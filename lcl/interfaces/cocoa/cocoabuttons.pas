{ $Id: $}
{                  --------------------------------------------
                  cocoabuttons.pas  -  Cocoa internal classes
                  --------------------------------------------

 This unit contains the private classhierarchy for the Cocoa implemetations

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit CocoaButtons;

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
  MacOSAll, CocoaAll, CocoaUtils, CocoaGDIObjects,
  cocoa_extra, CocoaPrivate
  // LCL
  ,Graphics;

const
  // these heights were received from Xcode interface builder,
  // where the height cannot be changed for a button control the actual size
  // of the button (the difference between top pixel and bottom pixel,
  // is less than frame size also

  PUSHBTN_REG_HEIGHT   = 20;
  PUSHBTN_SMALL_HEIGHT = 17;
  PUSHBTN_MINI_HEIGHT  = 14;


type

  { IButtonCallback }

  IButtonCallback = interface(ICommonCallback)
    procedure ButtonClick;
    procedure GetAllowMixedState(var allowed: Boolean);
  end;


  { TCocoaButton }

  TCocoaButton = objcclass(NSButton)
  protected
    procedure actionButtonClick(sender: NSObject); message 'actionButtonClick:';
    procedure boundsDidChange(sender: NSNotification); message 'boundsDidChange:';
    procedure frameDidChange(sender: NSNotification); message 'frameDidChange:';
  public
    callback: IButtonCallback;
    Glyph: TBitmap;

    smallHeight: integer;
    miniHeight: integer;
    adjustFontToControlSize: Boolean;
    procedure dealloc; override;
    function initWithFrame(frameRect: NSRect): id; override;
    function acceptsFirstResponder: LCLObjCBoolean; override;
    procedure drawRect(dirtyRect: NSRect); override;
    function lclGetCallback: ICommonCallback; override;
    procedure lclClearCallback; override;
    // keyboard
    procedure keyDown(event: NSEvent); override;
    function performKeyEquivalent(event: NSEvent): LCLObjCBoolean; override;

    // mouse
    procedure mouseDown(event: NSEvent); override;
    procedure mouseUp(event: NSEvent); override;
    procedure rightMouseDown(event: NSEvent); override;
    procedure rightMouseUp(event: NSEvent); override;
    procedure otherMouseDown(event: NSEvent); override;
    procedure otherMouseUp(event: NSEvent); override;

    procedure mouseDragged(event: NSEvent); override;
    procedure mouseEntered(event: NSEvent); override;
    procedure mouseExited(event: NSEvent); override;
    procedure mouseMoved(event: NSEvent); override;
    // lcl overrides
    procedure lclSetFrame(const r: TRect); override;
    procedure lclCheckMixedAllowance; message 'lclCheckMixedAllowance';
    function lclGetFrameToLayoutDelta: TRect; override;
    // cocoa
    procedure setState(astate: NSInteger); override;
  end;


  IStepperCallback = interface(ICommonCallback)
    procedure BeforeChange(var Allowed: Boolean);
    procedure Change(NewValue: Double; isUpPressed: Boolean; var Allowed: Boolean);
    procedure UpdownClick(isUpPressed: Boolean);
  end;

  { TCocoaStepper }

  TCocoaStepper = objcclass(NSStepper)
    callback: IStepperCallback;
    lastValue: Double;
    procedure stepperAction(sender: NSObject); message 'stepperAction:';

    procedure mouseDown(event: NSEvent); override;
    procedure mouseUp(event: NSEvent); override;
    procedure rightMouseDown(event: NSEvent); override;
    procedure rightMouseUp(event: NSEvent); override;
    procedure otherMouseDown(event: NSEvent); override;
    procedure otherMouseUp(event: NSEvent); override;

    procedure mouseDragged(event: NSEvent); override;
    procedure mouseMoved(event: NSEvent); override;

    function lclGetCallback: ICommonCallback; override;
    procedure lclClearCallback; override;
  end;

implementation

{ TCocoaStepper }

procedure TCocoaStepper.stepperAction(sender: NSObject);
var
  newval      : Double;
  allowChange : Boolean;
  updownpress : Boolean;
begin
  newval := doubleValue;
  allowChange := true;
  updownpress := newval > lastValue;

  if Assigned(callback) then begin
    callback.BeforeChange(allowChange);
    callback.Change(newval, updownpress, allowChange);
  end;

  if not allowChange then
    setDoubleValue(lastValue)
  else
    lastValue := doubleValue;

  if Allowchange and Assigned(callback) then callback.UpdownClick(updownpress);
end;

procedure TCocoaStepper.mouseDown(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
  begin
    inherited mouseDown(event);
    if Assigned(Callback) then
      callback.MouseUpDownEvent(event, true);
  end;
end;

procedure TCocoaStepper.mouseUp(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited mouseUp(event);
end;

procedure TCocoaStepper.rightMouseDown(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited rightMouseDown(event);
end;

procedure TCocoaStepper.rightMouseUp(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited rightMouseUp(event);
end;

procedure TCocoaStepper.otherMouseDown(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited otherMouseDown(event);
end;

procedure TCocoaStepper.otherMouseUp(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited otherMouseUp(event);
end;

procedure TCocoaStepper.mouseDragged(event: NSEvent);
begin
  if not callback.MouseMove(event) then
    inherited mouseDragged(event);
end;

procedure TCocoaStepper.mouseMoved(event: NSEvent);
begin
  if not callback.MouseMove(event) then
    inherited mouseMoved(event);
end;

function TCocoaStepper.lclGetCallback: ICommonCallback;
begin
  Result:= callback;
end;

procedure TCocoaStepper.lclClearCallback;
begin
  callback := nil;
end;

{ TCocoaButton }

procedure TCocoaButton.lclSetFrame(const r: TRect);
var
  lBtnHeight, lDiff: Integer;
  lRoundBtnSize: NSSize;
begin
  // NSTexturedRoundedBezelStyle should be the preferred style, but it has a fixed height!
  // fittingSize is 10.7+
 {  if respondsToSelector(objcselector('fittingSize')) then
  begin
    lBtnHeight := r.Bottom - r.Top;
    lRoundBtnSize := fittingSize();
    lDiff := Abs(Round(lRoundBtnSize.Height) - lBtnHeight);
    if lDiff < 4 then // this nr of pixels maximum size difference is arbitrary and we could choose another number
      setBezelStyle(NSTexturedRoundedBezelStyle)
    else
      setBezelStyle(NSTexturedSquareBezelStyle);
  end
  else
    setBezelStyle(NSTexturedSquareBezelStyle);
  }
  if (miniHeight<>0) or (smallHeight<>0) then
    SetNSControlSize(Self,r.Bottom-r.Top,miniHeight, smallHeight, adjustFontToControlSize);
  inherited lclSetFrame(r);
end;

procedure TCocoaButton.lclCheckMixedAllowance;
var
  allowed : Boolean;
begin
  if allowsMixedState and Assigned(callback)  then begin
    allowed := false;
    callback.GetAllowMixedState(allowed);
    if not allowed then begin
      // "mixed" should be following by "On" state
      // lclCheckMixedAllowance is called prior to changing
      // the state. So the state needs to be switched to "Off"
      // so it could be then switched to "On" by Cocoa
      if state = NSMixedState then
        inherited setState(NSOffState);
      {$ifdef BOOLFIX}
      setAllowsMixedState_(Ord(false));
      {$else}
      setAllowsMixedState(false);
      {$endif}
    end;
  end;
end;

function TCocoaButton.lclGetFrameToLayoutDelta: TRect;
begin
  case bezelStyle of
    NSPushOnPushOffButton:
    begin
      // todo: on 10.7 or later there's a special API for that!
        // The data is received from 10.6 Interface Builder
      case NSCell(Self.Cell).controlSize of
        NSSmallControlSize: begin
          Result.Left := 5;
          Result.Top := 4;
          Result.Right := -5;
          Result.Bottom := -7;
        end;
        NSMiniControlSize: begin
          Result.Left := 1;
          Result.Top := 0;
          Result.Right := -1;
          Result.Bottom := -2;
        end;
      else
        // NSRegularControlSize
        Result.Left := 6;
        Result.Top := 4;
        Result.Right := -6;
        Result.Bottom := -8;
      end;
    end;
  else
    Result := inherited lclGetFrameToLayoutDelta;
  end;
end;

procedure TCocoaButton.setState(astate: NSInteger);
var
  ch : Boolean;
begin
  ch := astate<>state;
  inherited setState(astate);
  if Assigned(callback) and ch then callback.SendOnChange;
end;

procedure TCocoaButton.actionButtonClick(sender: NSObject);
begin
  // this is the action handler of button
  if Assigned(callback) then
    callback.ButtonClick;
end;

procedure TCocoaButton.boundsDidChange(sender: NSNotification);
begin
  if Assigned(callback) then
    callback.boundsDidChange(self);
end;

procedure TCocoaButton.frameDidChange(sender: NSNotification);
begin
  if Assigned(callback) then
    callback.frameDidChange(self);
end;

procedure TCocoaButton.dealloc;
begin
  if Assigned(Glyph) then
    FreeAndNil(Glyph);

  inherited dealloc;
end;

function TCocoaButton.initWithFrame(frameRect: NSRect): id;
begin
  Result := inherited initWithFrame(frameRect);
  if Assigned(Result) then
  begin
    setTarget(Self);
    setAction(objcselector('actionButtonClick:'));
  //  todo: find a way to release notifications below
  //  NSNotificationCenter.defaultCenter.addObserver_selector_name_object(Self, objcselector('boundsDidChange:'), NSViewBoundsDidChangeNotification, Result);
  //  NSNotificationCenter.defaultCenter.addObserver_selector_name_object(Self, objcselector('frameDidChange:'), NSViewFrameDidChangeNotification, Result);
  //  Result.setPostsBoundsChangedNotifications(True);
  //  Result.setPostsFrameChangedNotifications(True);
  end;
end;

function TCocoaButton.acceptsFirstResponder: LCLObjCBoolean;
begin
  Result := True;
end;

procedure TCocoaButton.drawRect(dirtyRect: NSRect);
var ctx: NSGraphicsContext;
begin
  inherited drawRect(dirtyRect);
  if CheckMainThread and Assigned(callback) then
    callback.Draw(NSGraphicsContext.currentContext, bounds, dirtyRect);
end;

function TCocoaButton.lclGetCallback: ICommonCallback;
begin
  Result := callback;
end;

procedure TCocoaButton.lclClearCallback;
begin
  callback := nil;
end;

procedure TCocoaButton.keyDown(event: NSEvent);
begin
  if event.keyCode = kVK_Space then
    lclCheckMixedAllowance;
  inherited keyDown(event);
end;

function TCocoaButton.performKeyEquivalent(event: NSEvent): LCLObjCBoolean;
begin
  // "Return" is a keyEquivalent for a "default" button"
  // LCL provides its own mechanism for handling default buttons
  if (keyEquivalent.length = 1) and (keyEquivalentModifierMask = 0) and
     (keyEquivalent.characterAtIndex(0) = NSCarriageReturnCharacter) then
    Result := False
  else
    Result := inherited performKeyEquivalent(event);
end;

procedure TCocoaButton.mouseUp(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited mouseUp(event);
end;

procedure TCocoaButton.rightMouseDown(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited rightMouseDown(event);
end;

procedure TCocoaButton.rightMouseUp(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited rightMouseUp(event);
end;

procedure TCocoaButton.otherMouseDown(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited otherMouseDown(event);
end;

procedure TCocoaButton.otherMouseUp(event: NSEvent);
begin
  if not callback.MouseUpDownEvent(event) then
    inherited otherMouseUp(event);
end;

procedure TCocoaButton.mouseDown(event: NSEvent);
begin
  if not Assigned(callback) or not callback.MouseUpDownEvent(event) then
  begin
    lclCheckMixedAllowance;
    // We need to call the inherited regardless of the result of the call to
    // MouseUpDownEvent otherwise mouse clicks don't work, see bug 30131
    inherited mouseDown(event);
    if Assigned(callback) then
      callback.MouseUpDownEvent(event, true);
  end;
end;

procedure TCocoaButton.mouseDragged(event: NSEvent);
begin
  if not callback.MouseMove(event) then
    inherited mouseDragged(event);
end;

procedure TCocoaButton.mouseEntered(event: NSEvent);
begin
  inherited mouseEntered(event);
end;

procedure TCocoaButton.mouseExited(event: NSEvent);
begin
  inherited mouseExited(event);
end;

procedure TCocoaButton.mouseMoved(event: NSEvent);
begin
  if not callback.MouseMove(event) then
    inherited mouseMoved(event);
end;

end.

