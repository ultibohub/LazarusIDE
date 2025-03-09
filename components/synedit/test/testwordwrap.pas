unit TestWordWrap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, TestBase, SynEditViewedLineMap, SynEditMiscClasses,
  SynEditTypes, SynEditWrappedView,
  LazSynEditText, SynEditHighlighterFoldBase, LazLoggerBase,
  SynEditKeyCmds, SynEdit, SynEditPointClasses, testregistry;

type
  TIntArray = Array of integer;

  { TTestSynLineMapAVLTree }

  TTestSynLineMapAVLTree = class(TSynLineMapAVLTree)
    function FindPageForLine(ALineIdx: IntIdx; AMode: TSynSizedDiffAVLFindMode = afmPrev
      ): TSynEditLineMapPageHolder;
  end;

  { TExpWraps }

  TExpWraps = object
    w: Array of Integer;
    len: Integer;
    function Init(const a: array of integer): TExpWraps;
    procedure SetCapacity(l: Integer);
    procedure InitFill(AFrom, ATo: integer; AIncrease: Integer = 1);
    procedure FillRange(AStartIdx, ACount, AFromVal: integer; AIncrease: Integer = 1);
    procedure Join(const a: TExpWraps; AInsertPos: Integer = -1);
    procedure Join(const a: array of integer; AInsertPos: Integer = -1);
    procedure SpliceArray(ADelFrom, ADelCount: integer);
  end;

  { TTestWordWrapBase }

  TTestWordWrapBase = class(TTestBase)
  protected
    function TheTree: TSynLineMapAVLTree; virtual; abstract;
    function  TreeNodeCount: integer;
    procedure CheckTree(AName: String); virtual;
    procedure CheckTree(AName: String; ANode: TSynEditLineMapPage; ANodeLine: TLineIdx; AMinLine, AMaxLine: TLineIdx);

  end;

  TTestSynEditLineWrapPlugin = class(TLazSynEditLineWrapPlugin)
  public
    property LineMapView;
    property LineMappingData;
  end;

  { TTestWordWrap }

  TTestWordWrap = class(TTestWordWrapBase)
  private
    FTree: TTestSynLineMapAVLTree;
    procedure AssertRealToWrapOffsets(const AName: String; ALine: TSynWordWrapLineMap;
      const ExpWrapOffsets: TExpWraps; AStartOffs: Integer = 0);
    procedure AssertWrapToRealOffset(const AName: String; ALine: TSynWordWrapLineMap;
      const ExpRealAndSubOffsets: TExpWraps; AStartOffs: Integer = 0);
    procedure AssertLineForWraps(const AName: String; ALine: TSynWordWrapLineMap;
      const ExpWrapForEachLine: TExpWraps; AnExpAllValid: Boolean = False);
    procedure InitLine(ALine: TSynWordWrapLineMap;
      const AWrapValues: TExpWraps);
    procedure ValidateWraps(ALine: TSynWordWrapLineMap;
      const AWrapValues: TExpWraps; AStartOffs: Integer = 0; ABackward: Boolean = False);
    procedure ValidateNeededWraps(ALine: TSynWordWrapLineMap; const AWrapValues: TExpWraps);

    procedure ValidateTreeWraps(const AWrapValues: TExpWraps; AStartOffs: Integer = 0);
    procedure AssertTreeForWraps(const AName: String; const ExpWrapForEachLine: TExpWraps; AStartOffs: Integer = 0);

    function CreateTree(APageJoinSize, APageSplitSize, APageJoinDistance: Integer): TTestSynLineMapAVLTree;
  protected
    function TheTree: TSynLineMapAVLTree; override;

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestWordWrapLineMap;
    procedure TestWordWrapLineMapInvalidate;
    procedure TestWordWrapLineMapInvalidateNoneContineous;
    procedure TestWordWrapLineMapValidate;
    procedure TestWordWrapLineMapMerge;
    procedure TestWordWrapLineMapMergeInvalidate;
    procedure TestWordWrapJoinWithSibling;

    procedure TestWordWrapTreeInsertThenDelete;
    procedure TestWordWrapTreeDeleteThenInsert;
  end;

  TPointType = (ptViewed, ptPhys, ptLog);

  TPointSpecs = record
    XY: array [TPointType] of TPoint;
    LogOffs: Integer;
  end;

  TCommandAndPointSpecs = record
    Exp: TPointSpecs;
    Cmd: Array of TSynEditorCommand;
    RunOnlyIf: Boolean;
  end;

  TTestWrapLineInfo = record
    TextIdx: TLineIdx;
    ViewedIdx, ViewedTopIdx, ViewedBottomIdx: TLineIdx;
    SubIdx: Integer;
    //FirstLogX: Integer;
    TextStartMatch: String;
    NoTrim: Boolean;
  end;
  TTestViewedLineRangeInfo = array of TTestWrapLineInfo;

  TTripleBool = (tTrue, tFalse, tKeep);

function l(ATxtIdx: TLineIdx; ASubIdx: Integer; AText: String; ANoTrim: Boolean = False): TTestWrapLineInfo;
function ViewedExp(AFirstViewedIdx: TLineIdx; ALines:
  array of TTestWrapLineInfo; ANoTrim: TTripleBool = tKeep): TTestViewedLineRangeInfo;

type

  { TTestWordWrapPluginBase }

  TTestWordWrapPluginBase = class(TTestWordWrapBase)
  private
    procedure ClearCaret;
    function GetTreeNodeHolder(AIndex: Integer): TSynEditLineMapPageHolder;
    procedure SetCaret(SourcePt: TPointType; APos: TPoint);
    procedure TestCaret(AName: String; SourcePt, ExpPt: TPointType; AnExp: TPoint;
      AnExpOffs: Integer = -1);
  protected
    FWordWrap: TTestSynEditLineWrapPlugin;
    class procedure AssertEquals(const AMessage: string; Expected, Actual: TPoint); overload;
    procedure AddLines(AFirstLineIdx, ACount, ALen: Integer; AnID: String; SkipBeginUpdate: Boolean = False; AReplaceExisting: Boolean = False);
    procedure InternalCheckLine(AName: String; dsp: TLazSynDisplayView; ALine: TLineIdx; AExpTextStart: String; NoTrim: Boolean = False);
    procedure CheckLine(AName: String; ALine: TLineIdx; AExpTextStart: String; NoTrim: Boolean = False);
    procedure CheckLines(AName: String; AStartLine: TLineIdx; AExpTextStart: array of String; NoTrim: Boolean = False);

    procedure CheckLine(AName: String; AExpLine: TTestWrapLineInfo);
    procedure CheckLines(AName: String; AExpLines: TTestViewedLineRangeInfo);

    procedure CheckXyMap(AName: String; APhysTExtXY, AViewedXY: TPoint; OnlyViewToText: Boolean = False);
    procedure CheckXyMap(AName: String; APhysTExtX, APhysTExtY, AViewedX, AViewedY: integer; OnlyViewToText: Boolean = False);

    procedure CheckXyMap(AName: String; APoints: TPointSpecs);
    procedure CheckXyMap(AName: String; APoints: TPointSpecs;
      ATestCommands: array of TCommandAndPointSpecs);

    procedure CheckLineIndexMapping(AName: String; ATextIdx, AViewTopIdx, AViewBottomIdx: TLineIdx);

    function TheTree: TSynLineMapAVLTree; override;
    property TreeNodeHolder[AIndex: Integer]: TSynEditLineMapPageHolder read GetTreeNodeHolder;

    procedure ReCreateEdit(ADispWidth: Integer);
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TTestWordWrapPlugin = class(TTestWordWrapPluginBase)
  published
    procedure TestEditorWrap;
    procedure TestWrapSplitJoin;
    procedure TestEditorEdit;
  end;

implementation

function p(VX, VY,  PX, PY,  LX, LY: Integer; Offs: Integer = -1): TPointSpecs; overload;
begin
  with Result do begin
    XY[ptViewed].X          := VX;
    XY[ptViewed].Y          := VY;
    XY[ptPhys].X            := PX;
    XY[ptPhys].Y            := PY;
    XY[ptLog].X             := LX;
    XY[ptLog].Y             := LY;
    LogOffs                 := Offs;
  end;
end;

function c(Cmd: Array of TSynEditorCommand; VX, VY,  PX, PY,  LX, LY: Integer; Offs: Integer = -1; RunOnlyIf: Boolean = True): TCommandAndPointSpecs; overload;
begin
  Result.Exp := p(VX, VY, PX, PY, LX, LY, Offs);
  SetLength(Result.Cmd, Length(Cmd));
  move(Cmd[0], Result.Cmd[0], SizeOf(cmd[0]) * Length(Cmd));
  Result.RunOnlyIf := RunOnlyIf;
end;

function c(Cmd: TSynEditorCommand; VX, VY,  PX, PY,  LX, LY: Integer; Offs: Integer = -1; RunOnlyIf: Boolean = True): TCommandAndPointSpecs; overload;
begin
  Result := c([Cmd], VX, VY, PX, PY, LX, LY, Offs, RunOnlyIf);
end;

function FillArray(AFrom, ATo: integer; AIncrease: Integer = 1): TIntArray;
var
  i: Integer;
begin
  SetLength(Result{%H-}, ATo - AFrom + 1);
  for i := 0 to high(Result) do
    Result[i] := AFrom + i * AIncrease;
end;

function l(ATxtIdx: TLineIdx; ASubIdx: Integer; AText: String; ANoTrim: Boolean
  ): TTestWrapLineInfo;
begin
  Result.TextIdx := ATxtIdx;
  Result.SubIdx  := ASubIdx;
  Result.TextStartMatch := AText;
  Result.NoTrim  := ANoTrim;
end;

function ViewedExp(AFirstViewedIdx: TLineIdx;
  ALines: array of TTestWrapLineInfo; ANoTrim: TTripleBool
  ): TTestViewedLineRangeInfo;
var
  i, j: Integer;
begin
  SetLength(Result{%H-}, Length(ALines));
  j := 0;
  for i := 0 to Length(ALines) - 1 do begin
    if (i > 0) and (ALines[i].SubIdx = 0) then begin
      while j < i do begin
        Result[j].ViewedBottomIdx := AFirstViewedIdx - 1;
        inc(j);
      end;
      j := i;
    end;
    Result[i] := ALines[i];
    Result[i].ViewedIdx    := AFirstViewedIdx;
    Result[i].ViewedTopIdx := AFirstViewedIdx - Result[i].SubIdx;
    case ANoTrim of
      tFalse: Result[i].NoTrim := False;
      tTrue:  Result[i].NoTrim := True;
    end;
    inc(AFirstViewedIdx);
  end;
  while j < Length(ALines) do begin
    Result[j].ViewedBottomIdx := AFirstViewedIdx - 1;
    inc(j);
  end;
end;

{ TTestWordWrapBase }

function TTestWordWrapBase.TreeNodeCount: integer;
var
  n: TSynEditLineMapPageHolder;
begin
  Result := 0;
  n := TheTree.FirstPage;
  while n.HasPage do begin
    inc(Result);
    n := n.Next;
  end;
end;

procedure TTestWordWrapBase.CheckTree(AName: String);
var
  n: TSynEditLineMapPageHolder;
begin
  if TheTree = nil then
    AssertTrue(AName, False);
  n := TheTree.FirstPage;
  if n.HasPage then
    CheckTree(AName, n.Page, n.StartLine, 0, MaxInt);
end;

procedure TTestWordWrapBase.CheckTree(AName: String;
  ANode: TSynEditLineMapPage; ANodeLine: TLineIdx; AMinLine, AMaxLine: TLineIdx
  );
var
  n: TSynEditLineMapPage;
  dummy, i, EndLine: Integer;
  nl: TLineIdx;
begin
  nl := ANodeLine;
  n := ANode.Precessor(nl, dummy);
  while n <> nil do begin
    ANode := n;
    ANodeLine := nl;
    n := ANode.Precessor(nl, dummy);
  end;

  i := 0;
  while ANode <> nil do begin
    AssertTrue(Format('%s(%d): MinLine', [AName, i]), ANodeLine >= AMinLine);
    EndLine := ANodeLine + Max(0, ANode.RealEndLine);
    AssertTrue(Format('%s(%d): EndLine', [AName, i]), EndLine <= AMaxLine);

    AMinLine := EndLine + 1;
    ANode := ANode.Successor(ANodeLine, dummy);
    inc(i);
  end;
end;

{ TTestSynLineMapAVLTree }

function TTestSynLineMapAVLTree.FindPageForLine(ALineIdx: IntIdx; AMode: TSynSizedDiffAVLFindMode
  ): TSynEditLineMapPageHolder;
begin
  Result := inherited FindPageForLine(ALineIdx, AMode);
end;

{ TExpWraps }

function TExpWraps.Init(const a: array of integer): TExpWraps;
begin
  len := Length(a);
  if len > 0 then begin
    SetCapacity(len);
    move(a[0], w[0], SizeOf(w[0]) * len);
  end;
  Result := self;
end;

procedure TExpWraps.SetCapacity(l: Integer);
begin
  if Length(w) < l then
    SetLength(w, l*2);
end;

procedure TExpWraps.InitFill(AFrom, ATo: integer; AIncrease: Integer);
var
  p: PLongInt;
  i: Integer;
begin
  len := ATo - AFrom + 1;
  SetCapacity(len);
  p := @w[0];
  for i := 0 to len - 1 do begin
    p^ := AFrom;
    inc(p);
    inc(AFrom, AIncrease);
  end;
end;

procedure TExpWraps.FillRange(AStartIdx, ACount, AFromVal: integer;
  AIncrease: Integer);
var
  p: PLongInt;
  i: Integer;
begin
  if len < AStartIdx + ACount then
    len := AStartIdx + ACount;
  SetCapacity(len);

  p := @w[AStartIdx];
  for i := 0 to ACount - 1 do begin
    p^ := AFromVal;
    inc(p);
    inc(AFromVal, AIncrease);
  end;

end;

procedure TExpWraps.Join(const a: TExpWraps; AInsertPos: Integer);
var
  i, old: Integer;
begin
  if AInsertPos < 0 then
    AInsertPos := Len;

  i := (Len-AInsertPos);
  old := len;
  len := len + a.len;
  if i < 0 then
    len := len - i;
  SetCapacity(len);

  if i > 0 then begin
    move(w[AInsertPos], w[AInsertPos+a.len], sizeof(w[0]) * i);
  end
  else
  if i < 0 then begin
    FillDWord(w[old], -i, 1);
  end;
  move(a.w[0], w[AInsertPos], sizeof(w[0]) * a.len);
end;

procedure TExpWraps.Join(const a: array of integer; AInsertPos: Integer);
var
  i, la, old: Integer;
begin
  if AInsertPos < 0 then
    AInsertPos := Len;

  i := (Len-AInsertPos);
  la := Length(a);
  old := len;
  len := len + la;
  if i < 0 then
    len := len - i;
  SetCapacity(len);

  if i > 0 then begin
    move(w[AInsertPos], w[AInsertPos+la], sizeof(w[0]) * i);
  end
  else
  if i < 0 then begin
    FillDWord(w[old], -i, 1);
  end;
  move(a[0], w[AInsertPos], sizeof(w[0]) * la);
end;

procedure TExpWraps.SpliceArray(ADelFrom, ADelCount: integer);
var
  i: Integer;
begin
  len := len - ADelCount;

  i := Length(w) - ADelFrom - ADelCount;
  if i > 0 then
    move(w[ADelFrom+ADelCount], w[ADelFrom], sizeof(w[0]) * (i));
end;

{ TTestWordWrap }

procedure TTestWordWrap.AssertRealToWrapOffsets(const AName: String;
  ALine: TSynWordWrapLineMap; const ExpWrapOffsets: TExpWraps;
  AStartOffs: Integer);
var
  i: Integer;
begin
  for i := 0 to ExpWrapOffsets.len - 1 do
    AssertEquals(format('%s: RealToWrap Idx %d StartOffs: %d ', [AName, i, AStartOffs]),
      ExpWrapOffsets.w[i], ALine.WrappedOffsetFor[AStartOffs + i]);
end;

procedure TTestWordWrap.AssertWrapToRealOffset(const AName: String;
  ALine: TSynWordWrapLineMap; const ExpRealAndSubOffsets: TExpWraps;
  AStartOffs: Integer);
var
  i, sub, r: Integer;
begin
  for i := 0 to ExpRealAndSubOffsets.len div 2 - 1 do begin
    r := ALine.GetOffsetForWrap(AStartOffs + i, sub);
    AssertEquals(format('%s: WrapToReal Idx %d StartOffs: %d ', [AName, i, AStartOffs]),
      ExpRealAndSubOffsets.w[i*2], r);
    AssertEquals(format('%s: WrapToReal(SUB) Idx %d StartOffs: %d ', [AName, i, AStartOffs]),
      ExpRealAndSubOffsets.w[i*2+1], sub);
  end;
end;

procedure TTestWordWrap.AssertLineForWraps(const AName: String;
  ALine: TSynWordWrapLineMap; const ExpWrapForEachLine: TExpWraps;
  AnExpAllValid: Boolean);
var
  i, j, ExpWrap, TestWrapToReal, GotReal, sub: Integer;
begin
  if AnExpAllValid then
    AssertTrue(AName + ' - all lines valid', ALine.FirstInvalidLine < 0);
  i := 0;
  while (i < ExpWrapForEachLine.len) and (ExpWrapForEachLine.w[i] = 1) do
    inc(i);
  if i = ExpWrapForEachLine.len then
    i := 0;
  AssertEquals(Format('%s: Offset', [AName]), i, ALine.Offset);

  j := ExpWrapForEachLine.len - 1;
  while (j >= 0) and (ExpWrapForEachLine.w[j] = 1) do
    dec(j);
  AssertEquals(Format('%s: RealCount', [AName]), j + 1 - i, ALine.RealCount);

  ExpWrap := 0;
  TestWrapToReal := 0;
  for i := 0 to ExpWrapForEachLine.len - 1 do begin
    AssertEquals(Format('%s: RealToWrap Idx %d', [AName, i]), ExpWrap, ALine.WrappedOffsetFor[i]);
    ExpWrap := ExpWrap + ExpWrapForEachLine.w[i];

    for j := 0 to ExpWrapForEachLine.w[i] - 1 do begin
      GotReal := ALine.GetOffsetForWrap(TestWrapToReal, sub);
      AssertEquals(Format('%s: WrapToReal Idx %d', [AName, TestWrapToReal]), i, GotReal);
      AssertEquals(Format('%s: WrapToReal Idx %d SUB', [AName, TestWrapToReal]), j, sub);
      inc(TestWrapToReal);
    end;
  end;

  CheckTree(AName+'TreeCheck');
end;

procedure TTestWordWrap.InitLine(ALine: TSynWordWrapLineMap;
  const AWrapValues: TExpWraps);
begin
  ALine.DeleteLinesAtOffset(0, max(ALine.RealCount + ALine.Offset, ALine.LastInvalidLine+1));
  if AWrapValues.len > 0 then begin
    ALine.InsertLinesAtOffset(0, AWrapValues.len);
    ValidateWraps(ALine, AWrapValues);
  end;
  AssertEquals('all valid', -1, ALine.FirstInvalidLine);
end;

procedure TTestWordWrap.ValidateWraps(ALine: TSynWordWrapLineMap;
  const AWrapValues: TExpWraps; AStartOffs: Integer; ABackward: Boolean);
var
  i: Integer;
begin
  if ABackward then begin
    for i := AWrapValues.len - 1 downto 0 do
      ALine.ValidateLine(AStartOffs + i, AWrapValues.w[i]);
  end
  else begin
    for i := 0 to AWrapValues.len - 1 do
      ALine.ValidateLine(AStartOffs + i, AWrapValues.w[i]);
  end;
  ALine.EndValidate;
end;

procedure TTestWordWrap.ValidateNeededWraps(ALine: TSynWordWrapLineMap;
  const AWrapValues: TExpWraps);
var
  i: Integer;
begin
  i := ALine.FirstInvalidLine;
  while i >= 0 do begin
    ALine.ValidateLine(i, AWrapValues.w[i]);
    i := ALine.FirstInvalidLine;
  end;
  ALine.EndValidate;
end;

procedure TTestWordWrap.ValidateTreeWraps(const AWrapValues: TExpWraps;
  AStartOffs: Integer);
var
  i: Integer;
  LowLine, HighLine: TLineIdx;
begin
  while FTree.NextBlockForValidation(LowLine, HighLine) do begin
    for i := LowLine to HighLine do begin
      AssertTrue(i-AStartOffs < AWrapValues.len);
      FTree.ValidateLine(i, AWrapValues.w[i-AStartOffs]);
    end;
  end;
  FTree.EndValidate;
end;

procedure TTestWordWrap.AssertTreeForWraps(const AName: String;
  const ExpWrapForEachLine: TExpWraps; AStartOffs: Integer);
var
  i, w: Integer;
  sub: TLineIdx;
begin
  w := AStartOffs;
  for i := 0 to (ExpWrapForEachLine.len - 1) do begin
    AssertEquals(Format('%s // l=%d getWrap', [AName, i]),
      w,
      FTree.GetWrapLineForForText(AStartOffs + i)
    );
    w := w + ExpWrapForEachLine.w[i];
    AssertEquals(Format('%s // l=%d getLine', [AName, i]),
      i,
      FTree.GetLineForForWrap(w-1, sub)
    );
    AssertEquals(Format('%s // l=%d sub', [AName, i]),
      ExpWrapForEachLine.w[i]-1,
      sub
    );
  end;

  CheckTree(AName+'TreeCheck');
end;

function TTestWordWrap.CreateTree(APageJoinSize, APageSplitSize,
  APageJoinDistance: Integer): TTestSynLineMapAVLTree;
begin
  Result := TTestSynLineMapAVLTree.Create(APageJoinSize, APageSplitSize, APageJoinDistance);
end;

function TTestWordWrap.TheTree: TSynLineMapAVLTree;
begin
  Result := FTree;
end;

procedure TTestWordWrap.SetUp;
begin
  FTree := CreateTree(15, 60, 20);
  inherited SetUp;
end;

procedure TTestWordWrap.TearDown;
begin
  inherited TearDown;
  FTree.Free;
end;

procedure TTestWordWrap.TestWordWrapLineMap;
var
  ALine: TSynWordWrapLineMap;
  ANode: TSynEditLineMapPage;
  i: Integer;
  ATestName: String;
  w: TExpWraps;
begin
  ANode := FTree.FindPageForLine(0, afmCreate).Page;
  ALine := ANode.SynWordWrapLineMapStore;
  ALine.InsertLinesAtOffset(0, 5);
  ALine.InvalidateLines(2,3);
  ValidateWraps(ALine, w.init([1, 1, 3, 3, 1]));
  AssertLineForWraps('', ALine, w.init([1, 1, 3, 3, 1,   1,1]));
  //AssertRealToWrapOffsets('', ALine, [0, 1, 2, 5, 8, 9, 10]);
  //AssertWrapToRealOffset('', ALine, [0,0,  1,0,  2,0, 2,1, 2,2,  3,0, 3,1, 3,2,  4,0,  5,0]);
  AssertEquals('all valid', -1, ALine.FirstInvalidLine);

  for i := 1 to 2 do begin

    // insert into offset
    ATestName := 'Insert at start of "Offset"';
    ALine.InsertLinesAtOffset(0, 2);
    ValidateWraps(ALine, w.init([2, 2]), 0, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([2, 2,   1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(0, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Insert at middle of "Offset"';
    ALine.InsertLinesAtOffset(1, 2);
    ValidateWraps(ALine, w.init([2, 2]), 1, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1,   2, 2,   1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(1, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Insert at end of "Offset"';
    ALine.InsertLinesAtOffset(2, 2);
    ValidateWraps(ALine, w.init([2, 2]), 2, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1,   2, 2,   3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(2, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);



    ATestName := 'Insert at start of "Offset" - single lines';
    ALine.InsertLinesAtOffset(0, 2);
    ValidateWraps(ALine, w.init([1, 1]), 0, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1,   1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(0, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Insert at middle of "Offset" - single lines';
    ALine.InsertLinesAtOffset(1, 2);
    ValidateWraps(ALine, w.init([1, 1]), 1, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1,   1, 1,   1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(1, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Insert at end of "Offset" - single lines';
    ALine.InsertLinesAtOffset(2, 2);
    ValidateWraps(ALine, w.init([1, 1]), 2, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1,   1, 1,   3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(2, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);



    ATestName := 'Insert at start of "Offset" - single/wrap lines';
    ALine.InsertLinesAtOffset(0, 2);
    ValidateWraps(ALine, w.init([1, 2]), 0, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 2,   1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(1, 1);
    AssertLineForWraps(ATestName, ALine, w.init([1,   1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);
    ALine.DeleteLinesAtOffset(0, 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Delete mixed offset/data';
    ALine.DeleteLinesAtOffset(1, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1,    3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.InsertLinesAtOffset(1, 2);
    ValidateWraps(ALine, w.init([1, 3]), 1, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    // insert into data
    ATestName := 'Insert at middle of Data';
    ALine.InsertLinesAtOffset(3, 2);
    ValidateWraps(ALine, w.init([2, 2]), 3, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3,   2, 2,   3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(3, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);



    ATestName := 'Insert at middle of Data';
    ALine.InsertLinesAtOffset(3, 2);
    ValidateWraps(ALine, w.init([2, 2]), 3, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3,   2, 2,   3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(3, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);



    // insert after data
    ATestName := 'Insert at end of Data';
    ALine.InsertLinesAtOffset(5, 1);
    ValidateWraps(ALine, w.init([4]), 5, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   4,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(5, 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Insert at end of Data - single line';
    ALine.InsertLinesAtOffset(5, 1);
    ValidateWraps(ALine, w.init([1]), 5, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(5, 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Insert behind end of Data';
    ALine.InsertLinesAtOffset(6, 1);
    ValidateWraps(ALine, w.init([4]), 6, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1, 4,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(6, 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Insert behind end of Data - single line';
    ALine.InsertLinesAtOffset(6, 1);
    ValidateWraps(ALine, w.init([1]), 6, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.DeleteLinesAtOffset(6, 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);


    ATestName := 'Delete mixed data/after';
    ALine.DeleteLinesAtOffset(3, 2);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3,    1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

    ALine.InsertLinesAtOffset(3, 2);
    ValidateWraps(ALine, w.init([3, 1]), 3, i mod 1 = 1);
    AssertLineForWraps(ATestName, ALine, w.init([1, 1, 3, 3, 1,   1,1]));
    AssertEquals('all valid', -1, ALine.FirstInvalidLine);

  end;

  ALine.InvalidateLines(0, 4);
  ValidateWraps(ALine, w.init([1,1,1,1,1]), 0, False);
  AssertLineForWraps('', ALine, w.init([1, 1, 1, 1, 1,   1,1]));
  AssertEquals('all valid', -1, ALine.FirstInvalidLine);

  ALine.InsertLinesAtOffset(0, 5);
  ValidateWraps(ALine, w.init([1, 1, 3, 3, 1]));
  AssertLineForWraps('', ALine, w.init([1, 1, 3, 3, 1,   1,1]));
  AssertEquals('all valid', -1, ALine.FirstInvalidLine);

  ALine.InvalidateLines(0, 4);
  ValidateWraps(ALine, w.init([1,1,1,1,1]), 0, True);
  AssertLineForWraps('', ALine, w.init([1, 1, 1, 1, 1,   1,1]));
  AssertEquals('all valid', -1, ALine.FirstInvalidLine);

end;

procedure TTestWordWrap.TestWordWrapLineMapInvalidate;
var
  ANode1: TSynEditLineMapPage;
  ALine1: TSynWordWrapLineMap;
  //ATestName: String;
  w: TExpWraps;
begin
  // invalidate and insert/remove lines
  ANode1 := FTree.FindPageForLine(0, afmCreate).Page;
  ALine1 := ANode1.SynWordWrapLineMapStore;

  InitLine(ALine1, w.init([1]));
  ALine1.InvalidateLines(3,6);
  AssertEquals('invalid', 3, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 6, ALine1.LastInvalidLine);

  ALine1.DeleteLinesAtOffset(6,2);
  AssertEquals('invalid', 3, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 5, ALine1.LastInvalidLine);

  ALine1.InsertLinesAtOffset(2,1);
  AssertEquals('invalid', 2, ALine1.FirstInvalidLine);
  ValidateWraps(ALine1, w.init([1]), 2);

  AssertEquals('invalid', 4, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 6, ALine1.LastInvalidLine);

  ALine1.InsertLinesAtOffset(5,1);
  AssertEquals('invalid', 4, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 7, ALine1.LastInvalidLine);

  ALine1.DeleteLinesAtOffset(4,1);
  AssertEquals('invalid', 4, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 6, ALine1.LastInvalidLine);

end;

procedure TTestWordWrap.TestWordWrapLineMapInvalidateNoneContineous;
var
  ANode1: TSynEditLineMapPage;
  ALine1: TSynWordWrapLineMap;
  //ATestName: String;
  w: TExpWraps;
begin
  // invalidate and insert/remove lines
  ANode1 := FTree.FindPageForLine(0, afmCreate).Page;
  ALine1 := ANode1.SynWordWrapLineMapStore;

  InitLine(ALine1, w.init([1]));
  ALine1.InvalidateLines(30,31);
  ALine1.InvalidateLines(32,35);
  ALine1.InvalidateLines(40,41);
  ALine1.InvalidateLines(10,11);
  ALine1.InvalidateLines(20,21);
  ALine1.InvalidateLines(22,23);

  AssertEquals('invalid first from', 10, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   11, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       41, ALine1.LastInvalidLine);

  ALine1.ValidateLine(10, 1);
  AssertEquals('invalid first from', 11, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   11, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       41, ALine1.LastInvalidLine);

  ALine1.ValidateLine(11, 1);
  AssertEquals('invalid first from', 20, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   23, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       41, ALine1.LastInvalidLine);

  ALine1.ValidateLine(20, 1);
  AssertEquals('invalid first from', 21, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   23, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       41, ALine1.LastInvalidLine);

  ALine1.ValidateLine(21, 1);
  ALine1.ValidateLine(22, 1);
  ALine1.ValidateLine(23, 1);
  AssertEquals('invalid first from', 30, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   35, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       41, ALine1.LastInvalidLine);

  ALine1.ValidateLine(30, 1);
  ALine1.ValidateLine(31, 1);
  ALine1.ValidateLine(32, 1);
  ALine1.ValidateLine(33, 1);
  ALine1.ValidateLine(34, 1);
  ALine1.ValidateLine(35, 1);
  AssertEquals('invalid first from', 40, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   41, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       41, ALine1.LastInvalidLine);

  ALine1.ValidateLine(40, 1);
  AssertEquals('invalid first from', 41, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   41, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       41, ALine1.LastInvalidLine);

  ALine1.ValidateLine(41, 1);
  AssertEquals('invalid first from', -1, ALine1.FirstInvalidLine);
  AssertEquals('invalid first to',   -1, ALine1.FirstInvalidEndLine);
  AssertEquals('invalid last',       -1, ALine1.LastInvalidLine);

end;

procedure TTestWordWrap.TestWordWrapLineMapValidate;
var
  ANode1: TSynEditLineMapPage;
  ALine1: TSynWordWrapLineMap;
  ATestName: String;
  w: TExpWraps;
  i: Integer;
begin
  // invalidate/ re-validate => increase/decrease offset/tail by switching between wrap and one-line lines
  ANode1 := FTree.FindPageForLine(0, afmCreate).Page;
  ALine1 := ANode1.SynWordWrapLineMapStore;

  ATestName := 'fill one-lines at start - increasing';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 0 to 3 do begin
    ALine1.InvalidateLines(0, 3);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;

  ATestName := 'fill one-lines at start - decreasing';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 3 downto 0 do begin
    ALine1.InvalidateLines(0, 3);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;



  ATestName := 'fill one-lines at end - decreasing';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 9 downto 7 do begin
    ALine1.InvalidateLines(7, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;

  ATestName := 'fill one-lines at end - increasing';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 7 to 9 do begin
    ALine1.InvalidateLines(7, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;


  ATestName := 'fill one-lines - all, incr';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 0 to 9 do begin
    ALine1.InvalidateLines(0, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;

  ATestName := 'fill one-lines - all, decr';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 9 downto 0 do begin
    ALine1.InvalidateLines(0, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;


  ATestName := 'fill one-lines - all, incr then decr';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 0 to 4 do begin
    ALine1.InvalidateLines(0, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;
  for i := 9 downto 5 do begin
    ALine1.InvalidateLines(0, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;

  ATestName := 'fill one-lines - all, decr then incr';
  InitLine(ALine1, w.init(FillArray(10, 19)));
  w.Join([1,1]);
  for i := 9 downto 5 do begin
    ALine1.InvalidateLines(0, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;
  for i := 0 to 4 do begin
    ALine1.InvalidateLines(0, 9);
    w.w[i] := 1;
    ValidateNeededWraps(ALine1, w);
    AssertLineForWraps(Format('%s %d', [ATestName, i]), ALine1, w, True);
  end;

end;

procedure TTestWordWrap.TestWordWrapLineMapMerge;
var
  ANode1, ANode2: TSynEditLineMapPage;
  ALine1, ALine2: TSynWordWrapLineMap;
  ATestName: String;
  w: TExpWraps;
begin
  ANode1 := FTree.FindPageForLine(0, afmCreate).Page;
  ANode2 := FTree.FindPageForLine(100, afmCreate).Page;
  ALine1 := ANode1.SynWordWrapLineMapStore;
  ALine2 := ANode2.SynWordWrapLineMapStore;

  ATestName := 'Insert at start: no-offset => no-offset';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 0, 3);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 3);
  AssertLineForWraps('', ALine1, w.init([4, 5, 6,   2, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: no-offset => offset';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 0, 3);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 3);
  AssertLineForWraps('', ALine1, w.init([4, 5, 6,   1, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: offset => no offset';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 0, 3);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 3);
  AssertLineForWraps('', ALine1, w.init([1, 5, 6,   2, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: offset => offset';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 0, 3);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 3);
  AssertLineForWraps('', ALine1, w.init([1, 5, 6,   1, 1, 3, 3, 1,   1,1]));


  ATestName := 'Insert at start: no-offset 2nd => no-offset';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 1, 2);
  //ALine1.InsertLinesFromPage(ALine2, 1, 0, 2);
  AssertLineForWraps('', ALine1, w.init([5, 6,   2, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: no-offset 2nd => offset';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 1, 2);
  //ALine1.InsertLinesFromPage(ALine2, 1, 0, 2);
  AssertLineForWraps('', ALine1, w.init([5, 6,   1, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: offset 2nd => no offset';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 1, 2);
  //ALine1.InsertLinesFromPage(ALine2, 1, 0, 2);
  AssertLineForWraps('', ALine1, w.init([5, 6,   2, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: offset 2nd => offset';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 1, 2);
  //ALine1.InsertLinesFromPage(ALine2, 1, 0, 2);
  AssertLineForWraps('', ALine1, w.init([5, 6,   1, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: offset 3rd => no offset';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6, 7]));
  ALine2.MoveLinesAtEndTo(ALine1, 2, 2);
  //ALine1.InsertLinesFromPage(ALine2, 2, 0, 2);
  AssertLineForWraps('', ALine1, w.init([6, 7,   2, 1, 3, 3, 1,   1,1]));

  ATestName := 'Insert at start: offset 3rd => offset';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6, 7]));
  ALine2.MoveLinesAtEndTo(ALine1, 2, 2);
  //ALine1.InsertLinesFromPage(ALine2, 2, 0, 2);
  AssertLineForWraps('', ALine1, w.init([6, 7,   1, 1, 3, 3, 1,   1,1]));


  ATestName := 'Insert at start: overlen';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 0, 4);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 4);
  AssertLineForWraps(ATestName, ALine1, w.init([4, 5, 6, 1,   1, 1, 3, 3, 1,   1,1]));

  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtEndTo(ALine1, 1, 4);
  //ALine1.InsertLinesFromPage(ALine2, 1, 0, 4);
  AssertLineForWraps(ATestName, ALine1, w.init([5, 6, 1, 1,   1, 1, 3, 3, 1,   1,1]));

  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1]));
  ALine2.MoveLinesAtEndTo(ALine1, 1, 4);
  //ALine1.InsertLinesFromPage(ALine2, 1, 0, 4);
  AssertLineForWraps(ATestName, ALine1, w.init([1, 1, 1, 1,   1, 1, 3, 3, 1,   1,1]));



  ATestName := 'Insert at end';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtStartTo(ALine1, 2, 5);
  //ALine1.InsertLinesFromPage(ALine2, 0, 5, 3);
  AssertLineForWraps(ATestName, ALine1, w.init([1, 1, 3, 3, 1,   4, 5, 6,   1,1]));

  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.MoveLinesAtStartTo(ALine1, 2, 6);
  //ALine1.InsertLinesFromPage(ALine2, 0, 6, 3);
  AssertLineForWraps(ATestName, ALine1, w.init([1, 1, 3, 3, 1,   1, 4, 5, 6,   1,1]));


  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6]));
  ALine2.MoveLinesAtStartTo(ALine1, 2, 5);
  //ALine1.InsertLinesFromPage(ALine2, 0, 5, 3);
  AssertLineForWraps(ATestName, ALine1, w.init([1, 1, 3, 3, 1,   1, 5, 6,   1,1]));

  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([1, 5, 6]));
  ALine2.MoveLinesAtStartTo(ALine1, 2, 6);
  //ALine1.InsertLinesFromPage(ALine2, 0, 6, 3);
  AssertLineForWraps(ATestName, ALine1, w.init([1, 1, 3, 3, 1,   1, 1, 5, 6,   1,1]));

///////////////////////////////////////
  (* split node at none wrapping lines - ensure the none-wrap "WrappedExtraSums" are stripped *)
  ATestName := 'Insert at start: empty lines in the middle -> dest 2';
  InitLine(ALine1, w.init([4, 5]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtEndTo(ALine1, 3, 3);
  AssertLineForWraps('', ALine1, w.init([1, 1, 3, 4, 5,   1,1]));

  ATestName := 'Insert at start: empty lines in the middle -> dest 1';
  InitLine(ALine1, w.init([4]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtEndTo(ALine1, 3, 3);
  AssertLineForWraps('', ALine1, w.init([1, 1, 3, 4,   1,1]));

  ATestName := 'Insert at start: empty lines in the middle -> empty dest';
  InitLine(ALine1, w.init([]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtEndTo(ALine1, 3, 3);
  AssertLineForWraps('', ALine1, w.init([1, 1, 3,   1,1]));

  ATestName := 'Insert at start: empty lines in the middle -> dest 2 - with dest offset';
  InitLine(ALine1, w.init([1, 1, 4, 5]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtEndTo(ALine1, 3, 3);
  AssertLineForWraps('', ALine1, w.init([1, 1, 3, 1, 1, 4, 5,   1,1]));

  ATestName := 'Insert at start: empty lines in the middle -> dest 2 - with source offset';
  InitLine(ALine1, w.init([4, 5]));
  InitLine(ALine2, w.init([1, 1, 2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtEndTo(ALine1, 5, 3);
  AssertLineForWraps('', ALine1, w.init([1, 1, 3, 4, 5,   1,1]));



  ATestName := 'Insert at end : empty lines in the middle -> dest 2';
  InitLine(ALine1, w.init([4, 5]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtStartTo(ALine1, 3, 2);
  AssertLineForWraps('', ALine1, w.init([4, 5, 2, 1, 1,   1,1]));

  ATestName := 'Insert at end : empty lines in the middle -> dest 1';
  InitLine(ALine1, w.init([4]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtStartTo(ALine1, 3, 1);
  AssertLineForWraps('', ALine1, w.init([4, 2, 1, 1,   1,1]));

  ATestName := 'Insert at end : empty lines in the middle -> emyty dest';
  InitLine(ALine1, w.init([]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtStartTo(ALine1, 3, 0);
  AssertLineForWraps('', ALine1, w.init([2, 1, 1,   1,1]));

  ATestName := 'Insert at end : empty lines in the middle -> dest 2 - with dest offset';
  InitLine(ALine1, w.init([1, 1, 4, 5]));
  InitLine(ALine2, w.init([2, 1, 1, 1, 1, 3]));
  ALine2.MoveLinesAtStartTo(ALine1, 3, 4);
  AssertLineForWraps('', ALine1, w.init([1, 1, 4, 5, 2, 1, 1,   1,1]));

  ATestName := 'Insert at end : empty lines in the middle -> dest 2 - with source offset';
  InitLine(ALine1, w.init([4, 5]));
  InitLine(ALine2, w.init([1, 1, 2, 1, 1, 1, 1, 2]));
  ALine2.MoveLinesAtStartTo(ALine1, 5, 2);
  AssertLineForWraps('', ALine1, w.init([4, 5, 1, 1, 2, 1, 1,   1,1]));

end;

procedure TTestWordWrap.TestWordWrapLineMapMergeInvalidate;
var
  ANode1, ANode2: TSynEditLineMapPage;
  ALine1, ALine2: TSynWordWrapLineMap;
  ATestName: String;
  w: TExpWraps;

  procedure DoMoveLinesAtEndTo(const AName: String;
    const AWrapValues1, AWrapValues2: array of integer; AInvalLine: Integer; const AInvalDest: Boolean;
    ASourceStartLine, ALineCount: Integer;
    Exp: array of integer;  ExpInval: Integer
  );
  begin
    InitLine(ALine1, w.init(AWrapValues1));
    InitLine(ALine2, w.init(AWrapValues2));
    if AInvalDest then
      ALine1.InvalidateLines(AInvalLine, AInvalLine)
    else
      ALine2.InvalidateLines(AInvalLine, AInvalLine);
    ALine2.MoveLinesAtEndTo(ALine1, ASourceStartLine, ALineCount);
    AssertLineForWraps(AName, ALine1, w.init(Exp));
    AssertEquals(AName+' invalid', ExpInval, ALine1.FirstInvalidLine);
    AssertEquals(AName+' invalid', ExpInval, ALine1.LastInvalidLine);
  end;

  procedure DoMoveLinesAtStartTo(const AName: String;
    const AWrapValues1, AWrapValues2: array of integer; AInvalLine: Integer; const AInvalDest: Boolean;
    ASourceEndLine, ATargetStartLine: Integer;
    Exp: array of integer;  ExpInval: Integer
  );
  begin
    InitLine(ALine1, w.init(AWrapValues1));
    InitLine(ALine2, w.init(AWrapValues2));
    if AInvalDest then
      ALine1.InvalidateLines(AInvalLine, AInvalLine)
    else
      ALine2.InvalidateLines(AInvalLine, AInvalLine);
    ALine2.MoveLinesAtStartTo(ALine1, ASourceEndLine, ATargetStartLine);
    AssertLineForWraps(AName, ALine1, w.init(Exp));
    AssertEquals(AName+' invalid', ExpInval, ALine1.FirstInvalidLine);
    AssertEquals(AName+' invalid', ExpInval, ALine1.LastInvalidLine);
  end;

begin
  ANode1 := FTree.FindPageForLine(0, afmCreate).Page;
  ANode2 := FTree.FindPageForLine(100, afmCreate).Page;
  ALine1 := ANode1.SynWordWrapLineMapStore;
  ALine2 := ANode2.SynWordWrapLineMapStore;

  ATestName := 'Insert at start: target inval';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine1.InvalidateLines(1, 1);
  ALine2.MoveLinesAtEndTo(ALine1, 0, 3);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 3);
  AssertLineForWraps('', ALine1, w.init([4, 5, 6,   2, 1, 3, 3, 1,   1,1]));
  AssertEquals('invalid', 4, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 4, ALine1.LastInvalidLine);

  ATestName := 'Insert at start: source inval';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.InvalidateLines(1, 1);
  ALine2.MoveLinesAtEndTo(ALine1, 0, 3);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 3);
  AssertLineForWraps('', ALine1, w.init([4, 5, 6,   2, 1, 3, 3, 1,   1,1]));
  AssertEquals('invalid', 1, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 1, ALine1.LastInvalidLine);

  ATestName := 'Insert at start: source inval';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.InvalidateLines(0, 1);
  ALine2.MoveLinesAtEndTo(ALine1, 1, 2);
  //ALine1.InsertLinesFromPage(ALine2, 1, 0, 2);
  AssertLineForWraps('', ALine1, w.init([5, 6,   2, 1, 3, 3, 1,   1,1]));
  AssertEquals('invalid', 0, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 0, ALine1.LastInvalidLine);

  ATestName := 'Insert at start: source inval';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.InvalidateLines(0, 1);
  ALine2.MoveLinesAtEndTo(ALine1, 2, 1);
  //ALine1.InsertLinesFromPage(ALine2, 2, 0, 1);
  AssertLineForWraps('', ALine1, w.init([6,   2, 1, 3, 3, 1,   1,1]));
  AssertEquals('invalid', -1, ALine1.FirstInvalidLine);
  AssertEquals('invalid', -1, ALine1.LastInvalidLine);

  ATestName := 'Insert at start: both inval';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine1.InvalidateLines(1, 1);
  ALine2.InvalidateLines(2, 2);
  ALine2.MoveLinesAtEndTo(ALine1, 0, 3);
  //ALine1.InsertLinesFromPage(ALine2, 0, 0, 3);
  AssertLineForWraps('', ALine1, w.init([4, 5, 6,   2, 1, 3, 3, 1,   1,1]));
  AssertEquals('invalid', 2, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 4, ALine1.LastInvalidLine);


  ATestName := 'Insert at end: source inval';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([4, 5, 6]));
  ALine2.InvalidateLines(2, 2);
  ALine2.MoveLinesAtStartTo(ALine1, 2, 5);
  //ALine1.InsertLinesFromPage(ALine2, 0, 5, 3);
  AssertLineForWraps(ATestName, ALine1, w.init([1, 1, 3, 3, 1,   4, 5, 6,   1,1]));
  AssertEquals('invalid', 7, ALine1.FirstInvalidLine);
  AssertEquals('invalid', 7, ALine1.LastInvalidLine);



  ATestName := 'Insert from end to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtEndTo(ALine2, 3, 3);
  AssertLineForWraps(ATestName, ALine2, w.init([3, 1, 1,  1,1,1]));

  ATestName := 'Insert from end to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtEndTo(ALine2, 2, 3);
  AssertLineForWraps(ATestName, ALine2, w.init([3, 3, 1,  1,1,1]));

  ATestName := 'Insert from end to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtEndTo(ALine2, 1, 3);
  AssertLineForWraps(ATestName, ALine2, w.init([1, 3, 3,  1,1,1]));

  ATestName := 'Insert from end to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtEndTo(ALine2, 1, 4);
  AssertLineForWraps(ATestName, ALine2, w.init([1, 3, 3, 1,  1,1,1]));

  ATestName := 'Insert from after end to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtEndTo(ALine2, 6, 3);
  AssertLineForWraps(ATestName, ALine2, w.init([1, 1, 1,  1,1,1]));


  ATestName := 'Insert from start to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtStartTo(ALine2, 2, 0);
  AssertLineForWraps(ATestName, ALine2, w.init([1, 1, 3,    1,1,1]));

  ATestName := 'Insert from start to empty';
  InitLine(ALine1, w.init([2, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtStartTo(ALine2, 2, 0);
  AssertLineForWraps(ATestName, ALine2, w.init([2, 1, 3,    1,1,1,1]));

  ATestName := 'Insert from start to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtStartTo(ALine2, 1, 0);
  AssertLineForWraps(ATestName, ALine2, w.init([1, 1,     1,1,1,1]));

  ATestName := 'Insert from start to empty';
  InitLine(ALine1, w.init([1, 1, 3, 3, 1]));
  InitLine(ALine2, w.init([]));
  ALine1.MoveLinesAtStartTo(ALine2, 2, 3);
  AssertLineForWraps(ATestName, ALine2, w.init([1, 1, 1,  1, 1, 3,    1,1,1]));


///////////////////////////////////////
  (* split node at none wrapping lines - ensure the none-wrap "WrappedExtraSums" are stripped *)
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 3,  {=>}  [1, 1, 3, 4, 5,   1,1],  4);

  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 3, {=>}   [1, 1, 3, 4, 5,   1,1],  -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   2,  False,    3, 3, {=>}   [1, 1, 3, 4, 5,   1,1],  -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   3,  False,    3, 3, {=>}   [1, 1, 3, 4, 5,   1,1],  0);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 3, {=>}   [1, 1, 3, 4, 5,   1,1],  1);


  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - gap at source end',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 4,  {=>}  [1, 1, 3, 1, 4, 5,   1,1],  5);

  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - gap at source end',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 4,  {=>}  [1, 1, 3, 1, 4, 5,   1,1],  -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - gap at source end',
    [4, 5],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 4,  {=>}  [1, 1, 3, 1, 4, 5,   1,1],  1);


  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 1',
    [4],  [2, 1, 1, 1, 1, 3],      1,  True,    3, 3,  {=>}  [1, 1, 3, 4,   1,1],  4);

  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 1',
    [4],  [2, 1, 1, 1, 1, 3],      1,  False,    3, 3, {=>}   [1, 1, 3, 4,   1,1],  -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 1',
    [4],  [2, 1, 1, 1, 1, 3],      3,  False,    3, 3, {=>}   [1, 1, 3, 4,   1,1],  0);


  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> empty dest',
    [],  [2, 1, 1, 1, 1, 3],       1,  True,    3, 3,  {=>}  [1, 1, 3,   1,1],  4);

  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> empty dest',
    [],  [2, 1, 1, 1, 1, 3],       1,  False,    3, 3, {=>}   [1, 1, 3,   1,1],  -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> empty dest',
    [],  [2, 1, 1, 1, 1, 3],       4,  False,    3, 3, {=>}   [1, 1, 3,   1,1],  1);


  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset',
    [1,1,4, 5],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 3,  {=>}  [1, 1, 3, 1,1,4, 5,   1,1],  4);

  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset',
    [1,1,4, 5],  [2, 1, 1, 1, 1, 3],   1,  False,   3, 3,  {=>}  [1, 1, 3, 1,1,4, 5,   1,1], -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset',
    [1,1,4, 5],  [2, 1, 1, 1, 1, 3],   4,  False,   3, 3,  {=>}  [1, 1, 3, 1,1,4, 5,   1,1],  1);


  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - with source offset',
    [4, 5],  [1,1,2, 1, 1, 1, 1, 3],   1,  True,    5, 3,  {=>}  [1, 1, 3, 4, 5,   1,1],  4);

  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - with source offset',
    [4, 5],  [1,1,2, 1, 1, 1, 1, 3],   1,  False,    5, 3,  {=>}  [1, 1, 3, 4, 5,   1,1],  -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - with source offset',
    [4, 5],  [1,1,2, 1, 1, 1, 1, 3],   3,  False,    5, 3,  {=>}  [1, 1, 3, 4, 5,   1,1],  -1);
  DoMoveLinesAtEndTo('Insert at start: empty lines in the middle -> dest 2 - with source offset',
    [4, 5],  [1,1,2, 1, 1, 1, 1, 3],   6,  False,    5, 3,  {=>}  [1, 1, 3, 4, 5,   1,1],  1);





  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 2,  {=>}  [4, 5, 2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 2,  {=>}  [4, 5, 2, 1, 1,   1,1],  3);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2',
    [4, 5],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 2,  {=>}  [4, 5, 2, 1, 1,   1,1],  -1);


  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - gap at target end',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 3,  {=>}  [4, 5, 1,  2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - gap at target end',
    [4, 5],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 3,  {=>}  [4, 5, 1,  2, 1, 1,   1,1],  4);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - gap at target end',
    [4, 5],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 3,  {=>}  [4, 5, 1,  2, 1, 1,   1,1],  -1);


  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 1',
    [4],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 1,  {=>}  [4, 2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 1',
    [4],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 1,  {=>}  [4, 2, 1, 1,   1,1],  2);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 1',
    [4],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 1,  {=>}  [4, 2, 1, 1,   1,1],  -1);


// empty dest can not have invalid...
  //DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> empty dest',
  //  [],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 0,  {=>}  [2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> empty dest',
    [],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 0,  {=>}  [2, 1, 1,   1,1],  1);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> empty dest',
    [],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 0,  {=>}  [2, 1, 1,   1,1],  -1);


  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> empty dest - gap',
    [],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 2,  {=>}  [1,1, 2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> empty dest - gap',
    [],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 2,  {=>}  [1,1, 2, 1, 1,   1,1],  3);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> empty dest- gap',
    [],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 2,  {=>}  [1,1, 2, 1, 1,   1,1],  -1);


  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset',
    [1,1, 4, 5],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 4,  {=>}  [1,1, 4, 5, 2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset',
    [1,1, 4, 5],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 4,  {=>}  [1,1, 4, 5, 2, 1, 1,   1,1],  5);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset',
    [1,1, 4, 5],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 4,  {=>}  [1,1, 4, 5, 2, 1, 1,   1,1],  -1);


  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset - gap',
    [1,1, 4, 5],  [2, 1, 1, 1, 1, 3],   1,  True,    3, 5,  {=>}  [1,1, 4, 5, 1, 2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset - gap',
    [1,1, 4, 5],  [2, 1, 1, 1, 1, 3],   1,  False,    3, 5,  {=>}  [1,1, 4, 5, 1, 2, 1, 1,   1,1],  6);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with dest offset - gap',
    [1,1, 4, 5],  [2, 1, 1, 1, 1, 3],   4,  False,    3, 5,  {=>}  [1,1, 4, 5, 1, 2, 1, 1,   1,1],  -1);


  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with source offset',
    [4, 5],  [1,1, 2, 1, 1, 1, 1, 3],   1,  True,    5, 2,  {=>}  [4, 5, 1,1, 2, 1, 1,   1,1],  1);

  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with source offset',
    [4, 5],  [1,1, 2, 1, 1, 1, 1, 3],   1,  False,    5, 2,  {=>}  [4, 5, 1,1, 2, 1, 1,   1,1],  3);
  DoMoveLinesAtStartTo('Insert at start: empty lines in the middle -> dest 2 - with source offset',
    [4, 5],  [1,1, 2, 1, 1, 1, 1, 3],   6,  False,    5, 2,  {=>}  [4, 5, 1,1, 2, 1, 1,   1,1],  -1);


end;

procedure TTestWordWrap.TestWordWrapJoinWithSibling;
var
  CurWraps: TExpWraps;

  procedure DoTestAssert(AName: String; ExpNodeCnt: Integer);
  begin
    //debugln(AName); FTree.DebugDump ;
    AssertTreeForWraps(AName + ' Wrap', CurWraps);
    AssertEquals(AName + ' Cnt ', ExpNodeCnt, TreeNodeCount);
  end;

  procedure DoTestInit(AName: String; AFromVal, ALineCount, AnIncrease, ExpNodeCnt: Integer);
  begin
    FTree.Clear;
    CurWraps.InitFill(AFromVal, AFromVal+ALineCount-1, AnIncrease); // 4 pages
    FTree.AdjustForLinesInserted(0, ALineCount, 0);
    ValidateTreeWraps(CurWraps);

    DoTestAssert(Format('%s (Init %d, %d) Wrap', [AName, AFromVal, ALineCount]), ExpNodeCnt);
  end;

  procedure DoTestChgWrp(AName: String; AStartLine, ALineCount, AFromVal, AnIncrease, ExpNodeCnt: Integer);
  begin
    CurWraps.FillRange(AStartLine, ALineCount, AFromVal, AnIncrease);
    FTree.InvalidateLines(AStartLine, AStartLine + ALineCount - 1);
    ValidateTreeWraps(CurWraps);

    DoTestAssert(Format('%s (Changed %d, %d) Wrap', [AName, AStartLine, ALineCount]), ExpNodeCnt);
  end;

  procedure DoTestDelete(AName: String; AStartLine, ALineCount, ExpNodeCnt: Integer);
  begin
    FTree.AdjustForLinesDeleted(AStartLine, ALineCount,0);
    CurWraps.SpliceArray(AStartLine, ALineCount);

    DoTestAssert(Format('%s (Deleted %d, %d) Wrap', [AName, AStartLine, ALineCount]), ExpNodeCnt);
  end;

var
  OffsetAtStart, OffsetAtEnd, Node1Del, Node2Del, FinalNodeCount: Integer;
  N: String;
begin
  (* After "DoTestInit" each node should be filled to the max.
     So the test knows where each node begins
  *)
  FTree.Free;
  FTree := CreateTree(10, 30, 4); // APageJoinSize, APageSplitSize, APageJoinDistance

  For OffsetAtStart := 0 to 3 do
  For OffsetAtEnd := 0 to 3 do  // RealEnd = NextNode.Startline-1 - x
  For Node1Del := 18 to 25 do
  For Node2Del := 18 to 25 do
  begin
    N := Format('Start: %d  End: %d  Del1: %d Del2: %d', [OffsetAtStart, OffsetAtEnd, Node1Del, Node2Del]);

    FinalNodeCount := 3;
    if (OffsetAtStart + OffsetAtEnd > 4) or   //  APageJoinDistance not met
       (Node1Del + OffsetAtEnd < 20) or (Node2Del + OffsetAtStart < 20)
    then
      FinalNodeCount := 4;

    DoTestInit  (N, 10, 4*30, 1,    4);  // Create 4 full nodes

    if OffsetAtStart > 0 then
      DoTestChgWrp(N, 90,              OffsetAtStart, 1, 0,   4);  // At Start of Last node
    if OffsetAtEnd > 0 then
      DoTestChgWrp(N, 90-OffsetAtEnd,  OffsetAtEnd,   1, 0,   4);  // At End of 2nd-Last node

    DoTestDelete(N, 60,          Node1Del,         4);
    DoTestDelete(N, 95-Node1Del, Node2Del,         FinalNodeCount);

    // Delete from 2nd node before 1st node
    DoTestInit  (N, 10, 4*30, 1,    4);  // Create 4 full nodes

    if OffsetAtStart > 0 then
      DoTestChgWrp(N, 90,              OffsetAtStart, 1, 0,   4);  // At Start of Last node
    if OffsetAtEnd > 0 then
      DoTestChgWrp(N, 90-OffsetAtEnd,  OffsetAtEnd,   1, 0,   4);  // At End of 2nd-Last node

    DoTestDelete(N, 95, Node2Del,         4);
    DoTestDelete(N, 60, Node1Del,         FinalNodeCount);

  end;
end;


procedure TTestWordWrap.TestWordWrapTreeInsertThenDelete;
var
  CurWraps: TExpWraps;
  InsPos, InsLen, DelPos, DelCount: Integer;
begin
  FTree.Free;
  FTree := CreateTree(2, 9, 4);
//  FTree := TSynLineMapAVLTree.Create(TSynEditLineMapPage, 2, 11, 4);
  for DelPos := 0 to 26 do
  for DelCount := 1 to Min(5, 27-DelPos) do
  for InsPos := 0 to 29 do
  for InsLen := 1 to 4 do begin
    FTree.Clear;

    // init
    CurWraps.InitFill(10, 10+26);
    FTree.AdjustForLinesInserted(0, 27, 0);
    ValidateTreeWraps(CurWraps);
    //FTree.DebugDump;
    AssertTreeForWraps(Format('Before ins at pos %d Len %d', [InsPos, InsLen]), CurWraps);

    // ins
    CurWraps.Join(FillArray(500, 499+InsLen), InsPos);
    FTree.AdjustForLinesInserted(InsPos, InsLen, 0);
    //FTree.DebugDump;
    ValidateTreeWraps(CurWraps);
    //FTree.DebugDump;
    AssertTreeForWraps(Format('After ins at pos %d Len %d ins at pos %d Len %d', [DelPos, DelCount, InsPos, InsLen]), CurWraps);

    // del
    FTree.AdjustForLinesDeleted(DelPos, DelCount, 0);
    CurWraps.SpliceArray(DelPos, DelCount);
    AssertTrue(Format('valid After del at pos %d Len %d ins at pos %d Len %d', [DelPos, DelCount, InsPos, InsLen]),
      not FTree.NeedsValidation);
    AssertTreeForWraps(Format('After del at pos %d Len %d ins at pos %d Len %d', [DelPos, DelCount, InsPos, InsLen]), CurWraps);
  end;
end;

procedure TTestWordWrap.TestWordWrapTreeDeleteThenInsert;
var
  CurWraps: TExpWraps;
  InsPos, InsLen, DelPos, DelCount: Integer;
begin
  FTree.Free;
  FTree := CreateTree(2, 9, 4);
//  FTree := TSynLineMapAVLTree.Create(TSynEditLineMapPage, 2, 11, 4);
  for DelPos := 0 to 26 do
  for DelCount := 1 to Min(5, 27-DelPos) do
  for InsPos := 0 to 29 do
  for InsLen := 1 to 4 do begin
//if  (InsPos<>15) or (InsLen<>1) or (DelPos<>0) or (DelCount<>1) then continue;
    FTree.Clear;

    // init
    CurWraps.InitFill(10, 10+26);
    FTree.AdjustForLinesInserted(0, 27, 0);
    ValidateTreeWraps(CurWraps);
    //FTree.DebugDump;
    AssertTreeForWraps(Format('Before del at pos %d Len %d ins at pos %d Len %d', [DelPos, DelCount, InsPos, InsLen]), CurWraps);

    // del
    FTree.AdjustForLinesDeleted(DelPos, DelCount, 0);
    CurWraps.SpliceArray(DelPos, DelCount);
    AssertTrue(Format('valid After del at pos %d Len %d ins at pos %d Len %d', [DelPos, DelCount, InsPos, InsLen]),
      not FTree.NeedsValidation);
    AssertTreeForWraps(Format('After del at pos %d Len %d ins at pos %d Len %d', [DelPos, DelCount, InsPos, InsLen]), CurWraps);

    // ins
    FTree.AdjustForLinesInserted(InsPos, InsLen, 0);
    CurWraps.Join(FillArray(500, 499+InsLen), InsPos);
    //FTree.DebugDump;
    ValidateTreeWraps(CurWraps);
    //FTree.DebugDump;
    AssertTreeForWraps(Format('After del/ins : del at pos %d Len %d ins at pos %d Len %d', [DelPos, DelCount, InsPos, InsLen]), CurWraps);
  end;
end;

{ TTestWordWrapPluginBase }

procedure TTestWordWrapPluginBase.ClearCaret;
begin
  SynEdit.CaretXY := Point(2,2);
  SynEdit.CaretXY := Point(1,1);
end;

function TTestWordWrapPluginBase.GetTreeNodeHolder(AIndex: Integer
  ): TSynEditLineMapPageHolder;
begin
  Result := FWordWrap.LineMappingData.FirstPage;
  while (AIndex > 0) and Result.HasPage do begin
    dec(AIndex);
    Result := Result.Next;
  end;

end;

procedure TTestWordWrapPluginBase.SetCaret(SourcePt: TPointType; APos: TPoint);
begin
  case SourcePt of
    ptViewed:          SynEdit.CaretObj.ViewedLineCharPos := Apos;
    ptPhys:            SynEdit.CaretObj.LineCharPos       := Apos;
    ptLog:             SynEdit.CaretObj.LineBytePos       := APos;
  end;
end;

procedure TTestWordWrapPluginBase.TestCaret(AName: String;SourcePt, ExpPt: TPointType;
  AnExp: TPoint; AnExpOffs: Integer);
var
  got: TPoint;
  src, dest: String;
begin
  case ExpPt of
    ptViewed:          got := SynEdit.CaretObj.ViewedLineCharPos;
    ptPhys:            got := SynEdit.CaretObj.LineCharPos;
    ptLog:             got := SynEdit.CaretObj.LineBytePos;
  end;
  writestr(src, SourcePt);
  writestr(dest, ExpPt);
  AssertEquals(Format('%s (%s -> %s)', [AName, src, dest]), AnExp, got);
  if (ExpPt = ptLog) and (AnExpOffs >= 0) then
    AssertEquals(Format('%s (%s -> %s) Offs: ', [AName, src, dest]), AnExpOffs, SynEdit.CaretObj.BytePosOffset);
end;

class procedure TTestWordWrapPluginBase.AssertEquals(const AMessage: string;
  Expected, Actual: TPoint);
begin
  AssertEquals(AMessage, dbgs(Expected), dbgs(Actual));
end;

procedure TTestWordWrapPluginBase.AddLines(AFirstLineIdx, ACount,
  ALen: Integer; AnID: String; SkipBeginUpdate: Boolean;
  AReplaceExisting: Boolean);
var
  i, j: Integer;
  l: String;
begin
  if not SkipBeginUpdate then SynEdit.BeginUpdate;
  for i := 0 to ACount - 1 do begin
    l := '';
    j := 0;
    while Length(l) < ALen do begin
      l := l + copy(AnID+'_'+IntToStr(i)+'_'+IntToStr(j) + '            ',1,12);
      inc(j);
    end;
    l := copy(l, 1, ALen);
    if AReplaceExisting then
      SynEdit.Lines[AFirstLineIdx + i] := l
    else
      SynEdit.Lines.Insert(AFirstLineIdx + i, l);
  end;
  if not SkipBeginUpdate then SynEdit.EndUpdate;
end;

procedure TTestWordWrapPluginBase.InternalCheckLine(AName: String;
  dsp: TLazSynDisplayView; ALine: TLineIdx; AExpTextStart: String;
  NoTrim: Boolean);
var
  gotRealLine: TLineIdx;
  gotStartPos, GotLineLen, gotStartPhys, gotSubLineIdx: Integer;
  gotTokenOk: Boolean;
  gotToken: TLazSynDisplayTokenInfo;
  gotText: PChar;
  s: String;
begin
  dsp.SetHighlighterTokensLine(ALine, gotRealLine, gotSubLineIdx, gotStartPos, gotStartPhys, GotLineLen);
  gotTokenOk := dsp.GetNextHighlighterToken(gotToken);
  if gotTokenOk then
    gotText := gotToken.TokenStart
  else
    gotText := '';

  if AExpTextStart = '' then begin
    AssertEquals(AName, '', gotText);
    AssertEquals(AName, 0, GotLineLen);
    exit;
  end
  else
  if gotText = '' then begin
    AssertTrue(AName, False);
    exit;
  end;

  if NoTrim then
    s := copy(gotText, 1, Length(AExpTextStart))
  else
    s := copy(Trim(gotText), 1, Length(AExpTextStart));
  if not(AExpTextStart = s) then begin
    debugln(['Failed ', AName, ' ', ALine, ':']);
    DebugLn(['GOT: "', StringReplace(gotText, #9, '#9', [rfReplaceAll]), '"']);
    DebugLn(['EXP: "', StringReplace(AExpTextStart, #9, '#9', [rfReplaceAll]), '"']);
  end;
  AssertEquals(AName, AExpTextStart, s);
end;

procedure TTestWordWrapPluginBase.CheckLine(AName: String; ALine: TLineIdx;
  AExpTextStart: String; NoTrim: Boolean);
var
  v: TSynEditStringsLinked;
  dsp: TLazSynDisplayView;
begin
  v := SynEdit.TextViewsManager.SynTextView[SynEdit.TextViewsManager.Count - 1];
  dsp := v.DisplayView;
  dsp.InitHighlighterTokens(nil);
  try
    InternalCheckLine(AName, dsp, ALine, AExpTextStart, NoTrim);
  finally
    dsp.FinishHighlighterTokens;
  end;
end;

procedure TTestWordWrapPluginBase.CheckLines(AName: String;
  AStartLine: TLineIdx; AExpTextStart: array of String; NoTrim: Boolean);
var
  v: TSynEditStringsLinked;
  dsp: TLazSynDisplayView;
  i, gotStartPos, GotLineLen, gotStartPhys, gotSubLineIdx: Integer;
  gotTokenOk: Boolean;
  gotToken: TLazSynDisplayTokenInfo;
  s: String;
  gotRealLine: TLineIdx;
begin
  v := SynEdit.TextViewsManager.SynTextView[SynEdit.TextViewsManager.Count - 1];
  dsp := v.DisplayView;
  dsp.InitHighlighterTokens(nil);
  try
    try
      for i := 0 to Length(AExpTextStart)-1 do
        InternalCheckLine(AName, dsp, AStartLine+i, AExpTextStart[i], NoTrim);
    except
      dsp.FinishHighlighterTokens;
      dsp.InitHighlighterTokens(nil);
      for i := 0 to Length(AExpTextStart)-1 do begin
        dsp.SetHighlighterTokensLine(AStartLine+i, gotRealLine, gotSubLineIdx, gotStartPos, gotStartPhys, GotLineLen);
        s := '';
        while dsp.GetNextHighlighterToken(gotToken) and (gotToken.TokenLength > 0) do
          s := s + copy(gotToken.TokenStart, 1, gotToken.TokenLength);
        debugln('Line %d (real %d): "%s" %d/%d start %d',
          [AStartLine+i, gotRealLine, StringReplace(s, #9, '#9', [rfReplaceAll]), length(s), GotLineLen, gotStartPos]);
      end;
      raise;
    end;
  finally
    dsp.FinishHighlighterTokens;
  end;
end;

procedure TTestWordWrapPluginBase.CheckLine(AName: String;
  AExpLine: TTestWrapLineInfo);
begin
  CheckLine(AName, AExpLine.ViewedIdx, AExpLine.TextStartMatch, AExpLine.NoTrim);
end;

procedure TTestWordWrapPluginBase.CheckLines(AName: String;
  AExpLines: TTestViewedLineRangeInfo);
var
  i: Integer;
  n: TSynEditLineMapPageHolder;
begin
  for i := 0 to length(AExpLines) - 1 do begin
    CheckLine(Format('%s (%d)', [AName, i]), AExpLines[i]);
    CheckLineIndexMapping(Format('%s (%d)', [AName, i]), AExpLines[i].TextIdx, AExpLines[i].ViewedTopIdx, AExpLines[i].ViewedBottomIdx);
  end;
  if TheTree <> nil then begin
    n := TheTree.FirstPage;
    if n.HasPage then
      CheckTree(AName+' (TreeCheck)', n.Page, n.StartLine, 0, SynEdit.Lines.Count-1);
  end;
end;

procedure TTestWordWrapPluginBase.CheckXyMap(AName: String; APhysTExtXY,
  AViewedXY: TPoint; OnlyViewToText: Boolean);
var
  v: TSynEditStringsLinked;
  GotTextXY, GotViewXY: TPoint;
begin
  v := SynEdit.TextViewsManager.SynTextView[SynEdit.TextViewsManager.Count - 1];
  GotTextXY := v.ViewXYToTextXY(AViewedXY);
  GotViewXY := v.TextXYToViewXY(APhysTExtXY);

  AssertTrue(Format('%s: Viewed %s to Text %s (exp) => got %s', [AName, dbgs(AViewedXY), dbgs(APhysTExtXY), dbgs(GotTextXY)]),
             (GotTextXY.x = APhysTExtXY.x) and (GotTextXY.y = APhysTExtXY.y) );
  if not OnlyViewToText then
  AssertTrue(Format('%s: Text %s to viewed %s (exp) => got %s', [AName, dbgs(APhysTExtXY), dbgs(AViewedXY), dbgs(GotViewXY)]),
             (GotViewXY.x = AViewedXY.x) and (GotViewXY.y = AViewedXY.y) );
end;

procedure TTestWordWrapPluginBase.CheckXyMap(AName: String; APhysTExtX,
  APhysTExtY, AViewedX, AViewedY: integer; OnlyViewToText: Boolean);
begin
  CheckXyMap(AName, Point(APhysTExtX, APhysTExtY), Point(AViewedX, AViewedY), OnlyViewToText);
end;

procedure TTestWordWrapPluginBase.CheckXyMap(AName: String;
  APoints: TPointSpecs);
var
  StartP, TestP: TPointType;
begin
  CheckXyMap(AName + 'XyMap', APoints.xy[ptPhys], APoints.xy[ptViewed]);


  for TestP in TPointType do begin
    ClearCaret;
    SynEdit.CaretXY := APoints.XY[ptPhys];
    TestCaret(AName, ptPhys, TestP, APoints.XY[TestP], APoints.LogOffs);

    if APoints.LogOffs <= 0 then begin
      ClearCaret;
      SynEdit.LogicalCaretXY := APoints.XY[ptLog];
      TestCaret(AName, ptLog, TestP, APoints.XY[TestP], APoints.LogOffs);
    end;

    AName := AName + ' [CaretObj] ';
    for StartP in TPointType do begin
      if APoints.xy[StartP].x <= 0 then
        Continue;
    if (StartP = ptLog) and (APoints.LogOffs > 0) then
      continue;

      ClearCaret;
      SetCaret(StartP, APoints.XY[StartP]);
      TestCaret(AName, StartP, TestP, APoints.XY[TestP], APoints.LogOffs);
    end;
  end;

end;

procedure TTestWordWrapPluginBase.CheckXyMap(AName: String;
  APoints: TPointSpecs; ATestCommands: array of TCommandAndPointSpecs);
var
  i: Integer;
  StartP, TestP: TPointType;
  n: string;
  c: TSynEditorCommand;
begin
  CheckXyMap(AName+'(p)', APoints);

  for i := 0 to Length(ATestCommands) - 1 do begin
    if not ATestCommands[i].RunOnlyIf then
      Continue;
    n := AName+'(p'+IntToStr(i)+')';
    CheckXyMap(n, ATestCommands[i].Exp);

    for StartP in TPointType do begin
      if APoints.xy[StartP].x <= 0 then
        Continue;
      if (StartP = ptLog) and (APoints.LogOffs > 0) then
        continue;

      for TestP in TPointType do begin
        ClearCaret;
        SetCaret(StartP, APoints.XY[StartP]);
        for c in ATestCommands[i].Cmd do
          SynEdit.ExecuteCommand(c, '', nil);

        TestCaret(n, StartP, TestP, ATestCommands[i].Exp.XY[TestP], ATestCommands[i].Exp.LogOffs);
      end;
    end;
  end;
end;

procedure TTestWordWrapPluginBase.CheckLineIndexMapping(AName: String;
  ATextIdx, AViewTopIdx, AViewBottomIdx: TLineIdx);
var
  v: TSynEditStringsLinked;
  i: TLineIdx;
  dv: TLazSynDisplayView;
  r: TLineRange;
begin
  v := SynEdit.TextViewsManager.SynTextView[SynEdit.TextViewsManager.Count - 1];
  dv := v.DisplayView;

  AssertEquals(AName + ' TextToViewIndex', AViewTopIdx, v.TextToViewIndex(ATextIdx));
  for i := AViewTopIdx to AViewBottomIdx do
    AssertEquals(AName + ' ViewToTextIndex', ATextIdx, v.ViewToTextIndex(i));

  r := dv.TextToViewIndex(ATextIdx);
  AssertEquals(AName + 'DispView.TextToViewIndex Top', AViewTopIdx, r.Top);
  AssertEquals(AName + 'DispView.TextToViewIndex Bottom', AViewBottomIdx, r.Bottom);
  for i := AViewTopIdx to AViewBottomIdx do begin
    AssertEquals(AName + ' ViewToTextIndex', ATextIdx, dv.ViewToTextIndex(i));

    AssertEquals(AName + ' ViewToTextIndexEx', ATextIdx, dv.ViewToTextIndexEx(i, r));
    AssertEquals(AName + ' ViewToTextIndexEx Top', AViewTopIdx, r.Top);
    AssertEquals(AName + ' ViewToTextIndexEx Bottom', AViewBottomIdx, r.Bottom);
  end;
end;

function TTestWordWrapPluginBase.TheTree: TSynLineMapAVLTree;
begin
  Result := nil;
  if FWordWrap = nil then
    exit;
  Result := FWordWrap.LineMappingData;
end;

procedure TTestWordWrapPluginBase.ReCreateEdit(ADispWidth: Integer);
begin
  TearDown;
  SetUp;
  SetSynEditWidth(ADispWidth);
end;

procedure TTestWordWrapPluginBase.SetUp;
begin
  inherited SetUp;
  FWordWrap := TTestSynEditLineWrapPlugin.Create(SynEdit);
end;

procedure TTestWordWrapPluginBase.TearDown;
begin
  inherited TearDown;
end;

{ TTestWordWrapPlugin }

procedure TTestWordWrapPlugin.TestEditorWrap;
var
  SkipTab, AllowPastEOL, KeepX: Boolean;
begin
  SynEdit.Options := [];
  SynEdit.TabWidth := 4;

  SetLines([
    // 0
    'abc def ' + 'ABC DEFG ' + 'XYZ',
    //'A'  #9'B'  #9'C ' + 'DEF G'#9'H'  #9 + ''   #9   #9'xy',
    'A'#9'B'#9'C ' + 'DEF G'#9'H'#9 + #9#9'xy',
    'äää ööö ' + 'ÄÄÄ ÖÖÖ ' + 'ÜÜÜ',
    '999',

    // 4
    'A نمت X',
    'A نمت X Foo',
    // 6
    'Abc d نمت Foo',
    'Abc de نمت Foo',
    'Abcde def نمت Foo',
    'Abcde  def نمت Foo',

    // 10
    'Abcde نمت نمت Foo',
    'Abc de نمت نمت Foo',
    'Abc de نمت نمت F نمت نمت Foo',
    'Abc de نمت نمت  نمت نمت Foo',

    // 13
    'نمت) نمت نمت 789 123 نمت', // digits are weak LTR/RTL
    ''
  ]);

  SetSynEditWidth(10);
  CheckLines('', 0, [
    // 0 // Virt = 0
    'abc def ',
    'ABC DEFG ',
    'XYZ',
    'A'#9'B'#9'C ',
    'DEF G'#9'H'#9,
    #9#9'xy',
    'äää ööö ',
    'ÄÄÄ ÖÖÖ ',
    'ÜÜÜ',
    '999',

    // 4  // Virt= 10
    'A نمت X',
    'A نمت X ',
      'Foo',
    // 6  // Virt=13
    'Abc d نمت ',
      'Foo',
    'Abc de نمت',
      ' Foo',
    'Abcde def ',
      'نمت Foo',
    'Abcde  def',
      ' نمت Foo',

    // 10 // Virt = 21
    'Abcde نمت ',
      'نمت Foo',
    'Abc de نمت',
      ' نمت Foo',
    'Abc de نمت',
      ' نمت F نمت'
      ,' نمت Foo',
    'Abc de نمت',
      ' نمت  نمت '
      ,'نمت Foo',

    // 14 // Virt = 31
    'نمت) نمت ',
    'نمت 789 ',
    '123 نمت',

    ''

  ], True);

  CheckLines('', ViewedExp(0, [
    l(0, 0, 'abc def '),
    l(0, 1, 'ABC DEFG '),
    l(0, 2, 'XYZ'),
    l(1, 0, 'A'#9'B'#9'C '),
    l(1, 1, 'DEF G'#9'H'#9),
    l(1, 2, #9#9'xy'),
    l(2, 0, 'äää ööö '),
    l(2, 1, 'ÄÄÄ ÖÖÖ '),
    l(2, 2, 'ÜÜÜ'),
    l(3, 0, '999'),

    // 4  // Virt= 10
    l(4, 0, 'A نمت X'),
    l(5, 0, 'A نمت X '),
    l(5, 1,   'Foo'),
    // 6  // Virt=13
    l(6, 0, 'Abc d نمت '),
    l(6, 1,   'Foo'),
    l(7, 0, 'Abc de نمت'),
    l(7, 1,   ' Foo'),
    l(8, 0, 'Abcde def '),
    l(8, 1,   'نمت Foo'),
    l(9, 0, 'Abcde  def'),
    l(9, 1,   ' نمت Foo'),

    // 10 // Virt = 21
    l(10, 0, 'Abcde نمت '),
    l(10, 1,   'نمت Foo'),
    l(11, 0, 'Abc de نمت'),
    l(11, 1,   ' نمت Foo'),
    l(12, 0, 'Abc de نمت'),
    l(12, 1,   ' نمت F نمت'),
    l(12, 2,   ' نمت Foo'),
    l(13, 0, 'Abc de نمت'),
    l(13, 1,   ' نمت  نمت '),
    l(13, 2,   'نمت Foo'),

    // 14 // Virt = 31
    l(14, 0, 'نمت) نمت '),
    l(14, 1, 'نمت 789 '),
    l(14, 2, '123 نمت'),

    l(15, 0, '')

  ], tTrue));


  //CheckXyMap('', pt(4,3,   21,1,   21,1); // after "Z" EOL
  for AllowPastEOL in boolean do
  for KeepX in boolean do
  for SkipTab in boolean do begin
    if AllowPastEOL
    then SynEdit.Options := SynEdit.Options + [eoScrollPastEol]
    else SynEdit.Options := SynEdit.Options - [eoScrollPastEol];
    if SkipTab
    then SynEdit.Options2 := SynEdit.Options2 + [eoCaretSkipTab]
    else SynEdit.Options2 := SynEdit.Options2 - [eoCaretSkipTab];
    if KeepX
    then SynEdit.Options := SynEdit.Options + [eoKeepCaretX]
    else SynEdit.Options := SynEdit.Options - [eoKeepCaretX];

    FWordWrap.CaretWrapPos := wcpEOL;
    CheckXyMap('wcpEOL', p( 1,1,           1,1,    1,1),
                        [c(ecRight,                         2,1,   2,1,    2,1,0),
                         c(ecDown,                          2,2,  10,1,   10,1,0),
                         c([ecDown,ecDown],                 2,3,  19,1,   19,1,0),
                         c([ecDown,ecDown, ecRight],        3,3,  20,1,   20,1,0),
                         c([ecDown,ecDown, ecRight,ecDown], 2,4,   2,2,    2,2,0, SkipTab),
                         c([ecDown,ecDown, ecRight,ecDown], 3,4,   3,2,    2,2,1, not SkipTab),
                         c([ecDown,ecDown,ecDown],          1,4,   1,2,    1,2,0, KeepX),
                         c([ecDown,ecDown,ecDown],          2,4,   2,2,    2,2,0, not KeepX),
                         c([ecDown,ecDown,ecDown,ecDown],   2,5,  12,2,    8,2,0)
                        ]);
    CheckXyMap('wcpEOL', p( 2,1,           2,1,    2,1),
                        [c(ecDown,                          2,2,  10,1,   10,1,0)
                        ]);
    CheckXyMap('wcpEOL', p( 7,1,           7,1,    7,1), // after "e"
                        [c([ecColSelDown],              7,4,   7,2,   4,2,1,  not SkipTab ),    // A#9B#|9  // 1 in tab
                         c([ecColSelDown],              6,4,   6,2,   4,2,0,  SkipTab ),    // A#9B|#9  // 1 in tab
                         c([ecColSelDown,ecColSelDown], 7,7,   7,3,  12,3,0,  (not SkipTab) or KeepX ),
                         c([ecColSelDown,ecColSelDown], 6,7,   6,3,  10,3,0,  SkipTab and not KeepX ),
                         c([ecColSelDown,ecColSelDown,ecColSelDown], 4,10,   4,4,  4,4,0, not AllowPastEOL),
                         c([ecColSelDown,ecColSelDown,ecColSelDown], 7,10,   7,4,  7,4,0, AllowPastEOL and ((not SkipTab) or KeepX) )
                        ]);
    CheckXyMap('wcpEOL', p( 8,1,           8,1,    8,1));
    if AllowPastEOL then
    CheckXyMap('wcpEOL', p( 9,1,           9,1,    9,1), // def |
                        [c([ecDown],                        9,2,  17,1,   17,1,0), // DEFG|
                         c([ecDown,ecDown],                 9,3,  26,1,   26,1,0), // XYZ     |
                         c([ecDown,ecDown,ecDown],          9,4,   9,2,    5,2,0), // A#9B#9|C
                         c([ecDown,ecDown,ecDown,ecDown],   8,5,  18,2,   14,2,0,  SkipTab),     // G#9|H#9
                         c([ecDown,ecDown,ecDown,ecDown],   9,5,  19,2,   14,2,1,  not SkipTab), // G#9H#|9 //in #9
                         c([ecDown,ecDown,ecDown,ecDown,ecDown],   9,6,  29,2,   17,2,0,  (not SkipTab) or KeepX), // before x
                         c([ecDown,ecDown,ecDown,ecDown,ecDown],   5,6,  25,2,   16,2,0,  SkipTab       and not KeepX),  // in tab, before x
                         c([ecDown,ecDown,ecDown,ecDown,ecDown,ecDown],   9,7,   9,3,   15,3,0,  (not SkipTab) or KeepX),
                         c([ecDown,ecDown,ecDown,ecDown,ecDown,ecDown],   5,7,   5,3,    8,3,0,  SkipTab and not KeepX)
                        ])
    else // not AllowPastEOL then
    CheckXyMap('wcpEOL', p( 9,1,           9,1,    9,1), // after " " / still on line 1
                        [c([ecDown],                        9,2,  17,1,   17,1,0),             // DEFG|
                         c([ecDown,ecDown],                 4,3,  21,1,   21,1,0),             // XYZ|
                         c([ecDown,ecDown,ecDown],          9,4,   9,2,    5,2,0,  KeepX),     // A#9B#9|C
                         c([ecDown,ecDown,ecDown],          4,4,   4,2,    2,2,2,  (not KeepX) and (not SkipTab) ), // A#|9B#9C //in tab
                         c([ecDown,ecDown,ecDown],          2,4,   2,2,    2,2,0,  (not KeepX) and SkipTab)  // A#|9B#9C //in tab
                        ]);
    CheckXyMap('wcpEOL', p( 2,2,          10,1,   10,1));
    CheckXyMap('wcpEOL', p( 4,2,          12,1,   12,1), // ABC| DE
                         [c([ecColSelDown],              2,5,  12,2,   8,2,0),             // D|EF G#9
                          c([ecColSelDown,ecColSelDown], 4,8,  12,3,   21,3,0),
                          c([ecColSelDown,ecColSelDown,ecColSelDown], 4,10,  4,4,   4,4,0,  not AllowPastEOL)
                         ]);
    CheckXyMap('wcpEOL', p( 9,2,          17,1,   17,1)); // after "G"
    CheckXyMap('wcpEOL', p(10,2,          18,1,   18,1)); // after " "
    CheckXyMap('wcpEOL', p( 2,3,          19,1,   19,1)); // after "X"
    CheckXyMap('wcpEOL', p( 4,3,          21,1,   21,1)); // after "Z" EOL
    if AllowPastEOL then
    CheckXyMap('wcpEOL', p( 5,3,          22,1,   22,1)); // at EOL + 1

    CheckXyMap('wcpEOL', p( 1,4,           1,2,    1,2),
                        [c([ecDown],                  2,5,  12,2,   8,2,0),
                         c([ecDown,ecDown],           5,6,  25,2,  16,2,0,  SkipTab),
                         c([ecDown,ecDown],           2,6,  22,2,  15,2,1,  not SkipTab),
                         c([ecDown,ecDown,ecDown],    1,7,   1,3,   1,3,0,  KeepX),
                         c([ecDown,ecDown,ecDown],    5,7,   5,3,   8,3,0,  (SkipTab) and not KeepX)
                        ]);
    CheckXyMap('wcpEOL', p( 2,4,           2,2,    2,2, 0)); // before tab
    if not SkipTab then
    CheckXyMap('wcpEOL', p( 3,4,           3,2,    2,2, 1)); // 1 inside tab
    CheckXyMap('wcpEOL', p( 5,4,           5,2,    3,2, 0)); // after tab
    CheckXyMap('wcpEOL', p( 9,4,           9,2,    5,2)); // after tab, before "C"
    CheckXyMap('wcpEOL', p(10,4,          10,2,    6,2)); // after "C"
    CheckXyMap('wcpEOL', p(11,4,          11,2,    7,2)); // after " "
    CheckXyMap('wcpEOL', p( 2,5,          12,2,    8,2)); // after "D"
    CheckXyMap('wcpEOL', p( 8,5,          18,2,   14,2)); // after "H"
    if not SkipTab then
    CheckXyMap('wcpEOL', p( 9,5,          19,2,   14,2, 1)); // in #9
    if not SkipTab then
    CheckXyMap('wcpEOL', p(10,5,          20,2,   14,2, 2)); // in #9
    CheckXyMap('wcpEOL', p(11,5,          21,2,   15,2)); // after #9
    if not SkipTab then
    CheckXyMap('wcpEOL', p( 2,6,          22,2,   15,2, 1)); // in #9 / next line
    CheckXyMap('wcpEOL', p( 5,6,          25,2,   16,2)); // after 1st #9 / next line
    CheckXyMap('wcpEOL', p(10,6,          30,2,   18,2)); // after "x"
    CheckXyMap('wcpEOL', p(11,6,          31,2,   19,2)); // after "z" EOL

    CheckXyMap('wcpEOL', p( 1,7,           1,3,    1,3));
    CheckXyMap('wcpEOL', p( 2,7,           2,3,    3,3));
    CheckXyMap('wcpEOL', p( 8,7,           8,3,   14,3)); // after "ö"
    CheckXyMap('wcpEOL', p( 9,7,           9,3,   15,3)); // after " "
    CheckXyMap('wcpEOL', p( 2,8,          10,3,   17,3)); // after "Ä"
    CheckXyMap('wcpEOL', p( 9,8,          17,3,   29,3)); // after " "

    FWordWrap.CaretWrapPos := wcpBOL;
    CheckXyMap('wcpBOL', p( 1,1,           1,1,    1,1),
                        [c(ecRight,                         2,1,   2,1,    2,1,0),
                         c(ecDown,                          1,2,   9,1,    9,1,0),
                         c([ecDown,ecDown],                 1,3,  18,1,   18,1,0),
                         c([ecDown,ecDown, ecRight,ecRight],        3,3,  20,1,   20,1,0),
                         c([ecDown,ecDown, ecRight,ecRight,ecDown], 2,4,   2,2,    2,2,0, SkipTab),
                         c([ecDown,ecDown, ecRight,ecRight,ecDown], 3,4,   3,2,    2,2,1, not SkipTab),
                         c([ecDown,ecDown,ecDown],          1,4,   1,2,    1,2,0),
                         c([ecDown,ecDown,ecDown,ecDown],   1,5,  11,2,    7,2,0)
                        ]);
    CheckXyMap('wcpBOL', p( 2,1,           2,1,    2,1),
                        [c(ecDown,                          2,2,  10,1,   10,1,0)
                        ]);
    CheckXyMap('wcpBOL', p( 7,1,           7,1,    7,1)); // after "e"
    CheckXyMap('wcpBOL', p( 8,1,           8,1,    8,1));
    CheckXyMap('wcpBOL', p( 1,2,           9,1,    9,1)); // after " " / still on line 1
    CheckXyMap('wcpBOL', p( 2,2,          10,1,   10,1));
    CheckXyMap('wcpBOL', p( 9,2,          17,1,   17,1), // after "G"
                        [c([ecUp],                          8,1,   8,1,   8,1,0),
                         c([ecUp, ecDown],                  9,2,  17,1,  17,1,0,  KeepX),
                         c([ecUp, ecDown],                  8,2,  16,1,  16,1,0,  not KeepX)
                        ]);
    CheckXyMap('wcpBOL', p( 1,3,          18,1,   18,1)); // after " "
    CheckXyMap('wcpBOL', p( 2,3,          19,1,   19,1)); // after "X"
    CheckXyMap('wcpBOL', p( 4,3,          21,1,   21,1)); // after "Z" EOL
    if AllowPastEOL then
    CheckXyMap('wcpBOL', p( 5,3,          22,1,   22,1)); // at EOL + 1

    CheckXyMap('wcpBOL', p( 1,4,           1,2,    1,2),
                        [c([ecDown],                  1,5,  11,2,   7,2,0),
                         c([ecDown,ecDown],           1,6,  21,2,  15,2,0),
                         c([ecDown,ecDown,ecDown],    1,7,   1,3,   1,3,0)
                        ]);
    CheckXyMap('wcpBOL', p( 2,4,           2,2,    2,2, 0)); // before tab
    if not SkipTab then
    CheckXyMap('wcpBOL', p( 3,4,           3,2,    2,2, 1)); // 1 inside tab
    CheckXyMap('wcpBOL', p( 5,4,           5,2,    3,2, 0)); // after tab
    CheckXyMap('wcpBOL', p( 9,4,           9,2,    5,2)); // after tab, before "C"
    CheckXyMap('wcpBOL', p(10,4,          10,2,    6,2), // after "C"
                        [c([ecDown],                        8,5,  18,2,   14,2,0, SkipTab),      // G#9H#|9
                         c([ecDown],                       10,5,  20,2,   14,2,2, not SkipTab),  // G#9H#|9
                         c([ecDown,ecDown],                10,6,  30,2,   18,2,0,  KeepX),       // #9#9X|Y
                         c([ecDown,ecDown],                 5,6,  25,2,   16,2,0,  (not KeepX) and SkipTab)    // #9#9X|Y
                        ]);
    CheckXyMap('wcpBOL', p( 1,5,          11,2,    7,2)); // after " "
    CheckXyMap('wcpBOL', p( 2,5,          12,2,    8,2)); // after "D"
    CheckXyMap('wcpBOL', p( 8,5,          18,2,   14,2)); // after "H"
    if not SkipTab then
    CheckXyMap('wcpBOL', p( 9,5,          19,2,   14,2, 1)); // in #9
    if not SkipTab then
    CheckXyMap('wcpBOL', p(10,5,          20,2,   14,2, 2)); // in #9
    CheckXyMap('wcpBOL', p( 1,6,          21,2,   15,2)); // after #9
    if not SkipTab then
    CheckXyMap('wcpBOL', p( 2,6,          22,2,   15,2, 1)); // in #9 / next line
    CheckXyMap('wcpBOL', p( 5,6,          25,2,   16,2)); // after 1st #9 / next line
    CheckXyMap('wcpBOL', p(10,6,          30,2,   18,2)); // after "x"
    CheckXyMap('wcpBOL', p(11,6,          31,2,   19,2), // after "y" EOL
                        [c([ecUp],                        8,5,  18,2,   14,2,0, SkipTab),      // G#9H#|9
                         c([ecUp],                       10,5,  20,2,   14,2,2, not SkipTab),  // G#9H#|9
                         c([ecUp,ecDown],                11,6,  31,2,   19,2,0,  KeepX)
                        ]);

    CheckXyMap('wcpBOL', p( 1,7,           1,3,    1,3));
    CheckXyMap('wcpBOL', p( 2,7,           2,3,    3,3));
    CheckXyMap('wcpBOL', p( 8,7,           8,3,   14,3)); // after "ö"
    CheckXyMap('wcpBOL', p( 1,8,           9,3,   15,3)); // after " "
    CheckXyMap('wcpBOL', p( 2,8,          10,3,   17,3)); // after "Ä"
    CheckXyMap('wcpBOL', p( 1,9,          17,3,   29,3)); // after " "

    //FWordWrap.CaretWrapPos := wcpBOL;

    FWordWrap.CaretWrapPos := wcpEOL;
    // viewed phys log  x,y
    // line 5 (idx=4)
    CheckXyMap('RTL', p( 2,11,           2,5,    2,5)); // after A
    CheckXyMap('RTL', p( 3,11,           3,5,    3,5)); // after A space  // befare first RTL / could be PX = 6
    CheckXyMap('RTL', p( 5,11,           5,5,    5,5)); // after first RTL
    CheckXyMap('RTL', p( 4,11,           4,5,    7,5)); // after 2nd RTL
    CheckXyMap('RTL', p( 6,11,           6,5,    9,5)); // after 3rd RTL  // before space / could be PX=3
    CheckXyMap('RTL', p( 7,11,           7,5,   10,5)); // after 2nd space
    CheckXyMap('RTL', p( 8,11,           8,5,   11,5)); // after X

    // line 6 (idx=5)
    CheckXyMap('RTL', p( 8,12,           8,6,   11,6)); // after X
    CheckXyMap('RTL', p( 9,12,           9,6,   12,6)); // after X space
    CheckXyMap('RTL', p( 2,13,          10,6,   13,6)); // after F of Foo

    // line 7 (idx=6)
    CheckXyMap('RTL', p(11,14,          11,7,   14,7)); // after last space in first line
    CheckXyMap('RTL', p( 2,15,          12,7,   15,7)); // after F of Foo (subline)

    // line 8 (idx=7)
    CheckXyMap('RTL', p(11,16,          11,8,   14,8)); // after last RTL
    CheckXyMap('RTL', p( 2,17,          12,8,   15,8)); // after space, before Foo (subline)

    // line 9 (idx=8)
    FWordWrap.CaretWrapPos := wcpBOL;
    CheckXyMap('RTL BOL', p( 1,19,          11,9,   11,9)); // subline at start (before first RTL)
    CheckXyMap('RTL BOL', p( 3,19,          13,9,   13,9)); // subline (after first RTL)
    CheckXyMap('RTL BOL', p( 2,19,          12,9,   15,9)); // subline (after 2nd RTL)
    FWordWrap.CaretWrapPos := wcpEOL;
    CheckXyMap('RTL', p(11,18,          11,9,   11,9)); // at end of first line
    CheckXyMap('RTL', p( 3,19,          13,9,   13,9)); // subline (after first RTL)
    CheckXyMap('RTL', p( 2,19,          12,9,   15,9)); // subline (after 2nd RTL)

    // line 10 (idx=9)  / Virt 20

    // line 11 (idx=10)  / Virt 22
    (* The space at the end of the first line is the space between the 2 RTL sequences.
       (the space is part of the overall RTL sequence)
       That space is therefore displayed at the left end of the RTL run.
       I.e. On the screen it is right after the normal space from "ABCDE "
       The RTL sequence in the first line is the sequence from the right of the RTL run
    *)
    FWordWrap.CaretWrapPos := wcpEOL;
    CheckXyMap('RTL', p(10,22,          13,11,   9,11)); // after first RTL (first line)
    CheckXyMap('RTL', p( 9,22,          12,11,  11,11)); // after 2nd RTL (first line)
    CheckXyMap('RTL', p( 8,22,          11,11,  13,11)); // after 3rd / before space
// The viewed-x is between the leading LTR and the RTL text. So it can not be distinguished
//    CheckXyMap('RTL', p( 7,22,          10,11,  14,11)); // after space  //???????????? TEST BOL <> EOL

//  same at the end
//    CheckXyMap('RTL', p( 3,23,           9,11,  16,11)); // 1st subline: after 1st RTL (2nd sequence)
    CheckXyMap('RTL', p( 2,23,           8,11,  18,11)); // 1st subline: after 2nd RTL (2nd sequence)
    CheckXyMap('RTL', p( 4,23,          14,11,  20,11)); // 1st subline: after 3rd RTL (2nd sequence) => go to LTR sequence


  end;


  CheckLineIndexMapping('LineMap 0',   0,   0, 2);
  CheckLineIndexMapping('LineMap 1',   1,   3, 5);
  CheckLineIndexMapping('LineMap 2',   2,   6, 8);
  CheckLineIndexMapping('LineMap 3',   3,   9, 9);


  SynEdit.ExecuteCommand(ecEditorBottom, '', nil);
  AssertEquals('ecEditorBottom', 15 ,SynEdit.CaretY);
  AssertEquals('ecEditorBottom', 34 ,SynEdit.CaretObj.ViewedLineCharPos.y);

  SetSynEditWidth(65);
  AddLines(0, 6000, 60, 'A');

  CheckLine('', 0, 'A_0_0');
  CheckLine('', 1, 'A_1_0');
  CheckLine('', 2, 'A_2_0');
  CheckLine('', 3, 'A_3_0');

  SetSynEditWidth(35);
  CheckLine('', 0, 'A_0_0');
  CheckLine('', 1, 'A_0_3');
  CheckLine('', 2, 'A_1_0');

// '		'

end;

procedure TTestWordWrapPlugin.TestWrapSplitJoin;
  procedure AddLineTestCount(AName: String; ALineIdx, ACount, ALen: Integer; AExpCount: Integer);
  begin
    AddLines(ALineIdx, ACount, ALen, 'A');
    AssertEquals(Format('%s : After ins %d Line(s) at %d  Len %d', [AName, ACount, ALineIdx, ALen]), AExpCount, TreeNodeCount);
  end;
  procedure AddLineTestCount(AName: String; ALineIdx, ALen: Integer; AExpCount: Integer);
  begin
    AddLineTestCount(AName, ALineIdx, 1, ALen, AExpCount);
  end;

  procedure ChangeLineTestCount(AName: String; ALineIdx, ALen: Integer; AExpCount: Integer);
  begin
    AddLines(ALineIdx, 1, ALen, 'A', False, True);
    AssertEquals(Format('%s : After ins %d Line(s) at %d  Len %d', [AName, 1, ALineIdx, ALen]), AExpCount, TreeNodeCount);
  end;
  procedure ChangeLineTestCount(AName: String; ALineIdx, ANodeIdx, ALen: Integer; AExpCount: Integer);
  var
    n: TSynEditLineMapPageHolder;
  begin
    n := TreeNodeHolder[ANodeIdx];
    if ALineIdx >= 0
    then AddLines(n.RealStartLine + ALineIdx, 1, ALen, 'A', False, True)
    else AddLines(n.RealEndLine + 1 + ALineIdx, 1, ALen, 'A', False, True);
    AssertEquals(Format('%s : After ins %d Line(s) at %d  Len %d', [AName, 1, ALineIdx, ALen]), AExpCount, TreeNodeCount);
  end;

  procedure DelLineTestCount(AName: String; ALineIdx: Integer; AExpCount: Integer);
  begin
    if ALineIdx < 0
    then SynEdit.Lines.Delete(SynEdit.Lines.Count + 1 + ALineIdx)
    else SynEdit.Lines.Delete(ALineIdx);
    AssertEquals(Format('%s : After DEL Line at %d  Len %d', [AName, ALineIdx]), AExpCount, TreeNodeCount);
  end;
  procedure DelLineTestCount(AName: String; ANodeIdx, ALineIdx: Integer; AExpCount: Integer);
  var
    n: TSynEditLineMapPageHolder;
  begin
    n := TreeNodeHolder[ANodeIdx];
    if ALineIdx < 0
    then SynEdit.Lines.Delete(n.RealEndLine + 1 + ALineIdx)
    else SynEdit.Lines.Delete(n.RealStartLine + ALineIdx);
    AssertEquals(Format('%s : After DEL Line at %d  Len %d', [AName, ALineIdx]), AExpCount, TreeNodeCount);
  end;

var
  t: TSynLineMapAVLTree;
  n1, n2: TSynEditLineMapPageHolder;
  i: Integer;
begin
  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
debugln(' split %d  join %d  dist %d', [t.PageSplitSize, t.PageJoinSize, t.PageJoinDistance]);

  AddLineTestCount('new: split - 2', 0, t.PageSplitSize - 2, 18,    1);
  AddLineTestCount('insert start: split - 1', 0, 18,    1);
  AddLineTestCount('insert start: split - 0', 0, 18,    1);
  AddLineTestCount('insert start: split + 1', 0, 18,    2);
  AddLineTestCount('insert start: split + 2', 0, 18,    2);


  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
  AddLineTestCount('new: split - 2', 0, t.PageSplitSize - 2, 18,    1);
  AddLineTestCount('insert end: split - 1', SynEdit.Lines.Count, 18,    1);
  AddLineTestCount('insert end: split - 0', SynEdit.Lines.Count, 18,    1);
  AddLineTestCount('insert end: split + 1', SynEdit.Lines.Count, 18,    2);
  AddLineTestCount('insert end: split + 2', SynEdit.Lines.Count, 18,    2);


  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
  AddLineTestCount('new: split - 2', 0, t.PageSplitSize - 2, 18,    1);
  AddLineTestCount('insert @10: split - 1', 10, 18,    1);
  AddLineTestCount('insert @10: split - 0', 10, 18,    1);
  AddLineTestCount('insert @10: split + 1', 10, 18,    2);
  AddLineTestCount('insert @10: split + 2', 10, 18,    2);


  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
  i := t.PageSplitSize - 2;
  AddLineTestCount('new: split - 2', 0,  i, 18,    1);
  AddLineTestCount('new: split - 2', i, 10,  1,    1);
  ChangeLineTestCount('update end: split - 1', i, 18,   1);   inc(i);
  ChangeLineTestCount('update end: split - 0', i, 18,   1);   inc(i);
  ChangeLineTestCount('update end: split + 1', i, 18,   2);   inc(i);
  ChangeLineTestCount('update end: split + 2', i, 18,   2);   inc(i);


  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
  i := 9;
  AddLineTestCount('new: split - 2', 0,  t.PageSplitSize - 2, 18,    1);
  AddLineTestCount('new: split - 2', 0, 10,  1,    1);
  ChangeLineTestCount('update start: split - 1', i, 18,   1);   dec(i);
  ChangeLineTestCount('update start: split - 0', i, 18,   1);   dec(i);
  ChangeLineTestCount('update start: split + 1', i, 18,   2);   dec(i);
  ChangeLineTestCount('update start: split + 2', i, 18,   2);   dec(i);



  ///////////////////
  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
  AddLineTestCount('new: split double', 0,  t.PageSplitSize + t.PageJoinSize + 2, 18,    2);


  n1 := TreeNodeHolder[0];
  while n1.RealCount > t.PageJoinSize + 1 do
    SynEdit.Lines.Delete(n1.RealStartLine + 2);
  AssertEquals('insert start: split + 2', 2, TreeNodeCount);

  n2 := TreeNodeHolder[1];
  while n2.RealCount > t.PageJoinSize + 1 do
    SynEdit.Lines.Delete(n2.RealStartLine + 2);
  AssertEquals('insert start: split + 2', 2, TreeNodeCount);

  SynEdit.Lines.Delete(1);
  SynEdit.Lines.Delete(SynEdit.Lines.Count - 2);

  AssertEquals('insert start: split + 2', 1, TreeNodeCount);





  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
  AddLineTestCount('new: split double', 0,  t.PageSplitSize + t.PageJoinSize + 2, 18,    2);


  n1 := TreeNodeHolder[0];
  while n1.RealCount > t.PageJoinSize + 1 do
    ChangeLineTestCount('edit n1 start', 0,0,  1,   2);
  n2 := TreeNodeHolder[1];
  while n2.RealCount > t.PageJoinSize + 1 do
    ChangeLineTestCount('edit n2 end', -1,1,  1,   2);

  ChangeLineTestCount('edit n1 start',  0,0,  1,   2);
  ChangeLineTestCount('edit n2 end  ', -1,1,  1,   1);




  // do not join
  ReCreateEdit(10);
  SynEdit.Options := [];
  t := FWordWrap.LineMappingData;
  AddLineTestCount('new: split * 2 - 2', 0,  t.PageSplitSize * 2 - 2, 18,    2);


  n1 := TreeNodeHolder[0];
  while n1.RealCount > t.PageJoinSize + 1 do
    ChangeLineTestCount('edit n1 end', -1,0,  1,   2);
  n2 := TreeNodeHolder[1];
  while n2.RealCount > t.PageJoinSize + 1 do
    ChangeLineTestCount('edit n2 start', 0,1,  1,   2);

  ChangeLineTestCount('edit n1 start', -1,0,  1,   2);
  ChangeLineTestCount('edit n2 end  ',  0,1,  1,   2);
  ChangeLineTestCount('edit n1 start', -1,0,  1,   2);
  ChangeLineTestCount('edit n2 end  ',  0,1,  1,   2);
  ChangeLineTestCount('edit n1 start', -1,0,  1,   2);
  ChangeLineTestCount('edit n2 end  ',  0,1,  1,   2);



end;

procedure TTestWordWrapPlugin.TestEditorEdit;
begin
  SynEdit.Options := [];
  SynEdit.TabWidth := 4;

  SetLines([
    'abc def ' + 'ABC DEFG ' + 'XYZ',
    '',
    //'A'  #9'B'  #9'C ' + 'DEF G'#9'H'  #9 + ''   #9   #9'xy',
    'A'#9'B'#9'C ' + 'DEF G'#9'H'#9 + #9#9'xy',
    '',
    'äää ööö ' + 'ÄÄÄ ÖÖÖ ' + 'ÜÜÜ',
    '',
    '999'
  ]);
  SetSynEditWidth(10);

  SetSynEditWidth(10);
  CheckLines('', 0, [
    'abc def ',
    'ABC DEFG ',
    'XYZ',
    '',
    'A'#9'B'#9'C ',
    'DEF G'#9'H'#9,
    #9#9'xy',
    '',
    'äää ööö ',
    'ÄÄÄ ÖÖÖ ',
    'ÜÜÜ',
    '',
    '999'
  ], True);

  SynEdit.BeginUpdate;
  SynEdit.TestTypeText(1,7, '4 ');
  SynEdit.TestTypeText(1,3, '2 ');
  SynEdit.TestTypeText(1,5, '3 ');
  SynEdit.TestTypeText(1,1, '1 ');
  SynEdit.EndUpdate;

  CheckLines('', 0, [
    '1 abc def ',
    'ABC DEFG ',
    'XYZ',
    '',
    '2 A'#9'B'#9'C ',
    'DEF G'#9'H'#9,
    #9#9'xy',
    '',
    '3 äää ööö ',
    'ÄÄÄ ÖÖÖ ',
    'ÜÜÜ',
    '',
    '4 999'
  ], True);
end;

initialization

  RegisterTest(TTestWordWrap);
  RegisterTest(TTestWordWrapPlugin);
end.

