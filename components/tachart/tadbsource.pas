{

 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Authors: Alexander Klenin

}
unit TADbSource;

{$MODE ObjFPC}{$H+}
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
interface

uses
  Classes, Db, TAChartUtils, TACustomSource;

type

  TDbChartSourceOptions = set of (dcsoDateTimeX, dcsoDateTimeY);

  TDbChartSource = class;

  TDbChartSourceGetItemEvent = procedure (
    ASender: TDbChartSource; var AItem: TChartDataItem) of object;

  { TDbChartSource }

  TDbChartSource = class(TCustomChartSource)
  strict private
    FBookmark: TBookmark;
    FCurItem: TChartDataItem;
    FDataLink: TDataLink;
    FDateTimeFormat: String;
    FFieldColor: String;
    FFieldText: String;
    FFieldX: String;
    FFieldY: String;
    FFieldXList: TStringList;
    FFieldYList: TStringList;
    FOnGetItem: TDbChartSourceGetItemEvent;
    FOptions: TDbChartSourceOptions;

    function GetDataSource: TDataSource; inline;
    procedure SetDataSource(AValue: TDataSource);
    procedure SetFieldColor(const AValue: String);
    procedure SetFieldText(const AValue: String);
    procedure SetFieldX(const AValue: String);
    procedure SetFieldY(const AValue: String);
    procedure SetOnGetItem(AValue: TDbChartSourceGetItemEvent);
    procedure SetOptions(AValue: TDbChartSourceOptions);
  protected
    function GetCount: Integer; override;
    function GetItem(AIndex: Integer): PChartDataItem; override;
    procedure SetXCount(AValue: Cardinal); override;
    procedure SetYCount(AValue: Cardinal); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure AfterDraw; override;
    procedure BeforeDraw; override;
    function DataSet: TDataSet; inline;
    procedure DefaultGetItem(var AItem: TChartDataItem);
    procedure Reset;
  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DateTimeFormat: String read FDateTimeFormat write FDateTimeFormat;
    property FieldColor: String read FFieldColor write SetFieldColor;
    property FieldText: String read FFieldText write SetFieldText;
    property FieldX: String read FFieldX write SetFieldX;
    property FieldY: String read FFieldY write SetFieldY;
    property Options: TDbChartSourceOptions read FOptions write SetOptions default [];
  published
    property OnGetItem: TDbChartSourceGetItemEvent read FOnGetItem write SetOnGetItem;
  end;

procedure Register;

implementation

uses
  Math, SysUtils, DateUtils, TAMath;

type

  { TDbChartSourceDataLink }

  TDbChartSourceDataLink = class(TDataLink)
  strict private
    FChartSrc: TDbChartSource;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(ADistance: Integer); override;
    procedure UpdateData; override;
  public
    constructor Create(ASrc: TDbChartSource);
  end;

// FIXME: This is a workaround for issue #19887.
// Remove when dataset gains the capability to turn data events off.
var
  VLockedDatasets: TFPList;

{ TDbChartSourceDataLink }

procedure TDbChartSourceDataLink.ActiveChanged;
begin
  inherited ActiveChanged;
  // Make associated series check XCount and YCount.
  if (FChartSrc.ComponentState = []) and Assigned(Dataset) and (Dataset.State <> dsInactive) then
    FChartSrc.Reset;
end;

constructor TDbChartSourceDataLink.Create(ASrc: TDbChartSource);
begin
  FChartSrc := ASrc;
  VisualControl := true;
end;

procedure TDbChartSourceDataLink.DataSetChanged;
begin
  inherited DataSetChanged;
  if DataSet.State = dsBrowse then
    FChartSrc.Reset;
end;

procedure TDbChartSourceDataLink.DataSetScrolled(ADistance: Integer);
begin
  Unused(ADistance); // No need to react on scrolling.
end;

procedure TDbChartSourceDataLink.UpdateData;
begin
  inherited UpdateData;
  FChartSrc.Reset;
end;


{ TDbChartSource }

procedure TDbChartSource.AfterDraw;
begin
  inherited AfterDraw;
  try
    if not FDataLink.Active or (FBookmark = nil) then exit;
    FDataLink.Dataset.EnableControls;
    FDataLink.DataSet.GotoBookmark(FBookmark);
    FDataLink.DataSet.FreeBookmark(FBookmark);
  finally
    FBookmark := nil;
    VLockedDatasets.Remove(FDataLink.DataSet);
  end;
end;

procedure TDbChartSource.BeforeDraw;
begin
  inherited BeforeDraw;
  VLockedDatasets.Add(FDataLink.DataSet);
  FDataLink.Dataset.DisableControls;
  if FDataLink.Active and (FBookmark = nil) then
    FBookmark := FDataLink.DataSet.GetBookmark;
end;

constructor TDbChartSource.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TDbChartSourceDataLink.Create(Self);
  FFieldXList := TStringList.Create;
  FFieldXList.StrictDelimiter := true;
  FFieldYList := TStringList.Create;
  FFieldYList.StrictDelimiter := true;
  FXCount := 1;    // Even when no FieldX is specified there is an x value (sequential counter).
  FYCount := 0;    // Has been set to 1 by inherited constructor
end;

function TDbChartSource.DataSet: TDataSet;
begin
  Result := FDataLink.DataSet;
end;

procedure TDbChartSource.DefaultGetItem(var AItem: TChartDataItem);

  function FieldValueOrNaN(
    ADataset: TDataSet; const AFieldName: String; ADateTime: Boolean): Double;
  begin
    with ADataset.FieldByName(AFieldName) do
      if IsNull then
        Result := SafeNan
      else if ADateTime then
      begin
        if (DataType = ftString) and (FDateTimeFormat <> '')  then
          Result := ScanDateTime(FDateTimeFormat, AsString)
        else
          Result := AsDateTime
      end else
        Result := AsFloat;
  end;

var
  ds: TDataSet;
  i: Integer;
begin
  ds := DataSet;

  if FFieldXList.Count > 0 then begin
    AItem.X := FieldValueOrNaN(ds, FFieldXList[0], dcsoDateTimeX in Options);
    for i := 0 to High(AItem.XList) do
      AItem.XList[i] :=
        FieldValueOrNaN(ds, FFieldXList[i + 1], false);  // no date/time in extra x values
  end else
    AItem.X := ds.RecNo;

  if FYCount > 0 then begin
    AItem.Y := FieldValueOrNaN(ds, FFieldYList[0], dcsoDateTimeY in Options);
    for i := 0 to High(AItem.YList) do
      AItem.YList[i] :=
        FieldValueOrNaN(ds, FFieldYList[i + 1], false);  // not date/time in extra y values!
  end;

  if FieldColor <> '' then
    AItem.Color := ds.FieldByName(FieldColor).AsInteger;

  if FieldText <> '' then
    AItem.Text := ds.FieldByName(FieldText).AsString;
end;

destructor TDbChartSource.Destroy;
begin
  FreeAndNil(FDataLink);
  FreeAndNil(FFieldXList);
  FreeAndNil(FFieldYList);
  inherited;
end;

function TDbChartSource.GetCount: Integer;
begin
  if FDataLink.Active then
    Result := DataSource.DataSet.RecordCount
  else
    Result := 0;
end;

function TDbChartSource.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TDbChartSource.GetItem(AIndex: Integer): PChartDataItem;
var
  ds: TDataSet;
begin
  Result := @FCurItem;
  SetDataItemDefaults(FCurItem);
  if not FDataLink.Active then exit;

  Inc(AIndex); // RecNo is counted from 1
  ds := DataSet;
  if ds.IsUniDirectional then begin
    if ds.RecNo < AIndex then
      ds.First;
  end
  else begin
    if AIndex > ds.RecNo - AIndex then
      while (ds.RecNo > AIndex) and not ds.BOF do
        ds.Prior
    else
      ds.First;
  end;
  while (ds.RecNo < AIndex) and not ds.EOF do
    ds.Next;
  if ds.RecNo <> AIndex then begin
    // Either the requested item is out of range, or the dataset is filtered.
    FCurItem.X := SafeNaN;
    FCurItem.Y := SafeNaN;
    exit;
  end;
  if Assigned(OnGetItem) then
    // Data in unusual format, e.g. dates in non-current locale, will cause
    // errors in DefaultGetItem -- so don't call it before the handler.
    // User may call it himself if he deems it safe and necessary.
    OnGetItem(Self, FCurItem)
  else
    DefaultGetItem(FCurItem);
end;

procedure TDbChartSource.Reset;
begin
  InvalidateCaches;
  if VLockedDatasets.IndexOf(FDataLink.DataSet) >= 0 then exit;
  Notify;
end;

procedure TDbChartSource.SetDataSource(AValue: TDataSource);
begin
  if DataSource = AValue then exit;
  FDataLink.DataSource := AValue;
end;

procedure TDbChartSource.SetFieldColor(const AValue: String);
begin
  if FFieldColor = AValue then exit;
  FFieldColor := AValue;
  Reset;
end;

procedure TDbChartSource.SetFieldText(const AValue: String);
begin
  if FFieldText = AValue then exit;
  FFieldText := AValue;
  Reset;
end;

procedure TDbChartSource.SetFieldX(const AValue: String);
begin
  if FFieldX = AValue then exit;
  FFieldX := AValue;
  if FFieldX = '' then
    FFieldXList.Clear
  else
    FFieldXList.CommaText := FFieldX;
  FXCount := Min(1, FFieldXList.Count);
  // There is always one x value even if FieldX is not specified (sequential counter).
  SetLength(FCurItem.XList, Max(FXCount - 1, 0));
  Reset;
end;

procedure TDbChartSource.SetFieldY(const AValue: String);
begin
  if FFieldY = AValue then exit;
  FFieldY := AValue;
  if FFieldY = '' then
    FFieldYList.Clear
  else
    FFieldYList.CommaText := FFieldY;
  FYCount := FFieldYList.Count;
  SetLength(FCurItem.YList, Max(FYCount - 1, 0));
  SetLength(FYRange, FYCount);
  SetLength(FYRangeValid, FYCount);
  Reset;
end;

procedure TDbChartSource.SetOnGetItem(AValue: TDbChartSourceGetItemEvent);
begin
  if TMethod(FOnGetItem) = TMethod(AValue) then exit;
  FOnGetItem := AValue;
  Reset;
end;

procedure TDbChartSource.SetOptions(AValue: TDbChartSourceOptions);
begin
  if FOptions = AValue then exit;
  FOptions := AValue;
  Reset;
end;

procedure TDbChartSource.SetXCount(AValue: Cardinal);
begin
  Unused(AValue);
  raise EXCountError.Create('Set FieldX instead');
end;

procedure TDbChartSource.SetYCount(AValue: Cardinal);
begin
  Unused(AValue);
  raise EYCountError.Create('Set FieldY instead');
end;


procedure Register;
begin
  RegisterComponents(CHART_COMPONENT_IDE_PAGE, [TDbChartSource]);
end;


initialization
  VLockedDatasets := TFPList.Create;

finalization
  FreeAndNil(VLockedDatasets);

end.

