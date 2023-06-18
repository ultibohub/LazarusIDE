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
    Dialog to show information about the message
      "recompiling unit1, checksum changed for unit2"

  ToDo:
    - show the location(s) of the first unit
    - show the location(s) of the second unit
    - actions:
      - open a source file
      - open a package
      - delete a ppu+o file
      - recompile a package clean (remove the .compiled file)
}
unit InspectChksumChangedDlg;

{$mode objfpc}{$H+}

interface

uses
  // RTL + FCL
  Classes, SysUtils, Contnrs,
  // LCL
  Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, ButtonPanel,
  // CodeTools
  CodeToolManager, FileProcs, DirectoryCacher, DefineTemplates,
  // LazUtils
  LazFileUtils, LazFileCache,
  // IDEIntf
  TextTools, IDEMsgIntf, PackageIntf, ProjectIntf, IDEExternToolIntf,
  // IDE
  LazarusIDEStrConsts;

const
  ICC_FPC = '#FPC unit search path';
  ICC_Project = '#Project';
type
  TInspectChksumChgDialog = class;

  { TICCAction }

  TICCAction = class
  public
    Dlg: TInspectChksumChgDialog;
    Caption: string;
    constructor Create(aDlg: TInspectChksumChgDialog; aCaption: string);
  end;

  { TICCFile }

  TICCFile = class(TComponent)
  public
    Filename: string;
    Age: integer;
    OwnerNames: TStringList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  { TICCFiles }

  TICCFiles = class(TComponentList)
  private
    function GetFiles(Index: integer): TICCFile;
    procedure SetFiles(Index: integer; const AValue: TICCFile);
  public
    property Files[Index: integer]: TICCFile read GetFiles write SetFiles; default;
  end;

  { TInspectChksumChgDialog }

  TInspectChksumChgDialog = class(TForm)
    ButtonPanel1: TButtonPanel;
    InfoGroupBox: TGroupBox;
    ProgressBar1: TProgressBar;
    ActionsRadioGroup: TRadioGroup;
    Splitter1: TSplitter;
    InfoTreeView: TTreeView;
    procedure CancelClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FMsg: string;
    FUnit1: string;
    FUnit1Files: TICCFiles;
    FUnit2: string;
    FUnit2Files: TICCFiles;
    procedure FindUnitOwnerNames(aFile: TICCFile);
    procedure SearchDirectory(anUnitName: string; Dir: string;
                              IsFPCPath: boolean; Files: TICCFiles);
    procedure SearchInFPCFiles(anUnitName: string; Files: TICCFiles);
    procedure SearchInSearchPath(anUnitName, SearchPath: string; Files: TICCFiles);
    function SearchUnit(anUnitName, SearchPath: string): TICCFiles;
    procedure AddNodesForUnit(anUnitName: string; Files: TICCFiles);
  public
    procedure InitWithMsg(const aMsg, aUnitName1, aUnitName2: string);
    property Msg: string read FMsg;
    property Unit1: string read FUnit1;
    property Unit2: string read FUnit2;
    property Unit1Files: TICCFiles read FUnit1Files;
    property Unit2Files: TICCFiles read FUnit2Files;
  end;

type
  { TQuickFixRecompilingChecksumChanged }

  TQuickFixRecompilingChecksumChanged = class(TMsgQuickFix)
  public
    function IsApplicable(Msg: TMessageLine; out Unitname1, Unitname2: string): boolean;
    procedure CreateMenuItems(Fixes: TMsgQuickFixes); override;
    procedure QuickFix({%H-}Fixes: TMsgQuickFixes; Msg: TMessageLine); override;
  end;

procedure InitInspectChecksumChangedQuickFixItems;

implementation

procedure InitInspectChecksumChangedQuickFixItems;
begin
  RegisterIDEMsgQuickFix(TQuickFixRecompilingChecksumChanged.Create);
end;

{ TICCFile }

constructor TICCFile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OwnerNames:=TStringList.Create;
end;

destructor TICCFile.Destroy;
begin
  FreeAndNil(OwnerNames);
  inherited Destroy;
end;

{ TICCFiles }

function TICCFiles.GetFiles(Index: integer): TICCFile;
begin
  Result:=TICCFile(Items[Index]);
end;

procedure TICCFiles.SetFiles(Index: integer; const AValue: TICCFile);
begin
  Items[Index]:=AValue;
end;

{ TICCAction }

constructor TICCAction.Create(aDlg: TInspectChksumChgDialog; aCaption: string);
begin
  Dlg:=aDlg;
  Caption:=aCaption;
end;

{$R *.lfm}

{ TInspectChksumChgDialog }

procedure TInspectChksumChgDialog.FormCreate(Sender: TObject);
begin
  Caption:='Inspect checksum changed message';
  InfoGroupBox.Caption:='Hints:';
  ActionsRadioGroup.Caption:='Actions';

  ButtonPanel1.OKButton.OnClick:=@OkClick;
  ButtonPanel1.CancelButton.OnClick:=@CancelClick;
  ProgressBar1.Visible:=false;
end;

procedure TInspectChksumChgDialog.OkClick(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

procedure TInspectChksumChgDialog.CancelClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TInspectChksumChgDialog.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FUnit1Files);
  FreeAndNil(FUnit2Files);
end;

procedure TInspectChksumChgDialog.FindUnitOwnerNames(aFile: TICCFile);
var
  Owners: TFPList;
  i: Integer;
begin
  Owners:=PackageEditingInterface.GetPossibleOwnersOfUnit(aFile.Filename,
                                               [piosfIncludeSourceDirectories]);
  //debugln(['TInspectChksumChgDialog.FindUnitOwnerNames ',aFile.Filename,' ',DbgSName(Owners)]);
  if Owners<>nil then begin
    for i:=0 to Owners.Count-1 do begin
      if TObject(Owners[i]) is TIDEPackage then
        aFile.OwnerNames.Add(TIDEPackage(Owners[i]).Name)
      else if TObject(Owners[i]) is TLazProject then
        aFile.OwnerNames.Add(ICC_Project);
    end;
    Owners.Free;
  end;
end;

procedure TInspectChksumChgDialog.SearchDirectory(anUnitName: string;
  Dir: string; IsFPCPath: boolean; Files: TICCFiles);
var
  DirCache: TCTDirectoryCache;
  i: Integer;
  Filename: PChar;
  aFile: TICCFile;
  j: Integer;
begin
  if (Dir='') or (not FilenameIsAbsolute(Dir)) then exit;
  // search in directory for all files that could be sources or ppu files of this unit
  DirCache:=CodeToolBoss.DirectoryCachePool.GetCache(Dir,true,false);
  if (DirCache=nil) or (DirCache.Listing=nil) then exit;
  for i:=0 to DirCache.Listing.Count-1 do begin
    Filename:=DirCache.Listing.GetFilename(i);
    if FilenameExtIn(Filename,['.pas','.pp','.p','.ppu'])
    and (CompareText(anUnitName,ExtractFileNameOnly(Filename))=0)
    then begin
      j:=Files.Count-1;
      while (j>=0) and (CompareFilenames(Files[j].Filename,Filename)<>0) do
        dec(j);
      if j<0 then begin
        //debugln(['TInspectChksumChgDialog.SearchUnit Unit="',anUnitName,'" Filename="',Filename,'"']);
        aFile:=TICCFile.Create(nil);
        aFile.Filename:=AppendPathDelim(Dir)+Filename;
        aFile.Age:=FileAgeCached(aFile.Filename);
        FindUnitOwnerNames(aFile);
        if IsFPCPath then
          aFile.OwnerNames.Add(ICC_FPC);
        Files.Add(aFile);
      end;
    end;
  end;
end;

procedure TInspectChksumChgDialog.SearchInSearchPath(anUnitName,
  SearchPath: string; Files: TICCFiles);
var
  CurDir: String;
  p: LongInt;
  l: Integer;
  StartPos: Integer;
begin
  // search in search path
  StartPos:=1;
  l:=length(SearchPath);
  while StartPos<=l do begin
    p:=StartPos;
    while (p<=l) and (SearchPath[p]<>';') do inc(p);
    CurDir:=TrimFilename(copy(SearchPath,StartPos,p-StartPos));
    SearchDirectory(anUnitName,CurDir,false,Files);
    StartPos:=p+1;
  end;
end;

procedure TInspectChksumChgDialog.SearchInFPCFiles(
  anUnitName: string; Files: TICCFiles);
var
  UnitSetID: String;
  UnitSet: TFPCUnitSetCache;
  CfgCache: TPCTargetConfigCache;
  i: Integer;
  HasChanged: boolean;
  CurDir: String;
begin
  // search in fpc unit paths
  UnitSetID:=CodeToolBoss.GetUnitSetIDForDirectory('');
  if UnitSetID='' then exit;
  UnitSet:=CodeToolBoss.CompilerDefinesCache.FindUnitSetWithID(UnitSetID,HasChanged,false);
  if UnitSet=nil then exit;
  CfgCache:=UnitSet.GetConfigCache(false);
  if CfgCache=nil then exit;
  if CfgCache.UnitPaths=nil then exit;
  for i:=0 to CfgCache.UnitPaths.Count-1 do begin
    CurDir:=TrimFilename(CfgCache.UnitPaths[i]);
    SearchDirectory(anUnitName,CurDir,false,Files);
  end;
end;

function TInspectChksumChgDialog.SearchUnit(anUnitName, SearchPath: string
  ): TICCFiles;
begin
  Result:=TICCFiles.create(true);
  if (anUnitName='') then exit;

  SearchInSearchPath(anUnitName,SearchPath,Result);
  SearchInFPCFiles(anUnitName,Result);
end;

procedure TInspectChksumChgDialog.AddNodesForUnit(anUnitName: string;
  Files: TICCFiles);
var
  UnitNode: TTreeNode;
  i: Integer;
  aFile: TICCFile;
  FileNode: TTreeNode;
  OwnerName: string;
  j: Integer;
  s: String;
  APackage: TIDEPackage;
  PPUCount: Integer;
  SrcCount: Integer;
begin
  UnitNode:=InfoTreeView.Items.Add(nil,'Unit '+anUnitName);
  if Files<>nil then begin
    PPUCount:=0;
    SrcCount:=0;
    FileNode:=nil;
    for i:=0 to Files.Count-1 do begin
      aFile:=Files[i];
      if FilenameExtIs(aFile.Filename,'ppu',true) then
        inc(PPUCount)
      else
        inc(SrcCount);
      FileNode:=InfoTreeView.Items.AddChildObject(UnitNode,aFile.Filename,aFile);
      for j:=0 to aFile.OwnerNames.Count-1 do begin
        OwnerName:=aFile.OwnerNames[j];
        if OwnerName=ICC_FPC then begin
          s:=lisInFPCUnitSearchPathProbablyInstalledByTheFPCPackag;
        end else if OwnerName=ICC_Project then begin
          s:=lisInASourceDirectoryOfTheProjectCheckForDuplicates;
        end else begin
          s:=Format(lisInASourceDirectoryOfThePackage, [OwnerName]);
          APackage:=PackageEditingInterface.FindPackageWithName(OwnerName);
          if APackage<>nil then begin
            if APackage.IsVirtual then begin
              s:=Format(lisCheckTheTargetOSCPULCLWidgetTypeMaybeYouHaveToReco, [s]);
            end else begin
              s:=Format(lisMaybeYouHaveToRecompileThePackage, [s]);
            end;
          end;
        end;
        if s<>'' then
          InfoTreeView.Items.AddChild(FileNode,s);
      end;
    end;
    if PPUCount>1 then begin
      // ToDo: Fix uninitialized FileNode. It is initialized inside a loop, this is outside of the loop.
      InfoTreeView.Items.AddChild(FileNode,
        lisDuplicatePpuFilesDeleteOneOrMakeSureAllSearchPaths);
    end;
    if SrcCount>1 then begin
      InfoTreeView.Items.AddChild(FileNode,
        lisDuplicateSourcesDeleteOneOrMakeSureAllSearchPathsH);
    end;
  end;
  UnitNode.Expand(true);
end;

procedure TInspectChksumChgDialog.InitWithMsg(const aMsg, aUnitName1,
  aUnitName2: string);
var
  SearchPath: String;
begin
  FMsg:=aMsg;
  FUnit1:=aUnitName1;
  FUnit2:=aUnitName2;
  FreeAndNil(FUnit1Files);
  FreeAndNil(FUnit2Files);

  SearchPath:=CodeToolBoss.GetCompleteSrcPathForDirectory('');
  //debugln(['TInspectChksumChgDialog.InitWithMsg SearchPath=',SearchPath]);
  FUnit1Files:=SearchUnit(Unit1,SearchPath);
  FUnit2Files:=SearchUnit(Unit2,SearchPath);

  InfoTreeView.BeginUpdate;
  InfoTreeView.Items.Clear;

  InfoTreeView.Items.Add(nil,'Message: '+dbgstr(Msg));

  AddNodesForUnit(Unit1,Unit1Files);
  AddNodesForUnit(Unit2,Unit2Files);

  InfoTreeView.EndUpdate;
end;

{ TQuickFixRecompilingChecksumChanged }

function TQuickFixRecompilingChecksumChanged.IsApplicable(Msg: TMessageLine;
  out Unitname1, Unitname2: string): boolean;
begin
  // check: Recompiling $1, checksum changed for $2
  Result:=IDEFPCParser.MsgLineIsId(Msg,10028,Unitname1,Unitname2);
end;

procedure TQuickFixRecompilingChecksumChanged.CreateMenuItems(
  Fixes: TMsgQuickFixes);
var
  Msg: TMessageLine;
  Unitname1: string;
  Unitname2: string;
  i: Integer;
begin
  for i:=0 to Fixes.LineCount-1 do begin
    Msg:=Fixes.Lines[i];
    if not IsApplicable(Msg,Unitname1,Unitname2) then continue;
    Fixes.AddMenuItem(Self,Msg,'Explore message "checksum changed"');
    exit;
  end;
end;

procedure TQuickFixRecompilingChecksumChanged.QuickFix(Fixes: TMsgQuickFixes;
  Msg: TMessageLine);
var
  Unit1: String;
  Unit2: String;
  Dlg: TInspectChksumChgDialog;
begin
  if not IsApplicable(Msg,Unit1,Unit2) then exit;
  debugln(['TQuickFixRecompilingChecksumChanged.Execute Unit1=',REVar(1),', checksum changed for Unit2=',REVar(2)]);
  Dlg:=TInspectChksumChgDialog.Create(nil);
  try
    Dlg.InitWithMsg(Msg.Msg,Unit1,Unit2);
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

end.

