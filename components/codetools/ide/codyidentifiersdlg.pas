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

  Author: Mattias Gaertner

  Abstract:
    Dictionary of identifiers.
    Dialog to view and search the whole list.

  ToDo:
    -use identifier: check package version
    -check for conflict: other unit with same name already in search path
    -check for conflict: other identifier in scope, use unitname.identifier
    -use gzip? lot of cpu, may be faster on first load
}
unit CodyIdentifiersDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, LCLProc, contnrs, AVL_Tree,
  // LCL
  Forms, Controls, Dialogs, ButtonPanel, StdCtrls, ExtCtrls, LCLType, Buttons, Menus,
  // IdeIntf
  PackageIntf, LazIDEIntf, SrcEditorIntf, ProjectIntf,
  CompOptsIntf, IDEDialogs, IDEMsgIntf, IDEExternToolIntf, ProjPackIntf,
  // Codetools
  CodeCache, BasicCodeTools, CustomCodeTool, CodeToolManager, UnitDictionary,
  CodeTree, LinkScanner, DefineTemplates, FindDeclarationTool,
  CodyStrConsts, CodyUtils, CodyOpts, FileProcs,
  // LazUtils
  LazFileUtils, LazFileCache, AvgLvlTree;

const
  PackageNameFPCSrcDir = 'FPCSrcDir';
  PackageNameDefault = 'PCCfg';
type
  TCodyUnitDictionary = class;

  { TCodyUDLoadSaveThread }

  TCodyUDLoadSaveThread = class(TThread)
  public
    Load: boolean;
    Dictionary: TCodyUnitDictionary;
    Filename: string;
    Done: boolean;
    procedure Execute; override;
  end;

  { TCodyUnitDictionary }

  TCodyUnitDictionary = class(TUnitDictionary)
  private
    FLoadAfterStartInS: integer;
    FLoadSaveError: string;
    FSaveIntervalInS: integer;
    fTimer: TTimer;
    FIdleConnected: boolean;
    fQueuedTools: TAVLTree; // tree of TCustomCodeTool
    fParsingTool: TCustomCodeTool;
    fLoadSaveThread: TCodyUDLoadSaveThread;
    fCritSec: TRTLCriticalSection;
    fLoaded: boolean; // has loaded the file
    fStartTime: TDateTime;
    fClosing: boolean;
    fCheckFiles: TStringToStringTree;
    procedure CheckFiles;
    procedure SetIdleConnected(AValue: boolean);
    procedure SetLoadAfterStartInS(AValue: integer);
    procedure SetLoadSaveError(AValue: string);
    procedure SetSaveIntervalInS(AValue: integer);
    procedure ToolTreeChanged(Tool: TCustomCodeTool; {%H-}NodesDeleting: boolean);
    procedure OnIdle(Sender: TObject; var Done: Boolean);
    procedure WaitForThread;
    procedure OnTimer(Sender: TObject);
    function StartLoadSaveThread: boolean;
    procedure OnIDEClose(Sender: TObject);
    procedure OnApplyOptions(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    property Loaded: boolean read fLoaded;
    function GetFilename: string;
    property IdleConnected: boolean read FIdleConnected write SetIdleConnected;
    property SaveIntervalInS: integer read FSaveIntervalInS write SetSaveIntervalInS;
    property LoadAfterStartInS: integer read FLoadAfterStartInS write SetLoadAfterStartInS;
    procedure BeginCritSec;
    procedure EndCritSec;
    procedure CheckFileAsync(aFilename: string); // check eventually if file exists and delete unit/group
    property LoadSaveError: string read FLoadSaveError write SetLoadSaveError;
  end;

  TCodyIdentifierDlgAction = (
    cidaUseIdentifier,
    cidaJumpToIdentifier
    );

  TCodyIdentifierFilter = (
    cifStartsWith,
    cifContains
    );

  { TCodyIdentifier }

  TCodyIdentifier = class
  public
    Identifier: string;
    Unit_Name: string;
    UnitFile: string;
    GroupName: string;
    GroupFile: string;
    MatchExactly: boolean;
    DirectUnit: boolean; // belongs to same owner
    InUsedPackage: boolean;
    PathDistance: integer; // how far is UnitFile from the current unit
    UseCount: int64;
    constructor Create(const TheIdentifier, TheUnitName, TheUnitFile,
      ThePackageName, ThePackageFile: string; TheMatchExactly: boolean);
  end;

  { TCodyIdentifiersDlg }

  TCodyIdentifiersDlg = class(TForm)
    AddToImplementationUsesCheckBox: TCheckBox;
    ButtonPanel1: TButtonPanel;
    ContainsRadioButton: TRadioButton;
    FilterEdit: TEdit;
    HideOtherProjectsCheckBox: TCheckBox;
    InfoLabel: TLabel;
    ItemsListBox: TListBox;
    JumpMenuItem: TMenuItem;
    DeleteSeparatorMenuItem: TMenuItem;
    DeleteUnitMenuItem: TMenuItem;
    DeletePackageMenuItem: TMenuItem;
    StartsRadioButton: TRadioButton;
    UseMenuItem: TMenuItem;
    PackageLabel: TLabel;
    PopupMenu1: TPopupMenu;
    UnitLabel: TLabel;
    procedure ButtonPanel1HelpButtonClick(Sender: TObject);
    procedure DeletePackageClick(Sender: TObject);
    procedure DeleteUnitClick(Sender: TObject);
    procedure UseIdentifierClick(Sender: TObject);
    procedure ContainsRadioButtonClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure FilterEditKeyDown(Sender: TObject; var Key: Word;
      {%H-}Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure JumpButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure HideOtherProjectsCheckBoxChange(Sender: TObject);
    procedure ItemsListBoxClick(Sender: TObject);
    procedure ItemsListBoxSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure OnIdle(Sender: TObject; var {%H-}Done: Boolean);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure StartsRadioButtonClick(Sender: TObject);
  private
    FDlgAction: TCodyIdentifierDlgAction;
    FJumpButton: TBitBtn;
    FLastFilter: string;
    FLastHideOtherProjects: boolean;
    FIdleConnected: boolean;
    FMaxItems: integer;
    FItems: TObjectList; // list of TCodyIdentifier
    FLastFilterType: TCodyIdentifierFilter;
    procedure SetDlgAction(NewAction: TCodyIdentifierDlgAction);
    procedure SetIdleConnected(AValue: boolean);
    procedure SetMaxItems(AValue: integer);
    procedure UpdateGeneralInfo;
    procedure UpdateItemsList;
    procedure UpdateItemsListIfFilterChanged;
    procedure SortItems;
    procedure UpdateIdentifierInfo;
    function GetFilterEditText: string;
    function FindSelectedIdentifier: TCodyIdentifier;
    function FindSelectedItem(out Identifier, UnitFilename,
      GroupName, GroupFilename: string): boolean;
    procedure UpdateCurOwnerOfUnit;
    procedure AddToUsesSection(JumpToSrcError: boolean);
    function UpdateTool(JumpToSrcError: boolean): boolean;
    function AddButton: TBitBtn;
    function GetCurOwnerCompilerOptions: TLazCompilerOptions;
  public
    CurIdentifier: string;
    CurIdentStart: integer; // column
    CurIdentEnd: integer; // column
    CurInitError: TCUParseError;
    CurTool: TCodeTool;
    CurCleanPos: integer;
    CurNode: TCodeTreeNode;
    CurCodePos: TCodeXYPosition;
    CurSrcEdit: TSourceEditorInterface;
    CurMainFilename: string; // if CurSrcEdit is an include file, then CurMainFilename<>CurSrcEdit.Filename
    CurMainCode: TCodeBuffer;
    CurInImplementation: Boolean;

    CurOwner: TObject; // only valid after UpdateCurOwnerOfUnit and till next event
    CurUnitPath: string; // depends on CurOwner
    CurOwnerDir: string; // depends on CurOwner

    NewIdentifier: string;
    NewUnitFilename: string;
    NewGroupName: string;
    NewGroupFilename: string;

    function Init: boolean;
    procedure UseIdentifier;
    procedure JumpToIdentifier;
    property IdleConnected: boolean read FIdleConnected write SetIdleConnected;
    property MaxItems: integer read FMaxItems write SetMaxItems;
    function OwnerToString(AnOwner: TObject): string;
    property DlgAction: TCodyIdentifierDlgAction read FDlgAction;
    function GetFilterType: TCodyIdentifierFilter;
  end;

  { TQuickFixIdentifierNotFoundShowDictionary }

  TQuickFixIdentifierNotFoundShowDictionary = class(TMsgQuickFix)
  public
    function IsApplicable(Msg: TMessageLine; out Identifier: string): boolean;
    procedure CreateMenuItems(Fixes: TMsgQuickFixes); override;
    procedure QuickFix({%H-}Fixes: TMsgQuickFixes; Msg: TMessageLine); override;
  end;

var
  CodyUnitDictionary: TCodyUnitDictionary = nil;

procedure ShowUnitDictionaryDialog(Sender: TObject);
procedure InitUnitDictionary;

function CompareCodyIdentifiersAlphaScopeUse(Item1, Item2: Pointer): integer;
function CompareCodyIdentifiersScopeAlpha(Item1, Item2: Pointer): integer;
function CompareCodyIdentifiersAlpha(Item1, Item2: Pointer): integer;
function CompareCodyIdentifiersScope(Item1, Item2: Pointer): integer;
function CompareCodyIdentifiersUseCount(Item1, Item2: Pointer): integer;

implementation

{$R *.lfm}

procedure ShowUnitDictionaryDialog(Sender: TObject);
var
  Dlg: TCodyIdentifiersDlg;
begin
  Dlg:=TCodyIdentifiersDlg.Create(nil);
  try
    if not Dlg.Init then exit;
    if Dlg.ShowModal=mrOk then begin
      case Dlg.DlgAction of
      cidaUseIdentifier: Dlg.UseIdentifier;
      cidaJumpToIdentifier: Dlg.JumpToIdentifier;
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure InitUnitDictionary;
begin
  CodyUnitDictionary:=TCodyUnitDictionary.Create;
  RegisterIDEMsgQuickFix(TQuickFixIdentifierNotFoundShowDictionary.Create);
end;

function CompareCodyIdentifiersAlphaScopeUse(Item1, Item2: Pointer): integer;
begin
  Result:=CompareCodyIdentifiersAlpha(Item1,Item2);
  //if Result<>0 then debugln(['CompareCodyIdentifiersAlphaScopeUse Alpha diff: ',TCodyIdentifier(Item1).Identifier,' ',TCodyIdentifier(Item2).Identifier]);
  if Result<>0 then exit;
  Result:=CompareCodyIdentifiersScope(Item1,Item2);
  //if Result<>0 then debugln(['CompareCodyIdentifiersAlphaScopeUse Scope diff: ',TCodyIdentifier(Item1).Identifier,' ',TCodyIdentifier(Item1).UnitFile,' ',TCodyIdentifier(Item2).UnitFile]);
  if Result<>0 then exit;
  Result:=CompareCodyIdentifiersUseCount(Item1,Item2);
  //if Result<>0 then debugln(['CompareCodyIdentifiersAlphaScopeUse UseCount diff: ',TCodyIdentifier(Item1).Identifier,' ',TCodyIdentifier(Item1).UseCount,' ',TCodyIdentifier(Item2).UseCount]);
end;

function CompareCodyIdentifiersScopeAlpha(Item1, Item2: Pointer): integer;
begin
  Result:=CompareCodyIdentifiersScope(Item1,Item2);
  if Result<>0 then exit;
  Result:=CompareCodyIdentifiersAlpha(Item1,Item2);
end;

function CheckFlag(Flag1, Flag2: boolean; var r: integer): boolean;
begin
  if Flag1=Flag2 then exit(false);
  Result:=true;
  if Flag1 then r:=-1 else r:=1;
end;

function CompareCodyIdentifiersAlpha(Item1, Item2: Pointer): integer;
// positive is sorted on top
var
  i1: TCodyIdentifier absolute Item1;
  i2: TCodyIdentifier absolute Item2;
begin
  Result:=0;
  // an exact match is better
  if CheckFlag(i1.MatchExactly,i2.MatchExactly,Result) then exit;
  // otherwise alphabetically
  Result:=-CompareIdentifiers(PChar(i1.Identifier),PChar(i2.Identifier));
end;

function CompareCodyIdentifiersScope(Item1, Item2: Pointer): integer;
// positive is sorted on top
var
  i1: TCodyIdentifier absolute Item1;
  i2: TCodyIdentifier absolute Item2;
begin
  Result:=0;
  // an exact match is better
  if CheckFlag(i1.MatchExactly,i2.MatchExactly,Result) then begin
    //debugln(['CompareCodyIdentifiersScope ',i1.Identifier,' MatchExactly 1=',i1.MatchExactly,' 2=',i2.MatchExactly]);
    exit;
  end;
  // an unit of the owner is better
  if CheckFlag(i1.DirectUnit,i2.DirectUnit,Result) then begin
    //debugln(['CompareCodyIdentifiersScope ',i1.Identifier,' DirectUnit 1=',i1.DirectUnit,' 2=',i2.DirectUnit]);
    exit;
  end;
  // an unit in a used package is better
  if CheckFlag(i1.InUsedPackage,i2.InUsedPackage,Result) then begin
    //debugln(['CompareCodyIdentifiersScope ',i1.Identifier,' InUsedPackage 1=',i1.InUsedPackage,' 2=',i2.InUsedPackage]);
    exit;
  end;
  // a fpc unit is better
  if CheckFlag(i1.GroupName=PackageNameDefault,i2.GroupName=PackageNameDefault,Result) then begin
    //debugln(['CompareCodyIdentifiersScope fpc.cfg unit ',i1.Identifier,' GroupName 1=',i1.GroupName,' 2=',i2.GroupName]);
    exit;
  end;
  if CheckFlag(i1.GroupName=PackageNameFPCSrcDir,i2.GroupName=PackageNameFPCSrcDir,Result) then begin
    //debugln(['CompareCodyIdentifiersScope fpcsrcdir unit ',i1.Identifier,' GroupName 1=',i1.GroupName,' 2=',i2.GroupName]);
    exit;
  end;
  // a near directory is better
  Result:=i1.PathDistance-i2.PathDistance;
  if Result<>0 then begin
    //debugln(['CompareCodyIdentifiersScope ',i1.Identifier,' PathDistance 1=',i1.PathDistance,' 2=',i2.PathDistance]);
  end;
end;

function CompareCodyIdentifiersUseCount(Item1, Item2: Pointer): integer;
var
  i1: TCodyIdentifier absolute Item1;
  i2: TCodyIdentifier absolute Item2;
begin
  if i1.UseCount>i2.UseCount then
    exit(-1)
  else if i1.UseCount<i2.UseCount then
    exit(1)
  else
    exit(0);
end;

{ TQuickFixIdentifierNotFoundShowDictionary }

function TQuickFixIdentifierNotFoundShowDictionary.IsApplicable(
  Msg: TMessageLine; out Identifier: string): boolean;
var
  Dummy: string;
begin
  Result:=IDEFPCParser.MsgLineIsId(Msg,5000,Identifier,Dummy);
end;

procedure TQuickFixIdentifierNotFoundShowDictionary.CreateMenuItems(
  Fixes: TMsgQuickFixes);
var
  Msg: TMessageLine;
  Identifier: string;
  i: Integer;
begin
  for i:=0 to Fixes.LineCount-1 do begin
    Msg:=Fixes.Lines[i];
    if not IsApplicable(Msg,Identifier) then continue;
    Fixes.AddMenuItem(Self, Msg, Format(crsShowCodyDict, [Identifier]));
    exit;
  end;
end;

procedure TQuickFixIdentifierNotFoundShowDictionary.QuickFix(
  Fixes: TMsgQuickFixes; Msg: TMessageLine);
var
  Identifier: string;
begin
  if not IsApplicable(Msg,Identifier) then exit;
  if LazarusIDE.DoOpenFileAndJumpToPos(Msg.GetFullFilename,
    Point(Msg.Column,Msg.Line),-1,-1,-1,[ofOnlyIfExists,ofRegularFile])<>mrOk then exit;
  ShowUnitDictionaryDialog(nil);
end;

{ TCodyIdentifier }

constructor TCodyIdentifier.Create(const TheIdentifier, TheUnitName,
  TheUnitFile, ThePackageName, ThePackageFile: string; TheMatchExactly: boolean
  );
begin
  Identifier:=TheIdentifier;
  Unit_Name:=TheUnitName;
  UnitFile:=TheUnitFile;
  GroupName:=ThePackageName;
  GroupFile:=ThePackageFile;
  MatchExactly:=TheMatchExactly;
end;

{ TCodyUDLoadSaveThread }

procedure TCodyUDLoadSaveThread.Execute;
var
  UncompressedMS: TMemoryStream;
  TempFilename: String;
  BugFilename: String;
begin
  Dictionary.LoadSaveError:='';
  FreeOnTerminate:=true;
  try
    if Load then begin
      // load
      //debugln('TCodyUDLoadSaveThread.Execute loading '+Filename+' exists='+dbgs(FileExistsUTF8(Filename)));
      // Note: if loading fails, then the format or read permissions are wrong
      // mark as loaded, so that the next save will create a valid one
      Dictionary.fLoaded:=true;
      if FileExistsUTF8(Filename) then begin
        UncompressedMS:=TMemoryStream.Create;
        try
          UncompressedMS.LoadFromFile(Filename);
          UncompressedMS.Position:=0;
          Dictionary.BeginCritSec;
          try
            Dictionary.LoadFromStream(UncompressedMS,true);
          finally
            Dictionary.EndCritSec;
          end;
        finally
          UncompressedMS.Free;
        end;
      end;
    end else begin
      // save
      //debugln('TCodyUDLoadSaveThread.Execute saving '+Filename);
      TempFilename:='';
      UncompressedMS:=TMemoryStream.Create;
      try
        Dictionary.BeginCritSec;
        try
          Dictionary.SaveToStream(UncompressedMS);
        finally
          Dictionary.EndCritSec;
        end;
        UncompressedMS.Position:=0;
        // reduce the risk of file corruption due to crashes while saving:
        // save to a temporary file and then rename
        TempFilename:=FileProcs.GetTempFilename(Filename,'writing_tmp_');
        UncompressedMS.SaveToFile(TempFilename);
        if FileExistsUTF8(Filename) and (not DeleteFileUTF8(Filename)) then
          raise Exception.Create(Format(crsUnableToDelete, [Filename]));
        if not RenameFileUTF8(TempFilename,Filename) then
          raise Exception.Create(Format(crsUnableToRenameTo, [TempFilename,
            Filename]));
      finally
        UncompressedMS.Free;
        if FileExistsUTF8(TempFilename) then
          DeleteFileUTF8(TempFilename);
      end;
    end;
  except
    on E: Exception do begin
      debugln(['WARNING: TCodyUDLoadSaveThread.Execute Load=',Load,' ',E.Message]);
      Dictionary.LoadSaveError:=E.Message;
      // DumpExceptionBackTrace; gives wrong line numbers multithreaded
      if E is ECTUnitDictionaryLoadError then begin
        BugFilename:=Filename+'.bug';
        debugln(['TCodyUDLoadSaveThread.Execute saving buggy file for inspection to "',BugFilename,'"']);
        try
          RenameFileUTF8(Filename,BugFilename);
        except
        end;
      end;
    end;
  end;
  Done:=true;
  Dictionary.BeginCritSec;
  try
    Dictionary.fLoadSaveThread:=nil;
  finally
    Dictionary.EndCritSec;
  end;
  WakeMainThread(nil);
  //debugln('TCodyUDLoadSaveThread.Execute END');
end;

{ TCodyUnitDictionary }

procedure TCodyUnitDictionary.ToolTreeChanged(Tool: TCustomCodeTool;
  NodesDeleting: boolean);
begin
  if fParsingTool=Tool then exit;
  if not (Tool is TFindDeclarationTool) then exit;
  if TFindDeclarationTool(Tool).GetSourceType<>ctnUnit then exit;
  //debugln(['TCodyUnitDictionary.ToolTreeChanged ',Tool.MainFilename]);
  if fQueuedTools.Find(Tool)<>nil then exit;
  fQueuedTools.Add(Tool);
  IdleConnected:=true;
end;

procedure TCodyUnitDictionary.OnIdle(Sender: TObject; var Done: Boolean);
var
  OwnerList: TFPList;
  i: Integer;
  Pkg: TIDEPackage;
  UDUnit: TUDUnit;
  UDGroup: TUDUnitGroup;
  ok: Boolean;
  OldChangeStamp: Int64;
  UnitSet: TFPCUnitSetCache;
  CfgCache: TPCTargetConfigCache;
  DefaultFile: String;
begin
  // check without critical section if currently loading/saving
  if fLoadSaveThread<>nil then
    exit;

  if fQueuedTools.Root<>nil then begin
    fParsingTool:=TCustomCodeTool(fQueuedTools.Root.Data);
    fQueuedTools.Delete(fQueuedTools.Root);
    //debugln(['TCodyUnitDictionary.OnIdle parsing ',fParsingTool.MainFilename]);
    OwnerList:=nil;
    try
      ok:=false;
      OldChangeStamp:=ChangeStamp;
      try
        BeginCritSec;
        try
          UDUnit:=ParseUnit(fParsingTool.MainFilename);
        finally
          EndCritSec;
        end;
        ok:=true;
      except
        // parse error
      end;
      //ConsistencyCheck;
      if Ok then begin
        OwnerList:=PackageEditingInterface.GetPossibleOwnersOfUnit(
          fParsingTool.MainFilename,[piosfIncludeSourceDirectories]);
        if (OwnerList<>nil) then begin
          BeginCritSec;
          try
            for i:=0 to OwnerList.Count-1 do begin
              if TObject(OwnerList[i]) is TIDEPackage then begin
                Pkg:=TIDEPackage(OwnerList[i]);
                if Pkg.IsVirtual then continue;
                UDGroup:=AddUnitGroup(Pkg.Filename,Pkg.Name);
                //debugln(['TCodyUnitDictionary.OnIdle Pkg=',Pkg.Filename,' Name=',Pkg.Name]);
                if UDGroup=nil then begin
                  debugln(['ERROR: TCodyUnitDictionary.OnIdle unable to AddUnitGroup: File=',Pkg.Filename,' Name=',Pkg.Name]);
                  exit;
                end;
                UDGroup.AddUnit(UDUnit);
                //ConsistencyCheck;
              end;
            end;
          finally
            EndCritSec;
          end;
        end;

        // check if in FPC source directory
        UnitSet:=CodeToolBoss.GetUnitSetForDirectory('');
        if UnitSet<>nil then begin
          if (UnitSet.FPCSourceDirectory<>'')
          and FileIsInPath(fParsingTool.MainFilename,UnitSet.FPCSourceDirectory)
          then begin
            // unit in FPC source directory
            BeginCritSec;
            try
              UDGroup:=AddUnitGroup(
                AppendPathDelim(UnitSet.FPCSourceDirectory)+PackageNameFPCSrcDir+'.lpk',
                PackageNameFPCSrcDir);
              UDGroup.AddUnit(UDUnit);
            finally
              EndCritSec;
            end;
          end else begin
            CfgCache:=UnitSet.GetConfigCache(false);
            if (CfgCache<>nil) and (CfgCache.Units<>nil) then begin
              DefaultFile:=CfgCache.Units[ExtractFileNameOnly(fParsingTool.MainFilename)];
              if CompareFilenames(DefaultFile,fParsingTool.MainFilename)=0 then
              begin
                // unit source is in default compiler unit path
                BeginCritSec;
                try
                  UDGroup:=AddUnitGroup(
                    ExtractFilePath(UnitSet.CompilerFilename)+PackageNameDefault+'.lpk',
                    PackageNameDefault);
                  UDGroup.AddUnit(UDUnit);
                finally
                  EndCritSec;
                end;
              end;
            end;
          end;
        end;

        if ChangeStamp<>OldChangeStamp then begin
          if (fTimer=nil) and (not fClosing) then begin
            fTimer:=TTimer.Create(nil);
            fTimer.Interval:=SaveIntervalInS*1000;
            fTimer.OnTimer:=@OnTimer;
          end;
          if fTimer<>nil then
            fTimer.Enabled:=true;
        end;
      end;
    finally
      fParsingTool:=nil;
      OwnerList.Free;
    end;
  end else if fCheckFiles<>nil then begin
    CheckFiles;
  end else begin
    // nothing to do, maybe it's time to load the database
    if fStartTime=0 then
      fStartTime:=Now
    else if (fLoadSaveThread=nil) and (not fLoaded)
    and (Abs(Now-fStartTime)*86400>=LoadAfterStartInS) then
      StartLoadSaveThread;
  end;
  Done:=fQueuedTools.Count=0;
  if Done then
    IdleConnected:=false;
end;

procedure TCodyUnitDictionary.WaitForThread;
begin
  repeat
    BeginCritSec;
    try
      if fLoadSaveThread=nil then exit;
    finally
      EndCritSec;
    end;
    Sleep(10);
  until false;
end;

procedure TCodyUnitDictionary.OnTimer(Sender: TObject);
begin
  if StartLoadSaveThread then
    if fTimer<>nil then
      fTimer.Enabled:=false;
end;

function TCodyUnitDictionary.GetFilename: string;
begin
  Result:=AppendPathDelim(LazarusIDE.GetPrimaryConfigPath)+'codyunitdictionary.txt';
end;

function TCodyUnitDictionary.StartLoadSaveThread: boolean;
begin
  Result:=false;
  if (Self=nil) or fClosing then exit;
  if (Application=nil) or (CodyUnitDictionary=nil) then exit;
  //debugln(['TCodyUnitDictionary.StartLoadSaveThread ',fLoadSaveThread<>nil]);
  BeginCritSec;
  try
    if fLoadSaveThread<>nil then exit;
  finally
    EndCritSec;
  end;
  Result:=true;
  fLoadSaveThread:=TCodyUDLoadSaveThread.Create(true);
  fLoadSaveThread.Load:=not fLoaded;
  fLoadSaveThread.Dictionary:=Self;
  fLoadSaveThread.Filename:=GetFilename;
  fLoadSaveThread.Start;
end;

procedure TCodyUnitDictionary.OnIDEClose(Sender: TObject);
begin
  fClosing:=true;
  FreeAndNil(fTimer);
end;

procedure TCodyUnitDictionary.OnApplyOptions(Sender: TObject);
begin
  LoadAfterStartInS:=CodyOptions.UDLoadDelayInS;
  SaveIntervalInS:=CodyOptions.UDSaveIntervalInS;
end;

procedure TCodyUnitDictionary.SetIdleConnected(AValue: boolean);
begin
  if FIdleConnected=AValue then Exit;
  FIdleConnected:=AValue;
  if Application=nil then exit;
  if IdleConnected then
    Application.AddOnIdleHandler(@OnIdle)
  else
    Application.RemoveOnIdleHandler(@OnIdle);
end;

procedure TCodyUnitDictionary.CheckFiles;
var
  aFilename: String;
  StrItem: PStringToStringItem;
  List: TStringList;
  UDGroup: TUDUnitGroup;
  CurUnit: TUDUnit;
begin
  List:=TStringList.Create;
  try
    for StrItem in fCheckFiles do
      List.Add(StrItem^.Name);
    FreeAndNil(fCheckFiles);
    for aFilename in List do begin
      if FileExistsCached(aFilename) then continue;
      BeginCritSec;
      try
        UDGroup:=FindGroupWithFilename(aFilename);
        if UDGroup<>nil then
          DeleteGroup(UDGroup,true);
        CurUnit:=FindUnitWithFilename(aFilename);
        if CurUnit<>nil then
          DeleteUnit(CurUnit,true);
      finally
        EndCritSec;
      end;
    end;
  finally
    List.Free;
  end;
end;

procedure TCodyUnitDictionary.SetLoadAfterStartInS(AValue: integer);
begin
  if FLoadAfterStartInS=AValue then Exit;
  FLoadAfterStartInS:=AValue;
end;

procedure TCodyUnitDictionary.SetLoadSaveError(AValue: string);
begin
  BeginCritSec;
  try
    FLoadSaveError:=AValue;
  finally
    EndCritSec;
  end;
end;

procedure TCodyUnitDictionary.SetSaveIntervalInS(AValue: integer);
begin
  if FSaveIntervalInS=AValue then Exit;
  FSaveIntervalInS:=AValue;
  if fTimer<>nil then
    fTimer.Interval:=SaveIntervalInS;
end;

constructor TCodyUnitDictionary.Create;
begin
  inherited Create;
  FSaveIntervalInS:=60*3; // every 3 minutes
  FLoadAfterStartInS:=3;
  InitCriticalSection(fCritSec);
  fQueuedTools:=TAVLTree.Create;
  CodeToolBoss.AddHandlerToolTreeChanging(@ToolTreeChanged);
  LazarusIDE.AddHandlerOnIDEClose(@OnIDEClose);
  CodyOptions.AddHandlerApply(@OnApplyOptions);
end;

destructor TCodyUnitDictionary.Destroy;
begin
  fClosing:=true;
  CodyOptions.RemoveHandlerApply(@OnApplyOptions);
  FreeAndNil(fCheckFiles);
  CodeToolBoss.RemoveHandlerToolTreeChanging(@ToolTreeChanged);
  FreeAndNil(fTimer);
  WaitForThread;
  IdleConnected:=false;
  FreeAndNil(fQueuedTools);
  inherited Destroy;
  DoneCriticalsection(fCritSec);
end;

procedure TCodyUnitDictionary.Load;
begin
  if fLoaded then exit;
  WaitForThread;
  if fLoaded then exit;
  StartLoadSaveThread;
  WaitForThread;
  //debugln(['TCodyUnitDictionary.Load ']);
  //ConsistencyCheck;
end;

procedure TCodyUnitDictionary.Save;
begin
  WaitForThread;
  fLoaded:=true;
  StartLoadSaveThread;
  WaitForThread;
end;

procedure TCodyUnitDictionary.BeginCritSec;
begin
  EnterCriticalsection(fCritSec);
end;

procedure TCodyUnitDictionary.EndCritSec;
begin
  LeaveCriticalsection(fCritSec);
end;

procedure TCodyUnitDictionary.CheckFileAsync(aFilename: string);
begin
  if fClosing then exit;
  if (aFilename='') or (not FilenameIsAbsolute(aFilename)) then exit;
  if fCheckFiles=nil then
    fCheckFiles:=TStringToStringTree.Create(false);
  fCheckFiles[aFilename]:='1';
  IdleConnected:=true;
end;

{ TCodyIdentifiersDlg }

procedure TCodyIdentifiersDlg.FilterEditChange(Sender: TObject);
begin
  if FItems=nil then exit;
  IdleConnected:=true;
end;

procedure TCodyIdentifiersDlg.UseIdentifierClick(Sender: TObject);
begin
  SetDlgAction(cidaUseIdentifier);
end;

procedure TCodyIdentifiersDlg.ButtonPanel1HelpButtonClick(Sender: TObject);
begin
  OpenCodyHelp('#Identifier_Dictionary');
end;

procedure TCodyIdentifiersDlg.DeletePackageClick(Sender: TObject);
var
  Identifier: string;
  UnitFilename: string;
  GroupName: string;
  GroupFilename: string;
  Group: TUDUnitGroup;
  s: String;
begin
  if not FindSelectedItem(Identifier, UnitFilename, GroupName, GroupFilename)
  then exit;
  if GroupFilename='' then exit;
  s:=Format(crsReallyDeleteThePackageFromTheDatabaseNoteThisDoe, [#13, #13,
    #13, GroupFilename]);
  if IDEMessageDialog(crsDeletePackage, s, mtConfirmation, [mbYes, mbNo], '')<>
    mrYes
  then exit;
  Group:=CodyUnitDictionary.FindGroupWithFilename(GroupFilename);
  if Group=nil then exit;
  CodyUnitDictionary.DeleteGroup(Group,true);
  UpdateGeneralInfo;
  UpdateItemsList;
end;

procedure TCodyIdentifiersDlg.DeleteUnitClick(Sender: TObject);
var
  Identifier: string;
  UnitFilename: string;
  GroupName: string;
  GroupFilename: string;
  CurUnit: TUDUnit;
  s: String;
begin
  if not FindSelectedItem(Identifier, UnitFilename, GroupName, GroupFilename)
  then exit;
  s:=Format(crsReallyDeleteTheUnitFromTheDatabaseNoteThisDoesNo, [#13, #13,
    #13, UnitFilename]);
  if GroupFilename<>'' then
    s+=#13+Format(crsIn, [GroupFilename]);
  if IDEMessageDialog(crsDeleteUnit, s, mtConfirmation, [mbYes, mbNo], '')<>
    mrYes
  then exit;
  CurUnit:=CodyUnitDictionary.FindUnitWithFilename(UnitFilename);
  if CurUnit=nil then exit;
  CodyUnitDictionary.DeleteUnit(CurUnit,true);
  UpdateGeneralInfo;
  UpdateItemsList;
end;

procedure TCodyIdentifiersDlg.ContainsRadioButtonClick(Sender: TObject);
begin
  StartsRadioButton.Checked:=not ContainsRadioButton.Checked;
  IdleConnected:=true;
end;

procedure TCodyIdentifiersDlg.FilterEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
begin
  i:=ItemsListBox.ItemIndex;
  case Key of
  VK_DOWN:
    if i<0 then
      ItemsListBox.ItemIndex:=Min(ItemsListBox.Items.Count-1,0)
    else if i<ItemsListBox.Count-1 then
      ItemsListBox.ItemIndex:=i+1;
  VK_UP:
    if i<0 then
      ItemsListBox.ItemIndex:=ItemsListBox.Count-1
    else if i>0 then
      ItemsListBox.ItemIndex:=i-1;
  end;
end;

procedure TCodyIdentifiersDlg.FormDestroy(Sender: TObject);
begin
  IdleConnected:=false;
end;

procedure TCodyIdentifiersDlg.JumpButtonClick(Sender: TObject);
begin
  SetDlgAction(cidaJumpToIdentifier);
end;

procedure TCodyIdentifiersDlg.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  IdleConnected:=false;
  CodyOptions.PreferImplementationUsesSection:=
                                        AddToImplementationUsesCheckBox.Checked;
  FreeAndNil(FItems);
end;

procedure TCodyIdentifiersDlg.FormCreate(Sender: TObject);
begin
  Caption:=crsCodyIdentifierDictionary;
  ButtonPanel1.HelpButton.OnClick:=@ButtonPanel1HelpButtonClick;
  ButtonPanel1.OKButton.Caption:=crsUseIdentifier;
  ButtonPanel1.OKButton.OnClick:=@UseIdentifierClick;
  FMaxItems:=40;
  FilterEdit.TextHint:=crsFilter;
  FItems:=TObjectList.Create;
  HideOtherProjectsCheckBox.Checked:=true;
  HideOtherProjectsCheckBox.Caption:=crsHideUnitsOfOtherProjects;
  AddToImplementationUsesCheckBox.Caption:=
    crsAddUnitToImplementationUsesSection;
  AddToImplementationUsesCheckBox.Hint:=
    crsIfIdentifierIsAddedToTheImplementationSectionAndNe;

  FJumpButton:=AddButton;
  FJumpButton.Name:='JumpButton';
  FJumpButton.OnClick:=@JumpButtonClick;
  FJumpButton.Caption:= crsJumpTo;

  StartsRadioButton.Checked:=true;
  StartsRadioButton.Caption:=crsStarts;
  StartsRadioButton.Hint:=crsShowOnlyIdentifiersStartingWithFilterText;
  ContainsRadioButton.Checked:=false;
  ContainsRadioButton.Caption:=crsContains;
  ContainsRadioButton.Hint:=crsShowOnlyIdentifiersContainingFilterText;
end;

procedure TCodyIdentifiersDlg.HideOtherProjectsCheckBoxChange(Sender: TObject);
begin
  if FItems=nil then exit;
  IdleConnected:=true;
end;

procedure TCodyIdentifiersDlg.ItemsListBoxClick(Sender: TObject);
begin
  if FItems=nil then exit;

end;

procedure TCodyIdentifiersDlg.ItemsListBoxSelectionChange(Sender: TObject;
  User: boolean);
begin
  if FItems=nil then exit;
  UpdateIdentifierInfo;
end;

procedure TCodyIdentifiersDlg.OnIdle(Sender: TObject; var Done: Boolean);
begin
  if not CodyUnitDictionary.Loaded then begin
    CodyUnitDictionary.Load;
    UpdateGeneralInfo;
    UpdateItemsList;
  end;
  UpdateItemsListIfFilterChanged;
  IdleConnected:=false;
end;

procedure TCodyIdentifiersDlg.PopupMenu1Popup(Sender: TObject);
var
  Identifier: string;
  UnitFilename: string;
  GroupName: string;
  GroupFilename: string;
begin
  if FindSelectedItem(Identifier, UnitFilename, GroupName, GroupFilename) then
  begin
    UseMenuItem.Caption:='Use '+Identifier;
    UseMenuItem.Enabled:=true;
    JumpMenuItem.Caption:='Jump to '+Identifier;
    JumpMenuItem.Enabled:=true;
    DeleteUnitMenuItem.Caption:='Delete unit '+ExtractFilename(UnitFilename);
    DeleteUnitMenuItem.Enabled:=true;
    DeletePackageMenuItem.Caption:='Delete package '+ExtractFilename(GroupFilename);
    DeletePackageMenuItem.Enabled:=true;
  end else begin
    UseMenuItem.Enabled:=false;
    JumpMenuItem.Enabled:=false;
    DeleteUnitMenuItem.Enabled:=false;
    DeletePackageMenuItem.Enabled:=false;
  end;
end;

procedure TCodyIdentifiersDlg.StartsRadioButtonClick(Sender: TObject);
begin
  StartsRadioButton.Checked:=not ContainsRadioButton.Checked;
  IdleConnected:=true;
end;

procedure TCodyIdentifiersDlg.SetIdleConnected(AValue: boolean);
begin
  if FIdleConnected=AValue then Exit;
  FIdleConnected:=AValue;
  if Application=nil then exit;
  if IdleConnected then
    Application.AddOnIdleHandler(@OnIdle)
  else
    Application.RemoveOnIdleHandler(@OnIdle);
end;

procedure TCodyIdentifiersDlg.SetDlgAction(NewAction: TCodyIdentifierDlgAction);
begin
  FDlgAction:=NewAction;
  if FindSelectedItem(NewIdentifier, NewUnitFilename, NewGroupName,
    NewGroupFilename)
  then
    ModalResult:=mrOk
  else
    ModalResult:=mrNone;
end;

procedure TCodyIdentifiersDlg.SetMaxItems(AValue: integer);
begin
  if FMaxItems=AValue then Exit;
  FMaxItems:=AValue;
  UpdateItemsList;
end;

procedure TCodyIdentifiersDlg.UpdateItemsList;
var
  FilterP: PChar;
  Found: Integer;
  UnitSet: TFPCUnitSetCache;
  FPCSrcDir: String;
  CfgCache: TPCTargetConfigCache;

  procedure AddItems(AddExactMatches: boolean);
  var
    FPCSrcFilename: String;
    Dir, aFilename: String;
    Group: TUDUnitGroup;
    GroupNode: TAVLTreeNode;
    Item: TUDIdentifier;
    Node: TAVLTreeNode;
  begin
    Node:=CodyUnitDictionary.Identifiers.FindLowest;
    //debugln(['TCodyIdentifiersDlg.UpdateItemsList Filter="',FLastFilter,'" Count=',CodyUnitDictionary.Identifiers.Count]);
    while Node<>nil do begin
      Item:=TUDIdentifier(Node.Data);
      Node:=CodyUnitDictionary.Identifiers.FindSuccessor(Node);
      if CompareIdentifiers(FilterP,PChar(Pointer(Item.Name)))=0 then begin
        // exact match
        if not AddExactMatches then continue;
      end else begin
        // not exact
        if AddExactMatches then continue;
        case FLastFilterType of
        cifStartsWith:
          if not ComparePrefixIdent(FilterP,PChar(Pointer(Item.Name))) then continue;
        cifContains:
          if IdentifierPos(FilterP,PChar(Pointer(Item.Name)))<0 then continue;
        end;
      end;
      if Found>MaxItems then begin
        inc(Found); // only count, do not check
        continue;
      end;
      GroupNode:=Item.DUnit.Groups.FindLowest;
      while GroupNode<>nil do begin
        Group:=TUDUnitGroup(GroupNode.Data);
        GroupNode:=Item.DUnit.Groups.FindSuccessor(GroupNode);
        if not FilenameIsAbsolute(Item.DUnit.Filename) then continue;
        if Group.Name='' then begin
          // it's a unit without package
          if FLastHideOtherProjects then begin
            // check if unit is in unit path of current owner
            if CurUnitPath='' then continue;
            Dir:=ExtractFilePath(Item.DUnit.Filename);
            if (Dir<>'')
            and (FindPathInSearchPath(PChar(Dir),length(Dir),
                PChar(CurUnitPath),length(CurUnitPath))=nil)
            then continue;
          end;
        end else if Group.Name=PackageNameFPCSrcDir then begin
          // it's a FPC source directory
          // => check if it is the current one
          Dir:=ChompPathDelim(ExtractFilePath(Group.Filename));
          if CompareFilenames(Dir,FPCSrcDir)<>0 then continue;
          // some units have multiple sources in FPC => check target platform
          if UnitSet<>nil then begin
            FPCSrcFilename:=UnitSet.GetUnitSrcFile(Item.DUnit.Name);
            if (FPCSrcFilename<>'')
            and (CompareFilenames(FPCSrcFilename,Item.DUnit.Filename)<>0)
            then continue; // this is not the source for this target platform
            if FLastHideOtherProjects then begin
              // Note: some units do no exists on all targets (e.g. windows.pp)
              if CfgCache.Units[Item.DUnit.Name]='' then
                continue; // the unit has no ppu file
            end;
          end;
        end else if Group.Name=PackageNameDefault then begin
          // unit was in default unit path
          // => check if this is still the case
          if CfgCache<>nil then begin
            aFilename:=CfgCache.Units[Item.DUnit.Name];
            if aFilename='' then
              continue; // the unit is not in current default unit path
            if CompareFilenames(aFilename,Item.DUnit.Filename)<>0 then
              continue; // this is another unit (e.g. from another compiler target)
          end;
        end else if FileExistsCached(Group.Filename) then begin
          // lpk exists
        end else begin
          // lpk does not exist any more
          CodyUnitDictionary.CheckFileAsync(Group.Filename);
        end;
        if FileExistsCached(Item.DUnit.Filename) then begin
          inc(Found);
          if Found<MaxItems then begin
            FItems.Add(TCodyIdentifier.Create(Item.Name,
              Item.DUnit.Name,Item.DUnit.Filename,
              Group.Name,Group.Filename,AddExactMatches));
          end;
        end else begin
          // unit does not exist any more
          CodyUnitDictionary.CheckFileAsync(Item.DUnit.Filename);
        end;
      end;
    end;
  end;

var
  sl: TStringList;
  i: Integer;
  Item: TCodyIdentifier;
  s: String;
begin
  if not CodyUnitDictionary.Loaded then exit;
  FLastFilter:=GetFilterEditText;
  FilterP:=PChar(FLastFilter);
  FLastHideOtherProjects:=HideOtherProjectsCheckBox.Checked;
  FLastFilterType:=GetFilterType;
  UpdateCurOwnerOfUnit;

  FItems.Clear;
  sl:=TStringList.Create;
  try
    Found:=0;
    UnitSet:=CodeToolBoss.GetUnitSetForDirectory('');
    FPCSrcDir:='';
    if (UnitSet<>nil) then begin
      FPCSrcDir:=ChompPathDelim(UnitSet.FPCSourceDirectory);
      CfgCache:=UnitSet.GetConfigCache(false);
    end;
    AddItems(true);
    AddItems(false);

    SortItems;

    for i:=0 to FItems.Count-1 do begin
      Item:=TCodyIdentifier(FItems[i]);
      s:=Item.Identifier+' in '+Item.Unit_Name;
      if Item.GroupName<>'' then begin
        if Item.GroupName=PackageNameDefault then
          s:=s+' in compiler unit path'
        else
          s:=s+' of '+Item.GroupName;
      end;
      sl.Add(s);
    end;
    if Found>sl.Count then
      sl.Add(Format(crsAndMoreIdentifiers, [IntToStr(Found-sl.Count)]));

    ItemsListBox.Items.Assign(sl);
    if Found>0 then
      ItemsListBox.ItemIndex:=0;
    UpdateIdentifierInfo;
  finally
    sl.Free;
  end;
end;

procedure TCodyIdentifiersDlg.UpdateItemsListIfFilterChanged;
begin
  if (FLastFilter<>GetFilterEditText)
  or (FLastHideOtherProjects<>HideOtherProjectsCheckBox.Checked)
  or (FLastFilterType<>GetFilterType) then
    UpdateItemsList;
end;

procedure TCodyIdentifiersDlg.SortItems;
var
  i: Integer;
  Item: TCodyIdentifier;
  DepOwner: TObject;
  BaseDir: String;
  Dir: String;
  CurUnit: TUDUnit;
begin
  BaseDir:=ExtractFilePath(CurMainFilename);
  for i:=0 to FItems.Count-1 do begin
    Item:=TCodyIdentifier(FItems[i]);
    Item.DirectUnit:=false;
    Item.UseCount:=0;
    CurUnit:=CodyUnitDictionary.FindUnitWithFilename(Item.UnitFile);
    if CurUnit<>nil then
      Item.UseCount:=CurUnit.UseCount;
    Item.PathDistance:=length(CreateRelativePath(ExtractFilePath(Item.UnitFile),BaseDir));
    Dir:=ChompPathDelim(ExtractFilePath(Item.UnitFile));
    if (not FilenameIsAbsolute(Item.UnitFile)) or (Dir='') then begin
      // new unit is always very near
      Item.DirectUnit:=true;
      continue;
    end;
    if (CurUnitPath<>'')
    and (FindPathInSearchPath(PChar(Dir),length(Dir),
      PChar(CurUnitPath),length(CurUnitPath))<>nil)
    then begin
      // unit is in search path of current unit
      Item.DirectUnit:=true;
      continue;
    end;
    if Item.GroupName='' then
      continue; // other project is always far away
    if Item.GroupName=PackageNameFPCSrcDir then
      continue; // FPC unit
    if Item.GroupName=PackageNameDefault then
      continue; // FPC unit
    if CurOwner=nil then continue;
    // package unit
    Item.InUsedPackage:=PackageEditingInterface.IsOwnerDependingOnPkg(CurOwner,
                                                       Item.GroupName,DepOwner);
  end;
  FItems.Sort(@CompareCodyIdentifiersAlphaScopeUse);
end;

procedure TCodyIdentifiersDlg.UpdateIdentifierInfo;
var
  Identifier: string;
  UnitFilename: string;
  GroupName, GroupFilename: string;
begin
  if FindSelectedItem(Identifier, UnitFilename, GroupName, GroupFilename) then begin
    if GroupFilename<>'' then
      UnitFilename:=CreateRelativePath(UnitFilename,ExtractFilePath(GroupFilename));
    UnitLabel.Caption:=Format(crsUnit2, [UnitFilename]);
    PackageLabel.Caption:=Format(crsPackage2, [GroupFilename]);
    ButtonPanel1.OKButton.Enabled:=true;
  end else begin
    UnitLabel.Caption:= Format(crsUnit2, [crsNoneSelected]);
    PackageLabel.Caption:= Format(crsPackage2, [crsNoneSelected]);
    ButtonPanel1.OKButton.Enabled:=false;
  end;
end;

procedure TCodyIdentifiersDlg.UpdateGeneralInfo;
var
  s: String;
begin
  s:=Format(crsPackagesUnitsIdentifiersFile,
    [IntToStr(CodyUnitDictionary.UnitGroupsByFilename.Count),
     IntToStr(CodyUnitDictionary.UnitsByFilename.Count),
     IntToStr(CodyUnitDictionary.Identifiers.Count),
     LineEnding,
     CodyUnitDictionary.GetFilename]);
  if CodyUnitDictionary.LoadSaveError<>'' then
    s:=s+LineEnding+Format(crsError, [CodyUnitDictionary.LoadSaveError]);
  InfoLabel.Caption:=s;
end;

function TCodyIdentifiersDlg.GetFilterEditText: string;
begin
  Result:=FilterEdit.Text;
end;

function TCodyIdentifiersDlg.FindSelectedIdentifier: TCodyIdentifier;
var
  i: Integer;
begin
  Result:=nil;
  if FItems=nil then exit;
  i:=ItemsListBox.ItemIndex;
  if (i<0) or (i>=FItems.Count) then exit;
  Result:=TCodyIdentifier(FItems[i]);
end;

function TCodyIdentifiersDlg.FindSelectedItem(out Identifier, UnitFilename,
  GroupName, GroupFilename: string): boolean;
var
  Item: TCodyIdentifier;
begin
  Result:=false;
  Identifier:='';
  UnitFilename:='';
  GroupName:='';
  GroupFilename:='';
  Item:=FindSelectedIdentifier;
  if Item=nil then exit;
  Identifier:=Item.Identifier;
  UnitFilename:=Item.UnitFile;
  GroupName:=Item.GroupName;
  GroupFilename:=Item.GroupFile;
  //debugln(['TCodyIdentifiersDlg.FindSelectedItem ',Identifier,' Unit=',UnitFilename,' Pkg=',GroupFilename]);
  Result:=true;
end;

function TCodyIdentifiersDlg.Init: boolean;
var
  ErrorHandled: boolean;
  Line: String;
  ImplNode: TCodeTreeNode;
begin
  Result:=true;
  CurInitError:=ParseTilCursor(CurTool, CurCleanPos, CurNode, ErrorHandled, false, @CurCodePos);

  CurIdentifier:='';
  CurIdentStart:=0;
  CurIdentEnd:=0;
  if (CurCodePos.Code<>nil) then begin
    Line:=CurCodePos.Code.GetLine(CurCodePos.Y-1,false);
    GetIdentStartEndAtPosition(Line,CurCodePos.X,CurIdentStart,CurIdentEnd);
    if CurIdentStart<CurIdentEnd then
      CurIdentifier:=copy(Line,CurIdentStart,CurIdentEnd-CurIdentStart);
  end;
  CurInImplementation:=false;
  if (CurNode<>nil) then begin
    ImplNode:=CurTool.FindImplementationNode;
    if (ImplNode<>nil) and (ImplNode.StartPos<=CurNode.StartPos)
    then
      CurInImplementation:=true;
  end;
  AddToImplementationUsesCheckBox.Enabled:=CurInImplementation;
  AddToImplementationUsesCheckBox.Checked:=
                                    CodyOptions.PreferImplementationUsesSection;

  CurSrcEdit:=SourceEditorManagerIntf.ActiveEditor;
  if CurTool<>nil then begin
    CurMainFilename:=CurTool.MainFilename;
    CurMainCode:=TCodeBuffer(CurTool.Scanner.MainCode);
  end else if CurSrcEdit<>nil then begin
    CurMainFilename:=CurSrcEdit.FileName;
    CurMainCode:=TCodeBuffer(CurSrcEdit.CodeToolsBuffer);
  end else begin
    CurMainFilename:='';
    CurMainCode:=nil;
  end;

  UpdateCurOwnerOfUnit;
  UpdateGeneralInfo;
  FLastFilter:='...'; // force one update
  if CurIdentifier<>'' then
    FilterEdit.Text:=CurIdentifier;
  IdleConnected:=true;
end;

procedure TCodyIdentifiersDlg.UseIdentifier;
var
  UnitSet: TFPCUnitSetCache;
  NewUnitInPath: Boolean;
  FPCSrcFilename: String;
  CompOpts: TLazCompilerOptions;
  UnitPathAdd: String;
  Pkg: TIDEPackage;
  CurUnitName: String;
  NewUnitName: String;
  SameUnitName: boolean;
  PkgDependencyAdded: boolean;
  NewUnitCode: TCodeBuffer;
  NewCode: TCodeBuffer;
  NewX: integer;
  NewY: integer;
  NewTopLine: integer;
  CurUnit: TUDUnit;
  NewUnitDir: String;

  function OpenDependency: boolean;
  // returns false to abort
  var
    DepOwner: TObject;
  begin
    debugln(['TCodyIdentifiersDlg.UseIdentifier not in unit path, loading package "'+NewGroupName+'", "'+NewGroupFilename+'" ...']);
    Result:=true;
    Pkg:=PackageEditingInterface.FindPackageWithName(NewGroupName);
    if (Pkg=nil) or (CompareFilenames(Pkg.Filename,NewGroupFilename)<>0) then
    begin
      if PackageEditingInterface.DoOpenPackageFile(NewGroupFilename,
        [pofDoNotOpenEditor],false)<>mrOK
      then begin
        debugln(['TCodyIdentifiersDlg.UseIdentifier: DoOpenPackageFile failed']);
        exit(false);
      end;
      Pkg:=PackageEditingInterface.FindPackageWithName(NewGroupName);
      if Pkg=nil then begin
        IDEMessageDialog(crsPackageNotFound,
          Format(crsPackageNotFoundItShouldBeIn, [NewGroupName, NewGroupFilename
            ]),
          mtError,[mbCancel]);
        exit(false);
      end;
    end;
    if PackageEditingInterface.IsOwnerDependingOnPkg(CurOwner,NewGroupName,DepOwner)
    then begin
      // already depending on package name
      PkgDependencyAdded:=true;
      debugln(['TCodyIdentifiersDlg.UseIdentifier owner is already using "'+NewGroupName+'"']);
      // ToDo: check version
    end;
  end;

  function AddDependency: boolean;
  // returns false to abort
  var
    OwnerList: TFPList;
    AddResult: TModalResult;
  begin
    if PkgDependencyAdded then exit(true);
    PkgDependencyAdded:=true;
    // add dependency
    OwnerList:=TFPList.Create;
    try
      OwnerList.Add(CurOwner);
      AddResult:=PackageEditingInterface.AddDependencyToOwners(OwnerList,Pkg,true);
      if AddResult=mrIgnore then exit(true);
      if AddResult<>mrOk then begin
        debugln(['TCodyIdentifiersDlg.UseIdentifier checking via AddDependencyToOwners failed for new package "'+NewGroupName+'"']);
        exit(false);
      end;
      if PackageEditingInterface.AddDependencyToOwners(OwnerList,Pkg,false)<>mrOK
      then begin
        debugln(['TCodyIdentifiersDlg.UseIdentifier AddDependencyToOwners failed for new package "'+NewGroupName+'"']);
        exit(false);
      end;
      debugln(['TCodyIdentifiersDlg.UseIdentifier added dependency "'+NewGroupName+'"']);
    finally
      OwnerList.Free;
    end;
    Result:=true;
  end;

begin
  if CurSrcEdit=nil then exit;

  UpdateCurOwnerOfUnit;

  // do some sanity checks
  NewUnitInPath:=false;
  UnitPathAdd:=ChompPathDelim(
    CreateRelativePath(CurOwnerDir,
                       ExtractFilePath(NewUnitFilename)));
  CurUnitName:=ExtractFileNameOnly(CurMainFilename);
  NewUnitName:=ExtractFileNameOnly(NewUnitFilename);
  FPCSrcFilename:='';
  Pkg:=nil;
  PkgDependencyAdded:=false;

  debugln(['TCodyIdentifiersDlg.UseIdentifier CurUnitName="',CurUnitName,'" NewUnitName="',NewUnitName,'"']);

  SameUnitName:=CompareDottedIdentifiers(PChar(CurUnitName),PChar(NewUnitName))=0;
  if SameUnitName and (CompareFilenames(CurMainFilename,NewUnitFilename)<>0)
  then begin
    // another unit with same name
    IDEMessageDialog(crsUnitNameClash,
      Format(crsTheTargetUnitHasTheSameNameAsTheCurrentUnitFreePas, [LineEnding]),
      mtError,[mbCancel]);
    exit;
  end;

  debugln(['TCodyIdentifiersDlg.UseIdentifier CurMainFilename="',CurMainFilename,'" NewUnitFilename="',NewUnitFilename,'"']);
  if CompareFilenames(CurMainFilename,NewUnitFilename)=0 then begin
    // same file
    NewUnitInPath:=true;
    debugln(['TCodyIdentifiersDlg.UseIdentifier same unit CurMainFilename="',CurMainFilename,'" NewUnitFilename="',NewUnitFilename,'"']);
  end
  else if (CompareFilenames(ExtractFilePath(CurMainFilename),
                            ExtractFilePath(NewUnitFilename))=0)
  then begin
    // same directory
    debugln(['TCodyIdentifiersDlg.UseIdentifier same directory CurMainFilename="',CurMainFilename,'" NewUnitFilename="',NewUnitFilename,'"']);
    NewUnitInPath:=true;
  end
  else if (CurUnitPath<>'')
  and FilenameIsAbsolute(NewUnitFilename) then begin
    NewUnitDir:=ExtractFilePath(NewUnitFilename);
    if (FindPathInSearchPath(PChar(NewUnitDir),length(NewUnitDir),
                             PChar(CurUnitPath),length(CurUnitPath))<>nil)
    then begin
      // in unit search path
      debugln(['TCodyIdentifiersDlg.UseIdentifier in unit search path of owner NewUnitDir="',NewUnitDir,'" CurUnitPath="',CurUnitPath,'"']);
      NewUnitInPath:=true;
    end else
      debugln(['TCodyIdentifiersDlg.UseIdentifier not in unitpath: NewUnitDir="',NewUnitDir,'"']);
  end;
  if not NewUnitInPath then
    debugln(['TCodyIdentifiersDlg.UseIdentifier not in unit path: CurMainFilename="',CurMainFilename,'" NewUnitFilename="',NewUnitFilename,'" CurUnitPath="',CurUnitPath,'"']);

  UnitSet:=CodeToolBoss.GetUnitSetForDirectory('');
  if not NewUnitInPath then begin
    // new unit is not in the projects/package unit path
    if NewGroupName=PackageNameFPCSrcDir then begin
      // new unit is a FPC unit
      debugln(['TCodyIdentifiersDlg.UseIdentifier in FPCSrcDir']);
      if UnitSet<>nil then
        FPCSrcFilename:=UnitSet.GetUnitSrcFile(ExtractFileNameOnly(NewUnitFilename));
      if FPCSrcFilename='' then begin
        // a FPC unit without a ppu file
        // => ask for confirmation
        if IDEQuestionDialog(crsFPCUnitWithoutPpu,
          crsThisUnitIsLocatedInTheFreePascalSourcesButNoPpuFil,
          mtConfirmation, [mrOk, crsExtendUnitPath, mrCancel])<> mrOk then exit;
      end else
        NewUnitInPath:=true;
    end else if NewGroupName=PackageNameDefault then begin
      // new unit is in default compiler unit path
      NewUnitInPath:=true;
    end else if NewGroupName<>'' then begin
      // new unit is part of a package
      debugln(['TCodyIdentifiersDlg.UseIdentifier unit is part of a package in "'+NewGroupFilename+'"']);
      Pkg:=PackageEditingInterface.FindPackageWithName(NewGroupName);
      if (Pkg<>nil) and (CompareFilenames(Pkg.Filename,NewGroupFilename)<>0) then
      begin
        if Pkg=CurOwner then begin
          IDEMessageDialog(crsImpossibleDependency,
            Format(crsTheUnitIsPartOfItCanNotUseAnotherPackageWithTheSam, [CurMainFilename,
                LineEnding, Pkg.Filename, LineEnding, LineEnding, NewGroupFilename]),
            mtError, [mbCancel]);
          exit;
        end;
        if IDEQuestionDialog(crsPackageWithSameName,
          Format(crsThereIsAlreadyAnotherPackageLoadedWithTheSameNameO, [LineEnding,
            Pkg.Filename, LineEnding, NewGroupFilename, LineEnding]),
          mtConfirmation, [mrCancel, crsBTNCancel,
                           mrOk, crsCloseOtherPackageAndOpenNew]) <> mrOk
        then exit;
      end;
    end;
    if not NewUnitInPath then begin
      // new unit is a rogue unit (no package)
      debugln(['TCodyIdentifiersDlg.UseIdentifier unit is not in a package']);
      if UnitSet.GetUnitToSourceTree(false).Contains(NewUnitName) then
        NewUnitInPath:=true;
    end;
  end;

  // open package to get the compiler settings to parse the unit
  if (CurOwner<>nil)
  and (not NewUnitInPath)
  and (NewGroupName<>'')
  and (NewGroupName<>PackageNameFPCSrcDir)
  and (NewGroupName<>PackageNameDefault) then begin
    if not OpenDependency then exit;
  end;

  // check if target unit is readable
  NewUnitCode:=CodeToolBoss.LoadFile(NewUnitFilename,true,false);
  if NewUnitCode=nil then begin
    IDEMessageDialog(crsFileReadError,
      Format(crsUnableToReadFile, [NewUnitFilename]),
      mtError,[mbCancel]);
    exit;
  end;

  // check if identifier still exist
  if not CodeToolBoss.FindDeclarationInInterface(NewUnitCode,NewIdentifier,
    NewCode, NewX, NewY, NewTopLine)
  then begin
    IDEMessageDialog(crsIdentifierNotFound,
      Format(crsIdentifierNotFoundInUnit, [NewIdentifier, NewUnitFilename]),
      mtError,[mbCancel]);
    exit;
  end;

  CurSrcEdit.BeginUndoBlock{$IFDEF SynUndoDebugBeginEnd}('TCodyIdentifiersDlg.UseIdentifier'){$ENDIF};
  try
    // insert or replace identifier
    if (not CurSrcEdit.SelectionAvailable)
    and (CurIdentStart<CurIdentEnd) then
      CurSrcEdit.SelectText(CurCodePos.Y,CurIdentStart,CurCodePos.Y,CurIdentEnd);
    CurSrcEdit.Selection:=NewIdentifier;

    debugln(['TCodyIdentifiersDlg.UseIdentifier CurOwner=',DbgSName(CurOwner),' ',NewUnitInPath]);
    if (CurOwner<>nil) and (not NewUnitInPath) then begin
      debugln(['TCodyIdentifiersDlg.UseIdentifier not in unit path, connecting pkg="',NewGroupName,'" ...']);
      if (NewGroupName<>'') then begin
        // add dependency
        if (NewGroupName<>PackageNameFPCSrcDir)
        and (NewGroupName<>PackageNameDefault)
        then
          if not AddDependency then exit;
      end else if FilenameIsAbsolute(NewUnitFilename)
      and FilenameIsAbsolute(CurMainFilename) then begin
        // extend unit path
        CompOpts:=GetCurOwnerCompilerOptions;
        if CompOpts<>nil then begin
          CompOpts.OtherUnitFiles:=CompOpts.OtherUnitFiles+';'+UnitPathAdd;
        end;
      end;
    end;

    if not SameUnitName then
      AddToUsesSection(true);
  finally
    CurSrcEdit.EndUndoBlock{$IFDEF SynUndoDebugBeginEnd}('TCodyIdentifiersDlg.UseIdentifier'){$ENDIF};
  end;

  CurUnit:=CodyUnitDictionary.FindUnitWithFilename(NewUnitFilename);
  if CurUnit<>nil then
    CodyUnitDictionary.IncreaseUnitUseCount(CurUnit);
end;

procedure TCodyIdentifiersDlg.JumpToIdentifier;
var
  NewUnitCode: TCodeBuffer;
  NewCode: TCodeBuffer;
  NewX: integer;
  NewY: integer;
  NewTopLine: integer;
  Pkg: TIDEPackage;
begin
  if not FileExistsUTF8(NewUnitFilename) then begin
    IDEMessageDialog(crsFileNotFound,
      Format(crsFileDoesNotExistAnymore, [NewUnitFilename]),
      mtError,[mbCancel]);
    exit;
  end;

  // open package to get proper settings
  if (NewGroupName<>'')
  and (NewGroupName<>PackageNameFPCSrcDir)
  and (NewGroupName<>PackageNameDefault) then begin
    Pkg:=PackageEditingInterface.FindPackageWithName(NewGroupName);
    if (Pkg=nil) or (CompareFilenames(Pkg.Filename,NewGroupFilename)<>0) then
    begin
      if PackageEditingInterface.DoOpenPackageFile(NewGroupFilename,
        [pofAddToRecent],true)=mrAbort
      then
        exit;
    end;
  end;

  // load file
  NewUnitCode:=CodeToolBoss.LoadFile(NewUnitFilename,true,false);
  if NewUnitCode=nil then begin
    IDEMessageDialog(crsFileReadError,
      Format(crsUnableToReadFile, [NewUnitFilename]),
      mtError,[mbCancel]);
    exit;
  end;

  if not CodeToolBoss.FindDeclarationInInterface(NewUnitCode,NewIdentifier,
    NewCode, NewX, NewY, NewTopLine)
  then begin
    IDEMessageDialog(crsIdentifierNotFound,
      Format(crsIdentifierNotFoundInUnit, [NewIdentifier, NewUnitFilename]),
      mtError,[mbCancel]);
    exit;
  end;

  LazarusIDE.DoOpenFileAndJumpToPos(NewCode.Filename,Point(NewX,NewY),NewTopLine,
    -1,-1,[ofDoNotLoadResource]);
end;

function TCodyIdentifiersDlg.OwnerToString(AnOwner: TObject): string;
begin
  Result:='nil';
  if AnOwner is TLazProject then
    Result:='project'
  else if AnOwner is TIDEPackage then
    Result:=TIDEPackage(AnOwner).Name;
end;

function TCodyIdentifiersDlg.GetFilterType: TCodyIdentifierFilter;
begin
  if ContainsRadioButton.Checked then
    exit(cifContains)
  else
    exit(cifStartsWith);
end;

procedure TCodyIdentifiersDlg.UpdateCurOwnerOfUnit;

  procedure GetBest(OwnerList: TFPList);
  var
    i: Integer;
  begin
    if OwnerList=nil then exit;
    for i:=0 to OwnerList.Count-1 do begin
      if (TObject(OwnerList[i]) is TLazProject)
      or ((TObject(OwnerList[i]) is TIDEPackage) and (CurOwner=nil)) then
        CurOwner:=TObject(OwnerList[i]);
    end;
    OwnerList.Free;
  end;

var
  CompOpts: TLazCompilerOptions;
begin
  CurOwner:=nil;
  CurUnitPath:='';
  CurOwnerDir:='';
  if CurMainFilename='' then exit;
  GetBest(PackageEditingInterface.GetOwnersOfUnit(CurMainFilename));
  if CurOwner=nil then
    GetBest(PackageEditingInterface.GetPossibleOwnersOfUnit(CurMainFilename,
             [piosfExcludeOwned,piosfIncludeSourceDirectories]));
  if CurOwner<>nil then begin
    CompOpts:=GetCurOwnerCompilerOptions;
    if CompOpts<>nil then
      CurUnitPath:=CompOpts.GetUnitPath(false);
    if CurOwner is TIDEProjPackBase then
      CurOwnerDir:= TIDEProjPackBase(CurOwner).Directory;
  end;
end;

procedure TCodyIdentifiersDlg.AddToUsesSection(JumpToSrcError: boolean);
var
  NewUnitCode: TCodeBuffer;
  NewUnitName: String;
  CurUnitName: String;
  UsesNode: TCodeTreeNode;
begin
  if (CurTool=nil) or (NewUnitFilename='') then begin
    debugln(['TCodyIdentifiersDlg.AddToUsesSection failed: no tool']);
    exit;
  end;
  UpdateTool(JumpToSrcError);
  if (CurNode=nil) then begin
    debugln(['TCodyIdentifiersDlg.AddToUsesSection failed: no node']);
    exit;
  end;

  // check if already in uses section
  NewUnitName:=ExtractFileNameOnly(NewUnitFilename);
  if CurTool.IsHiddenUsedUnit(PChar(NewUnitName)) then begin
    debugln(['TCodyIdentifiersDlg.AddToUsesSection "',NewUnitName,'" is hidden used unit']);
    exit;
  end;
  UsesNode:=CurTool.FindMainUsesNode;
  if (UsesNode<>nil) and (CurTool.FindNameInUsesSection(UsesNode,NewUnitName)<>nil)
  then begin
    debugln(['TCodyIdentifiersDlg.AddToUsesSection "',NewUnitName,'" is already used in main uses section']);
    exit;
  end;
  if CurInImplementation then begin
    UsesNode:=CurTool.FindImplementationUsesNode;
    if (UsesNode<>nil) and (CurTool.FindNameInUsesSection(UsesNode,NewUnitName)<>nil)
    then begin
      debugln(['TCodyIdentifiersDlg.AddToUsesSection "',NewUnitName,'" is already used in implementation uses section']);
      exit;
    end;
  end;

  // get unit name
  NewUnitCode:=CodeToolBoss.LoadFile(NewUnitFilename,true,false);
  if NewUnitCode=nil then begin
    debugln(['TCodyIdentifiersDlg.AddToUsesSection failed: unable to load file "',NewUnitFilename,'"']);
    exit;
  end;
  NewUnitName:=CodeToolBoss.GetSourceName(NewUnitCode,false);
  if NewUnitName='' then
    NewUnitName:=ExtractFileNameOnly(NewUnitFilename);
  CurUnitName:=ExtractFileNameOnly(CurMainFilename);
  if CompareDottedIdentifiers(PChar(CurUnitName),PChar(NewUnitName))=0 then begin
    debugln(['TCodyIdentifiersDlg.AddToUsesSection same unit']);
    exit; // is the same unit
  end;

  if (CurNode.Desc in [ctnUnit,ctnUsesSection]) then begin
    debugln(['TCodyIdentifiersDlg.AddToUsesSection identifier in uses section, not adding unit to uses section']);
    exit;
  end;

  // add to uses section
  debugln(['TCodyIdentifiersDlg.AddToUsesSection adding to uses section']);
  if CurInImplementation and AddToImplementationUsesCheckBox.Checked then
    CodeToolBoss.AddUnitToImplementationUsesSection(CurMainCode,NewUnitName,'')
  else
    CodeToolBoss.AddUnitToMainUsesSection(CurMainCode,NewUnitName,'');
  if CodeToolBoss.ErrorMessage<>'' then
    LazarusIDE.DoJumpToCodeToolBossError;
end;

function TCodyIdentifiersDlg.UpdateTool(JumpToSrcError: boolean): boolean;
var
  Tool: TCodeTool;
begin
  Result:=false;
  if (CurTool=nil) or (NewUnitFilename='') then exit;
  if not LazarusIDE.BeginCodeTools then exit;
  try
    CurTool.BuildTree(lsrEnd);
  except
  end;
  CurNode:=CurTool.FindDeepestNodeAtPos(CurCleanPos,false);
  if CurNode<>nil then
    Result:=true
  else if JumpToSrcError then begin
    CodeToolBoss.Explore(CurCodePos.Code,Tool,false);
    if CodeToolBoss.ErrorCode=nil then
      IDEMessageDialog(crsCaretOutsideOfCode, CurTool.CleanPosToStr(
        CurCleanPos, true),
        mtError,[mbOk])
    else
      LazarusIDE.DoJumpToCodeToolBossError;
  end;
end;

function TCodyIdentifiersDlg.AddButton: TBitBtn;
begin
  Result := TBitBtn.Create(Self);
  Result.Align := alCustom;
  Result.Default := false;
  Result.Constraints.MinWidth:=25;
  Result.AutoSize := true;
  Result.Parent := ButtonPanel1;
end;

function TCodyIdentifiersDlg.GetCurOwnerCompilerOptions: TLazCompilerOptions;
begin
  if CurOwner is TLazProject then
    Result:=TLazProject(CurOwner).LazCompilerOptions
  else if CurOwner is TIDEPackage then
    Result:=TIDEPackage(CurOwner).LazCompilerOptions
  else
    Result:=nil;
end;

finalization
  FreeAndNil(CodyUnitDictionary);

end.

