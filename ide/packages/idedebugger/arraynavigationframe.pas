unit ArrayNavigationFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Buttons, StdCtrls, LCLType, SpinEx, LazNumEdit,
  IDEImagesIntf, IdeDebuggerStringConstants;

type

  TArrayNavigationBar = class;

  TArrayNavChangeEvent = procedure(Sender: TArrayNavigationBar; AValue: Int64) of object;

  { TArrayNavigationBar }

  TArrayNavigationBar = class(TFrame)
    btnArrayEnd: TSpeedButton;
    btnArrayFastUp: TSpeedButton;
    btnArrayFastDown: TSpeedButton;
    btnArrayPageDec: TSpeedButton;
    btnArrayPageInc: TSpeedButton;
    btnArrayStart: TSpeedButton;
    cbEnforceBound: TCheckBox;
    Label1: TLabel;
    edArrayPageSize: TLazIntegerEdit;
    edArrayStart: TLazIntegerEdit;
    lblBounds: TLabel;
    procedure BtnChangePageClicked(Sender: TObject);
    procedure BtnChangeSizeClicked(Sender: TObject);
    procedure cbEnforceBoundChange(Sender: TObject);
    procedure edArrayPageSizeEditingDone(Sender: TObject);
    procedure edArrayPageSizeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edArrayStartEditingDone(Sender: TObject);
    procedure edArrayStartKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FHardLimits: Boolean;
    FHighBound: int64;
    FLowBound: int64;
    FOnIndexChanged: TArrayNavChangeEvent;
    FOnPageSize: TArrayNavChangeEvent;
    FOnSizeChanged: TNotifyEvent;
    FOwnerData: pointer;
    FShowBoundInfo: Boolean;
    function GetIndex: int64;
    function GetIndexOffs: int64;
    function GetLimitedPageSize: int64;
    function GetPageSize: int64;
    procedure SetHardLimits(AValue: Boolean);
    procedure SetHighBound(AValue: int64);
    procedure SetIndex(AValue: int64);
    procedure SetLowBound(AValue: int64);
    procedure SetPageSize(AValue: int64);
    procedure SetShowBoundInfo(AValue: Boolean);
    procedure UpdateBoundsInfo;
    procedure DoOnSizeChanged;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure Loaded; override;
    property LowBound: int64 read FLowBound write SetLowBound;
    property HighBound: int64 read FHighBound write SetHighBound;
    property ShowBoundInfo: Boolean read FShowBoundInfo write SetShowBoundInfo;

    property Index: int64 read GetIndex write SetIndex;
    property PageSize: int64 read GetPageSize write SetPageSize;
    property IndexOffs: int64 read GetIndexOffs;
    property LimitedPageSize: int64 read GetLimitedPageSize;

    property OwnerData: pointer read FOwnerData write FOwnerData;
  published
    property OnIndexChanged: TArrayNavChangeEvent read FOnIndexChanged write FOnIndexChanged;
    property OnPageSize: TArrayNavChangeEvent read FOnPageSize write FOnPageSize;
    property OnSizeChanged: TNotifyEvent read FOnSizeChanged write FOnSizeChanged;
    property HardLimits: Boolean read FHardLimits write SetHardLimits;
  end;

implementation

{$R *.lfm}

{ TArrayNavigationBar }

procedure TArrayNavigationBar.SetHighBound(AValue: int64);
begin
  if FHighBound = AValue then Exit;
  FHighBound := AValue;
  UpdateBoundsInfo;
end;

procedure TArrayNavigationBar.BtnChangePageClicked(Sender: TObject);
var
  v: int64;
begin
  v := edArrayStart.Value;
  if Sender = btnArrayStart then
    edArrayStart.Value := FLowBound
  else
  if Sender = btnArrayFastDown then begin
    if (v < FLowBound) or (v > FHighBound) then
      edArrayStart.Value := edArrayStart.Value - edArrayPageSize.Value
    else
      edArrayStart.Value := max(edArrayStart.Value - edArrayPageSize.Value,
                                FLowBound);
  end
  else
  if Sender = btnArrayFastUp then begin
    if (v < FLowBound) or (v > FHighBound) then
      edArrayStart.Value := edArrayStart.Value + edArrayPageSize.Value
    else
      edArrayStart.Value := min(edArrayStart.Value + edArrayPageSize.Value,
                                Max(FLowBound,
                                    FHighBound + 1 - edArrayPageSize.Value)
                                );
  end
  else
  if Sender = btnArrayEnd then
    edArrayStart.Value :=  Max(FLowBound,
                               FHighBound + 1 - edArrayPageSize.Value)
  ;
  if (FOnIndexChanged <> nil) and (edArrayStart.Value <> v) then
    FOnIndexChanged(Self, edArrayStart.Value);
end;

procedure TArrayNavigationBar.BtnChangeSizeClicked(Sender: TObject);
var
  v: int64;
begin
  v := edArrayPageSize.Value;
  if Sender = btnArrayPageDec then
    edArrayPageSize.Value := Max(10, edArrayPageSize.Value - 10)
  else
  if Sender = btnArrayPageInc then
    edArrayPageSize.Value := Min(5000, edArrayPageSize.Value + 10)
  ;
  if (FOnPageSize <> nil) and (edArrayPageSize.Value <> v) then
    FOnPageSize(Self, edArrayStart.Value);
end;

procedure TArrayNavigationBar.cbEnforceBoundChange(Sender: TObject);
begin
  UpdateBoundsInfo;
end;

procedure TArrayNavigationBar.edArrayPageSizeEditingDone(Sender: TObject);
begin
  if (FOnPageSize <> nil) then
    FOnPageSize(Self, edArrayStart.Value);
end;

procedure TArrayNavigationBar.edArrayPageSizeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  v: Int64;
begin
  if not edArrayPageSize.Valid then
    exit;
  v := edArrayPageSize.CurrentValue;

  case Key of
    VK_UP: begin
        if ssCtrl in Shift then
          edArrayPageSize.Value := Min(5000, v + 5)
        else
          edArrayPageSize.Value := Min(5000, v + 1);
      end;
    VK_DOWN: begin
        if ssCtrl in Shift then
          edArrayPageSize.Value := Max(10, v - 5)
        else
          edArrayPageSize.Value := Max(10, v - 1);
      end;
    VK_PRIOR: begin
        if ssCtrl in Shift then
          edArrayPageSize.Value := Min(5000, FHighBound - FLowBound+1)
        else
          edArrayPageSize.Value := Min(5000, v + 10);
      end;
    VK_NEXT: begin
        if ssCtrl in Shift then
          edArrayPageSize.Value := 10
        else
          edArrayPageSize.Value := Max(10, v - 10);
      end;
  end;
end;

procedure TArrayNavigationBar.edArrayStartEditingDone(Sender: TObject);
begin
  if (FOnIndexChanged <> nil) then
    FOnIndexChanged(Self, edArrayStart.Value);
end;

procedure TArrayNavigationBar.edArrayStartKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  v, PgSz: Int64;
  OutOfBnd: Boolean;

  function MaxVal(v: int64): integer;
  begin
    if OutOfBnd then
      Result := Min(high(Integer), v)
    else
      Result := Min(FHighBound, v);
  end;
  function MinVal(v: int64): integer;
  begin
    if OutOfBnd then
      Result := Max(low(Integer)+1, v)
    else
      Result := Max(FLowBound, v);
  end;
begin
  if not edArrayStart.Valid then
    exit;

  if (not FHardLimits) and (ssAlt in Shift) then
    cbEnforceBound.Checked := False;

  OutOfBnd := (not FHardLimits) and (not cbEnforceBound.Checked);

  v := edArrayStart.CurrentValue;
  PgSz := edArrayPageSize.CurrentValue;
  case Key of
    VK_UP: begin
        if ssCtrl in Shift then
          edArrayStart.Value := MaxVal(v + Max(2, PgSz div 2))
        else
          edArrayStart.Value := MaxVal(v + 1);
        Key := 0;
      end;
    VK_DOWN: begin
        if ssCtrl in Shift then
          edArrayStart.Value := MinVal(v - Max(2, PgSz div 2))
        else
          edArrayStart.Value := MinVal(v - 1);
        Key := 0;
      end;
    VK_PRIOR: begin
        if ssCtrl in Shift then
          edArrayStart.Value :=  Max(FLowBound,
                                     FHighBound + 1 - PgSz)
        else
          edArrayStart.Value := MaxVal(v + PgSz);
        Key := 0;
      end;
    VK_NEXT: begin
        if ssCtrl in Shift then
          edArrayStart.Value := FLowBound
        else
          edArrayStart.Value := MinVal(v - PgSz);
        Key := 0;
      end;
  end;
end;

function TArrayNavigationBar.GetIndex: int64;
begin
  Result := edArrayStart.Value;
end;

function TArrayNavigationBar.GetIndexOffs: int64;
begin
  Result := edArrayStart.Value - FLowBound;
end;

function TArrayNavigationBar.GetLimitedPageSize: int64;
var
  idx: Int64;
begin
  Result := edArrayPageSize.Value;
  idx := edArrayStart.Value;
  if (idx >= FLowBound) and (idx <= FHighBound) then
    Result := Max(1, Min(Result, FHighBound + 1 - idx));
end;

function TArrayNavigationBar.GetPageSize: int64;
begin
  Result := edArrayPageSize.Value;
end;

procedure TArrayNavigationBar.SetHardLimits(AValue: Boolean);
begin
  if FHardLimits = AValue then
    exit;
  FHardLimits := AValue;
  UpdateBoundsInfo;
  cbEnforceBound.Visible := not FHardLimits;
end;

procedure TArrayNavigationBar.SetIndex(AValue: int64);
begin
  edArrayStart.Value := AValue;
end;

procedure TArrayNavigationBar.SetLowBound(AValue: int64);
begin
  if FLowBound = AValue then Exit;
  FLowBound := AValue;
  UpdateBoundsInfo;
end;

procedure TArrayNavigationBar.SetPageSize(AValue: int64);
begin
  edArrayPageSize.Value := AValue;
end;

procedure TArrayNavigationBar.Loaded;
begin
  inherited Loaded;
  Constraints.MinWidth := btnArrayPageInc.Left + btnArrayPageInc.Width;
end;

procedure TArrayNavigationBar.SetShowBoundInfo(AValue: Boolean);
begin
  if FShowBoundInfo = AValue then Exit;
  FShowBoundInfo := AValue;

  lblBounds.Visible := FShowBoundInfo;
  UpdateBoundsInfo;
end;

procedure TArrayNavigationBar.UpdateBoundsInfo;
begin
  if FHardLimits or cbEnforceBound.Checked then begin
    edArrayPageSize.Visible := FHighBound + 1 - FLowBound > edArrayPageSize.MinValue;
    btnArrayPageInc.Visible := FHighBound + 1 - FLowBound > edArrayPageSize.MinValue;
    btnArrayPageDec.Visible := FHighBound + 1 - FLowBound > edArrayPageSize.MinValue;
    edArrayStart.MinValue := FLowBound;
    edArrayStart.MaxValue := FHighBound;
  end
  else begin
    edArrayPageSize.Visible := True;
    btnArrayPageInc.Visible := True;
    btnArrayPageDec.Visible := True;
    edArrayStart.MaxValue := High(Integer)+1;
    edArrayStart.MinValue := Low(Integer);
  end;

  if FShowBoundInfo then
    lblBounds.Caption := format(dlgInspectBoundsDD, [FLowBound, FHighBound]);
  DoOnSizeChanged;
end;

procedure TArrayNavigationBar.DoOnSizeChanged;
begin
  if FOnSizeChanged <> nil then
    FOnSizeChanged(Self);
end;

constructor TArrayNavigationBar.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Name := '';
  Constraints.MinWidth := btnArrayPageInc.Left + btnArrayPageInc.Width;

  edArrayStart.Hint := dlgInspectIndexOfFirstItemToShow;
  edArrayPageSize.Hint := dlgInspectAmountOfItemsToShow;

  btnArrayStart.Images     := IDEImages.Images_16;
  btnArrayStart.ImageIndex := IDEImages.LoadImage('NavArrow_F');
  btnArrayStart.Caption    := '';

  btnArrayFastDown.Images     := IDEImages.Images_16;
  btnArrayFastDown.ImageIndex := IDEImages.LoadImage('NavArrow_L');
  btnArrayFastDown.Caption    := '';

  btnArrayFastUp.Images     := IDEImages.Images_16;
  btnArrayFastUp.ImageIndex := IDEImages.LoadImage('NavArrow_R');
  btnArrayFastUp.Caption    := '';

  btnArrayEnd.Images     := IDEImages.Images_16;
  btnArrayEnd.ImageIndex := IDEImages.LoadImage('NavArrow_E');
  btnArrayEnd.Caption    := '';

  btnArrayPageDec.Images     := IDEImages.Images_16;
  btnArrayPageDec.ImageIndex := IDEImages.LoadImage('NavMinus');
  btnArrayPageDec.Caption    := '';

  btnArrayPageInc.Images     := IDEImages.Images_16;
  btnArrayPageInc.ImageIndex := IDEImages.LoadImage('NavPlus');
  btnArrayPageInc.Caption    := '';

  btnArrayFastDown.Caption := '';

  cbEnforceBound.Caption := arrnavEnforceBounds;
end;

end.

