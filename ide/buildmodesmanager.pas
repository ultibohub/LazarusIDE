{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************

 Author: Mattias Gaertner, Juha Manninen

 Abstract:
   Modal dialog for editing build modes: add, delete, reorder, rename, diff.
   Global functions related to many build modes.
}
unit BuildModesManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  Forms, Controls, Dialogs, StdCtrls, Grids, Menus, ComCtrls, ButtonPanel, LCLProc,
  // LazUtils
  LazFileUtils, LazLoggerBase, UITypes,
  // IdeIntf
  IDEDialogs, CompOptsIntf, IDEOptionsIntf, LazIDEIntf, IDEImagesIntf,
  // IDE
  MainBase, MainBar, BasePkgManager, PackageDefs, Project, CompilerOptions,
  EnvironmentOpts, TransferMacros, BaseBuildManager, Compiler_ModeMatrix,
  BuildModeDiffDlg, GenericCheckList, IDEProcs, LazarusIDEStrConsts;

type

  { TBuildModesForm }

  TBuildModesForm = class(TForm)
    btnCreateDefaultModes: TButton;
    BuildModesStringGrid: TStringGrid;
    RenameButton: TButton;
    BuildModesPopupMenu: TPopupMenu;
    ButtonPanel1: TButtonPanel;
    NoteLabel: TLabel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton5: TToolButton;
    ToolButtonAdd: TToolButton;
    ToolButtonDelete: TToolButton;
    ToolButtonDiff: TToolButton;
    ToolButtonMoveDown: TToolButton;
    ToolButtonMoveUp: TToolButton;
    procedure btnCreateDefaultModesClick(Sender: TObject);
    procedure BuildModesStringGridDrawCell(Sender: TObject;
      aCol, aRow: Integer; aRect: TRect; {%H-}aState: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DiffSpeedButtonClick(Sender: TObject);
    procedure AddSpeedButtonClick(Sender: TObject);
    procedure DeleteSpeedButtonClick(Sender: TObject);
    procedure MoveDownSpeedButtonClick(Sender: TObject);
    procedure MoveUpSpeedButtonClick(Sender: TObject);
    procedure BuildModesCheckboxToggled(Sender: TObject;
      aCol, aRow: Integer; aState: TCheckboxState);
    procedure BuildModesStringGridSelection(Sender: TObject;
      {%H-}aCol, {%H-}aRow: Integer);
    procedure BuildModesStringGridValidateEntry(Sender: TObject;
      aCol, aRow: Integer; const OldValue: string; var NewValue: String);
    procedure FormShow(Sender: TObject);
    procedure RenameButtonClick(Sender: TObject);
  private
    fActiveBuildMode: TProjectBuildMode;
    fBuildModes: TProjectBuildModes;
    fShowSession: boolean;
    fModeActiveCol: integer;
    fModeInSessionCol: integer;
    fModeNameCol: integer;
    procedure FillBuildModesGrid(aOnlyActiveState: Boolean = False);
    function GetActiveBuildMode: TProjectBuildMode;
    procedure SetActiveBuildMode(AValue: TProjectBuildMode);
    procedure UpdateBuildModeButtons;
    procedure SetShowSession(const AValue: boolean);
    procedure DoShowSession;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetSelectedBuildMode: TProjectBuildMode;
    procedure SetActiveBuildModeByID(const Identifier: string; SelectInGrid: boolean);
  public
    property ActiveBuildMode: TProjectBuildMode read GetActiveBuildMode write SetActiveBuildMode;
    property BuildModes: TProjectBuildModes read fBuildModes;
    property ShowSession: boolean read fShowSession write SetShowSession;
  end;

  { TBuildModesCheckList }

  TBuildModesCheckList = class
  private
    FListForm: TGenericCheckListForm;
    function IsSelected(AIndex: Integer): Boolean;
    procedure SaveManyModesSelection;
    procedure SelectAll;
    procedure SelectFirst;
    function Show: Boolean;
  public
    constructor Create(InfoCaption: String);
    destructor Destroy; override;
  end;

function ShowBuildModesDlg(aShowSession: Boolean): TModalResult;
procedure SwitchBuildMode(aBuildModeID: string);
procedure UpdateBuildModeCombo(aCombo: TComboBox);

// Functions dealing with many BuildModes. They depend on TBuildModesCheckList.
function AddPathToBuildModes(aDir: string; IsIncludeFile: Boolean): Boolean;
procedure RemovePathFromBuildModes(ObsoletePaths: String; pcos: TParsedCompilerOptString);
function BuildManyModes: Boolean;

// Check if UnitDirectory is part of the Unit Search Paths.
//  If not, ask user if he wants to extend dependencies or the Unit Search Paths.
// Not strictly for many BuildModes but it adds a path to them all.
function CheckDirIsInSearchPath(UnitInfo: TUnitInfo; IsIncludeFile: Boolean): Boolean;

var
  OnLoadIDEOptionsHook: TOnLoadIDEOptions;
  OnSaveIDEOptionsHook: TOnSaveIDEOptions;


implementation

{$R *.lfm}

function ShowBuildModesDlg(aShowSession: Boolean): TModalResult;
var
  frm: TBuildModesForm;
begin
  frm := TBuildModesForm.Create(nil);
  try
    Assert(Assigned(Project1), 'ShowBuildModesDlg: Project is not assigned.');
    // Save changes
    OnSaveIDEOptionsHook(Nil, Project1.CompilerOptions);
    // Copy to dialog
    frm.BuildModes.Assign(Project1.BuildModes, True);
    frm.SetActiveBuildModeByID(Project1.ActiveBuildMode.Identifier,true);
    frm.fShowSession:=aShowSession;
    // Show the form. Let user add / edit / delete.
    Result := frm.ShowModal;
    if Result = mrOk then
    begin
      // Copy back from dialog
      Project1.BuildModes.Assign(frm.BuildModes, True);
      // Switch
      Project1.ActiveBuildModeID:=frm.fActiveBuildMode.Identifier;
      IncreaseBuildMacroChangeStamp;
      // Load options
      if ModeMatrixFrame<>nil then
        ModeMatrixFrame.UpdateModes(true);
      OnLoadIDEOptionsHook(Nil, Project1.CompilerOptions);
    end;
  finally
    frm.Free;
  end;
end;

procedure PrepareForBuild;
begin
  Project1.DefineTemplates.AllChanged(false);
  IncreaseBuildMacroChangeStamp;
  BuildBoss.SetBuildTargetProject1;
end;

procedure SwitchBuildMode(aBuildModeID: string);
begin
  OnSaveIDEOptionsHook(Nil, Project1.CompilerOptions);    // Save changes
  Project1.ActiveBuildModeID := aBuildModeID;             // Switch
  PrepareForBuild;
  OnLoadIDEOptionsHook(Nil, Project1.CompilerOptions);    // Load options
end;

procedure UpdateBuildModeCombo(aCombo: TComboBox);
var
  i, ActiveIndex: Integer;
  CurMode: TProjectBuildMode;
  sl: TStringList;
begin
  ActiveIndex := 0;
  sl:=TStringList.Create;
  try
    {$IFDEF EnableOptionsAllBuildModes}
    sl.Add(lisAllBuildModes);
    {$ENDIF}
    for i := 0 to Project1.BuildModes.Count-1 do
    begin
      CurMode := Project1.BuildModes[i];
      sl.Add(CurMode.Identifier);
      if CurMode = Project1.ActiveBuildMode then
        ActiveIndex := sl.Count-1;  // Will be set as ItemIndex in Combo.
    end;
    aCombo.Items.Assign(sl);
    aCombo.ItemIndex := ActiveIndex;
  finally
    sl.Free;
  end;
end;

function AddPathToBuildModes(aDir: string; IsIncludeFile: Boolean): Boolean;
var
  DlgCapt, DlgMsg: String;
  i: Integer;
  Ok: Boolean;
  BMList: TBuildModesCheckList;
begin
  Result:=True;
  if IsIncludeFile then begin
    DlgCapt:=lisAddToIncludeSearchPath;
    DlgMsg:=lisTheNewIncludeFileIsNotYetInTheIncludeSearchPathAdd;
  end
  else begin
    DlgCapt:=lisAddToUnitSearchPath;
    DlgMsg:=lisTheNewUnitIsNotYetInTheUnitSearchPathAddDirectory;
  end;
  BMList:=TBuildModesCheckList.Create(DlgCapt);
  try
    if Project1.BuildModes.Count > 1 then
    begin
      BMList.SelectAll;
      Ok:=BMList.Show;
    end
    else begin
      Ok:=IDEMessageDialog(DlgCapt, Format(DlgMsg,[LineEnding,aDir]),
                           mtConfirmation,[mbYes,mbNo]) = mrYes;
      BMList.SelectFirst; // The only (Default) build mode must be selected.
    end;
    if not Ok then Exit(False);
    if not Project1.IsVirtual then
      aDir:=CreateRelativePath(aDir, Project1.Directory);
    for i:=0 to Project1.BuildModes.Count-1 do
      if BMList.IsSelected(i) then
        with Project1.BuildModes[i].CompilerOptions do
          if IsIncludeFile then
            MergeToIncludePaths(aDir)
          else
            MergeToUnitPaths(aDir);
  finally
    BMList.Free;
  end;
end;

procedure RemovePathFromBuildModes(ObsoletePaths: String; pcos: TParsedCompilerOptString);
var
  bm: TProjectBuildMode;
  DlgCapt, DlgMsg: String;
  ProjPaths, CurDir, ResolvedDir, PrevResolvedDir: String;
  i, p, OldP: Integer;
  QRes: TModalResult;
begin
  if pcos=pcosUnitPath then begin
    DlgCapt:=lisRemoveUnitPath;
    DlgMsg:=lisTheDirectoryContainsNoProjectUnitsAnyMoreRemoveThi;
  end
  else begin    // pcos=pcosIncludePath
    DlgCapt:=lisRemoveIncludePath;
    DlgMsg:=lisTheDirectoryContainsNoProjectIncludeFilesAnyMoreRe;
  end;
  QRes:=mrNone;
  i:=0;
  // Iterate all build modes until the user chooses to cancel.
  PrevResolvedDir:='';
  while (i < Project1.BuildModes.Count) and (QRes in [mrNone,mrYes]) do
  begin
    bm:=Project1.BuildModes[i];
    p:=1;
    repeat
      OldP:=p;
      if pcos=pcosUnitPath then
        ProjPaths:=bm.CompilerOptions.OtherUnitFiles
      else
        ProjPaths:=bm.CompilerOptions.IncludePath;
      CurDir:=GetNextDirectoryInSearchPath(ProjPaths,p);
      if CurDir='' then break;

      // Find build modes that have unneeded search paths
      ResolvedDir:=bm.CompilerOptions.ParsedOpts.DoParseOption(CurDir,pcos,false);
      if (ResolvedDir<>'')
      and (SearchDirectoryInSearchPath(ObsoletePaths,ResolvedDir)>0) then begin
        // Ask confirmation once for each path.
        // In fact there should be only one path after one source file is removed.
        if (QRes=mrNone) or ((PrevResolvedDir<>'') and (PrevResolvedDir<>ResolvedDir)) then
          QRes:=IDEQuestionDialog(DlgCapt,Format(DlgMsg,[CurDir]),
                   mtConfirmation, [mrYes, lisRemove,
                                    mrNo, lisKeep2], '');
        if QRes=mrYes then begin
          // remove
          if pcos=pcosUnitPath then
            bm.CompilerOptions.OtherUnitFiles:=RemoveSearchPaths(ProjPaths,CurDir)
          else
            bm.CompilerOptions.IncludePath:=RemoveSearchPaths(ProjPaths,CurDir);
          p:=OldP;
        end;
        PrevResolvedDir:=ResolvedDir;
      end;
    until false;
    Inc(i);
  end;
end;

function BuildManyModes(): Boolean;
var
  ModeCnt: Integer;

  function BuildOneMode(LastMode: boolean): Boolean;
  begin
    Inc(ModeCnt);
    DebugLn('');
    DebugLn(Format('Building mode %d: %s ...', [ModeCnt, Project1.ActiveBuildMode.Identifier]));
    DebugLn('');
    Result := MainIDE.DoBuildProject(crCompile, [], LastMode) = mrOK;
  end;

var
  BMList: TBuildModesCheckList;
  ModeList: TList;
  md, ActiveMode: TProjectBuildMode;
  BuildActiveMode: Boolean;
  i: Integer;
  LastMode: boolean;
begin
  Result := False;
  ModeCnt := 0;
  if PrepareForCompileWithMsg <> mrOk then Exit;
  BMList := TBuildModesCheckList.Create(lisCompileFollowingModes);
  ModeList := TList.Create;
  try
    if not BMList.Show then Exit;
    BMList.SaveManyModesSelection;      // Remember the selection for next time.
    ActiveMode := Project1.ActiveBuildMode;
    BuildActiveMode := False;
    // Collect modes to be built.
    for i := 0 to Project1.BuildModes.Count-1 do
    begin
      md := Project1.BuildModes[i];
      if BMList.IsSelected(i) then
        if md = ActiveMode then
          BuildActiveMode := True
        else
          ModeList.Add(md);
    end;
    try
      MainIDEBar.itmProjectOptions.Enabled:=False;
      // Build first the active mode so we don't have to switch many times.
      if BuildActiveMode then
      begin
        DebugLn('BuildManyModes: Active Mode');
        LastMode := (ModeList.Count=0);
        if not BuildOneMode(LastMode) then Exit;
      end
      else if ModeList.Count=0 then
      begin
        IDEMessageDialog(lisExit, lisPleaseSelectAtLeastOneBuildMode,
                         mtInformation, [mbOK]);
        Exit;
      end;
      // Build rest of the modes.
      DebugLn('BuildManyModes: Rest of the Modes');
      for i := 0 to ModeList.Count-1 do
      begin
        LastMode := (i=(ModeList.Count-1));
        Project1.ActiveBuildMode := TProjectBuildMode(ModeList[i]);
        PrepareForBuild;
        if not BuildOneMode(LastMode) then Exit;
      end;
      Result:=True;
    finally
      // Switch back to original mode.
      DebugLn('BuildManyModes: Switch back to ActiveMode');
      Project1.ActiveBuildMode := ActiveMode;
      PrepareForBuild;
      MainIDEBar.itmProjectOptions.Enabled:=True;
      LazarusIDE.DoSaveProject([]);
      if Result then
        IDEMessageDialog(lisSuccess, Format(lisSelectedModesWereCompiled, [ModeCnt]),
                         mtInformation, [mbOK]);
    end;
  finally
    ModeList.Free;
    BMList.Free;
  end;
end;

function CheckDirIsInSearchPath(UnitInfo: TUnitInfo; IsIncludeFile: Boolean): Boolean;
// Check if the given unit's path is on Unit- or Include-search path.
// Returns true if it is OK to add the unit to current project.
var
  UnitDir, CurPath: String;
begin
  Result:=True;
  if UnitInfo.IsVirtual then exit;
  if IsIncludeFile then
    CurPath:=Project1.CompilerOptions.GetIncludePath(false)
  else
    CurPath:=Project1.CompilerOptions.GetUnitPath(false);
  UnitDir:=AppendPathDelim(UnitInfo.GetDirectory);
  if SearchDirectoryInSearchPath(CurPath,UnitDir)<1 then
    // unit is not in search path => extend it
    Result:=AddPathToBuildModes(UnitDir,IsIncludeFile);
end;

{ TBuildModesForm }

constructor TBuildModesForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fBuildModes := TProjectBuildModes.Create(Nil);
end;

destructor TBuildModesForm.Destroy;
begin
  FreeAndNil(fBuildModes);
  inherited Destroy;
end;

procedure TBuildModesForm.FormCreate(Sender: TObject);
begin
  ;
end;

procedure TBuildModesForm.FormDestroy(Sender: TObject);
begin
  ;
end;

procedure TBuildModesForm.FormShow(Sender: TObject);
begin
  // options dialog
  DoShowSession;
  // modes
  FillBuildModesGrid;
  UpdateBuildModeButtons;

  Toolbar1.Images := IDEImages.Images_16;
  ToolButtonAdd.ImageIndex := IDEImages.LoadImage('laz_add', 16);
  ToolButtonDelete.ImageIndex := IDEImages.LoadImage('laz_delete', 16);
  ToolButtonMoveUp.ImageIndex := IDEImages.LoadImage('arrow_up', 16);
  ToolButtonMoveDown.ImageIndex := IDEImages.LoadImage('arrow_down', 16);
  ToolButtonDiff.ImageIndex := IDEImages.LoadImage('menu_tool_diff', 16);
  RenameButton.Caption:=lisBtnRename;
end;

procedure TBuildModesForm.RenameButtonClick(Sender: TObject);
var
  CurMode: TProjectBuildMode;
  Value, OldValue: string;
  i: Integer;
begin
  i:=BuildModesStringGrid.Row-1;
  if (i<0) then exit;
  CurMode:=fBuildModes[i];
  Value:=CurMode.Identifier;
  OldValue:=Value;
  if InputQuery(lisRename, lisUIDName, Value) then
  begin
    CurMode.Identifier:=Value;
    FillBuildModesGrid;
    // Rename in many BuildModes selection.
    i:=fBuildModes.ManyBuildModes.IndexOf(OldValue);
    if i>=0 then
      fBuildModes.ManyBuildModes[i]:=Value;
    // Rename in the ModeMatrix settings frame.
    ModeMatrixFrame.Grid.RenameMode(OldValue, Value);
  end;
end;

procedure TBuildModesForm.DiffSpeedButtonClick(Sender: TObject);
begin
  // show diff dialog
  ShowBuildModeDiffDialog(BuildModes,GetSelectedBuildMode);
end;

procedure TBuildModesForm.btnCreateDefaultModesClick(Sender: TObject);
var
  CurMode: TProjectBuildMode;
  i: Integer;
begin
  i:=BuildModesStringGrid.Row-1;
  if (i>=0) then
    CurMode:=fBuildModes[i]
  else
    CurMode:=nil;
  // Create Debug and Release modes, activate Debug mode
  fActiveBuildMode:=fBuildModes.CreateExtraModes(CurMode);
  FillBuildModesGrid;               // show
  // select identifier
  BuildModesStringGrid.Col:=fModeNameCol;
  BuildModesStringGrid.Row:=BuildModesStringGrid.RowCount-1;
end;

procedure TBuildModesForm.AddSpeedButtonClick(Sender: TObject);
var
  i: Integer;
  NewName, Identifier: String;
  CurMode, NewMode: TProjectBuildMode;
begin
  // use current mode as template
  i:=BuildModesStringGrid.Row-1;
  if (i>=0) then
  begin
    Identifier:=BuildModesStringGrid.Cells[fModeNameCol,i+1];
    CurMode:=fBuildModes[i];
  end
  else begin
    Identifier:='Mode';
    CurMode:=nil;
  end;
  // find unique name
  i:=0;
  repeat
    inc(i);
    NewName:=Identifier+IntToStr(i);
  until fBuildModes.Find(NewName)=nil;
  // create new mode
  NewMode:=fBuildModes.Add(NewName);
  // clone from currently selected mode
  if CurMode<>nil then
    NewMode.Assign(CurMode);
  fActiveBuildMode:=NewMode; // activate
  FillBuildModesGrid;     // show
  // select identifier
  BuildModesStringGrid.Col:=fModeNameCol;
  BuildModesStringGrid.Row:=BuildModesStringGrid.RowCount-1;
  BuildModesStringGrid.EditorMode:=true;
end;

procedure TBuildModesForm.DeleteSpeedButtonClick(Sender: TObject);
var
  i: Integer;
  CurMode: TProjectBuildMode;
  Grid: TStringGrid;
begin
  Grid:=BuildModesStringGrid;
  i:=Grid.Row-1;
  if i<0 then exit;
  if fBuildModes.Count=1 then
  begin
    IDEMessageDialog(lisCCOErrorCaption, lisThereMustBeAtLeastOneBuildMode,
      mtError,[mbCancel]);
    exit;
  end;
  CurMode:=fBuildModes[i];
  // when delete the activated: activate another
  if fActiveBuildMode=CurMode then
  begin
    if i<fBuildModes.Count-1 then
      fActiveBuildMode:=fBuildModes[i+1]
    else
      fActiveBuildMode:=fBuildModes[i-1];
  end;
  if fActiveBuildMode=CurMode then begin
    debugln(['TBuildModesForm.BuildModeDeleteSpeedButtonClick activate failed']);
    exit;
  end;
  // delete mode
  fBuildModes.Delete(i);
  FillBuildModesGrid;
  // select next mode
  if i>=Grid.RowCount then
    Grid.Row:=Grid.RowCount-1
  else
    Grid.Row:=i;
end;

procedure TBuildModesForm.MoveDownSpeedButtonClick(Sender: TObject);
var
  i: Integer;
begin
  i:=BuildModesStringGrid.Row-1;
  if i+1>=fBuildModes.Count then exit;
  fBuildModes.Move(i,i+1);
  fBuildModes[0].InSession:=false;
  inc(i);
  FillBuildModesGrid;
  BuildModesStringGrid.Row:=i+1;
end;

procedure TBuildModesForm.MoveUpSpeedButtonClick(Sender: TObject);
var
  i: Integer;
begin
  i:=BuildModesStringGrid.Row-1;
  if i<=0 then exit;
  fBuildModes.Move(i,i-1);
  dec(i);
  fBuildModes[0].InSession:=false;
  FillBuildModesGrid;
  BuildModesStringGrid.Row:=i+1;
end;

procedure TBuildModesForm.BuildModesCheckboxToggled(Sender: TObject;
  aCol, aRow: Integer; aState: TCheckboxState);
var
  CurMode: TProjectBuildMode;
  i: Integer;
  Grid: TStringGrid;
begin
  //debugln(['TBuildModesForm.BuildModesCheckboxToggled Row=',aRow,' Col=',aCol,' ',ord(aState)]);
  i:=aRow-1;
  if (i<0) or (i>=fBuildModes.Count) then exit;
  CurMode:=fBuildModes[i];
  Grid:=BuildModesStringGrid;
  if aCol=fModeActiveCol then
  begin
    // activate
    if CurMode=fActiveBuildMode then begin
      //debugln(['TBuildModesForm.BuildModesCheckboxToggled, is ActiveBuildMode',i]);
      // Switch back to Checked state. There must always be an active mode
      Grid.Cells[aCol,aRow]:=Grid.Columns[aCol].ValueChecked;
    end
    else begin
      //debugln(['TBuildModesForm.BuildModesCheckboxToggled, another Mode',i]);
      fActiveBuildMode:=CurMode;
      FillBuildModesGrid(True);
    end;
  end else if aCol=fModeInSessionCol then
  begin
    // in session
    if (aState=cbChecked) and (i=0) then
    begin
      Grid.Cells[aCol,aRow]:=Grid.Columns[aCol].ValueUnchecked;
      NoteLabel.Caption:=lisTheDefaultModeMustBeStoredInProject;
      exit;
    end;
    CurMode.InSession:=aState=cbChecked;
  end;
end;

procedure TBuildModesForm.BuildModesStringGridSelection(Sender: TObject;
  aCol, aRow: Integer);
begin
  UpdateBuildModeButtons;
end;

procedure TBuildModesForm.BuildModesStringGridValidateEntry(Sender: TObject;
  aCol, aRow: Integer; const OldValue: string; var NewValue: String);
var
  CurMode: TProjectBuildMode;
  s: string;
  i: Integer;
  b: Boolean;
begin
  //debugln(['TBuildModesForm.BuildModesStringGridValidateEntry Row=',aRow,' Col=',aCol]);
  i:=aRow-1;
  if (i<0) or (i>=fBuildModes.Count) then exit;
  CurMode:=fBuildModes[i];
  if aCol=fModeInSessionCol then
  begin
    // in session
    b:=NewValue=BuildModesStringGrid.Columns[aCol].ValueChecked;
    if b and (i=0) then
    begin
      NewValue:=OldValue;
      IDEMessageDialog(lisCCOErrorCaption,lisTheDefaultModeMustBeStoredInProject,
                       mtError,[mbCancel]);
      exit;
    end;
    CurMode.InSession:=b;
  end
  else if aCol=fModeNameCol then
  begin
    // identifier
    s:=NewValue;
    for i:=1 to length(s) do
      if s[i]<' ' then
        s[i]:=' ';
    NewValue:=s;
    if CurMode.Identifier<>s then begin
      for i:=0 to fBuildModes.Count-1 do begin
        if (fBuildModes[i]<>CurMode)
        and (Comparetext(fBuildModes[i].Identifier,NewValue)=0) then begin
          IDEMessageDialog(lisDuplicateEntry,
            lisThereIsAlreadyABuildModeWithThisName, mtError, [mbCancel]);
          NewValue:=CurMode.Identifier;
          exit;
        end;
      end;
      BuildModes.RenameMatrixMode(CurMode.Identifier,s);
      CurMode.Identifier:=s;
    end;
  end;
  NoteLabel.Caption:='';
end;

procedure TBuildModesForm.FillBuildModesGrid(aOnlyActiveState: Boolean);
var
  i: Integer;
  CurMode: TProjectBuildMode;
  Grid: TStringGrid;
begin
  Grid:=BuildModesStringGrid;
  Grid.BeginUpdate;
  Grid.RowCount:=fBuildModes.Count+1;
  for i:=0 to fBuildModes.Count-1 do
  begin
    CurMode:=fBuildModes[i];
    // active
    if CurMode=fActiveBuildMode then
      Grid.Cells[fModeActiveCol,i+1]:=Grid.Columns[fModeActiveCol].ValueChecked
    else
      Grid.Cells[fModeActiveCol,i+1]:=Grid.Columns[fModeActiveCol].ValueUnchecked;
    if not aOnlyActiveState then
    begin
      // in session
      if fModeInSessionCol>=0 then
        if CurMode.InSession then
          Grid.Cells[fModeInSessionCol,i+1]:=Grid.Columns[fModeInSessionCol].ValueChecked
        else
          Grid.Cells[fModeInSessionCol,i+1]:=Grid.Columns[fModeInSessionCol].ValueUnchecked;
      // identifier
      Grid.Cells[fModeNameCol,i+1]:=CurMode.Identifier;
    end;
  end;
  Grid.EndUpdate(true);
end;

procedure TBuildModesForm.UpdateBuildModeButtons;
var
  i: Integer;
  CurMode: TProjectBuildMode;
  Identifier: string;
begin
  i:=BuildModesStringGrid.Row-1;
  if (fBuildModes<>nil) and (i>=0) and (i<fBuildModes.Count) then
  begin
    CurMode:=fBuildModes[i];
    Identifier:=BuildModesStringGrid.Cells[fModeNameCol,i+1];
  end
  else begin
    CurMode:=nil;
    Identifier:='';
  end;
  // Dialog caption
  Caption:=Format(lisBuildMode, [Identifier]);
  // Buttons
  ToolButtonAdd.Hint:=Format(lisAddNewBuildModeCopyingSettingsFrom, [Identifier]);
  ToolButtonDelete.Enabled:=(CurMode<>nil) and (fBuildModes.Count>1);
  ToolButtonDelete.Hint:=Format(lisDeleteMode, [Identifier]);
  ToolButtonMoveUp.Enabled:=(CurMode<>nil) and (i>0);
  ToolButtonMoveUp.Hint:=Format(lisMoveOnePositionUp, [Identifier]);
  ToolButtonMoveDown.Enabled:=i<BuildModesStringGrid.RowCount-2;
  ToolButtonMoveDown.Hint:=Format(lisMoveOnePositionDown, [Identifier]);
  ToolButtonDiff.Hint:=lisShowDifferencesBetweenModes;
  NoteLabel.Caption:='';
  btnCreateDefaultModes.Caption:=lisCreateDebugAndReleaseModes;
  btnCreateDefaultModes.Hint:='';   // ToDo: Figure out a good hint.
  btnCreateDefaultModes.Visible := (fBuildModes.Find(DebugModeName)=Nil)
                               and (fBuildModes.Find(ReleaseModeName)=Nil);
end;

procedure TBuildModesForm.SetShowSession(const AValue: boolean);
begin
  if AValue=fShowSession then exit;
  fShowSession:=AValue;
  DoShowSession;
  FillBuildModesGrid;
end;

procedure TBuildModesForm.DoShowSession;
var
  Grid: TStringGrid;
begin
  Grid:=BuildModesStringGrid;
  Grid.BeginUpdate;
  fModeActiveCol:=0;
  if fShowSession then
  begin
    fModeInSessionCol:=1;
    fModeNameCol:=2;
    if Grid.Columns.Count<3 then
      Grid.Columns.Insert(fModeInSessionCol);
  end else begin
    fModeInSessionCol:=-1;
    fModeNameCol:=1;
    if Grid.Columns.Count>2 then
      Grid.Columns.Delete(1);
  end;
  BuildModesStringGrid.Columns[fModeActiveCol].Title.Caption:=lisActive;
  BuildModesStringGrid.Columns[fModeActiveCol].SizePriority:=1;
  BuildModesStringGrid.Columns[fModeActiveCol].ButtonStyle:=cbsCheckboxColumn;
  if fModeInSessionCol>=0 then
  begin
    BuildModesStringGrid.Columns[fModeInSessionCol].Title.Caption:=lisInSession;
    BuildModesStringGrid.Columns[fModeInSessionCol].SizePriority:=1;
    BuildModesStringGrid.Columns[fModeInSessionCol].ButtonStyle:=cbsCheckboxColumn;
  end;
  BuildModesStringGrid.Columns[fModeNameCol].Title.Caption:=lisName;
  BuildModesStringGrid.Columns[fModeNameCol].SizePriority:=10;
  BuildModesStringGrid.Columns[fModeNameCol].ButtonStyle:=cbsAuto;
  Grid.EndUpdate(true);
end;

function TBuildModesForm.GetSelectedBuildMode: TProjectBuildMode;
var
  i: LongInt;
begin
  Result:=nil;
  i:=BuildModesStringGrid.Row-1;
  if (i<0) or (i>=fBuildModes.Count) then exit;
  Result:=fBuildModes[i];
end;

procedure TBuildModesForm.BuildModesStringGridDrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
begin
  Assert(aCol <> -1, 'TBuildModesForm.BuildModesStringGridDrawCell: aCol = -1');
  // Hide InSession field of the first BuildMode by drawing an empty rect on it.
  if (aCol=fModeInSessionCol) and (aRow=1) then
    (Sender as TStringGrid).Canvas.FillRect(aRect);
end;

function TBuildModesForm.GetActiveBuildMode: TProjectBuildMode;
begin
  Result := fActiveBuildMode;
end;

procedure TBuildModesForm.SetActiveBuildMode(AValue: TProjectBuildMode);
begin
  fActiveBuildMode := AValue;
end;

procedure TBuildModesForm.SetActiveBuildModeByID(const Identifier: string;
  SelectInGrid: boolean);
var
  i: Integer;
begin
  for i:=0 to fBuildModes.Count-1 do
  begin
    if fBuildModes[i].Identifier=Identifier then
    begin
      ActiveBuildMode:=fBuildModes[i];
      if SelectInGrid then
        BuildModesStringGrid.Row:=i+1;
      Break;
    end;
  end;
end;

{ TBuildModesCheckList }

constructor TBuildModesCheckList.Create(InfoCaption: String);
var
  i: Integer;
  BM: String;
  ManyBMs: TStringList;
begin
  FListForm:=TGenericCheckListForm.Create(Nil);
  //lisApplyForBuildModes = 'Apply for build modes:';
  FListForm.Caption:=lisAvailableProjectBuildModes;
  FListForm.InfoLabel.Caption:=InfoCaption;
  ManyBMs:=Project1.BuildModes.ManyBuildModes;
  // Backwards compatibility. Many BuildModes value used to be in EnvironmentOptions.
  if ManyBMs.Count=0 then
    ManyBMs:=EnvironmentOptions.ManyBuildModesSelection;
  // Add project build modes to a CheckListBox.
  for i:=0 to Project1.BuildModes.Count-1 do begin
    BM:=Project1.BuildModes[i].Identifier;
    FListForm.CheckListBox1.Items.Add(BM);
    if ManyBMs.IndexOf(BM) >= 0 then
      FListForm.CheckListBox1.Checked[i]:=True;
  end;
  if ManyBMs.Count=0 then  // No persistent selections -> select all by default.
    SelectAll;
end;

destructor TBuildModesCheckList.Destroy;
begin
  FListForm.Free;
  inherited Destroy;
end;

function TBuildModesCheckList.IsSelected(AIndex: Integer): Boolean;
begin
  Result := FListForm.CheckListBox1.Checked[AIndex];
end;

procedure TBuildModesCheckList.SaveManyModesSelection;
var
  i: Integer;
begin
  // Remember selected items.
  Project1.BuildModes.ManyBuildModes.Clear;
  for i:=0 to FListForm.CheckListBox1.Items.Count-1 do
    if FListForm.CheckListBox1.Checked[i] then
      Project1.BuildModes.ManyBuildModes.Add(FListForm.CheckListBox1.Items[i]);
  Project1.Modified:=True;
end;

procedure TBuildModesCheckList.SelectAll;
var
  i: Integer;
begin
  for i := 0 to FListForm.CheckListBox1.Count-1 do
    FListForm.CheckListBox1.Checked[i] := True;
end;

procedure TBuildModesCheckList.SelectFirst;
begin
  Assert(FListForm.CheckListBox1.Items.Count>0, 'TBuildModesCheckList.SelectFirst: Build modes count < 1');
  FListForm.CheckListBox1.Checked[0] := True;
end;

function TBuildModesCheckList.Show: Boolean;
begin
  Result := FListForm.ShowModal=mrOK;
end;

end.

