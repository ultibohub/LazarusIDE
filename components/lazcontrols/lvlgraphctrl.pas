{ LvlGraphCtrl

  Copyright (C) 2013 Lazarus team

  This library is free software; you can redistribute it and/or modify it
  under the same terms as the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
}
unit LvlGraphCtrl;
{off $DEFINE LvlGraphConsistencyCheck}
{off $DEFINE CheckMinXGraph}

{$mode objfpc}{$H+}
{$IFDEF LvlGraphConsistencyCheck}
  {$ASSERTIONS ON}
{$ELSE}
  {$ASSERTIONS OFF}
{$ENDIF}

interface

uses
  Classes, SysUtils, Types, Math, TypInfo, FPimage, FPCanvas, AVL_Tree,
  // LCL
  LMessages, LCLType, LCLIntf, Graphics, Controls, ImgList, Forms, Themes,
  // LazUtils
  GraphType, LazLoggerBase, AvgLvlTree;

type
  TLazCtrlPalette = array of TFPColor;

const
  DefaultLvlGraphNodeImageEffect = gdeNormal;
type
  TLvlGraph = class;
  TLvlGraphEdge = class;
  TLvlGraphLevel = class;
  TLvlGraphNode = class;
  TLvlGraphNodeArray = array of TLvlGraphNode;

  { TLvlGraphNode }

  TLvlGraphNode = class(TPersistent)
  private
    FCaption: string;
    FColor: TFPColor;
    FDrawnCaptionRect: TRect;
    FGraph: TLvlGraph;
    FImageEffect: TGraphicsDrawEffect;
    FImageIndex: integer;
    FInEdges: TFPList; // list of TLvlGraphEdge
    FDrawSize: integer;
    FInWeight: single;
    FLevel: TLvlGraphLevel;
    FNextSelected: TLvlGraphNode;
    FOutEdges: TFPList; // list of TLvlGraphEdge
    FDrawPosition: integer;
    FOutWeight: single;
    FOverlayIndex: integer;
    FPrevSelected: TLvlGraphNode;
    FSelected: boolean;
    FSubGraph: Integer;
    FVisible: boolean;
    function GetIndexInLevel: integer;
    function GetInEdges(Index: integer): TLvlGraphEdge; inline;
    function GetOutEdges(Index: integer): TLvlGraphEdge; inline;
    procedure SetCaption(AValue: string);
    procedure SetColor(AValue: TFPColor);
    procedure OnLevelDestroy;
    procedure SetDrawCenter(AValue: integer);
    procedure SetDrawSize(AValue: integer);
    procedure SetImageEffect(AValue: TGraphicsDrawEffect);
    procedure SetImageIndex(AValue: integer);
    procedure SetIndexInLevel(AValue: integer);
    procedure SetLevel(AValue: TLvlGraphLevel);
    procedure SetOverlayIndex(AValue: integer);
    procedure SetSelected(AValue: boolean);
    procedure SetSubGraph(AValue: Integer);
    procedure SetVisible(AValue: boolean);
    procedure UnbindLevel;
    procedure SelectionChanged;
    function GetDrawCenter: integer;
  protected
    property SubGraph: Integer read FSubGraph write SetSubGraph;
  public
    Data: Pointer; // free for user data
    constructor Create(TheGraph: TLvlGraph; TheCaption: string; TheLevel: TLvlGraphLevel);
    destructor Destroy; override;
    procedure Clear;
    procedure Invalidate;
    property Color: TFPColor read FColor write SetColor;
    property Caption: string read FCaption write SetCaption;
    property Visible: boolean read FVisible write SetVisible;
    property ImageIndex: integer read FImageIndex write SetImageIndex;
    property OverlayIndex: integer read FOverlayIndex write SetOverlayIndex; // requires ImageIndex>=0
    property ImageEffect: TGraphicsDrawEffect read FImageEffect write SetImageEffect default DefaultLvlGraphNodeImageEffect;
    property Graph: TLvlGraph read FGraph;
    function IndexOfInEdge(Source: TLvlGraphNode): integer;
    function FindInEdge(Source: TLvlGraphNode): TLvlGraphEdge; virtual;
    function InEdgeCount: integer; inline;
    property InEdges[Index: integer]: TLvlGraphEdge read GetInEdges;
    function IndexOfOutEdge(Target: TLvlGraphNode): integer;
    function FindOutEdge(Target: TLvlGraphNode): TLvlGraphEdge; virtual;
    function OutEdgeCount: integer;
    property OutEdges[Index: integer]: TLvlGraphEdge read GetOutEdges;
    function GetVisibleSourceNodes: TLvlGraphNodeArray;
    function GetVisibleSourceNodesAsAVLTree: TAvlTree;
    function GetVisibleTargetNodes: TLvlGraphNodeArray;
    function GetVisibleTargetNodesAsAVLTree: TAvlTree;
    property IndexInLevel: integer read GetIndexInLevel write SetIndexInLevel;
    property Level: TLvlGraphLevel read FLevel write SetLevel;
    property Selected: boolean read FSelected write SetSelected;
    property NextSelected: TLvlGraphNode read FNextSelected;
    property PrevSelected: TLvlGraphNode read FPrevSelected;
    property DrawPosition: integer read FDrawPosition write FDrawPosition; // position in a level
    property DrawSize: integer read FDrawSize write SetDrawSize default 1;
    property DrawCenter: integer read GetDrawCenter write SetDrawCenter;
    function DrawPositionEnd: integer;// = DrawPosition+Max(InSize,OutSize)
    property DrawnCaptionRect: TRect read FDrawnCaptionRect; // last draw position of caption with scrolling
    property InWeight: single read FInWeight; // total weight of InEdges
    property OutWeight: single read FOutWeight; // total weight of OutEdges
  end;
  TLvlGraphNodeClass = class of TLvlGraphNode;
  PLvlGraphNode = ^TLvlGraphNode;

  { TLvlGraphEdge }

  TLvlGraphEdge = class(TPersistent)
  private
    FBackEdge: boolean;
    FNoGapCircle: boolean; // a circle between 2 nodes, with no levels between => both edges paint in the same location
    FDrawnAt: TRect;
    FHighlighted: boolean;
    FSource: TLvlGraphNode;
    FTarget: TLvlGraphNode;
    FWeight: single;
    procedure SetHighlighted(AValue: boolean);
    procedure SetWeight(AValue: single);
  protected
    procedure RevertDirection;
  public
    Data: Pointer; // free for user data
    constructor Create(TheSource: TLvlGraphNode; TheTarget: TLvlGraphNode);
    destructor Destroy; override;
    property Source: TLvlGraphNode read FSource;
    property Target: TLvlGraphNode read FTarget;
    property Weight: single read FWeight write SetWeight; // >=0
    function IsBackEdge: boolean;
    property BackEdge: boolean read FBackEdge; // edge had its direction reverted (source <> target exchanged)
    property Highlighted: boolean read FHighlighted write SetHighlighted;
    property DrawnAt: TRect read FDrawnAt;  // last drawn with scrolling
    function GetVisibleSourceNodes: TLvlGraphNodeArray;
    function GetVisibleSourceNodesAsAVLTree: TAvlTree;
    function GetVisibleTargetNodes: TLvlGraphNodeArray;
    function GetVisibleTargetNodesAsAVLTree: TAvlTree;
    function AsString: string;
  end;
  TLvlGraphEdgeClass = class of TLvlGraphEdge;
  TLvlGraphEdgeArray = array of TLvlGraphEdge;
  PLvlGraphEdge = ^TLvlGraphEdge;

  { TLvlGraphLevel }

  TLvlGraphLevel = class(TPersistent)
  private
    FGraph: TLvlGraph;
    FIndex: integer;
    fNodes: TFPList;
    FDrawPosition: integer;
    function GetNodes(Index: integer): TLvlGraphNode;
    procedure SetDrawPosition(AValue: integer);
    procedure MoveNode(Node: TLvlGraphNode; NewIndexInLevel: integer);
  public
    Data: Pointer; // free for user data
    constructor Create(TheGraph: TLvlGraph; TheIndex: integer);
    destructor Destroy; override;
    procedure Invalidate;
    property Nodes[Index: integer]: TLvlGraphNode read GetNodes; default;
    function IndexOf(Node: TLvlGraphNode): integer;
    function Count: integer;
    function GetTotalInOutWeights: single; // sum of all nodes Max(InWeight,OutWeight)
    property Index: integer read FIndex;
    property Graph: TLvlGraph read FGraph;
    property DrawPosition: integer read FDrawPosition write SetDrawPosition;
  end;
  TLvlGraphLevelClass = class of TLvlGraphLevel;

  { TLvlGraphSubGraph }

  TLvlGraphSubGraph = class(TPersistent)
  private
    FGraph: TLvlGraph;
    FHighestLevel: integer;
    FIndex: integer;
    FLowestLevel: integer;
  public
    constructor Create(TheGraph: TLvlGraph; TheIndex: integer);
    destructor Destroy; override;
    property Graph: TLvlGraph read FGraph;
    property Index: integer read FIndex;
    property LowestLevel: integer read FLowestLevel;
    property HighestLevel: integer read FHighestLevel;
  end;

  TOnLvlGraphStructureChanged = procedure(Sender, Element: TObject;
                                               Operation: TOperation) of object;

  TLvlGraphEdgeSplitMode = (
    lgesNone,
    lgesSeparate, // create for each edge separate hidden nodes, this creates a lot of hidden nodes
    lgesMergeSource, // combine hidden nodes at source (outgoing edge)
    lgesMergeTarget, // combine hidden nodes at target (incoming edge)
    lgesMergeHighest // combine hidden nodes at source or target, whichever has more edges
    );

  { TLvlGraph }

  TLvlGraph = class(TPersistent)
  private
    FEdgeClass: TLvlGraphEdgeClass;
    FFirstSelected: TLvlGraphNode;
    FLastSelected: TLvlGraphNode;
    FLevelClass: TLvlGraphLevelClass;
    FNodeClass: TLvlGraphNodeClass;
    FOnInvalidate: TNotifyEvent;
    FNodes: TFPList; // list of TLvlGraphNode
    fLevels: TFPList;
    fSubGraphs: TFPList;
    FCaseSensitive: Boolean;
    FOnSelectionChanged: TNotifyEvent;
    FOnStructureChanged: TOnLvlGraphStructureChanged;
    function GetLevelCount: integer;
    function GetLevels(Index: integer): TLvlGraphLevel;
    function GetNodes(Index: integer): TLvlGraphNode;
    function GetSubGraphCount: integer;
    function GetSubGraphs(Index: integer): TLvlGraphSubGraph;
    procedure SetLevelCount(AValue: integer);
    procedure InternalRemoveNode(Node: TLvlGraphNode);
    procedure InternalRemoveLevel(Lvl: TLvlGraphLevel);
  protected
    procedure SelectionChanged;
    function NewLevelAtIndex(AnIndex, ASubGraphIndex: integer): TLvlGraphLevel;
  public
    Data: Pointer; // free for user data
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    procedure Invalidate;
    procedure StructureChanged(Element: TObject; Operation: TOperation);
    property OnInvalidate: TNotifyEvent read FOnInvalidate write FOnInvalidate;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnStructureChanged: TOnLvlGraphStructureChanged read FOnStructureChanged write FOnStructureChanged;// node, edge, level was added/deleted

    // nodes
    function NodeCount: integer;
    property Nodes[Index: integer]: TLvlGraphNode read GetNodes;
    function GetNode(aCaption: string; CreateIfNotExists: boolean): TLvlGraphNode;
    function CreateHiddenNode(Level: integer = 0): TLvlGraphNode;
    property NodeClass: TLvlGraphNodeClass read FNodeClass;
    property FirstSelected: TLvlGraphNode read FFirstSelected;
    property LastSelected: TLvlGraphNode read FLastSelected;
    procedure ClearSelection;
    procedure SingleSelect(Node: TLvlGraphNode);
    function IsMultiSelection: boolean;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;

    // edges
    function GetEdge(SourceCaption, TargetCaption: string;
      CreateIfNotExists: boolean): TLvlGraphEdge;
    function GetEdge(Source, Target: TLvlGraphNode;
      CreateIfNotExists: boolean): TLvlGraphEdge;
    property EdgeClass: TLvlGraphEdgeClass read FEdgeClass;

    property SubGraphs[Index: integer]: TLvlGraphSubGraph read GetSubGraphs;
    property SubGraphCount: integer read GetSubGraphCount;
    // levels
    property Levels[Index: integer]: TLvlGraphLevel read GetLevels;
    property LevelCount: integer read GetLevelCount write SetLevelCount;
    property LevelClass: TLvlGraphLevelClass read FLevelClass;

    procedure FindIndependentGraphs;
    procedure CreateTopologicalLevels(HighLevels, ReduceBackEdges: boolean); // create levels from edges
    procedure MinimizeEdgeLens(HighLevels: boolean); // requires that BackEdge have been processed by procedure MarkBackEdges
    procedure LimitLevelHeights(MaxHeight: integer; MaxHeightRel: Single);
    procedure SplitLongEdges(SplitMode: TLvlGraphEdgeSplitMode); // split long edges by adding hidden nodes
    procedure ScaleNodeDrawSizes(NodeGapAbove, NodeGapBelow,
      HardMaxTotal, HardMinOneNode, SoftMaxTotal, SoftMinOneNode: integer; out PixelPerWeight: single);
    procedure SetAllNodeDrawSizes(PixelPerWeight: single = 1.0; MinWeight: single = 0.0);
    procedure MarkBackEdges;
    procedure MinimizeCrossings; // permutate nodes to minimize crossings
    // MinimizeOverlappings: Adjust Node.DrawPosition to ensure all nodes have the required gaps between them.
    procedure MinimizeOverlappings(MinPos: integer = 0;
      NodeGapAbove: integer = 1; NodeGapBelow: integer = 1);
    procedure MinimizeOverlappings(MinPos: integer; NodeGapAbove: integer;
      NodeGapBelow: integer; aLevel: integer);
    procedure StraightenGraph;
    procedure SetColors(Palette: TLazCtrlPalette);

    // debugging
    procedure WriteDebugReport(Msg: string);
    procedure ConsistencyCheck(WithBackEdge: boolean);
  end;

type
  TLvlGraphCtrlOption = (
    lgoAutoLayout, // automatic graph layout after graph was changed
    lgoReduceBackEdges, // CreateTopologicalLevels (AutoLayout) will attempts to find an order with less BackEdges
    lgoHighLevels, // put nodes topologically at higher levels
    lgoMinimizeEdgeLens, // If nodes are not fixed to a level by neighbours on both side, find the level which reduces total edge len the most
    lgoStraightenGraph, // Minimize vertical up/down movement of edges
    lgoHighlightNodeUnderMouse, // when mouse over node highlight node and its edges
    lgoHighlightEdgeNearMouse, // when mouse near an edge highlight edge and its edges, lgoHighlightNodeUnderMouse takes precedence
    lgoMouseSelects
    );
  TLvlGraphCtrlOptions = set of TLvlGraphCtrlOption;
const
  DefaultLvlGraphCtrlOptions = [lgoAutoLayout, lgoStraightenGraph,
          lgoHighlightNodeUnderMouse,lgoHighlightEdgeNearMouse,lgoMouseSelects];

type
  TLvlGraphNodeCaptionPosition = (
    lgncLeft,
    lgncTop,
    lgncRight,
    lgncBottom
    );
  TLvlGraphNodeCaptionPositions = set of TLvlGraphNodeCaptionPosition;

  TLvlGraphNodeShape = (
    lgnsNone,
    lgnsRectangle,
    lgnsEllipse
    );
  TLvlGraphNodeShapes = set of TLvlGraphNodeShape;

  TLvlGraphNodeColoring = (
    lgncNone,
    lgncRGB
    );
  TLvlGraphNodeColorings = set of TLvlGraphNodeColoring;

const
  // node style
  DefaultLvlGraphNodeWith             = 10;
  DefaultLvlGraphNodeCaptionScale     = 0.7;
  DefaultLvlGraphNodeCaptionPosition  = lgncTop;
  DefaultLvlGraphNodeGapLeft          = 2;
  DefaultLvlGraphNodeGapRight         = 2;
  DefaultLvlGraphNodeGapTop           = 1;
  DefaultLvlGraphNodeGapBottom        = 1;
  DefaultLvlGraphNodeShape            = lgnsRectangle;
  DefaultLvlGraphNodeColoring         = lgncRGB;

type
  TLvlGraphEdgeShape = (
    lgesStraight,
    lgesCurved
    );
  TLvlGraphEdgeShapes = set of TLvlGraphEdgeShape;

const
  // edge style
  DefaultLvlGraphEdgeSplitMode          = lgesMergeHighest;
  DefaultLvlGraphEdgeNearMouseDistMax   = 5;
  DefaultLvlGraphEdgeShape              = lgesCurved;
  DefaultLvlGraphEdgeColor              = clSilver;
  DefaultLvlGraphEdgeHighlightColor     = clBlack;
  DefaultLvlGraphEdgeBackColor          = clRed;
  DefaultLvlGraphEdgeBackHighlightColor = clBlue;
  DefaultMaxLevelHeightAbs              = 0;
  DefaultMaxLevelHeightRel              = single(1.5);

type

  TCustomLvlGraphControl = class;

  { TLvlGraphNodeStyle }

  TLvlGraphNodeStyle = class(TPersistent)
  private
    FCaptionPosition: TLvlGraphNodeCaptionPosition;
    FCaptionScale: single;
    FColoring: TLvlGraphNodeColoring;
    FControl: TCustomLvlGraphControl;
    FDefaultImageIndex: integer;
    FGapBottom: integer;
    FGapLeft: integer;
    FGapRight: integer;
    FGapTop: integer;
    FShape: TLvlGraphNodeShape;
    FWidth: integer;
    procedure SetCaptionPosition(AValue: TLvlGraphNodeCaptionPosition);
    procedure SetCaptionScale(AValue: single);
    procedure SetColoring(AValue: TLvlGraphNodeColoring);
    procedure SetDefaultImageIndex(AValue: integer);
    procedure SetGapBottom(AValue: integer);
    procedure SetGapLeft(AValue: integer);
    procedure SetGapRight(AValue: integer);
    procedure SetGapTop(AValue: integer);
    procedure SetShape(AValue: TLvlGraphNodeShape);
    procedure SetWidth(AValue: integer);
  public
    constructor Create(AControl: TCustomLvlGraphControl);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Equals(Obj: TObject): boolean; override;
    property Control: TCustomLvlGraphControl read FControl;
  published
    property CaptionPosition: TLvlGraphNodeCaptionPosition
      read FCaptionPosition write SetCaptionPosition default DefaultLvlGraphNodeCaptionPosition;
    property CaptionScale: single read FCaptionScale write SetCaptionScale default DefaultLvlGraphNodeCaptionScale;
    property Shape: TLvlGraphNodeShape read FShape write SetShape default DefaultLvlGraphNodeShape;
    property GapLeft: integer read FGapLeft write SetGapLeft default DefaultLvlGraphNodeGapLeft; // used by AutoLayout
    property GapTop: integer read FGapTop write SetGapTop default DefaultLvlGraphNodeGapTop; // used by AutoLayout
    property GapRight: integer read FGapRight write SetGapRight default DefaultLvlGraphNodeGapRight; // used by AutoLayout
    property GapBottom: integer read FGapBottom write SetGapBottom default DefaultLvlGraphNodeGapBottom; // used by AutoLayout
    property Width: integer read FWidth write SetWidth default DefaultLvlGraphNodeWith;
    property DefaultImageIndex: integer read FDefaultImageIndex write SetDefaultImageIndex;
    property Coloring: TLvlGraphNodeColoring read FColoring write SetColoring;
  end;

  { TLvlGraphEdgeStyle }

  TLvlGraphEdgeStyle = class(TPersistent)
  private
    FBackColor: TColor;
    FColor: TColor;
    FControl: TCustomLvlGraphControl;
    FBackHighlightColor: TColor;
    FHighlightColor: TColor;
    FMouseDistMax: integer;
    FShape: TLvlGraphEdgeShape;
    FSplitMode: TLvlGraphEdgeSplitMode;
    procedure SetBackColor(AValue: TColor);
    procedure SetColor(AValue: TColor);
    procedure SetBackHighlightColor(AValue: TColor);
    procedure SetHighlightColor(AValue: TColor);
    procedure SetMouseDistMax(AValue: integer);
    procedure SetShape(AValue: TLvlGraphEdgeShape);
    procedure SetSplitMode(AValue: TLvlGraphEdgeSplitMode);
  public
    constructor Create(AControl: TCustomLvlGraphControl);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Equals(Obj: TObject): boolean; override;
    property Control: TCustomLvlGraphControl read FControl;
  published
    property SplitMode: TLvlGraphEdgeSplitMode read FSplitMode write SetSplitMode default DefaultLvlGraphEdgeSplitMode;
    property MouseDistMax: integer read FMouseDistMax write SetMouseDistMax default DefaultLvlGraphEdgeNearMouseDistMax;
    property Shape: TLvlGraphEdgeShape read FShape write SetShape default DefaultLvlGraphEdgeShape;
    property Color: TColor read FColor write SetColor default DefaultLvlGraphEdgeColor;
    property BackColor: TColor read FBackColor write SetBackColor default DefaultLvlGraphEdgeBackColor;
    property HighlightColor: TColor read FHighlightColor write SetHighlightColor default DefaultLvlGraphEdgeHighlightColor;
    property BackHighlightColor: TColor read FBackHighlightColor write SetBackHighlightColor default DefaultLvlGraphEdgeBackHighlightColor;
  end;

  { TLvlGraphLimits }

  TLvlGraphLimits = class(TPersistent)
  private
    FControl: TCustomLvlGraphControl;
    FMaxLevelHeightAbs: integer;
    FMaxLevelHeightRel: single;
    procedure SetMaxLevelHeightAbs(AValue: integer);
    procedure SetMaxLevelHeightRel(AValue: single);
  public
    constructor Create(AControl: TCustomLvlGraphControl);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Equals(Obj: TObject): boolean; override;
    property Control: TCustomLvlGraphControl read FControl;
  published
    // Maximum amount of visible (user specified nodes) in a level. (0 = ignore)
    property MaxLevelHeightAbs: integer read FMaxLevelHeightAbs write SetMaxLevelHeightAbs default DefaultMaxLevelHeightAbs;
    // Relative max amount of visible nodes per level. Limit := Max(3, sqr(NodeCount) * MaxLevelHeightRel) / (0 = ignore)
    property MaxLevelHeightRel: single read FMaxLevelHeightRel write SetMaxLevelHeightRel default DefaultMaxLevelHeightRel;
  end;

  TLvlGraphControlFlag =  (
    lgcNeedInvalidate,
    lgcNeedAutoLayout,
    lgcIgnoreGraphInvalidate,
    lgcUpdatingScrollBars,
    lgcFocusedPainting
    );
  TLvlGraphControlFlags = set of TLvlGraphControlFlag;

  TLvlGraphMinimizeOverlappingsEvent = procedure(var MinPos: integer;
      var NodeGapInFront: integer; var NodeGapBehind: integer;
      var Handled: Boolean) of object;
  TLvlGraphDrawStep = (
    lgdsBackground,
    lgdsHeader,
    lgdsNormalEdges,
    lgdsNodeCaptions,
    lgdsHighlightedEdges,
    lgdsNodes,
    lgdsFinish
    );
  TLvlGraphDrawSteps = set of TLvlGraphDrawStep;
  TLvlGraphDrawEvent = procedure(Step: TLvlGraphDrawStep; var Skip: boolean) of object;

  { TCustomLvlGraphControl }

  TCustomLvlGraphControl = class(TCustomControl)
  private
    FEdgeStyle: TLvlGraphEdgeStyle;
    FEdgeNearMouse: TLvlGraphEdge;
    FGraph: TLvlGraph;
    FImageChangeLink: TChangeLink;
    FImages: TCustomImageList;
    FLimits: TLvlGraphLimits;
    FNodeStyle: TLvlGraphNodeStyle;
    FNodeUnderMouse: TLvlGraphNode;
    FOnDrawStep: TLvlGraphDrawEvent;
    FOnEndAutoLayout: TNotifyEvent;
    FOnMinimizeCrossings: TNotifyEvent;
    FOnMinimizeOverlappings: TLvlGraphMinimizeOverlappingsEvent;
    FOnSelectionChanged: TNotifyEvent;
    FOnStartAutoLayout: TNotifyEvent;
    FOptions: TLvlGraphCtrlOptions;
    FZoom: Single;
    FPixelPerWeight: single;
    FScrollLeft: integer;
    FScrollLeftMax: integer;
    FScrollTopMax: integer;
    FScrollTop: integer;
    fUpdateLock: integer;
    FFlags: TLvlGraphControlFlags;
    procedure ColorNodesRandomRGB;
    procedure DrawCaptions(const TxtH: integer);
    procedure ComputeEdgeCoords;
    procedure DrawEdges(Highlighted: boolean);
    procedure DrawNodes;
    function GetSelectedNode: TLvlGraphNode;
    procedure SetEdgeNearMouse(AValue: TLvlGraphEdge);
    procedure SetImages(AValue: TCustomImageList);
    procedure SetNodeStyle(AValue: TLvlGraphNodeStyle);
    procedure SetNodeUnderMouse(AValue: TLvlGraphNode);
    procedure SetOptions(AValue: TLvlGraphCtrlOptions);
    procedure SetScrollLeft(AValue: integer);
    procedure SetScrollTop(AValue: integer);
    function  ClientPosFor(AGraphPoint: TPoint): TPoint; overload;
    function  ClientPosFor(AGraphRect: TRect): TRect; overload;
    function  ApplyZoom(c: Integer): Integer; overload;
    function  ApplyZoom(p: TPoint): TPoint; overload;
    function  ApplyZoom(r: TRect): TRect; overload;
    function  GetZoomedTop(ANode: TLvlGraphNode): Integer; overload;
    function  GetZoomedCenter(ANode: TLvlGraphNode): Integer; overload;
    function  GetZoomedBottom(ANode: TLvlGraphNode): Integer; overload;
    procedure SetSelectedNode(AValue: TLvlGraphNode);
    procedure UpdateScrollBars;
    procedure WMHScroll(var Msg: TLMScroll); message LM_HSCROLL;
    procedure WMVScroll(var Msg: TLMScroll); message LM_VSCROLL;
    procedure WMMouseWheel(var Message: TLMMouseEvent); message LM_MOUSEWHEEL;
    procedure ImageListChange(Sender: TObject);
  protected
    procedure GraphInvalidate(Sender: TObject); virtual;
    procedure GraphSelectionChanged(Sender: TObject); virtual;
    procedure GraphStructureChanged(Sender, Element: TObject; Operation: TOperation); virtual;
    procedure DoSetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    procedure DoStartAutoLayout; virtual;
    procedure DoMinimizeCrossings; virtual;
    procedure DoAutoLayoutLevels(TxtHeight: integer); virtual;
    procedure DoMinimizeOverlappings(MinPos: integer = 0;
      NodeGapInFront: integer = 1; NodeGapBehind: integer = 1); virtual;
    procedure DoEndAutoLayout; virtual;
    procedure DoDrawEdge(Edge: TLvlGraphEdge); virtual; // draw line at Edge.DrawX1,Y1,X2,Y2 with current Canvas colors
    procedure Paint; override;
    function Draw(Step: TLvlGraphDrawStep): boolean; virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CreateWnd; override;
    procedure HighlightConnectedEgdes(Element: TObject);
    procedure DoOnShowHint(HintInfo: PHintInfo); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure EraseBackground({%H-}DC: HDC); override;
    property Graph: TLvlGraph read FGraph;
    procedure Clear;
    procedure AutoLayout; virtual;
    procedure Invalidate; override;
    procedure InvalidateAutoLayout;
    procedure BeginUpdate;
    procedure EndUpdate;
    function GetNodeAt(X,Y: integer): TLvlGraphNode;
    function GetEdgeAt(X,Y: integer; out Distance: integer): TLvlGraphEdge;
    class function GetControlClassDefaultSize: TSize; override;
    function GetDrawSize: TPoint;
  public
    property NodeStyle: TLvlGraphNodeStyle read FNodeStyle write SetNodeStyle;
    property NodeUnderMouse: TLvlGraphNode read FNodeUnderMouse write SetNodeUnderMouse;
    property EdgeNearMouse: TLvlGraphEdge read FEdgeNearMouse write SetEdgeNearMouse;
    property EdgeStyle: TLvlGraphEdgeStyle read FEdgeStyle;
    property Limits: TLvlGraphLimits read FLimits;
    property Options: TLvlGraphCtrlOptions read FOptions write SetOptions default DefaultLvlGraphCtrlOptions;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
    property ScrollTop: integer read FScrollTop write SetScrollTop;
    property ScrollTopMax: integer read FScrollTopMax;
    property ScrollLeft: integer read FScrollLeft write SetScrollLeft;
    property ScrollLeftMax: integer read FScrollLeftMax;
    property OnMinimizeCrossings: TNotifyEvent read FOnMinimizeCrossings write FOnMinimizeCrossings;// provide an alternative minimize crossing algorithm
    property OnMinimizeOverlappings: TLvlGraphMinimizeOverlappingsEvent read FOnMinimizeOverlappings write FOnMinimizeOverlappings;// provide an alternative minimize overlappings algorithm
    property OnStartAutoLayout: TNotifyEvent read FOnStartAutoLayout write FOnStartAutoLayout;
    property OnEndAutoLayout: TNotifyEvent read FOnEndAutoLayout write FOnEndAutoLayout;
    property OnDrawStep: TLvlGraphDrawEvent read FOnDrawStep write FOnDrawStep;
    property Images: TCustomImageList read FImages write SetImages;
    property PixelPerWeight: single read FPixelPerWeight;
    property SelectedNode: TLvlGraphNode read GetSelectedNode write SetSelectedNode;
    property ShowHint default True;
  end;

  { TLvlGraphControl }

  TLvlGraphControl = class(TCustomLvlGraphControl)
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property BorderStyle;
    property BorderWidth;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EdgeStyle;
    property Enabled;
    property Font;
    property NodeStyle;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawStep;
    property OnEndAutoLayout;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMinimizeCrossings;
    property OnMinimizeOverlappings;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnSelectionChanged;
    property OnShowHint;
    property OnStartAutoLayout;
    property OnStartDrag;
    property OnUTF8KeyPress;
    property Options;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Tag;
    property Visible;
  end;

function GetCCPaletteRGB(Cnt: integer; Shuffled: boolean): TLazCtrlPalette;
procedure ShuffleCCPalette({%H-}Palette: TLazCtrlPalette);
function Darker(const c: TColor): TColor; overload;

function GetManhattanDistancePointLine(X,Y, LineX1, LineY1, LineX2, LineY2: integer): integer;
function GetDistancePointLine(X,Y, LineX1, LineY1, LineX2, LineY2: integer): integer;
function GetDistancePointPoint(X1,Y1,X2,Y2: integer): integer;

// level graph
procedure LvlGraphMinimizeCrossings(Graph: TLvlGraph); overload;
procedure LvlGraphHighlightNode(Node: TLvlGraphNode;
  HighlightedElements: TAvlTree; FollowIn, FollowOut: boolean);
function CompareLGNodesByCenterPos(Node1, Node2: Pointer): integer;
procedure DrawCurvedLvlLeftToRightEdge(Canvas: TFPCustomCanvas; x1, y1, x2, y2: integer; StraightenLeft, StraightenRight: Single);
function NodeAVLTreeToNodeArray(Nodes: TAvlTree; RemoveHidden: boolean; FreeTree: boolean): TLvlGraphNodeArray;
function NodeArrayAsString(Nodes: TLvlGraphNodeArray): String;

// debugging
function dbgs(p: TLvlGraphNodeCaptionPosition): string; overload;
function dbgs(o: TLvlGraphCtrlOption): string; overload;
function dbgs(Options: TLvlGraphCtrlOptions): string; overload;

implementation

type
  TMinXGraph = class;
  TMinXLevel = class;
  TMinXPair = class;

  { TMinXNode }

  TMinXNode = class
  public
    GraphNode: TLvlGraphNode;
    InEdges, OutEdges: array of TMinXNode;
    Level: TMinXLevel;
    IndexInLevel: integer;
    constructor Create(aNode: TLvlGraphNode);
    destructor Destroy; override;
  end;

  { TMinXLevel }

  TMinXLevel = class
  public
    Index: integer;
    Graph: TMinXGraph;
    GraphLevel: TLvlGraphLevel;
    Nodes: array of TMinXNode;
    Pairs: array of TMinXPair;
    BestNodes: TLvlGraphNodeArray;
    constructor Create(aGraph: TMinXGraph; aIndex: integer);
    destructor Destroy; override;
    procedure GetCrossingCount(Node1, Node2: TMinXNode; out Crossing, SwitchCrossing: integer);
  end;

  { TMinXPair }

  TMinXPair = class
  private
    FSwitchDiff: integer; // change of crossings when the two nodes would switch
    procedure SetSwitchDiff(AValue: integer);
  public
    Level: TMinXLevel;
    Graph: TMinXGraph;
    Index: integer;
    PrevSameSwitchPair, NextSameSwitchPair: TMinXPair;
    NextChangedSinceBestStored: TMinXPair;
    constructor Create(aLevel: TMinXLevel; aIndex: integer);
    destructor Destroy; override;
    procedure UnbindFromSwitchList;
    function BindToSwitchList(AtEnd: Boolean=False): integer;
    procedure ComputeCrossingCount(out Crossing, SwitchCrossing: integer);
    function ComputeSwitchDiff: integer;
    property SwitchDiff: integer read FSwitchDiff write SetSwitchDiff;
    function AsString: string;
  end;

  { TMinXGraph }

  TMinXGraph = class
  private
    FGraphNodeToNode: TPointerToPointerTree; // TLvlGraphNode to TMinXNode
    PairsChangedSinceBestStored: TMinXPair;
    procedure InitPairs;
    procedure UnbindPairs;
    procedure BindPairs;
    function ComputeCrossCount: integer;
    procedure StoreAsBest(CheckIfBetter: boolean);
    procedure StoreAsBest(APair: TMinXPair);
    function ComputeHighestSwitchDiff(StartAtOld: boolean; IgnorePair: TMinXPair): integer;
  public
    Graph: TLvlGraph;
    Levels: array of TMinXLevel;
    Pairs: array of TMinXPair;
    (* SameSwitchDiffPairs:
         TMinXPair ordered by their SwitchDiff.
         - SwitchDiff is negative (for pairs that have "resolvable crossings")
         - Pairs are stored at: SameSwitchDiffPairs[ - SwitchDiff]
       HighestSwitchDiff:
         - The highest index in use in SameSwitchDiffPairs.
         - The index to the pair(s) with the most resolvable crossings"
           This is Max(Abs(SwitchDiff))  OR  Abs(Min(SwitchDiff))
    *)
    SameSwitchDiffPairs: array of TMinXPair;
    HighestSwitchDiff: integer;
    CrossCount: integer;
    BestCrossCount: integer;
    constructor Create(aGraph: TLvlGraph);
    destructor Destroy; override;
    procedure InitSearch;
    function FindBestPair: TMinXPair;
    procedure SwitchCrossingPairs(MaxRun: int64; var Run: int64; ZeroRunLimit: int64);
    procedure Shuffle;
    procedure SwitchAndShuffle(MaxSingleRun, MaxTotalRun: int64);
    procedure SwitchPair(Pair: TMinXPair);
    procedure Apply; // reorder Graph nodes
    function GraphNodeToNode(GraphNode: TLvlGraphNode): TMinXNode; inline;
    procedure ConsistencyCheck;
  end;

  (** For MinimizeEdgeLens **)
  TGraphEdgeLenMinimizerTree = class;

  { TGraphEdgeLenMinimizerNode }

  TGraphEdgeLenMinimizerNode = class(TAVLTreeNode)
  protected
    FTree: TGraphEdgeLenMinimizerTree;
    function GetLevel: Integer; virtual;
    procedure SetLevel(AValue: Integer); virtual;
    function GetInSibling(Index: Integer): TGraphEdgeLenMinimizerNode;  virtual;
    function GetOutSibling(Index: Integer): TGraphEdgeLenMinimizerNode;  virtual;
    function GetOutSiblingDistance(Index: Integer): Integer; virtual;
    class function MapLevel(ALvl, {%H-}LvlCount: Integer): integer; virtual;
  public
    Node: TLvlGraphNode;
    NextExtNodeTowardsLowerLevel: TGraphEdgeLenMinimizerNode;
    MaxLevel, LevelDiff, VisitedId: Integer;
    MinSubGraphLevel, MaxSubGraphLevel: Integer;
    (* gelOnlyPush:
         Nodes that have no shorten-able OutEdges.
         Either no OutEdges at all, or all OutEdges are directly (len=1) connected
         to another gelOnlyPush
         Only move them, to make space for a moved none-gelOnlyPush node.
    *)
    Flags: set of (gelOnlyPush);
  public
    property Level: Integer read GetLevel write SetLevel;
    function OutSiblingCount: Integer; virtual;
    property OutSibling[Index: Integer]: TGraphEdgeLenMinimizerNode read GetOutSibling;
    property OutSiblingDistance[Index: Integer]: Integer read GetOutSiblingDistance;
    function InSiblingCount: Integer; virtual;
    property InSibling[Index: Integer]: TGraphEdgeLenMinimizerNode read GetInSibling;
  end;

  TGraphEdgeLenMinimizerNodeClass = class of TGraphEdgeLenMinimizerNode;

  { TGraphEdgeLenMinimizerReverseNode }

  TGraphEdgeLenMinimizerReverseNode = class(TGraphEdgeLenMinimizerNode)
  protected
    function GetLevel: Integer; override;
    procedure SetLevel(AValue: Integer); override;
    function GetInSibling(Index: Integer): TGraphEdgeLenMinimizerNode;  override;
    function GetOutSibling(Index: Integer): TGraphEdgeLenMinimizerNode;  override;
    function GetOutSiblingDistance(Index: Integer): Integer; override;
    class function MapLevel(ALvl, LvlCount: Integer): integer; override;
  public
    function OutSiblingCount: Integer; override;
    function InSiblingCount: Integer; override;
  end;

  { TGraphEdgeLenMinimizerTree }

  TGraphEdgeLenMinimizerTree = class(TAvlTree)
  public
    Graph: TLvlGraph;
    ExtNodeWithHighestLevel, ExtNodeWithLowestLevel :TGraphEdgeLenMinimizerNode;
    constructor Create;
    function GetTreeNode(Node: TLvlGraphNode): TGraphEdgeLenMinimizerNode;
    function AddGraphNode(Node: TLvlGraphNode): TGraphEdgeLenMinimizerNode;
    function MapLevel(ALvl: Integer): integer;
  end;


procedure LvlGraphMinimizeCrossings(Graph: TLvlGraph);
var
  g: TMinXGraph;
begin
  if (Graph.LevelCount<2) or (Graph.NodeCount<3) then exit;
  g:=TMinXGraph.Create(Graph);
  try
    if length(g.Pairs)=0 then exit;
    g.InitSearch;
    {$IFDEF CheckMinXGraph}
    debugln(['LvlGraphMinimizeCrossings Graph.NodeCount=',Graph.NodeCount]);
    g.SwitchAndShuffle(100*Graph.NodeCount,
                       Min(10000,Graph.NodeCount*Graph.NodeCount));
    {$ELSE}
    g.SwitchAndShuffle(100*Graph.NodeCount,
                       Min(100000,Graph.NodeCount*Graph.NodeCount)
                       ){%H-};
    {$ENDIF}
    g.Apply;
  finally
    g.Free;
  end;
end;

procedure LvlGraphHighlightNode(Node: TLvlGraphNode; HighlightedElements: TAvlTree;
  FollowIn, FollowOut: boolean);
var
  i: Integer;
  Edge: TLvlGraphEdge;
begin
  if HighlightedElements.Find(Node)<>nil then exit;
  HighlightedElements.Add(Node);
  if FollowIn then
    for i:=0 to Node.InEdgeCount-1 do begin
      Edge:=Node.InEdges[i];
      HighlightedElements.Add(Edge);
      if not Edge.Source.Visible then
        LvlGraphHighlightNode(Edge.Source,HighlightedElements,true,false);
    end;
  if FollowOut then
    for i:=0 to Node.OutEdgeCount-1 do begin
      Edge:=Node.OutEdges[i];
      HighlightedElements.Add(Edge);
      if not Edge.Target.Visible then
        LvlGraphHighlightNode(Edge.Target,HighlightedElements,false,true);
    end;
end;

function GetManhattanDistancePointLine(X, Y, LineX1, LineY1, LineX2, LineY2: integer
  ): integer;
// Manhattan distance
var
  m: Integer;
begin
  Result:=abs(X-LineX1)+abs(Y-LineY1);
  Result:=Min(Result,abs(X-LineX2)+abs(Y-LineY2));
  // from left to right
  if abs(LineX2-LineX1)<abs(LineY2-LineY1) then begin
    // vertical line
    if (LineY1<LineY2) and ((Y<LineY1) or (Y>LineY2)) then exit;
    if (LineY1>LineY2) and ((Y<LineY2) or (Y>LineY1)) then exit;
    m:=((LineX2-LineX1)*(Y-LineY1)) div (LineY2-LineY1);
    Result:=Min(Result,abs(X-m));
  end else if LineX1<>LineX2 then begin
    // horizontal line
    if (LineX1<LineX2) and ((X<LineX1) or (X>LineX2)) then exit;
    if (LineX1>LineX2) and ((X<LineX2) or (X>LineX1)) then exit;
    m:=((LineY2-LineY1)*(X-LineX1)) div (LineX2-LineX1);
    Result:=Min(Result,abs(Y-m));
  end;
end;

function GetDistancePointLine(X, Y, LineX1, LineY1, LineX2, LineY2: integer
  ): integer;
var
  lx, ly: single; // nearest point on line
  lm, ln, pm, pn: single;
  d: integer;
begin
  //debugln(['GetDistancePointLine X=',X,',Y=',Y,' Line=',LineX1,',',LineY1,'..',LineX2,',',LineY2]);
  Result:=GetDistancePointPoint(X,Y,LineX1,LineY1);
  if Result<=1 then exit;
  Result:=Min(Result,GetDistancePointPoint(X,Y,LineX2,LineY2));
  if Result<=1 then exit;
  if Abs(LineX1-LineX2)<=1 then begin
    // vertical line
    lx:=LineX1;
    ly:=Y;
  end else if Abs(LineY1-LineY2)<=1 then begin
    lx:=X;
    ly:=LineY1;
  end else begin
    lm:=single(LineY2-LineY1)/single(LineX2-LineX1);
    ln:=single(LineY1)-single(LineX1)*lm;
    pm:=single(-1)/lm;
    pn:=single(Y)-single(X)*pm;
    //debugln(['GetDistancePointLine lm=',lm,' ln=',ln,' pm=',pm,' pn=',pn]);
    // ly = lx*lm+ln = lx*pm'+pn
    // <=> lx*(lm-pm)=pn-ln
    // <=> lx = (pn-ln) / (lm-pm)
    lx:=(pn-ln)/(lm-pm);
    ly:=single(lx)*lm+ln;
  end;
  //debugln(['GetDistancePointLine lx=',lx,', ly=',ly]);

  // check if nearest point is on the line
  if (LineX1<LineX2) and ((lx<LineX1) or (lx>LineX2)) then exit;
  if (LineX1>LineX2) and ((lx>LineX1) or (lx<LineX2)) then exit;
  d:=round(sqrt(sqr(single(X)-lx)+sqr(single(Y)-ly)));
  Result:=Min(Result,d);
  //debugln(['GetDistancePointLine lx=',lx,', ly=',ly,' Result=',Result]);
end;

function GetDistancePointPoint(X1, Y1, X2, Y2: integer): integer;
begin
  Result:=round(sqrt(sqr(X2-X1)+sqr(Y1-Y2))+0.5);
end;

function GetCCPaletteRGB(Cnt: integer; Shuffled: boolean): TLazCtrlPalette;
type
  TChannel = (cRed, cGreen, cBlue);
const
  ChannelMax = alphaOpaque;
var
  Steps, Step, Start, Value: array[TChannel] of integer;

  function EnoughColors: boolean;
  var
    PotCnt: Integer;
    ch: TChannel;
  begin
    PotCnt:=1;
    for ch:=Low(TChannel) to High(TChannel) do
      PotCnt*=Steps[ch];
    Result:=PotCnt>=Cnt;
  end;

var
  ch: TChannel;
  i: Integer;
begin
  SetLength(Result,Cnt);
  if Cnt=0 then exit;
  for ch:=Low(TChannel) to High(TChannel) do
    Steps[ch]:=1;
  while not EnoughColors do
    for ch:=Low(TChannel) to High(TChannel) do begin
      if EnoughColors then break;
      inc(Steps[ch]);
    end;
  for ch:=Low(TChannel) to High(TChannel) do begin
    Step[ch]:=ChannelMax div Steps[ch];
    Start[ch]:=ChannelMax-1-Step[ch]*(Steps[ch]-1);
    Value[ch]:=Start[ch];
  end;
  for i:=0 to Cnt-1 do begin
    Result[i].red:=Value[cRed];
    Result[i].green:=Value[cGreen];
    Result[i].blue:=Value[cBlue];
    ch:=Low(TChannel);
    repeat
      Value[ch]+=Step[ch];
      if (Value[ch]<ChannelMax) or (ch=High(TChannel)) then break;
      Value[ch]:=Start[ch];
      inc(ch);
    until false;
  end;
  if Shuffled then
    ShuffleCCPalette(Result);
end;

procedure ShuffleCCPalette(Palette: TLazCtrlPalette);
begin

end;

function Darker(const c: TColor): TColor;
var
  r: Byte;
  g: Byte;
  b: Byte;
begin
  RedGreenBlue(c,r,g,b);
  r:=r div 2;
  g:=g div 2;
  b:=b div 2;
  Result:=RGBToColor(r,g,b);
end;

function CompareLGNodesByCenterPos(Node1, Node2: Pointer): integer;
var
  LNode1: TLvlGraphNode absolute Node1;
  LNode2: TLvlGraphNode absolute Node2;
  p1: Integer;
  p2: Integer;
begin
  p1:=LNode1.DrawCenter;
  p2:=LNode2.DrawCenter;
  if p1<p2 then
    exit(-1)
  else if p1>p2 then
    exit(1);
  // default compare by position in level
  Result:=LNode1.IndexInLevel-LNode2.IndexInLevel;
end;

procedure DrawCurvedLvlLeftToRightEdge(Canvas: TFPCustomCanvas; x1, y1, x2,
  y2: integer; StraightenLeft, StraightenRight: Single);
//var
//  b: TBezier;
//  Points: PPoint;
//  Count: Longint;
//  p: PPoint;
//  i: Integer;
begin
  Canvas.PolyBezier([
    Point(x1,y1),
    Point(x1+10,y1-Trunc(0.5+10*StraightenLeft)),
    Point(x2-10,y2+Trunc(0.5+10*StraightenRight)),
    Point(x2,y2)]);
  exit;
  //b:=Bezier(Point(x1,y1),Point(x1+10,y1),Point(x2-10,y2),Point(x2,y2));
  //Points:=nil;
  //Count:=0;
  //Bezier2Polyline(b,Points,Count);
  ////debugln(['DrawCurvedLvlLeftToRightEdge Count=',Count]);
  //if Count=0 then exit;
  //p:=Points;
  //Canvas.MoveTo(p^);
  ////debugln(['DrawCurvedLvlLeftToRightEdge Point0=',dbgs(p^)]);
  //for i:=1 to Count-1 do begin
  //  inc(p);
  //  //debugln(['DrawCurvedLvlLeftToRightEdge Point',i,'=',dbgs(p^)]);
  //  Canvas.LineTo(p^);
  //end;
  //Freemem(Points);
end;

function NodeAVLTreeToNodeArray(Nodes: TAvlTree; RemoveHidden: boolean;
  FreeTree: boolean): TLvlGraphNodeArray;
var
  AVLNode: TAvlTreeNode;
  Node: TLvlGraphNode;
  i: Integer;
begin
  if Nodes=nil then begin
    SetLength(Result,0);
    exit;
  end;
  AVLNode:=Nodes.FindLowest;
  i:=0;
  SetLength(Result,Nodes.Count);
  while AVLNode<>nil do begin
    Node:=TLvlGraphNode(AVLNode.Data);
    if Node.Visible or (not RemoveHidden) then begin
      Result[i]:=Node;
      inc(i);
    end;
    AVLNode:=Nodes.FindSuccessor(AVLNode);
  end;
  SetLength(Result,i);
  if FreeTree then
    Nodes.Free;
end;

function NodeArrayAsString(Nodes: TLvlGraphNodeArray): String;
var
  i: Integer;
begin
  Result:='';
  for i:=0 to Length(Nodes)-1 do begin
    if i>0 then
      Result+=', ';
    Result+=Nodes[i].Caption;
  end;
end;

function dbgs(p: TLvlGraphNodeCaptionPosition): string;
begin
  Result:=GetEnumName(typeinfo(p),ord(p));
end;

function dbgs(o: TLvlGraphCtrlOption): string;
begin
  Result:=GetEnumName(typeinfo(o),ord(o));
end;

function dbgs(Options: TLvlGraphCtrlOptions): string;
var
  o: TLvlGraphCtrlOption;
begin
  Result:='';
  for o:=Low(TLvlGraphCtrlOption) to high(TLvlGraphCtrlOption) do
    if o in Options then begin
      if Result<>'' then Result+=',';
      Result+=dbgs(o);
    end;
  Result:='['+Result+']';
end;

{ TLvlGraphSubGraph }

constructor TLvlGraphSubGraph.Create(TheGraph: TLvlGraph; TheIndex: integer);
begin
  inherited Create;
  FGraph := TheGraph;
  FIndex := TheIndex;
  FGraph.fSubGraphs.Insert(TheIndex, Self);
end;

destructor TLvlGraphSubGraph.Destroy;
begin
  FGraph.fSubGraphs.Remove(Self);
  inherited Destroy;
end;

{ TGraphEdgeLenMinimizerTree }

function CompareEdgeLenMinimizerNodes(Node1, Node2: Pointer): integer;
begin
  Result:=ComparePointer(Node1,Node2);
end;

function CompareLGNodeWithEdgeLenMinimizerNode(GNode, ANode: Pointer): integer;
begin
  Result:=ComparePointer(GNode,ANode);
end;

{ TLvlGraphLimits }

procedure TLvlGraphLimits.SetMaxLevelHeightAbs(AValue: integer);
begin
  if FMaxLevelHeightAbs = AValue then Exit;
  FMaxLevelHeightAbs := AValue;
  Control.Invalidate;
end;

procedure TLvlGraphLimits.SetMaxLevelHeightRel(AValue: single);
begin
  if FMaxLevelHeightRel = AValue then Exit;
  FMaxLevelHeightRel := AValue;
  Control.Invalidate;
end;

constructor TLvlGraphLimits.Create(AControl: TCustomLvlGraphControl);
begin
  FControl:=AControl;
  FMaxLevelHeightAbs := DefaultMaxLevelHeightAbs;
  FMaxLevelHeightRel := DefaultMaxLevelHeightRel;
end;

destructor TLvlGraphLimits.Destroy;
begin
  FControl.FLimits:=nil;
  inherited Destroy;
end;

procedure TLvlGraphLimits.Assign(Source: TPersistent);
var
  Src: TLvlGraphLimits;
begin
  if Source is TLvlGraphLimits then begin
    Src:=TLvlGraphLimits(Source);
    MaxLevelHeightAbs := Src.MaxLevelHeightAbs;
    MaxLevelHeightRel := Src.MaxLevelHeightRel;
  end;
  inherited Assign(Source);
end;

function TLvlGraphLimits.Equals(Obj: TObject): boolean;
var
  Src: TLvlGraphLimits;
begin
  Result:=inherited Equals(Obj);
  if not Result then exit;
  if Obj is TLvlGraphLimits then begin
    Src:=TLvlGraphLimits(Obj);
    Result:=(MaxLevelHeightAbs=Src.MaxLevelHeightAbs)
        and (MaxLevelHeightRel=Src.MaxLevelHeightRel);
  end;
end;

constructor TGraphEdgeLenMinimizerTree.Create;
begin
  inherited Create(@CompareEdgeLenMinimizerNodes);
  NodeClass := TGraphEdgeLenMinimizerNode;
end;

function TGraphEdgeLenMinimizerTree.GetTreeNode(Node: TLvlGraphNode): TGraphEdgeLenMinimizerNode;
begin
  Result:=TGraphEdgeLenMinimizerNode(FindKey(Pointer(Node),@CompareLGNodeWithEdgeLenMinimizerNode));
end;

function TGraphEdgeLenMinimizerTree.AddGraphNode(Node: TLvlGraphNode
  ): TGraphEdgeLenMinimizerNode;
begin
  Result:=TGraphEdgeLenMinimizerNode(NodeClass.Create);
  Result.FTree := Self;
  Result.Node:=Node;
  Result.Data:=Node;
  if ExtNodeWithHighestLevel = nil then
    ExtNodeWithHighestLevel := Result
  else
    ExtNodeWithLowestLevel.NextExtNodeTowardsLowerLevel := Result;
  ExtNodeWithLowestLevel := Result;
  Add(Result);
end;

function TGraphEdgeLenMinimizerTree.MapLevel(ALvl: Integer): integer;
begin
  Result := TGraphEdgeLenMinimizerNodeClass(NodeClass).MapLevel(ALvl, Graph.LevelCount);
end;

{ TGraphEdgeLenMinimizerNode }

function TGraphEdgeLenMinimizerNode.GetLevel: Integer;
begin
  Result := Node.Level.Index;
end;

procedure TGraphEdgeLenMinimizerNode.SetLevel(AValue: Integer);
begin
  Node.Level := FTree.Graph.Levels[AValue];
end;

function TGraphEdgeLenMinimizerNode.GetInSibling(Index: Integer
  ): TGraphEdgeLenMinimizerNode;
begin
  Result := FTree.GetTreeNode(Node.InEdges[Index].Source);
end;

function TGraphEdgeLenMinimizerNode.GetOutSiblingDistance(Index: Integer
  ): Integer;
begin
  Result := Node.OutEdges[Index].Target.Level.Index - Node.Level.Index;
end;

function TGraphEdgeLenMinimizerNode.GetOutSibling(Index: Integer
  ): TGraphEdgeLenMinimizerNode;
begin
  Result := FTree.GetTreeNode(Node.OutEdges[Index].Target);
end;

class function TGraphEdgeLenMinimizerNode.MapLevel(ALvl, LvlCount: Integer
  ): integer;
begin
  Result := ALvl;
end;

function TGraphEdgeLenMinimizerNode.OutSiblingCount: Integer;
begin
  Result := Node.OutEdgeCount;
end;

function TGraphEdgeLenMinimizerNode.InSiblingCount: Integer;
begin
  Result := Node.InEdgeCount;
end;

{ TGraphEdgeLenMinimizerReverseNode }

function TGraphEdgeLenMinimizerReverseNode.GetInSibling(Index: Integer
  ): TGraphEdgeLenMinimizerNode;
begin
  Result := FTree.GetTreeNode(Node.OutEdges[Index].Target);
end;

function TGraphEdgeLenMinimizerReverseNode.GetOutSibling(Index: Integer
  ): TGraphEdgeLenMinimizerNode;
begin
  Result := FTree.GetTreeNode(Node.InEdges[Index].Source);
end;

function TGraphEdgeLenMinimizerReverseNode.GetOutSiblingDistance(Index: Integer
  ): Integer;
begin
  Result := Node.Level.Index - Node.InEdges[Index].Source.Level.Index;
end;

class function TGraphEdgeLenMinimizerReverseNode.MapLevel(ALvl,
  LvlCount: Integer): integer;
begin
  Result := LvlCount - 1 - ALvl;
end;

procedure TGraphEdgeLenMinimizerReverseNode.SetLevel(AValue: Integer);
begin
  Node.Level := FTree.Graph.Levels[MinSubGraphLevel + MaxSubGraphLevel - AValue];
end;

function TGraphEdgeLenMinimizerReverseNode.GetLevel: Integer;
begin
  Result := MinSubGraphLevel + MaxSubGraphLevel - Node.Level.Index;
end;

function TGraphEdgeLenMinimizerReverseNode.OutSiblingCount: Integer;
begin
  Result := Node.InEdgeCount;
end;

function TGraphEdgeLenMinimizerReverseNode.InSiblingCount: Integer;
begin
  Result := Node.OutEdgeCount;
end;

{ TLvlGraphEdgeStyle }

procedure TLvlGraphEdgeStyle.SetMouseDistMax(AValue: integer);
begin
  if FMouseDistMax=AValue then Exit;
  FMouseDistMax:=AValue;
end;

procedure TLvlGraphEdgeStyle.SetBackColor(AValue: TColor);
begin
  if FBackColor=AValue then Exit;
  FBackColor:=AValue;
  Control.Invalidate;
end;

procedure TLvlGraphEdgeStyle.SetColor(AValue: TColor);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  Control.Invalidate;
end;

procedure TLvlGraphEdgeStyle.SetBackHighlightColor(AValue: TColor);
begin
  if FBackHighlightColor=AValue then Exit;
  FBackHighlightColor:=AValue;
  Control.Invalidate;
end;

procedure TLvlGraphEdgeStyle.SetHighlightColor(AValue: TColor);
begin
  if FHighlightColor=AValue then Exit;
  FHighlightColor:=AValue;
  Control.Invalidate;
end;

procedure TLvlGraphEdgeStyle.SetShape(AValue: TLvlGraphEdgeShape);
begin
  if FShape=AValue then Exit;
  FShape:=AValue;
  Control.Invalidate;
end;

procedure TLvlGraphEdgeStyle.SetSplitMode(AValue: TLvlGraphEdgeSplitMode);
begin
  if FSplitMode=AValue then Exit;
  FSplitMode:=AValue;
  Control.InvalidateAutoLayout;
end;

constructor TLvlGraphEdgeStyle.Create(AControl: TCustomLvlGraphControl);
begin
  FControl:=AControl;
  FMouseDistMax:=DefaultLvlGraphEdgeNearMouseDistMax;
  FSplitMode:=DefaultLvlGraphEdgeSplitMode;
  FShape:=DefaultLvlGraphEdgeShape;
  FColor:=DefaultLvlGraphEdgeColor;
  FHighlightColor:=DefaultLvlGraphEdgeHighlightColor;
  FBackColor:=DefaultLvlGraphEdgeBackColor;
  FBackHighlightColor:=DefaultLvlGraphEdgeBackHighlightColor;
end;

destructor TLvlGraphEdgeStyle.Destroy;
begin
  FControl.FEdgeStyle:=nil;
  inherited Destroy;
end;

procedure TLvlGraphEdgeStyle.Assign(Source: TPersistent);
var
  Src: TLvlGraphEdgeStyle;
begin
  if Source is TLvlGraphEdgeStyle then begin
    Src:=TLvlGraphEdgeStyle(Source);
    MouseDistMax:=Src.MouseDistMax;
    SplitMode:=Src.SplitMode;
    Shape:=Src.Shape;
    Color:=Src.Color;
    HighlightColor:=Src.HighlightColor;
    BackColor:=Src.BackColor;
    BackHighlightColor:=Src.BackHighlightColor;
  end else
    inherited Assign(Source);
end;

function TLvlGraphEdgeStyle.Equals(Obj: TObject): boolean;
var
  Src: TLvlGraphEdgeStyle;
begin
  Result:=inherited Equals(Obj);
  if not Result then exit;
  if Obj is TLvlGraphEdgeStyle then begin
    Src:=TLvlGraphEdgeStyle(Obj);
    Result:=(SplitMode=Src.SplitMode)
        and (MouseDistMax=Src.MouseDistMax)
        and (Shape=Src.Shape)
        and (Color=Src.Color)
        and (HighlightColor=Src.HighlightColor)
        and (BackColor=Src.BackColor)
        and (BackHighlightColor=Src.BackHighlightColor);
  end;
end;

{ TMinXPair }

procedure TMinXPair.SetSwitchDiff(AValue: integer);
begin
  if FSwitchDiff=AValue then Exit;
  UnbindFromSwitchList;
  FSwitchDiff:=AValue;
  BindToSwitchList;
end;

constructor TMinXPair.Create(aLevel: TMinXLevel; aIndex: integer);
begin
  Level:=aLevel;
  Graph:=Level.Graph;
  Index:=aIndex;
end;

destructor TMinXPair.Destroy;
begin
  inherited Destroy;
end;

procedure TMinXPair.UnbindFromSwitchList;
begin
  if SwitchDiff > 0 then
    exit;
  if PrevSameSwitchPair<>nil then
    PrevSameSwitchPair.NextSameSwitchPair:=NextSameSwitchPair
  else if Graph.SameSwitchDiffPairs[-SwitchDiff]=Self
  then begin
    Graph.SameSwitchDiffPairs[-SwitchDiff]:=NextSameSwitchPair;
  end;
  if NextSameSwitchPair<>nil then
    NextSameSwitchPair.PrevSameSwitchPair:=PrevSameSwitchPair;
  PrevSameSwitchPair:=nil;
  NextSameSwitchPair:=nil;
end;

function TMinXPair.BindToSwitchList(AtEnd: Boolean): integer;
var
  n: TMinXPair;
begin
  Result := 0;
  if SwitchDiff > 0 then
    exit;
  n:=Graph.SameSwitchDiffPairs[-SwitchDiff];
  if AtEnd and (n<> nil) then begin
    while n.NextSameSwitchPair <> nil do begin
      n:=n.NextSameSwitchPair;
      inc(Result);
    end;
    n.NextSameSwitchPair:=Self;
    PrevSameSwitchPair:=n;
    exit;
  end;
  NextSameSwitchPair:=n;
  Graph.SameSwitchDiffPairs[-SwitchDiff]:=Self;
  if NextSameSwitchPair<>nil then
    NextSameSwitchPair.PrevSameSwitchPair:=Self;
  if (Graph.HighestSwitchDiff<-SwitchDiff) then
    Graph.HighestSwitchDiff:=-SwitchDiff;
end;

procedure TMinXPair.ComputeCrossingCount(out Crossing,
  SwitchCrossing: integer);
begin
  Level.GetCrossingCount(Level.Nodes[Index],Level.Nodes[Index+1],
    Crossing,SwitchCrossing);
end;

function TMinXPair.ComputeSwitchDiff: integer;
var
  Crossing, SwitchCrossing: integer;
begin
  Level.GetCrossingCount(Level.Nodes[Index],Level.Nodes[Index+1],
    Crossing,SwitchCrossing);
  Result:=SwitchCrossing-Crossing;
end;

function TMinXPair.AsString: string;
begin
  Result:='[lvl='+dbgs(Level.Index)
    +',A='+dbgs(Index)+':'+Level.Nodes[Index].GraphNode.Caption
    +',B='+dbgs(Index+1)+':'+Level.Nodes[Index+1].GraphNode.Caption
    +',Switch='+dbgs(SwitchDiff)
    +']';
end;

{ TMinXGraph }

constructor TMinXGraph.Create(aGraph: TLvlGraph);
var
  GraphNode: TLvlGraphNode;
  i: Integer;
  Level: TMinXLevel;
  n: Integer;
  e: Integer;
  Node: TMinXNode;
  Cnt: Integer;
  OtherNode: TMinXNode;
begin
  Graph:=aGraph;

  // create nodes
  FGraphNodeToNode:=TPointerToPointerTree.Create;
  for i:=0 to Graph.NodeCount-1 do begin
    GraphNode:=Graph.Nodes[i];
    Node:=TMinXNode.Create(GraphNode);
    FGraphNodeToNode[GraphNode]:=Node;
  end;

  // create levels
  SetLength(Levels,aGraph.LevelCount);
  for i:=0 to length(Levels)-1 do
    Levels[i]:=TMinXLevel.Create(Self,i);

  // create OutEdges arrays
  for i:=0 to length(Levels)-2 do begin
    Level:=Levels[i];
    for n:=0 to length(Level.Nodes)-1 do begin
      Node:=Level.Nodes[n];
      GraphNode:=Node.GraphNode;
      SetLength(Node.OutEdges,GraphNode.OutEdgeCount);
      Cnt:=0;
      for e:=0 to GraphNode.OutEdgeCount-1 do begin
        OtherNode:=GraphNodeToNode(GraphNode.OutEdges[e].Target);
        if Node.Level.Index+1<>OtherNode.Level.Index then continue;
        Node.OutEdges[Cnt]:=OtherNode;
        Cnt+=1;
      end;
      SetLength(Node.OutEdges,Cnt);
    end;
  end;

  // create InEdges arrays
  for i:=1 to length(Levels)-1 do begin
    Level:=Levels[i];
    for n:=0 to length(Level.Nodes)-1 do begin
      Node:=Level.Nodes[n];
      GraphNode:=Node.GraphNode;
      SetLength(Node.InEdges,GraphNode.InEdgeCount);
      Cnt:=0;
      for e:=0 to GraphNode.InEdgeCount-1 do begin
        OtherNode:=GraphNodeToNode(GraphNode.InEdges[e].Source);
        if Node.Level.Index-1<>OtherNode.Level.Index then continue;
        Node.InEdges[Cnt]:=OtherNode;
        Cnt+=1;
      end;
      SetLength(Node.InEdges,Cnt);
    end;
  end;

  InitPairs;
  BindPairs;

  {$IFDEF CheckMinXGraph}
  ConsistencyCheck;
  {$ENDIF}
end;

destructor TMinXGraph.Destroy;
var
  i: Integer;
begin
  for i:=0 to length(Levels)-1 do
    Levels[i].Free;
  SetLength(Levels,0);
  for i:=0 to length(Pairs)-1 do
    Pairs[i].Free;
  SetLength(Pairs,0);
  SetLength(SameSwitchDiffPairs,0);
  FreeAndNil(FGraphNodeToNode);
  inherited Destroy;
end;

procedure TMinXGraph.InitPairs;
var
  Cnt: Integer;
  i, n: Integer;
  Level: TMinXLevel;
  Pair: TMinXPair;
begin
  Cnt:=0;
  for i:=0 to length(Levels)-1 do
    Cnt+=Max(0,length(Levels[i].Nodes)-1);
  SetLength(Pairs,Cnt);

  Cnt:=0;
  for i:=0 to length(Levels)-1 do begin
    Level:=Levels[i];
    if length(Level.Nodes) > 0 then
      SetLength(Level.Pairs,length(Level.Nodes)-1);
    for n:=0 to length(Level.Pairs)-1 do begin
      Pair:=TMinXPair.Create(Level,n);
      Pairs[Cnt]:=Pair;
      Level.Pairs[n]:=Pair;
      Cnt+=1;
    end;
  end;

  HighestSwitchDiff:=-1;
  // TODO: CountOfEdges (even less: Max(Cnt(Level.OutEdges))
  // Worst case: half the nodes are on Level[0], the other half on Level[1]
  SetLength(SameSwitchDiffPairs,Graph.NodeCount*Graph.NodeCount div 4 +1);
end;

procedure TMinXGraph.UnbindPairs;
var
  i: Integer;
begin
  for i:=0 to length(Pairs)-1 do
    Pairs[i].UnbindFromSwitchList;
end;

procedure TMinXGraph.BindPairs;
var
  i: Integer;
  Pair: TMinXPair;
begin
  for i:=0 to length(Pairs)-1 do begin
    Pair:=Pairs[i];
    Pair.FSwitchDiff:=Pair.ComputeSwitchDiff;
    Pair.BindToSwitchList;
  end;

  CrossCount:=ComputeCrossCount;
end;

function TMinXGraph.ComputeCrossCount: integer;
var
  l: Integer;
  Level: TMinXLevel;
  i: Integer;
  Node1: TMinXNode;
  j: Integer;
  Node2: TMinXNode;
  e1: Integer;
  Target1: TMinXNode;
  e2: Integer;
  Target2: TMinXNode;
begin
  Result:=0;
  for l:=0 to length(Levels)-2 do begin
    Level:=Levels[l];
    for i:=0 to length(Level.Nodes)-2 do begin
      Node1:=Level.Nodes[i];
      for j:=i+1 to length(Level.Nodes)-1 do begin
        Node2:=Level.Nodes[j];
        for e1:=0 to length(Node1.OutEdges)-1 do begin
          Target1:=Node1.OutEdges[e1];
          for e2:=0 to length(Node2.OutEdges)-1 do begin
            Target2:=Node2.OutEdges[e2];
            if Target1.IndexInLevel>Target2.IndexInLevel then
              Result+=1;
          end;
        end;
      end;
    end;
  end;
end;

procedure TMinXGraph.InitSearch;
begin
  StoreAsBest(false);
end;

procedure TMinXGraph.StoreAsBest(CheckIfBetter: boolean);
var
  l: Integer;
  Level: TMinXLevel;
  n: Integer;
begin
  if CheckIfBetter then begin // e.g. after Shuffly => a new full StoreAsBest is needed
    PairsChangedSinceBestStored := TMinXPair(PtrUInt(-1));
  end;

  if CheckIfBetter and (BestCrossCount>=0) and (BestCrossCount<CrossCount) then
    exit;
  PairsChangedSinceBestStored := nil;
  BestCrossCount:=CrossCount;

  for l:=0 to length(Pairs)-1 do
    Pairs[l].NextChangedSinceBestStored := nil;
  for l:=0 to length(Levels)-1 do begin
    Level:=Levels[l];
    for n:=0 to length(Level.Nodes)-1 do
      Level.BestNodes[n]:=Level.Nodes[n].GraphNode;
  end;
end;

procedure TMinXGraph.StoreAsBest(APair: TMinXPair);
var
  idx: Integer;
  NextPair: TMinXPair;
begin
  if PairsChangedSinceBestStored = TMinXPair(PtrUInt(-1)) then begin
    StoreAsBest(True);
    exit;
  end;
  if (BestCrossCount>=0) and (BestCrossCount<CrossCount) then begin
    if APair.NextChangedSinceBestStored = nil then begin
      APair.NextChangedSinceBestStored := PairsChangedSinceBestStored;
      PairsChangedSinceBestStored := APair;
    end;
    exit;
  end;
  BestCrossCount:=CrossCount;

  while APair <> nil do begin
    with APair.Level do begin
      idx := APair.Index;
      BestNodes[idx]:=Nodes[idx].GraphNode;
      inc(idx);
      BestNodes[idx]:=Nodes[idx].GraphNode;
    end;
    NextPair := APair.NextChangedSinceBestStored;
    APair.NextChangedSinceBestStored := nil;
    APair := NextPair;
  end;
end;

function TMinXGraph.ComputeHighestSwitchDiff(StartAtOld: boolean;
  IgnorePair: TMinXPair): integer;
var
  i: Integer;
  Pair: TMinXPair;
begin
  if StartAtOld then begin
    for i:=HighestSwitchDiff-1 downto 0 do begin
      if SameSwitchDiffPairs[i]<>nil then
        exit(i);
    end;
    exit(-1);
  end;

  // Search all Pairs
  Result:= -1;
  for i:=0 to length(Pairs)-1 do begin
    Pair:=Pairs[i];
    if IgnorePair=Pair then continue;
    Result:=Max(Result,-Pair.SwitchDiff);
  end;
end;

function TMinXGraph.FindBestPair: TMinXPair;
begin
  if HighestSwitchDiff>=0 then begin
    Result:=SameSwitchDiffPairs[HighestSwitchDiff];
    if Result = nil then begin
      HighestSwitchDiff := ComputeHighestSwitchDiff(True, nil);
      if HighestSwitchDiff>=0 then
        Result:=SameSwitchDiffPairs[HighestSwitchDiff];
    end;
  end
  else
    Result:=nil;
end;

procedure TMinXGraph.SwitchCrossingPairs(MaxRun: int64; var Run: int64;
  ZeroRunLimit: int64);
(* Calculating how many rounds to go for ZeroRun
   Switching a node with SwitchDiff=0, can move other zero-nodes (i.e.,
   remove them in one place, and create another in a new place)
   Extra loops are needed to:
   - run such new nodes
   - re-run and switch back the original nodes, to test the zero-nodes
     that were removed.
   Sucessful swaps (unblocking actual crossings) can be found even at
   high multiplies of LastInsertIdx (the count of zero-nodes)
*)
var
  Pair: TMinXPair;
  CountOfZeroDiffNodes, ZeroRun, ZeroBest: Integer;
begin
  while (MaxRun>0) and (BestCrossCount<>0) do begin
    //debugln(['TMinXGraph.SwitchCrossingPairs ',MaxRun,' ',Run]);
    Pair:=FindBestPair;
    if (Pair=nil) then exit;
    if (Pair.SwitchDiff=0) then break; // Enter ZeroRun
    Run+=1;
    SwitchPair(Pair);
    MaxRun-=1;
  end;

  ZeroRun := -1;
  ZeroBest := high(ZeroBest);
  while (MaxRun>0) and (BestCrossCount<>0) do begin
    if (Pair.SwitchDiff<0) then begin
      SwitchPair(Pair);
      if CrossCount < ZeroBest then
        ZeroRun := -1;
    end
    else begin
      if ZeroRun > 0 then begin
        dec(ZeroRun);
        if ZeroRun = 0 then
          exit;
      end;

      SwitchPair(Pair);
      Pair.UnbindFromSwitchList;
      CountOfZeroDiffNodes := Pair.BindToSwitchList(True);
      if (ZeroRun < 0) then begin
        ZeroRun := Max(4 * CountOfZeroDiffNodes+1, Graph.NodeCount);
        if CrossCount < BestCrossCount * 4 then
          ZeroRun := ZeroRun * 4;
        ZeroRun := Min(ZeroRun, ZeroRunLimit);
        if CrossCount < ZeroBest then
          ZeroBest := CrossCount;
      end;
    end;

    Pair:=FindBestPair;
    if (Pair=nil) then exit;
    Run+=1;
    MaxRun-=1;
  end;
end;

procedure TMinXGraph.Shuffle;
var
  l, i: Integer;
  Level: TMinXLevel;
  n1: Integer;
  n2: Integer;
  Node: TMinXNode;
begin
  {$IFDEF CheckMinXGraph}
  ConsistencyCheck;
  {$ENDIF}
  UnbindPairs;
  for l:=0 to length(Levels)-1 do begin
    Level:=Levels[l];
    for i:=0 to 1 do begin
      n1:=Random(length(Level.Nodes));
      n2:=Random(length(Level.Nodes));
      if n1=n2 then continue;
      Node:=Level.Nodes[n1];
      Level.Nodes[n1]:=Level.Nodes[n2];
      Level.Nodes[n2]:=Node;
      Level.Nodes[n1].IndexInLevel:=n1;
      Level.Nodes[n2].IndexInLevel:=n2;
    end;
  end;
  BindPairs;
  StoreAsBest(true);
  {$IFDEF CheckMinXGraph}
  ConsistencyCheck;
  {$ENDIF}
end;

procedure TMinXGraph.SwitchAndShuffle(MaxSingleRun, MaxTotalRun: int64);
var
  Run, LastRun: int64;
begin
  Run:=1;
  LastRun := 0;
  while BestCrossCount<>0 do begin
    SwitchCrossingPairs(MaxSingleRun,Run,Graph.NodeCount div 2);
    if Run = LastRun then exit;
    if Run>MaxTotalRun then break;
    Shuffle;
    LastRun := Run;
  end;
  SwitchCrossingPairs(MaxSingleRun,Run, MaxTotalRun);
end;

procedure TMinXGraph.SwitchPair(Pair: TMinXPair);

  procedure UpdateSwitchDiff(TargetOfNode1, TargetOfNode2: TMinXNode);
  var
    TargetPair: TMinXPair;
  begin
    if TargetOfNode1.IndexInLevel+1=TargetOfNode2.IndexInLevel then begin
      TargetPair:=TargetOfNode1.Level.Pairs[TargetOfNode1.IndexInLevel];
      // no longer crossing, switching TargetPair would create the cross again, from -1 to +1 = +2
      TargetPair.SwitchDiff:=TargetPair.SwitchDiff+2;
    end else if TargetOfNode1.IndexInLevel-1=TargetOfNode2.IndexInLevel then begin
      TargetPair:=TargetOfNode2.Level.Pairs[TargetOfNode2.IndexInLevel];
      // now crossing, switching TargetPair would solve the cross again, from +1 to -1 = -2
      TargetPair.SwitchDiff:=TargetPair.SwitchDiff-2;
    end;
  end;

var
  Node1, Node2: TMinXNode;
  i: Integer;
  j: Integer;
  NeighbourPair: TMinXPair;
  Level: TMinXLevel;
begin
  //debugln(['TMinXGraph.SwitchPair ',Pair.AsString]);
  {$IFDEF CheckMinXGraph}
  ConsistencyCheck;
  {$ENDIF}

  Level:=Pair.Level;

  // switch nodes
  Node1:=Level.Nodes[Pair.Index];
  Node2:=Level.Nodes[Pair.Index+1];
  Level.Nodes[Pair.Index]:=Node2;
  Level.Nodes[Pair.Index+1]:=Node1;
  Node1:=Level.Nodes[Pair.Index];
  Node2:=Level.Nodes[Pair.Index+1];
  Node1.IndexInLevel:=Pair.Index;
  Node2.IndexInLevel:=Pair.Index+1;

  // reverse Pair.SwitchDiff
  CrossCount+=Pair.SwitchDiff;
  Pair.SwitchDiff:=-Pair.SwitchDiff;
  //debugln(['TMinXGraph.SwitchPair Pair.SwitchDiff should be equal: ',Pair.SwitchDiff,' = ',Pair.ComputeSwitchDiff]);

  // compute SwitchDiff of new neighbour pairs
  if Pair.Index>0 then begin
    NeighbourPair:=Level.Pairs[Pair.Index-1];
    NeighbourPair.SwitchDiff:=NeighbourPair.ComputeSwitchDiff;
  end;
  if Pair.Index+1<length(Level.Pairs) then begin
    NeighbourPair:=Level.Pairs[Pair.Index+1];
    NeighbourPair.SwitchDiff:=NeighbourPair.ComputeSwitchDiff;
  end;

  // update SwitchDiff of all connected nodes
  for i:=0 to length(Node1.OutEdges)-1 do
    for j:=0 to length(Node2.OutEdges)-1 do
      UpdateSwitchDiff(Node1.OutEdges[i],Node2.OutEdges[j]);
  for i:=0 to length(Node1.InEdges)-1 do
    for j:=0 to length(Node2.InEdges)-1 do
      UpdateSwitchDiff(Node1.InEdges[i],Node2.InEdges[j]);

  StoreAsBest(Pair);

  {$IFDEF CheckMinXGraph}
  ConsistencyCheck;
  {$ENDIF}
end;

procedure TMinXGraph.Apply;
var
  i: Integer;
  Level: TMinXLevel;
  j: Integer;
begin
  for i:=0 to length(Levels)-1 do begin
    Level:=Levels[i];
    for j:=0 to length(Level.BestNodes)-1 do
      Level.BestNodes[j].IndexInLevel:=j;
  end;
end;

function TMinXGraph.GraphNodeToNode(GraphNode: TLvlGraphNode): TMinXNode;
begin
  Result:=TMinXNode(FGraphNodeToNode[GraphNode]);
end;

procedure TMinXGraph.ConsistencyCheck;

  procedure Err(Msg: string = '');
  begin
    raise Exception.Create('TMinXGraph.ConsistencyCheck: '+Msg);
  end;

var
  i: Integer;
  Pair: TMinXPair;
  Level: TMinXLevel;
  j: Integer;
  Node: TMinXNode;
  e: Integer;
  OtherNode: TMinXNode;
  k: Integer;
  AVLNode: TAvlTreeNode;
  P2PItem: PPointerToPointerItem;
begin
  AVLNode:=FGraphNodeToNode.Tree.FindLowest;
  while AVLNode<>nil do begin
    P2PItem:=PPointerToPointerItem(AVLNode.Data);
    if not (TObject(P2PItem^.Key) is TLvlGraphNode) then
      Err(DbgSName(TObject(P2PItem^.Key)));
    if not (TObject(P2PItem^.Value) is TMinXNode) then
      Err(DbgSName(TObject(P2PItem^.Value)));
    if TMinXNode(P2PItem^.Value).GraphNode=nil then
      Err(dbgs(TMinXNode(P2PItem^.Value).IndexInLevel));
    if TLvlGraphNode(P2PItem^.Key)<>TMinXNode(P2PItem^.Value).GraphNode then
      Err;
    AVLNode:=FGraphNodeToNode.Tree.FindSuccessor(AVLNode);
  end;

  if length(Levels)<>Graph.LevelCount then
    Err;
  for i:=0 to length(Levels)-1 do begin
    Level:=Levels[i];
    for j:=0 to Length(Level.Pairs)-1 do begin
      Pair:=Level.Pairs[j];
      if Pair.Level<>Level then
        Err(Pair.AsString);
    end;
    for j:=0 to length(Level.Nodes)-1 do begin
      Node:=Level.Nodes[j];
      if Node.Level<>Level then
        Err;
      if Node.IndexInLevel<>j then
        Err;
      if Node.GraphNode=nil then
        Err;
      for e:=0 to length(Node.InEdges)-1 do begin
        OtherNode:=Node.InEdges[e];
        if OtherNode=nil then
          Err('node="'+Node.GraphNode.Caption+'" e='+dbgs(e));
        if Node.Level.Index-1<>OtherNode.Level.Index then
          Err('node="'+Node.GraphNode.Caption+'" othernode="'+OtherNode.GraphNode.Caption+'"');
        k:=length(OtherNode.OutEdges)-1;
        while (k>=0) and (OtherNode.OutEdges[k]<>Node) do dec(k);
        if k<0 then
          Err('node="'+Node.GraphNode.Caption+'" othernode="'+OtherNode.GraphNode.Caption+'"');
      end;
      for e:=0 to length(Node.OutEdges)-1 do begin
        OtherNode:=Node.OutEdges[e];
        if OtherNode=nil then
          Err('node="'+Node.GraphNode.Caption+'" e='+dbgs(e));
        if Node.Level.Index+1<>OtherNode.Level.Index then
          Err('node="'+Node.GraphNode.Caption+'" othernode="'+OtherNode.GraphNode.Caption+'"');
        k:=length(OtherNode.InEdges)-1;
        while (k>=0) and (OtherNode.InEdges[k]<>Node) do dec(k);
        if k<0 then
          Err('node="'+Node.GraphNode.Caption+'" othernode="'+OtherNode.GraphNode.Caption+'"');
      end;
    end;
  end;
  for i:=0 to length(Pairs)-1 do begin
    Pair:=Pairs[i];
    if Pair.Graph<>Self then
      Err(Pair.AsString);
    if Pair.Level.Pairs[Pair.Index]<>Pair then
      Err(Pair.AsString);
    if Pair.SwitchDiff<>Pair.ComputeSwitchDiff then
      Err(Pair.AsString);
  end;
  for i:=0 to length(SameSwitchDiffPairs)-1 do begin
    Pair:=SameSwitchDiffPairs[i];
    while Pair<>nil do begin
      if -Pair.SwitchDiff<>i then
        Err(Pair.AsString);
      if Pair.PrevSameSwitchPair<>nil then begin
        if Pair.PrevSameSwitchPair.NextSameSwitchPair<>Pair then
          Err(Pair.AsString);
      end else begin
        if Pair<>SameSwitchDiffPairs[i] then
          Err(Pair.AsString);
      end;
      if Pair.NextSameSwitchPair<>nil then begin
        if Pair.NextSameSwitchPair.PrevSameSwitchPair<>Pair then
          Err(Pair.AsString);
      end;
      Pair:=Pair.NextSameSwitchPair;
    end;
  end;

  if CrossCount<>ComputeCrossCount then
    Err;
  if (HighestSwitchDiff < 0) or (SameSwitchDiffPairs[HighestSwitchDiff] <> nil) then
    if HighestSwitchDiff<>ComputeHighestSwitchDiff(false,nil) then
      Err;
end;

{ TMinXLevel }

constructor TMinXLevel.Create(aGraph: TMinXGraph; aIndex: integer);
var
  i: Integer;
  GraphNode: TLvlGraphNode;
  Node: TMinXNode;
begin
  Index:=aIndex;
  Graph:=aGraph;
  GraphLevel:=Graph.Graph.Levels[Index];
  SetLength(Nodes,GraphLevel.Count);
  SetLength(BestNodes,length(Nodes));
  for i:=0 to length(Nodes)-1 do begin
    GraphNode:=GraphLevel[i];
    Node:=Graph.GraphNodeToNode(GraphNode);
    Node.Level:=Self;
    Node.IndexInLevel:=i;
    Nodes[i]:=Node;
    BestNodes[i]:=GraphNode;
  end;
end;

destructor TMinXLevel.Destroy;
var
  i: Integer;
begin
  SetLength(Pairs,0);
  for i:=0 to length(Nodes)-1 do
    Nodes[i].Free;
  SetLength(Nodes,0);
  SetLength(BestNodes,0);
  inherited Destroy;
end;

procedure TMinXLevel.GetCrossingCount(Node1, Node2: TMinXNode; out
  Crossing, SwitchCrossing: integer);
var
  i: Integer;
  j: Integer;
  n: TMinXNode;
begin
  if (Node1.IndexInLevel>Node2.IndexInLevel) then begin
    n := Node1;
    Node1 := Node2;
    Node2 := n;
  end;

  Crossing:=0;
  SwitchCrossing:=0;
  for i:=0 to length(Node1.OutEdges)-1 do begin
    for j:=0 to length(Node2.OutEdges)-1 do begin
      if Node1.OutEdges[i]=Node2.OutEdges[j] then continue;
      if (Node1.OutEdges[i].IndexInLevel>Node2.OutEdges[j].IndexInLevel)
      then
        Crossing+=1
      else
        SwitchCrossing+=1;
    end;
  end;
  for i:=0 to length(Node1.InEdges)-1 do begin
    for j:=0 to length(Node2.InEdges)-1 do begin
      if Node1.InEdges[i]=Node2.InEdges[j] then continue;
      // these two edges can cross
      if (Node1.InEdges[i].IndexInLevel>Node2.InEdges[j].IndexInLevel)
      then
        Crossing+=1
      else
        SwitchCrossing+=1;
    end;
  end;
end;

{ TMinXNode }

constructor TMinXNode.Create(aNode: TLvlGraphNode);
begin
  GraphNode:=aNode;
end;

destructor TMinXNode.Destroy;
begin
  SetLength(InEdges,0);
  SetLength(OutEdges,0);
  inherited Destroy;
end;

{ TLvlGraphNodeStyle }

procedure TLvlGraphNodeStyle.SetCaptionPosition(
  AValue: TLvlGraphNodeCaptionPosition);
begin
  if FCaptionPosition=AValue then Exit;
  FCaptionPosition:=AValue;
  Control.InvalidateAutoLayout;
end;

procedure TLvlGraphNodeStyle.SetCaptionScale(AValue: single);
begin
  if FCaptionScale=AValue then Exit;
  FCaptionScale:=AValue;
  Control.InvalidateAutoLayout;
end;

procedure TLvlGraphNodeStyle.SetColoring(AValue: TLvlGraphNodeColoring);
begin
  if FColoring=AValue then Exit;
  FColoring:=AValue;
  if not (csLoading in Control.ComponentState) then begin
    if Coloring=lgncRGB then
      Control.ColorNodesRandomRGB;
  end;
end;

procedure TLvlGraphNodeStyle.SetDefaultImageIndex(AValue: integer);
begin
  if FDefaultImageIndex=AValue then Exit;
  FDefaultImageIndex:=AValue;
  Control.Invalidate;
end;

procedure TLvlGraphNodeStyle.SetGapBottom(AValue: integer);
begin
  if FGapBottom=AValue then Exit;
  FGapBottom:=AValue;
  Control.InvalidateAutoLayout;
end;

procedure TLvlGraphNodeStyle.SetGapLeft(AValue: integer);
begin
  if FGapLeft=AValue then Exit;
  FGapLeft:=AValue;
  Control.InvalidateAutoLayout;
end;

procedure TLvlGraphNodeStyle.SetGapRight(AValue: integer);
begin
  if FGapRight=AValue then Exit;
  FGapRight:=AValue;
  Control.InvalidateAutoLayout;
end;

procedure TLvlGraphNodeStyle.SetGapTop(AValue: integer);
begin
  if FGapTop=AValue then Exit;
  FGapTop:=AValue;
  Control.InvalidateAutoLayout;
end;

procedure TLvlGraphNodeStyle.SetShape(AValue: TLvlGraphNodeShape);
begin
  if FShape=AValue then Exit;
  FShape:=AValue;
  Control.Invalidate;
end;

procedure TLvlGraphNodeStyle.SetWidth(AValue: integer);
begin
  if FWidth=AValue then Exit;
  FWidth:=AValue;
  Control.InvalidateAutoLayout;
end;

constructor TLvlGraphNodeStyle.Create(AControl: TCustomLvlGraphControl);
begin
  FControl:=AControl;
  FWidth:=DefaultLvlGraphNodeWith;
  FGapLeft:=DefaultLvlGraphNodeGapLeft;
  FGapTop:=DefaultLvlGraphNodeGapTop;
  FGapRight:=DefaultLvlGraphNodeGapRight;
  FGapBottom:=DefaultLvlGraphNodeGapBottom;
  FCaptionScale:=DefaultLvlGraphNodeCaptionScale;
  FCaptionPosition:=DefaultLvlGraphNodeCaptionPosition;
  FShape:=DefaultLvlGraphNodeShape;
  FDefaultImageIndex:=-1;
  FColoring:=DefaultLvlGraphNodeColoring;
end;

destructor TLvlGraphNodeStyle.Destroy;
begin
  FControl.FNodeStyle:=nil;
  inherited Destroy;
end;

procedure TLvlGraphNodeStyle.Assign(Source: TPersistent);
var
  Src: TLvlGraphNodeStyle;
begin
  if Source is TLvlGraphNodeStyle then begin
    Src:=TLvlGraphNodeStyle(Source);
    Width:=Src.Width;
    GapLeft:=Src.GapLeft;
    GapRight:=Src.GapRight;
    GapTop:=Src.GapTop;
    GapBottom:=Src.GapBottom;
    CaptionScale:=Src.CaptionScale;
    CaptionPosition:=Src.CaptionPosition;
    Shape:=Src.Shape;
    DefaultImageIndex:=Src.DefaultImageIndex;
  end else
    inherited Assign(Source);
end;

function TLvlGraphNodeStyle.Equals(Obj: TObject): boolean;
var
  Src: TLvlGraphNodeStyle;
begin
  Result:=inherited Equals(Obj);
  if not Result then exit;
  if Obj is TLvlGraphNodeStyle then begin
    Src:=TLvlGraphNodeStyle(Obj);
    Result:=(Width=Src.Width)
        and (GapLeft=Src.GapLeft)
        and (GapRight=Src.GapRight)
        and (GapTop=Src.GapTop)
        and (GapBottom=Src.GapBottom)
        and (CaptionScale=Src.CaptionScale)
        and (CaptionPosition=Src.CaptionPosition)
        and (Shape=Src.Shape)
        and (DefaultImageIndex=Src.DefaultImageIndex);
  end;
end;

{ TLvlGraphLevel }

function TLvlGraphLevel.GetNodes(Index: integer): TLvlGraphNode;
begin
  Result:=TLvlGraphNode(fNodes[Index]);
end;

procedure TLvlGraphLevel.SetDrawPosition(AValue: integer);
begin
  if FDrawPosition=AValue then Exit;
  FDrawPosition:=AValue;
  Invalidate;
end;

procedure TLvlGraphLevel.MoveNode(Node: TLvlGraphNode; NewIndexInLevel: integer
  );
var
  OldIndexInLevel: Integer;
begin
  OldIndexInLevel:=fNodes.IndexOf(Node);
  if OldIndexInLevel=NewIndexInLevel then exit;
  fNodes.Move(OldIndexInLevel,NewIndexInLevel);
end;

constructor TLvlGraphLevel.Create(TheGraph: TLvlGraph; TheIndex: integer);
var
  i: Integer;
begin
  FGraph:=TheGraph;
  if TheIndex < FGraph.fLevels.Count then begin
    FGraph.fLevels.Insert(TheIndex, Self);
    for i := TheIndex + 1 to FGraph.fLevels.Count - 1 do
      TLvlGraphLevel(FGraph.fLevels[i]).FIndex := TLvlGraphLevel(FGraph.fLevels[i]).Index + 1;
  end
  else
    FGraph.fLevels.Add(Self);
  FIndex:=TheIndex;
  fNodes:=TFPList.Create;
  if Graph<>nil then
    Graph.StructureChanged(Self,opInsert);
end;

destructor TLvlGraphLevel.Destroy;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    Nodes[i].OnLevelDestroy;
  if Count>0 then
    raise Exception.Create('');
  FreeAndNil(fNodes);
  Graph.InternalRemoveLevel(Self);
  inherited Destroy;
end;

procedure TLvlGraphLevel.Invalidate;
begin
  if Graph<>nil then
    Graph.Invalidate;
end;

function TLvlGraphLevel.IndexOf(Node: TLvlGraphNode): integer;
begin
  for Result:=0 to Count-1 do
    if Nodes[Result]=Node then exit;
  Result:=-1;
end;

function TLvlGraphLevel.Count: integer;
begin
  Result:=fNodes.Count;
end;

function TLvlGraphLevel.GetTotalInOutWeights: single;
var
  i: Integer;
  Node: TLvlGraphNode;
begin
  Result:=0;
  for i:=0 to Count-1 do begin
    Node:=Nodes[i];
    Result+=Max(Node.InWeight,Node.OutWeight);
  end;
end;

{ TCustomLvlGraphControl }

procedure TCustomLvlGraphControl.GraphInvalidate(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomLvlGraphControl.GraphStructureChanged(Sender,
  Element: TObject; Operation: TOperation);
begin
  if ((Element is TLvlGraphNode)
  or (Element is TLvlGraphEdge)) then begin
    if Operation=opRemove then begin
      if FNodeUnderMouse=Element then
        FNodeUnderMouse:=nil;
    end;
    //debugln(['TCustomLvlGraphControl.GraphStructureChanged ']);
    if lgoAutoLayout in FOptions then
      InvalidateAutoLayout;
  end;
end;

procedure TCustomLvlGraphControl.SetNodeUnderMouse(AValue: TLvlGraphNode);
begin
  if FNodeUnderMouse=AValue then Exit;
  FNodeUnderMouse:=AValue;
  if lgoHighlightNodeUnderMouse in Options then
    HighlightConnectedEgdes(NodeUnderMouse);
end;

procedure TCustomLvlGraphControl.DrawEdges(Highlighted: boolean);
var
  i: Integer;
  Level: TLvlGraphLevel;
  j: Integer;
  Node: TLvlGraphNode;
  k: Integer;
  Edge: TLvlGraphEdge;
  TargetNode: TLvlGraphNode;
begin
  for i:=0 to Graph.LevelCount-1 do begin
    Level:=Graph.Levels[i];
    for j:=0 to Level.Count-1 do begin
      Node:=Level.Nodes[j];
      for k:=0 to Node.OutEdgeCount-1 do begin
        Edge:=Node.OutEdges[k];
        TargetNode:=Edge.Target;
        if Edge.Highlighted<>Highlighted then continue;
        // compare Level in case MarkBackEdges was skipped
        if (TargetNode.Level.Index>Level.Index) and (not Edge.BackEdge) then begin
          // normal dependency
          // => draw line from right of Node to left of TargetNode
          if Edge.Highlighted then
            Canvas.Pen.Color:=EdgeStyle.HighlightColor
          else
            Canvas.Pen.Color:=EdgeStyle.Color;
        end else begin
          // cycle dependency
          // => draw line from left of Node to right of TargetNode
          if Edge.Highlighted then
            Canvas.Pen.Color:=EdgeStyle.BackHighlightColor
          else
            Canvas.Pen.Color:=EdgeStyle.BackColor;
        end;
        DoDrawEdge(Edge);
      end;
    end;
  end;
end;

procedure TCustomLvlGraphControl.GraphSelectionChanged(Sender: TObject);
begin
  if OnSelectionChanged<>nil then
    OnSelectionChanged(Self);
end;

procedure TCustomLvlGraphControl.ImageListChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomLvlGraphControl.DrawCaptions(const TxtH: integer);
var
  Node: TLvlGraphNode;
  j: Integer;
  Level: TLvlGraphLevel;
  i: Integer;
  TxtW: Integer;
  p: TPoint;
  Details: TThemedElementDetails;
  NodeRect: TRect;
begin
  Canvas.Font.Height:=round(single(TxtH)*NodeStyle.CaptionScale+0.5);
  for i:=0 to Graph.LevelCount-1 do begin
    Level:=Graph.Levels[i];
    for j:=0 to Level.Count-1 do begin
      Node:=Level.Nodes[j];
      if (Node.Caption='') or (not Node.Visible) then continue;
      TxtW:=Canvas.TextWidth(Node.Caption);
      case NodeStyle.CaptionPosition of
      lgncLeft,lgncRight: p.y:=GetZoomedCenter(Node)-(TxtH div 2);
      lgncTop: p.y:=GetZoomedTop(Node)-NodeStyle.GapTop-TxtH;
      lgncBottom: p.y:=GetZoomedBottom(Node)+NodeStyle.GapBottom;
      end;
      case NodeStyle.CaptionPosition of
      lgncLeft: p.x:=ApplyZoom(Level.DrawPosition)-NodeStyle.GapLeft-TxtW;
      lgncRight: p.x:=ApplyZoom(Level.DrawPosition)+NodeStyle.Width+NodeStyle.GapRight;
      lgncTop,lgncBottom: p.x:=ApplyZoom(Level.DrawPosition)+((NodeStyle.Width-TxtW) div 2);
      end;
      //debugln(['TCustomLvlGraphControl.Paint ',Node.Caption,' DrawPosition=',Node.DrawPosition,' DrawSize=',Node.DrawSize,' TxtH=',TxtH,' TxtW=',TxtW,' p=',dbgs(p),' Selected=',Node.Selected]);
      Node.FDrawnCaptionRect:=Bounds(p.x,p.y,TxtW,TxtH);
      p := ClientPosFor(p);
      NodeRect:=Bounds(p.x,p.y,TxtW,TxtH);
      if Node.Selected then begin
        if lgcFocusedPainting in FFlags then
          Details := ThemeServices.GetElementDetails(ttItemSelected)
        else
          Details := ThemeServices.GetElementDetails(ttItemSelectedNotFocus);
        ThemeServices.DrawElement(Canvas.Handle, Details, NodeRect, nil);
      end else begin
        Details := ThemeServices.GetElementDetails(ttItemNormal);
        //Canvas.Brush.Style:=bsClear;
        //Canvas.Brush.Color:=clNone;
      end;
      ThemeServices.DrawText(Canvas, Details, Node.Caption, NodeRect,
           DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX, 0)
      //Canvas.TextOut(p.x,p.y,Node.Caption);
    end;
  end;
end;

procedure TCustomLvlGraphControl.ComputeEdgeCoords;
var
  l: Integer;
  Level: TLvlGraphLevel;
  n: Integer;
  Node: TLvlGraphNode;
  e: Integer;
  Edge: TLvlGraphEdge;
  TargetNode: TLvlGraphNode;
  x1: Integer;
  x2: Integer;
  TotalWeight, Weight: Single;
  Start: Integer;
begin
  for l:=0 to Graph.LevelCount-1 do begin
    Level:=Graph.Levels[l];
    for n:=0 to Level.Count-1 do begin
      Node:=Level.Nodes[n];

      // out edges
      TotalWeight:=Node.OutWeight;
      Weight:=0.0;
      Start:=GetZoomedCenter(Node)-integer(round(TotalWeight*PixelPerWeight) div 2);
      for e:=0 to Node.OutEdgeCount-1 do begin
        Edge:=Node.OutEdges[e];
        Edge.FDrawnAt.Top:=Start+round(Weight*PixelPerWeight);
        Weight+=Edge.Weight;
      end;

      // in edges
      TotalWeight:=Node.InWeight;
      Weight:=0.0;
      Start:=GetZoomedCenter(Node)-integer(round(TotalWeight*PixelPerWeight) div 2);
      for e:=0 to Node.InEdgeCount-1 do begin
        Edge:=Node.InEdges[e];
        Edge.FDrawnAt.Bottom:=Start+round(Weight*PixelPerWeight);
        Weight+=Edge.Weight;
      end;

      // x1, x2
      for e:=0 to Node.OutEdgeCount-1 do begin
        Edge:=Node.OutEdges[e];
        TargetNode:=Edge.Target;
        x1:=ApplyZoom(Level.DrawPosition);
        x2:=ApplyZoom(TargetNode.Level.DrawPosition);
        if TargetNode.Level.Index>Level.Index then begin
          // normal dependency
          // => draw line from right of Node to left of TargetNode
          if Node.Visible then
            x1+=NodeStyle.Width
          else
            x1+=NodeStyle.Width div 2;
          if not TargetNode.Visible then
            x2+=NodeStyle.Width div 2;
        end else begin
          // This code is only reachable if MarkBackEdges was skipped
          // cycle dependency
          // => draw line from left of Node to right of TargetNode
          if not Node.Visible then
            x1+=NodeStyle.Width div 2;
          if TargetNode.Visible then
            x2+=NodeStyle.Width
          else
            x2+=NodeStyle.Width div 2;
        end;
        Edge.FDrawnAt.Left:=x1;
        Edge.FDrawnAt.Right:=x2;
      end;
    end;
  end;
end;

procedure TCustomLvlGraphControl.ColorNodesRandomRGB;
var
  Palette: TLazCtrlPalette;
begin
  Palette:=GetCCPaletteRGB(Graph.NodeCount, true);
  Graph.SetColors(Palette);
  SetLength(Palette, 0);
end;

procedure TCustomLvlGraphControl.DrawNodes;
var
  i: Integer;
  Level: TLvlGraphLevel;
  j: Integer;
  Node: TLvlGraphNode;
  x: Integer;
  y: Integer;
  ImgIndex: Integer;
begin
  Canvas.Brush.Style:=bsSolid;
  for i:=0 to Graph.LevelCount-1 do begin
    Level:=Graph.Levels[i];
    for j:=0 to Level.Count-1 do begin
      Node:=Level.Nodes[j];
      if not Node.Visible then continue;
      //debugln(['TCustomLvlGraphControl.Paint ',Node.Caption,' ',dbgs(FPColorToTColor(Node.Color)),' Level.DrawPosition=',Level.DrawPosition,' Node.DrawPosition=',Node.DrawPosition,' ',Node.DrawPositionEnd]);

      // draw shape
      Canvas.Brush.Color:=FPColorToTColor(Node.Color);
      Canvas.Pen.Color:=Darker(Canvas.Brush.Color);
      x:=ApplyZoom(Level.DrawPosition)-ScrollLeft;
      y:=GetZoomedTop(Node)-ScrollTop;
      case NodeStyle.Shape of
      lgnsRectangle:
        Canvas.Rectangle(x, y, x+NodeStyle.Width, y+Node.DrawSize);
      lgnsEllipse:
        Canvas.Ellipse(x, y, x+NodeStyle.Width, y+Node.DrawSize);
      end;

      // draw image and overlay
      if (Images<>nil) then begin
        x:=ApplyZoom(Level.DrawPosition)+((NodeStyle.Width-Images.Width) div 2)-ScrollLeft;
        y:=GetZoomedCenter(Node)-(Images.Height div 2)-ScrollTop;
        ImgIndex:=Node.ImageIndex;
        if (ImgIndex<0) or (ImgIndex>=Images.Count) then
          ImgIndex:=NodeStyle.DefaultImageIndex;
        if (ImgIndex>=0) and (ImgIndex<Images.Count) then begin
          Images.Draw(Canvas, x, y, ImgIndex, Node.FImageEffect);
          if (Node.OverlayIndex>=0) and (Node.OverlayIndex<Images.Count) then begin
            Images.Overlay(Node.OverlayIndex, 0);
            Images.DrawOverlay(Canvas, x, y, ImgIndex, 0, Node.FImageEffect);
            Images.Overlay(-1, 0);
          end;
        end;
      end;
    end;
  end;
end;

function TCustomLvlGraphControl.GetSelectedNode: TLvlGraphNode;
begin
  Result:=Graph.FirstSelected;
end;

procedure TCustomLvlGraphControl.SetEdgeNearMouse(AValue: TLvlGraphEdge);
begin
  if FEdgeNearMouse=AValue then Exit;
  FEdgeNearMouse:=AValue;
  if (lgoHighlightEdgeNearMouse in Options)
  and ((NodeUnderMouse=nil) or (not (lgoHighlightNodeUnderMouse in Options)))
  then
    HighlightConnectedEgdes(EdgeNearMouse);
end;

procedure TCustomLvlGraphControl.SetImages(AValue: TCustomImageList);
begin
  if FImages=AValue then Exit;
  if Images <> nil then
    Images.UnRegisterChanges(FImageChangeLink);
  FImages:=AValue;
  if Images <> nil then begin
    Images.RegisterChanges(FImageChangeLink);
    Images.FreeNotification(Self);
  end;
  Invalidate;
end;

procedure TCustomLvlGraphControl.SetNodeStyle(AValue: TLvlGraphNodeStyle);
begin
  if FNodeStyle=AValue then Exit;
  FNodeStyle.Assign(AValue);
end;

procedure TCustomLvlGraphControl.SetOptions(AValue: TLvlGraphCtrlOptions);
begin
  if FOptions=AValue then Exit;
  FOptions:=AValue;
  InvalidateAutoLayout;
end;

procedure TCustomLvlGraphControl.SetScrollLeft(AValue: integer);
begin
  AValue:=Max(0,Min(AValue,ScrollLeftMax));
  if FScrollLeft=AValue then Exit;
  FScrollLeft:=AValue;
  UpdateScrollBars;
  Invalidate;
end;

procedure TCustomLvlGraphControl.SetScrollTop(AValue: integer);
begin
  AValue:=Max(0,Min(AValue,ScrollTopMax));
  if FScrollTop=AValue then Exit;
  FScrollTop:=AValue;
  UpdateScrollBars;
  Invalidate;
end;

function TCustomLvlGraphControl.ClientPosFor(AGraphPoint: TPoint): TPoint;
begin
  Result := AGraphPoint;
  Result.X := Result.X - ScrollLeft;
  Result.Y := Result.Y - ScrollTop;
end;

function TCustomLvlGraphControl.ClientPosFor(AGraphRect: TRect): TRect;
begin
  Result.TopLeft     := ClientPosFor(AGraphRect.TopLeft);
  Result.BottomRight := ClientPosFor(AGraphRect.BottomRight);
end;

function TCustomLvlGraphControl.ApplyZoom(c: Integer): Integer;
begin
  Result := round(c*FZoom);
end;

function TCustomLvlGraphControl.ApplyZoom(p: TPoint): TPoint;
begin
  Result.X := round(p.X*FZoom);
  Result.Y := round(p.Y*FZoom);
end;

function TCustomLvlGraphControl.ApplyZoom(r: TRect): TRect;
begin
  Result.TopLeft := ApplyZoom(r.TopLeft);
  Result.BottomRight := ApplyZoom(r.BottomRight);
end;

function TCustomLvlGraphControl.GetZoomedTop(ANode: TLvlGraphNode): Integer;
begin
  Result := ApplyZoom(ANode.DrawCenter)-(ANode.DrawSize div 2);
end;

function TCustomLvlGraphControl.GetZoomedCenter(ANode: TLvlGraphNode): Integer;
begin
  Result := ApplyZoom(ANode.DrawCenter);
end;

function TCustomLvlGraphControl.GetZoomedBottom(ANode: TLvlGraphNode): Integer;
begin
  Result := ApplyZoom(ANode.DrawCenter)-(ANode.DrawSize div 2)+ANode.DrawSize;
end;

procedure TCustomLvlGraphControl.SetSelectedNode(AValue: TLvlGraphNode);
begin
  if AValue=nil then
    Graph.ClearSelection
  else
    Graph.SingleSelect(AValue);
end;

procedure TCustomLvlGraphControl.UpdateScrollBars;
var
  ScrollInfo: TScrollInfo;
  DrawSize: TPoint;
begin
  if HandleAllocated and (not (lgcUpdatingScrollBars in FFlags)) then begin
    Include(FFlags,lgcUpdatingScrollBars);
    DrawSize:=GetDrawSize;
    FScrollTopMax:=DrawSize.Y-ClientHeight+2*BorderWidth;
    FScrollTop:=Max(0,Min(FScrollTop,ScrollTopMax));
    FScrollLeftMax:=DrawSize.X-ClientWidth+2*BorderWidth;
    FScrollLeft:=Max(0,Min(FScrollLeft,ScrollLeftMax));
    //debugln(['TCustomLvlGraphControl.UpdateScrollBars ',dbgs(DrawSize),' ClientRect=',dbgs(ClientRect),' ScrollLeft=',ScrollLeft,'/',ScrollLeftMax,' ScrollTop=',ScrollTop,'/',ScrollTopMax,' ']);

    // vertical scrollbar
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;
    ScrollInfo.nMin := 0;
    ScrollInfo.nTrackPos := 0;
    ScrollInfo.nMax := DrawSize.Y;
    ScrollInfo.nPage := Max(1,ClientHeight-1);
    ScrollInfo.nPos := ScrollTop;
    ShowScrollBar(Handle, SB_VERT, True);
    SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);

    // horizontal scrollbar
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;
    ScrollInfo.nMin := 0;
    ScrollInfo.nTrackPos := 0;
    ScrollInfo.nMax := DrawSize.X;
    ScrollInfo.nPage := Max(1,ClientWidth-1);
    ScrollInfo.nPos := ScrollLeft;
    ShowScrollBar(Handle, SB_Horz, True);
    SetScrollInfo(Handle, SB_Horz, ScrollInfo, True);

    Exclude(FFlags,lgcUpdatingScrollBars);
  end;
end;

procedure TCustomLvlGraphControl.WMHScroll(var Msg: TLMScroll);
begin
  case Msg.ScrollCode of
    SB_TOP:        ScrollLeft := 0;
    SB_BOTTOM:     ScrollLeft := ScrollLeftMax;
    SB_LINEDOWN:   ScrollLeft := ScrollLeft + NodeStyle.Width div 2;
    SB_LINEUP:     ScrollLeft := ScrollLeft - NodeStyle.Width div 2;
    SB_PAGEDOWN:   ScrollLeft := ScrollLeft + ClientWidth - NodeStyle.Width;
    SB_PAGEUP:     ScrollLeft := ScrollLeft - ClientWidth + NodeStyle.Width;
    SB_THUMBPOSITION,
    SB_THUMBTRACK: ScrollLeft := Msg.Pos;
    SB_ENDSCROLL:  SetCaptureControl(nil); // release scrollbar capture
  end;
end;

procedure TCustomLvlGraphControl.WMVScroll(var Msg: TLMScroll);
begin
  case Msg.ScrollCode of
    SB_TOP:        ScrollTop := 0;
    SB_BOTTOM:     ScrollTop := ScrollTopMax;
    SB_LINEDOWN:   ScrollTop := ScrollTop + NodeStyle.Width div 2;
    SB_LINEUP:     ScrollTop := ScrollTop - NodeStyle.Width div 2;
    SB_PAGEDOWN:   ScrollTop := ScrollTop + ClientHeight - NodeStyle.Width;
    SB_PAGEUP:     ScrollTop := ScrollTop - ClientHeight + NodeStyle.Width;
    SB_THUMBPOSITION,
    SB_THUMBTRACK: ScrollTop := Msg.Pos;
    SB_ENDSCROLL:  SetCaptureControl(nil); // release scrollbar capture
  end;
end;

procedure TCustomLvlGraphControl.WMMouseWheel(var Message: TLMMouseEvent);
begin
  if (Message.State * [ssShift, ssAlt, ssAltGr, ssCtrl] = [ssCtrl]) then
  begin
    FZoom := FZoom + Message.WheelDelta / (120 * 20);
    if FZoom < 0.3 then FZoom := 0.3;
    if FZoom > 25 then FZoom := 25;
    ComputeEdgeCoords;
    UpdateScrollBars;
    Invalidate;
  end
  else
  if Mouse.WheelScrollLines=-1 then
  begin
    // -1 : scroll by page
    ScrollTop := ScrollTop -
              (Message.WheelDelta * (ClientHeight - NodeStyle.Width)) div 120;
  end else begin
    // scrolling one line -> scroll half an item, see SB_LINEDOWN and SB_LINEUP
    // handler in WMVScroll
    ScrollTop := ScrollTop -
        (Message.WheelDelta * Mouse.WheelScrollLines*NodeStyle.Width) div 240;
  end;
  Message.Result := 1;
end;

procedure TCustomLvlGraphControl.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbMiddle) and (Shift * [ssShift, ssAlt, ssAltGr, ssCtrl] = [ssCtrl])
  then begin
    FZoom := 1;
    ComputeEdgeCoords;
    UpdateScrollBars;
    Invalidate;
    exit;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCustomLvlGraphControl.DoAutoLayoutLevels(TxtHeight: integer);
// compute all Levels.DrawPosition
var
  j: Integer;
  p: Integer;
  i: Integer;
  LevelTxtWidths: array of integer;
  Level: TLvlGraphLevel;
begin
  Canvas.Font.Height:=round(single(TxtHeight)*NodeStyle.CaptionScale+0.5);
  if Graph.LevelCount=0 then exit;
  SetLength(LevelTxtWidths,Graph.LevelCount);
  for i:=0 to Graph.LevelCount-1 do begin
    // compute needed width of the level
    Level:=Graph.Levels[i];
    LevelTxtWidths[i]:=Max(NodeStyle.Width,Canvas.TextWidth('NodeX'+StringOfChar('j',Min(20,Level.Count))));
    for j:=0 to Level.Count-1 do
      if Level[j].Visible then
        LevelTxtWidths[i]:=Max(LevelTxtWidths[i], Canvas.TextWidth(Level[j].Caption));
    p:=0; // Prevent compiler warning.
    if i=0 then begin
      // first level
      case NodeStyle.CaptionPosition of
      lgncLeft: p:=NodeStyle.GapRight+LevelTxtWidths[0]+NodeStyle.GapLeft;
      lgncRight: p:=NodeStyle.GapLeft;
      lgncTop,lgncBottom: p:=NodeStyle.GapLeft+((LevelTxtWidths[0]-NodeStyle.Width) div 2);
      end;
    end else begin
      // following level
      p:=Graph.Levels[i-1].DrawPosition;
      case NodeStyle.CaptionPosition of
      lgncLeft: p+=NodeStyle.Width+NodeStyle.GapRight+LevelTxtWidths[i]+NodeStyle.GapLeft;
      lgncRight: p+=NodeStyle.Width+NodeStyle.GapRight+LevelTxtWidths[i-1]+NodeStyle.GapLeft;
      lgncTop,lgncBottom:
        p+=((LevelTxtWidths[i-1]+LevelTxtWidths[i]) div 2)+NodeStyle.GapRight+NodeStyle.GapLeft;
      end;
    end;
    Graph.Levels[i].DrawPosition:=p;
  end;
  SetLength(LevelTxtWidths,0);
end;

procedure TCustomLvlGraphControl.DoSetBounds(ALeft, ATop, AWidth,
  AHeight: integer);
begin
  inherited DoSetBounds(ALeft, ATop, AWidth, AHeight);
  UpdateScrollBars;
end;

procedure TCustomLvlGraphControl.DoStartAutoLayout;
begin
  if Assigned(OnStartAutoLayout) then
    OnStartAutoLayout(Self);
end;

procedure TCustomLvlGraphControl.DoEndAutoLayout;
begin
  if Assigned(OnEndAutoLayout) then
    OnEndAutoLayout(Self);
end;

procedure TCustomLvlGraphControl.DoDrawEdge(Edge: TLvlGraphEdge);
var
  r: TRect;
  s, Ascend, FarAscend: integer;
  Source, Target, FarSource, FarTarget: TLvlGraphNode;
  SourceStraighenFactor, TargetStraighenFactor: Single;
begin
  SourceStraighenFactor := 0;
  TargetStraighenFactor := 0;
  if EdgeStyle.Shape = lgesCurved then begin
    Source := Edge.Source;
    Target := Edge.Target;
    Ascend := (Source.DrawCenter - Target.DrawCenter) * 1024
              div (Target.Level.DrawPosition - Source.Level.DrawPosition);
    if (not Source.Visible) and (Source.OutEdgeCount = 1) and (Source.InEdgeCount = 1) then begin
      FarSource := Source.InEdges[0].Source;
      FarAscend := (FarSource.DrawCenter - Source.DrawCenter) * 1024
              div (Source.Level.DrawPosition - FarSource.Level.DrawPosition);
      if ((Ascend < 0) and (FarAscend < 0)) then
        SourceStraighenFactor := Max(Ascend, FarAscend) / 1024
      else
      if ((Ascend > 0) and (FarAscend > 0)) then
        SourceStraighenFactor := Min(Ascend, FarAscend) / 1024;
    end;
    if (not Target.Visible) and (Target.OutEdgeCount = 1) and (Target.InEdgeCount = 1) then begin
      FarTarget := Target.OutEdges[0].Target;
      FarAscend := (Target.DrawCenter - FarTarget.DrawCenter) * 1024
              div (FarTarget.Level.DrawPosition - Target.Level.DrawPosition);
      if ((Ascend < 0) and (FarAscend < 0)) then
        TargetStraighenFactor := Max(Ascend, FarAscend) / 1024
      else
      if ((Ascend > 0) and (FarAscend > 0)) then
        TargetStraighenFactor := Min(Ascend, FarAscend) / 1024;
    end;
  end;

  r:=ClientPosFor(Edge.DrawnAt);
  if Edge.FNoGapCircle then begin
    if EdgeStyle.Shape = lgesCurved then begin
      if Edge.BackEdge then begin
        SourceStraighenFactor := -0.4;
        TargetStraighenFactor :=  0.4;
      end else begin
        SourceStraighenFactor :=  0.4;
        TargetStraighenFactor := -0.4;
      end;
    end else begin
      if Edge.BackEdge then begin
        inc(r.Top, 2);
        inc(r.Bottom, 2);
      end else begin
        dec(r.Top);
        dec(r.Bottom);
      end;
    end;
  end;
  s:=round(Edge.Weight*PixelPerWeight);
  if s>1 then begin
    case EdgeStyle.Shape of
    lgesStraight: Canvas.Line(r);
    lgesCurved:
      begin
        DrawCurvedLvlLeftToRightEdge(Canvas,r.Left,r.Top,r.Right,r.Bottom, SourceStraighenFactor, TargetStraighenFactor);
        DrawCurvedLvlLeftToRightEdge(Canvas,r.Left,r.Top+s,r.Right,r.Bottom+s, SourceStraighenFactor, TargetStraighenFactor);
      end;
    end;
  end else begin
    case EdgeStyle.Shape of
    lgesStraight: Canvas.Line(r);
    lgesCurved: DrawCurvedLvlLeftToRightEdge(Canvas,r.Left,r.Top,r.Right,r.Bottom, SourceStraighenFactor, TargetStraighenFactor);
    end;
  end;
end;

procedure TCustomLvlGraphControl.DoMinimizeCrossings;
begin
  if OnMinimizeCrossings<>nil then
    OnMinimizeCrossings(Self)
  else
    Graph.MinimizeCrossings;
end;

procedure TCustomLvlGraphControl.DoMinimizeOverlappings(MinPos: integer;
  NodeGapInFront: integer; NodeGapBehind: integer);
var
  Handled: Boolean;
begin
  Handled := False;
  if Assigned(OnMinimizeOverlappings) then
    OnMinimizeOverlappings(MinPos,NodeGapInFront,NodeGapBehind,Handled);
  if not Handled then
    Graph.MinimizeOverlappings(MinPos,NodeGapInFront,NodeGapBehind);
end;

procedure TCustomLvlGraphControl.Paint;
var
  w: Integer;
  TxtH: integer;
begin
  inherited Paint;

  Canvas.Font.Assign(Font);
  Canvas.Font.PixelsPerInch := Font.PixelsPerInch;

  Include(FFlags,lgcFocusedPainting);

  if (lgoAutoLayout in FOptions)
  and (lgcNeedAutoLayout in FFlags) then begin
    Include(FFlags,lgcIgnoreGraphInvalidate);
    try
      AutoLayout;
    finally
      Exclude(FFlags,lgcIgnoreGraphInvalidate);
    end;
  end;

  // background
  if Draw(lgdsBackground) then begin
    Canvas.Brush.Style:=bsSolid;
    Canvas.Brush.Color:=Color; //clWhite;
    Canvas.FillRect(ClientRect);
  end;

  TxtH:=Canvas.TextHeight('ABCTM');

  // header
  if Draw(lgdsHeader) and (Caption<>'') then begin
    w:=Canvas.TextWidth(Caption);
    Canvas.TextOut((ClientWidth-w) div 2-ScrollLeft,round(0.25*TxtH)-ScrollTop,Caption);
  end;

  // draw edges, node captions, nodes
  if Draw(lgdsNormalEdges) then
    DrawEdges(false);
  if Draw(lgdsNodeCaptions) then
    DrawCaptions(TxtH);
  if Draw(lgdsHighlightedEdges) then
    DrawEdges(true);
  if Draw(lgdsNodes) then
    DrawNodes;

  // finish
  Draw(lgdsFinish);
end;

function TCustomLvlGraphControl.Draw(Step: TLvlGraphDrawStep): boolean;
var
  Skip: Boolean;
begin
  if not Assigned(OnDrawStep) then exit(true);
  Skip:=false;
  OnDrawStep(Step,Skip);
  Result:=not Skip;
end;

procedure TCustomLvlGraphControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Distance: integer;
  Edge: TLvlGraphEdge;
begin
  inherited MouseMove(Shift, X, Y);
  NodeUnderMouse:=GetNodeAt(X,Y);
  Edge:=GetEdgeAt(X,Y,Distance);
  if Distance<=EdgeStyle.MouseDistMax then
    EdgeNearMouse:=Edge
  else
    EdgeNearMouse:=nil;
end;

procedure TCustomLvlGraphControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: TLvlGraphNode;
begin
  BeginUpdate;
  try
    inherited MouseDown(Button, Shift, X, Y);
    Node:=GetNodeAt(X,Y);
    if Node<>nil then begin
      if Button=mbLeft then begin
        if lgoMouseSelects in Options then begin
          if ssCtrl in Shift then begin
            // toggle selection
            Node.Selected:=not Node.Selected;
          end else begin
            // single selection
            Graph.ClearSelection;
            Node.Selected:=true;
          end;
        end;
      end;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TCustomLvlGraphControl.CreateWnd;
begin
  inherited CreateWnd;
  UpdateScrollBars;
end;

procedure TCustomLvlGraphControl.HighlightConnectedEgdes(Element: TObject);
var
  n: Integer;
  CurNode: TLvlGraphNode;
  e: Integer;
  HighlightedElements: TAvlTree;
  Edge: TLvlGraphEdge;
begin
  BeginUpdate;
  HighlightedElements:=TAvlTree.Create;
  try
    if Element is TLvlGraphNode then
      LvlGraphHighlightNode(TLvlGraphNode(Element),HighlightedElements,true,true)
    else if Element is TLvlGraphEdge then begin
      Edge:=TLvlGraphEdge(Element);
      HighlightedElements.Add(Edge);
      if not Edge.Source.Visible then
        LvlGraphHighlightNode(Edge.Source,HighlightedElements,true,false);
      if not Edge.Target.Visible then
        LvlGraphHighlightNode(Edge.Target,HighlightedElements,false,true);
    end;
    for n:=0 to Graph.NodeCount-1 do begin
      CurNode:=Graph.Nodes[n];
      for e:=0 to CurNode.OutEdgeCount-1 do begin
        Edge:=CurNode.OutEdges[e];
        Edge.Highlighted:=HighlightedElements.Find(Edge)<>nil;
      end;
    end;
  finally
    HighlightedElements.Free;
  end;
  EndUpdate;
end;

procedure TCustomLvlGraphControl.DoOnShowHint(HintInfo: PHintInfo);
var
  s: String;
begin
  if NodeUnderMouse<>nil then begin
    s:=NodeArrayAsString(NodeUnderMouse.GetVisibleSourceNodes);
    s+=#13'->'#13;
    s+=NodeUnderMouse.Caption;
    s+=#13'->'#13;
    s+=NodeArrayAsString(NodeUnderMouse.GetVisibleTargetNodes);
    HintInfo^.HintStr:=s;
  end else if EdgeNearMouse<>nil then begin
    s:=NodeArrayAsString(EdgeNearMouse.GetVisibleSourceNodes);
    s+=#13'->'#13;
    s+=NodeArrayAsString(EdgeNearMouse.GetVisibleTargetNodes);
    HintInfo^.HintStr:=s;
  end;

  inherited DoOnShowHint(HintInfo);
end;

constructor TCustomLvlGraphControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FZoom := 1;
  ControlStyle:=ControlStyle+[csAcceptsControls];
  Color := clWhite;
  FOptions:=DefaultLvlGraphCtrlOptions;
  FGraph:=TLvlGraph.Create;
  FGraph.OnInvalidate:=@GraphInvalidate;
  FGraph.OnSelectionChanged:=@GraphSelectionChanged;
  FGraph.OnStructureChanged:=@GraphStructureChanged;
  FNodeStyle:=TLvlGraphNodeStyle.Create(Self);
  FEdgeStyle:=TLvlGraphEdgeStyle.Create(Self);
  FLimits:=TLvlGraphLimits.Create(Self);
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange:=@ImageListChange;
  ShowHint:=true;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, CX, CY);
end;

destructor TCustomLvlGraphControl.Destroy;
begin
  inc(fUpdateLock);
  FreeAndNil(FImageChangeLink);
  FGraph.OnInvalidate:=nil;
  FGraph.OnSelectionChanged:=nil;
  FGraph.OnStructureChanged:=nil;
  FGraph.Free;
  FGraph:=nil;
  FreeAndNil(FLimits);
  FreeAndNil(FEdgeStyle);
  FreeAndNil(FNodeStyle);
  inherited Destroy;
end;

procedure TCustomLvlGraphControl.EraseBackground(DC: HDC);
begin
  // Paint paints all, no need to erase background
end;

procedure TCustomLvlGraphControl.Clear;
begin
  BeginUpdate;
  try
    Graph.Clear;
  finally
    EndUpdate;
  end;
end;

procedure TCustomLvlGraphControl.AutoLayout;
{ Min/MaxPixelPerWeight: used to scale Node.DrawSize depending on weight of
                         incoming and outgoing edges
  NodeGap: space between nodes
}
var
  HeaderHeight: integer;
  TxtH: LongInt;
  GapInFront: Integer;
  GapBehind: Integer;
begin
  //debugln(['TCustomLvlGraphControl.AutoLayout ',DbgSName(Self),' ClientRect=',dbgs(ClientRect)]);
  BeginUpdate;
  try
    Canvas.Font.Assign(Font);

    DoStartAutoLayout;

    if HandleAllocated then
      TxtH:=Canvas.TextHeight('M')
    else
      TxtH:=Max(10,abs(Font.Height));
    if Caption<>'' then begin
      HeaderHeight:=round(1.5*TxtH);
    end else
      HeaderHeight:=0;

    Graph.FindIndependentGraphs;

    // distribute the nodes on levels and mark back edges
    Graph.CreateTopologicalLevels(lgoHighLevels in Options, lgoReduceBackEdges in Options);

    Graph.MarkBackEdges;

    if lgoMinimizeEdgeLens in Options then
      Graph.MinimizeEdgeLens(lgoHighLevels in Options);

    if (Limits.MaxLevelHeightAbs > 0) or (Limits.MaxLevelHeightRel > 0) then
      Graph.LimitLevelHeights(Limits.MaxLevelHeightAbs, Limits.MaxLevelHeightRel);

    Graph.SplitLongEdges(EdgeStyle.SplitMode);

    // permutate nodes within levels to avoid crossings
    DoMinimizeCrossings;

    // Level DrawPosition
    DoAutoLayoutLevels(TxtH);

    GapInFront:=NodeStyle.GapTop;
    GapBehind:=NodeStyle.GapBottom;
    case NodeStyle.CaptionPosition of
    lgncTop: GapInFront+=TxtH;
    lgncBottom: GapBehind+=TxtH;
    end;

    // scale Nodes.DrawSize
    // Preferably the smallest node should be the size of the text
    // Preferably the largest level should fit without needing a scrollbar
    Graph.ScaleNodeDrawSizes(GapInFront,GapBehind,Screen.Height*2,1,
      ClientHeight-HeaderHeight,round(single(TxtH)*NodeStyle.CaptionScale+0.5),
      FPixelPerWeight);

    // position nodes without overlapping
    DoMinimizeOverlappings(HeaderHeight,GapInFront,GapBehind);

    if lgoStraightenGraph in Options then
      Graph.StraightenGraph;

    // node colors
    if NodeStyle.Coloring=lgncRGB then
      ColorNodesRandomRGB;

    UpdateScrollBars;

    DoEndAutoLayout;

    ComputeEdgeCoords;
    Exclude(FFlags,lgcNeedAutoLayout);
  finally
    EndUpdate;
  end;
end;

procedure TCustomLvlGraphControl.Invalidate;
begin
  if lgcIgnoreGraphInvalidate in FFlags then
    exit;
  if fUpdateLock>0 then begin
    Include(FFlags,lgcNeedInvalidate);
    exit;
  end;
  Exclude(FFlags,lgcNeedInvalidate);
  inherited Invalidate;
end;

procedure TCustomLvlGraphControl.InvalidateAutoLayout;
begin
  if lgoAutoLayout in Options then
    Include(FFlags,lgcNeedAutoLayout);
  Invalidate;
end;

procedure TCustomLvlGraphControl.BeginUpdate;
begin
  inc(fUpdateLock);
end;

procedure TCustomLvlGraphControl.EndUpdate;
begin
  if fUpdateLock=0 then
    raise Exception.Create('');
  dec(fUpdateLock);
  if fUpdateLock=0 then begin
    if [lgcNeedAutoLayout,lgcNeedInvalidate]*FFlags<>[] then
      Invalidate;
  end;
end;

function TCustomLvlGraphControl.GetNodeAt(X, Y: integer): TLvlGraphNode;
var
  l: Integer;
  Level: TLvlGraphLevel;
  n: Integer;
  Node: TLvlGraphNode;
begin
  Result:=nil;
  X+=ScrollLeft;
  Y+=ScrollTop;
  // check in reverse painting order
  for l:=Graph.LevelCount-1 downto 0 do begin
    Level:=Graph.Levels[l];
    if (X<ApplyZoom(Level.DrawPosition)) or (X>=ApplyZoom(Level.DrawPosition)+NodeStyle.Width) then continue;
    for n:=Level.Count-1 downto 0 do begin
      Node:=Level.Nodes[n];
      if not Node.Visible then continue;
      if (Y<GetZoomedTop(Node)) or (Y>=GetZoomedBottom(Node)) then continue;
      exit(Node);
    end;
  end;
end;

function TCustomLvlGraphControl.GetEdgeAt(X, Y: integer; out Distance: integer
  ): TLvlGraphEdge;
var
  l: Integer;
  Level: TLvlGraphLevel;
  n: Integer;
  Node: TLvlGraphNode;
  e: Integer;
  Edge: TLvlGraphEdge;
  CurDist: Integer;
  r: TRect;
begin
  Result:=nil;
  X+=ScrollLeft;
  Y+=ScrollTop;
  Distance:=High(Integer);
  // check in reverse painting order
  for l:=Graph.LevelCount-1 downto 0 do begin
    Level:=Graph.Levels[l];
    for n:=Level.Count-1 downto 0 do begin
      Node:=Level.Nodes[n];
      for e:=Node.OutEdgeCount-1 downto 0 do begin
        Edge:=Node.OutEdges[e];
        r:=Edge.DrawnAt;
        CurDist:=GetDistancePointLine(X,Y,
                  r.Left,r.Top,r.Right,r.Bottom);
        if CurDist<Distance then begin
          Result:=Edge;
          Distance:=CurDist;
        end;
      end;
    end;
  end;
end;

class function TCustomLvlGraphControl.GetControlClassDefaultSize: TSize;
begin
  Result.cx:=200;
  Result.cy:=200;
end;

function TCustomLvlGraphControl.GetDrawSize: TPoint;
var
  l: Integer;
  Level: TLvlGraphLevel;
  n: Integer;
  Node: TLvlGraphNode;
  x: LongInt;
  CaptionRect: TRect;
begin
  Result:=Point(0,0);
  for l:=0 to Graph.LevelCount-1 do begin
    Level:=Graph.Levels[l];
    for n:=0 to Level.Count-1 do begin
      Node:=Level[n];
      CaptionRect:=Node.DrawnCaptionRect;

      Result.Y:=Max(Result.Y,GetZoomedBottom(Node)+NodeStyle.GapBottom);
      Result.Y:=Max(Result.Y,CaptionRect.Bottom);

      x:=NodeStyle.GapRight;
      if Node.OutEdgeCount>0 then
        x:=Max(x,NodeStyle.Width);
      x+=Level.DrawPosition+NodeStyle.Width;
      Result.X:=Max(Result.X,ApplyZoom(x));
      Result.X:=Max(Result.X,CaptionRect.Right);
    end;
  end;
end;

type

  { TGraphLevelerNode - used by TLvlGraph.UpdateLevels }

  TGraphLevelerNode = class
  public
    Node: TLvlGraphNode;
    Level: integer;
    Visited: boolean;
    InPath: boolean; // = node on stack
  end;

function CompareGraphLevelerNodes(Node1, Node2: Pointer): integer;
var
  LNode1: TGraphLevelerNode absolute Node1;
  LNode2: TGraphLevelerNode absolute Node2;
begin
  Result:=ComparePointer(LNode1.Node,LNode2.Node);
end;

function CompareLGNodeWithLevelerNode(GNode, LNode: Pointer): integer;
var
  LevelerNode: TGraphLevelerNode absolute LNode;
begin
  Result:=ComparePointer(GNode,LevelerNode.Node);
end;

{ TLvlGraph }

function TLvlGraph.GetNodes(Index: integer): TLvlGraphNode;
begin
  Result:=TLvlGraphNode(FNodes[Index]);
end;

function TLvlGraph.GetSubGraphCount: integer;
begin
  Result:=fSubGraphs.Count;
  if Result=0 then begin
    Result:=1;
    TLvlGraphSubGraph.Create(Self,0);
  end;
end;

function TLvlGraph.GetSubGraphs(Index: integer): TLvlGraphSubGraph;
begin
  if fSubGraphs.Count = 0 then
    GetSubGraphCount;
  Result:=TLvlGraphSubGraph(fSubGraphs[Index]);
  if fSubGraphs.Count=1 then begin
    Result.FLowestLevel:=0;
    Result.FHighestLevel:=LevelCount-1;
  end;
end;

procedure TLvlGraph.SetLevelCount(AValue: integer);
begin
  if AValue<1 then
    raise Exception.Create('at least one level');
  if LevelCount=AValue then Exit;
  while LevelCount<AValue do
    FLevelClass.Create(Self,LevelCount);
  while LevelCount>AValue do
    Levels[LevelCount-1].Free;
end;

procedure TLvlGraph.InternalRemoveNode(Node: TLvlGraphNode);
begin
  FNodes.Remove(Node);
  Node.FGraph:=nil;
  StructureChanged(Node,opRemove);
end;

function TLvlGraph.GetLevels(Index: integer): TLvlGraphLevel;
begin
  Result:=TLvlGraphLevel(fLevels[Index]);
end;

function TLvlGraph.GetLevelCount: integer;
begin
  Result:=fLevels.Count;
end;

constructor TLvlGraph.Create;
begin
  FNodeClass:=TLvlGraphNode;
  FEdgeClass:=TLvlGraphEdge;
  FLevelClass:=TLvlGraphLevel;
  FNodes:=TFPList.Create;
  fLevels:=TFPList.Create;
  fSubGraphs := TFPList.Create;
end;

destructor TLvlGraph.Destroy;
begin
  Clear;
  FreeAndNil(fSubGraphs);
  FreeAndNil(fLevels);
  FreeAndNil(FNodes);
  inherited Destroy;
end;

procedure TLvlGraph.Clear;
var
  i: Integer;
begin
  while NodeCount>0 do
    Nodes[NodeCount-1].Free;
  for i:=LevelCount-1 downto 0 do
    Levels[i].Free;
  for i:=fSubGraphs.Count-1 downto 0 do
    TLvlGraphSubGraph(fSubGraphs[i]).Free;
end;

procedure TLvlGraph.Invalidate;
begin
  if OnInvalidate<>nil then
    OnInvalidate(Self);
end;

procedure TLvlGraph.StructureChanged(Element: TObject; Operation: TOperation);
begin
  if Assigned(OnStructureChanged) then
    OnStructureChanged(Self,Element,Operation);
end;

function TLvlGraph.NodeCount: integer;
begin
  Result:=FNodes.Count;
end;

function TLvlGraph.GetNode(aCaption: string; CreateIfNotExists: boolean
  ): TLvlGraphNode;
var
  i: Integer;
begin
  i:=NodeCount-1;
  if FCaseSensitive then
    while (i>=0) and (aCaption<>Nodes[i].Caption) do dec(i)
  else
    while (i>=0) and not SameText(aCaption, Nodes[i].Caption) do dec(i);

  if i>=0 then begin
    Result:=Nodes[i];
  end else if CreateIfNotExists then begin
    if LevelCount=0 then
      LevelCount:=1;
    Result:=FNodeClass.Create(Self,aCaption,Levels[0]);
    FNodes.Add(Result);
    StructureChanged(Result,opInsert);
  end else
    Result:=nil;
end;

function TLvlGraph.CreateHiddenNode(Level: integer): TLvlGraphNode;
begin
  Result:=FNodeClass.Create(Self,'',Levels[Level]);
  Result.Visible:=false;
  FNodes.Add(Result);
  StructureChanged(Result,opInsert);
end;

procedure TLvlGraph.ClearSelection;
begin
  while FirstSelected<>nil do
    FirstSelected.Selected:=false;
end;

procedure TLvlGraph.SingleSelect(Node: TLvlGraphNode);
begin
  if (Node=FirstSelected) and (Node.NextSelected=nil) then exit;
  Node.Selected:=true;
  while FirstSelected<>Node do
    FirstSelected.Selected:=false;
  while LastSelected<>Node do
    LastSelected.Selected:=false;
end;

function TLvlGraph.IsMultiSelection: boolean;
begin
  Result:=(FirstSelected<>nil) and (FirstSelected.NextSelected<>nil);
end;

function TLvlGraph.GetEdge(SourceCaption, TargetCaption: string;
  CreateIfNotExists: boolean): TLvlGraphEdge;
var
  Source: TLvlGraphNode;
  Target: TLvlGraphNode;
begin
  Source:=GetNode(SourceCaption,CreateIfNotExists);
  if Source=nil then exit(nil);
  Target:=GetNode(TargetCaption,CreateIfNotExists);
  if Target=nil then exit(nil);
  Result:=GetEdge(Source,Target,CreateIfNotExists);
end;

function TLvlGraph.GetEdge(Source, Target: TLvlGraphNode;
  CreateIfNotExists: boolean): TLvlGraphEdge;
begin
  Result:=Source.FindOutEdge(Target);
  if Result<>nil then exit;
  if CreateIfNotExists then begin
    Result:=FEdgeClass.Create(Source,Target);
    StructureChanged(Result,opInsert);
  end;
end;

procedure TLvlGraph.FindIndependentGraphs;
  procedure ApplySubGraphRecursively(Node: TLvlGraphNode; SubGraph: integer);
  var
    i: Integer;
  begin
    assert((node.SubGraph < 0) or (Node.SubGraph = SubGraph), 'ApplySubGraphRecursively: node already in other subgraph');
    if Node.SubGraph >= 0 then
      exit;
    node.SubGraph := SubGraph;
    for i := 0 to node.InEdgeCount - 1 do
      ApplySubGraphRecursively(Node.InEdges[i].Source, SubGraph);
    for i := 0 to node.OutEdgeCount - 1 do
      ApplySubGraphRecursively(Node.OutEdges[i].Target, SubGraph);
  end;
var
  i: Integer;
  Node: TLvlGraphNode;
  CurrentSubGraph: TLvlGraphSubGraph;
begin
  CurrentSubGraph := SubGraphs[0];
  for i:=0 to NodeCount-1 do
    Nodes[i].FSubGraph := -1;
  for i:=0 to NodeCount-1 do begin
    Node := Nodes[i];
    if Node.SubGraph >= 0 then Continue;
    if CurrentSubGraph = nil then
      CurrentSubGraph:=TLvlGraphSubGraph.Create(Self, SubGraphCount);
    ApplySubGraphRecursively(Node, CurrentSubGraph.Index);
    CurrentSubGraph := nil;
  end;
end;

procedure TLvlGraph.InternalRemoveLevel(Lvl: TLvlGraphLevel);
var
  i: Integer;
begin
  if Levels[Lvl.Index]<>Lvl then
    raise Exception.Create('inconsistency');
  fLevels.Delete(Lvl.Index);
  // update level Index
  for i:=Lvl.Index to LevelCount-1 do
    Levels[i].FIndex:=i;
  StructureChanged(Lvl,opRemove);
end;

procedure TLvlGraph.SelectionChanged;
begin
  Invalidate;
  if OnSelectionChanged<>nil then
    OnSelectionChanged(Self);
end;

function TLvlGraph.NewLevelAtIndex(AnIndex, ASubGraphIndex: integer
  ): TLvlGraphLevel;
var
  i: Integer;
begin
  Result := FLevelClass.Create(Self,AnIndex);
  SubGraphs[ASubGraphIndex].FHighestLevel := SubGraphs[ASubGraphIndex].HighestLevel + 1;
  for i := ASubGraphIndex+1 to SubGraphCount - 1 do begin
    SubGraphs[i].FLowestLevel := SubGraphs[i].LowestLevel + 1;
    SubGraphs[i].FHighestLevel := SubGraphs[i].HighestLevel + 1;
  end
end;

procedure TLvlGraph.CreateTopologicalLevels(HighLevels, ReduceBackEdges: boolean);
var
  ExtNodes: TAvlTree; // tree of TGraphLevelerNode sorted by Node
  MaxLevel: Integer;

  function GetExtNode(Node: TLvlGraphNode): TGraphLevelerNode;
  begin
    Result:=TGraphLevelerNode(ExtNodes.FindKey(Pointer(Node),@CompareLGNodeWithLevelerNode).Data);
  end;

  procedure Traverse(ExtNode: TGraphLevelerNode; MinLevel: Integer);
  var
    Node: TLvlGraphNode;
    e: Integer;
    Edge: TLvlGraphEdge;
    ExtNextNode: TGraphLevelerNode;
    Cnt: Integer;
  begin
    if ExtNode.Visited then exit;
    ExtNode.InPath:=true;
    ExtNode.Visited:=true;
    if ExtNode.Level < MinLevel then
      ExtNode.Level := MinLevel;
    Node:=ExtNode.Node;
    if HighLevels then
      Cnt:=Node.OutEdgeCount
    else
      Cnt:=Node.InEdgeCount;
    for e:=0 to Cnt-1 do begin
      if HighLevels then begin
        Edge:=Node.OutEdges[e];
        ExtNextNode:=GetExtNode(Edge.Target);
      end else begin
        Edge:=Node.InEdges[e];
        ExtNextNode:=GetExtNode(Edge.Source);
      end;
      if not ExtNextNode.InPath then begin
        Traverse(ExtNextNode, MinLevel);
        ExtNode.Level:=Max(ExtNode.Level,ExtNextNode.Level+1);
      end;
      // else node is part of a cycle
    end;
    MaxLevel:=Max(MaxLevel,ExtNode.Level);
    // backtrack
    ExtNode.InPath:=false;
  end;

  procedure DoReduceBackEdges(var MaxLevel: integer; StartLevel, SubGraphIdx: integer);
  var
    MaybeReduceMaxLevel: Boolean;

    function IncomingBackEdgeCount(ExtReceivingNode: TGraphLevelerNode;
      PretendLevel: Integer; out HasSiblingOnPretendLevel: Boolean;
      out NextLowelSiblingAtLevel: integer): integer;
    var
      Node: TLvlGraphNode;
      i, c: Integer;
      ExtFromNode: TGraphLevelerNode;
    begin
      Result := 0;
      HasSiblingOnPretendLevel := False;
      NextLowelSiblingAtLevel := StartLevel-1;
      Node := ExtReceivingNode.Node;
      if HighLevels then
        c := Node.OutEdgeCount
      else
        c := Node.InEdgeCount;
      for i := 0 to c - 1 do begin
        if HighLevels then
          ExtFromNode := GetExtNode(Node.OutEdges[i].Target)
        else
          ExtFromNode := GetExtNode(Node.InEdges[i].Source);
        if ExtFromNode.Level >= PretendLevel then // include equal => they will need to be pushed up, if the node is inserted at this level
          inc(Result);
        if ExtFromNode.Level = PretendLevel then
          HasSiblingOnPretendLevel := True
        else
        if (ExtFromNode.Level > NextLowelSiblingAtLevel) and (ExtFromNode.Level < PretendLevel) then
          NextLowelSiblingAtLevel := ExtFromNode.Level;
      end;
    end;
    procedure AdjustSiblingLevels(ExtAdjustNode: TGraphLevelerNode; NewLevel: integer; Force: Boolean = False);
    var
      i, c, OldLevel: Integer;
      ExtSiblingNode: TGraphLevelerNode;
      Node: TLvlGraphNode;
    begin
      if ExtAdjustNode.InPath then
        exit;
      ExtAdjustNode.InPath := True;

      if (ExtAdjustNode.Level > NewLevel) and not force then begin
        Node := ExtAdjustNode.Node;
        if HighLevels then
          c := Node.OutEdgeCount
        else
          c := Node.InEdgeCount;
        for i := 0 to c - 1 do begin
          if HighLevels then
            ExtSiblingNode := GetExtNode(Node.OutEdges[i].Target)
          else
            ExtSiblingNode := GetExtNode(Node.InEdges[i].Source);
          if (ExtSiblingNode.Level >= NewLevel) and (ExtSiblingNode.Level < ExtAdjustNode.Level) then
            NewLevel := ExtSiblingNode.Level + 1;
        end;
        if HighLevels then
          c := Node.InEdgeCount
        else
          c := Node.OutEdgeCount;
        // check backlinks
        for i := 0 to c - 1 do begin
          if HighLevels then
            ExtSiblingNode := GetExtNode(Node.InEdges[i].Source)
          else
            ExtSiblingNode := GetExtNode(Node.OutEdges[i].Target);
          if (ExtSiblingNode.Level = NewLevel) then
            NewLevel := ExtSiblingNode.Level + 1;
        end;
      end;

      if (ExtAdjustNode.Level = NewLevel) and not Force then begin
        ExtAdjustNode.InPath := False;
        exit;
      end;

      OldLevel := ExtAdjustNode.Level;
      ExtAdjustNode.Level := NewLevel;
      if NewLevel > MaxLevel then
          MaxLevel := NewLevel;
      if OldLevel = MaxLevel then
        MaybeReduceMaxLevel := True;

      Node := ExtAdjustNode.Node;
      if HighLevels then
        c := Node.InEdgeCount
      else
        c := Node.OutEdgeCount;
      for i := 0 to c - 1 do begin
        if HighLevels then
          ExtSiblingNode := GetExtNode(Node.InEdges[i].Source)
        else
          ExtSiblingNode := GetExtNode(Node.OutEdges[i].Target);
        if ExtSiblingNode.Level >= OldLevel then // do not adjust other BackEdges
          AdjustSiblingLevels(ExtSiblingNode, NewLevel + 1);
      end;
      // maybe new backegdes on the InEdge side
      if HighLevels then
        c := Node.OutEdgeCount
      else
        c := Node.InEdgeCount;
      for i := 0 to c - 1 do begin
        if HighLevels then
          ExtSiblingNode := GetExtNode(Node.OutEdges[i].Target)
        else
          ExtSiblingNode := GetExtNode(Node.InEdges[i].Source);
        if ExtSiblingNode.Level = NewLevel then // do not adjust other BackEdges
          AdjustSiblingLevels(ExtSiblingNode, NewLevel + 1);
      end;

      ExtAdjustNode.InPath := False;
    end;
  var
    AVLNode: TAVLTreeNode;
    ExtNode, ExtTargetNode: TGraphLevelerNode;
    Node: TLvlGraphNode;
    LvlIdx, LowerLvl, BackEdgeCnt, TotalBackEdgeCnt: Integer;
    i, c, j, BestLvl: integer;
    BackEdgeList: array of TGraphLevelerNode;
    SiblingOnLvl: Boolean;
  begin
    SetLength(BackEdgeList, NodeCount);
    MaybeReduceMaxLevel := False;
    AVLNode := ExtNodes.FindLowest;
    while AVLNode <> nil do begin
      ExtNode := TGraphLevelerNode(AVLNode.Data);
      AVLNode := AVLNode.Successor;
      Node := ExtNode.Node;
      if (Node.SubGraph <> SubGraphIdx) then
        Continue;

      BackEdgeCnt := 0;
      if HighLevels then
        c := Node.InEdgeCount
      else
        c := Node.OutEdgeCount;
      if c > Length(BackEdgeList) then
        SetLength(BackEdgeList, c);
      LvlIdx := ExtNode.Level;
      for i := 0 to c - 1 do begin
        if HighLevels then
          ExtTargetNode := GetExtNode(Node.InEdges[i].Source)
        else
          ExtTargetNode := GetExtNode(Node.OutEdges[i].Target);
        if ExtTargetNode.Level <  LvlIdx then begin
          j := 0;
          while (j < BackEdgeCnt) and (BackEdgeList[j].Level < ExtTargetNode.Level) do
            inc(j);
          move(BackEdgeList[j], BackEdgeList[j+1], (BackEdgeCnt-j)*SizeOf(TGraphLevelerNode));
          BackEdgeList[j] := ExtTargetNode;
          inc(BackEdgeCnt);
        end;
      end;
      if BackEdgeCnt = 0 then
        Continue;

      BestLvl := ExtNode.Level;
      TotalBackEdgeCnt := BackEdgeCnt + IncomingBackEdgeCount(ExtNode, BestLvl, SiblingOnLvl, LowerLvl);
      BestLvl := LowerLvl + 1;
      while BackEdgeCnt > 0 do begin
        dec(BackEdgeCnt);
        i := BackEdgeList[BackEdgeCnt].Level;
        while (BackEdgeCnt > 0) and (BackEdgeList[BackEdgeCnt - 1].Level = i) do
          dec(BackEdgeCnt);
        c := BackEdgeCnt + IncomingBackEdgeCount(ExtNode, i, SiblingOnLvl, LowerLvl);
        if c < TotalBackEdgeCnt then begin
          BestLvl := LowerLvl + 1;
          TotalBackEdgeCnt := c;
        end;
      end;

      if BestLvl < ExtNode.Level then begin
        ExtNode.Level := BestLvl;
        AdjustSiblingLevels(ExtNode, BestLvl, True);
      end;

    end;

    if MaybeReduceMaxLevel then begin
      MaxLevel := StartLevel;
      AVLNode := ExtNodes.FindLowest;
      while AVLNode <> nil do begin
        ExtNode := TGraphLevelerNode(AVLNode.Data);
        AVLNode := AVLNode.Successor;
        if ExtNode.Node.SubGraph <> SubGraphIdx then
          continue;
        if ExtNode.Level > MaxLevel then
          MaxLevel := ExtNode.Level;
      end;
    end;
  end;

var
  i, g, GroupMinLevel: Integer;
  Node: TLvlGraphNode;
  ExtNode: TGraphLevelerNode;
  CurrentSubGraph: TLvlGraphSubGraph;
begin
  //WriteDebugReport('TLvlGraph.CreateTopologicalLevels START');
  {$IFDEF LvlGraphConsistencyCheck}
  ConsistencyCheck(false);
  {$ENDIF}
  ExtNodes:=TAvlTree.Create(@CompareGraphLevelerNodes);
  try
    // init ExtNodes
    for i:=0 to NodeCount-1 do begin
      Node:=Nodes[i];
      ExtNode:=TGraphLevelerNode.Create;
      ExtNode.Node:=Node;
      ExtNodes.Add(ExtNode);
    end;
    // traverse all nodes
    MaxLevel:=-1;
    for g := 0 to SubGraphCount - 1 do begin
      inc(MaxLevel);
      CurrentSubGraph := SubGraphs[g];
      CurrentSubGraph.FLowestLevel := MaxLevel;
      GroupMinLevel := MaxLevel;
      for i:=0 to NodeCount-1 do begin
        Node:=Nodes[i];
        if (Node.SubGraph <> CurrentSubGraph.Index) then
          Continue;
        Traverse(GetExtNode(Node), GroupMinLevel);
      end;

      if ReduceBackEdges then
        DoReduceBackEdges(MaxLevel, CurrentSubGraph.FLowestLevel, CurrentSubGraph.Index);
      CurrentSubGraph.FHighestLevel := MaxLevel;
    end;

    // set levels
    LevelCount:=Max(LevelCount,MaxLevel+1);
    for i:=0 to NodeCount-1 do begin
      Node:=Nodes[i];
      ExtNode:=GetExtNode(Node);
      if HighLevels then begin
        CurrentSubGraph := SubGraphs[ExtNode.Node.SubGraph];
        Node.Level:=Levels[CurrentSubGraph.LowestLevel + CurrentSubGraph.HighestLevel - ExtNode.Level];
      end
      else
        Node.Level:=Levels[ExtNode.Level];
    end;
    // delete unneeded levels
    LevelCount:=MaxLevel+1;
  finally
    ExtNodes.FreeAndClear;
    ExtNodes.Free;
  end;
  //WriteDebugReport('TLvlGraph.CreateTopologicalLevels END');
  {$IFDEF LvlGraphConsistencyCheck}
  ConsistencyCheck(False);
  {$ENDIF}
end;

procedure TLvlGraph.MinimizeEdgeLens(HighLevels: boolean);
(* This method can only minize edges in certain graphs.
   Therefore some edges may not be fully minimized.

  Possible TODOs
  * gelOnlyPush:
    - For Edges with len>1, check if the target node is reachable via len=1 nodes.
    If yes the edge cannot be shortened
    - Collect all InEntries for each entire group, so that CalculateCostForMoveUp can
    calculate the cost for the entire group at once.
  * Check for nodes in front of the current node, that are free to pull up.
    If a node has several InEdges, they may prevent it from moving.
    And in turn the node itself may prevent any of those sources from moving.
*)
var
  NodeTree: TGraphEdgeLenMinimizerTree; // tree of TGraphEdgeLenMinimizerNode sorted by Node
  VisitingId: Integer;

  procedure UpdateMaxLevelsForSiblings(ExtNode: TGraphEdgeLenMinimizerNode);
  var
    i: Integer;
    Sibling: TGraphEdgeLenMinimizerNode;
  begin
    for i := 0 to ExtNode.InSiblingCount - 1 do begin
      Sibling := ExtNode.InSibling[i];
      Sibling.MaxLevel := Min(Sibling.MaxLevel, ExtNode.MaxLevel-1);
      Assert(Sibling.MaxLevel >= Sibling.Level, 'UpdateMaxLevelsForSiblings: Sibling.MinLevel <= Sibling.Level');
      Assert(Sibling.Level < ExtNode.Level, 'UpdateMaxLevelsForSiblings: Sibling.Level > ExtNode.Level');
    end;
  end;

  procedure MaybeMarkOnlyPush(ExtNode: TGraphEdgeLenMinimizerNode);
  var
    i: Integer;
    Sibling: TGraphEdgeLenMinimizerNode;
  begin
    for i := 0 to ExtNode.OutSiblingCount - 1 do begin
      if ExtNode.OutSiblingDistance[i] > 1 then exit;
      Sibling := ExtNode.OutSibling[i];
      assert(Sibling.Level - ExtNode.Level = 1, 'MaybeMarkOnlyPush: Dist = 1');
      if not (gelOnlyPush in Sibling.Flags) then exit;
    end;
    Include(ExtNode.Flags, gelOnlyPush);
  end;

  function CalculateCostForMoveUp(CalcExtNode: TGraphEdgeLenMinimizerNode; var CalcNewLevel: Integer): Integer;
    function CheckInEdgeSavingsQuick(InEdgeExtNode: TGraphEdgeLenMinimizerNode; MaxSavingNeeded: Integer): Integer;
    var
      i, j, l, d, SiblingCanSave: Integer;
      InSibling, ReverseSibling: TGraphEdgeLenMinimizerNode;
    begin
      Result := 0;
      l := InEdgeExtNode.Level - 1;
      for i := 0 to InEdgeExtNode.InSiblingCount - 1 do begin
        InSibling := InEdgeExtNode.InSibling[i];
        SiblingCanSave := 0;
        if InSibling.Level < l then
          continue;
        if InSibling.InSiblingCount >= InSibling.OutSiblingCount-1 then
          continue;
        for j := 0 to InSibling.OutSiblingCount - 1 do begin
          ReverseSibling := InSibling.OutSibling[j];
          d := ReverseSibling.Level - InSibling.Level;
          if (ReverseSibling = InEdgeExtNode) then
            continue;
          if d <= 1 then
            break;
          if d < MaxSavingNeeded then
            MaxSavingNeeded := d;
        end;
        if (d <= 1) and (ReverseSibling <> InEdgeExtNode) then begin // loop aborted
          continue;
        end;
        for j := 0 to InSibling.OutSiblingCount - 1 do begin
          ReverseSibling := InSibling.OutSibling[j];
          if (ReverseSibling = InEdgeExtNode) then
            continue;
          d := ReverseSibling.Level - InSibling.Level;
          SiblingCanSave := SiblingCanSave + Min(MaxSavingNeeded, d);
        end;
        SiblingCanSave := SiblingCanSave - InSibling.InSiblingCount;
        Result := Result + max(0, SiblingCanSave);
      end;
    end;
    procedure SetNewLevelDiffRecursive(TargetExtNode: TGraphEdgeLenMinimizerNode; TargetNewLevel: Integer;
      out CostChangesAtLevel: integer);
    var
      Diff, i, SiblingCostChangesAtLevel: Integer;
      FirstMove: Boolean;
      SiblingNode: TGraphEdgeLenMinimizerNode;
    begin
      Assert(TargetNewLevel <= TargetExtNode.MaxLevel, 'CalculateCostForMoveUp(): TargetNewLevel < MaxLevel');
      Assert(TargetNewLevel < LevelCount, 'CalculateCostForMoveUp(): TargetNewLevel < LevelCount');
      CostChangesAtLevel := TargetExtNode.Level + 1; // Applies, if this node is NOT pushed
      Diff := TargetNewLevel - TargetExtNode.Level;
      FirstMove := TargetExtNode.VisitedId <> VisitingId; // The same node may be pushed several times, if more than one edge leads here
      TargetExtNode.VisitedId := VisitingId;
      if FirstMove then
        TargetExtNode.LevelDiff := 0
      else
        CostChangesAtLevel := TargetExtNode.MaxLevel+1; // correct limit has been applied before / in case next line does exit
      if Diff <= TargetExtNode.LevelDiff then
        exit;
      TargetExtNode.LevelDiff := Diff;
      CostChangesAtLevel := TargetExtNode.MaxLevel+1; // Best case we can go to MaxLevel, then cost goes to infinite
      if (TargetExtNode.InSiblingCount > 1) then       // One InEdge is from the pushing node
        CostChangesAtLevel := TargetExtNode.Level + Diff + 1; // could be more, if the nodes can be pulled free of cost
      for i := 0 to TargetExtNode.InSiblingCount - 1 do begin
        SiblingNode := TargetExtNode.InSibling[i];
        if SiblingNode.VisitedId <> VisitingId then
          SiblingNode.LevelDiff := 0;
      end;
      for i := 0 to TargetExtNode.OutSiblingCount - 1 do begin
        SiblingNode := TargetExtNode.OutSibling[i];
        SetNewLevelDiffRecursive(SiblingNode, TargetNewLevel + 1, SiblingCostChangesAtLevel);
        if SiblingCostChangesAtLevel - 1 < CostChangesAtLevel then
          CostChangesAtLevel := SiblingCostChangesAtLevel - 1;
      end;
    end;
    function DoCalculateCostForMoveUp(ExtNode: TGraphEdgeLenMinimizerNode): Integer;
    var
      i: Integer;
      SiblingNode: TGraphEdgeLenMinimizerNode;
    begin
      Result := 0;
      if (ExtNode.VisitedId = VisitingId) or (ExtNode.LevelDiff = 0) then
        exit;
      ExtNode.VisitedId := VisitingId;
      // InEdges get longer
      for i := 0 to ExtNode.InSiblingCount - 1 do
        Result := Result + ExtNode.LevelDiff - ExtNode.InSibling[i].LevelDiff;
      for i := 0 to ExtNode.OutSiblingCount - 1 do begin
        SiblingNode := ExtNode.OutSibling[i];
        Result := Result - ExtNode.LevelDiff + SiblingNode.LevelDiff;
        Result := Result + DoCalculateCostForMoveUp(SiblingNode);
      end;
    end;
  var
    NextCostChangesAtLevel, i: Integer;
  begin
    inc(VisitingId);
    SetNewLevelDiffRecursive(CalcExtNode, CalcNewLevel, NextCostChangesAtLevel);
    dec(NextCostChangesAtLevel); // the last level use-able without extra cost
    Assert(NextCostChangesAtLevel <= CalcExtNode.MaxLevel, 'CalculateCostForMoveUp: NextCostChangesAtLevel <= CalcExtNode.MaxLevel');
    Assert(NextCostChangesAtLevel >= CalcNewLevel, 'CalculateCostForMoveUp: NextCostChangesAtLevel >= CalcNewLevel');
    if (NextCostChangesAtLevel > CalcNewLevel) and (NextCostChangesAtLevel <= CalcExtNode.MaxLevel) then begin
      CalcNewLevel := NextCostChangesAtLevel;
      inc(VisitingId);
      SetNewLevelDiffRecursive(CalcExtNode, CalcNewLevel, NextCostChangesAtLevel);
    end;
    inc(VisitingId);
    Result := DoCalculateCostForMoveUp(CalcExtNode);
    if Result >= 0 then
      Result := Result - CheckInEdgeSavingsQuick(CalcExtNode, CalcNewLevel - CalcExtNode.Level)
    else
    if Result = 0 then begin
      inc(Result); // zero cost should be moved only, if it might block on of its InEdges
      for i := 0 to CalcExtNode.InSiblingCount - 1 do begin
        if CalcExtNode.InSibling[i].Level = CalcExtNode.Level - 1 then begin
          dec(Result); // return 0 => at least one node that might be blocked
          exit;
        end;
      end;
    end;
  end;

  procedure PushLevelUpRecursive(ExtNode: TGraphEdgeLenMinimizerNode; NewLevel: Integer);
  var
    i: Integer;
  begin
    Assert(NewLevel < LevelCount, 'PushLevelUpRecursive: NewLevel < LevelCount');
    if ExtNode.Level >= NewLevel then
      exit;
    ExtNode.Level:=NewLevel;

    for i := 0 to ExtNode.OutSiblingCount - 1 do
      PushLevelUpRecursive(ExtNode.OutSibling[i], NewLevel + 1);
  end;

  function TryMoveNode(ExtNode: TGraphEdgeLenMinimizerNode): boolean;
  var
    BestCost, ConsecutiveBadCost, Cost, BestLvl, i, mx: Integer;
  begin
    Result := False;
    BestCost := 0;
    ConsecutiveBadCost := 0;

    mx := ExtNode.MaxLevel-1;
    i := ExtNode.Level;
    while i < mx do begin
      inc(i);
      Cost := CalculateCostForMoveUp(ExtNode, i);
      if Cost > 0 then begin
        ConsecutiveBadCost := ConsecutiveBadCost + 1;
        if ConsecutiveBadCost >= 3 then
          break; // give up
      end
      else
      if Cost <= BestCost then begin
        ConsecutiveBadCost := 0;
        BestCost := Cost;
        BestLvl := i;
      end;
    end;

    inc(mx);
    Cost := CalculateCostForMoveUp(ExtNode, mx);
    if Cost <= BestCost then begin
      BestCost := Cost;
      BestLvl := mx;
    end;

    //DebugLn([' BestCost: ',ExtNode.Node.Caption, ' from ', ExtNode.Level, ' to idx ', BestLvl,' (', ExtNode.Level+1 ,'..', ExtNode.MaxLevel,')  cost ', BestCost ]);
    Result := BestCost < 0;
    if Result then
      PushLevelUpRecursive(ExtNode, BestLvl);
  end;

var
  i, l, j: Integer;
  ExtNode: TGraphEdgeLenMinimizerNode;
  DidMove: Boolean;
  CurrentSubGraph: TLvlGraphSubGraph;
begin
  NodeTree:=TGraphEdgeLenMinimizerTree.Create;
  NodeTree.Graph:=Self;
  VisitingId := 0;
  if HighLevels then
    NodeTree.NodeClass := TGraphEdgeLenMinimizerReverseNode;

  try
    // init NodeTree // Add highest level first, so nodes can be linked in initial order
    for j := LevelCount-1 downto 0 do begin
      l := NodeTree.MapLevel(j);
      for i := 0 to Levels[l].Count - 1 do begin
        ExtNode := NodeTree.AddGraphNode(Levels[l].Nodes[i]);
        CurrentSubGraph := SubGraphs[ExtNode.Node.SubGraph];
        ExtNode.MaxLevel := CurrentSubGraph.HighestLevel;
        ExtNode.MinSubGraphLevel := CurrentSubGraph.LowestLevel;
        ExtNode.MaxSubGraphLevel := CurrentSubGraph.HighestLevel;
      end;
    end;

    // Update MaxLevel
    ExtNode := NodeTree.ExtNodeWithHighestLevel;
    while ExtNode <> nil do begin
      UpdateMaxLevelsForSiblings(ExtNode);
      ExtNode := ExtNode.NextExtNodeTowardsLowerLevel;
    end;

    // gelOnlyPush: Mark nodes, with no outgoing edges that could be shortened (push would push entire subtree)
    ExtNode := NodeTree.ExtNodeWithHighestLevel;
    while ExtNode <> nil do begin
      if ExtNode.MaxLevel > ExtNode.Level then
        MaybeMarkOnlyPush(ExtNode);
      ExtNode := ExtNode.NextExtNodeTowardsLowerLevel;
    end;

    repeat
      DidMove := False;
      ExtNode := TGraphEdgeLenMinimizerNode(NodeTree.FindLowest);
      while ExtNode<> nil do begin
        if (ExtNode.OutSiblingCount > 0) and (ExtNode.MaxLevel > ExtNode.Level) and
           not(gelOnlyPush in ExtNode.Flags)
        then
          if TryMoveNode(ExtNode) then
            DidMove := True;
        ExtNode := TGraphEdgeLenMinimizerNode(ExtNode.Successor);
      end;
    until not DidMove;

  finally
    NodeTree.Free;
  end;
end;

procedure TLvlGraph.LimitLevelHeights(MaxHeight: integer; MaxHeightRel: Single);
var
  SubGraphIdx, LowLevelIdx, HighLevelIdx, CurLevelIdx: Integer;
  CurNodeCount, CurMaxHeight: Integer;
  i, j, w, LevelsNeeded, TargetLvlCnt: Integer;
  CurLevel: TLvlGraphLevel;
  CurNode: TLvlGraphNode;
  NodeWeights: array of record
    Node: TLvlGraphNode;
    Weight: integer;
  end;
  CurrentSubGraph: TLvlGraphSubGraph;
begin
  if LevelCount = 0 then
    exit;
  NodeWeights := nil;
  For SubGraphIdx := 0 to SubGraphCount-1 do begin
    CurrentSubGraph := SubGraphs[SubGraphIdx];
  //For SubGraphIdx := 0 to Max(0, FSubGraphCount-1) do begin
    // Find Lowest/Highest level for subgraph
    LowLevelIdx := CurrentSubGraph.LowestLevel;
    HighLevelIdx := CurrentSubGraph.HighestLevel;
    CurNodeCount := 0;
    for i := LowLevelIdx to HighLevelIdx do
      CurNodeCount := CurNodeCount + Levels[i].Count;

    // Calculate CurMaxHeight for SubGraph
    if MaxHeightRel > 0 then begin
      if MaxHeight > 0 then
        CurMaxHeight := Min(MaxHeight, Max(3, Trunc(0.5 + sqrt(CurNodeCount)*MaxHeightRel)))
      else
        CurMaxHeight := Max(3, Trunc(0.5 + sqrt(CurNodeCount)*MaxHeightRel));
    end
    else
      CurMaxHeight := MaxHeight;
    if CurMaxHeight <= 0 then Continue;

    // Process each level
    CurLevelIdx := HighLevelIdx + 1;
    while CurLevelIdx > LowLevelIdx do begin
      dec(CurLevelIdx);
      CurLevel := Levels[CurLevelIdx];
      if CurLevel.Count <= CurMaxHeight then
        continue;

      if Length(NodeWeights) < CurLevel.Count then
        SetLength(NodeWeights, CurLevel.Count + 8);

      for i := 0 to CurLevel.Count - 1 do begin
        CurNode := CurLevel.Nodes[i];
        if CurNode.InEdgeCount = 0 then
          w := CurNodeCount * CurNode.OutEdgeCount
        else
        if CurNode.OutEdgeCount = 0 then
          w := -CurNodeCount * CurNode.InEdgeCount
        else
          w := CurNode.OutEdgeCount - CurNode.InEdgeCount;
        // if w=0 then // find outher criteria; edge length...
        //DebugLn(w=0, ['LimitLevelHeights has node with zero weight. L=', CurLevel.Index, ' N=',CurNode.IndexInLevel, ' ', CurNode.Caption]);

        j := 0;
        while (j < i) and (NodeWeights[j].Weight < w) do
          inc(j);
        if j < i then
          move(NodeWeights[j], NodeWeights[j+1], (i-j) * SizeOf(NodeWeights[0]));
        NodeWeights[j].Node := CurNode;
        NodeWeights[j].Weight := w;
      end;

      LevelsNeeded := (CurLevel.Count-1) div CurMaxHeight + 1;
      assert(LevelsNeeded > 1, 'LimitLevelHeights: LevelsNeeded > 1');
      for i := 0 to LevelsNeeded-2 do
        NewLevelAtIndex(CurLevelIdx+1, SubGraphIdx);

      i := CurLevel.Count;
      while LevelsNeeded > 1 do begin
        TargetLvlCnt := i div LevelsNeeded;
        j := min(i, CurMaxHeight); // Nodes with no InEdge should be moved until MaxHeight, even if the distribution of nodes will be uneven
        dec(LevelsNeeded);
        CurLevel := Levels[CurLevelIdx+LevelsNeeded];
        while ( (TargetLvlCnt > 0) or
                ( (j > 0) and (NodeWeights[i-1].Weight>=CurNodeCount) )
              ) and
              not( (i<=MaxHeight) and (NodeWeights[i-1].Weight<=-CurNodeCount) )  // Keep as many Nodes with no outedge, in the left most column
        do begin
          dec(i);
          NodeWeights[i].Node.Level := CurLevel;
          dec(TargetLvlCnt);
          dec(j);
        end;
      end;

    end;
  end;
end;

procedure TLvlGraph.SplitLongEdges(SplitMode: TLvlGraphEdgeSplitMode);
// replace edges over several levels into several short edges by adding hidden nodes
type
  THiddenGraphNodeArray = Array [boolean] of TLvlGraphNodeArray;
  TNodeInfo = record
    HiddenNodes: THiddenGraphNodeArray;
    LongInEdges, LongOutEdges: integer;
  end;
  PNodeInfo = ^TNodeInfo;

var
  NodeToInfo: TPointerToPointerTree; // node to TNodeInfo
  n: Integer;
  SourceNode: TLvlGraphNode;
  e: Integer;
  Edge: TLvlGraphEdge;
  TargetNode: TLvlGraphNode;
  EdgeWeight: Single;
  EdgeData: Pointer;
  HiddenNodes: TLvlGraphNodeArray;
  l: Integer;
  LastNode: TLvlGraphNode;
  NextNode: TLvlGraphNode;
  AVLNode: TAvlTreeNode;
  P2PItem: PPointerToPointerItem;
  MergeAtSourceNode, EdgeBack: Boolean;
  SourceInfo: PNodeInfo;
  TargetInfo: PNodeInfo;
begin
  if SplitMode=lgesNone then exit;

  NodeToInfo:=TPointerToPointerTree.Create;
  try
    // create node infos
    for n:=0 to NodeCount-1 do begin
      SourceNode:=Nodes[n];
      New(SourceInfo);
      FillByte(SourceInfo^,SizeOf(TNodeInfo),0);
      SetLength(SourceInfo^.HiddenNodes[False],LevelCount);
      SetLength(SourceInfo^.HiddenNodes[True],LevelCount);
      for e:=0 to SourceNode.OutEdgeCount-1 do begin
        Edge:=SourceNode.OutEdges[e];
        if Edge.Target.Level.Index-SourceNode.Level.Index<=1 then continue;
        SourceInfo^.LongOutEdges+=1;
      end;
      for e:=0 to SourceNode.InEdgeCount-1 do begin
        Edge:=SourceNode.InEdges[e];
        if SourceNode.Level.Index-Edge.Source.Level.Index<=1 then continue;
        SourceInfo^.LongInEdges+=1;
      end;
      //debugln(['TLvlGraph.SplitLongEdges ',SourceNode.Caption,' LongOutEdges=',SourceInfo^.LongOutEdges,' LongInEdges=',SourceInfo^.LongInEdges]);
      NodeToInfo[SourceNode]:=SourceInfo;
    end;

    // split long edges
    for n:=0 to NodeCount-1 do begin
      SourceNode:=Nodes[n];
      for e:=SourceNode.OutEdgeCount-1 downto 0 do begin // Note: run downwards, because edges will be deleted
        Edge:=SourceNode.OutEdges[e];
        TargetNode:=Edge.Target;
        if TargetNode.Level.Index-SourceNode.Level.Index<=1 then continue;
        //debugln(['TLvlGraph.SplitLongEdges long edge: ',SourceNode.Caption,'(',SourceNode.Level.Index,') ',TargetNode.Caption,'(',TargetNode.Level.Index,')']);
        EdgeWeight:=Edge.Weight;
        EdgeData:=Edge.Data;
        EdgeBack:=Edge.BackEdge;
        // remove long edge
        Edge.Free;
        // create merged hidden nodes
        if SplitMode in [lgesMergeSource,lgesMergeTarget,lgesMergeHighest] then
        begin
          SourceInfo:=PNodeInfo(NodeToInfo[SourceNode]);
          TargetInfo:=PNodeInfo(NodeToInfo[TargetNode]);
          MergeAtSourceNode:=true;
          case SplitMode of
          lgesMergeTarget: MergeAtSourceNode:=false;
          lgesMergeHighest: MergeAtSourceNode:=SourceInfo^.LongOutEdges>=TargetInfo^.LongInEdges;
          end;
          //debugln(['TLvlGraph.SplitLongEdges ',SourceNode.Caption,'=',SourceInfo^.LongOutEdges,' ',TargetNode.Caption,'=',TargetInfo^.LongInEdges,' MergeAtSourceNode=',MergeAtSourceNode]);
          if MergeAtSourceNode then
            HiddenNodes:=SourceInfo^.HiddenNodes[EdgeBack]
          else
            HiddenNodes:=TargetInfo^.HiddenNodes[EdgeBack];
          // create hidden nodes
          for l:=SourceNode.Level.Index+1 to TargetNode.Level.Index-1 do
            if HiddenNodes[l]=nil then
              HiddenNodes[l]:=CreateHiddenNode(l);
        end;
        // create edges
        LastNode:=SourceNode;
        for l:=SourceNode.Level.Index+1 to TargetNode.Level.Index do begin
          if l<TargetNode.Level.Index then begin
            if SplitMode=lgesSeparate then
              NextNode:=CreateHiddenNode(l)
            else
              NextNode:=HiddenNodes[l];
          end else
            NextNode:=TargetNode;
          Edge:=GetEdge(LastNode,NextNode,true);
          Edge.Weight:=Edge.Weight+EdgeWeight;
          Edge.FBackEdge:=EdgeBack;
          if Edge.Data=nil then
            Edge.Data:=EdgeData;
          LastNode:=NextNode;
        end;
      end;
    end;
  finally
    // free NodeToInfo
    AVLNode:=NodeToInfo.Tree.FindLowest;
    while AVLNode<>nil do begin
      P2PItem:=PPointerToPointerItem(AVLNode.Data);
      SourceInfo:=PNodeInfo(P2PItem^.Value);
      Dispose(SourceInfo);
      AVLNode:=NodeToInfo.Tree.FindSuccessor(AVLNode);
    end;
    NodeToInfo.Free;
  end;
end;

procedure TLvlGraph.ScaleNodeDrawSizes(NodeGapAbove, NodeGapBelow,
  HardMaxTotal, HardMinOneNode, SoftMaxTotal, SoftMinOneNode: integer; out
  PixelPerWeight: single);
{ NodeGapAbove: minimum space above each node
  NodeGapBelow: minimum space below each node
  HardMaxTotal: maximum size of largest level
  HardMinOneNode: minimum size of a node
  SoftMaxTotal: preferred maximum size of the largest level, total can be bigger
                to achieve HardMinOneNode
  SoftMinOneNode: preferred minimum size of a node, can be smaller to achieve
                  SoftMaxTotal
  Order of precedence: HardMinOneNode, SoftMaxTotal, SoftMinOneNode
}
var
  SmallestWeight: Single;
  i: Integer;
  Node: TLvlGraphNode;
  j: Integer;
  Edge: TLvlGraphEdge;
  Level: TLvlGraphLevel;
  LvlWeight: Single;
  MinPixelPerWeight, PrefMinPixelPerWeight: single;
  DrawHeight: integer;
  MaxPixelPerWeight, PrefMaxPixelPerWeight: single;
  Gap: Integer;
begin
  PixelPerWeight:=1.0;
  //debugln(['TLvlGraph.ScaleNodeDrawSizes',
  //  ' NodeGapAbove=',NodeGapAbove,' NodeGapBelow=',NodeGapBelow,
  //  ' HardMaxTotal=',HardMaxTotal,' HardMinOneNode=',HardMinOneNode,
  //  ' SoftMaxTotal=',SoftMaxTotal,' SoftMinOneNode=',SoftMinOneNode]);

  // sanitize input
  HardMinOneNode:=Max(0,HardMinOneNode);
  SoftMinOneNode:=Max(SoftMinOneNode,HardMinOneNode);
  HardMaxTotal:=Max(1,HardMaxTotal);
  SoftMaxTotal:=Min(Max(1,SoftMaxTotal),HardMaxTotal);

  SmallestWeight:=-1.0;
  for i:=0 to NodeCount-1 do begin
    Node:=Nodes[i];
    for j:=0 to Node.OutEdgeCount-1 do begin
      Edge:=Node.OutEdges[j];
      if Edge.Weight<=0.0 then continue;
      if (SmallestWeight<0) or (SmallestWeight>Edge.Weight) then
        SmallestWeight:=Edge.Weight;
    end;
  end;
  if SmallestWeight<0 then SmallestWeight:=1.0;
  if SmallestWeight>0 then begin
    MinPixelPerWeight:=single(HardMinOneNode)/SmallestWeight;
    PrefMinPixelPerWeight:=single(SoftMinOneNode)/SmallestWeight;
  end else begin
    MinPixelPerWeight:=single(HardMinOneNode);
    PrefMinPixelPerWeight:=single(SoftMinOneNode);
  end;
  //debugln(['TLvlGraph.ScaleNodeDrawSizes SmallestWeight=',SmallestWeight,
  //  ' MinPixelPerWeight=',MinPixelPerWeight,
  //  ' PrefMinPixelPerWeight=',PrefMinPixelPerWeight]);

  MaxPixelPerWeight:=0.0;
  PrefMaxPixelPerWeight:=0.0;
  for i:=0 to LevelCount-1 do begin
    Level:=Levels[i];
    // LvlWeight = how much weight to draw
    // DrawHeight - how much pixel left to draw the weight
    LvlWeight:=0.0;
    Gap:=0;
    DrawHeight:=HardMaxTotal;
    for j:=0 to Level.Count-1 do begin
      // ToDo: Node is probably uninitialized.
      LvlWeight+=Max(Node.InWeight,Node.OutWeight);
      Gap+=NodeGapAbove+NodeGapBelow;
    end;
    if LvlWeight=0.0 then continue;
    DrawHeight:=Max(1,HardMaxTotal-Gap);
    PixelPerWeight:=single(DrawHeight)/LvlWeight;
    if (MaxPixelPerWeight=0.0) or (MaxPixelPerWeight>PixelPerWeight) then
      MaxPixelPerWeight:=PixelPerWeight;
    DrawHeight:=Max(1,SoftMaxTotal-Gap);
    PixelPerWeight:=single(DrawHeight)/LvlWeight;
    if (PrefMaxPixelPerWeight=0.0) or (PrefMaxPixelPerWeight>PixelPerWeight) then
      PrefMaxPixelPerWeight:=PixelPerWeight;
  end;
  //debugln(['TLvlGraph.ScaleNodeDrawSizes MaxPixelPerWeight=',MaxPixelPerWeight,' PrefMaxPixelPerWeight=',PrefMaxPixelPerWeight]);

  PixelPerWeight:=PrefMinPixelPerWeight;
  if PrefMaxPixelPerWeight>0.0 then
    PixelPerWeight:=Min(PixelPerWeight,PrefMaxPixelPerWeight);
  PixelPerWeight:=Max(PixelPerWeight,MinPixelPerWeight);
  if MaxPixelPerWeight>0.0 then
    PixelPerWeight:=Min(PixelPerWeight,MaxPixelPerWeight);

  //debugln(['TLvlGraph.ScaleNodeDrawSizes PixelPerWeight=',PixelPerWeight]);
  SetAllNodeDrawSizes(PixelPerWeight,SmallestWeight);
end;

procedure TLvlGraph.SetAllNodeDrawSizes(PixelPerWeight: single;
  MinWeight: single);
var
  i: Integer;
  Node: TLvlGraphNode;
begin
  for i:=0 to NodeCount-1 do begin
    Node:=Nodes[i];
    Node.DrawSize:=round(Max(MinWeight,Max(Node.InWeight,Node.OutWeight))*PixelPerWeight+0.5);
  end;
end;

procedure TLvlGraph.MarkBackEdges;
var
  i: Integer;
  Node, OtherNode: TLvlGraphNode;
  j, k: Integer;
  Edge: TLvlGraphEdge;
begin
  for i:=0 to NodeCount-1 do
    for j := 0 to Nodes[i].OutEdgeCount-1 do
      Nodes[i].OutEdges[j].FNoGapCircle := False;
  for i:=0 to NodeCount-1 do begin
    Node:=Nodes[i];
    for j:=Node.OutEdgeCount-1 downto 0 do begin // Edges may be removed/replaced
      Edge:=Node.OutEdges[j];
      if Edge.IsBackEdge then
        Edge.RevertDirection;
      if Edge.Source.Level.Index = Edge.Target.Level.Index - 1 then begin
        // check for circles of exactly 2 nodes, with no levels between
        OtherNode := Edge.Source;
        for k := 0 to OtherNode.OutEdgeCount - 1 do begin
          if (OtherNode.OutEdges[k] <> Edge) and
             (OtherNode.OutEdges[k].Target = Node) and
             (not OtherNode.OutEdges[k].BackEdge)
          then begin
            Edge.FNoGapCircle := True;
            OtherNode.OutEdges[k].FNoGapCircle := True;
          end;
        end;
      end;
    end;
  end;
end;

procedure TLvlGraph.MinimizeCrossings;
begin
  LvlGraphMinimizeCrossings(Self);
end;

procedure TLvlGraph.MinimizeOverlappings(MinPos: integer;
  NodeGapAbove: integer; NodeGapBelow: integer);
var
  i: Integer;
begin
  for i:=0 to LevelCount-1 do
    MinimizeOverlappings(MinPos,NodeGapAbove,NodeGapBelow,i);
end;

procedure TLvlGraph.MinimizeOverlappings(MinPos: integer;
  NodeGapAbove: integer; NodeGapBelow: integer; aLevel: integer);
var
  Below, i: Integer;
  Level: TLvlGraphLevel;
  Node: TLvlGraphNode;
  PreviousNode: TLvlGraphNode;
begin
  Level:=Levels[aLevel];
  if Level.Count = 0 then
    exit;

  PreviousNode := Level[0];
  PreviousNode.DrawPosition:=MinPos+NodeGapAbove;

  for i:=1 to Level.Count-1 do begin
    Node:=Level[i];
    Below := 0;
    if PreviousNode.Visible then
      Below := NodeGapBelow;
    if Node.Visible then
      Node.DrawPosition:=Max(Node.DrawPosition,PreviousNode.DrawPositionEnd+Below+NodeGapAbove)
    else
      Node.DrawPosition:=Max(Node.DrawPosition,PreviousNode.DrawPositionEnd+1+Below);
    //debugln(['TLvlGraph.MinimizeOverlappings Level=',aLevel,' Node=',Node.Caption,' Size=',Node.DrawSize,' Position=',Node.DrawPosition]);
    PreviousNode:=Node;
  end;
end;

procedure TLvlGraph.StraightenGraph;
const
  DRAWPOS_UNKOWN = low(integer);
type
  TNodeInfo = record
    TheNode: TLvlGraphNode;
    TheNodeIdx: Integer;
    TheLevelIdx: Integer;
    DrawPosGapAbove: integer;
    CurDrawPos, TmpDrawPos: Integer;
  end;
  PNodeInfo = ^TNodeInfo;
var
  NodeInfos: array of array of TNodeInfo;

  function GetWantedDrawPosByAvgIn(NInfo: PNodeInfo): integer;
  var
    Node: TLvlGraphNode;
    i: Integer;
  begin
    Node := NInfo^.TheNode;
    if Node.InEdgeCount = 0 then
      exit(DRAWPOS_UNKOWN);
    Result := 0;
    for i := 0 to Node.InEdgeCount - 1 do
      Result := Result + Node.InEdges[i].Source.DrawCenter;
    Result := (Result div (Node.InEdgeCount));
  end;

  function GetWantedDrawPosByAvgOut(NInfo: PNodeInfo): integer;
  var
    Node: TLvlGraphNode;
    i: Integer;
  begin
    Node := NInfo^.TheNode;
    if Node.OutEdgeCount = 0 then
      exit(DRAWPOS_UNKOWN);
    Result := 0;
    for i := 0 to Node.OutEdgeCount - 1 do
      Result := Result + Node.OutEdges[i].Target.DrawCenter;
    Result := (Result div (Node.OutEdgeCount));
  end;

  procedure PreComputeWantedPositions(ALvlIdx, AnInWeight, AnOutWeight: integer);
  var
    Level: TLvlGraphLevel;
    NodeIdx: Integer;
    NInfo: PNodeInfo;
  begin
    Level := Levels[ALvlIdx];
    if Level.Count = 0 then
      exit;

    if (AnInWeight > 0) and (AnOutWeight > 0) then
      for NodeIdx := 0 to Level.Count - 1 do begin
        NInfo := @NodeInfos[ALvlIdx, NodeIdx];
        if (NInfo^.TheNode.OutEdgeCount > 0) and (NInfo^.TheNode.InEdgeCount > 0) then
          NInfo^.TmpDrawPos := (
            GetWantedDrawPosByAvgOut(NInfo) * AnOutWeight * NInfo^.TheNode.OutEdgeCount +
            GetWantedDrawPosByAvgIn(NInfo) * AnInWeight * NInfo^.TheNode.InEdgeCount
            ) div (AnOutWeight * NInfo^.TheNode.OutEdgeCount + AnInWeight * NInfo^.TheNode.InEdgeCount)
        else
        if (NInfo^.TheNode.OutEdgeCount > 0) then
          NInfo^.TmpDrawPos := GetWantedDrawPosByAvgOut(NInfo)
        else
          NInfo^.TmpDrawPos := GetWantedDrawPosByAvgIn(NInfo);
      end
    else
    if AnOutWeight > 0 then
      for NodeIdx := 0 to Level.Count - 1 do begin
        NInfo := @NodeInfos[ALvlIdx, NodeIdx];
        NInfo^.TmpDrawPos := GetWantedDrawPosByAvgOut(NInfo);
      end
    else
      for NodeIdx := 0 to Level.Count - 1 do begin
        NInfo := @NodeInfos[ALvlIdx, NodeIdx];
        NInfo^.TmpDrawPos := GetWantedDrawPosByAvgIn(NInfo);
      end;

  end;

  procedure AdjustNodesInLevel(ALvlIdx, AMinDrawPos, AMaxDrawPos: integer);
  var
    Level: TLvlGraphLevel;
    i, NodeIdx: Integer;
    PushUpNeeded, PushUpAllowed, FreeGapAbove: Integer;
    CurGroupWeight, CurGroupCnt, WantedPos: Integer;
    NInfo, NInfoPrev, PushNode, PushNodePrev: PNodeInfo;
    Node: TLvlGraphNode;
  begin
    Level := Levels[ALvlIdx];
    if Level.Count = 0 then
      exit;

    NInfoPrev := @NodeInfos[ALvlIdx, 0];
    if (NInfoPrev^.TmpDrawPos <> DRAWPOS_UNKOWN) and
       (NInfoPrev^.TmpDrawPos >= AMinDrawPos + NInfoPrev^.DrawPosGapAbove)
    then
      NInfoPrev^.CurDrawPos := NInfoPrev^.TmpDrawPos
    else
      NInfoPrev^.CurDrawPos := AMinDrawPos + NInfoPrev^.DrawPosGapAbove;
    NInfoPrev^.TheNode.DrawCenter := NInfoPrev^.CurDrawPos;

    for NodeIdx := 1 to Level.Count - 1 do begin
      NInfo := @NodeInfos[ALvlIdx, NodeIdx];
      Node := NInfo^.TheNode;
      if NInfo^.TmpDrawPos <> DRAWPOS_UNKOWN then begin
        NInfo^.CurDrawPos := NInfo^.TmpDrawPos;
        PushUpNeeded := (NInfoPrev^.CurDrawPos + NInfo^.DrawPosGapAbove) - NInfo^.TmpDrawPos;
      end
      else begin
        NInfo^.CurDrawPos := NInfoPrev^.CurDrawPos + NInfo^.DrawPosGapAbove;
        PushUpNeeded := 0;
      end;

      if PushUpNeeded > 0 then begin
        NInfo^.CurDrawPos := NInfo^.TmpDrawPos + PushUpNeeded; // default pos
        PushUpAllowed := 0;
        // try to push up prev node
        CurGroupWeight := 0; // negative: nodes have up-pull / positive: nodes have down-pull
        CurGroupCnt := 0;
        PushNode := NInfo;
        while (PushNode <> nil) do begin
          if PushNode^.TmpDrawPos <> DRAWPOS_UNKOWN then begin
            CurGroupWeight := CurGroupWeight + PushNode^.TmpDrawPos - PushNode^.CurDrawPos;
            inc(CurGroupCnt);
          end;

          if PushNode^.TheNodeIdx = 0 then begin
            PushNodePrev := nil;
            i := AMinDrawPos;
          end
          else begin
            PushNodePrev := @NodeInfos[ALvlIdx, PushNode^.TheNodeIdx-1];
            i := PushNodePrev^.CurDrawPos;
          end;

          FreeGapAbove := PushNode^.CurDrawPos - PushNode^.DrawPosGapAbove - i;
          if (FreeGapAbove = 0) and (PushNodePrev = nil) then
            break; // can not push any further
          if (FreeGapAbove > 0) then begin
            // push
            if CurGroupWeight >= 0 then
              break; // can not pull up
            Assert((CurGroupCnt > 0) or (CurGroupWeight = 0), 'AdjustNodesInLevel: (CurGroupCnt > 0) or (CurGroupWeight = 0)');
            i := 0;
            if CurGroupCnt > 0 then
              i := -(CurGroupWeight - CurGroupCnt div 2) div CurGroupCnt;
            i := Min(Min(i, PushUpNeeded), FreeGapAbove);
            PushUpAllowed := PushUpAllowed + i;
            PushUpNeeded := PushUpNeeded - i;

            if (PushUpNeeded <= 0) or (i < FreeGapAbove) then
              break;
            CurGroupWeight := CurGroupWeight + i * CurGroupCnt;
          end;

          PushNode := PushNodePrev;
        end; // while (PushNode <> nil) do begin

        if NInfo^.CurDrawPos - PushUpAllowed > AMaxDrawPos then // force pushup
          PushUpAllowed := NInfo^.CurDrawPos - AMaxDrawPos;

        if PushUpAllowed > 0 then begin
          WantedPos := NInfo^.CurDrawPos - PushUpAllowed;
          NInfo^.CurDrawPos := WantedPos;
          NInfo^.TheNode.DrawCenter := WantedPos;
          PushNode := NInfo;
          i := 0; // the current (first) node wants to move
          while (PushNode <> nil) and (PushNode^.TheNodeIdx > 0) do begin
            WantedPos := WantedPos - PushNode^.DrawPosGapAbove;
            PushNodePrev := @NodeInfos[ALvlIdx, PushNode^.TheNodeIdx-1];
            if PushNodePrev^.CurDrawPos <= WantedPos then
              break;
            PushNodePrev^.CurDrawPos := WantedPos;
            PushNodePrev^.TheNode.DrawCenter := WantedPos;
            PushNode := PushNodePrev;
          end;
        end;
      end

      else // if PushUpNeeded > 0 then begin
      if (NInfoPrev^.TmpDrawPos = DRAWPOS_UNKOWN) then begin
        // re-distribute nodes with unknown weight to avg between upper/lower
        // They depend on the nodes on the other side, but that is a cyclic dependecy....
        PushNode := NInfoPrev;
        CurGroupCnt := 1;
        while (PushNode <> nil) and (PushNode^.TmpDrawPos = DRAWPOS_UNKOWN) do begin
          PushNodePrev := PushNode; // node below
          inc(CurGroupCnt);
          if PushNode^.TheNodeIdx > 0 then
            PushNode := @NodeInfos[ALvlIdx, PushNode^.TheNodeIdx-1]
          else
            PushNode := nil;
        end;
        FreeGapAbove := 0;
        if PushNode <> nil then
          FreeGapAbove := NInfo^.CurDrawPos - NInfo^.DrawPosGapAbove - NInfoPrev^.CurDrawPos;
        PushNode := NInfoPrev;
        PushNodePrev := NInfo;
        while (PushNode <> nil) and (PushNode^.TmpDrawPos = DRAWPOS_UNKOWN) do begin
          i := FreeGapAbove div CurGroupCnt;
          WantedPos := PushNodePrev^.CurDrawPos - PushNodePrev^.DrawPosGapAbove - i;
          FreeGapAbove := FreeGapAbove - i;
          dec(CurGroupCnt);
          PushNode^.CurDrawPos := WantedPos;
          PushNode^.TheNode.DrawCenter := WantedPos;
          PushNodePrev := PushNode;
          if PushNode^.TheNodeIdx > 0 then
            PushNode := @NodeInfos[ALvlIdx, PushNode^.TheNodeIdx-1]
          else
            PushNode := nil;
        end;
      end;

      Node.DrawCenter := NInfo^.CurDrawPos;
      NInfoPrev:= NInfo;
    end;
  end;

  procedure ProcessSubGraph(ALowLevelIdx, AHighLevelIdx: integer);
  var
    MaxLevelCount, LvlIdx: integer;
    j, c, MaxDrawPos, MaxLvlIdx: integer;
    Node: TLvlGraphNode;
    Level: TLvlGraphLevel;
    NInfo, NInfoPrev: PNodeInfo;
  begin
    if AHighLevelIdx <= ALowLevelIdx then
      exit;
    MaxLvlIdx := -1;
    MaxLevelCount := 0;
    MaxDrawPos := 0;
    SetLength(NodeInfos, LevelCount);
    NInfoPrev := nil;
    for LvlIdx := ALowLevelIdx to AHighLevelIdx do begin
      Level := Levels[LvlIdx];
      if Level.Count > MaxLevelCount then
        MaxLevelCount := Level.Count;
      SetLength(NodeInfos[LvlIdx], Level.Count);
      c := Level.Count - 1;
      for j := 0 to c do begin
        Node := Level.Nodes[j];
        NInfo := @NodeInfos[LvlIdx,j];
        NInfo^.TheNode := Node;
        NInfo^.TheNodeIdx := j;
        NInfo^.TheLevelIdx := LvlIdx;
        NInfo^.CurDrawPos := Node.DrawCenter;
        if j = 0 then
          NInfo^.DrawPosGapAbove := NInfo^.CurDrawPos
        else
          NInfo^.DrawPosGapAbove := NInfo^.CurDrawPos - NInfoPrev^.CurDrawPos;
        NInfoPrev := NInfo;
      end;
      if (c > 0) and (Node.DrawCenter > MaxDrawPos) then begin
        MaxDrawPos := Node.DrawCenter;
        MaxLvlIdx := LvlIdx;
      end;
    end;
    if MaxLvlIdx < 0 then
      exit;


    for LvlIdx := MaxLvlIdx+1 to AHighLevelIdx do begin
      PreComputeWantedPositions(LvlIdx, 1, 0);
      AdjustNodesInLevel(LvlIdx, 0, MaxDrawPos);
    end;
    for LvlIdx := MaxLvlIdx-1 downto ALowLevelIdx do begin
      PreComputeWantedPositions(LvlIdx, 0, 1);
      AdjustNodesInLevel(LvlIdx, 0, MaxDrawPos);
    end;

    for j := 0 to 1 do begin
      for LvlIdx := ALowLevelIdx to AHighLevelIdx do begin
        PreComputeWantedPositions(LvlIdx, 1, 1);
        AdjustNodesInLevel(LvlIdx, 0, MaxDrawPos);
      end;
      for LvlIdx := AHighLevelIdx downto ALowLevelIdx do begin
        PreComputeWantedPositions(LvlIdx, 1, 1);
        AdjustNodesInLevel(LvlIdx, 0, MaxDrawPos);
      end;
    end;
  end;

var
  i: Integer;
begin
  For i := 0 to SubGraphCount-1 do
    ProcessSubGraph(SubGraphs[i].LowestLevel, SubGraphs[i].HighestLevel);
end;

procedure TLvlGraph.SetColors(Palette: TLazCtrlPalette);
var
  i: Integer;
begin
  for i:=0 to NodeCount-1 do
    Nodes[i].Color:=Palette[i];
end;

procedure TLvlGraph.WriteDebugReport(Msg: string);
var
  l: Integer;
  Level: TLvlGraphLevel;
  i: Integer;
  Node: TLvlGraphNode;
  Edge: TLvlGraphEdge;
  j: Integer;
begin
  debugln([Msg,' NodeCount=',NodeCount,' LevelCount=',LevelCount]);
  debugln(['  Nodes:']);
  for i:=0 to NodeCount-1 do begin
    Node:=Nodes[i];
    dbgout(['   ',i,'/',NodeCount,': "',Node.Caption,'" OutEdges:']);
    for j:=0 to Node.OutEdgeCount-1 do begin
      Edge:=Node.OutEdges[j];
      dbgout('"',Edge.Target.Caption,'",');
    end;
    debugln;
  end;
  debugln(['  Levels:']);
  for l:=0 to LevelCount-1 do begin
    dbgout(['   Level: ',l,'/',LevelCount]);
    Level:=Levels[l];
    if l<>Level.Index then
      debugln(['ERROR: l<>Level.Index=',Level.Index]);
    dbgout('  ');
    for i:=0 to Level.Count-1 do begin
      dbgout('"',Level.Nodes[i].Caption,'",');
    end;
    debugln;
  end;
end;

procedure TLvlGraph.ConsistencyCheck(WithBackEdge: boolean);
var
  i: Integer;
  Node: TLvlGraphNode;
  j: Integer;
  Edge: TLvlGraphEdge;
  Level: TLvlGraphLevel;
begin
  for i:=0 to LevelCount-1 do begin
    Level:=Levels[i];
    if Level.Index<>i then
      raise Exception.Create('');
    for j:=0 to Level.Count-1 do begin
      Node:=Level.Nodes[j];
      if Node.Level<>Level then
        raise Exception.Create('');
      if Level.IndexOf(Node)<j then
        raise Exception.Create('');
    end;
  end;
  for i:=0 to NodeCount-1 do begin
    Node:=Nodes[i];
    for j:=0 to Node.OutEdgeCount-1 do begin
      Edge:=Node.OutEdges[j];
      if Edge.Source<>Node then
        raise Exception.Create('');
      if Edge.Target.FInEdges.IndexOf(Edge)<0 then
        raise Exception.Create('');
      // An edge can EITHER be marked "BackEdge" or be "IsBackEdge" (aka target is before source).
      // An egge is not allowed ot be both.
      if WithBackEdge and Edge.BackEdge and Edge.IsBackEdge then
        raise Exception.Create('Edge.BackEdge '+Edge.AsString+' Edge.BackEdge='+dbgs(Edge.BackEdge)+' Edge.IsBackEdge='+dbgs(Edge.IsBackEdge)+' Source.Index='+dbgs(Edge.Source.Level.Index)+' Target.Index='+dbgs(Edge.Target.Level.Index));
    end;
    for j:=0 to Node.InEdgeCount-1 do begin
      Edge:=Node.InEdges[j];
      if Edge.Target<>Node then
        raise Exception.Create('');
      if Edge.Source.FOutEdges.IndexOf(Edge)<0 then
        raise Exception.Create('');
    end;
    if Node.Level.fNodes.IndexOf(Node)<0 then
      raise Exception.Create('');
  end;
end;

{ TLvlGraphEdge }

procedure TLvlGraphEdge.SetWeight(AValue: single);
var
  Diff: single;
begin
  if AValue<0.0 then AValue:=0.0;
  if FWeight=AValue then Exit;
  Diff:=AValue-FWeight;
  Source.FOutWeight+=Diff;
  Target.FInWeight+=Diff;
  FWeight:=AValue;
  Source.Invalidate;
end;

procedure TLvlGraphEdge.SetHighlighted(AValue: boolean);
begin
  if FHighlighted=AValue then Exit;
  FHighlighted:=AValue;
  Source.Invalidate;
end;

constructor TLvlGraphEdge.Create(TheSource: TLvlGraphNode;
  TheTarget: TLvlGraphNode);
begin
  FSource:=TheSource;
  FTarget:=TheTarget;
  Source.FOutEdges.Add(Self);
  Target.FInEdges.Add(Self);
end;

destructor TLvlGraphEdge.Destroy;
var
  OldGraph: TLvlGraph;
begin
  OldGraph:=Source.Graph;
  Source.FOutEdges.Remove(Self);
  Target.FInEdges.Remove(Self);
  Source.FOutWeight-=FWeight;
  Target.FInWeight-=FWeight;
  FSource:=nil;
  FTarget:=nil;
  if OldGraph<>nil then
    OldGraph.StructureChanged(Self,opRemove);
  inherited Destroy;
end;

function TLvlGraphEdge.IsBackEdge: boolean;
begin
  Result:=Source.Level.Index>=Target.Level.Index;
end;

procedure TLvlGraphEdge.RevertDirection;
var
  t: TLvlGraphNode;
begin
  Source.FOutEdges.Remove(Self);
  Target.FInEdges.Remove(Self);
  Source.FOutWeight-=FWeight;
  Target.FInWeight-=FWeight;

  t := FSource;
  FSource := FTarget;
  FTarget := t;

  Source.FOutEdges.Add(Self);
  Target.FInEdges.Add(Self);
  Source.FOutWeight+=FWeight;
  Target.FInWeight+=FWeight;
  FBackEdge := not FBackEdge;
end;

function TLvlGraphEdge.GetVisibleSourceNodes: TLvlGraphNodeArray;
// return all visible nodes connected in Source direction
begin
  Result:=NodeAVLTreeToNodeArray(GetVisibleSourceNodesAsAVLTree,true,true);
end;

function TLvlGraphEdge.GetVisibleSourceNodesAsAVLTree: TAvlTree;
// return all visible nodes connected in Source direction
var
  Visited: TAvlTree;

  procedure Search(Node: TLvlGraphNode);
  var
    i: Integer;
  begin
    if Node=nil then exit;
    if Visited.Find(Node)<>nil then exit;
    Visited.Add(Node);
    if Node.Visible then begin
      Result.Add(Node);
    end else begin
      for i:=0 to Node.InEdgeCount-1 do
        Search(Node.InEdges[i].Source);
    end;
  end;

begin
  if BackEdge then begin
    FBackEdge := False;
    Result := GetVisibleTargetNodesAsAVLTree;
    FBackEdge := True;
    exit;
  end;
  Result:=TAvlTree.Create;
  Visited:=TAvlTree.Create;
  try
    Search(Source);
  finally
    Visited.Free;
  end;
end;

function TLvlGraphEdge.GetVisibleTargetNodes: TLvlGraphNodeArray;
// return all visible nodes connected in Target direction
begin
  Result:=NodeAVLTreeToNodeArray(GetVisibleTargetNodesAsAVLTree,true,true);
end;

function TLvlGraphEdge.GetVisibleTargetNodesAsAVLTree: TAvlTree;
// return all visible nodes connected in Target direction
var
  Visited: TAvlTree;

  procedure Search(Node: TLvlGraphNode);
  var
    i: Integer;
  begin
    if Node=nil then exit;
    if Visited.Find(Node)<>nil then exit;
    Visited.Add(Node);
    if Node.Visible then begin
      Result.Add(Node);
    end else begin
      for i:=0 to Node.OutEdgeCount-1 do
        Search(Node.OutEdges[i].Target);
    end;
  end;

begin
  if BackEdge then begin
    FBackEdge := False;
    Result := GetVisibleSourceNodesAsAVLTree;
    FBackEdge := True;
    exit;
  end;
  Result:=TAvlTree.Create;
  Visited:=TAvlTree.Create;
  try
    Search(Target);
  finally
    Visited.Free;
  end;
end;

function TLvlGraphEdge.AsString: string;
begin
  Result:='('+Source.Caption+'->'+Target.Caption+')';
end;

{ TLvlGraphNode }

function TLvlGraphNode.InEdgeCount: integer;
begin
  Result:=FInEdges.Count;
end;

function TLvlGraphNode.GetInEdges(Index: integer): TLvlGraphEdge;
begin
  Result:=TLvlGraphEdge(FInEdges[Index]);
end;

function TLvlGraphNode.GetIndexInLevel: integer;
begin
  if Level=nil then exit(-1);
  Result:=Level.IndexOf(Self);
end;

function TLvlGraphNode.GetOutEdges(Index: integer): TLvlGraphEdge;
begin
  Result:=TLvlGraphEdge(FOutEdges[Index]);
end;

procedure TLvlGraphNode.SetCaption(AValue: string);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
  Invalidate;
end;

procedure TLvlGraphNode.SetColor(AValue: TFPColor);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  Invalidate;
end;

procedure TLvlGraphNode.OnLevelDestroy;
begin
  if Level.Index>0 then
    Level:=Graph.Levels[0]
  else if Graph.LevelCount>1 then
    Level:=Graph.Levels[1]
  else
    fLevel:=nil;
end;

procedure TLvlGraphNode.SetDrawCenter(AValue: integer);
begin
  DrawPosition := AValue-(DrawSize div 2);
end;

procedure TLvlGraphNode.SetDrawSize(AValue: integer);
begin
  if FDrawSize=AValue then Exit;
  FDrawSize:=AValue;
  Invalidate;
end;

procedure TLvlGraphNode.SetImageEffect(AValue: TGraphicsDrawEffect);
begin
  if FImageEffect=AValue then Exit;
  FImageEffect:=AValue;
  Invalidate;
end;

procedure TLvlGraphNode.SetImageIndex(AValue: integer);
begin
  if FImageIndex=AValue then Exit;
  FImageIndex:=AValue;
  Invalidate;
end;

procedure TLvlGraphNode.SetIndexInLevel(AValue: integer);
begin
  Level.MoveNode(Self,AValue);
end;

procedure TLvlGraphNode.SetLevel(AValue: TLvlGraphLevel);
begin
  if AValue=nil then
    raise Exception.Create('node needs a level');
  if AValue.Graph<>Graph then
    raise Exception.Create('wrong graph');
  if FLevel=AValue then Exit;
  if FLevel<>nil then
    UnbindLevel;
  FLevel:=AValue;
  FLevel.fNodes.Add(Self);
end;

procedure TLvlGraphNode.SetOverlayIndex(AValue: integer);
begin
  if FOverlayIndex=AValue then Exit;
  FOverlayIndex:=AValue;
  Invalidate;
end;

procedure TLvlGraphNode.SetSelected(AValue: boolean);

  procedure Unselect;
  begin
    if FPrevSelected<>nil then
      FPrevSelected.FNextSelected:=FNextSelected
    else
      Graph.FFirstSelected:=FNextSelected;
    if FNextSelected<>nil then
      FNextSelected.FPrevSelected:=FPrevSelected
    else
      Graph.FLastSelected:=FPrevSelected;
    FNextSelected:=nil;
    FPrevSelected:=nil;
  end;

  procedure Select;
  begin
    FPrevSelected:=Graph.LastSelected;
    if FPrevSelected<>nil then
      FPrevSelected.FNextSelected:=Self
    else
      Graph.FFirstSelected:=Self;
    Graph.FLastSelected:=Self;
  end;

begin
  if FSelected=AValue then begin
    if Graph=nil then exit;
    if not FSelected then exit;
    if Graph.LastSelected=Self then exit;
    // make this node the last selected
    Unselect;
    Select;
    SelectionChanged;
    exit;
  end;
  // change Selected
  FSelected:=AValue;
  if Graph<>nil then begin
    if Selected then begin
      Select;
    end else begin
      Unselect;
    end;
  end;
  SelectionChanged;
end;

procedure TLvlGraphNode.SetSubGraph(AValue: Integer);
begin
  if FSubGraph = AValue then Exit;
  if (AValue < 0) or (AValue >= FGraph.SubGraphCount) then
    raise Exception.Create('subgraph index out of range');

  FSubGraph := AValue;
end;

procedure TLvlGraphNode.SetVisible(AValue: boolean);
begin
  if FVisible=AValue then Exit;
  FVisible:=AValue;
  Invalidate;
end;

procedure TLvlGraphNode.UnbindLevel;
begin
  if FLevel<>nil then
    FLevel.fNodes.Remove(Self);
end;

procedure TLvlGraphNode.SelectionChanged;
begin
  if Graph<>nil then
    Graph.SelectionChanged;
end;

procedure TLvlGraphNode.Invalidate;
begin
  if Graph<>nil then
    Graph.Invalidate;
end;

constructor TLvlGraphNode.Create(TheGraph: TLvlGraph; TheCaption: string;
  TheLevel: TLvlGraphLevel);
begin
  FGraph:=TheGraph;
  FCaption:=TheCaption;
  FInEdges:=TFPList.Create;
  FOutEdges:=TFPList.Create;
  FDrawSize:=1;
  FVisible:=true;
  FImageIndex:=-1;
  FOverlayIndex:=-1;
  FImageEffect:=DefaultLvlGraphNodeImageEffect;
  Level:=TheLevel;
end;

destructor TLvlGraphNode.Destroy;
begin
  Selected:=false;
  Clear;
  UnbindLevel;
  if Graph<>nil then
    Graph.InternalRemoveNode(Self);
  FreeAndNil(FInEdges);
  FreeAndNil(FOutEdges);
  inherited Destroy;
end;

procedure TLvlGraphNode.Clear;
begin
  while InEdgeCount>0 do
    InEdges[InEdgeCount-1].Free;
  while OutEdgeCount>0 do
    OutEdges[OutEdgeCount-1].Free;
end;

function TLvlGraphNode.IndexOfInEdge(Source: TLvlGraphNode): integer;
begin
  for Result:=0 to InEdgeCount-1 do
    if InEdges[Result].Source=Source then exit;
  Result:=-1;
end;

function TLvlGraphNode.FindInEdge(Source: TLvlGraphNode): TLvlGraphEdge;
var
  i: Integer;
begin
  i:=IndexOfInEdge(Source);
  if i>=0 then
    Result:=InEdges[i]
  else
    Result:=nil;
end;

function TLvlGraphNode.IndexOfOutEdge(Target: TLvlGraphNode): integer;
begin
  for Result:=0 to OutEdgeCount-1 do
    if OutEdges[Result].Target=Target then exit;
  Result:=-1;
end;

function TLvlGraphNode.FindOutEdge(Target: TLvlGraphNode): TLvlGraphEdge;
var
  i: Integer;
begin
  i:=IndexOfOutEdge(Target);
  if i>=0 then
    Result:=OutEdges[i]
  else
    Result:=nil;
end;

function TLvlGraphNode.OutEdgeCount: integer;
begin
  Result:=FOutEdges.Count;
end;

function TLvlGraphNode.GetVisibleSourceNodes: TLvlGraphNodeArray;
// return all visible nodes connected in Source direction
begin
  Result:=NodeAVLTreeToNodeArray(GetVisibleSourceNodesAsAVLTree,true,true);
end;

procedure SearchForTargets(Node: TLvlGraphNode; AResult, Visited: TAvlTree);
var
  i: Integer;
begin
  if Node=nil then exit;
  if Visited.Find(Node)<>nil then exit;
  Visited.Add(Node);
  if Node.Visible then begin
    AResult.Add(Node);
  end else begin
    for i:=0 to Node.OutEdgeCount-1 do
      SearchForTargets(Node.OutEdges[i].Target, AResult, Visited);
  end;
end;

procedure SearchForSources(Node: TLvlGraphNode; AResult: TAvlTree);
var
  i: Integer;
begin
  if Node=nil then exit;
  if Node.Visible then begin
    AResult.Add(Node);
  end else begin
    for i:=0 to Node.InEdgeCount-1 do
      SearchForSources(Node.InEdges[i].Source, AResult);
  end;
end;

function TLvlGraphNode.GetVisibleSourceNodesAsAVLTree: TAvlTree;
// return all visible nodes connected in Source direction
var
  i: Integer;
  Visited: TAvlTree;
begin
  Result:=TAvlTree.Create;
  Visited:=TAvlTree.Create;
  try
    for i:=0 to InEdgeCount-1 do
      if not InEdges[i].BackEdge then
        SearchForSources(InEdges[i].Source, Result);
    for i:=0 to OutEdgeCount-1 do
      if OutEdges[i].BackEdge then
        SearchForTargets(OutEdges[i].Target, Result, Visited);
  finally
    Visited.Free;
  end;
end;

function TLvlGraphNode.GetVisibleTargetNodes: TLvlGraphNodeArray;
// return all visible nodes connected in Target direction
begin
  Result:=NodeAVLTreeToNodeArray(GetVisibleTargetNodesAsAVLTree,true,true);
end;

function TLvlGraphNode.GetVisibleTargetNodesAsAVLTree: TAvlTree;
// return all visible nodes connected in Target direction
var
  Visited: TAvlTree;
  i: Integer;
begin
  Result:=TAvlTree.Create;
  Visited:=TAvlTree.Create;
  try
    for i:=0 to OutEdgeCount-1 do
      if not OutEdges[i].BackEdge then
        SearchForTargets(OutEdges[i].Target, Result, Visited);
    for i:=0 to InEdgeCount-1 do
      if InEdges[i].BackEdge then
        SearchForSources(InEdges[i].Source, Result);
  finally
    Visited.Free;
  end;
end;

function TLvlGraphNode.GetDrawCenter: integer;
begin
  Result:=DrawPosition+(DrawSize div 2);
end;

function TLvlGraphNode.DrawPositionEnd: integer;
begin
  Result:=DrawPosition+DrawSize;
end;

end.

