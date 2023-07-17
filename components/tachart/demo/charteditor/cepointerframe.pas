unit cePointerFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Spin,
  TATypes, TAChartCombos, TAGraph,
  ceBrushFrame, cePenFrame;

type

  { TChartPointerFrame }

  TChartPointerFrame = class(TFrame)
    cbPointerStyle: TChartComboBox;
    GroupBox1: TGroupBox;
    gbPointerBrush: TGroupBox;
    gbPointerPen: TGroupBox;
    lblPointerSize: TLabel;
    sePointerSize: TSpinEdit;
    procedure cbPointerStyleChange(Sender: TObject);
    procedure sePointerSizeChange(Sender: TObject);
  private
    FPointer: TSeriesPointer;
    FPointerBrushFrame: TChartBrushFrame;
    FPointerPenFrame: TChartPenFrame;
    FOnChange: TNotifyEvent;
    procedure ChangedHandler(Sender: TObject);
    procedure DoChange;
  protected
    function GetChart: TChart;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Prepare(APointer: TSeriesPointer);
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

{$R *.lfm}

type
  TSeriesPointerAccess = class(TSeriesPointer);

constructor TChartPointerFrame.Create(AOwner: TComponent);
begin
  inherited;
  cbPointerStyle.DropdownCount := DEFAULT_DROPDOWN_COUNT;

  FPointerBrushFrame := TChartBrushFrame.Create(Self);
  FPointerBrushFrame.Name := '';
  FPointerBrushFrame.Align := alClient;
  FPointerBrushFrame.AutoSize := true;
  FPointerBrushFrame.BorderSpacing.Around := 8;
  FPointerBrushFrame.OnChange := @ChangedHandler;
  FPointerBrushFrame.Parent := gbPointerBrush;
  gbPointerBrush.Caption := 'Fill';
  gbPointerBrush.AutoSize := true;

  FPointerPenFrame := TChartPenFrame.Create(self);
  FPointerPenFrame.Name := '';
  FPointerPenFrame.Align := alClient;
  FPointerPenFrame.AutoSize := true;
  FPointerPenFrame.borderspacing.Around := 8;
  FPointerPenFrame.OnChange := @ChangedHandler;
  FPointerPenFrame.Parent := gbPointerPen;
  gbPointerPen.Caption := 'Border';
  gbPointerPen.AutoSize := true;

  AutoSize := true;
end;

procedure TChartPointerFrame.cbPointerStyleChange(Sender: TObject);
begin
  FPointer.Style := cbPointerStyle.PointerStyle;
  DoChange;
end;

procedure TChartPointerFrame.ChangedHandler(Sender: TObject);
begin
  DoChange;
end;

procedure TChartPointerFrame.sePointerSizeChange(Sender: TObject);
begin
  FPointer.HorizSize := sePointerSize.Value;
  FPointer.VertSize := sePointerSize.Value;
  DoChange;
end;

procedure TChartPointerFrame.DoChange;
begin
  if Assigned(FOnChange) then FOnChange(FPointer);
end;

function TChartPointerFrame.GetChart: TChart;
begin
  Result := TSeriesPointerAccess(FPointer).GetOwner as TChart;
end;

procedure TChartPointerFrame.Prepare(APointer: TSeriesPointer);
begin
  FPointer := APointer;
  cbPointerStyle.PointerStyle := APointer.Style;
  sePointerSize.Value := APointer.HorizSize;
  FPointerBrushFrame.Prepare(APointer.Brush);
  FPointerPenFrame.Prepare(APointer.Pen);
end;

end.

