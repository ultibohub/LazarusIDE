{%MainUnit win32wsextctrls.pp}
{ $Id: win32trayicon.inc 11994 2007-09-10 22:30:15Z marc $ }
{******************************************************************************
                 Implementation of TWin32WSCustomTrayIcon

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}

{ TWin32WSCustomTrayIcon }

type
  // IE 5+ version of TNotifyIconDataW
  TNotifyIconDataW2 = record
    cbSize: DWORD;
    hWnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of WideChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of WideChar;
    u: record
         case longint of
           0 : ( uTimeout : UINT );
           1 : ( uVersion : UINT );
          end;
    szInfoTitle: array[0..63] of WideChar;
    dwInfoFlags: DWORD;
  end;

const
  szClassName = 'TTrayIconClass';
  szAppTitle = 'apptitle';
  uIDTrayIcon = 25;

var
  msgTaskbarRestart: DWord = DWord(-1);

{*******************************************************************
*  TrayWndProc ()
*
*  DESCRIPTION:    Window procedure that processes messages for the
*                 systray icon
*
*  PARAMETERS:     Standard Mouse Messages have this parameters:
*
*                  fwKeys = wParam;        // key flags
*                  xPos = LOWORD(lParam);  // horizontal position of cursor
*                  yPos = HIWORD(lParam);  // vertical position of cursor
*                                          //* Those positions seam to be wrong
*                                          // Use Mouse.CursorPos instead
*
*  RETURNS:        A pointer to the newly created object
*
*******************************************************************}
function TrayWndProc(Handle: HWND; iMsg: UINT; WParam_: WPARAM; LParam_:LPARAM):LRESULT; stdcall;
var
  pt: TPoint;
  vwsTrayIcon: TCustomTrayIcon;
begin
  if iMsg = WM_USER + uIDTrayIcon then
  begin
    vwsTrayIcon := TCustomTrayIcon(PtrUInt(LCLIntf.GetWindowLong(Handle, GWL_USERDATA)));
    case LParam_ of
      WM_RBUTTONUP:
      begin
        pt := Mouse.CursorPos;
        if Assigned(vwsTrayIcon.OnMouseUp) then
          vwsTrayIcon.OnMouseUp(Application, mbRight, KeysToShiftState(WParam_), pt.x, pt.y);
        if Assigned(vwsTrayIcon.PopUpMenu) then
        begin
          // Apparently SetForegroundWindow and PostMessage are necessary
          // because we're invoking the shortcut menu from a notification icon
          // This is an attempt to prevent from messing with the Z-order
          SetForegroundWindow(Handle);
          PostMessage(Handle, WM_NULL, 0, 0);
          vwsTrayIcon.PopUpMenu.Popup(pt.x, pt.y);
        end;
      end;
      WM_RBUTTONDOWN:
        if Assigned(vwsTrayIcon.OnMouseDown) then
        begin
          pt := Mouse.CursorPos;
          vwsTrayIcon.OnMouseDown(Application, mbRight, KeysToShiftState(WParam_), pt.x, pt.y);
        end;
      WM_RBUTTONDBLCLK:
        if Assigned(vwsTrayIcon.OnDblClick) then
          vwsTrayIcon.OnDblClick(Application);
      WM_MBUTTONDOWN:
        if Assigned(vwsTrayIcon.OnMouseDown) then
        begin
          pt := Mouse.CursorPos;
          vwsTrayIcon.OnMouseDown(Application, mbMiddle, KeysToShiftState(WParam_), pt.x, pt.y);
        end;
      WM_MBUTTONUP:
        if Assigned(vwsTrayIcon.OnMouseUp) then
        begin
          pt := Mouse.CursorPos;
          vwsTrayIcon.OnMouseUp(Application, mbMiddle, KeysToShiftState(WParam_), pt.x, pt.y);
        end;
      WM_LBUTTONUP:
      begin
        pt := Mouse.CursorPos;
        if Assigned(vwsTrayIcon.OnMouseUp) then
          vwsTrayIcon.OnMouseUp(Application, mbLeft, KeysToShiftState(WParam_), pt.x, pt.y);
        if Assigned(vwsTrayIcon.OnClick) then
          vwsTrayIcon.OnClick(Application);
      end;
      WM_LBUTTONDOWN:
        if Assigned(vwsTrayIcon.OnMouseDown) then
        begin
          pt := Mouse.CursorPos;
          vwsTrayIcon.OnMouseDown(Application, mbLeft, KeysToShiftState(WParam_), pt.x, pt.y);
        end;
      WM_LBUTTONDBLCLK:
        if Assigned(vwsTrayIcon.OnDblClick) then
          vwsTrayIcon.OnDblClick(Application);
      WM_MOUSEMOVE:
        if Assigned(vwsTrayIcon.OnMouseMove) then
        begin
          pt := Mouse.CursorPos;
          vwsTrayIcon.OnMouseMove(Application, KeysToShiftState(WParam_), pt.x, pt.y);
        end;
    end;

    Result := 1;
    Exit;
  end
  else
  if iMsg = WM_CREATE then
  begin
    msgTaskbarRestart := RegisterWindowMessage('TaskbarCreated');
    SetWindowLongPtrW(Handle, GWL_USERDATA, PtrInt(PCREATESTRUCT(LParam_)^.lpCreateParams));
  end
  else
  if (iMsg = msgTaskbarRestart) then
  begin
    // add taskbar icon
    vwsTrayIcon := TCustomTrayIcon(PtrUInt(LCLIntf.GetWindowLong(Handle, GWL_USERDATA)));
    if Assigned(vwsTrayIcon) then
      TWin32WSCustomTrayIcon.AddIcon(vwsTrayIcon);
  end;

  Result := DefWindowProc(Handle, iMsg, WParam_, LParam_);
end;

{ TWin32WSCustomTrayIcon }

class function TWin32WSCustomTrayIcon.AddIcon(ATrayIcon: TCustomTrayIcon): Boolean;
var
  tnidw: TNotifyIconDataW2;
  WideBuffer: widestring;
begin
  // Fill TNotifyIconDataW
  tnidw := Default(TNotifyIconDataW2);
  tnidw.cbSize := SizeOf(tnidw);
  tnidw.hWnd := ATrayIcon.Handle;
  tnidw.uID := uIDTrayIcon;
  tnidw.uFlags := NIF_MESSAGE or NIF_ICON;
  if (ATrayIcon.Hint <> '') then tnidw.uFlags := tnidw.uFlags or NIF_TIP;
  tnidw.uCallbackMessage := WM_USER + uIDTrayIcon;
  tnidw.hIcon := ATrayIcon.Icon.Handle;

  WideBuffer := UTF8ToUTF16(ATrayIcon.Hint);
  WideStrLCopy(@tnidw.szTip[0], PWideChar(WideBuffer), SizeOf(tnidw.szTip));

  Result := Shell_NotifyIconW(NIM_ADD, PNotifyIconDataW(@tnidw));
  if not Result then
  begin
    // Try old version of TNotifyIconDataW
    tnidw.cbSize := SizeOf(TNotifyIconDataW);
    WideStrLCopy(@tnidw.szTip[0], PWideChar(WideBuffer), 63);
    Result := Shell_NotifyIconW(NIM_MODIFY, PNotifyIconDataW(@tnidw));
  end;
end;

{*******************************************************************
*  TWin32WSCustomTrayIcon.Hide ()
*
*  DESCRIPTION:    Hides the main tray icon of the program
*
*  PARAMETERS:     None
*
*  RETURNS:        True if sucessfull, otherwise False
*
*******************************************************************}

class function TWin32WSCustomTrayIcon.Hide(const ATrayIcon: TCustomTrayIcon): Boolean;
var
  tnid: TNotifyIconData;
begin
  // Fill TNotifyIconData
  tnid := Default(TNotifyIconData);
  tnid.cbSize := SizeOf(TNotifyIconData);
  tnid.hWnd := ATrayIcon.Handle;
  tnid.uID := uIDTrayIcon;

  // Remove the icon
  Result := Shell_NotifyIconA(NIM_DELETE, @tnid);

  // Destroys the helper Windows
  SendMessage(ATrayIcon.Handle, WM_CLOSE, 0, 0);
  SendMessage(ATrayIcon.Handle, WM_DESTROY, 0, 0);
end;

{*******************************************************************
*  TWin32WSCustomTrayIcon.Show ()
*
*  DESCRIPTION:    Shows the main tray icon of the program
*
*  PARAMETERS:     None
*
*  RETURNS:        True if sucessfull, otherwise False
*
*******************************************************************}
class function TWin32WSCustomTrayIcon.Show(const ATrayIcon: TCustomTrayIcon): Boolean;
var
  Window: Windows.TWNDClassEx;
begin
  if not GetClassInfoEx(hInstance, szClassName, @Window) then
  begin
    Window := Default(Windows.TWNDClassEx);
    Window.cbSize := SizeOf(TWndClassEx);
    Window.style := CS_OWNDC;
    Window.lpfnWndProc := @TrayWndProc;
    Window.cbClsExtra := 0;
    Window.cbWndExtra := 0;
    Window.hInstance := hInstance;
    Window.hCursor := Windows.LoadCursor(0, IDC_ARROW);
    Window.hbrBackground := HBRUSH(GetStockObject(NULL_BRUSH));
    Window.lpszMenuName := nil;
    Window.lpszClassName := szClassName;
    Windows.RegisterClassEx(Window);
  end;

  ATrayIcon.Handle := CreateWindowEx(
        0,            //* Ensure that there will be no button in the bar */
        szClassName,        //* Name of the registered class */
        szAppTitle,         //* Title of the window */
        0,                  //* Style of the window */
        0,                  //* x-position (at beginning) */
        0,                  //* y-position (at beginning) */
        CW_USEDEFAULT,      //* window width */
        CW_USEDEFAULT,      //* window height */
        0,                  //* handle to parent or owner window */
        0,                  //* handle to menu */
        hInstance,          //* handle to application instance */
        ATrayIcon);               //* pointer to window-creation data */

  Result := AddIcon(ATrayIcon);
end;

{*******************************************************************
*  TWin32WSCustomTrayIcon.InternalUpdate ()
*
*  DESCRIPTION:    Makes modifications to the Icon while running
*                  i.e. without hiding it and showing again
*
*******************************************************************}
class procedure TWin32WSCustomTrayIcon.InternalUpdate(const ATrayIcon: TCustomTrayIcon);
var
  tnidw: TNotifyIconDataW2;
  WideBuffer: widestring;
begin
  // Fill TNotifyIconDataW
  tnidw := Default(TNotifyIconDataW2);
  tnidw.cbSize := SizeOf(tnidw);
  tnidw.hWnd := ATrayIcon.Handle;
  tnidw.uID := uIDTrayIcon;
  tnidw.hIcon := ATrayIcon.Icon.Handle;
  tnidw.uFlags := NIF_TIP or NIF_ICON;

  WideBuffer := UTF8ToUTF16(ATrayIcon.Hint);
  WideStrLCopy(@tnidw.szTip[0], PWideChar(WideBuffer), SizeOf(tnidw.szTip));

  if not Shell_NotifyIconW(NIM_MODIFY, PNotifyIconDataW(@tnidw)) then
  begin
    // Try old version of TNotifyIconDataW
    tnidw.cbSize := SizeOf(TNotifyIconDataW);
    WideStrLCopy(@tnidw.szTip[0], PWideChar(WideBuffer), 63);
    Shell_NotifyIconW(NIM_MODIFY, PNotifyIconDataW(@tnidw));
  end;
end;

{*******************************************************************
*  TWin32WSCustomTrayIcon.ShowBalloonHint ()
*
*  DESCRIPTION:    Shows a small message balloon near the tray icon
*
*  RETURNS:        False if the default cross-platform hint should be used
*                  True if a platform-specific hint will be used
*
*******************************************************************}
class function TWin32WSCustomTrayIcon.ShowBalloonHint(const ATrayIcon: TCustomTrayIcon): Boolean;
const
  FlagsMap: array[TBalloonFlags] of dword = (NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR);
var
  NotifyData: TNotifyIconDataW2;
  w: WideString;
begin
  NotifyData.cbSize:=SizeOf(NotifyData);
  NotifyData.hWnd := ATrayIcon.Handle;
  NotifyData.uID := uIDTrayIcon;
  NotifyData.uFlags:=NIF_INFO;
  NotifyData.u.uTimeout:=ATrayIcon.BalloonTimeout;
  w:=UTF8ToUTF16(ATrayIcon.BalloonHint);
  WideStrLCopy(@NotifyData.szInfo[0], PWideChar(w), High(NotifyData.szInfo));
  w:=UTF8ToUTF16(ATrayIcon.BalloonTitle);
  WideStrLCopy(@NotifyData.szInfoTitle[0], PWideChar(w), High(NotifyData.szInfoTitle));
  NotifyData.dwInfoFlags:=FlagsMap[ATrayIcon.BalloonFlags];

  Result:= Shell_NotifyIconW(NIM_MODIFY, PNotifyIconDataW(@NotifyData));
end;

{*******************************************************************
*  TWin32WSCustomTrayIcon.GetPosition ()
*
*  DESCRIPTION:    Returns the position of the tray icon on the display.
*                  This function is utilized to show message boxes near
*                  the icon
*
*******************************************************************}
function EnumChildProc(handle: HWND; lp: LParam): LongBool; stdcall;
begin
  if Pos('ToolbarWindow32', WndClassName(handle)) > 0 then
  begin
    LParam(Pointer(lp)^) := handle;
    Result := False;
  end
  else
    Result := True;
end;

class function TWin32WSCustomTrayIcon.GetPosition(const ATrayIcon: TCustomTrayIcon): TPoint;
var
  hWndTaskbar, hWndTray: HWND;
  TaskbarRect, TrayRect: TRect;
  TaskbarMonitor: TMonitor;
begin
  Result := Point(0, 0);

  { First we get the Taskbar window and it's screen position }
  hWndTaskbar := FindWindow('Shell_TrayWnd', nil);

  if hWndTaskbar = 0 then Exit;
  
  Windows.GetWindowRect(hWndTaskbar, @TaskbarRect);
  
  hWndTray := ATrayIcon.Handle;

  { Then we locate inside the Tray area, which is just a Toolbar control }
  EnumChildWindows(hWndTaskbar, @EnumChildProc, LParam(@hWndTray));

  if hWndTray = 0 then Exit;

  { And we get the size of that control }
  Windows.GetWindowRect(hWndTray, @TrayRect);
  // OBS: Here TrayRect seams to have a wrong value, so we don't use it

  { We need this in order to "normalize" in later if statements. This is required to get right coordinates on multiple monitors }
  TaskbarMonitor := Screen.MonitorFromWindow(hWndTaskbar);

  { Returns an aproximate position of the tray area }
  if (TaskbarRect.Top - TaskbarMonitor.Top = 0) and (TaskbarRect.Left - TaskbarMonitor.Left = 0) then
  begin
    { Taskbar is at the top of the monitor area OR on the left side of the monitor area }
    Result.X := TaskbarRect.Right;
    Result.Y := TaskbarRect.Bottom;
  end
  else if (TaskbarRect.Left - TaskbarMonitor.Left = 0) then
  begin
    { Taskbar is at the bottom of the monitor area }
    Result.X := TaskbarRect.Right;
    Result.Y := TaskbarRect.Top;
  end
  else
  begin
    Result.X := TaskbarRect.Left;
    Result.Y := TaskbarRect.Bottom;
    { Taskbar is on the right side of the monitor area }
  end;
end;


