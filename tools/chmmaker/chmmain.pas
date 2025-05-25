unit CHMMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Math,
  Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls, EditBtn,
  ActnList, LazFileUtils, UTF8Process, LCLTranslator,
  chmsitemap, chmfilewriter;

type

  { TCHMForm }

  TCHMForm = class(TForm)
    AcNew: TAction;
    AcOpen: TAction;
    AcSave: TAction;
    AcSaveAs: TAction;
    AcClose: TAction;
    AcQuit: TAction;
    AcCompile: TAction;
    AcCompileAndView: TAction;
    AcAbout: TAction;
    ActionList: TActionList;
    AddFilesBtn: TButton;
    AutoAddLinksBtn: TButton;
    AddAllBtn: TButton;
    Bevel1: TBevel;
    CompileViewBtn: TButton;
    CompileBtn: TButton;
    DefaultPageCombo: TComboBox;
    ChmFileNameEdit: TFileNameEdit;
    ChmTitleEdit: TEdit;
    CompileTimeOptionsGroupbox: TGroupBox;
    ScanHtmlCheck: TCheckBox;
    CreateSearchableCHMCheck: TCheckBox;
    FilesNoteLabel: TLabel;
    DefaultPageLabel: TLabel;
    CHMFilenameLabel: TLabel;
    OpenDialog2: TOpenDialog;
    RemoveFilesBtn: TButton;
    ChmTitleLabel: TLabel;
    Splitter: TSplitter;
    TOCEditBtn: TButton;
    IndexEditBtn: TButton;
    IndexEdit: TFileNameEdit;
    FilesGroupBox: TGroupBox;
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
    HelpAboutItem: TMenuItem;
    ProjNewItem: TMenuItem;
    ProjOpenItem: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    MainPanel: TPanel;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    StatusBar: TStatusBar;
    TOCEdit: TFileNameEdit;
    procedure AcAboutExecute(Sender: TObject);
    procedure AcCloseExecute(Sender: TObject);
    procedure AcCompileAndViewExecute(Sender: TObject);
    procedure AcCompileExecute(Sender: TObject);
    procedure AcNewExecute(Sender: TObject);
    procedure AcOpenExecute(Sender: TObject);
    procedure AcQuitExecute(Sender: TObject);
    procedure AcSaveAsExecute(Sender: TObject);
    procedure AcSaveExecute(Sender: TObject);
    procedure AddAllBtnClick(Sender: TObject);
    procedure AddFilesBtnClick(Sender: TObject);
    procedure AutoAddLinksBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ChmFileNameEditAcceptFileName(Sender: TObject; var Value: String);
    procedure ChmFileNameEditEditingDone(Sender: TObject);
    procedure ChmTitleEditChange(Sender: TObject);
    procedure DefaultPageComboEditingDone(Sender: TObject);
    procedure FileListBoxDrawItem({%H-}Control: TWinControl; Index: Integer;
      ARect: TRect; {%H-}State: TOwnerDrawState);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IndexEditAcceptFileName(Sender: TObject; var Value: String);
    procedure IndexEditBtnClick(Sender: TObject);
    procedure IndexEditEditingDone(Sender: TObject);
    procedure RemoveFilesBtnClick(Sender: TObject);
    procedure ScanHtmlCheckClick(Sender: TObject);
    procedure TOCEditAcceptFileName(Sender: TObject; var Value: String);
    procedure TOCEditBtnClick(Sender: TObject);
    procedure TOCEditEditingDone(Sender: TObject);
  private
    FActivated: Boolean;
    FModified: Boolean;
    procedure AddItems({%H-}AParentItem: TTreeNode; {%H-}ChmItems: TChmSiteMapItems);

    function Compile(ShowSuccessMsg: Boolean): Boolean;
    function GetModified: Boolean;
    function Save(aAs: Boolean): Boolean;
    function StrictModified: Boolean;
    function CloseProject: Boolean;

    procedure AddFilesToProject(Strings: TStrings);
    procedure InitFileDialog(Dlg: TFileDialog);
    procedure ProjectDirChanged;
    function CreateRelativeProjectFile(Filename: string): string;
    procedure SetLanguage(ALang: string);
    procedure UpdateCaption;
  public
    Project: TChmProject;
    procedure OpenProject(AFileName: String);
    // Dirty flag: has project been modified since opening?
    property Modified: Boolean read GetModified write FModified;
    function CreateAbsoluteProjectFile(Filename: string): string;
  end;

var
  CHMForm: TCHMForm;

implementation

{$R *.lfm}

uses
  CHMStrConsts, CHMSiteMapEditor, CHMAbout, LHelpControl, Process;

{ TCHMForm }

procedure TCHMForm.AcAboutExecute(Sender: TObject);
begin
  with TAboutForm.Create(nil) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TCHMForm.AcNewExecute(Sender: TObject);
begin
  // The new file will be saved first. (wp: Is this really needed?)
  InitFileDialog(SaveDialog1);
  SaveDialog1.Title := 'Save new project as';
  if SaveDialog1.Execute then
  begin
    if (not CloseProject) then Exit;
    // Note: The OverwritePrompt must be active in SaveDialog1.Options so that
    // the user can be notified that an existing file will be deleted.
    if FileExists(SaveDialog1.FileName) then
      DeleteFile(SaveDialog1.FileName);
    OpenProject(SaveDialog1.FileName);
    case Lowercase(ExtractFileExt(SaveDialog1.FileName)) of
      '.hfp': Project.SaveToFile(SaveDialog1.FileName);
      '.hhp': Project.SaveToHHP(SaveDialog1.FileName);
    end;
    UpdateCaption;
  end;
end;

procedure TCHMForm.AcCloseExecute(Sender: TObject);
begin
  CloseProject;
end;

procedure TCHMForm.AcCompileAndViewExecute(Sender: TObject);
var
  LHelpName: String;
  LHelpConn: TLHelpConnection;
  Proc: TProcessUTF8;
  ext: String;
begin
  // Compile
  if not Compile(false) then
    exit;

  // Open CHM in LHelp
  ext := ExtractFileExt(Application.ExeName);
  LHelpName := '../../components/chmhelp/lhelp/lhelp' + ext;
  if not FileExists(LHelpName) then
  begin
    if MessageDlg(
         Format(rsLHelpCouldNotBeLocatedAt, [LHelpName]) +
         LineEnding + LineEnding +
         rsTryToBuildUsingLazBuild,
         mtError, [mbCancel, mbYes], 0
      ) = mrYes then
    begin
      if not FileExists('../../lazbuild' + ext) then
      begin
        MessageDlg(rsLazBuildCouldNotBeFound, mtError, [mbCancel], 0);
        Exit;
      end;
      Proc := TProcessUTF8.Create(Self);
      try
        Statusbar.SimpleText := rsBuildingLHelp;
        Application.ProcessMessages;
        Proc.Executable := '../../../lazbuild';
        Proc.Parameters.Add('./lhelp.lpi');
        SetCurrentDir('../../components/chmhelp/lhelp/');
        Proc.Options := [poWaitOnExit];
        Proc.Execute;
        SetCurrentDir('../../../tools/chmmaker/');
        Statusbar.SimpleText := '';
        if Proc.ExitStatus <> 0 then
        begin
          MessageDlg(rsLHelpFailedtoBuild, mtError, [mbCancel], 0);
          Exit;
        end;
      finally
        Proc.Free;
        Statusbar.SimpleText := '';
      end;
    end
    else
      Exit;
  end;
  LHelpConn := TLHelpConnection.Create;
  try
    LHelpConn.StartHelpServer('chmmaker', LHelpName);
    LHelpConn.OpenFile(CreateAbsoluteProjectFile(Project.OutputFileName));
  finally
    LHelpConn.Free;
  end;
end;

procedure TCHMForm.AcCompileExecute(Sender: TObject);
begin
  Compile(true);
end;

procedure TCHMForm.AcOpenExecute(Sender: TObject);
begin
  InitFileDialog(OpenDialog1);
  if OpenDialog1.Execute then
  begin
    if CloseProject() then
      OpenProject(OpenDialog1.FileName);
  end;
end;

procedure TCHMForm.AcQuitExecute(Sender: TObject);
begin
  Close;
end;

procedure TCHMForm.AcSaveAsExecute(Sender: TObject);
begin
  Save(True);
end;

procedure TCHMForm.AcSaveExecute(Sender: TObject);
begin
  Save(False);
end;

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
  if OpenDialog2.Execute then
  begin
    Modified := True;
    AddFilesToProject(OpenDialog2.Files);
  end;
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
  if MessageDlg(
       rsThisWillAddAllFiles + LineEnding + rsDoYouWantToContinue,
       mtConfirmation, [mbYes, mbNo],0) <> mrYes
  then
    exit;

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
  Modified := True;
  Value := CreateRelativeProjectFile(Value);
  if ExtractFileExt(Value) = '' then Value := Value+'.chm';
  Project.OutputFileName := Value;
end;

procedure TCHMForm.ChmFileNameEditEditingDone(Sender: TObject);
begin
  // Normalize filename and store in Project
  if (ChmFileNameEdit.FileName = '') then Exit;
  if (ExtractFileExt(ChmFileNameEdit.FileName)) = '' then ChmFileNameEdit.FileName := ChmFileNameEdit.FileName + '.chm';
  ChmFileNameEdit.FileName := CreateRelativeProjectFile(ChmFileNameEdit.FileName);
  Project.OutputFileName := ChmFileNameEdit.FileName;
  Modified := True;
end;

procedure TCHMForm.ChmTitleEditChange(Sender: TObject);
begin
  Modified := True;
end;

procedure TCHMForm.DefaultPageComboEditingDone(Sender: TObject);
begin
//
end;

function TCHMForm.Compile(ShowSuccessMsg: Boolean): Boolean;
var
  OutFile: TFileStream;
begin
  Result := false;
  if (Project.OutputFileName = '') then
  begin
    MessageDlg(rsFileNameNeeded, mtError, [mbCancel], 0);
    ChmFileNameEdit.SetFocus;
    Exit;
  end;
  if (Project.TableOfContentsFileName = '') then
  begin
    MessageDlg(rsTableOfContentsFileNameNeeded, mtError, [mbCancel], 0);
    TOCEdit.SetFocus;
    exit;
  end;

  if not Save(False) then
    exit;

  OutFile := TFileStream.Create(CreateAbsoluteProjectFile(Project.OutputFileName), fmCreate or fmOpenWrite);
  try
    Project.WriteChm(OutFile);
    if ShowSuccessMsg then
      MessageDlg(Format(rsFileCreated, [Project.OutputFileName]), mtInformation, [mbOk], 0);
    Result := true;
  finally
    OutFile.Free;
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

procedure TCHMForm.FormActivate(Sender: TObject);
begin
  if not FActivated then
  begin
    FActivated := true;
    AddFilesBtn.Anchors := AddFilesBtn.Anchors - [akRight];
    RemoveFilesBtn.Anchors := RemoveFilesBtn.Anchors - [akLeft];
    AddAllBtn.Anchors := AddAllBtn.Anchors - [akRight];
    AutoAddLinksBtn.Anchors := AutoAddLinksBtn.Anchors - [akRight];
    FilesGroupbox.Constraints.MinWidth :=
      Max(AddAllBtn.Width, Max(AutoAddLinksBtn.Width, AddFilesBtn.Width + RemoveFilesBtn.Width + Bevel1.Width)) +
      AutoAddLinksBtn.BorderSpacing.Around * 2;
    if FilesGroupbox.Width < FilesGroupbox.Constraints.MinWidth then
      FilesGroupbox.Width := FilesGroupbox.Constraints.MinWidth;
    Bevel1.Left := AddFilesBtn.Left + AddFilesBtn.Width;
    Constraints.MinWidth := FilesGroupBox.Width + FilesGroupBox.BorderSpacing.Left + FilesGroupBox.BorderSpacing.Right +
      Splitter.Width + CompileTimeOptionsGroupbox.Width +
      Mainpanel.BorderSpacing.Left + MainPanel.BorderSpacing.Right;
    if Width < Constraints.MinWidth then
      Width := Constraints.MinWidth;
    AddFilesBtn.Anchors := AddFilesBtn.Anchors + [akRight];
    RemoveFilesBtn.Anchors := RemoveFilesBtn.Anchors + [akLeft];
    AddAllBtn.Anchors := AddAllBtn.Anchors + [akRight];
    AutoAddLinksBtn.Anchors := AutoAddLinksBtn.Anchors + [akRight];
    Constraints.MinHeight :=  CHMFileNameEdit.Top + CHMFileNameEdit.Height +
      CompileBtn.Height + CompileBtn.BorderSpacing.Top +
      MainPanel.BorderSpacing.Top + MainPanel.BorderSpacing.Bottom +
      StatusBar.Height;
    if Height < Constraints.MinHeight then
      Height := Constraints.MinHeight;
  end;
end;

procedure TCHMForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  MResult: Integer;
begin
  if StrictModified then
  begin
    MResult := MessageDlg(
      rsProjectHasBeenModified + LineEnding + rsSaveChanges,
      mtConfirmation, [mbYes, mbNo, mbCancel], 0
    );
    case MResult of
      mrYes: Save(False);
      mrNo: Modified := false;   // Avoid "can close" prompt when project is closed.
      mrCancel: CanClose := false;
    end;
  end;
end;

procedure TCHMForm.FormCreate(Sender: TObject);
var
  i: Integer;
  s: String;
  sa: TStringArray;
  filename: String;
begin
  filename := '';
  Lang := '';
  for i := 1 to ParamCount do
  begin
    s := ParamStr(i);
    if s[1] <> '-' then
      filename := s
    else
    begin
      sa := s.Split('=');
      if Lowercase(sa[0]) = '-lang' then
        Lang := sa[1];
    end;
  end;
  SetLanguage(Lang);
  CloseProject;
  if (filename <> '') then
  begin
    filename := CleanAndExpandFilename(filename);
    if FileExists(filename) then
      OpenProject(filename)
    else
      MessageDlg(Format(rsFileNotFound, [fileName]), mtError, [mbOK], 0);
  end;
end;

procedure TCHMForm.FormDestroy(Sender: TObject);
begin
  CloseProject;
end;

procedure TCHMForm.IndexEditAcceptFileName(Sender: TObject; var Value: String);
begin
  Modified := True;
  Value := CreateRelativeProjectFile(Value);
  if ExtractFileExt(Value) = '' then Value := Value + '.hhk';
  Project.IndexFileName := Value;
end;

procedure TCHMForm.IndexEditBtnClick(Sender: TObject);
var
  Stream: TStream;
  FileName: String;
begin
  if (Project.IndexFileName = '') then
  begin
    Project.IndexFileName := '_index.hhk';
    IndexEdit.FileName := Project.IndexFileName;
    Modified := True;
  end;

  FileName := CreateAbsoluteProjectFile(Project.IndexFileName);

  if FileExists(FileName) then
  begin
    Stream := TFileStream.Create(FileName, fmOpenReadWrite);
  end
  else
  begin
    Stream := TFileStream.Create(FileName, fmCreate or fmOpenReadWrite);
  end;

  try
    SitemapEditForm.Execute(Stream, stIndex, FileListBox.Items);
  finally
    Stream.Free;
  end;
end;

procedure TCHMForm.IndexEditEditingDone(Sender: TObject);
begin
  // Normalize filename and store in Project
  if (IndexEdit.FileName = '') then Exit;
  if (ExtractFileExt(IndexEdit.FileName)) = '' then IndexEdit.FileName := IndexEdit.FileName + '.hhk';
  IndexEdit.FileName := CreateRelativeProjectFile(IndexEdit.FileName);
  Project.IndexFileName := IndexEdit.FileName;
  Modified := True;
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

procedure TCHMForm.ScanHtmlCheckClick(Sender: TObject);
begin
  Modified := True;
end;

procedure TCHMForm.TOCEditAcceptFileName(Sender: TObject; var Value: String);
begin
  Modified := True;
  Value := CreateRelativeProjectFile(Value);
  if ExtractFileExt(Value) = '' then Value := Value + '.hhc';
  Project.TableOfContentsFileName := Value;
end;

procedure TCHMForm.TOCEditBtnClick(Sender: TObject);
var
  Stream: TStream;
  FileName: String;
begin
  if (Project.TableOfContentsFileName = '') then
  begin
    Project.TableOfContentsFileName := '_table_of_contents.hhc';
    TOCEdit.FileName := Project.TableOfContentsFileName;
    Modified := True;
  end;

  FileName := CreateAbsoluteProjectFile(Project.TableOfContentsFileName);

  if FileExists(FileName) then
  begin
    Stream := TFileStream.Create(FileName, fmOpenReadWrite);
  end
  else
  begin
    Stream := TFileStream.Create(FileName, fmCreate or fmOpenReadWrite);
  end;

  try
    SitemapEditForm.Execute(Stream, stTOC, FileListBox.Items);
  finally
    Stream.Free;
  end;
end;

procedure TCHMForm.TOCEditEditingDone(Sender: TObject);
begin
  if (TOCEdit.FileName <> '') then
  begin
    if (ExtractFileExt(TOCEdit.FileName)) = '' then
      TOCEdit.FileName := TOCEdit.FileName + '.hhc';
    TOCEdit.FileName := CreateRelativeProjectFile(TOCEdit.FileName);
  end;
  Project.TableOfContentsFileName := TOCEdit.FileName;
  Modified := True;
end;

function TCHMForm.GetModified: Boolean;
begin
  Result := (Project <> nil) and FModified;
end;

function TCHMForm.StrictModified: Boolean;
begin
  Result := Modified;

  // The following case happens that one of the FileNameEdits has been changed
  // and the project is closed in a way which does not fire the OnEditingDone
  // event (e.g., close form by 'x' button).
  if (not Result) and Assigned(Project) and (
    (ExtractFileName(CHMFilenameEdit.FileName) <> Project.OutputFileName) or
    (ExtractFileName(TOCEdit.FileName) <> Project.TableOfContentsFileName) or
    (ExtractFileName(IndexEdit.FileName) <> Project.IndexFileName)
    )
  then
    Result := true;
end;

function TCHMForm.Save(aAs: Boolean): Boolean;
var
  ext: String;
begin
  Result := false;
  if aAs or (Project.FileName = '') then
  begin
    InitFileDialog(SaveDialog1);
    if SaveDialog1.Execute then
    begin
      Project.FileName := SaveDialog1.FileName;
      ProjectDirChanged;
    end else
      exit;
  end;
  Project.Files.Assign(FileListBox.Items);
  Project.Title                   := ChmTitleEdit.Text;
  Project.TableOfContentsFileName := CreateRelativeProjectFile(TOCEdit.FileName);
  Project.IndexFileName           := CreateRelativeProjectFile(IndexEdit.FileName);
  Project.DefaultPage             := DefaultPageCombo.Text;
  Project.ScanHtmlContents        := ScanHtmlCheck.Checked;
  Project.MakeSearchable          := CreateSearchableCHMCheck.Checked;
  Project.OutputFileName          := CreateRelativeProjectFile(ChmFileNameEdit.FileName);

  case Lowercase(ExtractFileExt(Project.FileName)) of
    '.hfp': Project.SaveToFile(Project.FileName);
    '.hhp': Project.SaveToHHP(Project.FileName);
  end;
  UpdateCaption;

  Modified := False;
  Result := true;
end;

function TCHMForm.CloseProject: Boolean;
var
  MResult: TModalResult;
begin
  Result := True;

  if Modified then
  begin
    MResult := MessageDlg(
      rsProjectHasBeenModified + LineEnding + rsSaveChanges,
      mtConfirmation, [mbYes, mbNo, mbCancel], 0
    );
    case MResult of
      mrCancel: Exit(False);
      mrYes: Save(False);
      mrNo: Modified := false;
    end;
  end;

  FileListBox.Clear;
  DefaultPageCombo.Clear;
  ChmTitleEdit.Clear();
  TOCEdit.Clear;
  IndexEdit.Clear;
  ChmFileNameEdit.Clear;
  FilesGroupBox.Enabled := False;
  MainPanel.Enabled := False;
  AcSaveAs.Enabled := False;
  AcSave.Enabled := False;
  AcClose.Enabled := False;
  AcCompile.Enabled := False;
  AcCompileAndView.Enabled := False;
  CompileTimeOptionsGroupBox.Enabled := False;
  ScanHtmlCheck.Checked := False;
  CreateSearchableCHMCheck.Checked := False;
  FreeAndNil(Project);
  Modified := False;
end;

procedure TCHMForm.OpenProject(AFileName: String);
begin
  if not Assigned(Project) then
    Project := TChmProject.Create;

  if FileExists(AFileName) then
  begin
    case lowercase(ExtractFileExt(AFileName)) of
      '.hhp': Project.LoadFromHHP(AFileName, true);
      '.hfp': Project.LoadFromFile(AFileName);
      else raise Exception.Create('File type not supported');
    end;
    ProjectDirChanged;
  end else
    Project.FileName := AFileName;

  FilesGroupBox.Enabled := True;
  MainPanel.Enabled := True;
  AcSaveAs.Enabled := True;
  AcSave.Enabled := True;
  AcClose.Enabled := True;
  AcCompile.Enabled := True;
  AcCompileAndView.Enabled := True;
  CompileTimeOptionsGroupBox.Enabled := True;

  FileListBox.Items.AddStrings(Project.Files);
  ChmTitleEdit.Text := Project.Title;
  TOCEdit.FileName := Project.TableOfContentsFileName;
  IndexEdit.FileName := Project.IndexFileName;
  DefaultPageCombo.Items.Assign(FileListBox.Items);
  DefaultPageCombo.Text := Project.DefaultPage;
  ScanHtmlCheck.Checked := Project.ScanHtmlContents;
  CreateSearchableCHMCheck.Checked := Project.MakeSearchable;
  ChmFileNameEdit.FileName := Project.OutputFileName;

  Modified := False;
  UpdateCaption;
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

procedure TCHMForm.SetLanguage(ALang: String);
begin
  SetDefaultLang(ALang);
  Caption := rsCHMMakerCaption;

  AcNew.Caption := rsNew;
  AcOpen.Caption := rsOpen;
  AcSave.Caption := rsSave;
  AcSaveAs.Caption := rsSaveAs;
  AcClose.Caption := rsClose;
  AcQuit.Caption := rsQuit;
  AcCompile.Caption := rsCompile;
  AcCompileAndView.Caption := rsCompileAndView;
  AcAbout.Caption := rsAbout;

  FilesGroupbox.Caption := rsFiles;
  TOCEditBtn.Caption := rsEdit;
  IndexEditBtn.Caption := rsEdit;

  AcNew.Hint := rsNew_Hint;
  AcOpen.Hint := rsOpen_Hint;
  AcSave.Hint := rsSave_Hint;
  AcSaveAs.Hint := rsSaveAs_Hint;
  AcClose.Hint := rsClose_Hint;
  AcQuit.Hint := rsQuit_Hint;
  AcCompile.Hint := rsCompile_Hint;
  AcCompileAndView.Hint := rsCompileAndView_Hint;
  AcAbout.Hint := rsAbout_Hint;
  CreateSearchableCHMCheck.Hint := rsCreateSearchableHTML_Hint;

  OpenDialog1.Filter :=
    rsHelpProjectFiles  + '|*.hfp;*.hhp|' +
    rsHelpFileProjectHFP + '|*.hfp|'+
    rsHelpWorkshopProjectHHP + '|*.hhp';
  SaveDialog1.Filter := OpenDialog1.Filter;

  TOCEdit.Filter := rsTOCFiles + '|*.hhc|' + rsAllFiles + '|*';
  IndexEdit.Filter := rsIndexFiles + '|*.hhk|' + rsAllFiles + '|*';
  ChmFileNameEdit.Filter := rsCompressedHTMLHelpFiles + '|*.chm';
end;

procedure TCHMForm.UpdateCaption;
var
  fn: string;
begin
  if Assigned(Project) then
  begin
    if Project.FileName <> '' then
      fn := ExtractFileName(Project.Filename)
    else
      fn := rsNoName;
    Caption := Format('%s - %s', [rsCHMMakerCaption, fn]);
  end else
    Caption := rsCHMMakerCaption;
end;

end.

