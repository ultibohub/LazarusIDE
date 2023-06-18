{ Copyright (C) 2008 Darius Blaszijk

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.
}

unit SVNStatusForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process,
  Forms, Controls, Dialogs, ComCtrls, StdCtrls, ButtonPanel, ExtCtrls, Menus,
  // LazUtils
  LazFileUtils, LazConfigStorage, UTF8Process, LazLoggerBase,
  // IDEIntf
  LazIDEIntf, BaseIDEIntf,
  // LazSvn
  SVNClasses;

type
  { TSVNStatusFrm }

  TSVNStatusFrm = class(TForm)
    ButtonPanel: TButtonPanel;
    CommitMsgHistoryLabel: TLabel;
    CommitMsgLabel: TLabel;
    Panel1: TPanel;
    ImageList: TImageList;
    mnuOpen: TMenuItem;
    mnuRemove: TMenuItem;
    mnuAdd: TMenuItem;
    mnuRevert: TMenuItem;
    mnuShowDiff: TMenuItem;
    PopupMenu1: TPopupMenu;
    Splitter: TSplitter;
    SVNCommitMsgHistoryComboBox: TComboBox;
    SVNCommitMsgMemo: TMemo;
    SVNFileListView: TListView;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuAddClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuRemoveClick(Sender: TObject);
    procedure mnuRevertClick(Sender: TObject);
    procedure mnuShowDiffClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure PatchButtonClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SVNCommitMsgHistoryComboBoxChange(Sender: TObject);
    procedure SVNFileListViewColumnClick(Sender: TObject; Column: TListColumn);
  private
    FRepositoryPath: string;
    SVNStatus: TSVNStatus;
    procedure Initialize({%H-}Data: PtrInt);
    procedure ExecuteSvnCommand(ACommand: String; AFile: String);
    procedure UpdateFilesListView;
    procedure ChangeCursor(ACursor: TCursor);
    procedure UpdateCheckedStatus;
  public
    {path the root of the local working copy}
    property RepositoryPath: string read FRepositoryPath write FRepositoryPath;
  end;

procedure ShowSVNStatusFrm(ARepoPath: string);

var
  SVNStatusFrm: TSVNStatusFrm;

implementation

{$R *.lfm}

uses
  SVNDiffForm, SVNCommitForm;

procedure ShowSVNStatusFrm(ARepoPath: string);
begin
  if not Assigned(SVNStatusFrm) then
    SVNStatusFrm := TSVNStatusFrm.Create(nil);
  SVNStatusFrm.ChangeCursor(crHourGlass);
  SVNStatusFrm.RepositoryPath:=ARepoPath;
  SVNStatusFrm.Show;
end;

{ TSVNStatusFrm }

procedure TSVNStatusFrm.FormShow(Sender: TObject);
begin
  Caption := Format('%s - %s ...', [RepositoryPath, rsLazarusSVNCommit]);
  CommitMsgHistoryLabel.Caption:=rsCommitMsgHistory;
  CommitMsgLabel.Caption:=rsCommitMsg;
  Application.QueueAsyncCall(@Initialize, 0);
end;

procedure TSVNStatusFrm.Initialize(Data: PtrInt);
begin
  SVNStatus := TSVNStatus.Create(RepositoryPath, false);
  SVNStatus.Sort(siChecked, sdAscending);
  UpdateFilesListView;
  ChangeCursor(crDefault);
end;

procedure TSVNStatusFrm.mnuRevertClick(Sender: TObject);
begin
  if Assigned(SVNFileListView.Selected) then
  begin
    ExecuteSvnCommand('revert', SVNFileListView.Selected.SubItems[0]);

    //now delete the entry from the list
    SVNStatus.List.Delete(SVNFileListView.Selected.Index);

    //update the listview again
    UpdateFilesListView;
  end;
end;

procedure TSVNStatusFrm.mnuAddClick(Sender: TObject);
begin
  if Assigned(SVNFileListView.Selected) then
  begin
    ExecuteSvnCommand('add', SVNFileListView.Selected.SubItems[0]);

    // completely re-read the status
    SVNStatus.Free;
    SVNStatus := TSVNStatus.Create(RepositoryPath, false);
    SVNStatus.Sort(siChecked, sdAscending);
    UpdateFilesListView;
  end;
end;

procedure TSVNStatusFrm.mnuOpenClick(Sender: TObject);
var
  FileName: String;
begin
  if Assigned(SVNFileListView.Selected) then
  begin
    FileName := CreateAbsolutePath(SVNFileListView.Selected.SubItems[0], RepositoryPath);
    LazarusIDE.DoOpenEditorFile(FileName, -1, -1, [ofOnlyIfExists]);
  end;
end;

procedure TSVNStatusFrm.mnuRemoveClick(Sender: TObject);
begin
  if Assigned(SVNFileListView.Selected) then
  begin
    ExecuteSvnCommand('remove --keep-local', SVNFileListView.Selected.SubItems[0]);

    // completely re-read the status
    SVNStatus.Free;
    SVNStatus := TSVNStatus.Create(RepositoryPath, false);
    SVNStatus.Sort(siChecked, sdAscending);
    UpdateFilesListView;
  end;
end;

procedure TSVNStatusFrm.ExecuteSvnCommand(ACommand: String; AFile: String);
var
  AProcess: TProcessUTF8;
begin
  AProcess := TProcessUTF8.Create(nil);

  if pos(RepositoryPath, AFile) <> 0 then
    AProcess.CommandLine := SVNExecutable + ' ' + ACommand + ' "' + AFile + '"'
  else
    AProcess.CommandLine := SVNExecutable + ' ' + ACommand + ' "' + AppendPathDelim(RepositoryPath) + AFile + '"';

  debugln('TSVNStatusFrm.ExecuteSvnCommand commandline=', AProcess.CommandLine);
  AProcess.Options := AProcess.Options + [poWaitOnExit];
  AProcess.ShowWindow := swoHIDE;
  AProcess.Execute;
  AProcess.Free;
end;

procedure TSVNStatusFrm.mnuShowDiffClick(Sender: TObject);

begin
  if Assigned(SVNFileListView.Selected) then
  begin
    debugln('TSVNStatusFrm.mnuShowDiffClick Path=' ,SVNFileListView.Selected.SubItems[0]);

    if pos(RepositoryPath,SVNFileListView.Selected.SubItems[0]) <> 0 then
      ShowSVNDiffFrm('-r BASE', SVNFileListView.Selected.SubItems[0])
    else
      ShowSVNDiffFrm('-r BASE', AppendPathDelim(RepositoryPath) + SVNFileListView.Selected.SubItems[0]);
  end;
end;

procedure TSVNStatusFrm.OKButtonClick(Sender: TObject);
var
  i: integer;
  CmdLine: string;
  StatusItem : TSVNStatusItem;
  FileName: string;
begin
  UpdateCheckedStatus;
  if SVNCommitMsgMemo.Text = '' then
    if MessageDlg ('No message set.', 'Do you wish to continue?', mtConfirmation,
                  [mbYes, mbNo],0) <> mrYes then
      exit;

  //commit the checked files
  CmdLine := SVNExecutable + ' commit --non-interactive --force-log ';

  for i := 0 to SVNStatus.List.Count - 1 do
  begin
    StatusItem := SVNStatus.List[i];
    if StatusItem.Checked then
      if pos(RepositoryPath,StatusItem.Path) = 0 then
        CmdLine := CmdLine + ' "' + AppendPathDelim(RepositoryPath) + StatusItem.Path + '"'
      else
        CmdLine := CmdLine + ' "' + StatusItem.Path + '"';
  end;

  FileName := GetTempFileNameUTF8('','');
  SVNCommitMsgMemo.Lines.SaveToFile(FileName);
  CmdLine := CmdLine + ' --file ' + FileName;

  ShowSVNCommitFrm(CmdLine);
  DeleteFile(FileName);
  Close;
end;

procedure TSVNStatusFrm.PatchButtonClick(Sender: TObject);
var
  i: Integer;
  StatusItem: TSVNStatusItem;
  FileNames: TStringList;
begin
  UpdateCheckedStatus;
  Filenames := TStringList.Create;
  FileNames.Sorted := True;
  for i := 0 to SVNStatus.List.Count - 1 do
  begin
    StatusItem := SVNStatus.List.Items[i];
    if StatusItem.Checked then
      if pos(RepositoryPath,StatusItem.Path) = 0 then
        FileNames.Append(AppendPathDelim(RepositoryPath) + StatusItem.Path)
      else
        FileNames.Append(StatusItem.Path);
  end;
  ShowSVNDiffFrm('-r BASE', FileNames);
end;

procedure TSVNStatusFrm.PopupMenu1Popup(Sender: TObject);
var
  P: TPoint;
  LI: TListItem;
begin
  // make sure the row under the mouse is selected
  P := SVNFileListView.ScreenToControl(Mouse.CursorPos);
  LI := SVNFileListView.GetItemAt(P.X, P.Y);
  if LI <> nil then begin
    SVNFileListView.Selected := LI;
    {$note: using hardcoded column index!}
    if LI.SubItems[2] = 'unversioned' then
      mnuRevert.Enabled := False
    else
      mnuRevert.Enabled := True;
    if (LI.SubItems[2] = 'unversioned') or (LI.SubItems[2] = 'deleted') then begin
      mnuShowDiff.Enabled := False;
      mnuRemove.Enabled := False;
      mnuAdd.Enabled := True;
    end else begin
      mnuShowDiff.Enabled := True;
      mnuRemove.Enabled := True;
      mnuAdd.Enabled := False;
    end;
  end;
end;

procedure TSVNStatusFrm.SVNCommitMsgHistoryComboBoxChange(Sender: TObject);
begin
  with SVNCommitMsgHistoryComboBox do
    if ItemIndex > -1 then
      SVNCommitMsgMemo.Text := Items[ItemIndex];
end;

procedure TSVNStatusFrm.SVNFileListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  case Column.Index of
    0: SVNStatus.ReverseSort(siChecked);
    1: SVNStatus.ReverseSort(siPath);
    2: SVNStatus.ReverseSort(siExtension);
    3: SVNStatus.ReverseSort(siItemStatus);
    4: SVNStatus.ReverseSort(siPropStatus);
    5: SVNStatus.ReverseSort(siAuthor);
    6: SVNStatus.ReverseSort(siRevision);
    7: SVNStatus.ReverseSort(siCommitRevision);
    8: SVNStatus.ReverseSort(siDate);
  end;

  UpdateFilesListView;
end;

procedure TSVNStatusFrm.UpdateFilesListView;
var
  i: integer;
  StatusItem : TSVNStatusItem;
  Path: string;
begin
  SVNFileListView.BeginUpdate;
  SVNFileListView.Clear;
  for i := 0 to SVNStatus.List.Count - 1 do
  begin
    with SVNFileListView.Items.Add do
    begin
      StatusItem := SVNStatus.List.Items[i];
      //checkboxes
      Caption := '';
      Checked := StatusItem.Checked;
      //path
      Path := StatusItem.Path;
      if pos(RepositoryPath, Path) = 1 then
        path := CreateRelativePath(path, RepositoryPath, false);
      SubItems.Add(Path);
      //extension
      SubItems.Add(StatusItem.Extension);
      //file status
      SubItems.Add(StatusItem.ItemStatus);
      //property status
      SubItems.Add(StatusItem.PropStatus);
      //check if file is versioned
      if (CompareText(StatusItem.ItemStatus, 'unversioned') <> 0) and
         (CompareText(StatusItem.ItemStatus, 'added') <> 0) then
      begin
        //revision
        SubItems.Add(IntToStr(StatusItem.Revision));
        //commit revision
        SubItems.Add(IntToStr(StatusItem.CommitRevision));
        //author
        SubItems.Add(StatusItem.Author);
        //date
        SubItems.Add(DateTimeToStr(StatusItem.Date));
      end;
    end;
  end;
  SVNFileListView.EndUpdate;
end;

procedure TSVNStatusFrm.ChangeCursor(ACursor: TCursor);
begin
  Cursor := ACursor;
  SVNCommitMsgMemo.Cursor := ACursor;
  SVNFileListView.Cursor := ACursor;
  Self.Cursor := ACursor;
  Application.ProcessMessages;
end;

procedure TSVNStatusFrm.UpdateCheckedStatus;
var
  i : Integer;
begin
  for i := 0 to SVNFileListView.Items.Count - 1 do
    with SVNFileListView.Items[i] do
      SVNStatus.List[Index].Checked := Checked;
end;

procedure TSVNStatusFrm.FormCreate(Sender: TObject);
var
  Config: TConfigStorage;
  count: integer;
  i: integer;
  s: string;
begin
  mnuShowDiff.Caption := rsShowDiff;
  mnuOpen.Caption := rsOpenFileInEditor;
  mnuRevert.Caption := rsRevert;
  mnuAdd.Caption := rsAdd;
  mnuRemove.Caption := rsRemove;

  ButtonPanel.HelpButton.Caption:=rsCreatePatchFile;
  ButtonPanel.OKButton.Caption:=rsCommit;

  ButtonPanel.OKButton.OnClick:=@OKButtonClick;

  SetColumn(SVNFileListView, 0, 25, '', False);
  SetColumn(SVNFileListView, 1, 300, rsPath, False);
  SetColumn(SVNFileListView, 2, 75, rsExtension, True);
  SetColumn(SVNFileListView, 3, 100, rsFileStatus, True);
  SetColumn(SVNFileListView, 4, 125, rsPropertyStatus, True);
  SetColumn(SVNFileListView, 5, 75, rsRevision, True);
  SetColumn(SVNFileListView, 6, 75, rsCommitRevision, True);
  SetColumn(SVNFileListView, 7, 75, rsAuthor, True);
  SetColumn(SVNFileListView, 8, 75, rsDate, True);

  ImageList.AddResourceName(HInstance, 'menu_svn_diff');
  ImageList.AddResourceName(HInstance, 'menu_svn_revert');
  try
    Config := GetIDEConfigStorage('lazsvnpkg.xml', true);
    count := Config.GetValue('HistoryCount', 0);
    //limit to 100 entries
    if count > 100 then
      count := 100;
    for i := count downto 0 do
    begin
      s := Config.GetValue('Msg' + IntToStr(i), '');
      if s <> '' then
        SVNCommitMsgHistoryComboBox.Items.Add(s);
    end;
  finally
    Config.Free;
  end;
end;

procedure TSVNStatusFrm.FormDestroy(Sender: TObject);
begin
  SVNStatusFrm := nil;
end;

procedure TSVNStatusFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  Config: TConfigStorage;
  count: integer;
begin
  if SVNCommitMsgMemo.Text <> '' then
  begin
    try
      Config := GetIDEConfigStorage('lazsvnpkg.xml', true);
      count := Config.GetValue('HistoryCount', 0);
      Config.SetValue('HistoryCount', count + 1);
      Config.SetValue('Msg' + IntToStr(count + 1), SVNCommitMsgMemo.Text);
    finally
      Config.Free;
    end;
  end;
  SVNStatus.Free;
  CloseAction := caFree;
end;

procedure TSVNStatusFrm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

end.

