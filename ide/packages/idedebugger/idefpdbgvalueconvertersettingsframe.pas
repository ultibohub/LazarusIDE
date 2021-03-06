unit IdeFpDbgValueConverterSettingsFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, CheckLst, LCLIntf,
  Dialogs, StrUtils, FpDebugValueConvertors, IdeDebuggerStringConstants,
  IdeDebuggerFpDbgValueConv;

type

  { TFpDbgValConvFrame }

  TFpDbgValConvFrame = class(TFrame)
    btnAdd: TButton;
    btnRemove: TButton;
    EdName: TEdit;
    lblName: TLabel;
    lstConverters: TCheckListBox;
    dropAction: TComboBox;
    lblAction: TLabel;
    lblTypeNames: TLabel;
    lblDesc: TLabel;
    memoTypeNames: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    pnlCurrentConv: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure lstConvertersClick(Sender: TObject);
    procedure lstConvertersItemClick(Sender: TObject; Index: integer);
  private
    FValConvList: TIdeFpDbgConverterConfigList;
    FCurIdx: Integer;
    FCurValConv: TIdeFpDbgConverterConfig;
    procedure FillList;
    procedure UpdateButtons;
    procedure SetValConvList(AValue: TIdeFpDbgConverterConfigList);
  public
    constructor Create(TheOwner: TComponent); override;
    procedure SaveCurrent;
    procedure Setup;

    property ValConvList: TIdeFpDbgConverterConfigList read FValConvList write SetValConvList;
  end;

implementation

{$R *.lfm}

{ TFpDbgValConvFrame }

procedure TFpDbgValConvFrame.btnAddClick(Sender: TObject);
var
  AvailClass: TFpDbgValueConverterClassList;
  AName: String;
  obj: TIdeFpDbgConverterConfig;
begin
  AName := InputBox(dlgIdeDbgNewItem, dlgIdeDbgEnterName, '');
  if AName = '' then
    exit;

  SaveCurrent;

  FCurValConv := nil;
  AvailClass := ValueConverterClassList;
  obj := TIdeFpDbgConverterConfig.Create(AvailClass[0].Create);
  obj.Enabled := True;
  obj.Name := AName;
  obj.MatchKinds := obj.Converter.GetSupportedKinds;
  FValConvList.Add(obj);

  FillList;
  lstConverters.ItemIndex := lstConverters.Count-1;
  lstConvertersClick(nil);
  memoTypeNames.SetFocus;
end;

procedure TFpDbgValConvFrame.btnRemoveClick(Sender: TObject);
var
  i: Integer;
begin
  SaveCurrent;
  FCurValConv := nil;
  i := lstConverters.ItemIndex;
  FValConvList.Delete(i);

  FillList;
  if i > lstConverters.Count then
    dec(i);
  lstConverters.ItemIndex := i;
  lstConvertersClick(nil);
end;

procedure TFpDbgValConvFrame.lstConvertersClick(Sender: TObject);
var
  AvailClass: TFpDbgValueConverterClassList;
begin
  SaveCurrent;
  pnlCurrentConv.Enabled := lstConverters.Count > 0;

  FCurIdx := lstConverters.ItemIndex;
  if FCurIdx >= FValConvList.Count then begin
    FCurIdx := -1;
    FCurValConv := nil;
    lblDesc.Caption := '';
    EdName.Text := '';
    memoTypeNames.Text := '';
  end
  else
    FCurValConv := FValConvList[FCurIdx];

  lblDesc.Caption := FCurValConv.Converter.GetName;
  EdName.Text := FCurValConv.Name;
  memoTypeNames.Text := FCurValConv.MatchTypeNames.Text;

  AvailClass := ValueConverterClassList;
  dropAction.ItemIndex := AvailClass.IndexOf(TFpDbgValueConverterClass(FCurValConv.Converter.ClassType));

  lstConvertersItemClick(nil, FCurIdx);
end;

procedure TFpDbgValConvFrame.lstConvertersItemClick(Sender: TObject; Index: integer);
begin
  if Index < 0 then
    exit;

  if (FValConvList[Index].Enabled <> lstConverters.Checked[Index]) then begin
    FValConvList[Index].Enabled := lstConverters.Checked[Index];
    FValConvList.Changed := True;
  end;

  if FCurIdx <> lstConverters.ItemIndex then
    lstConvertersClick(nil);

  UpdateButtons;
end;

procedure TFpDbgValConvFrame.FillList;
var
  i: Integer;
  obj: TIdeFpDbgConverterConfig;
begin
  FCurValConv := nil;

  lstConverters.Clear;
  for i := 0 to FValConvList.Count - 1 do begin
    obj := FValConvList[i];
    lstConverters.AddItem(obj.Name, nil);
    lstConverters.Checked[i] := obj.Enabled;
  end;
end;

procedure TFpDbgValConvFrame.UpdateButtons;
begin
  btnAdd.Enabled := ValueConverterClassList.Count > 0;
  btnRemove.Enabled := (lstConverters.Count > 0) and (lstConverters.ItemIndex >= 0);
  pnlCurrentConv.Enabled := FCurValConv <> nil;
end;

procedure TFpDbgValConvFrame.SetValConvList(AValue: TIdeFpDbgConverterConfigList);
begin
  if FValConvList = AValue then Exit;
  FValConvList := AValue;
  FCurValConv := nil;

  FillList;

  if FValConvList.Count > 0 then begin
    lstConverters.ItemIndex := 0;
    lstConvertersClick(nil);
  end;
  UpdateButtons;
end;

procedure TFpDbgValConvFrame.SaveCurrent;
var
  AvailClass: TFpDbgValueConverterClassList;
begin
  if FCurValConv = nil then
    exit;

  AvailClass := ValueConverterClassList;
  if (TrimSet(FCurValConv.MatchTypeNames.Text, [#1..#32]) <> TrimSet(memoTypeNames.Text, [#1..#32])) or
     (dropAction.ItemIndex <> AvailClass.IndexOf(TFpDbgValueConverterClass(FCurValConv.Converter.ClassType))) or
     (EdName.Text <> FCurValConv.Name)
  then begin
    FValConvList.Changed := True;
    if (dropAction.ItemIndex <> AvailClass.IndexOf(TFpDbgValueConverterClass(FCurValConv.Converter.ClassType))) then begin
      FCurValConv.Converter := AvailClass[dropAction.ItemIndex].Create;
      FCurValConv.MatchKinds := FCurValConv.Converter.GetSupportedKinds;
    end;
    FCurValConv.MatchTypeNames.Text := memoTypeNames.Text;
    FCurValConv.Name := EdName.Text
  end;
end;

procedure TFpDbgValConvFrame.Setup;
var
  AvailClass: TFpDbgValueConverterClassList;
  i: Integer;
begin
  btnAdd.Caption       := dlgFpConvOptAddNew;
  btnRemove.Caption    := dlgFpConvOptRemove;
  lblName.Caption      := dlgFpConvOptName;
  lblTypeNames.Caption := dlgFpConvOptMatchTypesByName;
  lblAction.Caption    := dlgFpConvOptAction;

  FCurValConv := nil;
  lblDesc.Caption := '-';

  dropAction.Clear;
  AvailClass := ValueConverterClassList;
  for i := 0 to ValueConverterClassList.Count - 1 do
    dropAction.AddItem(AvailClass[i].GetName, nil);

  UpdateButtons;
end;

constructor TFpDbgValConvFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Setup;
end;

end.

