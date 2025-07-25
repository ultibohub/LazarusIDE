unit Test_ChildSizing;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpcunit, testutils, testregistry, Controls, Forms;

type
  TIntegerArray = array of integer;

  { TTestWinControl }

  TTestWinControl = class(TWinControl)
  private
    FTestVisible: boolean;
    FPrefWidth, FPrefHeight: Integer;
  protected
    procedure CreateHandle; override;
    procedure DestroyHandle; override;
    function IsVisible: Boolean; override;
    function IsControlVisible: Boolean; override;
    procedure GetPreferredSize(var PreferredWidth, PreferredHeight: Integer; Raw: Boolean = false;
      WithThemeSpace: Boolean = true); override;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure SetTestPrefSize(APrefWidth, APrefHeight: Integer);
    property TestVisible: boolean read FTestVisible write FTestVisible;
  end;

  { TTestChild }

  TTestChild = class(TTestWinControl)
  public
    constructor Create(TheOwner: TWinControl);
    constructor Create(TheOwner: TWinControl; APrefWidth, APrefHeight: Integer);
  end;

  { TTestContainer }

  TTestContainer = class(TTestWinControl)
  protected
    function AutoSizeDelayedHandle: Boolean; override;
  public
  end;

  TTestChildArray = array of TTestChild;

  { TTestChildSizing }

  TTestChildSizing = class(TTestCase)
  private
    FContainer: TTestContainer;
    FTestForm: TForm;
  protected
    class procedure AssertApprox(Expected, Actual: integer; AnAllowance: Integer = 1);
    class procedure AssertApprox(AName: String; Expected, Actual: integer);
    class procedure AssertNoDecrementInList(ANew,AOld: TIntegerArray);
    class procedure AssertMaxOneDecrementInList(ANew,AOld: TIntegerArray);
    procedure EnableAutoSizing(c: TWinControl); virtual;
    procedure DisableAutoSizing(c: TWinControl); virtual;
    procedure Init1(
      out P: TTestContainer; AContainerWidth: integer;
      AStyle: TChildControlResizeStyle; APerLine: Integer;
      out C: TTestChildArray; AWidths: array of integer;
      AInitContainerHeight: boolean = False);
    procedure AddPaddingAround(var C: TTestChildArray; APadding: integer; ALowIdx: Integer = -1; AHighIdx: integer = -1);
    function GetLefts(C: TTestChildArray; ALowIdx, AHighIdx: integer): TIntegerArray;
    function GetWidths(C: TTestChildArray; ALowIdx, AHighIdx: integer): TIntegerArray;
    function SumWidths(C: TTestChildArray; ALowIdx, AHighIdx: integer): integer;
    function GetSpaces(C: TTestChildArray; AStartX, ATotalWidth, ALowIdx, AHighIdx: integer): TIntegerArray;
    function SumSpaces(s: TIntegerArray): integer;
  public
    class procedure AssertZero(Expected, Actual: integer); overload;
    procedure TearDown; override;
  published
    procedure TestAnchorAlign;
    procedure TestAnchorAlignBideRTL;
    procedure TestScaleChilds;
    procedure TestScaleChildsConstrained;
    procedure TestScaleChildsBidiRtl;
    procedure TestSameSize;
    procedure TestSameSizeConstrained;
    procedure TestHomogenousChildResize;
    procedure TestHomogenousChildResizeConstrained;
    procedure TestHomogenousSpaceResize;
    procedure TestCalculateCellConstraints;
  end;

  { TTestChildSizingWithTempAutoSizing }

  TTestChildSizingWithTempAutoSizing = class(TTestChildSizing)
  protected
    // Do nothing / let every change compute the size
    procedure EnableAutoSizing(c: TWinControl); override;
    procedure DisableAutoSizing(c: TWinControl); override;
  end;

implementation

const
  {$IFDEF LCLNOGUI}
  MIN_CTRL_WIDTH = 0;
  {$ELSE}
    {$IFDEF LCLTESTMOCK}
  MIN_CTRL_WIDTH = 0;
    {$ELSE}
  MIN_CTRL_WIDTH = 1; // Not every WS allows the containes to have size zero
    {$ENDIF}
  {$ENDIF}
  MIN_CONTAINER_WIDTH = 3 * MIN_CTRL_WIDTH; // container (3 columns)


{ TTestWinControl }

procedure TTestWinControl.CreateHandle;
begin
  {$IFDEF LCLNOGUI}
  Handle := 1;
  {$ELSE}
  inherited;
  {$ENDIF}
end;

procedure TTestWinControl.DestroyHandle;
begin
  {$IFDEF LCLNOGUI}
  {$ELSE}
  inherited;
  {$ENDIF}
end;

function TTestWinControl.IsVisible: Boolean;
begin
  Result := FTestVisible;
end;

function TTestWinControl.IsControlVisible: Boolean;
begin
  Result := FTestVisible;
end;

procedure TTestWinControl.GetPreferredSize(var PreferredWidth, PreferredHeight: Integer;
  Raw: Boolean; WithThemeSpace: Boolean);
begin
  PreferredWidth := FPrefWidth;
  PreferredHeight := FPrefHeight;
end;

constructor TTestWinControl.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FTestVisible := True;
end;

procedure TTestWinControl.SetTestPrefSize(APrefWidth, APrefHeight: Integer);
begin
  FPrefWidth := APrefWidth;
  FPrefHeight := APrefHeight;
  AdjustSize;
end;

{ TTestChild }

constructor TTestChild.Create(TheOwner: TWinControl);
begin
  inherited Create(TheOwner);
  Parent := TheOwner;
end;

constructor TTestChild.Create(TheOwner: TWinControl; APrefWidth, APrefHeight: Integer);
begin
  Create(TheOwner);
  SetTestPrefSize(APrefWidth, APrefHeight);
end;

{ TTestContainer }

function TTestContainer.AutoSizeDelayedHandle: Boolean;
begin
  Result := False;
end;

{ TTestChildSizing }

class procedure TTestChildSizing.AssertApprox(Expected, Actual: integer; AnAllowance: Integer);
begin
  if (Actual >= Expected) and (Actual <= Expected + AnAllowance) then Actual := Expected;
  AssertEquals(Expected, Actual);
end;

class procedure TTestChildSizing.AssertApprox(AName: String; Expected, Actual: integer);
begin
  if Actual = Expected + 1 then dec(Actual);
  AssertEquals(AName, Expected, Actual);
end;

class procedure TTestChildSizing.AssertNoDecrementInList(ANew, AOld: TIntegerArray);
var
  i: Integer;
begin
  AssertEquals('NO DECR', Length(ANew), Length(AOld));
  for i := 0 to Length(ANew) - 1 do
    AssertTrue('NO DECR', ANew[i] >= AOld[i]);
end;

class procedure TTestChildSizing.AssertMaxOneDecrementInList(ANew, AOld: TIntegerArray);
var
  i: Integer;
begin
  AssertEquals('MAX ONE DECR', Length(ANew), Length(AOld));
  for i := 0 to Length(ANew) - 1 do
    AssertTrue('MAX ONE DECR', ANew[i] >= AOld[i]-1);
end;

procedure TTestChildSizing.EnableAutoSizing(c: TWinControl);
begin
  c.EnableAutoSizing;
end;

procedure TTestChildSizing.DisableAutoSizing(c: TWinControl);
begin
  c.DisableAutoSizing;
end;

procedure TTestChildSizing.Init1(out P: TTestContainer; AContainerWidth: integer;
  AStyle: TChildControlResizeStyle; APerLine: Integer; out C: TTestChildArray;
  AWidths: array of integer; AInitContainerHeight: boolean);
var
  i: Integer;
begin
  {$IFnDEF LCLNOGUI}
  if FTestForm = nil then begin
    FTestForm := TForm.CreateNew(nil);
    FTestForm.SetBounds(10,10,100,100);
    FTestForm.Show;
  end;
  {$ENDIF}

  P := TTestContainer.Create(FTestForm);
  p.Parent := FTestForm;
  if AInitContainerHeight then begin
    P.SetBounds(0,0, 150, AContainerWidth);
    p.ChildSizing.ControlsPerLine := APerLine;
    p.ChildSizing.EnlargeVertical := AStyle;
    p.ChildSizing.ShrinkVertical  := AStyle;
    p.ChildSizing.Layout := cclTopToBottomThenLeftToRight;
  end
  else begin
    P.SetBounds(0,0, AContainerWidth, 150);
    p.ChildSizing.ControlsPerLine := APerLine;
    p.ChildSizing.EnlargeHorizontal := AStyle;
    p.ChildSizing.ShrinkHorizontal  := AStyle;
    p.ChildSizing.Layout := cclLeftToRightThenTopToBottom;
  end;

  DisableAutoSizing(p);
  SetLength(C, Length(AWidths));
  for i := 0 to Length(AWidths) - 1 do
    if AInitContainerHeight then
      C[i] := TTestChild.Create(P, 10, AWidths[i])
    else
      C[i] := TTestChild.Create(P, AWidths[i], 10);
  EnableAutoSizing(P);
end;

procedure TTestChildSizing.AddPaddingAround(var C: TTestChildArray; APadding: integer;
  ALowIdx: Integer; AHighIdx: integer);
var
  i: Integer;
begin
  if ALowIdx = -1 then ALowIdx := low(C);
  if AHighIdx = -1 then AHighIdx := High(C);
  DisableAutoSizing(FContainer);
  for i := ALowIdx to AHighIdx do
    C[i].BorderSpacing.Around := APadding;
  EnableAutoSizing(FContainer);
end;

function TTestChildSizing.GetLefts(C: TTestChildArray; ALowIdx, AHighIdx: integer): TIntegerArray;
var
  i: Integer;
begin
  SetLength(Result, AHighIdx - ALowIdx + 1);
  for i := ALowIdx to AHighIdx do
    Result[i-ALowIdx] := C[i].Left;
end;

function TTestChildSizing.GetWidths(C: TTestChildArray; ALowIdx, AHighIdx: integer): TIntegerArray;
var
  i: Integer;
begin
  SetLength(Result, AHighIdx - ALowIdx + 1);
  for i := ALowIdx to AHighIdx do
    Result[i-ALowIdx] := C[i].Width;
end;

function TTestChildSizing.SumWidths(C: TTestChildArray; ALowIdx, AHighIdx: integer): integer;
var
  i: Integer;
begin
  Result := 0;
  for i := ALowIdx to AHighIdx do
    Result := Result + C[i].Width;
end;

function TTestChildSizing.GetSpaces(C: TTestChildArray; AStartX, ATotalWidth, ALowIdx,
  AHighIdx: integer): TIntegerArray;
var
  i: Integer;
begin
  SetLength(Result, AHighIdx - ALowIdx + 2);
  Result[0] := C[ALowIdx].Left - AStartX;
  for i := ALowIdx to AHighIdx - 1 do
    Result[1+i-ALowIdx] := C[i+1].Left - (C[i].Left + C[i].Width);
  Result[1+AHighIdx-ALowIdx] := ATotalWidth - (C[AHighIdx].Left + C[AHighIdx].Width);
end;

function TTestChildSizing.SumSpaces(s: TIntegerArray): integer;
var
  i: Integer;
begin
  Result := 0;
  for i := low(s) to High(s) do
    Result := Result + s[i];
end;

class procedure TTestChildSizing.AssertZero(Expected, Actual: integer);
begin
  if Expected = 0 then begin
    if Expected = Actual then
      exit;
    if MIN_CTRL_WIDTH = Actual then
      exit;
  end;
  AssertEquals(Expected, Actual);
end;

procedure TTestChildSizing.TearDown;
begin
  inherited TearDown;
  FreeAndNil(FContainer);
  FreeAndNil(FTestForm);
end;

procedure TTestChildSizing.TestAnchorAlign;
var
  C: TTestChildArray;
  ALeftSpace, AMidSpace, ACtrlSpace, j, L1, L2, L3: Integer;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  for ACtrlSpace := 0 to 2 do
  begin
    Init1(FContainer, 300, crsAnchorAligning, 3, C,
          [20, 70, 30,
           25, 35  {-}]);
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    AddPaddingAround(C, ACtrlSpace);
    EnableAutoSizing(FContainer);

    AssertEquals(25,  C[0].Width);
    AssertEquals(25,  C[3].Width);
    AssertEquals(70,  C[1].Width);
    AssertEquals(70,  C[4].Width);
    AssertEquals(30,  C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 150 do begin
      FContainer.Width := j;
      L1 := Max(ALeftSpace, ACtrlSpace);
      AssertEquals(L1, C[0].Left);
      AssertEquals(L1, C[3].Left);
      AssertEquals(25,  C[0].Width);
      AssertEquals(25,  C[3].Width);
      L2 := L1 + 25 + Max(AMidSpace, ACtrlSpace);
      AssertEquals(L2, C[1].Left);
      AssertEquals(L2, C[4].Left);
      AssertEquals(70,  C[1].Width);
      AssertEquals(70,  C[4].Width);
      L3 := L2 + 70 + Max(AMidSpace, ACtrlSpace);
      AssertEquals(L3, C[2].Left);
      AssertEquals(30,  C[2].Width);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestAnchorAlignBideRTL;
var
  C: TTestChildArray;
  ALeftSpace, AMidSpace, ACtrlSpace, j, L1, L2, L3: Integer;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  for ACtrlSpace := 0 to 2 do
  begin
    Init1(FContainer, 300, crsAnchorAligning, 3, C,
          [20, 70, 30,
           25, 35  {-}]);
    FContainer.BiDiMode := bdRightToLeft;
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    AddPaddingAround(C, ACtrlSpace);
    EnableAutoSizing(FContainer);

    AssertEquals(25,  C[0].Width);
    AssertEquals(25,  C[3].Width);
    AssertEquals(70,  C[1].Width);
    AssertEquals(70,  C[4].Width);
    AssertEquals(30,  C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 150 do begin
      FContainer.Width := j;
      L1 := j - Max(ALeftSpace, ACtrlSpace) - 25;
      AssertEquals(L1, C[0].Left);
      AssertEquals(L1, C[3].Left);
      AssertEquals(25,  C[0].Width);
      AssertEquals(25,  C[3].Width);
      L2 := L1 - Max(AMidSpace, ACtrlSpace) - 70;
      AssertEquals(L2, C[1].Left);
      AssertEquals(L2, C[4].Left);
      AssertEquals(70,  C[1].Width);
      AssertEquals(70,  C[4].Width);
      L3 := L2 - Max(AMidSpace, ACtrlSpace) - 30;
      AssertEquals(L3, C[2].Left);
      AssertEquals(30,  C[2].Width);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestScaleChilds;
var
  C: TTestChildArray;
  i, MinVal, ALeftSpace, AMidSpace, ACtrlSpace, TotalSpace, j, k: Integer;
  WList, OldWList, LList, OldLList: TIntegerArray;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  for ACtrlSpace := 0 to 2 do
  begin
    TotalSpace := 2*Max(ALeftSpace, ACtrlSpace) + 2*Max(AMidSpace, ACtrlSpace);
    Init1(FContainer, 300 + TotalSpace,crsScaleChilds, 3, C,
          [20, 70, 30,
           20, 35  {-}]);
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    AddPaddingAround(C, ACtrlSpace);
    EnableAutoSizing(FContainer);

    AssertEquals(50,  C[0].Width);
    AssertEquals(50,  C[3].Width);
    AssertEquals(175, C[1].Width);
    AssertEquals(175, C[4].Width);
    AssertEquals(75,  C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 1000 do begin
      FContainer.Width := j;
      i := Max(0, j - TotalSpace);
      MinVal := 1;
      if i <= 2 then MinVal := 0;

      WList := GetWidths(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertMaxOneDecrementInList(WList, OldWList);
      OldWList := WList;
      LList := GetLefts(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertNoDecrementInList(LList, OldLList);
      OldLList := LList;

      k := 0;
      if i < 4 then k := -1; // column 2 may be restricted by others forced to 1
      if i >= MIN_CONTAINER_WIDTH then
        AssertEquals('Total Width', i, SumWidths(C, 0, 2));
      AssertApprox(Max(MinVal, 20 * i div 120), C[0].Width);
      AssertApprox(Max(MinVal, 20 * i div 120), C[3].Width);
      AssertApprox(Max(MinVal, 70 * i div 120 + k), C[1].Width);
      AssertApprox(Max(MinVal, 70 * i div 120 + k), C[4].Width);
      AssertApprox(Max(MinVal, 30 * i div 120), C[2].Width);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + 0, C[0].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + 0, C[3].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) + C[0].Width, C[1].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) + C[0].Width, C[4].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) * 2 + C[0].Width+C[1].Width, C[2].Left);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestScaleChildsConstrained;
var
  C: TTestChildArray;
  i, MinVal, ALeftSpace, AMidSpace, TotalSpace, j, k: Integer;
  WList, OldWList, LList, OldLList: TIntegerArray;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  begin
    TotalSpace := 2*ALeftSpace + 2*AMidSpace;
    Init1(FContainer, 170 + TotalSpace,crsScaleChilds, 3, C,
          [20, 40, 30,
           20, 35  {-}]);
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    c[1].Constraints.MinWidth := 35;
    c[1].Constraints.MaxWidth := 45;
    c[4].Constraints.MinWidth := 35;
    c[4].Constraints.MaxWidth := 45;
    EnableAutoSizing(FContainer);

    AssertEquals(50,  C[0].Width);
    AssertEquals(50,  C[3].Width);
    AssertEquals(45,  C[1].Width);
    AssertEquals(45,  C[4].Width);
    AssertEquals(75,  C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 1000 do begin
      FContainer.Width := j;
      i := Max(0, j - TotalSpace);
      MinVal := 1;
      if i < 2+35 then MinVal := 0;

      WList := GetWidths(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertMaxOneDecrementInList(WList, OldWList);
      OldWList := WList;
      LList := GetLefts(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertNoDecrementInList(LList, OldLList);
      OldLList := LList;

      if i >= MIN_CONTAINER_WIDTH*38 then
        AssertEquals('Total Width', Max(35, i), SumWidths(C, 0, 2));

      if i <= 35 then begin
        AssertZero(MinVal, C[0].Width);
        AssertZero(MinVal, C[3].Width);
        AssertEquals(35,     C[1].Width);
        AssertEquals(35,     C[4].Width);
        AssertZero(MinVal, C[2].Width);
      end
      else
      if i <= 80 then begin
        AssertApprox(Max(MinVal, 20 * (i-35) div 50), C[0].Width);
        AssertApprox(Max(MinVal, 20 * (i-35) div 50), C[3].Width);
        AssertEquals(35,     C[1].Width);
        AssertEquals(35,     C[4].Width);
        AssertApprox(Max(MinVal, 30 * (i-35) div 50), C[2].Width);
      end
      else
      if i <= 101 then begin
        AssertApprox(20 * i div 90, C[0].Width);
        AssertApprox(20 * i div 90, C[3].Width);
        AssertApprox(40 * i div 90, C[1].Width);
        AssertApprox(40 * i div 90, C[4].Width);
        AssertApprox(30 * i div 90, C[2].Width);
      end
      else
      begin
        AssertApprox(20 * (i-45) div 50, C[0].Width);
        AssertApprox(20 * (i-45) div 50, C[3].Width);
        AssertEquals(45,                 C[1].Width);
        AssertEquals(45,                 C[4].Width);
        AssertApprox(30 * (i-45) div 50, C[2].Width);
      end;

      AssertEquals(ALeftSpace + 0, C[0].Left);
      AssertEquals(ALeftSpace + 0, C[3].Left);
      AssertEquals(ALeftSpace + AMidSpace + C[0].Width, C[1].Left);
      AssertEquals(ALeftSpace + AMidSpace + C[0].Width, C[4].Left);
      AssertEquals(ALeftSpace + AMidSpace * 2 + C[0].Width+C[1].Width, C[2].Left);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestScaleChildsBidiRtl;
var
  C: TTestChildArray;
  i, MinVal, ALeftSpace, AMidSpace, ACtrlSpace, TotalSpace, j, k, L1, L2, L3: Integer;
  WList, OldWList, LList, OldLList: TIntegerArray;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  for ACtrlSpace := 0 to 2 do
  begin
    TotalSpace := 2*Max(ALeftSpace, ACtrlSpace) + 2*Max(AMidSpace, ACtrlSpace);
    Init1(FContainer, 300 + TotalSpace,crsScaleChilds, 3, C,
          [20, 70, 30,
           20, 35  {-}]);
    FContainer.BiDiMode := bdRightToLeft;
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    AddPaddingAround(C, ACtrlSpace);
    EnableAutoSizing(FContainer);

    AssertEquals(50,  C[0].Width);
    AssertEquals(50,  C[3].Width);
    AssertEquals(175, C[1].Width);
    AssertEquals(175, C[4].Width);
    AssertEquals(75,  C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 200 do begin
      FContainer.Width := j;
      i := Max(0, j - TotalSpace);
      MinVal := 1;
      if i <= 2 then MinVal := 0;

      WList := GetWidths(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertMaxOneDecrementInList(WList, OldWList);
      OldWList := WList;
      LList := GetLefts(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertNoDecrementInList(LList, OldLList);
      OldLList := LList;

      k := 0;
      if i < 4 then k := -1; // column 2 may be restricted by others forced to 1
      if i >= MIN_CONTAINER_WIDTH then
        AssertEquals('Total Width', i, SumWidths(C, 0, 2));
      AssertApprox(Max(MinVal, 20 * i div 120), C[0].Width);
      AssertApprox(Max(MinVal, 20 * i div 120), C[3].Width);
      AssertApprox(Max(MinVal, 70 * i div 120 + k), C[1].Width);
      AssertApprox(Max(MinVal, 70 * i div 120 + k), C[4].Width);
      AssertApprox(Max(MinVal, 30 * i div 120), C[2].Width);
      L1 := j - Max(ALeftSpace, ACtrlSpace) - C[0].Width;
      AssertEquals(L1, C[0].Left);
      AssertEquals(L1, C[3].Left);
      L2 := L1 - Max(AMidSpace, ACtrlSpace) - C[1].Width;
      AssertEquals(L2, C[1].Left);
      AssertEquals(L2, C[4].Left);
      L3 := L2 - Max(AMidSpace, ACtrlSpace) - C[2].Width;
      AssertEquals(L3, C[2].Left);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestSameSize;
var
  C: TTestChildArray;
  i, MinVal, ALeftSpace, AMidSpace, ACtrlSpace, TotalSpace, j: Integer;
  WList, OldWList, LList, OldLList: TIntegerArray;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  for ACtrlSpace := 0 to 2 do
  begin
    TotalSpace := 2*Max(ALeftSpace, ACtrlSpace) + 2*Max(AMidSpace, ACtrlSpace);
    Init1(FContainer, 150 + TotalSpace,crsSameSize, 3, C,
          [20, 40, 30,
           20, 35  {-}]);
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    AddPaddingAround(C, ACtrlSpace);
    EnableAutoSizing(FContainer);

    AssertEquals(50, C[0].Width);
    AssertEquals(50, C[3].Width);
    AssertEquals(50, C[1].Width);
    AssertEquals(50, C[4].Width);
    AssertEquals(50, C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 1000 do begin
      FContainer.Width := j;
      i := Max(0, j - TotalSpace);
      MinVal := 1;
      if i <= 2 then MinVal := 0;

      WList := GetWidths(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertMaxOneDecrementInList(WList, OldWList);
      OldWList := WList;
      LList := GetLefts(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertNoDecrementInList(LList, OldLList);
      OldLList := LList;

      if i >= MIN_CONTAINER_WIDTH then
        AssertEquals('Total Width', i, SumWidths(C, 0, 2));
      AssertApprox(Max(MinVal, i div 3), C[0].Width);
      AssertApprox(Max(MinVal, i div 3), C[3].Width);
      AssertApprox(Max(MinVal, i div 3), C[1].Width);
      AssertApprox(Max(MinVal, i div 3), C[4].Width);
      AssertApprox(Max(MinVal, i div 3), C[2].Width);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + 0, C[0].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + 0, C[3].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) + C[0].Width, C[1].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) + C[0].Width, C[4].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) *2 + C[0].Width+C[1].Width, C[2].Left);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestSameSizeConstrained;
var
  C: TTestChildArray;
  i, MinVal, ALeftSpace, AMidSpace, TotalSpace, j: Integer;
  WList, OldWList, LList, OldLList: TIntegerArray;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  begin
    TotalSpace := 2*ALeftSpace + 2*AMidSpace;
    Init1(FContainer, 145 + TotalSpace,crsSameSize, 3, C,
          [20, 40, 30,
           20, 35  {-}]);
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    c[1].Constraints.MinWidth := 35;
    c[1].Constraints.MaxWidth := 45;
    c[4].Constraints.MinWidth := 35;
    c[4].Constraints.MaxWidth := 45;
    EnableAutoSizing(FContainer);

    AssertEquals(50, C[0].Width);
    AssertEquals(50, C[3].Width);
    AssertEquals(45, C[1].Width);
    AssertEquals(45, C[4].Width);
    AssertEquals(50, C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 1000 do begin
      FContainer.Width := j;
      i := Max(0, j - TotalSpace);
      MinVal := 1;
      if i < 2+35 then MinVal := 0;

      WList := GetWidths(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertMaxOneDecrementInList(WList, OldWList);
      OldWList := WList;
      LList := GetLefts(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertNoDecrementInList(LList, OldLList);
      OldLList := LList;

      if i >= MIN_CONTAINER_WIDTH*38 then
        AssertEquals('Total Width', Max(35, i), SumWidths(C, 0, 2));

      if i <= 35 then begin
        AssertZero(MinVal, C[0].Width);
        AssertZero(MinVal, C[3].Width);
        AssertEquals(35,     C[1].Width);
        AssertEquals(35,     C[4].Width);
        AssertZero(MinVal, C[2].Width);
      end
      else
      if i <= 105 then begin
        AssertApprox(Max(MinVal, (i-35) div 2), C[0].Width);
        AssertApprox(Max(MinVal, (i-35) div 2), C[3].Width);
        AssertEquals(35,     C[1].Width);
        AssertEquals(35,     C[4].Width);
        AssertApprox(Max(MinVal, (i-35) div 2), C[2].Width);
      end
      else
      if i <= 135 then begin
        AssertApprox(Max(MinVal, i div 3), C[0].Width);
        AssertApprox(Max(MinVal, i div 3), C[3].Width);
        AssertApprox(Max(MinVal, i div 3), C[1].Width);
        AssertApprox(Max(MinVal, i div 3), C[4].Width);
        AssertApprox(Max(MinVal, i div 3), C[2].Width);
      end
      else
      begin
        AssertApprox(Max(MinVal, (i-45) div 2), C[0].Width);
        AssertApprox(Max(MinVal, (i-45) div 2), C[3].Width);
        AssertEquals(45,     C[1].Width);
        AssertEquals(45,     C[4].Width);
        AssertApprox(Max(MinVal, (i-45) div 2), C[2].Width);
      end;

      AssertEquals(ALeftSpace + 0, C[0].Left);
      AssertEquals(ALeftSpace + 0, C[3].Left);
      AssertEquals(ALeftSpace + AMidSpace + C[0].Width, C[1].Left);
      AssertEquals(ALeftSpace + AMidSpace + C[0].Width, C[4].Left);
      AssertEquals(ALeftSpace + AMidSpace *2 + C[0].Width+C[1].Width, C[2].Left);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestHomogenousChildResize;
var
  C: TTestChildArray;
  i, ALeftSpace, AMidSpace, ACtrlSpace, TotalSpace, j: Integer;
  WList, OldWList, LList, OldLList: TIntegerArray;
begin
  for ALeftSpace := 0 to 3 do
  for AMidSpace := 0 to 3 do
  for ACtrlSpace := 0 to 2 do
  begin
    TotalSpace := 2*Max(ALeftSpace, ACtrlSpace) + 2*Max(AMidSpace, ACtrlSpace);
    Init1(FContainer, 120 + TotalSpace, crsHomogenousChildResize, 3, C,
          [20, 40, 30,
           20, 35  {-}]);
    DisableAutoSizing(FContainer);
    FContainer.ChildSizing.LeftRightSpacing := ALeftSpace;
    FContainer.ChildSizing.HorizontalSpacing := AMidSpace;
    AddPaddingAround(C, ACtrlSpace);
    EnableAutoSizing(FContainer);

    AssertEquals(30,  C[0].Width);
    AssertEquals(30,  C[3].Width);
    AssertEquals(50, C[1].Width);
    AssertEquals(50, C[4].Width);
    AssertEquals(40,  C[2].Width);

    for j := MIN_CONTAINER_WIDTH to 1000 do begin
      FContainer.Width := j;
      i := Max(0, j - TotalSpace);

      WList := GetWidths(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertMaxOneDecrementInList(WList, OldWList);
      OldWList := WList;
      LList := GetLefts(C, 0,2);
      if j > MIN_CONTAINER_WIDTH then
        AssertNoDecrementInList(LList, OldLList);
      OldLList := LList;

      if i >= MIN_CONTAINER_WIDTH then
        AssertEquals('Total Width', i, SumWidths(C, 0, 2));
      if i < 3 then begin  // All column are limited
        AssertApprox(0, C[0].Width);
        AssertApprox(0, C[3].Width);
        AssertApprox(0, C[1].Width);
        AssertApprox(0, C[4].Width);
        AssertApprox(0, C[2].Width);
      end
      else
      if i <= 11 then begin  // First and Last column is limited
        // 11 = 90 - 79 = 90 -  19 (1st) + 2*30
        AssertEquals(1, C[0].Width);
        AssertEquals(1, C[3].Width);
        // 40 + (i - (90 - (19+29))) div 1
        AssertEquals(Max(1, i-2), C[1].Width);
        AssertEquals(Max(1, i-2), C[4].Width);
        AssertEquals(1, C[2].Width);
      end
      else
      if i <= 30 then begin  // First column is limited
        // 30 = 90 - 60 = 90 - 3*20 to subtract => first column forced to 1
        AssertEquals(1, C[0].Width);
        AssertEquals(1, C[3].Width);
        AssertApprox(Max(1, -1 + 40 + (i-(90-19)) div 2), C[1].Width);
        AssertApprox(Max(1, -1 + 40 + (i-(90-19)) div 2), C[4].Width);
        AssertApprox(Max(1, -1 + 30 + (i-(90-19)) div 2), C[2].Width);
      end
      else
      if i <= 90 then begin  // shrink
        AssertApprox(Max(1, -1 + 20 + (i-90) div 3), C[0].Width);
        AssertApprox(Max(1, -1 + 20 + (i-90) div 3), C[3].Width);
        AssertApprox(Max(1, -1 + 40 + (i-90) div 3), C[1].Width);
        AssertApprox(Max(1, -1 + 40 + (i-90) div 3), C[4].Width);
        AssertApprox(Max(1, -1 + 30 + (i-90) div 3), C[2].Width);
      end
      else begin
        // enlarge
        AssertApprox(max(1, 20 + (i-90) div 3), C[0].Width);
        AssertApprox(Max(1, 20 + (i-90) div 3), C[3].Width);
        AssertApprox(Max(1, 40 + (i-90) div 3), C[1].Width);
        AssertApprox(Max(1, 40 + (i-90) div 3), C[4].Width);
        AssertApprox(Max(1, 30 + (i-90) div 3), C[2].Width);
      end;
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + 0, C[0].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + 0, C[3].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) + C[0].Width, C[1].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) + C[0].Width, C[4].Left);
      AssertEquals(Max(ALeftSpace, ACtrlSpace) + Max(AMidSpace, ACtrlSpace) * 2 + C[0].Width+C[1].Width, C[2].Left);
    end;
    FreeAndNil(FContainer);
  end;
end;

procedure TTestChildSizing.TestHomogenousChildResizeConstrained;
var
  C: TTestChildArray;
  i, j: Integer;
  WList, OldWList, LList, OldLList: TIntegerArray;
begin
  Init1(FContainer, 115, crsHomogenousChildResize, 3, C,
        [20, 40, 30,
         20, 35  {-}]);
  DisableAutoSizing(FContainer);
    c[1].Constraints.MinWidth := 35;
    c[1].Constraints.MaxWidth := 45;
    c[4].Constraints.MinWidth := 35;
    c[4].Constraints.MaxWidth := 45;
  EnableAutoSizing(FContainer);

  //   // 90 + 25 (5 Constrained / +20 for the 2 other column)
  AssertEquals(30,  C[0].Width);
  AssertEquals(30,  C[3].Width);
  AssertEquals(45, C[1].Width);
  AssertEquals(45, C[4].Width);
  AssertEquals(40,  C[2].Width);

  FContainer.Width := 65;  // 90 - 25 (5 Constrained / -20 for the 2 other column)
  AssertEquals(10,  C[0].Width);
  AssertEquals(10,  C[3].Width);
  AssertEquals(35, C[1].Width);
  AssertEquals(35, C[4].Width);
  AssertEquals(20,  C[2].Width);

  FContainer.Width := 45; // 90 - 35 (5 Constrained / -30 for the 2 other column)
  AssertEquals( 1,  C[0].Width);
  AssertEquals( 1,  C[3].Width);
  AssertEquals(35, C[1].Width);
  AssertEquals(35, C[4].Width);
  AssertEquals( 9,  C[2].Width);

  FContainer.Width := 40; // 90 - 50 (5 Constrained / -45 for the 2 other column)
  AssertEquals( 1,  C[0].Width);
  AssertEquals( 1,  C[3].Width);
  AssertEquals(35, C[1].Width);
  AssertEquals(35, C[4].Width);
  AssertEquals( 4,  C[2].Width);

  FContainer.Width := 30;
  AssertZero( 0,  C[0].Width);
  AssertZero( 0,  C[3].Width);
  AssertEquals(35, C[1].Width);
  AssertEquals(35, C[4].Width);
  AssertZero( 0,  C[2].Width);



  for j := MIN_CONTAINER_WIDTH to 1000 do begin
    FContainer.Width := j;
    i := Max(0, j);

    WList := GetWidths(C, 0,2);
    if j > MIN_CONTAINER_WIDTH then
      AssertMaxOneDecrementInList(WList, OldWList);
    OldWList := WList;
    LList := GetLefts(C, 0,2);
    if j > MIN_CONTAINER_WIDTH then
      AssertNoDecrementInList(LList, OldLList);
    OldLList := LList;

    if i >= MIN_CONTAINER_WIDTH*38 then
      AssertEquals('Total Width', Max(35, i), SumWidths(C, 0, 2));

    AssertEquals(0, C[0].Left);
    AssertEquals(0, C[3].Left);
    AssertEquals(C[0].Width, C[1].Left);
    AssertEquals(C[0].Width, C[4].Left);
    AssertEquals(C[0].Width+C[1].Width, C[2].Left);
  end;

end;

procedure TTestChildSizing.TestHomogenousSpaceResize;
var
  C: TTestChildArray;
  i, d, j: Integer;
  gaps, OldGaps, LList, OldLList: TIntegerArray;
begin
  Init1(FContainer, 120, crsHomogenousSpaceResize, 3, C,
        [20, 40, 30,
         20, 35  {-}]);

  for i := MIN_CONTAINER_WIDTH to 1000 do begin
    FContainer.Width := i;
    if i >= MIN_CONTAINER_WIDTH then
      AssertEquals('Total Width', 90, SumWidths(C, 0, 2));
    AssertEquals(20,  C[0].Width);
    AssertEquals(20,  C[3].Width);
    AssertEquals(40, C[1].Width);
    //AssertEquals(35, C[4].Width); // Even though it's "space resize", the cell size gets applied to all children
    AssertEquals(30,  C[2].Width);

    gaps := GetSpaces(C, 0, Max(90,i), 0,2);
    AssertEquals('Spaces', Max(0, i-90), SumSpaces(gaps));
    d := Max(0, i-90) div 4;
    for j := 0 to Length(gaps) - 1 do
      AssertApprox(d, gaps[j]);
  end;
  FreeAndNil(FContainer);

  /////////////////
  // With Spacing

  Init1(FContainer, 120, crsHomogenousSpaceResize, 3, C,
        [20, 40, 30,
         20, 35  {-}]);
  DisableAutoSizing(FContainer);
  FContainer.ChildSizing.LeftRightSpacing  := 9;
  FContainer.ChildSizing.HorizontalSpacing := 4;
  C[2].BorderSpacing.Left := 11;
  EnableAutoSizing(FContainer);
  // Spacing   9  C0  4  C1  11  C2  9


  for i := MIN_CONTAINER_WIDTH to 1000 do begin
    FContainer.Width := i;
    if i >= MIN_CONTAINER_WIDTH then
      AssertEquals('Total Width', 90, SumWidths(C, 0, 2));
    AssertEquals(20,  C[0].Width);
    AssertEquals(20,  C[3].Width);
    AssertEquals(40, C[1].Width);
    //AssertEquals(35, C[4].Width); // Even though it's "space resize", the cell size gets applied to all children
    AssertEquals(30,  C[2].Width);

    gaps := GetSpaces(C, 0, Max(90,i), 0,2);
    if i > MIN_CONTAINER_WIDTH then
      AssertMaxOneDecrementInList(gaps, OldGaps);
    OldGaps := gaps;
    LList := GetLefts(C, 0,2);
    if i > MIN_CONTAINER_WIDTH then
      AssertNoDecrementInList(LList, OldLList);
    OldLList := LList;
    AssertEquals('Spaces', Max(0, i-90), SumSpaces(gaps));

    if i <= 90 then begin
      AssertZero( 0, gaps[0]);
      AssertZero( 0, gaps[1]);
      AssertZero( 0, gaps[2]);
      AssertZero( 0, gaps[3]);
    end
    else
    if i <= 92 then begin
      d := i-90;
      AssertZero( 0, gaps[0]);
      AssertZero( 0, gaps[1]);
      AssertZero( 0 + d, gaps[2]); // 91 = 1 .... 92 = 2
      AssertZero( 0, gaps[3]);
    end
    else
    if i <= 107 then begin
      d := Max(0, i-92) div 3;   // 93-95=1 ..  105..107=5
      AssertApprox( 0 + d, gaps[0]);
      AssertZero( 0, gaps[1]);
      AssertApprox( 2 + d, gaps[2]);
      AssertApprox( 0 + d, gaps[3]);
    end
    else
    if i <= 123 then begin
      d := Max(0, i-107) div 4;
      AssertApprox( 5 + d, gaps[0]);
      AssertApprox( 0 + d, gaps[1]);
      AssertApprox( 7 + d, gaps[2]);
      AssertApprox( 5 + d, gaps[3]);
    end;



  end;
end;

procedure TTestChildSizing.TestCalculateCellConstraints;
var
  C: TTestChildArray;
  UseMaxTop, UseMaxBtm: Integer;
  cc1, cc2, cc3: TControlCellAlign;
  w1, w2, w2Top, w2Btm, w3: Integer;
  MaxW2, PrefW2: Integer;
begin
  Init1(FContainer, 1000,crsScaleChilds, 3, C,
        [20, 90, 30,
         25, 85, 30,
         20, 95, 30]);

  // preferred width
  w1 := 25 * 1000 div (25+95+30);
  w2 := 95 * 1000 div (25+95+30);
  w3 := 30 * 1000 div (25+95+30);
  AssertApprox(w1, C[0].Width); AssertApprox(w2, C[1].Width); AssertApprox(w3, C[2].Width);
  AssertApprox(w1, C[3].Width); AssertApprox(w2, C[4].Width); AssertApprox(w3, C[5].Width);
  AssertApprox(w1, C[6].Width); AssertApprox(w2, C[7].Width); AssertApprox(w3, C[8].Width);

  (* MaxWidth only limits the column if the control has CellAlignHorizontal = ccaLeftTop
  *)
  for UseMaxTop   := 0 to 1 do  // Enable/disable MaxWidth on top row
  for UseMaxBtm   := 0 to 1 do  // Enable/disable MaxWidth on bottom row
  for cc1 := low(TControlCellAlign) to high(TControlCellAlign) do
  for cc2 := low(TControlCellAlign) to high(TControlCellAlign) do
  for cc3 := low(TControlCellAlign) to high(TControlCellAlign) do begin
    DisableAutoSizing(FContainer);
    // constraints for cells in column 2
    c[1].Constraints.MaxWidth := 75 * UseMaxTop;
    c[4].Constraints.MaxWidth := 70;       // lowest MaxWidth, always set - only applies to column if ccaFill;
    c[7].Constraints.MaxWidth := 75 * UseMaxBtm;
    // alignment for cells in column 2
    c[1].BorderSpacing.CellAlignHorizontal := cc1;
    c[4].BorderSpacing.CellAlignHorizontal := cc2;
    c[7].BorderSpacing.CellAlignHorizontal := cc3;
    EnableAutoSizing(FContainer);

    // Check if any limit applies
    MaxW2  :=  0;   // if the column is constrained, then use the constrained width
    if cc2 = ccaFill      then MaxW2  := 70
    else if (cc1 = ccaFill) and (UseMaxTop=1) then MaxW2  := 75
    else if (cc3 = ccaFill) and (UseMaxBtm=1) then MaxW2  := 75;

    PrefW2 := 75;                        // PrefWidth from constrained top or bottom row
    if UseMaxTop = 0 then PrefW2 := 90;  // PrefWidth from top row
    if UseMaxBtm = 0 then PrefW2 := 95;  // PrefWidth from bottom row
    if MaxW2 > 0 then PrefW2 := 0;

    w1 := 25     * (1000-MaxW2) div (25+PrefW2+30);
    w2 := PrefW2 * (1000-MaxW2) div (25+PrefW2+30)  + MaxW2;
    w3 := 30     * (1000-MaxW2) div (25+PrefW2+30);
    w2Top := w2;
    if cc1 <> ccaFill then w2Top := Min(w2, 90);  // not enlarged to column - not FILLing
    if UseMaxTop = 1  then w2Top := Min(w2, 75);  // constrained
    w2Btm := w2;
    if cc3 <> ccaFill then w2Btm := Min(w2, 95);  // not enlarged to column - not FILLing
    if UseMaxBtm = 1  then w2Btm := Min(w2, 75);  // constrained

    AssertApprox(w1, C[0].Width);   AssertApprox(w2Top, C[1].Width);   AssertApprox(w3, C[2].Width);
    AssertApprox(w1, C[3].Width);   AssertEquals(70,    C[4].Width);   AssertApprox(w3, C[5].Width);
    AssertApprox(w1, C[6].Width);   AssertApprox(w2Btm, C[7].Width);   AssertApprox(w3, C[8].Width);

    AssertApprox(w1+w2, C[2].Left, 2); // check left of 3rd column
  end;

  DisableAutoSizing(FContainer);
  c[4].Constraints.MaxWidth := 900;
  c[7].Constraints.MaxWidth := 900;
  c[0].Constraints.MinWidth := 135; // highest MinWidth
  c[3].Constraints.MinWidth := 115;
  FContainer.Width := 200;
  EnableAutoSizing(FContainer);
  w1 := 135;
  w2 := 95 * (200-135) div (95+30);
  w3 := 30 * (200-135) div (95+30);
  AssertEquals(w1, C[0].Width); AssertApprox(w2, C[1].Width); AssertApprox(w3, C[2].Width);
  AssertEquals(w1, C[3].Width); AssertApprox(w2, C[4].Width); AssertApprox(w3, C[5].Width);
  AssertEquals(w1, C[6].Width); AssertApprox(w2, C[7].Width); AssertApprox(w3, C[8].Width);

  FreeAndNil(FContainer);

  // check Height
  Init1(FContainer, 1000,crsScaleChilds, 3, C,
        [20, 90, 30,
         25, 85, 30,
         20, 95, 30],
        True);

  w1 := 25 * 1000 div (25+95+30);
  w2 := 95 * 1000 div (25+95+30);
  w3 := 30 * 1000 div (25+95+30);
  AssertApprox(w1, C[0].Height); AssertApprox(w2, C[1].Height); AssertApprox(w3, C[2].Height);
  AssertApprox(w1, C[3].Height); AssertApprox(w2, C[4].Height); AssertApprox(w3, C[5].Height);
  AssertApprox(w1, C[6].Height); AssertApprox(w2, C[7].Height); AssertApprox(w3, C[8].Height);

  // preferred height
  for UseMaxTop   := 0 to 1 do  // Enable/disable MaxWidth on top row
  for UseMaxBtm   := 0 to 1 do  // Enable/disable MaxWidth on bottom row
  for cc1 := low(TControlCellAlign) to high(TControlCellAlign) do
  for cc2 := low(TControlCellAlign) to high(TControlCellAlign) do
  for cc3 := low(TControlCellAlign) to high(TControlCellAlign) do begin
    DisableAutoSizing(FContainer);
    // constraints for cells in column 2
    c[1].Constraints.MaxHeight := 75 * UseMaxTop;
    c[4].Constraints.MaxHeight := 70;       // lowest MaxHeight, always set - only applies to column if ccaFill;
    c[7].Constraints.MaxHeight := 75 * UseMaxBtm;
    // alignment for cells in column 2
    c[1].BorderSpacing.CellAlignVertical := cc1;
    c[4].BorderSpacing.CellAlignVertical := cc2;
    c[7].BorderSpacing.CellAlignVertical := cc3;
    EnableAutoSizing(FContainer);

    // Check if any limit applies
    MaxW2  :=  0;   // if the column is constrained, then use the constrained Height
    if cc2 = ccaFill      then MaxW2  := 70
    else if (cc1 = ccaFill) and (UseMaxTop=1) then MaxW2  := 75
    else if (cc3 = ccaFill) and (UseMaxBtm=1) then MaxW2  := 75;

    PrefW2 := 75;                        // PrefHeight from constrained first or last column
    if UseMaxTop = 0 then PrefW2 := 90;  // PrefHeight from first column
    if UseMaxBtm = 0 then PrefW2 := 95;  // PrefHeight from last column
    if MaxW2 > 0 then PrefW2 := 0;

    w1 := 25     * (1000-MaxW2) div (25+PrefW2+30);
    w2 := PrefW2 * (1000-MaxW2) div (25+PrefW2+30)  + MaxW2;
    w3 := 30     * (1000-MaxW2) div (25+PrefW2+30);
    w2Top := w2;
    if cc1 <> ccaFill then w2Top := Min(w2, 90);  // not enlarged to row - not FILLing
    if UseMaxTop = 1  then w2Top := Min(w2, 75);  // constrained
    w2Btm := w2;
    if cc3 <> ccaFill then w2Btm := Min(w2, 95);  // not enlarged to row - not FILLing
    if UseMaxBtm = 1  then w2Btm := Min(w2, 75);  // constrained

    AssertApprox(w1, C[0].Height);   AssertApprox(w2Top, C[1].Height);   AssertApprox(w3, C[2].Height);
    AssertApprox(w1, C[3].Height);   AssertEquals(70,    C[4].Height);   AssertApprox(w3, C[5].Height);
    AssertApprox(w1, C[6].Height);   AssertApprox(w2Btm, C[7].Height);   AssertApprox(w3, C[8].Height);

    AssertApprox(w1+w2, C[2].Top, 2); // check Top of 3rd row
  end;

  DisableAutoSizing(FContainer);
  c[4].Constraints.MaxHeight := 900;
  c[7].Constraints.MaxHeight := 900;
  c[0].Constraints.MinHeight := 135; // highest MinHeight
  c[3].Constraints.MinHeight := 115;
  FContainer.Height := 200;
  EnableAutoSizing(FContainer);
  w1 := 135;
  w2 := 95 * (200-135) div (95+30);
  w3 := 30 * (200-135) div (95+30);
  AssertEquals(w1, C[0].Height); AssertApprox(w2, C[1].Height); AssertApprox(w3, C[2].Height);
  AssertEquals(w1, C[3].Height); AssertApprox(w2, C[4].Height); AssertApprox(w3, C[5].Height);
  AssertEquals(w1, C[6].Height); AssertApprox(w2, C[7].Height); AssertApprox(w3, C[8].Height);

  FreeAndNil(FContainer);

end;

{ TTestChildSizingWithTempAutoSizing }

procedure TTestChildSizingWithTempAutoSizing.EnableAutoSizing(c: TWinControl);
begin
  //
end;

procedure TTestChildSizingWithTempAutoSizing.DisableAutoSizing(c: TWinControl);
begin
  //
end;


initialization

  RegisterTest(TTestChildSizing);
  RegisterTest(TTestChildSizingWithTempAutoSizing);
end.

