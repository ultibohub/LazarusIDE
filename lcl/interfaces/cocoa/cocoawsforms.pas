{ $Id: cocoawsforms.pp 12783 2007-11-08 11:45:39Z tombo $}
{
 *****************************************************************************
 *                             CocoaWSForms.pp                               *
 *                               ------------                                *
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit CocoaWSForms;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}
{$include cocoadefines.inc}

interface

uses
  // RTL,FCL
  MacOSAll, CocoaAll, Classes,
  // LCL
  Controls, Forms, Graphics, LCLType, Messages, LMessages, LCLProc,
  // Widgetset
  WSForms, WSLCLClasses, WSProc, LCLMessageGlue,
  // LCL Cocoa
  CocoaPrivate, CocoaUtils, CocoaWSCommon, CocoaWSStdCtrls, CocoaWSMenus,
  CocoaGDIObjects,
  CocoaWindows, CocoaScrollers, cocoa_extra;

type
  { TLCLWindowCallback }

  TLCLWindowCallback = class(TLCLCommonCallBack, IWindowCallback)
  private
    IsActivating: boolean;
  public
    window : CocoaAll.NSWindow;
    constructor Create(AOwner: NSObject; ATarget: TWinControl; AHandleView: NSView); override;
    destructor Destroy; override;

    function CanActivate: Boolean; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure CloseQuery(var CanClose: Boolean); virtual;
    procedure Close; virtual;
    procedure Resize; virtual;
    procedure Move; virtual;
    procedure WindowStateChanged; virtual;

    function GetEnabled: Boolean; virtual;
    procedure SetEnabled(AValue: Boolean); virtual;

    function AcceptFilesDrag: Boolean;
    procedure DropFiles(const FileNames: array of string);

    function HasCancelControl: Boolean;
    function HasDefaultControl: Boolean;

    property Enabled: Boolean read GetEnabled write SetEnabled;
  end;


  { TCocoaWSScrollingWinControl }

  TCocoaWSScrollingWinControl = class(TWSScrollingWinControl)
  private
  protected
  public
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class procedure SetBorderStyle(const AWinControl: TWinControl; const ABorderStyle: TBorderStyle); override;
  end;

  { TCocoaWSScrollBox }

  TCocoaWSScrollBox = class(TWSScrollBox)
  private
  protected
  public
  end;

  { TCocoaWSCustomFrame }

  TCocoaWSCustomFrame = class(TWSCustomFrame)
  private
  protected
  public
  end;

  { TCocoaWSFrame }

  TCocoaWSFrame = class(TWSFrame)
  private
  protected
  public
  end;

  { TCocoaWSCustomForm }
  TCocoaWSCustomFormClass = class of TCocoaWSCustomForm;
  TCocoaWSCustomForm = class(TWSCustomForm)
  private
    class function GetStyleMaskFor(ABorderStyle: TFormBorderStyle; ABorderIcons: TBorderIcons): NSUInteger;
    class procedure UpdateWindowIcons(AWindow: NSWindow; ABorderStyle: TFormBorderStyle; ABorderIcons: TBorderIcons);
  public
    class procedure UpdateWindowMask(AWindow: NSWindow; ABorderStyle: TFormBorderStyle; ABorderIcons: TBorderIcons);
    class function GetWindowFromHandle(const ACustomForm: TCustomForm): TCocoaWindow;
    class function GetWindowContentFromHandle(const ACustomForm: TCustomForm): TCocoaWindowContent;
  published
    class function AllocWindowHandle: TCocoaWindow; virtual;
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class procedure DestroyHandle(const AWinControl: TWinControl); override;

    class function GetText(const AWinControl: TWinControl; var AText: String): Boolean; override;
    class function GetTextLen(const AWinControl: TWinControl; var ALength: Integer): Boolean; override;
    class procedure SetText(const AWinControl: TWinControl; const AText: String); override;

    class procedure CloseModal(const ACustomForm: TCustomForm); override;
    class procedure ShowModal(const ACustomForm: TCustomForm); override;
    class procedure SetModalResult(const ACustomForm: TCustomForm; ANewValue: TModalResult); override;

    class procedure SetAllowDropFiles(const AForm: TCustomForm; AValue: Boolean); override;
    class procedure SetAlphaBlend(const ACustomForm: TCustomForm; const AlphaBlend: Boolean; const Alpha: Byte); override;
    class procedure SetBorderIcons(const AForm: TCustomForm; const ABorderIcons: TBorderIcons); override;
    class procedure SetFormBorderStyle(const AForm: TCustomForm; const AFormBorderStyle: TFormBorderStyle); override;
    class procedure SetFormStyle(const AForm: TCustomform; const AFormStyle, AOldFormStyle: TFormStyle); override;
    class procedure SetIcon(const AForm: TCustomForm; const Small, Big: HICON); override;
    class procedure SetRealPopupParent(const ACustomForm: TCustomForm;
      const APopupParent: TCustomForm); override;
    class procedure ShowHide(const AWinControl: TWinControl); override;

    {need to override these }
    class function GetClientBounds(const AWincontrol: TWinControl; var ARect: TRect): Boolean; override;
    class function GetClientRect(const AWincontrol: TWinControl; var ARect: TRect): Boolean; override;
    class procedure SetBounds(const AWinControl: TWinControl; const ALeft, ATop, AWidth, AHeight: Integer); override;
  end;

  { TCocoaWSForm }

  TCocoaWSForm = class(TWSForm)
  private
  protected
  public
  end;

  { TCocoaWSHintWindow }

  TCocoaWSHintWindow = class(TWSHintWindow)
  private
  protected
  public
  published
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class procedure SetText(const AWinControl: TWinControl; const AText: String); override;
  end;

  { TCocoaWSScreen }

  TCocoaWSScreen = class(TWSScreen)
  private
  protected
  public
  end;

  { TCocoaWSApplicationProperties }

  TCocoaWSApplicationProperties = class(TWSApplicationProperties)
  private
  protected
  public
  end;

procedure ArrangeTabOrder(const AWinControl: TWinControl);
function HWNDToForm(AFormHandle: HWND): TCustomForm;
procedure WindowSetFormStyle(win: NSWindow; AFormStyle: TFormStyle);

var
  CocoaIconsStyle: Boolean = false;

implementation

uses
  GraphMath,
  CocoaInt;

const
  // The documentation is using constants like "NSNormalWindowLevel=4" for normal forms,
  // however, these are macros of a function call to CGWindowLevelKey()
  // where "Key" values of kCGNormalWindowLevelKey=4.

  FormStyleToWindowLevelKey: array[TFormStyle] of NSInteger = (
 { fsNormal          } kCGNormalWindowLevelKey,
 { fsMDIChild        } kCGNormalWindowLevelKey,
 { fsMDIForm         } kCGNormalWindowLevelKey,
 { fsStayOnTop       } kCGFloatingWindowLevelKey,
 { fsSplash          } kCGFloatingWindowLevelKey,
 { fsSystemStayOnTop } kCGFloatingWindowLevelKey  // NSModalPanelWindowLevel
  );
  // Window levels make the form always stay on top, so if it is supposed to
  // stay on top of the app only, then a workaround is to hide it while the app
  // is deactivated
  FormStyleToHideOnDeactivate: array[TFormStyle] of Boolean = (
 { fsNormal          } False,
 { fsMDIChild        } False,
 { fsMDIForm         } False,
 { fsStayOnTop       } false,
 { fsSplash          } false,
 { fsSystemStayOnTop } False
  );

  HintWindowLevel = 11;  // NSPopUpMenuWindowLevel

function GetDesigningBorderStyle(const AForm: TCustomForm): TFormBorderStyle;
begin
  if csDesigning in AForm.ComponentState then
    Result := bsSizeable
  else
    Result := AForm.BorderStyle;
end;

procedure WindowSetFormStyle(win: NSWindow; AFormStyle: TFormStyle);
var
  lvl : NSInteger;
begin
  lvl := CGWindowLevelForKey(FormStyleToWindowLevelKey[AFormStyle]);
  {$ifdef BOOLFIX}
  win.setHidesOnDeactivate_(Ord(FormStyleToHideOnDeactivate[AFormStyle]));
  {$else}
  win.setHidesOnDeactivate(FormStyleToHideOnDeactivate[AFormStyle]);
  {$endif}
  win.setLevel(lvl);
  if win.isKindOfClass(TCocoaWindow) then
    TCocoaWindow(win).keepWinLevel := lvl;
end;

{ TCocoaWSHintWindow }

class function TCocoaWSHintWindow.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
var
  win: TCocoaPanel;
  cnt: TCocoaWindowContent;
  R: NSRect;
  Form: TCustomForm absolute AWinControl;
  cb: TLCLWindowCallback;
  doc: TCocoaWindowContentDocument;
const
  WinMask = NSBorderlessWindowMask or NSUtilityWindowMask;
begin
  win := TCocoaPanel(TCocoaPanel.alloc);

  if not Assigned(win) then
  begin
    Result := 0;
    Exit;
  end;

  R := CreateParamsToNSRect(AParams);
  {$ifdef BOOLFIX}
  win := TCocoaPanel(win.initWithContentRect_styleMask_backing_defer_(R, WinMask, NSBackingStoreBuffered, Ord(False)));
  {$else}
  win := TCocoaPanel(win.initWithContentRect_styleMask_backing_defer(R, WinMask, NSBackingStoreBuffered, False));
  {$endif}
  win.setLevel(HintWindowLevel);
  win.setDelegate(win);
  {$ifdef BOOLFIX}
  win.setHasShadow_(Ord(true));
  {$else}
  win.setHasShadow(true);
  {$endif}
  if AWinControl.Perform(WM_NCHITTEST, 0, 0)=HTTRANSPARENT then
    {$ifdef BOOLFIX}
    win.setIgnoresMouseEvents_(Ord(True))
    {$else}
    win.setIgnoresMouseEvents(True)
    {$endif}
  else
    {$ifdef BOOLFIX}
    win.setAcceptsMouseMovedEvents_(Ord(True));
    {$else}
    win.setAcceptsMouseMovedEvents(True);
    {$endif}


  R.origin.x := 0;
  R.origin.y := 0;
  cnt := TCocoaWindowContent.alloc.initWithFrame(R);
  doc := TCocoaWindowContentDocument.alloc.initWithFrame(R);
  doc.setHidden(false);
  doc.setAutoresizesSubviews(true);
  doc.setAutoresizingMask(NSViewMaxXMargin or NSViewMinYMargin or NSViewHeightSizable or NSViewWidthSizable);
  cb := TLCLWindowCallback.Create(doc, AWinControl, cnt);
  doc.callback := cb;
  doc.wincallback := cb;
  cb.window := win;
  cnt.callback := cb;
  cnt.wincallback := cb;
  cnt.preventKeyOnShow := true;
  cnt.isCustomRange := true;
  cnt.setDocumentView(doc);
  cnt.setDrawsBackground(false); // everything is covered anyway
  TCocoaPanel(win).callback := cb;

  win.setContentView(cnt);
  doc.release;

  Result := TLCLHandle(cnt);
end;

class procedure TCocoaWSHintWindow.SetText(const AWinControl: TWinControl;
  const AText: String);
begin
  TCocoaWSCustomForm.SetText(AWinControl, AText);
  AWinControl.Invalidate;
end;

{ TLCLWindowCallback }

type
  TWinControlAccess = class(TWinControl)
  end;

function TLCLWindowCallback.CanActivate: Boolean;
begin
  Result := Enabled;
  // it's possible that a Modal window requests this (target) window
  // to become visible (i.e. when modal is closing)
  // All other Windows are disabled while modal is active.
  // Thus must check wcfUpdateShowing flag (which set when changing window visibility)
  // And if it's used, then we allow the window to become Key window
  if not Result and (Target is TWinControl) then
    Result := wcfUpdateShowing in TWinControlAccess(Target).FWinControlFlags;
end;

constructor TLCLWindowCallback.Create(AOwner: NSObject; ATarget: TWinControl; AHandleView: NSView);
begin
  inherited;
  IsActivating:=false;
end;

destructor TLCLWindowCallback.Destroy;
begin
  if Assigned(window) then window.lclClearCallback;
  inherited Destroy;
end;

procedure TLCLWindowCallback.Activate;
var
  ACustForm: TCustomForm;
  isDesign: Boolean;
begin
  if not IsActivating then
  begin
    IsActivating:=True;
    ACustForm := Target as TCustomForm;

    isDesign :=
      (csDesigning in ACustForm.ComponentState)
      or (
        Assigned(ACustForm.Menu)
        and (csDesigning in ACustForm.Menu.ComponentState)
      );

    // only adjust main menu, if the form is not being designed
    if not isDesign then
    begin
      if (ACustForm.Menu <> nil) and
         (ACustForm.Menu.HandleAllocated) then
      begin
        if NSObject(ACustForm.Menu.Handle).isKindOfClass_(TCocoaMenu) then
        begin
          CocoaWidgetSet.SetMainMenu(ACustForm.Menu.Handle, ACustForm.Menu);
        end
        else
          debugln('Warning: Menu does not have a valid handle.');
      end
      else
        CocoaWidgetSet.SetMainMenu(0, nil);
    end;

    LCLSendActivateMsg(Target, WA_ACTIVE, false);
    LCLSendSetFocusMsg(Target);
    // The only way to update Forms.ActiveCustomForm for the main form
    // is calling TCustomForm.SetFocusedControl, see bug 31056
    ACustForm.SetFocusedControl(ACustForm.ActiveControl);

    IsActivating:=False;

    if CocoaWidgetSet.isModalSession then
      NSView(ACustForm.Handle).window.orderFront(nil);
  end;
end;

procedure TLCLWindowCallback.Deactivate;
begin
  LCLSendActivateMsg(Target, WA_INACTIVE, false);
  LCLSendKillFocusMsg(Target);
end;

procedure TLCLWindowCallback.CloseQuery(var CanClose: Boolean);
var
  i: Integer;
begin
  // Message results : 0 - do nothing, 1 - destroy window
  CanClose := LCLSendCloseQueryMsg(Target) > 0;

  // Special code for modal forms, which otherwise would get 0 here and not call Close
  if (CocoaWidgetSet.CurModalForm = window) and
    (TCustomForm(Target).ModalResult <> mrNone) then
  begin
    {$IFDEF COCOA_USE_NATIVE_MODAL}
    NSApp.stopModal();
    {$ENDIF}
    CocoaWidgetSet.CurModalForm := nil;
    {// Felipe: This code forces focusing another form, its a work around
    // for a gdb issue, gdb doesn't start the app properly
    //
    // At this point the modal form is closed, but the previously open form isn't focused
    // Focus the main window if it is visible
    if Application.MainForm.Visible then Application.MainForm.SetFocus()
    else
    begin
      // if the mainform is hidden, just choose any visible form
      // ToDo: Figure out a better solution
      for i := 0 to Screen.FormCount-1 do
        if Screen.Forms[i].Visible then
        begin
          Screen.Forms[i].SetFocus();
          Break;
        end;
    end;}
  end;
end;

procedure TLCLWindowCallback.Close;
begin
  LCLSendCloseUpMsg(Target);
end;

procedure TLCLWindowCallback.Resize;
begin
  boundsDidChange(Owner);
end;

procedure TLCLWindowCallback.Move;
begin
  boundsDidChange(Owner);
end;

procedure TLCLWindowCallback.WindowStateChanged;
var
  Bounds: TRect;
begin
  Bounds := HandleFrame.lclFrame;
  LCLSendSizeMsg(Target, Bounds.Right - Bounds.Left, Bounds.Bottom - Bounds.Top,
    Owner.lclWindowState, True);
end;

function TLCLWindowCallback.GetEnabled: Boolean;
begin
  Result := Owner.lclIsEnabled;
end;

procedure TLCLWindowCallback.SetEnabled(AValue: Boolean);
begin
  Owner.lclSetEnabled(AValue);
end;

function TLCLWindowCallback.AcceptFilesDrag: Boolean;
begin
  Result := Assigned(Target)
    and TCustomForm(Target).AllowDropFiles
    and Assigned(TCustomForm(Target).OnDropFiles);
end;

procedure TLCLWindowCallback.DropFiles(const FileNames: array of string);
begin
  if Assigned(Target) then
    TCustomForm(Target).IntfDropFiles(FileNames);
end;

function TLCLWindowCallback.HasCancelControl: Boolean;
{ TODO: Should this be solved differently?  TForm/TApplication could expose a
  property to avoid duplicating them here and in TApplication.DoEscapeKey }
var
  lControl: TControl;
begin
  if Assigned(Target) and
     (anoEscapeForCancelControl in Application.Navigation) then
  begin
    lControl := TCustomForm(Target).CancelControl;
    Result := Assigned(lControl) and lControl.Enabled and lControl.Visible;
  end
  else
    Result := False;
end;

function TLCLWindowCallback.HasDefaultControl: Boolean;
{ TODO: Should this be solved differently?  TForm/TApplication could expose a
  property to avoid duplicating them here and in TApplication.DoReturnKey }
var
  lControl: TControl;
begin
  if Assigned(Target) and
     (anoReturnForDefaultControl in Application.Navigation) then
  begin
    lControl := TCustomForm(Target).ActiveDefaultControl;
    if lControl = nil then
      lControl := TCustomForm(Target).DefaultControl;
    Result := Assigned(lControl) and
      ((lControl.Parent = nil) or lControl.Parent.CanFocus) and
      lControl.Enabled and lControl.Visible;
  end
  else
    Result := False;
end;

{ TCocoaWSScrollingWinControl}

class function  TCocoaWSScrollingWinControl.CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle;
var
  scrollcon: TCocoaScrollView;
  docview: TCocoaCustomControl;
  lcl : TLCLCommonCallback;
begin
  docview := TCocoaCustomControl.alloc.lclInitWithCreateParams(AParams);
  scrollcon:=EmbedInScrollView(docView);
  scrollcon.setBackgroundColor(NSColor.windowBackgroundColor);
  scrollcon.setAutohidesScrollers(True);
  scrollcon.setHasHorizontalScroller(True);
  scrollcon.setHasVerticalScroller(True);
  scrollcon.isCustomRange := true;

  lcl := TLCLCommonCallback.Create(docview, AWinControl, scrollcon);
  lcl.BlockCocoaUpDown := true;
  docview.callback := lcl;
  docview.setAutoresizingMask(NSViewWidthSizable or NSViewHeightSizable);
  scrollcon.callback := lcl;
  scrollcon.setDocumentView(docview);
  ScrollViewSetBorderStyle(scrollcon, TScrollingWinControl(AWincontrol).BorderStyle);
  Result := TLCLHandle(scrollcon);
end;

class procedure TCocoaWSScrollingWinControl.SetBorderStyle(
  const AWinControl: TWinControl; const ABorderStyle: TBorderStyle);
begin
  if not Assigned(AWinControl) or not AWincontrol.HandleAllocated then Exit;
  ScrollViewSetBorderStyle( NSScrollView(AWinControl.Handle), ABorderStyle);
end;


{ TCocoaWSCustomForm }

procedure ArrangeTabOrder(const AWinControl: TWinControl);
var
  lList: TFPList;
  prevControl, curControl: TWinControl;
  lPrevView, lCurView: NSView;
  i: Integer;
begin
  lList := TFPList.Create;
  try
    AWinControl.GetTabOrderList(lList);
    if lList.Count>0 then
      begin
      prevControl := TWinControl(lList.Items[lList.Count-1]);
      lPrevView := NSObject(prevControl.Handle).lclContentView;
      for i := 0 to lList.Count-1 do
      begin
        curControl := TWinControl(lList.Items[i]);
        lCurView := NSObject(curControl.Handle).lclContentView;

        if (lCurView <> nil) and (lPrevView <> nil) then
          lPrevView.setNextKeyView(lCurView);

        lPrevView := lCurView;
      end;
    end;
  finally
    lList.Free;
  end;
end;


class function TCocoaWSCustomForm.GetStyleMaskFor(
  ABorderStyle: TFormBorderStyle; ABorderIcons: TBorderIcons): NSUInteger;
begin
  case ABorderStyle of
    bsSizeable, bsSizeToolWin:
      Result := NSTitledWindowMask or NSResizableWindowMask;
    bsSingle, bsDialog, bsToolWindow:
      Result := NSTitledWindowMask;
  else
    Result := NSBorderlessWindowMask;
  end;
  if biSystemMenu in ABorderIcons then
  begin
    Result := Result or NSClosableWindowMask;
    if biMinimize in ABorderIcons then
      Result := Result or NSMiniaturizableWindowMask;
  end;
end;

class procedure TCocoaWSCustomForm.UpdateWindowIcons(AWindow: NSWindow;
  ABorderStyle: TFormBorderStyle; ABorderIcons: TBorderIcons);

  procedure SetWindowButtonState(AButton: NSWindowButton; AEnabled, AVisible: Boolean);
  var
    Btn: NSButton;
  begin
    Btn := AWindow.standardWindowButton(AButton);
    if Assigned(Btn) then
    begin
      {$ifdef BOOLFIX}
      Btn.setHidden_(Ord(not AVisible));
      Btn.setEnabled_(Ord(AEnabled));
      {$else}
      Btn.setHidden(not AVisible);
      Btn.setEnabled(AEnabled);
      {$endif}
    end;
  end;

var
  btn : NSButton;
  url : NSURL;
  b   : NSBundle;

const
  // mimic Windows border styles
  isIconVisible : array [TFormBorderStyle] of Boolean = (
    false, // bsNone
    true,  // bsSingle
    true,  // bsSizeable
    false, // bsDialog
    false, // bsToolWindow
    false  // bsSizeToolWin
  );

begin
  SetWindowButtonState(NSWindowMiniaturizeButton, biMinimize in ABorderIcons, (ABorderStyle in [bsSingle, bsSizeable]) and (biSystemMenu in ABorderIcons));
  SetWindowButtonState(NSWindowZoomButton, (biMaximize in ABorderIcons) and (ABorderStyle in [bsSizeable, bsSizeToolWin]), (ABorderStyle in [bsSingle, bsSizeable]) and (biSystemMenu in ABorderIcons));
  SetWindowButtonState(NSWindowCloseButton, True, (ABorderStyle <> bsNone) and (biSystemMenu in ABorderIcons));

  if not CocoaInt.CocoaIconUse then
  begin
    btn := AWindow.standardWindowButton(NSWindowDocumentIconButton);
    url := nil;
    if isIconVisible[ABorderStyle] then
    begin
      b := NSBundle.mainBundle;
      if Assigned(b) then url := b.bundleURL;
    end;
    AWindow.setRepresentedURL(url);
  end;
end;

class procedure TCocoaWSCustomForm.UpdateWindowMask(AWindow: NSWindow;
  ABorderStyle: TFormBorderStyle; ABorderIcons: TBorderIcons);
var
  StyleMask: NSUInteger;
begin
  StyleMask := GetStyleMaskFor(ABorderStyle, ABorderIcons);
  AWindow.setStyleMask(StyleMask);
  UpdateWindowIcons(AWindow, ABorderStyle, ABorderIcons);
end;

class function TCocoaWSCustomForm.GetWindowFromHandle(const ACustomForm: TCustomForm): TCocoaWindow;
begin
  Result := nil;
  if not ACustomForm.HandleAllocated then Exit;
  Result := TCocoaWindow(TCocoaWindowContent(ACustomForm.Handle).lclOwnWindow);
end;

class function TCocoaWSCustomForm.GetWindowContentFromHandle(const ACustomForm: TCustomForm): TCocoaWindowContent;
begin
  Result := nil;
  if not ACustomForm.HandleAllocated then Exit;
  Result := TCocoaWindowContent(ACustomForm.Handle);
end;

// Some projects that use the LCL need to override this
class function TCocoaWSCustomForm.AllocWindowHandle: TCocoaWindow;
begin
  Result := TCocoaWindow(TCocoaWindow.alloc);
end;

class function TCocoaWSCustomForm.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
var
  Form: TCustomForm absolute AWinControl;
  win: TCocoaWindow;
  cnt: TCocoaWindowContent;
  doc: TCocoaWindowContentDocument;
  ns: NSString;
  R: NSRect;
  LR: NSRect;
  lDestView: NSView;
  ds: TCocoaDesignOverlay;
  cb: TLCLWindowCallback;
begin
  //todo: create TCocoaWindow or TCocoaPanel depending on the border style
  //      if parent is specified neither Window nor Panel needs to be created
  //      the only thing that needs to be created is Content

  R := CreateParamsToNSRect(AParams);
  if R.size.width<1 then R.size.width:=1;
  if R.size.height<1 then R.size.height:=1;

  LR := R;
  LR.origin.x := 0;
  LR.origin.y := 0;
  doc := TCocoaWindowContentDocument.alloc.initWithFrame(LR);
  cnt := TCocoaWindowContent.alloc.initWithFrame(R);
  cb := TLCLWindowCallback.Create(doc, AWinControl, cnt);

  cnt.callback := cb;
  doc.wincallback := cb;
  doc.callback := cb;
  cnt.wincallback := cb;
  cnt.isCustomRange := true;

  cnt.setDocumentView(doc);
  cnt.setDrawsBackground(false); // everything is covered anyway
  doc.setHidden(false);

  doc.setAutoresizesSubviews(true);
  doc.setAutoresizingMask(NSViewMaxXMargin or NSViewMinYMargin or NSViewHeightSizable or NSViewWidthSizable);

  if (AParams.Style and WS_CHILD) = 0 then
  begin

    win := AllocWindowHandle;

    if not Assigned(win) then
    begin
      Result := 0;
      Exit;
    end;

    {$ifdef BOOLFIX}
    win := TCocoaWindow(win.initWithContentRect_styleMask_backing_defer_(R,
      GetStyleMaskFor(GetDesigningBorderStyle(Form), Form.BorderIcons), NSBackingStoreBuffered, Ord(False)));
    {$else}
    win := TCocoaWindow(win.initWithContentRect_styleMask_backing_defer(R,
      GetStyleMaskFor(GetDesigningBorderStyle(Form), Form.BorderIcons), NSBackingStoreBuffered, False));
    {$endif}
    UpdateWindowIcons(win, GetDesigningBorderStyle(Form), Form.BorderIcons);
    // For safety, it is better to not apply any setLevel & similar if the form is just a standard style
    // see issue http://bugs.freepascal.org/view.php?id=28473
    if not (csDesigning in AWinControl.ComponentState) then
      WindowSetFormStyle(win, Form.FormStyle);

    TCocoaWindow(win).callback := cb;
    cb.window := win;

    win.setDelegate(win);
    ns := NSStringUtf8(AWinControl.Caption);
    win.setTitle(ns);
    ns.release;
    {$ifdef BOOLFIX}
    win.setReleasedWhenClosed_(Ord(False)); // do not release automatically
    win.setAcceptsMouseMovedEvents_(Ord(True));
    {$else}
    win.setReleasedWhenClosed(False); // do not release automatically
    win.setAcceptsMouseMovedEvents(True);
    {$endif}

    if win.respondsToSelector(ObjCSelector('setTabbingMode:')) then
      win.setTabbingMode(NSWindowTabbingModeDisallowed);

    if AWinControl.Perform(WM_NCHITTEST, 0, 0)=HTTRANSPARENT then
    begin
      {$ifdef BOOLFIX}
      win.setIgnoresMouseEvents_(Ord(True));
      {$else}
      win.setIgnoresMouseEvents(True);
      {$endif}
    end;

    cnt.callback.IsOpaque:=true;
    cnt.wincallback := TCocoaWindow(win).callback;
    win.setContentView(cnt);

    // Don't call addChildWindow_ordered here because this function can cause
    // events to arrive for this window, creating a second call to TCocoaWSCustomForm.CreateHandle
    // while the first didn't finish yet, instead delay the call
    cnt.popup_parent := AParams.WndParent;
  end
  else
  begin
    if AParams.WndParent <> 0 then
    begin
      cnt.isembedded:= true;
      lDestView := NSObject(AParams.WndParent).lclContentView;
      lDestView.addSubView(cnt);
      //cnt.setAutoresizingMask(NSViewMaxXMargin or NSViewMinYMargin);
      if cnt.window <> nil then
         cnt.window.setAcceptsMouseMovedEvents(True);
      cnt.callback.IsOpaque:=true;
      //  todo: We have to find a way to remove the following notifications save before cnt will be released
      //  NSNotificationCenter.defaultCenter.addObserver_selector_name_object(cnt, objcselector('didBecomeKeyNotification:'), NSWindowDidBecomeKeyNotification, cnt.window);
      //  NSNotificationCenter.defaultCenter.addObserver_selector_name_object(cnt, objcselector('didResignKeyNotification:'), NSWindowDidResignKeyNotification, cnt.window);
    end;
  end;

  if IsFormDesign(AWinControl) then begin
    ds:=(TCocoaDesignOverlay.alloc).initWithFrame(cnt.frame);
    ds.callback := cnt.callback;
    ds.setFrame( NSMakeRect(0,0, cnt.frame.size.width, cnt.frame.size.height));
    ds.setAutoresizingMask(
      //NSViewWidthSizable or NSViewHeightSizable
      NSViewMinXMargin
      or NSViewWidthSizable
      or NSViewMaxXMargin
      or NSViewMinYMargin
      or NSViewHeightSizable
      or NSViewMaxYMargin
    );

    cnt.addSubview_positioned_relativeTo(ds, NSWindowAbove, nil);
    doc.overlay := ds;
    ds.release;
  end;
  doc.release;

  Result := TLCLHandle(cnt);
end;

class procedure TCocoaWSCustomForm.DestroyHandle(const AWinControl: TWinControl
  );
var
  win : NSWindow;
  cb  : ICommonCallback;
  obj : TObject;
  wcb : TLCLWindowCallback;
begin
  if not AWinControl.HandleAllocated then
    Exit;

  win := TCocoaWindowContent(AWinControl.Handle).lclOwnWindow;

  if Assigned(win) then
  begin
    // this is needed for macOS 10.6.
    // if window has been created with a parent (on ShowModal)
    // it should be removed from "parentWindow"
    if Assigned(win.parentWindow) then
      win.parentWindow.removeChildWindow(win);
    win.setLevel(NSNormalWindowLevel);
    win.close;
    win.setContentView(nil);
    cb := win.lclGetCallback();
    if Assigned(cb) then
    begin
      obj := cb.GetCallbackObject;
      if (obj is TLCLWindowCallback) then
        TLCLWindowCallback(obj).window := nil;
    end;
    win.lclClearCallback();
    win.release;
  end;

  TCocoaWSWinControl.DestroyHandle(AWinControl);
end;


class function TCocoaWSCustomForm.GetText(const AWinControl: TWinControl; var AText: String): Boolean;
var
  win : NSWindow;
begin
  Result := AWinControl.HandleAllocated;
  if Result then
  begin
    win := TCocoaWindowContent(AWinControl.Handle).lclOwnWindow;
    if not Assigned(win) then
      AText := NSStringToString(TCocoaWindowContent(AWinControl.Handle).stringValue)
    else
      AText := NSStringToString(win.title);
  end;
end;

class function TCocoaWSCustomForm.GetTextLen(const AWinControl: TWinControl; var ALength: Integer): Boolean;
var
  win : NSWindow;
begin
  Result := AWinControl.HandleAllocated;
  if Result then
  begin
    win := TCocoaWindowContent(AWinControl.Handle).lclOwnWindow;
    if Assigned(win) then
      ALength := NSWindow(AWinControl.Handle).title.length
    else
    begin
      ALength := TCocoaWindowContent(AWinControl.Handle).stringValue.length
    end;
  end;
end;

class procedure TCocoaWSCustomForm.SetText(const AWinControl: TWinControl; const AText: String);
var
  ns: NSString;
  win : NSWindow;
begin
  if not AWinControl.HandleAllocated then
    Exit;
  win := TCocoaWindowContent(AWinControl.Handle).lclOwnWindow;
  ns := NSStringUtf8(AText);
  if Assigned(win) then
    NSwindow(win).setTitle(ns)
  else
    TCocoaWindowContent(AWinControl.Handle).setStringValue(ns);
  ns.release;
end;

class procedure TCocoaWSCustomForm.CloseModal(const ACustomForm: TCustomForm);
begin
  CocoaWidgetSet.EndModal(NSView(ACustomForm.Handle).window);
end;

class procedure TCocoaWSCustomForm.ShowModal(const ACustomForm: TCustomForm);
var
  lWinContent: TCocoaWindowContent;
  win: TCocoaWindow;
  {$ifdef COCOA_USE_NATIVE_MODAL}
  win: TCocoaWindow;
  {$endif}
  fullscreen: Boolean;
begin
  // Another possible implementation is to have modal started in ShowHide with (fsModal in AForm.FormState)

  // Handle PopupParent
  lWinContent := GetWindowContentFromHandle(ACustomForm);

  fullscreen := ACustomForm.WindowState = wsFullScreen;
  if (not fullscreen) and (lWinContent.window.isKindOfClass(TCocoaWindow)) then
    fullscreen := TCocoaWindow(lWinContent.window).lclIsFullScreen;

  // A window opening in full screen doesn't like to be added as someones popup
  // Thus resolvePopupParent should only be used for non full-screens forms
  //if (lWinContent <> nil) and (not fullscreen) then
    //lWinContent.resolvePopupParent();

  CocoaWidgetSet.CurModalForm := lWinContent.lclOwnWindow;
  // LCL initialization code would cause the custom form to be disabled
  // (due to the fact, ShowModal() has not been called yet, and a previous form
  // might be disabled at the time.
  // ...
  // The fact there's a single global variable is used to indicate, that there's
  // a modal form (neglecting the need for stack of modal forms)
  // makes a developer want to rewrite the whole approach for something more
  // Cocoa and good-practicies friendly.
  // ...
  // At this point of time, we simply force enabling of the new modal form
  // (which is happening in LCL code, but at the wrong time)
  NSObject(ACustomForm.Handle).lclSetEnabled(true);

  // Another possible implementation is using a session, but this requires
  //  disabling the other windows ourselves
  win := TCocoaWSCustomForm.GetWindowFromHandle(ACustomForm);
  if win = nil then Exit;
  CocoaWidgetSet.StartModal(NSView(ACustomForm.Handle).window, Assigned(ACustomForm.Menu));

  // Another possible implementation is using runModalForWindow
  {$ifdef COCOA_USE_NATIVE_MODAL}
  win := TCocoaWSCustomForm.GetWindowFromHandle(ACustomForm);
  if win = nil then Exit;
  NSApp.runModalForWindow(win);
  {$endif}
end;

// If ShowModal will not be fully blocking in the future this can be removed
class procedure TCocoaWSCustomForm.SetModalResult(const ACustomForm: TCustomForm;
  ANewValue: TModalResult);
begin
  if (CocoaWidgetSet.CurModalForm = NSView(ACustomForm.Handle).window) and (ANewValue <> 0) then
    CloseModal(ACustomForm);
end;

class procedure TCocoaWSCustomForm.SetAllowDropFiles(const AForm: TCustomForm;
  AValue: Boolean);
var
  view : NSView;
begin
  if AForm.HandleAllocated then
  begin
    view := NSView(AForm.Handle).lclContentView;
    if AValue then
      view.registerForDraggedTypes(NSArray.arrayWithObjects_count(@NSFilenamesPboardType, 1))
    else
      view.unregisterDraggedTypes
  end;
end;

class procedure TCocoaWSCustomForm.SetAlphaBlend(const ACustomForm: TCustomForm; const AlphaBlend: Boolean; const Alpha: Byte);
var
  win : NSWindow;
begin
  if ACustomForm.HandleAllocated then
  begin
    win := TCocoaWindowContent(ACustomForm.Handle).lclOwnWindow;
    if not Assigned(win) then
      Exit;
    if AlphaBlend then
      win.setAlphaValue(Alpha / 255)
    else
      win.setAlphaValue(1);
  end;
end;

class procedure TCocoaWSCustomForm.SetBorderIcons(const AForm: TCustomForm;
  const ABorderIcons: TBorderIcons);
var
  win : NSWindow;
begin
  if AForm.HandleAllocated then
  begin
    win := NSWindow(TCocoaWindowContent(AForm.Handle).lclOwnWindow);
    if Assigned(win) then
      UpdateWindowMask(win, GetDesigningBorderStyle(AForm), ABorderIcons);
  end;
end;

class procedure TCocoaWSCustomForm.SetFormBorderStyle(const AForm: TCustomForm;
  const AFormBorderStyle: TFormBorderStyle);
var
  win : NSWindow;
begin
  if AForm.HandleAllocated then
  begin
    win := NSWindow(TCocoaWindowContent(AForm.Handle).lclOwnWindow);
    if Assigned(win) then
      UpdateWindowMask(win, AFormBorderStyle, AForm.BorderIcons);
  end;
end;

class procedure TCocoaWSCustomForm.SetFormStyle(const AForm: TCustomform;
  const AFormStyle, AOldFormStyle: TFormStyle);
var
  win : NSWindow;
begin
  if AForm.HandleAllocated and not (csDesigning in AForm.ComponentState) then
  begin
    win := TCocoaWindowContent(AForm.Handle).lclOwnWindow;
    WindowSetFormStyle(win, AFormStyle);
  end;
end;

class procedure TCocoaWSCustomForm.SetIcon(const AForm: TCustomForm;
  const Small, Big: HICON);
var
  win : NSWindow;
  trg : NSImage;
  btn : NSButton;
begin
  if CocoaInt.CocoaIconUse then Exit;
  if not AForm.HandleAllocated then Exit;

  win := TCocoaWindowContent(AForm.Handle).lclOwnWindow;
  if Assigned(win) then
  begin
    if Small <> 0 then
      trg := TCocoaBitmap(Small).image
    else if Big <> 0 then
      trg := TCocoaBitmap(Big).image
    else
      trg := nil;

    btn := win.standardWindowButton(NSWindowDocumentIconButton);
    if Assigned(btn) then btn.setImage(trg);
  end;
end;

class procedure TCocoaWSCustomForm.SetRealPopupParent(
  const ACustomForm: TCustomForm; const APopupParent: TCustomForm);
var
  win : NSWindow;
begin
  if not ACustomForm.HandleAllocated then Exit;

  win := TCocoaWindowContent(ACustomForm.Handle).lclOwnWindow;
  if Assigned(win.parentWindow) then
    win.parentWindow.removeChildWindow(win);
  if Assigned(APopupParent) then begin
     writeln('SetRealPopupParent ',APopupParent.ClassName);
    NSWindow( NSView(APopupParent.Handle).window).addChildWindow_ordered(win, NSWindowAbove);
  end;
end;

class procedure TCocoaWSCustomForm.ShowHide(const AWinControl: TWinControl);
var
  lShow : Boolean;
  w : NSWindow;
begin
  lShow := AWinControl.HandleObjectShouldBeVisible;
  // TCustomForm class of LCL doesn't do anything specific about first time showing
  // of wsFullScreen window. Thus it should be taken care of in WS size
  if lShow and (TCustomForm(AWinControl).WindowState = wsFullScreen) then
  begin
    w := NSView(AWinControl.Handle).window;
    if Assigned(w) and (w.isKindOfClass(TCocoaWindow)) then
      TCocoaWindow(w).lclSwitchFullScreen(true);
  end
  else
  begin
    w := TCocoaWindowContent(AWinControl.Handle).lclOwnWindow;
    if not lShow then
    begin
      // macOS 10.6. If a window with a parent window is hidden, then parent is also hidden.
      // Detaching from the parent first!
      if Assigned(w) and Assigned(w.parentWindow) then
        w.parentWindow.removeChildWindow(w);
      // if the same control needs to be shown again, it will be redrawn
      // without this invalidation, Cocoa might should the previously cached contents
      TCocoaWindowContent(AWinControl.Handle).documentView.setNeedsDisplay_(true);
    end;
    TCocoaWSWinControl.ShowHide(AWinControl);

    // ShowHide() also actives (sets focus to) the window
    if lShow and Assigned(w) and not (w.isKindOfClass(NSPanel)) then
      w.makeKeyWindow;
  end;

  if (lShow) then
    ArrangeTabOrder(AWinControl);
end;

class function TCocoaWSCustomForm.GetClientBounds(
  const AWincontrol: TWinControl; var ARect: TRect): Boolean;
begin
  Result := False;
  if not AWinControl.HandleAllocated then Exit;
  ARect := NSObject(AWinControl.Handle).lclClientFrame;
  Result := True;
end;

class function TCocoaWSCustomForm.GetClientRect(const AWincontrol: TWinControl;
  var ARect: TRect): Boolean;
var
  x, y: Integer;
begin
  Result := AWinControl.HandleAllocated;
  if not Result then Exit;
  ARect := NSObject(AWinControl.Handle).lclClientFrame;
  x := 0;
  y := 0;
  NSObject(AWinControl.Handle).lclLocalToScreen(x, y);
  MoveRect(ARect, x, y);
end;

class procedure TCocoaWSCustomForm.SetBounds(const AWinControl: TWinControl;
  const ALeft, ATop, AWidth, AHeight: Integer);
begin
  if AWinControl.HandleAllocated then
  begin
    //debugln('TCocoaWSCustomForm.SetBounds: '+AWinControl.Name+'Bounds='+dbgs(Bounds(ALeft, ATop, AWidth, AHeight)));
    NSObject(AWinControl.Handle).lclSetFrame(Bounds(ALeft, ATop, AWidth, AHeight));
    TCocoaWindowContent(AwinControl.Handle).callback.boundsDidChange(NSObject(AWinControl.Handle));
  end;
end;

function HWNDToForm(AFormHandle: HWND): TCustomForm;
var
  obj : TObject;
begin
  obj := HWNDToTargetObject(AFormHandle);
  if Assigned(obj) and (obj is TCustomForm)
    then Result := TCustomForm(obj)
    else Result := nil;
end;

end.
