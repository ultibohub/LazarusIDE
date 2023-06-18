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

unit SVNUpdateForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  FileUtil, UTF8Process, LazLoggerBase,
  LResources, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ButtonPanel, Process, Buttons, Menus,
  IDEImagesIntf;

type

  { TSVNUpdateFrm }

  TSVNUpdateFrm = class(TForm)
    mnuShowDiff: TMenuItem;
    UpdatePopupMenu: TPopupMenu;
    ButtonPanel: TButtonPanel;
    SVNUpdateListView: TListView;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuShowDiffClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ShowLogButtonClick(Sender: TObject);
  private
    FRepositoryPath: string;
    { private declarations }
    procedure ProcessSVNUpdateOutput(var MemStream: TMemoryStream; var BytesRead: LongInt);
  public
    { public declarations }
    procedure Execute({%H-}Data: PtrInt);

    property RepositoryPath: string read FRepositoryPath write FrepositoryPath;
  end;

procedure ShowSVNUpdateFrm(ARepoPath: string);

var
  SVNUpdateFrm: TSVNUpdateFrm;

implementation

{$R *.lfm}

uses
  SVNLogForm, SVNDiffForm, SVNClasses;

{ TSVNUpdateFrm }

procedure ShowSVNUpdateFrm(ARepoPath: string);
begin
  if not Assigned(SVNUpdateFrm) then
    SVNUpdateFrm := TSVNUpdateFrm.Create(nil);

  SVNUpdateFrm.RepositoryPath := ARepoPath;
  SVNUpdateFrm.Show;
end;

procedure TSVNUpdateFrm.FormCreate(Sender: TObject);
begin
  SetColumn(SVNUpdateListView, 0, 75, rsAction);
  SetColumn(SVNUpdateListView, 1, 400, rsPath);
  //SetColumn(SVNUpdateListView, 2, 100,'Mime type');

  ButtonPanel.OKButton.OnClick := @OKButtonClick;
  ButtonPanel.HelpButton.Caption := rsShowLog;
  IDEImages.AssignImage(ButtonPanel.HelpButton, 'tsynsyncroedit');
  mnuShowDiff.Caption:=rsShowDiff;
end;

procedure TSVNUpdateFrm.FormDestroy(Sender: TObject);
begin
  SVNUpdateFrm := nil;
end;

procedure TSVNUpdateFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TSVNUpdateFrm.FormShow(Sender: TObject);
begin
  Caption := Format(rsLazarusSVNUpdate, [RepositoryPath]);
  Application.QueueAsyncCall(@Execute, 0);
end;

procedure TSVNUpdateFrm.mnuShowDiffClick(Sender: TObject);
begin
  if Assigned(SVNUpdateListView.Selected) then
  begin
    if (SVNUpdateListView.Selected.Caption = rsAdded) or
       (SVNUpdateListView.Selected.Caption = rsDeleted) or
       (SVNUpdateListView.Selected.Caption = rsUpdated) or
       (SVNUpdateListView.Selected.Caption = rsConflict) or
       (SVNUpdateListView.Selected.Caption = rsMerged) then
    begin
      debugln('TSVNUpdateFrm.mnuShowDiffClick Path=' ,SVNUpdateListView.Selected.SubItems[0]);
      ShowSVNDiffFrm('-r PREV', SVNUpdateListView.Selected.SubItems[0]);
    end;
  end;
end;

procedure TSVNUpdateFrm.OKButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSVNUpdateFrm.ShowLogButtonClick(Sender: TObject);
begin
  ShowSVNLogFrm(RepositoryPath);
end;

procedure TSVNUpdateFrm.ProcessSVNUpdateOutput(var MemStream: TMemoryStream; var BytesRead: LongInt);
var
  S: TStringList;
  n: LongInt;
  i: integer;
  str: string;
begin
  Memstream.SetSize(BytesRead);
  S := TStringList.Create;
  S.LoadFromStream(MemStream);

  for n := 0 to S.Count - 1 do
    with SVNUpdateListView.Items.Add do
    begin
      //find position of first space character
      i := pos(' ', S[n]);
      str := Copy(S[n],1, i - 1);

      if str = 'A'then str := rsAdded;
      if str = 'D'then str := rsDeleted;
      if str = 'U'then str := rsUpdated;
      if str = 'C'then str := rsConflict;
      if str = 'G'then str := rsMerged;
      Caption := str;

      Subitems.Add(Trim(Copy(S[n],i, Length(S[n])-i+1)));
    end;

  S.Free;
  BytesRead := 0;
  MemStream.Clear;

  SVNUpdateListView.Items[SVNUpdateListView.Items.Count - 1].MakeVisible(True);

  //repaint the listview
  Application.ProcessMessages;
end;

procedure TSVNUpdateFrm.Execute(Data: PtrInt);
var
  AProcess: TProcessUTF8;
  n: LongInt;
  MemStream: TMemoryStream;
  BytesRead: LongInt;
begin
  SVNUpdateListView.Clear;

  MemStream := TMemoryStream.Create;
  BytesRead := 0;

  AProcess := TProcessUTF8.Create(nil);
  AProcess.CommandLine := SVNExecutable + ' update "' + RepositoryPath + '" --non-interactive';
  debugln('TSVNUpdateFrm.Execute CommandLine ' + AProcess.CommandLine);
  AProcess.Options := [poUsePipes, poStdErrToOutput];
  AProcess.ShowWindow := swoHIDE;
  AProcess.Execute;

  while AProcess.Running do
  begin
    // make sure we have room
    MemStream.SetSize(BytesRead + READ_BYTES);

    // try reading it
    n := AProcess.Output.Read((MemStream.Memory + BytesRead)^, READ_BYTES);
    if n > 0
    then begin
      Inc(BytesRead, n);
      ProcessSVNUpdateOutput(MemStream, BytesRead);
    end
    else
      // no data, wait 100 ms
      Sleep(100);
  end;
  // read last part
  repeat
    // make sure we have room
    MemStream.SetSize(BytesRead + READ_BYTES);
    // try reading it
    n := AProcess.Output.Read((MemStream.Memory + BytesRead)^, READ_BYTES);
    if n > 0
    then begin
      Inc(BytesRead, n);
      ProcessSVNUpdateOutput(MemStream, BytesRead);
    end;
  until n <= 0;

  AProcess.Free;
  MemStream.Free;
end;

end.

