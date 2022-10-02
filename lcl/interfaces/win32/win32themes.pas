unit Win32Themes;

{$mode objfpc}{$H+}
{$I win32defines.inc}

interface

uses
  // os
  Windows, UxTheme, Win32Proc, Win32Extra, Win32Int,
  // rtl
  Classes, SysUtils,
  // lcl
  Controls, Graphics, Themes, LCLType, InterfaceBase, LazUTF8;
  
type

  TThemeData = array[TThemedElement] of HTHEME;
  { TWin32ThemeServices }

  TWin32ThemeServices = class(TThemeServices)
  private
    FThemeData: TThemeData;            // Holds a list of theme data handles.
  protected
    function GetTheme(Element: TThemedElement): HTHEME;
    function InitThemes: Boolean; override;
    procedure UnloadThemeData; override;
    function UseThemes: Boolean; override;
    function ThemedControlsEnabled: Boolean; override;
    
    function InternalColorToRGB(Details: TThemedElementDetails; Color: TColor): COLORREF; override;
    procedure InternalDrawParentBackground(Window: HWND; Target: HDC; Bounds: PRect); override;

    function GetImageAndMaskFromIcon(const Icon: HICON; out Image, Mask: HBITMAP): Boolean;
  public
    destructor Destroy; override;

    function GetDetailSize(Details: TThemedElementDetails): TSize; override;
    function GetDetailRegion(DC: HDC; Details: TThemedElementDetails; const R: TRect): HRGN; override;
    function GetStockImage(StockID: LongInt; out Image, Mask: HBitmap): Boolean; override;
    function GetStockImage(StockID: LongInt; const AWidth, AHeight: Integer; out Image, Mask: HBitmap): Boolean; override;
    function GetOption(AOption: TThemeOption): Integer; override;
    function GetTextExtent(DC: HDC; Details: TThemedElementDetails; const S: String; Flags: Cardinal; BoundingRect: PRect): TRect; override;

    procedure DrawElement(DC: HDC; Details: TThemedElementDetails; const R: TRect;
      ClipRect: PRect = nil); override;
    procedure DrawEdge(DC: HDC; Details: TThemedElementDetails; const R: TRect; Edge, Flags: Cardinal;
      AContentRect: PRect = nil); override;
    procedure DrawIcon(DC: HDC; Details: TThemedElementDetails; const R: TRect;
      himl: HIMAGELIST; Index: Integer); override;

    procedure DrawText(DC: HDC; Details: TThemedElementDetails;
      const S: String; R: TRect; Flags, Flags2: Cardinal); override;
    procedure DrawText(ACanvas: TPersistent; Details: TThemedElementDetails;
      const S: String; R: TRect; Flags, Flags2: Cardinal); override;

    procedure DrawTextEx(DC: HDC; Details: TThemedElementDetails;
      const S: String; R: TRect; Flags: Cardinal; Options: PDTTOpts);

    function ContentRect(DC: HDC; Details: TThemedElementDetails; BoundingRect: TRect): TRect; override;
    function HasTransparentParts(Details: TThemedElementDetails): Boolean; override;
    procedure PaintBorder(Control: TObject; EraseLRCorner: Boolean); override;
    property Theme[Element: TThemedElement]: HTHEME read GetTheme;
  end;

implementation

uses
  TmSchema;

const
  ThemeDataNames: array[TThemedElement] of PWideChar = (
    'button',      // teButton
    'clock',       // teClock
    'combobox',    // teComboBox
    'edit',        // teEdit
    'explorerbar', // teExplorerBar
    'header',      // teHeader
    'listview',    // teListView
    'menu',        // teMenu
    'page',        // tePage
    'progress',    // teProgress
    'rebar',       // teRebar
    'scrollbar',   // teScrollBar
    'spin',        // teSpin
    'startpanel',  // teStartPanel
    'status',      // teStatus
    'tab',         // teTab
    'taskband',    // teTaskBand
    'taskbar',     // teTaskBar
    'toolbar',     // teToolBar
    'tooltip',     // teToolTip
    'trackbar',    // teTrackBar
    'traynotify',  // teTrayNotify
    'treeview',    // teTreeview
    'window'       // teWindow
  );

  ThemeDataNamesVista: array[TThemedElement] of PWideChar = (
    'button',      // teButton
    'clock',       // teClock
    'combobox',    // teComboBox
    'edit',        // teEdit
    'explorerbar', // teExplorerBar
    'header',      // teHeader
    'explorer::listview',    // teListView
    'menu',        // teMenu
    'page',        // tePage
    'progress',    // teProgress
    'rebar',       // teRebar
    'scrollbar',   // teScrollBar
    'spin',        // teSpin
    'startpanel',  // teStartPanel
    'status',      // teStatus
    'tab',         // teTab
    'taskband',    // teTaskBand
    'taskbar',     // teTaskBar
    'toolbar',     // teToolBar
    'tooltip',     // teToolTip
    'trackbar',    // teTrackBar
    'traynotify',  // teTrayNotify
    'explorer::treeview',    // teTreeview
    'window'       // teWindow
  );

  // standard windows icons (WinUser.h)
  // they are already defined in the rtl, however the
  // const = const defines after this fail with an illegal expression
  IDI_APPLICATION = System.MakeIntResource(32512);
  IDI_HAND        = System.MakeIntResource(32513);
  IDI_QUESTION    = System.MakeIntResource(32514);
  IDI_EXCLAMATION = System.MakeIntResource(32515);
  IDI_ASTERISK    = System.MakeIntResource(32516);
  IDI_WINLOGO     = System.MakeIntResource(32517); // XP only
  IDI_SHIELD      = System.MakeIntResource(32518);

  IDI_WARNING     = IDI_EXCLAMATION;
  IDI_ERROR       = IDI_HAND;
  IDI_INFORMATION = IDI_ASTERISK;

{ TWin32ThemeServices }

procedure TWin32ThemeServices.UnloadThemeData;
var
  Entry: TThemedElement;
begin
  for Entry := Low(TThemeData) to High(TThemeData) do
    if FThemeData[Entry] <> 0 then
    begin
      CloseThemeData(FThemeData[Entry]);
      FThemeData[Entry] := 0;
    end;
end;

function TWin32ThemeServices.InitThemes: Boolean;
begin
  Result := InitThemeLibrary;
  FThemeData := Default(TThemeData);
end;

destructor TWin32ThemeServices.Destroy;
begin
  inherited Destroy;
  FreeThemeLibrary;
end;

function TWin32ThemeServices.GetDetailSize(Details: TThemedElementDetails): TSize;
var
  R: TRect;
begin
  // GetThemeInt(Theme[Details.Element], Details.Part, Details.State, TMT_HEIGHT, Result);
  // does not work for some reason
  if ThemesEnabled then
  begin
    if (Details.Element = teToolBar) and (Details.Part = TP_SPLITBUTTONDROPDOWN) then
       Result.cx := MulDiv(12, ScreenInfo.PixelsPerInchX, 96)
    else
    if ((Details.Element = teTreeview) and (Details.Part in [TVP_GLYPH, TVP_HOTGLYPH])) or
       ((Details.Element = teWindow) and (Details.Part in [WP_SMALLCLOSEBUTTON])) or
       (Details.Element = teTrackBar) or (Details.Element = teHeader) then
    begin
      R := Rect(0, 0, 800, 800);
      GetThemePartSize(GetTheme(Details.Element), 0, Details.Part, Details.State, @R, TS_TRUE, Result);
    end
    else
      Result := inherited GetDetailSize(Details);
  end
  else
    Result := inherited GetDetailSize(Details);
end;

function TWin32ThemeServices.GetImageAndMaskFromIcon(const Icon: HICON; out Image, Mask: HBITMAP): Boolean;
var
  IconInfo: TIconInfo;
  Bitmap: Windows.TBitmap;
  x, y: Integer;
  LinePtr: PByte;
  Pixel: PRGBAQuad;
  SHIconInfo: TSHSTOCKICONINFO;
begin
  Result := GetIconInfo(Icon, @IconInfo);
  if not Result then
    Exit;

  Image := IconInfo.hbmColor;
  Mask := IconInfo.hbmMask;

  if WindowsVersion >= wvXP then Exit; // XP and up return alpha bitmaps
  if GetObject(Image, SizeOf(Bitmap), @Bitmap) = 0 then Exit;
  if Bitmap.bmBitsPixel <> 32 then Exit; // we only need to "fix" 32bpp images

  Image := CopyImage(IconInfo.hbmColor, IMAGE_BITMAP, 0, 0, LR_COPYDELETEORG or LR_CREATEDIBSECTION);
  if WindowsVersion in [wv95, wv98, wvME]
  then begin
    // 95 or ME aren't tested, so if icons appear invisible remove them
    // only copying is enough
    Exit;
  end;

  // Others remain ( wvUnknown, wvNT4, wv2000 )

  if GetObject(Image, SizeOf(Bitmap), @Bitmap) = 0 then Exit; // ???
  if Bitmap.bmBits = nil then Exit; // ?? we requested a dibsection, but didn't get one ??

  LinePtr := Bitmap.bmBits;

  for y := Bitmap.bmHeight downto 1 do
  begin
    Pixel := Pointer(LinePtr);
    for x := Bitmap.bmWidth downto 1 do
    begin
      Pixel^.Alpha := 255;
      Inc(Pixel);
    end;
    Inc(LinePtr, Bitmap.bmWidthBytes);
  end;
end;

function TWin32ThemeServices.GetDetailRegion(DC: HDC;
  Details: TThemedElementDetails; const R: TRect): HRGN;
begin
  Result := 0;
  if ThemesEnabled then
    GetThemeBackgroundRegion(GetTheme(Details.Element), DC, Details.Part, Details.State, R, Result)
  else
    Result := inherited;
end;

function TWin32ThemeServices.GetStockImage(StockID: LongInt; out Image, Mask: HBitmap): Boolean;
var
  IconHandle: HIcon;
  SHIconInfo: TSHSTOCKICONINFO;
begin
  case StockID of
    idDialogWarning: IconHandle := LoadImage(0, IDI_WARNING, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE or LR_SHARED);
    idDialogError  : IconHandle := LoadImage(0, IDI_ERROR, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE or LR_SHARED);
    idDialogInfo   : IconHandle := LoadImage(0, IDI_INFORMATION, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE or LR_SHARED);
    idDialogConfirm: IconHandle := LoadImage(0, IDI_QUESTION, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE or LR_SHARED);
    idDialogShield:
      begin
        SHIconInfo := Default(TSHSTOCKICONINFO);
        SHIconInfo.cbSize := SizeOf(SHIconInfo);
        if (SHGetStockIconInfo(SIID_SHIELD, SHGFI_ICON or SHGFI_LARGEICON, @SHIconInfo) = S_OK) then
          IconHandle := SHIconInfo.hIcon
        else
          IconHandle := 0;
      end;
    idButtonShield:
      begin
        SHIconInfo := Default(TSHSTOCKICONINFO);
        SHIconInfo.cbSize := SizeOf(SHIconInfo);
        if (SHGetStockIconInfo(SIID_SHIELD, SHGFI_ICON or SHGFI_SMALLICON, @SHIconInfo) = S_OK) then
          IconHandle := SHIconInfo.hIcon
        else
          IconHandle := 0;
      end;
  else
    IconHandle := 0;
  end;
  Result := (IconHandle <> 0) and GetImageAndMaskFromIcon(IconHandle, Image, Mask);
  if not Result then
  begin
    Result := inherited GetStockImage(StockID, Image, Mask);
    Exit;
  end;
end;

function TWin32ThemeServices.GetStockImage(StockID: LongInt; const AWidth, AHeight: Integer; out Image,
  Mask: HBitmap): Boolean;
const
  WIN_ICONS: array[idDialogWarning..idDialogShield] of PWideChar = (IDI_WARNING, IDI_ERROR, IDI_INFORMATION, IDI_QUESTION, IDI_SHIELD);
var
  IconHandle: HICON;
  Ico: TIcon;
begin
  IconHandle := 0;
  Result := (StockID>=Low(WIN_ICONS)) and (StockID<=High(WIN_ICONS)) and (WIN_ICONS[StockID]<>nil)
    and (LoadIconWithScaleDown(0, WIN_ICONS[StockID], AWidth, AHeight, IconHandle)=S_OK);

  Result := (IconHandle <> 0) and GetImageAndMaskFromIcon(IconHandle, Image, Mask);
  if not Result then
  begin
    Result := inherited GetStockImage(StockID, Image, Mask);
    Exit;
  end;
end;

function TWin32ThemeServices.GetOption(AOption: TThemeOption): Integer;
begin
  case AOption of
    toShowButtonImages: Result := 0;
  else
    Result := inherited GetOption(AOption);
  end;
end;

function TWin32ThemeServices.GetTextExtent(DC: HDC; Details: TThemedElementDetails;
  const S: String; Flags: Cardinal; BoundingRect: PRect): TRect;
var
  w: widestring;
begin
  if ThemesEnabled then
    with Details do
    begin
      w := UTF8ToUTF16(S);
      Result := Rect(0, 0, 0, 0);
      GetThemeTextExtent(Theme[Element], DC, Part, State, PWideChar(W), Length(W),
        Flags, BoundingRect, Result);
    end
  else
    Result := inherited GetTextExtent(DC, Details, S, Flags, BoundingRect);
end;

function TWin32ThemeServices.UseThemes: Boolean;
begin
  Result := UxTheme.UseThemes and (GetFileVersion(comctl32) >= ComCtlVersionIE6);
end;

function TWin32ThemeServices.ThemedControlsEnabled: Boolean;
var
  Flags: DWORD;
begin
  Flags := UxTheme.GetThemeAppProperties();
  if (Flags and STAP_ALLOW_CONTROLS) = 0 then
    Result := False
  else
    Result := True;
end;

function TWin32ThemeServices.GetTheme(Element: TThemedElement): HTHEME;
begin
  if (FThemeData[Element] = 0) then
  begin
    if (WindowsVersion >= wvVista) then
      FThemeData[Element] := OpenThemeData(0, ThemeDataNamesVista[Element])
    else
      FThemeData[Element] := OpenThemeData(0, ThemeDataNames[Element]);
  end;
  Result := FThemeData[Element];
end;

function TWin32ThemeServices.InternalColorToRGB(Details: TThemedElementDetails; Color: TColor): COLORREF;
begin
  if ThemesEnabled then
    Result := GetThemeSysColor(Theme[Details.Element], Integer(Color and not $80000000))
  else
    Result := inherited;
end;

function TWin32ThemeServices.ContentRect(DC: HDC; Details: TThemedElementDetails; BoundingRect: TRect): TRect;
begin
  if ThemesEnabled then
    with Details do
      GetThemeBackgroundContentRect(Theme[Element], DC, Part, State, BoundingRect, @Result)
  else
    Result := inherited;
end;

procedure TWin32ThemeServices.DrawEdge(DC: HDC; Details: TThemedElementDetails; const R: TRect; Edge, Flags: Cardinal;
      AContentRect: PRect = nil);
begin
  if ThemesEnabled then
    with Details do
      DrawThemeEdge(Theme[Element], DC, Part, State, R, Edge, Flags, AContentRect)
  else
    inherited;
end;

procedure TWin32ThemeServices.DrawElement(DC: HDC; Details: TThemedElementDetails; const R: TRect; ClipRect: PRect = nil);
var
  ARect: TRect;
  Brush: HBrush;
begin
  if ThemesEnabled then
  begin
    if (Details.Element = teTreeview) and (Details.Part = TVP_HOTGLYPH) and (WindowsVersion < wvVista) then
      Details.Part := TVP_GLYPH;
    if (Details.Element = teTreeview) and (Details.Part = TVP_TREEITEM) and (Details.State = TREIS_HOT) and (WindowsVersion < wvVista) then
      Details.State := TREIS_NORMAL;
    if (Details.Element = teTreeview) and (Details.Part = TVP_TREEITEM) and (WindowsVersion < wvVista) then
    begin
      inherited;
      Exit;
    end;
    with Details do
      DrawThemeBackground(Theme[Element], DC, Part, State, R, ClipRect);
    if (Details.Element = teToolTip) and (Details.Part = TTP_STANDARD) and (WindowsVersion < wvVista) then
    begin
      // use native background on windows vista
      ARect := ContentRect(DC, Details, R);
      Brush := CreateSolidBrush(ColorToRGB(clInfoBk));
      FillRect(DC, ARect, Brush);
      DeleteObject(Brush);
    end;
  end
  else
  begin
    if (Details.Element = teTreeview) and (Details.Part = TVP_TREEITEM) and (Details.State = TREIS_HOT) then
      Details.State := TREIS_NORMAL;

    inherited;
  end;
end;

procedure TWin32ThemeServices.DrawIcon(DC: HDC; Details: TThemedElementDetails;
  const R: TRect; himl: HIMAGELIST; Index: Integer);
begin
  if ThemesEnabled then
    with Details do
      DrawThemeIcon(Theme[Element], DC, Part, State, R, himl, Index)
  else
    inherited;
end;

function TWin32ThemeServices.HasTransparentParts(Details: TThemedElementDetails): Boolean;
begin
  if ThemesEnabled then
    with Details do
      Result := IsThemeBackgroundPartiallyTransparent(Theme[Element], Part, State)
   else
     Result := inherited;
end;

procedure TWin32ThemeServices.PaintBorder(Control: TObject;
  EraseLRCorner: Boolean);
var
  EmptyRect,
  DrawRect: TRect;
  DC: HDC;
  H, W: Integer;
  AStyle,
  ExStyle: Integer;
  Details: TThemedElementDetails;
begin
  if not (Control is TWinControl) then
    Exit;

  if not ThemesEnabled then
  begin
    inherited;
    Exit;
  end;

  with TWinControl(Control) do
  begin
    ExStyle := GetWindowLong(Handle, GWL_EXSTYLE);
    if (ExStyle and WS_EX_CLIENTEDGE) <> 0 then
    begin
      DrawRect := Rect(0, 0, 0, 0);
      GetWindowRect(Handle, DrawRect);
      OffsetRect(DrawRect, -DrawRect.Left, -DrawRect.Top);
      DC := GetWindowDC(Handle);
      try
        EmptyRect := DrawRect;
        if EraseLRCorner then
        begin
          AStyle := GetWindowLong(Handle, GWL_STYLE);
          if ((AStyle and WS_HSCROLL) <> 0) and ((AStyle and WS_VSCROLL) <> 0) then
          begin
            W := GetSystemMetrics(SM_CXVSCROLL);
            H := GetSystemMetrics(SM_CYHSCROLL);
            InflateRect(EmptyRect, -2, -2);
            EmptyRect := Rect(EmptyRect.Right - W, EmptyRect.Bottom - H, EmptyRect.Right, EmptyRect.Bottom);
            FillRect(DC, EmptyRect, GetSysColorBrush(COLOR_BTNFACE));
          end;
        end;
        with DrawRect do
          ExcludeClipRect(DC, Left + 2, Top + 2, Right - 2, Bottom - 2);
        Details := ThemeServices.GetElementDetails(teEditTextNormal);
        DrawElement(DC, Details, DrawRect, nil);
      finally
        ReleaseDC(Handle, DC);
      end;
    end;
  end;
end;

procedure TWin32ThemeServices.InternalDrawParentBackground(Window: HWND;
  Target: HDC; Bounds: PRect);
begin
  if ThemesEnabled then
    DrawThemeParentBackground(Window, Target, Bounds)
  else
    inherited;
end;

procedure TWin32ThemeServices.DrawText(DC: HDC; Details: TThemedElementDetails;
  const S: String; R: TRect; Flags, Flags2: Cardinal);
var
  w: widestring;
begin
  if ThemesEnabled then
    with Details do
    begin
      w := UTF8ToUTF16(S);
      DrawThemeText(Theme[Element], DC, Part, State, PWideChar(w), Length(w), Flags, Flags2, R);
    end
  else
    inherited;
end;

procedure TWin32ThemeServices.DrawText(ACanvas: TPersistent;
  Details: TThemedElementDetails; const S: String; R: TRect; Flags,
  Flags2: Cardinal);

var
  FontUnderlineSave:boolean;
  DC: HDC;
  DCIndex: Integer;
  ARect: TRect;

  procedure SaveState;
  begin
    if DCIndex <> 0 then exit;
    DCIndex := SaveDC(DC);
  end;

  procedure RestoreState;
  begin
    if DCIndex = 0 then exit;
    RestoreDC(DC, DCIndex);
  end;

  function NotImplementedInXP: Boolean; inline;
  begin
    Result :=
      ((Details.Element = teTreeview) and (Details.Part = TVP_TREEITEM)) or
      (Details.Element = teToolTip) or (Details.Element = teMenu);
  end;

begin
  if (NotImplementedInXP and (WindowsVersion < wvVista))or not ThemesEnabled then
  begin
    FontUnderlineSave:=TCanvas(ACanvas).Font.Underline;
    if (Details.Element = teTreeview) and (Details.Part = TVP_TREEITEM) and (Details.State = TREIS_HOT) then
    begin
         TCanvas(ACanvas).Font.Underline:=true;
    end;
    inherited;
    TCanvas(ACanvas).Font.Underline:=FontUnderlineSave;
    Exit;
  end;
  if ThemesEnabled then
  begin
    // windows does not paint disabled toolbar text properly - the only way is
    // to fix it here with disabled button text
    if (Details.Element = teToolBar) and (Details.State = TS_DISABLED) then
      Details := GetElementDetails(tbPushButtonDisabled);

    DCIndex := 0;
    DC := TCanvas(ACanvas).Handle;
    if TCanvas(ACanvas).Font.IsDefault then
    begin
      SaveState;
      SelectObject(DC, OnGetSystemFont());
    end;
    DrawText(DC, Details, S, R, Flags, Flags2);
    RestoreState;
  end
  else
    inherited;
end;

procedure TWin32ThemeServices.DrawTextEx(DC: HDC;
  Details: TThemedElementDetails; const S: String; R: TRect; Flags: Cardinal;
  Options: PDTTOpts);
var
  w: widestring;
begin
  if ThemesEnabled and (DrawThemeTextEx <> nil) then
    with Details do
    begin
      w := UTF8ToUTF16(S);
      DrawThemeTextEx(Theme[Element], DC, Part, State, PWideChar(w), Length(w), Flags, @R, Options);
    end
  else
    DrawText(DC, Details, S, R, Flags, 0);
end;

end.
