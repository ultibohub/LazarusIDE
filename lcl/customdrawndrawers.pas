unit CustomDrawnDrawers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, fpcanvas, fpimage,
  // LCL for types
  Controls, Graphics, ComCtrls, ExtCtrls, LazUTF8;

const
  CDDRAWSTYLE_COUNT = 19;

  cddTestStr = 'ŹÇ'; // Used for testing text height

  // Measures
  TCDEDIT_LEFT_TEXT_SPACING  = $400; // The space between the start of the text and the left end of the control
  TCDEDIT_RIGHT_TEXT_SPACING = $401; // The space between the end of the text and the right end of the control
  TCDEDIT_TOP_TEXT_SPACING   = $402;
  TCDEDIT_BOTTOM_TEXT_SPACING= $403;

  TCDCHECKBOX_SQUARE_HALF_HEIGHT = $500;
  TCDCHECKBOX_SQUARE_HEIGHT = $501;

  TCDRADIOBUTTON_CIRCLE_HEIGHT = $601;

  TCDCOMBOBOX_DEFAULT_HEIGHT = $801;

  TCDSCROLLBAR_BUTTON_WIDTH = $900;
  TCDSCROLLBAR_LEFT_SPACING = $901;   // Left and right are only read left and right for horizontal orientation
  TCDSCROLLBAR_RIGHT_SPACING= $902;   // in vertical orientation they are respectively top and bottom
  TCDSCROLLBAR_LEFT_BUTTON_POS =$903; // Positive Pos means it relative to the left margin,
  TCDSCROLLBAR_RIGHT_BUTTON_POS=$904; // negative that it is relative to the right margin

  TCDTRACKBAR_LEFT_SPACING    = $1000;
  TCDTRACKBAR_RIGHT_SPACING   = $1001;
  TCDTRACKBAR_TOP_SPACING     = $1002;
  TCDTRACKBAR_FRAME_HEIGHT    = $1003;

  TCDLISTVIEW_COLUMN_LEFT_SPACING  = $1200;
  TCDLISTVIEW_COLUMN_RIGHT_SPACING = $1201;
  TCDLISTVIEW_COLUMN_TEXT_LEFT_SPACING = $1202;
  TCDLISTVIEW_LINE_TOP_SPACING     = $1203;
  TCDLISTVIEW_LINE_BOTTOM_SPACING  = $1204;

  TCDTOOLBAR_ITEM_SPACING = $1300;
  TCDTOOLBAR_ITEM_ARROW_WIDTH = $1301;
  TCDTOOLBAR_ITEM_BUTTON_DEFAULT_WIDTH = $1303;
  TCDTOOLBAR_ITEM_ARROW_RESERVED_WIDTH = $1304;
  TCDTOOLBAR_ITEM_SEPARATOR_DEFAULT_WIDTH = $1305;
  TCDTOOLBAR_DEFAULT_HEIGHT = $1306;

  TCDCTABCONTROL_CLOSE_TAB_BUTTON_WIDTH = $2600;
  TCDCTABCONTROL_CLOSE_TAB_BUTTON_EXTRA_SPACING = $2601;

  // Measures Ex
  TCDCONTROL_CAPTION_WIDTH  = $100;
  TCDCONTROL_CAPTION_HEIGHT = $101;

  TCDCTABCONTROL_TAB_HEIGHT = $2600;
  TCDCTABCONTROL_TAB_WIDTH  = $2601;
  TCDCTABCONTROL_TAB_LEFT_POS = $2602;
  TCDCTABCONTROL_CLOSE_BUTTON_POS_X = $2603;
  TCDCTABCONTROL_CLOSE_BUTTON_POS_Y = $2604;

  // Colors
  TCDEDIT_BACKGROUND_COLOR = $400;
  TCDEDIT_TEXT_COLOR = $401;
  TCDEDIT_SELECTED_BACKGROUND_COLOR = $402;
  TCDEDIT_SELECTED_TEXT_COLOR = $403;

  // Default Colors
  TCDBUTTON_DEFAULT_COLOR = $10000;

type

  TCDDrawStyle = (
    // The default is given by the DefaultStyle global variable
    // Don't implement anything for this drawer
    dsDefault = 0,
    // This is a common drawer, with a minimal implementation on which other
    // drawers base on
    dsCommon,
    // Operating system styles
    dsWinCE, dsWin2000, dsWinXP, dsWindows7,
    dsKDEPlastique, dsGNOME, dsMacOSX,
    dsAndroid,
    // Other special styles for the user
    dsExtra1, dsExtra2, dsExtra3, dsExtra4, dsExtra5,
    dsExtra6, dsExtra7, dsExtra8, dsExtra9, dsExtra10
    );

  // Inspired by http://doc.qt.nokia.com/stable/qstyle.html#StateFlag-enum
  TCDControlStateFlag = (
    // Basic state flags
    csfEnabled,
    csfRaised, // Raised beyond the normal state, unlike Qt for buttons
    csfSunken,
    csfHasFocus,
    csfReadOnly,
    csfMouseOver,
    // for TCDCheckBox, TCDRadioButton
    csfOn,
    csfOff,
    csfPartiallyOn,
    // for TCDScrollBar, TCDProgressBar
    csfHorizontal,
    csfVertical,
    csfRightToLeft,
    csfTopDown,
    // for TCDProgressBar, TCDScrollBar, TCDComboBox
    csfLeftArrow,
    csfRightArrow,
    csfDownArrow,
    csfUpArrow
{    // for tool button
    csfAutoRaise,
    csfTop,
    csfBottom,
    csfFocusAtBorder,
    csfSelected,
    csfActive,
    csfWindow,
    csfOpen,
    csfChildren,
    csfItem,
    csfSibling,
    csfEditing,
    csfKeyboardFocusChange,
    // For Mac OS X
    csfSmall,
    csfMini}
   );

  TCDControlState = set of TCDControlStateFlag;

  TCDControlStateEx = class
  public
    ParentRGBColor: TColor;
    FPParentRGBColor: TFPColor;
    RGBColor: TColor;
    FPRGBColor: TFPColor;
    Caption: string;
    Font: TFont; // Just a reference, never Free
    AutoSize: Boolean;
  end;

  TCDButtonStateEx = class(TCDControlStateEx)
  public
    Glyph: TBitmap; // Just a reference, never Free
  end;

  TCDEditStateEx = class(TCDControlStateEx)
  public
    CaretIsVisible: Boolean;
    CaretPos: TPoint; // X and Y are zero-based positions
    SelStart: TPoint; // X and Y are zero-based positions
    SelLength: Integer; // zero means no selection. Negative numbers selection to the left from the start and positive ones to the right
    VisibleTextStart: TPoint; // X is 1-based, Y is 0-based
    EventArrived: Boolean; // Added by event handlers and used by the caret so that it stops blinking while events are incoming
    MultiLine: Boolean;
    Lines: TStrings; // Just a reference, never Free
    FullyVisibleLinesCount, LineHeight: Integer; // Filled on drawing to be used in customdrawncontrols.pas
    PasswordChar: Char;
    // customizable extra margins, zero is the base value
    LeftTextMargin, RightTextMargin: Integer;
    // For the combo box for example
    ExtraButtonState: TCDControlState;
  end;

  TCDPanelStateEx = class(TCDControlStateEx)
  public
    BevelInner: TPanelBevel;
    BevelOuter: TPanelBevel;
    BevelWidth: TBevelWidth;
  end;

  TCDPositionedCStateEx = class(TCDControlStateEx)
  public
    PosCount: integer; // The number of positions, calculated as Max - Min + 1
    Position: integer; // A zero-based position, therefore it is = Position - Min
    FloatPos: Double; // The same position, but as a float between 0.0 and 1.0
    FloatPageSize: Double; // The page size as a float between 0.0 and 1.0
  end;

  TCDProgressBarStateEx = class(TCDControlStateEx)
  public
    BarShowText: Boolean;
    PercentPosition: Double; // a float between 0.0 and 1.0 (1=full)
    Smooth: Boolean;
    Style: TProgressBarStyle;
  end;

  // TCDListItems are implemented as a tree with 2 levels beyond the first node
  TCDListItems = class
  private
    procedure DoFreeItem(data,arg:pointer);
  public
    // These fields are not used in the first node of the tree
    Caption: string;
    ImageIndex: Integer;
    StateIndex: Integer;
    //
    Childs: TFPList;
    constructor Create;
    destructor Destroy; override;
    function Add(ACaption: string; AImageIndex, AStateIndex: Integer): TCDListItems;
    function GetItem(AIndex: Integer): TCDListItems;
    function GetItemCount: Integer;
  end;

  TCDListViewStateEx = class(TCDControlStateEx)
  public
    Columns: TListColumns; // just a reference, never free
    Items: TCDListItems; // just a reference, never free
    ViewStyle: TViewStyle;
    FirstVisibleColumn: Integer; // 0-based index
    FirstVisibleLine: Integer; // 0-based index, remember that the header is always visible or always invisible
    ShowColumnHeader: Boolean;
  end;

  // ToolBar Start

  TCDToolbarItemKind = (tikButton, tikCheckButton, tikDropDownButton,
    tikSeparator, tikDivider);

  TCDToolbarItemSubpartKind = (tiskMain, tiskArrow);

  TCDToolBarItem = class
    Kind: TCDToolbarItemKind;
    SubpartKind: TCDToolbarItemSubpartKind;
    Image: TBitmap;
    Caption: string;
    Width: Integer;
    Down: Boolean;
    // filled for drawing
    State: TCDControlState;
  end;

  TCDToolBarStateEx = class(TCDControlStateEx)
    ShowCaptions: Boolean;
    IsVertical: Boolean;
    Items: TFPList; // of TCDToolBarItem
    ToolBarHeight: Integer;
  end;

  // ToolBar End

  TCDCTabControlStateEx = class(TCDControlStateEx)
  public
    LeftmostTabVisibleIndex: Integer;
    Tabs: TStringList; // Just a reference, don't Free
    TabIndex: Integer;
    TabCount: Integer;
    Options: TCTabControlOptions;
    // Used internally by the drawers
    CurTabIndex: Integer;// For Tab routines, obtain the index
    CurStartLeftPos: Integer;
    CurStartTopPos: Integer;
  end;

  TCDSpinStateEx = class(TCDPositionedCStateEx)
  public
    Min: integer;
    Increment: integer;
    FloatMin: Double;
    FloatIncrement: Double;
  end;

  TCDControlID = (
    cidControl,
    // Standard
    cidMenu, cidPopUp, cidButton, cidEdit, cidCheckBox, cidRadioButton,
    cidListBox, cidComboBox, cidScrollBar, cidGroupBox, cidPanel,
    // Additional
    cidStaticText,
    // Common Controls
    cidTrackBar, cidProgressBar, cidListView, cidToolBar, cidCTabControl
    );

  { TCDColorPalette }

  TCDColorPalette = class
  public
    ScrollBar, Background, ActiveCaption, InactiveCaption,
    Menu, Window, WindowFrame, MenuText, WindowText, CaptionText,
    ActiveBorder, InactiveBorder, AppWorkspace, Highlight, HighlightText,
    BtnFace, BtnShadow, GrayText, BtnText, InactiveCaptionText,
    BtnHighlight, color3DDkShadow, color3DLight, InfoText, InfoBk,
    //
    HotLight, GradientActiveCaption, GradientInactiveCaption,
    MenuHighlight, MenuBar, Form: TColor;
    procedure Assign(AFrom: TCDColorPalette);
  end;

  { There are 5 possible sources of input for color palettes:
   palDefault  - Uses palNative when the operating system matches the drawer style,
                 palFallback otherwise
   palNative   - Obtain from the operating system
   palFallback - Use the fallback colors of the drawer
   palUserConfig-Load it from the user configuration files, ToDo
   palCustom   - The user application has set its own palette
  }
  TCDPaletteKind = (palDefault, palNative, palFallback, palUserConfig, palCustom);

  { TCDDrawer }

  TCDDrawer = class
  protected
  public
    Palette: TCDColorPalette;
    FallbackPalette: TCDColorPalette;
    PaletteKind: TCDPaletteKind;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure CreateResources; virtual;
    procedure LoadResources; virtual;
    procedure FreeResources; virtual;
    procedure ScaleRasterImage(ARasterImage: TRasterImage; ASourceDPI, ADestDPI: Word);
    procedure LoadPalette;
    procedure LoadNativePaletteColors;
    procedure LoadFallbackPaletteColors; virtual;
    function  PalDefaultUsesNativePalette: Boolean; virtual;
    function GetDrawStyle: TCDDrawStyle; virtual;
    class function VisibleText(const aVisibleText: TCaption; const APasswordChar: Char): TCaption;
    // GetControlDefaultColor is used by customdrawncontrols to resolve clDefault
    function GetControlDefaultColor(AControlId: TCDControlID): TColor;
    // General
    function GetMeasures(AMeasureID: Integer): Integer; virtual; abstract;
    function GetMeasuresEx(ADest: TCanvas; AMeasureID: Integer;
      AState: TCDControlState; AStateEx: TCDControlStateEx): Integer; virtual; abstract;
    procedure CalculatePreferredSize(ADest: TCanvas; AControlId: TCDControlID;
      AState: TCDControlState; AStateEx: TCDControlStateEx;
      var PreferredWidth, PreferredHeight: integer; WithThemeSpace, AAllowUseOfMeasuresEx: Boolean); virtual; abstract;
    function GetColor(AColorID: Integer): TColor; virtual; abstract;
    function GetClientArea(ADest: TCanvas; ASize: TSize; AControlId: TCDControlID;
      AState: TCDControlState; AStateEx: TCDControlStateEx): TRect; virtual; abstract;
    // To set a different position to draw the control then (0, 0) use the window org of the canvas
    procedure DrawControl(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AControl: TCDControlID; AState: TCDControlState; AStateEx: TCDControlStateEx);
    // General drawing routines. The ones using TFPCustomCanvas are reusable in LCL-CustomDrawn
    procedure DrawFocusRect(ADest: TFPCustomCanvas; ADestPos: TPoint; ASize: TSize); virtual; abstract;
    procedure DrawRaisedFrame(ADest: TCanvas; ADestPos: TPoint; ASize: TSize); virtual; abstract;
    procedure DrawFrame3D(ADest: TFPCustomCanvas; ADestPos: TPoint; ASize: TSize;
      const FrameWidth : integer; const Style : TBevelCut); virtual; abstract;
    procedure DrawSunkenFrame(ADest: TCanvas; ADestPos: TPoint; ASize: TSize); virtual; abstract;
    procedure DrawShallowSunkenFrame(ADest: TCanvas; ADestPos: TPoint; ASize: TSize); virtual; abstract;
    procedure DrawTickmark(ADest: TFPCustomCanvas; ADestPos: TPoint; AState: TCDControlState); virtual; abstract;
    procedure DrawSlider(ADest: TCanvas; ADestPos: TPoint; ASize: TSize; AState: TCDControlState); virtual; abstract;
    procedure DrawArrow(ADest: TCanvas; ADestPos: TPoint; ADirection: TCDControlState; ASize: Integer = 7); virtual; abstract;
    // Extra buttons drawing routines
    procedure DrawSmallCloseButton(ADest: TCanvas; ADestPos: TPoint); virtual; abstract;
    procedure DrawButtonWithArrow(ADest: TCanvas; ADestPos: TPoint; ASize: TSize; AState: TCDControlState); virtual; abstract;
    // TCDControl
    procedure DrawControl(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDControlStateEx); virtual; abstract;
    // TCDButton
    procedure DrawButton(ADest: TFPCustomCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDButtonStateEx); virtual; abstract;
    // TCDEdit
    procedure DrawEditBackground(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDEditStateEx); virtual; abstract;
    procedure DrawEditFrame(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDEditStateEx); virtual; abstract;
    procedure DrawCaret(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDEditStateEx); virtual; abstract;
    procedure DrawEdit(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDEditStateEx); virtual; abstract;
    // TCDCheckBox
    procedure DrawCheckBoxSquare(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDControlStateEx); virtual; abstract;
    procedure DrawCheckBox(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDControlStateEx); virtual; abstract;
    // TCDRadioButton
    procedure DrawRadioButtonCircle(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDControlStateEx); virtual; abstract;
    procedure DrawRadioButton(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDControlStateEx); virtual; abstract;
    // TCDComboBox
    procedure DrawComboBox(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDEditStateEx); virtual; abstract;
    // TCDScrollBar
    procedure DrawScrollBar(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDPositionedCStateEx); virtual; abstract;
    // TCDGroupBox
    procedure DrawGroupBox(ADest: TFPCustomCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDControlStateEx); virtual; abstract;
    // TCDPanel
    procedure DrawPanel(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDPanelStateEx); virtual; abstract;
    // ===================================
    // Additional Tab
    // ===================================
    procedure DrawStaticText(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDControlStateEx); virtual; abstract;
    // ===================================
    // Common Controls Tab
    // ===================================
    // TCDTrackBar
    procedure DrawTrackBar(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDPositionedCStateEx); virtual; abstract;
    // TCDProgressBar
    procedure DrawProgressBar(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDProgressBarStateEx); virtual; abstract;
    // TCDListView
    procedure DrawListView(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDListViewStateEx); virtual; abstract;
    procedure DrawReportListView(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDListViewStateEx); virtual; abstract;
    procedure DrawReportListViewItem(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      ACurItem: TCDListItems; AState: TCDControlState; AStateEx: TCDListViewStateEx); virtual; abstract;
    // TCDToolBar
    procedure DrawToolBar(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDToolBarStateEx); virtual; abstract;
    procedure DrawToolBarItem(ADest: TCanvas; ASize: TSize;
      ACurItem: TCDToolBarItem; AX, AY: Integer;
      AState: TCDControlState; AStateEx: TCDToolBarStateEx); virtual; abstract;
    // TCDCustomTabControl
    procedure DrawCTabControl(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDCTabControlStateEx); virtual; abstract;
    procedure DrawCTabControlFrame(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDCTabControlStateEx); virtual; abstract;
    procedure DrawTabSheet(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDCTabControlStateEx); virtual; abstract;
    procedure DrawTabs(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDCTabControlStateEx); virtual; abstract;
    procedure DrawTab(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDCTabControlStateEx); virtual; abstract;
    // ===================================
    // Misc Tab
    // ===================================
    procedure DrawSpinEdit(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDSpinStateEx); virtual; abstract;
  end;

procedure RegisterDrawer(ADrawer: TCDDrawer; AStyle: TCDDrawStyle);
function GetDefaultDrawer: TCDDrawer;
function GetDrawer(AStyle: TCDDrawStyle): TCDDrawer;

var
  DefaultStyle: TCDDrawStyle = dsCommon; // For now default to the most complete one, later per platform

implementation

var
  RegisteredDrawers: array[TCDDrawStyle] of TCDDrawer
    = (nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil);

procedure RegisterDrawer(ADrawer: TCDDrawer; AStyle: TCDDrawStyle);
begin
  if RegisteredDrawers[AStyle] <> nil then RegisteredDrawers[AStyle].Free;
  RegisteredDrawers[AStyle] := ADrawer;
end;

function GetDefaultDrawer: TCDDrawer;
begin
  Result := GetDrawer(dsDefault);
end;

function GetDrawer(AStyle: TCDDrawStyle): TCDDrawer;
var
  lDrawStyle: TCDDrawStyle;
begin
  if AStyle = dsDefault then lDrawStyle := DefaultStyle
  else lDrawStyle := AStyle;
  Result := RegisteredDrawers[lDrawStyle];
end;

var
  i: Integer;

{ TCDColorPalette }

procedure TCDColorPalette.Assign(AFrom: TCDColorPalette);
begin
  ScrollBar := AFrom.ScrollBar;
  Background := AFrom.Background;
  ActiveCaption := AFrom.ActiveCaption;
  InactiveCaption := AFrom.InactiveCaption;
  Menu := AFrom.Menu;
  Window := AFrom.Window;
  WindowFrame := AFrom.WindowFrame;
  MenuText := AFrom.MenuText;
  WindowText := AFrom.WindowText;
  CaptionText := AFrom.CaptionText;
  ActiveBorder := AFrom.ActiveBorder;
  InactiveBorder := AFrom.InactiveBorder;
  AppWorkspace := AFrom.AppWorkspace;
  Highlight := AFrom.Highlight;
  HighlightText := AFrom.HighlightText;
  BtnFace := AFrom.BtnFace;
  BtnShadow := AFrom.BtnShadow;
  GrayText := AFrom.GrayText;
  BtnText := AFrom.BtnText;
  InactiveCaptionText := AFrom.InactiveCaptionText;
  BtnHighlight := AFrom.BtnHighlight;
  color3DDkShadow := AFrom.color3DDkShadow;
  color3DLight := AFrom.color3DLight;
  InfoText := AFrom.InfoText;
  InfoBk := AFrom.InfoBk;
  //
  HotLight := AFrom.HotLight;
  GradientActiveCaption := AFrom.GradientActiveCaption;
  GradientInactiveCaption := AFrom.GradientInactiveCaption;
  MenuHighlight := AFrom.MenuHighlight;
  MenuBar := AFrom.MenuBar;
  Form := AFrom.Form;
end;

{ TCDListItems }

procedure TCDListItems.DoFreeItem(data, arg: pointer);
begin
  TCDListItems(data).Free;
end;

constructor TCDListItems.Create;
begin
  inherited Create;
  Childs := TFPList.Create;
end;

destructor TCDListItems.Destroy;
begin
  Childs.ForEachCall(@DoFreeItem, nil);
  Childs.Free;
  inherited Destroy;
end;

function TCDListItems.Add(ACaption: string; AImageIndex, AStateIndex: Integer
  ): TCDListItems;
begin
  Result := TCDListItems.Create;
  Result.Caption := ACaption;
  Result.ImageIndex := AImageIndex;
  Result.StateIndex := AStateIndex;
  Childs.Add(Pointer(Result));
end;

function TCDListItems.GetItem(AIndex: Integer): TCDListItems;
begin
  Result := TCDListItems(Childs.Items[AIndex]);
end;

function TCDListItems.GetItemCount: Integer;
begin
  Result := Childs.Count;
end;

{ TCDDrawer }

constructor TCDDrawer.Create;
begin
  inherited Create;

  // We never load the system palette at creation because we might get created
  // before the Widgetset is constructed
  Palette := TCDColorPalette.Create;
  LoadFallbackPaletteColors();
  FallbackPalette := TCDColorPalette.Create;
  FallbackPalette.Assign(Palette);
  PaletteKind := palDefault;

  CreateResources;
  LoadResources;
end;

destructor TCDDrawer.Destroy;
begin
  FreeResources;
  Palette.Free;
  FallbackPalette.Free;

  inherited Destroy;
end;

procedure TCDDrawer.CreateResources;
begin

end;

procedure TCDDrawer.LoadResources;
begin

end;

procedure TCDDrawer.FreeResources;
begin

end;

procedure TCDDrawer.ScaleRasterImage(ARasterImage: TRasterImage; ASourceDPI, ADestDPI: Word);
var
  lNewWidth, lNewHeight: Int64;
  lTmpBmp: TBitmap;
begin
  lNewWidth := Round(ARasterImage.Width * ADestDPI / ASourceDPI);
  lNewHeight := Round(ARasterImage.Height * ADestDPI / ASourceDPI);
  lTmpBmp := TBitmap.Create;
  try
    lTmpBmp.Width := ARasterImage.Width;
    lTmpBmp.Height := ARasterImage.Height;
    lTmpBmp.Canvas.Draw(0, 0, ARasterImage);
    ARasterImage.Canvas.StretchDraw(Bounds(0, 0, lNewWidth, lNewHeight), lTmpBmp);
  finally
    lTmpBmp.Free;
  end;
  ARasterImage.Width := lNewWidth;
  ARasterImage.Height := lNewHeight;
end;

procedure TCDDrawer.LoadPalette;
begin
  case PaletteKind of
  palDefault:
  begin
    if PalDefaultUsesNativePalette() then LoadNativePaletteColors()
    else LoadFallbackPaletteColors();
  end;
  palNative:   LoadNativePaletteColors();
  palFallback: LoadFallbackPaletteColors();
  //palUserConfig:
  end;
end;

procedure TCDDrawer.LoadNativePaletteColors;
begin
  Palette.ScrollBar := ColorToRGB(clScrollBar);
  Palette.Background := ColorToRGB(clBackground);
  Palette.ActiveCaption := ColorToRGB(clActiveCaption);
  Palette.InactiveCaption := ColorToRGB(clInactiveCaption);
  Palette.Menu := ColorToRGB(clMenu);
  Palette.Window := ColorToRGB(clWindow);
  Palette.WindowFrame := ColorToRGB(clWindowFrame);
  Palette.MenuText := ColorToRGB(clMenuText);
  Palette.WindowText := ColorToRGB(clWindowText);
  Palette.CaptionText := ColorToRGB(clCaptionText);
  Palette.ActiveBorder := ColorToRGB(clActiveBorder);
  Palette.InactiveBorder := ColorToRGB(clInactiveBorder);
  Palette.AppWorkspace := ColorToRGB(clAppWorkspace);
  Palette.Highlight := ColorToRGB(clHighlight);
  Palette.HighlightText := ColorToRGB(clHighlightText);
  Palette.BtnFace := ColorToRGB(clBtnFace);
  Palette.BtnShadow := ColorToRGB(clBtnShadow);
  Palette.GrayText := ColorToRGB(clGrayText);
  Palette.BtnText := ColorToRGB(clBtnText);
  Palette.InactiveCaptionText := ColorToRGB(clInactiveCaptionText);
  Palette.BtnHighlight := ColorToRGB(clBtnHighlight);
  Palette.color3DDkShadow := ColorToRGB(cl3DDkShadow);
  Palette.color3DLight := ColorToRGB(cl3DLight);
  Palette.InfoText := ColorToRGB(clInfoText);
  Palette.InfoBk := ColorToRGB(clInfoBk);

  Palette.HotLight := ColorToRGB(clHotLight);
  Palette.GradientActiveCaption := ColorToRGB(clGradientActiveCaption);
  Palette.GradientInactiveCaption := ColorToRGB(clGradientInactiveCaption);
  Palette.MenuHighlight := ColorToRGB(clMenuHighlight);
  Palette.MenuBar := ColorToRGB(clMenuBar);
  Palette.Form := ColorToRGB(clForm);
end;

procedure TCDDrawer.LoadFallbackPaletteColors;
begin

end;

function TCDDrawer.PalDefaultUsesNativePalette: Boolean;
begin
  Result := False;
end;

function TCDDrawer.GetDrawStyle: TCDDrawStyle;
begin
  Result := dsCommon;
end;

class function TCDDrawer.VisibleText(const aVisibleText: TCaption; const APasswordChar: Char): TCaption;
begin
  if aPasswordChar = #0 then
    result := aVisibleText
  else
    result := StringOfChar( aPasswordChar, UTF8Length(aVisibleText) );
end;

{ Control colors can refer to their background or foreground }
function TCDDrawer.GetControlDefaultColor(AControlId: TCDControlID): TColor;
begin
  case AControlId of
  cidControl:     Result := Palette.Form;
  cidButton:      Result := Palette.BtnFace;// foreground color
  cidEdit:        Result := Palette.Window; // foreground color
  cidCheckBox:    Result := Palette.Form;   // background color
  cidGroupBox:    Result := Palette.Form;   // ...
  //
  cidStaticText:  Result := Palette.Form;   // ...
  //
  cidTrackBar:    Result := Palette.Form;   // ...
  cidProgressBar: Result := Palette.Form;   // foreground color
  cidListView:    Result := Palette.Window; // foreground color
  cidCTabControl: Result := Palette.Form;   // foreground color
  else
    Result := Palette.Form;
  end;
end;

procedure TCDDrawer.DrawControl(ADest: TCanvas; ADestPos: TPoint; ASize: TSize;
  AControl: TCDControlID; AState: TCDControlState; AStateEx: TCDControlStateEx
    );
begin
  case AControl of
  cidControl:    DrawControl(ADest, ASize, AState, AStateEx);
  //
  cidButton:     DrawButton(ADest, ADestPos, ASize, AState, TCDButtonStateEx(AStateEx));
  cidEdit:       DrawEdit(ADest, ASize, AState, TCDEditStateEx(AStateEx));
  cidCheckBox:   DrawCheckBox(ADest, ASize, AState, AStateEx);
  cidRadioButton:DrawRadioButton(ADest, ASize, AState, AStateEx);
  cidComboBox:   DrawComboBox(ADest, ASize, AState, TCDEditStateEx(AStateEx));
  cidScrollBar:  DrawScrollBar(ADest, ASize, AState, TCDPositionedCStateEx(AStateEx));
  cidGroupBox:   DrawGroupBox(ADest, ADestPos, ASize, AState, AStateEx);
  cidPanel:      DrawPanel(ADest, ASize, AState, TCDPanelStateEx(AStateEx));
  //
  cidStaticText: DrawStaticText(ADest, ASize, AState, AStateEx);
  //
  cidTrackBar:   DrawTrackBar(ADest, ASize, AState, TCDPositionedCStateEx(AStateEx));
  cidProgressBar:DrawProgressBar(ADest, ASize, AState, TCDProgressBarStateEx(AStateEx));
  cidListView:   DrawListView(ADest, ASize, AState, TCDListViewStateEx(AStateEx));
  cidToolBar:    DrawToolBar(ADest, ASize, AState, TCDToolBarStateEx(AStateEx));
  cidCTabControl:DrawCTabControl(ADest, ASize, AState, TCDCTabControlStateEx(AStateEx));
  end;
end;

finalization
  // Free all drawers
  for i := 0 to CDDRAWSTYLE_COUNT-1 do
  begin
    if RegisteredDrawers[TCDDrawStyle(i)] <> nil then
    begin
      RegisteredDrawers[TCDDrawStyle(i)].Free;
      RegisteredDrawers[TCDDrawStyle(i)] := nil;
    end;
  end;
end.

