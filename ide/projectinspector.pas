{
 /***************************************************************************
                          projectinspector.pas
                          --------------------


 ***************************************************************************/

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

  Author: Mattias Gaertner

  Abstract:
    TProjectInspectorForm is the form of the project inspector.

  ToDo:
    - project groups:
      - activate
   popup menu:
      - copy file name
      - save
      - options
      - activate
      - compile
      - build
      - view source
      - close
      - remove project
      - build sooner Ctrl+Up
      - build later Ctrl+Down
      - compile all from here
      - build all from here
}
unit ProjectInspector;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  LCLType, LCLIntf, Forms, Controls, Buttons, ComCtrls, Menus, Dialogs,
  ExtCtrls, StdCtrls, Graphics,
  // LazControls
  TreeFilterEdit,
  // LazUtils
  FileUtil, LazFileUtils, LazUtilities, LazLoggerBase, LazTracer, LazFileCache,
  // Codetools
  CodeToolsStructs, CodeToolManager, FileProcs, CodeCache, CodeTree, FindDeclarationTool,
  // BuildIntf
  ProjectIntf, PackageIntf, PackageLinkIntf, PackageDependencyIntf,
  // IDEIntf
  IDEHelpIntf, IDECommands, IDEDialogs, IDEImagesIntf, LazIDEIntf, ToolBarIntf,
  // IDE
  LazarusIDEStrConsts, MainBase, MainBar, IDEProcs, DialogProcs, IDEOptionDefs, Project,
  InputHistory, TransferMacros, EnvironmentOpts, BuildManager, BasePkgManager,
  ProjPackChecks, ProjPackEditing, ProjPackFilePropGui, PackageDefs,
  AddToProjectDlg, AddPkgDependencyDlg, AddFPMakeDependencyDlg, LResources;

type
  TOnAddUnitToProject =
    function(Sender: TObject; AnUnitInfo: TUnitInfo): TModalresult of object;
  TRemoveProjInspFileEvent =
    function(Sender: TObject; AnUnitInfo: TUnitInfo): TModalResult of object;
  TRemoveProjInspDepEvent = function(Sender: TObject;
                           ADependency: TPkgDependency): TModalResult of object;
  TAddProjInspDepEvent = function(Sender: TObject;
                           ADependency: TPkgDependency): TModalResult of object;

  { TProjectInspectorForm }

  TProjectInspectorForm = class(TForm,IFilesEditorInterface)
    AddPopupMenu: TPopupMenu;
    FilterPanel: TPanel;
    DirectoryHierarchyButton: TSpeedButton;
    FilterEdit: TTreeFilterEdit;
    PropsGroupBox: TGroupBox;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    mnuAddFPMakeReq: TMenuItem;
    mnuAddEditorFiles: TMenuItem;
    mnuAddDiskFile: TMenuItem;
    mnuAddReq: TMenuItem;
    OpenButton: TSpeedButton;
    ItemsTreeView: TTreeView;
    ItemsPopupMenu: TPopupMenu;
    SortAlphabeticallyButton: TSpeedButton;
    Splitter1: TSplitter;
    // toolbar
    ToolBar: TToolBar;
    // toolbuttons
    AddBitBtn: TToolButton;
    RemoveBitBtn: TToolButton;
    OptionsBitBtn: TToolButton;
    HelpBitBtn: TToolButton;
    procedure CopyMoveToDirMenuItemClick(Sender: TObject);
    procedure DirectoryHierarchyButtonClick(Sender: TObject);
    procedure FilterEditKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure ItemsPopupMenuPopup(Sender: TObject);
    procedure ItemsTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; {%H-}State: TCustomDrawState; Stage: TCustomDrawStage;
      var {%H-}PaintImages, {%H-}DefaultDraw: Boolean);
    procedure ItemsTreeViewDblClick(Sender: TObject);
    procedure ItemsTreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ItemsTreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ItemsTreeViewKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure ItemsTreeViewSelectionChanged(Sender: TObject);
    procedure mnuAddDiskFileClick(Sender: TObject);
    procedure mnuAddEditorFilesClick(Sender: TObject);
    procedure mnuAddFPMakeReqClick(Sender: TObject);
    procedure mnuAddReqClick(Sender: TObject);
    procedure mnuOpenFolderClick(Sender: TObject);
    procedure MoveDependencyUpClick(Sender: TObject);
    procedure MoveDependencyDownClick(Sender: TObject);
    procedure SetDependencyDefaultFilenameMenuItemClick(Sender: TObject);
    procedure SetDependencyPreferredFilenameMenuItemClick(Sender: TObject);
    procedure ClearDependencyFilenameMenuItemClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure OptionsBitBtnClick(Sender: TObject);
    procedure HelpBitBtnClick(Sender: TObject);
    procedure ReAddMenuItemClick(Sender: TObject);
    procedure RemoveBitBtnClick(Sender: TObject);
    procedure RemoveNonExistingFilesMenuItemClick(Sender: TObject);
    procedure SortAlphabeticallyButtonClick(Sender: TObject);
    procedure EnableI18NForLFMMenuItemClick(Sender: TObject);
    procedure DisableI18NForLFMMenuItemClick(Sender: TObject);
  private
    FIdleConnected: boolean;
    FOnAddDependency: TAddProjInspDepEvent;
    FOnAddUnitToProject: TOnAddUnitToProject;
    FOnCopyMoveFiles: TNotifyEvent;
    FOnDragDropTreeView: TDragDropEvent;
    FOnDragOverTreeView: TOnDragOverTreeView;
    FOnReAddDependency: TAddProjInspDepEvent;
    FOnRemoveDependency: TRemoveProjInspDepEvent;
    FOnRemoveFile: TRemoveProjInspFileEvent;
    FShowDirectoryHierarchy: boolean;
    FSortAlphabetically: boolean;
    FUpdateLock: integer;
    FLazProject: TProject;
    FFilesNode: TTreeNode;
    FNextSelectedPart: TObject;// select this file/dependency on next update
    FDependenciesNode: TTreeNode;
    FRemovedDependenciesNode: TTreeNode;
    ImageIndexFiles: integer;
    ImageIndexProject: integer;
    ImageIndexUnit: integer;
    ImageIndexRegisterUnit: integer;
    ImageIndexText: integer;
    ImageIndexBinary: integer;
    ImageIndexDirectory: integer;
    FFlags: TPEFlags;
    FPropGui: TProjPackFilePropGui;
    procedure AddMenuItemClick(Sender: TObject);
    function AddOneFile(aFilename: string): TModalResult;
    procedure DoAddMoreDialog;
    procedure DoAddDepDialog;
    procedure DoAddFPMakeDepDialog;
    function CreateToolButton(AName, ACaption, AHint, AImageName: String;
      AOnClick: TNotifyEvent): TToolButton;
    function CreateDivider: TToolButton;
    procedure SetDependencyDefaultFilename(AsPreferred: boolean);
    procedure SetIdleConnected(AValue: boolean);
    procedure SetLazProject(const AValue: TProject);
    procedure SetShowDirectoryHierarchy(const AValue: boolean);
    procedure SetSortAlphabetically(const AValue: boolean);
    procedure SetupComponents;
    function GetDependencyToUpdate(Immediately: boolean): TPkgDependencyID;
    function GetSingleSelectedDependency: TPkgDependency;
    procedure ApplyDependencyButtonClick(Sender: TObject);
    function TreeViewGetImageIndex({%H-}Str: String; Data: TObject; var {%H-}AIsEnabled: Boolean): Integer;
    procedure ProjectBeginUpdate(Sender: TObject);
    procedure ProjectEndUpdate(Sender: TObject; ProjectChanged: boolean);
    procedure EnableI18NForSelectedLFM(TheEnable: boolean);
    procedure PackageListAvailable(Sender: TObject);
    function CanUpdate(Flag: TPEFlag; Immediately: boolean): boolean;
    procedure UpdateFiles(Immediately: boolean = false);
    procedure UpdateProperties(Immediately: boolean = false);
    procedure UpdateButtons(Immediately: boolean = false);
    procedure UpdatePending;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure IdleHandler(Sender: TObject; var {%H-}Done: Boolean);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    function IsUpdateLocked: boolean; inline;
    procedure UpdateTitle(Immediately: boolean = false);
    procedure UpdateRequiredPackages(Immediately: boolean = false);
    function TreeViewToInspector(TV: TTreeView): TProjectInspectorForm;
  public
    // IFilesEditorInterface
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure UpdateAll(Immediately: boolean = false);
    function GetNodeItem(NodeData: TPENodeData): TObject;
    function GetNodeDataItem(TVNode: TTreeNode; out NodeData: TPENodeData;
      out Item: TObject): boolean;
    function ExtendIncSearchPath(NewIncPaths: string): boolean;
    function ExtendUnitSearchPath(NewUnitPaths: string): boolean;
    function FilesBaseDirectory: string;
    function FilesEditForm: TCustomForm;
    function FilesEditTreeView: TTreeView;
    function FilesOwner: TObject;
    function FilesOwnerName: string;
    function FilesOwnerReadOnly: boolean;
    function FirstRequiredDependency: TPkgDependency;
    function GetNodeFilename(Node: TTreeNode): string;
    function IsDirectoryNode(Node: TTreeNode): boolean;
    function TVNodeFiles: TTreeNode;
    function TVNodeRequiredPackages: TTreeNode;
  public
    property LazProject: TProject read FLazProject write SetLazProject;
    property OnAddUnitToProject: TOnAddUnitToProject read FOnAddUnitToProject
                                                     write FOnAddUnitToProject;
    property OnAddDependency: TAddProjInspDepEvent
                             read FOnAddDependency write FOnAddDependency;
    property OnRemoveFile: TRemoveProjInspFileEvent read FOnRemoveFile
                                                    write FOnRemoveFile;
    property OnRemoveDependency: TRemoveProjInspDepEvent
                             read FOnRemoveDependency write FOnRemoveDependency;
    property OnReAddDependency: TAddProjInspDepEvent
                             read FOnReAddDependency write FOnReAddDependency;
    property OnDragDropTreeView: TDragDropEvent read FOnDragDropTreeView
                                                      write FOnDragDropTreeView;
    property OnDragOverTreeView: TOnDragOverTreeView read FOnDragOverTreeView
                                                      write FOnDragOverTreeView;
    property OnCopyMoveFiles: TNotifyEvent read FOnCopyMoveFiles
                                           write FOnCopyMoveFiles;
    property SortAlphabetically: boolean read FSortAlphabetically write SetSortAlphabetically;
    property ShowDirectoryHierarchy: boolean read FShowDirectoryHierarchy write SetShowDirectoryHierarchy;
    property IdleConnected: boolean read FIdleConnected write SetIdleConnected;
  end;

  { TSetBuildModeToolButton }

  TSetBuildModeToolButton = class(TIDEToolButton)
  public type
    TBuildModeMenuItem = class(TMenuItem)
    public
      BuildModeIndex: Integer;
      procedure Click; override;
    end;

    TBuildModeMenu = class(TPopupMenu)
    protected
      procedure DoPopup(Sender: TObject); override;
    end;
  public
    procedure DoOnAdded; override;
  end;

var
  ProjInspector: TProjectInspectorForm = nil;


function UpdateUnitInfoResourceBaseClass(AnUnitInfo: TUnitInfo; Quiet: boolean): boolean;


implementation

{$R *.lfm}

function UpdateUnitInfoResourceBaseClass(AnUnitInfo: TUnitInfo; Quiet: boolean): boolean;
var
  LFMFilename, LFMType, Ancestor, LFMClassName, LFMComponentName: String;
  LFMCode, Code: TCodeBuffer;
  LoadFileFlags: TLoadBufferFlags;
  ClearOldInfo: Boolean;
  Tool: TCodeTool;
  Node: TCodeTreeNode;
  ListOfPFindContext: TFPList;
  i: Integer;
  Context: PFindContext;
begin
  Result:=false;
  if AnUnitInfo.Component<>nil then
    exit(true); // a loaded resource is always uptodate
  if AnUnitInfo.IsVirtual then
    exit(true); // a new unit is always uptodate
  ListOfPFindContext:=nil;
  ClearOldInfo:=true;
  try
    // find lfm file
    if not FilenameIsPascalUnit(AnUnitInfo.Filename) then
      exit(true); // not a unit -> clear info
    LFMFilename:=AnUnitInfo.UnitResourceFileformat.GetUnitResourceFilename(
      AnUnitInfo.Filename,true);
    if (LFMFilename='') or not FileExistsCached(LFMFilename) then
      exit(true); // no lfm -> clear info
  finally
    if ClearOldInfo then begin
      AnUnitInfo.ResourceBaseClass:=pfcbcNone;
      AnUnitInfo.ComponentName:='';
      AnUnitInfo.ComponentResourceName:='';
    end;
  end;
  try
    if not FilenameExtIs(LFMFilename,'lfm',true) then
      exit(true);          // no lfm format -> keep old info
    // clear old info
    AnUnitInfo.ResourceBaseClass:=pfcbcNone;
    AnUnitInfo.ComponentName:='';
    AnUnitInfo.ComponentResourceName:='';
    // load lfm
    LoadFileFlags:=[lbfUpdateFromDisk,lbfCheckIfText];
    if Quiet then
      Include(LoadFileFlags,lbfQuiet);
    if LoadCodeBuffer(LFMCode,LFMFilename,LoadFileFlags,false)<>mrOk then
      exit; // lfm read error
    // read lfm header
    ReadLFMHeader(LFMCode.Source,LFMType,LFMComponentName,LFMClassName);
    if LFMClassName='' then
      exit; // lfm syntax error

    // LFM component name
    AnUnitInfo.ComponentName:=LFMComponentName;
    AnUnitInfo.ComponentResourceName:=LFMComponentName;

    // check ancestors
    if LoadCodeBuffer(Code,AnUnitInfo.Filename,LoadFileFlags,false)<>mrOk then
      exit; // pas read error
    CodeToolBoss.Explore(Code,Tool,false,true);
    if Tool=nil then
      exit; // pas load error
    try
      Node:=Tool.FindDeclarationNodeInInterface(LFMClassName,true);
      if Node=nil then
        exit(Tool.FindImplementationNode<>nil); // class not found, reliable if whole interface was read

      if (Node.Desc<>ctnTypeDefinition)
      or (Node.FirstChild=nil) or (Node.FirstChild.Desc<>ctnClass) then
        exit(true); // this is not a class
      Tool.FindClassAndAncestors(Node.FirstChild,ListOfPFindContext,false);
      if ListOfPFindContext=nil then
        exit; // ancestor not found -> probably syntax error

      for i:=0 to ListOfPFindContext.Count-1 do begin
        Context:=PFindContext(ListOfPFindContext[i]);
        Ancestor:=UpperCase(Context^.Tool.ExtractClassName(Context^.Node,false));
        if (Ancestor='TFORM') then begin
          AnUnitInfo.ResourceBaseClass:=pfcbcForm;
          Result:=true;
          Break;
        end else if (Ancestor='TCUSTOMFORM') then begin
          AnUnitInfo.ResourceBaseClass:=pfcbcCustomForm;
          Result:=true;
          Break;
        end else if Ancestor='TDATAMODULE' then begin
          AnUnitInfo.ResourceBaseClass:=pfcbcDataModule;
          Result:=true;
          Break;
        end else if (Ancestor='TFRAME') or (Ancestor='TCUSTOMFRAME') then begin
          AnUnitInfo.ResourceBaseClass:=pfcbcFrame;
          Result:=true;
          Break;
        end else if Ancestor='TCOMPONENT' then begin
          Result:=true;
          Break;
        end;
      end;
    except
      exit; // syntax error or unit not found
    end;
    if not Result then exit;

    // Maybe auto-create it
    //   (pfMainUnitHasCreateFormStatements in Project1.Flags)
    //   and Project1.AutoCreateForms are checked by caller.
    if (AnUnitInfo.ResourceBaseClass in [pfcbcForm,pfcbcCustomForm,pfcbcDataModule])
    and (LFMComponentName<>'')
    and (IDEMessageDialog(lisAddToStartupComponents,
                          Format(lisShouldTheComponentBeAutoCreatedWhenTheApplicationS,
                                 [LFMComponentName]),
                          mtInformation,[mbYes,mbNo])=mrYes)
    then
      Project1.AddCreateFormToProjectFile(LFMClassName,LFMComponentName);
  finally
    FreeListOfPFindContext(ListOfPFindContext);
  end;
end;


{ TProjectInspectorForm }

// inline
function TProjectInspectorForm.IsUpdateLocked: boolean;
begin
  Result:=FUpdateLock>0;
end;

function TProjectInspectorForm.TVNodeFiles: TTreeNode;
begin
  Result:=FFilesNode;
end;

function TProjectInspectorForm.TVNodeRequiredPackages: TTreeNode;
begin
  Result:=FDependenciesNode;
end;

procedure TProjectInspectorForm.ItemsTreeViewDblClick(Sender: TObject);
begin
  OpenButtonClick(Self);
end;

procedure TProjectInspectorForm.ItemsTreeViewDragDrop(Sender, Source: TObject;
  X, Y: Integer);
begin
  OnDragDropTreeView(Sender,Source,X,Y);
end;

procedure TProjectInspectorForm.ItemsTreeViewDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  TargetTVNode: TTreeNode;
  TargetTVType: TTreeViewInsertMarkType;
begin
  if not OnDragOverTreeView(Sender,Source,X,Y, TargetTVNode, TargetTVType) then
  begin
    ItemsTreeView.SetInsertMark(nil,tvimNone);
    Accept:=false;
    exit;
  end;

  if State=dsDragLeave then
    ItemsTreeView.SetInsertMark(nil,tvimNone)
  else
    ItemsTreeView.SetInsertMark(TargetTVNode,TargetTVType);
  Accept:=true;
end;

procedure TProjectInspectorForm.ItemsTreeViewKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  Handled: Boolean;
begin
  Handled := True;
  try
    if Key = VK_ESCAPE then
      Close
    else if Key = VK_RETURN then
      OpenButtonClick(Nil)
    else if Key = VK_DELETE then
      RemoveBitBtnClick(Nil)
    else if Key = VK_INSERT then
      AddMenuItemClick(Nil)
    else
      Handled := False;
  finally
    if Handled then
      Key := VK_UNKNOWN;
  end;
end;

procedure TProjectInspectorForm.ItemsTreeViewSelectionChanged(Sender: TObject);
begin
  UpdateProperties;
  UpdateButtons;
end;

procedure TProjectInspectorForm.mnuAddDiskFileClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  ADirectory, NewFilename: String;
  i: Integer;
begin
  OpenDialog:=IDEOpenDialogClass.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(OpenDialog);
    ADirectory:=LazProject.Directory;
    if not FilenameIsAbsolute(ADirectory) then
      ADirectory:='';
    if ADirectory<>'' then
      OpenDialog.InitialDir:=ADirectory;
    OpenDialog.Title:=lisOpenFile;
    OpenDialog.Options:=OpenDialog.Options
                          +[ofFileMustExist,ofPathMustExist,ofAllowMultiSelect];
    OpenDialog.Filter:=dlgFilterAll+' ('+GetAllFilesMask+')|'+GetAllFilesMask
                 +'|'+dlgFilterLazarusUnit+' (*.pas;*.pp)|*.pas;*.pp'
                 +'|'+dlgFilterLazarusInclude+' (*.inc)|*.inc'
                 +'|'+dlgFilterLazarusForm+' (*.lfm;*.dfm)|*.lfm;*.dfm';
    if OpenDialog.Execute then
    begin
      InputHistories.StoreFileDialogSettings(OpenDialog);
      for i:=0 to OpenDialog.Files.Count-1 do
      begin
        NewFilename := OpenDialog.Files[i];
        case TPrjFileCheck.AddingFile(LazProject, NewFilename) of
          mrOk: if not (AddOneFile(NewFilename) in [mrOk, mrIgnore]) then
                  break;
          mrIgnore: continue;
          mrCancel: exit;
        end;
      end;
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure TProjectInspectorForm.mnuAddEditorFilesClick(Sender: TObject);
begin
  DoAddMoreDialog;
end;

procedure TProjectInspectorForm.mnuAddFPMakeReqClick(Sender: TObject);
begin
  DoAddFPMakeDepDialog;
end;

procedure TProjectInspectorForm.mnuAddReqClick(Sender: TObject);
begin
  DoAddDepDialog;
end;

procedure TProjectInspectorForm.mnuOpenFolderClick(Sender: TObject);
begin
  OpenDocument(LazProject.Directory);
end;

procedure TProjectInspectorForm.MoveDependencyUpClick(Sender: TObject);
var
  Dependency: TPkgDependency;
begin
  Dependency:=GetSingleSelectedDependency;
  if SortAlphabetically or (Dependency=nil) or Dependency.Removed
  or (Dependency.PrevRequiresDependency=nil) then exit;
  LazProject.MoveRequiredDependencyUp(Dependency);
end;

procedure TProjectInspectorForm.MoveDependencyDownClick(Sender: TObject);
var
  Dependency: TPkgDependency;
begin
  Dependency:=GetSingleSelectedDependency;
  if SortAlphabetically or (Dependency=nil) or Dependency.Removed
  or (Dependency.NextRequiresDependency=nil) then exit;
  LazProject.MoveRequiredDependencyDown(Dependency);
end;

procedure TProjectInspectorForm.SetDependencyDefaultFilenameMenuItemClick(Sender: TObject);
begin
  SetDependencyDefaultFilename(false);
end;

procedure TProjectInspectorForm.SetDependencyPreferredFilenameMenuItemClick(Sender: TObject);
begin
  SetDependencyDefaultFilename(true);
end;

procedure TProjectInspectorForm.ClearDependencyFilenameMenuItemClick(Sender: TObject);
var
  CurDependency: TPkgDependency;
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
begin
  BeginUpdate;
  try
    for i:=0 to ItemsTreeView.SelectionCount-1 do begin
      TVNode:=ItemsTreeView.Selections[i];
      if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
      if not (Item is TPkgDependency) then continue;
      CurDependency:=TPkgDependency(Item);
      if CurDependency.DefaultFilename='' then exit;
      CurDependency.DefaultFilename:='';
      CurDependency.PreferDefaultFilename:=false;
      LazProject.Modified:=true;
      UpdateRequiredPackages;
    end;
  finally
    EndUpdate;
  end;
end;

function TProjectInspectorForm.AddOneFile(aFilename: string): TModalResult;
var
  NewUnit: TUnitInfo;
begin
  Result := mrOK;
  NewUnit:=LazProject.UnitInfoWithFilename(aFilename);
  if NewUnit<>nil then begin
    if NewUnit.IsPartOfProject then Exit(mrIgnore);
  end else begin
    NewUnit:=TUnitInfo.Create(nil);
    NewUnit.Filename:=aFilename;
    if LazProject.AutoCreateForms and FilenameIsPascalUnit(NewUnit.Filename)
    and (pfMainUnitHasCreateFormStatements in LazProject.Flags) then
      UpdateUnitInfoResourceBaseClass(NewUnit, true);
    LazProject.AddFile(NewUnit,false);
  end;
  if Assigned(OnAddUnitToProject) then begin
    Result:=OnAddUnitToProject(Self,NewUnit);
    if Result<>mrOK then Exit;
  end;
  FNextSelectedPart:=NewUnit;
end;

procedure TProjectInspectorForm.AddMenuItemClick(Sender: TObject);
begin
  //check the selected item in ItemsTreeView
  // -> if it's "Required Packages", call "New Requirement" (mnuAddReqClick)
  // -> otherwise (selected = "Files") call "Add files from file system" (AddBitBtnClick)
  if NodeTreeIsIn(ItemsTreeView.Selected, FDependenciesNode) then
    mnuAddReqClick(Sender)
  else
    mnuAddDiskFileClick(Sender);
end;

procedure TProjectInspectorForm.DoAddMoreDialog;
var
  Files: TStringList;
  i: Integer;
begin
  Files:=TStringList.Create;
  try
    if ShowAddToProjectDlg(LazProject,Files)<>mrOk then
      exit;
    BeginUpdate;
    for i:=0 to Files.Count-1 do
      if not (AddOneFile(Files[i]) in [mrOk, mrIgnore]) then break;
    UpdateAll;
    EndUpdate;
  finally
    Files.Free;
  end;
end;

procedure TProjectInspectorForm.DoAddDepDialog;
var
  Deps: TPkgDependencyList;
  i: Integer;
  Resu: TModalResult;
begin
  Resu:=ShowAddPkgDependencyDlg(LazProject, Deps);
  try
    if (Resu<>mrOK) or (Deps.Count=0) or (OnAddDependency=nil) then exit;
    try
      BeginUpdate;
      for i := 0 to Deps.Count-1 do
        OnAddDependency(Self, Deps[i]);
      FNextSelectedPart:=Deps[Deps.Count-1];
      UpdateRequiredPackages;
    finally
      EndUpdate;
    end;
  finally
    Deps.Free;
  end;
end;

procedure TProjectInspectorForm.DoAddFPMakeDepDialog;
var
  Deps: TPkgDependencyList;
  i: Integer;
  Resu: TModalResult;
begin
  Resu:=ShowAddFPMakeDependencyDlg(LazProject, Deps);
  try
    if (Resu<>mrOK) or (Deps.Count=0) then exit;
    try
      BeginUpdate;
      for i := 0 to Deps.Count-1 do
        OnAddDependency(Self, Deps[i]);
      FNextSelectedPart:=Deps[Deps.Count-1];
    finally
      EndUpdate;
    end;
  finally
    Deps.Free;
  end;
end;

procedure TProjectInspectorForm.CopyMoveToDirMenuItemClick(Sender: TObject);
begin
  OnCopyMoveFiles(Self);
end;

procedure TProjectInspectorForm.DirectoryHierarchyButtonClick(Sender: TObject);
begin
  ShowDirectoryHierarchy:=DirectoryHierarchyButton.Down;
end;

procedure TProjectInspectorForm.FilterEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    OpenButtonClick(Nil);
    Key := VK_UNKNOWN;
  end;
end;

procedure TProjectInspectorForm.FormCreate(Sender: TObject);
begin
  if LazarusIDE.IDEStarted and (LazProject=nil) then
  begin   // User opens this window for the very first time. Set active project.
    LazProject := Project1;
    UpdateAll;
  end;
  if OPMInterface <> nil then
    OPMInterface.AddPackageListNotification(@PackageListAvailable);
end;

procedure TProjectInspectorForm.FormDestroy(Sender: TObject);
begin
  if OPMInterface <> nil then
    OPMInterface.RemovePackageListNotification(@PackageListAvailable);
end;

procedure TProjectInspectorForm.FormActivate(Sender: TObject);
begin
  //DebugLn('* TProjectInspectorForm.FormActivate *');
  ItemsTreeView.OnSelectionChanged := @ItemsTreeViewSelectionChanged;
end;

procedure TProjectInspectorForm.FormDeactivate(Sender: TObject);
begin
  // Prevent calling handler when the tree gets updated with a project.
  ItemsTreeView.OnSelectionChanged := Nil;
end;

procedure TProjectInspectorForm.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var
  i: Integer;
begin
  {$IFDEF VerboseProjInspDrag}
  debugln(['TProjectInspectorForm.FormDropFiles ',length(FileNames)]);
  {$ENDIF}
  if length(FileNames)=0 then exit;
  BeginUpdate;
  try
    for i:=0 to high(Filenames) do
      if not (AddOneFile(FileNames[i]) in [mrOk, mrIgnore]) then break;
    UpdateAll;
  finally
    EndUpdate;
  end;
end;

procedure TProjectInspectorForm.ItemsPopupMenuPopup(Sender: TObject);
var
  ItemCnt: integer;

  function AddPopupMenuItem(const ACaption: string; AnEvent: TNotifyEvent;
    EnabledFlag: boolean = True): TMenuItem;
  begin
    if ItemsPopupMenu.Items.Count<=ItemCnt then begin
      Result:=TMenuItem.Create(Self);
      ItemsPopupMenu.Items.Add(Result);
    end else
      Result:=ItemsPopupMenu.Items[ItemCnt];
    Result.Caption:=ACaption;
    Result.OnClick:=AnEvent;
    Result.Enabled:=EnabledFlag;
    Result.Checked:=false;
    Result.ShowAlwaysCheckable:=false;
    Result.Visible:=true;
    Result.RadioItem:=false;
    Result.ImageIndex:=-1;
    inc(ItemCnt);
  end;

var
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
  CanRemoveCount: Integer;
  CanOpenCount: Integer;
  HasLFMCount: Integer;
  CurUnitInfo: TUnitInfo;
  DisabledI18NForLFMCount: Integer;
  CanReAddCount: Integer;
  SingleSelectedDep: TPkgDependency;
  DepCount: Integer;
  Dependency: TPkgDependency;
  HasValidDep: Integer;
  CanClearDep: Integer;
  CanMoveFileCount: Integer;
  OpenItemCapt: String;
begin
  ItemCnt:=0;

  CanRemoveCount:=0;
  CanOpenCount:=0;
  CanMoveFileCount:=0;
  HasLFMCount:=0;
  DisabledI18NForLFMCount:=0;
  CanReAddCount:=0;
  SingleSelectedDep:=nil;
  DepCount:=0;
  HasValidDep:=0;
  CanClearDep:=0;
  for i:=0 to ItemsTreeView.SelectionCount-1 do begin
    TVNode:=ItemsTreeView.Selections[i];
    if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
    if Item is TUnitInfo then begin
      CurUnitInfo:=TUnitInfo(Item);
      inc(CanOpenCount);
      if (CurUnitInfo<>LazProject.MainUnitInfo) and (not NodeData.Removed) then begin
        inc(CanRemoveCount);
        inc(CanMoveFileCount);
      end;
      if FilenameIsPascalSource(CurUnitInfo.Filename)
      and FileExistsCached(ChangeFileExt(CurUnitInfo.Filename,'.lfm')) then begin
        inc(HasLFMCount);
        if CurUnitInfo.DisableI18NForLFM then
          inc(DisabledI18NForLFMCount);
      end;
    end else if Item is TPkgDependency then begin
      Dependency:=TPkgDependency(Item);
      if NodeData.Removed then begin
        inc(CanReAddCount);
      end else begin
        inc(DepCount);
        if DepCount=1 then
          SingleSelectedDep:=Dependency
        else
          SingleSelectedDep:=nil;
        inc(CanRemoveCount);
        if Dependency.DependencyType=pdtLazarus then
          inc(CanOpenCount);
        if Dependency.RequiredPackage<>nil then
          inc(HasValidDep);
        if (Dependency.DefaultFilename<>'') then
          inc(CanClearDep);
      end;
    end;
  end;

  if ItemsTreeView.Selected = FFilesNode then
  begin
    // Only the Files node is selected.
    Assert(AddBitBtn.Enabled, 'AddBitBtn not Enabled');
    AddPopupMenuItem(lisBtnDlgAdd, @mnuAddDiskFileClick);
    if not LazProject.IsVirtual then
      AddPopupMenuItem(lisRemoveNonExistingFiles,@RemoveNonExistingFilesMenuItemClick);
    AddPopupMenuItem(cLineCaption, Nil, False);                // Separator
    AddPopupMenuItem(lisMenuOpenFolder, @mnuOpenFolderClick);
  end
  else if ItemsTreeView.Selected = FDependenciesNode then
  begin
    // Only the Required Packages node is selected.
    AddPopupMenuItem(lisBtnDlgAdd, @mnuAddReqClick);
  end
  else begin
    // Files, dependencies or everything mixed is selected.
    if CanOpenCount>0 then begin
      OpenItemCapt := lisOpen;
      if Assigned(SingleSelectedDep) then
        case SingleSelectedDep.LoadPackageResult of
          lprAvailableOnline:
            OpenItemCapt:=lisPckEditInstall;
          lprNotFound:
            if Assigned(OPMInterface) and not OPMInterface.IsPackageListLoaded then
              OpenItemCapt:=lisPckEditCheckAvailabilityOnline;
        end;
      AddPopupMenuItem(OpenItemCapt, @OpenButtonClick);
    end;
    if CanRemoveCount>0 then
      AddPopupMenuItem(lisRemove, @RemoveBitBtnClick);
    // files section
    if CanMoveFileCount>0 then
      AddPopupMenuItem(lisCopyMoveFileToDirectory,@CopyMoveToDirMenuItemClick);
  end;

  if LazProject.EnableI18N and LazProject.EnableI18NForLFM
  and (HasLFMCount>0) then begin
    AddPopupMenuItem(lisEnableI18NForLFM,
      @EnableI18NForLFMMenuItemClick, DisabledI18NForLFMCount>0);
    AddPopupMenuItem(lisDisableI18NForLFM,
      @DisableI18NForLFMMenuItemClick, DisabledI18NForLFMCount<HasLFMCount);
  end;

  // Required packages section
  if CanReAddCount>0 then
    AddPopupMenuItem(lisPckEditReAddDependency, @ReAddMenuItemClick, true);
  if SingleSelectedDep<>nil then begin
    AddPopupMenuItem(lisPckEditMoveDependencyUp, @MoveDependencyUpClick,
                     (SingleSelectedDep.PrevRequiresDependency<>nil));
    AddPopupMenuItem(lisPckEditMoveDependencyDown, @MoveDependencyDownClick,
                     (SingleSelectedDep.NextRequiresDependency<>nil));
  end;
  if HasValidDep>0 then begin
    AddPopupMenuItem(lisPckEditStoreFileNameAsDefaultForThisDependency,
                     @SetDependencyDefaultFilenameMenuItemClick, true);
    AddPopupMenuItem(lisPckEditStoreFileNameAsPreferredForThisDependency,
                     @SetDependencyPreferredFilenameMenuItemClick, true);
  end;
  if CanClearDep>0 then begin
    AddPopupMenuItem(lisPckEditClearDefaultPreferredFilenameOfDependency,
                     @ClearDependencyFilenameMenuItemClick, true);
  end;

  while ItemsPopupMenu.Items.Count>ItemCnt do
    ItemsPopupMenu.Items.Delete(ItemsPopupMenu.Items.Count-1);
end;

procedure TProjectInspectorForm.ItemsTreeViewAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  NodeData: TPENodeData;
  r: TRect;
  y: Integer;
begin
  if Stage=cdPostPaint then begin
    NodeData:=GetNodeData(Node);
    if (NodeData<>nil) then begin
      if  (NodeData.Typ=penFile) and (not NodeData.Removed)
      and FilenameIsAbsolute(NodeData.Name)
      and (not FileExistsCached(NodeData.Name))
      then begin
        r:=Node.DisplayRect(true);
        ItemsTreeView.Canvas.Pen.Color:=clRed;
        y:=(r.Top+r.Bottom) div 2;
        ItemsTreeView.Canvas.Line(r.Left,y,r.Right,y);
      end;
    end;
  end;
end;

procedure TProjectInspectorForm.OpenButtonClick(Sender: TObject);
var
  i: Integer;
  NodeData: TPENodeData;
  Item: TObject;
begin
  for i:=0 to ItemsTreeView.SelectionCount-1 do
  begin
    if GetNodeDataItem(ItemsTreeView.Selections[i], NodeData, Item) then
    begin
      if Item is TUnitInfo then
      begin
        if LazarusIDE.DoOpenEditorFile(TUnitInfo(Item).Filename,
                                       -1,-1,[ofAddToRecent]) <> mrOk then
          Exit;
      end
      else if Item is TPkgDependency then
        if not OpmAddOrOpenDependency(TPkgDependency(Item)) then
          Exit;
    end;
  end;
  OpmInstallPendingDependencies;
end;

procedure TProjectInspectorForm.OptionsBitBtnClick(Sender: TObject);
begin
  MainIDEBar.itmProjectOptions.DoOnClick;
end;

procedure TProjectInspectorForm.HelpBitBtnClick(Sender: TObject);
begin
  LazarusHelp.ShowHelpForIDEControl(Self);
end;

procedure TProjectInspectorForm.ReAddMenuItemClick(Sender: TObject);
var
  Dependency: TPkgDependency;
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
begin
  BeginUpdate;
  try
    for i:=0 to ItemsTreeView.SelectionCount-1 do begin
      TVNode:=ItemsTreeView.Selections[i];
      if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
      if not NodeData.Removed then continue;
      if not (Item is TPkgDependency) then continue;
      Dependency:=TPkgDependency(Item);
      if TPrjFileCheck.AddingDependency(LazProject,Dependency)<>mrOK then exit;
      if Assigned(OnReAddDependency) then
        OnReAddDependency(Self,Dependency);
    end;
  finally
    EndUpdate;
  end;
end;

procedure TProjectInspectorForm.RemoveBitBtnClick(Sender: TObject);
var
  CurDependency: TPkgDependency;
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
  Msg, Cap: String;
  DeleteCount: Integer;
  CurFile: TUnitInfo;
begin
  BeginUpdate;
  try
    // check selection
    Msg:='';
    DeleteCount:=0;
    for i:=0 to ItemsTreeView.SelectionCount-1 do begin
      TVNode:=ItemsTreeView.Selections[i];
      if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
      if Item is TUnitInfo then begin
        CurFile:=TUnitInfo(Item);
        if CurFile=LazProject.MainUnitInfo then continue;
        // remove file
        inc(DeleteCount);
        Msg:=Format(lisProjInspRemoveFileFromProject, [CurFile.Filename]);
      end else if Item is TPkgDependency then begin
        CurDependency:=TPkgDependency(item);
        if NodeData.Removed then continue;
        // remove dependency
        inc(DeleteCount);
        Msg:=Format(lisProjInspDeleteDependencyFor, [CurDependency.AsString]);
      end;
    end;

    // ask for confirmation
    if DeleteCount=0 then exit;
    if DeleteCount>1 then
      Msg:=Format(lisProjInspRemoveItemsF, [IntToStr(DeleteCount)]);
    if CurFile<>nil then
      Cap:=lisProjInspConfirmRemovingFile
    else
      Cap:=lisProjInspConfirmDeletingDependency;
    if IDEMessageDialog(Cap,
      Msg, mtConfirmation,[mbYes,mbNo])<>mrYes then exit;

    // delete
    for i:=0 to ItemsTreeView.SelectionCount-1 do begin
      TVNode:=ItemsTreeView.Selections[i];
      if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
      if Item is TUnitInfo then begin
        CurFile:=TUnitInfo(Item);
        if CurFile=LazProject.MainUnitInfo then continue;
        // remove file
        if Assigned(OnRemoveFile) then OnRemoveFile(Self,CurFile);
      end else if Item is TPkgDependency then begin
        CurDependency:=TPkgDependency(item);
        if NodeData.Removed then continue;
        // remove dependency
        if Assigned(OnRemoveDependency) then
          OnRemoveDependency(Self,CurDependency);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TProjectInspectorForm.RemoveNonExistingFilesMenuItemClick(Sender: TObject);
var
  AnUnitInfo: TUnitInfo;
  NextUnitInfo: TUnitInfo;
  HasChanged: Boolean;
begin
  if LazProject.IsVirtual then exit;
  BeginUpdate;
  try
    HasChanged:=false;
    AnUnitInfo:=LazProject.FirstPartOfProject;
    while AnUnitInfo<>nil do begin
      NextUnitInfo:=AnUnitInfo.NextPartOfProject;
      if not (AnUnitInfo.IsVirtual or FileExistsUTF8(AnUnitInfo.Filename)) then begin
        AnUnitInfo.IsPartOfProject:=false;
        HasChanged:=true;
      end;
      AnUnitInfo:=NextUnitInfo;
    end;
    if HasChanged then begin
      LazProject.Modified:=true;
      UpdateFiles;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TProjectInspectorForm.SortAlphabeticallyButtonClick(Sender: TObject);
begin
  SortAlphabetically:=SortAlphabeticallyButton.Down;
end;

procedure TProjectInspectorForm.EnableI18NForLFMMenuItemClick(Sender: TObject);
begin
  EnableI18NForSelectedLFM(true);
end;

procedure TProjectInspectorForm.DisableI18NForLFMMenuItemClick(Sender: TObject);
begin
  EnableI18NForSelectedLFM(false);
end;

procedure TProjectInspectorForm.SetLazProject(const AValue: TProject);
begin
  if FLazProject=AValue then exit;
  if FLazProject<>nil then begin       // Old Project
    dec(FUpdateLock,LazProject.UpdateLock);
    FLazProject.OnBeginUpdate:=nil;
    FLazProject.OnEndUpdate:=nil;
  end;
  FLazProject:=AValue;
  if FLazProject<>nil then begin       // New Project
    inc(FUpdateLock,LazProject.UpdateLock);
    FLazProject.OnBeginUpdate:=@ProjectBeginUpdate;
    FLazProject.OnEndUpdate:=@ProjectEndUpdate;
  end
  else // Only update when no project. ProjectEndUpdate will update a project.
    UpdateAll;
end;

procedure TProjectInspectorForm.SetShowDirectoryHierarchy(const AValue: boolean);
begin
  if FShowDirectoryHierarchy=AValue then exit;
  FShowDirectoryHierarchy:=AValue;
  DirectoryHierarchyButton.Down:=FShowDirectoryHierarchy;
  FilterEdit.ShowDirHierarchy:=FShowDirectoryHierarchy;
  FilterEdit.InvalidateFilter;
  EnvironmentOptions.ProjInspShowDirHierarchy := ShowDirectoryHierarchy;
end;

procedure TProjectInspectorForm.SetSortAlphabetically(const AValue: boolean);
begin
  if FSortAlphabetically=AValue then exit;
  FSortAlphabetically:=AValue;
  SortAlphabeticallyButton.Down:=FSortAlphabetically;
  FilterEdit.SortData:=FSortAlphabetically;
  FilterEdit.InvalidateFilter;
  EnvironmentOptions.ProjInspSortAlphabetically := SortAlphabetically;
end;

procedure TProjectInspectorForm.SetDependencyDefaultFilename(AsPreferred: boolean);
var
  NewFilename: String;
  CurDependency: TPkgDependency;
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
begin
  BeginUpdate;
  try
    for i:=0 to ItemsTreeView.SelectionCount-1 do begin
      TVNode:=ItemsTreeView.Selections[i];
      if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
      if NodeData.Removed then continue;
      if not (Item is TPkgDependency) then continue;
      CurDependency:=TPkgDependency(Item);
      if CurDependency.RequiredPackage=nil then continue;
      NewFilename:=CurDependency.RequiredPackage.Filename;
      if (NewFilename=CurDependency.DefaultFilename) // do not use CompareFilenames
      and (CurDependency.PreferDefaultFilename=AsPreferred) then continue;
      CurDependency.DefaultFilename:=NewFilename;
      CurDependency.PreferDefaultFilename:=AsPreferred;
      LazProject.Modified:=true;
      UpdateRequiredPackages;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TProjectInspectorForm.SetIdleConnected(AValue: boolean);
begin
  if csDestroying in ComponentState then
    AValue:=false;
  if FIdleConnected=AValue then exit;
  FIdleConnected:=AValue;
  if FIdleConnected then
    Application.AddOnIdleHandler(@IdleHandler)
  else
    Application.RemoveOnIdleHandler(@IdleHandler);
end;

function TProjectInspectorForm.GetDependencyToUpdate(Immediately: boolean): TPkgDependencyID;
begin
  if CanUpdate(pefNeedUpdateApplyDependencyButton,Immediately) then
    Result:=GetSingleSelectedDependency
  else
    Result:=nil;
end;

procedure TProjectInspectorForm.ApplyDependencyButtonClick(Sender: TObject);
var
  CurDependency: TPkgDependency;
begin
  CurDependency:=GetSingleSelectedDependency;
  if (LazProject=nil) or (CurDependency=nil)
  or not FPropGui.CheckApplyDependency(CurDependency) then exit;
  LazProject.Modified:=True;
  PkgBoss.ApplyDependency(CurDependency);
end;

function TProjectInspectorForm.CreateToolButton(AName, ACaption, AHint, AImageName: String;
  AOnClick: TNotifyEvent): TToolButton;
begin
  Result := TToolButton.Create(Self);
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Hint := AHint;
  if AImageName <> '' then
    Result.ImageIndex := IDEImages.LoadImage(AImageName);
  Result.ShowHint := True;
  Result.OnClick := AOnClick;
  Result.AutoSize := True;
  Result.Parent := ToolBar;
end;

function TProjectInspectorForm.CreateDivider: TToolButton;
begin
  Result := TToolButton.Create(Self);
  Result.Style := tbsDivider;
  Result.AutoSize := True;
  Result.Parent := ToolBar;
end;

procedure TProjectInspectorForm.SetupComponents;
begin
  ImageIndexFiles           := IDEImages.LoadImage('pkg_files');
  ImageIndexProject         := IDEImages.LoadImage('item_project_source');
  ImageIndexUnit            := IDEImages.LoadImage('item_unit');
  ImageIndexRegisterUnit    := IDEImages.LoadImage('pkg_registerunit');
  ImageIndexText            := IDEImages.LoadImage('pkg_text');
  ImageIndexBinary          := IDEImages.LoadImage('pkg_binary');
  ImageIndexDirectory       := IDEImages.LoadImage('pkg_files');

  ItemsTreeView.Images      := IDEImages.Images_16;
  ToolBar.Images            := IDEImages.Images_16;
  FilterEdit.OnGetImageIndex:=@TreeViewGetImageIndex;

  AddBitBtn     := CreateToolButton('AddBitBtn', lisAdd, lisClickToSeeTheChoices, 'laz_add', nil);
  AddBitBtn.Style:=tbsButtonDrop;
  RemoveBitBtn  := CreateToolButton('RemoveBitBtn', lisRemove, lisPckEditRemoveSelectedItem, 'laz_delete', @RemoveBitBtnClick);
  CreateDivider;
  OptionsBitBtn := CreateToolButton('OptionsBitBtn', lisOptions, lisPckEditEditGeneralOptions, 'menu_environment_options', @OptionsBitBtnClick);
  OptionsBitBtn.DropdownMenu := TSetBuildModeToolButton.TBuildModeMenu.Create(Self);
  OptionsBitBtn.Style := tbsDropDown;
  HelpBitBtn    := CreateToolButton('HelpBitBtn', GetButtonCaption(idButtonHelp), lisMenuOnlineHelp, 'btn_help', @HelpBitBtnClick);

  AddBitBtn.DropdownMenu:=AddPopupMenu;
  mnuAddDiskFile.Caption:=lisPckEditAddFilesFromFileSystem;
  mnuAddEditorFiles.Caption:=lisProjAddEditorFile;
  mnuAddReq.Caption:=lisProjAddNewRequirement;
  mnuAddFPMakeReq.Caption:=lisProjAddNewFPMakeRequirement;

  IDEImages.AssignImage(OpenButton, 'laz_open');
  OpenButton.Caption:='';
  OpenButton.Hint:=lisOpenFile2;
  SortAlphabeticallyButton.Hint:=lisPESortFilesAlphabetically;
  IDEImages.AssignImage(SortAlphabeticallyButton, 'pkg_sortalphabetically');
  DirectoryHierarchyButton.Hint:=lisPEShowDirectoryHierarchy;
  IDEImages.AssignImage(DirectoryHierarchyButton, 'pkg_hierarchical');

  FPropGui.OnGetPkgDep := @GetDependencyToUpdate;
  FPropGui.ApplyDependencyButton.OnClick := @ApplyDependencyButtonClick;

  with ItemsTreeView do begin
    FFilesNode:=Items.Add(nil, dlgEnvFiles);
    FFilesNode.ImageIndex:=ImageIndexFiles;
    FFilesNode.SelectedIndex:=FFilesNode.ImageIndex;
    FDependenciesNode:=Items.Add(nil, lisPckEditRequiredPackages);
    FDependenciesNode.ImageIndex:=FPropGui.ImageIndexRequired;
    FDependenciesNode.SelectedIndex:=FDependenciesNode.ImageIndex;
  end;
end;

function TProjectInspectorForm.TreeViewGetImageIndex(Str: String; Data: TObject;
                                                var AIsEnabled: Boolean): Integer;
var
  NodeData: TPENodeData;
  Item: TObject;
begin
  Result := -1;
  if not (Data is TPENodeData) then exit;
  NodeData:=TPENodeData(Data);
  Item:=GetNodeItem(NodeData);
  if Item=nil then exit;
  if Item is TUnitInfo then begin
    if FilenameHasPascalExt(TUnitInfo(Item).Filename) then
      Result:=ImageIndexUnit
    else if (LazProject<>nil) and (LazProject.MainUnitinfo=Item) then
      Result:=ImageIndexProject
    else
      Result:=ImageIndexText;
  end
  else if Item is TPkgDependency then
    Result:=FPropGui.GetDependencyImageIndex(TPkgDependency(Item));
end;

procedure TProjectInspectorForm.UpdateFiles(Immediately: boolean);
var
  CurFile: TUnitInfo;
  FilesBranch: TTreeFilterBranch;
  Filename: String;
  ANodeData : TPENodeData;
begin
  if not CanUpdate(pefNeedUpdateFiles,Immediately) then exit;
  FilesBranch:=FilterEdit.GetCleanBranch(FFilesNode);
  FilesBranch.ClearNodeData;
  FPropGui.FreeNodeData(penFile);
  if LazProject<>nil then begin
    FilterEdit.SelectedPart:=FNextSelectedPart;
    FilterEdit.ShowDirHierarchy:=ShowDirectoryHierarchy;
    FilterEdit.SortData:=SortAlphabetically;
    FilterEdit.ImageIndexDirectory:=ImageIndexDirectory;
    // collect and sort files
    CurFile:=LazProject.FirstPartOfProject;
    while CurFile<>nil do begin
      Filename:=CurFile.GetShortFilename(true);
      if Filename<>'' then Begin
        ANodeData:=FPropGui.CreateNodeData(penFile, CurFile.Filename, False);
        FilesBranch.AddNodeData(Filename, ANodeData, CurFile.Filename);
      end;
      CurFile:=CurFile.NextPartOfProject;
    end;
  end;
  FilterEdit.InvalidateFilter;            // Data is shown by FilterEdit.
  UpdateProperties;
  UpdateButtons;
end;

procedure TProjectInspectorForm.UpdateRequiredPackages(Immediately: boolean);
var
  Dependency: TPkgDependency;
  RequiredBranch, RemovedBranch: TTreeFilterBranch;
  ANodeData : TPENodeData;
begin
  if not CanUpdate(pefNeedUpdateRequiredPkgs,Immediately) then exit;
  RequiredBranch:=FilterEdit.GetCleanBranch(FDependenciesNode);
  RequiredBranch.ClearNodeData;
  FPropGui.FreeNodeData(penDependency);
  Dependency:=Nil;
  if LazProject<>nil then begin
    // required packages
    Dependency:=LazProject.FirstRequiredDependency;
    while Dependency<>nil do begin
      // Add the required package under the branch
      ANodeData:=FPropGui.CreateNodeData(penDependency, Dependency.PackageName, False);
      RequiredBranch.AddNodeData(Dependency.AsString(False,True)+OPNote(Dependency), ANodeData);
      Dependency:=Dependency.NextRequiresDependency;
    end;

    // removed required packages
    Dependency:=LazProject.FirstRemovedDependency;
    if Dependency<>nil then begin
      // Create root node for removed dependencies if not done yet.
      if FRemovedDependenciesNode=nil then begin
        FRemovedDependenciesNode:=ItemsTreeView.Items.Add(FDependenciesNode,
                                                lisProjInspRemovedRequiredPackages);
        FRemovedDependenciesNode.ImageIndex:=FPropGui.ImageIndexRemovedRequired;
        FRemovedDependenciesNode.SelectedIndex:=FRemovedDependenciesNode.ImageIndex;
      end;
      RemovedBranch:=FilterEdit.GetCleanBranch(FRemovedDependenciesNode);
      // Add all removed dependencies under the branch
      while Dependency<>nil do begin
        ANodeData := FPropGui.CreateNodeData(penDependency, Dependency.PackageName, True);
        RemovedBranch.AddNodeData(Dependency.AsString, ANodeData);
        Dependency:=Dependency.NextRequiresDependency;
      end;
    end;
  end;

  // Dependency is set to removed required packages if there is active project
  if (Dependency=nil) and (FRemovedDependenciesNode<>nil) then begin
    // No removed dependencies -> delete the root node
    FilterEdit.DeleteBranch(FRemovedDependenciesNode);
    FreeThenNil(FRemovedDependenciesNode);
  end;
  FilterEdit.InvalidateFilter;
  UpdateProperties;
  UpdateButtons;
end;

procedure TProjectInspectorForm.ProjectBeginUpdate(Sender: TObject);
begin
  BeginUpdate;
end;

procedure TProjectInspectorForm.ProjectEndUpdate(Sender: TObject; ProjectChanged: boolean);
begin
  if ProjectChanged then
    UpdateAll;
  EndUpdate;
end;

procedure TProjectInspectorForm.EnableI18NForSelectedLFM(TheEnable: boolean);
var
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
  CurUnitInfo: TUnitInfo;
begin
  for i:=0 to ItemsTreeView.SelectionCount-1 do begin
    TVNode:=ItemsTreeView.Selections[i];
    if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
    if not (Item is TUnitInfo) then continue;
    CurUnitInfo:=TUnitInfo(Item);
    if not FilenameIsPascalSource(CurUnitInfo.Filename) then continue;
    CurUnitInfo.DisableI18NForLFM:=not TheEnable;
  end;
end;

procedure TProjectInspectorForm.PackageListAvailable(Sender: TObject);
begin
  //DebugLn(['TProjectInspectorForm.PackageListAvailable: ', LazProject.Title]);
  UpdateRequiredPackages;
end;

procedure TProjectInspectorForm.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  ExecuteIDEShortCut(Self,Key,Shift,nil);
end;

procedure TProjectInspectorForm.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  if fUpdateLock>0 then exit;
  IdleConnected:=false;
  UpdatePending;
end;

function TProjectInspectorForm.GetSingleSelectedDependency: TPkgDependency;
var
  Item: TObject;
  NodeData: TPENodeData;
begin
  Result:=nil;
  if not GetNodeDataItem(ItemsTreeView.Selected,NodeData,Item) then exit;
  if Item is TPkgDependency then
    Result:=TPkgDependency(Item);
end;

function TProjectInspectorForm.TreeViewToInspector(TV: TTreeView): TProjectInspectorForm;
begin
  if TV=ItemsTreeView then
    Result:=Self
  else
    Result:=nil;
end;

constructor TProjectInspectorForm.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Name:=NonModalIDEWindowNames[nmiwProjectInspector];
  Caption:=lisMenuProjectInspector;
  KeyPreview:=true;
  FPropGui:=TProjPackFilePropGui.Create(PropsGroupBox, False);
  SetupComponents;
  KeyPreview:=true;
  SortAlphabetically := EnvironmentOptions.ProjInspSortAlphabetically;
  ShowDirectoryHierarchy := EnvironmentOptions.ProjInspShowDirHierarchy;
end;

destructor TProjectInspectorForm.Destroy;
begin
  IdleConnected:=false;
  LazProject:=nil;
  inherited Destroy;
  FreeAndNil(FPropGui);
  if ProjInspector=Self then
    ProjInspector:=nil;
end;

function TProjectInspectorForm.ExtendIncSearchPath(NewIncPaths: string): boolean;
begin
  Result:=LazProject.ExtendIncSearchPath(NewIncPaths);
end;

function TProjectInspectorForm.ExtendUnitSearchPath(NewUnitPaths: string): boolean;
begin
  Result:=LazProject.ExtendUnitSearchPath(NewUnitPaths);
end;

function TProjectInspectorForm.FilesBaseDirectory: string;
begin
  if LazProject<>nil then
    Result:=LazProject.Directory
  else
    Result:='';
end;

function TProjectInspectorForm.FilesEditForm: TCustomForm;
begin
  Result:=Self;
end;

function TProjectInspectorForm.FilesEditTreeView: TTreeView;
begin
  Result:=ItemsTreeView;
end;

function TProjectInspectorForm.FilesOwner: TObject;
begin
  Result:=LazProject;
end;

function TProjectInspectorForm.FilesOwnerName: string;
begin
  Result:=lisProject3;
end;

function TProjectInspectorForm.FilesOwnerReadOnly: boolean;
begin
  Result:=false;
end;

function TProjectInspectorForm.FirstRequiredDependency: TPkgDependency;
begin
  if LazProject<>nil then
    Result:=LazProject.FirstRequiredDependency
  else
    Result:=nil;
end;

function TProjectInspectorForm.GetNodeFilename(Node: TTreeNode): string;
var
  Item: TFileNameItem;
begin
  Result:='';
  if Node=nil then exit;
  if Node=FFilesNode then
    exit(FilesBaseDirectory);
  Item:=TFileNameItem(Node.Data);
  if (Item is TFileNameItem) then begin
    Result:=Item.Filename;
  end else if Node.HasAsParent(FFilesNode) then begin
    // directory node
    Result:=Node.Text;
  end else
    exit;
  if not FilenameIsAbsolute(Result) then
    Result:=AppendPathDelim(FilesBaseDirectory)+Result;
end;

function TProjectInspectorForm.IsDirectoryNode(Node: TTreeNode): boolean;
begin
  Result:=(Node<>nil) and (Node.Data=nil) and Node.HasAsParent(FFilesNode);
end;

procedure TProjectInspectorForm.BeginUpdate;
begin
  inc(FUpdateLock);
end;

procedure TProjectInspectorForm.EndUpdate;
begin
  if FUpdateLock=0 then RaiseGDBException('TProjectInspectorForm.EndUpdate');
  dec(FUpdateLock);
  if FUpdateLock=0 then
    IdleConnected:=true;
end;

procedure TProjectInspectorForm.UpdateAll(Immediately: boolean);
begin
  if csDestroying in ComponentState then exit;
  fFlags:=fFlags+[
    pefNeedUpdateTitle,
    pefNeedUpdateFiles,
    pefNeedUpdateRequiredPkgs,
    pefNeedUpdateProperties,
    pefNeedUpdateButtons,
    pefNeedUpdateApplyDependencyButton,
    pefNeedUpdateStatusBar];
  //UpdateTitle;
  //UpdateFiles;
  //UpdateRequiredPackages;
  //UpdateButtons;
  if Immediately then
    UpdatePending
  else
    IdleConnected:=true;
end;

procedure TProjectInspectorForm.UpdateTitle(Immediately: boolean);
var
  NewCaption: String;
  IconStream: TStream;
begin
  if not CanUpdate(pefNeedUpdateTitle,Immediately) then exit;
  Icon.Clear;
  if LazProject=nil then
    Caption:=lisMenuProjectInspector
  else begin
    NewCaption:=LazProject.GetTitle;
    if NewCaption='' then
      NewCaption:=ExtractFilenameOnly(LazProject.ProjectInfoFile);
    NewCaption:=Format(lisProjInspProjectInspector, [NewCaption]);
    if (LazProject.ActiveBuildMode.GetCaption<>'') then
      NewCaption := NewCaption + ' ['+LazProject.ActiveBuildMode.GetCaption+']';
    Caption := NewCaption;

    if not LazProject.ProjResources.ProjectIcon.IsEmpty then
    begin
      IconStream := LazProject.ProjResources.ProjectIcon.GetStream;
      if IconStream<>nil then
        try
          Icon.LoadFromStream(IconStream);
        finally
          IconStream.Free;
        end;
    end;
  end;
end;

procedure TProjectInspectorForm.UpdateProperties(Immediately: boolean);
var
  CurDependency, SingleSelectedDep: TPkgDependency;
  TVNode, SingleSelectedDirectory: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
  i, SelFileCount, SelDepCount, SelUnitCount, SelDirCount: Integer;
  SingleSelectedRemoved: Boolean;
begin
  if not CanUpdate(pefNeedUpdateProperties,Immediately) then exit;
  //GuiToFileOptions(False);

  // check selection
  SingleSelectedDep:=nil;
  SingleSelectedDirectory:=nil;
  SingleSelectedRemoved:=false;
  SelFileCount:=0;
  SelDepCount:=0;
  SelUnitCount:=0;
  SelDirCount:=0;
  for i:=0 to ItemsTreeView.SelectionCount-1 do begin
    TVNode:=ItemsTreeView.Selections[i];
    if GetNodeDataItem(TVNode,NodeData,Item) then begin
      if Item is TUnitInfo then begin
        inc(SelFileCount);
        SingleSelectedRemoved:=NodeData.Removed;
        inc(SelUnitCount);
      end
      else if Item is TPkgDependency then begin
        inc(SelDepCount);
        CurDependency:=TPkgDependency(Item);
        SingleSelectedDep:=CurDependency;
        SingleSelectedRemoved:=NodeData.Removed;
      end;
    end else if IsDirectoryNode(TVNode) or (TVNode=FFilesNode) then begin
      inc(SelDirCount);
      SingleSelectedDirectory:=TVNode;
    end //else if TVNode=FRequiredPackagesNode then
      // DebugLn('UpdatePEProperties: Required packages selected');
  end;

  if (SelFileCount+SelDepCount+SelDirCount>1) then begin
    // it is a multi selection
    SingleSelectedDep:=nil;
    SingleSelectedDirectory:=nil;
  end;

  //OnlyFilesWithUnitsSelected:=
  //  (SelFileCount>0) and (SelDepCount=0) and (SelDirCount=0) and (SelUnitCount>0);
  //FPropGui.ControlVisible := OnlyFilesWithUnitsSelected;
  FPropGui.ControlEnabled := True; //not LazProject.ReadOnly;
  DisableAlign;
  try
    // Min/Max version of dependency (only single selection)
    FPropGui.ControlVisible := SingleSelectedDep<>nil;
    FPropGui.SetMinMaxVisibility;
    if SelFileCount>0 then begin
      PropsGroupBox.Enabled:=true;
      PropsGroupBox.Caption:=lisPckEditFileProperties;
    end
    else if SingleSelectedDep<>nil then begin
      PropsGroupBox.Enabled:=not SingleSelectedRemoved;
      PropsGroupBox.Caption:=lisPckEditDependencyProperties;
      FPropGui.SetMinMaxValues(SingleSelectedDep);
      FPropGui.UpdateApplyDependencyButton;
    end
    else if SingleSelectedDirectory<>nil then begin
      //PropsGroupBox.Enabled:=true;
      //PropsGroupBox.Caption:=lisPckEditFileProperties;
    end
    else begin
      PropsGroupBox.Enabled:=false;
      PropsGroupBox.Caption:=lisPckEditDependencyProperties;
    end;
  finally
    EnableAlign;
  end;
end;

procedure TProjectInspectorForm.UpdateButtons(Immediately: boolean);
var
  i: Integer;
  TVNode: TTreeNode;
  NodeData: TPENodeData;
  Item: TObject;
  CanRemoveCount: Integer;
  CurUnitInfo: TUnitInfo;
  CanOpenCount: Integer;
begin
  if not CanUpdate(pefNeedUpdateButtons,Immediately) then exit;
  CanRemoveCount:=0;
  CanOpenCount:=0;
  if Assigned(LazProject) then
  begin
    for i:=0 to ItemsTreeView.SelectionCount-1 do begin
      TVNode:=ItemsTreeView.Selections[i];
      if not GetNodeDataItem(TVNode,NodeData,Item) then continue;
      if Item is TUnitInfo then begin
        CurUnitInfo:=TUnitInfo(Item);
        inc(CanOpenCount);
        if CurUnitInfo<>LazProject.MainUnitInfo then
          inc(CanRemoveCount);
      end else if Item is TPkgDependency then begin
        if not NodeData.Removed and (TPkgDependency(Item).DependencyType=pdtLazarus) then begin
          inc(CanRemoveCount);
          inc(CanOpenCount);
        end;
      end;
    end;
  end;
  AddBitBtn.Enabled:=Assigned(LazProject);
  RemoveBitBtn.Enabled:=(CanRemoveCount>0);
  OpenButton.Enabled:=(CanOpenCount>0);
  OptionsBitBtn.Enabled:=Assigned(LazProject);
end;

procedure TProjectInspectorForm.UpdatePending;
begin
  ItemsTreeView.BeginUpdate;
  try
    if pefNeedUpdateTitle in FFlags then
      UpdateTitle(True);
    if pefNeedUpdateFiles in FFlags then
      UpdateFiles(True);
    if pefNeedUpdateRequiredPkgs in FFlags then
      UpdateRequiredPackages(True);
    if pefNeedUpdateProperties in FFlags then
      UpdateProperties(True);
    if pefNeedUpdateButtons in FFlags then
      UpdateButtons(True);
    //if pefNeedUpdateApplyDependencyButton in fFlags then
    //  FPropGui.UpdateApplyDependencyButton(true);
    IdleConnected:=false;
  finally
    ItemsTreeView.EndUpdate;
  end;
end;

function TProjectInspectorForm.CanUpdate(Flag: TPEFlag; Immediately: boolean): boolean;
begin
  Result:=false;
  if csDestroying in ComponentState then exit;
  if (FUpdateLock>0) and not Immediately then begin
    Include(fFlags,Flag);
    IdleConnected:=true;
  end else begin
    Exclude(fFlags,Flag);
    Result:=true;
  end;
end;

function TProjectInspectorForm.GetNodeItem(NodeData: TPENodeData): TObject;
begin
  Result:=nil;
  if (LazProject=nil) or (NodeData=nil) then exit;
  case NodeData.Typ of
  penFile:
    if NodeData.Removed then
      Result:=nil
    else
      Result:=LazProject.UnitInfoWithFilename(NodeData.Name,[pfsfOnlyProjectFiles]);
  penDependency:
    if NodeData.Removed then
      Result:=LazProject.FindRemovedDependencyByName(NodeData.Name)
    else
      Result:=LazProject.FindDependencyByName(NodeData.Name);
  end;
end;

function TProjectInspectorForm.GetNodeDataItem(TVNode: TTreeNode; out
  NodeData: TPENodeData; out Item: TObject): boolean;
begin
  Result:=false;
  Item:=nil;
  NodeData:=GetNodeData(TVNode);
  Item:=GetNodeItem(NodeData);
  Result:=Item<>nil;
end;

{ TSetBuildModeToolButton.TBuildModeMenu }

procedure TSetBuildModeToolButton.TBuildModeMenu.DoPopup(Sender: TObject);
var
  CurIndex: Integer;
  i: Integer;

  procedure AddMode(BuildModeIndex: Integer; CurMode: TProjectBuildMode);
  var
    AMenuItem: TBuildModeMenuItem;
  begin
    if Items.Count > CurIndex then
      AMenuItem := Items[CurIndex] as TBuildModeMenuItem
    else
    begin
      AMenuItem := TBuildModeMenuItem.Create(Self);
      AMenuItem.Name := Name + 'Mode' + IntToStr(CurIndex);
      Items.Add(AMenuItem);
    end;
    AMenuItem.BuildModeIndex := BuildModeIndex;
    AMenuItem.Caption := CurMode.GetCaption;
    AMenuItem.Checked := (Project1<>nil) and (Project1.ActiveBuildMode=CurMode);
    AMenuItem.RadioItem := true;
    AMenuItem.ShowAlwaysCheckable:=true;
    inc(CurIndex);
  end;

begin
  // fill the PopupMenu
  CurIndex := 0;
  if Project1<>nil then
    for i:=0 to Project1.BuildModes.Count-1 do
      AddMode(i, Project1.BuildModes[i]);
  // remove unused menuitems
  while Items.Count > CurIndex do
    Items[Items.Count - 1].Free;

  inherited DoPopup(Sender);
end;

{ TSetBuildModeToolButton.TBuildModeMenuItem }

procedure TSetBuildModeToolButton.TBuildModeMenuItem.Click;
var
  NewMode: TProjectBuildMode;
begin
  inherited Click;

  NewMode := Project1.BuildModes[BuildModeIndex];
  if NewMode = Project1.ActiveBuildMode then exit;
  if not (MainIDE.ToolStatus in [itNone,itDebugger]) then begin
    IDEMessageDialog(dlgMsgWinColorUrgentError,
      lisYouCanNotChangeTheBuildModeWhileCompiling,
      mtError,[mbOk]);
    exit;
  end;

  Project1.ActiveBuildMode := NewMode;
  Project1.DefineTemplates.AllChanged(false);
  IncreaseCompilerParseStamp;
  MainBuildBoss.SetBuildTargetProject1(false);
  MainIDE.UpdateCaption;
  MainIDE.UpdateDefineTemplates;
  if Assigned(ProjInspector) then
    ProjInspector.UpdateTitle;
end;

{ TSetBuildModeToolButton }

procedure TSetBuildModeToolButton.DoOnAdded;
begin
  inherited DoOnAdded;

  DropdownMenu := TBuildModeMenu.Create(Self);
  Style := tbsDropDown;
end;

end.

