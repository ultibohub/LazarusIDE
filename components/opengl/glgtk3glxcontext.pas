{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}

unit GLGtk3GlxContext;

{$mode objfpc}
{$LinkLib GL}

interface

uses
  Classes, SysUtils, gl, glext,
  // LazUtils
  LazUtilities,
  // LCL
  LCLType, InterfaceBase, LMessages, Controls,
  WSLCLClasses, LCLMessageGlue,
  LazGLib2, gtk3int, LazGdk3, LazGtk3, LazGObject2, gtk3widgets, gtk3objects;

function LBackingScaleFactor(Handle: HWND): single;
procedure LOpenGLViewport({%H-}Handle: HWND; Left, Top, Width, Height: integer);
procedure LOpenGLSwapBuffers(Handle: HWND);
function LOpenGLMakeCurrent(Handle: HWND): boolean;
function LOpenGLReleaseContext({%H-}Handle: HWND): boolean;
function LOpenGLCreateContext(AWinControl: TWinControl;
             WSPrivate: TWSPrivateClass; SharedControl: TWinControl;
             DoubleBuffered, RGBA, DebugContext: boolean;
             const RedBits, GreenBits, BlueBits, MajorVersion, MinorVersion,
             MultiSampling, AlphaBits, DepthBits, StencilBits, AUXBuffers: Cardinal;
             const AParams: TCreateParams): HWND;
procedure LOpenGLDestroyContextInfo(AWinControl: TWinControl);

implementation

{$assertions on}

type
  PMSAAState = ^TMSAAState;
  TMSAAState = record
    Samples: GLint;
    Width, Height: GLint;
    FBO, ColorRBO, DepthStencilRBO: GLuint;
    HasDepth, HasStencil: gboolean;
    GLLoaded: Boolean;
  end;

procedure msaa_state_free(data: gPointer); cdecl;
var
  st: PMSAAState;
begin
  st := PMSAAState(data);
  if st = nil then Exit;
  if st^.FBO <> 0 then glDeleteFramebuffers(1, @st^.FBO);
  if st^.ColorRBO <> 0 then glDeleteRenderbuffers(1, @st^.ColorRBO);
  if st^.DepthStencilRBO <> 0 then glDeleteRenderbuffers(1, @st^.DepthStencilRBO);
  Dispose(st);
end;

function ensure_msaa_fbo(area: PGtkGLArea; st: PMSAAState; W, H: GLint): gboolean;
var
  status: GLenum;
  maxSamples: GLint;
  effectiveSamples: GLint;
begin
  Result := False;
  if not st^.GLLoaded then
  begin
    Load_GL_ARB_framebuffer_object(True);
    st^.GLLoaded := True;
  end;
  if (st^.FBO <> 0) and (st^.Width = W) and (st^.Height = H) then
  begin
    glBindFramebuffer(GL_FRAMEBUFFER, st^.FBO);
    Result := True;
    Exit;
  end;

  // Clamp requested samples to driver max
  glGetIntegerv(GL_MAX_SAMPLES, @maxSamples);
  effectiveSamples := st^.Samples;
  if effectiveSamples > maxSamples then effectiveSamples := maxSamples;
  if effectiveSamples < 2 then Exit;

  if st^.FBO = 0 then glGenFramebuffers(1, @st^.FBO);
  if st^.ColorRBO = 0 then glGenRenderbuffers(1, @st^.ColorRBO);

  glBindRenderbuffer(GL_RENDERBUFFER, st^.ColorRBO);

  //GtkGLArea uses a GL_RGBA8 texture for its color attachment regardless of
  //has_alpha (per gtkglarea.c). Match that format so blit-resolve works.
  glRenderbufferStorageMultisample(GL_RENDERBUFFER, effectiveSamples, GL_RGBA8, W, H);

  //Use combined depth+stencil if either is requested, single format avoids most
  //driver completeness issues.
  if st^.HasDepth or st^.HasStencil then
  begin
    if st^.DepthStencilRBO = 0 then glGenRenderbuffers(1, @st^.DepthStencilRBO);
    glBindRenderbuffer(GL_RENDERBUFFER, st^.DepthStencilRBO);
    glRenderbufferStorageMultisample(GL_RENDERBUFFER, effectiveSamples, GL_DEPTH24_STENCIL8, W, H);
  end;

  glBindFramebuffer(GL_FRAMEBUFFER, st^.FBO);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, st^.ColorRBO);
  if st^.HasDepth or st^.HasStencil then
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, st^.DepthStencilRBO);

  status := glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if status <> GL_FRAMEBUFFER_COMPLETE then Exit;

  st^.Width := W;
  st^.Height := H;
  Result := True;
end;

type
  PGLContextRequest = ^TGLContextRequest;
  TGLContextRequest = record
    MajorVersion, MinorVersion: gint;
    DebugContext: gboolean;
  end;

procedure context_request_free(data: gPointer; {%H-}closure: PGClosure); cdecl;
begin
  if data <> nil then Dispose(PGLContextRequest(data));
end;

function on_create_context(area: PGtkGLArea; data: gPointer): PGdkGLContext; cdecl;
var
  req: PGLContextRequest;
  ctx: PGdkGLContext;
  err: PGError;
  win: PGdkWindow;
begin
  Result := nil;
  req := PGLContextRequest(data);
  win := gtk_widget_get_window(PGtkWidget(area));
  if win = nil then Exit;
  err := nil;
  ctx := gdk_window_create_gl_context(win, @err);
  if (err <> nil) or (ctx = nil) then Exit;
  gdk_gl_context_set_use_es(ctx, 0);
  gdk_gl_context_set_forward_compatible(ctx, False);
  if (req <> nil) and ((req^.MajorVersion > 3) or
     ((req^.MajorVersion = 3) and (req^.MinorVersion >= 2))) then
    gdk_gl_context_set_required_version(ctx, req^.MajorVersion, req^.MinorVersion)
  else
    gdk_gl_context_set_required_version(ctx, 3, 2);
  if (req <> nil) and req^.DebugContext then
    gdk_gl_context_set_debug_enabled(ctx, True);
  if not gdk_gl_context_realize(ctx, @err) then
  begin
    g_object_unref(ctx);
    Exit;
  end;
  Result := ctx;
end;

function on_render(widget: PGtkWidget; gl_context: PGdkGLContext; data: TGtk3Widget): gboolean; cdecl;
var
  st: PMSAAState;
  W, H: GLint;
  scale: GLint;
  DC: TGtk3DeviceContext;
  msaa_active: Boolean;
begin
  Result := gtk_true;
  if (data = nil) or (data.LCLObject = nil) then
    exit;

  PGtkGLArea(widget)^.make_current;
  PGtkGLArea(widget)^.attach_buffers;

  scale := gtk_widget_get_scale_factor(widget);
  if scale < 1 then
    scale := 1;
  W := PGtkWidget(widget)^.get_allocated_width * scale;
  H := PGtkWidget(widget)^.get_allocated_height * scale;
  if (W <= 0) or (H <= 0) then
    exit;

  glViewport(0, 0, W, H);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_SCISSOR_TEST);

  st := PMSAAState(g_object_get_data(PGObject(widget), 'lcl-msaa-state'));
  msaa_active := (st <> nil) and (st^.Samples > 1)
                 and ensure_msaa_fbo(PGtkGLArea(widget), st, W, H);
  if msaa_active then
    glEnable(GL_MULTISAMPLE)
  else
    glDisable(GL_MULTISAMPLE);

  glClearColor(0.0, 0.0, 0.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

  DC := TGtk3DeviceContext.Create(widget, False);
  try
    data.LCLObject.Perform(LM_PAINT, WPARAM(DC), 0);
    glFlush;

    if msaa_active then
    begin
      PGtkGLArea(widget)^.attach_buffers;
      glBindFramebuffer(GL_READ_FRAMEBUFFER, st^.FBO);
      glReadBuffer(GL_COLOR_ATTACHMENT0);
      glBlitFramebuffer(0, 0, W, H, 0, 0, W, H, GL_COLOR_BUFFER_BIT, GL_NEAREST);
      PGtkGLArea(widget)^.attach_buffers;
      glDisable(GL_MULTISAMPLE);
    end;
  finally
    DC.Free;
  end;
end;

function gtkglarea_size_allocateCB(Widget: PGtkWidget; Size: pGtkAllocation; Data: gPointer): GBoolean; cdecl;
var
  SizeMsg: TLMSize;
  GtkWidth, GtkHeight: integer;
  LCLControl: TWinControl;
begin
  Result := true;
  LCLControl:=TWinControl(Data);
  if LCLControl=nil then exit;

  gtk_widget_get_size_request(Widget, @GtkWidth, @GtkHeight);

  SizeMsg.Msg:=0;
  FillChar(SizeMsg,SizeOf(SizeMsg),0);
  with SizeMsg do
  begin
    Result := 0;
    Msg := LM_SIZE;
    SizeType := Size_SourceIsInterface;
    Width := SmallInt(GtkWidth);
    Height := SmallInt(GtkHeight);
  end;
  LCLControl.WindowProc(TLMessage(SizeMsg));
end;

function LBackingScaleFactor(Handle: HWND): single;
var
  glarea: TGtk3GLArea absolute Handle;
begin
  if Assigned(glarea) then begin
    Result := glarea.GetWindow^.get_scale_factor;
  end else begin
    Result := 1;
  end;
end;

procedure LOpenGLViewport(Handle: HWND; Left, Top, Width, Height: integer);
var
  scaleFactor: integer;
begin
  scaleFactor := RoundToInt(LBackingScaleFactor(Handle));
  glViewport(Left,Top,Width*scaleFactor,Height*scaleFactor);
end;

procedure LOpenGLSwapBuffers(Handle: HWND);
var
  glarea: TGtk3GLArea absolute Handle;
begin
  if Handle = 0 then
    exit;
  glFlush();
  if Assigned(glarea) then
    PGtkGLArea(glarea.Widget)^.queue_render;
end;

function LOpenGLMakeCurrent(Handle: HWND): boolean;
var
  glarea: TGtk3GLArea absolute Handle;
begin
  if Handle = 0 then
    exit(False);
  glarea.Widget^.realize;
  PGtkGLArea(glarea.Widget)^.make_current;
  Assert(gtk_gl_area_get_error(PGtkGLArea(glarea.Widget)) = nil, 'LOpenGLMakeCurrent failed');
  Result := True;
end;

function LOpenGLReleaseContext(Handle: HWND): boolean;
begin
  Result := True;
end;

function LOpenGLCreateContext(AWinControl: TWinControl;
  WSPrivate: TWSPrivateClass; SharedControl: TWinControl;
  DoubleBuffered, RGBA, DebugContext: boolean;
  const RedBits, GreenBits, BlueBits, MajorVersion, MinorVersion,
  MultiSampling, AlphaBits, DepthBits, StencilBits, AUXBuffers: Cardinal;
  const AParams: TCreateParams): HWND;
var
  NewWidget: TGtk3GLArea;
  glarea: PGtkGLArea;
  st: PMSAAState;
  shared_glarea: PGtkGLArea;
  ctxReq: PGLContextRequest;
begin
  if (SharedControl <> nil) and SharedControl.HandleAllocated and
     (TObject(SharedControl.Handle) is TGtk3GLArea) then
  begin
    shared_glarea := PGtkGLArea(TGtk3GLArea(SharedControl.Handle).Widget);
    if shared_glarea <> nil then
    begin
      PGtkWidget(shared_glarea)^.realize;
      shared_glarea^.make_current;
    end;
  end;

  NewWidget := TGtk3GLArea.Create(AWinControl, AParams);
  result := TLCLHandle(NewWidget);

  //Designer uses DrawingArea, fixes issue #42185
  if csDesigning in AWinControl.ComponentState then
    exit;

  glarea := PGtkGLArea(NewWidget.Widget);

  glarea^.set_auto_render(False);
  glarea^.set_has_depth_buffer(DepthBits > 0);
  glarea^.set_has_alpha(AlphaBits > 0);
  glarea^.set_has_stencil_buffer(StencilBits > 0);

  New(ctxReq);
  ctxReq^.MajorVersion := MajorVersion;
  ctxReq^.MinorVersion := MinorVersion;
  ctxReq^.DebugContext := DebugContext;
  g_signal_connect_data(PGObject(glarea), 'create-context', TGCallback(@on_create_context), ctxReq, @context_request_free, []);
  g_signal_connect_data(PGObject(glarea), 'render', TGCallback(@on_render), NewWidget, nil, []);
  g_signal_connect_data(PGObject(glarea), 'size-allocate', TGCallback(@gtkglarea_size_allocateCB), AWinControl, nil, [G_CONNECT_AFTER]);

  if (MultiSampling > 1) then
  begin
    New(st);
    FillChar(st^, SizeOf(TMSAAState), 0);
    st^.Samples := MultiSampling;
    st^.HasDepth := DepthBits > 0;
    st^.HasStencil := StencilBits > 0;
    g_object_set_data_full(PGObject(glarea), 'lcl-msaa-state', st, @msaa_state_free);
  end;
end;

procedure LOpenGLDestroyContextInfo(AWinControl: TWinControl);
begin
  if not AWinControl.HandleAllocated then exit;
  // nothing to do
end;

end.

