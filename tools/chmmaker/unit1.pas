unit unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, types, chmsitemap, chmfilewriter,
  Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls, EditBtn,
  LazFileUtils, UTF8Process;

type

  { TCHMForm }

  TCHMForm = class(TForm)
    AddFilesBtn: TButton;
    AutoAddLinksBtn: TButton;
    AddAllBtn: TButton;
    CompileViewBtn: TButton;
    CompileBtn: TButton;
    DefaultPageCombo: TComboBox;
    ChmFileNameEdit: TFileNameEdit;
    FollowLinksCheck: TCheckBox;
    CreateSearchableCHMCheck: TCheckBox;
    CompileTimeOptionsLabel: TLabel;
    FilesNoteLabel: TLabel;
    DefaultPageLabel: TLabel;
    CHMFilenameLabel: TLabel;
    OpenDialog2: TOpenDialog;
    RemoveFilesBtn: TButton;
    TOCEditBtn: TButton;
    IndexEditBtn: TButton;
    IndexEdit: TFileNameEdit;
    GroupBox1: TGroupBox;
    FileListBox: TListBox;
    TableOfContentsLabel: TLabel;
    IndexLabel: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    ProjSaveItem: TMenuItem;
    ProjSaveAsItem: TMenuItem;
    MenuItem12: TMenuItem;
    ProjQuitItem: TMenuItem;
    CompileItem: TMenuItem;
    CompileProjItem: TMenuItem;
    CompileOpenBttn: TMenuItem;
    ProjCloseItem: TMenuItem;
    MenuItem3: TMenuItem;
    HelpHelpItem: TMenuItem;
    MenuItem5: TMenuItem;
    HelpAboutItem: TMenuItem;
    ProjNewItem: TMenuItem;
    ProjOpenItem: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    MainPanel: TPanel;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    TOCEdit: TFileNameEdit;
    procedure AddAllBtnClick(Sender: TObject);
    procedure AddFilesBtnClick(Sender: TObject);
    procedure AutoAddLinksBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ChmFileNameEditAcceptFileName(Sender: TObject; var Value: String);
    procedure CompileBtnClick(Sender: TObject);
    procedure CompileViewBtnClick(Sender: TObject);
    procedure FileListBoxDrawItem({%H-}Control: TWinControl; Index: Integer;
      ARect: TRect; {%H-}State: TOwnerDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IndexEditAcceptFileName(Sender: TObject; var Value: String);
    procedure IndexEditBtnClick(Sender: TObject);
    procedure ProjCloseItemClick(Sender: TObject);
    procedure ProjNewItemClick(Sender: TObject);
    procedure ProjOpenItemClick(Sender: TObject);
    procedure ProjQuitItemClick(Sender: TObject);
    procedure ProjSaveAsItemClick(Sender: TObject);
    procedure ProjSaveItemClick(Sender: TObject);
    procedure RemoveFilesBtnClick(Sender: TObject);
    procedure TOCEditAcceptFileName(Sender: TObject; var Value: String);
    procedure TOCEditBtnClick(Sender: TObject);
  private
    FModified: Boolean;
    procedure AddItems({%H-}AParentItem: TTreeNode; {%H-}ChmItems: TChmSiteMapItems);

    function GetModified: Boolean;
    procedure Save(aAs: Boolean);
    procedure CloseProject;

    procedure AddFilesToProject(Strings: TStrings);
    procedure InitFileDialog(Dlg: TFileDialog);
    procedure ProjectDirChanged;
    function CreateRelativeProjectFile(Filename: string): string;
    function CreateAbsoluteProjectFile(Filename: string): string;
  public
    Project: TChmProject;
    procedure OpenProject(AFileName: String);
    // Dirty flag: has project been modified since opening?
    property Modified: Boolean read GetModified write FModified;
  end; 

var
  CHMForm: TCHMForm;

implementation

{$R *.lfm}

uses CHMSiteMapEditor, LHelpControl, Process;

{ TCHMForm }

procedure TCHMForm.AddItems(AParentItem: TTreeNode; ChmItems: TChmSiteMapItems);
  begin
{    for I := 0 to ChmItems.Count-1 do begin
      Item := TreeView1.Items.AddChild(AParentItem, ChmItems.Item[I].Text);
      AddItems(Item, ChmItems.Item[I].Children);
    end;
 } end;

procedure TCHMForm.Button1Click(Sender: TObject);
begin
  {SiteMap := TChmSiteMap.Create(stTOC);
  OpenDialog1.InitialDir := GetCurrentDir;
  if OpenDialog1.Execute = False then Exit;
  SiteMap.LoadFromFile(OpenDialog1.FileName);
  AddItems(nil, sitemap.Items);
  
  Stream := TMemoryStream.Create;
  
  Sitemap.SaveToStream(Stream);
  Stream.Position := 0;
  
  SynEdit1.Lines.LoadFromStream(Stream);
  Stream.Free;
   }
end;

procedure TCHMForm.AddFilesBtnClick(Sender: TObject);
begin
  InitFileDialog(OpenDialog2);
  if OpenDialog2.Execute = False then exit;
  Modified := True;
  AddFilesToProject(OpenDialog2.Files);
end;

procedure TCHMForm.AddAllBtnClick(Sender: TObject);
var
  Files: TStrings;
  procedure AddDir(ADir: String);
  var
    SearchRec: TSearchRec;
    FileName: String;
  begin
    // WriteLn('Adding Dir: ', ADir);
    if FindFirst(ADir+'*', faAnyFile or faDirectory, SearchRec) = 0 then
    begin
      repeat
        if (SearchRec.Attr and faDirectory) <> 0 then
        begin
          if Pos('.', SearchRec.Name) = 0 then
          begin
            AddDir(IncludeTrailingPathDelimiter(ADir+SearchRec.Name));
          end;
        end
        else
        begin
          FileName := ADir+SearchRec.Name;
          FileName := ExtractRelativepath(Project.ProjectDir, FileName);
          if Files.IndexOf(FileName) = -1 then
            Files.Add(FileName);
        end;
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;
  end;
begin
  if MessageDlg('This will add all files in the project directory ' + LineEnding +
                'recursively. Do you want to continue?',
                mtConfirmation, [mbYes, mbNo],0) <> mrYes then exit;
  Modified := True;
  Files := TStringList.Create;
  try
    Files.AddStrings(FileListBox.Items);
    AddDir(Project.ProjectDir);
    FileListBox.Items.Assign(Files);
  finally
    Files.Free;
  end;
end;

procedure TCHMForm.AutoAddLinksBtnClick(Sender: TObject);
begin
  Modified := True;
end;

procedure TCHMForm.Button2Click(Sender: TObject);
begin
    {
  if OpenDialog1.Execute = False then Exit;
  OutStream := TFileStream.Create('/home/andrew/test.chm', fmCreate or fmOpenWrite);
  Chm := TChmWriter.Create(OutStream, False);
  Chm.FilesToCompress.AddStrings(OpenDialog1.Files);
  Chm.GetFileData := @GetData;
  Chm.Title := 'test';
  Chm.DefaultPage := 'index.html';
  Chm.Execute;
  OutStream.Free;
  Chm.Free;
     }
  
  
end;

procedure TCHMForm.ChmFileNameEditAcceptFileName(Sender: TObject; var Value: String);
begin
  if ExtractFileExt(Value) = '' then Value := Value+'.chm';
end;

procedure TCHMForm.CompileBtnClick(Sender: TObject);
var
  OutFile: TFileStream;
begin
  if ChmFileNameEdit.FileName = '' then
  begin
    MessageDlg('You must set a filename for the output CHM file!', mtError, [mbCancel], 0);
    Exit;
  end;
  Save(False);
  OutFile := TFileStream.Create(Project.OutputFileName, fmCreate or fmOpenWrite);
  try
    Project.WriteChm(OutFile);
    ShowMessage('CHM file '+ChmFileNameEdit.FileName+' was created.');
  finally
    OutFile.Free;
  end;
end;


procedure TCHMForm.CompileViewBtnClick(Sender: TObject);
var
  LHelpName: String;
  LHelpConn: TLHelpConnection;
  Proc: TProcessUTF8;
  ext: String;
begin
  if ChmFileNameEdit.FileName = '' then
  begin
    MessageDlg('You must set a filename for the output CHM file!', mtError, [mbCancel], 0);
    Exit;
  end;
  CompileBtnClick(Sender);
  // open
  // ...
  ext := ExtractFileExt(Application.ExeName);
  LHelpName := '../../components/chmhelp/lhelp/lhelp' + ext;
  if not FileExists(LHelpName) then
  begin
    if MessageDlg('LHelp could not be located at '+ LHelpName +' Try to build using lazbuild?', mtError, [mbCancel, mbYes], 0) = mrYes then
    begin
      if not FileExists('../../lazbuild' + ext) then
      begin
        MessageDlg('lazbuild coul not be found.', mtError, [mbCancel], 0);
        Exit;
      end;
      Proc := TProcessUTF8.Create(Self);
      Proc.CommandLine := '../../../lazbuild ./lhelp.lpi';
      SetCurrentDir('../../components/chmhelp/lhelp/');
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
      SetCurrentDir('../../../tools/chmmaker/');
      if Proc.ExitStatus <> 0 then
      begin
        MessageDlg('lhelp failed to build', mtError, [mbCancel], 0);
        Exit;
      end;
      Proc.Free;
    end
    else
      Exit;
  end;
  LHelpConn := TLHelpConnection.Create;
  try
    LHelpConn.StartHelpServer('chmmaker', LHelpName);
    LHelpConn.OpenFile(ChmFileNameEdit.FileName);
  finally
    LHelpConn.Free;
  end;
end;

procedure TCHMForm.FileListBoxDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  FileListbox.Canvas.FillRect(ARect);
  if Pos('..', FileListBox.Items.Strings[Index]) > 0 then
  begin
    // These items won't be added to the chm because they are not within the project dir
    // so mark them with a red rectangle
    Dec(ARect.Right);
    Dec(ARect.Bottom);
    FileListBox.Canvas.Pen.Color := clRed;
    FileListBox.Canvas.Frame(ARect);
  end;
  // Draw item text
  FileListBox.Canvas.TextRect(ARect,
    2, (ARect.Top + ARect.Bottom - FileListbox.Canvas.TextHeight('Tg')) div 2,
    FileListBox.Items[Index]
  );
end;

procedure TCHMForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  MResult: Integer;
begin
  if Modified then
  begin
    MResult := MessageDlg('Project is modified would you like to save the changes?', mtConfirmation,
                                      [mbYes, mbNo, mbCancel], 0);
    case MResult of
      mrYes: Save(False);
      mrNo: CloseAction := caFree;
      mrCancel: CloseAction := caNone;
    end;
   end;
end;

procedure TCHMForm.FormCreate(Sender: TObject);
begin
  CloseProject;
end;

procedure TCHMForm.FormDestroy(Sender: TObject);
begin
  CloseProject;
end;

procedure TCHMForm.IndexEditAcceptFileName(Sender: TObject; var Value: String);
begin
  Modified := True;
  //Value := ExtractRelativepath(Project.ProjectDir, Value);
  //WriteLn(Value);
  Project.IndexFileName := Value;
end;

procedure TCHMForm.IndexEditBtnClick(Sender: TObject);
var
  Stream: TStream;
  FileName: String;
begin
  FileName := IndexEdit.FileName;
  if FileName = '' then
  begin
    FileName := Project.ProjectDir+'_index.hhk'
  end;

  if FileExists(FileName) then
  begin
    Stream := TFileStream.Create(FileName, fmOpenReadWrite);
  end
  else
  begin
    Stream := TFileStream.Create(FileName, fmCreate or fmOpenReadWrite);
  end;

  try
    if SitemapEditForm.Execute(Stream, stIndex, FileListBox.Items) then IndexEdit.FileName := FileName;
  finally
    Stream.Free;
  end;
end;

procedure TCHMForm.ProjCloseItemClick(Sender: TObject);
begin
  CloseProject;
end;

procedure TCHMForm.ProjNewItemClick(Sender: TObject);
begin
  InitFileDialog(SaveDialog1);
  If SaveDialog1.Execute then
  begin
    if FileExists(SaveDialog1.FileName)
    and (MessageDlg('File Already Exists! Ovewrite?', mtWarning, [mbYes, mbNo],0) <> mrYes) then Exit;
    OpenProject(SaveDialog1.FileName);
    Project.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TCHMForm.ProjOpenItemClick(Sender: TObject);
begin
  InitFileDialog(OpenDialog1);
  if OpenDialog1.Execute then
  begin
    CloseProject;
    OpenProject(OpenDialog1.FileName);
  end;
end;

procedure TCHMForm.ProjQuitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TCHMForm.ProjSaveAsItemClick(Sender: TObject);
begin
  Save(True);
end;

procedure TCHMForm.ProjSaveItemClick(Sender: TObject);
begin
  Save(False);
end;

procedure TCHMForm.RemoveFilesBtnClick(Sender: TObject);
var
  I: Integer;
begin
  Modified := True;
  for I := FileListBox.Items.Count-1 downto 0 do
    if FileListBox.Selected[I] then FileListBox.Items.Delete(I);
  DefaultPageCombo.Items.Assign(FileListBox.Items);
end;

procedure TCHMForm.TOCEditAcceptFileName(Sender: TObject; var Value: String);
begin
  Modified := True;
  Project.TableOfContentsFileName := Value;
end;

procedure TCHMForm.TOCEditBtnClick(Sender: TObject);
var
  Stream: TStream;
  FileName: String;
  BDir: String;
begin
  FileName := TOCEdit.FileName;
  if FileName = '' then
  begin
    FileName := Project.ProjectDir+'_table_of_contents.hhc'
  end;
  
  if FileExists(FileName) then
  begin
    Stream := TFileStream.Create(FileName, fmOpenReadWrite);
  end
  else
  begin
    Stream := TFileStream.Create(FileName, fmCreate or fmOpenReadWrite);
  end;

  try
    BDir := ExtractFilePath(Project.FileName);
    FileName := ExtractRelativepath(BDir, FileName);
    if SitemapEditForm.Execute(Stream, stTOC, FileListBox.Items) then TOCEdit.FileName := FileName;
  finally
    Stream.Free;
  end;
end;

function TCHMForm.GetModified: Boolean;
begin
  Result := (Project <> nil) and FModified;
end;

procedure TCHMForm.Save(aAs: Boolean);
begin
  if aAs or (Project.FileName = '') then
  begin
    InitFileDialog(SaveDialog1);
    if SaveDialog1.Execute then
    begin
      Project.FileName := ChangeFileExt(SaveDialog1.FileName,'.hfp');
      ProjectDirChanged;
    end;
  end;
  Project.Files.Assign(FileListBox.Items);
  Project.TableOfContentsFileName := CreateRelativeProjectFile(TOCEdit.FileName);
  Project.IndexFileName           := CreateRelativeProjectFile(IndexEdit.FileName);
  Project.DefaultPage             := DefaultPageCombo.Text;
  Project.AutoFollowLinks         := FollowLinksCheck.Checked;
  Project.MakeSearchable          := CreateSearchableCHMCheck.Checked;
  Project.OutputFileName          := CreateRelativeProjectFile(ChmFileNameEdit.FileName);

  Project.SaveToFile(Project.FileName);
  Modified := False;
end;

procedure TCHMForm.CloseProject;
begin
  FileListBox.Clear;
  DefaultPageCombo.Clear;
  TOCEdit.Clear;
  IndexEdit.Clear;
  GroupBox1.Enabled      := False;
  MainPanel.Enabled         := False;
  CompileItem.Enabled    := False;
  ProjSaveAsItem.Enabled := False;
  ProjSaveItem.Enabled   := False;
  ProjCloseItem.Enabled  := False;

  FollowLinksCheck.Checked := False;
  CreateSearchableCHMCheck.Checked := False;
  FreeAndNil(Project);
end;

procedure TCHMForm.OpenProject(AFileName: String);
begin
  if not Assigned(Project) then Project := TChmProject.Create;
  Project.LoadFromFile(AFileName);
  GroupBox1.Enabled      := True;
  MainPanel.Enabled      := True;
  CompileItem.Enabled    := True;
  ProjSaveAsItem.Enabled := True;
  ProjSaveItem.Enabled   := True;
  ProjCloseItem.Enabled  := True;

  FileListBox.Items.AddStrings(Project.Files);
  TOCEdit.FileName := Project.TableOfContentsFileName;
  IndexEdit.FileName := Project.IndexFileName;
  DefaultPageCombo.Items.Assign(FileListBox.Items);
  DefaultPageCombo.Text := Project.DefaultPage;
  FollowLinksCheck.Checked := Project.AutoFollowLinks;
  CreateSearchableCHMCheck.Checked := Project.MakeSearchable;
  ChmFileNameEdit.FileName := Project.OutputFileName;

  ProjectDirChanged;
end;

procedure TCHMForm.AddFilesToProject(Strings: TStrings);
var
  BDir: String;
  I: Integer;
  RelativePath: String;
  FileName: String;
begin
  Modified := True;
  BDir := ExtractFilePath(Project.FileName);

  for I := 0 to Strings.Count-1 do begin
    FileName := Strings.Strings[I];

    RelativePath := ExtractRelativepath(BDir, FileName);
    if Pos('..', RelativePath) > 0 then
      FileListBox.Items.AddObject(RelativePath, TObject(1))
    else
      FileListBox.Items.AddObject(RelativePath, TObject(0));
  end;
  DefaultPageCombo.Items.Assign(FileListBox.Items);
end;

procedure TCHMForm.InitFileDialog(Dlg: TFileDialog);
var
  Dir: String;
begin
  Dir:='';
  if (Project<>nil) then
    Dir:=ExtractFilePath(Project.FileName);
  if not DirPathExists(Dir) then
    Dir:=GetCurrentDirUTF8;
  Dlg.InitialDir:=Dir;
end;

procedure TCHMForm.ProjectDirChanged;
var
  Dir: String;
begin
  if Project=nil then exit;
  Dir:=ExtractFilePath(Project.FileName);

  TOCEdit.InitialDir:=Dir;
  IndexEdit.InitialDir:=Dir;
  ChmFileNameEdit.InitialDir:=Dir;
end;

function TCHMForm.CreateRelativeProjectFile(Filename: string): string;
begin
  Result:=Filename;
  if (Project=nil) or (not FilenameIsAbsolute(Project.FileName)) then exit;
  Result:=CreateRelativePath(Filename,ExtractFilePath(Project.FileName));
end;

function TCHMForm.CreateAbsoluteProjectFile(Filename: string): string;
begin
  Result:=Filename;
  if FilenameIsAbsolute(Result) then exit;
  if (Project=nil) or (not FilenameIsAbsolute(Project.FileName)) then exit;
  Result:=ExtractFilePath(Project.FileName)+Filename;
end;

end.

