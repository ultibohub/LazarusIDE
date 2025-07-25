{
 ***************************************************************************
                              editbtn.pas
                              -----------
               Component Library Extended dialogs Controls


 ***************************************************************************

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************


}
unit EditBtn;

{$mode objfpc}{$H+}

{$I lcl_defines.inc}

interface

uses
  Classes, SysUtils, Types, Math, StrUtils, DateUtils,
  LazFileUtils, LazUTF8,
  LResources, LCLStrConsts, LCLType, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Calendar, ExtDlgs, GroupedEdit, CalendarPopup,
  MaskEdit, Menus, TimePopup, CalcForm, ImgList;

const
  NullDate: TDateTime = 29584650.5 {appr 10 x MaxDateTime};
  //Note: if you change this value to be in the range of allowed dates
  //you will be unable to select that date from the calendar, so better not do that
  //In hindside this vale should have been declared as a non-writeable constant
  NullTime: TDateTime = 0;

type

  { TEbEdit }

  TEbEdit = class(TGEEdit)
  protected
    procedure DoEnter; override;
    procedure DoExit; override;
  end;

  TEditSpeedButton = class(TSpeedButton)
  protected
    procedure GlyphChanged(Sender: TObject); override;
  end;

  { TCustomEditButton }

  TCustomEditButton = class(TCustomAbstractGroupedEdit)
  private
    FButtonOnlyWhenFocused: Boolean;
    FFlat: Boolean;
    //Forwarded events from Button
    //Forwarded events from Edit

    function GetFocusOnButtonClick: Boolean;
    function GetOnButtonClick: TNotifyEvent;
    function GetButton: TSpeedButton;
    function GetGlyph: TBitmap;
    function GetNumGlyps: Integer;
    function GetEdit: TEbEdit;
    procedure SetFocusOnButtonClick(AValue: Boolean);
    procedure SetOnButtonClick(AValue: TNotifyEvent);

    procedure SetButtonOnlyWhenFocused(AValue: Boolean);
    procedure SetFlat(AValue: Boolean);
    procedure SetGlyph(AValue: TBitmap);
    procedure SetNumGlyphs(AValue: Integer);
    function GetImages: TCustomImageList;
    procedure SetImages(const aImages: TCustomImageList);
    function GetImageIndex: TImageIndex;
    procedure SetImageIndex(const aImageIndex: TImageIndex);
    function GetImageWidth: Integer;
    procedure SetImageWidth(const aImageWidth: Integer);
  protected
    procedure ButtonClick; virtual;
    procedure BuddyClick; override;
    function GetEditorClassType: TGEEditClass; override;
    function GetBuddyClassType: TControlClass; override;
    class function GetControlClassDefaultSize: TSize; override;
    function CalcButtonVisible: Boolean; virtual;
    function GetDefaultGlyphName: string; virtual;

    procedure CalculatePreferredSize(var PreferredWidth,
                                     PreferredHeight: integer;
                                     WithThemeSpace: Boolean); override;
    procedure CheckButtonVisible;
    procedure LoadDefaultGlyph;
    procedure GlyphChanged(Sender: TObject); virtual;

    property Button: TSpeedButton read GetButton;
    property ButtonCaption: TCaption read GetBuddyCaption write SetBuddyCaption;
    property ButtonCursor: TCursor read GetBuddyCursor write SetBuddyCursor default crDefault;
    property ButtonHint: TTranslateString read GetBuddyHint write SetBuddyHint;
    property ButtonOnlyWhenFocused: Boolean read FButtonOnlyWhenFocused write SetButtonOnlyWhenFocused default False;
    property ButtonWidth: Integer read GetBuddyWidth write SetBuddyWidth;
    property Edit: TEbEdit read GetEdit;
    property Flat: Boolean read FFlat write SetFlat default False;
    property FocusOnButtonClick: Boolean read GetFocusOnButtonClick write SetFocusOnButtonClick default False;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property NumGlyphs: Integer read GetNumGlyps write SetNumGlyphs;
    property Images: TCustomImageList read GetImages write SetImages;
    property ImageIndex: TImageIndex read GetImageIndex write SetImageIndex default -1;
    property ImageWidth: Integer read GetImageWidth write SetImageWidth default 0;
    property Spacing default 4;

    property OnButtonClick: TNotifyEvent read GetOnButtonClick write SetOnButtonClick;
  public
    constructor Create(AOwner: TComponent); override;
  end;

 { TEditButton }

  TEditButton = class(TCustomEditButton)
  public
    property AutoSelected;
    property Button;
    property Edit;
  published
    property NumbersOnly;
    property Action;
    property AutoSelect;
    property AutoSize default True;
    property Align;
    property Alignment;
    property Anchors;
    property BiDiMode;
    property BorderSpacing;
    property BorderStyle default bsNone;
    property ButtonCaption;
    property ButtonCursor;
    property ButtonHint;
    property ButtonOnlyWhenFocused;
    property ButtonWidth;
    property CharCase;
    property Color;
    property Constraints;
    property Cursor;
    property DirectInput;
    property EchoMode;
    property Enabled;
    property Flat;
    property FocusOnButtonClick;
    property Font;
    property Glyph;
//    property HideSelection;
    property Hint;
    property Images;
    property ImageIndex;
    property ImageWidth;
    property Layout;
    property MaxLength;
    property NumGlyphs;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property Spacing;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Visible;

    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnContextPopup;
    property OnEditingDone;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;

  TFilterStringOption = (fsoCaseSensitive, fsoMatchOnlyAtStart);
  TFilterStringOptions = set of TFilterStringOption;

  // Called when an item is filtered. Returns true if the item passes the filter.
  // Done=False means the data should also be filtered by its title string.
  // Done=True means no other filtering is needed.
  TFilterItemEvent = function (ItemData: Pointer; out Done: Boolean): Boolean of object;
  TFilterItemExEvent = function (const ACaption: string; ItemData: Pointer;
                                 out Done: Boolean): Boolean of object;

  // Can be used only for items that have a checkbox. Returns true if checked.
  TCheckItemEvent = function (Item: TObject): Boolean of object;

  { TCustomControlFilterEdit }

  // An abstract base class for edit controls which filter data in
  // visual controls like TListView and TTreeView.
  TCustomControlFilterEdit = class(TCustomEditButton)
  private
    fFilter: string;
    fFilterLowercase: string;
    fFilterOptions: TFilterStringOptions;
    fIdleConnected: Boolean;
    fSortData: Boolean;             // Data needs to be sorted.
    fIsFirstSetFormActivate: Boolean;
    fOnAfterFilter: TNotifyEvent;
    procedure SetFilter(AValue: string);
    procedure SetFilterOptions(AValue: TFilterStringOptions);
    procedure SetSortData(AValue: Boolean);
    procedure SetIdleConnected(const AValue: Boolean);
    procedure OnAsync(Data: PtrInt);
    function IsTextHintStored: Boolean;
  protected
    fAlreadyFiltered: Boolean;
    fIsFirstUpdate: Boolean;
    fNeedFiltering, fNeedButtonEnabled: Boolean;
    fSelectedPart: TObject;         // Select this node on next update
    fOnFilterItem: TFilterItemEvent;
    fOnFilterItemEx: TFilterItemExEvent;
    fOnCheckItem: TCheckItemEvent;
    procedure DestroyWnd; override;
    procedure InternalSetFilter(const AValue: string);
    function DoDefaultFilterItem(const ACaption: string;
      const ItemData: Pointer): Boolean; virtual;
    function DoFilterItem(const ACaption: string;
      ItemData: Pointer): Boolean; virtual;
    procedure EditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure EditChange; override;
    procedure BuddyClick; override;
    procedure SortAndFilter; virtual; abstract;
    procedure ApplyFilterCore; virtual; abstract;
    procedure ApplyFilter(Immediately: Boolean = False);
    procedure MoveNext(ASelect: Boolean = False); virtual; abstract;
    procedure MovePrev(ASelect: Boolean = False); virtual; abstract;
    procedure MovePageUp(ASelect: Boolean = False); virtual; abstract;
    procedure MovePageDown(ASelect: Boolean = False); virtual; abstract;
    procedure MoveHome(ASelect: Boolean = False); virtual; abstract;
    procedure MoveEnd(ASelect: Boolean = False); virtual; abstract;
    function ReturnKeyHandled: Boolean; virtual; abstract;
    function GetDefaultGlyphName: string; override;
    class procedure WSRegisterClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InvalidateFilter;
    procedure ResetFilter;
    function ForceFilter(AFilter: String) : String;
    procedure StoreSelection; virtual; abstract;
    procedure RestoreSelection; virtual; abstract;
  public
    property Filter: string read fFilter write SetFilter;
    property FilterLowercase: string read fFilterLowercase;
    property IdleConnected: Boolean read fIdleConnected write SetIdleConnected;
    property SortData: Boolean read fSortData write SetSortData;
    property SelectedPart: TObject read fSelectedPart write fSelectedPart;
  published
    property CharCase default ecLowerCase;
    property FilterOptions: TFilterStringOptions read fFilterOptions write SetFilterOptions default [];
    property OnAfterFilter: TNotifyEvent read fOnAfterFilter write fOnAfterFilter;
    property OnFilterItem: TFilterItemEvent read fOnFilterItem write fOnFilterItem;
      deprecated 'Use OnFilterItemEx with a caption parameter instead.';
    property OnFilterItemEx: TFilterItemExEvent read fOnFilterItemEx write fOnFilterItemEx;
    property OnCheckItem: TCheckItemEvent read fOnCheckItem write fOnCheckItem;
    // TEditButton properties.
    property ButtonCaption;
    property ButtonCursor;
    property ButtonHint;
    property ButtonOnlyWhenFocused;
    property ButtonWidth;
    property Constraints;
    property DirectInput;
    property Flat;
    property FocusOnButtonClick;
    // Other properties
    property Align;
    property Alignment;
    property Anchors;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property AutoSize;
    property AutoSelect;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Glyph;
    property NumGlyphs;
    property Images;
    property ImageIndex;
    property ImageWidth;
    property Layout;
    property MaxLength;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property Spacing;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint stored IsTextHintStored;
    property Visible;

    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditingDone;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;

  { TFileNameEdit }

  TAcceptFileNameEvent = procedure (Sender : TObject; Var Value : String) of Object;
  TDialogKind = (dkOpen,dkSave,dkPictureOpen,dkPictureSave);

  TFileNameEdit = class(TCustomEditButton)
  private
    FDialogOptions: TOpenOptions;
    FFileName : String;
    FDialogFiles : TStrings;
    FDialogKind: TDialogKind;
    FDialogTitle: String;
    FFilter: String;
    FFilterIndex: Integer;
    FDefaultExt: String;
    FHideDirectories: Boolean;
    FInitialDir: String;
    FOnAcceptFileName: TAcceptFileNameEvent;
    FOnFolderChange: TNotifyEvent;
    FFileNameChangeLock: Integer;
    procedure SetFileName(const AValue: String);
  protected
    function GetDefaultGlyphName: string; override;
    function CreateDialog(AKind: TDialogKind): TCommonDialog; virtual;
    procedure SaveDialogResult(AKind: TDialogKind; D: TCommonDialog); virtual;
    procedure ButtonClick; override;
    procedure EditChange; override;
    procedure DoFolderChange(Sender:TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RunDialog; virtual;
    property AutoSelected;
    property DialogFiles: TStrings read FDialogFiles;
  published
    // TFileName properties.
    property FileName: String read FFileName write SetFileName;
    property InitialDir: String read FInitialDir write FInitialDir;
    property OnAcceptFileName: TAcceptFileNameEvent read FOnAcceptFileName write FOnAcceptFileName;
    property OnFolderChange: TNotifyEvent read FOnFolderChange write FOnFolderChange;
    property DialogKind: TDialogKind read FDialogKind write FDialogKind default dkOpen;
    property DialogTitle: String read FDialogTitle write FDialogTitle;
    property DialogOptions: TOpenOptions read FDialogOptions write FDialogOptions default DefaultOpenDialogOptions;
    property Filter: String read FFilter write FFilter;
    property FilterIndex: Integer read FFilterIndex write FFIlterIndex;
    property DefaultExt: String read FDefaultExt write FDefaultExt;
    property HideDirectories: Boolean read FHideDirectories write FHideDirectories;
    // TEditButton properties.
    property ButtonCaption;
    property ButtonCursor;
    property ButtonHint;
    property ButtonOnlyWhenFocused;
    property ButtonWidth;
    property Constraints;
    property DirectInput;
    property Glyph;
    property NumGlyphs;
    property Images;
    property ImageIndex;
    property ImageWidth;
    property Flat;
    property FocusOnButtonClick;
    // Other properties
    property Align;
    property Alignment;
    property Anchors;
    property AutoSelect;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property AutoSize;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Layout;
    property MaxLength;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property Spacing;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Visible;

    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditingDone;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;


  { TDirectoryEdit }

  TDirectoryEdit = class(TCustomEditButton)
  private
    FDialogTitle: String;
    FRootDir: String;
    FOnAcceptDir: TAcceptFileNameEvent;
    FShowHidden: Boolean;
    FDialogOptions: TOpenOptions;
    function GetDirectory: String;
    procedure SetDirectory(const AValue: String);
  protected
    function GetDefaultGlyphName: string; override;
    function CreateDialog: TCommonDialog; virtual;
    function GetDialogResult(D : TCommonDialog) : String; virtual;
    procedure ButtonClick; override;
  public
    property AutoSelected;
    constructor Create(AOwner: TComponent); override;
    procedure RunDialog; virtual;
  published
    // TDirectory properties.
    property Directory: String read GetDirectory write SetDirectory;
    property RootDir: String read FRootDir write FRootDir;
    property OnAcceptDirectory: TAcceptFileNameEvent read FOnAcceptDir write FonAcceptDir;
    property DialogTitle: String read FDialogTitle write FDialogTitle;
    property DialogOptions: TOpenOptions read FDialogOptions write FDialogOptions default DefaultOpenDialogOptions;
    property ShowHidden: Boolean read FShowHidden write FShowHidden;
    // TEditButton properties.
    property ButtonCaption;
    property ButtonCursor;
    property ButtonHint;
    property ButtonOnlyWhenFocused;
    property ButtonWidth;
    property Constraints;
    property DirectInput;
    property Glyph;
    property NumGlyphs;
    property Images;
    property ImageIndex;
    property ImageWidth;
    property Flat;
    property FocusOnButtonClick;
    // Other properties
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property AutoSelect;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Layout;
    property MaxLength;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property Spacing;
    property TabStop;
    property Text;
    property TextHint;
    property Visible;

    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditingDone;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;


  { TDateEdit }

  TAcceptDateEvent = procedure (Sender : TObject; var ADate : TDateTime;
    var AcceptDate: Boolean) of object;
  TCustomDateEvent = procedure (Sender : TObject; var ADate : string) of object;
  TDateRangeCheckEvent = procedure (Sender : TObject; var ADate : TDateTime) of object;
  TDateOrder = (doNone,doMDY,doDMY,doYMd);

  TDateEdit = class(TCustomEditButton)
  private
    FDateOrder: TDateOrder;
    FDefaultToday: Boolean;
    FDisplaySettings: TDisplaySettings;
    FDroppedDown: Boolean;
    FOnAcceptDate: TAcceptDateEvent;
    FOnCustomDate: TCustomDateEvent;
    FOnDateRangeCheck: TDateRangeCheckEvent;
    FFixedDateFormat: string; //used when DateOrder <> doNone
    FFreeDateFormat: String;  //used when DateOrder = doNone
    FDate: TDateTime;
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FUpdatingDate: Boolean;
    procedure CheckRange(var ADate: TDateTime; AMinDate, AMaxDate: TDateTime);
    procedure SetFreeDateFormat(AValue: String);
    procedure SetMaxDate(AValue: TDateTime);
    procedure SetMinDate(AValue: TDateTime);
    function IsLimited: Boolean;
    function GetMaxDateStored: Boolean;
    function GetMinDateStored: Boolean;
    function TextToDate(AText: String; ADefault: TDateTime): TDateTime;
    function GetDate: TDateTime;
    procedure SetDate(Value: TDateTime);
    procedure CalendarPopupReturnDate(Sender: TObject; const ADate: TDateTime);
    procedure CalendarPopupShowHide(Sender: TObject);
    procedure SetDateOrder(const AValue: TDateOrder);
    function DateToText(Value: TDateTime): String;
    function IsNullDate(ADate: TDateTime): Boolean;
  protected
    class procedure WSRegisterClass; override;
    function GetDefaultGlyphName: string; override;
    procedure ButtonClick; override;
    procedure EditDblClick; override;
    procedure EditEditingDone; override;
    procedure SetDirectInput(AValue: Boolean); override;
    procedure RealSetText(const AValue: TCaption); override;
    procedure SetDateMask; virtual;
    procedure Loaded; override;
    procedure DoDateRangeCheck(var ADate: TDateTime);
  public
    constructor Create(AOwner: TComponent); override;
    function GetDateFormat: string;
    property AutoSelected;
    property Date: TDateTime read GetDate write SetDate;
    property Button;
    property DroppedDown: Boolean read FDroppedDown;
  published
    property CalendarDisplaySettings: TDisplaySettings read FDisplaySettings write FDisplaySettings;
    property OnAcceptDate: TAcceptDateEvent read FOnAcceptDAte write FOnAcceptDate;
    property OnCustomDate: TCustomDateEvent read FOnCustomDate write FOnCustomDate;
    property OnDateRangeCheck: TDateRangeCheckEvent read FOnDateRangeCheck write FOnDateRangeCheck;
    property ReadOnly;
    property DefaultToday: Boolean read FDefaultToday write FDefaultToday default False;
    Property DateOrder : TDateOrder Read FDateOrder Write SetDateOrder;
    property DateFormat: String read FFreeDateFormat write SetFreeDateFormat;
    property MinDate: TDateTime read FMinDate write SetMinDate stored GetMinDateStored;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate stored GetMaxDateStored;
    property ButtonOnlyWhenFocused;
    property ButtonCaption;
    property ButtonCursor;
    property ButtonHint;
    property ButtonWidth;
    property Action;
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property AutoSelect;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property DirectInput;
    property Glyph;
    property NumGlyphs;
    property Images;
    property ImageIndex;
    property ImageWidth;
    property DragMode;
    property EchoMode;
    property Enabled;
    property Flat;
    property FocusOnButtonClick;
    property Font;
    property Layout;
    property MaxLength;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabStop;
    property TabOrder;
    property Spacing;
    property Visible;
    property Text;
    property TextHint;

    property OnButtonClick;
    property OnChange;
    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnEditingDone;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnUTF8KeyPress;
  end;
  
  { TTimeEdit }

  TAcceptTimeEvent = procedure (Sender : TObject; var ATime : TDateTime; var AcceptTime: Boolean) of object;
  TCustomTimeEvent = procedure (Sender : TObject; var ATime : TDateTime) of object;

  TTimeEdit = class(TCustomEditButton)
    private
      FTime: TTime;
      IsEmptyTime: Boolean;
      FDefaultNow: Boolean;
      FDroppedDown: Boolean;
      FSimpleLayout: Boolean;
      FTimeAMPMString: array[0..1] of String;
      FTimeFormat: String;
      FTimeSeparator: String;
      FOnAcceptTime: TAcceptTimeEvent;
      FOnCustomTime: TCustomTimeEvent;
      function GetTime: TDateTime;
      function GetTimeAMPMString(AIndex: Integer): String;
      procedure SetTime(AValue: TDateTime);
      procedure SetEmptyTime;
      function GetLayout: Boolean;
      procedure SetLayout(AValue: Boolean);
      procedure SetTimeAMPMString(AIndex: Integer; AValue: String);
      procedure SetTimeFormat(AValue: String);
      procedure SetTimeSeparator(AValue: String);
      procedure TimePopupReturnTime(Sender: TObject; const ATime: TDateTime);
      procedure TimePopupShowHide(Sender: TObject);
      procedure OpenTimePopup;
      procedure ParseInput;
      function TryParseInput(AInput: String; out ParseResult: TDateTime): Boolean;
    protected
      function GetDefaultGlyphName: string; override;
      function Is12HourMode: Boolean;
      function UsedFormatSettings: TFormatSettings;
      function UsedTimeAMString: String;
      function UsedTimeFormat: String;
      function UsedTimePMString: String;
      function UsedTimeSeparator: Char;
      procedure ButtonClick; override;
      procedure EditDblClick; override;
      procedure EditEditingDone; override;
    public
      constructor Create(AOwner: TComponent); override;
      function ValidTimeFormat(AFormat: String): Boolean;
      property Time: TDateTime read GetTime write SetTime;
      property Button;
      property DroppedDown: Boolean read FDroppedDown;
    published
      property DefaultNow: Boolean read FDefaultNow write FDefaultNow default False;
      property OnAcceptTime: TAcceptTimeEvent read FOnAcceptTime write FOnAcceptTime;
      property OnCustomTime: TCustomTimeEvent read FOnCustomTime write FOnCustomTime;
      property ReadOnly;
      property ButtonCaption;
      property ButtonCursor;
      property ButtonHint;
      property ButtonOnlyWhenFocused;
      property ButtonWidth;
      property Action;
      property Align;
      property Alignment;
      property Anchors;
      property AutoSize;
      property AutoSelect;
      property BidiMode;
      property BorderSpacing;
      property BorderStyle;
      property CharCase;
      property Color;
      property Constraints;
      property DirectInput;
      property Glyph;
      property NumGlyphs;
      property Images;
      property ImageIndex;
      property ImageWidth;
      property DragMode;
      property EchoMode;
      property Enabled;
      property Flat;
      property FocusOnButtonClick;
      property Font;
      property MaxLength;
      property ParentBidiMode;
      property ParentColor;
      property ParentFont;
      property ParentShowHint;
      property PopupMenu;
      property ShowHint;
      property SimpleLayout: Boolean read GetLayout write SetLayout default True;
      property Spacing;
      property TabStop;
      property TabOrder;
      property TimeAMString: String index 0 read GetTimeAMPMString write SetTimeAMPMString;
      property TimeFormat: String read FTimeFormat write SetTimeFormat;
      property TimeSeparator: String read FTimeSeparator write SetTimeSeparator;
      property TimePMString: String index 1 read GetTimeAMPMString write SetTimeAMPMString;
      property Visible;
      property Text;
      property TextHint;

      property OnButtonClick;
      property OnChange;
      property OnChangeBounds;
      property OnClick;
      property OnDblClick;
      property OnContextPopup;
      property OnEditingDone;
      property OnEnter;
      property OnExit;
      property OnKeyDown;
      property OnKeyPress;
      property OnKeyUp;
      property OnMouseDown;
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseMove;
      property OnMouseUp;
      property OnMouseWheel;
      property OnMouseWheelDown;
      property OnMouseWheelUp;
      property OnResize;
      property OnUTF8KeyPress;
  end;
  

  { TCalcEdit }

  TAcceptValueEvent = procedure(Sender: TObject; var AValue: Double; var Accept: Boolean) of object;

  TCalcEdit = class(TCustomEditButton)
  private
    FDialogTitle: String;
    FCalculatorLayout: TCalculatorLayout;
    FOnAcceptValue: TAcceptValueEvent;
    FDialogPosition: TPosition;
    FDialogLeft: Integer;
    FDialogTop: Integer;
    function GetAsFloat: Double;
    function GetAsInteger: Integer;
    procedure SetAsFloat(const AValue: Double);
    procedure SetAsInteger(const AValue: Integer);
    function TitleStored: boolean;
  protected
    FCalcDialog : TForm;
    function GetDefaultGlyphName: string; override;
    procedure ButtonClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RunDialog; virtual;
    property AutoSelected;
  published
    // CalcEdit properties
    property CalculatorLayout : TCalculatorLayout read FCalculatorLayout write FCalculatorLayout;
    property AsFloat : Double read GetAsFloat write SetAsFloat;
    property AsInteger : Integer read GetAsInteger write SetAsInteger;
    property OnAcceptValue : TAcceptValueEvent read FOnAcceptValue write FOnAcceptValue;
    property DialogTitle : String read FDialogTitle write FDialogTitle stored TitleStored;
    // TEditButton properties.
    property ButtonCaption;
    property ButtonCursor;
    property ButtonHint;
    property ButtonOnlyWhenFocused;
    property ButtonWidth;
    property Constraints;
    property DialogPosition: TPosition read FDialogPosition write FDialogPosition default poScreenCenter;
    property DialogTop: Integer read FDialogTop write FDialogTop;
    property DialogLeft: Integer read FDialogLeft write FDialogLeft;
    property DirectInput;
    property Glyph;
    property NumGlyphs;
    property Images;
    property ImageIndex;
    property ImageWidth;
    property Flat;
    property FocusOnButtonClick;
    // Other properties
    property Align;
    property Alignment;
    property Anchors;
    property BidiMode;
    property BorderSpacing;
    property BorderStyle;
    property AutoSize;
    property AutoSelect;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Layout;
    property MaxLength;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property Spacing;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Visible;

    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditingDone;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;

const
  ResBtnListFilter = 'btnfiltercancel';
  ResBtnFileOpen   = 'btnselfile';
  ResBtnSelDir     = 'btnseldir';
  ResBtnCalendar   = 'btncalendar';
  ResBtnCalculator = 'btncalculator';
  ResBtnTime       = 'btntime';

procedure Register;

implementation

{$R lcl_edbtnimg.res}

const
  DTEpsilon = Double(1.0)/(24*3600*1000*10); //0.1 millisec (0.000000001157407407);

{ TEditSpeedButton }

procedure TEditSpeedButton.GlyphChanged(Sender: TObject);
begin
  inherited GlyphChanged(Sender);
  if (Owner is TCustomEditButton) then TCustomEditButton(Owner).GlyphChanged(Sender);
end;

{ TEbEdit }

procedure TEbEdit.DoEnter;
begin
  if (Owner is TCustomEditButton) then TCustomEditButton(Owner).CheckButtonVisible;
  inherited DoEnter;
end;

procedure TEbEdit.DoExit;
begin
  if (Owner is TCustomEditButton) then TCustomEditButton(Owner).CheckButtonVisible;
  inherited DoExit;
end;


{ TCustomEditButton }

procedure TCustomEditButton.CalculatePreferredSize(var PreferredWidth,
  PreferredHeight: integer; WithThemeSpace: Boolean);
begin
  inherited CalculatePreferredSize(PreferredWidth, PreferredHeight, WithThemeSpace);
  PreferredWidth := 0;
end;

procedure TCustomEditButton.SetFocusOnButtonClick(AValue: Boolean);
begin
  FocusOnBuddyClick := AValue;
end;

procedure TCustomEditButton.SetOnButtonClick(AValue: TNotifyEvent);
begin
  OnBuddyClick := AValue;
end;

procedure TCustomEditButton.SetButtonOnlyWhenFocused(AValue: Boolean);
begin
  if FButtonOnlyWhenFocused <> AValue then
  begin
    FButtonOnlyWhenFocused := AValue;
    CheckButtonVisible;
  end;
end;

function TCustomEditButton.GetGlyph: TBitmap;
begin
  Result := Button.Glyph;
end;

function TCustomEditButton.GetImageIndex: TImageIndex;
begin
  Result := Button.ImageIndex;
end;

function TCustomEditButton.GetImages: TCustomImageList;
begin
  Result := Button.Images;
end;

function TCustomEditButton.GetImageWidth: Integer;
begin
  Result := Button.ImageWidth;
end;

function TCustomEditButton.GetButton: TSpeedButton;
begin
  Result := TSpeedButton(Buddy);
end;

function TCustomEditButton.GetOnButtonClick: TNotifyEvent;
begin
  Result := OnBuddyClick;
end;

procedure TCustomEditButton.GlyphChanged(Sender: TObject);
begin
  if ((Button.Glyph=nil) or (Button.Glyph.Empty))
  and (Button.Images=nil) and (Button.ImageIndex=-1) then
    LoadDefaultGlyph;
end;

procedure TCustomEditButton.LoadDefaultGlyph;
var
  N: string;
begin
  N := GetDefaultGlyphName;
  if N <> '' then
    (Button as TEditSpeedButton).ButtonGlyph.LCLGlyphName := N;
end;

function TCustomEditButton.GetFocusOnButtonClick: Boolean;
begin
  Result := FocusOnBuddyClick;
end;

function TCustomEditButton.GetNumGlyps: Integer;
begin
  Result := Button.NumGlyphs;
end;

function TCustomEditButton.GetEdit: TEbEdit;
begin
  Result := TEbEdit(BaseEditor);
end;


class function TCustomEditButton.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 80 + 23; //as TCustomEdit + TCustomSpeedButton
  Result.CY := 23;  //as TCustomEdit
end;

function TCustomEditButton.GetDefaultGlyphName: string;
begin
  Result := '';
end;

procedure TCustomEditButton.SetFlat(AValue: Boolean);
begin
  if FFlat = AValue then
    Exit;
  FFlat := AValue;
  Button.Flat := AValue;
end;

procedure TCustomEditButton.SetNumGlyphs(AValue: Integer);
begin
  Button.NumGlyphs := AValue;
end;

function TCustomEditButton.CalcButtonVisible: Boolean;
begin
  Result := (csdesigning in ComponentState) or
            (Visible and (Edit.Focused or not FButtonOnlyWhenFocused));
end;

procedure TCustomEditButton.CheckButtonVisible;
begin
  if Assigned(Button) then
  begin
    Button.Visible := CalcButtonVisible;
    UpdateSpacing;
  end;
end;

procedure TCustomEditButton.ButtonClick;
begin
  //debugln(['TCustomEditButton.ButtonClick']);
  {Don't remove, even if this is an empty method!}
end;

procedure TCustomEditButton.BuddyClick;
begin
  inherited BuddyClick;
  ButtonClick;
end;

procedure TCustomEditButton.SetGlyph(AValue: TBitmap);
begin
  Button.Glyph := AValue;
  if AValue=nil then
    LoadDefaultGlyph;
  Invalidate;
end;

procedure TCustomEditButton.SetImageIndex(const aImageIndex: TImageIndex);
begin
  Button.ImageIndex := aImageIndex;
end;

procedure TCustomEditButton.SetImages(const aImages: TCustomImageList);
begin
  Button.Images := aImages;
end;

procedure TCustomEditButton.SetImageWidth(const aImageWidth: Integer);
begin
  Button.ImageWidth := aImageWidth;
end;

function TCustomEditButton.GetEditorClassType: TGEEditClass;
begin
  Result := TEbEdit;
end;

function TCustomEditButton.GetBuddyClassType: TControlClass;
begin
  Result := TEditSpeedButton;
end;

constructor TCustomEditButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtonOnlyWhenFocused := False;
  FocusOnButtonClick := False;

  SetInitialBounds(0, 0, GetControlClassDefaultSize.CX, GetControlClassDefaultSize.CY);

  LoadDefaultGlyph;
  Spacing := 4;
end;


{ TCustomControlFilterEdit }

constructor TCustomControlFilterEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle:=ControlStyle-[csSetCaption];
  CharCase:=ecLowerCase;
  Button.Enabled:=False;
  fFilterOptions:=[];
  fIsFirstUpdate:=True;
  fIsFirstSetFormActivate:=True;
  TextHint:=rsFilter;
  fNeedButtonEnabled:=True;
  IdleConnected:=true;
end;

destructor TCustomControlFilterEdit.Destroy;
begin
  IdleConnected:=False;
  inherited Destroy;
end;

procedure TCustomControlFilterEdit.DestroyWnd;
begin
  IdleConnected:=false;
  inherited DestroyWnd;
end;

procedure TCustomControlFilterEdit.InternalSetFilter(const AValue: string);
begin
  Button.Enabled:=AValue<>'';
  fFilter:=AValue;
  fFilterLowercase:=UTF8LowerCase(fFilter);
  InvalidateFilter;
end;

procedure TCustomControlFilterEdit.SetFilter(AValue: string);
// AValue parameter must not have const modifier. It causes a crash, see issue #40300.
begin
  if Text=AValue then Exit;
  Text:=AValue;           // ApplyFilter will be called by EditChange handler.
  InternalSetFilter(AValue);
end;

procedure TCustomControlFilterEdit.SetFilterOptions(AValue: TFilterStringOptions);
begin
  if fFilterOptions=AValue then Exit;
  fFilterOptions:=AValue;
  InvalidateFilter;
end;

procedure TCustomControlFilterEdit.SetSortData(AValue: Boolean);
begin
  if fSortData=AValue then Exit;
  fSortData:=AValue;
  InvalidateFilter;
end;

function TCustomControlFilterEdit.DoDefaultFilterItem(const ACaption: string;
  const ItemData: Pointer): Boolean;
var
  NPos: integer;
begin
  if fFilter='' then
    exit(True);

  if fsoCaseSensitive in fFilterOptions then
    NPos := Pos(fFilter, ACaption)
  else
    NPos := Pos(fFilterLowercase, UTF8LowerCase(ACaption));

  if fsoMatchOnlyAtStart in fFilterOptions then
    Result := NPos=1
  else
    Result := NPos>0;
end;

function TCustomControlFilterEdit.DoFilterItem(const ACaption: string;
  ItemData: Pointer): Boolean;
var
  Done: Boolean;
begin
  Done := False;
  Result := False;

  // Filter with event handler if there is one.
  if Assigned(fOnFilterItemEx) then
    Result := fOnFilterItemEx(ACaption, ItemData, Done);

  // Support also the old filter event without a caption.
  if (not (Result and Done)) and Assigned(fOnFilterItem) then
    Result := fOnFilterItem(ItemData, Done);

  // Filter by item's caption text if needed.
  if not (Result or Done) then
    Result := DoDefaultFilterItem(ACaption, ItemData);
end;

procedure TCustomControlFilterEdit.OnAsync(Data: PtrInt);
begin
  if fNeedFiltering then begin
    ApplyFilter(true);
    fNeedFiltering:=False;
  end;
  if fNeedButtonEnabled then begin
    Button.Enabled:=Text<>'';
    fNeedButtonEnabled:=False;
  end;
  IdleConnected:=false;
  if Assigned(fOnAfterFilter) then
    fOnAfterFilter(Self);
end;

procedure TCustomControlFilterEdit.SetIdleConnected(const AValue: Boolean);
begin
  if fIdleConnected=AValue then exit;
  fIdleConnected:=AValue;
  if fIdleConnected then
    Application.QueueAsyncCall(@OnAsync, 0)
  else
    Application.RemoveAsyncCalls(Self);
end;

procedure TCustomControlFilterEdit.EditKeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited EditKeyDown(Key, Shift);
  if Key = 0 then exit;

  if Shift = [] then
    case Key of
      VK_RETURN: if ReturnKeyHandled then Key := 0;
    end;
  if (Shift = []) or (Shift = [ssShift]) then
    case Key of
      VK_UP:    begin MovePrev    (ssShift in Shift); Key := 0; end;
      VK_DOWN:  begin MoveNext    (ssShift in Shift); Key := 0; end;
      VK_PRIOR: begin MovePageUp  (ssShift in Shift); Key := 0; end;
      VK_NEXT:  begin MovePageDown(ssShift in Shift); Key := 0; end;
    end;
  if (Shift = [ssCtrl]) or (Shift = [ssCtrl, ssShift]) then
    case Key of
      VK_HOME:  begin MoveHome(ssShift in Shift); Key := 0; end;
      VK_END:   begin MoveEnd (ssShift in Shift); Key := 0; end;
    end;
end;

procedure TCustomControlFilterEdit.EditChange;
begin
  InternalSetFilter(Text);
  inherited;
end;

procedure TCustomControlFilterEdit.BuddyClick;
begin
  Text:='';
  ResetFilter;
  if FocusOnButtonClick then
    Edit.SetFocus; //don't SelectAll here
  inherited;
end;

procedure TCustomControlFilterEdit.ApplyFilter(Immediately: Boolean);
begin
  if Immediately then begin
    SortAndFilter;
    if (fSelectedPart=Nil) and not fIsFirstUpdate then
      StoreSelection;     // At first round the selection is from caller
    ApplyFilterCore;      // The actual filtering implemented by inherited class.
    fSelectedPart:=Nil;
    if not fIsFirstUpdate then
      RestoreSelection;
    fIsFirstUpdate:=False;
  end
  else if [csDestroying,csDesigning]*ComponentState=[] then
    InvalidateFilter;
end;

procedure TCustomControlFilterEdit.InvalidateFilter;
begin
  if fAlreadyFiltered then Exit;
  fNeedFiltering:=true;
  IdleConnected:=true;
end;

function TCustomControlFilterEdit.IsTextHintStored: Boolean;
begin
  Result := TextHint<>rsFilter;
end;

procedure TCustomControlFilterEdit.ResetFilter;
begin
  Filter:='';
end;

function TCustomControlFilterEdit.ForceFilter(AFilter: String): String;
// Apply a new filter immediately without waiting for idle. Returns the previous filter.
begin
  Result := FFilter;
  if fFilter <> AFilter then begin
    FFilter := AFilter;
    ApplyFilter(True);
  end;
end;

function TCustomControlFilterEdit.GetDefaultGlyphName: string;
begin
  Result := ResBtnListFilter;
end;

class procedure TCustomControlFilterEdit.WSRegisterClass;
begin
  inherited WSRegisterClass;
  RegisterPropertyToSkip(TCustomControlFilterEdit, 'UseFormActivate', 'Property streamed in older Lazarus revision','');
end;

{ TFileNameEdit }

constructor TFileNameEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialogFiles := TStringList.Create;
  FDialogKind := dkOpen;
  FDialogOptions := DefaultOpenDialogOptions;
end;

destructor TFileNameEdit.Destroy;
begin
  FreeAndNil(FDialogFiles);
  inherited Destroy;
end;

procedure TFileNameEdit.SetFileName(const AValue: String);
begin
  if FFileNameChangeLock > 0 then
    Exit;
  FFileName := AValue;
  Inc(FFileNameChangeLock);
  try
    if FHideDirectories then
      Text:=ExtractFileName(AValue) //Originally used inherited RealSetText()
    else
      Text:=AValue
  finally
    Dec(FFileNameChangeLock);
  end;
end;

function TFileNameEdit.CreateDialog(AKind: TDialogKind): TCommonDialog;
var
  O: TOpenDialog;
  S: TSaveDialog;
  Dir: String;
begin
  case AKind of
    dkOpen, dkPictureOpen:
    begin
      if AKind = dkPictureOpen then
        O := TOpenPictureDialog.Create(Self)
      else
        O := TOpenDialog.Create(Self);
      Result := O;
    end;
    dkSave, dkPictureSave:
    begin
      S:=TSaveDialog.Create(Self);
      S.DefaultExt := FDefaultExt;
      Result := S;
    end;
  end;
  if Result is TOpenDialog then
  begin
    O:=TOpenDialog(Result);
    Dir:=ExtractFilePath(Filename);
    if (Dir<>'') and DirPathExists(Dir) then
      // setting a FileName with path disables InitialDir
      O.FileName := FileName
    else begin
      // do not use path, so that InitialDir works
      O.FileName := ExtractFileName(Filename);
    end;
    O.Options := DialogOptions;
    O.Filter := Filter;
    O.FilterIndex := FilterIndex;
    if (InitialDir <> '') then   //don't force currentdir here, let WS do it's normal "magic" to decide where to open
      O.InitialDir := CleanAndExpandDirectory(InitialDir)
    else
      O.InitialDir := '';
  end;
  // Set some common things.
  Result.Title := DialogTitle;
end;

procedure TFileNameEdit.SaveDialogResult(AKind: TDialogKind; D: TCommonDialog);
var
  FN: String;
begin
  case AKind of
    dkOpen, dkPictureOpen :
    begin
      FilterIndex := TOpenDialog(D).FilterIndex;
      FN := TOpenDialog(D).FileName;
      if (FN <> '') then
      begin
        if Assigned(OnAcceptFileName) then
          OnAcceptFileName(Self, FN);
      end;
      if (FN <> '') then
      begin
        // set FDialogFiles first since assigning of FileName trigger events
        FDialogFiles.Text := TOpenDialog(D).Files.Text;
        FileName := FN;
      end;
    end;
    dkSave, dkPictureSave :
    begin
      FileName := TSaveDialog(D).FileName;
      FilterIndex := TSaveDialog(D).FilterIndex;
      FDialogFiles.Clear;
    end;
  end;
end;

procedure TFileNameEdit.ButtonClick;
begin
  inherited ButtonClick;
  RunDialog;
  //Do this after the dialog, otherwise it just looks silly
  if FocusOnButtonClick then FocusAndMaybeSelectAll;
end;

function TFileNameEdit.GetDefaultGlyphName: string;
begin
  Result := ResBtnFileOpen;
end;

procedure TFileNameEdit.RunDialog;
var
  D: TCommonDialog;
  Res: Boolean;
begin
  D := CreateDialog(DialogKind);
  try
    Res := D.Execute;
    //this is analogue to how TOpenDialog behaves, InitialDir is retrieved from the dialog, even if user cancels the dialog.
    if (D is TOpenDialog) then
      InitialDir := TOpenDialog(D).InitialDir;
    if Res then
      SaveDialogResult(DialogKind, D);
  finally
    D.Free;
  end
end;

procedure TFileNameEdit.EditChange;
begin
  if FFileNameChangeLock <= 0 then
  begin
    Inc(FFileNameChangeLock);
    try
      if FHideDirectories and (ExtractFilePath(Text) = '') then
        FFileName := ExtractFilePath(FFileName) + Text
      else
        FFileName := Text;
    finally
      Dec(FFileNameChangeLock);
    end;
  end;
  inherited EditChange; //do this _after_ we have updated FFileName
end;

procedure TFileNameEdit.DoFolderChange(Sender: TObject);
begin
  if Assigned(FOnFolderChange) then
    FOnFolderChange(Self);
end;

{ TDirectoryEdit }

constructor TDirectoryEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialogOptions := DefaultOpenDialogOptions;
end;

procedure TDirectoryEdit.SetDirectory(const AValue: String);
begin
  if (Text<>AValue) then
    Text:=AValue;
end;

function TDirectoryEdit.CreateDialog: TCommonDialog;
begin
  Result:=TSelectDirectoryDialog.Create(Self);
  if DirPathExists(Directory) then
  begin
    TSelectDirectoryDialog(Result).InitialDir:=Directory;
    TSelectDirectoryDialog(Result).FileName:='';
  end
  else
  begin
    TSelectDirectoryDialog(Result).InitialDir:=RootDir;
    TSelectDirectoryDialog(Result).FileName:=Directory;
  end;
  // Set some common things.
  TSelectDirectoryDialog(Result).Options := DialogOptions;
  Result.Title := DialogTitle;
end;

function TDirectoryEdit.GetDialogResult(D: TCommonDialog) : String;
begin
  Result:=TSelectDirectoryDialog(D).FileName;
end;

procedure TDirectoryEdit.ButtonClick;
begin
  inherited ButtonClick;
  RunDialog;
  //Do this after the dialog, oterwise it just looks silly
  if FocusOnButtonClick then FocusAndMaybeSelectAll;
end;

function TDirectoryEdit.GetDefaultGlyphName: string;
begin
  Result := ResBtnSelDir;
end;

procedure TDirectoryEdit.RunDialog;
var
  D: String;
  Dlg: TCommonDialog;
  B: Boolean;
begin
  Dlg:=CreateDialog;
  try
    B:=Dlg.Execute;
    if B then
      D:=GetDialogResult(Dlg);
  finally
    Dlg.Free;
  end;
  if B then
  begin
    if Assigned(FOnAcceptDir) then
    begin
      FOnAcceptdir(Self,D);
      if (D<>'') then
        Directory:=D;
    end
    else
      Directory:=D;
  end;
end;

function TDirectoryEdit.GetDirectory: String;
begin
  Result:=Text;
end;

{ TDateEdit }

function StrToDateDef(cDate: String; dDefault: TDateTime): TDateTime;
begin
  try
    Result := StrToDate(cDate)
  except
    Result := dDefault;
  end;
end;

constructor TDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDate := NullDate;
  FMinDate := 0.0;
  FMaxDate := 0.0;
  FUpdatingDate := False;
  FDefaultToday := False;
  FDisplaySettings := [dsShowHeadings, dsShowDayNames];
end;


function TDateEdit.GetDateFormat: string;
begin
  Result := FFixedDateFormat;
end;

function TDateEdit.GetDefaultGlyphName: string;
begin
  Result := ResBtnCalendar;
end;

procedure TDateEdit.ButtonClick;//or onClick
var
  PopupOrigin: TPoint;
  ADate: TDateTime;
begin
  inherited ButtonClick;

  PopupOrigin := ControlToScreen(Point(0, Height));
  ADate := GetDate;
  if IsNullDate(ADate) then
    ADate := SysUtils.Date;
  if IsLimited then
    CheckRange(ADate, FMinDate, FMaxDate)
  else
    CheckRange(ADate, MinDateTime, MaxDateTime);
  ShowCalendarPopup(PopupOrigin, ADate, CalendarDisplaySettings,
                    FMinDate, FMaxDate,
                    @CalendarPopupReturnDate, @CalendarPopupShowHide, self);
  //Do this after the dialog, otherwise it just looks silly
  if FocusOnButtonClick then FocusAndMaybeSelectAll;
end;


procedure TDateEdit.EditDblClick;
begin
  inherited EditDblClick;
  if not ReadOnly then
    ButtonClick;
end;

procedure TDateEdit.EditEditingDone;
var
  AText: String;
begin
  inherited EditEditingDone;
  if DirectInput then
  begin
    AText := DateToText(GetDate);
    if AText <> Text then //avoid unneccesary recalculation FDate
      Text := AText;
  end;
end;

procedure TDateEdit.SetDirectInput(AValue: Boolean);
var
  Def: TDateTime;
begin
  inherited SetDirectInput(AValue);
  //Synchronize FDate
  FDate := TextToDate(Text, NullDate);
  //Force a valid date in the control, but not if Text was empty in designmode
  if not ((csDesigning in ComponentState) and FDefaultToday and (IsNullDate(FDate))) then
    SetDate(FDate);
end;

procedure TDateEdit.RealSetText(const AValue: TCaption);
begin
  if (not DirectInput) and not FUpdatingDate then
  begin
    //force a valid date and set FDate
    //debugln('TDateEdit.SetText: DirectInput = False');
    if FDefaultToday then
      FDate := TextToDate(AValue, SysUtils.Date)
    else
      FDate := TextToDate(AValue, NullDate);
    //Allow to clear Text in Designer (Issue #0030425)
    if (csDesigning in ComponentState) and (AValue = '') then
      inherited RealSetText('')
    else
      inherited RealSetText(DateToText(FDate));
  end else
    inherited RealSetText(AValue);
end;

procedure TDateEdit.SetDateMask;

Var
  S : String;
  D : TDateTime;
begin
  Case DateOrder of
    doNone :
       begin
       S:=''; // no mask
       FFixedDateFormat:='';
       end;
    doDMY,
    doMDY  :
      begin
      S:='99/99/9999;1;_';
      if DateOrder=doMDY then
        FFixedDateFormat:='mm/dd/yyyy'
      else
        FFixedDateFormat:='dd/mm/yyyy';
      end;
    doYMD  :
      begin
      S:='9999/99/99;1;_';
      FFixedDateFormat:='yyyy/mm/dd';
      end;
  end;
  D:=GetDate;
  EditMask:=S;
  SetDate(D);
end;

procedure TDateEdit.Loaded;
begin
  //Forces a valid Text in the control
  if not (csDesigning in ComponentState) then
    SetDate(FDate);
  //avoid OnChange (regression introduced by #8ce29506c500e46d65b9a067bf446fd91224e6c0, happens when DirectInput=True and DefaultToday=True)
  //the FEdit's OnChange is only forwarded once the whole component has been loaded, so call inherited after setting the text, not before
  inherited Loaded;
end;

procedure TDateEdit.DoDateRangeCheck(var ADate: TDateTime);
begin
  if Assigned(FOnDateRangeCheck) then
    FOnDateRangeCheck(Self, ADate);
end;

Function ParseDate(S : String; Order : TDateOrder; Def: TDateTime) : TDateTime;

Var
  P,N1,N2,N3 : Integer;
  B : Boolean;

begin
  Result:=Def;
  P:=Pos(DefaultFormatSettings.DateSeparator,S);
  If (P=0) then
    Exit;
  N1:=StrToIntDef(Copy(S,1,P-1),-1);
  If (N1=-1) then Exit;
  Delete(S,1,P);
  P:=Pos(DefaultFormatSettings.DateSeparator,S);
  If (P=0) then
    Exit;
  N2:=StrToIntDef(Copy(S,1,P-1),-1);
  If (N2=-1) then Exit;
  Delete(S,1,P);
  N3:=StrToIntDef(S,-1);
  If (N3=-1) then
    exit;
  Case Order of
    doYMD : B:=TryEncodeDate(N1,N2,N3,Result);
    doMDY : B:=TryEncodeDate(N3,N1,N2,Result);
    doDMY : B:=TryEncodeDate(N3,N2,N1,Result);
    else B:=false;
  end;
  If not B then // Not sure if TryEncodeDate touches Result.
    Result:=Def;
end;

// Tries to parse string when DateOrder = doNone when string maybe contains
// literal day or monthnames. For example when ShortDateFormat = 'dd-mmm-yyy'
// Returns NullDate upon failure.
function ParseDateNoPredefinedOrder(SDate: String; FS: TFormatSettings): TDateTime;
var
  Fmt: String;
  DPos, MPos, YPos: SizeInt;
  DStr, MStr, YStr: String;
  LD, LM, LY: LongInt;
  DD, MM, YY: Word;
const
  Digits = ['0'..'9'];

  procedure GetPositions(out DPos, MPos, YPos: SizeInt);
  begin
    DStr := '';
    MStr := '';
    YStr := '';
    DPos := Pos('D', Fmt);
    MPos := Pos('M', Fmt);
    YPos := Pos('Y', Fmt);
    if (YPos = 0) or (MPos = 0) or (DPos = 0) then Exit;
    if (YPos > DPos) then YPos := 3 else YPos := 1;
    if (DPos < MPos) then
    begin
      if (YPos = 3) then
      begin
        DPos := 1;
        MPos := 2;
      end
      else
      begin
        DPos := 2;
        MPos := 3;
      end;
    end
    else
    begin
      if (YPos = 3) then
      begin
        DPos := 2;
        MPos := 1;
      end
      else
      begin
        DPos := 3;
        MPos := 2;
      end;
    end;
  end;

  procedure ReplaceLiterals;
  var
    i, P: Integer;
    Sub: String;
  begin
    if (Pos('MMMM',Fmt) > 0) then
    begin //long monthnames
      //writeln('Literal monthnames');
      for i := 1 to 12 do
      begin
        Sub := FS.LongMonthNames[i];
        P := Pos(Sub, SDate);
        if (P > 0) then
        begin
          Delete(SDate, P, Length(Sub));
          Insert(IntToStr(i), SDate, P);
          Break;
        end;
      end;
    end
    else
    begin
      if (Pos('MMM',Fmt) > 0) then
      begin //short monthnames
        for i := 1 to 12 do
        begin
          Sub := FS.ShortMonthNames[i];
          P := Pos(Sub, SDate);
          if (P > 0) then
          begin
            Delete(SDate, P, Length(Sub));
            Insert(IntToStr(i), SDate, P);
            Break;
          end;
        end;
      end;
    end;

    if (Pos('DDDD',Fmt) > 0) then
    begin  //long daynames
      //writeln('Literal daynames');
      for i := 1 to 7 do
      begin
        Sub := FS.LongDayNames[i];
        P := Pos(Sub, SDate);
        if (P > 0) then
        begin
          Delete(SDate, P, Length(Sub));
          Break;
        end;
      end;
    end
    else
    begin
      if (Pos('DDD',Fmt) > 0) then
      begin //short daynames
        for i := 1 to 7 do
        begin
          Sub := FS.ShortDayNames[i];
          P := Pos(Sub, SDate);
          if (P > 0) then
          begin
            Delete(SDate, P, Length(Sub));
            Break;
          end;
        end;
      end;
    end;
    SDate := Trim(SDate);
    //writeln('ReplaceLiterals -> ',SDate);
  end;

  procedure Split(out DStr, MStr, YStr: String);
  var
    i, P: Integer;
    Sep: Set of Char;
    Sub: String;
  begin
    DStr := '';
    MStr := '';
    YStr := '';
    Sep := [];
    for i :=  1 to Length(Fmt) do
      if not (Fmt[i] in Digits) then Sep := Sep + [Fmt[i]];
    //get fist part
    P := 1;
    while (P <= Length(SDate)) and (SDate[P] in Digits) do Inc(P);
    Sub := Copy(SDate, 1, P-1);
    Delete(SDate, 1, P);
    if (DPos = 1) then DStr := Sub else if (MPos = 1) then MStr := Sub else YStr := Sub;
    //get second part
    if (SDate = '') then Exit;
    while (Length(SDate) > 0) and (SDate[1] in Sep) do Delete(SDate, 1, 1);
    if (SDate = '') then Exit;
    P := 1;
    while (P <= Length(SDate)) and (SDate[P] in Digits) do Inc(P);
    Sub := Copy(SDate, 1, P-1);
    Delete(SDate, 1, P);
    if (DPos = 2) then DStr := Sub else if (MPos = 2) then MStr := Sub else YStr := Sub;
    //get thirdpart
    if (SDate = '') then Exit;
    while (Length(SDate) > 0) and (SDate[1] in Sep) do Delete(SDate, 1, 1);
    if (SDate = '') then Exit;
    Sub := SDate;
    if (DPos = 3) then DStr := Sub else if (MPos = 3) then MStr := Sub else YStr := Sub;
  end;

  procedure AdjustYear(var YY: Word);
  var
    CY, CM, CD: Word;
  begin
    DecodeDate(Date, CY, CM, CD);
    LY := CY Mod 100;
    CY := CY - LY;
    if ((YY - LY) <= 50) then
      YY := CY + YY
    else
      YY := CY + YY - 100;
  end;

begin
  Result := NullDate;  //assume failure
  if (Length(SDate) < 5) then Exit; //y-m-d is minimum we support
  Fmt := UpperCase(FS.ShortDateFormat); //only care about y,m,d so this will do
  GetPositions(DPos, MPos, YPos);
  ReplaceLiterals;
  if (not (SDate[1] in Digits)) or (not (SDate[Length(SDate)] in Digits)) then Exit;
  Split(Dstr, MStr, YStr);
  if not TryStrToInt(DStr, LD) or
     not TryStrToInt(Mstr, LM) or
     not TryStrToInt(YStr, LY) then Exit;
  DD := LD;
  MM := LM;
  YY := LY;
  if (YY < 100) and (Pos('YYYY', UpperCase(Fmt)) = 0) then
  begin
    AdjustYear(YY);
  end;
  if not TryEncodeDate(YY, MM, DD, Result) then
    Result := NullDate;
end;

function TDateEdit.TextToDate(AText: String; ADefault: TDateTime): TDateTime;
var
  FS: TFormatSettings;
begin
  if Assigned(FOnCustomDate) then
    FOnCustomDate(Self, AText);
  if (DateOrder = doNone) then
  begin
    FS := DefaultFormatSettings;
    if (FFreeDateFormat <> '') then
      FS.ShortDateFormat := FFreeDateFormat;
    if not TryStrToDate(AText, Result, FS) then
    begin
      Result := ParseDateNoPredefinedOrder(AText, FS);
      if IsNullDate(Result) then Result := ADefault;
    end;
  end
  else
    Result := ParseDate(AText,DateOrder,ADefault)
end;

procedure TDateEdit.CheckRange(var ADate: TDateTime; AMinDate, AMaxDate: TDateTime);
begin
  DoDateRangeCheck(ADate);
  //otherwise you get a message like "Invalid Date: 31-12-9999. Must be between 1-1-0001 and 31-12-9999"
  if (ADate < SysUtils.MinDateTime) then
    raise EInvalidDate.CreateFmt(rsDateTooSmall, [DateToStr(SysUtils.MinDateTime)]);
  if (ADate > SysUtils.MaxDateTime) then
    raise EInvalidDate.CreateFmt(rsDateTooLarge, [DateToStr(SysUtils.MaxDateTime)]);
  if (ADate < AMinDate) or (ADate > AMaxDate) then
  raise EInvalidDate.CreateFmt(rsInvalidDateRangeHint, [DateToStr(ADate),
      DateToStr(AMinDate), DateToStr(AMaxDate)]);
end;

procedure TDateEdit.SetFreeDateFormat(AValue: String);
var
  D: TDateTime;
begin
  if FFreeDateFormat = AValue then Exit;
  if (Text <> '') and (FDateOrder = doNone) and (not (csDesigning in ComponentState)) then
  begin
    D := GetDate;
    FFreeDateFormat := AValue;
    SetDate(D); //will update the text
  end
  else
    FFreeDateFormat := AValue;
end;

procedure TDateEdit.SetMaxDate(AValue: TDateTime);
begin
  CheckRange(AValue, MinDateTime, MaxDateTime);
  if FMaxDate = AValue then Exit;
  FMaxDate := AValue;
  if IsLimited and not IsNullDate(FDate) and (FDate > FMaxDate) then
    SetDate(FMaxDate);
end;

procedure TDateEdit.SetMinDate(AValue: TDateTime);
begin
  CheckRange(AValue, MinDateTime, MaxDateTime);
  if FMinDate = AValue then Exit;
  FMinDate := AValue;
  if IsLimited and not IsNullDate(FDate) and (FDate < FMinDate) then
    SetDate(FMinDate);
end;

function TDateEdit.IsLimited: Boolean;
begin
  Result := (Trunc(FMaxDate)-Trunc(FMinDate) > 0);
end;

function TDateEdit.GetMaxDateStored: Boolean;
begin
  Result := not SameValue(FMaxDate, Double(0.0), DTEpsilon);
end;

function TDateEdit.GetMinDateStored: Boolean;
begin
  Result := not SameValue(FMinDate, Double(0.0), DTEpsilon);
end;

function TDateEdit.GetDate: TDateTime;
var
  ADate: string;
  Def: TDateTime;
begin
  //debugln(['TDateEdit.GetDate: FDate = ',DateToStr(FDate)]);
  if IsNullDate(FDate) and FDefaultToday then
    Def := SysUtils.Date
  else
    Def := FDate;
  ADate := Trim(Text);
  //if not DirectInput then FDate matches the Text, so no need to parse it
  if {(ADate <> '') and} DirectInput then
  begin
    if (ADate = '') then
    begin
      if FDefaultToday then
        Result := SysUtils.Date
      else
        Result := NullDate;
    end
    else
    begin
      Result := TextToDate(ADate, Def);
      FDate := Result;
    end;
  end
  else
    Result := Def;
end;

procedure TDateEdit.SetDate(Value: TDateTime);
begin
  FUpdatingDate := True;
  try
    if IsNullDate(Value) then
    begin
      if DefaultToday then
        Value := SysUtils.Date
      //else
      //  Value := NullDate;
    end;
    if not IsNullDate(Value) then
    begin
      if IsLimited  then
        CheckRange(Value, FMinDate, FMaxDate)
      else
        CheckRange(Value, MinDateTime, MaxDateTime);
    end;
    FDate := Value;
    Text := DateToText(FDate);
  finally
    FUpdatingDate := False;
  end;
end;

procedure TDateEdit.CalendarPopupReturnDate(Sender: TObject;
  const ADate: TDateTime);
var
  B: Boolean;
  D: TDateTime;
begin
  try
    B := True;
    D := ADate;
    if Assigned(FOnAcceptDate) then
      FOnAcceptDate(Self, D, B);
    if B then
      Self.Date := D;
  except
    on E:Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TDateEdit.CalendarPopupShowHide(Sender: TObject);
begin
  FDroppedDown := (Sender as TForm).Visible;
end;

procedure TDateEdit.SetDateOrder(const AValue: TDateOrder);
begin
  if FDateOrder=AValue then exit;
  FDateOrder:=AValue;
  SetDateMask;
end;

function TDateEdit.DateToText(Value: TDateTime): String;
var
  FS: TFormatSettings;
begin
  if IsNullDate(Value) then
    Result := ''
  else
  begin
    if (FDateOrder = doNone) or (FFixedDateFormat = '') then
    begin
      FS := DefaultFormatSettings;
      if (FFreeDateFormat <> '') then
        FS.ShortDateFormat := FFreeDateFormat;
      Result := DateToStr(Value, FS)
    end
    else
      Result := FormatDateTime(FFixedDateFormat, Value)
  end;
end;

function TDateEdit.IsNullDate(ADate: TDateTime): Boolean;
begin
  Result := (Trunc(ADate) = Trunc(NullDate));
end;

class procedure TDateEdit.WSRegisterClass;
begin
  inherited WSRegisterClass;
  RegisterPropertyToSkip(TDateEdit, 'OKCaption', 'Property streamed in older Lazarus revision','');
  RegisterPropertyToSkip(TDateEdit, 'CancelCaption', 'Property streamed in older Lazarus revision','');
end;


{ TTimeEdit }

function TTimeEdit.GetTime: TDateTime;
var
  TmpResult: TDateTime;
begin
  if DirectInput and TryParseInput(Text, TmpResult) then
    FTime := TmpResult;
  Result := FTime;
  if IsEmptyTime then begin
    if FDefaultNow then
      Result := TimeOf(Now);
  end else begin
    if Assigned(FOnCustomTime) then
      FOnCustomTime(Self, Result);
  end;
end;

function TTimeEdit.GetTimeAMPMString(AIndex: Integer): String;
begin
  Result := FTimeAMPMString[AIndex];
end;

function TTimeEdit.GetLayout: Boolean;
begin
  Result := FSimpleLayout;
end;

procedure TTimeEdit.SetLayout(AValue: Boolean);
begin
  FSimpleLayout := AValue;
end;

procedure TTimeEdit.SetTime(AValue: TDateTime);
begin
  Text := FormatDateTime(UsedTimeFormat, AValue, UsedFormatSettings);
  FTime := AValue;
  IsEmptyTime := False;
end;

procedure TTimeEdit.SetTimeAMPMString(AIndex: Integer; AValue: String);
begin
  if FTimeAMPMString[AIndex] <> AValue then
  begin
    FTimeAMPMString[AIndex] := AValue;
    SetTime(FTime);
  end;
end;

procedure TTimeEdit.SetTimeFormat(AValue: String);
begin
  if (FTimeFormat <> AValue) and ValidTimeFormat(AValue) then
  begin
    FTimeFormat := AValue;
    SetTime(FTime);
  end;
end;

procedure TTimeEdit.SetTimeSeparator(AValue: String);
begin
  if FTimeSeparator <> AValue then
  begin
    FTimeSeparator := AValue;
    SetTime(FTime);
  end;
end;

procedure TTimeEdit.SetEmptyTime;
begin
  Text := EmptyStr;
  FTime := NullTime;
  IsEmptyTime := True;
end;

procedure TTimeEdit.TimePopupReturnTime(Sender: TObject; const ATime: TDateTime);
var
  AcceptResult: Boolean;
  ReturnedTime: TDateTime;
begin
  try
    AcceptResult := True;
    ReturnedTime := ATime;
    if Assigned(FOnAcceptTime) then
      FOnAcceptTime(Self, ReturnedTime, AcceptResult);
    if AcceptResult then
      Self.Time := ReturnedTime;
  except
    on E:Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TTimeEdit.TimePopupShowHide(Sender: TObject);
begin
  FDroppedDown := (Sender as TForm).Visible;
end;

procedure TTimeEdit.OpenTimePopup;
var
  PopupOrigin: TPoint;
  ATime: TDateTime;
begin
  ParseInput;
  PopupOrigin := ControlToScreen(Point(0, Height));
  ATime := GetTime;
  if ATime = NullTime then
    ATime := SysUtils.Time;
  ShowTimePopup(PopupOrigin, ATime, Self.DoubleBuffered,
    @TimePopupReturnTime, @TimePopupShowHide, FSimpleLayout, self, Is12HourMode,
    UsedTimeAMString, UsedTimePMString);
end;

function TTimeEdit.TryParseInput(AInput: String; out ParseResult: TDateTime): Boolean;
var
  timeSep: Char;
begin
  AInput := Trim(AInput);
  timeSep := UsedTimeSeparator;
  if (Length(AInput) in [3..4]) and (not AnsiContainsStr(AInput, timeSep)) then begin
    Insert(timeSep, AInput, Length(AInput) - 1);
  end;
  Result := TryStrToTime(AInput, ParseResult, UsedFormatSettings);
end;

procedure TTimeEdit.ParseInput;
var
  TmpResult: TDateTime;
begin
  if Trim(Text) = EmptyStr then
    SetEmptyTime
  else if TryParseInput(Self.Text, TmpResult) then
    SetTime(TmpResult)
  else
    SetTime(FTime);
end;

function TTimeEdit.GetDefaultGlyphName: string;
begin
  Result := ResBtnTime;
end;

function TTimeEdit.Is12HourMode: Boolean;
var
  tf: String;
begin
  tf := LowerCase(UsedTimeFormat);
  Result := (pos('am/pm', tf) > 0) or (pos('a/p', tf) > 0) or (pos('ampm', tf) > 0);
end;

function TTimeEdit.UsedFormatSettings: TFormatSettings;
begin
  Result := DefaultFormatSettings;
  Result.TimeSeparator := UsedTimeSeparator;
  Result.ShortTimeFormat := UsedTimeFormat;
  Result.TimeAMString := TimeAMString;
  Result.TimePMString := TimePMString;
end;

function TTimeEdit.UsedTimeAMString: String;
begin
  if (pos('ampm', Lowercase(UsedTimeFormat)) > 0) then
  begin
    if TimeAMString = '' then
      Result := DefaultFormatSettings.TimeAMString
    else
      Result := TimeAMString;
    if Result = '' then Result := 'am';
  end else
    Result := 'am';
end;

function TTimeEdit.UsedTimeFormat: String;
begin
  if (FTimeFormat = '') or (FTimeFormat = 't') then
    Result := DefaultFormatSettings.ShortTimeFormat
  else
    Result := FTimeFormat;
end;

function TTimeEdit.UsedTimePMString: String;
begin
  if (pos('ampm', Lowercase(UsedTimeFormat)) > 0) then
  begin
    if TimePMString = '' then
      Result := DefaultFormatSettings.TimePMString
    else
      Result := TimePMString;
    if Result = '' then Result := 'pm';
  end else
    Result := 'pm';
end;

function TTimeEdit.UsedTimeSeparator: Char;
begin
  if FTimeSeparator = '' then
    Result := DefaultFormatSettings.TimeSeparator
  else
    Result := FTimeSeparator[1];
end;

// Since TTimeEdit requires a pure "time format string" this function checks
// whether AFormat contains date parts and returns FALSE in this case.
function TTimeEdit.ValidTimeFormat(AFormat: String): Boolean;
type
  TFormatPart = (pH, pM, pN, pS, pZ);
var
  p, pEnd: PChar;
  parts: set of TFormatPart = [];
  quoteChar: Char;
begin
  if AFormat = '' then
    exit(true);

  Result := false;
  p := @AFormat[1];
  pEnd := p + Length(AFormat);
  while p < pEnd do begin
    case p^ of
      // allowed
      'h', 'H':
        Include(parts, pH);
      'n', 'N':
        begin
          Include(parts, pN);
          if (pM in parts) then exit;    // mixing of 'n' and 'm' not valid
        end;
      's', 'S':
        begin
          Include(parts, pS);
          if parts * [pH, pM, pS] = [pM, pS] then exit;  // m:s not valid
        end;
      'z', 'Z':
        begin
          Include(parts, pZ);
          if parts * [pH, pM, pS, pZ] = [pM, pZ] then exit;  // m:z is not valid
        end;
      'm', 'M':
        begin
          Include(parts, pM);
          if (pN in parts) then exit;   // mixing of 'n' and 'm' not valid
          if parts = [pM] then exit;    // isolated 'm' not allowed
          if parts * [pH, pM, pS] = [pM, pS] then exit;      // m:s not valid
          if parts * [pH, pM, pS, pZ] = [pM, pZ] then exit;  // m.z not valid
        end;
      // ignore quoted parts
      '"', '''':
        begin
          quotechar := p^;
          inc(p);
          while (p < pEnd) and (p^ <> quoteChar) do
            inc(p);
        end;
      // am/pm
      'a', 'A':
        begin
          if (StrLIComp(p, 'A/P', 3) = 0) then
            inc(p, 2)
          else
          if (StrLIComp(P, 'AMPM', 4) = 0) then
            inc(p, 3)
          else
          if (StrLIComp(P, 'AM/PM', 5) = 0) then
            inc(p, 4)
          else
            exit;
        end;
      '[', ']':
        exit;  // interval mode does not fit to the GUI of this control
      'd', 'D', 'y', 'Y':
        exit;  // parts of date format
    else
      ; // all other characters allowed (not necessariy optimal)
    end;
    inc(p);
  end;
  Result := true;
end;

procedure TTimeEdit.ButtonClick;
begin
  inherited ButtonClick;
  OpenTimePopup;
end;

procedure TTimeEdit.EditDblClick;
begin
  inherited EditDblClick;
  OpenTimePopup;
end;

procedure TTimeEdit.EditEditingDone;
begin
  ParseInput;
  inherited EditEditingDone;
end;

constructor TTimeEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetEmptyTime;
  FSimpleLayout := True;
end;


{ TCalcEdit }

function TCalcEdit.GetAsFloat: Double;
begin
  Result := StrToFloatDef(Trim(Text), 0.0);
end;

function TCalcEdit.GetAsInteger: Integer;
begin
  Result:=StrToIntDef(Text,0);
end;

function TCalcEdit.GetDefaultGlyphName: string;
begin
  Result := ResBtnCalculator;
end;

procedure TCalcEdit.SetAsFloat(const AValue: Double);
begin
  Text:=FloatToStr(AValue);
end;

procedure TCalcEdit.SetAsInteger(const AValue: Integer);
begin
  Text:=IntToStr(AValue);
end;

function TCalcEdit.TitleStored: boolean;
begin
  Result:=FDialogTitle<>rsCalculator;
end;

procedure TCalcEdit.ButtonClick;
begin
  inherited ButtonClick;
  RunDialog;
  //Do this after the dialog, otherwise it just looks silly
  if FocusOnButtonClick then FocusAndMaybeSelectAll;
end;

procedure TCalcEdit.RunDialog;
var
  D : Double;
  B : Boolean;
  Dlg: TCalculatorForm;
begin
  D:=AsFloat;
  Dlg := CreateCalculatorForm(Self,FCalculatorLayout,0);
  with Dlg do
    try
      Caption:=DialogTitle;
      Value:=D;
      Dlg.Top := FDialogTop;
      Dlg.Left := FDialogLeft;
      Dlg.Position := FDialogPosition;
      if (ShowModal=mrOK) then
      begin
        D:=Value;
        B:=True;
        If Assigned(FOnAcceptValue) then
          FOnAcceptValue(Self,D,B);
        if B then
          AsFloat:=D;
      end;
    finally
      Free;
    end;
end;

constructor TCalcEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialogTitle:=rsCalculator;
  FDialogPosition := poScreenCenter;
end;


procedure Register;
begin
  RegisterComponents('Misc', [TEditButton,TFileNameEdit,TDirectoryEdit,
                              TDateEdit,TTimeEdit,TCalcEdit]);
end;

end.
