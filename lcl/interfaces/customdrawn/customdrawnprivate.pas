unit customdrawnprivate;

{$mode objfpc}{$H+}

interface

uses
  // rtl+ftl
  Types, Classes, SysUtils,
  // LCL
  Controls, Graphics, stdctrls, extctrls, comctrls,
  customdrawnproc, customdrawncontrols, lcltype, lclproc, lclintf,
  lmessages, spin;

type

  // Standard Tab

  { TCDIntfButton }

  TCDIntfButton = class(TCDButton)
  public
    LCLControl: TCustomButton;
  end;

  { TCDIntfEdit }

  TCDIntfEdit = class(TCDEdit)
  protected
    // for descendents to override
    procedure DoChange; override;
  public
    LCLControl: TCustomEdit;
  end;

  TCDIntfCheckBox = class(TCDCheckBox)
  public
    LCLControl: TCustomCheckBox;
  end;

  TCDIntfRadioButton = class(TCDRadioButton)
  public
    LCLControl: TCustomCheckBox;
  end;

  TCDIntfComboBox = class(TCDComboBox)
  public
    LCLControl: TCustomComboBox;
  end;

  TCDIntfScrollBar = class(TCDScrollBar)
  public
    LCLControl: TCustomScrollBar;
  end;

  // Additional Tab

  TCDIntfStaticText = class(TCDStaticText)
  public
    LCLControl: TStaticText;
  end;

  // Common Controls Tab

  TCDIntfProgressBar = class(TCDProgressBar)
  public
    LCLControl: TCustomProgressBar;
  end;

  TCDIntfTrackBar = class(TCDTrackBar)
  public
    LCLControl: TCustomTrackBar;
  end;

  TCDIntfPageControl = class(TCDPageControl)
  public
    LCLControl: TCustomTabControl;
  end;

  // Misc

  TCDIntfSpinEdit = class(TCDSpinEdit)
  public
    LCLControl: TCustomFloatSpinEdit;
  end;

// These are default message handlers which backends might use to simplify their code
// They convert a message sent to the form into a message to the correct sub-control
procedure CallbackMouseUp(AWindowHandle: TCDForm; x, y: Integer; Button: TMouseButton; ShiftState: TShiftState = []);
procedure CallbackMouseDown(AWindowHandle: TCDForm; x, y: Integer; Button: TMouseButton; ShiftState: TShiftState = []);
procedure CallbackMouseMove(AWindowHandle: TCDForm; x, y: Integer; ShiftState: TShiftState = []);
procedure CallbackKeyDown(AWindowHandle: TCDForm; AKey: Word);
procedure CallbackKeyUp(AWindowHandle: TCDForm; AKey: Word);
procedure CallbackKeyChar(AWindowHandle: TCDForm; AKeyData: Word; AChar: TUTF8Char);
function IsIntfControl(AControl: TWinControl): Boolean;

implementation

uses customdrawnint, LCLMessageGlue;

procedure CallbackMouseUp(AWindowHandle: TCDForm; x, y: Integer; Button: TMouseButton; ShiftState: TShiftState = []);
var
  lTarget: TWinControl;
  lEventPos: TPoint;
  lEventEndsInsideTheControl: Boolean;
begin
  lTarget := AWindowHandle.LastMouseDownControl;
  AWindowHandle.LastMouseDownControl := nil;
  if lTarget = nil then lTarget := FindControlWhichReceivedEvent(
    AWindowHandle.LCLForm, AWindowHandle.Children, x, y);
  lEventPos := FormPosToControlPos(lTarget, x, y);
  LCLSendMouseUpMsg(lTarget, lEventPos.x, lEventPos.y, Button, ShiftState);

  // Send a click only if the event ends inside the control
//  DebugLn(Format('CallbackMouseUp lEventPos X=%d y=%d lTarget CX=%d CY=%d',
//    [lEventPos.X, lEventPos.y, lTarget.Width, lTarget.Height]));
  lEventEndsInsideTheControl := (lEventPos.X >= 0) and (lEventPos.Y >= 0)
    and (lEventPos.X <= lTarget.Width) and (lEventPos.Y <= lTarget.Height);
  if lEventEndsInsideTheControl then LCLSendClickedMsg(lTarget);

  // If this is a interface control, send the message to the main LCL control too
  if IsIntfControl(lTarget) then
  begin
    lTarget := lTarget.Parent;
    LCLSendMouseUpMsg(lTarget, lEventPos.x, lEventPos.y, Button, ShiftState);
    if lEventEndsInsideTheControl then LCLSendClickedMsg(lTarget);
  end;

  // Form scrolling
  AWindowHandle.IsScrolling := False;
end;

procedure CallbackMouseDown(AWindowHandle: TCDForm; x, y: Integer; Button: TMouseButton; ShiftState: TShiftState = []);
var
  lTarget: TWinControl;
  lIntfTarget: TWinControl = nil;
  lEventPos: TPoint;
begin
{  // if mouse-click, focus-change, mouse-click, cursor hasn't moved:
  // simulate double click, assume focus change due to first mouse-click
  if (MouseDownFocusStatus = mfFocusChanged) and (MouseDownFocusWindow = Window)
      and (GetTickCount - MouseDownTime <= GetDoubleClickTime)
      and CheckMouseMovement then
  begin
    PostMessage(Window, WM_LBUTTONDBLCLK, WParam, LParam);
  end;

  MouseDownTime := GetTickCount;
  MouseDownWindow := Window;
  MouseDownFocusWindow := 0;
  MouseDownFocusStatus := mfFocusSense;
  GetCursorPos(MouseDownPos);}

  lTarget := FindControlWhichReceivedEvent(AWindowHandle.LCLForm, AWindowHandle.Children, x, y);
  //DebugLn(Format('CallbackMouseDown lEventPos X=%d y=%d lTarget %s:%s',
  //  [lEventPos.X, lEventPos.y, lTarget.Name, lTarget.ClassName]));
  AWindowHandle.LastMouseDownControl := lTarget;
  AWindowHandle.FocusedControl := lTarget;
  AWindowHandle.FocusedIntfControl := nil;
  lEventPos := FormPosToControlPos(lTarget, x, y);

  LCLSendMouseDownMsg(lTarget, lEventPos.x, lEventPos.y, Button, ShiftState);

  // If this is a interface control, send the message to the main LCL control too
  if IsIntfControl(lTarget) then
  begin
    lIntfTarget := lTarget;
    AWindowHandle.FocusedIntfControl := lTarget;
    lTarget := lTarget.Parent;

    LCLSendMouseDownMsg(lTarget, lEventPos.x, lEventPos.y, Button, ShiftState);
  end;

  // If the target is focusable, a mouse down will give it focus
  CDWidgetset.CDSetFocusToControl(lTarget, lIntfTarget);

  // Check if we are scrolling the form
  if lTarget = AWindowHandle.LCLForm then
  begin
    AWindowHandle.IsScrolling := True;
    AWindowHandle.LastMousePos := lEventPos;
  end;
end;

procedure CallbackMouseMove(AWindowHandle: TCDForm; x, y: Integer; ShiftState: TShiftState = []);
var
  lTarget: TWinControl;
  lEventPos: TPoint;
  lOldScrollY: Integer;
begin
  if AWindowHandle.LastMouseDownControl = nil then
    lTarget := FindControlWhichReceivedEvent(AWindowHandle.LCLForm, AWindowHandle.Children, x, y)
  else
    lTarget := AWindowHandle.LastMouseDownControl;

  //DebugLn(Format('[CallbackMouseMove] X=%d Y=%d Control=%s', [X, Y, lTarget.Name]));

  lEventPos := FormPosToControlPos(lTarget, x, y);
  LCLSendMouseMoveMsg(lTarget, lEventPos.x, lEventPos.y, ShiftState);

  // If this is a interface control, send the message to the main LCL control too
  if IsIntfControl(lTarget) then
  begin
    lTarget := lTarget.Parent;

    LCLSendMouseMoveMsg(lTarget, lEventPos.x, lEventPos.y, ShiftState);
  end;

  // form scrolling
  if AWindowHandle.IsScrolling then
  begin
    lOldScrollY := AWindowHandle.ScrollY;
    AWindowHandle.ScrollY := AWindowHandle.LastMousePos.Y - lEventPos.Y + AWindowHandle.ScrollY;
    AWindowHandle.SanityCheckScrollPos();
    if AWindowHandle.ScrollY <> lOldScrollY then LCLIntf.InvalidateRect(HWND(AWindowHandle), nil, False);
  end;
end;

procedure CallbackKeyDown(AWindowHandle: TCDForm; AKey: Word);
var
  lTarget: TWinControl;
  lIsTab, lTabDirForward: Boolean;
  lTabNextControl: TWinControl;
  i: Integer;
begin
  lTarget := AWindowHandle.GetFocusedControl();
  {$ifdef VerboseCDEvents}
   DebugLn(Format('CallbackKeyDown FocusedControl=%s:%s AKey=%x', [lTarget.Name, lTarget.ClassName, AKey]));
  {$endif}

  lIsTab := AKey = VK_TAB;
  LCLSendKeyDownEvent(lTarget, AKey, 0, True, False);

  // If this is a interface control, send the message to the main LCL control too
  if IsIntfControl(lTarget) then
  begin
    lTarget := lTarget.Parent;
    {$ifdef VerboseCDEvents}
     DebugLn(Format('CallbackKeyDown IsIntfControl, sending msg to Parent=%s:%s', [lTarget.Name, lTarget.ClassName]));
    {$endif}
    LCLSendKeyDownEvent(lTarget, AKey, 0, True, False);
  end;

  // If the control didn't eat the tab, then circle around controls
  // Shift+Tab circles in the opposite direction
  lIsTab := lIsTab and (AKey = VK_TAB);
  if (lTarget.Parent <> nil) and lIsTab then
  begin
    lTabDirForward := LCLIntf.GetKeyState(VK_SHIFT) = 0;
    lTarget.Parent.SelectNext(lTarget, lTabDirForward, True);
  end
  // slightly different code when the currently selected item is the form itself
  else if lIsTab then
  begin
    // find the first TWinControl and select it
    lTabNextControl := nil;
    for i := 0 to lTarget.ControlCount - 1 do
      if lTarget.Controls[i] is TWinControl then
      begin
        lTabNextControl := TWinControl(lTarget.Controls[i]);
        Break;
      end;

    if lTabNextControl <> nil then lTabNextControl.SetFocus();
  end;
end;

procedure CallbackKeyUp(AWindowHandle: TCDForm; AKey: Word);
var
  lTarget: TWinControl;
begin
  lTarget := AWindowHandle.GetFocusedControl();
  if lTarget = nil then Exit;
  {$ifdef VerboseCDEvents}
   DebugLn(Format('CallbackKeyUp FocusedControl=%s:%s', [lTarget.Name, lTarget.ClassName]));
  {$endif}

  LCLSendKeyUpEvent(lTarget, AKey, 0, True, False);

  // If this is a interface control, send the message to the main LCL control too
  if IsIntfControl(lTarget) then
  begin
    lTarget := lTarget.Parent;
    LCLSendKeyUpEvent(lTarget, AKey, 0, True, False);
  end;
end;

procedure CallbackKeyChar(AWindowHandle: TCDForm; AKeyData: Word; AChar: TUTF8Char);
var
  lTarget: TWinControl;
  lCharCode: Word;
begin
  lTarget := AWindowHandle.GetFocusedControl();
  {$ifdef VerboseCDEvents}
   DebugLn(Format('CallbackKeyChar FocusedControl=%s:%s', [lTarget.Name, lTarget.ClassName]));
  {$endif}

  if lTarget = nil then Exit; // Fixes a crash
  if Length(AChar) = 1 then
    lCharCode := Byte(AChar[1])
  else
    lCharCode:=0;

  if AChar<>'' then LCLSendUTF8KeyPress(lTarget, AChar, False);
  if lCharCode <> 0 then LCLSendCharEvent(lTarget, lCharCode, AKeyData, True, False, True);

  // If this is a interface control, send the message to the main LCL control too
  if IsIntfControl(lTarget) then
  begin
    lTarget := lTarget.Parent;
    if AChar<>'' then LCLSendUTF8KeyPress(lTarget, AChar, False);
    if lCharCode <> 0 then LCLSendCharEvent(lTarget, lCharCode, AKeyData, True, False, True);
  end;
end;

function IsIntfControl(AControl: TWinControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl.Parent <> nil);
  if Result then Result :=
    // Standard Tab
    (AControl is TCDIntfButton) or (AControl is TCDIntfEdit) or (AControl is TCDIntfCheckBox) or
    (AControl is TCDIntfRadioButton) or (AControl is TCDIntfComboBox) or (AControl is TCDIntfScrollBar) or
    // Additional Tab
    (AControl is TCDIntfStaticText) or
    // Common Controls Tab
    (AControl is TCDIntfProgressBar) or (AControl is TCDIntfTrackBar) or
    (AControl is TCDIntfPageControl) or
    // Common Controls Tab
    (AControl is TCDIntfSpinEdit)
    ;
end;

{ TCDIntfEdit }

procedure TCDIntfEdit.DoChange;
var
  Msg: TLMessage;
begin
  inherited DoChange;

  // TCustomEdit responds only to CM_TEXTCHANGED, it doesn't respond to LM_CHANGED. TComboBox responds to LM_CHANGED
  FillChar(Msg{%H-}, SizeOf(Msg), 0);
  Msg.Msg := CM_TEXTCHANGED;
  DeliverMessage(LCLControl, Msg);
end;

end.

