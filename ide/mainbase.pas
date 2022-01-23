{
 /***************************************************************************
                    mainbase.pas  -  the "integrated" in IDE
                    ----------------------------------------
  TMainIDEBase is the ancestor of TMainIDE. The various top level parts of the
  IDE (called bosses/managers) access the TMainIDE via TMainIDEBase.


  main.pp      - TMainIDE = class(TMainIDEBase)
                   The highest manager/boss of the IDE. Only lazarus.pp uses
                   this unit.
  mainbase.pas - TMainIDEBase = class(TMainIDEInterface)
                   The ancestor class used by (and only by) the other
                   bosses/managers like debugmanager, pkgmanager.
  mainintf.pas - TMainIDEInterface = class(TLazIDEInterface)
                   The interface class of the top level functions of the IDE.
                   TMainIDEInterface is used by functions/units, that uses
                   several different parts of the IDE (designer, source editor,
                   codetools), so they can't be added to a specific boss and
                   which are yet too small to become a boss of their own.
  lazideintf.pas - TLazIDEInterface = class(TComponent)
                   For designtime packages, this is the interface class of the
                   top level functions of the IDE.

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
}
unit MainBase;

{$mode objfpc}{$H+}

interface

{$I ide.inc}

uses
  {$IFDEF IDE_MEM_CHECK}
  MemCheck,
  {$ENDIF}
  // RTL + FCL
  Classes, SysUtils, Types, Math,
  // LCL
  LCLProc, Buttons, Menus, ComCtrls, Controls, Graphics, Dialogs, Forms, ImgList,
  // LazUtils
  LazFileUtils, LazUTF8,
  // Codetools
  CodeToolManager,
  // SynEdit
  SynEditKeyCmds,
  // IDEIntf
  IDEImagesIntf, SrcEditorIntf, LazIDEIntf, MenuIntf, NewItemIntf, PackageIntf,
  IDECommands, IDEWindowIntf, ProjectIntf, ToolBarIntf, ObjectInspector,
  PropEdits, IDEDialogs, IDEUtils, EditorSyntaxHighlighterDef,
  // IDE
  LazConf, LazarusIDEStrConsts, Project, EnvironmentOpts,
  EditorOptions, CompilerOptions, SourceEditor, SourceSynEditor, FindInFilesDlg,
  Splash, MainBar, MainIntf, Designer, Debugger, RunParamsOpts;

type
  TResetToolFlag = (
    rfInteractive,
    rfCloseOnDone,
    rfSuccessOnTrigger
  );
  TResetToolFlags = set of TResetToolFlag;

  TIdleIdeAction = (
    iiaUpdateHighlighters,
    iiaSaveEnvironment,
    iiaUserInputSinceLastIdle,
    iiaCheckFilesOnDisk,
    iiaUpdateDefineTemplates,
    iiaRestartWanted
  );
  TIdleIdeActions = set of TIdleIdeAction;

  { TMainIDEBase }

  TMainIDEBase = class(TMainIDEInterface)
  private
    FWindowMenuActiveForm: TCustomForm;
    FDisplayState: TDisplayState;
    procedure SetDisplayState(AValue: TDisplayState);
    procedure UpdateWindowMenu;
  protected
    FIdleIdeActions: TIdleIdeActions;

    function CreateMenuSeparator(Section: TIDEMenuSection): TIDEMenuCommand;
    procedure CreateMenuItem(Section: TIDEMenuSection;
                             var MenuCommand: TIDEMenuCommand;
                             const MenuItemName, MenuItemCaption: String;
                             const bmpName: String = '';
                             mnuEnabled: Boolean = true;
                             mnuChecked: Boolean = false;
                             mnuVisible: Boolean = true);
    procedure CreateMenuSeparatorSection(ParentSection: TIDEMenuSection;
                             var Section: TIDEMenuSection; const AName: String);
    procedure CreateMenuSubSection(ParentSection: TIDEMenuSection;
                             var Section: TIDEMenuSection;
                             const AName, ACaption: String;
                             const bmpName: String = '');
    procedure CreateMainMenuItem(var Section: TIDEMenuSection;
                                 const MenuItemName, MenuItemCaption: String);
    procedure SetupMainMenu; virtual;
    procedure SetupAppleMenu; virtual;
    procedure SetupFileMenu; virtual;
    procedure SetupEditMenu; virtual;
    procedure SetupSearchMenu; virtual;
    procedure SetupViewMenu; virtual;
    procedure SetupSourceMenu; virtual;
    procedure SetupProjectMenu; virtual;
    procedure SetupRunMenu; virtual;
    procedure SetupPackageMenu; virtual;
    procedure SetupToolsMenu; virtual;
    procedure SetupWindowsMenu; virtual;
    procedure SetupHelpMenu; virtual;

    procedure LoadMenuShortCuts; virtual;
    procedure SetToolStatus(const AValue: TIDEToolStatus); override;

    procedure DoMnuWindowClicked(Sender: TObject);
    procedure ShowMainIDEBar(Center: boolean);
    procedure mnuOpenProjectClicked(Sender: TObject); virtual; abstract;
    procedure mnuOpenRecentClicked(Sender: TObject);
    procedure mnuWindowItemClick(Sender: TObject); virtual;
    procedure mnuCenterWindowItemClick(Sender: TObject); virtual;
    procedure mnuWindowSourceItemClick(Sender: TObject); virtual;
    procedure mnuBuildModeClicked(Sender: TObject); virtual; abstract;

  public
    function DoResetToolStatus(AFlags: TResetToolFlags): boolean; virtual; abstract;

    constructor Create(TheOwner: TComponent); override;
    procedure StartIDE; virtual; abstract;
    destructor Destroy; override;
    procedure CreateOftenUsedForms; virtual; abstract;
    function GetMainBar: TForm; override;
    function BeginCodeTool(var ActiveSrcEdit: TSourceEditor;
                           out ActiveUnitInfo: TUnitInfo;
                           Flags: TCodeToolsFlags): boolean;
    function BeginCodeTool(ADesigner: TDesigner;
                           var ActiveSrcEdit: TSourceEditor;
                           out ActiveUnitInfo: TUnitInfo;
                           Flags: TCodeToolsFlags): boolean;
    procedure ActivateCodeToolAbortableMode;
    function OnCodeToolBossCheckAbort: boolean;
    procedure DoShowDesignerFormOfCurrentSrc(AComponentPaletteClassSelected: Boolean); virtual; abstract;
    function CreateDesignerForComponent(AnUnitInfo: TUnitInfo;
                        AComponent: TComponent): TCustomForm; virtual; abstract;
    procedure UpdateSaveMenuItemsAndButtons(UpdateSaveAll: boolean); virtual; abstract;

    procedure DoMergeDefaultProjectOptions;
    procedure DoSwitchToFormSrc(var ActiveSourceEditor:TSourceEditor;
      var ActiveUnitInfo:TUnitInfo);
    procedure DoSwitchToFormSrc(ADesigner: TIDesigner;
      var ActiveSourceEditor:TSourceEditor; var ActiveUnitInfo:TUnitInfo);

    procedure GetUnitInfoForDesigner(ADesigner: TIDesigner;
                              out ActiveSourceEditor: TSourceEditorInterface;
                              out ActiveUnitInfo: TUnitInfo); override;
    procedure GetCurrentUnitInfo(out ActiveSourceEditor: TSourceEditorInterface;
                              out ActiveUnitInfo: TUnitInfo); override;
    procedure GetCurrentUnit(out ActiveSourceEditor: TSourceEditor;
                             out ActiveUnitInfo: TUnitInfo); virtual; abstract;
    procedure GetDesignerUnit(ADesigner: TDesigner;
          out ActiveSourceEditor: TSourceEditor; out ActiveUnitInfo: TUnitInfo); virtual; abstract;
    procedure GetObjectInspectorUnit(
          out ActiveSourceEditor: TSourceEditor; out ActiveUnitInfo: TUnitInfo); virtual; abstract;
    procedure GetUnitWithForm(AForm: TCustomForm;
          out ActiveSourceEditor: TSourceEditor; out ActiveUnitInfo: TUnitInfo); virtual; abstract;
    procedure GetUnitWithPersistent(APersistent: TPersistent;
          out ActiveSourceEditor: TSourceEditor; out ActiveUnitInfo: TUnitInfo); virtual; abstract;
    procedure DoShowComponentList(State: TIWGetFormState = iwgfShowOnTop); virtual; abstract;

    function DoOpenMacroFile(Sender: TObject; const AFilename: string): TModalResult; override;

    procedure SetRecentSubMenu(Section: TIDEMenuSection; FileList: TStringList;
                               OnClickEvent: TNotifyEvent); override;
    procedure SetRecentProjectFilesMenu;
    procedure SetRecentFilesMenu;
    procedure UpdateRecentFilesEnv;
    procedure DoOpenRecentFile(AFilename: string);

    procedure UpdateHighlighters(Immediately: boolean = false); override;
    procedure UpdateDefineTemplates;

    procedure FindInFilesPerDialog(AProject: TProject); override;
    procedure FindInFiles(AProject: TProject; const FindText: string); override;

    procedure SelComponentPageButtonMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual; abstract;
    procedure SelComponentPageButtonClick(Sender: TObject); virtual; abstract;
  public
    property WindowMenuActiveForm: TCustomForm read FWindowMenuActiveForm write FWindowMenuActiveForm;
    property DisplayState: TDisplayState read FDisplayState write SetDisplayState;
  end;

  { TOpenFileToolButton }

  TOpenFileToolButton = class(TIDEToolButton)
  private
    FIndex: TStringList;

    procedure RefreshMenu(Sender: TObject);
    procedure mnuOpenFile(Sender: TObject);
    procedure mnuProjectFile(Sender: TObject);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoOnAdded; override;
  end;

  { TOpenFileMenuItem }

  TOpenFileMenuItem = class(TMenuItem)
  public
    FileName: string;
  end;

  { TNewFormUnitToolButton }

  TNewFormUnitToolButton = class(TIDEToolButton)
  private
    SetDefaultMenuItem: TMenuItem;

    procedure RefreshMenu(Sender: TObject);
    procedure mnuSetFormUnitTemplate(Sender: TObject);
  protected
    class function FindDefaultTemplateName(Category: TNewIDEItemCategory): string; virtual; abstract;
    class procedure SetTemplateName(const TemplateName: string); virtual; abstract;
    class procedure UpdateHint(const AHint: string); virtual; abstract;
  public
    procedure DoOnAdded; override;

    class procedure UpdateHints;
  end;

  { TNewUnitToolButton }

  TNewUnitToolButton = class(TNewFormUnitToolButton)
  protected
    class function FindDefaultTemplateName(Category: TNewIDEItemCategory): string; override;
    class procedure SetTemplateName(const TemplateName: string); override;
    class procedure UpdateHint(const AHint: string); override;
  end;

  { TNewFormToolButton }

  TNewFormToolButton = class(TNewFormUnitToolButton)
  protected
    class function FindDefaultTemplateName(Category: TNewIDEItemCategory): string; override;
    class procedure SetTemplateName(const TemplateName: string); override;
    class procedure UpdateHint(const AHint: string); override;
  end;

  { TNewFormUnitMenuItem }

  TNewFormUnitMenuItem = class(TMenuItem)
  public
    TemplateName: string;
  end;

  TRunOptionItem = class(TMenuItem)
  public
    RunOptionName: string;
  end;

  TRunToolButton = class(TIDEToolButton)
  private
    procedure ChangeRunMode(Sender: TObject);
    procedure MenuOnPopup(Sender: TObject);

    procedure RefreshMenu;
    procedure RunParametersClick(Sender: TObject);
  public
    procedure DoOnAdded; override;
  end;

function GetMainIde: TMainIDEBase;
function PrepareForCompileWithMsg: TModalResult; // Ensure starting compilation is OK.
function UpdateTargetFilename(const ABaseFN: String): Boolean;

property MainIDE: TMainIDEBase read GetMainIde;

  { Normally the IDE builds itself with packages named in config files.
    When the IDE should keep the packages installed in the current executable
    set KeepInstalledPackages to true. }
var KeepInstalledPackages: boolean = false;

implementation

function GetMainIde: TMainIDEBase;
begin
  Result := TMainIDEBase(MainIDEInterface)
end;

function PrepareForCompileWithMsg: TModalResult;
begin
  Result:=mrCancel;
  if Project1=nil then exit;
  if Project1.MainUnitInfo=nil then
    // this project has no source to compile
    IDEMessageDialog(lisCanNotCompileProject,lisTheProjectHasNoMainSourceFile,mtError,[mbCancel])
  else
    Result:=MainIDE.PrepareForCompile;
end;

function UpdateTargetFilename(const ABaseFN: String): Boolean;
// Return True if Project1.TargetFilename was actually changed.
var
  TargetF, StemFN, NewTargetFN: String;
  i: Integer;
begin
  TargetF:=ExtractFileName(Project1.TargetFilename);
  StemFN:=ExtractFileNameOnly(ABaseFN);
  if (TargetF='') or (StemFN='') then exit(False);   // Using default -> ok
  Result:=CompareFilenames(TargetF,StemFN)<>0;       // Names differ -> update.
  if Result then
  begin
    NewTargetFN:=ExtractFilePath(Project1.TargetFilename) + StemFN
               + ExtractFileExt(TargetF);
    for i := 0 to Project1.BuildModes.Count-1 do     // Update all buildmodes.
      Project1.BuildModes[i].CompilerOptions.TargetFilename:=NewTargetFN;
  end;
end;

{ TNewFormUnitToolButton }

procedure TNewFormUnitToolButton.DoOnAdded;
begin
  inherited DoOnAdded;

  PopupMenu := TPopupMenu.Create(Self);
  PopupMenu.OnPopup := @RefreshMenu;

  SetDefaultMenuItem:=TMenuItem.Create(PopupMenu);
  SetDefaultMenuItem.Caption:=lisSetDefault;
  PopupMenu.Items.Add(SetDefaultMenuItem);

  UpdateHints;
end;

procedure TNewFormUnitToolButton.mnuSetFormUnitTemplate(Sender: TObject);
begin
  SetTemplateName((Sender as TNewFormUnitMenuItem).TemplateName);
  EnvironmentOptions.Save(False);

  UpdateHints;
end;

procedure TNewFormUnitToolButton.RefreshMenu(Sender: TObject);
var
  TemplateName: String;
  Category: TNewIDEItemCategory;
  i: Integer;
  CurTemplate: TNewIDEItemTemplate;
  TheIndex: Integer;
  xItem: TNewFormUnitMenuItem;
begin
  Category:=NewIDEItems.FindCategoryByPath(FileDescGroupName,true);
  TemplateName:=FindDefaultTemplateName(Category);

  // create menu items
  TheIndex:=0;
  for i:=0 to Category.Count-1 do begin
    CurTemplate:=Category[i];
    if not CurTemplate.VisibleInNewDialog then continue;
    if TheIndex<SetDefaultMenuItem.Count then
      xItem:=SetDefaultMenuItem[TheIndex] as TNewFormUnitMenuItem
    else begin
      xItem:=TNewFormUnitMenuItem.Create(SetDefaultMenuItem);
      SetDefaultMenuItem.Add(xItem);
    end;
    xItem.OnClick:=@mnuSetFormUnitTemplate;
    xItem.Caption:=CurTemplate.LocalizedName;
    xItem.TemplateName:=CurTemplate.Name;
    xItem.ShowAlwaysCheckable:=true;
    xItem.Checked:=CompareText(TemplateName,CurTemplate.Name)=0;
    inc(TheIndex);
  end;
  // remove unneeded items
  while SetDefaultMenuItem.Count>TheIndex do
    SetDefaultMenuItem.Items[SetDefaultMenuItem.Count-1].Free;
end;

class procedure TNewFormUnitToolButton.UpdateHints;
var
  Category: TNewIDEItemCategory;
  TemplateName: String;
  Template: TNewIDEItemTemplate;
begin
  if not Assigned(NewIDEItems) then
    Exit;
  Category:=NewIDEItems.FindCategoryByPath(FileDescGroupName,true);
  TemplateName:=FindDefaultTemplateName(Category);
  if TemplateName<>'' then  //try to get the LocalizedName
  begin
    Template:=Category.FindTemplateByName(TemplateName);
    if Assigned(Template) then
      TemplateName := Template.LocalizedName;
  end;
  UpdateHint(Format(lisMenuNewCustom, [TemplateName]));
end;

{ TNewFormToolButton }

class function TNewFormToolButton.FindDefaultTemplateName(
  Category: TNewIDEItemCategory): string;
begin
  Result:=EnvironmentOptions.NewFormTemplate;
  if (Result='') or (Category.FindTemplateByName(Result)=nil) then
    Result:=FileDescNameLCLForm;
end;

class procedure TNewFormToolButton.SetTemplateName(const TemplateName: string);
begin
  EnvironmentOptions.NewFormTemplate:=TemplateName;
end;

class procedure TNewFormToolButton.UpdateHint(const AHint: string);
begin
  MainIDEBar.itmFileNewForm.Hint := AHint;
end;

{ TNewUnitToolButton }

class function TNewUnitToolButton.FindDefaultTemplateName(
  Category: TNewIDEItemCategory): string;
begin
  Result:=EnvironmentOptions.NewUnitTemplate;
  if (Result='') or (Category.FindTemplateByName(Result)=nil) then
    Result:=FileDescNamePascalUnit;
end;

class procedure TNewUnitToolButton.SetTemplateName(const TemplateName: string);
begin
  EnvironmentOptions.NewUnitTemplate:=TemplateName;
end;

class procedure TNewUnitToolButton.UpdateHint(const AHint: string);
begin
  MainIDEBar.itmFileNewUnit.Hint := AHint;
end;

{ TOpenFileToolButton }

constructor TOpenFileToolButton.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FIndex := TStringList.Create;
end;

destructor TOpenFileToolButton.Destroy;
begin
  FIndex.Free;

  inherited Destroy;
end;

procedure TOpenFileToolButton.DoOnAdded;
begin
  inherited DoOnAdded;

  DropdownMenu := TPopupMenu.Create(Self);
  DropdownMenu.OnPopup := @RefreshMenu;
  DropdownMenu.Images := LCLGlyphs;
  Style := tbsDropDown;
end;

procedure TOpenFileToolButton.mnuOpenFile(Sender: TObject);
begin
  // Hint holds the full filename, Caption may have a shortened form.
  MainIDE.DoOpenRecentFile((Sender as TOpenFileMenuItem).Hint);
end;

procedure TOpenFileToolButton.mnuProjectFile(Sender: TObject);
begin
  MainIDE.DoOpenProjectFile((Sender as TOpenFileMenuItem).Hint, [ofAddToRecent]);
end;

procedure TOpenFileToolButton.RefreshMenu(Sender: TObject);

  procedure AddFile(const AFileName: string; const AOnClick: TNotifyEvent);
  var
    AMenuItem: TOpenFileMenuItem;
  begin
    AMenuItem := TOpenFileMenuItem.Create(DropdownMenu);
    DropdownMenu.Items.Add(AMenuItem);
    AMenuItem.OnClick := AOnClick;
    AMenuItem.FileName := AFileName;
    AMenuItem.Caption := ShortDisplayFilename(AFilename);
    AMenuItem.Hint := AFilename; // Hint is not shown, it just holds the full filename.
    if FilenameExtIn(AFileName,['.lpi','.lpr']) then
      AMenuItem.ImageIndex := LoadProjectIconIntoImages(AFileName, DropdownMenu.Images, FIndex);
  end;

  procedure AddFiles(List: TStringList; MaxCount: integer; const AOnClick: TNotifyEvent);
  var
    i: integer;
  begin
    i := 0;
    while (i < List.Count) and (i < MaxCount) do
    begin
      AddFile(List[i], AOnClick);
      inc(i);
    end;
  end;

begin
  DropdownMenu.Items.Clear;

  // first add recent projects
  AddFiles(EnvironmentOptions.RecentProjectFiles, EnvironmentOptions.MaxRecentProjectFiles,
           @mnuProjectFile);
  // add a separator
  DropdownMenu.Items.AddSeparator;
  // then add recent files
  AddFiles(EnvironmentOptions.RecentOpenFiles, EnvironmentOptions.MaxRecentOpenFiles,
           @mnuOpenFile);
end;

{$IFDEF LCLCocoa}
var
  mnuApple: TIDEMenuSection = nil;
  itmAppleAbout: TIDEMenuSection;
  itmApplePref: TIDEMenuSection;
{$ENDIF}

function FormMatchesCmd(aForm: TCustomForm; aCmd: TIDEMenuCommand): Boolean;
begin
  if EnvironmentOptions.Desktop.IDENameForDesignedFormList and IsFormDesign(aForm) then
    Result := aForm.Name = aCmd.Caption
  else
    Result := aForm.Caption = aCmd.Caption;
end;

{ TMainIDEBase }

procedure TMainIDEBase.mnuWindowItemClick(Sender: TObject);
var
  Form: TCustomForm;
begin
  Form:=TCustomForm(TIDEMenuCommand(Sender).UserTag);
  if Form=MainIDEBar then
    ShowMainIDEBar(false)
  else
    IDEWindowCreators.ShowForm(Form, true);
end;

procedure TMainIDEBase.mnuCenterWindowItemClick(Sender: TObject);
var
  i: Integer;
  Form: TCustomForm;
  r, NewBounds: TRect;
begin
  Form:=TCustomForm(TIDEMenuCommand(Sender).UserTag);
  if Form=MainIDEBar then begin
    ShowMainIDEBar(true);
    exit;
  end;

  i:=Screen.CustomFormCount-1;
  while (i>=0) do begin
    Form:=Screen.CustomForms[i];
    if FormMatchesCmd(Form, Sender as TIDEMenuCommand) then
    begin
      // show
      if not Form.IsVisible then
        IDEWindowCreators.ShowForm(Form,true);
      // move to monitor of main IDE bar
      Form:=GetParentForm(Form);
      if Form<>MainIDEBar then begin
        // center on main IDE
        Form.MakeFullyVisible(MainIDEBar.Monitor,true);
        debugln(['TMainIDEBase.mnuCenterWindowItemClick ',DbgSName(Form),' ',dbgs(Form.BoundsRect)]);
        r:=MainIDEBar.BoundsRect;
        if Form.Width<MainIDEBar.Width then
          NewBounds.Left:=(r.Left+r.Right-Form.Width) div 2
        else
          NewBounds.Left:=r.Left+50;
        if Form.Height<MainIDEBar.Height then
          NewBounds.Top:=(r.Top+r.Bottom-Form.Height) div 2
        else
          NewBounds.Top:=r.Top+50;
        NewBounds.Right:=NewBounds.Left+Max(70,Form.Width);
        NewBounds.Bottom:=NewBounds.Top+Max(70,Form.Height);
        debugln(['TMainIDEBase.mnuCenterWindowItemClick New=',dbgs(NewBounds)]);
        Form.BoundsRect:=NewBounds;
        Form.WindowState:=wsNormal;
        Form.BringToFront;
      end;
      break;
    end;
    dec(i);
  end;
end;

procedure TMainIDEBase.mnuWindowSourceItemClick(Sender: TObject);
var
  i: LongInt;
begin
  if SourceEditorManager = nil then exit;
  i:=(sender as TIDEMenuCommand).tag;
  if (i<0) or (i>=SourceEditorManager.SourceEditorCount) then exit;
  SourceEditorManager.ActiveEditor := SourceEditorManager.SourceEditors[i];
  SourceEditorManager.ShowActiveWindowOnTop(True);
end;

procedure TMainIDEBase.SetToolStatus(const AValue: TIDEToolStatus);
begin
  if ToolStatus=AValue then exit;
  inherited SetToolStatus(AValue);
  UpdateCaption;
end;

constructor TMainIDEBase.Create(TheOwner: TComponent);
begin
  // Do not own everything in one big component hierachy. Otherwise the
  // notifications slow down everything
  fOwningComponent:=TComponent.Create(nil);
  inherited Create(TheOwner);
end;

destructor TMainIDEBase.Destroy;
begin
  FreeThenNil(fOwningComponent);
  inherited Destroy;
end;

procedure TMainIDEBase.GetUnitInfoForDesigner(ADesigner: TIDesigner;
  out ActiveSourceEditor: TSourceEditorInterface; out ActiveUnitInfo: TUnitInfo);
var
  SrcEdit: TSourceEditor;
begin
  ActiveSourceEditor:=nil;
  ActiveUnitInfo:=nil;
  if ADesigner is TDesigner then begin
    GetDesignerUnit(TDesigner(ADesigner),SrcEdit,ActiveUnitInfo);
    ActiveSourceEditor:=SrcEdit;
  end;
end;

procedure TMainIDEBase.GetCurrentUnitInfo(
  out ActiveSourceEditor: TSourceEditorInterface; out ActiveUnitInfo: TUnitInfo);
var
  ASrcEdit: TSourceEditor;
  AnUnitInfo: TUnitInfo;
begin
  GetCurrentUnit(ASrcEdit, AnUnitInfo);
  ActiveSourceEditor:=ASrcEdit;
  ActiveUnitInfo:=AnUnitInfo;
end;

function TMainIDEBase.GetMainBar: TForm;
begin
  Result:=MainIDEBar;
end;

function TMainIDEBase.BeginCodeTool(var ActiveSrcEdit: TSourceEditor;
  out ActiveUnitInfo: TUnitInfo; Flags: TCodeToolsFlags): boolean;
begin
  Result:=BeginCodeTool(nil,ActiveSrcEdit,ActiveUnitInfo,Flags);
end;

function TMainIDEBase.BeginCodeTool(ADesigner: TDesigner;
  var ActiveSrcEdit: TSourceEditor; out ActiveUnitInfo: TUnitInfo;
  Flags: TCodeToolsFlags): boolean;
var
  Edit: TIDESynEditor;
begin
  Result:=false;
  if (ctfUseGivenSourceEditor in Flags) and (Project1<>nil)
  and (ActiveSrcEdit<>nil) then begin
    ActiveUnitInfo := Project1.EditorInfoWithEditorComponent(ActiveSrcEdit).UnitInfo;
  end
  else begin
    ActiveSrcEdit:=nil;
    ActiveUnitInfo:=nil;
  end;

  // check global stati
  if (ToolStatus in [itCodeTools,itCodeToolAborting]) then begin
    debugln('TMainIDEBase.BeginCodeTool impossible ',dbgs(ord(ToolStatus)));
    exit;
  end;
  if (not (ctfSourceEditorNotNeeded in Flags)) and (SourceEditorManager.SourceEditorCount=0)
  then begin
    //DebugLn('TMainIDEBase.BeginCodeTool no source editor');
    exit;
  end;

  // check source editor
  if not (ctfUseGivenSourceEditor in Flags) then begin
    if ctfSwitchToFormSource in Flags then
      DoSwitchToFormSrc(ADesigner,ActiveSrcEdit,ActiveUnitInfo)
    else if ADesigner<>nil then
      GetDesignerUnit(ADesigner,ActiveSrcEdit,ActiveUnitInfo)
    else
      GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  end;
  if (not (ctfSourceEditorNotNeeded in Flags)) and
     ((ActiveSrcEdit=nil) or (ActiveUnitInfo=nil))
  then exit;

  // init codetools
  SaveSourceEditorChangesToCodeCache(nil);
  if ActiveSrcEdit<>nil then begin
    Edit:=ActiveSrcEdit.EditorComponent;
    CodeToolBoss.VisibleEditorLines:=Edit.LinesInWindow;
    CodeToolBoss.TabWidth:=Edit.TabWidth;
    CodeToolBoss.IndentSize:=Edit.BlockIndent+Edit.BlockTabIndent*Edit.TabWidth;
    CodeToolBoss.UseTabs:=Edit.BlockTabIndent>0;
  end else begin
    CodeToolBoss.VisibleEditorLines:=25;
    CodeToolBoss.TabWidth:=EditorOpts.TabWidth;
    CodeToolBoss.IndentSize:=EditorOpts.BlockIndent+EditorOpts.BlockTabIndent*EditorOpts.TabWidth;
    CodeToolBoss.UseTabs:=EditorOpts.BlockTabIndent>0;
  end;

  if ctfActivateAbortMode in Flags then
    ActivateCodeToolAbortableMode;

  Result:=true;
end;

procedure TMainIDEBase.ActivateCodeToolAbortableMode;
begin
  if ToolStatus=itNone then
    RaiseGDBException('TMainIDEBase.ActivateCodeToolAbortableMode Error 1');
  ToolStatus:=itCodeTools;
  CodeToolBoss.OnCheckAbort:=@OnCodeToolBossCheckAbort;
  CodeToolBoss.Abortable:=true;
end;

function TMainIDEBase.OnCodeToolBossCheckAbort: boolean;
begin
  Result:=true;
  if ToolStatus<>itCodeTools then exit;
  Application.ProcessMessages;
  Result:=ToolStatus<>itCodeTools;
end;

procedure TMainIDEBase.DoMergeDefaultProjectOptions;
var
  AFilename: String;
begin
  // load default project options if exists
  AFilename:=AppendPathDelim(GetPrimaryConfigPath)+DefaultProjectOptionsFilename;
  if not FileExistsUTF8(AFilename) then
    CopySecondaryConfigFile(DefaultProjectOptionsFilename);
  if FileExistsUTF8(AFilename) then
    if Project1.ReadProject(AFilename,nil,False)<>mrOk then
      DebugLn(['TMainIDEBase.DoLoadDefaultCompilerOptions failed']);

  // change target file name
  Assert(Project1.CompilerOptions.TargetFilename = Project1.TargetFilename,
         'DoMergeDefaultProjectOptions: TargetFilename mismatch.');
  if UpdateTargetFilename(Project1.ProjectInfoFile) then
    Project1.CompilerOptions.Modified:=false;
end;

procedure TMainIDEBase.DoSwitchToFormSrc(var ActiveSourceEditor: TSourceEditor;
  var ActiveUnitInfo: TUnitInfo);
begin
  DoSwitchToFormSrc(nil,ActiveSourceEditor,ActiveUnitInfo);
end;

procedure TMainIDEBase.DoSwitchToFormSrc(ADesigner: TIDesigner;
  var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo);
begin
  if (ADesigner<>nil) then
    ActiveUnitInfo:=Project1.UnitWithComponent(ADesigner.LookupRoot)
  else if GlobalDesignHook.LookupRoot is TComponent then
    ActiveUnitInfo:=Project1.UnitWithComponent(TComponent(GlobalDesignHook.LookupRoot))
  else
    ActiveUnitInfo:=nil;
  if (ActiveUnitInfo<>nil) and (ActiveUnitInfo.OpenEditorInfoCount > 0) then begin
    ActiveSourceEditor := TSourceEditor(ActiveUnitInfo.OpenEditorInfo[0].EditorComponent);
    SourceEditorManagerIntf.ActiveEditor := ActiveSourceEditor;
  end
  else
    ActiveSourceEditor:=nil;
end;

procedure TMainIDEBase.DoMnuWindowClicked(Sender: TObject);
begin
  UpdateWindowMenu;
end;

procedure TMainIDEBase.ShowMainIDEBar(Center: boolean);
var
  NewBounds, WorkArea: TRect;
  aMonitor: TMonitor;
  x, y: LongInt;
begin
  debugln(['TMainIDEBase.ShowMainIDEBar Center=',Center]);
  NewBounds:=MainIDEBar.BoundsRect;
  aMonitor:=MainIDEBar.Monitor;
  if aMonitor=nil then
    aMonitor:=Screen.PrimaryMonitor;
  WorkArea:=aMonitor.WorkareaRect;

  // for experimental or buggy widgetsets: sanity check workarea
  WorkArea.Right:=Max(WorkArea.Right,WorkArea.Left+400);
  WorkArea.Bottom:=Max(WorkArea.Bottom,WorkArea.Top+400);

  if NewBounds.Left<WorkArea.Left then begin
    // move right
    OffsetRect(NewBounds,WorkArea.Left-NewBounds.Left,0);
    NewBounds.Right:=Min(NewBounds.Right,WorkArea.Right);
  end else if NewBounds.Right>WorkArea.Right then begin
    // move left
    NewBounds.Left:=Max(NewBounds.Left-(NewBounds.Right-WorkArea.Right),WorkArea.Left);
  end;
  if NewBounds.Top<WorkArea.Top then begin
    // move down
    OffsetRect(NewBounds,0,WorkArea.Top-NewBounds.Top);
    NewBounds.Bottom:=Min(NewBounds.Bottom,WorkArea.Bottom);
  end else if NewBounds.Bottom>WorkArea.Bottom then begin
    // move up
    NewBounds.Top:=Max(NewBounds.Top-(NewBounds.Bottom-WorkArea.Bottom),WorkArea.Top);
  end;
  if Center then begin
    x:=(WorkArea.Right-WorkArea.Left-(NewBounds.Right-NewBounds.Left)) div 2;
    y:=(WorkArea.Bottom-WorkArea.Top-(NewBounds.Bottom-NewBounds.Top)) div 2;
    OffsetRect(NewBounds,x-NewBounds.Left,y-NewBounds.Top);
  end;

  MainIDEBar.BoundsRect:=NewBounds;
  MainIDEBar.WindowState:=wsNormal;
  MainIDEBar.BringToFront;
end;

procedure TMainIDEBase.SetDisplayState(AValue: TDisplayState);
begin
  if FDisplayState=AValue then Exit;
  FDisplayState:=AValue;
  {$IFDEF VerboseIDEDisplayState}
  debugln(['TMainIDEBase.SetDisplayState ',dbgs(DisplayState)]);
  {$ENDIF}
end;

var
  SeparatorNum: Integer=0;

function TMainIDEBase.CreateMenuSeparator(Section: TIDEMenuSection): TIDEMenuCommand;
begin
  Inc(SeparatorNum);
  Result:=nil;
  CreateMenuItem(Section, Result, 'Separator'+IntToStr(SeparatorNum), '-');  // Result - var parameter
end;

procedure TMainIDEBase.CreateMenuItem(Section: TIDEMenuSection;
  var MenuCommand: TIDEMenuCommand; const MenuItemName, MenuItemCaption: String;
  const bmpName: String; mnuEnabled: Boolean; mnuChecked: Boolean;
  mnuVisible: Boolean);
begin
  MenuCommand:=RegisterIDEMenuCommand(Section,MenuItemName,MenuItemCaption);
  MenuCommand.Enabled:=mnuEnabled;
  MenuCommand.Checked:=mnuChecked;
  MenuCommand.Visible:=mnuVisible;
  if bmpName<>'' then
    MenuCommand.ImageIndex := IDEImages.LoadImage(bmpName);
end;

procedure TMainIDEBase.CreateMenuSeparatorSection(
  ParentSection: TIDEMenuSection; var Section: TIDEMenuSection;
  const AName: String);
begin
  Section:=RegisterIDEMenuSection(ParentSection,AName);
end;

procedure TMainIDEBase.CreateMenuSubSection(ParentSection: TIDEMenuSection;
  var Section: TIDEMenuSection; const AName, ACaption: String;
  const bmpName: String = '');
begin
  Section:=RegisterIDESubMenu(ParentSection,AName,ACaption);
  if bmpName<>'' then
    Section.ImageIndex := IDEImages.LoadImage(bmpName);
end;

procedure TMainIDEBase.CreateMainMenuItem(var Section: TIDEMenuSection;
  const MenuItemName, MenuItemCaption: String);
begin
  Section:=RegisterIDESubMenu(mnuMain,MenuItemName,MenuItemCaption);
end;

procedure TMainIDEBase.SetupAppleMenu;
begin
  with MainIDEBar do begin
    {$IFDEF LCLCocoa}
    CreateMenuSeparatorSection(mnuApple,itmAppleAbout,'itmAppleAbout');
    CreateMenuSeparatorSection(mnuApple,itmApplePref,'itmApplePref');
    {$ENDIF}
  end;
end;

procedure TMainIDEBase.SetupMainMenu;
begin
  MainIDEBar.mnuMainMenu := TMainMenu.Create(MainIDEBar);
  MainIDEBar.mnuMainMenu.Images := IDEImages.Images_16;
  with MainIDEBar do begin
    mnuMain:=RegisterIDEMenuRoot('IDEMainMenu',nil);
    {$ifdef LCLCocoa}
    // Under Apple there is a special policy: every application should create
    // a special Apple menu and put Quit, About there.
    // See issue: http://bugs.freepascal.org/view.php?id=12294
    // See http://lists.apple.com/archives/carbon-development/2002/Apr/msg01183.html, for details
    CreateMainMenuItem(mnuApple,'AppleApplication',#$EF#$A3#$BF);
    {$endif}
    CreateMainMenuItem(mnuFile,'File',lisMenuFile);
    CreateMainMenuItem(mnuEdit,'Edit',lisMenuEdit);
    CreateMainMenuItem(mnuSearch,'Search',lisMenuSearch);
    CreateMainMenuItem(mnuView,'View',lisMenuView);
    CreateMainMenuItem(mnuSource,'Source',lisMenuSource);
    CreateMainMenuItem(mnuProject,'Project',lisMenuProject);
    CreateMainMenuItem(mnuRun,'Run',lisMenuRun);
    CreateMainMenuItem(mnuPackage,'Package',lisMenuPackage);
    mnuComponent:=mnuPackage;
    CreateMainMenuItem(mnuTools,'Tools',lisMenuTools);
    CreateMainMenuItem(mnuWindow,'Window',lisMenuWindow);
    mnuWindow.OnClick  := @DoMnuWindowClicked;
    CreateMainMenuItem(mnuHelp,'Help',lisMenuHelp);
  end;
end;

procedure TMainIDEBase.SetupFileMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuFile,itmFileNew,'itmFileNew');
    ParentMI:=itmFileNew;
    CreateMenuItem(ParentMI,itmFileNewUnit,'itmFileNewUnit',lisMenuNewUnit,'menu_new_unit');
    CreateMenuItem(ParentMI,itmFileNewForm,'itmFileNewForm',lisMenuNewForm,'menu_new_form');
    CreateMenuItem(ParentMI,itmFileNewOther,'itmFileNewOther',lisMenuNewOther,'menu_new');

    CreateMenuSeparatorSection(mnuFile,itmFileOpenSave,'itmFileOpenSave');
    ParentMI:=itmFileOpenSave;
    CreateMenuItem(ParentMI, itmFileOpen, 'itmFileOpen', lisMenuOpen, 'laz_open');
    CreateMenuItem(ParentMI,itmFileRevert,'itmFileRevert',lisMenuRevert, 'menu_file_revert');
    CreateMenuItem(ParentMI, itmFileOpenUnit, 'itmFileOpenUnit', lisMenuOpenUnit, 'laz_open_unit');
    CreateMenuSubSection(ParentMI,itmFileRecentOpen,'itmFileRecentOpen',lisMenuOpenRecent, 'laz_open_recent');
    CreateMenuItem(ParentMI,itmFileSave,'itmFileSave',lisMenuSave,'laz_save');
    CreateMenuItem(ParentMI,itmFileSaveAs,'itmFileSaveAs',lisMenuSaveAs,'menu_saveas');
    CreateMenuItem(ParentMI,itmFileSaveAll,'itmFileSaveAll',lisSaveAll,'menu_save_all');
    CreateMenuItem(ParentMI,itmFileExportHtml,'itmFileExportHtml',lisExportHtml);
    CreateMenuItem(ParentMI,itmFileClose,'itmFileClose',lisMenuCloseEditorFile,'menu_close',false);
    CreateMenuItem(ParentMI,itmFileCloseAll,'itmFileCloseAll',lisMenuCloseAll,'menu_close_all',false);

    CreateMenuSeparatorSection(mnuFile,itmFileDirectories,'itmFileDirectories');
    ParentMI:=itmFileDirectories;
    CreateMenuItem(ParentMI,itmFileCleanDirectory,'itmFileCleanDirectory',lisMenuCleanDirectory, 'menu_clean');

    CreateMenuSeparatorSection(mnuFile,itmFileIDEStart,'itmFileIDEStart');
    ParentMI:=itmFileIDEStart;
    CreateMenuItem(ParentMI,itmFileRestart,'itmFileRestart',lisRestart, 'laz_refresh');
    CreateMenuItem(ParentMI,itmFileQuit,'itmFileQuit',lisBtnQuit, 'menu_exit');
  end;
end;

procedure TMainIDEBase.SetupEditMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuEdit,itmEditReUndo,'itmEditReUndo');
    ParentMI:=itmEditReUndo;
    CreateMenuItem(ParentMI,itmEditUndo,'itmEditUndo',lisUndo,'menu_undo');
    CreateMenuItem(ParentMI,itmEditRedo,'itmEditRedo',lisRedo,'menu_redo');

    CreateMenuSeparatorSection(mnuEdit,itmEditClipboard,'itmEditClipboard');
    ParentMI:=itmEditClipboard;
    CreateMenuItem(ParentMI,itmEditCut,'itmEditCut',lisCut,'laz_cut');
    CreateMenuItem(ParentMI,itmEditCopy,'itmEditCopy',lisCopy,'laz_copy');
    CreateMenuItem(ParentMI,itmEditPaste,'itmEditPaste',lisPaste,'laz_paste');
    CreateMenuItem(ParentMI,itmEditMultiPaste,'itmEditMultiPaste',lisMenuMultiPaste);

    // "Select" menu items
    CreateMenuSeparatorSection(mnuEdit,itmEditSelect,'itmEditSelect');
    ParentMI:=itmEditSelect;
    CreateMenuItem(ParentMI,itmEditSelectAll,'itmEditSelectAll',lisMenuSelectAll, 'menu_select_all');
    CreateMenuItem(ParentMI,itmEditSelectToBrace,'itmEditSelectToBrace',lisMenuSelectToBrace);
    CreateMenuItem(ParentMI,itmEditSelectCodeBlock,'itmEditSelectCodeBlock',lisMenuSelectCodeBlock);
    CreateMenuItem(ParentMI,itmEditSelectWord,'itmEditSelectWord',lisMenuSelectWord);
    CreateMenuItem(ParentMI,itmEditSelectLine,'itmEditSelectLine',lisMenuSelectLine);
    CreateMenuItem(ParentMI,itmEditSelectParagraph,'itmEditSelectParagraph',lisMenuSelectParagraph);

    // "Char Conversion" menu items
    CreateMenuSeparatorSection(mnuEdit,itmEditBlockActions,'itmEditBlockActions');
    ParentMI:=itmEditBlockActions;
    CreateMenuItem(ParentMI,itmEditIndentBlock,'itmEditIndentBlock',lisMenuIndentSelection,'menu_indent');
    CreateMenuItem(ParentMI,itmEditUnindentBlock,'itmEditUnindentBlock',lisMenuUnindentSelection,'menu_unindent');
    CreateMenuItem(ParentMI,itmEditUpperCaseBlock,'itmEditUpperCaseBlock',lisMenuUpperCaseSelection, 'menu_edit_uppercase');
    CreateMenuItem(ParentMI,itmEditLowerCaseBlock,'itmEditLowerCaseBlock',lisMenuLowerCaseSelection, 'menu_edit_lowercase');
    CreateMenuItem(ParentMI,itmEditSwapCaseBlock,'itmEditSwapCaseBlock',lisMenuSwapCaseSelection, 'menu_edit_uppercase');
    CreateMenuItem(ParentMI,itmEditSortBlock,'itmEditSortBlock',lisMenuSortSelection, 'menu_edit_sort');
    CreateMenuItem(ParentMI,itmEditTabsToSpacesBlock,'itmEditTabsToSpacesBlock',lisMenuTabsToSpacesSelection);
    CreateMenuItem(ParentMI,itmEditSelectionBreakLines,'itmEditSelectionBreakLines',lisMenuBeakLinesInSelection);

    // *** insert text ***:
    CreateMenuSeparatorSection(mnuEdit,itmEditInsertions,'itmEditInsertions');
    ParentMI:=itmEditInsertions;
    CreateMenuItem(ParentMI,itmEditInsertCharacter,'itmEditInsertCharacter',lisMenuInsertCharacter);
  end;
end;

procedure TMainIDEBase.SetupSearchMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuSearch,itmSearchFindReplace,'itmSearchFindReplace');
    ParentMI:=itmSearchFindReplace;

    CreateMenuItem(ParentMI,itmSearchFind, 'itmSearchFind', lisMenuFind2, 'menu_search_find');
    CreateMenuItem(ParentMI,itmSearchFindNext,'itmSearchFindNext',lisMenuFindNext, 'menu_search_find_next');
    CreateMenuItem(ParentMI,itmSearchFindPrevious,'itmSearchFindPrevious',lisMenuFindPrevious, 'menu_search_find_previous');
    CreateMenuItem(ParentMI,itmSearchFindInFiles,'itmSearchFindInFiles',lisMenuFindInFiles, 'menu_search_files');
    CreateMenuItem(ParentMI,itmSearchReplace, 'itmSearchReplace', lisBtnDlgReplace, 'menu_search_replace');
    CreateMenuItem(ParentMI,itmIncrementalFind,'itmIncrementalFind',lisMenuIncrementalFind, 'menu_search_incremental');

    CreateMenuSeparatorSection(mnuSearch,itmJumpings,'itmJumpings');
    ParentMI:=itmJumpings;

    CreateMenuItem(ParentMI,itmGotoLine,'itmGotoLine',lisMenuGotoLine, 'menu_goto_line');
    CreateMenuItem(ParentMI,itmJumpBack,'itmJumpBack',lisMenuJumpBack, 'menu_search_jumpback');
    CreateMenuItem(ParentMI,itmJumpForward,'itmJumpForward',lisMenuJumpForward, 'menu_search_jumpforward');
    CreateMenuItem(ParentMI,itmAddJumpPoint,'itmAddJumpPoint',lisMenuAddJumpPointToHistory, 'menu_add_jump_point_to_history');
    CreateMenuItem(ParentMI,itmJumpToNextError,'itmJumpToNextError',lisMenuJumpToNextError, 'menu_search_next_error');
    CreateMenuItem(ParentMI,itmJumpToPrevError,'itmJumpToPrevError',lisMenuJumpToPrevError, 'menu_search_previous_error');

    CreateMenuSubSection(ParentMI,itmJumpToSection,'itmJumpToSection',lisMenuJumpTo, 'menu_jumpto_section');
    ParentMI:=itmJumpToSection;

    CreateMenuItem(ParentMI,itmJumpToInterface,'itmJumpToInterface',lisMenuJumpToInterface, 'menu_jumpto_interface');
    CreateMenuItem(ParentMI,itmJumpToInterfaceUses,'itmJumpToInterfaceUses',lisMenuJumpToInterfaceUses, 'menu_jumpto_interfaceuses');
    CreateMenuSeparator(ParentMI);
    CreateMenuItem(ParentMI,itmJumpToImplementation,'itmJumpToImplementation',lisMenuJumpToImplementation, 'menu_jumpto_implementation');
    CreateMenuItem(ParentMI,itmJumpToImplementationUses,'itmJumpToImplementationUses',lisMenuJumpToImplementationUses, 'menu_jumpto_implementationuses');
    CreateMenuSeparator(ParentMI);
    CreateMenuItem(ParentMI,itmJumpToInitialization,'itmJumpToInitialization',lisMenuJumpToInitialization, 'menu_jumpto_initialization');

    CreateMenuSeparatorSection(mnuSearch,itmBookmarks,'itmBookmarks');
    ParentMI:=itmBookmarks;

    CreateMenuItem(ParentMI,itmSetFreeBookmark,'itmSetFreeBookmark',lisMenuSetFreeBookmark, 'menu_search_set_bookmark');
    CreateMenuItem(ParentMI,itmJumpToNextBookmark,'itmJumpToNextBookmark',lisMenuJumpToNextBookmark, 'menu_search_next_bookmark');
    CreateMenuItem(ParentMI,itmJumpToPrevBookmark,'itmJumpToPrevBookmark',lisMenuJumpToPrevBookmark, 'menu_search_previous_bookmark');

    CreateMenuSeparatorSection(mnuSearch,itmCodeToolSearches,'itmCodeToolSearches');
    ParentMI:=itmCodeToolSearches;

    CreateMenuItem(ParentMI,itmFindBlockOtherEnd,'itmFindBlockOtherEnd',lisMenuFindBlockOtherEndOfCodeBlock);
    CreateMenuItem(ParentMI,itmFindBlockStart,'itmFindBlockStart',lisMenuFindCodeBlockStart);
    CreateMenuItem(ParentMI,itmFindDeclaration,'itmFindDeclaration',lisMenuFindDeclarationAtCursor);
    CreateMenuItem(ParentMI,itmOpenFileAtCursor,'itmOpenFileAtCursor',lisMenuOpenFilenameAtCursor,'menu_search_openfile_atcursor');
    CreateMenuItem(ParentMI,itmGotoIncludeDirective,'itmGotoIncludeDirective',lisMenuGotoIncludeDirective);
    CreateMenuItem(ParentMI,itmSearchFindIdentifierRefs,'itmSearchFindIdentifierRefs',lisMenuFindIdentifierRefs);
    CreateMenuItem(ParentMI,itmSearchProcedureList,'itmSearchProcedureList',lisMenuProcedureList, 'menu_search_procedure_list');
  end;
end;

procedure TMainIDEBase.SetupViewMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuView,itmViewMainWindows,'itmViewMainWindows');
    ParentMI:=itmViewMainWindows;
    CreateMenuItem(ParentMI,itmViewToggleFormUnit,'itmViewToggleFormUnit',lisMenuViewToggleFormUnit, 'menu_view_toggle_form_unit');
    CreateMenuItem(ParentMI,itmViewInspector,'itmViewInspector',lisMenuViewObjectInspector, 'menu_view_inspector');
    CreateMenuItem(ParentMI,itmViewSourceEditor,'itmViewSourceEditor',lisMenuViewSourceEditor, 'menu_view_source_editor');
    CreateMenuItem(ParentMI,itmViewMessage,'itmViewMessage',lisMenuViewMessages, 'menu_view_messages');
    CreateMenuItem(ParentMI,itmViewCodeExplorer,'itmViewCodeExplorer',lisMenuViewCodeExplorer, 'menu_view_code_explorer');
    CreateMenuItem(ParentMI,itmViewFPDocEditor,'itmViewFPDocEditor',lisFPDocEditor);
    CreateMenuItem(ParentMI,itmViewCodeBrowser,'itmViewCodeBrowser',lisMenuViewCodeBrowser, 'menu_view_code_browser');
    CreateMenuItem(ParentMI,itmSourceUnitDependencies,'itmSourceUnitDependencies',lisMenuViewUnitDependencies);
    CreateMenuItem(ParentMI,itmViewRestrictionBrowser,'itmViewRestrictionBrowser',lisMenuViewRestrictionBrowser, 'menu_view_restriction_browser');
    CreateMenuItem(ParentMI,itmViewComponents,'itmViewComponents',lisMenuViewComponents, 'menu_view_components');
    CreateMenuItem(ParentMI,itmJumpHistory,'itmJumpHistory',lisMenuViewJumpHistory, 'menu_view_jump_history');
    CreateMenuItem(ParentMI,itmMacroListView,'itmMacroListView',lisMenuMacroListView);

    CreateMenuSeparatorSection(mnuView,itmViewDesignerWindows,'itmViewDesignerWindows');
    ParentMI:=itmViewDesignerWindows;
    CreateMenuItem(ParentMI,itmViewAnchorEditor,'itmViewAnchorEditor',lisMenuViewAnchorEditor,'menu_view_anchor_editor');
    CreateMenuItem(ParentMI,itmViewTabOrder,'itmViewTabOrder',lisMenuViewTabOrder,'tab_order');

    CreateMenuSeparatorSection(mnuView,itmViewSecondaryWindows,'itmViewSecondaryWindows');
    ParentMI:=itmViewSecondaryWindows;
    CreateMenuItem(ParentMI,itmViewSearchResults,'itmViewSearchResults',lisMenuViewSearchResults, 'menu_view_search_results');
    CreateMenuSubSection(ParentMI,itmViewDebugWindows,'itmViewDebugWindows',lisMenuDebugWindows,'debugger');
    begin
      CreateMenuItem(itmViewDebugWindows,itmViewWatches,'itmViewWatches',lisMenuViewWatches,'debugger_watches');
      CreateMenuItem(itmViewDebugWindows,itmViewBreakPoints,'itmViewBreakPoints',lisMenuViewBreakPoints,'debugger_breakpoints');
      CreateMenuItem(itmViewDebugWindows,itmViewLocals,'itmViewLocals',lisMenuViewLocalVariables);
      if HasConsoleSupport then
        CreateMenuItem(itmViewDebugWindows,itmViewPseudoTerminal,'itmViewPseudoTerminal',lisMenuViewPseudoTerminal)
      else
        itmViewPseudoTerminal := nil;
      CreateMenuItem(itmViewDebugWindows,itmViewRegisters,'itmViewRegisters',lisMenuViewRegisters);
      CreateMenuItem(itmViewDebugWindows,itmViewCallStack,'itmViewCallStack',lisMenuViewCallStack,'debugger_call_stack');
      CreateMenuItem(itmViewDebugWindows,itmViewThreads,'itmViewThreads',lisMenuViewThreads);
      CreateMenuItem(itmViewDebugWindows,itmViewAssembler,'itmViewAssembler',lisMenuViewAssembler);
      CreateMenuItem(itmViewDebugWindows,itmViewDebugEvents,'itmViewDebugEvents',lisMenuViewDebugEvents,'debugger_event_log');
      CreateMenuItem(itmViewDebugWindows,itmViewDbgHistory,'itmViewDbgHistory',lisMenuViewHistory);
    end;
    CreateMenuSubSection(ParentMI, itmViewIDEInternalsWindows, 'itmViewIDEInternalsWindows', lisMenuIDEInternals);
    begin
      CreateMenuItem(itmViewIDEInternalsWindows, itmViewFPCInfo, 'itmViewFPCInfo', lisMenuAboutFPC);
      CreateMenuItem(itmViewIDEInternalsWindows, itmViewIDEInfo, 'itmViewIDEInfo', lisAboutIDE);
      CreateMenuItem(itmViewIDEInternalsWindows, itmViewNeedBuild, 'itmViewNeedBuild', lisMenuWhatNeedsBuilding);
      CreateMenuItem(itmViewIDEInternalsWindows,itmViewDebugOutput,'itmViewDebugOutput',lisMenuViewDebugOutput,'debugger_output');
      {$IFDEF EnableFPDocSearch}
      CreateMenuItem(itmViewIDEInternalsWindows, itmSearchInFPDocFiles,'itmSearchInFPDocFiles','Search in FPDoc files');
      {$ENDIF}
    end;
  end;
end;

procedure TMainIDEBase.SetupSourceMenu;
var
  ParentMI, SubParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuSource,itmSourceBlockActions,'itmSourceBlockActions');
    ParentMI:=itmSourceBlockActions;
    CreateMenuItem(ParentMI,itmSourceCommentBlock,'itmSourceCommentBlock',lisMenuCommentSelection, 'menu_comment');
    CreateMenuItem(ParentMI,itmSourceUncommentBlock,'itmSourceUncommentBlock',lisMenuUncommentSelection, 'menu_uncomment');
    CreateMenuItem(ParentMI,itmSourceToggleComment,'itmSourceToggleComment',lisMenuToggleComment, 'menu_comment');
    CreateMenuItem(ParentMI,itmSourceEncloseBlock,'itmSourceEncloseBlock',lisMenuEncloseSelection);
    CreateMenuItem(ParentMI,itmSourceEncloseInIFDEF,'itmSourceEncloseInIFDEF',lisMenuEncloseInIFDEF);
    CreateMenuItem(ParentMI,itmSourceCompleteCodeInteractive,'itmSourceCompleteCodeInteractive',lisMenuCompleteCodeInteractive);
    CreateMenuItem(ParentMI,itmRefactorInvertAssignment,'itmInvertAssignment',uemInvertAssignment);
    CreateMenuItem(ParentMI,itmSourceUseUnit,'itmSourceUseUnit',lisMenuUseUnit);
    // Refactor
    CreateMenuSeparatorSection(mnuSource,itmSourceRefactor,'itmSourceRefactor');
    CreateMenuSubSection(ParentMI,itmSourceRefactor,'itmSourceRefactor',uemRefactor);
    SubParentMI:=itmSourceRefactor;
      CreateMenuSeparatorSection(SubParentMI,itmRefactorCodeTools,'itmRefactorCodeTools');
      ParentMI:=itmRefactorCodeTools;
      CreateMenuItem(ParentMI,itmRefactorRenameIdentifier,'itmRefactorRenameIdentifier',lisMenuRenameIdentifier);
      CreateMenuItem(ParentMI,itmRefactorExtractProc,'itmRefactorExtractProc',lisMenuExtractProc);

      CreateMenuSeparatorSection(SubParentMI,itmRefactorAdvanced,'itmRefactorAdvanced');
      ParentMI:=itmRefactorAdvanced;
      CreateMenuItem(ParentMI,itmRefactorShowAbstractMethods,'itmShowAbstractMethods',srkmecAbstractMethods);
      CreateMenuItem(ParentMI,itmRefactorShowEmptyMethods,'itmShowEmptyMethods',srkmecEmptyMethods);
      CreateMenuItem(ParentMI,itmRefactorShowUnusedUnits,'itmShowUnusedUnits',srkmecUnusedUnits);
      {$IFDEF EnableFindOverloads}
      CreateMenuItem(ParentMI,itmRefactorFindOverloads,'itmFindOverloads',srkmecFindOverloadsCapt);
      {$ENDIF}

      CreateMenuSeparatorSection(SubParentMI,itmRefactorTools,'itmRefactorTools');
      ParentMI:=itmRefactorTools;
      CreateMenuItem(ParentMI,itmRefactorMakeResourceString,'itmRefactorMakeResourceString',
                     lisMenuMakeResourceString,'menu_tool_make_resourcestring');
    // CodeToolChecks
    CreateMenuSeparatorSection(mnuSource,itmSourceCodeToolChecks,'itmSourceCodeToolChecks');
    ParentMI:=itmSourceCodeToolChecks;
    CreateMenuItem(ParentMI,itmSourceSyntaxCheck,'itmSourceSyntaxCheck',lisMenuQuickSyntaxCheck, 'menu_tool_syntax_check');
    CreateMenuItem(ParentMI,itmSourceGuessUnclosedBlock,'itmSourceGuessUnclosedBlock',lisMenuGuessUnclosedBlock);
    {$IFDEF GuessMisplacedIfdef}
    CreateMenuItem(ParentMI,itmSourceGuessMisplacedIFDEF,'itmSourceGuessMisplacedIFDEF',lisMenuGuessMisplacedIFDEF);
    {$ENDIF}

    CreateMenuSeparatorSection(mnuSource,itmSourceInsertions,'itmSourceInsertions');
    ParentMI:=itmSourceInsertions;
    // *** insert text ***:
    CreateMenuSubSection(ParentMI,itmSourceInsertCVSKeyWord,'itmSourceInsertCVSKeyWord',lisMenuInsertCVSKeyword);
    SubParentMI:=itmSourceInsertCVSKeyWord;
      // insert CVS keyword sub menu items
      CreateMenuItem(SubParentMI,itmSourceInsertCVSAuthor,'itmSourceInsertCVSAuthor','Author');
      CreateMenuItem(SubParentMI,itmSourceInsertCVSDate,'itmSourceInsertCVSDate','Date');
      CreateMenuItem(SubParentMI,itmSourceInsertCVSHeader,'itmSourceInsertCVSHeader','Header');
      CreateMenuItem(SubParentMI,itmSourceInsertCVSID,'itmSourceInsertCVSID','ID');
      CreateMenuItem(SubParentMI,itmSourceInsertCVSLog,'itmSourceInsertCVSLog','Log');
      CreateMenuItem(SubParentMI,itmSourceInsertCVSName,'itmSourceInsertCVSName','Name');
      CreateMenuItem(SubParentMI,itmSourceInsertCVSRevision,'itmSourceInsertCVSRevision','Revision');
      CreateMenuItem(SubParentMI,itmSourceInsertCVSSource,'itmSourceInsertCVSSource','Source');

    CreateMenuSubSection(ParentMI,itmSourceInsertGeneral,'itmSourceInsertGeneral',lisMenuInsertGeneral);
    SubParentMI:=itmSourceInsertGeneral;
      // insert general text sub menu items
      CreateMenuItem(SubParentMI,itmSourceInsertGPLNotice,'itmSourceInsertGPLNotice',lisMenuInsertGPLNotice);
      CreateMenuItem(SubParentMI,itmSourceInsertGPLNoticeTranslated,'itmSourceInsertGPLNoticeTranslated',lisMenuInsertGPLNoticeTranslated);
      CreateMenuItem(SubParentMI,itmSourceInsertLGPLNotice,'itmSourceInsertLGPLNotice',lisMenuInsertLGPLNotice);
      CreateMenuItem(SubParentMI,itmSourceInsertLGPLNoticeTranslated,'itmSourceInsertLGPLNoticeTranslated',lisMenuInsertLGPLNoticeTranslated);
      CreateMenuItem(SubParentMI,itmSourceInsertModifiedLGPLNotice,'itmSourceInsertModifiedLGPLNotice',lisMenuInsertModifiedLGPLNotice);
      CreateMenuItem(SubParentMI,itmSourceInsertModifiedLGPLNoticeTranslated,'itmSourceInsertModifiedLGPLNoticeTranslated',lisMenuInsertModifiedLGPLNoticeTranslated);
      CreateMenuItem(SubParentMI,itmSourceInsertMITNotice,'itmSourceInsertMITNotice',lisMenuInsertMITNotice);
      CreateMenuItem(SubParentMI,itmSourceInsertMITNoticeTranslated,'itmSourceInsertMITNoticeTranslated',lisMenuInsertMITNoticeTranslated);
      CreateMenuItem(SubParentMI,itmSourceInsertUsername,'itmSourceInsertUsername',lisMenuInsertUsername);
      CreateMenuItem(SubParentMI,itmSourceInsertDateTime,'itmSourceInsertDateTime',lisMenuInsertDateTime);
      CreateMenuItem(SubParentMI,itmSourceInsertChangeLogEntry,'itmSourceInsertChangeLogEntry',lisMenuInsertChangeLogEntry);
      CreateMenuItem(SubParentMI,itmSourceInsertGUID,'itmSourceInsertGUID',srkmecInsertGUID);

    CreateMenuItem(itmSourceInsertions,itmSourceInsertFilename,'itmSourceInsertFilename',lisMenuInsertFilename);

    CreateMenuSeparatorSection(mnuSource,itmSourceTools,'itmSourceTools');
    ParentMI:=itmSourceTools;
    CreateMenuItem(ParentMI,itmSourceUnitInfo,'itmViewUnitInfo',lisMenuViewUnitInfo, 'menu_view_unit_info');
  end;
end;

procedure TMainIDEBase.SetupProjectMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuProject,itmProjectNewSection,'itmProjectNewSection');
    ParentMI:=itmProjectNewSection;
    CreateMenuItem(ParentMI,itmProjectNew,'itmProjectNew',lisMenuNewProject, 'menu_project_new');
    CreateMenuItem(ParentMI,itmProjectNewFromFile,'itmProjectNewFromFile',lisMenuNewProjectFromFile, 'menu_project_from_file');

    CreateMenuSeparatorSection(mnuProject,itmProjectOpenSection,'itmProjectOpenSection');
    ParentMI:=itmProjectOpenSection;
    CreateMenuItem(ParentMI,itmProjectOpen,'itmProjectOpen',lisMenuOpenProject,'menu_project_open');
    CreateMenuSubSection(ParentMI,itmProjectRecentOpen,'itmProjectRecentOpen',lisMenuOpenRecentProject,'menu_project_open_recent');
    CreateMenuItem(ParentMI,itmProjectClose,'itmProjectClose',lisMenuCloseProject, 'menu_project_close');

    CreateMenuSeparatorSection(mnuProject,itmProjectSaveSection,'itmProjectSaveSection');
    ParentMI:=itmProjectSaveSection;
    CreateMenuItem(ParentMI,itmProjectSave,'itmProjectSave',lisMenuSaveProject, 'menu_project_save');
    CreateMenuItem(ParentMI,itmProjectSaveAs,'itmProjectSaveAs',lisMenuSaveProjectAs, 'menu_project_save_as');
    CreateMenuItem(ParentMI, itmProjectResaveFormsWithI18n, 'itmProjectResaveFormsWithI18n', lisMenuResaveFormsWithI18n);
    CreateMenuItem(ParentMI,itmProjectPublish,'itmProjectPublish',lisMenuPublishProject);

    CreateMenuSeparatorSection(mnuProject,itmProjectWindowSection,'itmProjectWindowSection');
    ParentMI:=itmProjectWindowSection;
    CreateMenuItem(ParentMI,itmProjectInspector,'itmProjectInspector',lisMenuProjectInspector+' ...','menu_project_inspector');
    CreateMenuItem(ParentMI,itmProjectOptions,'itmProjectOptions',lisMenuProjectOptions,'menu_project_options');

    CreateMenuSeparatorSection(mnuProject,itmProjectAddRemoveSection,'itmProjectAddRemoveSection');
    ParentMI:=itmProjectAddRemoveSection;
    CreateMenuItem(ParentMI,itmProjectAddTo,'itmProjectAddTo',lisMenuAddToProject, 'menu_project_add');
    CreateMenuItem(ParentMI,itmProjectRemoveFrom,'itmProjectRemoveFrom',lisMenuRemoveFromProject, 'menu_project_remove');
    CreateMenuItem(ParentMI,itmProjectViewUnits,'itmProjectViewUnits',lisMenuViewUnits, 'menu_view_units');
    CreateMenuItem(ParentMI,itmProjectViewForms,'itmProjectViewForms',lisMenuViewForms, 'menu_view_forms');
    CreateMenuItem(ParentMI,itmProjectViewSource,'itmProjectViewSource',lisMenuViewProjectSource, 'item_project_source');
  end;
end;

procedure TMainIDEBase.SetupRunMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuRun,itmRunBuilding,'itmRunBuilding');
    ParentMI:=itmRunBuilding;
    CreateMenuItem(ParentMI,itmRunMenuCompile,'itmRunMenuCompile',lisCompile,'menu_build');
    CreateMenuItem(ParentMI,itmRunMenuBuild,'itmRunMenuBuild',lisBuild,'menu_build_all');
    CreateMenuItem(ParentMI,itmRunMenuQuickCompile,'itmRunMenuQuickCompile',lisMenuQuickCompile,'menu_quick_compile');
    CreateMenuItem(ParentMI,itmRunMenuCleanUpAndBuild,'itmRunMenuCleanUpAndBuild',lisMenuCleanUpAndBuild,'menu_build');
    CreateMenuItem(ParentMI,itmRunMenuBuildManyModes,'itmRunMenuBuildManyModes',lisMenuCompileManyModes,'menu_build_all');
    CreateMenuItem(ParentMI,itmRunMenuAbortBuild,'itmRunMenuAbortBuild',lisMenuAbortBuild,'menu_abort_build',False);

    CreateMenuSeparatorSection(mnuRun,itmRunnning,'itmRunnning');
    ParentMI:=itmRunnning;
    CreateMenuItem(ParentMI,itmRunMenuRunWithoutDebugging,'itmRunMenuRunWithoutDebugging',lisMenuRunWithoutDebugging,'menu_run_withoutdebugging');
    CreateMenuItem(ParentMI,itmRunMenuRun,'itmRunMenuRun',lisMenuProjectRun,'menu_run');
    CreateMenuItem(ParentMI,itmRunMenuPause,'itmRunMenuPause',lisPause,'menu_pause', False);
    CreateMenuItem(ParentMI,itmRunMenuShowExecutionPoint,'itmRunMenuShowExecutionPoint',
                   lisMenuShowExecutionPoint,'debugger_show_execution_point', False);
    CreateMenuItem(ParentMI,itmRunMenuStepInto,'itmRunMenuStepInto',lisMenuStepInto,'menu_stepinto');
    CreateMenuItem(ParentMI,itmRunMenuStepOver,'itmRunMenuStepOver',lisMenuStepOver,'menu_stepover');
    CreateMenuItem(ParentMI,itmRunMenuStepOut,'itmRunMenuStepOut',lisMenuStepOut,'menu_stepout');
    CreateMenuItem(ParentMI,itmRunMenuStepToCursor,'itmRunMenuStepToCursor',lisMenuStepToCursor,'menu_step_cursor');
    CreateMenuItem(ParentMI,itmRunMenuRunToCursor,'itmRunMenuRunToCursor',lisMenuRunToCursor,'menu_run_cursor');
    CreateMenuItem(ParentMI,itmRunMenuStop,'itmRunMenuStop',lisStop,'menu_stop', False);

    CreateMenuItem(ParentMI,itmRunMenuAttach,'itmRunMenuAttach',srkmecAttach+' ...','', False);
    CreateMenuItem(ParentMI,itmRunMenuDetach,'itmRunMenuDetach',srkmecDetach,'', False);

    CreateMenuItem(ParentMI,itmRunMenuRunParameters,'itmRunMenuRunParameters',lisMenuRunParameters, 'menu_run_parameters');
    CreateMenuItem(ParentMI,itmRunMenuResetDebugger,'itmRunMenuResetDebugger',lisMenuResetDebugger, 'menu_reset_debugger');

    CreateMenuSeparatorSection(mnuRun,itmRunBuildingFile,'itmRunBuildingFile');
    ParentMI:=itmRunBuildingFile;
    CreateMenuItem(ParentMI,itmRunMenuBuildFile,'itmRunMenuBuildFile',lisMenuBuildFile, 'menu_build_file');
    CreateMenuItem(ParentMI,itmRunMenuRunFile,'itmRunMenuRunFile',lisMenuRunFile,'menu_run_file');
    CreateMenuItem(ParentMI,itmRunMenuConfigBuildFile,'itmRunMenuConfigBuildFile',lisMenuConfigBuildFile, 'menu_build_run_file');

    CreateMenuSeparatorSection(mnuRun,itmRunDebugging,'itmRunDebugging');
    ParentMI:=itmRunDebugging;
    CreateMenuItem(ParentMI,itmRunMenuInspect,'itmRunMenuInspect',lisMenuInspect, 'debugger_inspect', False);
    CreateMenuItem(ParentMI,itmRunMenuEvaluate,'itmRunMenuEvaluate',lisMenuEvaluate, 'debugger_modify', False);
    CreateMenuItem(ParentMI,itmRunMenuAddWatch,'itmRunMenuAddWatch',lisMenuAddWatch, '', False);
    CreateMenuSubSection(ParentMI,itmRunMenuAddBreakpoint,'itmRunMenuAddBreakpoint',lisMenuAddBreakpoint, '');
    CreateMenuItem(itmRunMenuAddBreakpoint,itmRunMenuAddBPSource,'itmRunMenuAdddBPSource',lisSourceBreakpoint, '', False);
    CreateMenuItem(itmRunMenuAddBreakpoint,itmRunMenuAddBPAddress,'itmRunMenuAddBPAddress',lisAddressBreakpoint, '', False);
    CreateMenuItem(itmRunMenuAddBreakpoint,itmRunMenuAddBpWatchPoint,'itmRunMenuAddBpWatchPoint',lisWatchPointBreakpoint, '', False);
  end;
end;

procedure TMainIDEBase.SetupPackageMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuComponent,itmPkgOpening,'itmPkgOpening');
    ParentMI:=itmPkgOpening;
    CreateMenuItem(ParentMI,itmPkgNewPackage,'itmPkgNewPackage',lisMenuNewPackage);
    CreateMenuItem(ParentMI,itmPkgOpenLoadedPackage,'itmPkgOpenPackage',lisMenuOpenPackage,'pkg_installed');
    CreateMenuItem(ParentMI,itmPkgOpenPackageFile,'itmPkgOpenPackageFile',lisMenuOpenPackageFile,'pkg_open');
    CreateMenuItem(ParentMI,itmPkgOpenPackageOfCurUnit,'itmPkgOpenPackageOfCurUnit',lisMenuOpenPackageOfCurUnit);
    CreateMenuSubSection(ParentMI,itmPkgOpenRecent,'itmPkgOpenRecent',lisMenuOpenRecentPkg, 'pkg_open_recent');

    CreateMenuSeparatorSection(mnuComponent,itmPkgUnits,'itmPkgUnits');
    ParentMI:=itmPkgUnits;
    CreateMenuItem(ParentMI,itmPkgAddCurFileToPkg,'itmPkgAddCurFileToPkg',lisMenuAddCurFileToPkg,'pkg_add');
    CreateMenuItem(ParentMI, itmPkgAddNewComponentToPkg, 'itmPkgAddNewComponentToPkg', lisMenuNewComponent+' ...', 'pkg_add');

    CreateMenuSeparatorSection(mnuComponent,itmPkgGraphSection,'itmPkgGraphSection');
    ParentMI:=itmPkgGraphSection;
    CreateMenuItem(ParentMI,itmPkgPkgGraph,'itmPkgPkgGraph',lisMenuPackageGraph+' ...','pkg_graph');
    CreateMenuItem(ParentMI,itmPkgPackageLinks,'itmPkgPackageLinks',lisMenuPackageLinks);
    CreateMenuItem(ParentMI,itmPkgEditInstallPkgs,'itmPkgEditInstallPkgs',lisMenuEditInstallPkgs,'pkg_properties');
  end;
end;

procedure TMainIDEBase.SetupToolsMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuTools,itmOptionsDialogs,'itmOptionsDialogs');
    ParentMI:=itmOptionsDialogs;
    {$ifndef LCLCocoa}
    CreateMenuItem(ParentMI,itmEnvGeneralOptions,'itmEnvGeneralOptions',
                   lisMenuGeneralOptions,'menu_environment_options');
    {$else}
    CreateMenuItem(itmApplePref,itmEnvGeneralOptions,'itmEnvGeneralOptions',
                   lisMacPreferences,'menu_environment_options');
    {$endif}
    CreateMenuItem(ParentMI,itmToolRescanFPCSrcDir,'itmToolRescanFPCSrcDir',
                   lisMenuRescanFPCSourceDirectory);
    CreateMenuItem(ParentMI,itmEnvCodeTemplates,'itmEnvCodeTemplates',lisMenuEditCodeTemplates,'');
    CreateMenuItem(ParentMI,itmEnvCodeToolsDefinesEditor,'itmEnvCodeToolsDefinesEditor',
                   lisMenuCodeToolsDefinesEditor,'menu_codetoolsdefineseditor');

    CreateMenuSeparatorSection(mnuTools,itmCustomTools,'itmCustomTools');
    ParentMI:=itmCustomTools;
    CreateMenuItem(ParentMI,itmToolConfigure,'itmToolConfigure',lisMenuConfigExternalTools);

    CreateMenuSeparatorSection(mnuTools,itmSecondaryTools,'itmSecondaryTools');
    ParentMI:=itmSecondaryTools;
    CreateMenuItem(ParentMI,itmToolManageDesktops,'itmToolManageDesktops', lisDesktops, 'menu_manage_desktops');
    CreateMenuItem(ParentMI,itmToolManageExamples,'itmToolManageExamples',lisMenuExampleProjects, 'camera');
    CreateMenuItem(ParentMI,itmToolDiff,'itmToolDiff',lisMenuCompareFiles, 'menu_tool_diff');

    CreateMenuSeparatorSection(mnuTools,itmConversion,'itmConversion');
    ParentMI:=itmConversion;
    CreateMenuItem(ParentMI,itmToolConvertEncoding,'itmToolConvertEncoding',lisMenuConvertEncoding);
    CreateMenuItem(ParentMI,itmToolCheckLFM,'itmToolCheckLFM',lisMenuCheckLFM, 'menu_tool_check_lfm');

    CreateMenuSubSection(mnuTools,itmDelphiConversion,'itmDelphiConversion',lisMenuDelphiConversion,'menu_tool_del_to_laz');
    ParentMI:=itmDelphiConversion;
    CreateMenuItem(ParentMI,itmToolConvertDelphiUnit,'itmToolConvertDelphiUnit',lisMenuConvertDelphiUnit,'menu_tool_del_to_laz_unit');
    CreateMenuItem(ParentMI,itmToolConvertDelphiProject,'itmToolConvertDelphiProject',lisMenuConvertDelphiProject,'menu_tool_del_to_laz_project');
    CreateMenuItem(ParentMI,itmToolConvertDelphiPackage,'itmToolConvertDelphiPackage',lisMenuConvertDelphiPackage,'menu_tool_del_to_laz_pkg');
    CreateMenuItem(ParentMI,itmToolConvertDFMtoLFM,'itmToolConvertDFMtoLFM',lisMenuConvertDFMtoLFM,'menu_tool_del_to_laz_form');

    CreateMenuSeparatorSection(mnuTools,itmBuildingLazarus,'itmBuildingLazarus');
    ParentMI:=itmBuildingLazarus;
    CreateMenuItem(ParentMI,itmToolBuildLazarus,'itmToolBuildLazarus',lisMenuBuildLazarus,'menu_build_lazarus');
    CreateMenuItem(ParentMI,itmToolConfigureBuildLazarus,'itmToolConfigureBuildLazarus',
                   lisMenuConfigureBuildLazarus, 'menu_configure_build_lazarus');
  end;
end;

procedure TMainIDEBase.SetupWindowsMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuWindow,itmWindowManagers,'itmWindowManagers');
    ParentMI:=itmWindowManagers;
    CreateMenuItem(ParentMI,itmWindowManager,'itmWindowManager', lisManageSourceEditors, 'menu_manage_source_editors');
    // Populated later with a list of editor names
    CreateMenuSeparatorSection(mnuWindow,itmWindowLists,'itmWindowLists');
    CreateMenuSeparatorSection(mnuWindow,itmCenterWindowLists,'itmCenterWindowLists');
    itmCenterWindowLists.ChildrenAsSubMenu:=true;
    itmCenterWindowLists.Caption:=lisCenterALostWindow;
    CreateMenuSeparatorSection(mnuWindow,itmTabLists,'itmTabLists');
    CreateMenuSubSection(itmTabLists,itmTabListProject,'itmTabListProject', dlgEnvProject);
    CreateMenuSeparatorSection(itmTabLists, itmTabListPackage, 'itmTabListPackage');
    CreateMenuSubSection(itmTabLists,itmTabListOther,'itmTabListOther', lisMEOther);
  end;
end;

procedure TMainIDEBase.SetupHelpMenu;
var
  ParentMI: TIDEMenuSection;
begin
  with MainIDEBar do begin
    CreateMenuSeparatorSection(mnuHelp,itmOnlineHelps,'itmOnlineHelps');
    ParentMI:=itmOnlineHelps;

    CreateMenuItem(ParentMI,itmHelpOnlineHelp,'itmHelpOnlineHelp',
                   lisMenuOnlineHelp, 'btn_help');
    CreateMenuItem(ParentMI,itmHelpReportingBug,'itmHelpReportingBug',
                   lisMenuReportingBug, 'menu_reportingbug');

    CreateMenuSeparatorSection(mnuHelp,itmInfoHelps,'itmInfoHelps');
    // old behavior restored, until Tiger issue is fixed.
    // http://bugs.freepascal.org/view.php?id=14411


    // under Cocoa: add About item to the Apple menu
    ParentMI:=itmInfoHelps;
    CreateMenuItem({$ifndef LCLCocoa}ParentMI{$else}itmAppleAbout{$endif}, itmHelpAboutLazarus,'itmHelpAboutLazarus',
                   lisAboutLazarus, 'menu_information');

    CreateMenuSeparatorSection(mnuHelp,itmHelpTools,'itmHelpTools');
    ParentMI:=itmHelpTools;
  end;
end;

procedure TMainIDEBase.LoadMenuShortCuts;
begin
end;

function TMainIDEBase.DoOpenMacroFile(Sender: TObject; const AFilename: string
  ): TModalResult;
begin
  Result:=DoOpenEditorFile(AFilename,-1,-1,
                  [ofOnlyIfExists,ofAddToRecent,ofRegularFile,ofConvertMacros]);
end;

function GetIconIndex(AForm: TWinControl): Integer;
begin
  if csDesigning in AForm.ComponentState then             // in designer
    case AForm.ClassName of
      'TFrameProxyDesignerForm':
        Exit(IDEImages.GetImageIndex('frame_designer'));      // frame
      'TNonControlProxyDesignerForm':
        Exit(IDEImages.GetImageIndex('datamodule_designer')); // datamodule
    else
      Exit(IDEImages.GetImageIndex('form_designer'));         // own form class (TForm1, TForm2, etc.)
    end;

  with MainIDEBar do
  case AForm.ClassName of
    'TCharacterMapDialog':     Exit(-1);                      // for future icon
    'TObjectInspectorDlg':     Exit(itmViewInspector.ImageIndex);
    'TSourceNotebook':         Exit(itmViewSourceEditor.ImageIndex);
    'TMessagesView':           Exit(itmViewMessage.ImageIndex);
    'TCodeExplorerView':       Exit(itmViewCodeExplorer.ImageIndex);
    'TFPDocEditor':            Exit(-1);                      // for future icon
    'TCodeBrowserView':        Exit(itmViewCodeBrowser.ImageIndex);
    'TUnitDependenciesWindow': Exit(-1);                      // for future icon
    'TRestrictionBrowserView': Exit(itmViewRestrictionBrowser.ImageIndex);
    'TComponentListForm':      Exit(itmViewComponents.ImageIndex);
    'TJumpHistoryViewWin':     Exit(itmJumpHistory.ImageIndex);
    'TMacroListView':          Exit(-1);                      // for future icon
    'TTabOrderDialog':         Exit(itmViewTabOrder.ImageIndex);
    'TSearchResultsView':      Exit(itmViewSearchResults.ImageIndex);
    'TWatchesDlg':             Exit(itmViewWatches.ImageIndex);
    'TBreakPointsDlg':         Exit(itmViewBreakPoints.ImageIndex);
    'TLocalsDlg':              Exit(-1);                      // for future icon
    'TRegistersDlg':           Exit(-1);                      // for future icon
    'TCallStackDlg':           Exit(itmViewCallStack.ImageIndex);
    'TThreadsDlg':             Exit(-1);                      // for future icon
    'TAssemblerDlg':           Exit(-1);                      // for future icon
    'TDbgEventsForm':          Exit(-1);                      // for future icon
    'THistoryDialog':          Exit(-1);                      // for future icon
    'TDbgOutputForm':          Exit(itmViewDebugOutput.ImageIndex);
    'TProjectInspectorForm':   Exit(itmProjectInspector.ImageIndex);
    'TPkgGraphExplorerDlg':    Exit(itmPkgPkgGraph.ImageIndex);
    'TPackageEditorForm':      Exit(IDEImages.GetImageIndex('item_package'));
    'TDSFieldsEditorFrm':               Exit(-1);             // for future icon
    'TDBGridColumnsPropertyEditorForm': Exit(-1);             // for future icon
    'TActionListEditor':                Exit(-1);             // for future icon
    'TCollectionPropertyEditorForm':    Exit(-1);             // for future icon
    'TSeriesEditorForm':                Exit(-1);             // for future icon
    // In packages, may not be installed:
    'TProjectGroupEditorForm': Exit(IDEImages.GetImageIndex('pg_item'));
    'THeapTrcViewForm':        Exit(-1);                      // for future icon
    'TIDETodoWindow':          Exit(IDEImages.GetImageIndex('menu_view_todo'));
    'TAnchorDesigner':         Exit(IDEImages.GetImageIndex('menu_view_anchor_editor'));
  else
    Exit(-1);
  end;
end;

function GetMenuItem(Index: Integer; ASection: TIDEMenuSection): TIDEMenuItem;
begin
  Result := RegisterIDEMenuCommand(ASection,'Window'+IntToStr(Index)+ASection.Name,'');
  Result.CreateMenuItem;
end;

procedure InitMenuItem(AMenuItem: TIDEMenuItem; AForm: TCustomForm; AIcon: Integer);
begin
  AMenuItem.ImageIndex := AIcon;
  if not IsFormDesign(AForm) then
    AMenuItem.Caption := AForm.Caption
  else
    case AForm.ClassName of
      'TFrameProxyDesignerForm',         // frame
      'TNonControlProxyDesignerForm':    // datamodule
          AMenuItem.Caption := AForm.Caption;
    else                                 // form
      if EnvironmentOptions.Desktop.IDENameForDesignedFormList then
        AMenuItem.Caption := AForm.Name
      else
        AMenuItem.Caption := AForm.Caption;
    end;
  AMenuItem.UserTag := {%H-}PtrUInt(AForm);
end;

procedure TMainIDEBase.UpdateWindowMenu;
var
  WindowsList: TFPList;
  i, EditorIndex, ItemCountProject, ItemCountOther, IconInd: Integer;
  CurMenuItem: TIDEMenuItem;
  AForm: TForm;
  EdList: TStringListUTF8Fast;
  se: TSourceEditor;
  P: TIDEPackage;
  aSection: TIDEMenuSection;
  s: String;
begin
  itmWindowLists.Clear;
  itmCenterWindowLists.Clear;

  WindowsList:=TFPList.Create;
  // add typical IDE windows at the start of the list
  for i := 0 to SourceEditorManager.SourceWindowCount - 1 do
    WindowsList.Add(SourceEditorManager.SourceWindows[i]);
  if (ObjectInspector1<>nil) and (ObjectInspector1.Visible) then
    WindowsList.Add(ObjectInspector1);
  {$IFNDEF MSWindows}
  if MainIDEBar.Parent=nil then
    WindowsList.Add(MainIDEBar);
  {$ENDIF}
  // add special IDE windows
  for i := 0 to Screen.FormCount-1 do begin
    AForm := Screen.Forms[i];
    //debugln(['TMainIDEBase.UpdateWindowMenu ',DbgSName(AForm),' Vis=',AForm.IsVisible,' Des=',DbgSName(AForm.Designer)]);
    if (AForm=MainIDEBar) or (AForm=SplashForm) or IsFormDesign(AForm)
    or (WindowsList.IndexOf(AForm)>=0) then
      continue;
    if IDEDockMaster<>nil then
    begin
      if not IDEDockMaster.AddableInWindowMenu(AForm) then continue;
    end else begin
      if (AForm.Parent<>nil) or not AForm.IsVisible then continue;
    end;
    WindowsList.Add(AForm);
  end;
  // add designer forms and datamodule forms
  for i := 0 to Screen.FormCount-1 do begin
    AForm := Screen.Forms[i];
    if (AForm.Designer<>nil) and (WindowsList.IndexOf(AForm)<0) then
      WindowsList.Add(AForm);
  end;
  // create menuitems for all windows
  for i := 0 to WindowsList.Count-1 do
  begin
    IconInd := GetIconIndex(TWinControl(WindowsList[i]));
    // in the 'bring to front' list
    CurMenuItem := GetMenuItem(i, itmWindowLists);
    InitMenuItem(CurMenuItem, TCustomForm(WindowsList[i]), IconInd);
    CurMenuItem.Checked := WindowMenuActiveForm = TCustomForm(WindowsList[i]);
    CurMenuItem.OnClick := @mnuWindowItemClick;
    // in the 'center' list
    CurMenuItem := GetMenuItem(i, itmCenterWindowLists);
    InitMenuItem(CurMenuItem, TCustomForm(WindowsList[i]), IconInd);
    CurMenuItem.OnClick := @mnuCenterWindowItemClick;
  end;
  //create source page menuitems
  itmTabListProject.Visible := False;
  itmTabListOther.Visible := False;
  itmTabListProject.Checked := False;
  itmTabListOther.Checked := False;

  itmTabListProject.Clear;
  itmTabListPackage.Clear;
  itmTabListOther.Clear;

  if SourceEditorManager.SourceEditorCount > 0 then begin
    ItemCountProject := 0;
    ItemCountOther := 0;
    EdList := TStringListUTF8Fast.Create;
    EdList.OwnsObjects := False;
    for i := 0 to SourceEditorManager.SourceEditorCount - 1 do begin
      se := SourceEditorManager.SourceEditors[i];
      EdList.AddObject(se.PageName+' '+se.FileName+se.Owner.Name, TObject(PtrUInt(i)));
    end;
    EdList.Sorted := True;
    for i := 0 to EdList.Count - 1 do
    begin
      EditorIndex := PtrUInt(EdList.Objects[i]);
      se := SourceEditorManager.SourceEditors[EditorIndex];
      if (se.GetProjectFile <> nil) and (se.GetProjectFile.IsPartOfProject) then begin
        aSection := itmTabListProject;
        CurMenuItem := GetMenuItem(ItemCountProject, aSection);
        inc(ItemCountProject);
      end else begin
        SourceEditorManager.OnPackageForSourceEditor(P, se);
        if P <> nil then begin
          s := Format(lisTabsFor, [p.Name]);
          if itmTabListPackage.FindByName(S) is TIDEMenuSection then
            aSection := TIDEMenuSection(itmTabListPackage.FindByName(S))
          else
            aSection := RegisterIDESubMenu(itmTabListPackage, S, S);
          CurMenuItem := GetMenuItem(aSection.Count, aSection);
        end else begin
          aSection := itmTabListOther;
          CurMenuItem := GetMenuItem(ItemCountOther, aSection);
          inc(ItemCountOther);
        end;
      end;
      aSection.Visible := True;
      if se.SharedEditorCount > 1 then
        CurMenuItem.Caption := se.PageName + ' ('+TForm(se.Owner).Caption+')'
      else
        CurMenuItem.Caption := se.PageName;
      if CurMenuItem.MenuItem <> nil then
        CurMenuItem.Checked := SourceEditorManager.ActiveEditor = se;
      if (SourceEditorManager.ActiveEditor = se) and (aSection.MenuItem <> nil) then
        aSection.Checked := true;
      CurMenuItem.OnClick := @mnuWindowSourceItemClick;
      CurMenuItem.Tag := EditorIndex;
    end;
    EdList.Free;

    for i := 0 to itmTabListPackage.Count - 1 do begin
      if itmTabListPackage.Items[i] is TIDEMenuSection then begin
        aSection := itmTabListPackage.Items[i] as TIDEMenuSection;
        aSection.Caption := aSection.Caption +  Format(' (%d)', [aSection.Count]);
      end;
    end;
    itmTabListProject.Caption := dlgEnvProject +  Format(' (%d)', [itmTabListProject.Count]);
    itmTabListOther.Caption := lisMEOther +  Format(' (%d)', [itmTabListOther.Count]);
    if itmTabListPackage.TopSeparator <> nil then
      itmTabListPackage.TopSeparator.Visible := False;
    if itmTabListOther.TopSeparator <> nil then
      itmTabListOther.TopSeparator.Visible := False;
  end;
  WindowsList.Free;           // clean up
end;

procedure TMainIDEBase.SetRecentSubMenu(Section: TIDEMenuSection;
  FileList: TStringList; OnClickEvent: TNotifyEvent);
var
  i: integer;
  AMenuItem: TIDEMenuItem;
begin
  // create enough menuitems
  while Section.Count<FileList.Count do begin
    AMenuItem:=RegisterIDEMenuCommand(Section.GetPath,
                              Section.Name+'Recent'+IntToStr(Section.Count),'');
  end;
  // delete unused menuitems
  while Section.Count>FileList.Count do
    Section.Items[Section.Count-1].Free;
  Section.Enabled:=(Section.Count>0);
  // set captions and event
  for i:=0 to FileList.Count-1 do begin
    AMenuItem:=Section.Items[i];
    AMenuItem.Caption := ShortDisplayFilename(FileList[i]);
    AMenuItem.Hint := FileList[i]; // Hint is not shown, it just holds the full filename.
    AMenuItem.OnClick := OnClickEvent;
  end;
end;

procedure TMainIDEBase.SetRecentProjectFilesMenu;
begin
  SetRecentSubMenu(itmProjectRecentOpen,
                   EnvironmentOptions.RecentProjectFiles,
                   @mnuOpenProjectClicked);
end;

procedure TMainIDEBase.SetRecentFilesMenu;
begin
  SetRecentSubMenu(itmFileRecentOpen,
                   EnvironmentOptions.RecentOpenFiles,
                   @mnuOpenRecentClicked);
end;

procedure TMainIDEBase.UpdateRecentFilesEnv;
begin
  SetRecentFilesMenu;
  SaveEnvironment;
end;

procedure TMainIDEBase.DoOpenRecentFile(AFilename: string);
begin
  if DoOpenEditorFile(AFilename,-1,-1,[ofAddToRecent])=mrOk then
    UpdateRecentFilesEnv
  else begin
    // open failed
    if not FileExistsUTF8(AFilename) then begin
      // file does not exist -> delete it from recent file list
      EnvironmentOptions.RemoveFromRecentOpenFiles(AFilename);
      UpdateRecentFilesEnv;
    end;
  end;
end;

procedure TMainIDEBase.mnuOpenRecentClicked(Sender: TObject);
begin
  // Hint holds the full filename, Caption may have a shortened form.
  DoOpenRecentFile((Sender as TIDEMenuItem).Hint);
end;

procedure TMainIDEBase.UpdateHighlighters(Immediately: boolean);
var
  ASrcEdit: TSourceEditor;
  h: TLazSyntaxHighlighter;
  i: Integer;
  AnEditorInfo: TUnitEditorInfo;
begin
  if Immediately then begin
    Exclude(FIdleIdeActions, iiaUpdateHighlighters);
    for h := Low(TLazSyntaxHighlighter) to High(TLazSyntaxHighlighter) do
      if Highlighters[h]<>nil then begin
        Highlighters[h].BeginUpdate;
        EditorOpts.GetHighlighterSettings(Highlighters[h]);
        Highlighters[h].EndUpdate;
      end;
    if Project1<>nil then begin
      for i := 0 to SourceEditorManager.SourceEditorCount - 1 do begin
        ASrcEdit := SourceEditorManager.SourceEditors[i];
        AnEditorInfo:=Project1.EditorInfoWithEditorComponent(ASrcEdit);
        if AnEditorInfo <> nil then
          ASrcEdit.SyntaxHighlighterType := AnEditorInfo.SyntaxHighlighter;
      end;
    end;
  end
  else
    Include(FIdleIdeActions, iiaUpdateHighlighters);
end;

procedure TMainIDEBase.UpdateDefineTemplates;
begin
  Include(FIdleIdeActions, iiaUpdateDefineTemplates);
end;

procedure TMainIDEBase.FindInFilesPerDialog(AProject: TProject);
begin
  FindInFilesDialog.FindInFilesPerDialog(AProject);
end;

procedure TMainIDEBase.FindInFiles(AProject: TProject; const FindText: string);
begin
  FindInFilesDialog.FindInFiles(AProject, FindText);
end;

{ TRunToolButton }

procedure TRunToolButton.ChangeRunMode(Sender: TObject);
begin
  Project1.RunParameterOptions.ActiveModeName := (Sender as TRunOptionItem).RunOptionName;
  Project1.SessionModified:=true;
end;

procedure TRunToolButton.DoOnAdded;
begin
  inherited DoOnAdded;

  DropdownMenu := TPopupMenu.Create(Self);
  Style := tbsDropDown;
  DropdownMenu.OnPopup := @MenuOnPopup;
  if Assigned(FToolBar) then
    DropdownMenu.Images := IDEImages.Images_16;
end;

procedure TRunToolButton.MenuOnPopup(Sender: TObject);
begin
  RefreshMenu;
end;

procedure TRunToolButton.RefreshMenu;
  procedure _AddMode(const _Mode: TRunParamsOptionsMode; const _Parent: TMenuItem;
    const _OnClick: TNotifyEvent);
  var
    xItem: TRunOptionItem;
  begin
    xItem := TRunOptionItem.Create(_Parent.Menu);
    _Parent.Add(xItem);
    xItem.Caption := _Mode.Name;
    xItem.OnClick := _OnClick;
    xItem.RunOptionName := _Mode.Name;
    xItem.Checked := (Project1<>nil) and (_Mode.Name = Project1.RunParameterOptions.ActiveModeName);
  end;

var
  xPM: TPopupMenu;
  i: Integer;
  xMIRunParameters: TMenuItem;
  xMode: TRunParamsOptionsMode;
begin
  xPM := DropdownMenu;
  xPM.Items.Clear;

  xMIRunParameters := TMenuItem.Create(xPM);
  xMIRunParameters.Caption := dlgRunParameters+' ...';
  xMIRunParameters.ImageIndex := IDEImages.LoadImage('menu_run_parameters');
  xMIRunParameters.OnClick := @RunParametersClick;

  if Project1<>nil then
  for i:=0 to Project1.RunParameterOptions.Count-1 do
  begin
    xMode := Project1.RunParameterOptions[i] as TRunParamsOptionsMode;
    _AddMode(xMode, xPM.Items, @ChangeRunMode);
  end;

  if xPM.Items.Count > 0 then
    xPM.Items.AddSeparator;
  xPM.Items.Add(xMIRunParameters);
end;

procedure TRunToolButton.RunParametersClick(Sender: TObject);
begin
  ExecuteIDECommand(Sender, ecRunParameters);
end;

end.


