{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynEdit.pas, released 2000-04-07.
The Original Code is based on mwCustomEdit.pas by Martin Waldenburg, part of
the mwEdit component suite.
Portions created by Martin Waldenburg are Copyright (C) 1998 Martin Waldenburg.
All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id$

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:

  -DoubleBuffered
  -Font.CharSet
  -THintWindow
  -DragAcceptFiles

-------------------------------------------------------------------------------}

unit SynEdit;
{$IFDEF WINCE} {$IFnDEF WinIME}   {$DEFINE WithoutWinIME}   {$ENDIF} {$ENDIF}
{$IFDEF Windows}
  {$IFnDEF WithoutWinIME}
    {$DEFINE WinIME}
    {$DEFINE WinIMEFull}
  {$ENDIF}
{$ENDIF}

{$I synedit.inc}


{$IFDEF LCLGTK1}
{$DEFINE EnableDoubleBuf} // gtk1 does not have double buffering
{$ENDIF}
{$IFDEF LCLGTK2}
{ $DEFINE EnableDoubleBuf} // gtk2.10 paints faster to memory
                           // gtk2.12 paints faster directly
{$ENDIF}

{$IFDEF Windows}
  (* * On Windows 10 there is an issue, where under certain conditions a "ghost" of the text caret remains visible.
     That is one or a series of vertical black lines remain on the screen.
     * This can be reproduced, by moving part (eg bottom) of editor off screen (not just behind the taskbar, but
     off screen). Then press caret down to scroll. Ghost carets will scroll in with the new text.
     Similar move caret to a place off-screen, unfocus editor, and refocus by clicking into the editor (move caret
     while setting focus).
     To reproduce, the editor must have a visible gutter; and must not have "current line" highlight.
     * The conditions to cause this:
     - Caret must be in part of editor that is outside the screen.
     - Carte must be destroyed (maybe only hidden?), or ScrollWindowEx must affect caret
     - Caret must be in a part of the editor for which NO call to "invalidate" was made,
       but which will be repainted.
       E.g. the gutter, but not the line area received an invalidate, and another line above/below was invalidated
       (can happen through ScrollWindowEx). -> In this case the paint message receives a rect, that contains the caret,
       even though the part containing the caret was never explicitly invalidated.
     If this happens, while the caret is on screen (even if hidden behind another window/taskbar) then all works ok.
     But if the caret was off screen, a permanent image of the caret will remain (once scrolled/moved into the screen area).
     It seem that in this case windows does not update the information, that the caret became "invisible" when paint did paint
     over it. So if the already overpainted caret, is later (by Windows) attempted to be hidden by a final "xor", then it actually
     is made permanently visible.

     As a solution, in the above conditions, the full line (actually the text part with the caret) must be invalidated too.
     Since this is hard to track, the workaround will invalidate the full line, in any case that potentially could meet the
     conditions
  *)
  {$DEFINE Windows10GhostCaretIssue}
{$ENDIF}

interface

{ $DEFINE SYNSCROLLDEBUG}
{ $DEFINE VerboseKeys}
{ $DEFINE VerboseSynEditInvalidate}
{ $DEFINE SYNDEBUGPRINT}
{$IFDEF SynUndoDebug}
  {$Define SynUndoDebugItems}
  {$Define SynUndoDebugCalls}
{$ENDIF}

uses
  LazSynIMMBase,
  {$IFDEF WinIME}
  LazSynIMM,
  {$ENDIF}
  {$IFDEF Gtk2IME}
  LazSynGtk2IMM,
  {$ENDIF}
  {$IFDEF USE_UTF8BIDI_LCL}
  FreeBIDI, utf8bidi,
  {$ENDIF}
  {$IFDEF WithSynExperimentalCharWidth}
  SynEditTextSystemCharWidth,
  {$ENDIF}
  Types, SysUtils, Classes,
  // LCL
  LCLProc, LCLIntf, LCLType, LMessages, LResources, Messages, Controls, Graphics,
  Forms, StdCtrls, ExtCtrls, Menus, Clipbrd, StdActns,
  // LazUtils
  LazUtilities, LazMethodList, LazLoggerBase, LazTracer, LazUTF8,
  // SynEdit
  SynEditTypes, SynEditSearch, SynEditKeyCmds, SynEditMouseCmds, SynEditMiscProcs,
  SynEditPointClasses, SynBeautifier, SynEditMarks,
  // Markup
  SynEditMarkup, SynEditMarkupHighAll, SynEditMarkupBracket, SynEditMarkupWordGroup,
  SynEditMarkupCtrlMouseLink, SynEditMarkupSpecialLine, SynEditMarkupSelection,
  SynEditMarkupSpecialChar,
  // Lines
  SynEditTextBase, LazSynEditText, SynEditTextBuffer, SynEditLines,
  SynEditTextTrimmer, SynEditTextTabExpander, SynEditTextDoubleWidthChars,
  SynEditFoldedView,
  // Gutter
  SynGutterBase, SynGutter,
  SynEditMiscClasses, SynEditHighlighter, LazSynTextArea, SynTextDrawer,
  SynEditTextBidiChars,
  SynGutterCodeFolding, SynGutterChanges, SynGutterLineNumber, SynGutterMarks, SynGutterLineOverview;

const
  // SynDefaultFont is determined in InitSynDefaultFont()
  SynDefaultFontName:    String       = '';
  SynDefaultFontHeight:  Integer      = 13;
  SynDefaultFontSize:    Integer      = 10;
  SynDefaultFontPitch:   TFontPitch   = fpFixed;
  SynDefaultFontQuality: TFontQuality = fqNonAntialiased;

  // maximum scroll range
  MAX_SCROLL = 32767;

type
  TSynEditMarkupClass = SynEditMarkup.TSynEditMarkupClass;
  TSynReplaceAction = (raCancel, raSkip, raReplace, raReplaceAll);

  TSynDropFilesEvent = procedure(Sender: TObject; X, Y: integer; AFiles: TStrings)
    of object;

  TPaintEvent = procedure(Sender: TObject; ACanvas: TCanvas) of object;

  TChangeUpdatingEvent = procedure(ASender: TObject; AnUpdating: Boolean) of object;

  TProcessCommandEvent = procedure(Sender: TObject;
    var Command: TSynEditorCommand;
    var AChar: TUTF8Char;
    Data: pointer) of object;

  TReplaceTextEvent = procedure(Sender: TObject; const ASearch, AReplace:
    string; Line, Column: integer; var ReplaceAction: TSynReplaceAction) of object;

  TSynCopyPasteAction = (scaContinue, scaPlainText, scaAbort);
  TSynCopyPasteEvent = procedure(Sender: TObject; var AText: String;
    var AMode: TSynSelectionMode; ALogStartPos: TPoint;
    var AnAction: TSynCopyPasteAction) of object;

  TSynEditCaretType = SynEditPointClasses.TSynCaretType;

  TSynCaretAdjustMode = ( // used in TextBetweenPointsEx
    scamIgnore, // Caret stays at the same numeric values, if text is inserted before caret, the text moves, but the caret stays
    scamAdjust, // Caret moves with text. Except if it is at a selection boundary, in which case it stays with the selection (movement depends on setMoveBlock/setExtendBlock)
    scamForceAdjust, // Caret moves with text. Can be used if the caret should move away from the bound of a persistent selection
    scamEnd,
    scamBegin
  );

  (* This is used, if text is *replaced*.
     What to do with marks in text that is deleted/replaced
  *)
  TSynMarksAdjustMode = ( // used in SetTextBetweenPoints
    smaMoveUp, //
    smaKeep
    // smaDrop
  );

  TSynEditTextFlag = (
    setSelect,          // select the new text
    setPersistentBlock, // keep/move existent selection (only if not setSelect)
    setMoveBlock,       // weak persistent // see TSynBlockPersistMode
    setExtendBlock      // strong persistent // see TSynBlockPersistMode
  );
  TSynEditTextFlags = set of TSynEditTextFlag;

  TSynStateFlag = (sfCaretChanged, sfHideCursor,
    sfEnsureCursorPos, sfEnsureCursorPosAtResize, sfEnsureCursorPosForEditRight, sfEnsureCursorPosForEditLeft,
    sfExplicitTopLine, sfExplicitLeftChar,  // when doing EnsureCursorPos keep top/Left, if they where set explicitly after the caret (only applies before handle creation)
    sfPreventScrollAfterSelect,
    sfIgnoreNextChar, sfPainting, sfHasPainted, sfHasScrolled,
    sfScrollbarChanged, sfHorizScrollbarVisible, sfVertScrollbarVisible,
    sfAfterLoadFromFileNeeded,
    // Mouse-states
    sfLeftGutterClick, sfRightGutterClick,
    sfInClick, sfDblClicked, sfTripleClicked, sfQuadClicked,
    sfWaitForDragging, sfWaitForDraggingNoCaret, sfIsDragging, sfWaitForMouseSelecting, sfMouseSelecting, sfMouseDoneSelecting,
    sfIgnoreUpClick,
    sfSelChanged
    );                                           //mh 2000-10-30
  TSynStateFlags = set of TSynStateFlag;

  TSynEditorMouseOption = SynEditMouseCmds.TSynEditorMouseOption;
    //emUseMouseActions          // Enable mouse actions
    //emAltSetsColumnMode        // Allows to activate "column" selection mode, if <Alt> key is pressed and text is being selected with mouse
    //emDragDropEditing          // Allows to drag-and-drop text blocks within the control
    //emRightMouseMovesCursor    // When clicking with the right mouse button, for a popup menu, move the caret to clicked position
    //emDoubleClickSelectsLine   // Selects entire line with double-click, otherwise double-click selects only current word
    //emShowCtrlMouseLinks       // Pressing <Ctrl> key (SYNEDIT_LINK_MODIFIER) will highlight the word under mouse cursor
    //emCtrlWheelZoom            // Allows to zoom editor by <Ctrl+MouseWheel> commands
  TSynEditorMouseOptions = SynEditMouseCmds.TSynEditorMouseOptions;

  // options for textbuffersharing
  TSynEditorShareOption = (
    eosShareMarks              // Shared Editors use the same list of marks
  );
  TSynEditorShareOptions = set of TSynEditorShareOption;

  TSynVisibleSpecialChars = SynEditTypes.TSynVisibleSpecialChars;

const
  SYNEDIT_OLD_MOUSE_OPTIONS = [
    eoAltSetsColumnMode,       //
    eoDragDropEditing,         // Allows you to select a block of text and drag it within the document to another location
    eoRightMouseMovesCursor,   // When clicking with the right mouse for a popup menu, move the cursor to that location
    eoDoubleClickSelectsLine,  // Select line on double click
    eoShowCtrlMouseLinks       // Pressing Ctrl (SYNEDIT_LINK_MODIFIER) will highlight the word under the mouse cursor
  ];

  SYNEDIT_OLD_MOUSE_OPTIONS_MAP: array [eoAltSetsColumnMode..eoShowCtrlMouseLinks] of TSynEditorMouseOption = (
    emAltSetsColumnMode,       // eoAltSetsColumnMode
    emDragDropEditing,         // eoDragDropEditing
    emRightMouseMovesCursor,   // eoRightMouseMovesCursor
    emDoubleClickSelectsLine,  // eoDoubleClickSelectsLine
    emShowCtrlMouseLinks       // eoShowCtrlMouseLinks
  );

  SYNEDIT_DEFAULT_SHARE_OPTIONS = [
    eosShareMarks
  ];

  SYNEDIT_DEFAULT_VISIBLESPECIALCHARS = [
    vscSpace,
    vscTabAtLast
  ];

type
// use scAll to update a statusbar when another TCustomSynEdit got the focus
  TSynStatusChange = SynEditTypes.TSynStatusChange;
  TSynStatusChanges = SynEditTypes.TSynStatusChanges;
  TStatusChangeEvent = SynEditTypes.TStatusChangeEvent;

  TCustomSynEdit = class;


  { TLazSynEditPlugin }

  TLazSynEditPlugin = class(TSynEditFriend)
  protected
    procedure BeforeEditorChange; virtual;
    procedure AfterEditorChange; virtual;
    procedure RegisterToEditor(AValue: TCustomSynEdit);
    procedure UnRegisterFromEditor(AValue: TCustomSynEdit);
    procedure SetEditor(const AValue: TCustomSynEdit); virtual;
    function  GetEditor: TCustomSynEdit;
    function  OwnedByEditor: Boolean; virtual; // if true, this will be destroyed by synedit
    procedure DoEditorDestroyed(const AValue: TCustomSynEdit); virtual;

    procedure DoEditorAdded(AValue: TCustomSynEdit); virtual;
    procedure DoEditorRemoving(AValue: TCustomSynEdit); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Editor: TCustomSynEdit read GetEditor write SetEditor;
  end;

  { TSynHookedKeyTranslationList }

  TSynHookedKeyTranslationList = Class(TMethodList)
  public
    procedure CallHookedKeyTranslationHandlers(Sender: TObject;
      Code: word; SState: TShiftState; var Data: pointer;
      var IsStartOfCombo: boolean; var Handled: boolean;
      var Command: TSynEditorCommand;
      // ComboKeyStrokes decides, either FinishComboOnly, or new stroke
      var ComboKeyStrokes: TSynEditKeyStrokes
    );
  end;

  { TSynUndoRedoItemHandlerList }

  TSynUndoRedoItemHandlerList = Class(TMethodList)
  public
    function CallUndoRedoItemHandlers(Caller: TObject; Item: TSynEditUndoItem): Boolean;
  end;

  { TLazSynMouseDownEventList }

  TLazSynMouseDownEventList = Class(TMethodList)
  public
    procedure CallMouseDownHandlers(Sender: TObject; Button: TMouseButton;
                                    Shift: TShiftState; X, Y: Integer);
  end;

  { TLazSynKeyDownEventList }

  TLazSynKeyDownEventList = Class(TMethodList)
  public
    procedure CallKeyDownHandlers(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

  { TLazSynKeyPressEventList }

  TLazSynKeyPressEventList = Class(TMethodList)
  public
    procedure CallKeyPressHandlers(Sender: TObject; var Key: char);
  end;

  { TLazSynUtf8KeyPressEventList }

  TLazSynUtf8KeyPressEventList = Class(TMethodList)
  public
    procedure CallUtf8KeyPressHandlers(Sender: TObject; var UTF8Key: TUTF8Char);
  end;


  TSynMouseLinkEvent = procedure (
    Sender: TObject; X, Y: Integer; var AllowMouseLink: Boolean) of object;

  TSynHomeMode = (synhmDefault, synhmFirstWord);

  TSynCoordinateMappingFlag = SynEditTypes.TSynCoordinateMappingFlag;
  TSynCoordinateMappingFlags = SynEditTypes.TSynCoordinateMappingFlags;

  TLazSynWordBoundary = (
    swbWordBegin,
    swbWordEnd,
    swbTokenBegin,
    swbTokenEnd,
    swbCaseChange,
    swbWordSmart // begin or end of word with smart gaps (1 char)
  );

  { TSynScrollOnEditOptions }

  TSynScrollOnEditOptions = class(TPersistent)
  private
    FKeepBorderDistance: integer;
    FKeepBorderDistancePercent: integer;
    FOnChange: TNotifyEvent;
    FScrollExtraColumns: integer;
    FScrollExtraMax: integer;
    FScrollExtraPercent: integer;
    procedure SetKeepBorderDistance(AValue: integer);
    procedure SetKeepBorderDistancePercent(AValue: integer);
    procedure SetScrollExtraColumns(AValue: integer);
    procedure SetScrollExtraMax(AValue: integer);
    procedure SetScrollExtraPercent(AValue: integer);
  protected
    FCurrentDistance: integer;
    FCurrentColumns: integer;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure SetDefaults; virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property KeepBorderDistance: integer read FKeepBorderDistance write SetKeepBorderDistance;
    property KeepBorderDistancePercent: integer read FKeepBorderDistancePercent write SetKeepBorderDistancePercent;
    property ScrollExtraColumns: integer read FScrollExtraColumns write SetScrollExtraColumns;
    property ScrollExtraPercent: integer read FScrollExtraPercent write SetScrollExtraPercent;
    property ScrollExtraMax: integer read FScrollExtraMax write SetScrollExtraMax;
  end;

  { TSynScrollOnEditLeftOptions }

  TSynScrollOnEditLeftOptions = class(TSynScrollOnEditOptions)
  private const
    CKeepBorderDistance        = 2;
    CKeepBorderDistancePercent = 0;
    CScrollExtraColumns        = 5;
    CScrollExtraPercent        = 20;
    CScrollExtraMax            = 10;
  public
    procedure SetDefaults; override;
  published
    property KeepBorderDistance        default CKeepBorderDistance;
    property KeepBorderDistancePercent default CKeepBorderDistancePercent;
    property ScrollExtraColumns        default CScrollExtraColumns;
    property ScrollExtraPercent        default CScrollExtraPercent;
    property ScrollExtraMax            default CScrollExtraMax;
  end;

  { TSynScrollOnEditRightOptions }

  TSynScrollOnEditRightOptions = class(TSynScrollOnEditOptions)
  private const
    CKeepBorderDistance        = 0;
    CKeepBorderDistancePercent = 0;
    CScrollExtraColumns        = 10;
    CScrollExtraPercent        = 30;
    CScrollExtraMax            = 25;
  public
    procedure SetDefaults; override;
  published
    property KeepBorderDistance        default CKeepBorderDistance;
    property KeepBorderDistancePercent default CKeepBorderDistancePercent;
    property ScrollExtraColumns        default CScrollExtraColumns;
    property ScrollExtraPercent        default CScrollExtraPercent;
    property ScrollExtraMax            default CScrollExtraMax;
  end;

  { TCustomSynEdit }

  TCustomSynEdit = class(TSynEditBase)
    procedure SelAvailChange(Sender: TObject);
  private
    FImeHandler: LazSynIme;
  {$IFDEF Gtk2IME}
  protected
    procedure GTK_IMComposition(var Message: TMessage); message LM_IM_COMPOSITION;
  {$ENDIF}
  {$IFDEF WinIME}
  private
    procedure WMImeRequest(var Msg: TMessage); message WM_IME_REQUEST;
    procedure WMImeNotify(var Msg: TMessage); message WM_IME_NOTIFY;
    procedure WMImeStartComposition(var Msg: TMessage); message WM_IME_STARTCOMPOSITION;
    procedure WMImeComposition(var Msg: TMessage); message WM_IME_COMPOSITION;
    procedure WMImeEndComposition(var Msg: TMessage); message WM_IME_ENDCOMPOSITION;
  {$ENDIF}
  private
    procedure SetImeHandler(AValue: LazSynIme);
  protected
    // SynEdit takes ownership
    property ImeHandler: LazSynIme read FImeHandler write SetImeHandler;
  private
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure WMEraseBkgnd(var Msg: TMessage); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Msg: TLMScroll); message WM_HSCROLL;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMExit(var Message: TLMExit); message LM_EXIT;
    procedure WMMouseWheel(var Message: TLMMouseEvent); message LM_MOUSEWHEEL;
    procedure WMMouseHorizWheel(var Message: TLMMouseEvent); message LM_MOUSEHWHEEL;
    //procedure WMMouseWheel(var Msg: TMessage); message WM_MOUSEWHEEL;
    procedure WMSetFocus(var Msg: TLMSetFocus); message WM_SETFOCUS;
    procedure WMVScroll(var Msg: TLMScroll); message WM_VSCROLL;
  protected
    procedure CMWantSpecialKey(var Message: TLMessage); message CM_WANTSPECIALKEY;
  private
    FScrollOnEditLeftOptions: TSynScrollOnEditOptions;
    FScrollOnEditRightOptions: TSynScrollOnEditOptions;
    FTextCursor, FOffTextCursor, FOverrideCursor: TCursor;
    FBlockIndent: integer;
    FBlockTabIndent: integer;
    FCaret: TSynEditCaret;
    FInternalCaret: TSynEditCaret;
    //FScreenCaret: TSynEditScreenCaret;
    FInternalBlockSelection: TSynEditSelection;
    FLastCaretXForMoveSelection: Integer;
    FOnChangeUpdating: TChangeUpdatingEvent;
    FMouseSelectionMode: TSynSelectionMode;
    FMouseSelectionCmd: TSynEditorMouseCommand;
    fMarkupManager : TSynEditMarkupManager;
    fMarkupHighAll : TSynEditMarkupHighlightAll;
    fMarkupHighCaret : TSynEditMarkupHighlightAllCaret;
    fMarkupBracket : TSynEditMarkupBracket;
    fMarkupWordGroup : TSynEditMarkupWordGroup;
    fMarkupCtrlMouse : TSynEditMarkupCtrlMouseLink;
    fMarkupSpecialLine : TSynEditMarkupSpecialLine;
    fMarkupSelection : TSynEditMarkupSelection;
    fMarkupSpecialChar : TSynEditMarkupSpecialChar;
    fFontDummy: TFont;
    FLastSetFontSize: Integer;
    fInserting: Boolean;
    FLastMouseLocation: TSynMouseLocationInfo;
    FChangedLinesStart: integer; // 1 based, 0 means invalid
    FChangedLinesEnd: integer; // 1 based, 0 means invalid, -1 means rest of screen
    FChangedLinesDiff: integer; // count changed +/-
    FBeautifier, FDefaultBeautifier: TSynCustomBeautifier;
    FBeautifyStartLineIdx, FBeautifyEndLineIdx: Integer;

    FFoldedLinesView:  TSynEditFoldedView;
    FShareOptions: TSynEditorShareOptions;
    FVisibleSpecialChars: TSynVisibleSpecialChars;
    FTextViewsManager: TSynTextViewsManager;
    FTrimmedLinesView: TSynEditStringTrimmingList;
    FDoubleWidthChrLinesView: SynEditStringDoubleWidthChars;
    FBidiChrLinesView: TSynEditStringBidiChars;
    {$IFDEF WithSynExperimentalCharWidth}
    FSysCharWidthLinesView: TSynEditStringSystemWidthChars;
    {$ENDIF}
    FTabbedLinesView:  TSynEditStringTabExpander;
    FTheLinesView: TSynEditStringsLinked;
    FLines: TSynEditStringListBase;          // The real (un-mapped) line-buffer
    FStrings: TStrings;               // External TStrings based interface to the Textbuffer

    fMaxLeftChar: Integer; // 1024
    FOldWidth, FOldHeight: Integer;

    FPaintLock: Integer;
    FPaintLockOwnerCnt: Integer;
    FUndoBlockAtPaintLock: Integer;
    FStatusChangeLock: Integer;
    FRecalcCharsAndLinesLock: Integer;
    FScrollBarUpdateLock: Integer;
    FInvalidateRect: TRect;
    FIsInDecPaintLock: Boolean;
    FScrollBars: TScrollStyle;
    FOldTopView: Integer;
    FLastTextChangeStamp: Int64;
    fHighlighter: TSynCustomHighlighter;
    fUndoList: TSynEditUndoList;
    fRedoList: TSynEditUndoList;
    FBookMarks: array[0..9] of TSynEditMark;
    fMouseDownX: integer;
    fMouseDownY: integer;
    FMouseDownButton: TMouseButton;
    FMouseDownShift: TShiftState;
    FConfirmMouseDownMatchAct: TSynEditMouseAction;
    FConfirmMouseDownMatchFound: Boolean;
    FMouseWheelAccumulator, FMouseWheelLinesAccumulator: Array [Boolean] of integer;
    fOverwriteCaret: TSynEditCaretType;
    fInsertCaret: TSynEditCaretType;
    FKeyStrokes: TSynEditKeyStrokes;
    FCurrentComboKeyStrokes: TSynEditKeyStrokes; // Holding info about the keystroke(s) already received for a mult-stroke-combo
    FMouseActions, FMouseSelActions, FMouseTextActions: TSynEditMouseInternalActions;
    FMouseActionSearchHandlerList: TSynEditMouseActionSearchList;
    FMouseActionExecHandlerList: TSynEditMouseActionExecList;
    FMarkList: TSynEditMarkList;
    FUseUTF8: boolean;
    fWantTabs: boolean;
    FLeftGutter, FRightGutter: TSynGutter;
    fTabWidth: integer;
    fTextDrawer: TheTextDrawer;
    FPaintLineColor, FPaintLineColor2: TSynSelectedColor;
    fStateFlags: TSynStateFlags;
    fStatusChanges: TSynStatusChanges;
    fTSearch: TSynEditSearch;
    fHookedCommandHandlers: TList;
    FHookedKeyTranslationList: TSynHookedKeyTranslationList;
    FUndoRedoItemHandlerList: TSynUndoRedoItemHandlerList;
    FMouseDownEventList: TLazSynMouseDownEventList;
    FQueryMouseCursorList: TObject;
    FKeyDownEventList: TLazSynKeyDownEventList;
    FKeyUpEventList: TLazSynKeyDownEventList;
    FKeyPressEventList: TLazSynKeyPressEventList;
    FUtf8KeyPressEventList: TLazSynUtf8KeyPressEventList;
    FStatusChangedList: TObject;
    FPaintEventHandlerList: TObject; // TSynPaintEventHandlerList
    FScrollEventHandlerList: TObject; // TSynScrollEventHandlerList
    FPlugins: TList;
    fScrollTimer: TTimer;
    FScrollDeltaX, FScrollDeltaY: Integer;
    FInMouseClickEvent: Boolean;
    // event handlers
    FOnCutCopy: TSynCopyPasteEvent;
    FOnPaste: TSynCopyPasteEvent;
    fOnChange: TNotifyEvent;
    FOnClearMark: TPlaceMarkEvent;                                              // djlp 2000-08-29
    fOnCommandProcessed: TProcessCommandEvent;
    fOnDropFiles: TSynDropFilesEvent;
    fOnPaint: TPaintEvent;
    FOnPlaceMark: TPlaceMarkEvent;
    fOnProcessCommand: TProcessCommandEvent;
    fOnProcessUserCommand: TProcessCommandEvent;
    fOnReplaceText: TReplaceTextEvent;
    fOnSpecialLineColors: TSpecialLineColorsEvent;// needed, because bug fpc 11926
    fOnStatusChange: TStatusChangeEvent;
    FOnSpecialLineMarkup: TSpecialLineMarkupEvent;// needed, because bug fpc 11926
    FOnClickLink: TMouseEvent;
    FOnMouseLink: TSynMouseLinkEvent;
    FPendingFoldState: String;

    procedure DoTopViewChanged(Sender: TObject);
    procedure SetScrollOnEditLeftOptions(AValue: TSynScrollOnEditOptions);
    procedure SetScrollOnEditRightOptions(AValue: TSynScrollOnEditOptions);
    procedure UpdateScreenCaret;
    procedure AquirePrimarySelection;
    function GetChangeStamp: int64;
    function GetDefSelectionMode: TSynSelectionMode;
    function GetFoldedCodeLineColor: TSynSelectedColor;
    function GetFoldState: String;
    function GetHiddenCodeLineColor: TSynSelectedColor;
    function GetPaintLockOwner: TSynEditBase;
    function GetPlugin(Index: Integer): TLazSynEditPlugin;
    function GetRightEdge: Integer;
    function GetRightEdgeColor: TColor;
    function GetTextBetweenPoints(aStartPoint, aEndPoint: TPoint): String;
    procedure SetBlockTabIndent(AValue: integer);
    procedure SetBracketMatchColor(AValue: TSynSelectedColor);
    procedure SetTextCursor(AValue: TCursor);
    procedure SetDefSelectionMode(const AValue: TSynSelectionMode);
    procedure SetFoldedCodeColor(AValue: TSynSelectedColor);
    procedure SetFoldedCodeLineColor(AValue: TSynSelectedColor);
    procedure SetFoldState(const AValue: String);
    procedure SetHiddenCodeLineColor(AValue: TSynSelectedColor);
    procedure SetHighlightAllColor(AValue: TSynSelectedColor);
    procedure SetIncrementColor(AValue: TSynSelectedColor);
    procedure SetLineHighlightColor(AValue: TSynSelectedColor);
    procedure SetMouseLinkColor(AValue: TSynSelectedColor);
    procedure SetOffTextCursor(AValue: TCursor);
    procedure SetPaintLockOwner(const AValue: TSynEditBase);
    procedure SetShareOptions(const AValue: TSynEditorShareOptions);
    procedure SetTextBetweenPointsSimple(aStartPoint, aEndPoint: TPoint; const AValue: String);
    procedure SetTextBetweenPointsEx(aStartPoint, aEndPoint: TPoint;
      aCaretMode: TSynCaretAdjustMode; const AValue: String);
    procedure SetVisibleSpecialChars(AValue: TSynVisibleSpecialChars);
    procedure SurrenderPrimarySelection;
    procedure ComputeCaret(X, Y: Integer);
    procedure DoBlockIndent;
    procedure DoBlockUnindent;
    procedure DoHomeKey(aMode: TSynHomeMode = synhmDefault);
    procedure DoEndKey;
    procedure DoTabKey;
    function FindHookedCmdEvent(AHandlerProc: THookedCommandEvent): integer;
    function GetBracketHighlightStyle: TSynEditBracketHighlightStyle;
    function GetCanPaste: Boolean;
    function GetFoldedCodeColor: TSynSelectedColor;
    function GetMarkup(Index: integer): TSynEditMarkup;
    function GetMarkupByClass(Index: TSynEditMarkupClass): TSynEditMarkup;
    function GetCaretUndo: TSynEditUndoItem;
    function GetHighlightAllColor : TSynSelectedColor;
    function GetIncrementColor : TSynSelectedColor;
    function GetLineHighlightColor: TSynSelectedColor;
    function GetOnGutterClick : TGutterClickEvent;
    function GetBracketMatchColor : TSynSelectedColor;
    function GetMouseLinkColor : TSynSelectedColor;
    function GetTrimSpaceType: TSynEditStringTrimmingType;
    procedure SetBracketHighlightStyle(const AValue: TSynEditBracketHighlightStyle);
    procedure SetOnGutterClick(const AValue : TGutterClickEvent);
    procedure SetSpecialLineColors(const AValue : TSpecialLineColorsEvent);
    procedure SetSpecialLineMarkup(const AValue : TSpecialLineMarkupEvent);
    function GetHookedCommandHandlersCount: integer;
    function GetLineText: string;
    function GetCharLen(const Line: string; CharStartPos: integer): integer; // TODO: deprecated
    procedure SetBeautifier(NewBeautifier: TSynCustomBeautifier);
    function GetMaxUndo: Integer;
    procedure SetTrimSpaceType(const AValue: TSynEditStringTrimmingType);
    function SynGetText: string;
    procedure GutterChanged(Sender: TObject);
    procedure GutterResized(Sender: TObject);
    // x-pixel pos of first char on canvas
    function  TextLeftPixelOffset(IncludeGutterTextDist: Boolean = True): Integer;
    function  TextRightPixelOffset: Integer;
    function IsPointInSelection(Value: TPoint; AnIgnoreAtSelectionBound: Boolean = False): boolean;
    procedure LockUndo;
    procedure MoveCaretHorz(DX: integer);
    procedure MoveCaretVert(DY: integer; UseScreenLine: Boolean = False);
    procedure PrimarySelectionRequest(const RequestedFormatID: TClipboardFormat;
      Data: TStream);
    procedure ScanRanges(ATextChanged: Boolean = True);
    procedure IdleScanRanges(Sender: TObject; var Done: Boolean);
    procedure DoBlockSelectionChanged(Sender: TObject);
    procedure SetBlockIndent(const AValue: integer);
    procedure SetCaretAndSelection(const ptCaret, ptBefore, ptAfter: TPoint;
                                   Mode: TSynSelectionMode = smCurrent;
                                   MakeSelectionVisible: Boolean = False
                                   );
    procedure SetGutter(const Value: TSynGutter);
    procedure SetRightGutter(const AValue: TSynGutter);
    procedure RemoveHooksFromHighlighter;
    procedure SetInsertCaret(const Value: TSynEditCaretType);
    procedure SetInsertMode(const Value: boolean);
    procedure SetKeystrokes(const Value: TSynEditKeyStrokes);
    procedure SetLastMouseCaret(const AValue: TPoint);
    function  CurrentMaxLeftChar: Integer;
    function  CurrentMaxLineLen: Integer;
    procedure SetLineText(Value: string);
    procedure SetMaxLeftChar(Value: integer);
    procedure SetMaxUndo(const Value: Integer);
    procedure UpdateOptions;
    procedure UpdateOptions2;
    procedure UpdateMouseOptions;
    procedure SetOverwriteCaret(const Value: TSynEditCaretType);
    procedure SetRightEdge(Value: Integer);
    procedure SetRightEdgeColor(Value: TColor);
    procedure SetScrollBars(const Value: TScrollStyle);
    function  GetSelectionMode : TSynSelectionMode;
    procedure SetSelectionMode(const Value: TSynSelectionMode);
    procedure SetTabWidth(Value: integer);
    procedure SynSetText(const Value: string);
    function  CurrentMaxTopView: Integer;
    procedure ScrollAfterTopLineChanged;
    procedure SetWantTabs(const Value: boolean);
    procedure SetWordBlock(Value: TPoint);
    procedure SetLineBlock(Value: TPoint; WithLeadSpaces: Boolean = True);
    procedure SetParagraphBlock(Value: TPoint);
    procedure RecalcScrollOnEdit(Sender: TObject);
    procedure RecalcCharsAndLinesInWin(CheckCaret: Boolean);
    procedure StatusChangedEx(Sender: TObject; Changes: TSynStatusChanges);
    procedure UndoRedoAdded(Sender: TObject);
    procedure ModifiedChanged(Sender: TObject);
    procedure UnlockUndo;
    procedure UpdateCaret(IgnorePaintLock: Boolean = False);
    procedure UpdateScrollBars;
    procedure ChangeTextBuffer(NewBuffer: TSynEditStringList);
    function  IsMarkListShared: Boolean;
    procedure RecreateMarkList;
    procedure DestroyMarkList;
    procedure ExtraLineCharsChanged(Sender: TObject);
    procedure InternalBeginUndoBlock(aList: TSynEditUndoList = nil); // includes paintlock
    procedure InternalEndUndoBlock(aList: TSynEditUndoList = nil);
  protected
    FScreenCaretPainterClass: TSynEditScreenCaretPainterClass deprecated 'need refactor';
    {$IFDEF EnableDoubleBuf}
    BufferBitmap: TBitmap; // the double buffer
    SavedCanvas: TCanvas; // the normal TCustomControl canvas during paint
    {$ENDIF}
    FTextArea: TLazSynTextArea;
    FLeftGutterArea, FRightGutterArea: TLazSynGutterArea;
    FPaintArea: TLazSynSurfaceManager;
    property ScreenCaret: TSynEditScreenCaret read FScreenCaret;
    property OnClickLink : TMouseEvent read FOnClickLink write FOnClickLink;
    property OnMouseLink: TSynMouseLinkEvent read FOnMouseLink write FOnMouseLink;

    procedure Paint; override;
    procedure StartPaintBuffer(const ClipRect: TRect);
    procedure EndPaintBuffer(const ClipRect: TRect);
    procedure DoOnPaint; virtual;
    function GetPaintArea: TLazSynSurfaceManager; override;

    procedure IncPaintLock;
    procedure DecPaintLock;
    procedure DoIncPaintLock(Sender: TObject);
    procedure DoDecPaintLock(Sender: TObject);
    procedure DoIncForeignPaintLock(Sender: TObject);
    procedure DoDecForeignPaintLock(Sender: TObject);
    procedure SetUpdateState(NewUpdating: Boolean; Sender: TObject); virtual;      // Called *before* paintlock, and *after* paintlock
    procedure IncStatusChangeLock;
    procedure DecStatusChangeLock;
    procedure StatusChanged(AChanges: TSynStatusChanges); override;

    property PaintLockOwner: TSynEditBase read GetPaintLockOwner write SetPaintLockOwner;
    property TextDrawer: TheTextDrawer read fTextDrawer;

    procedure DoAutoAdjustLayout(const AMode: TLayoutAdjustmentPolicy;
      const AXProportion, AYProportion: Double); override;
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure VisibleChanged; override;
    procedure Loaded; override;
    function  GetChildOwner: TComponent; override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure UTF8KeyPress(var Key: TUTF8Char); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key : Word; Shift : TShiftState); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y:
      Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure ScrollTimerHandler(Sender: TObject);
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    procedure FindAndHandleMouseAction(AButton: TSynMouseButton; AShift: TShiftState;
                                X, Y: Integer; ACCount:TSynMAClickCount;
                                ADir: TSynMAClickDir;
                                out AnActionResult: TSynEditMouseActionResult;
                                AWheelDelta: Integer = 0);
    function DoHandleMouseAction(AnActionList: TSynEditMouseActions;
                                 var AnInfo: TSynEditMouseActionInfo): Boolean;
    procedure DoHandleMouseActionResult(AnActionResult: TSynEditMouseActionResult);
    function CheckDragDropAccecpt(ANewCaret: TPoint; ASource: TObject; out ADropMove: boolean): boolean;

  protected
    function GetBlockBegin: TPoint; override;
    function GetBlockEnd: TPoint; override;
    procedure SetBlockBegin(Value: TPoint); override;
    procedure SetBlockEnd(Value: TPoint); override;
    function GetCharsInWindow: Integer; override;
    function GetCharWidth: integer; override;
    function GetLeftChar: Integer; override;
    function GetLineHeight: integer; override;
    function GetLinesInWindow: Integer; override;
    function GetTopLine: Integer; override;
    procedure SetLeftChar(Value: Integer); override;
    procedure SetTopLine(Value: Integer); override;

    function GetCaretX : Integer; override;
    function GetCaretY : Integer; override;
    function GetCaretXY: TPoint; override;
    procedure SetCaretX(const Value: Integer); override;
    procedure SetCaretY(const Value: Integer); override;
    procedure SetCaretXY(Value: TPoint); override;
    function GetLogicalCaretXY: TPoint; override;
    procedure SetLogicalCaretXY(const NewLogCaretXY: TPoint); override;

    function GetMouseActions: TSynEditMouseActions; override;
    function GetMouseSelActions: TSynEditMouseActions; override;
    function GetMouseTextActions: TSynEditMouseActions; override;
    procedure SetMouseActions(const AValue: TSynEditMouseActions); override;
    procedure SetMouseSelActions(const AValue: TSynEditMouseActions); override;
    procedure SetMouseTextActions(AValue: TSynEditMouseActions); override;

    procedure SetExtraCharSpacing(const Value: integer); override;
    procedure SetExtraLineSpacing(const Value: integer); override;

    procedure SetHighlighter(const Value: TSynCustomHighlighter); virtual;
    procedure UpdateShowing; override;
    procedure SetColor(Value: TColor); override;
    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
    procedure DoOnResize; override;
    procedure CalculatePreferredSize(var PreferredWidth,
      PreferredHeight: integer; WithThemeSpace: Boolean); override;
    function  RealGetText: TCaption; override;
    procedure RealSetText(const Value: TCaption); override;
    function GetLines: TStrings; override;
    function GetModified: Boolean; override;
    function GetViewedTextBuffer: TSynEditStringsLinked; override;
    function GetFoldedTextBuffer: TObject; override;
    function GetTextBuffer: TSynEditStrings; override;
    procedure SetLines(Value: TStrings);  override;
    function GetMarkupMgr: TObject; override;
    function GetCanRedo: Boolean; override;
    function GetCanUndo: Boolean; override;
    function GetCaretObj: TSynEditCaret; override;
    function GetHighlighterObj: TObject; override;
    function GetMarksObj: TObject; override;
    function GetSelectedColor : TSynSelectedColor; override;
    function GetTextViewsManager: TSynTextViewsManager; override;
    procedure FontChanged(Sender: TObject); override;
    procedure HighlighterAttrChanged(Sender: TObject);
    Procedure LineCountChanged(Sender: TSynEditStrings; AIndex, ACount : Integer);
    Procedure LineTextChanged(Sender: TSynEditStrings; AIndex, ACount : Integer);
    procedure SizeOrFontChanged(bFont: boolean);
    procedure DoHighlightChanged(Sender: TSynEditStrings; AIndex, ACount : Integer);
    procedure ListCleared(Sender: TObject);
    procedure FoldChanged(Sender: TSynEditStrings; aIndex, aCount: Integer);
    function  GetTopView : Integer;
    procedure SetTopView(AValue : Integer);
    procedure MarkListChange(Sender: TSynEditMark; Changes: TSynEditMarkChangeReasons);
    procedure NotifyHookedCommandHandlers(var Command: TSynEditorCommand;
      var AChar: TUTF8Char; Data: pointer; ATime: THookedCommandFlag); virtual;
    function NextWordLogicalPos(ABoundary: TLazSynWordBoundary = swbWordBegin; WordEndForDelete : Boolean = false): TPoint;
    function PrevWordLogicalPos(ABoundary: TLazSynWordBoundary = swbWordBegin): TPoint;
    procedure RecalcCharExtent;
    procedure RedoItem(Item: TSynEditUndoItem);
    procedure CaretChanged(Sender: TObject);
    procedure SetModified(Value: boolean); override;
    procedure SetMouseOptions(AValue: TSynEditorMouseOptions); override;
    procedure SetName(const Value: TComponentName); override;
    procedure SetOptions(Value: TSynEditorOptions); override;
    procedure SetOptions2(Value: TSynEditorOptions2); override;
    procedure SetSelectedColor(const AValue : TSynSelectedColor); override;
    procedure SetSelTextExternal(const Value: string); override;
    procedure SetSelTextPrimitive(PasteMode: TSynSelectionMode; Value: PChar;
      AddToUndoList: Boolean = false);
    procedure UndoItem(Item: TSynEditUndoItem);
    procedure UpdateCursor;
    procedure DoOnCommandProcessed(Command: TSynEditorCommand;
      AChar: TUTF8Char;
      Data: pointer); virtual;
    // no method DoOnDropFiles, intercept the WM_DROPFILES instead
    procedure DoOnProcessCommand(var Command: TSynEditorCommand;
      var AChar: TUTF8Char;
      Data: pointer); virtual;
    function DoOnReplaceText(const ASearch, AReplace: string;
      Line, Column: integer): TSynReplaceAction; virtual;
    procedure DoOnStatusChange(Changes: TSynStatusChanges); virtual;
    property LastMouseCaret: TPoint read FLastMouseLocation.LastMouseCaret write SetLastMouseCaret; // TODO: deprecate? see MouseMove
    function GetSelEnd: integer; override;                                                //L505
    function GetSelStart: integer; override;
    procedure SetSelEnd(const Value: integer); override;
    procedure SetSelStart(const Value: integer); override;
    property TextView : TSynEditStringsLinked read FTheLinesView;
    property TopView: Integer read GetTopView write SetTopView;  // TopLine converted into Visible(View) lines
    function PasteFromClipboardEx(ClipHelper: TSynClipboardStream; AForceColumnMode: Boolean = False): Boolean;
    function FindNextUnfoldedLine(iLine: integer; Down: boolean): Integer;
    // Todo: Reduce the argument list of Creategutter
    function CreateGutter(AOwner : TSynEditBase; ASide: TSynGutterSide;
                          ATextDrawer: TheTextDrawer): TSynGutter; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterLoadFromFile;

    procedure BeginUndoBlock{$IFDEF SynUndoDebugBeginEnd}(ACaller: String = ''){$ENDIF}; override;
    procedure BeginUpdate(WithUndoBlock: Boolean = True); override;
    procedure EndUndoBlock{$IFDEF SynUndoDebugBeginEnd}(ACaller: String = ''){$ENDIF}; override;
    procedure EndUpdate; override;

  public
    // Caret
    function CaretXPix: Integer; override;
    function CaretYPix: Integer; override;
    procedure EnsureCursorPosVisible;
    procedure MoveCaretToVisibleArea;
    procedure MoveCaretIgnoreEOL(const NewCaret: TPoint);
    procedure MoveLogicalCaretIgnoreEOL(const NewLogCaret: TPoint);

    // Selection
    procedure ClearSelection;
    procedure SelectAll;
    procedure SelectToBrace;
    procedure SelectWord;
    procedure SelectLine(WithLeadSpaces: Boolean = True);
    procedure SelectParagraph;

    property BlockBegin: TPoint read GetBlockBegin write SetBlockBegin;         // Set Blockbegin. For none persistent also sets Blockend. Setting Caret may undo this and should be done before setting block
    property BlockEnd: TPoint read GetBlockEnd write SetBlockEnd;
    property SelStart: Integer read GetSelStart write SetSelStart;              // 1-based byte pos of first selected char
    property SelEnd: Integer read GetSelEnd write SetSelEnd;                    // 1-based byte pos of first char after selction end
    property IsBackwardSel: Boolean read GetIsBackwardSel;
    property SelText: string read GetSelText write SetSelTextExternal;

    // Text Raw (not undo-able)
    procedure Clear;
    procedure Append(const Value: String);
    property LineText: string read GetLineText write SetLineText;               // textline at CaretY
    property Text: string read SynGetText write SynSetText;                     // No uncommited (trailing/trimmable) spaces

    // Text (unho-able)
    procedure ClearAll;
    procedure InsertTextAtCaret(aText: String; aCaretMode : TSynCaretAdjustMode = scamEnd);

    property TextBetweenPoints[aStartPoint, aEndPoint: TPoint]: String              // Logical Points
      read GetTextBetweenPoints write SetTextBetweenPointsSimple;
    property TextBetweenPointsEx[aStartPoint, aEndPoint: TPoint; CaretMode: TSynCaretAdjustMode]: String
      write SetTextBetweenPointsEx;
    procedure SetTextBetweenPoints(aStartPoint, aEndPoint: TPoint;
                                   const AValue: String;
                                   aFlags: TSynEditTextFlags = [];
                                   aCaretMode: TSynCaretAdjustMode = scamIgnore;
                                   aMarksMode: TSynMarksAdjustMode = smaMoveUp;
                                   aSelectionMode: TSynSelectionMode = smNormal
                                  );


    function GetLineState(ALine: Integer): TSynLineState; override;
    procedure MarkTextAsSaved;

    // BoorMark
    procedure ClearBookMark(BookMark: Integer);
    function  GetBookMark(BookMark: integer; var X, Y: integer): boolean;
    procedure GotoBookMark(BookMark: Integer);
    function  IsBookmark(BookMark: integer): boolean;
    procedure SetBookMark(BookMark: Integer; X: Integer; Y: Integer);
    property Marks: TSynEditMarkList read fMarkList;

    // Undo/Redo
    procedure ClearUndo; override;
    procedure Redo; override;
    procedure Undo; override;

    // Clipboard
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard(AForceColumnMode: Boolean = False);
    procedure DoCopyToClipboard(SText: string; FoldInfo: String = '');
    property CanPaste: Boolean read GetCanPaste;

    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    function ExecuteAction(ExeAction: TBasicAction): boolean; override;
    procedure CommandProcessor(Command:TSynEditorCommand;
      AChar: TUTF8Char;
      Data:pointer;
      ASkipHooks: THookedCommandFlags = []); virtual;
    procedure ExecuteCommand(Command: TSynEditorCommand;
      const AChar: TUTF8Char; Data: pointer); virtual;

    function GetHighlighterAttriAtRowCol(XY: TPoint; out Token: string;
      out Attri: TSynHighlighterAttributes): boolean;
    function GetHighlighterAttriAtRowColEx(XY: TPoint; out Token: string;
      out TokenType, Start: Integer;
      out Attri: TSynHighlighterAttributes): boolean;                           //L505
    procedure CaretAtIdentOrString(XY: TPoint; out AtIdent, NearString: Boolean);
    procedure GetWordBoundsAtRowCol(const XY: TPoint; out StartX, EndX: integer); override;
    function GetWordAtRowCol(XY: TPoint): string; override;
    function NextTokenPos: TPoint; virtual; deprecated; // use next word pos instead
    function NextWordPos: TPoint; virtual;
    function PrevWordPos: TPoint; virtual;
    function IdentChars: TSynIdentChars;
    function IsIdentChar(const c: TUTF8Char): boolean;

    function IsLinkable(Y, X1, X2: Integer): Boolean; override;
    procedure InvalidateGutter; override;
    procedure InvalidateLine(Line: integer); override;
    procedure InvalidateGutterLines(FirstLine, LastLine: integer); override; // Currently invalidates full line => that may change
    procedure InvalidateLines(FirstLine, LastLine: integer); override;

    // Byte to Char
    function LogicalToPhysicalPos(const p: TPoint): TPoint; override;
    function LogicalToPhysicalCol(const Line: String; Index, LogicalPos
                              : integer): integer; override;
    // Char to Byte
    function PhysicalToLogicalPos(const p: TPoint): TPoint; override;
    function PhysicalToLogicalCol(const Line: string;
                                  Index, PhysicalPos: integer): integer; override;
    function PhysicalLineLength(Line: String; Index: integer): integer; override;

    (* from SynMemo - NOT recommended to use - Extremly slow code
       SynEdit (and SynMemo) is a Linebased Editor and not meant to be accessed as a contineous text
       Warning: This ignoces trailing spaces (same as in SynMemo). Result may be incorrect.
       If the caret must be adjusted use      SetTextBetweenPoints()
    *)
    function CharIndexToRowCol(Index: integer): TPoint;   experimental; deprecated 'SynMemo compatibility - very slow / SynEdit operates on x/y';
    function RowColToCharIndex(RowCol: TPoint): integer;  experimental; deprecated 'SynMemo compatibility - very slow / SynEdit operates on x/y';
    // End "from SynMemo"

    // Pixel
    function ScreenColumnToXValue(Col: integer): integer;  // map screen column to screen pixel
    function ScreenXYToPixels(RowCol: TPhysPoint): TPoint; // converts screen position (1,1) based
    function RowColumnToPixels(RowCol: TPoint): TPoint; // deprecated 'use ScreenXYToPixels(TextXYToScreenXY(point))';
    function PixelsToRowColumn(Pixels: TPoint; aFlags: TSynCoordinateMappingFlags = [scmLimitToLines]): TPoint;
    function PixelsToLogicalPos(const Pixels: TPoint): TPoint;
    //
    function ScreenRowToRow(ScreenRow: integer; LimitToLines: Boolean = True): integer; override; deprecated 'use ScreenXYToTextXY';
    function RowToScreenRow(PhysicalRow: integer): integer; override; deprecated 'use TextXYToScreenXY';
    (* ScreenXY:
       First visible (scrolled in) screen line is 1
       First column is 1 => column does not take scrolling into account
    *)
    function ScreenXYToTextXY(AScreenXY: TPhysPoint; LimitToLines: Boolean = True): TPhysPoint; override;
    function TextXYToScreenXY(APhysTextXY: TPhysPoint): TPhysPoint; override;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure RegisterCommandHandler(AHandlerProc: THookedCommandEvent;
      AHandlerData: pointer; AFlags: THookedCommandFlags = [hcfPreExec, hcfPostExec]); override;
    procedure UnregisterCommandHandler(AHandlerProc: THookedCommandEvent); override;

    procedure RegisterMouseActionSearchHandler(AHandlerProc: TSynEditMouseActionSearchProc); override;
    procedure UnregisterMouseActionSearchHandler(AHandlerProc: TSynEditMouseActionSearchProc); override;
    procedure RegisterMouseActionExecHandler(AHandlerProc: TSynEditMouseActionExecProc); override;
    procedure UnregisterMouseActionExecHandler(AHandlerProc: TSynEditMouseActionExecProc); override;

    procedure RegisterKeyTranslationHandler(AHandlerProc: THookedKeyTranslationEvent); override;
    procedure UnRegisterKeyTranslationHandler(AHandlerProc: THookedKeyTranslationEvent); override;

    procedure RegisterUndoRedoItemHandler(AHandlerProc: TSynUndoRedoItemEvent); override;
    procedure UnRegisterUndoRedoItemHandler(AHandlerProc: TSynUndoRedoItemEvent); override;

    procedure RegisterStatusChangedHandler(AStatusChangeProc: TStatusChangeEvent; AChanges: TSynStatusChanges); override;
    procedure UnRegisterStatusChangedHandler(AStatusChangeProc: TStatusChangeEvent); override;

    procedure RegisterBeforeMouseDownHandler(AHandlerProc: TMouseEvent); override;
    procedure UnregisterBeforeMouseDownHandler(AHandlerProc: TMouseEvent); override;

    procedure RegisterQueryMouseCursorHandler(AHandlerProc: TSynQueryMouseCursorEvent); override;
    procedure UnregisterQueryMouseCursorHandler(AHandlerProc: TSynQueryMouseCursorEvent); override;

    procedure RegisterBeforeKeyDownHandler(AHandlerProc: TKeyEvent); override;
    procedure UnregisterBeforeKeyDownHandler(AHandlerProc: TKeyEvent); override;
    procedure RegisterBeforeKeyUpHandler(AHandlerProc: TKeyEvent); override;
    procedure UnregisterBeforeKeyUpHandler(AHandlerProc: TKeyEvent); override;
    procedure RegisterBeforeKeyPressHandler(AHandlerProc: TKeyPressEvent); override;
    procedure UnregisterBeforeKeyPressHandler(AHandlerProc: TKeyPressEvent); override;
    procedure RegisterBeforeUtf8KeyPressHandler(AHandlerProc: TUTF8KeyPressEvent); override;
    procedure UnregisterBeforeUtf8KeyPressHandler(AHandlerProc: TUTF8KeyPressEvent); override;

    procedure RegisterPaintEventHandler(APaintEventProc: TSynPaintEventProc; AnEvents: TSynPaintEvents); override;
    procedure UnRegisterPaintEventHandler(APaintEventProc: TSynPaintEventProc); override;
    procedure RegisterScrollEventHandler(AScrollEventProc: TSynScrollEventProc; AnEvents: TSynScrollEvents); override;
    procedure UnRegisterScrollEventHandler(AScrollEventProc: TSynScrollEventProc); override;

    function SearchReplace(const ASearch, AReplace: string;
      AOptions: TSynSearchOptions): integer;
    function SearchReplaceEx(const ASearch, AReplace: string;
      AOptions: TSynSearchOptions; AStart: TPoint): integer;

    procedure SetUseIncrementalColor(const AValue : Boolean);
    procedure SetDefaultKeystrokes; virtual;
    procedure ResetMouseActions;  // set mouse-actions according to current Options / may clear them
    procedure SetOptionFlag(Flag: TSynEditorOption; Value: boolean);
    Procedure SetHighlightSearch(const ASearch: String; AOptions: TSynSearchOptions);
    function UpdateAction(TheAction: TBasicAction): boolean; override;
    procedure WndProc(var Msg: TMessage); override;
    procedure EraseBackground(DC: HDC); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function FindGutterFromGutterPartList(const APartList: TObject): TObject; override;
  public
    procedure FindMatchingBracket; override;
    function FindMatchingBracket(PhysStartBracket: TPoint;
                                 StartIncludeNeighborChars, MoveCaret,
                                 SelectBrackets, OnlyVisible: Boolean
                                ): TPoint; override; // Returns Physical
    function FindMatchingBracketLogical(LogicalStartBracket: TPoint;
                                        StartIncludeNeighborChars, MoveCaret,
                                        SelectBrackets, OnlyVisible: Boolean
                                       ): TPoint; override; // Returns Logical
    //code fold
    procedure CodeFoldAction(iLine: integer); deprecated;
    procedure UnfoldAll; deprecated;
    procedure FoldAll(StartLevel : Integer = 0; IgnoreNested : Boolean = False); deprecated;
    property FoldState: String read GetFoldState write SetFoldState;

    procedure AddKey(Command: TSynEditorCommand; Key1: word; SS1: TShiftState;
      Key2: word; SS2: TShiftState);
  public
    property MaxLeftChar: integer read fMaxLeftChar write SetMaxLeftChar default 1024;

    property ScrollOnEditLeftOptions: TSynScrollOnEditOptions read FScrollOnEditLeftOptions write SetScrollOnEditLeftOptions;
    property ScrollOnEditRightOptions: TSynScrollOnEditOptions read FScrollOnEditRightOptions write SetScrollOnEditRightOptions;

    property UseIncrementalColor : Boolean write SetUseIncrementalColor;
    property PaintLock: Integer read fPaintLock;

    property UseUTF8: boolean read FUseUTF8;
    procedure Invalidate; override;
    property ChangeStamp: int64 read GetChangeStamp;
    procedure ShareTextBufferFrom(AShareEditor: TCustomSynEdit);
    procedure UnShareTextBuffer;

    function PluginCount: Integer;
    property Plugin[Index: Integer]: TLazSynEditPlugin read GetPlugin;
    function MarkupCount: Integer;
    property Markup[Index: integer]: TSynEditMarkup read GetMarkup;
    property MarkupByClass[Index: TSynEditMarkupClass]: TSynEditMarkup read GetMarkupByClass;
    property TrimSpaceType: TSynEditStringTrimmingType read GetTrimSpaceType write SetTrimSpaceType;
  public
    // Caret
    procedure SetCaretTypeSize(AType: TSynCaretType;AWidth, AHeight, AXOffs, AYOffs: Integer);
    property InsertCaret: TSynEditCaretType read FInsertCaret write SetInsertCaret default ctVerticalLine;
    property OverwriteCaret: TSynEditCaretType read FOverwriteCaret write SetOverwriteCaret default ctBlock;

    // Selection
    property DefaultSelectionMode: TSynSelectionMode read GetDefSelectionMode write SetDefSelectionMode default smNormal;
    property SelectionMode: TSynSelectionMode read GetSelectionMode write SetSelectionMode default smNormal;

    // Cursor
    procedure UpdateCursorOverride; override;

    // Colors
    property MarkupManager: TSynEditMarkupManager read fMarkupManager;
    property Color default clWhite;
    property Cursor: TCursor read FTextCursor write SetTextCursor default crIBeam;
    property OffTextCursor: TCursor read FOffTextCursor write SetOffTextCursor default crDefault;
    property IncrementColor: TSynSelectedColor read GetIncrementColor write SetIncrementColor;
    property HighlightAllColor: TSynSelectedColor read GetHighlightAllColor write SetHighlightAllColor;
    property BracketMatchColor: TSynSelectedColor read GetBracketMatchColor write SetBracketMatchColor;
    property MouseLinkColor: TSynSelectedColor read GetMouseLinkColor write SetMouseLinkColor;
    property LineHighlightColor: TSynSelectedColor read GetLineHighlightColor write SetLineHighlightColor;
    property FoldedCodeColor: TSynSelectedColor read GetFoldedCodeColor write SetFoldedCodeColor;
    property FoldedCodeLineColor: TSynSelectedColor read GetFoldedCodeLineColor write SetFoldedCodeLineColor;
    property HiddenCodeLineColor: TSynSelectedColor read GetHiddenCodeLineColor write SetHiddenCodeLineColor;

    property Beautifier: TSynCustomBeautifier read fBeautifier write SetBeautifier;
    property BlockIndent: integer read FBlockIndent write SetBlockIndent default 2;
    property BlockTabIndent: integer read FBlockTabIndent write SetBlockTabIndent default 0;
    property Highlighter: TSynCustomHighlighter read fHighlighter write SetHighlighter;
    property Gutter: TSynGutter read FLeftGutter write SetGutter;
    property RightGutter: TSynGutter read FRightGutter write SetRightGutter;
    property InsertMode: boolean read fInserting write SetInsertMode default true;
    property Keystrokes: TSynEditKeyStrokes read FKeystrokes write SetKeystrokes;
    property MaxUndo: Integer read GetMaxUndo write SetMaxUndo default 1024;
    property ShareOptions: TSynEditorShareOptions read FShareOptions write SetShareOptions
      default SYNEDIT_DEFAULT_SHARE_OPTIONS; experimental;
    property VisibleSpecialChars: TSynVisibleSpecialChars read FVisibleSpecialChars write SetVisibleSpecialChars;
    property RightEdge: Integer read GetRightEdge write SetRightEdge default 80;
    property RightEdgeColor: TColor read GetRightEdgeColor write SetRightEdgeColor default clSilver;
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
    property BracketHighlightStyle: TSynEditBracketHighlightStyle
      read GetBracketHighlightStyle write SetBracketHighlightStyle;
    property TabWidth: integer read fTabWidth write SetTabWidth default 8;
    property WantTabs: boolean read fWantTabs write SetWantTabs default True;

    // Events
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChangeUpdating: TChangeUpdatingEvent read FOnChangeUpdating write FOnChangeUpdating;
    property OnCutCopy: TSynCopyPasteEvent read FOnCutCopy write FOnCutCopy;
    property OnPaste: TSynCopyPasteEvent read FOnPaste write FOnPaste;
    property OnDropFiles: TSynDropFilesEvent read fOnDropFiles write fOnDropFiles;
    property OnGutterClick: TGutterClickEvent read GetOnGutterClick write SetOnGutterClick;
    property OnPaint: TPaintEvent read fOnPaint write fOnPaint;
    // OnPlaceBookmark only triggers for Bookmarks
    property OnPlaceBookmark: TPlaceMarkEvent read FOnPlaceMark write FOnPlaceMark;
    // OnClearBookmark only triggers for Bookmarks
    property OnClearBookmark: TPlaceMarkEvent read FOnClearMark write FOnClearMark;
    property OnKeyDown;
    property OnKeyPress;
    property OnProcessCommand: TProcessCommandEvent read FOnProcessCommand write FOnProcessCommand;
    property OnProcessUserCommand: TProcessCommandEvent  read FOnProcessUserCommand write FOnProcessUserCommand;
    property OnCommandProcessed: TProcessCommandEvent read fOnCommandProcessed write fOnCommandProcessed;
    property OnReplaceText: TReplaceTextEvent read fOnReplaceText write fOnReplaceText;
    property OnSpecialLineColors: TSpecialLineColorsEvent read FOnSpecialLineColors write SetSpecialLineColors;  deprecated;
    property OnSpecialLineMarkup: TSpecialLineMarkupEvent read FOnSpecialLineMarkup write SetSpecialLineMarkup;
    property OnStatusChange: TStatusChangeEvent read fOnStatusChange write fOnStatusChange;
  end;

  TSynEdit = class(TCustomSynEdit)
  published
    // inherited properties
    property Align;
    property Beautifier;
    property BlockIndent;
    property BlockTabIndent;
    property BorderSpacing;
    property Anchors;
    property Constraints;
    property Color;
    property Cursor default crIBeam;
    property OffTextCursor default crDefault;
    property Enabled;
    property Font;
    property Height;
    property Name;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Tag;
    property Visible;
    property Width;
    // inherited events
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnTripleClick;
    property OnQuadClick;
    property OnDragDrop;
    property OnDragOver;
// ToDo Docking
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnClickLink;
    property OnMouseLink;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
// ToDo Docking
    property OnStartDock;
    property OnStartDrag;
    property OnUTF8KeyPress;
    // TCustomSynEdit properties
    property BookMarkOptions;
    property BorderStyle default bsSingle;
    property ExtraCharSpacing;
    property ExtraLineSpacing;
    property Gutter;
    property RightGutter;
    property HideSelection;
    property Highlighter;
    property InsertCaret;
    property InsertMode;
    property Keystrokes;
    property MouseActions;
    property MouseTextActions;
    property MouseSelActions;
    property Lines;
    property MaxLeftChar;
    property MaxUndo;
    property OnResize;
    property Options;
    property Options2;
    property MouseOptions;
    property VisibleSpecialChars;
    property OverwriteCaret;
    property ReadOnly;
    property RightEdge;
    property RightEdgeColor;
    property ScrollBars;
    property SelectedColor;
    property ScrollOnEditLeftOptions;
    property ScrollOnEditRightOptions;
    property IncrementColor;
    property HighlightAllColor;
    property BracketHighlightStyle;
    property BracketMatchColor;
    property FoldedCodeColor;
    property MouseLinkColor;
    property LineHighlightColor;
    property DefaultSelectionMode;
    property SelectionMode;
    property TabWidth;
    property WantTabs;
    // TCustomSynEdit events
    property OnChange;
    property OnChangeUpdating;
    property OnCutCopy;
    property OnPaste;
    property OnClearBookmark;                                                   // djlp 2000-08-29
    property OnCommandProcessed;
    property OnDropFiles;
    property OnGutterClick;
    property OnPaint;
    property OnPlaceBookmark;
    property OnProcessCommand;
    property OnProcessUserCommand;
    property OnReplaceText;
    property OnShowHint;
    property OnSpecialLineColors; deprecated;
    property OnSpecialLineMarkup;
    property OnStatusChange;
  end;

procedure Register;

implementation

var
  LOG_SynMouseEvents: PLazLoggerLogGroup;

const
  GutterTextDist = 2; //Pixel

type

  TSynTextViewsManagerInternal = class(TSynTextViewsManager)
  public
    property TextBuffer;
  end;

  { TSynEditMarkListInternal }

  TSynEditMarkListInternal = class(TSynEditMarkList)
  private
    function GetLinesView: TSynEditStringsLinked;
    procedure SetLinesView(const AValue: TSynEditStringsLinked);
  protected
    procedure AddOwnerEdit(AEdit: TSynEditBase);
    procedure RemoveOwnerEdit(AEdit: TSynEditBase);
    property LinesView: TSynEditStringsLinked read GetLinesView write SetLinesView;
  end;

  TSynStatusChangedHandlerList = Class(TSynFilteredMethodList)
  public
    procedure Add(AHandler: TStatusChangeEvent; Changes: TSynStatusChanges);
    procedure Remove(AHandler: TStatusChangeEvent);
    procedure CallStatusChangedHandlers(Sender: TObject; Changes: TSynStatusChanges);
  end;

  { TSynPaintEventHandlerList }

  TSynPaintEventHandlerList = Class(TSynFilteredMethodList)
  public
    procedure Add(AHandler: TSynPaintEventProc; Changes: TSynPaintEvents);
    procedure Remove(AHandler: TSynPaintEventProc);
    procedure CallPaintEventHandlers(Sender: TObject; AnEvent: TSynPaintEvent; const rcClip: TRect);
  end;

  { TSynScrollEventHandlerList}

  TSynScrollEventHandlerList = Class(TSynFilteredMethodList)
  public
    procedure Add(AHandler: TSynScrollEventProc; Changes: TSynScrollEvents);
    procedure Remove(AHandler: TSynScrollEventProc);
    procedure CallScrollEventHandlers(Sender: TObject; AnEvent: TSynScrollEvent;
      dx, dy: Integer; const rcScroll, rcClip: TRect);
  end;

  { TSynQueryMouseCursorList }

  TSynQueryMouseCursorList = Class(TSynMethodList)
  public
    procedure Add(AHandler: TSynQueryMouseCursorEvent);
    procedure Remove(AHandler: TSynQueryMouseCursorEvent);
    procedure CallScrollEventHandlers(Sender: TObject;
      const AMouseLocation: TSynMouseLocationInfo; var AnCursor: TCursor);
  end;

  { TSynEditUndoCaret }

  TSynEditUndoCaret = class(TSynEditUndoItem)
  private
    FCaretPos: TPoint;
  protected
    function IsEqualContent(AnItem: TSynEditUndoItem): Boolean; override;
    function DebugString: String; override;
  public
    constructor Create(CaretPos: TPoint);
    function IsCaretInfo: Boolean; override;
    function PerformUndo(Caller: TObject): Boolean; override;
  end;

  { TSynEditUndoSelCaret }

  TSynEditUndoSelCaret = class(TSynEditUndoItem)
  private
    FCaretPos, FBeginPos, FEndPos: TPoint;
    FBlockMode: TSynSelectionMode;
  protected
    function IsEqualContent(AnItem: TSynEditUndoItem): Boolean; override;
    function DebugString: String; override;
  public
    function IsCaretInfo: Boolean; override;
    constructor Create(CaretPos, BeginPos, EndPos: TPoint; BlockMode: TSynSelectionMode);
    function PerformUndo(Caller: TObject): Boolean; override;
  end;

  { TSynEditUndoIndent }

  TSynEditUndoIndent = class(TSynEditUndoItem)
  public
    FPosY1, FPosY2, FCnt, FTabCnt: Integer;
  public
    constructor Create(APosY, EPosY, ACnt, ATabCnt: Integer);
    function PerformUndo(Caller: TObject): Boolean; override;
  end;

  { TSynEditUndoUnIndent }

  TSynEditUndoUnIndent = class(TSynEditUndoItem)
  public
    FPosY1, FPosY2: Integer;
    FText: String;
  public
    constructor Create(APosY, EPosY: Integer; AText: String);
    function PerformUndo(Caller: TObject): Boolean; override;
  end;

  { TSynEditMouseGlobalActions }

  TSynEditMouseGlobalActions = class(TSynEditMouseInternalActions)
  protected
    procedure InitForOptions(AnOptions: TSynEditorMouseOptions); override;
  end;

  { TSynEditMouseTextActions }

  TSynEditMouseTextActions = class(TSynEditMouseInternalActions)
  protected
    procedure InitForOptions(AnOptions: TSynEditorMouseOptions); override;
  end;

  { TSynEditMouseSelActions }

  TSynEditMouseSelActions = class(TSynEditMouseInternalActions)
  protected
    procedure InitForOptions(AnOptions: TSynEditorMouseOptions); override;
  end;

  { THookedCommandHandlerEntry }

  THookedCommandHandlerEntry = class(TObject)
  private
    FEvent: THookedCommandEvent;
    FData: pointer;
    FFlags: THookedCommandFlags;
    function Equals(AEvent: THookedCommandEvent): boolean; reintroduce;
  public
    constructor Create(AEvent: THookedCommandEvent; AData: pointer; AFlags: THookedCommandFlags);
  end;

{ TSynEditUndoCaret }

function TSynEditUndoCaret.IsEqualContent(AnItem: TSynEditUndoItem): Boolean;
begin
  Result := (FCaretPos.x = TSynEditUndoCaret(AnItem).FCaretPos.x)
        and (FCaretPos.y = TSynEditUndoCaret(AnItem).FCaretPos.y);
end;

function TSynEditUndoCaret.DebugString: String;
begin
  Result := 'CaretPos='+dbgs(FCaretPos);
end;

constructor TSynEditUndoCaret.Create(CaretPos: TPoint);
begin
  FCaretPos := CaretPos;
  {$IFDEF SynUndoDebugItems}debugln(['---  Undo Insert ',DbgSName(self), ' ', dbgs(Self), ' - ', DebugString]);{$ENDIF}
end;

function TSynEditUndoCaret.IsCaretInfo: Boolean;
begin
  Result := True;
end;

function TSynEditUndoCaret.PerformUndo(Caller: TObject): Boolean;
begin
  Result := Caller is TCustomSynEdit;
  if Result then
    {$IFDEF SynUndoDebugItems}debugln(['---  Undo Perform ',DbgSName(self), ' ', dbgs(Self), ' - ', DebugString]);{$ENDIF}
    with TCustomSynEdit(Caller) do begin
      FCaret.LineCharPos := FCaretPos;
      FTheLinesView.CurUndoList.AddChange(TSynEditUndoCaret.Create(FCaretPos));
    end;
end;

{ TSynEditUndoSelCaret }

constructor TSynEditUndoSelCaret.Create(CaretPos, BeginPos, EndPos: TPoint;
  BlockMode: TSynSelectionMode);
begin
  FCaretPos := CaretPos;
  FBeginPos := BeginPos;
  FEndPos   := EndPos;
  FBlockMode := BlockMode;
  {$IFDEF SynUndoDebugItems}debugln(['---  Undo Insert ',DbgSName(self), ' ', dbgs(Self), ' - ', DebugString]);{$ENDIF}
end;

function TSynEditUndoSelCaret.IsEqualContent(AnItem: TSynEditUndoItem): Boolean;
begin
  Result := (FCaretPos.x = TSynEditUndoSelCaret(AnItem).FCaretPos.x)
        and (FCaretPos.y = TSynEditUndoSelCaret(AnItem).FCaretPos.y)
        and (FBeginPos.x = TSynEditUndoSelCaret(AnItem).FBeginPos.x)
        and (FBeginPos.y = TSynEditUndoSelCaret(AnItem).FBeginPos.y)
        and (FEndPos.x = TSynEditUndoSelCaret(AnItem).FEndPos.x)
        and (FEndPos.y = TSynEditUndoSelCaret(AnItem).FEndPos.y)
        and (FBlockMode = TSynEditUndoSelCaret(AnItem).FBlockMode);
end;

function TSynEditUndoSelCaret.DebugString: String;
begin
  Result := 'CaretPos='+dbgs(FCaretPos) + ' Begin=' + dbgs(FBeginPos) + ' End=' + dbgs(FEndPos) + ' Mode=' + dbgs(ord(FBlockMode));
end;

function TSynEditUndoSelCaret.IsCaretInfo: Boolean;
begin
  Result := True;
end;

function TSynEditUndoSelCaret.PerformUndo(Caller: TObject): Boolean;
begin
  Result := Caller is TCustomSynEdit;
  if Result then
    {$IFDEF SynUndoDebugItems}debugln(['---  Undo Perform ',DbgSName(self), ' ', dbgs(Self), ' - ', DebugString]);{$ENDIF}
    with TCustomSynEdit(Caller) do begin
      SetCaretAndSelection(FCaretPos, FBeginPos, FEndPos, FBlockMode, True);
      FTheLinesView.CurUndoList.AddChange(TSynEditUndoSelCaret.Create(FCaretPos, FBeginPos,
                                                     FEndPos, FBlockMode));
    end;
end;

{ TSynEditUndoIndent }

constructor TSynEditUndoIndent.Create(APosY, EPosY, ACnt, ATabCnt: Integer);
begin
  FPosY1 := APosY;
  FPosY2 := EPosY;
  FCnt    :=  ACnt;
  FTabCnt := ATabCnt;
end;

function TSynEditUndoIndent.PerformUndo(Caller: TObject): Boolean;
begin
  Result := False;
end;

{ TSynEditUndoUnIndent }

constructor TSynEditUndoUnIndent.Create(APosY, EPosY: Integer; AText: String);
begin
  FPosY1 := APosY;
  FPosY2 := EPosY;
  FText :=  AText;
end;

function TSynEditUndoUnIndent.PerformUndo(Caller: TObject): Boolean;
begin
  Result := False;
end;

function Roundoff(X: Extended): Longint;
begin
  if (x >= 0) then begin
    Result := TruncToInt(x + 0.5)
  end else begin
    Result := TruncToInt(x - 0.5);
  end;
end;

{ TSynEditMouseGlobalActions }

procedure TSynEditMouseGlobalActions.InitForOptions(AnOptions: TSynEditorMouseOptions);
begin
  // Normal wheel: scroll dependent on visible scroll-bars
  AddCommand(emcWheelScrollDown,       False,  mbXWheelDown, ccAny, cdDown, [], []);
  AddCommand(emcWheelScrollUp,         False,  mbXWheelUp, ccAny, cdDown, [], []);

  AddCommand(emcWheelHorizScrollDown,       False,  mbXWheelLeft, ccAny, cdDown, [], []);
  AddCommand(emcWheelHorizScrollUp,         False,  mbXWheelRight, ccAny, cdDown, [], []);

  if emCtrlWheelZoom in AnOptions then begin
    AddCommand(emcWheelZoomOut,        False,  mbXWheelDown, ccAny, cdDown, [ssCtrl], [ssCtrl]);
    AddCommand(emcWheelZoomIn,         False,  mbXWheelUp,   ccAny, cdDown, [ssCtrl], [ssCtrl]);
  end;
end;

{ TSynEditMouseTextActions }

procedure TSynEditMouseTextActions.InitForOptions(AnOptions: TSynEditorMouseOptions);
var
  rmc: Boolean;
begin
  Clear;
  rmc := (emRightMouseMovesCursor in AnOptions);
  //// eoRightMouseMovesCursor
  //if (eoRightMouseMovesCursor in ChangedOptions) then begin
  //  for i := FMouseActions.Count-1 downto 0 do
  //    if FMouseActions[i].Button = mbXRight then
  //      FMouseActions[i].MoveCaret := (eoRightMouseMovesCursor in fOptions);
  //end;

  AddCommand(emcStartSelections,       True,  mbXLeft, ccSingle, cdDown, [],        [ssShift, ssAlt], emcoSelectionStart);
  AddCommand(emcStartSelections,       True,  mbXLeft, ccSingle, cdDown, [ssShift], [ssShift, ssAlt], emcoSelectionContinue);
  if (emAltSetsColumnMode in AnOptions) then begin
    AddCommand(emcStartColumnSelections, True,  mbXLeft, ccSingle, cdDown, [ssAlt],          [ssShift, ssAlt], emcoSelectionStart);
    AddCommand(emcStartColumnSelections, True,  mbXLeft, ccSingle, cdDown, [ssShift, ssAlt], [ssShift, ssAlt], emcoSelectionContinue);
  end;
  if (emShowCtrlMouseLinks in AnOptions) then
    AddCommand(emcMouseLink,             False, mbXLeft, ccSingle, cdUp, [SYNEDIT_LINK_MODIFIER], [ssShift, ssAlt, ssCtrl] + [SYNEDIT_LINK_MODIFIER]);

  if (emDoubleClickSelectsLine in AnOptions) then begin
    AddCommand(emcSelectLine,            True,  mbXLeft, ccDouble, cdDown, [], []);
    AddCommand(emcSelectPara,            True,  mbXLeft, ccTriple, cdDown, [], []);
  end
  else begin
    AddCommand(emcSelectWord,            True,  mbXLeft, ccDouble, cdDown, [], []);
    AddCommand(emcSelectLine,            True,  mbXLeft, ccTriple, cdDown, [], []);
  end;
  AddCommand(emcSelectPara,            True,  mbXLeft, ccQuad,   cdDown, [], []);

  AddCommand(emcContextMenu,           rmc,   mbXRight, ccSingle, cdUp, [], [], emcoSelectionCaretMoveNever);

  AddCommand(emcPasteSelection,        True,  mbXMiddle, ccSingle, cdDown, [], []);
end;

{ TSynEditMouseSelActions }

procedure TSynEditMouseSelActions.InitForOptions(AnOptions: TSynEditorMouseOptions);
begin
  Clear;
  //rmc := (eoRightMouseMovesCursor in AnOptions);

  if (emDragDropEditing in AnOptions) then
    AddCommand(emcStartDragMove, False, mbXLeft, ccSingle, cdDown, [], [ssShift]);
end;

{ THookedCommandHandlerEntry }

constructor THookedCommandHandlerEntry.Create(AEvent: THookedCommandEvent; AData: pointer;
  AFlags: THookedCommandFlags);
begin
  inherited Create;
  fEvent := AEvent;
  fData := AData;
  FFlags := AFlags;
end;

function THookedCommandHandlerEntry.Equals(AEvent: THookedCommandEvent): boolean;
begin
  with TMethod(fEvent) do
    Result := (Code = TMethod(AEvent).Code) and (Data = TMethod(AEvent).Data);
end;

function dbgs(aStateFlag: TSynStateFlag): string; overload;
begin
  Result:='';
  WriteStr(Result, aStateFlag)
end;
function dbgs(aStateFlags: TSynStateFlags): string; overload;
var i: TSynStateFlag;
begin
  Result := '';
  for i := low(TSynStateFlags) to high(TSynStateFlags) do
    if i in aStateFlags then begin
      if Result <> '' then Result := Result + ',';
      Result := Result + dbgs(i);
    end;
  if Result <> '' then Result := '[' + Result + ']';
end;

procedure InitSynDefaultFont;
begin
  if SynDefaultFontName <> '' then exit;
  Screen.Fonts;
  {$UNDEF SynDefaultFont}
  {$IFDEF LCLgtk}
    SynDefaultFontName   := '-adobe-courier-medium-r-normal-*-*-140-*-*-*-*-iso10646-1';
    SynDefaultFontHeight := 14;
    {$DEFINE SynDefaultFont}
  {$ENDIF}
  {$IFDEF LCLcarbon}
    SynDefaultFontName   := 'Monaco'; // Note: carbon is case sensitive
    SynDefaultFontHeight := 12;
    {$DEFINE SynDefaultFont}
  {$ENDIF}
  {$IFDEF LCLcocoa}
    SynDefaultFontName   := 'Andale Mono'; // Note: cocoa is case sensitive
    SynDefaultFontHeight := 10;
    {$DEFINE SynDefaultFont}
  {$ENDIF}
  // LCLgtk2 and LCLQt use default settings
  {$IFnDEF SynDefaultFont}
    SynDefaultFontName   := 'Courier New';
    SynDefaultFontHeight := -13;
  {$ENDIF}
  if Screen.Fonts.IndexOf(SynDefaultFontName) >= 0 then
    exit;
  if Screen.Fonts.IndexOf('DejaVu Sans Mono') >= 0 then begin
    SynDefaultFontName   := 'DejaVu Sans Mono';
    SynDefaultFontHeight := 13;
  end;
end;

{ TSynScrollOnEditOptions }

procedure TSynScrollOnEditOptions.SetKeepBorderDistance(AValue: integer);
begin
  if FKeepBorderDistance = AValue then Exit;
  AValue := MinMax(AValue, 0, 1000);
  FKeepBorderDistance := AValue;
end;

procedure TSynScrollOnEditOptions.SetKeepBorderDistancePercent(AValue: integer);
begin
  if FKeepBorderDistancePercent = AValue then Exit;
  AValue := MinMax(AValue, 0, 100);
  FKeepBorderDistancePercent := AValue;
end;

procedure TSynScrollOnEditOptions.SetScrollExtraColumns(AValue: integer);
begin
  if FScrollExtraColumns = AValue then Exit;
  AValue := MinMax(AValue, 0, 1000);
  FScrollExtraColumns := AValue;
end;

procedure TSynScrollOnEditOptions.SetScrollExtraMax(AValue: integer);
begin
  if FScrollExtraMax = AValue then Exit;
  AValue := MinMax(AValue, 0, 1000);
  FScrollExtraMax := AValue;
end;

procedure TSynScrollOnEditOptions.SetScrollExtraPercent(AValue: integer);
begin
  if FScrollExtraPercent = AValue then Exit;
  AValue := MinMax(AValue, 0, 100);
  FScrollExtraPercent := AValue;
end;

procedure TSynScrollOnEditOptions.Assign(Source: TPersistent);
begin
  if not(Source is TSynScrollOnEditOptions) then
    exit;
  FKeepBorderDistance        := TSynScrollOnEditOptions(Source).FKeepBorderDistance;
  FKeepBorderDistancePercent := TSynScrollOnEditOptions(Source).FKeepBorderDistancePercent;
  FScrollExtraColumns        := TSynScrollOnEditOptions(Source).FScrollExtraColumns;
  FScrollExtraMax            := TSynScrollOnEditOptions(Source).FScrollExtraMax;
  FScrollExtraPercent        := TSynScrollOnEditOptions(Source).FScrollExtraPercent;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TSynScrollOnEditOptions.Create;
begin
  inherited Create;
  SetDefaults;
end;

procedure TSynScrollOnEditOptions.SetDefaults;
begin
  //
end;

{ TSynScrollOnEditLeftOptions }

procedure TSynScrollOnEditLeftOptions.SetDefaults;
begin
  inherited SetDefaults;
  FKeepBorderDistance        := CKeepBorderDistance;
  FKeepBorderDistancePercent := CKeepBorderDistancePercent;
  FScrollExtraColumns        := CScrollExtraColumns;
  FScrollExtraMax            := CScrollExtraMax;
  FScrollExtraPercent        := CScrollExtraPercent;
end;

{ TSynScrollOnEditRightOptions }

procedure TSynScrollOnEditRightOptions.SetDefaults;
begin
  FKeepBorderDistance        := CKeepBorderDistance;
  FKeepBorderDistancePercent := CKeepBorderDistancePercent;
  FScrollExtraColumns        := CScrollExtraColumns;
  FScrollExtraMax            := CScrollExtraMax;
  FScrollExtraPercent        := CScrollExtraPercent;
end;

{ TCustomSynEdit }

procedure TCustomSynEdit.AquirePrimarySelection;
var
  FormatList: Array [0..1] of TClipboardFormat;
begin
  if (not SelAvail)
  or (PrimarySelection.OnRequest=@PrimarySelectionRequest) then exit;
  FormatList[0] := CF_TEXT;
  FormatList[1] := TSynClipboardStream.ClipboardFormatId;
  try
    PrimarySelection.SetSupportedFormats(2, @FormatList[0]);
    PrimarySelection.OnRequest:=@PrimarySelectionRequest;
  except
  end;
end;

function TCustomSynEdit.GetChangeStamp: int64;
begin
  Result := TSynEditStringList(FLines).TextChangeStamp;
end;

function TCustomSynEdit.GetCharsInWindow: Integer;
begin
  if not Assigned(FTextArea) then
    Result := -1
  else
    Result := FTextArea.CharsInWindow;
end;

function TCustomSynEdit.GetCharWidth: integer;
begin
  if not Assigned(FTextArea) then
    Result := -1
  else
    Result := FTextArea.CharWidth;
end;

function TCustomSynEdit.GetDefSelectionMode: TSynSelectionMode;
begin
  Result := FBlockSelection.SelectionMode;
end;

function TCustomSynEdit.GetFoldedCodeLineColor: TSynSelectedColor;
begin
  Result := FFoldedLinesView.MarkupInfoFoldedCodeLine;
end;

function TCustomSynEdit.GetFoldState: String;
begin
  Result := FFoldedLinesView.GetFoldDescription(0, 0, -1, -1, True);
end;

function TCustomSynEdit.GetHiddenCodeLineColor: TSynSelectedColor;
begin
  Result := FFoldedLinesView.MarkupInfoHiddenCodeLine;
end;

function TCustomSynEdit.GetLeftChar: Integer;
begin
  if not Assigned(FTextArea) then
    Result := -1
  else
    Result := FTextArea.LeftChar;
end;

function TCustomSynEdit.GetLineHeight: integer;
begin
  if not Assigned(FTextArea) then
    Result := -1
  else
    Result := FTextArea.LineHeight;
end;

function TCustomSynEdit.GetLinesInWindow: Integer;
begin
  if not Assigned(FTextArea) then
    Result := -1
  else
    Result := FTextArea.LinesInWindow;
end;

function TCustomSynEdit.GetModified: Boolean;
begin
  Result := TSynEditStringList(FLines).Modified;
end;

function TCustomSynEdit.GetMouseActions: TSynEditMouseActions;
begin
  Result := FMouseActions.UserActions;
end;

function TCustomSynEdit.GetMouseSelActions: TSynEditMouseActions;
begin
  Result := FMouseSelActions.UserActions;
end;

function TCustomSynEdit.GetMouseTextActions: TSynEditMouseActions;
begin
  Result := FMouseTextActions.UserActions;
end;

function TCustomSynEdit.GetPaintLockOwner: TSynEditBase;
begin
  Result := TSynEditStringList(FLines).PaintLockOwner;
end;

function TCustomSynEdit.GetPlugin(Index: Integer): TLazSynEditPlugin;
begin
  Result := TLazSynEditPlugin(fPlugins[Index]);
end;

function TCustomSynEdit.GetRightEdge: Integer;
begin
  if not Assigned(FTextArea) then
    Result := -1
  else
    Result := FTextArea.RightEdgeColumn;
end;

function TCustomSynEdit.GetRightEdgeColor: TColor;
begin
  if not Assigned(FTextArea) then
    Result := clNone
  else
    Result := FTextArea.RightEdgeColor;
end;

function TCustomSynEdit.GetTextBetweenPoints(aStartPoint, aEndPoint: TPoint): String;
begin
  FInternalBlockSelection.SelectionMode := smNormal;
  FInternalBlockSelection.StartLineBytePos := aStartPoint;
  FInternalBlockSelection.EndLineBytePos := aEndPoint;
  Result := FInternalBlockSelection.SelText;
end;

function TCustomSynEdit.GetTopLine: Integer;
begin
  if not Assigned(FTextArea) then
    Result := -1
  else
    Result := FTheLinesView.ViewToTextIndex(ToIdx(FTextArea.TopLine)) + 1;
end;

procedure TCustomSynEdit.SetBlockTabIndent(AValue: integer);
begin
  if FBlockTabIndent = AValue then Exit;
  FBlockTabIndent := AValue;
end;

procedure TCustomSynEdit.SetBracketMatchColor(AValue: TSynSelectedColor);
begin
  fMarkupBracket.MarkupInfo.Assign(AValue);
end;

procedure TCustomSynEdit.SetTextCursor(AValue: TCursor);
begin
  if FTextCursor = AValue then exit;
  FTextCursor := AValue;
  UpdateCursor;
end;

procedure TCustomSynEdit.SetOffTextCursor(AValue: TCursor);
begin
  if FOffTextCursor = AValue then Exit;
  FOffTextCursor := AValue;
  UpdateCursor;
end;

procedure TCustomSynEdit.SetDefSelectionMode(const AValue: TSynSelectionMode);
begin
  FBlockSelection.SelectionMode := AValue; // Includes active
end;

procedure TCustomSynEdit.SetFoldedCodeColor(AValue: TSynSelectedColor);
begin
  FFoldedLinesView.MarkupInfoFoldedCode.Assign(AValue);
end;

procedure TCustomSynEdit.SetFoldedCodeLineColor(AValue: TSynSelectedColor);
begin
  FFoldedLinesView.MarkupInfoFoldedCodeLine.Assign(AValue);
end;

procedure TCustomSynEdit.SurrenderPrimarySelection;
begin
  if PrimarySelection.OnRequest=@PrimarySelectionRequest then
    PrimarySelection.OnRequest:=nil;
end;

function TCustomSynEdit.PixelsToRowColumn(Pixels: TPoint; aFlags: TSynCoordinateMappingFlags = [scmLimitToLines]): TPoint;
// converts the client area coordinate
// to Caret position (physical position, (1,1) based)
// To get the text/logical position use PixelsToLogicalPos
begin
  Result := YToPos(FTextArea.PixelsToRowColumn(Pixels, aFlags));
  Result := ScreenXYToTextXY(Result, scmLimitToLines in aFlags);
end;

function TCustomSynEdit.PixelsToLogicalPos(const Pixels: TPoint): TPoint;
begin
  Result:=PhysicalToLogicalPos(PixelsToRowColumn(Pixels));
end;

function TCustomSynEdit.ScreenRowToRow(ScreenRow: integer; LimitToLines: Boolean = True): integer;
// ScreenRow is 0-base
// result is 1-based
begin
  Result := ToPos(FTheLinesView.ViewToTextIndex(ToIdx(TopView + ScreenRow)));
  if LimitToLines and (Result >= Lines.Count) then
    Result := Lines.Count;
//  DebugLn(['=== SrceenRow TO Row   In:',ScreenRow,'  out:',Result, ' topline=',TopLine, '  view topline=',FFoldedLinesView.TopLine]);
end;

function TCustomSynEdit.RowToScreenRow(PhysicalRow: integer): integer;
// returns -1 for lines above visible screen (<TopLine)
// 0 for the first line
// 0 to LinesInWindow for visible lines (incl last partial visble line)
// and returns LinesInWindow+1 for lines below visible screen
begin
  Result := ToPos(FTheLinesView.TextToViewIndex(ToIdx(PhysicalRow))) - TopView;
  if Result < -1 then Result := -1;
  if Result > LinesInWindow+1 then Result := LinesInWindow+1;
//  DebugLn(['=== Row TO ScreenRow   In:',PhysicalRow,'  out:',Result]);
end;

function TCustomSynEdit.ScreenXYToTextXY(AScreenXY: TPhysPoint;
  LimitToLines: Boolean): TPhysPoint;
begin
  AScreenXY.y := AScreenXY.y + ToIdx(TopView);
  Result := FTheLinesView.ViewXYToTextXY(AScreenXY);
  if LimitToLines and (Result.y > Lines.Count) then
    Result.y := Lines.Count;
end;

function TCustomSynEdit.TextXYToScreenXY(APhysTextXY: TPhysPoint): TPhysPoint;
begin
  Result := FTheLinesView.TextXYToViewXY(APhysTextXY);
  Result.y := Result.y - ToIdx(TopView);
end;

function TCustomSynEdit.ScreenXYToPixels(RowCol: TPhysPoint): TPoint;
// converts screen position (1,1) based
// to client area coordinate (0,0 based on canvas)
begin
  dec(RowCol.y); // x is 1 based, as LeftChar will be subtracted.....
  Result := FTextArea.RowColumnToPixels(RowCol);
end;

function TCustomSynEdit.RowColumnToPixels(RowCol: TPoint): TPoint;
begin
  Result := ScreenXYToPixels(TextXYToScreenXY(RowCol));
end;

procedure TCustomSynEdit.ComputeCaret(X, Y: Integer);
// set caret to pixel position
begin
  FCaret.LineCharPos := PixelsToRowColumn(Point(X,Y));
end;

procedure TCustomSynEdit.DoCopyToClipboard(SText: string; FoldInfo: String = '');
var
  ClipHelper: TSynClipboardStream;
  PasteAction: TSynCopyPasteAction;
  PMode: TSynSelectionMode;
begin
  PasteAction := scaContinue;
  if length(FoldInfo) = 0 then PasteAction := scaPlainText;
  PMode :=  SelectionMode;
  if assigned(FOnCutCopy) then begin
    FOnCutCopy(self, SText, PMode, FBlockSelection.FirstLineBytePos, PasteAction);
    if PasteAction = scaAbort then
      exit;;
  end;

  if SText = '' then exit;
  Clipboard.Clear;
  ClipHelper := TSynClipboardStream.Create;
  try
    ClipHelper.Text := SText;
    ClipHelper.SelectionMode := PMode; // TODO if scaPlainText and smNormal, then avoid synedits own clipboard format

    if PasteAction = scaContinue then begin
      // Fold
      if length(FoldInfo) > 0 then
        ClipHelper.AddTag(synClipTagFold, @FoldInfo[1], length(FoldInfo));
    end;

    if not ClipHelper.WriteToClipboard(Clipboard) then begin
      {$IFDEF SynClipboardExceptions}raise ESynEditError.Create('Clipboard copy operation failed');{$ENDIF}
    end;
  finally
    ClipHelper.Free;
  end;
end;

procedure TCustomSynEdit.CopyToClipboard;
var
  FInfo: String;
begin
  if SelAvail then begin
    if eoFoldedCopyPaste in fOptions2 then
      FInfo := FFoldedLinesView.GetFoldDescription(
        FBlockSelection.FirstLineBytePos.Y - 1, FBlockSelection.FirstLineBytePos.X,
        FBlockSelection.LastLineBytePos.Y - 1,  FBlockSelection.LastLineBytePos.X);
    DoCopyToClipboard(SelText, FInfo);
  end;
end;

procedure TCustomSynEdit.CutToClipboard;
var
  FInfo: String;
begin
  if SelAvail then begin
    if eoFoldedCopyPaste in fOptions2 then
      FInfo := FFoldedLinesView.GetFoldDescription(
        FBlockSelection.FirstLineBytePos.Y - 1, FBlockSelection.FirstLineBytePos.X,
        FBlockSelection.LastLineBytePos.Y - 1,  FBlockSelection.LastLineBytePos.X);
    DoCopyToClipboard(SelText, FInfo);
    SetSelTextExternal('');
  end;
end;

procedure TCustomSynEdit.DoTopViewChanged(Sender: TObject);
begin
  FTheLinesView := TSynEditStringsLinked(Sender);

  if FPaintArea = nil then
    exit; // In SynEdit.Create

  FPaintArea.DisplayView := FTheLinesView.DisplayView;
  FCaret.Lines := FTheLinesView;
  FInternalCaret.Lines := FTheLinesView;
  FBlockSelection.Lines := FTheLinesView;
  FInternalBlockSelection.Lines := FTheLinesView;
  FMarkupManager.Lines := FTheLinesView;
  FTextArea.TheLinesView := FTheLinesView;
end;

procedure TCustomSynEdit.SetScrollOnEditLeftOptions(
  AValue: TSynScrollOnEditOptions);
begin
  FScrollOnEditLeftOptions.Assign(AValue);
  RecalcScrollOnEdit(nil);
end;

procedure TCustomSynEdit.SetScrollOnEditRightOptions(
  AValue: TSynScrollOnEditOptions);
begin
  FScrollOnEditRightOptions.Assign(AValue);
  RecalcScrollOnEdit(nil);
end;

constructor TCustomSynEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetInline(True);
  ControlStyle:=ControlStyle+[csOwnedChildrenNotSelectable];
  FScrollBarUpdateLock := 0;
  FPaintLock := 0;
  FStatusChangeLock := 0;
  FUndoBlockAtPaintLock := 0;
  FRecalcCharsAndLinesLock := 0;

  FStatusChangedList := TSynStatusChangedHandlerList.Create;
  FPaintEventHandlerList := TSynPaintEventHandlerList.Create;
  FScrollEventHandlerList := TSynScrollEventHandlerList.Create;

  FDefaultBeautifier := TSynBeautifier.Create(self);
  FBeautifier := FDefaultBeautifier;

  FLines := TSynEditStringList.Create;
  TSynEditStringList(FLines).AttachSynEdit(Self);

  FCaret := TSynEditCaret.Create;
  FCaret.MaxLeftChar := @CurrentMaxLineLen;
  FCaret.AddChangeHandler(@CaretChanged);
  FInternalCaret := TSynEditCaret.Create;
  FInternalCaret.MaxLeftChar := @CurrentMaxLineLen;
  {$ifdef LCLMui}
  FScreenCaretPainterClass{%H-} := TSynEditScreenCaretPainterInternal;
  {$else}
  FScreenCaretPainterClass{%H-} := TSynEditScreenCaretPainterSystem;
  {$endif}

  FTextViewsManager := TSynTextViewsManagerInternal.Create(FLines, @DoTopViewChanged);

  // Create the lines/views
  FTrimmedLinesView := TSynEditStringTrimmingList.Create(fCaret);
  FTextViewsManager.AddTextView(FTrimmedLinesView);

  FDoubleWidthChrLinesView := SynEditStringDoubleWidthChars.Create();
  FTextViewsManager.AddTextView(FDoubleWidthChrLinesView);

  {$IFDEF WithSynExperimentalCharWidth}
  //FSysCharWidthLinesView := TSynEditStringSystemWidthChars.Create(FDoubleWidthChrLinesView, Self.Canvas);
  FSysCharWidthLinesView := TSynEditStringSystemWidthChars.Create(Self.Canvas);
  FTextViewsManager.AddTextView(FSysCharWidthLinesView);

  FBidiChrLinesView := TSynEditStringBidiChars.Create();
  FTextViewsManager.AddTextView(FBidiChrLinesView);

  FTabbedLinesView := TSynEditStringTabExpander.Create();
  FTextViewsManager.AddTextView(FTabbedLinesView);
  {$ELSE}

  {$IFnDEF WithOutSynBiDi}
  FBidiChrLinesView := TSynEditStringBidiChars.Create();
  FTextViewsManager.AddTextView(FBidiChrLinesView);
  {$ENDIF}

  // ftab, currently has LengthOfLongestLine, therefore must be after DoubleWidthChar
  FTabbedLinesView := TSynEditStringTabExpander.Create();
  FTextViewsManager.AddTextView(FTabbedLinesView);

  {$ENDIF} // WithSynExperimentalCharWidth

  FFoldedLinesView := TSynEditFoldedView.Create(Self, fCaret);
  FFoldedLinesView.AddChangeHandler(senrLineMappingChanged, @FoldChanged);

  // External Accessor
  FStrings := TSynEditLines.Create(TSynEditStringList(FLines), @MarkTextAsSaved);

  FCaret.Lines := FTheLinesView;
  FInternalCaret.Lines := FTheLinesView;
  FFontDummy := TFont.Create;
  FOldWidth := -1;
  FOldHeight := -1;

  with FTheLinesView do begin
    AddChangeHandler(senrLineCount, @LineCountChanged);
    AddChangeHandler(senrLineChange, @LineTextChanged);
    AddChangeHandler(senrHighlightChanged, @DoHighlightChanged);
    AddNotifyHandler(senrCleared, @ListCleared);
    AddNotifyHandler(senrUndoRedoAdded, @Self.UndoRedoAdded);
    AddNotifyHandler(senrModifiedChanged, @ModifiedChanged);
    AddNotifyHandler(senrIncPaintLock, @DoIncPaintLock);
    AddNotifyHandler(senrDecPaintLock, @DoDecPaintLock);
    AddNotifyHandler(senrIncOwnedPaintLock, @DoIncForeignPaintLock);
    AddNotifyHandler(senrDecOwnedPaintLock, @DoDecForeignPaintLock);
  end;

  FScreenCaret := TSynEditScreenCaret.Create(Self);
  FScreenCaret.OnExtraLineCharsChanged := @ExtraLineCharsChanged;

  FUndoList := TSynEditStringList(fLines).UndoList;
  FRedoList := TSynEditStringList(fLines).RedoList;
  FUndoList.OnNeedCaretUndo := @GetCaretUndo;
  {$IFDEF SynUndoDebugCalls}
  fUndoList.DebugName := 'UNDO';
  fRedoList.DebugName := 'REDO';
  {$ENDIF}

  FBlockSelection := TSynEditSelection.Create(FTheLinesView, True);
  FBlockSelection.Caret := FCaret;
  FBlockSelection.InvalidateLinesMethod := @InvalidateLines;
  FBlockSelection.AddChangeHandler(@DoBlockSelectionChanged);

  FInternalBlockSelection := TSynEditSelection.Create(FTheLinesView, False);
  FInternalBlockSelection.InvalidateLinesMethod := @InvalidateLines;
  // No need for caret, on interanl block

  FWordBreaker := TSynWordBreaker.Create;
  FScrollOnEditLeftOptions  := TSynScrollOnEditLeftOptions.Create;
  FScrollOnEditLeftOptions.OnChange := @RecalcScrollOnEdit;
  FScrollOnEditRightOptions := TSynScrollOnEditRightOptions.Create;
  FScrollOnEditRightOptions.OnChange := @RecalcScrollOnEdit;

  RecreateMarkList;

  fTextDrawer := TheTextDrawer.Create([fsBold], fFontDummy);
  {$IFDEF WithSynExperimentalCharWidth}
  FSysCharWidthLinesView.TextDrawer := fTextDrawer;
  {$ENDIF} // WithSynExperimentalCharWidth
  FPaintLineColor := TSynSelectedColor.Create;
  FPaintLineColor2 := TSynSelectedColor.Create;

  FLeftGutter := CreateGutter(self, gsLeft, FTextDrawer);
  FLeftGutter.RegisterChangeHandler(@GutterChanged);
  FLeftGutter.RegisterResizeHandler(@GutterResized);
  FLeftGutter.DoAutoSize;
  FRightGutter := CreateGutter(self, gsRight, FTextDrawer);
  FRightGutter.RegisterChangeHandler(@GutterChanged);
  FRightGutter.RegisterResizeHandler(@GutterResized);
  FRightGutter.DoAutoSize;

  ControlStyle := ControlStyle + [csOpaque, csSetCaption, csTripleClicks, csQuadClicks];
  Height := 150;
  Width := 200;
  FTextCursor := crIBeam;
  FOffTextCursor := crDefault;
  FOverrideCursor := crDefault;
  inherited Cursor := FTextCursor;
  fPlugins := TList.Create;
  FHookedKeyTranslationList := TSynHookedKeyTranslationList.Create;
  FUndoRedoItemHandlerList := TSynUndoRedoItemHandlerList.Create;

  // needed before setting color
  fMarkupHighCaret := TSynEditMarkupHighlightAllCaret.Create(self);
  fMarkupHighCaret.Selection := FBlockSelection;
  fMarkupHighAll   := TSynEditMarkupHighlightAll.Create(self);
  fMarkupBracket   := TSynEditMarkupBracket.Create(self);
  fMarkupWordGroup := TSynEditMarkupWordGroup.Create(self);
  fMarkupCtrlMouse := TSynEditMarkupCtrlMouseLink.Create(self);
  fMarkupSpecialLine := TSynEditMarkupSpecialLine.Create(self);
  fMarkupSelection := TSynEditMarkupSelection.Create(self, FBlockSelection);
  fMarkupSpecialChar := TSynEditMarkupSpecialChar.Create(self);

  fMarkupSelection.MarkupInfoSeletion.SetAllPriorities(50);

  fMarkupManager := TSynEditMarkupManager.Create(self);
  fMarkupManager.AddMarkUp(fMarkupSpecialChar);
  fMarkupManager.AddMarkUp(fMarkupSpecialLine);
  fMarkupManager.AddMarkUp(fMarkupHighCaret);
  fMarkupManager.AddMarkUp(fMarkupHighAll);
  fMarkupManager.AddMarkUp(fMarkupCtrlMouse);
  fMarkupManager.AddMarkUp(fMarkupBracket);
  fMarkupManager.AddMarkUp(fMarkupWordGroup);
  fMarkupManager.AddMarkUp(fMarkupSelection);
  fMarkupManager.Lines := FTheLinesView;
  fMarkupManager.Caret := FCaret;
  fMarkupManager.InvalidateLinesMethod := @InvalidateLines;

  {$IFDEF WinIME}
  {$IFDEF WinIMEFull}
  FImeHandler := LazSynImeFull.Create(Self);
  {$ELSE}
  FImeHandler := LazSynImeSimple.Create(Self);
  LazSynImeSimple(FImeHandler).TextDrawer := FTextDrawer;
  {$ENDIF}
  FImeHandler.InvalidateLinesMethod := @InvalidateLines;
  {$ENDIF}
  {$IFDEF Gtk2IME}
  FImeHandler := LazSynImeGtk2 .Create(Self);
  FImeHandler.InvalidateLinesMethod := @InvalidateLines;
  {$ENDIF}

  fFontDummy.Name := SynDefaultFontName;
  fFontDummy.Height := SynDefaultFontHeight;
  fFontDummy.Pitch := SynDefaultFontPitch;
  fFontDummy.Quality := SynDefaultFontQuality;
  FLastSetFontSize := fFontDummy.Height;
  FLastMouseLocation.LastMouseCaret := Point(-1,-1);
  FLastMouseLocation.LastMousePoint := Point(-1,-1);
  fBlockIndent := 2;

  FTextArea := TLazSynTextArea.Create(Self, FTextDrawer);
  FTextArea.RightEdgeVisible := not(eoHideRightMargin in SYNEDIT_DEFAULT_OPTIONS);
  FTextArea.ExtraCharSpacing := 0;
  FTextArea.ExtraLineSpacing := 0;
  FTextArea.MarkupManager := fMarkupManager;
  FTextArea.TheLinesView := FTheLinesView;
  FTextArea.Highlighter := nil;
  FTextArea.OnStatusChange := @StatusChangedEx;

  FLeftGutterArea := TLazSynGutterArea.Create(Self);
  FLeftGutterArea.TextArea := FTextArea;
  FLeftGutterArea.Gutter := FLeftGutter;

  FRightGutterArea := TLazSynGutterArea.Create(Self);
  FRightGutterArea.TextArea := FTextArea;
  FRightGutterArea.Gutter := FRightGutter;

  FPaintArea := TLazSynSurfaceManager.Create(Self);
  FPaintArea.TextArea := FTextArea;
  FPaintArea.LeftGutterArea := FLeftGutterArea;
  FPaintArea.RightGutterArea := FRightGutterArea;
  FPaintArea.DisplayView := FTheLinesView.DisplayView;

  Color := clWhite;
  Font.Assign(fFontDummy);
  Font.OnChange := @FontChanged;
  FontChanged(nil);
  ParentFont := False;
  ParentColor := False;
  TabStop := True;
  fInserting := True;
  fMaxLeftChar := 1024;
  ScrollBars := ssBoth;
  BorderStyle := bsSingle;
  fInsertCaret := ctVerticalLine;
  fOverwriteCaret := ctBlock;
  FKeystrokes := TSynEditKeyStrokes.Create(Self);
  FCurrentComboKeyStrokes := nil;
  if assigned(Owner) and not (csLoading in Owner.ComponentState) then begin
    SetDefaultKeystrokes;
  end;

  FMouseActions     := TSynEditMouseGlobalActions.Create(Self);
  FMouseSelActions  := TSynEditMouseSelActions.Create(Self);
  FMouseTextActions := TSynEditMouseTextActions.Create(Self);
  FMouseActionSearchHandlerList := TSynEditMouseActionSearchList.Create;
  FMouseActionExecHandlerList  := TSynEditMouseActionExecList.Create;

  fWantTabs := True;
  fTabWidth := 8;
  FOldTopView := 1;
  FFoldedLinesView.TopLine := 1;
  // find / replace
  fTSearch := TSynEditSearch.Create;
  FOptions := SYNEDIT_DEFAULT_OPTIONS;
  FOptions2 := SYNEDIT_DEFAULT_OPTIONS2;
  FShareOptions := SYNEDIT_DEFAULT_SHARE_OPTIONS;
  FVisibleSpecialChars := SYNEDIT_DEFAULT_VISIBLESPECIALCHARS;
  fMarkupSpecialChar.VisibleSpecialChars := SYNEDIT_DEFAULT_VISIBLESPECIALCHARS;
  UpdateOptions;
  UpdateOptions2;
  UpdateMouseOptions;
  UpdateCaret;
  fScrollTimer := TTimer.Create(Self);
  fScrollTimer.Enabled := False;
  fScrollTimer.Interval := 100;
  fScrollTimer.OnTimer := @ScrollTimerHandler;

  // Accessibility
  AccessibleRole := larTextEditorMultiline;
  AccessibleValue := Self.Text;
  AccessibleDescription := 'source code editor';
end;

function TCustomSynEdit.GetChildOwner: TComponent;
begin
  result := self;
end;

procedure TCustomSynEdit.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
  if root = self then begin
    Proc(FLeftGutter.Parts);
    // only save right gutter, if it has gutter-parts
    // move to parts-class
    if FRightGutter.Parts.Count > 0 then
      Proc(FRightGutter.Parts);
  end;
end;

procedure TCustomSynEdit.CreateParams(var Params: TCreateParams);
(*
const
  ScrollBar: array[TScrollStyle] of DWORD = (0, WS_HSCROLL, WS_VSCROLL,
    WS_HSCROLL or WS_VSCROLL, WS_HSCROLL, WS_VSCROLL, WS_HSCROLL or WS_VSCROLL);
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
  ClassStylesOff = CS_VREDRAW or CS_HREDRAW;
*)
begin
  inherited CreateParams(Params);
(*
  with Params do begin
    {$IFOPT R+}{$DEFINE RangeCheckOn}{$R-}{$ENDIF}
    WindowClass.Style := WindowClass.Style and not Cardinal(ClassStylesOff);
    Style := Style or ScrollBar[FScrollBars] or BorderStyles[BorderStyle]
      or WS_CLIPCHILDREN;
    {$IFDEF RangeCheckOn}{$R+}{$ENDIF}
    if NewStyleControls and (BorderStyle = bsSingle) then begin
      Style := Style and not Cardinal(WS_BORDER);
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
*)
end;

procedure TCustomSynEdit.IncPaintLock;
begin
  if FIsInDecPaintLock then exit;
  if (PaintLockOwner = nil) then begin
    PaintLockOwner := Self;
    FLines.SendNotification(senrIncOwnedPaintLock, Self);  // DoIncForeignPaintLock
  end;
  inc(FPaintLockOwnerCnt);
  if FPaintLockOwnerCnt = 1 then
    FLines.BeginUpdate(Self);
end;

procedure TCustomSynEdit.DecPaintLock;
begin
  if FIsInDecPaintLock then exit;
  if FPaintLockOwnerCnt = 1 then
    FLines.EndUpdate(Self);
  dec(FPaintLockOwnerCnt);
  if (PaintLockOwner = Self) and (FPaintLockOwnerCnt = 0) then begin
    FLines.SendNotification(senrDecOwnedPaintLock, Self);  // DoDecForeignPaintLock
    PaintLockOwner := nil;
  end;
end;

procedure TCustomSynEdit.DoIncForeignPaintLock(Sender: TObject);
begin
  if Sender = Self then exit;
  FCaret.IncAutoMoveOnEdit;
  FBlockSelection.IncPersistentLock;
end;

procedure TCustomSynEdit.DoDecForeignPaintLock(Sender: TObject);
begin
  if Sender = Self then exit;
  FBlockSelection.DecPersistentLock;
  FCaret.DecAutoMoveOnEdit;
end;

procedure TCustomSynEdit.SetUpdateState(NewUpdating: Boolean; Sender: TObject);
begin
  if assigned(FOnChangeUpdating) then
    FOnChangeUpdating(Self, NewUpdating);
end;

procedure TCustomSynEdit.IncStatusChangeLock;
begin
  inc(FStatusChangeLock);
end;

procedure TCustomSynEdit.DecStatusChangeLock;
begin
  dec(FStatusChangeLock);
  if FStatusChangeLock = 0 then
    StatusChanged([]);
end;

procedure TCustomSynEdit.DoIncPaintLock(Sender: TObject);
begin
  if FIsInDecPaintLock then exit;
  if FPaintLock = 0 then begin
    SetUpdateState(True, Self);
    FInvalidateRect := Rect(-1, -1, -2, -2);
    FOldTopView := TopView;
    FLastTextChangeStamp := TSynEditStringList(FLines).TextChangeStamp;
    FMarkupManager.IncPaintLock;
  end;
  inc(FPaintLock);
  FFoldedLinesView.Lock; //DecPaintLock triggers ScanRanges, and folds must wait
  FTrimmedLinesView.Lock; // Lock before caret
  FBlockSelection.Lock;
  FCaret.Lock;
  FScreenCaret.Lock;
end;

procedure TCustomSynEdit.DoDecPaintLock(Sender: TObject);
begin
  if FIsInDecPaintLock then exit;
  FIsInDecPaintLock := True;
  try
    if (FUndoBlockAtPaintLock >= FPaintLock) then begin
      if (FUndoBlockAtPaintLock > FPaintLock) then
        debugln(['***** SYNEDIT: Fixing auto-undo-block FUndoBlockAtPaintLock=',FUndoBlockAtPaintLock,' FPaintLock=',FPaintLock]);
      FUndoBlockAtPaintLock := 0;
      EndUndoBlock{$IFDEF SynUndoDebugBeginEnd}('TCustomSynEdit.DoDecPaintLock'){$ENDIF};
    end;

    FCaret.Unlock;            // Maybe after FFoldedLinesView
    FBlockSelection.Unlock;
    // FTrimmedLinesView sets the highlighter to modified. Until fixed, must be done before ScanRanges
    FTrimmedLinesView.UnLock; // Must be unlocked after caret // May Change lines

    if (FPaintLock=1) and HandleAllocated then begin
      ScanRanges(FLastTextChangeStamp <> TSynEditStringList(FLines).TextChangeStamp);
      if sfAfterLoadFromFileNeeded in fStateFlags then
        AfterLoadFromFile;
      if FChangedLinesStart > 0 then begin
        InvalidateLines(FChangedLinesStart, FChangedLinesEnd);
        InvalidateGutterLines(FChangedLinesStart, FChangedLinesEnd);
      end;
      FChangedLinesStart:=0;
      FChangedLinesEnd:=0;
      FChangedLinesDiff:=0;
    end;

    // When fixed FCaret, FBlockSelection, FTrimmedLinesView can move here
    FFoldedLinesView.UnLock;  // after ScanRanges, but before UpdateCaret
    (* FFoldedLinesView.UnLock
       Any unfold (caused by caret move) will be done (deferred) in UnLock.
       UpdateCaret may call MoveCaretToVisibleArea (which depends on what is folded)
       Therefore UnLock must be called before UpdateCaret

       Caret.Unlock must be done before UpdateCaret, because it sends the events
         to FFoldedLinesView which triggers any unfold.
    *)

    Dec(FPaintLock);
    if (FPaintLock = 0) and HandleAllocated then begin
      ScrollAfterTopLineChanged;
      if sfScrollbarChanged in fStateFlags then
        UpdateScrollbars;
      // must be past UpdateScrollbars; but before UpdateCaret (for ScrollBar-Auto-show)
      if sfEnsureCursorPos in fStateFlags then
        EnsureCursorPosVisible;              // TODO: This may call SetTopLine, change order
                                             // This does Paintlock, should be before final decrease
      // Must be after EnsureCursorPosVisible (as it does MoveCaretToVisibleArea)
      if FCaret.LinePos > Max(FLines.Count, 1) then
        FCaret.LinePos := Max(FLines.Count, 1);
      if sfCaretChanged in fStateFlags then
        UpdateCaret;
      //if sfScrollbarChanged in fStateFlags then
      //  UpdateScrollbars;
      fMarkupHighCaret.CheckState; // Todo: need a global lock, including the markup
                                   // Todo: Markup can do invalidation, should be before ScrollAfterTopLineChanged;
    end;
    if (FPaintLock = 0) then begin
      FMarkupManager.DecPaintLock;
      FBlockSelection.AutoExtend := False;
      if fStatusChanges <> [] then
        DoOnStatusChange(fStatusChanges);
    end;
  finally
    FScreenCaret.UnLock;
    FIsInDecPaintLock := False;
    if FPaintLock = 0 then begin
      SetUpdateState(False, Self);
      if FInvalidateRect.Bottom >= FInvalidateRect.Top then begin
        InvalidateRect(Handle, @FInvalidateRect, False);
        {$IFDEF SynCheckPaintLock}
        debugln('Returning from Paintlock, wich had Paint called while active');
        DumpStack;
        {$ENDIF}
      end;
      if sfSelChanged in FStateFlags then
        SelAvailChange(nil);
    end;
  end;
end;

destructor TCustomSynEdit.Destroy;
var
  i: integer;
  p: TList;
begin
  {$IFDEF SynCheckPaintLock}
  if (FPaintLock > 0) then begin
    debugln(['TCustomSynEdit.Destroy: Paintlock=', FPaintLock, ' FInvalidateRect=', dbgs(FInvalidateRect)]);
    DumpStack;
  end;
  {$ENDIF}
  Application.RemoveOnIdleHandler(@IdleScanRanges);
  SurrenderPrimarySelection;
  Highlighter := nil;
  Beautifier:=nil;

  if fPlugins <> nil then begin
    p := FPlugins;
    FPlugins := nil;
    for i := p.Count - 1 downto 0 do
      TLazSynEditPlugin(p[i]).DoEditorDestroyed(Self);
    p.Free;
  end;

  // free listeners while other fields are still valid
  if Assigned(fHookedCommandHandlers) then begin
    for i := 0 to fHookedCommandHandlers.Count - 1 do
      THookedCommandHandlerEntry(fHookedCommandHandlers[i]).Free;
    FreeAndNil(fHookedCommandHandlers);
  end;

  FLeftGutter.UnRegisterChangeHandler(@GutterChanged);
  FLeftGutter.UnRegisterResizeHandler(@GutterResized);
  FRightGutter.UnRegisterChangeHandler(@GutterChanged);
  FRightGutter.UnRegisterResizeHandler(@GutterResized);

  FreeAndNil(FHookedKeyTranslationList);
  FreeAndNil(FUndoRedoItemHandlerList);
  fHookedCommandHandlers:=nil;
  fPlugins:=nil;
  FCaret.Lines := nil;
  FInternalCaret.Lines := nil;
  FMarkList.UnRegisterChangeHandler(@MarkListChange);
  FreeAndNil(FPaintArea);
  FreeAndNil(FLeftGutterArea);
  FreeAndNil(FRightGutterArea);
  FreeAndNil(FTextArea);
  FreeAndNil(fTSearch);
  FreeAndNil(FImeHandler);
  FreeAndNil(fMarkupManager);
  FreeAndNil(fKeyStrokes);
  FreeAndNil(FMouseActionSearchHandlerList);
  FreeAndNil(FMouseActionExecHandlerList);
  FreeAndNil(FMouseActions);
  FreeAndNil(FMouseSelActions);
  FreeAndNil(FMouseTextActions);
  FreeAndNil(FLeftGutter);
  FreeAndNil(FRightGutter);
  FreeAndNil(FPaintLineColor);
  FreeAndNil(FPaintLineColor2);
  FreeAndNil(fTextDrawer);
  FreeAndNil(fFontDummy);
  DestroyMarkList; // before detach from FLines
  FreeAndNil(FWordBreaker);
  FreeAndNil(FInternalBlockSelection);
  FreeAndNil(FBlockSelection);
  FreeAndNil(FStrings);
  FreeAndNil(FTextViewsManager);
  TSynEditStringList(FLines).DetachSynEdit(Self);
  if TSynEditStringList(FLines).AttachedSynEditCount = 0 then
    FreeAndNil(fLines);
  FreeAndNil(fCaret);
  FreeAndNil(fInternalCaret);
  FreeAndNil(FScreenCaret);
  FreeAndNil(FStatusChangedList);
  FreeAndNil(FPaintEventHandlerList);
  FreeAndNil(FScrollEventHandlerList);
  FBeautifier := nil;
  FreeAndNil(FDefaultBeautifier);
  FreeAndNil(FKeyDownEventList);
  FreeAndNil(FKeyUpEventList);
  FreeAndNil(FMouseDownEventList);
  FreeAndNil(FKeyPressEventList);
  FreeAndNil(FQueryMouseCursorList);
  FreeAndNil(FUtf8KeyPressEventList);
  FreeAndNil(FScrollOnEditLeftOptions);
  FreeAndNil(FScrollOnEditRightOptions);

  inherited Destroy;
end;

function TCustomSynEdit.GetBlockBegin: TPoint;
begin
  Result := FBlockSelection.FirstLineBytePos;
end;

function TCustomSynEdit.GetBlockEnd: TPoint;
begin
  Result := FBlockSelection.LastLineBytePos;
end;

function TCustomSynEdit.GetBracketHighlightStyle: TSynEditBracketHighlightStyle;
begin
  Result := fMarkupBracket.HighlightStyle;
end;

function TCustomSynEdit.CaretXPix: Integer;
var
  p: TPoint;
begin
  p := FCaret.ViewedLineCharPos;
  p.y := p.y - TopView + 1;
  Result := ScreenXYToPixels(p).X;
end;

function TCustomSynEdit.CaretYPix: Integer;
var
  p: TPoint;
begin
  p := FCaret.ViewedLineCharPos;
  p.y := p.y - TopView + 1;
  Result := ScreenXYToPixels(p).Y;
end;

procedure TCustomSynEdit.FontChanged(Sender: TObject);
begin // TODO: inherited ?
  FPaintArea.ForegroundColor := Font.Color;
  FLastSetFontSize := Font.Height;
  RecalcCharExtent;
end;

function TCustomSynEdit.GetTextBuffer: TSynEditStrings;
begin
  Result := FLines;
end;

function TCustomSynEdit.GetTextViewsManager: TSynTextViewsManager;
begin
  Result := FTextViewsManager;
end;

function TCustomSynEdit.GetLineText: string;
begin
  Result := FCaret.LineText;
end;

function TCustomSynEdit.GetMarkupByClass(Index: TSynEditMarkupClass): TSynEditMarkup;
begin
  Result := fMarkupManager.MarkupByClass[Index];
end;

function TCustomSynEdit.GetHighlightAllColor : TSynSelectedColor;
begin
  result := fMarkupHighAll.MarkupInfo;
end;

function TCustomSynEdit.GetHighlighterObj: TObject;
begin
  Result := fHighlighter;
end;

function TCustomSynEdit.GetIncrementColor : TSynSelectedColor;
begin
  result := fMarkupSelection.MarkupInfoIncr;
end;

function TCustomSynEdit.GetLineHighlightColor: TSynSelectedColor;
begin
  Result := fMarkupSpecialLine.MarkupLineHighlightInfo;
end;

function TCustomSynEdit.GetOnGutterClick : TGutterClickEvent;
begin
  Result := FLeftGutter.OnGutterClick;
end;

function TCustomSynEdit.GetSelectedColor : TSynSelectedColor;
begin
  result := fMarkupSelection.MarkupInfoSeletion;
end;

procedure TCustomSynEdit.SetSelectedColor(const AValue : TSynSelectedColor);
begin
  fMarkupSelection.MarkupInfoSeletion.Assign(AValue);
end;

procedure TCustomSynEdit.SetSpecialLineColors(const AValue : TSpecialLineColorsEvent);
begin
  fOnSpecialLineColors:=AValue;
  fMarkupSpecialLine.OnSpecialLineColors := AValue;
end;

procedure TCustomSynEdit.SetSpecialLineMarkup(const AValue : TSpecialLineMarkupEvent);
begin
  FOnSpecialLineMarkup:=AValue;
  fMarkupSpecialLine.OnSpecialLineMarkup := AValue;
end;

function TCustomSynEdit.GetBracketMatchColor : TSynSelectedColor;
begin
  Result := fMarkupBracket.MarkupInfo;
end;

function TCustomSynEdit.GetMouseLinkColor : TSynSelectedColor;
begin
  Result := fMarkupCtrlMouse.MarkupInfo;
end;

function TCustomSynEdit.GetTrimSpaceType: TSynEditStringTrimmingType;
begin
  Result := FTrimmedLinesView.TrimType;
end;

function TCustomSynEdit.GetViewedTextBuffer: TSynEditStringsLinked;
begin
  Result := FTheLinesView;
end;

function TCustomSynEdit.GetFoldedTextBuffer: TObject;
begin
  Result := FFoldedLinesView;
end;

procedure TCustomSynEdit.SetBracketHighlightStyle(const AValue: TSynEditBracketHighlightStyle);
begin
  fMarkupBracket.HighlightStyle := AValue;
end;

procedure TCustomSynEdit.SetOnGutterClick(const AValue : TGutterClickEvent);
begin
  FLeftGutter.OnGutterClick := AValue; // Todo: the IDE uses this for the left gutter only
end;

procedure TCustomSynEdit.SetUseIncrementalColor(const AValue : Boolean);
begin
  fMarkupSelection.UseIncrementalColor:=AValue;
end;

function TCustomSynEdit.GetCharLen(const Line: string; CharStartPos: integer): integer;
begin
  Result := FLines.LogicPosAddChars(Line, CharStartPos, 1, True) - CharStartPos;
end;

function TCustomSynEdit.GetLogicalCaretXY: TPoint;
begin
  Result := FCaret.LineBytePos;
end;

function TCustomSynEdit.GetMarksObj: TObject;
begin
  Result := FMarkList;
end;

procedure TCustomSynEdit.SetLogicalCaretXY(const NewLogCaretXY: TPoint);
begin
  FCaret.ChangeOnTouch;
  FCaret.LineBytePos := NewLogCaretXY;
end;

procedure TCustomSynEdit.SetBeautifier(NewBeautifier: TSynCustomBeautifier);
begin
  if fBeautifier = NewBeautifier then exit;
  if NewBeautifier = nil then
    fBeautifier := FDefaultBeautifier
  else
    fBeautifier := NewBeautifier;
end;

procedure TCustomSynEdit.SetTrimSpaceType(const AValue: TSynEditStringTrimmingType);
begin
  FTrimmedLinesView.TrimType := AValue;
end;

function TCustomSynEdit.SynGetText: string;
begin
  Result := fLines.Text;
end;

function TCustomSynEdit.RealGetText: TCaption;
begin
  if FLines<>nil then
    Result := FLines.Text
  else
    Result := '';
end;

procedure TCustomSynEdit.SetImeHandler(AValue: LazSynIme);
begin
  if FImeHandler = AValue then Exit;
  FreeAndNil(FImeHandler);
  FImeHandler := AValue;
end;

{$ifdef Gtk2IME}
procedure TCustomSynEdit.GTK_IMComposition(var Message: TMessage);
begin
  FImeHandler.WMImeComposition(Message);
end;
{$endif}

{$IFDEF WinIME}
procedure TCustomSynEdit.WMImeRequest(var Msg: TMessage);
begin
  FImeHandler.WMImeRequest(Msg);
end;

procedure TCustomSynEdit.WMImeNotify(var Msg: TMessage);
begin
    FImeHandler.WMImeNotify(Msg);
end;

procedure TCustomSynEdit.WMImeComposition(var Msg: TMessage);
begin
  FImeHandler.WMImeComposition(Msg);
end;

procedure TCustomSynEdit.WMImeStartComposition(var Msg: TMessage);
begin
  FImeHandler.WMImeStartComposition(Msg);
end;

procedure TCustomSynEdit.WMImeEndComposition(var Msg: TMessage);
begin
  FImeHandler.WMImeEndComposition(Msg);
end;
{$ENDIF}

procedure TCustomSynEdit.InvalidateGutter;
begin
  InvalidateGutterLines(-1, -1);
end;

procedure TCustomSynEdit.InvalidateGutterLines(FirstLine, LastLine: integer);   // Todo: move to gutter
begin
  if sfPainting in fStateFlags then exit;
  if Visible and HandleAllocated then begin
    {$IFDEF VerboseSynEditInvalidate}
    DebugLnEnter(['TCustomSynEdit.InvalidateGutterLines ',DbgSName(self), ' FirstLine=',FirstLine, ' LastLine=',LastLine]);
    {$ENDIF}
    {$IFDEF Windows10GhostCaretIssue}
    if (FLeftGutter.Visible or FRightGutter.Visible) and (sfCaretChanged in fStateFlags) then
      InvalidateLines(FirstLine, LastLine);
    {$ENDIF}
    if (FirstLine = -1) and (LastLine = -1) then begin
      FPaintArea.InvalidateGutterLines(-1, -1);
    end else begin
      if (LastLine <> -1) and (LastLine < FirstLine) then
        SwapInt(FirstLine, LastLine);

      if FPaintLock > 0 then begin
        // pretend we haven't scrolled
        FirstLine := FirstLine - (FOldTopView - TopView);
        LastLine  := LastLine - (FOldTopView - TopView);
      end;
      FPaintArea.InvalidateGutterLines(FirstLine-1, LastLine-1);
    end;
    {$IFDEF VerboseSynEditInvalidate}
    DebugLnExit(['TCustomSynEdit.InvalidateGutterLines ',DbgSName(self)]);
    {$ENDIF}
    end;
end;

procedure TCustomSynEdit.InvalidateLines(FirstLine, LastLine: integer);
begin
  if sfPainting in fStateFlags then exit;
  if Visible and HandleAllocated then begin
    {$IFDEF VerboseSynEditInvalidate}
    DebugLnEnter(['TCustomSynEdit.InvalidateTextLines ',DbgSName(self), ' FirstLine=',FirstLine, ' LastLine=',LastLine]);
    {$ENDIF}
    if (FirstLine = -1) and (LastLine = -1) then begin
      FPaintArea.InvalidateTextLines(-1, -1);
    end else begin
      if (LastLine <> -1) and (LastLine < FirstLine) then
        SwapInt(FirstLine, LastLine);

      if FPaintLock > 0 then begin
        // pretend we haven't scrolled
        FirstLine := FirstLine - (FOldTopView - TopView);
        LastLine  := LastLine - (FOldTopView - TopView);
      end;
      FPaintArea.InvalidateTextLines(FirstLine-1, LastLine-1);
    end;
    {$IFDEF VerboseSynEditInvalidate}
    DebugLnExit(['TCustomSynEdit.InvalidateTextLines ',DbgSName(self)]);
    {$ENDIF}
  end;
end;

procedure TCustomSynEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
  Data: pointer;
  C: char;
  Cmd: TSynEditorCommand;
  IsStartOfCombo, Handled: boolean;
begin
  FInMouseClickEvent := False;
  {$IFDEF VerboseKeys}
  DebugLn('[TCustomSynEdit.KeyDown] ',dbgs(Key),' ',dbgs(Shift));
  {$ENDIF}

  if (not WantTabs) and (Key = VK_TAB) and ((Shift - [ssShift]) = []) then begin
    inherited KeyDown(Key, Shift);
    exit;
  end;

  // Run even before OnKeyDown
  if FKeyDownEventList <> nil then
    FKeyDownEventList.CallKeyDownHandlers(Self, Key, Shift);
  if Key=0 then exit;

  inherited;
  if assigned(fMarkupCtrlMouse) then
    fMarkupCtrlMouse.UpdateCtrlState(Shift);

  if Key in [VK_SHIFT, VK_CONTROL, VK_MENU,
             VK_LSHIFT, VK_LCONTROL, VK_LMENU,
             VK_RSHIFT, VK_RCONTROL, VK_RMENU,
             VK_LWIN, VK_RWIN]
  then
    exit;

  Data := nil;
  C := #0;
  try
    // If the translations requires Data, memory will be allocated for it via a
    // GetMem call.  The client must call FreeMem on Data if it is not NIL.
    IsStartOfCombo := False;
    Handled := False;

    // Check 2nd stroke in SynEdit.KeyStrokes
    if FCurrentComboKeyStrokes <> nil then begin
      // Run hooked first, it might want to "steal" the key(s)
      Cmd := 0;
      FHookedKeyTranslationList.CallHookedKeyTranslationHandlers(self,
        Key, Shift, Data, IsStartOfCombo, Handled, Cmd, FCurrentComboKeyStrokes);

      if not Handled then begin
        Cmd := KeyStrokes.FindKeycodeEx(Key, Shift, Data, IsStartOfCombo, True, FCurrentComboKeyStrokes);
        if IsStartOfCombo then
          FCurrentComboKeyStrokes := FKeyStrokes;
        Handled := (Cmd <> ecNone) or IsStartOfCombo;
      end;

      if not IsStartOfCombo then begin
        FCurrentComboKeyStrokes.ResetKeyCombo;
        FCurrentComboKeyStrokes := nil;
      end;
    end;
    assert(Handled or (FCurrentComboKeyStrokes=nil), 'FCurrentComboKeyStrokes<>nil, should be handled');

    // Check 1st/single stroke in Hooked KeyStrokes
    if not Handled then begin
      FCurrentComboKeyStrokes := nil;
      FHookedKeyTranslationList.CallHookedKeyTranslationHandlers(self,
        Key, Shift, Data, IsStartOfCombo, Handled, Cmd, FCurrentComboKeyStrokes);
      if (not IsStartOfCombo) and (FCurrentComboKeyStrokes <> nil) then
        FCurrentComboKeyStrokes.ResetKeyCombo; // should not happen
    end;
    // Check 1st/single stroke in SynEdit.KeyStrokes
    if not Handled then begin
      FKeyStrokes.ResetKeyCombo;
      Cmd := KeyStrokes.FindKeycodeEx(Key, Shift, Data, IsStartOfCombo);
      if IsStartOfCombo then
        FCurrentComboKeyStrokes := FKeyStrokes;
    end;

    if Cmd <> ecNone then begin
      // Reset FCurrentComboKeyStrokes => no open combo
      assert(FCurrentComboKeyStrokes=nil, 'FCurrentComboKeyStrokes<>nil, should be ecNone');
      if FCurrentComboKeyStrokes <> nil then
        FCurrentComboKeyStrokes.ResetKeyCombo;
      FCurrentComboKeyStrokes := nil;

      Include(FStateFlags, sfHideCursor);
      LastMouseCaret := Point(-1,-1);                                           // includes update cursor
      //DebugLn(['[TCustomSynEdit.KeyDown] key translated ',cmd]);
      Key := 0; // eat it.
      Include(fStateFlags, sfIgnoreNextChar);
      CommandProcessor(Cmd, C, Data);
    end else if IsStartOfCombo then begin
      // this key could be the start of a two-key-combo shortcut
      Key := 0; // eat it.
      Include(fStateFlags, sfIgnoreNextChar);
    end else
      Exclude(fStateFlags, sfIgnoreNextChar);
  finally
    if Data <> nil then
      FreeMem(Data);
  end;
  UpdateCursor;
  SelAvailChange(nil);
  //DebugLn('[TCustomSynEdit.KeyDown] END ',dbgs(Key),' ',dbgs(Shift));
end;

procedure TCustomSynEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  {$IFDEF VerboseKeys}
  DebugLn(['[TCustomSynEdit.KeyUp] ',Key
    ,' Shift=',ssShift in Shift,' Ctrl=',ssCtrl in Shift,' Alt=',ssAlt in Shift]);
  {$ENDIF}

  // Run even before OnKeyUp
  if FKeyUpEventList <> nil then
    FKeyUpEventList.CallKeyDownHandlers(Self, Key, Shift);
  if Key=0 then exit;

  inherited KeyUp(Key, Shift);

  if sfIgnoreNextChar in fStateFlags then
    Exclude(FStateFlags, sfIgnoreNextChar);

  if assigned(fMarkupCtrlMouse) then
    fMarkupCtrlMouse.UpdateCtrlState(Shift);
  UpdateCursor;
end;


procedure TCustomSynEdit.Loaded;
begin
  inherited Loaded;
  UpdateCaret;
end;

procedure TCustomSynEdit.UTF8KeyPress(var Key: TUTF8Char);
var OnKeyPressFired : boolean = false;
begin
  if Key='' then exit;

  // Run even before OnKeyPress
  if FUtf8KeyPressEventList <> nil then
    FUtf8KeyPressEventList.CallUtf8KeyPressHandlers(Self, Key);
  if Key='' then exit;

  // don't fire the event if key is to be ignored
  if not (sfIgnoreNextChar in fStateFlags) then begin
    Include(FStateFlags, sfHideCursor);
    if Assigned(OnUTF8KeyPress) then OnUTF8KeyPress(Self, Key);
    // The key will be handled in UTFKeyPress always and KeyPress won't be called
    // so we we fire the OnKeyPress here
    if (ord(key[1])< %11000000) and (key[1]<>#0) and Assigned(OnKeyPress) then begin
      OnKeyPress(Self, Key[1]);
      OnKeyPressFired:= true;//used to prevent from double firing issue #0026444
    end;
    {$IFDEF VerboseKeys}
    DebugLn('TCustomSynEdit.UTF8KeyPress ',DbgSName(Self),' Key="',DbgStr(Key),'" UseUTF8=',dbgs(UseUTF8));
    {$ENDIF}
    CommandProcessor(ecChar, Key, nil);
    // Check if ecChar has handled the Key; Todo: move the condition, in one common place
    if (not ReadOnly or OnKeyPressFired) and ((Key = #13) or (Key >= #32)) and (Key <> #127) then
      Key:='';
  end else begin
    // don't ignore further keys
    Exclude(fStateFlags, sfIgnoreNextChar);
    // Key was handled anyway, so eat it!
    Key:='';
  end;
end;

procedure TCustomSynEdit.KeyPress(var Key: Char);
begin
  if Key=#0 then exit;

  // Run even before OnKeyPress
  if FKeyPressEventList <> nil then
    FKeyPressEventList.CallKeyPressHandlers(Self, Key);
  if Key=#0 then exit;

  // don't fire the event if key is to be ignored
  if not (sfIgnoreNextChar in fStateFlags) then begin
    Include(FStateFlags, sfHideCursor);
    {$IFDEF VerboseKeys}
    DebugLn('TCustomSynEdit.KeyPress ',DbgSName(Self),' Key="',DbgStr(Key),'" UseUTF8=',dbgs(UseUTF8));
    {$ENDIF}
    if Assigned(OnKeyPress) then OnKeyPress(Self, Key);
    CommandProcessor(ecChar, Key, nil);
    // Check if ecChar has handled the Key; Todo: move the condition, in one common place
    if not ReadOnly and ((Key = #13) or (Key >= #32)) and (Key <> #127) then
      Key:=#0;
  end else begin
    // don't ignore further keys
    Exclude(fStateFlags, sfIgnoreNextChar);
    // Key was handled anyway, so eat it!
    Key:=#0;
  end;
end;

function TCustomSynEdit.DoHandleMouseAction(AnActionList: TSynEditMouseActions;
  var AnInfo: TSynEditMouseActionInfo): Boolean;
var
  CaretDone, ResetMouseCapture: Boolean;
  AnAction: TSynEditMouseAction;

  procedure MoveCaret;
  begin
   FCaret.LineCharPos := AnInfo.NewCaret.LineCharPos;
   CaretDone := True;
  end;

  function GetWheelScrollAmount(APageSize: integer): integer;
  const
    WHEEL_DELTA = 120;
    //WHEEL_PAGESCROLL = MAXDWORD;
  var
    WClicks, WLines: Integer;
    IsHoriz: Boolean;
  begin
    IsHoriz := AnInfo.Button in [mbXWheelLeft, mbXWheelRight];
    Inc(FMouseWheelAccumulator[IsHoriz], AnInfo.WheelDelta);
    Inc(FMouseWheelLinesAccumulator[IsHoriz], MinMax(Mouse.WheelScrollLines, 1, APageSize) * AnInfo.WheelDelta);
    WClicks := FMouseWheelAccumulator[IsHoriz] div WHEEL_DELTA;
    WLines  := FMouseWheelLinesAccumulator[IsHoriz] div WHEEL_DELTA;
    dec(FMouseWheelAccumulator[IsHoriz], WClicks * WHEEL_DELTA);
    dec(FMouseWheelLinesAccumulator[IsHoriz], WLines * WHEEL_DELTA);

    case AnAction.Option of
      emcoWheelScrollSystem:
        begin
          Result := Abs(WLines);
        end;
      emcoWheelScrollLines:
        begin
          Result := Abs(WClicks);
          If Result = 0 then
            exit;
          if AnAction.Option2 > 0 then
            Result := Result * AnAction.Option2;
          if (Result > APageSize) then
            Result := APageSize;
          exit;
        end;
      emcoWheelScrollPages:
          Result := Abs(WClicks) * APageSize;
      emcoWheelScrollPagesLessOne:
          Result := Abs(WClicks) * (APageSize - 1);
      else
        begin
          Result := Abs(WLines);
          exit;
        end;
    end;

    If Result = 0 then
      exit;

    if AnAction.Option2 > 0 then
      Result := MulDiv(Result, AnAction.Option2, 100);
    if (Result > APageSize) then
      Result := APageSize;
    if (Result < 1) then
      Result := 1;
  end;

var
  ACommand: TSynEditorMouseCommand;
  ClipHelper: TSynClipboardStream;
  i, j: integer;
  p1, p2: TPoint;
  s: String;
  AnActionResultDummy: TSynEditMouseActionResult;
  DownMisMatch: Boolean;
begin
  AnAction := nil;
  Result := False;
  while not Result do begin
    AnAction := AnActionList.FindCommand(AnInfo, AnAction);

    if AnAction = nil then exit(False);

    if (FConfirmMouseDownMatchAct <> nil) then begin
      // simulated up click at the coordinates of the down click
      if FConfirmMouseDownMatchAct = AnAction then begin
        FConfirmMouseDownMatchFound := True;
        exit(True);
      end;
      if not(crLastDownPosSearchAll in FConfirmMouseDownMatchAct.ButtonUpRestrictions) then
        exit(True);

      continue;
    end;

    if (AnAction.ClickDir = cdUp) and (AnAction.ButtonUpRestrictions - [crAllowFallback] <> []) then
    begin
      DownMisMatch := ( (crLastDownButton in AnAction.ButtonUpRestrictions) and
                        (SynMouseButtonMap[FMouseDownButton] <> AnInfo.Button) ) or
                      ( (crLastDownShift in AnAction.ButtonUpRestrictions) and
                        (FMouseDownShift * [ssShift, ssAlt, ssCtrl, ssMeta, ssSuper, ssHyper, ssAltGr, ssCaps, ssNum, ssScroll]
                         <> AnInfo.Shift * [ssShift, ssAlt, ssCtrl, ssMeta, ssSuper, ssHyper, ssAltGr, ssCaps, ssNum, ssScroll]) ) or
                      ( (crLastDownPosSameLine in AnAction.ButtonUpRestrictions) and
                        (PixelsToRowColumn(Point(fMouseDownX, fMouseDownY)).y <> AnInfo.NewCaret.LinePos) );

      If (not DownMisMatch) and (crLastDownPos in AnAction.ButtonUpRestrictions) then begin
        try
          FConfirmMouseDownMatchAct := AnAction;
          FConfirmMouseDownMatchFound := False;
          // simulate up click at the coordinates of the down click
          FindAndHandleMouseAction(AnInfo.Button, AnInfo.Shift, fMouseDownX, fMouseDownY, AnInfo.CCount, cdUp, AnActionResultDummy);
        finally
          FConfirmMouseDownMatchAct := nil;
        end;
        DownMisMatch := not FConfirmMouseDownMatchFound;
      end;

      If DownMisMatch then
        exit(not(crAllowFallback in AnAction.ButtonUpRestrictions));
    end;


    ACommand := AnAction.Command;
    AnInfo.CaretDone := False;

    // Opening the context menu must not unset the block selection
    // Therefore if a non persistent block is given, it shall ignore the caret move.
    if (ACommand = emcContextMenu) and FBlockSelection.SelAvail and
       not FBlockSelection.Persistent then
    begin
      case AnAction.Option of
        emcoSelectionCaretMoveOutside:
          AnInfo.CaretDone :=
            (CompareCarets(AnInfo.NewCaret.LineBytePos, FBlockSelection.FirstLineBytePos) <= 0) and
            (CompareCarets(AnInfo.NewCaret.LineBytePos, FBlockSelection.LastLineBytePos) >= 0);
        emcoSelectionCaretMoveAlways:
          AnInfo.CaretDone := False;
        else
          AnInfo.CaretDone := True;
      end;
    end;

    // Plugins/External
    Result := FMouseActionExecHandlerList.CallExecHandlers(AnAction, AnInfo);
    // Gutter
    if not Result then
      Result := FLeftGutter.DoHandleMouseAction(AnAction, AnInfo);
    if not Result then
      Result := FRightGutter.DoHandleMouseAction(AnAction, AnInfo);

    if Result then begin
      if (not AnInfo.CaretDone) and AnAction.MoveCaret then
        MoveCaret;
      if (AnAction.IgnoreUpClick) then
        AnInfo.IgnoreUpClick := True;
      exit;
    end;

    Result := True;
    CaretDone := AnInfo.CaretDone;
    ResetMouseCapture := True;

    if (ACommand = emcWheelScrollDown)
    then begin
      // sroll dependant on visible scrollbar / or not at all
      if  (fStateFlags * [sfVertScrollbarVisible, sfHorizScrollbarVisible] = [sfHorizScrollbarVisible])
      then ACommand := emcWheelHorizScrollDown
      else ACommand := emcWheelVertScrollDown;
    end;

    if (ACommand = emcWheelScrollUp)
    then begin
      // sroll dependant on visible scrollbar / or not at all
      if  (fStateFlags * [sfVertScrollbarVisible, sfHorizScrollbarVisible] = [sfHorizScrollbarVisible])
      then ACommand := emcWheelHorizScrollUp
      else ACommand := emcWheelVertScrollUp;
    end;

    case ACommand of
      emcNone: ; // do nothing, but result := true
      emcStartSelections, emcStartColumnSelections, emcStartLineSelections, emcStartLineSelectionsNoneEmpty,
      emcStartSelectTokens, emcStartSelectWords, emcStartSelectLines:
        begin
          FMouseSelectionCmd := emcNone;
          FBlockSelection.AutoExtend := AnAction.Option = emcoSelectionContinue;
          FCaret.ChangeOnTouch;
          MoveCaret;
          FMouseSelectionMode := FBlockSelection.SelectionMode;
          case ACommand of
            emcStartColumnSelections:
              FMouseSelectionMode := smColumn;
            emcStartLineSelections:
                FMouseSelectionMode := smLine;
            emcStartLineSelectionsNoneEmpty: begin
                FMouseSelectionMode := smLine;
                if (AnAction.Option <> emcoSelectionContinue) or (not SelAvail) then
                  FBlockSelection.StartLineBytePos := FCaret.LineBytePos;
                FBlockSelection.ActiveSelectionMode := smLine;
                FBlockSelection.AutoExtend := True;
                FBlockSelection.ForceSingleLineSelected := True;
                FBlockSelection.AutoExtend := AnAction.Option = emcoSelectionContinue;
              end;
            emcStartSelectTokens, emcStartSelectWords, emcStartSelectLines: begin
                FMouseSelectionCmd := ACommand;
                AnInfo.NewCaret.LineCharPos := PixelsToRowColumn(Point(AnInfo.MouseX, AnInfo.MouseY), [scmLimitToLines, scmForceLeftSidePos]);
                s := AnInfo.NewCaret.LineText;
                i := length(s) + 1;
                p1 := AnInfo.NewCaret.LineBytePos;
                if (p1.X >= i) then
                  p1.X := Max(1, i - 1);
                p2 := p1;
                if (AnAction.Option = emcoSelectionContinue) and SelAvail then
                  p1 := FBlockSelection.StartLineBytePos;
                if p2.X = i then begin
                  p2 := Point(1, Min(FTheLinesView.Count, p2.Y + 1));
                end
                else begin
                  case ACommand of
                    emcStartSelectTokens: begin
                        if (AnAction.Option <> emcoSelectionContinue) or (not SelAvail) then
                          p1.X := Max(1, FWordBreaker.PrevBoundary(s, p1.X, True));
                        p2.X := FWordBreaker.NextBoundary(s, p2.X);
                        if p2.X < 1 then p2.X := i;
                      end;
                    emcStartSelectWords: begin
                        if (AnAction.Option <> emcoSelectionContinue) or (not SelAvail) then
                          p1.X := Max(1, Max(FWordBreaker.PrevWordEnd(s, p1.X, True),
                                             FWordBreaker.PrevWordStart(s, p1.X, True)));
                        j := FWordBreaker.NextWordStart(s, p2.X);
                        if j < 1 then j := i;
                        p2.X := FWordBreaker.NextWordEnd(s, p2.X);
                        if p2.X < 1 then p2.X := i;
                        p2.X := Min(p2.X, j);
                      end;
                    emcStartSelectLines: begin
                        if (AnAction.Option <> emcoSelectionContinue) or (not SelAvail) then
                          p1.X := 1;
                        p2 := Point(1, Min(FTheLinesView.Count, p1.Y + 1));
                      end;
                  end;
                end;
                if (AnAction.Option <> emcoSelectionContinue) or (not SelAvail) then
                  FBlockSelection.StartLineBytePos := p1;
                FBlockSelection.AutoExtend := True;
                FCaret.ChangeOnTouch;
                FCaret.LineBytePos := p2;
                FBlockSelection.EndLineBytePos := p2; // caret might be locked
                FBlockSelection.BeginMinimumSelection;
              end;
          end;
          if (AnAction.Option = emcoSelectionContinue) then begin
            // only set ActiveSelectionMode if we continue an existing selection
            // Otherwise we are just setting the caret, selection will start on mouse move
            FBlockSelection.ActiveSelectionMode := FMouseSelectionMode;
            Include(fStateFlags, sfMouseDoneSelecting);
            // TODO Add sfMouseSelecting, maybe only if caret did indeed move
          end;
          MouseCapture := True;
          ResetMouseCapture := False;
          Include(fStateFlags, sfWaitForMouseSelecting);
        end;
      emcSelectWord:
        begin
          if AnAction.MoveCaret then
            MoveCaret;
          SetWordBlock(AnInfo.NewCaret.LineBytePos);
        end;
      emcSelectLine:
        begin
          if AnAction.MoveCaret then
            MoveCaret;
          SetLineBlock(AnInfo.NewCaret.LineBytePos, AnAction.Option = emcoSelectLineFull);
        end;
      emcSelectPara:
        begin
          if AnAction.MoveCaret then
            MoveCaret;
          SetParagraphBlock(AnInfo.NewCaret.LineBytePos);
        end;
      emcStartDragMove:
        begin
          if SelAvail then begin
            Include(fStateFlags, sfWaitForDragging);
            if AnAction.Option = emcoNotDragedNoCaretOnUp then
              Include(fStateFlags, sfWaitForDraggingNoCaret);
            MouseCapture := True;
            ResetMouseCapture := False;
          end
          else
            Result := False; // Currently only drags smNormal
        end;
      emcPasteSelection:
        begin
          if not ReadOnly then begin
            ClipHelper := TSynClipboardStream.Create;
            try
              ClipHelper.ReadFromClipboard(PrimarySelection);
              if ClipHelper.TextP <> nil then begin
                MoveCaret;
                if (not FBlockSelection.Persistent) then
                  FBlockSelection.Clear;
                Result := PasteFromClipboardEx(ClipHelper);
              end
              else
                Result := False;
            finally
              ClipHelper.Free;
            end;
          end;
        end;
      emcMouseLink:
        begin
          if assigned(fMarkupCtrlMouse) and fMarkupCtrlMouse.IsMouseOverLink and
             assigned(FOnClickLink)
          then begin
            if AnAction.MoveCaret then
              MoveCaret;
            FOnClickLink(Self, SynMouseButtonBackMap[AnInfo.Button], AnInfo.Shift, AnInfo.MouseX, AnInfo.MouseY);
          end
          else
            Result := False;
        end;
      emcContextMenu:
        begin
          if AnAction.MoveCaret and (not CaretDone) then begin
            MoveCaret;
          end;
          AnInfo.ActionResult.DoPopUpEvent := True;
          AnInfo.ActionResult.PopUpEventX  := AnInfo.MouseX;
          AnInfo.ActionResult.PopUpEventY  := AnInfo.MouseY;
          AnInfo.ActionResult.PopUpMenu    := PopupMenu;
        end;
      emcSynEditCommand:
        begin
          if AnAction.MoveCaret then
            MoveCaret;
          CommandProcessor(AnAction.Option, #0, nil);
        end;
      emcWheelHorizScrollDown, emcWheelHorizScrollUp:
        begin
          i := GetWheelScrollAmount(CharsInWindow);
          if ACommand = emcWheelHorizScrollUp then i := -i;
          if i <> 0 then begin
            LeftChar := LeftChar + i;
            if fStateFlags * [sfMouseSelecting, sfWaitForMouseSelecting] <> [] then begin
              FStateFlags := FStateFlags - [sfWaitForMouseSelecting] + [sfMouseSelecting, sfMouseDoneSelecting];
              ResetMouseCapture := False;
              AnInfo.NewCaret.LineCharPos := PixelsToRowColumn(Point(AnInfo.MouseX, AnInfo.MouseY));
              FBlockSelection.AutoExtend := True;
              MoveCaret;
              FBlockSelection.ActiveSelectionMode := FMouseSelectionMode;
            end;
          end;
        end;
      emcWheelVertScrollDown, emcWheelVertScrollUp:
        begin
          i := GetWheelScrollAmount(LinesInWindow);
          if ACommand = emcWheelVertScrollUp then i := -i;
          if i <> 0 then begin
            TopView := TopView + i;
            if fStateFlags * [sfMouseSelecting, sfWaitForMouseSelecting] <> [] then begin
              FStateFlags := FStateFlags - [sfWaitForMouseSelecting] + [sfMouseSelecting, sfMouseDoneSelecting];
              ResetMouseCapture := False;
              AnInfo.NewCaret.LineCharPos := PixelsToRowColumn(Point(AnInfo.MouseX, AnInfo.MouseY));
              FBlockSelection.AutoExtend := True;
              MoveCaret;
              FBlockSelection.ActiveSelectionMode := FMouseSelectionMode;
            end;
          end;
        end;
      emcWheelZoomOut, emcWheelZoomIn:
        begin
          if ( (ACommand = emcWheelZoomOut) and (abs(Font.Height) < 3) ) or
             ( (ACommand = emcWheelZoomIn) and (abs(Font.Height) > 50) )
          then begin
            Result := False;
          end
          else begin
            j := 1;
            if ACommand = emcWheelZoomIn then j := -1;
            i := FLastSetFontSize;
            if Font.Height < 0
            then Font.Height := Font.Height + j
            else Font.Height := Font.Height - j;
            FLastSetFontSize := i;
          end;
        end;
      emcWheelZoomNorm:
        begin
          Font.Height := FLastSetFontSize;
        end;
      else
        Result := False; // ACommand was not handled => Fallback to parent Context
    end;

    if Result and (not CaretDone) and AnAction.MoveCaret then
      MoveCaret;
    if Result and (AnAction.IgnoreUpClick) then
      AnInfo.IgnoreUpClick := True;
    if ResetMouseCapture then
      MouseCapture := False;
    if FBlockSelection.AutoExtend and (FPaintLock = 0) then
      FBlockSelection.AutoExtend := False;
  end;
end;

procedure TCustomSynEdit.DoHandleMouseActionResult(AnActionResult: TSynEditMouseActionResult);
var
  Handled: Boolean;
begin
  if AnActionResult.PopUpMenu <> nil then begin
    Handled := False;
    if AnActionResult.DoPopUpEvent then
      inherited DoContextPopup(Point(AnActionResult.PopUpEventX, AnActionResult.PopUpEventY), Handled);
    if not Handled then begin
      AnActionResult.PopupMenu.PopupComponent:=self;
      AnActionResult.PopupMenu.PopUp;
    end;
  end;
end;

procedure TCustomSynEdit.UpdateShowing;
begin
  inherited UpdateShowing;
  if fMarkupManager <> nil then
    fMarkupManager.DoVisibleChanged(IsVisible);
  if HandleAllocated then
    UpdateScreenCaret;
end;

procedure TCustomSynEdit.SetColor(Value: TColor);
begin
  inherited SetColor(Value);
  FPaintArea.BackgroundColor := Color;
end;

procedure TCustomSynEdit.FindAndHandleMouseAction(AButton: TSynMouseButton;
  AShift: TShiftState; X, Y: Integer; ACCount: TSynMAClickCount; ADir: TSynMAClickDir; out
  AnActionResult: TSynEditMouseActionResult; AWheelDelta: Integer);
var
  Info: TSynEditMouseActionInfo;
begin
  FInternalCaret.AssignFrom(FCaret);
  FInternalCaret.LineCharPos := PixelsToRowColumn(Point(X,Y));
  with Info do begin
    NewCaret := FInternalCaret;
    Button := AButton;
    Shift := AShift;
    MouseX := X;
    MouseY := Y;
    WheelDelta := AWheelDelta;
    CCount := ACCount;
    Dir := ADir;
    IgnoreUpClick := False;
    ActionResult.DoPopUpEvent := False;
    ActionResult.PopUpMenu := nil;
  end;
  try
    // Check plugins/external handlers
    if FMouseActionSearchHandlerList.CallSearchHandlers(Info,
                                         @DoHandleMouseAction)
    then
      exit;

    if FLeftGutter.Visible and (X < FLeftGutter.Width) then begin
      // mouse event occurred in Gutter ?
      if FLeftGutter.MaybeHandleMouseAction(Info, @DoHandleMouseAction) then
        exit;
    end
    else
    if FRightGutter.Visible and (X > ClientWidth - FRightGutter.Width) then begin
      // mouse event occurred in Gutter ?
      if FRightGutter.MaybeHandleMouseAction(Info, @DoHandleMouseAction) then
        exit;
    end
    else
    begin
      // mouse event occurred in selected block ?
      if SelAvail and (X >= FTextArea.Bounds.Left) and (X < FTextArea.Bounds.Right) and
         (Y >= FTextArea.Bounds.Top) and (Y < FTextArea.Bounds.Bottom) and
         IsPointInSelection(FInternalCaret.LineBytePos)
      then
        if DoHandleMouseAction(FMouseSelActions.GetActionsForOptions(MouseOptions), Info) then
          exit;
      // mouse event occurred in text?
      if DoHandleMouseAction(FMouseTextActions.GetActionsForOptions(MouseOptions), Info) then
        exit;
    end;

    DoHandleMouseAction(FMouseActions.GetActionsForOptions(MouseOptions), Info);
  finally
    if Info.IgnoreUpClick then
      include(fStateFlags, sfIgnoreUpClick);
    AnActionResult := Info.ActionResult;
  end;
end;

function TCustomSynEdit.FindGutterFromGutterPartList(const APartList: TObject): TObject;
begin
  if APartList is TSynGutterPartList then
    Result := Gutter
  else
  if APartList is TSynRightGutterPartList then
    Result := RightGutter
  else
    Result := nil;
end;

procedure TCustomSynEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  CType: TSynMAClickCount;
  AnActionResult: TSynEditMouseActionResult;
begin
  DebugLnEnter(LOG_SynMouseEvents, ['>> TCustomSynEdit.MouseDown Mouse=',X,',',Y, ' Shift=',dbgs(Shift), ' Caret=',dbgs(CaretXY),', BlockBegin=',dbgs(BlockBegin),' BlockEnd=',dbgs(BlockEnd), ' StateFlags=',dbgs(fStateFlags)]);
  Exclude(FStateFlags, sfHideCursor);
  FInMouseClickEvent := True;

  if FMouseDownEventList <> nil then
    FMouseDownEventList.CallMouseDownHandlers(Self, Button, Shift, X, Y);

  if (X>=ClientWidth-ScrollBarWidth) or (Y>=ClientHeight-ScrollBarWidth) then
  begin
    inherited MouseDown(Button, Shift, X, Y);
    DebugLnExit(LOG_SynMouseEvents, ['<< TCustomSynEdit.MouseDown outside client']);
    exit;
  end;

  LastMouseCaret:=PixelsToRowColumn(Point(X,Y));
  fMouseDownX := X;
  fMouseDownY := Y;
  FMouseDownButton := Button;
  FMouseDownShift := Shift;

  fStateFlags := fStateFlags - [sfDblClicked, sfTripleClicked, sfQuadClicked,
                                sfLeftGutterClick, sfRightGutterClick,
                                sfWaitForMouseSelecting, sfMouseSelecting, sfMouseDoneSelecting,
                                sfWaitForDragging, sfWaitForDraggingNoCaret, sfIgnoreUpClick
                               ];

  Include(fStateFlags, sfInClick);

  if ssQuad in Shift then begin
    CType := ccQuad;
    Include(fStateFlags, sfQuadClicked);
  end
  else if ssTriple in Shift then begin
    CType := ccTriple;
    Include(fStateFlags, sfTripleClicked);
  end
  else if ssDouble in Shift then begin
    CType := ccDouble;
    Include(fStateFlags, sfDblClicked);
  end
  else
    CType := ccSingle;

  IncPaintLock;
  try
    if (X < TextLeftPixelOffset(False)) then begin
      Include(fStateFlags, sfLeftGutterClick);
      FLeftGutter.MouseDown(Button, Shift, X, Y);
    end;
    if (X > ClientWidth - TextRightPixelOffset - ScrollBarWidth) then begin
      Include(fStateFlags, sfRightGutterClick);
      FRightGutter.MouseDown(Button, Shift, X, Y);
    end;
    FindAndHandleMouseAction(SynMouseButtonMap[Button], Shift, X, Y, CType, cdDown, AnActionResult);
  finally
    DecPaintLock;
  end;
  DoHandleMouseActionResult(AnActionResult);

  inherited MouseDown(Button, Shift, X, Y);
  LCLIntf.SetFocus(Handle);
  UpdateCaret;
  SelAvailChange(nil);
  DebugLnExit(LOG_SynMouseEvents, ['<< TCustomSynEdit.MouseDown  StateFlags=',dbgs(fStateFlags)]);
end;

procedure TCustomSynEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  forw: Boolean;
  s: String;
  i, j: Integer;
  p1: TPoint;
begin
  Exclude(FStateFlags, sfHideCursor);
  inherited MouseMove(Shift, x, y);
  if (sfLeftGutterClick in fStateFlags) then
    FLeftGutter.MouseMove(Shift, X, Y);
  if (sfRightGutterClick in fStateFlags) then
    FRightGutter.MouseMove(Shift, X, Y);

  FLastMouseLocation.LastMousePoint := Point(X,Y);
  LastMouseCaret := PixelsToRowColumn(Point(X,Y)); // TODO: Used for ctrl-Link => Use LastMousePoint, and calculate only, if modifier is down
  UpdateCursor;

  if (sfWaitForMouseSelecting in fStateFlags) and MouseCapture and
     ( (abs(fMouseDownX-X) >= MinMax(CharWidth div 2, 2, 4)) or
       (abs(fMouseDownY-Y) >= MinMax(LineHeight div 2, 2, 4)) )
  then begin
    FStateFlags := FStateFlags - [sfWaitForMouseSelecting] + [sfMouseSelecting];
    FBlockSelection.StickyAutoExtend := False;
  end;

  //debugln('TCustomSynEdit.MouseMove sfWaitForDragging=',dbgs(sfWaitForDragging in fStateFlags),' MouseCapture=',dbgs(MouseCapture),' GetCaptureControl=',DbgSName(GetCaptureControl));
  if MouseCapture and (sfWaitForDragging in fStateFlags) then begin
    if (Abs(fMouseDownX - X) >= GetSystemMetrics(SM_CXDRAG))
      or (Abs(fMouseDownY - Y) >= GetSystemMetrics(SM_CYDRAG))
    then begin
      FStateFlags := FStateFlags
                   -[sfWaitForDragging, sfWaitForDraggingNoCaret, sfWaitForMouseSelecting, sfMouseSelecting]
                   + [sfIsDragging];
      FBlockSelection.StickyAutoExtend := False;
      //debugln('TCustomSynEdit.MouseMove BeginDrag');
      BeginDrag(true);
    end;
  end
  else
  if (fStateFlags * [sfMouseSelecting, sfIsDragging] <> []) and MouseCapture
  then begin
    //DebugLn(' TCustomSynEdit.MouseMove CAPTURE Mouse=',dbgs(X),',',dbgs(Y),' Caret=',dbgs(CaretXY),', BlockBegin=',dbgs(BlockBegin),' BlockEnd=',dbgs(BlockEnd));
    if sfIsDragging in fStateFlags then
      FBlockSelection.IncPersistentLock;
    FInternalCaret.AssignFrom(FCaret);
    FInternalCaret.LineCharPos := PixelsToRowColumn(Point(X,Y));

    if (fStateFlags * [sfMouseSelecting, sfIsDragging] = [sfMouseSelecting]) and
       (FMouseSelectionCmd in [emcStartSelectTokens, emcStartSelectWords, emcStartSelectLines])
    then begin
      FInternalCaret.LineCharPos := PixelsToRowColumn(Point(X,Y), [scmForceLeftSidePos]);
      forw := ComparePoints(FInternalCaret.LineBytePos, FBlockSelection.StartLineBytePos) >= 0;
      s := FInternalCaret.LineText;
      i := length(s) + 1;
      p1 := FInternalCaret.LineBytePos;
      case FMouseSelectionCmd of
        emcStartSelectTokens: begin
            if forw then
              p1.X := FWordBreaker.NextBoundary(s, p1.X)
            else
              p1.X := Max(1, FWordBreaker.PrevBoundary(s, p1.X, True));
          end;
        emcStartSelectWords: begin
            if forw then begin
              j := FWordBreaker.NextWordStart(s, p1.X);
              if j < 1 then j := i;
              p1.X := FWordBreaker.NextWordEnd(s, p1.X);
              if p1.X < 1 then p1.X := i;
              p1.X := Min(p1.X, j);
            end
            else
              p1.X := Max(1, Max(FWordBreaker.PrevWordEnd(s, p1.X, True),
                                 FWordBreaker.PrevWordStart(s, p1.X, True)));
          end;
        emcStartSelectLines: begin
            if forw then
              p1.X := i
            else
              p1.X := 1;
          end;
        end;
        if p1.X < 1 then p1.X := i;
        FInternalCaret.LineBytePos := p1;
    end;

    // compare to Bounds => Padding area does not scroll
    if ( (X >= FTextArea.Bounds.Left)   or (LeftChar <= 1) ) and
       ( (X <  FTextArea.Bounds.Right)  or (LeftChar >= CurrentMaxLeftChar) ) and
       ( (Y >= FTextArea.Bounds.Top)    or (TopView <= 1) ) and
       ( (Y <  FTextArea.Bounds.Bottom) or (TopView >= CurrentMaxTopView) )
    then begin
      if (sfMouseSelecting in fStateFlags) and not FInternalCaret.IsAtPos(FCaret) then
        Include(fStateFlags, sfMouseDoneSelecting);
      FBlockSelection.StickyAutoExtend := False;
      FBlockSelection.AutoExtend := sfMouseSelecting in fStateFlags;
      FCaret.LineBytePos := FInternalCaret.LineBytePos;
      FBlockSelection.AutoExtend := False;
    end
    else begin
      // begin scrolling?
      if X < FTextArea.Bounds.Left then
        FScrollDeltaX := Min((X - FTextArea.Bounds.Left - CharWidth) div CharWidth, -1)
      else if x >= FTextArea.Bounds.Right then
        FScrollDeltaX := Max((X - FTextArea.Bounds.Right + 1 + CharWidth) div CharWidth, 1)
      else
        FScrollDeltaX := 0;

      if Y < FTextArea.Bounds.Top then
        FScrollDeltaY := Min((Y - FTextArea.Bounds.Top - LineHeight) div LineHeight, -1)
      else if Y >= FTextArea.Bounds.Bottom then
        FScrollDeltaY := Max((Y - FTextArea.Bounds.Bottom + 1 + LineHeight) div LineHeight, 1)
      else
        FScrollDeltaY := 0;

      fScrollTimer.Enabled := (fScrollDeltaX <> 0) or (fScrollDeltaY <> 0);
      if (sfMouseSelecting in fStateFlags) and ((fScrollDeltaX <> 0) or (fScrollDeltaY <> 0)) then
        Include(fStateFlags, sfMouseDoneSelecting);
    end;
    if sfMouseDoneSelecting in fStateFlags then begin
      FBlockSelection.ActiveSelectionMode := FMouseSelectionMode;
    end;
    if sfIsDragging in fStateFlags then
      FBlockSelection.DecPersistentLock;
  end
  else
  if MouseCapture and (fStateFlags * [sfIsDragging, sfWaitForMouseSelecting] = [])
  then begin
    MouseCapture:=false;
    fScrollTimer.Enabled := False;
  end;
end;

procedure TCustomSynEdit.ScrollTimerHandler(Sender: TObject);
var
  ViewedCaret: TPoint;
  CurMousePos: TPoint;
  X, Y: Integer;
begin
  // changes to line / column in one go
  if sfIsDragging in fStateFlags then
    FBlockSelection.IncPersistentLock;
  DoIncPaintLock(Self); // No editing is taking place
  try
    CurMousePos:=Point(0,0);
    GetCursorPos(CurMousePos);
    CurMousePos:=ScreenToClient(CurMousePos);
    // PixelsToViewedXY
    ViewedCaret := YToPos(FTextArea.PixelsToRowColumn(CurMousePos, []));
    ViewedCaret.y := ViewedCaret.y + ToIdx(TopView);

    // recalculate scroll deltas
    if CurMousePos.X < FTextArea.Bounds.Left then
      FScrollDeltaX := Min((CurMousePos.X - FTextArea.Bounds.Left - CharWidth) div CharWidth, -1)
    else if CurMousePos.x >= FTextArea.Bounds.Right then
      FScrollDeltaX := Max((CurMousePos.X - FTextArea.Bounds.Right + 1 + CharWidth) div CharWidth, 1)
    else
      FScrollDeltaX := 0;

    if CurMousePos.Y < FTextArea.Bounds.Top then
      FScrollDeltaY := Min((CurMousePos.Y - FTextArea.Bounds.Top - LineHeight) div LineHeight, -1)
    else if CurMousePos.Y >= FTextArea.Bounds.Bottom then
      FScrollDeltaY := Max((CurMousePos.Y - FTextArea.Bounds.Bottom + 1 + LineHeight) div LineHeight, 1)
    else
      FScrollDeltaY := 0;

    fScrollTimer.Enabled := (fScrollDeltaX <> 0) or (fScrollDeltaY <> 0);
    // now scroll
    if fScrollDeltaX <> 0 then begin
      LeftChar := LeftChar + fScrollDeltaX;
      X := LeftChar;
      if fScrollDeltaX > 0 then  // scrolling right?
        Inc(X, CharsInWindow);
      FCaret.ViewedLineCharPos := Point(X, ViewedCaret.Y);
      if (not(sfIsDragging in fStateFlags)) then
        SetBlockEnd(LogicalCaretXY);
    end;
    if fScrollDeltaY <> 0 then begin
      if GetKeyState(VK_SHIFT) < 0 then
        TopView := TopView + fScrollDeltaY * LinesInWindow
      else
        TopView := TopView + fScrollDeltaY;
      if fScrollDeltaY > 0
      then Y := TopView + LinesInWindow
      else Y := TopView;  // scrolling up
      if Y < 1   // past end of file
      then y := FCaret.ViewedLinePos;
      FCaret.ViewedLineCharPos := Point(ViewedCaret.X, Y);
      if (not(sfIsDragging in fStateFlags)) then
        SetBlockEnd(LogicalCaretXY);
    end;
  finally
    DoDecPaintLock(Self);
    if sfIsDragging in fStateFlags then
      FBlockSelection.DecPersistentLock;
  end;
end;

procedure TCustomSynEdit.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  Handled := FInMouseClickEvent;
  if not Handled then
    Exclude(FStateFlags, sfHideCursor);
end;

procedure TCustomSynEdit.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  wasDragging, wasSelecting, ignoreUp : Boolean;
  CType: TSynMAClickCount;
  AnActionResult: TSynEditMouseActionResult;
begin
  DebugLn(LOG_SynMouseEvents, ['>> TCustomSynEdit.MouseUp Mouse=',X,',',Y, ' Shift=',dbgs(Shift), ' Caret=',dbgs(CaretXY),', BlockBegin=',dbgs(BlockBegin),' BlockEnd=',dbgs(BlockEnd), ' StateFlags=',dbgs(fStateFlags)]);
  Exclude(FStateFlags, sfHideCursor);
  FInMouseClickEvent := True;
  wasDragging := (sfIsDragging in fStateFlags);
  wasSelecting := (sfMouseDoneSelecting in fStateFlags);
  ignoreUp := (sfIgnoreUpClick in fStateFlags);
  Exclude(fStateFlags, sfIsDragging);
  Exclude(fStateFlags, sfWaitForMouseSelecting);
  Exclude(fStateFlags, sfMouseSelecting);
  Exclude(fStateFlags, sfMouseDoneSelecting);
  Exclude(fStateFlags, sfIgnoreUpClick);
  fScrollTimer.Enabled := False;
  inherited MouseUp(Button, Shift, X, Y);
  MouseCapture := False;
  if not (sfInClick in fStateFlags) then
    exit;

  if sfQuadClicked in fStateFlags then begin
    CType := ccQuad;
  end
  else if sfTripleClicked in fStateFlags then begin
    CType := ccTriple;
  end
  else if sfDblClicked in fStateFlags then begin
    CType := ccDouble;
  end
  else
    CType := ccSingle;
  fStateFlags:=fStateFlags - [sfInClick, sfDblClicked,sfTripleClicked,sfQuadClicked];

  if fStateFlags * [sfWaitForDragging, sfWaitForDraggingNoCaret] = [sfWaitForDragging] then
  begin
    ComputeCaret(X, Y);
    SetBlockBegin(LogicalCaretXY);
    SetBlockEnd(LogicalCaretXY);
    Exclude(fStateFlags, sfWaitForDragging);
  end;

  if (X>=ClientWidth-ScrollBarWidth) or (Y>=ClientHeight-ScrollBarWidth) then
    exit;
  LastMouseCaret:=PixelsToRowColumn(Point(X,Y));

  if wasDragging or wasSelecting or ignoreUp then exit;

  IncPaintLock;
  try
    if (sfLeftGutterClick in fStateFlags) then begin
      FLeftGutter.MouseUp(Button, Shift, X, Y);
      Exclude(fStateFlags, sfLeftGutterClick);
    end;
    if (sfRightGutterClick in fStateFlags) then begin
      FRightGutter.MouseUp(Button, Shift, X, Y);
      Exclude(fStateFlags, sfRightGutterClick);
    end;
    FindAndHandleMouseAction(SynMouseButtonMap[Button], Shift, X, Y, CType, cdUp, AnActionResult);
  finally
    DecPaintLock;
  end;
  DoHandleMouseActionResult(AnActionResult);

  SelAvailChange(nil);
  //DebugLn('TCustomSynEdit.MouseUp END Mouse=',X,',',Y,' Caret=',CaretX,',',CaretY,', BlockBegin=',BlockBegin.X,',',BlockBegin.Y,' BlockEnd=',BlockEnd.X,',',BlockEnd.Y);
end;

procedure TCustomSynEdit.Paint;
var
  rcClip: TRect;
begin
  // Get the invalidated rect. Compute the invalid area in lines / columns.
  rcClip := Canvas.ClipRect;

  If FPaintLock > 0 then begin
    debugln(['Warning: SynEdit.Paint called during PaintLock']);
    {$IFDEF SynCheckPaintLock}
    DumpStack;
    {$ENDIF}
    // Ensure this will be repainted after PaintLock
    if FInvalidateRect.Top < 0 then
      FInvalidateRect := rcClip
    else
      types.UnionRect(FInvalidateRect, FInvalidateRect, rcClip);
    // Just paint the background
    SetBkColor(Canvas.Handle, ColorToRGB(Color));
    InternalFillRect(Canvas.Handle, rcClip);
    if rcClip.Left <= TextLeftPixelOffset(False) then begin
      rcClip.Right := TextLeftPixelOffset(False)+1;
      SetBkColor(Canvas.Handle, ColorToRGB(FLeftGutter.Color));
      InternalFillRect(Canvas.Handle, rcClip);
    end;
    exit;
  end;

  {$IFDEF EnableDoubleBuf}
  //rcClip:=Rect(0,0,ClientWidth,ClientHeight);
  StartPaintBuffer(rcClip);
  {$ENDIF}
  {$IFDEF SYNSCROLLDEBUG}
  debugln(['PAINT ',DbgSName(self),' sfHasScrolled=',dbgs(sfHasScrolled in fStateFlags),' rect=',dbgs(rcClip)]);
  {$ENDIF}

  Include(fStateFlags,sfPainting);
  Exclude(fStateFlags, sfHasScrolled);
  TSynPaintEventHandlerList(FPaintEventHandlerList).CallPaintEventHandlers(Self, peBeforePaint, rcClip);
  FScreenCaret.BeginPaint(rcClip);
  // Now paint everything while the caret is hidden.
  try
    FPaintArea.Paint(Canvas, rcClip);
    DoOnPaint;
  finally
    UpdateCaret; // Todo: this is to call only ShowCaret() / do not create caret here / Issue 0021924
    FScreenCaret.FinishPaint(rcClip); // after update caret
    TSynPaintEventHandlerList(FPaintEventHandlerList).CallPaintEventHandlers(Self, peAfterPaint, rcClip);
    {$IFDEF EnableDoubleBuf}
    EndPaintBuffer(rcClip);
    {$ENDIF}
    Exclude(fStateFlags,sfPainting);
  Include(fStateFlags, sfHasPainted);
  end;
end;

procedure TCustomSynEdit.CodeFoldAction(iLine: integer);
// iLine is 1 based as parameter
var
  ScrY: Integer;
begin
  if (iLine<=0) or (iLine>FTheLinesView.Count) then exit;
  ScrY := ToIdx(TextXYToScreenXY(Point(1, iLine)).y);
//DebugLn(['****** FoldAction at ',iLine,' scrline=',ScrY, ' type ', SynEditCodeFoldTypeNames[FFoldedLinesView.FoldType[ScrY]],  '  view topline=',FFoldedLinesView.TopLine  ]);
  if FFoldedLinesView.FoldType[ScrY]
     * [cfCollapsedFold, cfCollapsedHide] <> []
  then
    FFoldedLinesView.UnFoldAtTextIndex(iLine)
  else
  if FFoldedLinesView.FoldType[ScrY]
     * [cfFoldStart] <> []
  then
    FFoldedLinesView.FoldAtTextIndex(iLine);
end;

function TCustomSynEdit.FindNextUnfoldedLine(iLine: integer; Down: boolean
  ): Integer;
// iLine is 1 based
begin
  Result := Max(0, FTheLinesView.TextToViewIndex(ToIdx(iLine)));
  if Down then
    Result := ToPos(FTheLinesView.ViewToTextIndex(Result+1))
  else
    Result := ToPos(FTheLinesView.ViewToTextIndex(Result));
end;

function TCustomSynEdit.CreateGutter(AOwner : TSynEditBase; ASide: TSynGutterSide;
  ATextDrawer: TheTextDrawer): TSynGutter;
begin
  Result := TSynGutter.Create(AOwner, ASide, ATextDrawer);
end;

procedure TCustomSynEdit.UnfoldAll;
begin
  FFoldedLinesView.UnfoldAll;
  Invalidate;
end;

procedure TCustomSynEdit.FoldAll(StartLevel : Integer = 0; IgnoreNested : Boolean = False);
begin
  FFoldedLinesView.FoldAll(StartLevel, IgnoreNested);
  Invalidate;
end;

procedure TCustomSynEdit.StartPaintBuffer(const ClipRect: TRect);
{$IFDEF EnableDoubleBuf}
var
  NewBufferWidth: Integer;
  NewBufferHeight: Integer;
{$ENDIF}
begin
  {$IFDEF EnableDoubleBuf}
  if (SavedCanvas<>nil) then RaiseGDBException('');
  if BufferBitmap=nil then
    BufferBitmap:=TBitmap.Create;
  NewBufferWidth:=BufferBitmap.Width;
  NewBufferHeight:=BufferBitmap.Height;
  if NewBufferWidth<ClipRect.Right then
    NewBufferWidth:=ClipRect.Right;
  if NewBufferHeight<ClipRect.Bottom then
    NewBufferHeight:=ClipRect.Bottom;
  BufferBitmap.Width:=NewBufferWidth;
  BufferBitmap.Height:=NewBufferHeight;
  SavedCanvas:=Canvas;
  Canvas:=BufferBitmap.Canvas;
  {$ENDIF}
end;

procedure TCustomSynEdit.EndPaintBuffer(const ClipRect: TRect);
begin
  {$IFDEF EnableDoubleBuf}
  if (SavedCanvas=nil) then RaiseGDBException('');
  if not (SavedCanvas is TControlCanvas) then RaiseGDBException('');
  Canvas:=SavedCanvas;
  SavedCanvas:=nil;
  Canvas.CopyRect(ClipRect,BufferBitmap.Canvas,ClipRect);
  {$ENDIF}
end;

function TCustomSynEdit.NextWordLogicalPos(ABoundary: TLazSynWordBoundary;
  WordEndForDelete: Boolean): TPoint;
var
  i, j, CX, CY, NX, OX, LineLen: integer;
  Line, ULine: string;
  CWidth: TPhysicalCharWidths;
  r, InclCurrent: Boolean;
begin
  Result := LogicalCaretXY;
  CX := Result.X;
  CY := Result.Y;

  if (CY < 1) then begin
    Result.X := 1;
    Result.Y := 1;
    exit;
  end;
  i := FTheLinesView.Count;
  if (CY > i) or ((CY = i) and (CX > length(FTheLinesView[i-1]))) then begin
    Result.Y := i;
    Result.X := length(FTheLinesView[Result.Y-1]) + 1;
    exit;
  end;

  Line := FTheLinesView[CY - 1];
  InclCurrent := False;
  LineLen := Length(Line);
  if CX > LineLen then begin
    Line := FTheLinesView[CY];
    LineLen := Length(Line);
    Inc(CY);
    CX := 1;
    InclCurrent := True;
  end;

  case ABoundary of
    swbWordBegin: begin
        CX := WordBreaker.NextWordStart(Line,  CX, InclCurrent);
        if (CX <= 0) and not InclCurrent then CX := LineLen + 1;
        if (CX <= 0) and InclCurrent then CX := 1;
      end;
    swbWordEnd: begin
        CX := WordBreaker.NextWordEnd(Line,  CX);
        if (CX <= 0) then CX := LineLen + 1;
      end;
    swbWordSmart: begin
        NX := WordBreaker.NextWordEnd(Line, CX);
        if (NX <= 0) then NX := LineLen + 1;
        CX := WordBreaker.NextWordStart(Line, CX, InclCurrent);
        if (CX <= 0) and not InclCurrent then CX := LineLen + 1;
        if (CX <= 0) and InclCurrent then CX := 1;

        if ((ABoundary=swbWordSmart) and (NX<CX-1)) then // step over 1 char gap
          CX := NX;
      end;
    swbTokenBegin: begin
        if not (   InclCurrent and
                   ((CX <= 1) or (Line[CX-1] in FWordBreaker.WhiteChars)) and
                   ((CX > LineLen) or not(Line[CX] in FWordBreaker.WhiteChars))   )
        then
          CX := WordBreaker.NextBoundary(Line,  CX);
        if (CX > 0) and (CX <= LineLen) and (Line[CX] in FWordBreaker.WhiteChars) then
          CX := WordBreaker.NextBoundary(Line,  CX);
        if (CX <= 0) then CX := LineLen + 1;
      end;
    swbTokenEnd: begin
        CX := WordBreaker.NextBoundary(Line,  CX);
        if (CX > 1) and (Line[CX-1] in FWordBreaker.WhiteChars) then
          CX := WordBreaker.NextBoundary(Line,  CX);
        if (CX <= 0) then CX := LineLen + 1;
      end;
    swbCaseChange: begin
        NX := WordBreaker.NextWordStart(Line,  CX, InclCurrent);
        if (NX <= 0) and not InclCurrent then NX := LineLen + 1;
        if (NX <= 0) and InclCurrent then NX := 1;

        ULine := UTF8UpperCase(Line);
        CWidth := FTheLinesView.GetPhysicalCharWidths(CY - 1); // for utf 8
        OX := CX;
        i := Length(ULine);
        // skip upper
        While (CX < NX) and (CX <= i) do begin          // check entire next utf-8 char to be equal
          r := (CX = OX) or (CX <= 1) or (Line[CX-1] <> '_') or ((CX <= i) and (Line[CX] = '_'));
          j := CX;
          repeat
            r := r and (Line[j] = ULine[j]);
            inc(j);
          until (j > i) or ((CWidth[j-1] and PCWMask) <> 0);
          if not r then break;
          CX := j;
        end;
        // skip lowercase
        ULine := UTF8LowerCase(Line);
        While (CX < NX) and (CX <= i) do begin          // check entire next utf-8 char to be equal
          r := (CX = OX) or (CX <= 1) or (Line[CX-1] <> '_') or ((CX <= i) and (Line[CX] = '_'));
          j := CX;
          repeat
            r := r and (Line[j] = ULine[j]);
            inc(j);
          until (j > i) or ((CWidth[j-1] and PCWMask) <> 0);
          if not r then break;
          CX := j;
        end;
      end;
  end;

  Result := Point(CX, CY);
end;

function TCustomSynEdit.PrevWordLogicalPos(ABoundary: TLazSynWordBoundary): TPoint;

  procedure CheckLineStart(var CX, CY: integer);
  var
    Line: String;
  begin
    if CX <= 0 then
      if CY > 1 then begin
        // just position at the end of the previous line
        // Todo skip spaces
        Dec(CY);
        Line := FTheLinesView[CY - 1];
        CX := Length(Line) + 1;
      end
      else
        CX := 1;
  end;

var
  i, j, CX, CY, NX, OX: integer;
  Line, ULine: string;
  CWidth: TPhysicalCharWidths;
  r: Boolean;
begin
  Result := LogicalCaretXY;
  CX := Result.X;
  CY := Result.Y;

  if (CY < 1) then begin
    Result.X := 1;
    Result.Y := 1;
    exit;
  end;
  if (CY > FTheLinesView.Count) then begin
    Result.Y := FTheLinesView.Count;
    Result.X := length(FTheLinesView[Result.Y-1]) + 1;
    exit;
  end;

  Line := FTheLinesView[CY - 1];

  case ABoundary of
    swbWordBegin: begin
        CX := WordBreaker.PrevWordStart(Line,  Min(CX, Length(Line) + 1));
        CheckLineStart(CX, CY);
      end;
    swbWordEnd: begin
        CX := WordBreaker.PrevWordEnd(Line,  Min(CX, Length(Line) + 1));
        CheckLineStart(CX, CY);
      end;
    swbWordSmart: begin
        Dec(CX); // step over 1 char gap
        if WordBreaker.IsAtWordStart(Line, CX) then
          NX := CX
        else
          NX := WordBreaker.PrevWordStart(Line,  Min(CX, Length(Line) + 1));
        CX := WordBreaker.PrevWordEnd(Line,  Min(CX, Length(Line) + 1));

        if (NX>CX-1) then // select the nearest
          CX := NX;
        CheckLineStart(CX, CY);
    end;
    swbTokenBegin: begin
        CX := WordBreaker.PrevBoundary(Line,  Min(CX, Length(Line) + 1));
        if (CX > 0) and (Line[CX] in FWordBreaker.WhiteChars) then
          CX := WordBreaker.PrevBoundary(Line,  Min(CX, Length(Line) + 1));
        if CX = 1 then CX := -1;
        CheckLineStart(CX, CY);
      end;
    swbTokenEnd: begin
        CX := WordBreaker.PrevBoundary(Line,  Min(CX, Length(Line) + 1));
        if (CX > 1) and (Line[CX-1] in FWordBreaker.WhiteChars) then
          CX := WordBreaker.PrevBoundary(Line,  Min(CX, Length(Line) + 1));
        if CX = 1 then CX := -1;
        CheckLineStart(CX, CY);
      end;
    swbCaseChange: begin
        NX := WordBreaker.PrevWordStart(Line,  Min(CX, Length(Line) + 1));

        ULine := UTF8LowerCase(Line);
        CWidth := FTheLinesView.GetPhysicalCharWidths(CY - 1); // for utf 8
        OX := CX;
        i := Length(ULine);
        if CX > i + 1 then CX := i + 1;
        // skip lowercase
        While (CX > NX) and (CX - 1 > 0) do begin          // check entire previous utf-8 char to be equal
          r := (CX = OX) or (Line[CX - 1] <> '_') or ((CX <= i) and (Line[CX] = '_'));
          j := CX;
          repeat
            dec(j);
            r := r and (Line[j] = ULine[j]);
          until (j < 1) or ((CWidth[j-1] and PCWMask) <> 0);
          if not r then break;
          CX := j;
        end;
        // skip upper
        While (CX > NX) and (CX - 1 > 0) do begin          // check entire previous utf-8 char to be not equal
          j := CX;
          r := true;
          repeat
            dec(j);
            r := r and (Line[j] = ULine[j]);
          until (j < 1) or ((CWidth[j-1] and PCWMask) <> 0);
          r := r or not( (CX = OX) or (Line[CX - 1] <> '_') or ((CX <= i) and (Line[CX] = '_')) );
          if r then break;
          CX := j;
        end;
        if (CX - 1 < 1) then
          CX := NX;
        CheckLineStart(CX, CY);
      end;
  end;

  Result := Point(CX, CY);
end;

procedure TCustomSynEdit.EraseBackground(DC: HDC);
begin
  // we are painting everything ourselves, so not need to erase background
end;

procedure TCustomSynEdit.Invalidate;
begin
  {$IFDEF VerboseSynEditInvalidate}
  DebugLn(['TCustomSynEdit.Invalidate ',DbgSName(self)]);
  {$ENDIF}
  inherited Invalidate;
end;

function TCustomSynEdit.PluginCount: Integer;
begin
  Result := fPlugins.Count;
end;

function TCustomSynEdit.MarkupCount: Integer;
begin
  Result := FMarkupManager.Count;
end;

procedure TCustomSynEdit.SetCaretTypeSize(AType: TSynCaretType; AWidth, AHeight, AXOffs,
  AYOffs: Integer);
begin
  FScreenCaret.SetCaretTypeSize(AType, AWidth, AHeight, AXOffs, AYOffs);
end;

procedure TCustomSynEdit.UpdateCursorOverride;
var
  c: TCursor;
begin
  c := crDefault;
  TSynQueryMouseCursorList(FQueryMouseCursorList).CallScrollEventHandlers(Self, FLastMouseLocation, c);
  FOverrideCursor := c;
end;

procedure TCustomSynEdit.PasteFromClipboard(AForceColumnMode: Boolean);
var
  ClipHelper: TSynClipboardStream;
begin
  ClipHelper := TSynClipboardStream.Create;
  try
    ClipHelper.ReadFromClipboard(Clipboard);
    PasteFromClipboardEx(ClipHelper, AForceColumnMode);
  finally
    ClipHelper.Free;
  end;
end;

function TCustomSynEdit.PasteFromClipboardEx(ClipHelper: TSynClipboardStream;
  AForceColumnMode: Boolean): Boolean;
var
  PTxt: PChar;
  PStr: String;
  PMode: TSynSelectionMode;
  InsStart: TPoint;
  PasteAction: TSynCopyPasteAction;
begin
  Result := False;
  InternalBeginUndoBlock;
  try
    PTxt := ClipHelper.TextP;
    if AForceColumnMode then
      PMode := smColumn
    else
      PMode := ClipHelper.SelectionMode;
    PasteAction := scaContinue;
    if assigned(FOnPaste) then begin
      if ClipHelper.IsPlainText then PasteAction := scaPlainText;
      InsStart := FCaret.LineBytePos;
      if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then
        InsStart := FBlockSelection.FirstLineBytePos;
      PStr := PTxt;
      FOnPaste(self, PStr, PMode, InsStart, PasteAction);
      PTxt := PChar(PStr);
      if (PStr = '') or (PasteAction = scaAbort) then
        exit;
    end;

    if ClipHelper.TextP = nil then
      exit;

    Result := True;
    if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then
      FBlockSelection.SelText := '';
    InsStart := FCaret.LineBytePos;
    FInternalBlockSelection.StartLineBytePos := InsStart;
    FInternalBlockSelection.SetSelTextPrimitive(PMode, PTxt);
    FCaret.LineBytePos := FInternalBlockSelection.StartLineBytePos;

    if PasteAction = scaPlainText then
      exit;

    if eoFoldedCopyPaste in fOptions2 then begin
      PTxt := ClipHelper.GetTagPointer(synClipTagFold);
      if PTxt <> nil then begin
        ScanRanges;
        FFoldedLinesView.ApplyFoldDescription(InsStart.Y -1, InsStart.X,
            FInternalBlockSelection.StartLinePos-1, FInternalBlockSelection.StartBytePos,
            PTxt, ClipHelper.GetTagLen(synClipTagFold));
      end;
    end;
  finally
    InternalEndUndoBlock;
  end;
end;

procedure TCustomSynEdit.SelectAll;
var
  LastPt: TPoint;
begin
  DoIncPaintLock(Self); // No editing is taking place
  LastPt := Point(1, FTheLinesView.Count);
  if LastPt.y > 0 then
    Inc(LastPt.x, Length(FTheLinesView[LastPt.y - 1]))
  else
    LastPt.y  := 1;
  SetCaretAndSelection(LogicalToPhysicalPos(LastPt), Point(1, 1), LastPt);
  FBlockSelection.ActiveSelectionMode := smNormal;
  if eoNoScrollOnSelectRange in FOptions2 then
    Include(fStateFlags, sfPreventScrollAfterSelect);
  DoDecPaintLock(Self);
end;

procedure TCustomSynEdit.SetHighlightSearch(const ASearch: String;
  AOptions: TSynSearchOptions);
begin
  fMarkupHighAll.SearchOptions := AOptions;
  fMarkupHighAll.SearchString := ASearch;
end;

procedure TCustomSynEdit.SelectToBrace;
begin
  DoIncPaintLock(Self); // No editing is taking place
  FindMatchingBracket(CaretXY,true,true,true,false);
  if eoNoScrollOnSelectRange in FOptions2 then
    Include(fStateFlags, sfPreventScrollAfterSelect);
  DoDecPaintLock(Self);
end;

procedure TCustomSynEdit.SelectWord;
begin
  SetWordBlock(LogicalCaretXY);
end;

procedure TCustomSynEdit.SelectLine(WithLeadSpaces: Boolean = True);
begin
  SetLineBlock(CaretXY, WithLeadSpaces);
end;

procedure TCustomSynEdit.SelectParagraph;
begin
  SetParagraphBlock(CaretXY);
end;

procedure TCustomSynEdit.Clear;
begin
  FTheLinesView.Clear;
end;

procedure TCustomSynEdit.Append(const Value: String);
begin
  FTheLinesView.Append(Value);
end;

procedure TCustomSynEdit.DoBlockSelectionChanged(Sender : TObject);
begin
  StatusChanged([scSelection]);
  if HandleAllocated and Focused then
    SelAvailChange(nil);
end;

procedure TCustomSynEdit.SetBlockBegin(Value: TPoint); // logical position (byte)
begin
  fBlockSelection.StartLineBytePos := Value;
end;

procedure TCustomSynEdit.SetBlockEnd(Value: TPoint); // logical position (byte)
begin
  fBlockSelection.EndLineBytePos := Value;
end;

procedure TCustomSynEdit.SetBlockIndent(const AValue: integer);
begin
  if fBlockIndent=AValue then exit;
  fBlockIndent:=AValue;
end;

function TCustomSynEdit.GetCaretX : Integer;
begin
  Result:= FCaret.CharPos;
end;

function TCustomSynEdit.GetCaretY : Integer;
begin
  Result:= FCaret.LinePos;
end;

function TCustomSynEdit.GetCaretUndo: TSynEditUndoItem;
begin
  if SelAvail then
    Result := TSynEditUndoSelCaret.Create(FCaret.LineCharPos,
       FBlockSelection.StartLineBytePos, FBlockSelection.EndLineBytePos,
       FBlockSelection.ActiveSelectionMode)
  else
    Result := TSynEditUndoCaret.Create(FCaret.LineCharPos);
end;

function TCustomSynEdit.GetMarkup(Index: integer): TSynEditMarkup;
begin
  Result := fMarkupManager.Markup[Index];
end;

procedure TCustomSynEdit.SetCaretX(const Value: Integer);
begin
  FCaret.ChangeOnTouch; // setting the caret always clears selection (even setting to current pos / no change)
  FCaret.CharPos := Value;
end;

procedure TCustomSynEdit.SetCaretY(const Value: Integer);
begin
  FCaret.ChangeOnTouch; // setting the caret always clears selection (even setting to current pos / no change)
  FCaret.LinePos := Value;
end;

function TCustomSynEdit.GetCaretXY: TPoint;
begin
  Result := FCaret.LineCharPos;
end;

function TCustomSynEdit.GetFoldedCodeColor: TSynSelectedColor;
begin
  Result := FFoldedLinesView.MarkupInfoFoldedCode;
end;

function TCustomSynEdit.GetLines: TStrings;
begin
  Result := FStrings;
end;

procedure TCustomSynEdit.SetCaretXY(Value: TPoint);
// physical position (screen)
begin
  FCaret.ChangeOnTouch; // setting the caret always clears selection (even setting to current pos / no change)
  FCaret.LineCharPos:= Value;
end;

procedure TCustomSynEdit.CaretChanged(Sender: TObject);
begin
  Include(fStateFlags, sfCaretChanged);
  fStateFlags := fStateFlags - [sfExplicitTopLine, sfExplicitLeftChar];
  if FCaret.OldCharPos <> FCaret.CharPos then
    Include(fStatusChanges, scCaretX);
  if FCaret.OldLinePos <> FCaret.LinePos then begin
    Include(fStatusChanges, scCaretY);
    InvalidateGutterLines(FCaret.OldLinePos, FCaret.OldLinePos);
    InvalidateGutterLines(FCaret.LinePos, FCaret.LinePos);
  end;
  EnsureCursorPosVisible;
  if fPaintLock = 0 then
    fMarkupHighCaret.CheckState; // Todo need a global lock, including the markup
end;

function TCustomSynEdit.CurrentMaxLeftChar: Integer;
begin
  if not HandleAllocated then // don't know chars in window yet
    exit(MaxInt);
  Result := FTheLinesView.LengthOfLongestLine;
  if (eoScrollPastEol in Options) and (Result < fMaxLeftChar) then
    Result := fMaxLeftChar;
  Result := Result - CharsInWindow + 1 + FScreenCaret.ExtraLineChars;
end;

function TCustomSynEdit.CurrentMaxLineLen: Integer;
begin
  if not HandleAllocated then // don't know chars in window yet
    exit(MaxInt);
  Result := FTheLinesView.LengthOfLongestLine + 1;
  if (eoScrollPastEol in Options) and (Result < fMaxLeftChar) then
    Result := fMaxLeftChar;
end;

procedure TCustomSynEdit.SetLeftChar(Value: Integer);
begin
  //{BUG21996} DebugLn(['TCustomSynEdit.SetLeftChar=',Value,'  Caret=',dbgs(CaretXY),', BlockBegin=',dbgs(BlockBegin),' BlockEnd=',dbgs(BlockEnd), ' StateFlags=',dbgs(fStateFlags), ' paintlock', FPaintLock]);
  Value := Min(Value, CurrentMaxLeftChar);
  Value := Max(Value, 1);
  if not HandleAllocated then
    Include(fStateFlags, sfExplicitLeftChar);
  if Value <> FTextArea.LeftChar then begin
    FTextArea.LeftChar := Value;
    UpdateScrollBars;
    InvalidateLines(-1, -1);
    StatusChanged([scLeftChar]);
  end;
end;

procedure TCustomSynEdit.SetLines(Value: TStrings);
begin
  if HandleAllocated then
    FStrings.Assign(Value);
end;

function TCustomSynEdit.GetMarkupMgr: TObject;
begin
  Result := fMarkupManager;
end;

function TCustomSynEdit.GetCaretObj: TSynEditCaret;
begin
  Result := FCaret;
end;

procedure TCustomSynEdit.SetLineText(Value: string);
begin
  FCaret.LineText := Value;
end;

procedure TCustomSynEdit.SetName(const Value: TComponentName);
var
  TextToName: boolean;
begin
  TextToName := (ComponentState * [csDesigning, csLoading] = [csDesigning])
    and (TrimRight(Text) = Name);
  inherited SetName(Value);
  if TextToName then
    Text := Value;
end;

procedure TCustomSynEdit.CreateHandle;
begin
  Application.RemoveOnIdleHandler(@IdleScanRanges);
  DoIncPaintLock(nil);
  try
    inherited CreateHandle;   //SizeOrFontChanged will be called
    FLeftGutter.RecalcBounds;
    FRightGutter.RecalcBounds;
    fStateFlags := fStateFlags - [sfHorizScrollbarVisible, sfVertScrollbarVisible];
    UpdateScrollBars;
  finally
    DoDecPaintLock(nil);
  end;
end;

procedure TCustomSynEdit.SetScrollBars(const Value: TScrollStyle);
begin
  if (FScrollBars <> Value) then begin
    FScrollBars := Value;
    UpdateScrollBars;
    Invalidate;
  end;
end;

procedure TCustomSynEdit.SetSelTextPrimitive(PasteMode: TSynSelectionMode;
  Value: PChar; AddToUndoList: Boolean = false);
Begin
  IncPaintLock;
  if not AddToUndoList then begin
    fUndoList.Lock;
    fRedoList.Lock;
  end;
  try
    FBlockSelection.SetSelTextPrimitive(PasteMode, Value);
  finally
    if not AddToUndoList then begin
      fUndoList.Unlock;
      fRedoList.Unlock;
    end;
    DecPaintLock;
  end;
end;

procedure TCustomSynEdit.SetSelTextExternal(const Value: string);
begin
  // undo entry added
  InternalBeginUndoBlock;
  try
    FBlockSelection.SelText := Value;
  finally
    InternalEndUndoBlock;
  end;
end;

procedure TCustomSynEdit.SynSetText(const Value: string);
begin
  FLines.Text := Value;
end;

procedure TCustomSynEdit.RealSetText(const Value: TCaption);
begin
  FLines.Text := Value; // Do not trim
end;

function TCustomSynEdit.CurrentMaxTopView: Integer;
begin
  Result := FTheLinesView.ViewedCount;
  if not(eoScrollPastEof in Options) then
    Result := Result + 1 - Max(0, LinesInWindow);
  Result := Max(Result, 1);
end;

procedure TCustomSynEdit.SetTopLine(Value: Integer);
var
  NewTopView: Integer;
begin
  // TODO : Above hidden line only if folded, if hidden then use below
  if not FTheLinesView.IsTextIdxVisible(ToIdx(Value)) then
    Value := FindNextUnfoldedLine(Value, False);

  if not HandleAllocated then
    Include(fStateFlags, sfExplicitTopLine);
  NewTopView := ToPos(FTheLinesView.TextToViewIndex(ToIdx(Value)));
  if NewTopView <> TopView then begin
    TopView := NewTopView;
  end;
end;

procedure TCustomSynEdit.ScrollAfterTopLineChanged;
var
  Delta: Integer;
  srect: TRect;
begin
  if (sfPainting in fStateFlags) or (fPaintLock <> 0) or (not HandleAllocated) then
    exit;
  Delta := FOldTopView - TopView;
  {$IFDEF SYNSCROLLDEBUG}
  if (sfHasScrolled in fStateFlags) then debugln(['ScrollAfterTopLineChanged with sfHasScrolled Delta=',Delta,' topline=',TopLine, '  FOldTopView=',FOldTopView ]);
  {$ENDIF}
  if Delta <> 0 then begin
    // TODO: SW_SMOOTHSCROLL --> can't get it work
    if (Abs(Delta) >= LinesInWindow) or (sfHasScrolled in FStateFlags) then begin
      {$IFDEF SYNSCROLLDEBUG}
      debugln(['ScrollAfterTopLineChanged does invalidet Delta=',Delta]);
      {$ENDIF}
      Invalidate;
    end else
    begin
      srect := FPaintArea.Bounds;
      srect.Top := FTextArea.TextBounds.Top;
      srect.Bottom := FTextArea.TextBounds.Bottom;
      TSynScrollEventHandlerList(FScrollEventHandlerList).CallScrollEventHandlers(Self, peBeforeScroll,
        0, LineHeight * Delta, srect, srect);
      FScreenCaret.BeginScroll(0, LineHeight * Delta, srect, srect);
      if ScrollWindowEx(Handle, 0, LineHeight * Delta, @srect, @srect, 0, nil, SW_INVALIDATE)
      then begin
        {$IFDEF SYNSCROLLDEBUG}
        debugln(['ScrollAfterTopLineChanged did scroll Delta=',Delta]);
        {$ENDIF}
        include(fStateFlags, sfHasScrolled);
        Include(fStateFlags, sfCaretChanged); // need to update
        FScreenCaret.FinishScroll(0, LineHeight * Delta, srect, srect, True);
        TSynScrollEventHandlerList(FScrollEventHandlerList).CallScrollEventHandlers(Self, peAfterScroll,
          0, LineHeight * Delta, srect, srect);
      end else begin
        FScreenCaret.FinishScroll(0, LineHeight * Delta, srect, srect, False);
        TSynScrollEventHandlerList(FScrollEventHandlerList).CallScrollEventHandlers(Self, peAfterScrollFailed,
          0, LineHeight * Delta, srect, srect);
        Invalidate;    // scrollwindow failed, invalidate all
        {$IFDEF SYNSCROLLDEBUG}
        debugln(['ScrollAfterTopLineChanged does invalidet (scroll failed) Delta=',Delta]);
        {$ENDIF}
      end;
    end;
  end;
  FOldTopView := TopView;
  if (Delta <> 0) and (eoAlwaysVisibleCaret in fOptions2) then
    MoveCaretToVisibleArea;
end;

procedure TCustomSynEdit.MoveCaretToVisibleArea;
// scroll to make the caret visible
var
  NewCaretXY: TPoint;
  MaxY: LongInt;
begin
  {$IFDEF SYNDEBUG}
  if (sfEnsureCursorPos in fStateFlags) then
    debugln('SynEdit. skip MoveCaretToVisibleArea');
  {$ENDIF}
  if (not HandleAllocated) or (sfEnsureCursorPos in fStateFlags) then
    exit;

  NewCaretXY:=CaretXY;
  if NewCaretXY.X < LeftChar then
    NewCaretXY.X := LeftChar
  else if NewCaretXY.X > LeftChar + CharsInWindow - FScreenCaret.ExtraLineChars then
    NewCaretXY.X := LeftChar + CharsInWindow - FScreenCaret.ExtraLineChars;
  if NewCaretXY.Y < TopLine then
    NewCaretXY.Y := TopLine
  else begin
    MaxY:= ScreenRowToRow(Max(0,LinesInWindow-1));
    if NewCaretXY.Y > MaxY then
      NewCaretXY.Y := MaxY;
  end;
  if CompareCarets(CaretXY,NewCaretXY)<>0 then
  begin
    //DebugLn(['TCustomSynEdit.MoveCaretToVisibleArea Old=',dbgs(CaretXY),' New=',dbgs(NewCaretXY)]);
    FCaret.LineCharPos:=NewCaretXY;
  end;
end;

procedure TCustomSynEdit.MoveCaretIgnoreEOL(const NewCaret: TPoint);
begin
  FCaret.IncForcePastEOL;
  FCaret.LineCharPos := NewCaret;
  FCaret.DecForcePastEOL;
end;

procedure TCustomSynEdit.MoveLogicalCaretIgnoreEOL(const NewLogCaret: TPoint);
begin
  MoveCaretIgnoreEOL(LogicalToPhysicalPos(NewLogCaret));
end;

procedure TCustomSynEdit.UpdateCaret(IgnorePaintLock: Boolean = False);
var
  p: TPoint;
begin
  if ( (PaintLock <> 0) and not IgnorePaintLock ) or (not HandleAllocated)
  then begin
    Include(fStateFlags, sfCaretChanged);
  end else begin
    Exclude(fStateFlags, sfCaretChanged);
    if eoAlwaysVisibleCaret in fOptions2 then
      MoveCaretToVisibleArea;

    p := FCaret.ViewedLineCharPos;
    p.y := p.y - TopView + 1;
    FScreenCaret.DisplayPos := ScreenXYToPixels(p);
  end;
end;

procedure TCustomSynEdit.UpdateScrollBars;
var
  ScrollInfo: TScrollInfo;
begin
  if FScrollBarUpdateLock <> 0 then exit;
  if not HandleAllocated or (PaintLock <> 0) then
    Include(fStateFlags, sfScrollbarChanged)
  else begin
    Exclude(fStateFlags, sfScrollbarChanged);
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL and not SIF_TRACKPOS;
    ScrollInfo.nMin := 1;
    ScrollInfo.nTrackPos := 0;

    // Horizontal
    ScrollInfo.nMax := FTheLinesView.LengthOfLongestLine + 1;
    if (eoScrollPastEol in Options) and (ScrollInfo.nMax < fMaxLeftChar + 1) then
      ScrollInfo.nMax := fMaxLeftChar + 1;
    inc(ScrollInfo.nMax, FScreenCaret.ExtraLineChars);
    if ((fScrollBars in [ssBoth, ssHorizontal]) or
        ((fScrollBars in [ssAutoBoth, ssAutoHorizontal]) and (ScrollInfo.nMax - 1 > CharsInWindow))
       ) xor (sfHorizScrollbarVisible in fStateFlags)
    then begin
      if (sfHorizScrollbarVisible in fStateFlags)
        then exclude(fStateFlags, sfHorizScrollbarVisible)
        else include(fStateFlags, sfHorizScrollbarVisible);
      if fStateFlags * [sfEnsureCursorPos, sfEnsureCursorPosAtResize] <> [] then
        include(fStateFlags, sfEnsureCursorPosAtResize);

      {$IFDEF LCLWin32}
      // Some bug in Windows? ShowScrollBar will not always remove the scrollbar
      // This will make the scrollbar un-scrollable, after that it can be hidden
      if not (sfHorizScrollbarVisible in fStateFlags) then begin
        ScrollInfo.nMax  := 99;
        ScrollInfo.nPage := ScrollInfo.nMax-1;
        ScrollInfo.nPos  := 1;
        SetScrollInfo(Handle, SB_HORZ, ScrollInfo, False);
      end;
      {$ENDIF}

      ShowScrollBar(Handle, SB_Horz, sfHorizScrollbarVisible in fStateFlags);
      RecalcCharsAndLinesInWin(True);
    end;
    if (sfHorizScrollbarVisible in fStateFlags) then begin
      ScrollInfo.nPage := CharsInWindow;
      ScrollInfo.nPos := LeftChar;
      SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
      {$IFNDEF LCLWin32} {$IFnDEF SynScrollBarWorkaround}
      if not (sfHorizScrollbarVisible in fStateFlags) then
        ShowScrollBar(Handle, SB_Horz, False);
      {$ENDIF} {$ENDIF}
    end;
    //DebugLn('[TCustomSynEdit.UpdateScrollbars] nMin=',ScrollInfo.nMin,' nMax=',ScrollInfo.nMax,
    //' nPage=',ScrollInfo.nPage,' nPos=',ScrollInfo.nPos,' ClientW=',ClientWidth);

    // Vertical
    ScrollInfo.nMax := FTheLinesView.ViewedCount+1;
    if (eoScrollPastEof in Options) then
      Inc(ScrollInfo.nMax, LinesInWindow - 1);
    if ((fScrollBars in [ssBoth, ssVertical]) or
        ((fScrollBars in [ssAutoBoth, ssAutoVertical]) and (ScrollInfo.nMax - 1 > LinesInWindow))
       ) xor (sfVertScrollbarVisible in fStateFlags)
    then begin
      if (sfVertScrollbarVisible in fStateFlags)
        then exclude(fStateFlags, sfVertScrollbarVisible)
        else include(fStateFlags, sfVertScrollbarVisible);
      if fStateFlags * [sfEnsureCursorPos, sfEnsureCursorPosAtResize] <> [] then
        include(fStateFlags, sfEnsureCursorPosAtResize);

      {$IFDEF LCLWin32}
      // Some bug in Windows? ShowScrollBar will not always remove the scrollbar
      // This will make the scrollbar un-scrollable, after that it can be hidden
      if not (sfVertScrollbarVisible in fStateFlags) then begin
        ScrollInfo.nMax  := 99;
        ScrollInfo.nPage := ScrollInfo.nMax-1;
        ScrollInfo.nPos  := 1;
        SetScrollInfo(Handle, SB_Vert, ScrollInfo, False);
      end;
      {$ENDIF}

      ShowScrollBar(Handle, SB_Vert, sfVertScrollbarVisible in fStateFlags);
      RecalcCharsAndLinesInWin(True);
    end;
      if (sfVertScrollbarVisible in fStateFlags) then begin
      ScrollInfo.nPage := LinesInWindow;
      ScrollInfo.nPos := TopView;
      SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
      {$IFNDEF LCLWin32} {$IFnDEF SynScrollBarWorkaround}
      if not (sfVertScrollbarVisible in fStateFlags) then
        ShowScrollBar(Handle, SB_Vert, False);
      {$ENDIF} {$ENDIF}
    end;
  end;
end;

procedure TCustomSynEdit.SelAvailChange(Sender: TObject);
begin
  if PaintLock > 0 then begin
    Include(FStateFlags, sfSelChanged);
    exit;
  end;
  Exclude(FStateFlags, sfSelChanged);
  if SelAvail
  then AquirePrimarySelection
  else SurrenderPrimarySelection;
end;

procedure TCustomSynEdit.WMDropFiles(var Msg: TMessage);
{TODO: DropFiles
var
  i, iNumberDropped: integer;
  szPathName: array[0..260] of char;
  Point: TPoint;
  FilesList: TStringList;
}
begin
  LastMouseCaret:=Point(-1,-1);
{TODO: DropFiles
  try
    if Assigned(fOnDropFiles) then begin
      FilesList := TStringList.Create;
      try
        iNumberDropped := DragQueryFile(THandle(Msg.wParam), Cardinal(-1),
          nil, 0);
        DragQueryPoint(THandle(Msg.wParam), Point);

        for i := 0 to iNumberDropped - 1 do begin
          DragQueryFile(THandle(Msg.wParam), i, szPathName,
            SizeOf(szPathName));
          FilesList.Add(szPathName);
        end;
        fOnDropFiles(Self, Point.X, Point.Y, FilesList);
      finally
        FilesList.Free;
      end;
    end;
  finally
    Msg.Result := 0;
    DragFinish(THandle(Msg.wParam));
  end;}
end;

procedure TCustomSynEdit.WMExit(var Message: TLMExit);
begin
  LastMouseCaret:=Point(-1,-1);
end;

procedure TCustomSynEdit.WMEraseBkgnd(var Msg: TMessage);
begin
  Msg.Result := 1;
end;

procedure TCustomSynEdit.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_WANTALLKEYS;
  if fWantTabs and (GetKeyState(VK_CONTROL) >= 0) then
    Msg.Result := Msg.Result or DLGC_WANTTAB;
end;

procedure TCustomSynEdit.WMHScroll(var Msg: TLMScroll);
begin
  case Msg.ScrollCode of
      // Scrolls to start / end of the line
    SB_TOP: LeftChar := 1;
    SB_BOTTOM: LeftChar := CurrentMaxLeftChar;
      // Scrolls one char left / right
    SB_LINEDOWN: LeftChar := LeftChar + 1;
    SB_LINEUP: LeftChar := LeftChar - 1;
      // Scrolls one page of chars left / right
    SB_PAGEDOWN: LeftChar := LeftChar
      + Max(1, (CharsInWindow - Ord(eoScrollByOneLess in fOptions)));
    SB_PAGEUP: LeftChar := LeftChar
      - Max(1, (CharsInWindow - Ord(eoScrollByOneLess in fOptions)));
      // Scrolls to the current scroll bar position
    SB_THUMBPOSITION,
    SB_THUMBTRACK: LeftChar := Msg.Pos;
  end;
end;

procedure TCustomSynEdit.WMKillFocus(var Msg: TWMKillFocus);
begin
  if fCaret = nil then exit; // This SynEdit is in Destroy
  Exclude(FStateFlags, sfHideCursor);
  Exclude(fStateFlags, sfInClick);
  {$IFDEF VerboseFocus}
  DebugLn(['[TCustomSynEdit.WMKillFocus] A ',DbgSName(Self), ' time=', dbgs(Now*86640)]);
  {$ENDIF}
  LastMouseCaret:=Point(-1,-1);
  // Todo: Under Windows, keeping the Caret only works, if no other component creates a caret
  FScreenCaretPainterClass{%H-} := TSynEditScreenCaretPainterClass(ScreenCaret.Painter.ClassType);
  UpdateScreenCaret;
  if HideSelection and SelAvail then
    Invalidate;
  if FImeHandler <> nil then
    FImeHandler.FocusKilled;
  inherited;
  StatusChanged([scFocus]);
end;

procedure TCustomSynEdit.WMSetFocus(var Msg: TLMSetFocus);
begin
  if fCaret = nil then exit; // This SynEdit is in Destroy
  Exclude(FStateFlags, sfHideCursor);
  LastMouseCaret:=Point(-1,-1);
  {$IFDEF VerboseFocus}
  DebugLn(['[TCustomSynEdit.WMSetFocus] A ',DbgSName(Self), ' time=', dbgs(Now*86640)]);
  {$ENDIF}
  FScreenCaret.DestroyCaret; // Ensure recreation. On Windows only one caret exists, and it must be moved to the focused editor
  if ScreenCaret.Painter.ClassType <> FScreenCaretPainterClass{%H-} then
    ScreenCaret.ChangePainter(FScreenCaretPainterClass{%H-});
  if ScreenCaret.Painter.ClassType <> TSynEditScreenCaretPainterSystem then // system painter does not use timer
    FScreenCaret.PaintTimer.ResetInterval;
  FScreenCaret.Visible := not(eoNoCaret in FOptions) and IsVisible;
  //if HideSelection and SelAvail then
  //  Invalidate;
  inherited;
  //DebugLn('[TCustomSynEdit.WMSetFocus] END');
  StatusChanged([scFocus]);
end;

procedure TCustomSynEdit.DoOnResize;
begin
  inherited;
  if (not HandleAllocated) or ((ClientWidth = FOldWidth) and (ClientHeight = FOldHeight)) then exit;
  FOldWidth := ClientWidth;
  FOldHeight := ClientHeight;
  inc(FScrollBarUpdateLock);
  FScreenCaret.Lock;
  try
    FLeftGutter.RecalcBounds;
    FRightGutter.RecalcBounds;
    SizeOrFontChanged(FALSE);
    if sfEnsureCursorPosAtResize in fStateFlags then
      EnsureCursorPosVisible;
    Exclude(fStateFlags, sfEnsureCursorPosAtResize);
  finally
    FScreenCaret.UnLock;
    dec(FScrollBarUpdateLock);
    UpdateScrollBars;
  end;
  //debugln('TCustomSynEdit.Resize ',dbgs(Width),',',dbgs(Height),',',dbgs(ClientWidth),',',dbgs(ClientHeight));
  // SetLeftChar(LeftChar);                                                     //mh 2000-10-19
end;

procedure TCustomSynEdit.CalculatePreferredSize(var PreferredWidth,
  PreferredHeight: integer; WithThemeSpace: Boolean);
begin
  // synedit has no preferred size
  PreferredWidth:=0;
  PreferredHeight:=0;
end;

var
  ScrollHintWnd: THintWindow;

function GetScrollHint: THintWindow;
begin
  if ScrollHintWnd = nil then begin
    ScrollHintWnd := HintWindowClass.Create(Application);
    ScrollHintWnd.Name:='SynEditScrollHintWnd';
    ScrollHintWnd.Visible := FALSE;
  end;
  Result := ScrollHintWnd;
  Result.AutoHide := True;  // Because SB_ENDSCROLL never happens under LCL-GTK2
  Result.HideInterval := 1500;
end;

procedure TCustomSynEdit.WMVScroll(var Msg: TLMScroll);
var
  s: ShortString;
  rc: TRect;
  pt: TPoint;
  ScrollHint: THintWindow;
begin
  {$IFDEF SYNSCROLLDEBUG}
  debugln('TCustomSynEdit.WMVScroll A ',DbgSName(Self),' Msg.ScrollCode=',dbgs(Msg.ScrollCode),' SB_PAGEDOWN=',dbgs(SB_PAGEDOWN),' SB_PAGEUP=',dbgs(SB_PAGEUP));
  {$ENDIF}
  case Msg.ScrollCode of
      // Scrolls to start / end of the text
    SB_TOP: TopView := 1;
    SB_BOTTOM: TopView := FTheLinesView.ViewedCount;
      // Scrolls one line up / down
    SB_LINEDOWN: TopView := TopView + 1;
    SB_LINEUP: TopView := TopView - 1;
      // Scrolls one page of lines up / down
    SB_PAGEDOWN: TopView := TopView
      + Max(1, (LinesInWindow - Ord(eoScrollByOneLess in fOptions))); // TODO: scroll half page ?
    SB_PAGEUP: TopView := TopView
      - Max(1, (LinesInWindow - Ord(eoScrollByOneLess in fOptions)));
      // Scrolls to the current scroll bar position
    SB_THUMBPOSITION,
    SB_THUMBTRACK:
      begin
        TopView := Msg.Pos;

        if eoShowScrollHint in fOptions then begin
          ScrollHint := GetScrollHint;
          if not ScrollHint.Visible then begin
            ScrollHint.Color := Application.HintColor;
            ScrollHint.Visible := TRUE;
          end;
          s := Format('line %d', [TopLine]);
          rc := ScrollHint.CalcHintRect(200, s, Nil);
          pt := ClientToScreen(Point(ClientWidth-ScrollBarWidth - rc.Right - 4, 10));
          if eoScrollHintFollows in fOptions then
            pt.y := Mouse.CursorPos.y - (rc.Bottom div 2);
          OffsetRect(rc, pt.x, pt.y);
          ScrollHint.ActivateWithBounds(rc, s);
          ScrollHint.Invalidate;
          ScrollHint.Update;
        end;
      end;
      // Ends scrolling
    SB_ENDSCROLL:
      if eoShowScrollHint in fOptions then
        with GetScrollHint do begin
          Visible := FALSE;
          ActivateWithBounds(Rect(0, 0, 0, 0), '');
        end;
  end;
end;

procedure TCustomSynEdit.CMWantSpecialKey(var Message: TLMessage);
begin
  if (Message.wParam = VK_TAB) then begin
    if WantTabs then
      Message.Result := 1
    else
      Message.Result := 0;
  end
  else
    inherited;
end;

procedure TCustomSynEdit.UpdateScreenCaret;
begin
  if not HandleAllocated then
    exit;
  if (not IsVisible) or
     ( (not Focused) and (not (eoPersistentCaret in fOptions)) ) or
     (eoNoCaret in FOptions)
  then begin
    FScreenCaret.Hide;
    FScreenCaret.DestroyCaret;
    exit;
  end;

  if Focused then begin
    // everything else is done in WM_SETFOCUS;
    FScreenCaret.Visible := True;
  end
  else begin
    // eoPersistentCaret is set
    if ScreenCaret.Painter.ClassType <> TSynEditScreenCaretPainterInternal then
      ScreenCaret.ChangePainter(TSynEditScreenCaretPainterInternal);

    if (eoPersistentCaretStopBlink in FOptions2) then
      FScreenCaret.PaintTimer.Interval := 0
    else
      ScreenCaret.PaintTimer.ResetInterval;

    FScreenCaret.Visible := True;
  end;
end;

procedure TCustomSynEdit.ScanRanges(ATextChanged: Boolean = True);
begin
  if not HandleAllocated then begin
    Application.RemoveOnIdleHandler(@IdleScanRanges); // avoid duplicate add
    if assigned(FHighlighter) then
      Application.AddOnIdleHandler(@IdleScanRanges, False);
    exit;
  end;
//TODO: exit if in paintlock ???
  if not assigned(FHighlighter) then begin
    if ATextChanged then begin
      fMarkupManager.TextChanged(FChangedLinesStart, FChangedLinesEnd, FChangedLinesDiff);
      // TODO: see TSynEditFoldedView.LineCountChanged, this is only needed, because NeedFixFrom does not always work
      FFoldedLinesView.FixFoldingAtTextIndex(FChangedLinesStart, FChangedLinesEnd);
    end;
    TopView := TopView;
    exit;
  end;
  FHighlighter.CurrentLines := FLines; // Trailing spaces are not needed
  FHighlighter.ScanRanges;

  // Todo: text may not have changed
  if ATextChanged then
    fMarkupManager.TextChanged(FChangedLinesStart, FChangedLinesEnd, FChangedLinesDiff);
  TopView := TopView;
end;

procedure TCustomSynEdit.IdleScanRanges(Sender: TObject; var Done: Boolean);
begin
  Application.RemoveOnIdleHandler(@IdleScanRanges);
  if not assigned(FHighlighter) then
    exit;

  FHighlighter.CurrentLines := FLines; // Trailing spaces are not needed
  if not FHighlighter.IdleScanRanges{%H-} then
    exit;

  // Move to the end; give others a change too
  Application.AddOnIdleHandler(@IdleScanRanges, False);
  Done := False;
end;

procedure TCustomSynEdit.LineCountChanged(Sender: TSynEditStrings; AIndex,
  ACount: Integer);
begin
  {$IFDEF SynFoldDebug}debugln(['FOLD-- LineCountChanged Aindex', AIndex, '  ACount=', ACount]);{$ENDIF}
  FBlockSelection.StickyAutoExtend := False;

  if (AIndex < FBeautifyStartLineIdx) or (FBeautifyStartLineIdx < 0) then
    FBeautifyStartLineIdx := AIndex;
  if ACount > 0 then begin
    if (AIndex > FBeautifyEndLineIdx) then
      FBeautifyEndLineIdx := AIndex + ACount - 1
    else
      FBeautifyEndLineIdx := FBeautifyEndLineIdx + ACount;
  end else begin
    FBeautifyEndLineIdx := FBeautifyEndLineIdx + ACount;
    if (FBeautifyEndLineIdx < AIndex) then
      FBeautifyEndLineIdx := AIndex;
  end;

  if PaintLock>0 then begin
    // FChangedLinesStart is also given to Markup.TextChanged; but it is not used there
    if (FChangedLinesStart<1) or (FChangedLinesStart>AIndex+1) then
      FChangedLinesStart:=AIndex+1;
    FChangedLinesEnd := -1; // Invalidate the rest of lines
    FChangedLinesDiff := FChangedLinesDiff + ACount;
  end else begin
    ScanRanges;
    InvalidateLines(AIndex + 1, -1);
    InvalidateGutterLines(AIndex + 1, -1);
    if FCaret.LinePos > FLines.Count then FCaret.LinePos := FLines.Count;
  end;
  if TopLine > AIndex + 1 then
    TopLine := TopLine + ACount // will call UpdateScrollBars
  else
    UpdateScrollBars;
end;

procedure TCustomSynEdit.LineTextChanged(Sender: TSynEditStrings; AIndex,
  ACount: Integer);
begin
  {$IFDEF SynFoldDebug}debugln(['FOLD-- LineTextChanged Aindex', AIndex, '  ACount=', ACount]);{$ENDIF}
  FBlockSelection.StickyAutoExtend := False;

  if (AIndex < FBeautifyStartLineIdx) or (FBeautifyStartLineIdx < 0) then
    FBeautifyStartLineIdx := AIndex;
  if (AIndex + ACount - 1 > FBeautifyEndLineIdx) then
    FBeautifyEndLineIdx := AIndex + ACount - 1;

  if PaintLock>0 then begin
    if (FChangedLinesStart<1) or (FChangedLinesStart>AIndex+1) then
      FChangedLinesStart:=AIndex+1;
    if (FChangedLinesEnd >= 0) and (FChangedLinesEnd<AIndex+1) then
      FChangedLinesEnd:=AIndex + 1 + MaX(ACount, 0);  // TODO: why 2 (TWO) extra lines?
  end else begin
    ScanRanges;
    InvalidateLines(AIndex + 1, AIndex + ACount);
    InvalidateGutterLines(AIndex + 1, AIndex + ACount);
  end;
  UpdateScrollBars;
end;

procedure TCustomSynEdit.DoHighlightChanged(Sender: TSynEditStrings; AIndex,
  ACount: Integer);
begin
  InvalidateLines(AIndex + 1, AIndex + 1 + ACount);
  InvalidateGutterLines(AIndex + 1, AIndex + 1 + ACount);
  FFoldedLinesView.FixFoldingAtTextIndex(AIndex, AIndex + ACount);
  if FPendingFoldState <> '' then
    SetFoldState(FPendingFoldState);
end;

procedure TCustomSynEdit.ListCleared(Sender: TObject);
begin
  ClearUndo;
  // invalidate the *whole* client area
  Invalidate;
  // set caret and selected block to start of text
  SetBlockBegin(Point(1, 1));
  SetCaretXY(Point(1, 1));
  // scroll to start of text
  TopView := 1;
  LeftChar := 1;
  StatusChanged(scTextCleared);
end;

procedure TCustomSynEdit.FoldChanged(Sender: TSynEditStrings; aIndex,
  aCount: Integer);
var
  i: Integer;
begin
  {$IFDEF SynFoldDebug}debugln(['FOLD-- FoldChanged; Index=', aIndex, ' TopView=', TopView, '  ScreenRowToRow(LinesInWindow + 1)=', ScreenRowToRow(LinesInWindow + 1)]);{$ENDIF}
  TopView := TopView;
  if (not FTheLinesView.IsTextIdxVisible(ToIdx(CaretY))) and (FTheLinesView.ViewedCount > 0) then begin
    i := Max(0, FTheLinesView.TextToViewIndex(ToIdx(CaretY)));
    i := ToPos(FTheLinesView.ViewToTextIndex(i)); // unfolded line, above the fold
    SetCaretXY(Point(1, i));
    UpdateCaret;
  end
  else
  if eoAlwaysVisibleCaret in fOptions2 then
    MoveCaretToVisibleArea;
  UpdateScrollBars;
  if aIndex + 1 > Max(1, ScreenRowToRow(LinesInWindow + 1)) then exit;
  if aIndex + 1 < TopLine then aIndex := TopLine - 1;
  InvalidateLines(aIndex + 1, -1);
  InvalidateGutterLines(aIndex + 1, -1);
end;

procedure TCustomSynEdit.SetTopView(AValue : Integer);
begin
  //  don't use MinMax here, it will fail in design mode (Lines.Count is zero,
  // but the painting code relies on TopLine >= 1)
  {$IFDEF SYNSCROLLDEBUG}
  if (fPaintLock = 0) and (not FIsInDecPaintLock) then debugln(['SetTopView outside Paintlock New=',AValue, ' Old=', FFoldedLinesView.TopLine]);
  if (sfHasScrolled in fStateFlags) then debugln(['SetTopView with sfHasScrolled Value=',AValue, '  FOldTopView=',FOldTopView ]);
  {$ENDIF}
  TSynEditStringList(FLines).SendCachedNotify; // TODO: review

  AValue := Min(AValue, CurrentMaxTopView);
  AValue := Max(AValue, 1);

  if not HandleAllocated then
    Include(fStateFlags, sfExplicitTopLine);

  (* ToDo: FFoldedLinesView.TopLine := AValue;
    Required, if "TopView := TopView" or "TopLine := TopLine" is called,
    after ScanRanges (used to be: LineCountChanged / LineTextChanged)
  *)
  FFoldedLinesView.TopLine := AValue;

  if FTextArea.TopLine <> AValue then begin
    if FPaintLock = 0 then
      FOldTopView := TopView;
    FTextArea.TopLine := AValue;
    UpdateScrollBars;
    // call MarkupMgr before ScrollAfterTopLineChanged, in case we aren't in a PaintLock
    fMarkupManager.TopLine := TopLine;
    if (sfPainting in fStateFlags) then debugln('SetTopline inside paint');
    ScrollAfterTopLineChanged;
    StatusChanged([scTopLine]);
  end
  else
    fMarkupManager.TopLine := TopLine;

  {$IFDEF SYNSCROLLDEBUG}
  if (fPaintLock = 0) and (not FIsInDecPaintLock) then debugln('SetTopline outside Paintlock EXIT');
  {$ENDIF}
end;

function TCustomSynEdit.GetTopView : Integer;
begin
  Result := FTextArea.TopLine;
end;

procedure TCustomSynEdit.SetWordBlock(Value: TPoint);
var
  TempString: string;
  x: Integer;
begin
  { Value is the position of the Caret in bytes }
  Value.y := MinMax(Value.y, 1, FTheLinesView.Count);
  TempString := FTheLinesView[Value.Y - 1];
  if TempString = '' then exit;
  x := MinMax(Value.x, 1, Length(TempString)+1);

  Value.X := WordBreaker.PrevWordStart(TempString, x, True);
  if Value.X < 0 then
    Value.X := WordBreaker.NextWordStart(TempString, x);
  if Value.X < 0 then
    exit;

  DoIncPaintLock(Self); // No editing is taking place
  FBlockSelection.StartLineBytePos := Value;
  Value.X := WordBreaker.NextWordEnd(TempString, Value.X);
  FBlockSelection.EndLineBytePos := Value;
  FBlockSelection.ActiveSelectionMode := smNormal;
  FCaret.LineBytePos := Value;
  DoDecPaintLock(Self);
end;

procedure TCustomSynEdit.SetLineBlock(Value: TPoint; WithLeadSpaces: Boolean = True);
var
  ALine: string;
  x, x2: Integer;
begin
  DoIncPaintLock(Self); // No editing is taking place
  FBlockSelection.StartLineBytePos := Point(1,MinMax(Value.y, 1, FTheLinesView.Count));
  FBlockSelection.EndLineBytePos := Point(1,MinMax(Value.y+1, 1, FTheLinesView.Count));
  if (FBlockSelection.StartLinePos >= 1)
  and (FBlockSelection.StartLinePos <= FTheLinesView.Count) then begin
    ALine:=FTheLinesView[FBlockSelection.StartLinePos - 1];
    x2:=length(ALine)+1;
    if not WithLeadSpaces then begin
      x := FBlockSelection.StartBytePos;
      while (x<length(ALine)) and (ALine[x] in [' ',#9]) do
        inc(x);
      FBlockSelection.StartLineBytePos := Point(x,MinMax(Value.y, 1, FTheLinesView.Count));
      while (x2 > x) and (ALine[X2-1] in [' ',#9]) do
        dec(x2);
    end;
    FBlockSelection.EndLineBytePos := Point(x2, MinMax(Value.y, 1, FTheLinesView.Count));
  end;
  FBlockSelection.ActiveSelectionMode := smNormal;
  LogicalCaretXY := FBlockSelection.EndLineBytePos;
  //DebugLn(' FFF2 ',Value.X,',',Value.Y,' BlockBegin=',BlockBegin.X,',',BlockBegin.Y,' BlockEnd=',BlockEnd.X,',',BlockEnd.Y);
  DoDecPaintLock(Self);
end;

procedure TCustomSynEdit.SetParagraphBlock(Value: TPoint);
var
  ParagraphStartLine, ParagraphEndLine, ParagraphEndX: integer;

begin
  DoIncPaintLock(Self); // No editing is taking place
  ParagraphStartLine := MinMax(Value.y,   1, FTheLinesView.Count);
  ParagraphEndLine   := MinMax(Value.y+1, 1, FTheLinesView.Count);
  ParagraphEndX := 1;
  while (ParagraphStartLine > 1) and
        (Trim(FTheLinesView[ParagraphStartLine-1])<>'')
  do
    dec(ParagraphStartLine);
  while (ParagraphEndLine <= FTheLinesView.Count) and
        (Trim(FTheLinesView[ParagraphEndLine-1])<>'')
  do
    inc(ParagraphEndLine);
  if (ParagraphEndLine > FTheLinesView.Count) then begin
    dec(ParagraphEndLine);
    ParagraphEndX := length(FTheLinesView[ParagraphEndLine-1]) + 1;
  end;
  FBlockSelection.StartLineBytePos := Point(1, ParagraphStartLine);
  FBlockSelection.EndLineBytePos   := Point(ParagraphEndX, ParagraphEndLine);
  FBlockSelection.ActiveSelectionMode := smNormal;
  CaretXY := FBlockSelection.EndLineBytePos;
  //DebugLn(' FFF3 ',Value.X,',',Value.Y,' BlockBegin=',BlockBegin.X,',',BlockBegin.Y,' BlockEnd=',BlockEnd.X,',',BlockEnd.Y);
  if eoNoScrollOnSelectRange in FOptions2 then
    Include(fStateFlags, sfPreventScrollAfterSelect);
  DoDecPaintLock(Self);
end;

function TCustomSynEdit.GetCanUndo: Boolean;
begin
  result := fUndoList.CanUndo;
end;

function TCustomSynEdit.GetCanRedo: Boolean;
begin
  result := fRedoList.CanUndo;
end;

function TCustomSynEdit.GetCanPaste:Boolean;
begin
  Result := (Clipboard.HasFormat(CF_TEXT) or
             Clipboard.HasFormat(TSynClipboardStream.ClipboardFormatId)
            )
end;

procedure TCustomSynEdit.Redo;
var
  Item: TSynEditUndoItem;
  Group: TSynEditUndoGroup;
begin
  Group := fRedoList.PopItem;
  if Group <> nil then begin;
    {$IFDEF SynUndoDebugCalls}
    DebugLnEnter(['>> TCustomSynEdit.Redo ',DbgSName(self), ' ', dbgs(Self), ' Group', dbgs(Group), ' cnt=', Group.Count]);
    {$ENDIF}
    IncPaintLock;
    FTheLinesView.IsRedoing := True;
    Item := Group.Pop;
    if Item <> nil then begin
      InternalBeginUndoBlock;
      fUndoList.CurrentGroup.Reason := Group.Reason;
      fUndoList.IsInsideRedo := True;
      try
        repeat
          RedoItem(Item);
          Item := Group.Pop;
        until (Item = nil);
      finally
        InternalEndUndoBlock;
      end;
    end;
    FTheLinesView.IsRedoing := False;
    Group.Free;
    if fRedoList.IsTopMarkedAsUnmodified then
      fUndoList.MarkTopAsUnmodified;
    DecPaintLock;
    {$IFDEF SynUndoDebugCalls}
    DebugLnExit(['<< TCustomSynEdit.Redo ',DbgSName(self), ' ', dbgs(Self)]);
  end else begin
    DebugLn(['<< TCustomSynEdit.Redo - NO GROUP ',DbgSName(self), ' ', dbgs(Self)]);
    {$ENDIF}
  end;
end;

procedure TCustomSynEdit.RedoItem(Item: TSynEditUndoItem);
var
  Line, StrToDelete: PChar;
  x, y, Len, Len2: integer;

  function GetLeadWSLen : integer;
  var
    Run : PChar;
  begin
    Run := Line;
    while (Run[0] in [' ', #9]) do
      Inc(Run);
    Result := Run - Line;
  end;

begin
  if Assigned(Item) then
  try
    FCaret.IncForcePastEOL;
    if Item.ClassType = TSynEditUndoIndent then
    begin // re-insert the column
      SetCaretAndSelection(LogicalToPhysicalPos(Point(1,TSynEditUndoIndent(Item).FPosY1)),
        Point(1, TSynEditUndoIndent(Item).FPosY1), Point(2, TSynEditUndoIndent(Item).FPosY2),
        smNormal);
      x := FBlockIndent;
      y := FBlockTabIndent;
      FBlockIndent := TSynEditUndoIndent(Item).FCnt;
      FBlockTabIndent := TSynEditUndoIndent(Item).FTabCnt;
      DoBlockIndent;
      FBlockIndent := x;
      FBlockTabIndent := y;
    end
    else
    if Item.ClassType = TSynEditUndoUnIndent then
    begin // re-delete the (raggered) column
      // add to undo list
      fUndoList.AddChange(TSynEditUndoUnIndent.Create(TSynEditUndoUnIndent(Item).FPosY1,
         TSynEditUndoUnIndent(Item).FPosY2, TSynEditUndoUnIndent(Item).FText));
      // Delete string
      fUndoList.Lock;
      StrToDelete := PChar(TSynEditUndoUnIndent(Item).FText);
      x := -1;
      for y := TSynEditUndoUnIndent(Item).FPosY1 to TSynEditUndoUnIndent(Item).FPosY2 do begin
        Line := PChar(FTheLinesView[y - 1]);
        Len := GetLeadWSLen;
        Len2 := GetEOL(StrToDelete) - StrToDelete;
        if (Len2 > 0) and (Len >= Len2) then
          FTheLinesView.EditDelete(1+Len-Len2, y, Len2);
        inc(StrToDelete, Len2+1);
      end;
      fUndoList.Unlock;
    end
    else
      if not Item.PerformUndo(self) then
        if not FUndoRedoItemHandlerList.CallUndoRedoItemHandlers(Self, Item) then
          FTheLinesView.EditRedo(Item);
  finally
    FCaret.DecForcePastEOL;
    Item.Free;
  end;
end;

procedure TCustomSynEdit.UpdateCursor;
begin
  if (sfHideCursor in FStateFlags) and (eoAutoHideCursor in fOptions2) then begin
    inherited Cursor := crNone;
    exit;
  end;

  if (FOverrideCursor <> crDefault) then
    inherited Cursor := FOverrideCursor
  else
  if (FLastMouseLocation.LastMousePoint.X >= FTextArea.Bounds.Left) and (FLastMouseLocation.LastMousePoint.X <  FTextArea.Bounds.Right) and
     (FLastMouseLocation.LastMousePoint.Y >= FTextArea.Bounds.Top) and (FLastMouseLocation.LastMousePoint.Y < FTextArea.Bounds.Bottom)
  then
    inherited Cursor := FTextCursor
  else
    inherited Cursor := FOffTextCursor;
end;

procedure TCustomSynEdit.Undo;
var
  Item: TSynEditUndoItem;
  Group: TSynEditUndoGroup;
begin
  Group := fUndoList.PopItem;
  if Group <> nil then begin
    {$IFDEF SynUndoDebugCalls}
    DebugLnEnter(['>> TCustomSynEdit.Undo ',DbgSName(self), ' ', dbgs(Self), ' Group', dbgs(Group), ' cnt=', Group.Count]);
    {$ENDIF}
    IncPaintLock;
    FTheLinesView.IsUndoing := True;
    Item := Group.Pop;
    if Item <> nil then begin
      InternalBeginUndoBlock(fRedoList);
      fRedoList.CurrentGroup.Reason := Group.Reason;
      fUndoList.Lock;
      try
        repeat
          UndoItem(Item);
          Item := Group.Pop;
        until (Item = nil);
      finally
        // Todo: Decide what do to, If there are any trimable spaces.
        FTrimmedLinesView.ForceTrim;
        fUndoList.UnLock;
        InternalEndUndoBlock(fRedoList);
      end;
    end;
    FTheLinesView.IsUndoing := False;
    Group.Free;
    if fUndoList.IsTopMarkedAsUnmodified then
      fRedoList.MarkTopAsUnmodified;
    DecPaintLock;
    {$IFDEF SynUndoDebugCalls}
    DebugLnExit(['<< TCustomSynEdit.Undo ',DbgSName(self), ' ', dbgs(Self)]);
  end else begin
    DebugLn(['<< TCustomSynEdit.Undo - NO GROUP ',DbgSName(self), ' ', dbgs(Self)]);
    {$ENDIF}
  end;
end;

procedure TCustomSynEdit.UndoItem(Item: TSynEditUndoItem);
var
  Line, OldText: PChar;
  y, Len, Len2, LenT: integer;
  s: String;

  function GetLeadWSLen : integer;
  var
    Run : PChar;
  begin
    Run := Line;
    while (Run[0] in [' ', #9]) do
      Inc(Run);
    Result := Run - Line;
  end;

begin
  if Assigned(Item) then try
    FCaret.IncForcePastEOL;

    if Item.ClassType = TSynEditUndoIndent then
    begin
      // add to redo list
      fRedoList.AddChange(TSynEditUndoIndent.Create(TSynEditUndoIndent(Item).FPosY1,
         TSynEditUndoIndent(Item).FPosY2, TSynEditUndoIndent(Item).FCnt, TSynEditUndoIndent(Item).FTabCnt));
      // quick unintend (must all be spaces, as inserted...)
      fRedoList.Lock;
      Len2 := TSynEditUndoIndent(Item).FCnt;
      LenT := TSynEditUndoIndent(Item).FTabCnt;
      for y := TSynEditUndoIndent(Item).FPosY1 to TSynEditUndoIndent(Item).FPosY2 do begin
        Line := PChar(FTheLinesView[y - 1]);
        if Len2 > 0 then begin
          Len := GetLeadWSLen;
          FTheLinesView.EditDelete(Len+1-Len2, y, Len2);
        end;
        if LenT > 0 then
          FTheLinesView.EditDelete(1, y, LenT);
      end;
      fRedoList.Unlock;
    end
    else

    if Item.ClassType = TSynEditUndoUnIndent then
    begin
      fRedoList.AddChange(TSynEditUndoUnIndent.Create(TSynEditUndoUnIndent(Item).FPosY1,
          TSynEditUndoUnIndent(Item).FPosY2, TSynEditUndoUnIndent(Item).FText));
      // reinsert the string
      fRedoList.Lock;
      OldText := PChar(TSynEditUndoUnIndent(Item).FText);
      for y := TSynEditUndoUnIndent(Item).FPosY1 to TSynEditUndoUnIndent(Item).FPosY2 do begin
        Len2 := GetEOL(OldText) - OldText;
        if Len2 > 0 then begin
          Line := PChar(FTheLinesView[y - 1]);
          Len := GetLeadWSLen;
          SetLength(s, Len2);
          Move(OldText^, s[1], Len2);
          FTheLinesView.EditInsert(Len+1, y, s);
        end;
        inc(OldText, Len2+1);
      end;
      fRedoList.Unlock;
    end

    else
      if not Item.PerformUndo(self) then
        if not FUndoRedoItemHandlerList.CallUndoRedoItemHandlers(Self, Item) then
          FTheLinesView.EditUndo(Item);
  finally
    FTrimmedLinesView.UndoTrimmedSpaces := False;
    FCaret.DecForcePastEOL;
    Item.Free;
  end;
end;

procedure TCustomSynEdit.SetFoldState(const AValue: String);
begin
  if assigned(fHighlighter) then begin
    fHighlighter.CurrentLines := FTheLinesView;
    if fHighlighter.NeedScan then begin
      FPendingFoldState := AValue;
      exit;
    end;
  end;
  if sfAfterLoadFromFileNeeded in fStateFlags then begin
    FPendingFoldState := AValue;
    exit;
  end;
  FFoldedLinesView.Lock;
  FFoldedLinesView.ApplyFoldDescription(0, 0, -1, -1, PChar(AValue), length(AValue), True);
  TopView := TopView; // Todo: reset TopView on foldedview
  FFoldedLinesView.UnLock;
  FPendingFoldState := '';
end;

procedure TCustomSynEdit.SetHiddenCodeLineColor(AValue: TSynSelectedColor);
begin
  FFoldedLinesView.MarkupInfoHiddenCodeLine.Assign(AValue);
end;

procedure TCustomSynEdit.SetHighlightAllColor(AValue: TSynSelectedColor);
begin
  fMarkupHighAll.MarkupInfo.Assign(AValue);
end;

procedure TCustomSynEdit.SetIncrementColor(AValue: TSynSelectedColor);
begin
  fMarkupSelection.MarkupInfoIncr.Assign(AValue);
end;

procedure TCustomSynEdit.SetLineHighlightColor(AValue: TSynSelectedColor);
begin
  fMarkupSpecialLine.MarkupLineHighlightInfo.Assign(AValue);
end;

procedure TCustomSynEdit.SetMouseActions(const AValue: TSynEditMouseActions);
begin
  FMouseActions.UserActions := AValue;
end;

procedure TCustomSynEdit.SetMouseLinkColor(AValue: TSynSelectedColor);
begin
  fMarkupCtrlMouse.MarkupInfo.Assign(AValue);
end;

procedure TCustomSynEdit.SetMouseSelActions(const AValue: TSynEditMouseActions);
begin
  FMouseSelActions.UserActions := AValue;
end;

procedure TCustomSynEdit.SetMouseTextActions(AValue: TSynEditMouseActions);
begin
  FMouseTextActions.UserActions := AValue;
end;

procedure TCustomSynEdit.SetPaintLockOwner(const AValue: TSynEditBase);
begin
  TSynEditStringList(FLines).PaintLockOwner := AValue;
end;

procedure TCustomSynEdit.SetShareOptions(const AValue: TSynEditorShareOptions);
var
  ChangedOptions: TSynEditorShareOptions;
  OldMarkList: TSynEditMarkList;
  it: TSynEditMarkIterator;
  MListShared: Boolean;
begin
  if FShareOptions = AValue then exit;

  ChangedOptions:=(FShareOptions - AValue) + (AValue - FShareOptions);
  FShareOptions := AValue;

  if (eosShareMarks in ChangedOptions) then begin
    MListShared := IsMarkListShared;
    if ( (FShareOptions * [eosShareMarks] = []) and MListShared ) or
       ( (eosShareMarks  in FShareOptions) and (not MListShared) and
         (TSynEditStringList(FLines).AttachedSynEditCount > 1) )
    then begin
      OldMarkList := FMarkList;
      FMarkList := nil;
      RecreateMarkList;
      it := TSynEditMarkIterator.Create(OldMarkList);
      it.GotoBOL;
      while it.Next do begin
        // Todo: prevent notifications
        if it.Mark.OwnerEdit = Self then
          FMarkList.Add(it.Mark);
      end;
      it.Free;
      FreeAndNil(FMarkList);
    end;
  end;
  StatusChanged([scOptions]);
end;

procedure TCustomSynEdit.ChangeTextBuffer(NewBuffer: TSynEditStringList);
var
  OldBuffer: TSynEditStringList;
begin
  FLines.SendNotification(senrTextBufferChanging, FLines); // Send the old buffer
  DestroyMarkList;

  // Detach Highlighter
  if FHighlighter <> nil then
    FHighlighter.DetachFromLines(FLines);

  // Set the New Lines
  OldBuffer := TSynEditStringList(FLines);

  Flines := NewBuffer;
  TSynEditStringList(FLines).AttachSynEdit(Self);
  TSynTextViewsManagerInternal(FTextViewsManager).TextBuffer := FLines;

  FUndoList := NewBuffer.UndoList;
  FRedoList := NewBuffer.RedoList;

  // Recreate te public access to FLines
  FreeAndNil(FStrings);
  FStrings := TSynEditLines.Create(TSynEditStringList(FLines), @MarkTextAsSaved);

  // Flines has been set to the new buffer; and self is attached to the new FLines
  // FTheLinesView points to new FLines
  RecreateMarkList;

  // Attach Highlighter
  if FHighlighter <> nil then
    FHighlighter.AttachToLines(FLines);

  OldBuffer.DetachSynEdit(Self);
  FLines.SendNotification(senrTextBufferChanged, OldBuffer); // Send the old buffer
  OldBuffer.SendNotification(senrTextBufferChanged, OldBuffer); // Send the old buffer
  if OldBuffer.AttachedSynEditCount = 0 then
    OldBuffer.Free;
end;

function TCustomSynEdit.IsMarkListShared: Boolean;
var
  i, j: Integer;
begin
  j := 0;
  i := TSynEditStringList(FLines).AttachedSynEditCount - 1;
  while (i >= 0) and (j <= 1) do begin
    if TCustomSynEdit(TSynEditStringList(FLines).AttachedSynEdits[i]).FMarkList = FMarkList then
      inc(j);
    dec(i);
  end;
  Result := j > 1;
end;

procedure TCustomSynEdit.RecreateMarkList;
var
  s: TSynEditBase;
  i: Integer;
begin
  DestroyMarkList;

  if (TSynEditStringList(FLines).AttachedSynEditCount > 1) and
     (eosShareMarks in FShareOptions)
  then begin
    s := TSynEditStringList(FLines).AttachedSynEdits[0];
    if s = Self then
      s := TSynEditStringList(FLines).AttachedSynEdits[1];
    FMarkList := TCustomSynEdit(s).FMarkList;
    TSynEditMarkListInternal(fMarkList).AddOwnerEdit(Self);
    for i := 0 to 9 do
      FBookMarks[i] := TCustomSynEdit(s).fBookMarks[i];
  end
  else begin
    FMarkList := TSynEditMarkListInternal.Create(self, FTheLinesView);
    for i := 0 to 9 do
      FBookMarks[i] := nil;
  end;

  FMarkList.RegisterChangeHandler(@MarkListChange,
    [low(TSynEditMarkChangeReason)..high(TSynEditMarkChangeReason)]);
end;

procedure TCustomSynEdit.DestroyMarkList;
var
  it: TSynEditMarkIterator;
  s: TSynEditBase;
begin
  if FMarkList = nil then
    exit;

  TSynEditMarkListInternal(fMarkList).RemoveOwnerEdit(Self);
  FMarkList.UnRegisterChangeHandler(@MarkListChange);

  if IsMarkListShared then begin
    s := TSynEditStringList(FLines).AttachedSynEdits[0];
    if s = Self then
      s := TSynEditStringList(FLines).AttachedSynEdits[1]; // TODO: find one that shares the MarkList (if someday partial sharing of Marks is avail)

    if TSynEditMarkListInternal(FMarkList).LinesView = FTheLinesView then
      TSynEditMarkListInternal(FMarkList).LinesView := TCustomSynEdit(s).FTheLinesView;

    it := TSynEditMarkIterator.Create(FMarkList);
    it.GotoBOL;
    while it.Next do begin
      // Todo: prevent notifications
      if it.Mark.OwnerEdit = Self then
        it.Mark.OwnerEdit := s;
    end;
    it.Free;
    FMarkList := nil;
  end
  else
    FreeAndNil(FMarkList);
end;

procedure TCustomSynEdit.ShareTextBufferFrom(AShareEditor: TCustomSynEdit);
begin
  if fPaintLock <> 0 then RaiseGDBException('Cannot change TextBuffer while paintlocked');

  ChangeTextBuffer(TSynEditStringList(AShareEditor.FLines));
end;

procedure TCustomSynEdit.UnShareTextBuffer;
begin
  if fPaintLock <> 0 then RaiseGDBException('Cannot change TextBuffer while paintlocked');
  if TSynEditStringList(FLines).AttachedSynEditCount = 1 then
    exit;

  ChangeTextBuffer(TSynEditStringList.Create);
end;

procedure TCustomSynEdit.ExtraLineCharsChanged(Sender: TObject);
begin
  UpdateScrollBars;
end;

procedure TCustomSynEdit.SetTextBetweenPointsSimple(aStartPoint, aEndPoint: TPoint;
  const AValue: String);
begin
  InternalBeginUndoBlock;
  try
    FInternalBlockSelection.SelectionMode := smNormal;
    FInternalBlockSelection.StartLineBytePos := aStartPoint;
    FInternalBlockSelection.EndLineBytePos := aEndPoint;
    FInternalBlockSelection.SelText := AValue;
  finally
    InternalEndUndoBlock;
  end;
end;

procedure TCustomSynEdit.SetTextBetweenPointsEx(aStartPoint, aEndPoint: TPoint;
  aCaretMode: TSynCaretAdjustMode; const AValue: String);
begin
  SetTextBetweenPoints(aStartPoint, aEndPoint, AValue, [], aCaretMode);
end;

procedure TCustomSynEdit.SetTextBetweenPoints(aStartPoint, aEndPoint: TPoint;
  const AValue: String; aFlags: TSynEditTextFlags; aCaretMode: TSynCaretAdjustMode;
  aMarksMode: TSynMarksAdjustMode; aSelectionMode: TSynSelectionMode);
var
  CaretAtBlock: (cabNo, cabBegin, cabEnd);
begin
  InternalBeginUndoBlock;
  try
    CaretAtBlock := cabNo;
    if aCaretMode = scamForceAdjust then
      FCaret.IncAutoMoveOnEdit
    else
    if aCaretMode = scamAdjust then begin
      if FBlockSelection.SelAvail then begin
        if FCaret.IsAtLineByte(FBlockSelection.StartLineBytePos) then
          CaretAtBlock := cabBegin
        else
        if FCaret.IsAtLineByte(FBlockSelection.EndLineBytePos) then
          CaretAtBlock := cabEnd;
      end;
      if CaretAtBlock = cabNo then
        FCaret.IncAutoMoveOnEdit;
    end;
    if setPersistentBlock in aFlags then
      FBlockSelection.IncPersistentLock;
    if setMoveBlock in aFlags then
      FBlockSelection.IncPersistentLock(sbpWeak);
    if setExtendBlock in aFlags then
      FBlockSelection.IncPersistentLock(sbpStrong);

    if aSelectionMode = smCurrent then
      FInternalBlockSelection.SelectionMode    := FBlockSelection.ActiveSelectionMode
    else
      FInternalBlockSelection.SelectionMode    := aSelectionMode;
    FInternalBlockSelection.StartLineBytePos := aStartPoint;
    FInternalBlockSelection.EndLineBytePos   := aEndPoint;
    aStartPoint := FInternalBlockSelection.FirstLineBytePos;

    if aCaretMode = scamBegin then
      FCaret.LineBytePos := aStartPoint;

    FInternalBlockSelection.SetSelTextPrimitive(FInternalBlockSelection.ActiveSelectionMode,
                                                PChar(AValue),
                                                (aMarksMode = smaKeep) or (aStartPoint.y = aEndPoint.y)
                                               );
    if aCaretMode = scamEnd then
      FCaret.LineBytePos := FInternalBlockSelection.StartLineBytePos;
    if setSelect in aFlags then begin
      FBlockSelection.StartLineBytePos    := aStartPoint;
      FBlockSelection.ActiveSelectionMode := FInternalBlockSelection.SelectionMode;
      FBlockSelection.EndLineBytePos      := FInternalBlockSelection.StartLineBytePos;
      if FBlockSelection.ActiveSelectionMode = smLine then
        FBlockSelection.EndLineBytePos := Point(FBlockSelection.StartBytePos + 1, FBlockSelection.EndLinePos - 1);
    end;
  finally
    if CaretAtBlock = cabBegin then
      FCaret.LineBytePos := FBlockSelection.StartLineBytePos
    else
    if CaretAtBlock = cabEnd then
      FCaret.LineBytePos := FBlockSelection.EndLineBytePos;

    if setPersistentBlock in aFlags then
      FBlockSelection.DecPersistentLock;
    if setMoveBlock in aFlags then
      FBlockSelection.DecPersistentLock;
    if setExtendBlock in aFlags then
      FBlockSelection.DecPersistentLock;
    if (CaretAtBlock = cabNo) and (aCaretMode in [scamAdjust, scamForceAdjust]) then
      FCaret.DecAutoMoveOnEdit;
    InternalEndUndoBlock;
  end;
end;

procedure TCustomSynEdit.SetVisibleSpecialChars(AValue: TSynVisibleSpecialChars);
begin
  if FVisibleSpecialChars = AValue then Exit;
  FVisibleSpecialChars := AValue;
  fMarkupSpecialChar.VisibleSpecialChars := AValue;
  if eoShowSpecialChars in Options
  then FPaintArea.VisibleSpecialChars := AValue
  else FPaintArea.VisibleSpecialChars := [];
  if eoShowSpecialChars in Options then Invalidate;
  StatusChanged([scOptions]);
end;

function TCustomSynEdit.GetLineState(ALine: Integer): TSynLineState;
begin
  with TSynEditStringList(fLines) do
    if [sfModified, sfSaved] * Flags[ALine] = [sfModified] then
      Result := slsUnsaved
    else
    if [sfModified, sfSaved] * Flags[ALine] = [sfModified, sfSaved] then
      Result := slsSaved
    else
      Result := slsNone;
end;

procedure TCustomSynEdit.ClearBookMark(BookMark: Integer);
begin
  if (BookMark in [0..9]) and assigned(fBookMarks[BookMark]) then
    FBookMarks[BookMark].Free;
end;

procedure TCustomSynEdit.GotoBookMark(BookMark: Integer);
var
  LogCaret: TPoint;
begin
  if (BookMark in [0..9]) and assigned(fBookMarks[BookMark])
    and (fBookMarks[BookMark].Line <= fLines.Count)
  then begin
    LogCaret:=Point(fBookMarks[BookMark].Column, fBookMarks[BookMark].Line);
    DoIncPaintLock(Self); // No editing is taking place
    FCaret.ChangeOnTouch;
    FCaret.LineBytePos := LogCaret;
    DoDecPaintLock(Self);
  end;
end;

function TCustomSynEdit.IsLinkable(Y, X1, X2: Integer): Boolean;
begin
  Result := X1 <> X2;
  if Result and Assigned(FOnMouseLink) then
    FOnMouseLink(Self, X1, Y, Result);
end;

procedure TCustomSynEdit.SetBookMark(BookMark: Integer; X: Integer; Y: Integer);
var
  i: Integer;
  mark: TSynEditMark;
begin
  if (BookMark in [0..9]) and (Y >= 1) and (Y <= Max(1, fLines.Count)) then
  begin
    mark := TSynEditMark.Create(self);
    X := PhysicalToLogicalPos(Point(X, Y)).x;
    with mark do begin
      Line := Y;
      Column := X;
      ImageIndex := Bookmark;
      BookmarkNumber := Bookmark;
      Visible := true;
      InternalImage := (BookMarkOptions.BookmarkImages = nil);
    end;
    for i := 0 to 9 do
      if assigned(fBookMarks[i]) and (fBookMarks[i].Line = Y) then
        ClearBookmark(i);
    if assigned(fBookMarks[BookMark]) then
      ClearBookmark(BookMark);
    FMarkList.Add(mark);
  end;
end;

procedure TCustomSynEdit.WndProc(var Msg: TMessage);
// Prevent Alt-Backspace from beeping
const
  ALT_KEY_DOWN = $20000000;
begin
  // ASAP after a paint // in case an App.AsyncCall takes longer
  if (Msg.msg <> WM_PAINT) and (Msg.msg <> LM_PAINT) and
     (sfHasPainted in fStateFlags) and (FScreenCaret <> nil)
  then
    FScreenCaret.AfterPaintEvent;

  if (Msg.Msg = WM_SYSCHAR) and (Msg.wParam = VK_BACK) and
    (Msg.lParam and ALT_KEY_DOWN <> 0)
  then
    Msg.Msg := 0
  else
    inherited;
end;

procedure TCustomSynEdit.InsertTextAtCaret(aText: String; aCaretMode : TSynCaretAdjustMode = scamEnd);
begin
  TextBetweenPointsEx[FCaret.LineBytePos, FCaret.LineBytePos, aCaretMode] := aText;
end;

function TCustomSynEdit.CheckDragDropAccecpt(ANewCaret: TPoint; ASource: TObject; out ADropMove: boolean): boolean;
begin
  // if from other control then move when SHIFT, else copy
  // if from Self then copy when CTRL, else move
  if ASource <> Self then begin
    ADropMove := GetKeyState(VK_SHIFT) < 0;
    Result := TRUE;
  end else begin
    ADropMove := GetKeyState(VK_CONTROL) >= 0;
    Result := not IsPointInSelection(ANewCaret, not ADropMove);
  end;
end;

procedure TCustomSynEdit.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  DropMove: boolean;
begin
  inherited;
  LastMouseCaret:=Point(-1,-1);
  if (eoAcceptDragDropEditing in FOptions2) and (Source is TCustomSynEdit) then begin
    Accept := False;
    if (not ReadOnly) and TCustomSynEdit(Source).SelAvail then
    begin
      FBlockSelection.IncPersistentLock;
      try
        //if State = dsDragLeave then //restore prev caret position
        //  ComputeCaret(FMouseDownX, FMouseDownY)
        //else //position caret under the mouse cursor
        ComputeCaret(X, Y);

        Accept := CheckDragDropAccecpt(LogicalCaretXY, Source, DropMove);
        if DropMove then
          DragCursor := crDrag
        else
          DragCursor := crMultiDrag;
      finally
        FBlockSelection.DecPersistentLock;
      end;
    end;
  end;
end;

procedure TCustomSynEdit.DragDrop(Source: TObject; X, Y: Integer);
var
  NewCaret: TPoint;
  DropMove: boolean;
  BB, BE: TPoint;
  DragDropText: string;
  Adjust: integer;
  FoldInfo: String;
  BlockSel: TSynEditSelection;
  sm: TSynSelectionMode;
begin
  if (eoAcceptDragDropEditing in FOptions2) and (not ReadOnly) and
     (Source is TCustomSynEdit) and TCustomSynEdit(Source).SelAvail
  then begin
    IncPaintLock;
    try
      inherited;
      ComputeCaret(X, Y);
      NewCaret := LogicalCaretXY;
      if CheckDragDropAccecpt(NewCaret, Source, DropMove) then begin
        BB := BlockBegin;
        BE := BlockEnd;
        InternalBeginUndoBlock;                                                         //mh 2000-11-20
        try
          DragDropText := TCustomSynEdit(Source).SelText;
          BlockSel := TCustomSynEdit(Source).FBlockSelection;
          if eoFoldedCopyPaste in fOptions2 then
            FoldInfo :=  TCustomSynEdit(Source).FFoldedLinesView.GetFoldDescription(
                  BlockSel.FirstLineBytePos.Y - 1, BlockSel.FirstLineBytePos.X,
                  BlockSel.LastLineBytePos.Y - 1,  BlockSel.LastLineBytePos.X);
          sm := BlockSel.ActiveSelectionMode;
          if sm = smLine then
            sm := smNormal;

          // delete the selected text if necessary
          if DropMove then begin
            if Source <> Self then
              TCustomSynEdit(Source).SelText := ''
            else begin
              FInternalCaret.AssignFrom(FCaret);
              FInternalCaret.IncAutoMoveOnEdit;
              FBlockSelection.SelText := '';
              FInternalCaret.DecAutoMoveOnEdit;
              NewCaret := FInternalCaret.LineBytePos;
            end;
          end;
          // insert the selected text
          FCaret.IncForcePastEOL;
          try
            if (eoPersistentBlock in Options2) and SelAvail then
              SetTextBetweenPoints(NewCaret, NewCaret, DragDropText, [setMoveBlock], scamEnd, smaMoveUp, sm)
            else
              SetTextBetweenPoints(NewCaret, NewCaret, DragDropText, [setSelect], scamEnd, smaMoveUp, sm);
            if (FoldInfo <> '') and (sm <> smColumn) then begin
              ScanRanges;
              FFoldedLinesView.ApplyFoldDescription(NewCaret.Y -1, NewCaret.X,
                    FBlockSelection.EndLinePos-1, FBlockSelection.EndBytePos,
                    PChar(FoldInfo), length(FoldInfo));
            end;
          finally
            FCaret.DecForcePastEOL;
          end;
        finally
          InternalEndUndoBlock;
        end;
      end;
    finally
      DecPaintLock;
    end;
  end else
    inherited;
end;

procedure TCustomSynEdit.SetRightEdge(Value: Integer);
begin
  // Todo: check and invalidate in text area
  if FTextArea.RightEdgeColumn <> Value then begin
    FPaintArea.RightEdgeColumn := Value;
    if FTextArea.RightEdgeVisible then
      Invalidate;
  end;
end;

procedure TCustomSynEdit.SetRightEdgeColor(Value: TColor);
var
  nX: integer;
  rcInval: TRect;
begin
  // Todo: check and invalidate in text area
  if RightEdgeColor <> Value then begin
    FPaintArea.RightEdgeColor := Value;
    if HandleAllocated then begin
      nX := FTextArea.ScreenColumnToXValue(FTextArea.RightEdgeColumn + 1);
      rcInval := Rect(nX - 1, 0, nX + 1, ClientHeight-ScrollBarWidth);
      {$IFDEF VerboseSynEditInvalidate}
      DebugLn(['TCustomSynEdit.SetRightEdgeColor ',dbgs(rcInval)]);
      {$ENDIF}
      InvalidateRect(Handle, @rcInval, FALSE);
    end;
  end;
end;

function TCustomSynEdit.GetMaxUndo: Integer;
begin
  result := fUndoList.MaxUndoActions;
end;

procedure TCustomSynEdit.SetMaxUndo(const Value: Integer);
begin
  if Value > -1 then begin
    fUndoList.MaxUndoActions := Value;
    fRedoList.MaxUndoActions := Value;
  end;
end;

procedure TCustomSynEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then begin
    if AComponent = fHighlighter then begin
      fHighlighter.DetachFromLines(FLines);
      fHighlighter := nil;
      fMarkupHighCaret.Highlighter := nil;
      fMarkupWordGroup.Highlighter := nil;
      FFoldedLinesView.Highlighter := nil;
      FPaintArea.Highlighter := nil;
      if not (csDestroying in ComponentState) then begin
        RecalcCharExtent;
        Invalidate;
      end;
    end;
    if (BookMarkOptions <> nil) then
      if (AComponent = BookMarkOptions.BookmarkImages) then begin
        BookMarkOptions.BookmarkImages := nil;
        InvalidateGutterLines(-1, -1);
      end;
  end;
end;

procedure TCustomSynEdit.RemoveHooksFromHighlighter;
begin
  if not Assigned(fHighlighter) then
    exit;
  fHighlighter.UnhookAttrChangeEvent(@HighlighterAttrChanged);
  fHighlighter.DetachFromLines(FLines);
  fHighlighter.RemoveFreeNotification(self);
end;

procedure TCustomSynEdit.SetHighlighter(const Value: TSynCustomHighlighter);
begin
  if Value <> fHighlighter then begin
    FPendingFoldState := '';
    RemoveHooksFromHighlighter;
    if Assigned(Value) then begin
      Value.HookAttrChangeEvent(
        @HighlighterAttrChanged);
      Value.FreeNotification(Self);
      Value.AttachToLines(FLines);
    end;
    fHighlighter := Value;
    IncPaintLock;
    try
      // Ensure to free all copies in SynEit.Notification too
      fMarkupHighCaret.Highlighter := Value;
      fMarkupWordGroup.Highlighter := Value;
      FFoldedLinesView.Highlighter := Value;
      FPaintArea.Highlighter := Value;
      FWordBreaker.Reset;
      if fHighlighter<>nil then begin
        fTSearch.IdentChars := fHighlighter.IdentChars;
        FWordBreaker.IdentChars     := fHighlighter.IdentChars;
        FWordBreaker.WordBreakChars := fHighlighter.WordBreakChars;
      end else begin
        fTSearch.ResetIdentChars;
      end;
      RecalcCharExtent;
      ScanRanges; // Todo: Skip if paintlocked
      // There may not have been a scan
      if fHighlighter <> nil then
        FHighlighter.CurrentLines := FLines;
      FLines.SendNotification(senrHighlightChanged, FLines, -1, -1);
    finally
      DecPaintLock;
    end;
  end;
end;

procedure TCustomSynEdit.SetInsertMode(const Value: boolean);
begin
  if fInserting <> Value then begin
    fInserting := Value;
    if InsertMode then
      FScreenCaret.DisplayType := FInsertCaret
    else
      FScreenCaret.DisplayType := FOverwriteCaret;
    StatusChanged([scInsertMode]);
  end;
end;

procedure TCustomSynEdit.SetInsertCaret(const Value: TSynEditCaretType);
begin
  if FInsertCaret <> Value then begin
    FInsertCaret := Value;
    if InsertMode then
      FScreenCaret.DisplayType := fInsertCaret;
    StatusChanged([scOptions]);
  end;
end;

procedure TCustomSynEdit.SetOverwriteCaret(const Value: TSynEditCaretType);
begin
  if FOverwriteCaret <> Value then begin
    FOverwriteCaret := Value;
    if not InsertMode then
      FScreenCaret.DisplayType := fOverwriteCaret;
    StatusChanged([scOptions]);
  end;
end;

procedure TCustomSynEdit.SetMaxLeftChar(Value: integer);
begin
  Value := MinMax(Value, 1, MAX_SCROLL); // horz scrolling is only 16 bit
  if fMaxLeftChar <> Value then begin
    fMaxLeftChar := Value;
    Invalidate;
  end;
end;

procedure TCustomSynEdit.EnsureCursorPosVisible;
var
  PhysCaretXY: TPoint;
  MinX: Integer;
  MaxX: Integer;
  PhysBlockBeginXY: TPoint;
  PhysBlockEndXY: TPoint;
begin
  if (PaintLockOwner <> nil) and (PaintLockOwner <> Self) and
     (not (eoAlwaysVisibleCaret in fOptions2))
  then
    exit;

  if (not HandleAllocated) or (fPaintLock > 0) or
     (FWinControlFlags * [wcfInitializing, wcfCreatingHandle] <> [])
  then begin
    include(fStateFlags, sfEnsureCursorPos);
    exit;
  end;

  //{BUG21996} DebugLnEnter(['TCustomSynEdit.EnsureCursorPosVisible Caret=',dbgs(CaretXY),', BlockBegin=',dbgs(BlockBegin),' BlockEnd=',dbgs(BlockEnd), ' StateFlags=',dbgs(fStateFlags), ' paintlock', FPaintLock]);
  exclude(fStateFlags, sfEnsureCursorPos);
  DoIncPaintLock(Self); // No editing is taking place
  try
    // Make sure X is visible
    //DebugLn('[TCustomSynEdit.EnsureCursorPosVisible] A CaretX=',CaretX,' LeftChar=',LeftChar,' CharsInWindow=',CharsInWindow,' ClientWidth=',ClientWidth);
    PhysCaretXY:=FCaret.ViewedLineCharPos;
    // try to make the current selection visible as well
    MinX:=PhysCaretXY.X;
    MaxX:=PhysCaretXY.X;
    // sfMouseSelecting: ignore block while selecting by mouse
    if SelAvail and not(sfMouseSelecting in fStateFlags) then begin
      PhysBlockBeginXY:=FBlockSelection.ViewedFirstLineCharPos;
      PhysBlockEndXY  :=FBlockSelection.ViewedLastLineCharPos;
      if (PhysBlockBeginXY.X<>PhysBlockEndXY.X)
      or (PhysBlockBeginXY.Y<>PhysBlockEndXY.Y) then begin
        if (FBlockSelection.ActiveSelectionMode <> smColumn) and
           (PhysBlockBeginXY.Y<>PhysBlockEndXY.Y) then
          PhysBlockBeginXY.X:=1;
        if MinX>PhysBlockBeginXY.X then
          MinX:=Max(PhysBlockBeginXY.X,PhysCaretXY.X-CharsInWindow+1);
        if MinX>PhysBlockEndXY.X then
          MinX:=Max(PhysBlockEndXY.X,PhysCaretXY.X-CharsInWindow+1);
        if MaxX<PhysBlockBeginXY.X then
          MaxX:=Min(PhysBlockBeginXY.X,MinX+CharsInWindow-1);
        if MaxX<PhysBlockEndXY.X then
          MaxX:=Min(PhysBlockEndXY.X,MinX+CharsInWindow-1);
      end;
    end;
    if not (sfPreventScrollAfterSelect in fStateFlags) then begin
      if not (sfExplicitLeftChar in fStateFlags) then begin
        {DebugLn('TCustomSynEdit.EnsureCursorPosVisible A CaretX=',dbgs(PhysCaretXY.X),
          ' BlockX=',dbgs(PhysBlockBeginXY.X)+'-'+dbgs(PhysBlockEndXY.X),
          ' CharsInWindow='+dbgs(CharsInWindow), MinX='+dbgs(MinX),' MaxX='+dbgs(MaxX),
          ' LeftChar='+dbgs(LeftChar), '');}
        MaxX := MaxX - (Max(1, CharsInWindow) - 1 - FScreenCaret.ExtraLineChars);
        if (sfEnsureCursorPosForEditLeft in fStateFlags) then
          dec(MinX, FScrollOnEditLeftOptions.FCurrentDistance)
        else
        if (sfEnsureCursorPosForEditRight in fStateFlags) then
          inc(MaxX, FScrollOnEditRightOptions.FCurrentDistance);

        if MinX < LeftChar then begin
          if sfEnsureCursorPosForEditLeft in fStateFlags then
            MinX := Min(MinX,
                        PhysCaretXY.X - FScrollOnEditLeftOptions.FCurrentColumns);
          LeftChar := MinX;
        end
        else if LeftChar < MaxX then begin
          if sfEnsureCursorPosForEditRight in fStateFlags then
            MaxX := Max(MaxX,
                        PhysCaretXY.X + FScrollOnEditRightOptions.FCurrentColumns - (Max(1, CharsInWindow) - 1 - FScreenCaret.ExtraLineChars));
          LeftChar := MaxX;
        end
        else
          LeftChar := LeftChar;                                                     //mh 2000-10-19
      end;
      if not (sfExplicitTopLine in fStateFlags) then begin
        //DebugLn(['TCustomSynEdit.EnsureCursorPosVisible B LeftChar=',LeftChar,' MinX=',MinX,' MaxX=',MaxX,' CharsInWindow=',CharsInWindow]);
        // Make sure Y is visible
        if PhysCaretXY.Y < TopView then
          TopView := PhysCaretXY.Y
        else if PhysCaretXY.Y > TopView + Max(0, LinesInWindow-1)
        then
          TopView := PhysCaretXY.Y - Max(0, LinesInWindow-1)
        else
          TopView := TopView;                                                       //mh 2000-10-19
      end;
    end;
    fStateFlags := fStateFlags - [sfPreventScrollAfterSelect, sfEnsureCursorPosForEditRight, sfEnsureCursorPosForEditLeft];
  finally
    DoDecPaintLock(Self);
    //{BUG21996} DebugLnExit(['TCustomSynEdit.EnsureCursorPosVisible Caret=',dbgs(CaretXY),', BlockBegin=',dbgs(BlockBegin),' BlockEnd=',dbgs(BlockEnd), ' StateFlags=',dbgs(fStateFlags), ' paintlock', FPaintLock]);
  end;
end;

procedure TCustomSynEdit.SetKeystrokes(const Value: TSynEditKeyStrokes);
begin
  if Value = nil then
    FKeystrokes.Clear
  else
    FKeystrokes.Assign(Value);
end;

procedure TCustomSynEdit.SetExtraCharSpacing(const Value: integer);
begin
  if ExtraCharSpacing=Value then exit;
  inherited;
  FPaintArea.ExtraCharSpacing := Value;
  FontChanged(self);
end;

procedure TCustomSynEdit.SetLastMouseCaret(const AValue: TPoint);
begin
  if (FLastMouseLocation.LastMouseCaret.X=AValue.X) and (FLastMouseLocation.LastMouseCaret.Y=AValue.Y) then exit;
  FLastMouseLocation.LastMouseCaret:=AValue;
  if assigned(fMarkupCtrlMouse) then
    fMarkupCtrlMouse.LastMouseCaret := AValue;
  UpdateCursor;
end;

procedure TCustomSynEdit.SetDefaultKeystrokes;
begin
  FKeystrokes.ResetDefaults;
end;

procedure TCustomSynEdit.ResetMouseActions;
begin
  FMouseActions.Options := MouseOptions;
  FMouseActions.ResetUserActions;
  FMouseSelActions.Options := MouseOptions;
  FMouseSelActions.ResetUserActions;
  FMouseTextActions.Options := MouseOptions;
  FMouseTextActions.ResetUserActions;

  FLeftGutter.ResetMouseActions;
  FRightGutter.ResetMouseActions;
end;

procedure TCustomSynEdit.CommandProcessor(Command: TSynEditorCommand; AChar: TUTF8Char;
  Data: pointer; ASkipHooks: THookedCommandFlags);
var
  InitialCmd: TSynEditorCommand;
  BeautifyWorker: TSynCustomBeautifier;
begin
  IncLCLRefCount;
  try
    {$IFDEF VerboseKeys}
    DebugLn(['[TCustomSynEdit.CommandProcessor] ',Command
      ,' AChar=',AChar,' Data=',DbgS(Data)]);
    {$ENDIF}
    if (Command <> ecMoveSelectUp) and (Command <> ecMoveSelectDown) then
      FLastCaretXForMoveSelection := -1;
    // first the program event handler gets a chance to process the command
    InitialCmd := Command;
    if not(hcfInit in ASkipHooks) then
      NotifyHookedCommandHandlers(Command, AChar, Data, hcfInit);
    DoOnProcessCommand(Command, AChar, Data);
    if Command <> ecNone then begin
      try
        InternalBeginUndoBlock;
        FBeautifyStartLineIdx := -1;
        FBeautifyEndLineIdx := -1;
        if assigned(FBeautifier) then begin
          BeautifyWorker := FBeautifier.GetCopy;
          BeautifyWorker.AutoIndent := (eoAutoIndent in FOptions);
          BeautifyWorker.BeforeCommand(self, FTheLinesView, FCaret, Command, InitialCmd);
        end;
        // notify hooked command handlers before the command is executed inside of
        // the class
        if (Command <> ecNone) and not(hcfPreExec in ASkipHooks) then
          NotifyHookedCommandHandlers(Command, AChar, Data, hcfPreExec);
        // internal command handler
        if (Command <> ecNone) and (Command < ecUserFirst) then
          ExecuteCommand(Command, AChar, Data);
        // notify hooked command handlers after the command was executed inside of
        // the class (only if NOT handled by hcfPreExec)
        if (Command <> ecNone) and not(hcfPostExec in ASkipHooks) then
          NotifyHookedCommandHandlers(Command, AChar, Data, hcfPostExec);
        if Command <> ecNone then
          DoOnCommandProcessed(Command, AChar, Data);

        if assigned(BeautifyWorker) then begin
          tsyneditstringlist(FLines).FlushNotificationCache;
          BeautifyWorker.AutoIndent := (eoAutoIndent in FOptions);
          BeautifyWorker.AfterCommand(self, FTheLinesView, FCaret, Command, InitialCmd,
                                   FBeautifyStartLineIdx+1, FBeautifyEndLineIdx+1);
          FreeAndNil(BeautifyWorker);
        end;
      finally
        InternalEndUndoBlock;
        {$IFDEF SynCheckPaintLock}
        if (FPaintLock > 0) and (FInvalidateRect.Bottom >= FInvalidateRect.Top) then begin
          debugln(['TCustomSynEdit.CommandProcessor: Paint called while locked  InitialCmd=', InitialCmd, ' Command=', Command]);
          DumpStack;
        end;
        {$ENDIF}
      end;
    end;
    Command := InitialCmd;
    if not(hcfFinish in ASkipHooks) then
      NotifyHookedCommandHandlers(Command, AChar, Data, hcfFinish);
  finally
    DecLCLRefCount;
  end;
end;

procedure TCustomSynEdit.ExecuteCommand(Command: TSynEditorCommand;
  const AChar: TUTF8Char; Data: pointer);
const
  SEL_MODE: array[ecNormalSelect..ecLineSelect] of TSynSelectionMode = (
    smNormal, smColumn, smLine);
var
  CX: Integer;
  Len: Integer;
  Temp: string;
  Helper: string;
  moveBkm, CurBack: boolean;
  WP: TPoint;
  Caret: TPoint;
  CaretNew: TPoint;
  counter: Integer;
  LogCounter: integer;
  LogCaretXY: TPoint;
  CY: Integer;
  CurSm: TSynSelectionMode;

begin
  IncPaintLock;
  IncLCLRefCount;
  try
    fUndoList.CurrentReason := Command;

    if Command in [ecSelectionStart..ecSelectionEnd] then
      FBlockSelection.StickyAutoExtend := False;

    if Command in [ecSelColCmdRangeStart..ecSelColCmdRangeEnd] then
      FBlockSelection.ActiveSelectionMode := smColumn;
    if Command in [ecSelCmdRangeStart..ecSelCmdRangeEnd] then
      FBlockSelection.ActiveSelectionMode := FBlockSelection.SelectionMode;
    if (Command <> ecMoveSelectUp) and (Command <> ecMoveSelectDown) then
      FLastCaretXForMoveSelection := -1;

    FBlockSelection.AutoExtend := Command in [ecSelectionStart..ecSelectionEnd];
    FCaret.ChangeOnTouch;

    case Command of
// horizontal caret movement or selection
      ecLeft, ecSelLeft, ecColSelLeft:
        begin
          if (eoCaretSkipsSelection in Options2) and (Command=ecLeft)
          and SelAvail and FCaret.IsAtLineByte(FBlockSelection.LastLineBytePos) then begin
            if not (eoCaretMoveEndsSelection in Options2) then
              FBlockSelection.IgnoreNextCaretMove;
            FCaret.LineBytePos := FBlockSelection.FirstLineBytePos;
          end
          else
          if (eoCaretMoveEndsSelection in Options2) and SelAvail then
            FBlockSelection.Clear
          else
            MoveCaretHorz(-1);
        end;
      ecRight, ecSelRight, ecColSelRight:
        begin
          if (eoCaretSkipsSelection in Options2) and (Command=ecRight)
          and SelAvail and FCaret.IsAtLineByte(FBlockSelection.FirstLineBytePos) then begin
            if not (eoCaretMoveEndsSelection in Options2) then
              FBlockSelection.IgnoreNextCaretMove;
            FCaret.LineBytePos := FBlockSelection.LastLineBytePos;
          end
          else
          if (eoCaretMoveEndsSelection in Options2) and SelAvail then
            FBlockSelection.Clear
          else
            MoveCaretHorz(1);
        end;
      ecPageLeft, ecSelPageLeft, ecColSelPageLeft:
        begin
          FCaret.CharPos := Max(1, FCaret.CharPos - Max(1, CharsInWindow));
        end;
      ecPageRight, ecSelPageRight, ecColSelPageRight:
        begin
          FCaret.IncForceAdjustToNextChar;
          FCaret.CharPos := FCaret.CharPos + Max(1, CharsInWindow);
          FCaret.DecForceAdjustToNextChar;
        end;
      ecLineStart, ecSelLineStart, ecColSelLineStart:
        begin
          DoHomeKey;
        end;
      ecLineTextStart, ecSelLineTextStart, ecColSelLineTextStart:
        begin
          DoHomeKey(synhmFirstWord);
        end;
      ecLineEnd, ecSelLineEnd, ecColSelLineEnd:
        begin
          DoEndKey;
        end;
// vertical caret movement or selection
      ecUp, ecSelUp, ecColSelUp:
        begin
          MoveCaretVert(-1, (Command = ecUp) or (Command = ecSelUp) );
        end;
      ecDown, ecSelDown, ecColSelDown:
        begin
          MoveCaretVert(1, (Command = ecDown) or (Command = ecSelDown));
        end;
      ecPageUp, ecSelPageUp, ecPageDown, ecSelPageDown, ecColSelPageUp, ecColSelPageDown:
        begin
          counter := LinesInWindow;
          if (eoHalfPageScroll in fOptions) then counter:=counter div 2;
          if eoScrollByOneLess in fOptions then
            Dec(counter);
          counter := Max(1, counter);
          if (Command in [ecPageUp, ecSelPageUp, ecColSelPageUp]) then
            counter := -counter;
          TopView := TopView + counter;
          MoveCaretVert(counter,
            (Command = ecPageUp) or (Command = ecSelPageUp) or
            (Command = ecPageDown) or (Command = ecSelPageDown)
          );
        end;
      ecPageTop, ecSelPageTop, ecColSelPageTop:
        begin
          FCaret.LinePos := TopLine;
        end;
      ecPageBottom, ecSelPageBottom, ecColSelPageBottom:
        begin
          FCaret.LinePos := ScreenRowToRow(LinesInWindow - 1);
        end;
      ecEditorTop, ecSelEditorTop:
        begin
          FCaret.LineCharPos := Point(1, ToPos(FTheLinesView.ViewToTextIndex(0)));
        end;
      ecEditorBottom, ecSelEditorBottom:
        begin
          CaretNew := Point(1, ToPos(FTheLinesView.ViewToTextIndex(ToIdx(FTheLinesView.ViewedCount))));
          if (CaretNew.Y > 0) then
            CaretNew.X := Length(FTheLinesView[CaretNew.Y - 1]) + 1;
          FCaret.LineCharPos := CaretNew;
        end;
      ecColSelEditorTop:
        begin
          FCaret.LinePos := ToPos(FTheLinesView.ViewToTextIndex(0));
        end;
      ecColSelEditorBottom:
        begin
          FCaret.LinePos := ToPos(FTheLinesView.ViewToTextIndex(ToIdx(FTheLinesView.ViewedCount)));
        end;

// goto special line / column position
      ecGotoXY, ecSelGotoXY:
        if Assigned(Data) then begin
          FCaret.LineCharPos := PPoint(Data)^;
        end;
// word selection
      ecWordLeft, ecSelWordLeft, ecColSelWordLeft,
      ecWordEndLeft, ecSelWordEndLeft, ecHalfWordLeft, ecSelHalfWordLeft,
      ecSmartWordLeft, ecSelSmartWordLeft:
        begin
          case Command of
            ecWordEndLeft, ecSelWordEndLeft:     CaretNew := PrevWordLogicalPos(swbWordEnd);
            ecHalfWordLeft, ecSelHalfWordLeft:   CaretNew := PrevWordLogicalPos(swbCaseChange);
            ecSmartWordLeft, ecSelSmartWordLeft: CaretNew := PrevWordLogicalPos(swbWordSmart);
            else                                 CaretNew := PrevWordLogicalPos;
          end;
          if not FTheLinesView.IsTextIdxVisible(ToIdx(CaretNew.Y)) then begin
            CY := FindNextUnfoldedLine(CaretNew.Y, False);
            CaretNew := Point(1 + Length(FTheLinesView[CY-1]), CY);
          end;
          FCaret.LineBytePos := CaretNew;
        end;
      ecWordRight, ecSelWordRight, ecColSelWordRight,
      ecWordEndRight, ecSelWordEndRight, ecHalfWordRight, ecSelHalfWordRight,
      ecSmartWordRight, ecSelSmartWordRight:
        begin
          case Command of
            ecWordEndRight, ecSelWordEndRight:     CaretNew := NextWordLogicalPos(swbWordEnd);
            ecHalfWordRight, ecSelHalfWordRight:   CaretNew := NextWordLogicalPos(swbCaseChange);
            ecSmartWordRight, ecSelSmartWordRight: CaretNew := NextWordLogicalPos(swbWordSmart);
            else                                   CaretNew := NextWordLogicalPos;
          end;
          if not FTheLinesView.IsTextIdxVisible(ToIdx(CaretNew.Y)) then
            CaretNew := Point(1, FindNextUnfoldedLine(CaretNew.Y, True));
          FCaret.LineBytePos := CaretNew;
        end;
      ecStickySelection, ecStickySelectionCol, ecStickySelectionLine: begin
          case command of
            ecStickySelection:     FBlockSelection.ActiveSelectionMode := smNormal;
            ecStickySelectionCol:  FBlockSelection.ActiveSelectionMode := smColumn;
            ecStickySelectionLine: FBlockSelection.ActiveSelectionMode := smLine;
          end;
          FBlockSelection.StickyAutoExtend := True;
        end;
      ecStickySelectionStop: begin
          FBlockSelection.StickyAutoExtend := False;
        end;
      ecSelectAll:
        begin
          SelectAll;
        end;
      ecDeleteLastChar:
        if not ReadOnly then begin
          if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then
            SetSelTextExternal('')
          else begin
            Temp := LineText;
            Len := Length(Temp);
            LogCaretXY := FCaret.LineBytePos;
            Caret := CaretXY;
            //debugln('ecDeleteLastChar B Temp="',DbgStr(Temp),'" CaretX=',dbgs(CaretX),' LogCaretXY=',dbgs(LogCaretXY));
            if LogCaretXY.X > Len +1
            then begin
              // past EOL; only move caret one column
              FCaret.IncForcePastEOL;
              CaretX := CaretX - 1;
              FCaret.DecForcePastEOL;
            end else if CaretX = 1 then begin
              // join this line with the last line if possible
              if CaretY > 1 then begin
                CaretY := CaretY - 1;
                CaretX := PhysicalLineLength(FTheLinesView[CaretY - 1],
                                             CaretY - 1) + 1;
                FTheLinesView.EditLineJoin(CaretY);
              end;
            end else begin
              // delete char
              LogCounter := LogCaretXY.X;
              if FCaret.BytePosOffset = 0 then begin
                LogCaretXY.X := FTheLinesView.LogicPosAddChars(Temp, LogCaretXY.X, -1, [lpStopAtCodePoint]);
                LogCounter := LogCounter - LogCaretXY.X;
              end
              else
                LogCounter :=  GetCharLen(Temp, LogCaretXY.X);
              FTheLinesView.EditDelete(LogCaretXY.X, LogCaretXY.Y, LogCounter);
              FCaret.BytePos := LogCaretXY.X;
              Include(fStateFlags, sfEnsureCursorPosForEditLeft);
            end;
          end;
        end;
      ecDeleteChar, ecDeleteCharNoCrLf:
        if not ReadOnly then begin
          if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then
            SetSelTextExternal('')
          else begin
            Temp := LineText;
            Len := Length(Temp);
            LogCaretXY:=LogicalCaretXY;
            if LogCaretXY.X <= Len then
            begin
              // delete char
              Counter:=GetCharLen(Temp,LogCaretXY.X);
              FTheLinesView.EditDelete(LogCaretXY.X, CaretY, Counter);
              SetLogicalCaretXY(LogCaretXY);
            end
            else
            if Command = ecDeleteChar then begin
              // join line with the line after
              if CaretY < FTheLinesView.Count then begin
                Helper := StringOfChar(' ', LogCaretXY.X - 1 - Len);
                FTheLinesView.EditLineJoin(CaretY, Helper);
              end;
            end;
          end;
        end;
      ecDeleteWord, ecDeleteEOL:
        if not ReadOnly then begin
          Helper := '';
          Caret := CaretXY;
          if Command = ecDeleteWord then begin
            Len := LogicalToPhysicalCol(LineText, CaretY-1,Length(LineText)+1)-1;
            if CaretX > Len + 1 then begin
              Helper := StringOfChar(' ', CaretX - 1 - Len);
              CaretX := 1 + Len;
            end;
            // if we are not in a word, delete word + spaces (up to next token)
            if WordBreaker.IsAtWordStart(LineText, LogicalCaretXY.X) or
               WordBreaker.IsAtWordEnd(LineText, LogicalCaretXY.X) or
               (not WordBreaker.IsInWord(LineText, LogicalCaretXY.X)) or
               (LogicalCaretXY.X > Length(LineText))
            then
              WP := NextWordLogicalPos(swbTokenBegin, True)
            else
              // if we are inside a word, delete to word-end
              WP := NextWordLogicalPos(swbWordEnd, True);
          end else
            WP := Point(Length(LineText) + 1, CaretY);
          if (WP.X <> FCaret.BytePos) or (WP.Y <> FCaret.LinePos) then begin
            FInternalBlockSelection.StartLineBytePos := WP;
            FInternalBlockSelection.EndLineBytePos := LogicalCaretXY;
            FInternalBlockSelection.ActiveSelectionMode := smNormal;
            FInternalBlockSelection.SetSelTextPrimitive(smNormal, PChar(Helper));
            FCaret.BytePos := FInternalBlockSelection.StartBytePos;
          end;
        end;
      ecDeleteLastWord, ecDeleteBOL:
        if not ReadOnly then begin
          if Command = ecDeleteLastWord then
            WP := PrevWordLogicalPos
          else
            WP := Point(1, CaretY);
          if (WP.X <> FCaret.BytePos) or (WP.Y <> FCaret.LinePos) then begin
            FInternalBlockSelection.StartLineBytePos := WP;
            FInternalBlockSelection.EndLineBytePos := LogicalCaretXY;
            FInternalBlockSelection.ActiveSelectionMode := smNormal;
            FInternalBlockSelection.SetSelTextPrimitive(smNormal, nil);
            FCaret.LineBytePos := WP;
          end;
        end;
      ecDeleteLine:
        if not ReadOnly
        then begin
          CY := FCaret.LinePos;
          if (Cy < FTheLinesView.Count) then
            FTheLinesView.EditLinesDelete(CaretY, 1)
          else
          if (Cy = FTheLinesView.Count) and (FTheLinesView[CY-1] <> '') then
            FTheLinesView.EditDelete(1, Cy, length(FTheLinesView[Cy-1]));
          CaretXY := Point(1, CaretY); // like seen in the Delphi editor
        end;
      ecClearAll:
        begin
          if not ReadOnly then ClearAll;
        end;
      ecInsertLine,
      ecLineBreak:
        if not ReadOnly then begin
          if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then
            SetSelTextExternal('');
          Temp := LineText;
          LogCaretXY:=LogicalCaretXY;
          Len := Length(Temp);
          if LogCaretXY.X > Len + 1 then
            LogCaretXY.X := Len + 1;
          FTheLinesView.EditLineBreak(LogCaretXY.X, LogCaretXY.Y);
          if Command = ecLineBreak then
            CaretXY := Point(1, CaretY + 1)
          else
            CaretXY := CaretXY;
        end;
      ecTab:
        if not ReadOnly then
        try
          FCaret.IncForcePastEOL;
          DoTabKey;
        finally
          FCaret.DecForcePastEOL;
        end;
      ecShiftTab:
        if not ReadOnly then
          if SelAvail and (eoTabIndent in Options) then
            DoBlockUnindent;
      ecMatchBracket:
        FindMatchingBracket;
      ecChar:
        if not ReadOnly and ((AChar = #9) or (AChar >= #32)) and (AChar <> #127) then begin
          if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then begin
            SetSelTextExternal(AChar);
          end else begin
            try
              FCaret.IncForcePastEOL;
              FCaret.IncForceAdjustToNextChar;

              LogCaretXY := FCaret.LineBytePos;
              Temp := LineText;
              Len := Length(Temp);
              if (not fInserting) and (LogCaretXY.X - 1 < Len) then begin
                counter := GetCharLen(Temp,LogCaretXY.X);
                FTheLinesView.EditDelete(LogCaretXY.X, LogCaretXY.Y, counter);
                Len := Len - counter;
              end;

              {$IFDEF USE_UTF8BIDI_LCL}
              // TODO: improve utf8bidi for tabs
              Len := VLength(LineText, drLTR);
              (*if Len < CaretX then
                Temp := StringOfChar(' ', CaretX - Len)
              else
                Temp := '' *)
              FTheLinesView.EditInsert(CaretX, LogCaretXY.Y, (*Temp +*) AChar);
              {$ELSE}
              FTheLinesView.EditInsert(LogCaretXY.X, LogCaretXY.Y, (*Temp +*) AChar);
              {$ENDIF}

              //CaretX := CaretX + 1;
              FCaret.BytePos := LogCaretXY.X + length(AChar);
              Include(fStateFlags, sfEnsureCursorPosForEditRight);
            finally
              FCaret.DecForceAdjustToNextChar;
              FCaret.DecForcePastEOL;
            end;
          end;
        end
        else if not ReadOnly and (AChar = #13) then begin
          // ecLineBreak is not assigned
          // Insert a linebreak, but do not apply any other functionality (such as indent)
          if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then
            SetSelTextExternal('');
          LogCaretXY:=LogicalCaretXY;
          FTheLinesView.EditLineBreak(LogCaretXY.X, LogCaretXY.Y);
          CaretXY := Point(1, CaretY + 1);
          EnsureCursorPosVisible;
        end;
      ecUndo:
        begin
          if not ReadOnly then Undo;
        end;
      ecRedo:
        begin
          if not ReadOnly then Redo;
        end;
      ecGotoMarker0..ecGotoMarker9:
        begin
          if BookMarkOptions.EnableKeys then
            GotoBookMark(Command - ecGotoMarker0);
        end;
      ecSetMarker0..ecSetMarker9,ecToggleMarker0..ecToggleMarker9:
        begin
          if BookMarkOptions.EnableKeys then begin
            if (Command >= ecSetMarker0) and (Command <= ecSetMarker9) then
              CX := Command - ecSetMarker0
            else
              CX := Command - ecToggleMarker0;
            if assigned(fBookMarks[CX]) then begin
              moveBkm := ((Command >= ecSetMarker0) and (Command <= ecSetMarker9))
                         or (fBookMarks[CX].Line <> CaretY);
              ClearBookMark(CX);
              if moveBkm then
                SetBookMark(CX, CaretX, CaretY);
            end else
              SetBookMark(CX, CaretX, CaretY);
          end; // if BookMarkOptions.EnableKeys
        end;
      ecCut:
        begin
          if (not ReadOnly) and SelAvail then
            CutToClipboard;
        end;
      ecCopy:
        begin
          CopyToClipboard;
        end;
      ecPaste, ecPasteAsColumns:
        begin
          if not ReadOnly then PasteFromClipboard(Command = ecPasteAsColumns);
        end;
      ecCopyAdd, ecCutAdd:
        if SelAvail then begin
          Temp := Clipboard.AsText;
          Helper := SelText;
          if (Temp <> '') and (not (Temp[Length(Temp)] in [#10,#13, #9, #32])) and
             (not (Helper[1] in [#10,#13, #9, #32]))
          then
            Temp := Temp + ' ';
          Clipboard.AsText := Temp + Helper;
          if (not ReadOnly) and (Command = ecCutAdd) then
            SelText := '';
        end;
      ecCopyCurrentLine, ecCutCurrentLine,
      ecCopyAddCurrentLine, ecCutAddCurrentLine:
        begin
          FInternalBlockSelection.AssignFrom(FBlockSelection);
          FInternalBlockSelection.ActiveSelectionMode := smLine;
          FInternalBlockSelection.ForceSingleLineSelected := True;
          Temp := '';
          if (Command = ecCopyAddCurrentLine) or (Command = ecCutAddCurrentLine) then begin
            Temp := Clipboard.AsText;
            if (Temp <> '') and not (Temp[Length(Temp)] in [#10,#13]) then
              Temp := Temp + LineEnding;
          end;
          Clipboard.AsText := Temp + FInternalBlockSelection.SelText;
          if (not ReadOnly) and ((Command = ecCutCurrentLine) or (Command = ecCutAddCurrentLine)) then begin
            FCaret.IncAutoMoveOnEdit;
            FInternalBlockSelection.SelText := '';
            FCaret.DecAutoMoveOnEdit;
          end;
          FInternalBlockSelection.ForceSingleLineSelected := False;
        end;
      ecMoveLineUp:
        if (not ReadOnly) then begin
          if FBlockSelection.SelAvail then
            CY := BlockBegin.Y
          else
            CY := FCaret.LinePos;
          if CY > 1 then begin
            InternalBeginUndoBlock;
            if not FBlockSelection.SelAvail then
              FBlockSelection.Clear;
            FBlockSelection.IncPersistentLock(sbpWeak);
            if SelAvail and (BlockEnd.x = 1) then
              FTheLinesView.EditLinesInsert(BlockEnd.y, 1, FTheLinesView[ToIdx(CY) - 1])
            else
              FTheLinesView.EditLinesInsert(BlockEnd.y + 1, 1, FTheLinesView[ToIdx(CY) - 1]);
            FCaret.IncAutoMoveOnEdit;
            FTheLinesView.EditLinesDelete(CY - 1, 1);
            FCaret.DecAutoMoveOnEdit;
            FBlockSelection.DecPersistentLock;
            InternalEndUndoBlock;
          end;
        end;
      ecMoveLineDown:
        if (not ReadOnly) then begin
          if FBlockSelection.SelAvail then begin
            CY := BlockEnd.Y;
            if (BlockEnd.x = 1) then
              Dec(CY);
          end
          else
            CY := FCaret.LinePos;
          if CY < FTheLinesView.Count - 1 then begin
            InternalBeginUndoBlock;
            if not FBlockSelection.SelAvail then
              FBlockSelection.Clear;
            FBlockSelection.IncPersistentLock(sbpWeak);
            FCaret.IncAutoMoveOnEdit;
            FTheLinesView.EditLinesInsert(BlockBegin.y, 1, FTheLinesView[ToIdx(CY) + 1]);
            FTheLinesView.EditLinesDelete(CY + 2, 1);
            FCaret.DecAutoMoveOnEdit;
            FBlockSelection.DecPersistentLock;
            InternalEndUndoBlock;
          end;
        end;
      ecDuplicateLine:
        if (not ReadOnly) then begin
          InternalBeginUndoBlock;
          if not FBlockSelection.SelAvail then
            FBlockSelection.Clear;
          FBlockSelection.IncPersistentLock(sbpWeak);
          FInternalBlockSelection.AssignFrom(FBlockSelection);
          if FInternalBlockSelection.IsBackwardSel then begin
            FInternalBlockSelection.StartLineBytePos := FBlockSelection.EndLineBytePos;
            FInternalBlockSelection.EndLineBytePos   := FBlockSelection.StartLineBytePos;
          end;
          FInternalBlockSelection.ActiveSelectionMode := smLine;
          FInternalBlockSelection.ForceSingleLineSelected := True;
          If (FInternalBlockSelection.EndBytePos = 1) and
             (FInternalBlockSelection.EndLinePos > FInternalBlockSelection.StartLinePos)
          then
            FInternalBlockSelection.EndLineBytePos := Point(1, FInternalBlockSelection.EndLinePos-1);
          Temp := FInternalBlockSelection.SelText;
          FInternalBlockSelection.ForceSingleLineSelected := False;
          FInternalBlockSelection.StartLineBytePos := Point(1, FInternalBlockSelection.LastLineBytePos.y+1);
          FInternalBlockSelection.SelText := Temp;
          FBlockSelection.DecPersistentLock;
          InternalEndUndoBlock;
        end;
      ecMoveSelectUp,
      ecMoveSelectDown,
      ecMoveSelectLeft,
      ecMoveSelectRight:
        if (not ReadOnly) and SelAvail then begin
          InternalBeginUndoBlock;
          if FLastCaretXForMoveSelection < 0 then
            FLastCaretXForMoveSelection := FBlockSelection.FirstLineBytePos.x;
          CurSm := FBlockSelection.ActiveSelectionMode;
          CurBack := FBlockSelection.IsBackwardSel;
          Temp := FBlockSelection.SelText;

          if CurSm = smColumn then
            FCaret.IncForcePastEOL;
          SetSelTextExternal('');
          FCaret.LineBytePos := FBlockSelection.StartLineBytePos;
          if (Command = ecMoveSelectUp) or (Command = ecMoveSelectDown) then
            FCaret.KeepCaretXPos := FLastCaretXForMoveSelection;
          case Command of
            ecMoveSelectUp:    MoveCaretVert(-1);
            ecMoveSelectDown:  MoveCaretVert(1);
            ecMoveSelectLeft:  FCaret.MoveHoriz(-1);
            ecMoveSelectRight: FCaret.MoveHoriz(1);
          end;
          FBlockSelection.Clear;
          FBlockSelection.SetSelTextPrimitive(CurSm, PChar(Temp), False, True);

          if CurBack then begin
            FBlockSelection.SortSelectionPoints(True);
            FCaret.LineBytePos := FBlockSelection.EndLineBytePos;
          end;
          if (Command = ecMoveSelectUp) or (Command = ecMoveSelectDown) then
            FCaret.KeepCaretXPos := FLastCaretXForMoveSelection;

          if CurSm = smColumn then
            FCaret.DecForcePastEOL;
          InternalEndUndoBlock;
        end;
      ecDuplicateSelection:
        if (not ReadOnly) and SelAvail then begin
          InternalBeginUndoBlock;
          FCaret.IncForcePastEOL;
          CurSm := FBlockSelection.ActiveSelectionMode;
          CurBack := FBlockSelection.IsBackwardSel;
          Temp := FBlockSelection.SelText;
          FCaret.LineBytePos := FBlockSelection.FirstLineBytePos;
          FBlockSelection.Clear;
          FBlockSelection.SetSelTextPrimitive(CurSm, PChar(Temp), False, True);
          if CurBack then
            FBlockSelection.SortSelectionPoints(True);
          FCaret.DecForcePastEOL;
          InternalEndUndoBlock;
        end;
      ecScrollUp:
        begin
          TopView := TopView - 1;
          if CaretY > ScreenRowToRow(LinesInWindow-1) then
            CaretY := ScreenRowToRow(LinesInWindow-1);
        end;
      ecScrollDown:
        begin
          TopView := TopView + 1;
          if CaretY < TopLine then
            CaretY := TopLine;
        end;
      ecScrollLeft:
        begin
          LeftChar := LeftChar - 1;
          if CaretX > LeftChar + CharsInWindow then
            CaretX := LeftChar + CharsInWindow;
        end;
      ecScrollRight:
        begin
          LeftChar := LeftChar + 1;
          if CaretX < LeftChar then
            CaretX := LeftChar;
        end;
      ecInsertMode:
        begin
          InsertMode := TRUE;
        end;
      ecOverwriteMode:
        begin
          InsertMode := FALSE;
        end;
      ecToggleMode:
        begin
          InsertMode := not InsertMode;
        end;
      ecBlockSetBegin:
        begin
          FBlockSelection.Hide :=
            CompareCarets(FCaret.LineBytePos, FBlockSelection.EndLineBytePos) <= 0;
          FBlockSelection.StartLineBytePosAdjusted := FCaret.LineBytePos;
        end;
      ecBlockSetEnd:
        begin
          FBlockSelection.Hide :=
            CompareCarets(FCaret.LineBytePos, FBlockSelection.StartLineBytePos) >= 0;
          FBlockSelection.EndLineBytePos := FCaret.LineBytePos;
        end;
      ecBlockToggleHide:
        begin
          FBlockSelection.Hide := not FBlockSelection.Hide;
        end;
      ecBlockHide:
        begin
          FBlockSelection.Hide := True;
        end;
      ecBlockShow:
        begin
          FBlockSelection.Hide := False;
        end;
      ecBlockMove:
        begin
          if SelAvail then begin
            helper := FBlockSelection.SelText;
            FInternalBlockSelection.AssignFrom(FBlockSelection);
            FBlockSelection.IncPersistentLock;
            FBlockSelection.StartLineBytePos := FCaret.LineBytePos;             // Track the Adjustment of the insert position
            FInternalBlockSelection.SelText := '';
            FCaret.LineBytePos := FBlockSelection.StartLineBytePos;
            Caret := FCaret.LineBytePos;
            FBlockSelection.SelText := Helper;
            FBlockSelection.DecPersistentLock;
            CaretNew := FCaret.LineBytePos;
            FBlockSelection.StartLineBytePos := Caret;
            FBlockSelection.EndLineBytePos := CaretNew;
          end;
        end;
      ecBlockCopy:
        begin
          if SelAvail then
            InsertTextAtCaret(FBlockSelection.SelText, scamEnd);
        end;
      ecBlockDelete:
        begin
          if SelAvail then
            FBlockSelection.SelText := '';
        end;
      ecBlockGotoBegin:
        begin
          FCaret.LineBytePos := FBlockSelection.FirstLineBytePos;
        end;
      ecBlockGotoEnd:
        begin
          FCaret.LineBytePos := FBlockSelection.LastLineBytePos;
        end;

      ecBlockIndent:
        if not ReadOnly then DoBlockIndent;
      ecBlockUnindent:
        if not ReadOnly then DoBlockUnindent;
      ecNormalSelect,
      ecColumnSelect,
      ecLineSelect:
        begin
          DefaultSelectionMode := SEL_MODE[Command];
        end;
      EcToggleMarkupWord:
          FMarkupHighCaret.ToggleCurrentWord;
      ecZoomOut, ecZoomIn: begin
          if not (( (Command = ecZoomOut) and (abs(Font.Height) < 3) ) or
                  ( (Command = ecZoomIn) and (abs(Font.Height) > 50) ))
          then begin
            CY := 1;
            if Command = ecZoomIn then CY := -1;
            CX := FLastSetFontSize;
            if Font.Height < 0
            then Font.Height := Font.Height + CY
            else Font.Height := Font.Height - CY;
            FLastSetFontSize := CX;
          end;
        end;
      ecZoomNorm: begin
          Font.Height := FLastSetFontSize;
        end;
    end;
  finally
    DecPaintLock;
    DecLCLRefCount;
  end;
end;

procedure TCustomSynEdit.DoOnCommandProcessed(Command: TSynEditorCommand;
  AChar: TUTF8Char;
  Data: pointer);
begin
  if Assigned(fOnCommandProcessed) then
    fOnCommandProcessed(Self, Command, AChar, Data);
end;

procedure TCustomSynEdit.DoOnProcessCommand(var Command: TSynEditorCommand;
  var AChar: TUTF8Char; Data: pointer);
begin
  //DebugLn(['TCustomSynEdit.DoOnProcessCommand Command=',Command]);
  if Command < ecUserFirst then begin
    if Assigned(FOnProcessCommand) then
      FOnProcessCommand(Self, Command, AChar, Data);
  end else begin
    if Assigned(FOnProcessUserCommand) then
      FOnProcessUserCommand(Self, Command, AChar, Data);
  end;
end;

procedure TCustomSynEdit.ClearAll;
begin
  InternalBeginUndoBlock;
  try
    SelectAll;
    SelText:='';
  finally
    InternalEndUndoBlock;
  end;
end;

procedure TCustomSynEdit.ClearSelection;
begin
  if SelAvail then
    SelText := '';
end;

function TCustomSynEdit.GetSelectionMode : TSynSelectionMode;
begin
  Result := fBlockSelection.ActiveSelectionMode;
end;

procedure TCustomSynEdit.SetSelectionMode(const Value: TSynSelectionMode);
begin
  fBlockSelection.ActiveSelectionMode := Value;
end;

procedure TCustomSynEdit.InternalBeginUndoBlock(aList: TSynEditUndoList);
begin
  if aList = nil then aList := fUndoList;
  {$IFDEF SynUndoDebugBeginEnd}
  DebugLnEnter(['>> TCustomSynEdit.InternalBeginUndoBlock', DbgSName(self), ' ', dbgs(Self), ' aList=', aList, ' FPaintLock=', FPaintLock, ' InGroupCount=',aList.InGroupCount]);
  {$ENDIF}
  aList.OnNeedCaretUndo := @GetCaretUndo;
  aList.BeginBlock;
  IncPaintLock;
end;

procedure TCustomSynEdit.InternalEndUndoBlock(aList: TSynEditUndoList);
begin
  if aList = nil then aList := fUndoList;
  DecPaintLock;
  aList.EndBlock; // Todo: Doing this after DecPaintLock, can cause duplicate calls to StatusChanged(scModified)
  {$IFDEF SynUndoDebugBeginEnd}
  DebugLnExit(['<< TCustomSynEdit.InternalEndUndoBlock', DbgSName(self), ' ', dbgs(Self), ' aList=', aList, ' FPaintLock=', FPaintLock, ' InGroupCount=',aList.InGroupCount]);
  {$ENDIF}
end;

procedure TCustomSynEdit.BeginUndoBlock{$IFDEF SynUndoDebugBeginEnd}(ACaller: String = ''){$ENDIF};
begin
  {$IFDEF SynUndoDebugBeginEnd}
  DebugLnEnter(['>> TCustomSynEdit.BeginUndoBlock ', DbgSName(self), ' ', dbgs(Self), ' Caller=', ACaller, ' FPaintLock=', FPaintLock, ' InGroupCount=',fUndoList.InGroupCount, '  FIsInDecPaintLock=',dbgs(FIsInDecPaintLock)]);
  if ACaller = '' then DumpStack;
  {$ENDIF}
  fUndoList.OnNeedCaretUndo := @GetCaretUndo;
  fUndoList.BeginBlock;
  //FTrimmedLinesView.Lock;
end;

procedure TCustomSynEdit.BeginUpdate(WithUndoBlock: Boolean = True);
begin
  IncPaintLock;
  {$IFDEF SynUndoDebugBeginEnd}
  if WithUndoBlock and (FPaintLock = 0) and (FUndoBlockAtPaintLock = 0) then
    DebugLn(['************** TCustomSynEdit.BeginUpdate  PAINTLOCK NOT INCREASED  ', DbgSName(self), ' ', dbgs(Self),  ' FPaintLock=', FPaintLock, ' InGroupCount=',fUndoList.InGroupCount, '  FIsInDecPaintLock=',dbgs(FIsInDecPaintLock)]);
  {$ENDIF}
  if WithUndoBlock and (FPaintLock > 0) and (FUndoBlockAtPaintLock = 0) then begin
    FUndoBlockAtPaintLock := FPaintLock;
    BeginUndoBlock{$IFDEF SynUndoDebugBeginEnd}('SynEdit.BeginUpdate'){$ENDIF};
  end;
end;

procedure TCustomSynEdit.EndUndoBlock{$IFDEF SynUndoDebugBeginEnd}(ACaller: String = ''){$ENDIF};
begin
  // Write all trimming info to the end of the undo block,
  // so it will be undone first, and other UndoItems do see the expected spaces
  //FTrimmedLinesView.UnLock;
  ////FFoldedLinesView.UnLock;
  fUndoList.EndBlock;
  {$IFDEF SynUndoDebugBeginEnd}
  DebugLnExit(['<< TCustomSynEdit.EndUndoBlock', DbgSName(self), ' ', dbgs(Self), ' Caller=', ACaller, ' FPaintLock=', FPaintLock, ' InGroupCount=',fUndoList.InGroupCount, '  FIsInDecPaintLock=',dbgs(FIsInDecPaintLock)]);
  //if ACaller = '' then DumpStack;
  {$ENDIF}
end;

procedure TCustomSynEdit.EndUpdate;
begin
  DecPaintLock;
end;

procedure TCustomSynEdit.AddKey(Command: TSynEditorCommand;
  Key1: word; SS1: TShiftState; Key2: word; SS2: TShiftState);
var
  Key: TSynEditKeyStroke;
begin
  Key := Keystrokes.Add;
  Key.Command := Command;
  Key.Key := Key1;
  Key.Shift := SS1;
  Key.Key2 := Key2;
  Key.Shift2 := SS2;
end;

procedure TCustomSynEdit.AfterLoadFromFile;
begin
  if (not HandleAllocated) or
     ( (FPaintLock > 0) and not((FPaintLock = 1) and FIsInDecPaintLock) )
  then begin
    Include(fStateFlags, sfAfterLoadFromFileNeeded);
    exit;
  end;
  Exclude(fStateFlags, sfAfterLoadFromFileNeeded);
  if assigned(FFoldedLinesView) then begin
    ScanRanges;
    FFoldedLinesView.UnfoldAll;
    FFoldedLinesView.CollapseDefaultFolds;
    if FPendingFoldState <> '' then
      SetFoldState(FPendingFoldState);
    TopView := TopView;
  end;
end;

procedure TCustomSynEdit.MarkListChange(Sender: TSynEditMark; Changes: TSynEditMarkChangeReasons);
begin
  if (smcrAdded in Changes) and Sender.IsBookmark then begin
    FBookMarks[Sender.BookmarkNumber] := Sender;
    if Assigned(FOnPlaceMark) then
      FOnPlaceMark(Self, Sender);
  end;
  if (smcrRemoved in Changes) and Sender.IsBookmark then begin
    FBookMarks[Sender.BookmarkNumber] := nil;
    if Assigned(FOnPlaceMark) then
      FOnClearMark(Self, Sender);
  end;

  if (not Sender.Visible) and (not (smcrVisible in Changes)) then
    exit;

  if smcrLine in Changes then begin
    InvalidateLine(Sender.OldLine); // TODO: only if mark has special line color, or other code markup
    InvalidateGutterLines(Sender.OldLine, Sender.OldLine);
  end;
  InvalidateLine(Sender.Line);  // TODO: only if mark has special line color, or other code markup
  InvalidateGutterLines(Sender.Line, Sender.Line);
end;

function TCustomSynEdit.GetSelStart: integer;                                   //L505 begin

  function llen(const data: string): integer;
  begin
    result := length(Data) + length(LineEnding);
  end;

var
  loop: integer;
  p: TPoint;
begin
  if SelAvail then
  begin
    p:=BlockBegin;
  end
  else
  begin
    p:=LogicalCaretXY;
  end;

  result := 0;
  loop := 0;
  while (loop < (p.Y - 1)) and (loop < FTheLinesView.Count) do
  begin
    result := result + llen(FTheLinesView[loop]);
    inc(loop);
  end;
  if loop < FTheLinesView.Count then
    result := result + Min(p.X, length(FTheLinesView[loop]) + 1);
end;

procedure TCustomSynEdit.SetSelStart(const Value: integer);

  function llen(const data: string): integer;
  begin
    result := length(Data) + length(LineEnding);
  end;

var
  loop: integer;
  count: integer;
begin
  assert(Value > 0, 'SelStart must be >= 1');
  loop := 0;
  count := 0;
  while (loop < FTheLinesView.Count) and (count + llen(FTheLinesView[loop]) < value) do begin
    count := count + llen(FTheLinesView[loop]);
    inc(loop);
  end;
{  CaretX := value - count;
  CaretY := loop + 1;

  fBlockBegin.X := CaretX;
  fBlockBegin.Y := CaretY;}

  //This seems the same as above, but uses the other fixes inside of SetCaretXY
  //to adjust the cursor pos correctly.
  FCaret.LineBytePos := Point(value - count, loop + 1);
  BlockBegin := Point(value - count, loop + 1);
end;

function TCustomSynEdit.GetSelEnd: integer;

  function llen(const data: string): integer;
  begin
    result := length(Data) + length(LineEnding);
  end;

var
  loop: integer;
  p: TPoint;
begin
  if SelAvail then
  begin
    p := BlockEnd;
  end else begin
    p := LogicalCaretXY;
  end;

  result := 0;
  loop := 0;
  while (loop < (p.y - 1)) and (loop < FTheLinesView.Count) do begin
    Result := result + llen(FTheLinesView[loop]);
    inc(loop);
  end;
  if loop<FTheLinesView.Count then
    result := result + p.x;
end;

procedure TCustomSynEdit.SetSelEnd(const Value: integer);

  function llen(const data: string): integer;
  begin
    result := length(Data) + length(LineEnding);
  end;

var
  p: TPoint;
  loop: integer;
  count: integer;
begin
  assert(Value > 0, 'SelEnd must be >= 1');
  loop := 0;
  count := 0;
  while (loop < FTheLinesView.Count) and (count + llen(FTheLinesView[loop]) < value) do begin
    count := count + llen(FTheLinesView.strings[loop]);
    inc(loop);
  end;
  p.x := value - count; p.y := loop + 1;
  BlockEnd := p;
end;

procedure TCustomSynEdit.SetExtraLineSpacing(const Value: integer);
begin
  if ExtraLineSpacing=Value then exit;
  inherited;
  FPaintArea.ExtraLineSpacing := Value;
  FontChanged(self);
end;

function TCustomSynEdit.GetBookMark(BookMark: integer; var X, Y: integer):
  boolean;
var
  i: integer;
begin
  Result := false;
  if assigned(Marks) then
    for i := 0 to Marks.Count - 1 do
      if Marks[i].IsBookmark and (Marks[i].BookmarkNumber = BookMark) then begin
        X := Marks[i].Column;
        Y := Marks[i].Line;
        X := LogicalToPhysicalPos(Point(X, Y)).x;
        Result := true;
        Exit;
      end;
end;

function TCustomSynEdit.IsBookmark(BookMark: integer): boolean;
var
  x, y: integer;
begin
  Result := GetBookMark(BookMark, x{%H-}, y{%H-});
end;

procedure TCustomSynEdit.MarkTextAsSaved;
begin
  TSynEditStringList(fLines).MarkSaved;
  if FLeftGutter.Visible and (FLeftGutter.ChangesPart(0) <> nil) and FLeftGutter.ChangesPart(0).Visible then
    InvalidateGutter; // Todo: Make the ChangeGutterPart an observer
end;

procedure TCustomSynEdit.ClearUndo;
begin
  fUndoList.Clear;
  fRedoList.Clear;
end;

procedure TCustomSynEdit.SetGutter(const Value: TSynGutter);
begin
  FLeftGutter.Assign(Value);
end;

procedure TCustomSynEdit.SetRightGutter(const AValue: TSynGutter);
begin
  FRightGutter.Assign(AValue);
end;

procedure TCustomSynEdit.GutterChanged(Sender: TObject);
begin
  if (csLoading in ComponentState) then exit;
  InvalidateGutter; //Todo: move to gutter
end;

procedure TCustomSynEdit.GutterResized(Sender: TObject);
begin
  if (csLoading in ComponentState) then exit;

  GutterChanged(Sender);

  if HandleAllocated then begin
    RecalcCharsAndLinesInWin(False);
    UpdateScrollBars;
    Invalidate;
  end;
end;

function TCustomSynEdit.TextLeftPixelOffset(IncludeGutterTextDist: Boolean): Integer;
begin
  if FLeftGutter.Visible then begin
    Result := FLeftGutter.Width;
    if IncludeGutterTextDist then
      inc(Result, GutterTextDist);
  end
  else begin
    Result := 0;
    if IncludeGutterTextDist then
      inc(Result, 1);  // include space for caret at pos.x=1 (if FOffsetX = -1)
  end;
end;

function TCustomSynEdit.TextRightPixelOffset: Integer;
begin
  if FRightGutter.Visible then
    Result := FRightGutter.Width
  else
    Result := 0;
end;

procedure TCustomSynEdit.LockUndo;
begin
  fUndoList.Lock;
  fRedoList.Lock
end;

procedure TCustomSynEdit.UnlockUndo;
begin
  fUndoList.Unlock;
  fRedoList.Unlock;
end;

procedure TCustomSynEdit.WMMouseWheel(var Message: TLMMouseEvent);
var
  lState: TShiftState;
  MousePos: TPoint;
  AnActionResult: TSynEditMouseActionResult;
begin
  if ((sfHorizScrollbarVisible in fStateFlags) and (Message.Y > ClientHeight)) or
     ((sfVertScrollbarVisible in fStateFlags) and (Message.X > ClientWidth))
   then begin
     // mouse is over scrollbar
     inherited; // include OnMouseWheel...;
     exit;
   end;

  MousePos.X := Message.X;
  MousePos.Y := Message.Y;
  if DoMouseWheel(Message.State, Message.WheelDelta, MousePos) then begin
    Message.Result := 1; // handled
    exit;
  end;

  lState := Message.State - [ssCaps, ssNum, ssScroll]; // Remove unreliable states, see http://bugs.freepascal.org/view.php?id=20065

  IncPaintLock;
  try
    if Message.WheelDelta > 0 then begin
      FindAndHandleMouseAction(mbXWheelUp, lState, Message.X, Message.Y, ccSingle, cdDown, AnActionResult, Message.WheelDelta);
    end
    else begin
      // send megative delta
      FindAndHandleMouseAction(mbXWheelDown, lState, Message.X, Message.Y, ccSingle, cdDown, AnActionResult, Message.WheelDelta);
    end;
  finally
    DecPaintLock;
  end;

  DoHandleMouseActionResult(AnActionResult);

  Message.Result := 1 // handled, skip further handling by interface
end;

procedure TCustomSynEdit.WMMouseHorizWheel(var Message: TLMMouseEvent);
var
  lState: TShiftState;
  MousePos: TPoint;
  AnActionResult: TSynEditMouseActionResult;
begin
  if ((sfHorizScrollbarVisible in fStateFlags) and (Message.Y > ClientHeight)) or
     ((sfVertScrollbarVisible in fStateFlags) and (Message.X > ClientWidth))
   then begin
     // mouse is over scrollbar
     inherited; // include OnMouseWheel...;
     exit;
   end;

  MousePos.X := Message.X;
  MousePos.Y := Message.Y;
  if DoMouseWheelHorz(Message.State, Message.WheelDelta, MousePos) then begin
    Message.Result := 1; // handled
    exit;
  end;

  lState := Message.State - [ssCaps, ssNum, ssScroll]; // Remove unreliable states, see http://bugs.freepascal.org/view.php?id=20065

  IncPaintLock;
  try
    if Message.WheelDelta > 0 then begin
      FindAndHandleMouseAction(mbXWheelLeft, lState, Message.X, Message.Y, ccSingle, cdDown, AnActionResult, Message.WheelDelta);
    end
    else begin
      // send megative delta
      FindAndHandleMouseAction(mbXWheelRight, lState, Message.X, Message.Y, ccSingle, cdDown, AnActionResult, Message.WheelDelta);
    end;
  finally
    DecPaintLock;
  end;

  DoHandleMouseActionResult(AnActionResult);

  Message.Result := 1 // handled, skip further handling by interface
end;

procedure TCustomSynEdit.SetWantTabs(const Value: boolean);
begin
  fWantTabs := Value;
end;

procedure TCustomSynEdit.SetTabWidth(Value: integer);
begin
  Value := MinMax(Value, 1{0}, 256);
  if (Value <> fTabWidth) then begin
    fTabWidth := Value;
    FTabbedLinesView.TabWidth := Value;
    Invalidate; // to redraw text containing tab chars
  end;
end;

// find / replace
function TCustomSynEdit.SearchReplace(const ASearch, AReplace: string;
  AOptions: TSynSearchOptions): integer;
var
  StartPos: TPoint;
begin
  if (ssoFindContinue in AOptions) and SelAvail then begin
    if ssoBackwards in AOptions then
      StartPos := BlockBegin
    else
      StartPos := BlockEnd;
  end
  else
    StartPos := LogicalCaretXY;
  Result := SearchReplaceEx(ASearch, AReplace, AOptions, StartPos);
end;

function TCustomSynEdit.SearchReplaceEx(const ASearch, AReplace: string;
  AOptions: TSynSearchOptions; AStart: TPoint): integer;
var
  ptStart, ptEnd: TPoint; // start and end of the search range
  ptCurrent: TPoint; // current search position
  nFound: integer;
  bBackward, bFromCursor: boolean;
  bPrompt: boolean;
  bReplace, bReplaceAll, SelIsColumn, ZeroLen: boolean;
  nAction: TSynReplaceAction;
  CurReplace: string;
  ptFoundStart, ptFoundEnd: TPoint;
  ptFoundStartSel, ptFoundEndSel: TPoint;
  ReplaceBlockSelection: TSynEditSelection;


  function InValidSearchRange(First, Last: integer): boolean;
  begin
    Result := TRUE;
    case FBlockSelection.ActiveSelectionMode of
      smNormal:
        if ((ptCurrent.Y = ptStart.Y) and (First < ptStart.X)) or
          ((ptCurrent.Y = ptEnd.Y) and (Last > ptEnd.X)) then Result := FALSE;
      smColumn:
        Result := (First >= ptStart.X) and (Last <= ptEnd.X);
    end;
  end;

  procedure SetFoundCaretAndSel;
  begin
    if ptFoundStartSel.y < 0 then
      exit;
    BlockBegin := ptFoundStartSel;
    if bBackward then LogicalCaretXY := BlockBegin;
    BlockEnd := ptFoundEndSel;
    if not bBackward then LogicalCaretXY := ptFoundEndSel;
  end;

begin
  Result := 0;
  ReplaceBlockSelection := nil;
  // can't search for or replace an empty string
  if Length(ASearch) = 0 then exit;
  // get the text range to search in, ignore the "Search in selection only"
  // option if nothing is selected
  bBackward := (ssoBackwards in AOptions);
  bPrompt := (ssoPrompt in AOptions);
  bReplace := (ssoReplace in AOptions);
  bReplaceAll := (ssoReplaceAll in AOptions);
  bFromCursor := not (ssoEntireScope in AOptions);
  SelIsColumn := False;
  if not SelAvail then Exclude(AOptions, ssoSelectedOnly);
  if (ssoSelectedOnly in AOptions) then begin
    ptStart := BlockBegin;
    ptEnd := BlockEnd;
    // search the whole line in the line selection mode
    if (FBlockSelection.ActiveSelectionMode = smLine) then begin
      ptStart.X := 1;
      ptEnd.X := Length(FTheLinesView[ptEnd.Y - 1]) + 1;
    end else if (FBlockSelection.ActiveSelectionMode = smColumn) then
      // make sure the start column is smaller than the end column
      if (ptStart.X > ptEnd.X) then begin
        nFound := ptStart.X;
        ptStart.X := ptEnd.X;
        ptEnd.X := nFound;
      end;
    // ignore the cursor position when searching in the selection
    if bBackward then ptCurrent := ptEnd else ptCurrent := ptStart;

    SelIsColumn := FBlockSelection.ActiveSelectionMode = smColumn;
    ReplaceBlockSelection := TSynEditSelection.Create(FTheLinesView, False);
    ReplaceBlockSelection.AssignFrom(FBlockSelection);
  end else begin
    ptStart := Point(1, 1);
    ptEnd.Y := FTheLinesView.Count;
    ptEnd.X := Length(FTheLinesView[ptEnd.Y - 1]) + 1;
    if bFromCursor then
      if bBackward then
        ptEnd := AStart
      else
        ptStart := AStart;
    if bBackward then ptCurrent := ptEnd else ptCurrent := ptStart;
  end;
  // initialize the search engine
  fTSearch.Sensitive := ssoMatchCase in AOptions;
  fTSearch.Whole := ssoWholeWord in AOptions;
  fTSearch.Pattern := ASearch;
  fTSearch.RegularExpressions := ssoRegExpr in AOptions;
  fTSearch.RegExprMultiLine := ssoRegExprMultiLine in AOptions;
  fTSearch.Replacement:=AReplace;
  fTSearch.Backwards:=bBackward;
  // search while the current search position is inside of the search range
  IncPaintLock;
  BeginUndoBlock{$IFDEF SynUndoDebugBeginEnd}('SynEdit.SearchReplaceEx'){$ENDIF};
  try
    ptFoundStartSel.y := -1;
    //DebugLn(['TCustomSynEdit.SearchReplace ptStart=',dbgs(ptStart),' ptEnd=',dbgs(ptEnd),' ASearch="',dbgstr(ASearch),'" AReplace="',dbgstr(AReplace),'"']);
    while fTSearch.FindNextOne(FTheLinesView,ptStart,ptEnd,ptFoundStart,ptFoundEnd, True) do
    begin
      //DebugLn(['TCustomSynEdit.SearchReplace FOUND ptStart=',dbgs(ptStart),' ptEnd=',dbgs(ptEnd),' ptFoundStart=',dbgs(ptFoundStart),' ptFoundEnd=',dbgs(ptFoundEnd)]);
      // check if found place is entirely in range
      ZeroLen := ptFoundStart = ptFoundEnd;
      if ( (not SelIsColumn) or
           ( (ptFoundStart.Y=ptFoundEnd.Y) and
             (ptFoundStart.X >= ReplaceBlockSelection.ColumnStartBytePos[ptFoundStart.Y]) and
             (ptFoundEnd.X   <= ReplaceBlockSelection.ColumnEndBytePos[ptFoundStart.Y])
           )
         ) and (
           not( ZeroLen and (ptStart = ptFoundStart) and
                (ssoFindContinue in AOptions) and (not SelAvail)
              )
         )
      then
      begin
        // pattern found
        Inc(Result);
        // Select the text, so the user can see it in the OnReplaceText event
        // handler or as the search result.
        ptFoundStartSel := ptFoundStart;
        ptFoundEndSel   := ptFoundEnd;
//SetFoundCaretAndSel;
        // If it's a 'search' only we can leave the procedure now.
        if not (bReplace or bReplaceAll) then exit;
        // Prompt and replace or replace all.  If user chooses to replace
        // all after prompting, turn off prompting.
        CurReplace:=AReplace;
        if ssoRegExpr in AOptions then
          CurReplace:=fTSearch.RegExprReplace;
        if bPrompt and Assigned(fOnReplaceText) then begin
          SetFoundCaretAndSel;
          EnsureCursorPosVisible;
          try
            EndUndoBlock;
            DecPaintLock;
            nAction := DoOnReplaceText(ASearch,CurReplace,
                                       ptFoundStart.Y,ptFoundStart.X);
          finally
            IncPaintLock;
            BeginUndoBlock{$IFDEF SynUndoDebugBeginEnd}('SynEdit.SearchReplaceEx(prompt)'){$ENDIF};
          end;
          if nAction = raCancel then exit;
        end else
          nAction := raReplace;
        if not (nAction = raSkip) then begin
          // user has been prompted and has requested to silently replace all
          // so turn off prompting
          if nAction = raReplaceAll then begin
            bReplaceAll := True;
            bPrompt := False;
          end;
          // replace text
          //DebugLn(['TCustomSynEdit.SearchReplace OldSel="',dbgstr(SelText),'"']);
//SetSelTextExternal(CurReplace);
          SetTextBetweenPoints(ptFoundStart, ptFoundEnd, CurReplace, [setSelect], scamIgnore);
          //DebugLn(['TCustomSynEdit.SearchReplace NewSel="',dbgstr(SelText),'"']);
          // adjust positions
          ptEnd:=AdjustPositionAfterReplace(ptEnd,ptFoundStart,ptFoundEnd,
                                            CurReplace);
          ptFoundEnd:=AdjustPositionAfterReplace(ptFoundEnd,
                                            ptFoundStart,ptFoundEnd,CurReplace);
          ptFoundEndSel   := ptFoundEnd;
        end;
        if not bReplaceAll then
          exit;
      end;
      Exclude(AOptions, ssoFindContinue); // ZeroLen will now be handled below

      // shrink search range for next search
      if ssoSearchInReplacement in AOptions then begin
        if bBackward then begin
          ptEnd:=ptFoundEnd;
        end else begin
          ptStart:=ptFoundStart;
        end;
      end else begin
        if bBackward then begin
          ptEnd:=ptFoundStart;
        end else begin
          ptStart:=ptFoundEnd;
        end;
      end;
      if ZeroLen then begin
        FInternalCaret.LineBytePos := ptStart;
        if bBackward then begin
          if not FInternalCaret.MoveHoriz(-1) then
            ptStart := Point(length(FTheLinesView[ptStart.Y - 1]), ptStart.Y - 1)
          else
            ptStart := FInternalCaret.LineBytePos;
        end
        else begin
          if not FInternalCaret.MoveHoriz(1) then
            ptStart := Point(1, ptStart.Y + 1)
          else
            ptStart := FInternalCaret.LineBytePos;
        end;
      end;
      //DebugLn(['TCustomSynEdit.SearchReplace FIND NEXT ptStart=',dbgs(ptStart),' ptEnd=',dbgs(ptEnd)]);
    end;
  finally
    SetFoundCaretAndSel;
    FreeAndNil(ReplaceBlockSelection);
    EndUndoBlock;
    DecPaintLock;
  end;
end;

function TCustomSynEdit.IsPointInSelection(Value: TPoint;
  AnIgnoreAtSelectionBound: Boolean): boolean;
var
  ptBegin, ptEnd: TPoint;
  i: Integer;
begin
  Result := SelAvail;
  if not Result then
    exit;

  ptBegin := BlockBegin;
  ptEnd := BlockEnd;
  Result :=  (Value.Y >= ptBegin.Y) and (Value.Y <= ptEnd.Y);
  if not Result then
    exit;

  if AnIgnoreAtSelectionBound then
    i := 0
  else
    i := 1;
  case FBlockSelection.ActiveSelectionMode of
    smLine: begin
        Result := TRUE;
      end;
    smColumn: begin
        Result := (Value.x > FBlockSelection.ColumnStartBytePos[Value.y] - i) and
                  (Value.x < FBlockSelection.ColumnEndBytePos[Value.y]   + i);
      end;
    else begin
        Result :=
          ( (Value.Y > ptBegin.Y) or (Value.X > ptBegin.X - i) ) and
          ( (Value.Y < ptEnd.Y)   or (Value.X < ptEnd.X + i) );
      end;
  end;
end;

procedure TCustomSynEdit.SetOptions(Value: TSynEditorOptions);
var
  ChangedOptions: TSynEditorOptions;
  m: TSynEditorOption;
  MOpt: TSynEditorMouseOptions;
  f: Boolean;
begin
  Value := Value - SYNEDIT_UNIMPLEMENTED_OPTIONS;
  if (Value = FOptions) then exit;

  ChangedOptions:=(FOptions-Value)+(Value-FOptions);
  FOptions := Value;
  UpdateOptions;

  if not (eoScrollPastEol in Options) then
    LeftChar := LeftChar;
  if (eoScrollPastEol in Options) or (eoScrollPastEof in Options) then begin
    UpdateScrollBars;
    TopView := TopView;
  end;
  // (un)register HWND as drop target
  if (eoDropFiles in ChangedOptions) and not (csDesigning in ComponentState) and HandleAllocated then
    ; // ToDo DragAcceptFiles
  if (ChangedOptions * [eoPersistentCaret, eoNoCaret] <> []) and HandleAllocated then begin
    UpdateCaret;
    UpdateScreenCaret;
  end;
  if (eoShowSpecialChars in ChangedOptions) then begin
    if eoShowSpecialChars in FOptions
    then FPaintArea.VisibleSpecialChars := VisibleSpecialChars
    else FPaintArea.VisibleSpecialChars := [];
    if HandleAllocated then
      Invalidate;
  end;
  fMarkupSpecialChar.Enabled := (eoShowSpecialChars in fOptions);

  if (eoHideRightMargin in ChangedOptions) then begin
    FPaintArea.RightEdgeVisible := not(eoHideRightMargin in FOptions);
    Invalidate;
  end;

  (* Deal with deprecated Mouse values
     Those are all controlled by mouse-actions.
     As long as the default mouse actions are set, the below will act as normal
  *)

  MOpt := MouseOptions;
  f := False;
  for m := low(SYNEDIT_OLD_MOUSE_OPTIONS_MAP) to high(SYNEDIT_OLD_MOUSE_OPTIONS_MAP) do
    if (m in SYNEDIT_OLD_MOUSE_OPTIONS) and (m in ChangedOptions) then begin
      f := True;
      if (m in FOptions)
      then MOpt := MOpt + [SYNEDIT_OLD_MOUSE_OPTIONS_MAP[m]]
      else MOpt := MOpt - [SYNEDIT_OLD_MOUSE_OPTIONS_MAP[m]];
    end;
  if f then
    MouseOptions := MOpt;

  FOptions := Value; // undo changes applied by MouseOptions

  StatusChanged([scOptions]);
end;

procedure TCustomSynEdit.UpdateOptions;
begin
  FTrimmedLinesView.Enabled := eoTrimTrailingSpaces in fOptions;
  FCaret.AllowPastEOL := (eoScrollPastEol in fOptions);
  FCaret.KeepCaretX := (eoKeepCaretX in fOptions);
  FBlockSelection.Enabled := not(eoNoSelection in fOptions);
  FUndoList.GroupUndo := eoGroupUndo in fOptions;
end;

procedure TCustomSynEdit.SetOptions2(Value: TSynEditorOptions2);
var
  ChangedOptions: TSynEditorOptions2;
begin
  if (Value <> fOptions2) then begin
    ChangedOptions := (fOptions2 - Value) + (Value - fOptions2);
    fOptions2 := Value;
    UpdateOptions2;
    if eoAlwaysVisibleCaret in fOptions2 then
      MoveCaretToVisibleArea;
    if (eoAutoHideCursor in ChangedOptions) and not(eoAutoHideCursor in fOptions2) then
      UpdateCursor;
    if (eoPersistentCaretStopBlink in ChangedOptions) then
      UpdateScreenCaret;
    StatusChanged([scOptions]);
  end;
end;

procedure TCustomSynEdit.UpdateOptions2;
begin
  FBlockSelection.Persistent := eoPersistentBlock in fOptions2;
  FCaret.SkipTabs := (eoCaretSkipTab in fOptions2);
  if Assigned(fMarkupSelection) then
    fMarkupSelection.ColorTillEol := eoColorSelectionTillEol in fOptions2;
end;

procedure TCustomSynEdit.SetMouseOptions(AValue: TSynEditorMouseOptions);
var
  ChangedOptions: TSynEditorMouseOptions;
  m: TSynEditorOption;
begin
  if MouseOptions = AValue then Exit;

  ChangedOptions := (MouseOptions-AValue)+(AValue-MouseOptions);
  inherited;
  // changes take effect when MouseActions are accessed

  for m := low(SYNEDIT_OLD_MOUSE_OPTIONS_MAP) to high(SYNEDIT_OLD_MOUSE_OPTIONS_MAP) do
    if (m in SYNEDIT_OLD_MOUSE_OPTIONS) and
       (SYNEDIT_OLD_MOUSE_OPTIONS_MAP[m] in ChangedOptions) and
       not(SYNEDIT_OLD_MOUSE_OPTIONS_MAP[m] in MouseOptions)
    then
      FOptions := FOptions - [m];

  if (emShowCtrlMouseLinks in ChangedOptions) then begin
    if assigned(fMarkupCtrlMouse) then
      fMarkupCtrlMouse.UpdateCtrlMouse;
    UpdateCursor;
  end;
  StatusChanged([scOptions]);
end;

procedure TCustomSynEdit.UpdateMouseOptions;
begin
  //
end;

procedure TCustomSynEdit.SetOptionFlag(Flag: TSynEditorOption; Value: boolean);
begin
  if (Value <> (Flag in fOptions)) then begin
    if Value then
      Options := Options + [Flag]
    else
      Options := Options - [Flag];
  end;
end;

procedure TCustomSynEdit.SizeOrFontChanged(bFont: boolean);
begin
  if HandleAllocated then begin
    LastMouseCaret:=Point(-1,-1);
    RecalcCharsAndLinesInWin(False);

    //DebugLn('TCustomSynEdit.SizeOrFontChanged LinesInWindow=',dbgs(LinesInWindow),' ClientHeight=',dbgs(ClientHeight),' ',dbgs(LineHeight));
    //debugln('TCustomSynEdit.SizeOrFontChanged A ClientWidth=',dbgs(ClientWidth),' FLeftGutter.Width=',dbgs(FLeftGutter.Width),' ScrollBarWidth=',dbgs(ScrollBarWidth),' CharWidth=',dbgs(CharWidth),' CharsInWindow=',dbgs(CharsInWindow),' Width=',dbgs(Width));
    if bFont then begin
      UpdateScrollbars;
      Invalidate;
    end else
      UpdateScrollbars;
    if not (eoScrollPastEol in Options) then
      LeftChar := LeftChar;
    if not (eoScrollPastEof in Options) then
      TopView := TopView;
  end;
end;

procedure TCustomSynEdit.RecalcScrollOnEdit(Sender: TObject);
begin
  FScrollOnEditLeftOptions.FCurrentDistance := Min(Max(
      FScrollOnEditLeftOptions.KeepBorderDistance,
      CharsInWindow * FScrollOnEditLeftOptions.KeepBorderDistancePercent div 100
    ),
    Max(0, CharsInWindow - 1) div 2
  );
  FScrollOnEditLeftOptions.FCurrentColumns := Min(Min(Max(
      FScrollOnEditLeftOptions.ScrollExtraColumns,
      CharsInWindow * FScrollOnEditLeftOptions.ScrollExtraPercent div 100
    ),
    FScrollOnEditLeftOptions.ScrollExtraMax
    ),
    Max(0, CharsInWindow - 1) div 2
  );

  FScrollOnEditRightOptions.FCurrentDistance := Min(Max(
      FScrollOnEditRightOptions.KeepBorderDistance,
      CharsInWindow * FScrollOnEditRightOptions.KeepBorderDistancePercent div 100
    ),
    Max(0, CharsInWindow - 1) div 2
  );
  FScrollOnEditRightOptions.FCurrentColumns := Min(Min(Max(
      FScrollOnEditRightOptions.ScrollExtraColumns,
      CharsInWindow * FScrollOnEditRightOptions.ScrollExtraPercent div 100
    ),
    FScrollOnEditRightOptions.ScrollExtraMax
    ),
    Max(0, CharsInWindow - 1) div 2
  );
end;

procedure TCustomSynEdit.RecalcCharsAndLinesInWin(CheckCaret: Boolean);
var
  l, r: Integer;
begin
  if FRecalcCharsAndLinesLock > 0 then
    exit;

  IncStatusChangeLock;
  try
    if FLeftGutter.Visible
    then l := FLeftGutter.Width
    else l := 0;
    if FRightGutter.Visible
    then r := FRightGutter.Width
    else r := 0;

    // TODO: lock FTextArea, so size re-calc is done once only
    FPaintArea.SetBounds(0, 0, ClientHeight - ScrollBarWidth, ClientWidth - ScrollBarWidth);
    FPaintArea.LeftGutterWidth := l;
    FPaintArea.RightGutterWidth := r;

    if FLeftGutter.Visible
    then FPaintArea.Padding[bsLeft] := GutterTextDist
    else FPaintArea.Padding[bsLeft] := 1;
    if FRightGutter.Visible
    then FPaintArea.Padding[bsRight] := 0 //GutterTextDist
    else FPaintArea.Padding[bsRight] := 0;

    FFoldedLinesView.LinesInWindow := LinesInWindow;
    FMarkupManager.LinesInWindow := LinesInWindow;

    FScreenCaret.Lock;
    FScreenCaret.ClipRect := FTextArea.Bounds;
    //FScreenCaret.ClipRect := Rect(TextLeftPixelOffset(False), 0,
    //                              ClientWidth - TextRightPixelOffset - ScrollBarWidth + 1,
    //                              ClientHeight - ScrollBarWidth);
    FScreenCaret.ClipExtraPixel := FTextArea.Bounds.Right - FTextArea.Bounds.Left - CharsInWindow * CharWidth;
    UpdateCaret;
    FScreenCaret.UnLock;

    if CheckCaret then begin
      if not (eoScrollPastEol in Options) then
        LeftChar := LeftChar;
      if not (eoScrollPastEof in Options) then
        TopView := TopView;
    end;

    RecalcScrollOnEdit(nil);
  finally
    DecStatusChangeLock;
  end;
end;

procedure TCustomSynEdit.MoveCaretHorz(DX: integer);
var
  NewCaret: TPoint;
  s: String;
begin
  // char or halfchar left/right

  DoIncPaintLock(Self);  // No editing is taking place
  try
    if not FCaret.MoveHoriz(DX) then begin
      if DX < 0 then begin
        if (FCaret.LinePos > 1) and not(eoScrollPastEol in fOptions) then begin
          // move to end of prev line
          NewCaret.Y:= ToPos(FTheLinesView.AddVisibleOffsetToTextIndex(ToIdx(FCaret.LinePos), -1));
          if NewCaret.Y <> FCaret.LinePos then begin
            s:=FTheLinesView[NewCaret.Y-1];
            NewCaret.X := length(s) + 1;
            FCaret.LineBytePos := NewCaret;
          end;
        end;
      end
      else begin
        if not(eoScrollPastEol in fOptions) then begin
          // move to begin of next line
          NewCaret.Y:= ToPos(FTheLinesView.AddVisibleOffsetToTextIndex(ToIdx(FCaret.LinePos), +1));
          if NewCaret.Y <= ToPos(FTheLinesView.ViewToTextIndex(ToIdx(FTheLinesView.ViewedCount))) then begin
            NewCaret.X := 1;
            FCaret.LineBytePos := NewCaret;
          end;
        end
      end;
    end;
  finally
    DoDecPaintLock(Self);
  end;
end;

procedure TCustomSynEdit.MoveCaretVert(DY: integer; UseScreenLine: Boolean);
// moves Caret vertical DY unfolded lines
var
  NewCaret: TPoint;
begin
  DoIncPaintLock(Self); // No editing is taking place
  if UseScreenLine then begin
    FCaret.ViewedLinePos := FCaret.ViewedLinePos + DY;
  end
  else begin
    NewCaret:=CaretXY;
    NewCaret.Y:=ToPos(FTheLinesView.AddVisibleOffsetToTextIndex(ToIdx(NewCaret.Y), DY));
    FCaret.LinePos := NewCaret.Y;
  end;
  DoDecPaintLock(Self);
end;

procedure TCustomSynEdit.SetCaretAndSelection(const ptCaret, ptBefore,
  ptAfter: TPoint; Mode: TSynSelectionMode = smCurrent; MakeSelectionVisible: Boolean = False);
// caret is physical (screen)
// Before, After is logical (byte)
var
  L1, L2, LBottomLine, LCaretFirst, LCaretLast: Integer;
begin
  DoIncPaintLock(Self); // No editing is taking place

  CaretXY := ptCaret;
  SetBlockBegin(ptBefore);
  SetBlockEnd(ptAfter);
  if Mode <> smCurrent then
    FBlockSelection.ActiveSelectionMode := Mode;

  if MakeSelectionVisible then begin
    //l1 := FBlockSelection.FirstLineBytePos;;
    LBottomLine := ToPos(FTheLinesView.AddVisibleOffsetToTextIndex(ToIdx(TopLine), LinesInWindow));

    LCaretFirst := CaretY;
    LCaretLast := Max(1, ToPos(FTheLinesView.AddVisibleOffsetToTextIndex(ToIdx(CaretY), 1-LinesInWindow)));  // Will have caret on last visible line

    l1 := Min(LCaretFirst, FBlockSelection.FirstLineBytePos.y);
    l2 := Max(LCaretFirst, FBlockSelection.LastLineBytePos.y);

    if CaretY < TopLine then begin
      // Scrolling up,  Topline = L1 ; but ensure Caret
      TopLine := Max(LCaretLast,
                 Min(LCaretFirst,
                     L1
                    ));
    end
    else if CaretY > LBottomLine then begin
      // Scrolling down, LastLine = L2
      TopLine := Max(LCaretLast,
                 Min(LCaretFirst,
                     ToPos(FTheLinesView.AddVisibleOffsetToTextIndex(ToIdx(L2), 1-LinesInWindow))
                    ));
    end
    else begin
      // Caret alreayd visible, check block
      if l1 < TopLine then
        TopLine := Max(LCaretLast,
                   Min(LCaretFirst,
                       L1
                      ))
      else
      if l2 > LBottomLine then
        TopLine := Max(LCaretLast,
                   Min(LCaretFirst,
                       ToPos(FTheLinesView.AddVisibleOffsetToTextIndex(ToIdx(L2), 1-LinesInWindow))
                      ));
    end;
  end;

  DoDecPaintLock(Self);
end;

procedure TCustomSynEdit.RecalcCharExtent;
var
  i: Integer;
begin
  (* Highlighter or Font changed *)
  IncStatusChangeLock;
  try
    inc(FRecalcCharsAndLinesLock);
    try
      FFontDummy.Assign(Font);
      with FFontDummy do begin
        // Keep GTK happy => By ensuring a change the XFLD fontname gets cleared
        {$IFDEF LCLGTK1}
        Pitch := fpVariable;
        Style := [fsBold];
        Pitch := fpDefault; // maybe Fixed
        {$ENDIF}
        // TODO: Clear style only, if Highlighter uses styles
        Style := [];        // Reserved for Highlighter
      end;
      //debugln(['TCustomSynEdit.RecalcCharExtent ',fFontDummy.Name,' ',fFontDummy.Size]);
      //debugln('TCustomSynEdit.RecalcCharExtent A UseUTF8=',dbgs(UseUTF8),' CharHeight=',dbgs(CharHeight));

      fTextDrawer.BaseFont := FFontDummy;
      if Assigned(fHighlighter) then
        for i := 0 to Pred(fHighlighter.AttrCount) do
          fTextDrawer.BaseStyle := fHighlighter.Attribute[i].Style;
      fTextDrawer.CharExtra := ExtraCharSpacing;

      FUseUTF8:=fTextDrawer.UseUTF8;
      FLines.IsUtf8 := FUseUTF8;
    finally
      dec(FRecalcCharsAndLinesLock);
      // RecalcCharsAndLinesInWin will be called by SizeOrFontChanged
    end;

    FScreenCaret.Lock;
    try
      FScreenCaret.CharWidth := CharWidth;
      FScreenCaret.CharHeight := LineHeight - Max(0, FPaintArea.TextArea.ExtraLineSpacing);
      SizeOrFontChanged(TRUE);
    finally
      FScreenCaret.UnLock;
    end;
    UpdateScrollBars;
  finally
    DecStatusChangeLock;
  end;
  //debugln('TCustomSynEdit.RecalcCharExtent UseUTF8=',dbgs(UseUTF8));
end;

procedure TCustomSynEdit.HighlighterAttrChanged(Sender: TObject);
begin
  RecalcCharExtent;
  Invalidate;
  // TODO: obey paintlock
  if fHighlighter.AttributeChangeNeedScan then begin
    FHighlighter.CurrentLines := FTheLinesView;
    FHighlighter.ScanAllRanges;
    fMarkupManager.TextChanged(1, FTheLinesView.Count, 0);
    TopView := TopView;
  end;
end;

procedure TCustomSynEdit.StatusChangedEx(Sender: TObject; Changes: TSynStatusChanges);
begin
  StatusChanged(Changes);
end;

procedure TCustomSynEdit.StatusChanged(AChanges: TSynStatusChanges);
begin
  fStatusChanges := fStatusChanges + AChanges;
  if (PaintLock = 0) and (FStatusChangeLock = 0) and (fStatusChanges <> []) then
    DoOnStatusChange(fStatusChanges);
end;

procedure TCustomSynEdit.DoTabKey;
var
  i, iLine: integer;
  PrevLine,
  Spaces: string;
  p: PChar;
  OldCaretX: integer;
begin
  if (eoTabIndent in Options) and SelAvail then begin
    DoBlockIndent;
    exit;
  end;

  InternalBeginUndoBlock;
  try
    i := 0;
    OldCaretX := CaretX;
    if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then
      SelText := '';
    // With a multi-line block the caret may have advanced, avoid negative spaces
    if CaretX > OldCaretX then
      OldCaretX := CaretX;
    if eoSmartTabs in fOptions then begin
      iLine := CaretY - 1;
      if (iLine > 0) and (iLine < FTheLinesView.Count) then begin
        repeat
          Dec(iLine);
          if iLine < 0 then break;
          PrevLine := FTheLinesView[iLine];
        until PhysicalLineLength(PrevLine, iLine) > OldCaretX - 1;

        if iLine >= 0 then begin
          p := @PrevLine[PhysicalToLogicalCol(PrevLine, iLine, OldCaretX)];
          // scan over non-whitespaces
          while not (p^ in [#0, #9, #32]) do
            inc(p);
          // scan over whitespaces
          while (p^ in [#9, #32]) do
            inc(p);
          i := LogicalToPhysicalCol(PrevLine, iLine, p-@PrevLine[1]+1) - CaretX;
        end;
      end;
    end;
    if i <= 0 then begin
      i := TabWidth - (CaretX - 1) mod TabWidth;
      if i = 0 then i := TabWidth;
    end;
    // i now contains the needed spaces
    Spaces := CreateTabsAndSpaces(CaretX,i,TabWidth,
                                  not (eoTabsToSpaces in Options));

    if SelAvail and (not FBlockSelection.Persistent) and (eoOverwriteBlock in fOptions2) then begin
      SetSelTextExternal(Spaces);
    end
    else begin
      FCaret.IncAutoMoveOnEdit;
      FTheLinesView.EditInsert(FCaret.BytePos, FCaret.LinePos, Spaces);
      FCaret.DecAutoMoveOnEdit;
      Include(fStateFlags, sfEnsureCursorPosForEditRight);
    end;
  finally
    InternalEndUndoBlock;
  end;
  EnsureCursorPosVisible;
end;

procedure TCustomSynEdit.CreateWnd;
begin
  inherited;
  if (eoDropFiles in fOptions) and not (csDesigning in ComponentState) then
    // ToDo DragAcceptFiles
    //old DragAcceptFiles(Handle, TRUE);
    ;
  SizeOrFontChanged(true);
end;

procedure TCustomSynEdit.DestroyWnd;
begin
  {$IFDEF SynCheckPaintLock}
  if (FPaintLock > 0) then begin
    debugln(['TCustomSynEdit.DestroyWnd: Paintlock=', FPaintLock, ' FInvalidateRect=', dbgs(FInvalidateRect)]);
    DumpStack;
  end;
  {$ENDIF}
  if (eoDropFiles in fOptions) and not (csDesigning in ComponentState) then begin
    // ToDo DragAcceptFiles
    //DragAcceptFiles(Handle, FALSE);
    ;
  end;
  {$IFDEF EnableDoubleBuf}
  FreeAndNil(BufferBitmap);
  {$ENDIF}
  SurrenderPrimarySelection;
  inherited DestroyWnd;
end;

procedure TCustomSynEdit.VisibleChanged;
begin
  inherited VisibleChanged;
  UpdateScreenCaret; // This may no longer be needed. It is now done in UpdateShowing
end;

procedure TCustomSynEdit.DoAutoAdjustLayout(
  const AMode: TLayoutAdjustmentPolicy; const AXProportion, AYProportion: Double
  );
begin
  inherited DoAutoAdjustLayout(AMode, AXProportion, AYProportion);

  if AMode in [lapAutoAdjustWithoutHorizontalScrolling, lapAutoAdjustForDPI] then
  begin
    FLeftGutter.ScalePPI(AXProportion);
    FRightGutter.ScalePPI(AXProportion);
  end;
end;

procedure TCustomSynEdit.DoBlockIndent;
var
  BB,BE            : TPoint;
  Line : PChar;
  Len, e, y: integer;
  Spaces, Tabs: String;

  function GetLeadWSLen : integer;
  var
    Run : PChar;
  begin
    Run := Line;
    while (Run[0] in [' ', #9]) do
      Inc(Run);
    Result := Run - Line;
  end;

begin
  IncPaintLock;
  FBlockSelection.IncPersistentLock;
  try
    // build text to insert
    if not SelAvail then begin
      BB := CaretXY;
      BE := CaretXY;
      e := BE.y;
    end else begin
      BB := BlockBegin;
      BE := BlockEnd;
      if FBlockSelection.LastLineHasSelection
      then e := BE.y
      else e := BE.y - 1;
    end;

    Spaces := StringOfChar(#32, FBlockIndent);
    Tabs   := StringOfChar( #9, FBlockTabIndent);
    fUndoList.Lock;
    fRedoList.Lock;
    try
      for y := BB.Y to e do
      begin
        Line := PChar(FTheLinesView[y - 1]);
        Len := GetLeadWSLen;
        FTheLinesView.EditInsert(Len + 1, y, Spaces);
        FTheLinesView.EditInsert(1,       y, Tabs);
      end;
    finally
      fUndoList.Unlock;
      fRedoList.Unlock;
    end;

    fUndoList.AddChange(TSynEditUndoIndent.Create(BB.Y, e, FBlockIndent, FBlockTabIndent));
  finally
    FTrimmedLinesView.ForceTrim; // Otherwise it may reset the block
    FCaret.LineBytePos := FBlockSelection.EndLineBytePos;
    FBlockSelection.DecPersistentLock;
    DecPaintLock;
  end;
end;

procedure TCustomSynEdit.DoBlockUnindent;
const
  LineEnd = #10;
var
  BB, BE: TPoint;
  FullStrToDelete: String;
  Line: PChar;
  Len, LogP1, PhyP1, LogP2, PhyP2, y, StrToDeleteLen, StrToDeletePos, e : integer;
  i, i2, j: Integer;
  SomethingDeleted : Boolean;
  HasTab: Boolean;

  function GetLeadWSLen : integer;
  var
    Run : PChar;
  begin
    Run := Line;
    HasTab := False;
    while (Run[0] in [' ', #9]) do begin
      HasTab := HasTab or (Run[0] = #9);
      Inc(Run);
    end;
    Result := Run - Line;
  end;

begin
  if not SelAvail then begin
    BB := CaretXY;
    BE := CaretXY;
    e := BE.y;
  end else begin
    BB := BlockBegin;
    BE := BlockEnd;
    // convert selection to complete lines
    if FBlockSelection.LastLineHasSelection then
      e := BE.y
    else
      e := BE.y - 1;
  end;

  IncPaintLock;
  FBlockSelection.IncPersistentLock;
  // build string to delete
  StrToDeleteLen := (fBlockIndent+length(LineEnd)) * (e - BB.y + 1) + 1;
  //                 chars per line * lines-1    + last line + null char
  SetLength(FullStrToDelete, StrToDeleteLen);
  StrToDeletePos := 1;
  try
    SomethingDeleted := False;

    fUndoList.Lock;
    fRedoList.Lock;

    // before locking the undo list
    for y := BB.Y to e do
    begin
      Line := PChar(FTheLinesView[y - 1]);
      Len := GetLeadWSLen;
      LogP1 := Len + 1;
      if HasTab and (Len > 0) then begin
        // LogP1, PhyP1 log and phys of the first none-whitespace
        PhyP1 := LogicalToPhysicalPos(Point(LogP1, y)).x;
        // LogP2, PhyP2 log and phys of the point to which to delete back
        LogP2 := PhysicalToLogicalPos(Point( Max(PhyP1 - FBlockIndent, 1), y )).x;
        PhyP2 := LogicalToPhysicalPos(Point(LogP2,y)).x;

        if PhyP1 - PhyP2 <> FBlockIndent then begin
          // need tab to space
          move(Line[LogP2-1], FullStrToDelete[StrToDeletePos], LogP1 - LogP2);
          inc(StrToDeletePos, LogP1 - LogP2);
          FullStrToDelete[StrToDeletePos] := LineEnd;
          inc(StrToDeletePos, 1);
          FTheLinesView.EditDelete(LogP2, y, LogP1 - LogP2);
          SomethingDeleted := True;

          fUndoList.Unlock;
          fRedoList.Unlock;
          FTheLinesView.EditInsert(LogP2, y, StringOfChar(' ', PhyP1 - PhyP2 - FBlockIndent));
          fUndoList.Lock;
          fRedoList.Lock;
          continue;
        end;
        // tabs present, but no replacement needed (LogP1, LogP2 are correct
      end
      else begin
        // no tabs present
        LogP2 := Max(LogP1 - FBlockIndent, 1);
      end;

      // Remove spaces (or tab)
      if LogP1 - LogP2 > 0 then begin
        move(Line[LogP2-1], FullStrToDelete[StrToDeletePos], LogP1 - LogP2);
        inc(StrToDeletePos, LogP1 - LogP2);
      end;
      FullStrToDelete[StrToDeletePos] := LineEnd;
      inc(StrToDeletePos, 1);
      if LogP1 - LogP2 > 0 then
        FTheLinesView.EditDelete(LogP2, y, LogP1 - LogP2);
      SomethingDeleted := SomethingDeleted or (LogP1 - LogP2 > 0);

      // Todo: create FullTabStrToDelete for tabs
      fUndoList.Unlock;
      fRedoList.Unlock;
      Line := PChar(FTheLinesView[y - 1]);
      j := 0;
      for i := 1 to FBlockTabIndent do begin
        i2 := fTabWidth;
        while (i2 > 0) and (Line[j] = #32) do begin
          dec(i2);
          inc(j);
        end;
        if (i2 > 0) and (Line[j] = #9) then inc(j);
      end;
      if j > 0 then
        FTheLinesView.EditDelete(1, y, j);
      fUndoList.Lock;
      fRedoList.Lock;

    end;

    fUndoList.Unlock;
    fRedoList.Unlock;

    if SomethingDeleted then begin
      SetLength(FullStrToDelete, StrToDeletePos - 1);
      fUndoList.AddChange(TSynEditUndoUnIndent.Create(BB.Y, e, FullStrToDelete));
    end;

    FTrimmedLinesView.ForceTrim; // Otherwise it may reset the block
  finally
    FCaret.LineBytePos := FBlockSelection.EndLineBytePos;
    FBlockSelection.DecPersistentLock;
    DecPaintLock;
  end;
end;

procedure TCustomSynEdit.DoHomeKey(aMode: TSynHomeMode = synhmDefault);
// jump to start of line (x=1),
// or if already there, jump to first non blank char
// or if blank line, jump to line indent position
// if eoEnhanceHomeKey and behind alternative point then jump first
var
  s: string;
  FirstNonBlank: Integer;
  LineStart: LongInt;
  OldPos: TPoint;
  NewPos: TPoint;
begin
  OldPos := CaretXY;
  NewPos := OldPos;

  if not(eoEnhanceHomeKey in fOptions) and (CaretX > 1) and (aMode in [synhmDefault]) then
  begin
    // not at start of line -> jump to start of line
    NewPos.X := 1;
  end else
  begin
    // calculate line start position
    FirstNonBlank := -1;
    if CaretY <= FTheLinesView.Count then
    begin
      s := FTheLinesView[CaretXY.Y - 1];

      // search first non blank char pos
      FirstNonBlank := 1;
      while (FirstNonBlank <= length(s)) and (s[FirstNonBlank] in [#32, #9]) do
        inc(FirstNonBlank);
      if FirstNonBlank > length(s) then
        FirstNonBlank := -1;
    end else
      s := '';

    if (FirstNonBlank >= 1) or (aMode in [synhmFirstWord]) then
    begin
      // this line is not blank
      if FirstNonBlank < 1 then FirstNonBlank := 1;
      LineStart := LogicalToPhysicalPos(Point(FirstNonBlank, CaretY)).x;
    end else
    begin
      // this line is blank
      // -> use automatic line indent
      LineStart := FBeautifier.GetDesiredIndentForLine(Self, FTheLinesView, FCaret);
    end;

    NewPos.X:=LineStart;
    if (eoEnhanceHomeKey in fOptions)  and (aMode in [synhmDefault]) and
       (OldPos.X>1) and (OldPos.X<=NewPos.X)
    then begin
      NewPos.X:=1;
    end;
  end;
  FCaret.LineCharPos := NewPos;
end;

procedure TCustomSynEdit.DoEndKey;
// jump to start of line (x=1),
// or if already there, jump to first non blank char
// or if blank line, jump to line indent position
// if eoEnhanceHomeKey and behind alternative point then jump first
var
  s: string;
  LastNonBlank: Integer;
  LineEnd: LongInt;
  OldPos: TPoint;
  NewPos: TPoint;
begin
  OldPos := CaretXY;
  NewPos := OldPos;
  s := LineText;

  if not (eoEnhanceEndKey in fOptions2) and (FCaret.BytePos <> Length(s)+1) then begin
    // not at end of real line -> jump to end of line
    FCaret.BytePos := Length(s)+1;
  end else begin
    // calculate line end position
    LastNonBlank := -1;
    if s <> '' then begin
      // search first non blank char pos
      LastNonBlank := Length(s);
      while (LastNonBlank > 0) and (s[LastNonBlank] in [#32, #9]) do
        dec(LastNonBlank);
    end;
    if LastNonBlank >=1 then begin
      // this line is not blank
      LineEnd := LogicalToPhysicalPos(Point(LastNonBlank + 1, CaretY)).x;
    end else begin
      // this line is blank
      // -> use automatic line indent
      LineEnd := FBeautifier.GetDesiredIndentForLine(Self, FTheLinesView, FCaret);
    end;

    NewPos.X:=LineEnd;
    if (eoEnhanceEndKey in fOptions2) and (FCaret.BytePos <> Length(s)+1) and (OldPos.X >= NewPos.X)
    then begin
      FCaret.BytePos := Length(s)+1;
    end
    else
      FCaret.LineCharPos := NewPos;
  end;
end;

function TCustomSynEdit.ExecuteAction(ExeAction: TBasicAction): boolean;
begin
  if ExeAction is TEditAction then
  begin
    Result := TRUE;
    if ExeAction is TEditCut then
      CutToClipboard
    else if ExeAction is TEditCopy then
      CopyToClipboard
    else if ExeAction is TEditPaste then
      PasteFromClipboard
    else if ExeAction is TEditDelete then
      ClearSelection
    else if ExeAction is TEditUndo then
      Undo
    else if ExeAction is TEditSelectAll then
      SelectAll;
  end else
    Result := inherited ExecuteAction(ExeAction);
end;

function TCustomSynEdit.UpdateAction(TheAction: TBasicAction): boolean;
begin
  if TheAction is TEditAction then
  begin
    Result := Focused;
    if Result then
    begin
      if (TheAction is TEditCut) then
        TEditAction(TheAction).Enabled := SelAvail and (not ReadOnly)
      else if (TheAction is TEditCopy) then
        TEditAction(TheAction).Enabled := SelAvail
      else if TheAction is TEditPaste then
        TEditAction(TheAction).Enabled := CanPaste and (not ReadOnly)
      else if TheAction is TEditDelete then
        TEditAction(TheAction).Enabled := (not ReadOnly)
      else if TheAction is TEditUndo then
        TEditAction(TheAction).Enabled := CanUndo and (not ReadOnly)
      else if TheAction is TEditSelectAll then
        TEditAction(TheAction).Enabled := TRUE;
    end;
  end else
    Result := inherited UpdateAction(TheAction);
end;

procedure TCustomSynEdit.SetModified(Value: boolean);
begin
  TSynEditStringList(FLines).Modified := Value;
end;

procedure TCustomSynEdit.InvalidateLine(Line: integer);
begin
  InvalidateLines(Line, Line);
  InvalidateGutterLines(Line, Line);
end;

procedure TCustomSynEdit.FindMatchingBracket;
begin
  FindMatchingBracket(CaretXY,false,true,false,false);
end;

function TCustomSynEdit.FindMatchingBracket(PhysStartBracket: TPoint;
  StartIncludeNeighborChars, MoveCaret, SelectBrackets, OnlyVisible: Boolean): TPoint;
begin
  Result := FindMatchingBracketLogical(PhysicalToLogicalPos(PhysStartBracket),
                                       StartIncludeNeighborChars, MoveCaret,
                                       SelectBrackets, OnlyVisible);
  if Result.Y > 0 then
    Result := LogicalToPhysicalPos(Result);
end;

function TCustomSynEdit.FindMatchingBracketLogical(LogicalStartBracket: TPoint;
  StartIncludeNeighborChars, MoveCaret, SelectBrackets, OnlyVisible: Boolean): TPoint;
// returns physical (screen) position of end bracket
const
  // keep the ' last
  Brackets: array[0..7] of char = ('(', ')', '[', ']', '{', '}', '''', '"');
type
  TokenPos = Record X: Integer; Attr: Integer; end;
var
  Line, s1: string;
  PosX, PosY: integer;
  StartPt: TPoint;
  // for ContextMatch
  BracketKind, TmpStart: Integer;
  SearchingForward: Boolean;
  TmpAttr : TSynHighlighterAttributes;
  // for IsContextBracket
  MaxKnownTokenPos, LastUsedTokenIdx, TokenListCnt: Integer;
  TokenPosList: Array of TokenPos;

  // remove all text, that is not of desired attribute
  function IsContextBracket: boolean;
  var
    i, l: Integer;
  begin
    if not assigned(fHighlighter) then exit(true);
    if PosX > MaxKnownTokenPos then begin
      // Token is not yet known
      l := Length(TokenPosList);
      if l < max(CharsInWindow * 2, 32) then begin
        l := max(CharsInWindow * 2, 32);
        SetLength(TokenPosList, l);
      end;
      // Init the Highlighter only once per line
      if MaxKnownTokenPos < 1 then begin
        fHighlighter.CurrentLines := FTheLinesView;
        fHighlighter.StartAtLineIndex(PosY - 1);
        TokenListCnt := 0;
      end
      else
        fHighlighter.Next;
      i := TokenListCnt;
      while not fHighlighter.GetEol do begin
        if i >= l then begin
          l := l * 4;
          SetLength(TokenPosList, l);
        end;
        TokenPosList[i].X := fHighlighter.GetTokenPos + 1;
        TokenPosList[i].Attr := fHighlighter.GetTokenKind;
        if TokenPosList[i].X > PosX then begin
          TokenListCnt := i + 1;
          MaxKnownTokenPos := TokenPosList[i].X;
          Result := TokenPosList[i-1].Attr = BracketKind;
          LastUsedTokenIdx := i; // -1; TODO: -1 only if searching backwards
          exit;
        end;
        inc(i);
        fHighlighter.Next;
      end;
      MaxKnownTokenPos := Length(Line) + 1;             // 1 based end+1 of last token (start pos of none existing after eol token)
      if i >= l then begin
        l := l * 4;
        SetLength(TokenPosList, l);
      end;
      TokenPosList[i].X := MaxKnownTokenPos;
      TokenListCnt := i + 1;
      Result := TokenPosList[i-1].Attr = BracketKind;
      LastUsedTokenIdx := i; // -1; TODO: -1 only if searching backwards
      exit;
    end;

    // Token is in previously retrieved values
    i := LastUsedTokenIdx;
    while (i > 0) and (TokenPosList[i].X > PosX) do
      dec(i);
    Result := TokenPosList[i].Attr = BracketKind;
    if not SearchingForward then
      LastUsedTokenIdx := i;
  end;

  procedure DoMatchingBracketFound;
  var
    EndPt, DummyPt: TPoint;
  begin
    // matching bracket found, set caret and bail out
    Result := Point(PosX, PosY); // start with logical (byte) position
    if SelectBrackets then begin
      EndPt:=Result;
      if (EndPt.Y < StartPt.Y)
        or ((EndPt.Y = StartPt.Y) and (EndPt.X < StartPt.X)) then
      begin
        DummyPt:=StartPt;
        StartPt:=EndPt;
        EndPt:=DummyPt;
      end;
      inc(EndPt.X);
      SetCaretAndSelection(CaretXY, StartPt, EndPt);
    end
    else if MoveCaret then
      LogicalCaretXY := Result;
  end;

  procedure DoFindMatchingQuote(q: char);
  var
    Test: char;
    Len, PrevPosX, PrevCnt: integer;
  begin
    StartPt:=Point(PosX,PosY);
    GetHighlighterAttriAtRowColEx(StartPt, s1, BracketKind, TmpStart, TmpAttr);
    // Checck if we have a complete token, e.g. Highlightec returned entire "string"
    if (TmpStart = PosX) and (Length(s1)>1) and (s1[Length(s1)] = q) then begin
      PosX := PosX + Length(s1) - 1;
      DoMatchingBracketFound;
      exit;
    end;
    if (TmpStart + Length(s1) - 1 = PosX) and (Length(s1)>1) and (s1[1] = q) then begin
      PosX := PosX - Length(s1) + 1;
      DoMatchingBracketFound;
      exit;
    end;

    MaxKnownTokenPos := 0;
    Len := PosX;
    PrevPosX := -1;
    PrevCnt := 0;
    // search until start of line
    SearchingForward := False;
    while PosX > 1 do begin
      Dec(PosX);
      Test := Line[PosX];
      if (Test = q) and IsContextBracket then begin
        inc(PrevCnt);
        if PrevPosX < 0 then PrevPosX := PosX;
      end;
    end;
    // 1st, 3rd, 5th, ... are opening
    if (PrevPosX > 0) and (PrevCnt mod 2 = 1) then begin
      PosX := PrevPosX;
      DoMatchingBracketFound;
      exit;
    end;

    PosX := Len;
    Len := Length(Line);
    SearchingForward := True;
    LastUsedTokenIdx := TokenListCnt;
    while PosX < Len do begin
      Inc(PosX);
      Test := Line[PosX];
      if (Test = q) and IsContextBracket then begin
        DoMatchingBracketFound;
        exit;
      end;
    end;

    if (PrevPosX > 0) then begin
      PosX := PrevPosX;
      DoMatchingBracketFound;
      exit;
    end;
  end;

  procedure DoFindMatchingBracket(i: integer);
  var
    Test, BracketInc, BracketDec: char;
    NumBrackets, Len: integer;
  begin
    StartPt:=Point(PosX,PosY);
    GetHighlighterAttriAtRowColEx(StartPt, s1, BracketKind, TmpStart, TmpAttr);
    MaxKnownTokenPos := 0;
    BracketInc := Brackets[i];
    BracketDec := Brackets[i xor 1]; // 0 -> 1, 1 -> 0, ...
    // search for the matching bracket (that is until NumBrackets = 0)
    NumBrackets := 1;
    if Odd(i) then begin
      // closing bracket -> search opening bracket
      SearchingForward := False;
      repeat
        // search until start of line
        while PosX > 1 do begin
          Dec(PosX);
          Test := Line[PosX];
          if (Test = BracketInc) and IsContextBracket then
            Inc(NumBrackets)
          else if (Test = BracketDec) and IsContextBracket then begin
            Dec(NumBrackets);
            if NumBrackets = 0 then begin
              DoMatchingBracketFound;
              exit;
            end;
          end;
        end;
        // get previous line if possible
        if PosY = 1 then break;
        Dec(PosY);
        if OnlyVisible
        and ((PosY<TopLine) or (PosY >= ScreenRowToRow(LinesInWindow)))
        then
          break;
        Line := FTheLinesView[PosY - 1];
        MaxKnownTokenPos := 0;
        PosX := Length(Line) + 1;
      until FALSE;
    end else begin
      // opening bracket -> search closing bracket
      SearchingForward := True;
      repeat
        // search until end of line
        Len := Length(Line);
        while PosX < Len do begin
          Inc(PosX);
          Test := Line[PosX];
          if (Test = BracketInc) and IsContextBracket then
            Inc(NumBrackets)
          else if (Test = BracketDec) and IsContextBracket then begin
            Dec(NumBrackets);
            if NumBrackets = 0 then begin
              DoMatchingBracketFound;
              exit;
            end;
          end;
        end;
        // get next line if possible
        if PosY = FTheLinesView.Count then break;
        Inc(PosY);
        if OnlyVisible
        and ((PosY < TopLine) or (PosY >= ScreenRowToRow(LinesInWindow)))
        then
          break;
        Line := FTheLinesView[PosY - 1];
        MaxKnownTokenPos := 0;
        PosX := 0;
      until FALSE;
    end;
  end;

  procedure DoCheckBracket;
  var
    i: integer;
    Test: char;
  begin
    if Length(Line) >= PosX then begin
      Test := Line[PosX];
      // is it one of the recognized brackets?
      for i := Low(Brackets) to High(Brackets) do begin
        if Test = Brackets[i] then begin
          // this is the bracket, get the matching one and the direction
          if Brackets[i] in ['''', '"'] then
            DoFindMatchingQuote(Brackets[i])
          else
            DoFindMatchingBracket(i);
          exit;
        end;
      end;
    end;
  end;

begin
  Result.X:=-1;
  Result.Y:=-1;

  PosX := LogicalStartBracket.X;
  PosY := LogicalStartBracket.Y;
  if (PosY<1) or (PosY>FTheLinesView.Count) then exit;
  if OnlyVisible
  and ((PosY<TopLine) or (PosY >= ScreenRowToRow(LinesInWindow)))
  then
   exit;

  Line := FTheLinesView[PosY - 1];
  DoCheckBracket;
  if Result.Y>0 then exit;
  if StartIncludeNeighborChars then begin
    if PosX>1 then begin
      // search in front
      dec(PosX);
      DoCheckBracket;
      if Result.Y>0 then exit;
      inc(PosX);
    end;
    if PosX<Length(Line) then begin
      // search behind
      inc(PosX);
      DoCheckBracket;
      if Result.Y>0 then exit;
    end;
  end;
end;

                                                                                 //L505 begin
function TCustomSynEdit.GetHighlighterAttriAtRowCol(XY: TPoint;
  out Token: string; out Attri: TSynHighlighterAttributes): boolean;
var
  TmpType, TmpStart: Integer;
begin
  Result := GetHighlighterAttriAtRowColEx(XY, Token, TmpType, TmpStart, Attri);
end;

function TCustomSynEdit.GetHighlighterAttriAtRowColEx(XY: TPoint;
  out Token: string; out TokenType, Start: Integer;
  out Attri: TSynHighlighterAttributes): boolean;
var
  PosX, PosY: integer;
  Line: string;
begin
  PosY := XY.Y -1;
  if Assigned(Highlighter) and (PosY >= 0) and (PosY < FTheLinesView.Count) then
  begin
    Line := FTheLinesView[PosY];
    fHighlighter.CurrentLines := FTheLinesView;
    Highlighter.StartAtLineIndex(PosY);
    PosX := XY.X;
    if (PosX > 0) and (PosX <= Length(Line)) then begin
      while not Highlighter.GetEol do begin
        Start := Highlighter.GetTokenPos + 1;
        Token := Highlighter.GetToken;
        if (PosX >= Start) and (PosX < Start + Length(Token)) then begin
          Attri := Highlighter.GetTokenAttribute;
          TokenType := Highlighter.GetTokenKind;
          exit(True);
        end;
        Highlighter.Next;
      end;
    end;
  end;
  Token := '';
  Attri := nil;
  TokenType := -1;
  Result := False;
end;

procedure TCustomSynEdit.CaretAtIdentOrString(XY: TPoint; out AtIdent, NearString: Boolean);
// This is optimized to check if cursor is on identifier or string.
var
  PosX, PosY: integer;
  Line, Token: string;
  Start: Integer;
  Attri, PrevAttri: TSynHighlighterAttributes;
begin
  PosY := XY.Y -1;
  PrevAttri := nil;
  AtIdent := False;
  NearString := False;
  //DebugLn('');
  //DebugLn('TCustomSynEdit.CaretAtIdentOrString: Enter');
  if Assigned(Highlighter) and (PosY >= 0) and (PosY < FTheLinesView.Count) then
  begin
    Line := FTheLinesView[PosY];
    fHighlighter.CurrentLines := FTheLinesView;
    Highlighter.StartAtLineIndex(PosY);
    PosX := XY.X;
    //DebugLn([' TCustomSynEdit.CaretAtIdentOrString: Line="', Line, '", PosX=', PosX, ', PosY=', PosY]);
    if (PosX > 0) and (PosX <= Length(Line)) then
    begin
      while not Highlighter.GetEol do
      begin
        Start := Highlighter.GetTokenPos + 1;
        Token := Highlighter.GetToken;
        //TokenType := Highlighter.GetTokenKind;
        Attri := Highlighter.GetTokenAttribute;
        //DebugLn(['  TCustomSynEdit.CaretAtIdentOrString: Start=', Start, ', Token=', Token]);
        if (PosX = Start) then
        begin
          AtIdent := (Attri = Highlighter.IdentifierAttribute)
                  or (PrevAttri = Highlighter.IdentifierAttribute);
          NearString := (Attri = Highlighter.StringAttribute)
                 or (PrevAttri = Highlighter.StringAttribute); // If cursor is on end-quote.
          //DebugLn(['   TCustomSynEdit.CaretAtIdentOrString: Success! Attri=', Attri,
          //         ', AtIdent=', AtIdent, ', AtString=', AtString]);
          exit;
        end;
        if (PosX >= Start) and (PosX < Start + Length(Token)) then
        begin
          AtIdent := Attri = Highlighter.IdentifierAttribute;
          NearString := (Attri = Highlighter.StringAttribute);
          exit;
        end;
        PrevAttri := Attri;
        Highlighter.Next;
      end;
    end;
  end;
end;

function TCustomSynEdit.IdentChars: TSynIdentChars;
begin
  Result := FWordBreaker.IdentChars;  // Maybe WordChars?
end;

function TCustomSynEdit.IsIdentChar(const c: TUTF8Char): boolean;
begin
  Result:=(length(c)=1) and (c[1] in IdentChars);
end;

procedure TCustomSynEdit.GetWordBoundsAtRowCol(const XY: TPoint; out StartX,
  EndX: integer); // all params are logical (byte) positions
var
  Line: string;
begin
  StartX:=XY.X;
  EndX:=XY.X;
  Line := FTheLinesView[XY.Y - 1];
  if WordBreaker.IsInWord(Line, XY.X) then begin
    StartX := WordBreaker.PrevWordStart(Line, XY.X, True);
    EndX := WordBreaker.NextWordEnd(Line, XY.X, True);
  end;
end;

function TCustomSynEdit.GetWordAtRowCol(XY: TPoint): string;
var
  StartX, EndX: integer;
  Line: string;
begin
  GetWordBoundsAtRowCol(XY, StartX, EndX);
  Line := FTheLinesView[XY.Y - 1];
  Result := Copy(Line, StartX, EndX - StartX);
end;

function TCustomSynEdit.NextTokenPos: TPoint;
var
  CX, CY, LineLen: integer;
  Line: string;
  CurIdentChars, WhiteChars: TSynIdentChars;
  nTokenPos, nTokenLen: integer;
  sToken: PChar;
  LogCaret: TPoint;

  procedure FindFirstNonWhiteSpaceCharInNextLine;
  begin
    if CY < FTheLinesView.Count then begin
      Line := FTheLinesView[CY];
      LineLen := Length(Line);
      Inc(CY);
      CX:=1;
      while (CX<=LineLen) and (Line[CX] in WhiteChars) do inc(CX);
      if CX>LineLen then CX:=1;
    end;
  end;

begin
  LogCaret:=LogicalCaretXY;
  CX := LogCaret.X;
  CY := LogCaret.Y;
  // valid line?
  if (CY >= 1) and (CY <= FTheLinesView.Count) then begin
    Line := FTheLinesView[CY - 1];
    LineLen := Length(Line);
    WhiteChars := FWordBreaker.WhiteChars;
    if CX > LineLen then begin
      FindFirstNonWhiteSpaceCharInNextLine;
    end else begin
      if fHighlighter<>nil then begin
        fHighlighter.CurrentLines := FTheLinesView;
        fHighlighter.StartAtLineIndex(CY - 1);
        while not fHighlighter.GetEol do begin
          nTokenPos := fHighlighter.GetTokenPos; // zero-based
          fHighlighter.GetTokenEx(sToken,nTokenLen);
          if (CX>nTokenPos) and (CX<=nTokenPos+nTokenLen) then begin
            CX:=nTokenPos+nTokenLen+1;
            break;
          end;
          // Let the highlighter scan the next token.
          fHighlighter.Next;
        end;
        if fHighlighter.GetEol then
          FindFirstNonWhiteSpaceCharInNextLine;
      end else begin
        // no highlighter
        CurIdentChars:=IdentChars;
        // find first "whitespace" if next char is not a "whitespace"
        if (Line[CX] in CurIdentChars) then begin
          // in a word -> move to end of word
          while (CX<=LineLen) and (Line[CX] in CurIdentChars) do inc(CX);
        end;
        if (Line[CX] in WhiteChars) then begin
          // skip white space
          while (CX<=LineLen) and (Line[CX] in WhiteChars) do inc(CX);
        end;
        // delete at least one char
        if (CX=CaretX) then inc(CX);
      end;
    end;
  end;
  Result := LogicalToPhysicalPos(Point(CX, CY));
end;

function TCustomSynEdit.NextWordPos: TPoint;
begin
  Result := LogicalToPhysicalPos(NextWordLogicalPos);
end;

function TCustomSynEdit.PrevWordPos: TPoint;
begin
  Result := LogicalToPhysicalPos(PrevWordLogicalPos);
end;

function TCustomSynEdit.FindHookedCmdEvent(AHandlerProc: THookedCommandEvent):
  integer;
var
  Entry: THookedCommandHandlerEntry;
begin
  Result := GetHookedCommandHandlersCount - 1;
  while Result >= 0 do begin
    Entry := THookedCommandHandlerEntry(fHookedCommandHandlers[Result]);
    if Entry.Equals(AHandlerProc) then
      break;
    Dec(Result);
  end;
end;

function TCustomSynEdit.GetHookedCommandHandlersCount: integer;
begin
  if Assigned(fHookedCommandHandlers) then
    Result := fHookedCommandHandlers.Count
  else
    Result := 0;
end;

procedure TCustomSynEdit.RegisterCommandHandler(AHandlerProc: THookedCommandEvent;
  AHandlerData: pointer; AFlags: THookedCommandFlags);
begin
  if not Assigned(AHandlerProc) then begin
{$IFDEF SYN_DEVELOPMENT_CHECKS}
    raise Exception.Create('Event handler is NIL in RegisterCommandHandler');
{$ENDIF}
    exit;
  end;
  if not Assigned(fHookedCommandHandlers) then
    fHookedCommandHandlers := TList.Create;
  if FindHookedCmdEvent(AHandlerProc) = -1 then
    fHookedCommandHandlers.Add(THookedCommandHandlerEntry.Create(
      AHandlerProc, AHandlerData, AFlags))
  else
{$IFDEF SYN_DEVELOPMENT_CHECKS}
    raise Exception.CreateFmt('Event handler (%p, %p) already registered',
      [TMethod(AHandlerProc).Data, TMethod(AHandlerProc).Code]);
{$ENDIF}
end;

procedure TCustomSynEdit.UnregisterCommandHandler(AHandlerProc:
  THookedCommandEvent);
var
  i: integer;
begin
  if not Assigned(AHandlerProc) then begin
{$IFDEF SYN_DEVELOPMENT_CHECKS}
    raise Exception.Create('Event handler is NIL in UnregisterCommandHandler');
{$ENDIF}
    exit;
  end;
  i := FindHookedCmdEvent(AHandlerProc);
  if i > -1 then begin
    THookedCommandHandlerEntry(fHookedCommandHandlers[i]).Free;
    fHookedCommandHandlers.Delete(i);
  end else
{$IFDEF SYN_DEVELOPMENT_CHECKS}
    raise Exception.CreateFmt('Event handler (%p, %p) is not registered',
      [TMethod(AHandlerProc).Data, TMethod(AHandlerProc).Code]);
{$ENDIF}
end;

procedure TCustomSynEdit.RegisterMouseActionSearchHandler(AHandlerProc: TSynEditMouseActionSearchProc);
begin
  FMouseActionSearchHandlerList.Add(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.UnregisterMouseActionSearchHandler(AHandlerProc: TSynEditMouseActionSearchProc);
begin
  FMouseActionSearchHandlerList.Remove(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterMouseActionExecHandler(AHandlerProc: TSynEditMouseActionExecProc);
begin
  FMouseActionExecHandlerList.Add(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.UnregisterMouseActionExecHandler(AHandlerProc: TSynEditMouseActionExecProc);
begin
  FMouseActionExecHandlerList.Remove(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterKeyTranslationHandler(AHandlerProc: THookedKeyTranslationEvent);
begin
  FHookedKeyTranslationList.Add(TMEthod(AHandlerProc));
end;

procedure TCustomSynEdit.UnRegisterKeyTranslationHandler(AHandlerProc: THookedKeyTranslationEvent);
begin
  FHookedKeyTranslationList.Remove(TMEthod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterUndoRedoItemHandler(AHandlerProc: TSynUndoRedoItemEvent);
begin
  FUndoRedoItemHandlerList.Add(TMEthod(AHandlerProc));
end;

procedure TCustomSynEdit.UnRegisterUndoRedoItemHandler(AHandlerProc: TSynUndoRedoItemEvent);
begin
  FUndoRedoItemHandlerList.Remove(TMEthod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterStatusChangedHandler(AStatusChangeProc: TStatusChangeEvent;
  AChanges: TSynStatusChanges);
begin
  TSynStatusChangedHandlerList(FStatusChangedList).Add(AStatusChangeProc, AChanges);
end;

procedure TCustomSynEdit.UnRegisterStatusChangedHandler(AStatusChangeProc: TStatusChangeEvent);
begin
  TSynStatusChangedHandlerList(FStatusChangedList).Remove(AStatusChangeProc);
end;

procedure TCustomSynEdit.RegisterBeforeMouseDownHandler(AHandlerProc: TMouseEvent);
begin
  if FMouseDownEventList = nil then
    FMouseDownEventList := TLazSynMouseDownEventList.Create;
  FMouseDownEventList.Add(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.UnregisterBeforeMouseDownHandler(AHandlerProc: TMouseEvent);
begin
  if FMouseDownEventList <> nil then
    FMouseDownEventList.Remove(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterQueryMouseCursorHandler(AHandlerProc: TSynQueryMouseCursorEvent);
begin
  if FQueryMouseCursorList = nil then
    FQueryMouseCursorList := TSynQueryMouseCursorList.Create;
  TSynQueryMouseCursorList(FQueryMouseCursorList).Add(AHandlerProc);
end;

procedure TCustomSynEdit.UnregisterQueryMouseCursorHandler(AHandlerProc: TSynQueryMouseCursorEvent);
begin
  if FQueryMouseCursorList <> nil then
    TSynQueryMouseCursorList(FQueryMouseCursorList).Remove(AHandlerProc);
end;

procedure TCustomSynEdit.RegisterBeforeKeyDownHandler(AHandlerProc: TKeyEvent);
begin
  if FKeyDownEventList = nil then
    FKeyDownEventList := TLazSynKeyDownEventList.Create;
  FKeyDownEventList.Add(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.UnregisterBeforeKeyDownHandler(AHandlerProc: TKeyEvent);
begin
  if FKeyDownEventList <> nil then
    FKeyDownEventList.Remove(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterBeforeKeyUpHandler(AHandlerProc: TKeyEvent);
begin
  if FKeyUpEventList = nil then
    FKeyUpEventList := TLazSynKeyDownEventList.Create;
  FKeyUpEventList.Add(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.UnregisterBeforeKeyUpHandler(AHandlerProc: TKeyEvent);
begin
  if FKeyUpEventList <> nil then
    FKeyUpEventList.Remove(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterBeforeKeyPressHandler(AHandlerProc: TKeyPressEvent);
begin
  if FKeyPressEventList = nil then
    FKeyPressEventList := TLazSynKeyPressEventList.Create;
  FKeyPressEventList.Add(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.UnregisterBeforeKeyPressHandler(AHandlerProc: TKeyPressEvent);
begin
  if FKeyPressEventList <> nil then
    FKeyPressEventList.Remove(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterBeforeUtf8KeyPressHandler(AHandlerProc: TUTF8KeyPressEvent);
begin
  if FUtf8KeyPressEventList = nil then
    FUtf8KeyPressEventList := TLazSynUtf8KeyPressEventList.Create;
  FUtf8KeyPressEventList.Add(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.UnregisterBeforeUtf8KeyPressHandler(AHandlerProc: TUTF8KeyPressEvent);
begin
  if FUtf8KeyPressEventList <> nil then
    FUtf8KeyPressEventList.Remove(TMethod(AHandlerProc));
end;

procedure TCustomSynEdit.RegisterPaintEventHandler(APaintEventProc: TSynPaintEventProc;
  AnEvents: TSynPaintEvents);
begin
  TSynPaintEventHandlerList(FPaintEventHandlerList).Add(APaintEventProc, AnEvents);
end;

procedure TCustomSynEdit.UnRegisterPaintEventHandler(APaintEventProc: TSynPaintEventProc);
begin
  TSynPaintEventHandlerList(FPaintEventHandlerList).Remove(APaintEventProc);
end;

procedure TCustomSynEdit.RegisterScrollEventHandler(AScrollEventProc: TSynScrollEventProc;
  AnEvents: TSynScrollEvents);
begin
  TSynScrollEventHandlerList(FScrollEventHandlerList).Add(AScrollEventProc, AnEvents);
end;

procedure TCustomSynEdit.UnRegisterScrollEventHandler(AScrollEventProc: TSynScrollEventProc);
begin
  TSynScrollEventHandlerList(FScrollEventHandlerList).Remove(AScrollEventProc);
end;

procedure TCustomSynEdit.NotifyHookedCommandHandlers(var Command: TSynEditorCommand;
  var AChar: TUTF8Char; Data: pointer; ATime: THookedCommandFlag);
var
  Handled: boolean;
  i: integer;
  Entry: THookedCommandHandlerEntry;
begin
  Handled := FALSE;
  for i := 0 to GetHookedCommandHandlersCount - 1 do begin
    Entry := THookedCommandHandlerEntry(fHookedCommandHandlers[i]);
    if not(ATime in Entry.FFlags) then continue;
    // NOTE: Command should NOT be set to ecNone, because this might interfere
    // with other handlers.  Set Handled to False instead (and check its value
    // to not process the command twice).
    Entry.fEvent(Self, ATime in [hcfPostExec, hcfFinish], Handled, Command, AChar, Data,
      Entry.fData);
  end;
  if Handled then
    Command := ecNone;
end;

procedure TCustomSynEdit.DoOnPaint;
begin
  if Assigned(fOnPaint) then begin
    Canvas.Font.Assign(Font);
    Canvas.Brush.Color := Color;
    fOnPaint(Self, Canvas);
  end;
end;

function TCustomSynEdit.GetPaintArea: TLazSynSurfaceManager;
begin
  Result := FPaintArea;
end;

function TCustomSynEdit.DoOnReplaceText(const ASearch, AReplace: string;
  Line, Column: integer): TSynReplaceAction;
begin
  Result := raCancel;
  if Assigned(fOnReplaceText) then
    fOnReplaceText(Self, ASearch, AReplace, Line, Column, Result);
end;

procedure TCustomSynEdit.DoOnStatusChange(Changes: TSynStatusChanges);
begin
  TSynStatusChangedHandlerList(FStatusChangedList).CallStatusChangedHandlers(Self, Changes);
  if Assigned(fOnStatusChange) then
    fOnStatusChange(Self, fStatusChanges);
  fStatusChanges := [];
end;

procedure TCustomSynEdit.UndoRedoAdded(Sender: TObject);
begin
  // Todo: Check Paintlock, otherwise move to LinesChanged, LineCountChanged
  if Assigned(fOnChange) then
    fOnChange(Self);
end;

procedure TCustomSynEdit.ModifiedChanged(Sender: TObject);
begin
  StatusChanged([scModified]);
end;

function TCustomSynEdit.LogicalToPhysicalPos(const p: TPoint): TPoint;
begin
  Result := FTheLinesView.LogicalToPhysicalPos(p);
end;

function TCustomSynEdit.LogicalToPhysicalCol(const Line: String;
  Index, LogicalPos: integer): integer;
// LogicalPos is 1-based
// Index 0-based LineNumber
begin
  Result := FTheLinesView.LogicalToPhysicalCol(Line, Index,
                                                                LogicalPos);
end;

function TCustomSynEdit.PhysicalLineLength(Line: String; Index: integer): integer;
begin
  Result:=LogicalToPhysicalCol(Line, Index, length(Line)+1) - 1
end;

(* from SynMemo - NOT recommended to use - Extremly slow code
   SynEdit (and SynMemo) is a Linebased Editor and not meant to be accessed as a contineous text
*)
function TCustomSynEdit.CharIndexToRowCol(Index: integer): TPoint;
var
  x, y, Chars: integer;
  e: string;
  LineEndLen: Integer;
begin
  x := 0;
  y := 0;
  e:=LineEnding;
  LineEndLen:=length(e);
  Chars := 0;
  while y < TextBuffer.Count do begin
    x := Length(TextBuffer[y]);
    if Chars + x + LineEndLen > Index then begin
      x := Index - Chars;
      break;
    end;
    Inc(Chars, x + LineEndLen);
    x := 0;
    Inc(y);
  end;
  Result := Point(x + 1, y + 1);
end;

(* from SynMemo - NOT recommended to use - Extremly slow code
   SynEdit (and SynMemo) is a Linebased Editor and not meant to be accessed as a contineous text
*)
function TCustomSynEdit.RowColToCharIndex(RowCol: TPoint): integer;
var
  i: integer;
  e: string;
  LineEndLen: Integer;
begin
  Result := 0;
  RowCol.y := Min(TextBuffer.Count, RowCol.y) - 1;
  e:=LineEnding;
  LineEndLen:=length(e);
  for i := 0 to RowCol.y - 1 do
    Result := Result + Length(TextBuffer[i]) + LineEndLen;
  Result := Result + RowCol.x;
end;

function TCustomSynEdit.PhysicalToLogicalPos(const p: TPoint): TPoint;
begin
  Result := FTheLinesView.PhysicalToLogicalPos(p);
end;

function TCustomSynEdit.PhysicalToLogicalCol(const Line: string;
  Index, PhysicalPos: integer): integer;
begin
  Result := FTheLinesView.PhysicalToLogicalCol(Line, Index,
                                                                PhysicalPos);
end;

function TCustomSynEdit.ScreenColumnToXValue(Col : integer) : integer;
begin
  Result := FTextArea.ScreenColumnToXValue(Col);
end;

procedure TCustomSynEdit.PrimarySelectionRequest(
  const RequestedFormatID: TClipboardFormat;  Data: TStream);
var
  s: string;
  ClipHelper: TSynClipboardStream;
begin
  if (not SelAvail) then exit;
  s:=SelText;
  if s = ''  then
    exit;
  if RequestedFormatID = CF_TEXT then begin
    Data.Write(s[1],length(s));
  end
  else
  if RequestedFormatID = TSynClipboardStream.ClipboardFormatId then begin
    ClipHelper := TSynClipboardStream.Create;
    try
      ClipHelper.SelectionMode := SelectionMode;
      // InternalText, so we don't need a 2nd call for CF_TEXT
      ClipHelper.InternalText := s;
      // Fold
      if eoFoldedCopyPaste in fOptions2 then
        s := FFoldedLinesView.GetFoldDescription(
          FBlockSelection.FirstLineBytePos.Y - 1, FBlockSelection.FirstLineBytePos.X,
          FBlockSelection.LastLineBytePos.Y - 1,  FBlockSelection.LastLineBytePos.X);
      if length(s) > 0 then
        ClipHelper.AddTag(synClipTagFold, @s[1], length(s));
      Data.Write(ClipHelper.Memory^, ClipHelper.Size);
    finally
      ClipHelper.Free;
    end;
  end;
end;

{ TLazSynEditPlugin }

constructor TLazSynEditPlugin.Create(AOwner: TComponent);
begin
  if AOwner is TCustomSynEdit then begin
    inherited Create(nil);
    Editor := TCustomSynEdit(AOwner);
  end
  else
    inherited Create(AOwner);
end;

destructor TLazSynEditPlugin.Destroy;
begin
  Editor := nil;
  inherited Destroy;
end;

procedure TLazSynEditPlugin.BeforeEditorChange;
begin
  if (Editor <> nil) then begin
    DoEditorRemoving(Editor);
    UnRegisterFromEditor(Editor);
  end;
end;

procedure TLazSynEditPlugin.AfterEditorChange;
begin
  if Editor <> nil then begin
    RegisterToEditor(Editor);
    DoEditorAdded(Editor);
  end;
end;

procedure TLazSynEditPlugin.RegisterToEditor(AValue: TCustomSynEdit);
begin
  if AValue.fPlugins <> nil then
    AValue.fPlugins.Add(Self);
end;

procedure TLazSynEditPlugin.UnRegisterFromEditor(AValue: TCustomSynEdit);
begin
  if AValue.fPlugins <> nil then
    AValue.fPlugins.Remove(Self);
end;

procedure TLazSynEditPlugin.SetEditor(const AValue: TCustomSynEdit);
begin
  if AValue = FriendEdit then exit;

  BeforeEditorChange;
  FriendEdit := AValue;
  AfterEditorChange;
end;

function TLazSynEditPlugin.GetEditor: TCustomSynEdit;
begin
  Result := FriendEdit as TCustomSynEdit;
end;

function TLazSynEditPlugin.OwnedByEditor: Boolean;
begin
  Result := Owner = nil;
end;

procedure TLazSynEditPlugin.DoEditorDestroyed(const AValue: TCustomSynEdit);
begin
  if Editor <> AValue then exit;
  if OwnedByEditor then begin
    // if no DoEditorDestroyed
    if TMethod(@DoEditorRemoving).Code = Pointer(@TLazSynEditPlugin.DoEditorDestroyed) then
      DoEditorRemoving(AValue);
    Free;
  end
  else
    Editor := nil;
end;

procedure TLazSynEditPlugin.DoEditorAdded(AValue: TCustomSynEdit);
begin
  //
end;

procedure TLazSynEditPlugin.DoEditorRemoving(AValue: TCustomSynEdit);
begin
  //
end;

procedure Register;
begin
  RegisterClasses([TSynGutterPartList, TSynRightGutterPartList,
                   TSynGutterSeparator, TSynGutterCodeFolding,
                   TSynGutterLineNumber, TSynGutterChanges, TSynGutterMarks,
                   TSynGutterLineOverview]);

  RegisterPropertyToSkip(TSynSelectedColor, 'OnChange', '', '');
  RegisterPropertyToSkip(TSynSelectedColor, 'StartX', '', '');
  RegisterPropertyToSkip(TSynSelectedColor, 'EndX', '', '');

  RegisterPropertyToSkip(TSynGutter, 'ShowCodeFolding', '', '');
  RegisterPropertyToSkip(TSynGutter, 'CodeFoldingWidth', '', '');
  RegisterPropertyToSkip(TSynGutter, 'ShowChanges', '', '');
  RegisterPropertyToSkip(TSynGutter, 'ShowLineNumbers', '', '');
  RegisterPropertyToSkip(TSynGutter, 'ShowOnlyLineNumbersMultiplesOf', '', '');
  RegisterPropertyToSkip(TSynGutter, 'ZeroStart', '', '');
  RegisterPropertyToSkip(TSynGutter, 'MarkupInfoLineNumber', '', '');
  RegisterPropertyToSkip(TSynGutter, 'MarkupInfoModifiedLine', '', '');
  RegisterPropertyToSkip(TSynGutter, 'MarkupInfoCodeFoldingTree', '', '');
  RegisterPropertyToSkip(TSynGutter, 'LeadingZeros', '', '');
  RegisterPropertyToSkip(TSynGutter, 'DigitCount', '', '');
  RegisterPropertyToSkip(TSynGutter, 'AllowSkipGutterSeparatorDraw', '', '');
  RegisterPropertyToSkip(TSynGutter, 'GutterParts', '', '');
  RegisterPropertyToSkip(TSynGutter, 'OnChange', '', '');
  RegisterPropertyToSkip(TSynEdit, 'CFDividerDrawLevel', '', '');
end;

{ TSynHookedKeyTranslationList }

procedure TSynHookedKeyTranslationList.CallHookedKeyTranslationHandlers(Sender: TObject;
  Code: word; SState: TShiftState; var Data: pointer; var IsStartOfCombo: boolean;
  var Handled: boolean; var Command: TSynEditorCommand;
  var ComboKeyStrokes: TSynEditKeyStrokes);
var
  i: Integer;
begin
  if ComboKeyStrokes <> nil then begin
    // Finish Combo
    for i := 0 to Count - 1 do
      THookedKeyTranslationEvent(Items[i])(Sender, Code, SState, Data,
        IsStartOfCombo, Handled, Command, True, ComboKeyStrokes);
  end
  else begin
    // New Stroke
    for i := 0 to Count - 1 do
      THookedKeyTranslationEvent(Items[i])(Sender, Code, SState, Data,
        IsStartOfCombo, Handled, Command, False, ComboKeyStrokes);
  end;
end;

{ TLazSynUtf8KeyPressEventList }

procedure TLazSynUtf8KeyPressEventList.CallUtf8KeyPressHandlers(Sender: TObject;
  var UTF8Key: TUTF8Char);
var
  i: LongInt;
begin
  i:=Count;
  while NextDownIndex(i) do
    TUTF8KeyPressEvent(Items[i])(Sender, UTF8Key);
end;

{ TLazSynKeyPressEventList }

procedure TLazSynKeyPressEventList.CallKeyPressHandlers(Sender: TObject; var Key: char);
var
  i: LongInt;
begin
  i:=Count;
  while NextDownIndex(i) do
    TKeyPressEvent(Items[i])(Sender, Key);
end;

{ TSynUndoRedoItemHandlerList }

function TSynUndoRedoItemHandlerList.CallUndoRedoItemHandlers(Caller: TObject;
  Item: TSynEditUndoItem): Boolean;
var
  i: LongInt;
begin
  i:=Count;
  Result := False;
  while NextDownIndex(i) and (not Result) do
    Result := TSynUndoRedoItemEvent(Items[i])(Caller, Item);
end;

{ TLazSynMouseDownEventList }

procedure TLazSynMouseDownEventList.CallMouseDownHandlers(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: LongInt;
begin
  i:=Count;
  while NextDownIndex(i) do
    TMouseEvent(Items[i])(Sender, Button, Shift, X, Y);
end;

{ TLazSynKeyDownEventList }

procedure TLazSynKeyDownEventList.CallKeyDownHandlers(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: LongInt;
begin
  i:=Count;
  while NextDownIndex(i) do
    TKeyEvent(Items[i])(Sender, Key, Shift);
end;

{ TSynStatusChangedHandlerList }
procedure TSynStatusChangedHandlerList.Add(AHandler: TStatusChangeEvent;
  Changes: TSynStatusChanges);
begin
  AddBitFilter(TMethod(AHandler), LongInt(Changes));
end;

procedure TSynStatusChangedHandlerList.Remove(AHandler: TStatusChangeEvent);
begin
  inherited Remove(TMethod(AHandler));
end;

procedure TSynStatusChangedHandlerList.CallStatusChangedHandlers(Sender: TObject;
  Changes: TSynStatusChanges);
var
  i: Integer;
begin
  i:=Count;
  while NextDownIndexBitFilter(i, LongInt(Changes)) do
    TStatusChangeEvent(FItems[i].FHandler)(Sender, Changes);
end;

{ TSynPaintEventHandlerList }

procedure TSynPaintEventHandlerList.Add(AHandler: TSynPaintEventProc;
  Changes: TSynPaintEvents);
begin
  AddBitFilter(TMethod(AHandler), LongInt(Changes));
end;

procedure TSynPaintEventHandlerList.Remove(AHandler: TSynPaintEventProc);
begin
  inherited Remove(TMethod(AHandler));
end;

procedure TSynPaintEventHandlerList.CallPaintEventHandlers(Sender: TObject;
  AnEvent: TSynPaintEvent; const rcClip: TRect);
var
  i: Integer;
begin
  i:=Count;
  while NextDownIndexBitFilter(i, LongInt([AnEvent])) do
    TSynPaintEventProc(FItems[i].FHandler)(Sender, AnEvent, rcClip);
end;

{ TSynScrollEventHandlerList}

procedure TSynScrollEventHandlerList.Add(AHandler: TSynScrollEventProc;
  Changes: TSynScrollEvents);
begin
  AddBitFilter(TMethod(AHandler), LongInt(Changes));
end;

procedure TSynScrollEventHandlerList.Remove(AHandler: TSynScrollEventProc);
begin
  inherited Remove(TMethod(AHandler));
end;

procedure TSynScrollEventHandlerList.CallScrollEventHandlers(Sender: TObject;
  AnEvent: TSynScrollEvent; dx, dy: Integer; const rcScroll, rcClip: TRect);
var
  i: Integer;
begin
  i:=Count;
  while NextDownIndexBitFilter(i, LongInt([AnEvent])) do
    TSynScrollEventProc(FItems[i].FHandler)(Sender, AnEvent, dx, dy, rcScroll, rcClip);
end;

{ TSynQueryMouseCursorList }

procedure TSynQueryMouseCursorList.Add(AHandler: TSynQueryMouseCursorEvent);
begin
  inherited Add(TMethod(AHandler));
end;

procedure TSynQueryMouseCursorList.Remove(AHandler: TSynQueryMouseCursorEvent);
begin
  inherited Remove(TMethod(AHandler));
end;

procedure TSynQueryMouseCursorList.CallScrollEventHandlers(Sender: TObject;
  const AMouseLocation: TSynMouseLocationInfo; var AnCursor: TCursor);
var
  i, p: Integer;
  c: TObject;
begin
  p := 0;
  c := nil;
  i:=Count;
  while NextDownIndex(i) do
    TSynQueryMouseCursorEvent(Items[i])(Sender, AMouseLocation, AnCursor, p, c);
end;

{ TSynEditMarkListInternal }

function TSynEditMarkListInternal.GetLinesView: TSynEditStringsLinked;
begin
  Result := FLines;
end;

procedure TSynEditMarkListInternal.SetLinesView(
  const AValue: TSynEditStringsLinked);
begin
  FLines.RemoveEditHandler(@DoLinesEdited);
  FLines := AValue;
  FLines.AddEditHandler(@DoLinesEdited);
end;

procedure TSynEditMarkListInternal.AddOwnerEdit(AEdit: TSynEditBase);
begin
  FOwnerList.Add(AEdit);
end;

procedure TSynEditMarkListInternal.RemoveOwnerEdit(AEdit: TSynEditBase);
begin
  FOwnerList.Remove(AEdit);
end;

initialization
  InitSynDefaultFont;
  Register;

  LOG_SynMouseEvents := DebugLogger.RegisterLogGroup('SynMouseEvents' {$IFDEF SynMouseEvents} , True {$ENDIF} );

end.
