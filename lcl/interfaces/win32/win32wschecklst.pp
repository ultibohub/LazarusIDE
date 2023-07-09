{
 *****************************************************************************
 *                            Win32WSCheckLst.pp                             * 
 *                            ------------------                             * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit Win32WSCheckLst;

{$mode objfpc}{$H+}
{$i win32defines.inc}

interface

uses
////////////////////////////////////////////////////
// I M P O R T A N T                                
////////////////////////////////////////////////////
// To get as little as posible circles,
// uncomment only when needed for registration
////////////////////////////////////////////////////
  Windows, Classes, Controls, CheckLst, StdCtrls, Themes, Graphics, LCLType,
  LazUTF8, LMessages, LCLMessageGlue,
////////////////////////////////////////////////////
  WSCheckLst, WSLCLClasses, Win32Int, Win32Proc, Win32WSControls, Win32WSStdCtrls;

type

  { TWin32WSCustomCheckListBox }

  TWin32WSCustomCheckListBox = class(TWSCustomCheckListBox)
  published
    class function CreateHandle(const AWinControl: TWinControl;
       const AParams: TCreateParams): TLCLHandle; override;
    class procedure DefaultWndHandler(const AWinControl: TWinControl;
       var AMessage); override;
    class function GetStrings(const ACustomListBox: TCustomListBox): TStrings; override;
    class function GetItemEnabled(const ACheckListBox: TCustomCheckListBox;
      const AIndex: integer): Boolean; override;
    class function GetState(const ACheckListBox: TCustomCheckListBox;
      const AIndex: integer): TCheckBoxState; override;
    class procedure SetItemEnabled(const ACheckListBox: TCustomCheckListBox;
      const AIndex: integer; const AEnabled: Boolean); override;
    class procedure SetState(const ACheckListBox: TCustomCheckListBox;
      const AIndex: integer; const AState: TCheckBoxState); override;
    class function GetHeader(const ACheckListBox: TCustomCheckListBox;
      const AIndex: Integer): Boolean; override;
    class procedure SetHeader(const ACheckListBox: TCustomCheckListBox;
      const AIndex: Integer; const AHeader: Boolean); override;
  end;


implementation

function CheckListBoxWndProc(Window: HWnd; Msg: UInt; WParam: Windows.WParam;
    LParam: Windows.LParam): LResult; stdcall;
var
  WindowInfo: PWin32WindowInfo;

  procedure CheckListBoxLButtonDown;
  var
    I: Integer;
    ItemRect: Windows.Rect;
    MousePos: Windows.Point;
    Message: TLMessage;
  begin
    MousePos.X := GET_X_LPARAM(LParam);
    MousePos.Y := GET_Y_LPARAM(LParam);
    for I := 0 to Windows.SendMessage(Window, LB_GETCOUNT, 0, 0) - 1 do
    begin
      Windows.SendMessage(Window, LB_GETITEMRECT, I, PtrInt(@ItemRect));
      if TCheckListbox(WindowInfo^.WinControl).UseRightToLeftAlignment then
        ItemRect.Left := ItemRect.Right - ItemRect.Bottom + ItemRect.Top
      else
        ItemRect.Right := ItemRect.Left + ItemRect.Bottom - ItemRect.Top;
      if Windows.PtInRect(ItemRect, MousePos) then
      begin
        // item clicked: toggle
        if I < TCheckListBox(WindowInfo^.WinControl).Items.Count then
        begin
          if TCheckListBox(WindowInfo^.WinControl).ItemEnabled[I] then
          begin
            TCheckListBox(WindowInfo^.WinControl).Toggle(I);
            Message.Msg := LM_CHANGED;
            Message.WParam := I;
            DeliverMessage(WindowInfo^.WinControl, Message);
          end;
        end;
        // can only click one item
        Exit;
      end;
    end;
  end;

var
  Count: LResult;
  Top: Integer;
  ARect: TRect;
begin
  // move checlistbox specific code here

  case Msg of
    WM_DESTROY:
    begin
      TWin32CheckListBoxStrings.DeleteItemRecords(Window);
    end;
    WM_PAINT,
    WM_PRINTCLIENT:
      begin
        Result := CallDefaultWindowProc(Window, Msg, WParam, LParam);
        Exit;
      end;
    WM_ERASEBKGND:
      begin
        WindowInfo := GetWin32WindowInfo(Window);
        Count := SendMessage(Window, LB_GETCOUNT, 0, 0);
        if Assigned(WindowInfo^.WinControl) and
           (TCustomListBox(WindowInfo^.WinControl).Columns < 2) and
           (Count <> LB_ERR) and (SendMessage(Window, LB_GETITEMRECT, Count - 1, Windows.LParam(@ARect)) <> LB_ERR) then
        begin
          Top := ARect.Bottom;
          Windows.GetClientRect(Window, ARect);
          ARect.Top := Top;
          if not IsRectEmpty(ARect) then
            Windows.FillRect(HDC(WParam), ARect, WindowInfo^.WinControl.Brush.Reference.Handle);
          Result := 1;
        end
        else
          Result := CallDefaultWindowProc(Window, Msg, WParam, LParam);
        Exit;
      end;
  end;

  Result := ListBoxWindowProc(Window, Msg, WParam, LParam);

  case Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
    begin
      WindowInfo := GetWin32WindowInfo(Window);
      if WindowInfo^.WinControl <> nil then
        CheckListBoxLButtonDown;
    end;
  end;
end;

class function TWin32WSCustomCheckListBox.CreateHandle(
  const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle;
var
  Params: TCreateWindowExParams;
begin
  // general initialization of Params
  PrepareCreateWindow(AWinControl, AParams, Params);
  with Params do
  begin
    pClassName := ListBoxClsName;
    pSubClassName := LCLCheckListboxClsName;
    SubClassWndProc := @CheckListBoxWndProc;
    // require always owner-drawn, add flags if not already set due to Style
    if (Flags and (LBS_OWNERDRAWFIXED or LBS_OWNERDRAWVARIABLE)) = 0 then
      Flags:= Flags or LBS_OWNERDRAWFIXED;
  end;
  // create window
  FinishCreateWindow(AWinControl, Params, False, True);
  Result := Params.Window;
end;

class procedure TWin32WSCustomCheckListBox.DefaultWndHandler(
  const AWinControl: TWinControl; var AMessage);

  procedure DrawCheckListBoxItem(CheckListBox: TCheckListBox; Data: PDrawItemStruct);
  const
    ThemeStateMap: array[TCheckBoxState, Boolean] of TThemedButton =
    (
     {cbUnchecked} (tbCheckBoxUncheckedDisabled, tbCheckBoxUncheckedNormal),
     {cbChecked  } (tbCheckBoxCheckedDisabled, tbCheckBoxCheckedNormal),
     {cbGrayed   } (tbCheckBoxMixedDisabled, tbCheckBoxMixedNormal)
    );
  var
    Enabled, Selected, Header: Boolean;
    ARect, TextRect: Windows.Rect;
    Details: TThemedElementDetails;
    TextFlags: DWord;
    OldColor: COLORREF;
    OldBkMode: Integer;
    sz: TSize;
    WideBuffer: widestring;
    HdrBg, HdrTxt: TColor;
    BgBrush: Windows.HBRUSH;
  begin
    Selected := (Data^.itemState and ODS_SELECTED) > 0;
    Enabled := CheckListBox.Enabled and CheckListBox.ItemEnabled[Data^.itemID];
    Header := CheckListBox.Header[Data^.itemID];

    if Header then
    begin
      HdrBg := CheckListBox.HeaderBackgroundColor;
      if HdrBg = clDefault then HdrBg := clInfoBk;
      HdrTxt := CheckListBox.HeaderColor;
      if HdrTxt = clDefault then HdrTxt := clInfoText;
    end;

    ARect := Data^.rcItem;
    TextRect := ARect;

    // adjust text rectangle for check box and padding
    if not Header then
    begin
      if CheckListBox.UseRightToLeftAlignment then
        TextRect.Right := TextRect.Right - TextRect.Bottom + TextRect.Top - 4
      else
        TextRect.Left := TextRect.Left + TextRect.Bottom - TextRect.Top + 4;
    end;

    // fill the background
    if Header then
    begin
      BgBrush := Windows.CreateSolidBrush(ColorToRGB(HdrBg));
      Windows.FillRect(Data^._HDC, ARect, BgBrush);
      Windows.DeleteObject(BgBrush);
    end
    else if Selected then
    begin
      Windows.FillRect(Data^._HDC, Rect(ARect.Left, ARect.Top, TextRect.Left, ARect.Bottom), CheckListBox.Brush.Reference.Handle);
      Windows.FillRect(Data^._HDC, TextRect, GetSysColorBrush(COLOR_HIGHLIGHT));
    end
    else
      Windows.FillRect(Data^._HDC, ARect, CheckListBox.Brush.Reference.Handle);

    // draw checkbox
    if not Header then
    begin
      if CheckListBox.UseRightToLeftAlignment then
        ARect.Left := ARect.Right - ARect.Bottom + ARect.Top
      else
        ARect.Right := ARect.Left + ARect.Bottom - ARect.Top;

      Details := ThemeServices.GetElementDetails(ThemeStateMap[CheckListBox.State[Data^.ItemID], Enabled]);
      sz := ThemeServices.GetDetailSize(Details);
      sz.cx := MulDiv(sz.cx, CheckListBox.Font.PixelsPerInch, ScreenInfo.PixelsPerInchX);
      sz.cy := MulDiv(sz.cy, CheckListBox.Font.PixelsPerInch, ScreenInfo.PixelsPerInchY);
      ARect := Bounds((ARect.Left + ARect.Right - sz.cx) div 2, (ARect.Top + ARect.Bottom - sz.cy) div 2,
        sz.cx, sz.cy);
      OffsetRect(ARect, 1, 1);
      ThemeServices.DrawElement(Data^._HDC, Details, ARect);
    end;

    // draw text
    if CheckListBox.UseRightToLeftAlignment then begin
      TextRect.Right := TextRect.Right - 2;
      TextFlags := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_RIGHT or DT_RTLREADING;
    end
    else
    begin
      TextRect.Left := TextRect.Left + 2;
      TextFlags := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
    end;
    OldBkMode := Windows.SetBkMode(Data^._HDC, TRANSPARENT);
    if not Enabled then
      OldColor := Windows.SetTextColor(Data^._HDC, Windows.GetSysColor(COLOR_GRAYTEXT))
    else if Header then
      OldColor := Windows.SetTextColor(Data^._HDC, ColorToRGB(HdrTxt))
    else if Selected then
      OldColor := Windows.SetTextColor(Data^._HDC, Windows.GetSysColor(COLOR_HIGHLIGHTTEXT))
    else
    begin
      OldColor := TColorRef(CheckListBox.Font.Color);
      if OldColor = clDefault then
        OldColor := TColorRef(CheckListBox.GetDefaultColor(dctFont));
      OldColor := Windows.SetTextColor(Data^._HDC, ColorToRGB(TColor(OldColor)));
    end;
    WideBuffer := UTF8ToUTF16(CheckListBox.Items[Data^.ItemID]);
    Windows.DrawTextW(Data^._HDC, PWideChar(WideBuffer), -1,
     TextRect, TextFlags);
    // restore old colors
    Windows.SetTextColor(Data^._HDC, OldColor);
    Windows.SetBkMode(Data^._HDC, OldBkMode);
    if Enabled and ((Data^.itemState and ODS_FOCUS) > 0) and CheckListBox.Focused then
    begin
      if CheckListBox.UseRightToLeftAlignment then
        TextRect.Right := TextRect.Right + 2
      else
        TextRect.Left := TextRect.Left - 2;
      Windows.DrawFocusRect(Data^._HDC, TextRect);
    end;
  end;

begin
  case TLMessage(AMessage).Msg of
    LM_DRAWITEM:
    begin
      { If the user set one of the OwnerDraw Styles, the widgetset will have translated the draw messages to LM_DRAWLISTITEM
        instead (in TWindowProcHelper.DoMsgDrawItem). This means we don't get to draw the checkmark and the CLB looks like a
        regular list.
      }
      with TLMDrawItems(AMessage) do
      begin
        // ItemID not UINT(-1)
        if DrawItemStruct^.ItemID <> DWORD($FFFFFFFF) then
          DrawCheckListBoxItem(TCheckListBox(AWinControl), DrawItemStruct);
      end;
    end;

    { LM_MEASUREITEM:
      TCustomListBox has a message handler, so DefaultWndHandler is never called.
      We handle CLB specialcasing via a CalculateStandardItemHeight override
    }
  end;

  inherited DefaultWndHandler(AWinControl, AMessage);
end;

class function  TWin32WSCustomCheckListBox.GetStrings(const ACustomListBox: TCustomListBox): TStrings;
var
  Handle: HWND;
begin
  Handle := ACustomListBox.Handle;
  Result := TWin32CheckListBoxStrings.Create(Handle, ACustomListBox);
  GetWin32WindowInfo(Handle)^.List := Result;
end;

class function TWin32WSCustomCheckListBox.GetHeader(const ACheckListBox: TCustomCheckListBox;
  const AIndex: integer): Boolean;
begin
  Result := TWin32CheckListBoxStrings(ACheckListBox.Items).Header[AIndex];
end;

class function TWin32WSCustomCheckListBox.GetItemEnabled(
  const ACheckListBox: TCustomCheckListBox; const AIndex: integer): Boolean;
begin
  Result := TWin32CheckListBoxStrings(ACheckListBox.Items).Enabled[AIndex];
end;

class function TWin32WSCustomCheckListBox.GetState(
  const ACheckListBox: TCustomCheckListBox; const AIndex: integer
  ): TCheckBoxState;
begin
  Result := TWin32CheckListBoxStrings(ACheckListBox.Items).State[AIndex];
end;

class procedure TWin32WSCustomCheckListBox.SetItemEnabled(
  const ACheckListBox: TCustomCheckListBox; const AIndex: integer;
  const AEnabled: Boolean);
var
  SizeRect: Windows.RECT;
  Handle: HWND;
begin
  TWin32CheckListBoxStrings(ACheckListBox.Items).Enabled[AIndex] := AEnabled;

  // redraw control
  Handle := ACheckListBox.Handle;
  Windows.SendMessage(Handle, LB_GETITEMRECT, AIndex, LPARAM(@SizeRect));
  Windows.InvalidateRect(Handle, @SizeRect, False);
end;

class procedure TWin32WSCustomCheckListBox.SetHeader(const ACheckListBox: TCustomCheckListBox;
  const AIndex: integer; const AHeader: Boolean);
var
  SizeRect: Windows.RECT;
  Handle: HWND;
begin
  TWin32CheckListBoxStrings(ACheckListBox.Items).Header[AIndex] := AHeader;

  // redraw control
  Handle := ACheckListBox.Handle;
  Windows.SendMessage(Handle, LB_GETITEMRECT, AIndex, LPARAM(@SizeRect));
  Windows.InvalidateRect(Handle, @SizeRect, False);
end;

class procedure TWin32WSCustomCheckListBox.SetState(
  const ACheckListBox: TCustomCheckListBox; const AIndex: integer;
  const AState: TCheckBoxState);
var
  SizeRect: Windows.RECT;
  Handle: HWND;
begin
  TWin32CheckListBoxStrings(ACheckListBox.Items).State[AIndex] := AState;

  // redraw control
  Handle := ACheckListBox.Handle;
  Windows.SendMessage(Handle, LB_GETITEMRECT, AIndex, LPARAM(@SizeRect));
  Windows.InvalidateRect(Handle, @SizeRect, False);
end;

end.
