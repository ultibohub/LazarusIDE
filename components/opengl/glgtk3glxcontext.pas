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
  Classes, SysUtils, ctypes, X, XUtil, XLib, gl, glext, glx,
  // LazUtils
  LazUtilities,
  // LCL
  LCLType, InterfaceBase, LMessages, Controls,
  WSLCLClasses, LCLMessageGlue,
  LazGLib2, gtk3int, LazGdk3, LazGtk3, LazGObject2, gtk3widgets;

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

procedure ensure_msaa_fbo(area: PGtkGLArea; st: PMSAAState; W, H: GLint);
var
  fmt: GLenum;
begin
  if not st^.GLLoaded then
  begin
    Load_GL_ARB_framebuffer_object(True);
    st^.GLLoaded := True;
  end;
  if (st^.FBO <> 0) and (st^.Width = W) and (st^.Height = H) then Exit;
  if st^.FBO = 0 then glGenFramebuffers(1, @st^.FBO);
  if st^.ColorRBO = 0 then glGenRenderbuffers(1, @st^.ColorRBO);

  glBindRenderbuffer(GL_RENDERBUFFER, st^.ColorRBO);
  glRenderbufferStorageMultisample(GL_RENDERBUFFER, st^.Samples, GL_RGBA8, W, H);

  if st^.HasDepth then
  begin
    if st^.DepthStencilRBO = 0 then glGenRenderbuffers(1, @st^.DepthStencilRBO);
    glBindRenderbuffer(GL_RENDERBUFFER, st^.DepthStencilRBO);
    if st^.HasStencil then
      fmt := GL_DEPTH24_STENCIL8
    else
      fmt := GL_DEPTH_COMPONENT24;
    glRenderbufferStorageMultisample(GL_RENDERBUFFER, st^.Samples, fmt, W, H);
  end;

  glBindFramebuffer(GL_FRAMEBUFFER, st^.FBO);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, st^.ColorRBO);
  if st^.HasDepth then
  begin
    if st^.HasStencil then
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, st^.DepthStencilRBO)
    else
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, st^.DepthStencilRBO);
  end;

  st^.Width := W;
  st^.Height := H;
end;

procedure on_render(widget: PGtkWidget; context: gpointer{Pcairo_t}; data: TGtk3Widget); cdecl;
var
  st: PMSAAState;
  default_fbo: GLint;
  W, H: GLint;
begin
  st := PMSAAState(g_object_get_data(PGObject(widget), 'lcl-msaa-state'));
  if (st = nil) or (st^.Samples <= 1) then
  begin
    data.LCLObject.Perform(LM_PAINT, WParam(data), 0);
    Exit;
  end;
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, @default_fbo);
  W := PGtkWidget(widget)^.get_allocated_width;
  H := PGtkWidget(widget)^.get_allocated_height;
  if (W <= 0) or (H <= 0) then
  begin
    data.LCLObject.Perform(LM_PAINT, WParam(data), 0);
    Exit;
  end;
  ensure_msaa_fbo(PGtkGLArea(widget), st, W, H);
  glBindFramebuffer(GL_FRAMEBUFFER, st^.FBO);
  data.LCLObject.Perform(LM_PAINT, WParam(data), 0);
  glBindFramebuffer(GL_READ_FRAMEBUFFER, st^.FBO);
  glBindFramebuffer(GL_DRAW_FRAMEBUFFER, default_fbo);
  glBlitFramebuffer(0, 0, W, H, 0, 0, W, H, GL_COLOR_BUFFER_BIT, GL_NEAREST);
  glBindFramebuffer(GL_FRAMEBUFFER, default_fbo);
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

function gtk_gl_area_get_error (area: PGtkGLArea): PGError; cdecl; external;

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
  if Handle=0 then exit;
  glFlush();
end;

function LOpenGLMakeCurrent(Handle: HWND): boolean;
var
  glarea: TGtk3GLArea absolute Handle;
begin
  glarea.Widget^.realize;
  PGtkGLArea(glarea.Widget)^.make_current;
  Assert(gtk_gl_area_get_error(PGtkGLArea(glarea.Widget)) = nil, 'LOpenGLMakeCurrent failed');
  result := true;
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
  glarea := PGtkGLArea(NewWidget.Widget);

  g_signal_connect_data(PGObject(glarea), 'render', TGCallback(@on_render), NewWidget, nil, []);
  g_signal_connect_data(PGObject(glarea), 'size-allocate', TGCallback(@gtkglarea_size_allocateCB), AWinControl, nil, [G_CONNECT_AFTER]);

  glarea^.set_auto_render(false);
  glarea^.set_required_version(MajorVersion, MinorVersion);
  glarea^.set_has_depth_buffer(DepthBits > 0);
  glarea^.set_has_alpha(AlphaBits > 0);
  glarea^.set_has_stencil_buffer(StencilBits > 0);

  if MultiSampling > 1 then
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

