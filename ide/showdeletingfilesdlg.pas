unit ShowDeletingFilesDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ButtonPanel, LazarusIDEStrConsts, IDEWindowIntf, CheckLst;

type

  { TShowDeletingFilesDialog }

  TShowDeletingFilesDialog = class(TForm)
    ButtonPanel: TButtonPanel;
    UnCheckAll: TCheckBox;
    FileList: TCheckListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure UnCheckAllChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

implementation

{$R *.lfm}

{ TShowDeletingFilesDialog }

procedure TShowDeletingFilesDialog.FormCreate(Sender: TObject);
begin
  Caption:=lisDeleteAllTheseFiles;
  FileList.Clear;
  UnCheckAll.Caption := lisCheckUncheckAll;
  IDEDialogLayoutList.ApplyLayout(Self);
end;

procedure TShowDeletingFilesDialog.FormDestroy(Sender: TObject);
begin
  IDEDialogLayoutList.SaveLayout(Self);
end;

procedure TShowDeletingFilesDialog.UnCheckAllChange(Sender: TObject);
var
  i: integer;
begin
  //check / uncheck all
  for i := 0 to FileList.Count - 1 do
    FileList.Checked[i] := UnCheckAll.Checked;
end;

end.

