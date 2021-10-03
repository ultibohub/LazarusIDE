{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract:
    Dialog for the TStrings property editor.
}
unit StringsPropEditDlg;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  // LCL
  Forms, Controls, StdCtrls, ButtonPanel,
  // LazUtils
  LazUTF8,
  // IdeIntf
  TextTools, ObjInspStrConsts, IDEWindowIntf;

type

  { TStringsPropEditorFrm }

  TStringsPropEditorFrm = class(TForm)
    BtnPanel: TButtonPanel;
    ClearButton: TButton;
    StatusLabel: TLabel;
    SortButton: TButton;
    TextGroupBox: TGroupBox;
    Memo: TMemo;
    procedure ClearButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure SortButtonClick(Sender: TObject);
  public
    procedure AddButtons; virtual;
  end;


implementation

{$R *.lfm}

{ TStringsPropEditorFrm }

procedure TStringsPropEditorFrm.FormCreate(Sender: TObject);
begin
  Caption := oisStringsEditorDialog;
  StatusLabel.Caption := ois0Lines0Chars;
  SortButton.Caption := oisSort;
  ClearButton.Caption := oisClear;
  AddButtons;
  IDEDialogLayoutList.ApplyLayout(Self);
end;

procedure TStringsPropEditorFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IDEDialogLayoutList.SaveLayout(Self);
end;

procedure TStringsPropEditorFrm.ClearButtonClick(Sender: TObject);
begin
  Memo.Clear;
end;

procedure TStringsPropEditorFrm.MemoChange(Sender: TObject);
var
  NumChars: Integer;
  I: Integer;
begin
  NumChars := 0;
  for I := 0 to Memo.Lines.Count - 1 do
    Inc(NumChars, Utf8Length(Memo.Lines[I]));

  if Memo.Lines.Count = 1 then
    StatusLabel.Caption := Format(ois1LineDChars, [NumChars])
  else
    StatusLabel.Caption := Format(oisDLinesDChars, [Memo.Lines.Count, NumChars]);
end;

procedure TStringsPropEditorFrm.SortButtonClick(Sender: TObject);
var
  OldText, NewSortedText: String;
  SortOnlySelection: Boolean;
begin
  if not Assigned(ShowSortSelectionDialogFunc) then
  begin
    SortButton.Enabled := False;
    Exit;
  end;

  SortOnlySelection := True;
  OldText := Memo.SelText;
  if OldText = '' then
  begin
    SortOnlySelection := False;
    OldText := Memo.Lines.Text;
  end;

  NewSortedText:='';
  if ShowSortSelectionDialogFunc(OldText, nil, NewSortedText) <> mrOk then Exit;
  if SortOnlySelection then
    Memo.SelText := NewSortedText
  else
    Memo.Lines.Text := NewSortedText;
end;

procedure TStringsPropEditorFrm.AddButtons;
begin
  //
end;

end.

