{ $Id: $}
{                  --------------------------------------------
                  cocoawindows.pas  -  Cocoa internal classes
                  --------------------------------------------

 This unit contains the private classhierarchy for the Cocoa implemetations

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit CocoaWindows;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}
{$modeswitch objectivec2}
{$interfaces corba}
{$include cocoadefines.inc}

interface

uses
  // rtl+ftl
  Types, Classes, SysUtils,
  CGGeometry,
  // Libs
  MacOSAll, CocoaAll, CocoaUtils, CocoaWScommon,
  cocoa_extra, CocoaPrivate, CocoaTextEdits, CocoaScrollers,
  // LCL
  //Forms,
  LCLType, LCLProc;

type

  { LCLWindowExtension }

  LCLWindowExtension = objccategory(NSWindow)
    function lclIsVisible: Boolean; message 'lclIsVisible'; reintroduce;
    procedure lclSetVisible(AVisible: Boolean); message 'lclSetVisible:'; reintroduce;
    function lclIsEnabled: Boolean; message 'lclIsEnabled'; reintroduce;
    procedure lclSetEnabled(AEnabled: Boolean); message 'lclSetEnabled:'; reintroduce;

    function lclWindowState: Integer; message 'lclWindowState'; reintroduce;
    procedure lclInvalidateRect(const r: TRect); message 'lclInvalidateRect:'; reintroduce;
    procedure lclInvalidate; message 'lclInvalidate'; reintroduce;
    procedure lclUpdate; message 'lclUpdate'; reintroduce;
    procedure lclRelativePos(var Left, Top: Integer); message 'lclRelativePos::'; reintroduce;
    procedure lclLocalToScreen(var X, Y: Integer); message 'lclLocalToScreen::'; reintroduce;
    procedure lclScreenToLocal(var X, Y: Integer); message 'lclScreenToLocal::'; reintroduce;
    function lclFrame: TRect; message 'lclFrame'; reintroduce;
    procedure lclSetFrame(const r: TRect); message 'lclSetFrame:'; reintroduce;
    function lclClientFrame: TRect; message 'lclClientFrame'; reintroduce;
    function lclGetTopBarHeight:integer; message 'lclGetTopBarHeight'; reintroduce;
    procedure lclOffsetMousePos(var Point: NSPoint); message 'lclOffsetMousePos:'; reintroduce;
  end;

  { IWindowCallback }

  IWindowCallback = interface(ICommonCallBack)
    function CanActivate: Boolean;
    procedure Activate;
    procedure Deactivate;
    procedure CloseQuery(var CanClose: Boolean);
    procedure Close;
    procedure Resize;
    procedure Move;
    procedure WindowStateChanged;

    function GetEnabled: Boolean;
    procedure SetEnabled(AValue: Boolean);

    function AcceptFilesDrag: Boolean;
    procedure DropFiles(const FileNames: array of string);

    function HasCancelControl: Boolean;
    function HasDefaultControl: Boolean;

    property Enabled: Boolean read GetEnabled write SetEnabled;
  end;

  { TCocoaPanel }

  TCocoaPanel = objcclass(NSPanel, NSWindowDelegateProtocol)
  protected
    function windowShouldClose(sender : id): LongBool; message 'windowShouldClose:';
    procedure windowWillClose(notification: NSNotification); message 'windowWillClose:';
    procedure windowDidBecomeKey(notification: NSNotification); message 'windowDidBecomeKey:';
    procedure windowDidResignKey(notification: NSNotification); message 'windowDidResignKey:';
    procedure windowDidResize(notification: NSNotification); message 'windowDidResize:';
    procedure windowDidMove(notification: NSNotification); message 'windowDidMove:';
  public
    callback: IWindowCallback;
    function acceptsFirstResponder: LCLObjCBoolean; override;
    function canBecomeKeyWindow: LCLObjCBoolean; override;
    function becomeFirstResponder: LCLObjCBoolean; override;
    function resignFirstResponder: LCLObjCBoolean; override;
    function lclGetCallback: ICommonCallback; override;
    procedure lclClearCallback; override;
    // mouse
    procedure mouseDown(event: NSEvent); override;
    procedure mouseUp(event: NSEvent); override;
    procedure rightMouseDown(event: NSEvent); override;
    procedure rightMouseUp(event: NSEvent); override;
    procedure rightMouseDragged(event: NSEvent); override;
    procedure otherMouseDown(event: NSEvent); override;
    procedure otherMouseUp(event: NSEvent); override;
    procedure otherMouseDragged(event: NSEvent); override;
    procedure mouseDragged(event: NSEvent); override;
    procedure mouseEntered(event: NSEvent); override;
    procedure mouseExited(event: NSEvent); override;
    procedure mouseMoved(event: NSEvent); override;
  end;

  { TCocoaWindow }

  TCocoaWindowContent = objcclass;

  TCocoaWindow = objcclass(NSWindow, NSWindowDelegateProtocol)
  private
    // for the reentrancy of makeFirstResponder()
    makeFirstResponderCount: Integer;
  private
    procedure DoWindowDidBecomeKey(); message 'DoWindowDidBecomeKey';
  protected
    fieldEditor: TCocoaFieldEditor;
    firedMouseEvent: Boolean;
    isInFullScreen: Boolean;
    orderOutAfterFS : Boolean;
    fsview: TCocoaWindowContent;

    function windowShouldClose(sender : id): LongBool; message 'windowShouldClose:';
    procedure windowWillClose(notification: NSNotification); message 'windowWillClose:';
    function windowWillReturnFieldEditor_toObject(sender: NSWindow; client: id): id; message 'windowWillReturnFieldEditor:toObject:';
    procedure windowDidBecomeKey(notification: NSNotification); message 'windowDidBecomeKey:';
    procedure windowDidResignKey(notification: NSNotification); message 'windowDidResignKey:';
    procedure windowDidResize(notification: NSNotification); message 'windowDidResize:';
    procedure windowDidMove(notification: NSNotification); message 'windowDidMove:';
    procedure windowDidMiniaturize(notification: NSNotification); message 'windowDidMiniaturize:';
    procedure windowDidDeminiaturize(notification: NSNotification); message 'windowDidDeminiaturize:';
    // fullscreen notifications are only reported for 10.7 fullscreen
    procedure windowWillEnterFullScreen(notification: NSNotification); message 'windowWillEnterFullScreen:';
    procedure windowDidEnterFullScreen(notification: NSNotification); message 'windowDidEnterFullScreen:';
    procedure windowDidExitFullScreen(notification: NSNotification); message 'windowDidExitFullScreen:';
  public
    _keyEvCallback: ICommonCallback;
    callback: IWindowCallback;
    keepWinLevel : NSInteger;
    //LCLForm: TCustomForm;
    procedure dealloc; override;
    function makeFirstResponder(aResponder: NSResponder): ObjCBOOL; override;
    function canBecomeKeyWindow: LCLObjCBoolean; override;
    function lclGetCallback: ICommonCallback; override;
    procedure lclClearCallback; override;
    // mouse
    procedure mouseDown(event: NSEvent); override;
    procedure mouseUp(event: NSEvent); override;
    procedure rightMouseDown(event: NSEvent); override;
    procedure rightMouseUp(event: NSEvent); override;
    procedure rightMouseDragged(event: NSEvent); override;
    procedure otherMouseDown(event: NSEvent); override;
    procedure otherMouseUp(event: NSEvent); override;
    procedure otherMouseDragged(event: NSEvent); override;
    procedure mouseDragged(event: NSEvent); override;
    procedure mouseEntered(event: NSEvent); override;
    procedure mouseExited(event: NSEvent); override;
    procedure mouseMoved(event: NSEvent); override;
    procedure scrollWheel(event: NSEvent); override;
    procedure sendEvent(event: NSEvent); override;
    // key
    procedure keyDown(event: NSEvent); override;
    // menu support
    procedure lclItemSelected(sender: id); message 'lclItemSelected:';

    procedure lclSwitchFullScreen(AEnabled: Boolean); message 'lclSwitchFullScreen:';
    function lclIsFullScreen: Boolean; message 'lclIsFullScreen';
  end;

  { TCocoaDesignOverlay }

  TCocoaDesignOverlay = objcclass(NSView)
    callback  : ICommonCallback;
    procedure drawRect(r: NSRect); override;
    function acceptsFirstResponder: LCLObjCBoolean; override;
    function hitTest(aPoint: NSPoint): NSView; override;
    function lclGetCallback: ICommonCallback; override;
    procedure lclClearCallback; override;
  end;

  { TCocoaWindowContentDocument }

  TCocoaWindowContentDocument = objcclass(TCocoaCustomControl)
  protected
    procedure didBecomeKeyNotification(sender: NSNotification); message 'didBecomeKeyNotification:';
    procedure didResignKeyNotification(sender: NSNotification); message 'didResignKeyNotification:';
  public
    overlay: NSView;
    wincallback: IWindowCallback;
    function lclWindowState: Integer; override;
    procedure didAddSubview(aview: NSView); override;
    procedure setNeedsDisplay_(aflag: LCLObjCBoolean); override;
    procedure setNeedsDisplayInRect(arect: NSRect); override;
    // NSDraggingDestinationCategory
    function draggingEntered(sender: NSDraggingInfoProtocol): NSDragOperation; override;
    function performDragOperation(sender: NSDraggingInfoProtocol): LCLObjCBoolean; override;
  end;

  { TCocoaWindowContent }

  TCocoaWindowContent = objcclass(TCocoaScrollView)
  private
    _stringValue: NSString;
  public
    wincallback: IWindowCallback;
    isembedded: Boolean; // true - if the content is inside of another control, false - if the content is in its own window;
    preventKeyOnShow: Boolean;
    ownwin: NSWindow;
    fswin: NSWindow; // window that was used as a content prior to switching to old-school fullscreen
    popup_parent: HWND; // if not 0, indicates that we should set the popup parent
    function performKeyEquivalent(event: NSEvent): LCLObjCBoolean; override;
    procedure resolvePopupParent(); message 'resolvePopupParent';
    function lclOwnWindow: NSWindow; message 'lclOwnWindow';
    procedure lclSetFrame(const r: TRect); override;
    function lclFrame: TRect; override;
    procedure lclRelativePos(var Left, Top: Integer); override;
    procedure viewDidMoveToSuperview; override;
    procedure viewDidMoveToWindow; override;
    procedure viewWillMoveToWindow(newWindow: CocoaAll.NSWindow); override;
    procedure dealloc; override;
    procedure setHidden(aisHidden: LCLObjCBoolean); override;

    procedure setStringValue(avalue: NSString); message 'setStringValue:';
    function stringValue: NSString; message 'stringValue';
  end;

implementation

uses
  CocoaInt;

{ TCocoaDesignOverlay }

procedure TCocoaDesignOverlay.drawRect(r: NSRect);
begin
  if Assigned(callback) then
    callback.DrawOverlay(NSGraphicsContext.currentContext, bounds, r);
  inherited drawRect(r);
end;

function TCocoaDesignOverlay.acceptsFirstResponder: LCLObjCBoolean;
begin
  Result:=false; // no focus
end;

function TCocoaDesignOverlay.hitTest(aPoint: NSPoint): NSView;
begin
  Result:=nil;  // no mouse
end;

function TCocoaDesignOverlay.lclGetCallback: ICommonCallback;
begin
  Result := callback;
end;

procedure TCocoaDesignOverlay.lclClearCallback;
begin
  callback := nil;
end;

{ TCocoaWindowContent }

function TCocoaWindowContentDocument.lclWindowState: Integer;
begin
  if window.lclGetCallback = wincallback then // not embedded
    Result := window.lclWindowState
  else
    Result := inherited lclWindowState
end;

procedure TCocoaWindowContentDocument.didAddSubview(aview: NSView);
const
  mustHaveSizing = (NSViewWidthSizable or NSViewHeightSizable);
begin
  if Assigned(aview) and Assigned(overlay) and (overlay<>aview) then
  begin
    overlay.retain;
    overlay.removeFromSuperview;
    addSubview_positioned_relativeTo(overlay, NSWindowAbove, nil);
    overlay.release;
    overlay.setFrame(frame);
    if (overlay.autoresizingMask and mustHaveSizing) <> mustHaveSizing then
      overlay.setAutoresizingMask(overlay.autoresizingMask or mustHaveSizing);
  end;
  inherited didAddSubview(aview);
end;

procedure TCocoaWindowContentDocument.didBecomeKeyNotification(sender: NSNotification);
begin
  if Assigned(callback) then
    callback.DidBecomeKeyNotification;
end;

procedure TCocoaWindowContentDocument.didResignKeyNotification(sender: NSNotification);
begin
  if Assigned(callback) then
    callback.DidResignKeyNotification;
end;

{ TCocoaWindowContent }

procedure NSResponderHotKeys(asender: NSResponder; event: NSEvent; var handled: LCLObjCBoolean; atarget: NSResponder);
var
  undoManager: NSUndoManager;
  ch : System.WideChar;
  msk : LongWord; //NSEventModifierFlags;
  chr : NSString;
const
  NSModsMask = NSShiftKeyMask
            or NSControlKeyMask
            or NSAlternateKeyMask
            or NSCommandKeyMask;
begin
  // todo: system keys could be overriden. thus need to review the current
  //       keyboard configuration first. See "Key Bindings" at
  //       https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html

  handled := false;
  if (event.type_ = NSKeyDown) then
  begin
    msk := (event.modifierFlags and NSModsMask);
    if (msk = 0) then Exit;
    // characters contain untranslated input characters, for layouts
    // without latin characters (i.e. greek cyrillic, arabic).
    // But for Latin based alphabet, "characters" are the same as
    // "charactersWihtoutModifiers"....The Roman Empire legacy today!
    //
    // charatersWithoutModifiers contain translated characters for any layout.

    // In order for the system shortkeys to work on any layout "characters"
    // property must be used
    chr := event.characters;
    if (chr.length = 0)
      then ch := #0
      else ch := System.WideChar(chr.characterAtIndex(0));
    case ch of
      'a': if msk= NSCommandKeyMask then
             handled := NSApplication(NSApp).sendAction_to_from(objcselector('selectAll:'), atarget, asender);
      'c': if msk = NSCommandKeyMask then
             handled := NSApplication(NSApp).sendAction_to_from(objcselector('copy:'), atarget, asender);
      'v': if msk = NSCommandKeyMask then
             handled := NSApplication(NSApp).sendAction_to_from(objcselector('paste:'), atarget, asender);
      'x': if msk = NSCommandKeyMask then
             handled := NSApplication(NSApp).sendAction_to_from(objcselector('cut:'), atarget, asender);
      'z': if msk = NSCommandKeyMask then
      begin
        undoManager := atarget.undoManager;
        if Assigned(undoManager) and undoManager.canUndo then
        begin
          handled := true;
          undoManager.undo;
        end;
      end;
      else if msk = (NSCommandKeyMask or NSShiftKeyMask) then
      begin
        undoManager := atarget.undoManager;
        if Assigned(undoManager) and undoManager.canRedo then
        begin
          handled := true;
          undoManager.redo;
        end;
      end;
    end;
  end;
end;

function TCocoaWindowContent.performKeyEquivalent(event: NSEvent): LCLObjCBoolean;
var
  resp : NSResponder;
  wn   : NSWindow;
  ch   : System.WideChar;
begin
  Result := false;

  // If the form has a default or cancel button, capture Return and Escape to
  // prevent further processing.  Actually clicking the buttons is handled in
  // the LCL in response to the keyUp
  if Assigned(wincallback) and (event.modifierFlags_ = 0) then
  begin
    ch := NSEventRawKeyChar(event);
    if (((ch = System.WideChar(NSCarriageReturnCharacter)) and wincallback.HasDefaultControl)
      or ((ch = #27{Escape}) and wincallback.HasCancelControl)) then
    begin
      Result := true;
      Exit;
    end;
  end;

  // Support Cut/Copy/Paste if the firstResponder is an NSTextView.
  // This could be done in TCocoaFieldEditor and TCocoaTextView's
  // performKeyEquivalent, but that wouldn't work for non-LCL edits.
  // Xcode Cocoa apps rely on the commands existing in the main menu
  wn := window;
  if Assigned(wn) then
  begin
    resp := wn.firstResponder;
    if Assigned(resp) and resp.isKindOfClass_(NSTextView) and
       resp.lclIsEnabled then
    begin
      NSResponderHotKeys(self, event, Result, resp);
      if Result then Exit;
    end;
  end;

  Result := inherited performKeyEquivalent(event);
end;

procedure TCocoaWindowContent.resolvePopupParent();
var
  lWindow: NSWindow;
  isfront: Boolean;
begin
  lWindow := nil;
  if (popup_parent <> 0) then
  begin
    if (NSObject(popup_parent).isKindOfClass(TCocoaWindowContent)) then
    begin
      if (not TCocoaWindowContent(popup_parent).isembedded) then
        lWindow := NSWindow(TCocoaWindowContent(popup_parent).window);
    end
    else
    begin
      lWindow := NSWindow(popup_parent);
    end;
  end;
  if lWindow <> nil then
  begin
    isfront:=NSApplication(NSApp).mainWindow=self.window;

    lWindow.addChildWindow_ordered(Self.window, NSWindowAbove);

    // adding a window as a child, would bring the "child" form to the bottom
    // of Zorder. need to restore the order.
    if isfront then self.window.makeKeyAndOrderFront(nil);
  end;
  popup_parent := 0;
end;

function TCocoaWindowContent.lclOwnWindow: NSWindow;
begin
  if not isembedded then
    Result := NSWindow(window)
  else
    Result := nil;
end;

procedure TCocoaWindowContent.lclSetFrame(const r: TRect);
begin
  if isembedded then
    inherited lclSetFrame(r)
  else
    window.lclSetFrame(r);
end;

function TCocoaWindowContent.lclFrame: TRect;
var
  wfrm : TRect;
begin
  Result := inherited lclFrame;
  if not isembedded then
  begin
    //Window bounds should return "client rect" in screen coordinates
    if Assigned(window.screen) then
      NSToLCLRect(window.frame, NSScreenZeroHeight, wfrm)
    else
      wfrm := NSRectToRect(frame);
    Types.OffsetRect(Result, -Result.Left+wfrm.Left, -Result.Top+wfrm.Top);
  end;
end;

procedure TCocoaWindowContent.lclRelativePos(var Left, Top: Integer);
begin
  if isembedded then
    inherited lclRelativePos(Left, Top)
  else
    window.lclRelativePos(Left, Top);
end;

procedure TCocoaWindowContent.viewDidMoveToSuperview;
begin
  inherited viewDidMoveToSuperview;
end;

procedure TCocoaWindowContent.viewDidMoveToWindow;
begin
  isembedded := window.contentView <> self;
  if isembedded then
  begin
    ownwin := nil;
  end
  else
  begin
    ownwin := NSWindow(window);
    if Assigned(stringValue) then
      ownwin.setTitle(stringValue);
  end;
  inherited viewDidMoveToWindow;
end;

procedure TCocoaWindowContent.viewWillMoveToWindow(newWindow: CocoaAll.NSWindow);
begin
  if newWindow<>nil then
     newWindow.setAcceptsMouseMovedEvents(True);
  if not isembedded and (newWindow <> window) then
  begin
    if Assigned(window) then
      setStringValue(window.title);
    ownwin := nil;
    isembedded := false;
  end;
  inherited viewWillMoveToWindow(newWindow);
end;

procedure TCocoaWindowContent.dealloc;
begin
  if Assigned(_stringValue) then _stringValue.release;
  inherited dealloc;
end;

procedure TCocoaWindowContent.setHidden(aisHidden: LCLObjCBoolean);
var
  cw : TCocoaWindow;
begin
  if isembedded then
  begin
    {$ifdef BOOLFIX}
    inherited setHidden_(Ord(aisHidden));
    {$else}
    inherited setHidden(aisHidden);
    {$endif}
  end
  else
  begin
    if aisHidden and window.isVisible then
    begin
      if (window.isKindOfClass(TCocoaWindow)) then
        cw := TCocoaWindow(window)
      else
        cw := nil;
      if cw.lclIsFullScreen then
      begin
        cw.orderOutAfterFS := true;
        cw.lclSwitchFullScreen(false);
      end else
        window.orderOut(nil);
    end
    else
    if not aisHidden and not window.isVisible then
    begin
      if preventKeyOnShow then // used for Hint-windows, so they would not steal the focus from the current window
        window.orderFrontRegardless
      else
        window.makeKeyAndOrderFront(nil);
    end;
  end;
end;

procedure TCocoaWindowContent.setStringValue(avalue: NSString);
begin
  if _stringValue = avalue then Exit;
  if Assigned(_stringValue) then _stringValue.release;
  _stringValue := AValue;
  if Assigned(_stringValue) then _stringValue.retain;
end;

function TCocoaWindowContent.stringValue: NSString;
begin
  Result := _stringValue;
end;

{ TCocoaPanel }

function TCocoaPanel.windowShouldClose(sender: id): LongBool;
var
  canClose: Boolean;
begin
  canClose := True;
  if Assigned(callback) then
    callback.CloseQuery(canClose);
  Result := canClose;
end;

procedure TCocoaPanel.windowWillClose(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Close;
end;

procedure TCocoaPanel.windowDidBecomeKey(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Activate;
end;

procedure TCocoaPanel.windowDidResignKey(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Deactivate;
end;

procedure TCocoaPanel.windowDidResize(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Resize;
end;

procedure TCocoaPanel.windowDidMove(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Move;
end;

function TCocoaPanel.acceptsFirstResponder: LCLObjCBoolean;
begin
  Result := True;
end;

function TCocoaPanel.canBecomeKeyWindow: LCLObjCBoolean;
begin
  Result := Assigned(callback) and callback.CanActivate;
end;

function TCocoaPanel.becomeFirstResponder: LCLObjCBoolean;
begin
  Result := inherited becomeFirstResponder;
//  if Assigned(callback) then
//    callback.BecomeFirstResponder;
end;

function TCocoaPanel.resignFirstResponder: LCLObjCBoolean;
begin
  Result := inherited resignFirstResponder;
//  if Assigned(callback) then
//    callback.ResignFirstResponder;
end;

function TCocoaPanel.lclGetCallback: ICommonCallback;
begin
  Result := callback;
end;

procedure TCocoaPanel.lclClearCallback;
begin
  callback := nil;
  contentView.lclClearCallback;
end;

procedure TCocoaPanel.mouseDown(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited mouseDown(event);
end;

procedure TCocoaPanel.mouseUp(event: NSEvent);
begin
  if Assigned(callback) then callback.MouseUpDownEvent(event);
    inherited mouseUp(event);
end;

procedure TCocoaPanel.rightMouseDown(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited rightMouseUp(event);
end;

procedure TCocoaPanel.rightMouseUp(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited rightMouseDown(event);
end;

procedure TCocoaPanel.rightMouseDragged(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited rightMouseDragged(event);
end;

procedure TCocoaPanel.otherMouseDown(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited otherMouseDown(event);
end;

procedure TCocoaPanel.otherMouseUp(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited otherMouseUp(event);
end;

procedure TCocoaPanel.otherMouseDragged(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited otherMouseDown(event);
end;

procedure TCocoaPanel.mouseDragged(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseMove(event) then
    inherited mouseDragged(event);
end;

procedure TCocoaPanel.mouseEntered(event: NSEvent);
begin
  inherited mouseEntered(event);
end;

procedure TCocoaPanel.mouseExited(event: NSEvent);
begin
  inherited mouseExited(event);
end;

procedure TCocoaPanel.mouseMoved(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseMove(event) then
    inherited mouseMoved(event);
end;

{ TCocoaWindow }

function TCocoaWindow.windowShouldClose(sender: id): LongBool;
var
  canClose: Boolean;
begin
  canClose := True;
  if Assigned(callback) then
    callback.CloseQuery(canClose);
  Result := canClose;
end;

function TCocoaWindow.windowWillReturnFieldEditor_toObject(sender: NSWindow; client: id): id;
begin
  //DebugLn('[TCocoaWindow.windowWillReturnFieldEditor_toObject]');
  Result := nil;

  // NSTextView itself is NSTextFieldEditor, then windowWillReturnFieldEditor never called for NSTextView
  if (NSObject(client).isKindOfClass(NSTextField)) and Assigned(NSObject(client).lclGetCallBack) then
  begin
    if (fieldEditor = nil) then
    begin
      fieldEditor := TCocoaFieldEditor.alloc.init;
      fieldEditor.setFieldEditor(True);
    end;
    Result := fieldEditor;
  end;
end;

procedure TCocoaWindow.windowWillClose(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Close;
end;

procedure TCocoaWindow.DoWindowDidBecomeKey();
begin
  if CocoaWidgetSet.isModalSession then
    self.orderFront(nil);
  CursorHelper.SetCursorOnActive();
end;

procedure TCocoaWindow.windowDidBecomeKey(notification: NSNotification);
begin
  // forcing to keep the level as all other LCL windows
  // Modal windows tend to "restore" their elevated level
  // And that doesn't work for modal windows that are "Showing" other windows

  // Another approach is to set elevated levels for windows, shown during modal session
  // That requires to revoke the elevated level from windows on closing a window session
  // This might be the way to go, if FormStyle (such as fsStayOnTop) would come
  // in conflict with modality
  if level <> keepWinLevel then begin
    setLevel(keepWinLevel);
  end;

  if Assigned(callback) then
    callback.Activate;

  performSelector_withObject_afterDelay( ObjCSelector('DoWindowDidBecomeKey'), nil, 0.1 );
end;

procedure TCocoaWindow.windowDidResignKey(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Deactivate;
end;

procedure TCocoaWindow.windowDidResize(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Resize;
end;

procedure TCocoaWindow.windowDidMove(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.Move;
end;

procedure TCocoaWindow.windowDidMiniaturize(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.WindowStateChanged;
end;

procedure TCocoaWindow.windowDidDeminiaturize(notification: NSNotification);
begin
  if Assigned(callback) then
    callback.WindowStateChanged;
end;

procedure TCocoaWindow.windowWillEnterFullScreen(notification: NSNotification);
begin
  if not isInFullScreen then isInFullScreen := true;
  // setting fullscreen flag, prior to the "Fullscreen" has actually been enabled.
  // MacOS does 10.7 fullscreen switch with an animation (that's about 1 second long)
  // if during that animation there's another call toggleFullScreen() is made
  // then macOS produces an output "not in fullscreen state" and ignores the call.
end;

procedure TCocoaWindow.windowDidEnterFullScreen(notification: NSNotification);
begin
  if not isInFullScreen then isInFullScreen := true;
end;

procedure TCocoaWindow.windowDidExitFullScreen(notification: NSNotification);
begin
  if isInFullScreen then isInFullScreen := false;
  if orderOutAfterFS then begin
    self.orderOut(nil);
    orderOutAfterFS := false;
  end;
end;

procedure TCocoaWindow.dealloc;
begin
  if (fieldEditor <> nil) then
  begin
    fieldEditor.release;
    fieldEditor := nil;
  end;
  inherited dealloc;
end;

function TCocoaWindow.canBecomeKeyWindow: LCLObjCBoolean;
begin
  Result := Assigned(callback) and callback.CanActivate;
end;

function TCocoaWindow.lclGetCallback: ICommonCallback;
begin
  Result := callback;
end;

procedure TCocoaWindow.lclClearCallback;
begin
  callback := nil;
  contentView.lclClearCallback;
end;

procedure TCocoaWindow.mouseDown(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited mouseDown(event);
end;

procedure TCocoaWindow.mouseUp(event: NSEvent);
begin
  //firedMouseEvent:=true;
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited mouseUp(event);
end;

procedure TCocoaWindow.rightMouseDown(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited rightMouseUp(event);
end;

procedure TCocoaWindow.rightMouseUp(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited rightMouseDown(event);
end;

procedure TCocoaWindow.rightMouseDragged(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited rightMouseDragged(event);
end;

procedure TCocoaWindow.otherMouseDown(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited otherMouseDown(event);
end;

procedure TCocoaWindow.otherMouseUp(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited otherMouseUp(event);
end;

procedure TCocoaWindow.otherMouseDragged(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
    inherited otherMouseDown(event);
end;

procedure TCocoaWindow.mouseDragged(event: NSEvent);
begin
  //if not Assigned(callback) or not callback.MouseMove(event) then
    inherited mouseDragged(event);
end;

procedure TCocoaWindow.mouseEntered(event: NSEvent);
begin
  inherited mouseEntered(event);
end;

procedure TCocoaWindow.mouseExited(event: NSEvent);
begin
  inherited mouseExited(event);
end;

procedure TCocoaWindow.mouseMoved(event: NSEvent);
begin
  // no need to call for callback or anything, because WindowContent
  // will take care of it anyway
  inherited mouseMoved(event);
end;

procedure TCocoaWindow.scrollWheel(event: NSEvent);
begin
  if not Assigned(callback) or not callback.scrollWheel(event) then
    inherited scrollWheel(event);
end;

procedure TCocoaWindow.sendEvent(event: NSEvent);
var
  Epos: NSPoint;
  cr : NSRect;
  fr : NSRect;
  prc: Boolean;
begin
  if event.type_ = NSLeftMouseUp then
  // This code is introduced here for an odd cocoa feature.
  // mouseUp is not fired, if pressed on Window's title.
  // (even though mouseDown, mouseMove and mouseDragged are fired)
  // (there are some information in the internet, that mouseDown is not firing as well)
  // (however this is not true for macOS 10.12)
  // The logic below is as following. If mouseUp event arrived
  // and mouse position is on the title of the form.
  // then try to process the event. If event was not processed, call mouseUp()
  // specifically.
  begin
    Epos:=event.locationInWindow;
    fr := frame;
    fr.origin.x:=0;
    fr.origin.y:=0;
    cr := contentRectForFrameRect(fr);
    if NSPointInRect(Epos, fr) and not NSPointInRect(Epos, cr) then
    begin
      firedMouseEvent := false;
      inherited sendEvent(event);
      if not firedMouseEvent then mouseUp(event);
    end
    else
      inherited sendEvent(event);
  end
  else
    inherited sendEvent(event);
end;

procedure TCocoaWindow.keyDown(event: NSEvent);
var
  mn : NSMenu;
  allowcocoa : Boolean;
begin
  if Assigned(_keyEvCallback) and _keyEvCallback.IsCocoaOnlyState then
  begin
    inherited keyDown(event);
    Exit;
  end;

  if performKeyEquivalent(event) then
    Exit;

  mn := NSApp.MainMenu;
  if Assigned(mn) and mn.performKeyEquivalent(event) then
    Exit;

  if Assigned(_keyEvCallback) then
  begin
    allowcocoa := True;
    _keyEvCallback.KeyEvAfterDown(allowcocoa);
    if not allowcocoa then
      Exit;
  end;

  inherited keyDown(event);
end;

// return proper focused responder by kind of class of NSResponder
function getProperFocusedResponder( const aResponder : NSResponder ): NSResponder;
begin
  Result := aResponder;
  if Result.isKindOfClass(NSWindow) then
    Result:= TCocoaWindowContent(NSWindow(Result).contentView).documentView;
end;

// return responder callback by kind of class of NSResponder
function getResponderCallback( const aResponder : NSResponder ): ICommonCallback;
var
  newResponder: NSResponder;
  dl : NSObject;
begin
  Result:= nil;
  if not Assigned(aResponder) then exit;

  newResponder := aResponder;
  if newResponder.isKindOfClass(NSText) then
  begin
    dl := {%H-}NSObject( NSText(newResponder).delegate );
    if Assigned(dl) and (dl.isKindOfClass(NSView)) then
      newResponder := NSResponder(dl);
  end
  else
  if newResponder.isKindOfClass(NSWindow) or newResponder.isKindOfClass(TCocoaWindowContentDocument) then
  begin
    newResponder := nil;
  end
  else
  begin
    newResponder := newResponder.lclContentView;
  end;

  if Assigned(newResponder) then
    Result:= newResponder.lclGetCallback;
end;

// send KillFocus/SetFocus messages to LCL at the right time
// 1. KillFocus/SetFocus messages should be sent after LCLIntf.SetFocus() in LCL,
// and before generating CM_UIACTIVATE message in LCL,
// this adapts to LCL, just like Win32.
// 2. if KillFocus/SetFocus messages are delayed,
// such as at the end of TCocoaApplication.sendevent(), it will cause many problems.
// for example, there are two buttons showing the selected state.
// 3. makeFirstResponder() already avoids infinite loops caused by 'Focus-fight'
// between LCL and COCOA, see also:
// https://wiki.lazarus.freepascal.org/Cocoa_Internals/Application#Focus_Change
// 4. makeFirstResponder() is Reentrant and Thread-safe
function TCocoaWindow.makeFirstResponder( aResponder : NSResponder ): ObjCBOOL;
var
  lastResponder : NSResponder;
  newResponder : NSResponder;
  cb : ICommonCallback;
begin
  inc( makeFirstResponderCount );
  try
    lastResponder := self.firstResponder;
    newResponder := getProperFocusedResponder( aResponder );
    if lastResponder = newResponder then exit;

    // do toggle Focused Control
    // Result=false when the focused control has not been changed
    // TCocoaWindow.makeFirstResponder() may be triggered reentrant here
    Result := inherited makeFirstResponder( newResponder );
    if not Result then exit;

    // send KillFocus/SetFocus messages to LCL only at level one
    if makeFirstResponderCount > 1 then
      exit;

    // 1st: send KillFocus Message first
    cb:= getResponderCallback( lastResponder );
    if Assigned(cb) then
      cb.ResignFirstResponder;

    // 2st: send SetFocus Message
    // TCocoaWindow.makeFirstResponder() may be triggered reentrant here
    cb := getResponderCallback( self.firstResponder );
    if Assigned(cb) then
      cb.BecomeFirstResponder;

  finally
    dec( makeFirstResponderCount );
  end;
end;


function TCocoaWindowContentDocument.draggingEntered(sender: NSDraggingInfoProtocol): NSDragOperation;
begin
  Result := NSDragOperationNone;
  if (wincallback <> nil) and (wincallback.AcceptFilesDrag) then
    Result := sender.draggingSourceOperationMask();
end;

function TCocoaWindowContentDocument.performDragOperation(sender: NSDraggingInfoProtocol): LCLObjCBoolean;
var
  draggedURLs{, lClasses}: NSArray;
  lFiles: array of string;
  i: Integer;
  pboard: NSPasteboard;
  lNSStr: NSString;
  //lClass: pobjc_class;
begin
  Result := False;
  pboard := sender.draggingPasteboard();

  // Multiple strings
  draggedURLs := pboard.propertyListForType(NSFilenamesPboardType);
  SetLength(lFiles, draggedURLs.count);
  for i := 0 to draggedURLs.count-1 do
  begin
    lNSStr := NSString(draggedURLs.objectAtIndex(i));
    lFiles[i] := NSStringToString(lNSStr);
  end;

  // Multiple URLs -> Results in strange URLs with file:// protocol
  {if pboard.types.containsObject(NSURLPboardType) then
  begin
    lClass := NSURL.classClass;
    lClasses := NSArray.arrayWithObjects_count(@lClass, 1);
    draggedURLs := pboard.readObjectsForClasses_options(lClasses, nil);
    SetLength(lFiles, draggedURLs.count);
    for i := 0 to draggedURLs.count-1 do
    begin
      lNSStr := NSURL(draggedURLs.objectAtIndex(i)).absoluteString;
      lFiles[i] := NSStringToString(lNSStr);
    end;
  end;}

  if (Length(lFiles) > 0) and (wincallback <> nil)  then
    wincallback.DropFiles(lFiles);
  Result := True;
end;

procedure TCocoaWindowContentDocument.setNeedsDisplay_(aflag: LCLObjCBoolean);
begin
  inherited setNeedsDisplay_(aflag);
  if Assigned(overlay) then overlay.setNeedsDisplay_(aflag);
end;

procedure TCocoaWindowContentDocument.setNeedsDisplayInRect(arect: NSRect);
begin
  inherited setNeedsDisplayInRect(arect);
  if Assigned(overlay) then overlay.setNeedsDisplayInRect(arect);
end;

procedure TCocoaWindow.lclItemSelected(sender: id);
begin

end;

procedure TCocoaWindow.lclSwitchFullScreen(AEnabled: Boolean);
const
  fsmask =  NSWindowCollectionBehaviorFullScreenPrimary
            or
            NSWindowCollectionBehaviorFullScreenAuxiliary;
begin
  if isInFullScreen = AEnabled then Exit; // nothing to do

  //todo: there are two flavours of full-screen
  //      (soft) macOS 10.7+ toggleFullScreen()
  //      (hard) macOS 10.5+ enterFullScreenMode_withOptions()
  //      the function should be smart enough to figure out the available mode

  isInFullScreen := AEnabled;
  if NSAppKitVersionNumber >= NSAppKitVersionNumber10_7 then
  begin
    if Self.collectionBehavior and fsmask = 0 then
      Self.setCollectionBehavior(Self.collectionBehavior or NSWindowCollectionBehaviorFullScreenPrimary);
    Self.toggleFullScreen(nil);
  end
  else
  begin
    if AEnabled then
    begin
      fsview := TCocoaWindowContent(contentView);
      fsview.fswin := self;
      fsview.enterFullScreenMode_withOptions(self.screen, nil);
    end else begin
      fsview.exitFullScreenModeWithOptions(nil);
      self.setContentView(fsview);
      fsview := nil;
    end;
  end;
end;

function TCocoaWindow.lclIsFullScreen: Boolean;
begin
  Result := isInFullScreen;
end;

{ LCLWindowExtension }

function LCLWindowExtension.lclIsVisible: Boolean;
begin
  Result := isVisible;
end;

procedure LCLWindowExtension.lclSetVisible(AVisible: Boolean);
begin
  if AVisible then
    orderFrontRegardless
  else
    orderOut(nil);
end;

function LCLWindowExtension.lclIsEnabled: Boolean;
begin
  Result := contentView.lclIsEnabled;
end;

procedure LCLWindowExtension.lclSetEnabled(AEnabled: Boolean);
begin
  contentView.lclSetEnabled(AEnabled);
end;

function LCLWindowExtension.lclWindowState: Integer;
const
  NSFullScreenWindowMask = 1 shl 14;
begin
  if isMiniaturized then
    Result := SIZE_MINIMIZED
  else
  if (styleMask and NSFullScreenWindowMask) <> 0 then
    Result := SIZE_FULLSCREEN
  else
  if isZoomed then
    Result := SIZE_MAXIMIZED
  else
    Result := SIZE_RESTORED;
end;

procedure LCLWindowExtension.lclInvalidateRect(const r: TRect);
begin
  contentView.lclInvalidateRect(r);
end;

procedure LCLWindowExtension.lclInvalidate;
begin
  contentView.lclInvalidate;
end;

procedure LCLWindowExtension.lclUpdate;
begin
  contentView.lclUpdate;
end;

procedure LCLWindowExtension.lclRelativePos(var Left, Top: Integer);
var
   f: NSRect;
begin
  if Assigned(screen) then
  begin
    f:=frame;
    Left := Round(f.origin.x);
    Top := Round(NSScreenZeroHeight - f.size.height - f.origin.y);
    //debugln('Top:'+dbgs(Top));
  end;
end;

procedure LCLWindowExtension.lclLocalToScreen(var X, Y:Integer);
var
  f: NSRect;
begin
  if Assigned(screen) then
  begin
    f := frame;
    inc(X, Round(f.origin.x));
    inc(Y, Round(NSScreenZeroHeight - f.size.height - f.origin.y));
  end;
end;

procedure LCLWindowExtension.lclScreenToLocal(var X, Y: Integer);
var
  f: NSRect;
begin
  if Assigned(screen) then
  begin
    f := frame;
    dec(X, Round(f.origin.x));
    dec(Y, Round(screen.frame.size.height - f.size.height - f.origin.y));
  end;
end;

function LCLWindowExtension.lclFrame: TRect;
begin
  if Assigned(contentView) then
    Result:=contentView.lclFrame
  else
  begin
    if Assigned(screen) then
      NSToLCLRect(frame, NSScreenZeroHeight, Result)
    else
      Result := NSRectToRect(frame);
  end;
end;

function LCLWindowExtension.lclGetTopBarHeight:integer;
var nw,nf: NSRect;
begin
  nf:= NSMakeRect (0, 0, 100, 100);
  nw:=contentRectForFrameRect(nf);
  result:=round(nf.size.height-nw.size.height);
end;

procedure LCLWindowExtension.lclOffsetMousePos(var Point: NSPoint);
begin
  Point.y := contentView.bounds.size.height - Point.y;
end;

procedure NSScreenGetRect(sc: NSScreen; mainScreenHeight: double; out r: TRect);
var
  fr : NSRect;
begin
  fr := sc.frame;
  r := Bounds(
    Round(fr.origin.x),
    Round(fr.origin.y - fr.size.height + mainScreenHeight),
    Round(fr.size.width), Round(fr.size.height)
  );
end;

procedure NSScreenGetRect(sc: NSScreen; out r: TRect);
begin
  NSScreenGetRect(sc, NSScreen.mainScreen.frame.size.height, r);
end;

procedure LCLWindowExtension.lclSetFrame(const r: TRect);
var
  ns : NSRect;
  h  : integer;
begin
  LCLToNSRect(r, NSScreenZeroHeight, ns);

  // add topbar height
  h:=lclGetTopBarHeight;
  ns.size.height:=ns.size.height+h;
  ns.origin.y:=ns.origin.y-h;
  {$ifdef BOOLFIX}
  setFrame_display_(ns, Ord(isVisible));
  {$else}
  setFrame_display(ns, isVisible);
  {$endif}
end;

function LCLWindowExtension.lclClientFrame: TRect;
var
  wFrame, cFrame: NSRect;
begin
  wFrame := frame;
  cFrame := contentRectForFrameRect(wFrame);
  Result.Left := Round(cFrame.origin.x - wFrame.origin.x);
  Result.Top := Round(wFrame.origin.y + wFrame.size.height - cFrame.origin.y - cFrame.size.height);
  Result.Right := Result.Left + Round(cFrame.size.width);
  Result.Bottom := Result.Top + Round(cFrame.size.height);
end;

end.

