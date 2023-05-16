{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Authors: Alexander Klenin

}

unit SourcesTest;

{$mode objfpc}{$H+}{$R+}

interface

uses
  Classes, SysUtils, FPCUnit, TestRegistry,
  TAChartUtils, TACustomSource, TAIntervalSources, TASources;

type

  { TListSourceTest }

  TListSourceTest = class(TTestCase)
  private
    FSource: TListChartSource;

    procedure AssertItemEquals(
      const AItem: TChartDataItem; AX, AY: Double; AText: String = '';
      AColor: TChartColor = clTAColor);
    function Compare(AItem1, AItem2: Pointer): Integer;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Basic;
    procedure Bounds;
    procedure Cache;
    procedure DataPoint;
    procedure DataPointSeparator;
    procedure Enum;
    procedure Extent;
    procedure Multi;
    procedure Sort;
  end;

  { TRandomSourceTest }

  TRandomSourceTest = class(TTestCase)
  published
    procedure Extent;
  end;

  { TCalculatedSourceTest }

  TCalculatedSourceTest = class(TTestCase)
  private
    FOrigin: TListChartSource;
    FSource: TCalculatedChartSource;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Accumulate;
    procedure Derivative;
    procedure Percentage;
    procedure Reorder;
  end;

  TIntervalSourceTest = class(TTestCase)
  private
    procedure AssertValueEquals(
      const AExpected: array of Double; const AActual: TChartValueTextArray);
  published
    procedure IntervalSource;
    procedure ListSource;
  end;

implementation

uses
  Math, TAMath, AssertHelpers;

type
  TDummyTransform = object
  public
    function IdentityDouble(AX: Double): Double;
    function IdentityInteger(AX: Integer): Integer;
    function PrepareValuesInRangeParams: TValuesInRangeParams;
    function Round(AX: Double): Integer;
  end;

var
  VDummyTransform: TDummyTransform;

{ TDummyTransform }

function TDummyTransform.IdentityDouble(AX: Double): Double;
begin
  Result := AX;
end;

function TDummyTransform.IdentityInteger(AX: Integer): Integer;
begin
  Result := AX;
end;

function TDummyTransform.PrepareValuesInRangeParams: TValuesInRangeParams;
begin
  with Result do begin
    FAxisToGraph := @IdentityDouble;
    FGraphToAxis := @IdentityDouble;
    FFormat := '';
    FGraphToImage := @Round;
    FMin := 30;
    FMax := 69;
    FMinStep := 0;
    FScale := @IdentityInteger;
    FUseY := false;
    FIntervals := TChartAxisIntervalParams.Create(nil);
  end;
end;

function TDummyTransform.Round(AX: Double): Integer;
begin
  Result := System.Round(AX);
end;

{ TCalculatedSourceTest }

procedure TCalculatedSourceTest.Accumulate;
var
  i, j: Integer;
  rng: TMWCRandomGenerator;
begin
  FSource.AccumulationMethod := camSum;
  FSource.AccumulationRange := 2;
  AssertEquals(3, FSource.YCount);
  AssertEquals(1, FSource[0]^.X);
  AssertEquals(102, FSource[0]^.Y);
  AssertEquals(2, FSource[1]^.X);
  AssertEquals(102 + 202, FSource[1]^.Y);
  AssertEquals(202 + 302, FSource[2]^.Y);
  FSource.AccumulationDirection := cadForward;
  AssertEquals(202 + 302, FSource[1]^.Y);
  AssertEquals(302 + 402, FSource[2]^.Y);
  FSource.AccumulationDirection := cadBackward;
  FSource.AccumulationMethod := camAverage;
  AssertEquals((2002 + 2102) / 2, FSource[20]^.Y);
  AssertEquals(1, FSource[0]^.X);
  AssertEquals(102, FSource[0]^.Y);
  AssertEquals((102 + 202) / 2, FSource[1]^.Y);
  AssertEquals(102, FSource[0]^.Y);
  FSource.AccumulationDirection := cadCenter;
  AssertEquals((1102 + 1202 + 1302) / 3, FSource[11]^.Y);
  FSource.AccumulationDirection := cadBackward;

  FSource.AccumulationRange := 5;
  rng := TMWCRandomGenerator.Create;
  try
    rng.Seed := 89237634;
    for i := 1 to 100 do begin
      j := rng.GetInRange(5, FSource.Count - 1);
      AssertEquals(IntToStr(j), (j - 1) * 100 + 2, FSource[j]^.Y);
    end;
    FSource.AccumulationRange := 0;
    FSource.AccumulationMethod := camSum;
    rng.Seed := 23784538;
    for i := 1 to 20 do begin
      j := rng.GetInRange(0, FSource.Count - 1);
      AssertEquals(
        IntToStr(j), (j + 1) * (j + 2) * 50 + (j + 1) * 3, FSource[j]^.YList[0]);
    end;
  finally
    rng.Free;
  end;
end;

procedure TCalculatedSourceTest.Derivative;
begin
  FSource.AccumulationMethod := camDerivative;
  FSource.AccumulationRange := 2;
  FOrigin.SetYValue(1, 202);
  AssertTrue(IsNan(FSource[0]^.Y));
  AssertEquals(100, FSource[1]^.Y);
  FSource.AccumulationDirection := cadCenter;
  AssertEquals(100, FSource[0]^.Y);
end;

procedure TCalculatedSourceTest.Percentage;
begin
  FSource.Percentage := true;
  AssertEquals(3, FSource.YCount);
  AssertEquals(102 / (102 + 103 + 104) * 100, FSource[0]^.Y);
  AssertEquals(103 / (102 + 103 + 104) * 100, FSource[0]^.YList[0]);
end;

procedure TCalculatedSourceTest.Reorder;
var
  i: Integer;
begin
  AssertEquals(3, FSource.YCount);
  FSource.ReorderYList := '2';
  AssertEquals(1, FSource.YCount);
  AssertEquals(104, FSource[0]^.Y);
  AssertEquals(204, FSource[1]^.Y);
  FSource.ReorderYList := '0,2';
  AssertEquals(2, FSource.YCount);
  AssertEquals(102, FSource[0]^.Y);
  AssertEquals(104, FSource[0]^.YList[0]);
  AssertEquals(202, FSource[1]^.Y);
  AssertEquals(204, FSource[1]^.YList[0]);
  FSource.ReorderYList := '1,1,1';
  AssertEquals(3, FSource.YCount);
  AssertEquals(103, FSource[0]^.Y);
  AssertEquals([103, 103], FSource[0]^.YList);
  FSource.ReorderYList := '';
  for i := 0 to FSource.Count - 1 do begin
    AssertEquals(FOrigin[i]^.Y, FSource[i]^.Y);
    AssertEquals(FOrigin[i]^.YList, FSource[i]^.YList);
  end;
end;

procedure TCalculatedSourceTest.SetUp;
var
  i: Integer;
begin
  inherited SetUp;
  FOrigin := TListChartSource.Create(nil);
  FSource := TCalculatedChartSource.Create(nil);
  FSource.Origin := FOrigin;
  FOrigin.YCount := 3;
  for i := 1 to 100 do
    FOrigin.SetYList(FOrigin.Add(i, i * 100 + 2), [i * 100 + 3, i * 100 + 4]);
end;

procedure TCalculatedSourceTest.TearDown;
begin
  FreeAndNil(FSource);
  FreeAndNil(FOrigin);
  inherited TearDown;
end;

{ TListSourceTest }

procedure TListSourceTest.AssertItemEquals(
  const AItem: TChartDataItem; AX, AY: Double; AText: String;
  AColor: TChartColor);
begin
  AssertEquals('X', AX, AItem.X);
  AssertEquals('Y', AY, AItem.Y);
  AssertEquals('Text', AText, AItem.Text);
  AssertEquals('Color', AColor, AItem.Color);
end;

procedure TListSourceTest.Basic;
var
  i: Integer;
  srcDest: TListChartSource;
begin
  FSource.Clear;
  AssertEquals(0, FSource.Count);
  AssertEquals(0, FSource.Add(1, 2, 'text', $FFFFFF));
  AssertEquals(1, FSource.Count);
  FSource.Delete(0);
  AssertEquals(0, FSource.Count);
  for i := 1 to 10 do
    FSource.Add(i, i * 2, IntToStr(i));
  srcDest := TListChartSource.Create(nil);
  try
    srcDest.CopyFrom(FSource);
    AssertEquals(FSource.Count, srcDest.Count);
    for i := 0 to FSource.Count - 1 do
      with FSource[i]^ do
        AssertItemEquals(srcDest[i]^, X, Y, Text, Color);
  finally
    srcDest.Free;
  end;
end;

procedure TListSourceTest.Bounds;

  procedure Check2(AExpectedLB, AExpectedUB: Integer; AXMin, AXMax: Double);
  var
    lb, ub: Integer;
  begin
    FSource.FindBounds(AXMin, AXMax, lb, ub);
    AssertEquals(AExpectedLB, lb);
    AssertEquals(AExpectedUB, ub);
  end;

  procedure Check(AExpectedLB, AExpectedUB: Integer; AValue: Double);
  begin
    Check2(AExpectedLB, AExpectedUB, AValue, AValue)
  end;

  procedure CheckAll;
  begin
    Check2(1, 2, 2, 3);
    Check2(1, 2, 1.9, 3.1);
    Check2(2, 1, 2.1, 2.9);
    Check(1, 1, 2);
    Check(1, 0, 1.9);
    Check(0, -1, 0.9);          // below left-most point
    Check(5, 4, 5.1);           // above right-most point
    Check(4, 3, 4.9);           // just below right-most point
    Check2(2, 4, 3, 1e100);
    Check2(0, 1, -1e100, 2);
  end;

  procedure CheckAll_XCount0;
  begin
    Check2(2, 3, 2, 3);
    Check2(2, 3, 1.9, 3.1);
    Check2(3, 2, 2.1, 2.9);
    Check(2, 2, 2);
    Check(2, 1, 1.9);
    Check(0, -1, -0.1);   // below left-most point
    Check(5, 4, 4.1);     // above right-most point
    Check(4, 3,  3.9);    // just below right-most point
    Check2(2, 4, 2, 1e100);
    Check2(0, 1, -1e100, 1);
  end;

begin
  FSource.Clear;
  FSource.Add(1, 2);
  FSource.Add(2, 3);
  FSource.Add(3, 4);
  FSource.Add(4, 5);
  FSource.Add(5, 6);
  FSource.Sorted := true;
  CheckAll;
  FSource.Sorted := false;
  CheckAll;

  FSource.XCount := 0;
  CheckAll_XCount0;

  FSource.XCount := 1;
  FSource.SetXValue(1, SafeNan);
  Check(2, 0, 2);
  FSource.SetXValue(0, SafeNan);
  Check2(2, 2, -1e100, 3);
  Check2(2, 2, NegInfinity, 3);

  FSource.Clear;
  FSource.Add(SafeNaN, SafeNaN);
  Check2(0, 0, NegInfinity, Infinity);
end;

procedure TListSourceTest.Cache;
begin
  FSource.Clear;
  FSource.Add(5, 6);
  FSource.Add(7, 8);
  AssertEquals(14, FSource.ValuesTotal);
  FSource.Add(8, SafeNan);
  AssertEquals(14, FSource.ValuesTotal);
  FSource.Delete(2);
  AssertEquals(14, FSource.ValuesTotal);
  FSource.Delete(1);
  AssertEquals(6, FSource.ValuesTotal);
  FSource.SetYValue(0, SafeNan);
  AssertEquals(0, FSource.ValuesTotal);
  FSource.SetYValue(0, 5);
  AssertEquals(5, FSource.ValuesTotal);

  FSource.Clear;
  AssertEquals(0, FSource.ValuesTotal);
  FSource.Add(NaN, NaN);
  FSource.BeginUpdate;
  FSource.EndUpdate;
  AssertEquals(0, FSource.ValuesTotal);
end;

procedure TListSourceTest.DataPoint;
begin
  FSource.Clear;
  FSource.DataPoints.Add('3|4|?|text1');
  FSource.DataPoints.Add('5|6|$FF0000|');
  AssertEquals(2, FSource.Count);
  AssertItemEquals(FSource[0]^, 3, 4, 'text1');
  AssertItemEquals(FSource[1]^, 5, 6, '', $FF0000);
  FSource[0]^.Color := 0;
  AssertEquals('3|4|$000000|text1', FSource.DataPoints[0]);
  FSource.DataPoints.Add('7|8|0|two words');
  AssertEquals('two words', FSource[2]^.Text);
end;

procedure TListSourceTest.DataPointSeparator;
var
  oldSeparator: Char;
begin
  FSource.Clear;
  oldSeparator := DefaultFormatSettings.DecimalSeparator;
  try
    DefaultFormatSettings.DecimalSeparator := ':';
    FSource.DataPoints.Add('3:5|?|?|');
    AssertEquals(3.5, FSource[0]^.X);
    FSource.DataPoints[0] := '4.5|?|?|';
    AssertEquals(4.5, FSource[0]^.X);
  finally
    DefaultFormatSettings.DecimalSeparator := oldSeparator;
  end;
end;

procedure TListSourceTest.Enum;
var
  it: PChartDataItem;
  s: Double = 0;
begin
  FSource.Clear;
  for it in FSource do
    s += 1;
  AssertEquals(0, s);
  FSource.Add(10, 1);
  FSource.Add(20, 7);
  for it in FSource do
    s += it^.X + it^.Y;
  AssertEquals(38, s);
end;

procedure TListSourceTest.Extent;

  procedure AssertExtent(AX1, AY1, AX2, AY2: Double);
  begin
    with FSource.Extent do begin
      AssertEquals('X1', AX1, a.X);
      AssertEquals('Y1', AY1, a.Y);
      AssertEquals('X2', AX2, b.X);
      AssertEquals('Y2', AY2, b.Y);
    end;
  end;

begin
  FSource.Clear;
  Assert(IsInfinite(FSource.Extent.a.X) and IsInfinite(FSource.Extent.a.Y));
  Assert(IsInfinite(FSource.Extent.b.X) and IsInfinite(FSource.Extent.b.Y));

  FSource.Add(1, 2);
  AssertExtent(1, 2, 1, 2);

  FSource.Add(3, 4);
  AssertExtent(1, 2, 3, 4);

  FSource.SetXValue(0, -1);
  AssertExtent(-1, 2, 3, 4);

  FSource.SetXValue(1, -2);
  AssertExtent(-2, 2, -1, 4);

  FSource.SetXValue(1, SafeNaN);
  AssertExtent(-1, 2, -1, 4);
  FSource.SetXValue(1, -2);

  FSource.SetYValue(0, 5);
  AssertExtent(-2, 4, -1, 5);

  FSource.SetYValue(0, 4.5);
  AssertExtent(-2, 4, -1, 4.5);

  FSource.SetYValue(1, SafeNaN);
  AssertExtent(-2, 4.5, -1, 4.5);

  FSource.Delete(1);
  AssertExtent(-1, 4.5, -1, 4.5);

  FSource.Clear;
  FSource.Add(1, 1);
  FSource.Add(2, 2);
  FSource.Add(3, 3);
  FSource.Add(4, 4);
  FSource.Delete(0);
  FSource.Delete(1);
  AssertExtent(2, 2, 4, 4);
end;

procedure TListSourceTest.Multi;
begin
  FSource.Clear;
  AssertEquals(1, FSource.YCount);
  AssertEquals(1, FSource.YCount);

  FSource.Add(1, 2);
  FSource.YCount := 2;
  AssertEquals([0], FSource[0]^.YList);

  FSource.SetYList(0, [3]);
  AssertEquals(3, FSource[0]^.YList[0]);

  FSource.DataPoints.Add('1|2|3|?|t');
  AssertEquals(1, FSource.XCount);
  AssertEquals(2, FSource.YCount);
  AssertEquals(1, FSource[1]^.X);
  AssertEquals(2, FSource[1]^.Y);
  AssertEquals(3, FSource[1]^.YList[0]);

  // Check too many parts
  try
    FSource.DataPoints.Add('10|20|30|40|?|');
  except
    on E: Exception do
      AssertTrue('Too many values', E is EListSourceStringError);
  end;
  AssertEquals(2, FSource.Count);

  // Check too few parts
  try
    FSource.DataPoints.Add('10|20|?|');
  except
    on E: Exception do
      AssertTrue('Too few values', E is EListSourceStringError);
  end;
  AssertEquals(2, FSource.Count);

  // Check text part missing
  try
    FSource.DataPoints.Add('10|20|30|?');
  except
    on E: Exception do
      AssertTrue('Text field missing', E is EListSourceStringError);
  end;
  AssertEquals(2, FSource.Count);

  // Check color part missing
  try
    FSource.DataPoints.Add('10|20|30|t');
  except
    on E: Exception do
      AssertTrue('Color field missing', E is EListSourceStringError);
  end;
  AssertEquals(2, FSource.Count);

  // Check non-numeric parts
  try
    FSource.DataPoints.Add('abc|20|30|?|t');
  except
    on E: Exception do
      AssertTrue('Non-numeric X', E is EListSourceStringError);
  end;
  try
    FSource.DataPoints.Add('10|abc|30|?|t');
  except
    on E: Exception do
      AssertTrue('Non-numeric Y', E is EListSourceStringError);
  end;
  try
    FSource.DataPoints.Add('10|20|abc|?|t');
  except
    on E: Exception do
      AssertTrue('Non-numeric YList', E is EListSourceStringError);
  end;
  try
    FSource.DataPoints.Add('10|20|30|abc|t');
  except
    on E: Exception do
      AssertTrue('Non-numeric Color', E is EListSourceStringError);
  end;

  // check empty list
  try
    FSource.AddXYList(4, []);
  except
    on E: Exception do
      AssertTrue('Empty YList', E is TListChartSource.EYListEmptyError);
  end;
  AssertEquals(2, FSource.Count);

  // Check decimal separators
  FSource.DataPoints.Add('1.23|2.34|3|?|t');
  AssertEquals(1.23, FSource[2]^.X);
  AssertEquals(2.34, FSource[2]^.Y);

  FSource.DataPoints.Add('1,23|2,34|3|?|t');
  AssertEquals(1.23, FSource[3]^.X);
  AssertEquals(2.34, FSource[3]^.Y);

  // Check missing values
  FSource.DataPoints.Add('|2|3|?|t');
  AssertTrue('IsNaN', IsNaN(FSource[4]^.X));
  AssertEquals(2, FSource[4]^.Y);
  AssertEquals(3, FSource[4]^.YList[0]);

  FSource.DataPoints.Add('1||3|?|t');
  AssertEquals(1, FSource[5]^.X);
  AssertTrue('IsNaN', IsNaN(FSource[5]^.Y));
  AssertEquals(3, FSource[5]^.YList[0]);

  FSource.DataPoints.Add('1|2|3||t');
  AssertEquals(clTAColor, FSource[6]^.Color);

  // Check Text part containing '|' character(s)
  FSource.DataPoints.Add('1|2|3|?|"a|b|c"');
  AssertEquals('a|b|c', FSource[7]^.Text);

  // Check Text part containing line ending
  FSource.DataPoints.Add('1|2|3|?|"a'+LineEnding+'b"');
  AssertEquals('a'+LineEnding+'b', FSource[8]^.Text);

  // Check Text part containing quotes
  FSource.DataPoints.Add('1|2|3|?|This is "quoted".');
  AssertEquals('This is "quoted".', FSource[9]^.Text);

  FSource.DataPoints.Add('1|2|3|?|"This is ""quoted""."');
  AssertEquals('This is "quoted".', FSource[10]^.Text);

  FSource.DataPoints.Add('1|2|3|?|"This is ""quoted"""');
  AssertEquals('This is "quoted"', FSource[11]^.Text);

  FSource.DataPoints.Add('1|2|3|?|Single ".');
  AssertEquals('Single ".', FSource[12]^.Text);

  FSource.DataPoints.Add('1|2|3|?|Two quotes "".');
  AssertEquals('Two quotes "".', FSource[13]^.Text);

  // Check Text part containing separator and quotes
  FSource.DataPoints.Add('1|2|3|?|"Number of ""|"" items"');
  AssertEquals('Number of "|" items', FSource[14]^.Text);

  // Check multiple x and y values
  FSource.Clear;
  FSource.XCount := 2;
  FSource.YCount := 3;
  FSource.AddXListYList([1, 2], [3, 4, 5]);
  AssertEquals(2, FSource.XCount);
  AssertEquals(3, FSource.YCount);
  AssertEquals(1, FSource[0]^.X);
  AssertEquals(2, FSource[0]^.XList[0]);
  AssertEquals(3, FSource[0]^.Y);
  AssertEquals(4, FSource[0]^.YList[0]);
  AssertEquals(5, FSource[0]^.YList[1]);

  FSource.DataPoints.Add('10|20|30|40|50|?|t');
  AssertEquals(10, FSource[1]^.X);
  AssertEquals(20, FSource[1]^.XList[0]);
  AssertEquals(30, FSource[1]^.Y);
  AssertEquals(40, FSource[1]^.YList[0]);
  AssertEquals(50, FSource[1]^.YList[1]);

  // Add multiple strings in a single AddText command
  FSource.Clear;
  FSource.XCount := 2;
  FSource.YCount := 3;
  FSource.DataPoints.AddText('100|200|300|400|500|?|Data1' + LineEnding +
                             '101|201|301|401|501|?|Data2');
  AssertEquals(2, FSource.Count);
  AssertEquals(2, FSource.XCount);
  AssertEquals(3, FSource.YCount);
  AssertEquals(100, FSource[0]^.X);
  AssertEquals(200, FSource[0]^.XList[0]);
  AssertEquals(300, FSource[0]^.Y);
  AssertEquals(500, FSource[0]^.YList[1]);
  AssertEquals('Data1', FSource[0]^.Text);
  AssertEquals(101, FSource[1]^.X);
  AssertEquals(501, FSource[1]^.YList[1]);
  AssertEquals('Data2', FSource[1]^.Text);

  // Add multiple strings in a single AddStrings command
  FSource.Datapoints.AddStrings(['110|210|310|410|510|?|ABC', '111|211|311|411|511|?|abc']);
  AssertEquals(4, FSource.Count);
  AssertEquals(2, FSource.XCount);
  AssertEquals(3, FSource.YCount);
  AssertEquals(110, FSource[2]^.X);
  AssertEquals(210, FSource[2]^.XList[0]);
  AssertEquals(310, FSource[2]^.Y);
  AssertEquals(510, FSource[2]^.YList[1]);
  AssertEquals('ABC', FSource[2]^.Text);
  AssertEquals(111, FSource[3]^.X);
  AssertEquals(511, FSource[3]^.YList[1]);
  AssertEquals('abc', FSource[3]^.Text);

  (*
  FSource.SetYList(0, [3, 4]);
  AssertEquals('Extra items are chopped', [3], FSource[0]^.YList);
  FSource.DataPoints.Add('1|2|3|4|?|t');
  AssertEquals(3, FSource.YCount);
  AssertEquals(2, FSource[1]^.Y);
  AssertEquals([3, 4], FSource[1]^.YList);

  FSource.AddXYList(2, [7, 8, 9]);
  AssertEquals(3, FSource.YCount);
  AssertEquals(7, FSource[2]^.Y);
  AssertEquals([8, 9], FSource[2]^.YList);
  FSource.AddXYList(3, [10]);
  AssertEquals(4, FSource.Count);
  AssertEquals(3, FSource.YCount);
  AssertEquals(10, FSource[3]^.Y);
  AssertEquals([0, 0], FSource[3]^.YList);
  try
    FSource.AddXYList(4, []);
    Fail('Empty YList');
  except on E: Exception do
    AssertTrue('Empty YList', E is TListChartSource.EYListEmptyError);
  end;
  *)
end;

function TListSourceTest.Compare(AItem1, AItem2: Pointer): Integer;
var
  item1: PChartDataItem absolute AItem1;
  item2: PChartDataItem absolute AItem2;
begin
  Result := CompareValue(item1^.X + item1^.XList[0], item2^.X + item2^.XList[0]);
end;

procedure TListSourceTest.Sort;
begin
  FSource.Clear;
  FSource.XCount := 2;
  FSource.YCount := 2;
  FSource.AddXListYList([1, -0.1], [10, 100], 'A');     // x1+x2 = 0.9
  FSource.AddXListYList([9, 0.9], [90, -900], 'M');     // x1+x2 = 9.9
  FSource.AddXListYList([5, -0.5], [50, 50], 'D');      // x1+x2 = 4.5

  FSource.SortBy := sbX;
  FSource.SortIndex := 0;
  FSource.SortDir := sdAscending;
  FSource.Sorted := true;
  AssertEquals(1, FSource[0]^.X);
  AssertEquals(5, FSource[1]^.X);
  AssertEquals(9, FSource[2]^.X);

  FSource.SortBy := sbX;
  FSource.SortIndex := 1;
  AssertEquals(-0.5, FSource[0]^.XList[0]);
  AssertEquals(-0.1, FSource[1]^.XList[0]);
  AssertEquals( 0.9, FSource[2]^.XList[0]);

  FSource.SortBy := sbY;
  FSource.SortIndex := 0;
  AssertEquals(10, FSource[0]^.Y);
  AssertEquals(50, FSource[1]^.Y);
  AssertEquals(90, FSource[2]^.Y);

  FSource.SortBy := sbY;
  FSource.SortIndex := 1;
  FSource.SortDir := sdDescending;
  AssertEquals(100, FSource[0]^.YList[0]);
  AssertEquals(50, FSource[1]^.YList[0]);
  AssertEquals(-900, FSource[2]^.YList[0]);

  FSource.SortBy := sbText;
  FSource.SortDir := sdDescending;
  AssertEquals('M', FSource[0]^.Text);
  AssertEquals('D', FSource[1]^.Text);
  AssertEquals('A', FSource[2]^.Text);

  FSource.OnCompare := @Compare;
  FSource.SortBy := sbCustom;
  FSource.SortDir := sdAscending;
  AssertEquals(1, FSource[0]^.X);
  AssertEquals(5, FSource[1]^.X);
  AssertEquals(9, FSource[2]^.X);

  FSource.OnCompare := nil;
  FSource.Sorted := false;
end;

procedure TListSourceTest.SetUp;
begin
  inherited SetUp;
  FSource := TListChartSource.Create(nil);
end;

procedure TListSourceTest.TearDown;
begin
  FreeAndNil(FSource);
  inherited TearDown;
end;

{ TRandomSourceTest }

procedure TRandomSourceTest.Extent;
var
  s: TRandomChartSource;
  ext: TDoubleRect;
begin
  s := TRandomChartSource.Create(nil);
  try
    s.XMin := 10;
    s.XMax := 20;
    s.YMin := 5;
    s.YMax := 6;
    s.PointsNumber := 1000;
    ext := s.Extent;
    AssertEquals(10, ext.a.X);
    AssertEquals(20, ext.b.X);
    Assert(ext.a.Y > 5);
    Assert(ext.b.Y < 6);
    Assert(ext.a.Y < ext.b.Y);
  finally
    s.Free;
  end;
end;

{ TIntervalSourceTest }

procedure TIntervalSourceTest.AssertValueEquals(
  const AExpected: array of Double; const AActual: TChartValueTextArray);
var
  i: Integer;
  a: array of Double;
begin
  SetLength(a, Length(AActual));
  for i := 0 to High(AActual) do
    a[i] := AActual[i].FValue;
  AssertEquals(AExpected, a, 1e-6);
end;

procedure TIntervalSourceTest.IntervalSource;
var
  p: TValuesInRangeParams;
  src: TIntervalChartSource;
  r: TChartValueTextArray = nil;
begin
  p := VDummyTransform.PrepareValuesInRangeParams;
  src := TIntervalChartSource.Create(nil);
  try
    src.Params.MaxLength := 15;
    src.ValuesInRange(p, r);
    AssertValueEquals([20, 30, 40, 50, 60, 70], r);
    src.Params.Options := [aipUseCount];
    src.Params.Count := 7;
    src.Params.Tolerance := 1;
    src.ValuesInRange(p, r);
    AssertValueEquals([24, 30, 36, 41, 47, 52, 58, 63, 69, 75], r);
  finally
    p.FIntervals.Free;
    src.Free;
  end;
end;

procedure TIntervalSourceTest.ListSource;
var
  i: Integer;
  p: TValuesInRangeParams;
  r: TChartValueTextArray = nil;
  src: TListChartSource;

  procedure Check(const AExpected: array of Double);
  begin
    r := nil;
    src.ValuesInRange(p, r);
    AssertValueEquals(AExpected, r);
  end;

begin
  p := VDummyTransform.PrepareValuesInRangeParams;
  p.FFormat := '%4:g';
  src := TListChartSource.Create(nil);
  for i := 1 to 10 do
    src.Add(10 * i, i);
  try
    Check([20, 30, 40, 50, 60, 70]);
    p.FIntervals.MinLength := 20;
    Check([20, 30, 50, 70]);
    p.FMin := 81;
    p.FMax := 82;
    Check([80, 90]);
    p.FMin := 9;
    p.FMax := 11;
    Check([10, 20]);
    src.Add(8, 11);
    Check([8, 10, 20]);
    p.FMin := 1;
    p.FMax := 20;
    p.FIntervals.Options := p.FIntervals.Options - [aipUseMinLength];
    Check([8, 10, 20, 30]);
    p.FIntervals.Options := p.FIntervals.Options + [aipUseMinLength];
    p.FMax := 50;
    Check([8, 30, 50, 60]);
    AssertEquals('Lower bound not first in-range value', '8', r[0].FText);
    src.Sort;
    Check([8, 30, 50, 60]);
    p.FIntervals.Tolerance := 3;
    Check([10, 30, 50, 60]);
  finally
    p.FIntervals.Free;
    src.Free;
  end;
end;

initialization

  RegisterTests([
    TListSourceTest, TRandomSourceTest, TCalculatedSourceTest,
    TIntervalSourceTest]);

end.

