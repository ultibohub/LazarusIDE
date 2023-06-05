{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

-------------------------------------------------------------------------------}

(* Naming Conventions:
  Byte = Logical: Refers to the location any TextToken has in the String.
         In Utf8String some TextToken can have more than one byte
  Char = Physical: Refers to the (x-)location on the screen matrix.
         Some TextToken (like tab) can spawn multiply char locations
*)

unit SynEditPointClasses;

{$I synedit.inc}

{off $DEFINE SynCaretDebug}
{off $DEFINE SynCaretHideInSroll} // Old behaviour, before Lazarus 2.1 / Aug 2019

interface

uses
  {$IFDEF windows}
  windows,
  {$ENDIF}
  Classes, SysUtils,
  // LCL
  Controls, LCLProc, LCLType, LCLIntf, ExtCtrls, Graphics, Forms,
  {$IFDEF SYN_MBCSSUPPORT}
  Imm,
  {$ENDIF}
  // LazUtils
  LazMethodList,
  // SynEdit
  LazSynEditText, SynEditTypes, SynEditMiscProcs;

type

  TInvalidateLines = procedure(FirstLine, LastLine: integer) of Object;
  TLinesCountChanged = procedure(FirstLine, Count: integer) of Object;
  TMaxLeftCharFunc = function: Integer of object;

  { TSynEditPointBase }

  TSynEditPointBase = class
  private
    function GetLocked: Boolean;
  protected
    FLines: TSynEditStringsLinked;
    FOnChangeList: TMethodList;
    FLockCount: Integer;
    procedure SetLines(const AValue: TSynEditStringsLinked); virtual;
    procedure DoLock; virtual;
    Procedure DoUnlock; virtual;
  public
    constructor Create;
    constructor Create(Lines: TSynEditStringsLinked);
    destructor Destroy; override;
    procedure AddChangeHandler(AHandler: TNotifyEvent);
    procedure RemoveChangeHandler(AHandler: TNotifyEvent);
    procedure Lock;
    Procedure Unlock;
    property  Lines: TSynEditStringsLinked read FLines write SetLines;
    property Locked: Boolean read GetLocked;
  end;

  TSynEditBaseCaret = class;
  TSynEditCaret = class;

  TSynBlockPersistMode = (
    sbpDefault,
    sbpWeak,     // selstart/end are treated as outside the block
    sbpStrong    // selstart/end are treated as inside the block
  );

  TSynBeforeSetSelTextEvent = procedure(Sender: TObject; AMode: TSynSelectionMode; ANewText: PChar) of object;

  { TSynBeforeSetSelTextList }

  TSynBeforeSetSelTextList = Class(TMethodList)
  public
    procedure CallBeforeSetSelTextHandlers(Sender: TObject; AMode: TSynSelectionMode; ANewText: PChar);
  end;

  { TSynEditSelection }

  TSynEditSelection = class(TSynEditPointBase)
  private
    FOnBeforeSetSelText: TSynBeforeSetSelTextList;
    FAutoExtend: Boolean;
    FCaret: TSynEditCaret;
    FHide: Boolean;
    FInternalCaret: TSynEditBaseCaret;
    FInvalidateLinesMethod: TInvalidateLines;
    FEnabled: Boolean;
    FHookedLines: Boolean;
    FIsSettingText: Boolean;
    FForceSingleLineSelected: Boolean;
    FActiveSelectionMode: TSynSelectionMode;
    FSelectionMode:       TSynSelectionMode;
    FStartLinePos: Integer; // 1 based
    FStartBytePos: Integer; // 1 based
    FAltStartLinePos, FAltStartBytePos: Integer; // 1 based // Alternate, for min selection
    FEndLinePos: Integer; // 1 based
    FEndBytePos: Integer; // 1 based
    FViewedFirstStartLineCharPos: TPoint; // 1 based
    FViewedLastEndLineCharPos: TPoint; // 1 based
    FFLags: set of (sbViewedFirstPosValid, sbViewedLastPosValid, sbHasLineMapHandler);
    FLeftCharPos: Integer;
    FRightCharPos: Integer;
    FPersistent: Boolean;
    FPersistentLock, FWeakPersistentIdx, FStrongPersistentIdx: Integer;
    FIgnoreNextCaretMove: Boolean;
    (* On any modification, remember the position of the caret.
       If it gets moved from there to either end of the block, this should be ignored
       This happens, if Block and caret are adjusted directly
    *)
    FLastCarePos: TPoint;
    FStickyAutoExtend: Boolean;
    function  AdjustBytePosToCharacterStart(Line: integer; BytePos: integer): integer;
    procedure DoLinesMappingChanged(Sender: TSynEditStrings; aIndex,
      aCount: Integer);
    function GetColumnEndBytePos(ALinePos: Integer): integer;
    function GetColumnStartBytePos(ALinePos: Integer): integer;
    function  GetFirstLineBytePos: TPoint;
    function  GetLastLineBytePos: TPoint;
    function GetLastLineHasSelection: Boolean;
    function GetColumnLeftCharPos: Integer;
    function GetColumnRightCharPos: Integer;
    function GetViewedFirstLineCharPos: TPoint;
    function GetViewedLastLineCharPos: TPoint;
    procedure SetAutoExtend(AValue: Boolean);
    procedure SetCaret(const AValue: TSynEditCaret);
    procedure SetEnabled(const Value : Boolean);
    procedure SetActiveSelectionMode(const Value: TSynSelectionMode);
    procedure SetForceSingleLineSelected(AValue: Boolean);
    procedure SetHide(const AValue: Boolean);
    procedure SetPersistent(const AValue: Boolean);
    procedure SetSelectionMode      (const AValue: TSynSelectionMode);
    function  GetStartLineBytePos: TPoint;
    procedure ConstrainStartLineBytePos(var Value: TPoint);
    procedure SetStartLineBytePos(Value: TPoint);
    procedure AdjustStartLineBytePos(Value: TPoint);
    function  GetEndLineBytePos: TPoint;
    procedure SetEndLineBytePos(Value: TPoint);
    function  GetSelText: string;
    procedure SetSelText(const Value: string);
    procedure DoCaretChanged(Sender: TObject);
    procedure AdjustAfterTrimming; // TODO: Move into TrimView?
  protected
    procedure DoLock; override;
    procedure DoUnlock; override;
    Procedure LineChanged(Sender: TSynEditStrings; AIndex, ACount : Integer);
    procedure DoLinesEdited(Sender: TSynEditStrings; aLinePos, aBytePos, aCount,
                            aLineBrkCnt: Integer; aText: String);
  public
    constructor Create(ALines: TSynEditStringsLinked; aActOnLineChanges: Boolean);
    destructor Destroy; override;
    procedure AssignFrom(Src: TSynEditSelection);
    procedure SetSelTextPrimitive(PasteMode: TSynSelectionMode; Value: PChar; AReplace: Boolean = False; ASetTextSelected: Boolean = False);
    function  SelAvail: Boolean;
    function  SelCanContinue(ACaret: TSynEditCaret): Boolean;
    function  IsBackwardSel: Boolean; // SelStart < SelEnd ?
    procedure BeginMinimumSelection; // current selection will be minimum while follow caret (autoExtend) // until next setSelStart or end of follow
    procedure SortSelectionPoints(AReverse: Boolean = False);
    procedure IgnoreNextCaretMove;
    // Mode can NOT be changed in nested calls
    procedure IncPersistentLock(AMode: TSynBlockPersistMode = sbpDefault); // Weak: Do not extend (but rather move) block, if at start/end
    procedure DecPersistentLock;
    procedure Clear;
    procedure AddBeforeSetSelTextHandler(AHandler: TSynBeforeSetSelTextEvent);
    procedure RemoveBeforeSetSelTextHandler(AHandler: TSynBeforeSetSelTextEvent);
    property  Enabled: Boolean read FEnabled write SetEnabled;
    property  ForceSingleLineSelected: Boolean read FForceSingleLineSelected write SetForceSingleLineSelected;
    property  ActiveSelectionMode: TSynSelectionMode
                read FActiveSelectionMode write SetActiveSelectionMode;
    property  SelectionMode: TSynSelectionMode
                read FSelectionMode write SetSelectionMode;
    property  SelText: String read GetSelText write SetSelText;
    // Start and End positions are in the order they where defined
    // This may mean Startpos is behind EndPos in the text
    property  StartLineBytePos: TPoint
                read GetStartLineBytePos write SetStartLineBytePos;
    property  StartLineBytePosAdjusted: TPoint
                 write AdjustStartLineBytePos;
    property  EndLineBytePos: TPoint
                read GetEndLineBytePos write SetEndLineBytePos;
    property  StartLinePos: Integer read FStartLinePos;
    property  EndLinePos: Integer read FEndLinePos;
    property  StartBytePos: Integer read FStartBytePos;
    property  EndBytePos: Integer read FEndBytePos;
    // First and Last Pos are ordered according to the text flow (LTR)
    property  FirstLineBytePos: TPoint read GetFirstLineBytePos;
    property  LastLineBytePos: TPoint read GetLastLineBytePos;
    property  ViewedFirstLineCharPos: TPoint read GetViewedFirstLineCharPos;
    property  ViewedLastLineCharPos: TPoint read GetViewedLastLineCharPos;
    // For column mode selection: Phys-Char pos of left and right side. (Start/End could each be either left or right)
    property  ColumnLeftCharPos: Integer read GetColumnLeftCharPos;
    property  ColumnRightCharPos: Integer read GetColumnRightCharPos;
    property  ColumnStartBytePos[ALinePos: Integer]: integer read GetColumnStartBytePos;
    property  ColumnEndBytePos[ALinePos: Integer]: integer read GetColumnEndBytePos;
    //
    property  LastLineHasSelection: Boolean read GetLastLineHasSelection;
    property  InvalidateLinesMethod : TInvalidateLines write FInvalidateLinesMethod;
    property  Caret: TSynEditCaret read FCaret write SetCaret;
    property  Persistent: Boolean read FPersistent write SetPersistent;
    // automatically Start/Extend selection if caret moves
    // (depends if caret was at block border or not)
    property  AutoExtend: Boolean read FAutoExtend write SetAutoExtend;
    property  StickyAutoExtend: Boolean read FStickyAutoExtend write FStickyAutoExtend;
    property  Hide: Boolean read FHide write SetHide;
  end;

  { TSynEditCaret }

  TSynEditCaretFlag = (
      // TSynEditBaseCaret
      scCharPosValid, scBytePosValid, scViewedPosValid,
      scHasLineMapHandler,
      // TSynEditCaret
      scfUpdateLastCaretX
    );
  TSynEditCaretFlags = set of TSynEditCaretFlag;

  TSynEditCaretUpdateFlag = (
      scuForceSet,                // Change even if equal to old
      scuChangedX, scuChangedY,   //
      scuNoInvalidate             // Keep the Char/Byte ValidFlags
    );
  TSynEditCaretUpdateFlags = set of TSynEditCaretUpdateFlag;


  { TSynEditBaseCaret
    No Checks at all.
    Caller MUST ensure at least not to set x to invalid pos (middle of char) (incl update x, after SetLine)
  }

  TSynEditBaseCaret = class(TSynEditPointBase)
  private
    FLinePos: Integer;     // 1 based
    FCharPos: Integer;     // 1 based
    FBytePos, FBytePosOffset: Integer;     // 1 based
    FViewedLineCharPos: TPoint;

    procedure DoLinesMappingChanged(Sender: TSynEditStrings; aIndex,
      aCount: Integer);
    function  GetBytePos: Integer;
    function  GetBytePosOffset: Integer;
    function  GetCharPos: Integer;
    function GetFullLogicalPos: TLogCaretPoint;
    function  GetLineBytePos: TPoint;
    function  GetLineCharPos: TPoint;
    function  GetViewedLineCharPos: TPoint;
    function  GetViewedLinePos: TLinePos;
    procedure SetBytePos(AValue: Integer);
    procedure SetBytePosOffset(AValue: Integer);
    procedure SetCharPos(AValue: Integer);
    procedure SetFullLogicalPos(AValue: TLogCaretPoint);
    procedure SetLineBytePos(AValue: TPoint);
    procedure SetLineCharPos(AValue: TPoint);
    procedure SetLinePos(AValue: Integer);

    function  GetLineText: string;
    procedure SetLineText(AValue: string);
    procedure SetViewedLineCharPos(AValue: TPoint);
    procedure SetViewedLinePos(AValue: TLinePos);
  protected
    FFlags: TSynEditCaretFlags;
    procedure ValidateBytePos;
    procedure ValidateCharPos;
    procedure ValidateViewedPos;

    procedure InternalEmptyLinesSetPos(NewCharPos: Integer; UpdFlags: TSynEditCaretUpdateFlags); virtual;
    procedure InternalSetLineCharPos(NewLine, NewCharPos: Integer;
                                     UpdFlags: TSynEditCaretUpdateFlags); virtual;
    procedure InternalSetLineByterPos(NewLine, NewBytePos, NewByteOffs: Integer;
                                     UpdFlags: TSynEditCaretUpdateFlags); virtual;
    procedure InternalSetViewedPos(NewLine, NewCharPos: Integer;
                                     UpdFlags: TSynEditCaretUpdateFlags); virtual;
  public
    constructor Create;
    procedure AssignFrom(Src: TSynEditBaseCaret);
    procedure Invalidate; // force to 1,1
    procedure InvalidateBytePos; // 1,1 IF no validCharPos
    procedure InvalidateCharPos;

    function IsAtLineChar(aPoint: TPoint): Boolean;
    function IsAtLineByte(aPoint: TPoint; aByteOffset: Integer = -1): Boolean;
    function IsAtPos(aCaret: TSynEditCaret): Boolean;

    property LinePos: Integer read FLinePos write SetLinePos;
    property CharPos: Integer read GetCharPos write SetCharPos;
    property LineCharPos: TPoint read GetLineCharPos write SetLineCharPos;
    property BytePos: Integer read GetBytePos write SetBytePos;
    property BytePosOffset: Integer read GetBytePosOffset write SetBytePosOffset;
    property LineBytePos: TPoint read GetLineBytePos write SetLineBytePos;
    property FullLogicalPos: TLogCaretPoint read GetFullLogicalPos write SetFullLogicalPos;
    property ViewedLineCharPos: TPoint read GetViewedLineCharPos write SetViewedLineCharPos;
    property ViewedLinePos: TLinePos read GetViewedLinePos write SetViewedLinePos;

    property LineText: string read GetLineText write SetLineText;
  end;

  { TSynEditCaret }

  TSynEditCaret = class(TSynEditBaseCaret)
  private
    FLinesEditedRegistered: Boolean;
    FAllowPastEOL: Boolean;
    FAutoMoveOnEdit: Integer;
    FForcePastEOL: Integer;
    FForceAdjustToNextChar: Integer;
    FKeepCaretX: Boolean;
    FLastCharPos, FLastViewedCharPos: Integer; // used by KeepCaretX

    FOldLinePos: Integer; // 1 based
    FOldCharPos: Integer; // 1 based

    FAdjustToNextChar: Boolean;
    FMaxLeftChar: TMaxLeftCharFunc;
    FChangeOnTouch: Boolean;
    FSkipTabs: Boolean;
    FTouched: Boolean;

    procedure AdjustToChar;
    function GetMaxLeftPastEOL: Integer;

    function  GetOldLineCharPos: TPoint;
    function  GetOldLineBytePos: TPoint;
    function  GetOldFullLogicalPos: TLogCaretPoint;

    procedure SetAllowPastEOL(const AValue: Boolean);
    procedure SetSkipTabs(const AValue: Boolean);
    procedure SetKeepCaretX(const AValue: Boolean);
    procedure UpdateLastCaretX;

    procedure RegisterLinesEditedHandler;
  protected
    procedure InternalEmptyLinesSetPos(NewCharPos: Integer; UpdFlags: TSynEditCaretUpdateFlags); override;
    procedure InternalSetLineCharPos(NewLine, NewCharPos: Integer;
                                     UpdFlags: TSynEditCaretUpdateFlags); override;
    procedure InternalSetLineByterPos(NewLine, NewBytePos, NewByteOffs: Integer;
                                     UpdFlags: TSynEditCaretUpdateFlags); override;
    procedure InternalSetViewedPos(NewLine, NewCharPos: Integer;
      UpdFlags: TSynEditCaretUpdateFlags); override;

    procedure DoLock; override;
    Procedure DoUnlock; override;
    procedure SetLines(const AValue: TSynEditStringsLinked); override;
    procedure DoLinesEdited(Sender: TSynEditStrings; aLinePos, aBytePos, aCount,
                            aLineBrkCnt: Integer; aText: String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AssignFrom(Src: TSynEditBaseCaret);

    procedure IncForcePastEOL;
    procedure DecForcePastEOL;
    procedure IncForceAdjustToNextChar;
    procedure DecForceAdjustToNextChar;
    procedure IncAutoMoveOnEdit;
    procedure DecAutoMoveOnEdit;
    procedure ChangeOnTouch;
    procedure Touch(aChangeOnTouch: Boolean = False);

    function WasAtLineChar(aPoint: TPoint): Boolean;
    function WasAtLineByte(aPoint: TPoint): Boolean;
    function MoveHoriz(ACount: Integer): Boolean; // Logical // False, if past EOL (not mowed)/BOl

    property OldLinePos: Integer read FOldLinePos;
    property OldCharPos: Integer read FOldCharPos;
    property OldLineCharPos: TPoint read GetOldLineCharPos;
    property OldLineBytePos: TPoint read GetOldLineBytePos;
    property OldFullLogicalPos: TLogCaretPoint read GetOldFullLogicalPos;

    property AdjustToNextChar: Boolean read FAdjustToNextChar write FAdjustToNextChar; deprecated;
    property SkipTabs: Boolean read FSkipTabs write SetSkipTabs;
    property AllowPastEOL: Boolean read FAllowPastEOL write SetAllowPastEOL;
    property KeepCaretX: Boolean read FKeepCaretX write SetKeepCaretX;
    property KeepCaretXPos: Integer read FLastCharPos write FLastCharPos;
    property MaxLeftChar: TMaxLeftCharFunc read FMaxLeftChar write FMaxLeftChar;
  end;

  TSynCaretType = (ctVerticalLine, ctHorizontalLine, ctHalfBlock, ctBlock, ctCostum);
  TSynCaretLockFlags = set of (sclfUpdateDisplay, sclfUpdateDisplayType);

  { TSynEditScreenCaretTimer
    Allow sync between carets which use an internal painter
  }

  TSynEditScreenCaretTimer = class
  private
    FDisplayCycle: Boolean;
    FTimerEnabled: Boolean;
    FTimer: TTimer;
    FTimerList: TMethodList;
    FAfterPaintList: TMethodList;
    FLocCount: Integer;
    FLocFlags: set of (lfTimer, lfRestart);
    procedure DoTimer(Sender: TObject);
    procedure DoAfterPaint(Data: PtrInt);
    function GetInterval: Integer;
    procedure SetInterval(AValue: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddAfterPaintHandler(AHandler: TNotifyEvent); // called once
    procedure AddHandler(AHandler: TNotifyEvent);
    procedure RemoveHandler(AHandler: TNotifyEvent);
    procedure RemoveHandler(AHandlerOwner: TObject);
    procedure IncLock;
    procedure DecLock;
    procedure AfterPaintEvent;
    procedure ResetInterval;

    procedure RestartCycle;
    property DisplayCycle: Boolean read FDisplayCycle;
    property Interval: Integer read GetInterval write SetInterval;
  end;

  TSynEditScreenCaret = class;

  { TSynEditScreenCaretPainter }

  TSynEditScreenCaretPainter = class
  private
    FLeft, FTop, FHeight, FWidth: Integer;
    FCreated, FShowing: Boolean;
    FInPaint, FInScroll: Boolean;
    FPaintClip: TRect;
    FScrollX, FScrollY: Integer;
    FScrollRect, FScrollClip: TRect;

    function GetHandle: HWND;
    function GetHandleAllocated: Boolean;
  protected
    FHandleOwner: TWinControl;
    FOwner: TSynEditScreenCaret;
    FNeedPositionConfirmed: boolean;
    procedure Init; virtual;
    property Handle: HWND read GetHandle;
    property HandleAllocated: Boolean read GetHandleAllocated;

    procedure BeginScroll(dx, dy: Integer; const rcScroll, rcClip: TRect); virtual;
    procedure FinishScroll(dx, dy: Integer; const rcScroll, rcClip: TRect; Success: Boolean); virtual;
    procedure BeginPaint(rcClip: TRect); virtual;
    procedure FinishPaint(rcClip: TRect); virtual;
    procedure WaitForPaint; virtual;
  public
    constructor Create(AHandleOwner: TWinControl; AOwner: TSynEditScreenCaret);
    function CreateCaret(w, h: Integer): Boolean; virtual;
    function DestroyCaret: Boolean; virtual;
    function HideCaret: Boolean; virtual;
    function ShowCaret: Boolean; virtual;
    function SetCaretPosEx(x, y: Integer): Boolean; virtual;

    property Left: Integer read FLeft;
    property Top: Integer read FTop;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Created: Boolean read FCreated;
    property Showing: Boolean read FShowing;
    property InPaint: Boolean read FInPaint;
    property InScroll: Boolean read FInScroll;
    property NeedPositionConfirmed: boolean read FNeedPositionConfirmed;
  end;

  TSynEditScreenCaretPainterClass = class of TSynEditScreenCaretPainter;

  { TSynEditScreenCaretPainterSystem }

  TSynEditScreenCaretPainterSystem = class(TSynEditScreenCaretPainter)
  protected
    procedure BeginScroll(dx, dy: Integer; const rcScroll, rcClip: TRect); override;
    procedure FinishScroll(dx, dy: Integer; const rcScroll, rcClip: TRect; Success: Boolean); override;
    procedure BeginPaint(rcClip: TRect); override;
    //procedure FinishPaint(rcClip: TRect); override; // unhide, currently done by editor
  public
    function CreateCaret(w, h: Integer): Boolean; override;
    function DestroyCaret: Boolean; override;
    function HideCaret: Boolean; override;
    function ShowCaret: Boolean; override;
    function SetCaretPosEx(x, y: Integer): Boolean; override;
  end;

  { TSynEditScreenCaretPainterInternal }

  TSynEditScreenCaretPainterInternal = class(TSynEditScreenCaretPainter)
  private type
    TIsInRectState = (irInside, irPartInside, irOutside);
    TPainterState = (psAfterPaintAdded, psCleanOld, psRemoveTimer);
    TPainterStates = set of TPainterState;
  private
    FColor: TColor;
    FForcePaintEvents: Boolean;
    FIsDrawn: Boolean;
    FSavePen: TPen;
    FOldX, FOldY, FOldW, FOldH: Integer;
    FState: TPainterStates;
    FCanPaint: Boolean;
    FInRect: TIsInRectState;
    FWaitForPaint: Boolean;

    function dbgsIRState(s: TIsInRectState): String;
    procedure DoTimer(Sender: TObject);
    procedure DoPaint(ACanvas: TCanvas; X, Y, H, W: Integer);
    procedure Paint;
    procedure Invalidate;
    procedure AddAfterPaint(AStates: TPainterStates = []);
    procedure DoAfterPaint(Sender: TObject);
    procedure ExecAfterPaint;
    function CurrentCanvas: TCanvas;
    procedure SetColor(AValue: TColor);
    function IsInRect(ARect: TRect): TIsInRectState;
    function IsInRect(ARect: TRect; X, Y, W, H: Integer): TIsInRectState;
  protected
    procedure Init; override;

    procedure BeginScroll(dx, dy: Integer; const rcScroll, rcClip: TRect); override;
    procedure FinishScroll(dx, dy: Integer; const rcScroll, rcClip: TRect; Success: Boolean); override;
    procedure BeginPaint(rcClip: TRect); override;
    procedure FinishPaint(rcClip: TRect); override;
    procedure WaitForPaint; override;
  public
    destructor Destroy; override;
    function CreateCaret(w, h: Integer): Boolean; override;
    function DestroyCaret: Boolean; override;
    function HideCaret: Boolean; override;
    function ShowCaret: Boolean; override;
    function SetCaretPosEx(x, y: Integer): Boolean; override;
    property Color: TColor read FColor write SetColor;
    property ForcePaintEvents: Boolean read FForcePaintEvents write FForcePaintEvents;
  end;

  // relative dimensions in percent from 0 to 1024 (=100%)
  TSynCustomCaretSizeFlag = (ccsRelativeLeft, ccsRelativeTop, ccsRelativeWidth, ccsRelativeHeight);
  TSynCustomCaretSizeFlags = set of TSynCustomCaretSizeFlag;

  { TSynEditScreenCaret }

  TSynEditScreenCaret = class
  private
    FCharHeight: Integer;
    FCharWidth: Integer;
    FClipRight: Integer;
    FClipBottom: Integer;
    FClipLeft: Integer;
    FClipTop: Integer;
    FDisplayPos: TPoint;
    FDisplayType: TSynCaretType;
    FExtraLinePixel, FExtraLineChars: Integer;
    FOnExtraLineCharsChanged: TNotifyEvent;
    FVisible: Boolean;
    FHandleOwner: TWinControl;
    FCaretPainter: TSynEditScreenCaretPainter;
    FPaintTimer: TSynEditScreenCaretTimer;
    FPaintTimerOwned: Boolean;
    function GetHandle: HWND;
    function GetHandleAllocated: Boolean;
    procedure SetCharHeight(const AValue: Integer);
    procedure SetCharWidth(const AValue: Integer);
    procedure SetClipRight(const AValue: Integer);
    procedure SetDisplayPos(const AValue: TPoint);
    procedure SetDisplayType(const AType: TSynCaretType);
    procedure SetVisible(const AValue: Boolean);
  private
    FClipExtraPixel: Integer;
    {$IFDeF SynCaretDebug}
    FDebugShowCount: Integer;
    {$ENDIF}
    FPixelWidth, FPixelHeight: Integer;
    FOffsetX, FOffsetY: Integer;
    FCustomPixelWidth, FCustomPixelHeight: Array [TSynCaretType] of Integer;
    FCustomOffsetX, FCustomOffsetY: Array [TSynCaretType] of Integer;
    FCustomFlags: Array [TSynCaretType] of TSynCustomCaretSizeFlags;
    FLockCount: Integer;
    FLockFlags: TSynCaretLockFlags;
    function GetHasPaintTimer: Boolean;
    function GetPaintTimer: TSynEditScreenCaretTimer;
    procedure SetClipBottom(const AValue: Integer);
    procedure SetClipExtraPixel(AValue: Integer);
    procedure SetClipLeft(const AValue: Integer);
    procedure SetClipRect(const AValue: TRect);
    procedure SetClipTop(const AValue: Integer);
    procedure CalcExtraLineChars;
    procedure SetPaintTimer(AValue: TSynEditScreenCaretTimer);
    procedure UpdateDisplayType;
    procedure UpdateDisplay;
    function  ClippedPixelHeihgh(var APxTop: Integer): Integer; inline;
    procedure ShowCaret;
    procedure HideCaret;
    property HandleAllocated: Boolean read GetHandleAllocated;
  protected
    property Handle: HWND read GetHandle;
  public
    constructor Create(AHandleOwner: TWinControl);
    constructor Create(AHandleOwner: TWinControl; APainterClass: TSynEditScreenCaretPainterClass);
    procedure ChangePainter(APainterClass: TSynEditScreenCaretPainterClass);
    destructor Destroy; override;

    procedure BeginScroll(dx, dy: Integer; const rcScroll, rcClip: TRect);
    procedure FinishScroll(dx, dy: Integer; const rcScroll, rcClip: TRect; Success: Boolean);
    procedure BeginPaint(rcClip: TRect);
    procedure FinishPaint(rcClip: TRect);
    procedure WaitForPaint;
    procedure Lock;
    procedure UnLock;
    procedure AfterPaintEvent;  // next async

    procedure  Hide; // Keep visible = true
    procedure  DestroyCaret(SkipHide: boolean = False);
    procedure ResetCaretTypeSizes;
    procedure SetCaretTypeSize(AType: TSynCaretType; AWidth, AHeight, AXOffs, AYOffs: Integer;
                               AFlags: TSynCustomCaretSizeFlags = []);
    property HandleOwner: TWinControl read FHandleOwner;
    property PaintTimer: TSynEditScreenCaretTimer read GetPaintTimer write SetPaintTimer;
    property HasPaintTimer: Boolean read GetHasPaintTimer;
    property Painter: TSynEditScreenCaretPainter read FCaretPainter;
    property CharWidth:   Integer read FCharWidth write SetCharWidth;
    property CharHeight:  Integer read FCharHeight write SetCharHeight;
    property ClipLeft:    Integer read FClipLeft write SetClipLeft;
    property ClipRight:   Integer read FClipRight write SetClipRight;           // First pixel outside the allowed area
    property ClipTop:     Integer read FClipTop write SetClipTop;
    property ClipRect:    TRect write SetClipRect;
    property ClipBottom:  Integer read FClipBottom write SetClipBottom;
    property ClipExtraPixel: Integer read FClipExtraPixel write SetClipExtraPixel; // Amount of pixels, after  the last full char (half visible char width)
    property Visible:     Boolean read FVisible write SetVisible;
    property DisplayType: TSynCaretType read FDisplayType write SetDisplayType;
    property DisplayPos:  TPoint  read FDisplayPos write SetDisplayPos;
    property ExtraLineChars: Integer read FExtraLineChars; // Extend the longest line by x chars
    property OnExtraLineCharsChanged: TNotifyEvent
             read FOnExtraLineCharsChanged write FOnExtraLineCharsChanged;
  end;

implementation

{ TSynBeforeSetSelTextList }

procedure TSynBeforeSetSelTextList.CallBeforeSetSelTextHandlers(Sender: TObject;
  AMode: TSynSelectionMode; ANewText: PChar);
var
  i: Integer;
begin
  i:=Count;
  while NextDownIndex(i) do
    TSynBeforeSetSelTextEvent(Items[i])(Sender, AMode, ANewText);
end;

{ TSynEditBaseCaret }

function TSynEditBaseCaret.GetBytePos: Integer;
begin
  ValidateBytePos;
  Result := FBytePos;
end;

procedure TSynEditBaseCaret.DoLinesMappingChanged(Sender: TSynEditStrings;
  aIndex, aCount: Integer);
begin
  Exclude(FFlags, scViewedPosValid);
end;

function TSynEditBaseCaret.GetBytePosOffset: Integer;
begin
  ValidateBytePos;
  Result := FBytePosOffset;
end;

function TSynEditBaseCaret.GetCharPos: Integer;
begin
  ValidateCharPos;
  Result := FCharPos;
end;

function TSynEditBaseCaret.GetFullLogicalPos: TLogCaretPoint;
begin
  ValidateBytePos;
  Result.Y := FLinePos;
  Result.X := FBytePos;
  Result.Offs := FBytePosOffset;
end;

function TSynEditBaseCaret.GetLineBytePos: TPoint;
begin
  ValidateBytePos;
  Result := Point(FBytePos, FLinePos);
end;

function TSynEditBaseCaret.GetLineCharPos: TPoint;
begin
  ValidateCharPos;
  Result := Point(FCharPos, FLinePos);
end;

function TSynEditBaseCaret.GetViewedLineCharPos: TPoint;
begin
  ValidateViewedPos;
  Result := FViewedLineCharPos;
end;

function TSynEditBaseCaret.GetViewedLinePos: TLinePos;
begin
  Result := ViewedLineCharPos.y;
end;

procedure TSynEditBaseCaret.SetBytePos(AValue: Integer);
begin
  InternalSetLineByterPos(FLinePos, AValue, 0, [scuChangedX]);
end;

procedure TSynEditBaseCaret.SetBytePosOffset(AValue: Integer);
begin
  ValidateBytePos;
  InternalSetLineByterPos(FLinePos, FBytePos, AValue, [scuChangedX]);
end;

procedure TSynEditBaseCaret.SetCharPos(AValue: Integer);
begin
  InternalSetLineCharPos(FLinePos, AValue, [scuChangedX]);
end;

procedure TSynEditBaseCaret.SetFullLogicalPos(AValue: TLogCaretPoint);
begin
  InternalSetLineByterPos(AValue.y, AValue.x, AValue.Offs, [scuChangedX, scuChangedY]);
end;

procedure TSynEditBaseCaret.SetLineBytePos(AValue: TPoint);
begin
  InternalSetLineByterPos(AValue.y, AValue.x, 0, [scuChangedX, scuChangedY]);
end;

procedure TSynEditBaseCaret.SetLineCharPos(AValue: TPoint);
begin
  InternalSetLineCharPos(AValue.y, AValue.X, [scuChangedX, scuChangedY]);
end;

procedure TSynEditBaseCaret.SetLinePos(AValue: Integer);
begin
  // TODO: may temporary lead to invalid x bytepos. Must be adjusted *before* calculating char
  //if scBytePosValid in FFlags then
  //  InternalSetLineByterPos(AValue, FBytePos, FBytePosOffset, [scuChangedY])
  //else
    ValidateCharPos;
    InternalSetLineCharPos(AValue, FCharPos, [scuChangedY]);
end;

function TSynEditBaseCaret.GetLineText: string;
begin
  if (LinePos >= 1) and (LinePos <= FLines.Count) then
    Result := FLines[LinePos - 1]
  else
    Result := '';
end;

procedure TSynEditBaseCaret.SetLineText(AValue: string);
begin
  if (LinePos >= 1) and (LinePos <= Max(1, FLines.Count)) then
    FLines[LinePos - 1] := AValue;
end;

procedure TSynEditBaseCaret.SetViewedLineCharPos(AValue: TPoint);
begin
  InternalSetViewedPos(AValue.y, AValue.x, [scuChangedX, scuChangedY]);
end;

procedure TSynEditBaseCaret.SetViewedLinePos(AValue: TLinePos);
begin
  ValidateViewedPos;
  InternalSetViewedPos(AValue, FViewedLineCharPos.x, [scuChangedY]);
end;

procedure TSynEditBaseCaret.ValidateBytePos;
begin
  if scBytePosValid in FFlags then
    exit;
  ValidateCharPos;
  assert(scCharPosValid in FFlags, 'ValidateBytePos: no charpos set');
  Include(FFlags, scBytePosValid);
  FBytePos := FLines.LogPhysConvertor.PhysicalToLogical(FLinePos-1, FCharPos, FBytePosOffset);
end;

procedure TSynEditBaseCaret.ValidateCharPos;
var
  p: TPhysPoint;
begin
  if scCharPosValid in FFlags then
    exit;

  if not(scBytePosValid in FFlags) then begin
    assert(scViewedPosValid in FFlags, 'ValidateCharPos: no viewedpos set');
    Include(FFlags, scCharPosValid);
    p := Lines.ViewXYToTextXY(FViewedLineCharPos);
    FCharPos := p.x;
    FLinePos := p.y;
    exit;
  end;

  assert(scBytePosValid in FFlags, 'ValidateCharPos: no bytepos set');
  Include(FFlags, scCharPosValid);
  FCharPos := FLines.LogPhysConvertor.LogicalToPhysical(FLinePos-1, FBytePos, FBytePosOffset);
end;

procedure TSynEditBaseCaret.ValidateViewedPos;
begin
  if scViewedPosValid in FFlags then
    exit;

  include(FFlags, scViewedPosValid);
  FViewedLineCharPos := Lines.TextXYToViewXY(LineCharPos);

  if not(scHasLineMapHandler in FFlags) then begin
    Lines.AddChangeHandler(senrLineMappingChanged, @DoLinesMappingChanged);
    Include(FFlags, scHasLineMapHandler);
  end;
end;

procedure TSynEditBaseCaret.InternalEmptyLinesSetPos(NewCharPos: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
begin
  if NewCharPos < 1 then
    NewCharPos := 1;

  FLinePos := 1;
  FBytePos := NewCharPos;
  FCharPos := NewCharPos;
  FViewedLineCharPos.y := 1;
  FViewedLineCharPos.x := NewCharPos;
  FFlags := FFlags + [scBytePosValid, scCharPosValid, scViewedPosValid];

  if not(scHasLineMapHandler in FFlags) then begin
    Lines.AddChangeHandler(senrLineMappingChanged, @DoLinesMappingChanged);
    Include(FFlags, scHasLineMapHandler);
  end;
end;

procedure TSynEditBaseCaret.InternalSetLineCharPos(NewLine, NewCharPos: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
begin
  if (fCharPos = NewCharPos) and (fLinePos = NewLine) and
     (scCharPosValid in FFlags) and not (scuForceSet in UpdFlags)
  then
    exit;

  if not (scuNoInvalidate in UpdFlags) then
    FFlags := FFlags - [scBytePosValid, scViewedPosValid];
  Include(FFlags, scCharPosValid);

  if NewLine < 1 then begin
    NewLine := 1;
    FFlags := FFlags - [scBytePosValid, scViewedPosValid];
  end;

  if NewCharPos < 1 then begin
    NewCharPos := 1;
    FFlags := FFlags - [scBytePosValid, scViewedPosValid];
  end;

  FCharPos := NewCharPos;
  FLinePos := NewLine;
end;

procedure TSynEditBaseCaret.InternalSetLineByterPos(NewLine, NewBytePos, NewByteOffs: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
begin
  if (FBytePos = NewBytePos) and (FBytePosOffset = NewByteOffs) and
     (FLinePos = NewLine) and (scBytePosValid in FFlags) and not (scuForceSet in UpdFlags)
  then
    exit;

  if not (scuNoInvalidate in UpdFlags) then
    FFlags := FFlags - [scCharPosValid, scViewedPosValid];
  Include(FFlags, scBytePosValid);

  if NewLine < 1 then begin
    NewLine := 1;
    FFlags := FFlags - [scCharPosValid, scViewedPosValid];
  end;

  if NewBytePos < 1 then begin
    NewBytePos := 1;
    FFlags := FFlags - [scCharPosValid, scViewedPosValid];
  end;

  FBytePos       := NewBytePos;
  FBytePosOffset := NewByteOffs;
  FLinePos       := NewLine;
end;

procedure TSynEditBaseCaret.InternalSetViewedPos(NewLine, NewCharPos: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
begin
  if (FViewedLineCharPos.x = NewCharPos) and (FViewedLineCharPos.y= NewLine) and
     (scViewedPosValid in FFlags) and not (scuForceSet in UpdFlags)
  then
    exit;

  if not (scuNoInvalidate in UpdFlags) then
    FFlags := FFlags - [scCharPosValid, scBytePosValid];
  Include(FFlags, scViewedPosValid);

  if NewLine < 1 then begin
    NewLine := 1;
    FFlags := FFlags - [scCharPosValid, scBytePosValid];
  end;

  if NewCharPos < 1 then begin
    NewCharPos := 1;
    FFlags := FFlags - [scCharPosValid, scBytePosValid];
  end;

  FViewedLineCharPos := Point(NewCharPos, NewLine);

  if not(scHasLineMapHandler in FFlags) then begin
    Lines.AddChangeHandler(senrLineMappingChanged, @DoLinesMappingChanged);
    Include(FFlags, scHasLineMapHandler);
  end;
end;

constructor TSynEditBaseCaret.Create;
begin
  inherited Create;
  fLinePos       := 1;
  fCharPos       := 1;
  FBytePos       := 1;
  FBytePosOffset := 0;
  FFlags := [scCharPosValid, scBytePosValid];
end;

procedure TSynEditBaseCaret.AssignFrom(Src: TSynEditBaseCaret);
begin
  FLinePos       := Src.FLinePos;
  FCharPos       := Src.FCharPos;
  FBytePos       := Src.FBytePos;
  FBytePosOffset := Src.FBytePosOffset;
  FFlags         := Src.FFlags;
  Exclude(FFlags, scViewedPosValid); // Or check that an senrLineMappingChanged handler exists
  SetLines(Src.FLines);
end;

procedure TSynEditBaseCaret.Invalidate;
begin
  FLinePos := 1;
  FCharPos := 1;
  FBytePos := 1;
  FFlags := [];
end;

procedure TSynEditBaseCaret.InvalidateBytePos;
begin
  if not (scCharPosValid in FFlags) then
    Invalidate
  else
    Exclude(FFlags, scBytePosValid);
end;

procedure TSynEditBaseCaret.InvalidateCharPos;
begin
  if not (scBytePosValid in FFlags) then
    Invalidate
  else
    FFlags := FFlags - [scCharPosValid, scViewedPosValid];
end;

function TSynEditBaseCaret.IsAtLineChar(aPoint: TPoint): Boolean;
begin
  ValidateCharPos;
  Result := (FLinePos = aPoint.y) and (FCharPos = aPoint.x);
end;

function TSynEditBaseCaret.IsAtLineByte(aPoint: TPoint; aByteOffset: Integer): Boolean;
begin
  ValidateBytePos;
  Result := (FLinePos = aPoint.y) and (BytePos = aPoint.x) and
            ( (aByteOffset < 0) or (FBytePosOffset = aByteOffset) );
end;

function TSynEditBaseCaret.IsAtPos(aCaret: TSynEditCaret): Boolean;
begin
  if (scBytePosValid in FFlags) or (scBytePosValid in aCaret.FFlags) then
    Result := IsAtLineByte(aCaret.LineBytePos, aCaret.BytePosOffset)
  else
    Result := IsAtLineChar(aCaret.LineCharPos);
end;

{ TSynEditPointBase }

function TSynEditPointBase.GetLocked: Boolean;
begin
  Result := FLockCount > 0;
end;

procedure TSynEditPointBase.SetLines(const AValue: TSynEditStringsLinked);
begin
  FLines := AValue;
end;

procedure TSynEditPointBase.DoLock;
begin
end;

procedure TSynEditPointBase.DoUnlock;
begin
end;

constructor TSynEditPointBase.Create;
begin
  FOnChangeList := TMethodList.Create;
end;

constructor TSynEditPointBase.Create(Lines : TSynEditStringsLinked);
begin
  Create;
  FLines := Lines;
end;

destructor TSynEditPointBase.Destroy;
begin
  FreeAndNil(FOnChangeList);
  inherited Destroy;
end;

procedure TSynEditPointBase.AddChangeHandler(AHandler : TNotifyEvent);
begin
  FOnChangeList.Add(TMethod(AHandler));
end;

procedure TSynEditPointBase.RemoveChangeHandler(AHandler : TNotifyEvent);
begin
  FOnChangeList.Remove(TMethod(AHandler));
end;

procedure TSynEditPointBase.Lock;
begin
  if FLockCount = 0 then
    DoLock;
  inc(FLockCount);
end;

procedure TSynEditPointBase.Unlock;
begin
  dec(FLockCount);
  if FLockCount = 0 then
    DoUnLock;
end;

{ TSynEditCaret }

constructor TSynEditCaret.Create;
begin
  inherited Create;
  FMaxLeftChar := nil;
  FAllowPastEOL := True;
  FForcePastEOL := 0;
  FAutoMoveOnEdit := 0;
  if FLines <> nil then
    FLines.AddEditHandler(@DoLinesEdited);
end;

destructor TSynEditCaret.Destroy;
begin
  if FLines <> nil then
    FLines.RemoveEditHandler(@DoLinesEdited);
  inherited Destroy;
end;

procedure TSynEditCaret.AssignFrom(Src: TSynEditBaseCaret);
begin
  FOldCharPos := FCharPos;
  FOldLinePos := FLinePos;

  inherited AssignFrom(Src);

  if Src is TSynEditCaret then begin
    FMaxLeftChar       := TSynEditCaret(Src).FMaxLeftChar;
    FAllowPastEOL      := TSynEditCaret(Src).FAllowPastEOL;
    FKeepCaretX        := TSynEditCaret(Src).FKeepCaretX;
    FLastCharPos       := TSynEditCaret(Src).FLastCharPos;
    FLastViewedCharPos := TSynEditCaret(Src).FLastViewedCharPos
  end
  else begin
    AdjustToChar;
    FLastCharPos   := FCharPos;
  end;
end;

procedure TSynEditCaret.DoLock;
begin
  FTouched := False;
  ValidateCharPos;
  //ValidateBytePos;
  FOldCharPos := FCharPos;
  FOldLinePos := FLinePos;
end;

procedure TSynEditCaret.DoUnlock;
begin
  if not FChangeOnTouch then
    FTouched := False;
  FChangeOnTouch := False;
  ValidateCharPos;
  //ValidateBytePos;
  if scfUpdateLastCaretX in FFLags then
    UpdateLastCaretX;
  if (FOldCharPos <> FCharPos) or (FOldLinePos <> FLinePos) or FTouched then
    fOnChangeList.CallNotifyEvents(self);
  // All notifications called, reset oldpos
  FTouched := False;
  FOldCharPos := FCharPos;
  FOldLinePos := FLinePos;
end;

procedure TSynEditCaret.SetLines(const AValue: TSynEditStringsLinked);
begin
  if FLines = AValue then exit;
  // Do not check flag. It will be cleared in Assign
  if (FLines <> nil) then
    FLines.RemoveEditHandler(@DoLinesEdited);
  FLinesEditedRegistered := False;
  inherited SetLines(AValue);
  if FAutoMoveOnEdit > 0 then
    RegisterLinesEditedHandler;
end;

procedure TSynEditCaret.RegisterLinesEditedHandler;
begin
  if FLinesEditedRegistered or (FLines = nil) then
    exit;
  FLinesEditedRegistered := True;
  FLines.AddEditHandler(@DoLinesEdited);
end;

procedure TSynEditCaret.DoLinesEdited(Sender: TSynEditStrings; aLinePos,
  aBytePos, aCount, aLineBrkCnt: Integer; aText: String);
  // Todo: refactor / this is a copy from selection
  function AdjustPoint(aPoint: Tpoint): TPoint; {$ifndef cpuaarch64}inline;{$endif} // workaround for issue https://bugs.freepascal.org/view.php?id=38766
  begin
    Result := aPoint;
    if aLineBrkCnt < 0 then begin
      (* Lines Deleted *)
      if aPoint.y > aLinePos then begin
        Result.y := Max(aLinePos, Result.y + aLineBrkCnt);
        if Result.y = aLinePos then
          Result.x := Result.x + aBytePos - 1;
      end;
    end
    else
    if aLineBrkCnt > 0 then begin
      (* Lines Inserted *)
      if (aPoint.y = aLinePos) and (aPoint.x >= aBytePos) then begin
        Result.x := Result.x - aBytePos + 1;
        Result.y := Result.y + aLineBrkCnt;
      end;
      if aPoint.y > aLinePos then begin
        Result.y := Result.y + aLineBrkCnt;
      end;
    end
    else
    if aCount <> 0 then begin
      (* Chars Insert/Deleted *)
      if (aPoint.y = aLinePos) and (aPoint.x >= aBytePos) then
        Result.x := Max(aBytePos, Result.x + aCount);
    end;
  end;

var
  p: TPoint;
begin
  if (FAutoMoveOnEdit > 0) and
     ( (aLineBrkCnt <> 0) or (aLinePos = FLinePos) )
  then begin
    IncForcePastEOL;
    ValidateBytePos;
    p :=  AdjustPoint(Point(FBytePos, FLinePos));
    InternalSetLineByterPos(p.y, p.x, FBytePosOffset, [scuChangedX, scuChangedY, scuForceSet]);
    DecForcePastEOL;
  end;
end;

procedure TSynEditCaret.AdjustToChar;
var
  CharWidthsArr: TPhysicalCharWidths;
  CharWidths: PPhysicalCharWidth;
  i, LogLen: Integer;
  ScreenPos: Integer;
  LogPos: Integer;
  L: String;
begin
  ValidateCharPos;
  L := LineText;
  if FLines.LogPhysConvertor.CurrentLine = FLinePos then begin
    CharWidths := FLines.LogPhysConvertor.CurrentWidths;
    LogLen     := FLines.LogPhysConvertor.CurrentWidthsCount;
  end
  else begin
    CharWidthsArr := FLines.GetPhysicalCharWidths(Pchar(L), length(L), FLinePos-1);
    LogLen        := Length(CharWidthsArr);
    if LogLen > 0 then
      CharWidths := @CharWidthsArr[0]
    else
      CharWidths := Nil;
  end;

  ScreenPos := 1;
  LogPos := 0;

  while LogPos < LogLen do begin
    if ScreenPos = FCharPos then exit;
    if ScreenPos + (CharWidths[LogPos] and PCWMask) > FCharPos then begin
      if (L[LogPos+1] = #9) and (not FSkipTabs) then exit;
      i := FCharPos;
      if FAdjustToNextChar or (FForceAdjustToNextChar > 0) then
        FCharPos := ScreenPos + (CharWidths[LogPos] and PCWMask)
      else
        FCharPos := ScreenPos;
      if FCharPos <> i then
        Exclude(FFlags, scBytePosValid);
      exit;
    end;
    ScreenPos := ScreenPos + (CharWidths[LogPos] and PCWMask);
    inc(LogPos);
  end;
end;

function TSynEditCaret.GetMaxLeftPastEOL: Integer;
begin
  if FMaxLeftChar <> nil then
    Result := FMaxLeftChar()
  else
    Result := MaxInt;
end;

procedure TSynEditCaret.InternalEmptyLinesSetPos(NewCharPos: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
var
  MaxPhysX: Integer;
begin
  assert(Lines.Count = 0, 'TSynEditCaret.InternalEmptyLinesSetPos: Lines.Count = 0');
  if (NewCharPos > 1) and (FAllowPastEOL or (FForcePastEOL > 0))
  then MaxPhysX := GetMaxLeftPastEOL
  else MaxPhysX := 1;
  if NewCharPos > MaxPhysX then
    NewCharPos := MaxPhysX;

  inherited InternalEmptyLinesSetPos(NewCharPos, UpdFlags);

  if (scuChangedX in UpdFlags) then begin
    //UpdateLastCaretX;
    // No need to wait for UnLock
    FLastCharPos := FCharPos;
    FLastViewedCharPos := ViewedLineCharPos.x;
    Exclude(FFLags, scfUpdateLastCaretX);
  end;
end;

procedure TSynEditCaret.InternalSetLineCharPos(NewLine, NewCharPos: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
var
  LogEolPos, MaxPhysX, NewLogCharPos, Offs: Integer;
  L: String;
begin
  if not (scuChangedX in UpdFlags) and FKeepCaretX then
    NewCharPos := FLastCharPos;

  Lock;
  FTouched := True;
  try
    if (fCharPos = NewCharPos) and (fLinePos = NewLine) and
       (scCharPosValid in FFlags) and not (scuForceSet in UpdFlags)
    then begin
      // Lines may have changed, so the other pos can be invalid
      if not (scuNoInvalidate in UpdFlags) then
        FFlags := FFlags - [scBytePosValid, scViewedPosValid];
      exit;
    end;

    if NewLine < 1 then begin
      NewLine := 1;
      Exclude(UpdFlags, scuNoInvalidate);
    end
    else
    if NewLine > FLines.Count then begin
      NewLine := FLines.Count;
      Exclude(UpdFlags, scuNoInvalidate);
    end;

    if FLines.Count = 0 then begin // Only allowed, if Lines.Count = 0
      InternalEmptyLinesSetPos(NewCharPos, UpdFlags);
    end else begin
      if FAdjustToNextChar or (FForceAdjustToNextChar > 0) then
        NewLogCharPos := Lines.LogPhysConvertor.PhysicalToLogical(NewLine-1, NewCharPos, Offs, cspDefault, [lpfAdjustToNextChar])
      else
        NewLogCharPos := Lines.LogPhysConvertor.PhysicalToLogical(NewLine-1, NewCharPos, Offs, cspDefault, [lpfAdjustToCharBegin]);
      Offs := Lines.LogPhysConvertor.UnAdjustedPhysToLogColOffs;
      L := Lines[NewLine - 1];

      if (Offs > 0) and (not FSkipTabs) and (L[NewLogCharPos] = #9) then begin
        // get the unadjusted result
        NewLogCharPos  := Lines.LogPhysConvertor.UnAdjustedPhysToLogResult
      end
      else begin
        // get adjusted Result
        NewCharPos := Lines.LogPhysConvertor.AdjustedPhysToLogOrigin;
        Offs := 0;
      end;

      LogEolPos := length(L)+1;
      if NewLogCharPos > LogEolPos then begin
        if FAllowPastEOL or (FForcePastEOL > 0) then begin
          MaxPhysX := GetMaxLeftPastEOL;
          if NewCharPos > MaxPhysX then begin
            NewLogCharPos := NewLogCharPos - (NewCharPos - MaxPhysX);
            NewCharPos := MaxPhysX;
            Exclude(UpdFlags, scuNoInvalidate);
          end;
        end
        else begin
          NewCharPos := NewCharPos - (NewLogCharPos - LogEolPos);
          NewLogCharPos := LogEolPos;
          Exclude(UpdFlags, scuNoInvalidate);
        end;
      end;

      if NewCharPos < 1 then begin
        NewCharPos := 1;
        Exclude(UpdFlags, scuNoInvalidate);
      end;

      inherited InternalSetLineCharPos(NewLine, NewCharPos, UpdFlags);
      inherited InternalSetLineByterPos(NewLine, NewLogCharPos, Offs, [scuNoInvalidate, scuChangedX]);

      if (scuChangedX in UpdFlags) then
        UpdateLastCaretX;
    end;
  finally
    Unlock;
  end;
end;

procedure TSynEditCaret.InternalSetLineByterPos(NewLine, NewBytePos, NewByteOffs: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
var
  MaxPhysX, NewCharPos, LogEolPos: Integer;
  L: String;
begin
  if not (scuChangedX in UpdFlags) and FKeepCaretX then begin
    Exclude(UpdFlags, scuNoInvalidate);
    InternalSetLineCharPos(NewLine, FLastCharPos, UpdFlags);
    exit;
  end;

  Lock;
  FTouched := True;
  try
    if (FBytePos = NewBytePos) and (FBytePosOffset = NewByteOffs) and
       (FLinePos = NewLine) and (scBytePosValid in FFlags) and not (scuForceSet in UpdFlags)
    then begin
      // Lines may have changed, so the other pos can be invalid
      if not (scuNoInvalidate in UpdFlags) then
        FFlags := FFlags - [scCharPosValid, scViewedPosValid];
      exit;
    end;

    if NewLine < 1 then begin
      NewLine := 1;
      Exclude(UpdFlags, scuNoInvalidate);
    end
    else
    if NewLine > FLines.Count then begin
      NewLine := FLines.Count;
      Exclude(UpdFlags, scuNoInvalidate);
    end;

    if FLines.Count = 0 then begin // Only allowed, if Lines.Count = 0
      InternalEmptyLinesSetPos(NewBytePos, UpdFlags);
    end else begin
      L := Lines[NewLine - 1];
      LogEolPos := length(L)+1;

      if (NewBytePos > LogEolPos) then begin
        if not(FAllowPastEOL or (FForcePastEOL > 0)) then
          NewBytePos := LogEolPos;
        NewByteOffs := 0;
      end
      else
      if (NewByteOffs > 0) and ( (FSkipTabs) or (L[NewBytePos] <> #9) ) then
        NewByteOffs := 0;


      if FAdjustToNextChar or (FForceAdjustToNextChar > 0) then
        NewCharPos := Lines.LogPhysConvertor.LogicalToPhysical(NewLine-1, NewBytePos, NewByteOffs, cslDefault, [lpfAdjustToNextChar])
      else
        NewCharPos := Lines.LogPhysConvertor.LogicalToPhysical(NewLine-1, NewBytePos, NewByteOffs, cslDefault, [lpfAdjustToCharBegin]);
      NewBytePos := Lines.LogPhysConvertor.AdjustedLogToPhysOrigin;

      if (NewBytePos > LogEolPos) then begin
        MaxPhysX := GetMaxLeftPastEOL;
        if NewCharPos > MaxPhysX then begin
          NewBytePos := NewBytePos - (NewCharPos - MaxPhysX);
          NewCharPos := MaxPhysX;
          Exclude(UpdFlags, scuNoInvalidate);
        end;
      end;

      if NewBytePos < 1 then begin
        NewBytePos := 1;
        Exclude(UpdFlags, scuNoInvalidate);
      end;

      inherited InternalSetLineByterPos(NewLine, NewBytePos, NewByteOffs, UpdFlags);
      inherited InternalSetLineCharPos(NewLine, NewCharPos, [scuNoInvalidate, scuChangedX]);

      if (scuChangedX in UpdFlags) then
        UpdateLastCaretX;
    end;
  finally
    Unlock;
  end;
end;

procedure TSynEditCaret.InternalSetViewedPos(NewLine, NewCharPos: Integer;
  UpdFlags: TSynEditCaretUpdateFlags);
var
  EolOffs, NewPhysX: Integer;
  Flags: TViewedXYInfoFlags;
  Info: TViewedXYInfo;
begin
  if not (scuChangedX in UpdFlags) and FKeepCaretX then
    NewCharPos := FLastViewedCharPos;

  Lock;
  FTouched := True;
  try
    if (FViewedLineCharPos.x = NewCharPos) and (FViewedLineCharPos.y = NewLine) and
       (scViewedPosValid in FFlags) and not (scuForceSet in UpdFlags)
    then begin
      // Lines may have changed, so the other pos can be invalid
      if not (scuNoInvalidate in UpdFlags) then
        FFlags := FFlags - [scBytePosValid, scCharPosValid];
      exit;
    end;

    if NewLine < 1 then begin
      NewLine := 1;
      Exclude(UpdFlags, scuNoInvalidate);
    end
    else
    if NewLine > FLines.ViewedCount then begin
      NewLine := FLines.ViewedCount;
      Exclude(UpdFlags, scuNoInvalidate);
    end;

    if FLines.Count = 0 then begin // Only allowed, if Lines.Count = 0
      InternalEmptyLinesSetPos(NewCharPos, UpdFlags);
    end else begin

      Flags := [vifReturnPhysXY, vifReturnLogXY, vifReturnLogEOL, vifReturnPhysOffset];
      if FAdjustToNextChar or (FForceAdjustToNextChar > 0) then
        Flags := Flags + [vifAdjustLogXYToNextChar]; // can go to next wrapped line
      Lines.GetInfoForViewedXY(Point(NewCharPos, NewLine), Flags, Info);

      if (Info.LogicalXY.Offs <> 0) then begin
        if FSkipTabs or (Lines[ToIdx(Info.LogicalXY.y)][Info.LogicalXY.x] <> #9) then begin
          Info.LogicalXY.Offs := 0;
          Info.CorrectedViewedXY.X := Info.CorrectedViewedXY.X - Info.PhysBoundOffset;
          Info.PhysXY.X := Info.PhysXY.X - Info.PhysBoundOffset;
          if Info.CorrectedViewedXY.x < Info.FirstViewedX then begin
            Info.LogicalXY.X := Info.LogicalXY.X + 1;
            Info.LogicalXY.Offs := 0;
            NewPhysX := Lines.LogPhysConvertor.LogicalToPhysical( ToIdx(Info.LogicalXY.y), Info.LogicalXY.x, Info.LogicalXY.Offs, cslDefault, []);
            Info.CorrectedViewedXY.x := Info.CorrectedViewedXY.x + NewPhysX - Info.PhysXY.x;
            Info.PhysXY.x := NewPhysX;
          end;
        end;
      end;

      //if TestEOL and (Info.LogicalXY.X > Info.LogEOLPos) then begin
      if (Info.LogicalXY.X > Info.LogEOLPos) then begin
        if FAllowPastEOL or (FForcePastEOL > 0) then
          EolOffs := Max(0, Info.PhysXY.X - GetMaxLeftPastEOL)
        else
          EolOffs := Info.LogicalXY.X - Info.LogEOLPos;

        Info.CorrectedViewedXY.X := Info.CorrectedViewedXY.X - EolOffs;
        Info.LogicalXY.X         := Info.LogicalXY.X - EolOffs;
        Info.PhysXY.X            := Info.PhysXY.X - EolOffs;
        Exclude(UpdFlags, scuNoInvalidate);
      end;

      if NewCharPos < 1 then begin
        NewCharPos := 1;
        Exclude(UpdFlags, scuNoInvalidate);
      end;

      inherited InternalSetLineCharPos(Info.PhysXY.Y, Info.PhysXY.X, UpdFlags);
      inherited InternalSetLineByterPos(Info.LogicalXY.Y, Info.LogicalXY.X, Info.LogicalXY.Offs, [scuNoInvalidate, scuChangedX]);
      inherited InternalSetViewedPos(Info.CorrectedViewedXY.Y, Info.CorrectedViewedXY.X, UpdFlags + [scuNoInvalidate]);

      if (scuChangedX in UpdFlags) then
        UpdateLastCaretX;
    end;
  finally
    Unlock;
  end;
end;

function TSynEditCaret.GetOldLineCharPos: TPoint;
begin
  Result := Point(FOldCharPos, FOldLinePos);
end;

function TSynEditCaret.GetOldLineBytePos: TPoint;
begin
  Result := FLines.PhysicalToLogicalPos(OldLineCharPos);
end;

function TSynEditCaret.GetOldFullLogicalPos: TLogCaretPoint;
begin
  Result.Y := FOldLinePos;
  Result.X := FLines.LogPhysConvertor.PhysicalToLogical(ToIdx(FOldLinePos), FOldCharPos, Result.Offs);
end;

procedure TSynEditCaret.SetAllowPastEOL(const AValue: Boolean);
begin
  if FAllowPastEOL = AValue then exit;
  FAllowPastEOL := AValue;
  if not FAllowPastEOL then begin
    // TODO: this would set x=LastX
    //if scBytePosValid in FFlags then
    //  InternalSetLineByterPos(FLinePos, FBytePos, FBytePosOffset, [scuForceSet]); // NO scuChangedX => FLastCharPos is kept
    //else
    ValidateCharPos;
    InternalSetLineCharPos(FLinePos, FCharPos, [scuForceSet]); // NO scuChangedX => FLastCharPos is kept
  end;
end;

procedure TSynEditCaret.SetKeepCaretX(const AValue: Boolean);
begin
  if FKeepCaretX = AValue then exit;
  FKeepCaretX := AValue;
  if FKeepCaretX then begin
    ValidateCharPos;
    UpdateLastCaretX;
  end;
end;

procedure TSynEditCaret.UpdateLastCaretX;
begin
  if not FKeepCaretX then begin
    Exclude(FFLags, scfUpdateLastCaretX);
    exit;
  end;

  FLastCharPos := FCharPos;

  if Locked then begin
    Include(FFLags, scfUpdateLastCaretX);
    exit;
  end;
  Exclude(FFLags, scfUpdateLastCaretX);
  //FLastCharPos := FCharPos;
  FLastViewedCharPos := ViewedLineCharPos.x;
end;

procedure TSynEditCaret.SetSkipTabs(const AValue: Boolean);
begin
  if FSkipTabs = AValue then exit;
  FSkipTabs := AValue;
  if FSkipTabs then begin
    Lock;
    AdjustToChar;
    Unlock;
  end;
end;

procedure TSynEditCaret.IncForcePastEOL;
begin
  inc(FForcePastEOL);
end;

procedure TSynEditCaret.DecForcePastEOL;
begin
  dec(FForcePastEOL);
end;

procedure TSynEditCaret.IncForceAdjustToNextChar;
begin
  Inc(FForceAdjustToNextChar);
end;

procedure TSynEditCaret.DecForceAdjustToNextChar;
begin
  Dec(FForceAdjustToNextChar);
end;

procedure TSynEditCaret.IncAutoMoveOnEdit;
begin
  if FAutoMoveOnEdit = 0 then begin
    RegisterLinesEditedHandler;
    ValidateBytePos;
  end;
  inc(FAutoMoveOnEdit);
end;

procedure TSynEditCaret.DecAutoMoveOnEdit;
begin
  dec(FAutoMoveOnEdit);
end;

procedure TSynEditCaret.ChangeOnTouch;
begin
  FChangeOnTouch := True;
  if not Locked then
    FTouched := False;
end;

procedure TSynEditCaret.Touch(aChangeOnTouch: Boolean);
begin
  if aChangeOnTouch then
    ChangeOnTouch;
  FTouched := True;
end;


function TSynEditCaret.WasAtLineChar(aPoint: TPoint): Boolean;
begin
  Result := (FOldLinePos = aPoint.y) and (FOldCharPos = aPoint.x);
end;

function TSynEditCaret.WasAtLineByte(aPoint: TPoint): Boolean;
begin
  Result := (FOldLinePos = aPoint.y) and
            (FLines.PhysicalToLogicalPos(Point(FOldCharPos, FOldLinePos)).X = aPoint.x);
end;

function TSynEditCaret.MoveHoriz(ACount: Integer): Boolean;
var
  L: String;
  CharWidths: TPhysicalCharWidths;
  GotCharWidths: Boolean;
  MaxOffs: Integer;
  p: Integer;
  NC: Boolean;
  NF: Integer;

  function GetMaxOffs(AlogPos: Integer): Integer;
  begin
    if not GotCharWidths then
      CharWidths := FLines.GetPhysicalCharWidths(Pchar(L), length(L), FLinePos-1);
    GotCharWidths := True;
    Result := CharWidths[AlogPos-1];
  end;

begin
  GotCharWidths := False;
  L := LineText;
  ValidateBytePos;

  If ACount > 0 then begin
    if (FBytePos <= length(L)) and (L[FBytePos] = #9) and (not FSkipTabs) then
      MaxOffs := GetMaxOffs(FBytePos) - 1
    else
      MaxOffs := 0;

    while ACount > 0 do begin
      if FBytePosOffset < MaxOffs then
        inc(FBytePosOffset)
      else begin
        if (FBytePos > length(L)) and not (FAllowPastEOL or (FForcePastEOL > 0)) then
          break;
        FBytePos := FLines.LogicPosAddChars(L, FBytePos, 1, True);
        FBytePosOffset := 0;
        if (FBytePos <= length(L)) and (L[FBytePos] = #9) and (not FSkipTabs) then
          MaxOffs := GetMaxOffs(FBytePos) - 1
        else
          MaxOffs := 0;
      end;
      dec(ACount);
    end;
    Result := ACount = 0;

    p := FBytePos;
    IncForceAdjustToNextChar;
    InternalSetLineByterPos(FLinePos, FBytePos, FBytePosOffset, [scuChangedX, scuForceSet]);
    DecForceAdjustToNextChar;
    if p > FBytePos then
      Result := False; // MaxLeftChar
  end
  else begin
    while ACount < 0 do begin
      if FBytePosOffset > 0 then
        dec(FBytePosOffset)
      else begin
        if FBytePos = 1 then
          break;
        FBytePos := FLines.LogicPosAddChars(L, FBytePos, -1, True);
        if (FBytePos <= length(L)) and (L[FBytePos] = #9) and (not FSkipTabs) then
          FBytePosOffset := GetMaxOffs(FBytePos) - 1
        else
          FBytePosOffset := 0;
      end;
      inc(ACount);
    end;
    Result := ACount = 0;

    NC := FAdjustToNextChar;
    NF := FForceAdjustToNextChar;
    FAdjustToNextChar      := False;
    FForceAdjustToNextChar := 0;
    InternalSetLineByterPos(FLinePos, FBytePos, FBytePosOffset, [scuChangedX, scuForceSet]);
    FAdjustToNextChar      := NC;
    FForceAdjustToNextChar := NF;
  end;
end;

{ TSynEditSelection }

constructor TSynEditSelection.Create(ALines : TSynEditStringsLinked; aActOnLineChanges: Boolean);
begin
  Inherited Create(ALines);
  FOnBeforeSetSelText := TSynBeforeSetSelTextList.Create;
  FInternalCaret := TSynEditBaseCaret.Create;
  FInternalCaret.Lines := FLines;

  FActiveSelectionMode := smNormal;
  FStartLinePos := 1;
  FStartBytePos := 1;
  FAltStartLinePos := -1;
  FAltStartBytePos := -1;
  FEndLinePos := 1;
  FEndBytePos := 1;
  FEnabled := True;
  FHookedLines := aActOnLineChanges;
  FIsSettingText := False;
  if FHookedLines then begin
    FLines.AddEditHandler(@DoLinesEdited);
    FLines.AddChangeHandler(senrLineChange, @LineChanged);
  end;
end;

destructor TSynEditSelection.Destroy;
begin
  FreeAndNil(FOnBeforeSetSelText);
  FreeAndNil(FInternalCaret);
  if FHookedLines then begin
    FLines.RemoveEditHandler(@DoLinesEdited);
    FLines.RemoveChangeHandler(senrLineChange, @LineChanged);
  end;
  inherited Destroy;
end;

procedure TSynEditSelection.AssignFrom(Src: TSynEditSelection);
begin
  //FEnabled             := src.FEnabled;
  FHide                := src.FHide;
  FActiveSelectionMode := src.FActiveSelectionMode;
  FSelectionMode       := src.FSelectionMode;
  FStartLinePos        := src.FStartLinePos; // 1 based
  FStartBytePos        := src.FStartBytePos; // 1 based
  FEndLinePos          := src.FEndLinePos; // 1 based
  FEndBytePos          := src.FEndBytePos; // 1 based
  FPersistent          := src.FPersistent;
  FLeftCharPos         := src.FLeftCharPos;
  FRightCharPos        := src.FRightCharPos;
  FAltStartLinePos     := src.FAltStartLinePos;
  FAltStartBytePos     := src.FAltStartBytePos;
  FFlags := FFLags - [sbViewedFirstPosValid, sbViewedLastPosValid];
end;

procedure TSynEditSelection.AdjustAfterTrimming;
begin
  if FStartBytePos > Length(FLines[FStartLinePos-1]) + 1 then begin
    FStartBytePos := Length(FLines[FStartLinePos-1]) + 1;
    FFlags := FFLags - [sbViewedFirstPosValid];
  end;
  if FEndBytePos > Length(FLines[FEndLinePos-1]) + 1 then begin
    FEndBytePos := Length(FLines[FEndLinePos-1]) + 1;
    FFlags := FFLags - [sbViewedLastPosValid];
  end;
  // Todo: Call ChangeNotification
end;

procedure TSynEditSelection.DoLock;
begin
  inherited DoLock;
  FLastCarePos := Point(-1, -1);
end;

procedure TSynEditSelection.DoUnlock;
begin
  inherited DoUnlock;
  FLastCarePos := Point(-1, -1);
end;

function TSynEditSelection.GetSelText : string;

  function CopyPadded(const S: string; Index, Count: integer): string;
  var
    SrcLen: Integer;
    DstLen: integer;
    P: PChar;
  begin
    SrcLen := Length(S);
    DstLen := Index + Count;
    if SrcLen >= DstLen then
      Result := Copy(S, Index, Count)
    else begin
      SetLength(Result, DstLen);
      P := PChar(Result);
      StrPCopy(P, Copy(S, Index, Count));
      Inc(P, SrcLen);
      FillChar(P^, DstLen - Srclen, $20);
    end;
  end;

  procedure CopyAndForward(const S: string; Index, Count: Integer; var P: PChar);
  var
    pSrc: PChar;
    SrcLen: Integer;
    DstLen: Integer;
  begin
    SrcLen := Length(S);
    if (Index <= SrcLen) and (Count > 0) then begin
      Dec(Index);
      pSrc := PChar(Pointer(S)) + Index;
      DstLen := Min(SrcLen - Index, Count);
      Move(pSrc^, P^, DstLen);
      Inc(P, DstLen);
      P^ := #0;
    end;
  end;

  procedure CopyPaddedAndForward(const S: string; Index, Count: Integer;
    var P: PChar);
  var
    OldP: PChar;
    Len: Integer;
  begin
    OldP := P;
    CopyAndForward(S, Index, Count, P);
    Len := Count - (P - OldP);
    FillChar(P^, Len, #$20);
    Inc(P, Len);
  end;


var
  First, Last, TotalLen: Integer;
  ColFrom, ColTo: Integer;
  I: Integer;
  P: PChar;
  C1, C2: Integer;
  Col, Len: array of Integer;

begin
  Result := '';
  if SelAvail then
  begin
    if IsBackwardSel then begin
      ColFrom := FEndBytePos;
      First := FEndLinePos - 1;
      ColTo := FStartBytePos;
      Last := FStartLinePos - 1;
    end else begin
      ColFrom := FStartBytePos;
      First := FStartLinePos - 1;
      ColTo := FEndBytePos;
      Last := FEndLinePos - 1;
    end;
    TotalLen := 0;
    case ActiveSelectionMode of
      smNormal:
        if (First = Last) then begin
          Result := Copy(FLines[First], ColFrom, ColTo - ColFrom);
          I := (ColTo - ColFrom) - length(Result);
          if I > 0 then
            Result := Result + StringOfChar(' ', I);
        end else begin
          // step1: calculate total length of result string
          TotalLen := Max(0, Length(FLines[First]) - ColFrom + 1);
          for i := First + 1 to Last - 1 do
            Inc(TotalLen, Length(FLines[i]));
          Inc(TotalLen, ColTo - 1);
          Inc(TotalLen, Length(sLineBreak) * (Last - First));
          // step2: build up result string
          SetLength(Result, TotalLen);
          P := PChar(Pointer(Result));
          CopyAndForward(FLines[First], ColFrom, MaxInt, P);
          CopyAndForward(sLineBreak, 1, MaxInt, P);
          for i := First + 1 to Last - 1 do begin
            CopyAndForward(FLines[i], 1, MaxInt, P);
            CopyAndForward(sLineBreak, 1, MaxInt, P);
          end;
          CopyPaddedAndForward(FLines[Last], 1, ColTo - 1, P);
        end;
      smColumn:
        begin
          // Calculate the byte positions for each line
          SetLength(Col, Last - First + 1);
          SetLength(Len, Last - First + 1);
          FInternalCaret.Invalidate;
          FInternalCaret.LineBytePos := FirstLineBytePos;
          C1 := FInternalCaret.CharPos;
          FInternalCaret.LineBytePos := LastLineBytePos;
          C2 := FInternalCaret.CharPos;
          if C1 > C2 then
            SwapInt(C1, C2);

          TotalLen := 0;
          for i := First to Last do begin
            FInternalCaret.LineCharPos := Point(C1, i + 1);
            Col[i - First] := FInternalCaret.BytePos;
            FInternalCaret.LineCharPos := Point(C2, i + 1);
            Len[i - First] := Max(0, FInternalCaret.BytePos - Col[i - First]);
            Inc(TotalLen, Len[i - First]);
          end;
          Inc(TotalLen, Length(LineEnding) * (Last - First));
          // build up result string
          SetLength(Result, TotalLen);
          P := PChar(Pointer(Result));
          for i := First to Last do begin
            CopyPaddedAndForward(FLines[i], Col[i-First], Len[i-First], P);
            if i < Last then
              CopyAndForward(LineEnding, 1, MaxInt, P);
          end;
        end;
      smLine:
        begin
          // If block selection includes LastLine,
          // line break code(s) of the last line will not be added.
          // step1: calclate total length of result string
          for i := First to Last do
            Inc(TotalLen, Length(FLines[i]) + Length(LineEnding));
          if Last = FLines.Count - 1 then
            Dec(TotalLen, Length(LineEnding));
          // step2: build up result string
          SetLength(Result, TotalLen);
          P := PChar(Pointer(Result));
          for i := First to Last - 1 do begin
            CopyAndForward(FLines[i], 1, MaxInt, P);
            CopyAndForward(LineEnding, 1, MaxInt, P);
          end;
          CopyAndForward(FLines[Last], 1, MaxInt, P);
          if Last < FLines.Count - 1 then
            CopyAndForward(LineEnding, 1, MaxInt, P);
        end;
    end;
  end;
end;

procedure TSynEditSelection.SetSelText(const Value : string);
begin
  SetSelTextPrimitive(FActiveSelectionMode, PChar(Value));
end;

procedure TSynEditSelection.DoCaretChanged(Sender: TObject);

  procedure SwapAltStart;
  var
    x, y: Integer;
  begin
    if FAltStartLinePos < FStartLinePos then
      FInvalidateLinesMethod(FAltStartLinePos, FStartLinePos)
    else
      FInvalidateLinesMethod(FStartLinePos, FAltStartLinePos);
    y := FAltStartLinePos;
    x := FAltStartBytePos;
    FAltStartLinePos := FStartLinePos;
    FAltStartBytePos := FStartBytePos;
    FStartLinePos := y;
    FStartBytePos := x;
    FFlags := FFLags - [sbViewedFirstPosValid];
  end;

  procedure FixMinimumSelection;
  begin
    if FAltStartLinePos < 0 then exit;
    case ComparePoints(Point(FAltStartBytePos, FAltStartLinePos), StartLineBytePos) of
      -1: begin // alt is before start
          if ComparePoints(StartLineBytePos, EndLineBytePos) <= 0 then
            SwapAltStart;
        end;
      1: begin // start is before alt
          if ComparePoints(StartLineBytePos, EndLineBytePos) >= 0 then
            SwapAltStart;
        end;
    end;
  end;

var
  f: Boolean;
begin
  // FIgnoreNextCaretMove => caret skip selection
  if FIgnoreNextCaretMove then begin
    FIgnoreNextCaretMove := False;
    FLastCarePos := Point(-1, -1);
    exit;
  end;

  if (FCaret.IsAtLineByte(StartLineBytePos) or
      FCaret.IsAtLineByte(EndLineBytePos)) and
     FCaret.WasAtLineChar(FLastCarePos)
  then
    exit;
  FLastCarePos := Point(-1, -1);

  if FAutoExtend or FStickyAutoExtend then begin
    f := FStickyAutoExtend;
    if (not FHide) and (FCaret.WasAtLineByte(EndLineBytePos)) then begin
      SetEndLineBytePos(FCaret.LineBytePos);
      FixMinimumSelection;
    end
    else
    if (not FHide) and (FCaret.WasAtLineByte(StartLineBytePos)) then begin
      AdjustStartLineBytePos(FCaret.LineBytePos);
      FAltStartLinePos := -1;
      FAltStartBytePos := -1;
    end
    else begin
      StartLineBytePos := FCaret.OldLineBytePos;
      EndLineBytePos := FCaret.LineBytePos;
      if Persistent and IsBackwardSel then
        SortSelectionPoints;
    end;
    FStickyAutoExtend := f;
    exit;
  end;

  if FPersistent or (FPersistentLock > 0) then
    exit;

  StartLineBytePos := FCaret.LineBytePos;
end;

procedure TSynEditSelection.LineChanged(Sender: TSynEditStrings; AIndex,
  ACount: Integer);
var
  i, i2: Integer;
begin
  if (FCaret <> nil) and (not FCaret.AllowPastEOL) and (not FIsSettingText) then begin
    i := ToPos(AIndex);
    i2 := i + ACount - 1;

    //AdjustAfterTrimming;
    if (FStartLinePos >= i) and (FStartLinePos <= i2) then
      if FStartBytePos > Length(FLines[FStartLinePos-1]) + 1 then begin
        FStartBytePos := Length(FLines[FStartLinePos-1]) + 1;
        FFlags := FFLags - [sbViewedFirstPosValid];
      end;
    if (FEndLinePos >= i) and (FEndLinePos <= i2) then
      if FEndBytePos > Length(FLines[FEndLinePos-1]) + 1 then begin
        FEndBytePos := Length(FLines[FEndLinePos-1]) + 1;
        FFlags := FFLags - [sbViewedLastPosValid];
      end;
  end;
end;

procedure TSynEditSelection.DoLinesEdited(Sender: TSynEditStrings; aLinePos,
  aBytePos, aCount, aLineBrkCnt: Integer; aText: String);

  function AdjustPoint(aPoint: Tpoint; AIsStart: Boolean): TPoint; //inline;
  begin
    Result := aPoint;
    if aLineBrkCnt < 0 then begin
      (* Lines Deleted *)
      if aPoint.y > aLinePos then begin
        Result.y := Max(aLinePos, Result.y + aLineBrkCnt);
        if Result.y = aLinePos then
          Result.x := Result.x + aBytePos - 1;
      end;
    end
    else
    if aLineBrkCnt > 0 then begin
      (* Lines Inserted *)
      if aPoint.y > aLinePos then begin
        Result.y := Result.y + aLineBrkCnt;
      end
      else
      if (aPoint.y = aLinePos) and (aPoint.x >= aBytePos) then begin
        if (aPoint.x = aBytePos) then begin
          if (FWeakPersistentIdx > 0) and (FWeakPersistentIdx > FStrongPersistentIdx) then begin
            if not AIsStart then
              exit;
          end
          else
          if (FStrongPersistentIdx > 0) then begin
            if AIsStart then
              exit;
          end;
        end;
        Result.x := Result.x - aBytePos + 1;
        Result.y := Result.y + aLineBrkCnt;
      end;
    end
    else
    if aCount <> 0 then begin
      (* Chars Insert/Deleted *)
      if (aPoint.y = aLinePos) then begin
        if (FWeakPersistentIdx > 0) and (FWeakPersistentIdx > FStrongPersistentIdx) then begin
          if (AIsStart and (aPoint.x >= aBytePos)) or
             (not AIsStart and (aPoint.x > aBytePos))
          then
            Result.x := Max(aBytePos, Result.x + aCount);
        end
        else
        if (FStrongPersistentIdx > 0) then begin
          if (AIsStart and (aPoint.x > aBytePos)) or
             (not AIsStart and (aPoint.x >= aBytePos))
          then
            Result.x := Max(aBytePos, Result.x + aCount);
        end
        else begin
          if (aPoint.x >= aBytePos) then
            Result.x := Max(aBytePos, Result.x + aCount);
        end;
      end;
    end;
  end;

var
  empty, back: Boolean;
begin
  FLeftCharPos  := -1;
  FRightCharPos := -1;
  if FIsSettingText then exit;
  if FPersistent or (FPersistentLock > 0) or
     ((FCaret <> nil) and (not FCaret.Locked))
  then begin
    if FActiveSelectionMode <> smColumn then begin // TODO: adjust ypos, height in smColumn mode
      empty := (FStartBytePos = FEndBytePos) and (FStartLinePos = FEndLinePos);
      back := IsBackwardSel;
      AdjustStartLineBytePos(AdjustPoint(StartLineBytePos, not back));
      if empty then
        EndLineBytePos := StartLineBytePos
      else
        EndLineBytePos := AdjustPoint(EndLineBytePos, back);
    end;
    // Todo: Change Lines in smColumn
  end
  else begin
    // Change the Selection, if change was made by owning SynEdit (Caret.Locked)
    // (InternalSelection has no Caret)
    if (FCaret <> nil) and (FCaret.Locked) then
      StartLineBytePos := FCaret.LineBytePos;
  end;
end;

procedure TSynEditSelection.SetSelTextPrimitive(PasteMode: TSynSelectionMode;
  Value: PChar; AReplace: Boolean; ASetTextSelected: Boolean);
var
  BB, BE: TPoint;

  procedure DeleteSelection;
  var
    y, l, r, xb, xe: Integer;
    Str: string;
    Start, P: PChar;
    //LogCaretXY: TPoint;
  begin
    case ActiveSelectionMode of
      smNormal, smLine:
        begin
          if FLines.Count > 0 then begin

            if AReplace and (Value <> nil) then begin
              // AReplace = True
              while Value^ <> #0 do begin
                Start := PChar(Value);
                P := GetEOL(Start);
                Value := P;

                if Value^ = #13 then Inc(Value);
                if Value^ = #10 then Inc(Value);

                SetString(Str, Start, P - Start);

                if BE.y > BB.y then begin
//                  FLines.EditDelete(BB.x, BB.Y, 1+Length(FLines[BB.y-1]) - BB.x);
////                  if Str <> '' then
//                  FLines.EditInsert(BB.x, BB.Y, Str);
                  FLines.EditReplace(BB.x, BB.Y, 1+Length(FLines[BB.y-1]) - BB.x, Str);
                  if (PasteMode = smLine) or (Value > P) then begin
                    inc(BB.y);
                    BB.x := 1;
                  end
                  else
                    BB.X := BB.X + length(Str);
                end
                else begin
                  // BE will be block-.nd, also used by SynEdit to set caret
                  if (ActiveSelectionMode = smLine) or (Value > P) then begin
                    FLines.EditReplace(BB.x, BB.Y, BE.x - BB.x, Str);
                    FLines.EditLineBreak(BB.x+length(Str), BB.Y);
                    //FLines.EditDelete(BB.x, BB.Y, BE.x - BB.x);
                    //FLines.EditLineBreak(BB.x, BB.Y);
                    //FLines.EditInsert(BB.x, BB.Y, Str);
                    inc(BE.y);
                    BE.x := 1;
                  end
                  else begin
                    //FLines.EditDelete(BB.x, BB.Y, BE.x - BB.x);
//                  if Str <> '' then
                    //FLines.EditInsert(BB.x, BB.Y, Str);
                    FLines.EditReplace(BB.x, BB.Y, BE.x - BB.x, Str);
                    BE.X := BB.X + length(Str);
                  end;
                  BB := BE; // end of selection
                end;

                if (BB.Y = BE.Y) and (BB.X = BE.X) then begin
                  FInternalCaret.LineBytePos := BB;
                  exit;
                end;

              end;
            end;

            // AReplace = False
            if BE.Y > BB.Y + 1 then begin
              FLines.EditLinesDelete(BB.Y + 1, BE.Y - BB.Y - 1);
              BE.Y := BB.Y + 1;
            end;
            if BE.Y > BB.Y then begin
              l := length(FLines[BB.Y - 1]);
              BE.X := BE.X + Max(l, BB.X - 1);
              FLines.EditLineJoin(BB.Y, StringOfChar(' ', Max(0, BB.X - (l+1))));
              BE.Y := BB.Y;
            end;
            if BE.X <> BB.X then
              FLines.EditDelete(BB.X, BB.Y, BE.X - BB.X);
          end;
          FInternalCaret.LineBytePos := BB;
        end;
      smColumn:
        begin
          // AReplace has no effect
          FInternalCaret.LineBytePos := BB;
          l := FInternalCaret.CharPos;
          FInternalCaret.LineBytePos := BE;
          r := FInternalCaret.CharPos;
          // swap l, r if needed
          if l > r then
            SwapInt(l, r);
          for y := BB.Y to BE.Y do begin
            FInternalCaret.LineCharPos := Point(l, y);
            xb := FInternalCaret.BytePos;
            FInternalCaret.LineCharPos := Point(r, y);
//            xe := Min(FInternalCaret.BytePos, 1 + length(FInternalCaret.LineText));
            xe := FInternalCaret.BytePos;
            if xe > xb then
              FLines.EditDelete(xb, y, xe - xb);
          end;
          FInternalCaret.LineCharPos := Point(l, BB.Y);
          BB := FInternalCaret.LineBytePos;
          // Column deletion never removes a line entirely,
          // so no (vertical) mark updating is needed here.
        end;
    end;
  end;

  procedure InsertText;

    function CountLines(p: PChar): integer;
    begin
      Result := 0;
      while p^ <> #0 do begin
        if p^ = #13 then
          Inc(p);
        if p^ = #10 then
          Inc(p);
        Inc(Result);
        p := GetEOL(p);
      end;
    end;

    function InsertNormal: Integer;
    var
      Str: string;
      Start: PChar;
      P: PChar;
      LogCaretXY: TPoint;
    begin
      Result := 0;
      LogCaretXY := FInternalCaret.LineBytePos;

      Start := PChar(Value);
      P := GetEOL(Start);
      if P^ = #0 then begin
        FLines.EditInsert(LogCaretXY.X, LogCaretXY.Y, Value);
        FInternalCaret.BytePos := FInternalCaret.BytePos + Length(Value);
      end else begin
        FLines.EditLineBreak(LogCaretXY.X, LogCaretXY.Y);
        if (P <> Start) or (LogCaretXY.X > 1 + length(FLines[ToIdx(LogCaretXY.Y)])) then begin
          SetString(Str, Value, P - Start);
          FLines.EditInsert(LogCaretXY.X, LogCaretXY.Y, Str);
        end
        else
          Str := '';
        Result :=  CountLines(P);
        if Result > 1 then
          FLines.EditLinesInsert(LogCaretXY.Y + 1, Result - 1);
        while P^ <> #0 do begin
          if P^ = #13 then
            Inc(P);
          if P^ = #10 then
            Inc(P);
          LogCaretXY.Y := LogCaretXY.Y + 1;
          Start := P;
          P := GetEOL(Start);
          if P <> Start then begin
            SetString(Str, Start, P - Start);
            FLines.EditInsert(1, LogCaretXY.Y, Str);
          end
          else
            Str := '';
        end;
        FInternalCaret.LinePos := LogCaretXY.Y;
        FInternalCaret.BytePos := 1 + Length(Str);
      end;
    end;

    function InsertColumn: Integer;
    var
      Str: string;
      Start: PChar;
      P: PChar;
    begin
      // Insert string at current position
      Result := 0;
      Start := PChar(Value);
      repeat
        P := GetEOL(Start);
        if P <> Start then begin
          SetLength(Str, P - Start);
          Move(Start^, Str[1], P - Start);
          FLines.EditInsert(FInternalCaret.BytePos, FInternalCaret.LinePos, Str);
        end;
        if p^ in [#10,#13] then begin
          if (p[1] in [#10,#13]) and (p[1]<>p^) then
            inc(p,2)
          else
            Inc(P);
          if FInternalCaret.LinePos = FLines.Count then
            FLines.EditLinesInsert(FInternalCaret.LinePos + 1, 1);
            // No need to inc result => adding at EOF
          FInternalCaret.LinePos := FInternalCaret.LinePos + 1;
        end;
        Start := P;
      until P^ = #0;
      FInternalCaret.BytePos:= FInternalCaret.BytePos + Length(Str);
    end;

    function InsertLine: Integer;
    var
      Start: PChar;
      P: PChar;
      Str: string;
    begin
      Result := 0;
      FInternalCaret.CharPos := 1;
      // Insert string before current line
      Start := PChar(Value);
      repeat
        P := GetEOL(Start);
        if P <> Start then begin
          SetLength(Str, P - Start);
          Move(Start^, Str[1], P - Start);
        end else
          Str := '';
        if (P^ = #0) then begin  // Not a full line?
          FLines.EditInsert(1, FInternalCaret.LinePos, Str);
          FInternalCaret.BytePos := 1 + Length(Str);
        end else begin
          FLines.EditLinesInsert(FInternalCaret.LinePos, 1, Str);
          FInternalCaret.LinePos := FInternalCaret.LinePos + 1;
          Inc(Result);
          if P^ = #13 then
            Inc(P);
          if P^ = #10 then
            Inc(P);
          Start := P;
        end;
      until P^ = #0;
    end;

  begin
    if Value = '' then
      Exit;
    if FLines.Count = 0 then
      FLines.EditLineBreak(1, 1);

    // Using a TStringList to do this would be easier, but if we're dealing
    // with a large block of text, it would be very inefficient.  Consider:
    // Assign Value parameter to TStringList.Text: that parses through it and
    // creates a copy of the string for each line it finds.  That copy is passed
    // to the Add method, which in turn creates a copy.  Then, when you actually
    // use an item in the list, that creates a copy to return to you.  That's
    // 3 copies of every string vs. our one copy below.  I'd prefer no copies,
    // but we aren't set up to work with PChars that well.

    case PasteMode of
      smNormal:
        InsertNormal;
      smColumn:
        InsertColumn;
      smLine:
        InsertLine;
    end;
  end;

begin
  FOnBeforeSetSelText.CallBeforeSetSelTextHandlers(Self, PasteMode, Value);
  FIsSettingText := True;
  FStickyAutoExtend := False;
  FLines.BeginUpdate; // Todo: can we get here, without paintlock?
  try
    // BB is lower than BE
    BB := FirstLineBytePos;
    BE := LastLineBytePos;
    FInternalCaret.Invalidate;
    if SelAvail then begin
      if FActiveSelectionMode = smLine then begin
        BB.X := 1;
        if BE.Y = FLines.Count then begin
          // Keep the (CrLf of) last line, since no Line exists to replace it
          BE.x := 1 + length(FLines[BE.Y - 1]);
        end else begin
          inc(BE.Y);
          BE.x := 1;
        end;
      end;
      DeleteSelection;
      StartLineBytePos := BB; // deletes selection // calls selection changed
      // Need to update caret (syncro edit follows on every edit)
      if FCaret <> nil then
        FCaret.LineCharPos := FInternalCaret.LineCharPos; // must equal BB
    end
    else
    if FCaret <> nil then
      StartLineBytePos := FCaret.LineBytePos;

    FInternalCaret.LineBytePos := StartLineBytePos;
    if (Value <> nil) and (Value[0] <> #0) then begin
      InsertText;
      if ASetTextSelected then begin
        EndLineBytePos := FInternalCaret.LineBytePos;
        FActiveSelectionMode := PasteMode;
      end
      else
        StartLineBytePos := FInternalCaret.LineBytePos; // reset selection
    end;
    if FCaret <> nil then
      FCaret.LineCharPos := FInternalCaret.LineCharPos;
  finally
    FLines.EndUpdate;
    FIsSettingText := False;
  end;
end;

function TSynEditSelection.GetStartLineBytePos : TPoint;
begin
  Result.y := FStartLinePos;
  Result.x := FStartBytePos;
end;

procedure TSynEditSelection.SetEnabled(const Value : Boolean);
begin
  if FEnabled = Value then exit;
  FEnabled := Value;
  if not Enabled then SetStartLineBytePos(StartLineBytePos);
end;

procedure TSynEditSelection.ConstrainStartLineBytePos(var Value: TPoint);
begin
  Value.y := MinMax(Value.y, 1, Max(fLines.Count, 1));

  if (FCaret = nil) or FCaret.AllowPastEOL or (FCaret.FForcePastEOL > 0) then
    Value.x := Max(Value.x, 1)
  else
    Value.x := MinMax(Value.x, 1, length(Lines[Value.y - 1])+1);

  if (ActiveSelectionMode = smNormal) then begin
    if (Value.y >= 1) and (Value.y <= FLines.Count) then
      Value.x := AdjustBytePosToCharacterStart(Value.y,Value.x)
    else
      Value.x := 1;
  end;
end;

procedure TSynEditSelection.SetStartLineBytePos(Value : TPoint);
// logical position (byte)
var
  nInval1, nInval2: integer;
  WasAvail: boolean;
begin
  FStickyAutoExtend := False;
  FAltStartLinePos := -1;
  FAltStartBytePos := -1;
  FLeftCharPos  := -1;
  FRightCharPos := -1;
  WasAvail := SelAvail;

  ConstrainStartLineBytePos(Value);

  if WasAvail then begin
    if FStartLinePos < FEndLinePos then begin
      nInval1 := Min(Value.Y, FStartLinePos);
      nInval2 := Max(Value.Y, FEndLinePos);
    end else begin
      nInval1 := Min(Value.Y, FEndLinePos);
      nInval2 := Max(Value.Y, FStartLinePos);
    end;
    FInvalidateLinesMethod(nInval1, nInval2);
  end;
  FActiveSelectionMode := FSelectionMode;
  FForceSingleLineSelected := False;
  FHide := False;
  FStartLinePos := Value.Y;
  FStartBytePos := Value.X;
  FEndLinePos := Value.Y;
  FEndBytePos := Value.X;
  FFlags := FFLags - [sbViewedFirstPosValid, sbViewedLastPosValid];

  if FCaret <> nil then
    FLastCarePos := Point(FCaret.OldCharPos, FCaret.OldLinePos);
  if WasAvail then
    fOnChangeList.CallNotifyEvents(self);
end;

procedure TSynEditSelection.AdjustStartLineBytePos(Value: TPoint);
begin
  FLeftCharPos  := -1;
  FRightCharPos := -1;
  if FEnabled then begin
    ConstrainStartLineBytePos(Value);

    if (Value.X <> FStartBytePos) or (Value.Y <> FStartLinePos) then begin
      if (ActiveSelectionMode = smColumn) and (Value.X <> FStartBytePos) then
        FInvalidateLinesMethod(Min(FStartLinePos, Min(FEndLinePos, Value.Y)),
                               Max(FStartLinePos, Max(FEndLinePos, Value.Y)))
      else
      if (ActiveSelectionMode <> smColumn) or (FStartBytePos <> FEndBytePos) then
        FInvalidateLinesMethod(FStartLinePos, Value.Y);

      FStartLinePos := Value.Y;
      FStartBytePos := Value.X;
      FFlags := FFLags - [sbViewedFirstPosValid];
      if FCaret <> nil then
        FLastCarePos := Point(FCaret.OldCharPos, FCaret.OldLinePos);
      FOnChangeList.CallNotifyEvents(self);
    end;
  end;
end;

function TSynEditSelection.GetEndLineBytePos : TPoint;
begin
  Result.y := FEndLinePos;
  Result.x := FEndBytePos;
end;

procedure TSynEditSelection.SetEndLineBytePos(Value : TPoint);
{$IFDEF SYN_MBCSSUPPORT}
var
  s: string;
{$ENDIF}
begin
  FLeftCharPos  := -1;
  FRightCharPos := -1;
  if FEnabled then begin
    FStickyAutoExtend := False;

    Value.y := MinMax(Value.y, 1, Max(fLines.Count, 1));

    // ensure folded block at bottom line is in selection
    if (ActiveSelectionMode = smLine) and (FLines <> nil) and
       (FAutoExtend or FStickyAutoExtend)
    then begin
      if ( (FStartLinePos > Value.y) or
           ( (FStartLinePos = Value.y) and (FStartBytePos > Value.x) )
         ) and
         (not SelAvail)
      then
        FStartLinePos := ToPos(FLines.AddVisibleOffsetToTextIndex(ToIdx(FStartLinePos), 1)) - 1
      else
      if (Value.y < fLines.Count) then
        Value.y := ToPos(FLines.AddVisibleOffsetToTextIndex(ToIdx(Value.y), 1)) - 1;
    end;

    if (FCaret = nil) or FCaret.AllowPastEOL then
      Value.x := Max(Value.x, 1)
    else
      Value.x := MinMax(Value.x, 1, length(Lines[Value.y - 1])+1);

    if (ActiveSelectionMode = smNormal) then
      if (Value.y >= 1) and (Value.y <= fLines.Count) then
        Value.x := AdjustBytePosToCharacterStart(Value.y,Value.x)
      else
        Value.x := 1;

    if (Value.X <> FEndBytePos) or (Value.Y <> FEndLinePos) then begin
      {$IFDEF SYN_MBCSSUPPORT}
      if Value.Y <= fLines.Count then begin
        s := fLines[Value.Y - 1];
        if (Length(s) >= Value.X) and (mbTrailByte = ByteType(s, Value.X)) then
          Dec(Value.X);
      end;
      {$ENDIF}

      if (Value.X <> FEndBytePos) or (Value.Y <> FEndLinePos) then begin
        if (ActiveSelectionMode = smColumn) and (Value.X <> FEndBytePos) then
          FInvalidateLinesMethod(Min(FStartLinePos, Min(FEndLinePos, Value.Y)),
                                 Max(FStartLinePos, Max(FEndLinePos, Value.Y)))
        else
        if (ActiveSelectionMode <> smColumn) or (FStartBytePos <> FEndBytePos) then
          FInvalidateLinesMethod(FEndLinePos, Value.Y);
        FEndLinePos := Value.Y;
        FEndBytePos := Value.X;
        FFlags := FFLags - [sbViewedLastPosValid];
        if FCaret <> nil then
          FLastCarePos := Point(FCaret.OldCharPos, FCaret.OldLinePos);
        FOnChangeList.CallNotifyEvents(self);
      end;
    end;
  end;
end;

procedure TSynEditSelection.SetSelectionMode(const AValue: TSynSelectionMode);
begin
  FSelectionMode := AValue;
  SetActiveSelectionMode(AValue);
  fOnChangeList.CallNotifyEvents(self);
end;

procedure TSynEditSelection.SetActiveSelectionMode(const Value: TSynSelectionMode);
begin
  FStickyAutoExtend := False;
  if FActiveSelectionMode <> Value then begin
    FActiveSelectionMode := Value;
    if SelAvail then
      FInvalidateLinesMethod(-1, -1);
    FOnChangeList.CallNotifyEvents(self);
  end;
end;

procedure TSynEditSelection.SetForceSingleLineSelected(AValue: Boolean);
var
  WasAvail: Boolean;
begin
  if FForceSingleLineSelected = AValue then Exit;
  WasAvail := SelAvail;
  FForceSingleLineSelected := AValue;

  if WasAvail <> SelAvail then begin
    // ensure folded block at bottom line is in selection
    // only when selection is new (WasAvail = False)
    if SelAvail and (FAutoExtend or FStickyAutoExtend) then begin
      if IsBackwardSel then
        FStartLinePos := ToPos(FLines.AddVisibleOffsetToTextIndex(ToIdx(FStartLinePos), 1)) - 1
      else
        FEndLinePos := ToPos(FLines.AddVisibleOffsetToTextIndex(ToIdx(FEndLinePos), 1)) - 1;
    end;
    FInvalidateLinesMethod(Min(FStartLinePos, FEndLinePos),
                           Max(FStartLinePos, FEndLinePos) );
    fOnChangeList.CallNotifyEvents(self);
  end;
end;

procedure TSynEditSelection.SetHide(const AValue: Boolean);
begin
  if FHide = AValue then exit;
  FHide := AValue;
  FInvalidateLinesMethod(Min(FStartLinePos, FEndLinePos),
                         Max(FStartLinePos, FEndLinePos) );
  FOnChangeList.CallNotifyEvents(self);
end;

procedure TSynEditSelection.SetPersistent(const AValue: Boolean);
begin
  if FPersistent = AValue then exit;
  FPersistent := AValue;
  if (not FPersistent) and (FCaret <> nil) and
     not ( FCaret.IsAtLineByte(StartLineBytePos) or
           FCaret.IsAtLineByte(EndLineBytePos) )
  then
    Clear;
end;

// Only needed if the Selection is set from External
function TSynEditSelection.AdjustBytePosToCharacterStart(Line : integer; BytePos : integer) : integer;
begin
  Result := BytePos;
  if Result < 1 then
    Result := 1
  else if (Line >= 1) and (Line <= FLines.Count) then begin
    Result := FLines.LogicPosAdjustToChar(FLines[Line-1], Result, False);
  end;
  if Result <> BytePos then debugln(['Selection needed byte adjustment  Line=', Line, ' BytePos=', BytePos, ' Result=', Result]);
end;

procedure TSynEditSelection.DoLinesMappingChanged(Sender: TSynEditStrings;
  aIndex, aCount: Integer);
begin
  FFlags := FFLags - [sbViewedFirstPosValid, sbViewedLastPosValid];
end;

function TSynEditSelection.GetColumnEndBytePos(ALinePos: Integer): integer;
begin
  FInternalCaret.Invalidate;
  FInternalCaret.LineCharPos := Point(GetColumnRightCharPos, ALinePos);
  Result := FInternalCaret.BytePos;
end;

function TSynEditSelection.GetColumnStartBytePos(ALinePos: Integer): integer;
begin
  FInternalCaret.Invalidate;
  FInternalCaret.LineCharPos := Point(GetColumnLeftCharPos, ALinePos);
  Result := FInternalCaret.BytePos;
end;

function TSynEditSelection.GetFirstLineBytePos: TPoint;
begin
  if IsBackwardSel then
    Result := EndLineBytePos
  else
    Result := StartLineBytePos;
end;

function TSynEditSelection.GetLastLineBytePos: TPoint;
begin
  if IsBackwardSel then
    Result := StartLineBytePos
  else
    Result := EndLineBytePos;
end;

function TSynEditSelection.GetLastLineHasSelection: Boolean;
begin
  Result := (LastLineBytePos.x > 1) or
            ( (FActiveSelectionMode = smLine) and
              ( FForceSingleLineSelected or       // Selection may be zero lenght, but will be entire line
                (FEndLinePos <> FStartLinePos) or // Any selection in line-mode covers the last line
                (FEndBytePos <> FStartBytePos)
              )
            );
end;

function TSynEditSelection.GetColumnLeftCharPos: Integer;
begin
  if FLeftCharPos < 0 then begin
    FInternalCaret.Invalidate;
    FInternalCaret.LineBytePos := FirstLineBytePos;
    FLeftCharPos := FInternalCaret.CharPos;
    FInternalCaret.LineBytePos := LastLineBytePos;
    FRightCharPos := FInternalCaret.CharPos;
    if FLeftCharPos > FRightCharPos then
      SwapInt(FLeftCharPos, FRightCharPos);
  end;
  Result := FLeftCharPos;
end;

function TSynEditSelection.GetColumnRightCharPos: Integer;
begin
  if FLeftCharPos < 0 then begin
    FInternalCaret.Invalidate;
    FInternalCaret.LineBytePos := FirstLineBytePos;
    FLeftCharPos := FInternalCaret.CharPos;
    FInternalCaret.LineBytePos := LastLineBytePos;
    FRightCharPos := FInternalCaret.CharPos;
    if FLeftCharPos > FRightCharPos then
      SwapInt(FLeftCharPos, FRightCharPos);
  end;
  Result := FRightCharPos;
end;

function TSynEditSelection.GetViewedFirstLineCharPos: TPoint;
begin
  if not(sbViewedFirstPosValid in FFlags) then
    FViewedFirstStartLineCharPos := Lines.TextXYToViewXY(
      Lines.LogicalToPhysicalPos(FirstLineBytePos)
    );

  include(FFlags, sbViewedFirstPosValid);
  Result := FViewedFirstStartLineCharPos;
  if sbHasLineMapHandler in FFlags then begin
    Lines.AddChangeHandler(senrLineMappingChanged, @DoLinesMappingChanged);
    Include(FFlags, sbHasLineMapHandler);
  end;
end;

function TSynEditSelection.GetViewedLastLineCharPos: TPoint;
begin
  if not(sbViewedLastPosValid in FFlags) then
    FViewedLastEndLineCharPos := Lines.TextXYToViewXY(
      Lines.LogicalToPhysicalPos(LastLineBytePos)
    );
  include(FFlags, sbViewedLastPosValid);
  Result := FViewedLastEndLineCharPos;
  if sbHasLineMapHandler in FFlags then begin
    Lines.AddChangeHandler(senrLineMappingChanged, @DoLinesMappingChanged);
    Include(FFlags, sbHasLineMapHandler);
  end;
end;

procedure TSynEditSelection.SetAutoExtend(AValue: Boolean);
begin
  if FAutoExtend = AValue then Exit;
  FAutoExtend := AValue;
end;

procedure TSynEditSelection.SetCaret(const AValue: TSynEditCaret);
begin
  if FCaret = AValue then exit;
  if FCaret <> nil then
    Caret.RemoveChangeHandler(@DoCaretChanged);
  FCaret := AValue;
  if FCaret <> nil then
    Caret.AddChangeHandler(@DoCaretChanged);
end;

function TSynEditSelection.SelAvail : Boolean;
begin
  if FHide then exit(False);
  if (FActiveSelectionMode = smColumn) then begin
    Result := (FStartBytePos <> FEndBytePos) and (FStartLinePos = FEndLinePos);
    if (not Result) and (FStartLinePos <> FEndLinePos) then begin
      // Todo: Cache values, but we need notification, if ines are modified (even only by change of tabwidth...)
      Result := Lines.LogicalToPhysicalPos(StartLineBytePos).X <>
                Lines.LogicalToPhysicalPos(EndLineBytePos).X;
    end;
  end
  else
    Result := (FStartBytePos <> FEndBytePos) or (FStartLinePos <> FEndLinePos)
      or ( (FActiveSelectionMode = smLine) and FForceSingleLineSelected);
end;

function TSynEditSelection.SelCanContinue(ACaret: TSynEditCaret): Boolean;
begin
  if SelAvail then exit(True);
  Result := (not FHide) and
            (FActiveSelectionMode = smColumn) and (FEndLinePos = ACaret.LinePos) and
            (FEndBytePos = ACaret.BytePos);
end;

function TSynEditSelection.IsBackwardSel: Boolean;
begin
  Result := (FStartLinePos > FEndLinePos)
    or ((FStartLinePos = FEndLinePos) and (FStartBytePos > FEndBytePos));
end;

procedure TSynEditSelection.BeginMinimumSelection;
begin
  if SelAvail then begin
    FAltStartLinePos := FEndLinePos;
    FAltStartBytePos := FEndBytePos;
  end
  else begin
    FAltStartLinePos := -1;
    FAltStartBytePos := -1;
  end;
end;

procedure TSynEditSelection.SortSelectionPoints(AReverse: Boolean);
begin
  if IsBackwardSel xor AReverse then begin
    SwapInt(FStartLinePos, FEndLinePos);
    SwapInt(FStartBytePos, FEndBytePos);
    FFlags := FFLags - [sbViewedFirstPosValid, sbViewedLastPosValid];
  end;
end;

procedure TSynEditSelection.IgnoreNextCaretMove;
begin
  FIgnoreNextCaretMove := True;
end;

procedure TSynEditSelection.IncPersistentLock(AMode: TSynBlockPersistMode);
begin
  inc(FPersistentLock);
  if (sbpWeak = AMode) and (FWeakPersistentIdx = 0) then
    FWeakPersistentIdx := FPersistentLock;
  if (sbpStrong = AMode) and (FStrongPersistentIdx = 0) then
    FStrongPersistentIdx := FPersistentLock;
end;

procedure TSynEditSelection.DecPersistentLock;
begin
  dec(FPersistentLock);
  if FWeakPersistentIdx > FPersistentLock then
    FWeakPersistentIdx := 0;
  if FStrongPersistentIdx > FPersistentLock then
    FStrongPersistentIdx := 0;
  if (FPersistentLock = 0) and (FCaret <> nil) and FCaret.Locked then
    FLastCarePos := Point(FCaret.OldCharPos, FCaret.OldLinePos);
end;

procedure TSynEditSelection.Clear;
begin
  if Caret <> nil then
    StartLineBytePos := Caret.LineBytePos
  else
    StartLineBytePos := StartLineBytePos;
end;

procedure TSynEditSelection.AddBeforeSetSelTextHandler(AHandler: TSynBeforeSetSelTextEvent);
begin
  FOnBeforeSetSelText.Add(TMethod(AHandler));
end;

procedure TSynEditSelection.RemoveBeforeSetSelTextHandler(AHandler: TSynBeforeSetSelTextEvent);
begin
  FOnBeforeSetSelText.Remove(TMethod(AHandler));
end;

{ TSynEditScreenCaretTimer }

procedure TSynEditScreenCaretTimer.DoAfterPaint(Data: PtrInt);
begin
  FAfterPaintList.CallNotifyEvents(Self);
  while FAfterPaintList.Count > 0 do
    FAfterPaintList.Delete(FAfterPaintList.Count - 1);
end;

function TSynEditScreenCaretTimer.GetInterval: Integer;
begin
  Result := FTimer.Interval;
end;

procedure TSynEditScreenCaretTimer.SetInterval(AValue: Integer);
begin
  if AValue = FTimer.Interval then
    exit;

  if (AValue = 0) then begin
    FTimer.Enabled := False;
    FDisplayCycle := True;
    FTimer.Interval := 0;
  end
  else begin
    FTimer.Interval := AValue;
    FTimer.Enabled := FTimerEnabled;
  end;
  if FTimerEnabled then
    RestartCycle;
end;

procedure TSynEditScreenCaretTimer.DoTimer(Sender: TObject);
begin
  if FLocCount > 0 then begin
    include(FLocFlags, lfTimer);
    exit;
  end;
  FDisplayCycle := not FDisplayCycle;
  FTimerList.CallNotifyEvents(Self);
end;

constructor TSynEditScreenCaretTimer.Create;
begin
  FTimerList := TMethodList.Create;
  FAfterPaintList := TMethodList.Create;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimerEnabled := False;
  ResetInterval;
  FTimer.OnTimer := @DoTimer;
end;

destructor TSynEditScreenCaretTimer.Destroy;
begin
  Application.RemoveAsyncCalls(Self);
  FreeAndNil(FTimer);
  FreeAndNil(FTimerList);
  FreeAndNil(FAfterPaintList);
  inherited Destroy;
end;

procedure TSynEditScreenCaretTimer.AddAfterPaintHandler(AHandler: TNotifyEvent);
begin
  if FAfterPaintList.Count = 0 then
    Application.QueueAsyncCall(@DoAfterPaint, 0);
  FAfterPaintList.Add(TMethod(AHandler));
end;

procedure TSynEditScreenCaretTimer.AddHandler(AHandler: TNotifyEvent);
begin
  FTimerList.Add(TMethod(AHandler));
  if not FTimer.Enabled then
    RestartCycle;
end;

procedure TSynEditScreenCaretTimer.RemoveHandler(AHandler: TNotifyEvent);
begin
  FTimerList.Remove(TMethod(AHandler));
  if FTimerList.Count = 0 then begin
    FTimer.Enabled := False;
    FTimerEnabled := False;
  end;
end;

procedure TSynEditScreenCaretTimer.RemoveHandler(AHandlerOwner: TObject);
begin
  FTimerList.RemoveAllMethodsOfObject(AHandlerOwner);
  FAfterPaintList.RemoveAllMethodsOfObject(AHandlerOwner);
  if FTimerList.Count = 0 then begin
    FTimer.Enabled := False;
    FTimerEnabled := False;
  end;
end;

procedure TSynEditScreenCaretTimer.IncLock;
begin
  inc(FLocCount);
end;

procedure TSynEditScreenCaretTimer.DecLock;
begin
  if FLocCount > 0 then
    dec(FLocCount);
  if FLocCount > 0 then
    exit;

  if lfRestart in FLocFlags then
    RestartCycle
  else;
  if lfTimer in FLocFlags then
    DoTimer(nil);

  FLocFlags := [];
end;

procedure TSynEditScreenCaretTimer.AfterPaintEvent;
begin
  Application.RemoveAsyncCalls(Self);
  DoAfterPaint(0);
end;

procedure TSynEditScreenCaretTimer.ResetInterval;
{$IFDEF windows}
var
  i: windows.UINT;
{$ENDIF}
begin
  {$IFDEF windows}
  i := GetCaretBlinkTime;
  if (i = high(i)) then i := 0;
  Interval := i;
  {$ELSE}
  Interval := 500;
  {$ENDIF}
  RestartCycle;
end;

procedure TSynEditScreenCaretTimer.RestartCycle;
begin
  if FLocCount > 0 then begin
    include(FLocFlags, lfRestart);
    exit;
  end;
  if FTimer.Interval = 0 then begin
    FTimerList.CallNotifyEvents(Self);
    exit;
  end;

  if FTimerList.Count = 0 then exit;
  FTimer.Enabled := False;
  FTimerEnabled := False;
  FDisplayCycle := False;
  DoTimer(nil);
  FTimer.Enabled := True;
  FTimerEnabled := True;
end;

{ TSynEditScreenCaretPainter }

function TSynEditScreenCaretPainter.GetHandle: HWND;
begin
  Result := FHandleOwner.Handle;
end;

function TSynEditScreenCaretPainter.GetHandleAllocated: Boolean;
begin
  Result := FHandleOwner.HandleAllocated;
end;

procedure TSynEditScreenCaretPainter.Init;
begin
  //
end;

constructor TSynEditScreenCaretPainter.Create(AHandleOwner: TWinControl;
  AOwner: TSynEditScreenCaret);
begin
  FLeft := -1;
  FTop := -1;
  inherited Create;
  FHandleOwner := AHandleOwner;
  FOwner := AOwner;
  Init;
end;

function TSynEditScreenCaretPainter.CreateCaret(w, h: Integer): Boolean;
begin
  FLeft := -1;
  FTop := -1;
  FWidth := w;
  FHeight := h;
  FCreated := True;
  FShowing := False;
  Result := True;
end;

function TSynEditScreenCaretPainter.DestroyCaret: Boolean;
begin
  FCreated := False;
  FShowing := False;
  Result := True;
end;

function TSynEditScreenCaretPainter.HideCaret: Boolean;
begin
  FShowing := False;
  Result := True;
end;

function TSynEditScreenCaretPainter.ShowCaret: Boolean;
begin
  FShowing := True;
  Result := True;
end;

function TSynEditScreenCaretPainter.SetCaretPosEx(x, y: Integer): Boolean;
begin
  FLeft := x;
  FTop := y;
  FNeedPositionConfirmed := False;
  Result := True;
end;

procedure TSynEditScreenCaretPainter.BeginScroll(dx, dy: Integer; const rcScroll,
  rcClip: TRect);
begin
  FInScroll := True;
  FScrollX := dx;
  FScrollY := dy;
  FScrollRect := rcScroll;
  FScrollClip := rcClip;
end;

procedure TSynEditScreenCaretPainter.FinishScroll(dx, dy: Integer; const rcScroll,
  rcClip: TRect; Success: Boolean);
begin
  FInScroll := False;
end;

procedure TSynEditScreenCaretPainter.BeginPaint(rcClip: TRect);
begin
  FInPaint := True;
  FPaintClip := rcClip;
end;

procedure TSynEditScreenCaretPainter.FinishPaint(rcClip: TRect);
begin
  FInPaint := False;
end;

procedure TSynEditScreenCaretPainter.WaitForPaint;
begin
  //
end;

{ TSynEditScreenCaretPainterSystem }

procedure TSynEditScreenCaretPainterSystem.BeginScroll(dx, dy: Integer;
  const rcScroll, rcClip: TRect);
begin
  {$IFDEF LCLGTK1}
  HideCaret;
  {$ENDIF}
  {$IFDEF LCLGTK2}
  HideCaret;
  {$ENDIF}

  inherited BeginScroll(dx, dy, rcScroll, rcClip);
end;

procedure TSynEditScreenCaretPainterSystem.FinishScroll(dx, dy: Integer; const rcScroll,
  rcClip: TRect; Success: Boolean);
begin
  inherited FinishScroll(dx, dy, rcScroll, rcClip, Success);
  if Success then
    inherited SetCaretPosEx(-1, -1);
  FNeedPositionConfirmed := True;
end;

procedure TSynEditScreenCaretPainterSystem.BeginPaint(rcClip: TRect);
begin
  inherited BeginPaint(rcClip);
  if Showing then
    if not HideCaret then
      DestroyCaret; // only if was Showing
end;

function TSynEditScreenCaretPainterSystem.CreateCaret(w, h: Integer): Boolean;
begin
  // do not create caret during paint / Issue 0021924
  Result := HandleAllocated and not InPaint;
  if not Result then
    exit;
  inherited CreateCaret(w, h);
  inherited SetCaretPosEx(-1, -1);
  Result := LCLIntf.CreateCaret(Handle, 0, w, h);
  SetCaretRespondToFocus(Handle, False); // Only for GTK
  if not Result then inherited DestroyCaret;
end;

function TSynEditScreenCaretPainterSystem.DestroyCaret: Boolean;
begin
  Result := inherited DestroyCaret;
  if HandleAllocated then
    Result := LCLIntf.DestroyCaret(Handle);
end;

function TSynEditScreenCaretPainterSystem.HideCaret: Boolean;
begin
  inherited HideCaret;
  if HandleAllocated then
    Result := LCLIntf.HideCaret(Handle)
  else
    Result := False;
end;

function TSynEditScreenCaretPainterSystem.ShowCaret: Boolean;
begin
  Result := HandleAllocated;
  if not Result then
    exit;
  inherited ShowCaret;
  Result := LCLIntf.ShowCaret(Handle);
end;

function TSynEditScreenCaretPainterSystem.SetCaretPosEx(x, y: Integer): Boolean;
begin
  Result := HandleAllocated;
  if not Result then
    exit;
  inherited SetCaretPosEx(x, y);
  Result := LCLIntf.SetCaretPosEx(Handle, x, y);
end;

{ TSynEditScreenCaretPainterInternal }

function TSynEditScreenCaretPainterInternal.dbgsIRState(s: TIsInRectState
  ): String;
begin
  WriteStr(Result, s);
end;

procedure TSynEditScreenCaretPainterInternal.DoTimer(Sender: TObject);
begin
  assert(not((not Showing) and FIsDrawn), 'TSynEditScreenCaretPainterInternal.DoTimer: not((not Showing) and FIsDrawn)');
  if (FState <> []) then
    ExecAfterPaint;

  if (not Showing) or NeedPositionConfirmed then exit;
  if FIsDrawn <> FOwner.PaintTimer.DisplayCycle then
    Paint;
end;

procedure TSynEditScreenCaretPainterInternal.DoPaint(ACanvas: TCanvas; X, Y, H, W: Integer);
var
  l: Integer;
  am: TAntialiasingMode;
begin
  if (ForcePaintEvents and (not FInPaint)) or
     FWaitForPaint
  then begin
   Invalidate;
   exit;
  end;

  am := ACanvas.AntialiasingMode;
  FSavePen.Assign(ACanvas.Pen);

  l := X + W div 2;
  ACanvas.MoveTo(l, Y);
  ACanvas.Pen.Mode := pmNotXOR;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Color := FColor;
  ACanvas.AntialiasingMode := amOff;
  ACanvas.pen.EndCap := pecFlat;
  ACanvas.pen.Width := Width;
  ACanvas.LineTo(l, Y+H);

  ACanvas.Pen.Assign(FSavePen);
  ACanvas.AntialiasingMode := am;
end;

procedure TSynEditScreenCaretPainterInternal.Paint;
begin
  if not HandleAllocated then begin
    FIsDrawn := False;
    exit;
  end;

  if FInPaint or FInScroll then begin
    if FCanPaint then
      FIsDrawn := not FIsDrawn; //change the state, that is applied at the end of paint
    exit;
  end;

  if (FState <> []) then
    ExecAfterPaint;

  FIsDrawn := not FIsDrawn;
  DoPaint(CurrentCanvas, FLeft, FTop, FHeight, FWidth);
end;

procedure TSynEditScreenCaretPainterInternal.Invalidate;
var
  r: TRect;
begin
  r.Left := Left;
  r.Top := Top;
  r.Right := Left+Width+1;
  r.Bottom := Top+Height+1;
  InvalidateRect(Handle, @r, False);
end;

procedure TSynEditScreenCaretPainterInternal.AddAfterPaint(AStates: TPainterStates);
begin
  if not(psAfterPaintAdded in FState) then
    FOwner.PaintTimer.AddAfterPaintHandler(@DoAfterPaint);
  FState := FState + [psAfterPaintAdded] + AStates;
end;

procedure TSynEditScreenCaretPainterInternal.DoAfterPaint(Sender: TObject);
begin
  Exclude(FState, psAfterPaintAdded);
  DoTimer(nil);
end;

procedure TSynEditScreenCaretPainterInternal.ExecAfterPaint;
begin
  if FInPaint or FInScroll then
    exit;

  if (psCleanOld in FState) then begin
    DoPaint(CurrentCanvas, FOldX, FOldY, FOldH, FOldW);
    Exclude(FState, psCleanOld);
  end;

  if (psRemoveTimer in FState) and not(FInPaint or FInScroll) then begin
    FOwner.PaintTimer.RemoveHandler(@DoTimer);
    Exclude(FState, psRemoveTimer);
  end;

end;

function TSynEditScreenCaretPainterInternal.CurrentCanvas: TCanvas;
begin
  Result := TCustomControl(FHandleOwner).Canvas;
end;

procedure TSynEditScreenCaretPainterInternal.SetColor(AValue: TColor);
var
  d: Boolean;
begin
  if FColor = AValue then Exit;

  d := FIsDrawn;
  if FIsDrawn then Paint;
  FColor := AValue;
  if d then Paint;
end;

function TSynEditScreenCaretPainterInternal.IsInRect(ARect: TRect): TIsInRectState;
begin
  Result := IsInRect(ARect, Left, Top, Width, Height);
end;

function TSynEditScreenCaretPainterInternal.IsInRect(ARect: TRect; X, Y, W,
  H: Integer): TIsInRectState;
begin
  if (Y >= ARect.Bottom) or (X >= ARect.Right) or (Y+H < ARect.Top) or (X+W < ARect.Left)
  then
    Result := irOutside
  else
  if (Y >= ARect.Top) and (X >= ARect.Left) and (Y+H < ARect.Bottom) and (X+W < ARect.Right)
  then
    Result := irInside
  else
    Result := irPartInside;
end;

procedure TSynEditScreenCaretPainterInternal.Init;
begin
  {$IFDEF LCLWin32}
    FForcePaintEvents := False;
  {$ELSE}
    FForcePaintEvents := True;
  {$ENDIF}
  FSavePen := TPen.Create;
  FColor := clBlack;
  FOldY := -1;
  FCanPaint := True;
  inherited Init;
end;

procedure TSynEditScreenCaretPainterInternal.BeginScroll(dx, dy: Integer; const rcScroll,
  rcClip: TRect);
var
  NewTop, NewHeight: Integer;
begin
  assert(not((FInPaint or FInScroll)), 'TSynEditScreenCaretPainterInternal.BeginScroll: not((FInPaint or FInScroll))');
  if (FState <> []) then
    ExecAfterPaint;
  {$IFnDEF SynCaretHideInSroll}
  if not FShowing then
    exit;
  {$ENDIF}

  {$IFDEF SynCaretHideInSroll}
  if not ((IsInRect(rcClip) = irOutside) and (IsInRect(rcScroll) = irOutside)) then begin
    HideCaret;
    inherited SetCaretPosEx(-1,-1);
  end;
  {$ELSE}
  FInRect     := IsInRect(rcScroll);
  NewTop := Top + dy;
  NewHeight := FOwner.ClippedPixelHeihgh(NewTop);
  // Caret must either be all irInside or all irOutside (all the same / not mixed)
  if (FInRect <> IsInRect(rcClip)) or
     (FInRect <> IsInRect(rcClip, Left+dx, NewTop, Width, Height)) or
     (FInRect = irPartInside) or
     // or top/bottom most => might change height afterwards
     (NewTop <> Top+dy) or (NewHeight <> Height)
  then begin
    HideCaret;
    inherited SetCaretPosEx(-1,-1);
  end;
  {$ENDIF}

  FCanPaint := False;

  inherited BeginScroll(dx, dy, rcScroll, rcClip);
end;

procedure TSynEditScreenCaretPainterInternal.FinishScroll(dx, dy: Integer; const rcScroll,
  rcClip: TRect; Success: Boolean);
begin
  {$IFnDEF SynCaretHideInSroll}
  if (not FShowing) then begin
    if FInScroll then
      inherited FinishScroll(dx, dy, rcScroll, rcClip, Success);
    exit;
  end;
  {$ENDIF}

  assert(FInScroll, 'TSynEditScreenCaretPainterInternal.FinishScroll: FInScroll');
  assert((FState-[psAfterPaintAdded]) = [], 'TSynEditScreenCaretPainterInternal.FinishScroll: FState = []');
  inherited FinishScroll(dx, dy, rcScroll, rcClip, Success);
  FCanPaint := True;
  {$IFnDEF SynCaretHideInSroll}
  if (Top >= 0) and (FInRect <> irOutside) then begin
    if Success then begin
      inherited SetCaretPosEx(Left+dx, Top+dy);
      FOwner.FDisplayPos.Offset(dx, dy);
    end
    else
      FNeedPositionConfirmed := True;
  end;
  {$ENDIF}
  FOwner.PaintTimer.RestartCycle;
end;

procedure TSynEditScreenCaretPainterInternal.BeginPaint(rcClip: TRect);
begin
  assert(not (FInPaint or FInScroll), 'TSynEditScreenCaretPainterInternal.BeginPaint: not (FInPaint or FInScroll)');

  FInRect := IsInRect(rcClip);
  FCanPaint := FInRect = irInside;
  FWaitForPaint := False;

  if (psCleanOld in FState) and not FCanPaint then begin
    if IsInRect(rcClip, FOldX, FOldY, FOldW, FOldH) <> irInside then begin
      debugln(['TSynEditScreenCaretPainterInternal.BeginPaint Invalidate for psCleanOld']);
      Invalidate;
    end;
    Exclude(FState, psCleanOld);
  end;

  if not(psCleanOld in FState) then begin
    FOldX := Left;
    FOldY := Top;
    FOldW := Width;
    FOldH := Height;
  end;

  inherited BeginPaint(rcClip);
end;

procedure TSynEditScreenCaretPainterInternal.FinishPaint(rcClip: TRect);
begin
  assert(FInPaint, 'TSynEditScreenCaretPainterInternal.FinishPaint: FInPaint');
  assert(FCanPaint = (IsInRect(rcClip)= irInside), 'TSynEditScreenCaretPainterInternal.FinishPaint: FCanPaint = (IsInRect(rcClip)= irInside)');
  assert(FCanPaint = (IsInRect(FPaintClip)= irInside), 'TSynEditScreenCaretPainterInternal.FinishPaint: FCanPaint = (IsInRect(rcClip)= irInside)');

  // partly restore IF irPartInside;
  // Better recalc size to remainder outside cliprect
  if (psCleanOld in FState) and (not ForcePaintEvents) then
    DoPaint(CurrentCanvas, FOldX, FOldY, FOldH, FOldW);

  // if changes where made, then FIsDrawn is always false
  if FIsDrawn and (FInRect <> irOutside) then
    DoPaint(CurrentCanvas, FLeft, FTop, FHeight, FWidth); // restore any part that is in the cliprect

  inherited FinishPaint(rcClip);
  FCanPaint := True;
end;

procedure TSynEditScreenCaretPainterInternal.WaitForPaint;
begin
  inherited WaitForPaint;
  FWaitForPaint := True;
end;

destructor TSynEditScreenCaretPainterInternal.Destroy;
begin
  assert(not(FInPaint or FInScroll), 'TSynEditScreenCaretPainterInternal.Destroy: not(FInPaint or FInScroll)');
  if FOwner.HasPaintTimer then
    FOwner.PaintTimer.RemoveHandler(Self);
  HideCaret;
  FreeAndNil(FSavePen);
  inherited Destroy;
end;

function TSynEditScreenCaretPainterInternal.CreateCaret(w, h: Integer): Boolean;
begin
  DestroyCaret;
  Result := inherited CreateCaret(w, h);
  if InPaint then  // InScroll ??
    FCanPaint := IsInRect(FPaintClip) = irInside;
  Result := True;
end;

function TSynEditScreenCaretPainterInternal.DestroyCaret: Boolean;
begin
  HideCaret;
  inherited DestroyCaret;
  Result := True;
end;

function TSynEditScreenCaretPainterInternal.HideCaret: Boolean;
begin
  inherited HideCaret;

  if (not FCanPaint) and FIsDrawn then begin
    AddAfterPaint([psCleanOld, psRemoveTimer]);
    FIsDrawn := False;
    exit(True);
  end;

  FOwner.PaintTimer.RemoveHandler(@DoTimer);
  if FIsDrawn then Paint;
  assert(not FIsDrawn, 'TSynEditScreenCaretPainterInternal.HideCaret: not FIsDrawn');
  Result := True;
end;

function TSynEditScreenCaretPainterInternal.ShowCaret: Boolean;
begin
  if Showing then exit(True);
  inherited ShowCaret;
  Exclude(FState, psRemoveTimer);
//  Exclude(FState, psCleanOld); // only if not moved

  FOwner.PaintTimer.RemoveHandler(@DoTimer);
  FOwner.PaintTimer.AddHandler(@DoTimer);
  FOwner.PaintTimer.RestartCycle;
  Result := True;
end;

function TSynEditScreenCaretPainterInternal.SetCaretPosEx(x, y: Integer): Boolean;
var
  d: Boolean;
begin
  if (not FCanPaint) and FIsDrawn then begin
    AddAfterPaint([psCleanOld]);
    FIsDrawn := False;
  end;

  d := FIsDrawn;
  if d then Paint;
  inherited SetCaretPosEx(x, y);

  if InPaint then  // InScroll ??
    FCanPaint := IsInRect(FPaintClip) = irInside;

  if d then Paint;
  // else aftecpaint needs show
  FOwner.PaintTimer.RestartCycle;  // if not d ??
  Result := True;
end;

{ TSynEditScreenCaret }

constructor TSynEditScreenCaret.Create(AHandleOwner: TWinControl);
begin
  {$ifdef LCLMui}
  Create(AHandleOwner, TSynEditScreenCaretPainterInternal);
  {$else}
  Create(AHandleOwner, TSynEditScreenCaretPainterSystem);
  {$endif}
end;

constructor TSynEditScreenCaret.Create(AHandleOwner: TWinControl;
  APainterClass: TSynEditScreenCaretPainterClass);
begin
  inherited Create;
  FCaretPainter := APainterClass.Create(AHandleOwner, Self);
  FLockCount := -1;
  ResetCaretTypeSizes;
  FHandleOwner := AHandleOwner;
  FVisible := False;
  FClipExtraPixel := 0;
  FLockCount := 0;
end;

procedure TSynEditScreenCaret.ChangePainter(APainterClass: TSynEditScreenCaretPainterClass);
begin
  DestroyCaret(True);
  FreeAndNil(FCaretPainter);
  FCaretPainter := APainterClass.Create(FHandleOwner, Self);
  UpdateDisplay;
end;

destructor TSynEditScreenCaret.Destroy;
begin
  DestroyCaret;
  FreeAndNil(FCaretPainter);
  if FPaintTimerOwned then
    FreeAndNil(FPaintTimer);
  inherited Destroy;
end;

procedure TSynEditScreenCaret.BeginScroll(dx, dy: Integer; const rcScroll, rcClip: TRect);
begin
  Painter.BeginScroll(dx, dy, rcScroll, rcClip);
end;

procedure TSynEditScreenCaret.FinishScroll(dx, dy: Integer; const rcScroll, rcClip: TRect;
  Success: Boolean);
begin
  Painter.FinishScroll(dx, dy, rcScroll, rcClip, Success);
end;

procedure TSynEditScreenCaret.BeginPaint(rcClip: TRect);
begin
  Painter.BeginPaint(rcClip);
end;

procedure TSynEditScreenCaret.FinishPaint(rcClip: TRect);
begin
  Painter.FinishPaint(rcClip);
end;

procedure TSynEditScreenCaret.WaitForPaint;
begin
  FCaretPainter.WaitForPaint;
end;

procedure TSynEditScreenCaret.Hide;
begin
  HideCaret;
end;

procedure TSynEditScreenCaret.DestroyCaret(SkipHide: boolean = False);
begin
  if Painter.Created then begin
    {$IFDeF SynCaretDebug}
    debugln(['SynEditCaret DestroyCaret for HandleOwner=',FHandleOwner, ' DebugShowCount=', FDebugShowCount, ' FVisible=', FVisible, ' FCurrentVisible=', Painter.Showing]);
    {$ENDIF}
    FCaretPainter.DestroyCaret;
  end;
  if not SkipHide then
    FVisible := False;
end;

procedure TSynEditScreenCaret.Lock;
begin
  inc(FLockCount);
  if FPaintTimer <> nil then
    FPaintTimer.IncLock;
end;

procedure TSynEditScreenCaret.UnLock;
begin
  dec(FLockCount);
  if (FLockCount=0) then begin
    if (sclfUpdateDisplayType in FLockFlags) then UpdateDisplayType;
    if (sclfUpdateDisplay in FLockFlags)     then UpdateDisplay;
  end;
  if FPaintTimer <> nil then
    FPaintTimer.DecLock;
end;

procedure TSynEditScreenCaret.AfterPaintEvent;
begin
  if FPaintTimer <> nil then
    FPaintTimer.AfterPaintEvent;

end;

procedure TSynEditScreenCaret.ResetCaretTypeSizes;
var
  i: TSynCaretType;
begin
  for i := low(TSynCaretType) to high(TSynCaretType) do begin
    FCustomPixelWidth[i] := 0;
  end;
  if FLockCount >= 0 then UpdateDisplayType;
end;

procedure TSynEditScreenCaret.SetCaretTypeSize(AType: TSynCaretType; AWidth, AHeight, AXOffs,
  AYOffs: Integer; AFlags: TSynCustomCaretSizeFlags);
begin
  FCustomPixelWidth[AType] := AWidth;
  FCustomPixelHeight[AType] := AHeight;
  FCustomOffsetX[AType] := AXOffs;
  FCustomOffsetY[AType] := AYOffs;
  FCustomFlags[AType] := AFlags;
  if FDisplayType = AType then UpdateDisplayType;
end;

procedure TSynEditScreenCaret.SetClipRight(const AValue: Integer);
begin
  if FClipRight = AValue then exit;
  FClipRight := AValue;
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.SetCharHeight(const AValue: Integer);
begin
  if FCharHeight = AValue then exit;
  FCharHeight := AValue;
  UpdateDisplayType;
end;

function TSynEditScreenCaret.GetHandle: HWND;
begin
  Result :=FHandleOwner.Handle;
end;

function TSynEditScreenCaret.GetHandleAllocated: Boolean;
begin
  Result :=FHandleOwner.HandleAllocated;
end;

procedure TSynEditScreenCaret.SetCharWidth(const AValue: Integer);
begin
  if FCharWidth = AValue then exit;
  FCharWidth := AValue;
  UpdateDisplayType;
end;

procedure TSynEditScreenCaret.SetDisplayPos(const AValue: TPoint);
begin
  if (FDisplayPos.x = AValue.x) and (FDisplayPos.y = AValue.y) and
     (FVisible = Painter.Showing) and (not Painter.NeedPositionConfirmed)
  then
    exit;
  FDisplayPos := AValue;
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.SetDisplayType(const AType: TSynCaretType);
begin
  if FDisplayType = AType then exit;
  FDisplayType := AType;
  UpdateDisplayType;
end;

procedure TSynEditScreenCaret.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then exit;
  FVisible := AValue;
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.UpdateDisplayType;
begin
  if FLockCount > 0 then begin
    Include(FLockFlags, sclfUpdateDisplayType);
    exit;
  end;
  Exclude(FLockFlags, sclfUpdateDisplayType);

  case FDisplayType of
    ctVerticalLine, ctCostum:
      begin
        FPixelWidth     := 2;
        FPixelHeight    := FCharHeight - 2;
        FOffsetX        := -1;
        FOffsetY        :=  1;
        FExtraLinePixel :=  1;
      end;
    ctBlock:
      begin
        FPixelWidth     := FCharWidth;
        FPixelHeight    := FCharHeight - 2;
        FOffsetX        := 0;
        FOffsetY        := 1;
        FExtraLinePixel := FCharWidth;
      end;
    ctHalfBlock:
      begin
        FPixelWidth     := FCharWidth;
        FPixelHeight    := (FCharHeight - 2) div 2;
        FOffsetX        := 0;
        FOffsetY        := FPixelHeight + 1;
        FExtraLinePixel := FCharWidth;
      end;
    ctHorizontalLine:
      begin
        FPixelWidth     := FCharWidth;
        FPixelHeight    := 2;
        FOffsetX        := 0;
        FOffsetY        := FCharHeight - 1;
        FExtraLinePixel := FCharWidth;
      end;
  end;

  if (FCustomPixelWidth[FDisplayType] <> 0) then begin
    if ccsRelativeWidth in FCustomFlags[FDisplayType]
    then FPixelWidth     := FCharWidth * FCustomPixelWidth[FDisplayType] div 1024
    else FPixelWidth     := FCustomPixelWidth[FDisplayType];
    if ccsRelativeLeft in FCustomFlags[FDisplayType]
    then FOffsetX        := FCharWidth * FCustomOffsetX[FDisplayType] div 1024
    else FOffsetX        := FCustomOffsetX[FDisplayType];
    FExtraLinePixel := Max(0, FPixelWidth + FOffsetX);
  end;
  if (FCustomPixelHeight[FDisplayType] <> 0) then begin
    if ccsRelativeHeight in FCustomFlags[FDisplayType]
    then FPixelHeight    := FCharHeight * FCustomPixelHeight[FDisplayType] div 1024
    else FPixelHeight    := FCustomPixelHeight[FDisplayType];
    if ccsRelativeTop in FCustomFlags[FDisplayType]
    then FOffsetY        := FCharHeight * FCustomOffsetY[FDisplayType] div 1024
    else FOffsetY        := FCustomOffsetY[FDisplayType];
  end;

  CalcExtraLineChars;
  DestroyCaret(True);
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.SetClipBottom(const AValue: Integer);
begin
  if FClipBottom = AValue then exit;
  FClipBottom := AValue;
  UpdateDisplay;
end;

function TSynEditScreenCaret.GetPaintTimer: TSynEditScreenCaretTimer;
begin
  if FPaintTimer = nil then begin
    FPaintTimer := TSynEditScreenCaretTimer.Create;
    FPaintTimerOwned := True;
    FPaintTimer.FLocCount := FLockCount;
  end;
  Result := FPaintTimer;
end;

function TSynEditScreenCaret.GetHasPaintTimer: Boolean;
begin
  Result := FPaintTimer <> nil;
end;

procedure TSynEditScreenCaret.SetClipExtraPixel(AValue: Integer);
begin
  if FClipExtraPixel = AValue then Exit;
  {$IFDeF SynCaretDebug}
  debugln(['SynEditCaret ClipRect for HandleOwner=',FHandleOwner, ' ExtraPixel=', dbgs(AValue)]);
  debugln(['TSynEditScreenCaret.SetClipExtraPixel ',FHandleOwner,' Focus=',FindControl(GetFocus)]);
  {$ENDIF}
  FClipExtraPixel := AValue;
  CalcExtraLineChars;
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.SetClipLeft(const AValue: Integer);
begin
  if FClipLeft = AValue then exit;
  FClipLeft := AValue;
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.SetClipRect(const AValue: TRect);
begin
  if (FClipLeft = AValue.Left) and (FClipRight = AValue.Right) and
     (FClipTop = AValue.Top) and (FClipBottom = AValue.Bottom)
  then
    exit;
  {$IFDeF SynCaretDebug}
  debugln(['SynEditCaret ClipRect for HandleOwner=',FHandleOwner, ' Rect=', dbgs(AValue)]);
  {$ENDIF}
  FClipLeft   := AValue.Left;
  FClipRight  := AValue.Right;
  FClipTop    := AValue.Top;
  FClipBottom := AValue.Bottom;
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.SetClipTop(const AValue: Integer);
begin
  if FClipTop = AValue then exit;
  FClipTop := AValue;
  UpdateDisplay;
end;

procedure TSynEditScreenCaret.CalcExtraLineChars;
var
  OldExtraChars: Integer;
begin
  if FCharWidth = 0 then exit;
  OldExtraChars := FExtraLineChars;
  FExtraLineChars := Max(0, FExtraLinePixel - FClipExtraPixel + FCharWidth)
                     div FCharWidth;
  if (FExtraLineChars <> OldExtraChars) and assigned(FOnExtraLineCharsChanged) then
    FOnExtraLineCharsChanged(Self);
end;

procedure TSynEditScreenCaret.SetPaintTimer(AValue: TSynEditScreenCaretTimer);
begin
  assert(FPaintTimer = nil, 'TSynEditScreenCaret.SetPaintTimer: FPaintTimer = nil');
  if FPaintTimer = nil then
    FPaintTimer := AValue;
end;

procedure TSynEditScreenCaret.UpdateDisplay;
begin
  if FLockCount > 0 then begin
    Include(FLockFlags, sclfUpdateDisplay);
    exit;
  end;
  Exclude(FLockFlags, sclfUpdateDisplay);

  if FVisible then
    ShowCaret
  else
    HideCaret;
end;

function TSynEditScreenCaret.ClippedPixelHeihgh(var APxTop: Integer): Integer;
begin
  Result := FPixelHeight;
  if APxTop + Result >= FClipBottom then
    Result := FClipBottom - APxTop - 1;
  if APxTop < FClipTop then begin
    Result := Result - (FClipTop - APxTop);
    APxTop := FClipTop;
  end;
end;

procedure TSynEditScreenCaret.ShowCaret;
var
  x, y, w, h: Integer;
begin
  if not HandleAllocated then
    exit;
  x := FDisplayPos.x + FOffsetX;
  y := FDisplayPos.y + FOffsetY;
  w := FPixelWidth;
  h := ClippedPixelHeihgh(y);
  if x + w >= FClipRight then
    w := FClipRight - x - 1;
  if x < FClipLeft then begin
    w := w - (FClipLeft - w);
    x := FClipLeft;
  end;
  if (w <= 0) or (h < 0) or
     (x < FClipLeft) or (x >= FClipRight) or
     (y < FClipTop) or (y >= FClipBottom)
  then begin
    HideCaret;
    exit;
  end;

  if (not Painter.Created) or (FCaretPainter.Width <> w) or (FCaretPainter.Height <> h) then begin
    {$IFDeF SynCaretDebug}
    debugln(['SynEditCaret CreateCaret for HandleOwner=',FHandleOwner, ' DebugShowCount=', FDebugShowCount, ' Width=', w, ' pref-width=', FPixelWidth, ' Height=', FPixelHeight, '  FCurrentCreated=',Painter.Created,  ' FCurrentVisible=',Painter.Showing]);
    FDebugShowCount := 0;
    {$ENDIF}
    // // Create caret includes destroy
    FCaretPainter.CreateCaret(w, h);
  end;
  if (x <> Painter.Left) or (y <> Painter.Top) or (Painter.NeedPositionConfirmed) then begin
    {$IFDeF SynCaretDebug}
    debugln(['SynEditCaret SetPos for HandleOwner=',FHandleOwner, ' x=', x, ' y=',y]);
    {$ENDIF}
    FCaretPainter.SetCaretPosEx(x, y);
  end;
  if (not Painter.Showing) then begin
    {$IFDeF SynCaretDebug}
    debugln(['SynEditCaret ShowCaret for HandleOwner=',FHandleOwner, ' FDebugShowCount=',FDebugShowCount, ' FVisible=', FVisible, ' FCurrentVisible=', Painter.Showing]);
    inc(FDebugShowCount);
    {$ENDIF}
    if not FCaretPainter.ShowCaret then begin
      {$IFDeF SynCaretDebug}
      debugln(['SynEditCaret ShowCaret FAILED for HandleOwner=',FHandleOwner, ' FDebugShowCount=',FDebugShowCount]);
      {$ENDIF}
      DestroyCaret(True);
    end;
  end;
end;

procedure TSynEditScreenCaret.HideCaret;
begin
  if not HandleAllocated then
    exit;
  if not Painter.Created then exit;
  if Painter.Showing then begin
    {$IFDeF SynCaretDebug}
    debugln(['SynEditCaret HideCaret for HandleOwner=',FHandleOwner, ' FDebugShowCount=',FDebugShowCount, ' FVisible=', FVisible, ' FCurrentVisible=', Painter.Showing]);
    dec(FDebugShowCount);
    {$ENDIF}
    if FCaretPainter.HideCaret then
    else begin
      {$IFDeF SynCaretDebug}
      debugln(['SynEditCaret HideCaret FAILED for HandleOwner=',FHandleOwner, ' FDebugShowCount=',FDebugShowCount]);
      {$ENDIF}
      DestroyCaret(True);
    end;
  end;
end;

end.

