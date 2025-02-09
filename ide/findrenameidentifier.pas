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
    Options dialog and methods for finding and renaming identifier references.
}
unit FindRenameIdentifier;

{$mode objfpc}{$H+}

interface

uses
  // RTL + FCL
  Classes, SysUtils, AVL_Tree, Contnrs,
  // LCL
  Forms, Controls, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ButtonPanel, LclIntf, Graphics,
  // CodeTools
  IdentCompletionTool, KeywordFuncLists, CTUnitGraph, CodeTree, CodeAtom, LinkScanner,
  CodeCache, CodeToolManager, BasicCodeTools,
  // LazUtils
  LazFileUtils, LazFileCache, laz2_DOM, LazStringUtils, AvgLvlTree, LazLoggerBase,
  // IdeIntf
  IdeIntfStrConsts, LazIDEIntf, IDEWindowIntf, SrcEditorIntf, PackageIntf,
  IDEDialogs, InputHistory,
  // IdeUtils
  DialogProcs,
  // LazConfig
  TransferMacros, IDEProcs, SearchPathProcs,
  // IDE
  LazarusIDEStrConsts, MiscOptions, CodeToolsOptions, SearchResultView, CodeHelp, CustomCodeTool,
  FindDeclarationTool, ChangeDeclarationTool, SourceFileManager, Project;

type

  { TFindRenameIdentifierDialog }

  TFindRenameIdentifierDialog = class(TForm)
    ButtonPanel1: TButtonPanel;
    ScopeOverridesCheckBox: TCheckBox;
    ShowResultCheckBox: TCheckBox;
    CurrentGroupBox: TGroupBox;
    CurrentListBox: TListBox;
    ExtraFilesEdit: TEdit;
    ExtraFilesGroupBox: TGroupBox;
    NewEdit: TEdit;
    NewGroupBox: TGroupBox;
    RenameCheckBox: TCheckBox;
    ScopeCommentsCheckBox: TCheckBox;
    ScopeGroupBox: TGroupBox;
    ScopeRadioGroup: TRadioGroup;
    procedure FindOrRenameButtonClick(Sender: TObject);
    procedure FindRenameIdentifierDialogClose(Sender: TObject;
      var {%H-}CloseAction: TCloseAction);
    procedure FindRenameIdentifierDialogCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure RenameCheckBoxChange(Sender: TObject);
    procedure ValidateNewName(Sender: TObject);
  private
    FAllowRename: boolean;
    FIdentifierFilename: string;
    FIdentifierPosition: TPoint;
    FOldIdentifier: string;
    FNewIdentifier: string;
    FForbidden: TStringList; // already defined identifiers in scope
    FIsPrivate: boolean;
    FNode: TCodeTreeNode;
    FTool: TCustomCodeTool;
    FFiles: TStringList;
    procedure SetAllowRename(const AValue: boolean);
    procedure SetIsPrivate(const AValue: boolean);
    procedure SetFiles(const Files:TStringList);
    procedure UpdateRename;
    procedure GatherFiles;
    function NewIdentifierIsConflicted(var ErrMsg: string): boolean;
  public
    destructor Destroy; override;
    procedure LoadFromConfig;
    procedure SaveToConfig;
    procedure LoadFromOptions(Options: TFindRenameIdentifierOptions);
    procedure SaveToOptions(Options: TFindRenameIdentifierOptions);
    procedure SetIdentifier(const NewIdentifierFilename: string;
                            var NewIdentifierPosition: TPoint);

    property IdentifierFilename: string read FIdentifierFilename;
    property IdentifierPosition: TPoint read FIdentifierPosition;
    property AllowRename: boolean read FAllowRename write SetAllowRename;
    property IsPrivate: boolean read FIsPrivate write SetIsPrivate;
  end;

function ShowFindRenameIdentifierDialog(const Filename: string;
  var Position: TPoint;
  AllowRename: boolean; // allow user to disable/enable rename
  SetRenameActive: boolean; // check rename
  Options: TFindRenameIdentifierOptions): TModalResult;
function DoFindRenameIdentifier(
  AllowRename: boolean; // allow user to disable/enable rename
  SetRenameActive: boolean; // check rename
  Options: TFindRenameIdentifierOptions): TModalResult;
function GatherIdentifierReferences(Files: TStringList;
  const DeclCodeXY: TCodeXYPosition;
  DeclTool: TCodeTool; // can be nil
  DeclNode: TCodeTreeNode; // can be nil
  SearchInComments: boolean;
  out ListOfSrcNameRefs: TObjectList; const Flags: TFindRefsFlags): boolean;
function ShowIdentifierReferences(
  DeclFilename: string;
  ListOfSrcNameRefs: TObjectList;
  Identifier: string; RenameTo: string = ''): TModalResult;
procedure AddReferencesToResultView(Identifier: string; ListOfSrcNameRefs: TObjectList;
  ClearItems: boolean; SearchPageIndex: integer);

function GatherFPDocReferencesForPascalFiles(PascalFiles: TStringList;
  DeclarationCode: TCodeBuffer; const DeclarationCaretXY: TPoint;
  var ListOfLazFPDocNode: TFPList): TModalResult;
function GatherReferencesInFPDocFile(
  const OldPackageName, OldModuleName, OldElementName: string;
  const FPDocFilename: string;
  var ListOfLazFPDocNode: TFPList): TModalResult;
function RenameUnitFromFileName(OldFileName: string; NewUnitName: string):
  TModalResult;
function ShowSaveProject(NewProjectName: string): TModalResult;
function EnforceAmp(AmpString: string): string;

implementation

{$R *.lfm}

function ShowFindRenameIdentifierDialog(const Filename: string;
  var Position: TPoint; AllowRename: boolean; SetRenameActive: boolean;
  Options: TFindRenameIdentifierOptions): TModalResult;
var
  FindRenameIdentifierDialog: TFindRenameIdentifierDialog;
begin
  FindRenameIdentifierDialog:=TFindRenameIdentifierDialog.Create(nil);
  try
    FindRenameIdentifierDialog.LoadFromConfig;
    FindRenameIdentifierDialog.SetIdentifier(Filename,Position);
    FindRenameIdentifierDialog.AllowRename:=AllowRename;
    FindRenameIdentifierDialog.RenameCheckBox.Checked:=SetRenameActive and AllowRename;
    if Options<>nil then
      FindRenameIdentifierDialog.ShowResultCheckBox.Checked:=Options.RenameShowResult and AllowRename;
    Result:=FindRenameIdentifierDialog.ShowModal;
    if Result=mrOk then
      if Options<>nil then
        FindRenameIdentifierDialog.SaveToOptions(Options);
  finally
    FindRenameIdentifierDialog.Free;
    FindRenameIdentifierDialog:=nil;
  end;
end;

function GetDeclCodeNode(const DeclCodeXY: TCodeXYPosition; out DeclTool: TCodeTool;
  out DeclNode: TCodeTreeNode; out DeclCleanPos: integer): boolean;

  procedure Err(id: int64; Msg: string);
  begin
    Msg:='DoFindRenameIdentifier: '+Msg;
    debugln(['Error: ',DeclCodeXY.Code.Filename,'(',DeclCodeXY.Y,',',DeclCodeXY.X,') [',id,'] ',Msg]);
    CodeToolBoss.SetError(id,DeclCodeXY.Code,DeclCodeXY.Y,DeclCodeXY.X,Msg);
    LazarusIDE.DoJumpToCodeToolBossError;
  end;

begin
  Result:=false;
  DeclTool:=nil;
  DeclNode:=nil;
  if DeclCodeXY.Code=nil then exit;
  CodeToolBoss.Explore(DeclCodeXY.Code,DeclTool,false);
  if DeclTool=nil then begin
    debugln(['Error: (lazarus) [20250206142319] DoFindRenameIdentifier CodeToolBoss.Explore failed']);
    LazarusIDE.DoJumpToCodeToolBossError;
    exit;
  end;
  if DeclTool.CaretToCleanPos(DeclCodeXY,DeclCleanPos)<>0 then begin
    Err(20250206143746,'position not in Pascal');
    exit;
  end;
  DeclNode:=DeclTool.FindDeepestNodeAtPos(DeclCleanPos,false);
  if DeclNode=nil then begin
    Err(20250206143807,'no Pascal node');
    exit;
  end;
  if (DeclNode.Desc=ctnIdentifier)
      and (DeclNode.Parent.Desc in [ctnSrcName,ctnUseUnitClearName,ctnUseUnitNamespace]) then
    DeclNode:=DeclNode.Parent;

  Result:=true;
end;

function DoFindRenameIdentifier(AllowRename: boolean; SetRenameActive: boolean;
  Options: TFindRenameIdentifierOptions): TModalResult;
var
  DeclCleanPos: integer;
  DeclTool: TCodeTool;
  DeclNode: TCodeTreeNode;
  DeclCodeXY: TCodeXYPosition;

  procedure Err(id: int64; Msg: string);
  begin
    Msg:='DoFindRenameIdentifier: '+Msg;
    debugln(['Error: ',DeclCodeXY.Code.Filename,'(',DeclCodeXY.Y,',',DeclCodeXY.X,') [',id,'] ',Msg]);
    CodeToolBoss.SetError(id,DeclCodeXY.Code,DeclCodeXY.Y,DeclCodeXY.X,Msg);
    LazarusIDE.DoJumpToCodeToolBossError;
  end;

  function UpdateCodeNode: boolean;
  begin
    Result:=GetDeclCodeNode(DeclCodeXY,DeclTool,DeclNode,DeclCleanPos);
  end;

  function CheckUsesNode: boolean;
  var
    InFilename, aUnitName, Dir, Filename: string;
    NewCode: TCodeBuffer;
    NewTool: TCodeTool;
    NamePos: TAtomPosition;
    CodeXYPos, NewDeclCodeXY: TCodeXYPosition;
  begin
    if not (DeclNode.Desc in [ctnUseUnitNamespace,ctnUseUnitClearName]) then
      exit(true);
    // renaming a uses -> rename the unit
    // find unit
    Result:=false;
    aUnitName:=DeclTool.ExtractUsedUnitName(DeclNode.Parent,@InFilename);
    if aUnitName='' then begin
      Err(20250206143851,'ExtractUsedUnitName failed');
      exit;
    end;
    Dir:=ExtractFilePath(DeclTool.MainFilename);
    Filename:=CodeToolBoss.DirectoryCachePool.FindUnitSourceInCompletePath(Dir,aUnitName,InFilename);
    if Filename='' then begin
      Err(20250206143916,'unit "'+aUnitName+'" not found');
      exit;
    end;
    // load unit
    NewCode:=CodeToolBoss.LoadFile(Filename,true,false);
    if NewCode=nil then begin
      Err(20250206143931,'unable to load file "'+Filename+'"');
      exit;
    end;
    // parse
    if not CodeToolBoss.Explore(NewCode,NewTool,true) then begin
      debugln(['Error: (lazarus) [20250206142339] DoFindRenameIdentifier CodeToolBoss.Explore failed']);
      LazarusIDE.DoJumpToCodeToolBossError;
      exit;
    end;
    DeclTool:=NewTool;
    DeclCodeXY.Code:=NewCode;
    DeclCodeXY.X:=1;
    DeclCodeXY.Y:=1;
    DeclNode:=DeclTool.GetSourceNameNode;
    if DeclNode=nil then begin
      Err(20250206144454,'failed to find unit name');
      exit;
    end;
    DeclTool.CleanPosToCaret(DeclNode.StartPos,DeclCodeXY);
    Result:=true;
  end;

  function AddExtraFiles(Files: TStrings): boolean;
  // TODO: replace Files: TStringsList with a AVL tree
  var
    i: Integer;
    CurFileMask: string;
    FileInfo: TSearchRec;
    CurDirectory: String;
    CurFilename: String;
    OnlyPascalSources: Boolean;
    SPMaskType: TSPMaskType;
    FilesTree: TFilenameToStringTree;
    FTItem: PStringToStringItem;
  begin
    Result:=false;
    if (Options.ExtraFiles<>nil) then begin
      for i:=0 to Options.ExtraFiles.Count-1 do begin
        CurFileMask:=Options.ExtraFiles[i];
        if not GlobalMacroList.SubstituteStr(CurFileMask) then begin
          Err(20250206153855,'invalid file mask "'+CurFileMask+'"');
          exit;
        end;
        CurFileMask:=ChompPathDelim(CurFileMask);
        if not FilenameIsAbsolute(CurFileMask) then begin
          if LazarusIDE.ActiveProject.IsVirtual then continue;
          CurFileMask:=AppendPathDelim(LazarusIDE.ActiveProject.Directory+CurFileMask);
        end;
        CurFileMask:=TrimFilename(CurFileMask);
        SPMaskType:=GetSPMaskType(CurFileMask);
        if SPMaskType<>TSPMaskType.None then
        begin
          FilesTree:=TFilenameToStringTree.Create(false);
          try
            CollectFilesInSearchPath(CurFileMask,FilesTree);
            for FTItem in FilesTree do
            begin
              if not FilenameIsPascalSource(FTItem^.Name) then
                continue;
              if FileIsText(FTItem^.Name) then
                Files.Add(FTItem^.Name);
            end;
          finally
            FilesTree.Free;
          end;
          continue;
        end;

        OnlyPascalSources:=false;
        if DirPathExistsCached(CurFileMask) then begin
          // a whole directory
          OnlyPascalSources:=true;
          CurFileMask:=AppendPathDelim(CurFileMask)+AllFilesMask;
        end else if FileExistsCached(CurFileMask) then begin
          // single file
          Files.Add(CurFileMask);
          continue;
        end else begin
          // a mask
        end;
        if FindFirstUTF8(CurFileMask,faAnyFile,FileInfo)=0
        then begin
          CurDirectory:=AppendPathDelim(ExtractFilePath(CurFileMask));
          repeat
            // check if special file
            if (FileInfo.Name='.') or (FileInfo.Name='..') or (FileInfo.Name='')
            then
              continue;
            if OnlyPascalSources and not FilenameIsPascalSource(FileInfo.Name)
            then
              continue;
            CurFilename:=CurDirectory+FileInfo.Name;
            //debugln(['AddExtraFiles ',CurFilename]);
            if FileIsText(CurFilename) then
              Files.Add(CurFilename);
          until FindNextUTF8(FileInfo)<>0;
        end;
        FindCloseUTF8(FileInfo);
      end;
    end;
    Result:=true;
  end;

var
  StartSrcEdit: TSourceEditorInterface;
  StartSrcCode: TCodeBuffer;
  DeclTopLine, StartTopLine, i, CleanPos: integer;
  StartCaretXY, DeclXY: TPoint;
  OwnerList, ListOfLazFPDocNode: TFPList;
  ExtraFiles: TStrings;
  Files: TStringList;
  PascalReferences: TObjectList;
  OldChange, Completed, RenamingFile, IsConflicted: Boolean;
  Graph: TUsesGraph;
  AVLNode: TAVLTreeNode;
  UGUnit: TUGUnit;
  Identifier, NewFilename, OldFileName, ChangedFileType, SrcNamed, lfmString: string;
  FindRefFlags: TFindRefsFlags;
  Tool: TCodeTool;
  Node: TCodeTreeNode;
  TreeOfPCodeXYPosition: TAVLTree;
begin
  Result:=mrCancel;
  if not LazarusIDE.BeginCodeTools then exit(mrCancel);
  StartSrcEdit:=SourceEditorManagerIntf.ActiveEditor;
  StartSrcCode:=TCodeBuffer(StartSrcEdit.CodeToolsBuffer);
  StartTopLine:=StartSrcEdit.TopLine;
  RenamingFile:=False;
  ChangedFileType:='';

  // find the main declaration
  StartCaretXY:=StartSrcEdit.CursorTextXY;
  if not CodeToolBoss.FindMainDeclaration(StartSrcCode,
    StartCaretXY.X,StartCaretXY.Y,
    DeclCodeXY.Code,DeclCodeXY.X,DeclCodeXY.Y,DeclTopLine) then
  begin
    LazarusIDE.DoJumpToCodeToolBossError;
    exit(mrCancel);
  end;
  DeclTool:=nil;
  if not UpdateCodeNode then exit;
  if not CheckUsesNode then exit;

  DeclXY:=Point(DeclCodeXY.X,DeclCodeXY.Y);
  Result:=LazarusIDE.DoOpenFileAndJumpToPos(DeclCodeXY.Code.Filename, DeclXY,
    DeclTopLine,-1,-1,[ofOnlyIfExists,ofRegularFile,ofDoNotLoadResource]);
  if Result<>mrOk then
    exit;

  CodeToolBoss.GetIdentifierAt(DeclCodeXY.Code,DeclCodeXY.X,DeclCodeXY.Y,Identifier);
  Files:=nil;
  OwnerList:=nil;
  PascalReferences:=nil;
  ListOfLazFPDocNode:=nil;
  NewFilename:='';
  try
    // let user choose the search scope
    Result:=ShowFindRenameIdentifierDialog(DeclCodeXY.Code.Filename,DeclXY,
      AllowRename,SetRenameActive,nil);
    if Result<>mrOk then begin
      debugln('Error: (lazarus) DoFindRenameIdentifier failed: user cancelled dialog');
      exit;
    end;

    if not UpdateCodeNode then exit(mrCancel);

    // create the file list
    Files:=TStringList.Create;
    Files.Add(DeclCodeXY.Code.Filename);
    if CompareFilenames(DeclCodeXY.Code.Filename,StartSrcCode.Filename)<>0 then
      Files.Add(StartSrcCode.Filename);

    Options:=MiscellaneousOptions.FindRenameIdentifierOptions;

    // add packages, projects
    case Options.Scope of
    frProject:
      begin
        OwnerList:=TFPList.Create;
        OwnerList.Add(LazarusIDE.ActiveProject);
      end;
    frOwnerProjectPackage,frAllOpenProjectsAndPackages:
      begin
        OwnerList:=PackageEditingInterface.GetOwnersOfUnit(StartSrcCode.Filename);
        if (OwnerList<>nil) and (OwnerList.Count=0) then
          FreeAndNil(OwnerList);
        if (OwnerList=nil) then
          OwnerList:=PackageEditingInterface.GetPossibleOwnersOfUnit(
            StartSrcCode.Filename,[piosfExcludeOwned,piosfIncludeSourceDirectories]);
        if (OwnerList<>nil) and (OwnerList.Count=0) then
          FreeAndNil(OwnerList);
        if (OwnerList<>nil) then begin
          if Options.Scope=frAllOpenProjectsAndPackages then begin
            PackageEditingInterface.ExtendOwnerListWithUsedByOwners(OwnerList);
            ReverseList(OwnerList);
          end;
        end else begin
          // unknown unit -> search everywhere
          OwnerList:=TFPList.Create;
          OwnerList.Add(LazarusIDE.ActiveProject);
          for i:=0 to PackageEditingInterface.GetPackageCount-1 do
            OwnerList.Add(PackageEditingInterface.GetPackages(i));
          ReverseList(OwnerList);
        end;
      end;
    end;

    // get source files of packages and projects
    if OwnerList<>nil then begin
      // start in all listed files of the package(s)
      ExtraFiles:=PackageEditingInterface.GetSourceFilesOfOwners(OwnerList);
      if ExtraFiles<>nil then
      begin
        // parse all used units
        Graph:=CodeToolBoss.CreateUsesGraph;
        try
          for i:=0 to ExtraFiles.Count-1 do
            Graph.AddStartUnit(ExtraFiles[i]);
          Graph.AddTargetUnit(DeclCodeXY.Code.Filename);
          Graph.Parse(true,Completed);
          AVLNode:=Graph.FilesTree.FindLowest;
          while AVLNode<>nil do begin
            UGUnit:=TUGUnit(AVLNode.Data);
            Files.Add(UGUnit.Filename);
            AVLNode:=AVLNode.Successor;
          end;
        finally
          ExtraFiles.Free;
          Graph.Free;
        end;
      end;
    end;

    //debugln(['DoFindRenameIdentifier ',Files.Text]);

    // add user defined extra files
    if not AddExtraFiles(Files) then
      exit(mrCancel);

    // search pascal source references

    FindRefFlags:=[];
    if Options.Overrides then
      Include(FindRefFlags,frfMethodOverrides);
    if not GatherIdentifierReferences(Files,DeclCodeXY,DeclTool,DeclNode,
      Options.SearchInComments,PascalReferences,FindRefFlags) then
    begin
      debugln('20250206162727 DoFindRenameIdentifier GatherIdentifierReferences failed');
      exit(mrCancel);
    end;

    {$IFDEF EnableFPDocRename}
    // search fpdoc references
    Result:=GatherFPDocReferencesForPascalFiles(Files,DeclarationUnitInfo.Source,
                                  DeclarationCaretXY,ListOfLazFPDocNode);
    if Result<>mrOk then begin
      debugln('Error: (lazarus) DoFindRenameIdentifier GatherFPDocReferences failed');
      exit;
    end;
    {$ENDIF}

    // ToDo: search i18n references
    // ToDo: search fpdoc references
    // ToDo: search designer references

    if Options.Rename then begin

      RenamingFile:=false;
      OldFileName:=DeclCodeXY.Code.Filename;
      NewFilename:=OldFileName;
      if DeclNode.Desc=ctnSrcName then
      begin
        // rename unit/program
        NewFilename:=ExtractFilePath(OldFileName)+
          LowerCase(RemoveAmpersands(Options.RenameTo))+
          ExtractFileExt(OldFileName);
        RenamingFile:= CompareFileNames(ExtractFilenameOnly(NewFilename),
          ExtractFilenameOnly(OldFileName))<>0;
        if RenamingFile and FileExists(NewFilename) then begin
          IDEMessageDialog(lisRenamingAborted,
            Format(lisFileAlreadyExists,[NewFilename]),
            mtError,[mbOK]);
          exit(mrCancel);
        end;
        ChangedFileType:=lowercase(CodeToolBoss.GetSourceType(DeclCodeXY.Code,False));
        if ChangedFileType='' then
          RenamingFile:=false
        else begin
          case ChangedFileType of
          'program': SrcNamed:=dlgFoldPasProgram;
          'library': SrcNamed:=lisPckOptsLibrary;
          'package': SrcNamed:=lisPackage;
          else
            SrcNamed:=dlgFoldPasUnit;
          end;
        end;
        if RenamingFile and (IDEMessageDialog(srkmecRenameIdentifier,
             Format(lisTheIdentifierIsAUnitProceedAnyway,
             [SrcNamed,LineEnding,LineEnding]),
             mtInformation,[mbCancel, mbOK],'') <> mrOK) then
          exit(mrCancel);
      end;

      // rename identifier
      OldChange:=LazarusIDE.OpenEditorsOnCodeToolChange;
      LazarusIDE.OpenEditorsOnCodeToolChange:=true;
      try
        // todo: check for conflicts and show user list
        IsConflicted:=false;
        Result:=mrOk;
        if DeclNode.Desc=ctnSrcName then begin
          if not CodeToolBoss.RenameSourceNameReferences(OldFileName,NewFilename,
            Options.RenameTo,PascalReferences) then
            Result:=mrCancel;
        end else begin
          if (PascalReferences<>nil) and (PascalReferences.Count>0) then begin
            TreeOfPCodeXYPosition:=TSrcNameRefs(PascalReferences[0]).TreeOfPCodeXYPosition;
            if not CodeToolBoss.RenameIdentifier(TreeOfPCodeXYPosition,
              Identifier, Options.RenameTo, DeclCodeXY.Code, @DeclXY) then
              Result:=mrCancel;
          end;
        end;

        if Result<>mrOk then begin
          if IsConflicted then
            IDEMessageDialog(lisRenamingConflict,
              Format(lisIdentifierWasAlreadyUsed,[Options.RenameTo]),
              mtError,[mbOK])
          else
            LazarusIDE.DoJumpToCodeToolBossError;
            debugln('Error: (lazarus) DoFindRenameIdentifier unable to commit');
          exit(mrCancel);
        end;

        // ToDo: rename lfm references
        // ToDo: rename fpdoc references
        // ToDo: rename designer references

      finally
        LazarusIDE.OpenEditorsOnCodeToolChange:=OldChange;
      end;

      if RenamingFile then begin
        if ChangedFileType='unit' then
          Result:=RenameUnitFromFileName(OldFileName, Options.RenameTo)
        else
          Result:=ShowSaveProject(Options.RenameTo);
        if Result<>mrOK then exit;

        if Options.RenameShowResult then begin
          // search again
          i:=0;
          while (i<=Files.Count-1) do begin
            if (CompareFileNames(PChar(Files[i]), PChar(OldFileName))=0) then begin
              Files.Delete(i);
              Files.Add(NewFilename);
              break;
            end;
            Inc(i);
          end;
          DeclCodeXY.Code:=CodeToolBoss.LoadFile(NewFilename,false,false);
          //  X,Y are the same as before renaming
          FreeAndNil(PascalReferences);
          if not GatherIdentifierReferences(Files,DeclCodeXY,DeclTool,DeclNode,
            Options.SearchInComments,PascalReferences,FindRefFlags) then
          begin
            debugln('20250206162727 DoFindRenameIdentifier GatherIdentifierReferences failed');
            exit(mrCancel);
          end;
        end;
      end;
      if Options.RenameShowResult then
        Result:=ShowIdentifierReferences(DeclCodeXY.Code.Filename,
          PascalReferences,Identifier,Options.RenameTo);

    end else begin //no renaming, only references - always shown
      Result:=ShowIdentifierReferences(DeclCodeXY.Code.Filename,
        PascalReferences,Identifier);
    end;

  finally
    Files.Free;
    OwnerList.Free;
    PascalReferences.Free;
    FreeListObjects(ListOfLazFPDocNode,true);

    if RenamingFile and (Result=mrOK) then
      // source renamed -> jump to new file
      Result:=LazarusIDE.DoOpenFileAndJumpToPos(NewFilename, DeclXY,
        StartTopLine,-1,-1,[ofOnlyIfExists,ofRegularFile,ofDoNotLoadResource])
    else
      // jump back to where user started
      Result:=LazarusIDE.DoOpenFileAndJumpToPos(StartSrcCode.Filename, StartCaretXY,
        StartTopLine,-1,-1,[ofOnlyIfExists,ofRegularFile,ofDoNotLoadResource]);
  end;
end;

function GatherIdentifierReferences(Files: TStringList; const DeclCodeXY: TCodeXYPosition;
  DeclTool: TCodeTool; DeclNode: TCodeTreeNode; SearchInComments: boolean; out
  ListOfSrcNameRefs: TObjectList; const Flags: TFindRefsFlags): boolean;
var
  i, DeclCleanPos: Integer;
  LoadResult: TModalResult;
  Code: TCodeBuffer;
  ListOfPCodeXYPosition: TFPList;
  Cache: TFindIdentifierReferenceCache;
  TreeOfPCodeXYPosition: TAVLTree;
  Refs: TSrcNameRefs;
begin
  Result:=false;
  ListOfSrcNameRefs:=nil;
  ListOfPCodeXYPosition:=nil;
  TreeOfPCodeXYPosition:=nil;
  Cache:=nil;
  try
    CleanUpFileList(Files);

    if DeclNode=nil then begin
      if not GetDeclCodeNode(DeclCodeXY,DeclTool,DeclNode,DeclCleanPos) then
        exit;
    end;

    if DeclNode.Desc=ctnSrcName then begin
      // search source name references
      if not CodeToolBoss.FindSourceNameReferences(DeclCodeXY.Code.Filename,Files,
        not SearchInComments,ListOfSrcNameRefs) then
      begin
        debugln('GatherIdentifierReferences CodeToolBoss.FindSourceNameReferences failed');
        if CodeToolBoss.ErrorMessage='' then
          CodeToolBoss.SetError(20250206162241,DeclCodeXY.Code,DeclCodeXY.Y,DeclCodeXY.X,'CodeToolBoss.FindSourceNameReferences failed');
        LazarusIDE.DoJumpToCodeToolBossError;
        exit;
      end;
    end else begin
      // search identifier in every file
      for i:=0 to Files.Count-1 do begin
        //debugln(['GatherIdentifierReferences ',Files[i]]);
        LoadResult:=
            LoadCodeBuffer(Code,Files[i],[lbfCheckIfText,lbfUpdateFromDisk,lbfIgnoreMissing],true);
        if LoadResult=mrAbort then begin
          debugln('GatherIdentifierReferences unable to load "',Files[i],'"');
          exit;
        end;
        if LoadResult<>mrOk then continue;

        // search references
        CodeToolBoss.FreeListOfPCodeXYPosition(ListOfPCodeXYPosition);
        if not CodeToolBoss.FindReferences(
          DeclCodeXY.Code,DeclCodeXY.X,DeclCodeXY.Y,
          Code, not SearchInComments, ListOfPCodeXYPosition, Cache, Flags) then
        begin
          debugln('GatherIdentifierReferences CodeToolBoss.FindReferences failed in "',Code.Filename,'"');
          if CodeToolBoss.ErrorMessage='' then
            CodeToolBoss.SetError(20250206161149,Code,1,1,'CodeToolBoss.FindReferences failed');
          LazarusIDE.DoJumpToCodeToolBossError;
          exit;
        end;
        //debugln('GatherIdentifierReferences FindReferences in "',Code.Filename,'" ',dbgs(ListOfPCodeXYPosition<>nil));

        // add to tree
        if ListOfPCodeXYPosition<>nil then begin
          if TreeOfPCodeXYPosition=nil then
            TreeOfPCodeXYPosition:=CodeToolBoss.CreateTreeOfPCodeXYPosition;
          CodeToolBoss.AddListToTreeOfPCodeXYPosition(ListOfPCodeXYPosition,
                                                TreeOfPCodeXYPosition,true,false);
        end;
      end;
      if TreeOfPCodeXYPosition<>nil then begin
        ListOfSrcNameRefs:=TObjectList.Create(true);
        Refs:=TSrcNameRefs.Create;
        Refs.TreeOfPCodeXYPosition:=TreeOfPCodeXYPosition;
        TreeOfPCodeXYPosition:=nil;
        if ListOfSrcNameRefs=nil then
          ListOfSrcNameRefs:=TObjectList.Create(true);
        ListOfSrcNameRefs.Add(Refs);
      end;
    end;

    Result:=true;
  finally
    CodeToolBoss.FreeListOfPCodeXYPosition(ListOfPCodeXYPosition);
    CodeToolBoss.FreeTreeOfPCodeXYPosition(TreeOfPCodeXYPosition);
    Cache.Free;
  end;
end;

function ShowIdentifierReferences(DeclFilename: string; ListOfSrcNameRefs: TObjectList;
  Identifier: string; RenameTo: string): TModalResult;
var
  OldSearchPageIndex: TTabSheet;
  SearchPageIndex: TTabSheet;
  lOptions: TLazFindInFileSearchOptions;
begin
  if (ListOfSrcNameRefs=nil) or (ListOfSrcNameRefs.Count=0) then exit(mrOk);

  Result:=mrCancel;
  LazarusIDE.DoShowSearchResultsView(iwgfShow);
  SearchPageIndex:=nil;
  try
    // create a search result page
    //debugln(['ShowIdentifierReferences ',DbgSName(SearchResultsView)]);
    if RenameTo = '' then
      lOptions := []
    else
      lOptions := [fifReplace];

    SearchPageIndex:=SearchResultsView.AddSearch(
      Identifier,
      RenameTo,
      ExtractFilePath(DeclFilename),
      '*.pas;*.pp;*.p;*.inc',
      lOptions);
    if SearchPageIndex = nil then exit;

    // list results
    SearchResultsView.BeginUpdate(SearchPageIndex.PageIndex);
    AddReferencesToResultView(Identifier,ListOfSrcNameRefs,true,SearchPageIndex.PageIndex);
    OldSearchPageIndex:=SearchPageIndex;
    SearchPageIndex:=nil;
    Identifier:=EnforceAmp(Identifier);
    SearchResultsView.EndUpdate(OldSearchPageIndex.PageIndex, 'Ref: '+Identifier);
    IDEWindowCreators.ShowForm(SearchResultsView,true);

  finally
    if SearchPageIndex <> nil then
      SearchResultsView.EndUpdate(SearchPageIndex.PageIndex, 'Ref: '+Identifier);
  end;
  Result:=mrOK;
end;

procedure AddReferencesToResultView(Identifier: string; ListOfSrcNameRefs: TObjectList;
  ClearItems: boolean; SearchPageIndex: integer);
var
  CodePos: PCodeXYPosition;
  CurLine, TrimmedLine, CurIdentifier: String;
  TrimCnt: Integer;
  ANode: TAVLTreeNode;
  CaretXY: TCodeXYPosition;
  i, Len: integer;
  CleanPos: integer;
  EndPos: integer;
  CodeTool: TCodeTool;
  Refs: TSrcNameRefs;
  Tree: TAVLTree;
begin
  SearchResultsView.BeginUpdate(SearchPageIndex);
  if ClearItems then
    SearchResultsView.Items[SearchPageIndex].Clear;
  if ListOfSrcNameRefs<>nil then begin
    for i:=0 to ListOfSrcNameRefs.Count-1 do begin
      Refs:=TSrcNameRefs(ListOfSrcNameRefs[i]);
      Tree:=Refs.TreeOfPCodeXYPosition;
      if Tree=nil then continue;

      CurIdentifier:=Refs.NewLocalSrcName;
      if CurIdentifier='' then CurIdentifier:=Identifier;

      ANode:=Tree.FindLowest;
      while ANode<>nil do begin
        CodePos:=PCodeXYPosition(ANode.Data);
        ANode:=Tree.FindSuccessor(ANode);

        CurLine:=TrimRight(CodePos^.Code.GetLine(CodePos^.Y-1,false));
        TrimmedLine:=Trim(CurLine);
        TrimCnt:=length(CurLine)-length(TrimmedLine);
        //debugln('ShowReferences x=',dbgs(CodePos^.x),' y=',dbgs(CodePos^.y),' ',CurLine);
        Len:=length(CurIdentifier);
        if Pos('.',CurIdentifier)>0 then begin
          CodeToolBoss.Explore(CodePos^.Code,CodeTool,true);
          CaretXY.X:=CodePos^.X;
          CaretXY.Y:=CodePos^.Y;
          CaretXY.Code:=CodePos^.Code;
          if CodeTool.CaretToCleanPos(CaretXY,CleanPos)<>0 then
            continue;
          CodeTool.ExtractIdentifierWithPointsOutEndPos(CleanPos,EndPos,
            length(Identifier));
          Len:=EndPos-CleanPos;
        end;
        SearchResultsView.AddMatch(SearchPageIndex,
                                   CodePos^.Code.Filename,
                                   Point(CodePos^.X,CodePos^.Y),
                                   Point(CodePos^.X+Len,CodePos^.Y),
                                   TrimmedLine,
                                   CodePos^.X-TrimCnt, Len);
      end;
    end;
  end;
  SearchResultsView.EndUpdate(SearchPageIndex);
end;

function GatherFPDocReferencesForPascalFiles(PascalFiles: TStringList;
  DeclarationCode: TCodeBuffer; const DeclarationCaretXY: TPoint;
  var ListOfLazFPDocNode: TFPList): TModalResult;
var
  PascalFilenames, FPDocFilenames: TFilenameToStringTree;
  CacheWasUsed: boolean;
  Chain: TCodeHelpElementChain;
  CHResult: TCodeHelpParseResult;
  CHElement: TCodeHelpElement;
  FPDocFilename: String;
  S2SItem: PStringToStringItem;
begin
  Result:=mrCancel;
  PascalFilenames:=nil;
  FPDocFilenames:=nil;
  try
    // gather FPDoc files
    CleanUpFileList(PascalFiles);

    PascalFilenames:=TFilenameToStringTree.Create(false);
    PascalFilenames.AddNames(PascalFiles);
    CodeHelpBoss.GetFPDocFilenamesForSources(PascalFilenames,true,FPDocFilenames);
    if FPDocFilenames=nil then begin
      DebugLn(['GatherFPDocReferences no fpdoc files found']);
      exit(mrOk);
    end;

    // get codehelp element
    CHResult:=CodeHelpBoss.GetElementChain(DeclarationCode,
             DeclarationCaretXY.X,DeclarationCaretXY.Y,true,Chain,CacheWasUsed);
    if CHResult<>chprSuccess then begin
      DebugLn(['GatherFPDocReferences CodeHelpBoss.GetElementChain failed']);
      exit;
    end;
    CHElement:=Chain[0];
    DebugLn(['GatherFPDocReferences OwnerName=',CHElement.ElementOwnerName,' FPDocPkg=',CHElement.ElementFPDocPackageName,' Name=',CHElement.ElementName]);

    // search FPDoc files
    for S2SItem in FPDocFilenames do begin
      FPDocFilename:=S2SItem^.Name;
      Result:=GatherReferencesInFPDocFile(
                CHElement.ElementFPDocPackageName,CHElement.ElementUnitName,
                CHElement.ElementName,
                FPDocFilename,ListOfLazFPDocNode);
      if Result<>mrOk then exit;
    end;

    Result:=mrOk;
  finally
    PascalFilenames.Free;
    FPDocFilenames.Free;
    if Result<>mrOk then begin
      FreeListObjects(ListOfLazFPDocNode,true);
      ListOfLazFPDocNode:=nil;
    end;
  end;
end;

function GatherReferencesInFPDocFile(
  const OldPackageName, OldModuleName, OldElementName: string;
  const FPDocFilename: string;
  var ListOfLazFPDocNode: TFPList
  ): TModalResult;
var
  DocFile: TLazFPDocFile;
  IsSamePackage: Boolean;
  IsSameModule: Boolean;// = same unit

  procedure CheckLink(Node: TDOMNode; Link: string);
  var
    p: LongInt;
    PackageName: String;
  begin
    if Link='' then exit;
    if Link[1]='#' then begin
      p:=System.Pos('.',Link);
      if p<1 then exit;
      PackageName:=copy(Link,2,p-2);
      if SysUtils.CompareText(PackageName,OldPackageName)<>0 then exit;
      delete(Link,1,p);
    end;
    if (SysUtils.CompareText(Link,OldElementName)=0)
    or (SysUtils.CompareText(Link,OldModuleName+'.'+OldElementName)=0) then
    begin
      DebugLn(['CheckLink Found: ',Link]);
      if ListOfLazFPDocNode=nil then
        ListOfLazFPDocNode:=TFPList.Create;
      ListOfLazFPDocNode.Add(TLazFPDocNode.Create(DocFile,Node));
    end;
  end;

  procedure SearchLinksInChildNodes(Node: TDomNode);
  // search recursively for links
  begin
    Node:=Node.FirstChild;
    while Node<>nil do begin
      if (Node.NodeName='link')
      and (Node is TDomElement) then begin
        CheckLink(Node,TDomElement(Node).GetAttribute('id'));
      end;
      SearchLinksInChildNodes(Node);
      Node:=Node.NextSibling;
    end;
  end;

var
  CHResult: TCodeHelpParseResult;
  CacheWasUsed: boolean;
  Node: TDOMNode;
begin
  Result:=mrCancel;
  DebugLn(['GatherFPDocReferences ',
    ' OldPackageName=',OldPackageName,
    ' OldModuleName=',OldModuleName,' OldElementName=',OldElementName,
    ' FPDocFilename=',FPDocFilename]);

  CHResult:=CodeHelpBoss.LoadFPDocFile(FPDocFilename,[chofUpdateFromDisk],
                                       DocFile,CacheWasUsed);
  if CHResult<>chprSuccess then begin
    DebugLn(['GatherReferencesInFPDocFile CodeHelpBoss.LoadFPDocFile failed File=',FPDocFilename]);
    exit(mrCancel);
  end;

  // search in Doc nodes
  IsSamePackage:=SysUtils.CompareText(DocFile.GetPackageName,OldPackageName)=0;
  IsSameModule:=SysUtils.CompareText(DocFile.GetModuleName,OldModuleName)=0;
  DebugLn(['GatherReferencesInFPDocFile ',DocFile.GetPackageName,'=',OldPackageName,' ',DocFile.GetModuleName,'=',OldModuleName]);
  Node:=DocFile.GetFirstElement;
  while Node<>nil do begin
    if Node is TDomElement then begin
      if (SysUtils.CompareText(TDomElement(Node).GetAttribute('name'),OldElementName)=0)
      and IsSamePackage and IsSameModule
      then begin
        // this is the element itself
        DebugLn(['GatherReferencesInFPDocFile Element itself found: ',Node.NodeName,' ',Node.NodeValue]);
        if ListOfLazFPDocNode=nil then
          ListOfLazFPDocNode:=TFPList.Create;
        ListOfLazFPDocNode.Add(TLazFPDocNode.Create(DocFile,Node));
      end;
      CheckLink(Node,TDomElement(Node).GetAttribute('link'));
      SearchLinksInChildNodes(Node);
    end;
    Node:=Node.NextSibling;
  end;

  Result:=mrOk;
end;

{ TFindRenameIdentifierDialog }

procedure TFindRenameIdentifierDialog.FindRenameIdentifierDialogCreate(
  Sender: TObject);
begin
  IDEDialogLayoutList.ApplyLayout(Self,450,480);

  Caption:=lisFRIFindOrRenameIdentifier;
  CurrentGroupBox.Caption:=lisCodeToolsOptsIdentifier;
  ExtraFilesGroupBox.Caption:=lisFRIAdditionalFilesToSearchEGPathPasPath2Pp;
  ButtonPanel1.OKButton.Caption:=lisFRIFindReferences;
  ButtonPanel1.OKButton.ModalResult:=mrNone;
  ButtonPanel1.CancelButton.Caption:=lisCancel;
  NewGroupBox.Caption:=lisFRIRenaming;
  RenameCheckBox.Caption:=lisRename;
  ShowResultCheckBox.Caption:=lisRenameShowResult;
  ScopeCommentsCheckBox.Caption:=lisFRISearchInCommentsToo;
  ScopeOverridesCheckBox.Caption:=lisFindOverridesToo;
  ScopeGroupBox.Caption:=lisFRISearch;
  ScopeRadioGroup.Caption:=dlgSearchScope;
  ScopeRadioGroup.Items[0]:=lisFRIinCurrentUnit;
  ScopeRadioGroup.Items[1]:=lisFRIinMainProject;
  ScopeRadioGroup.Items[2]:=lisFRIinProjectPackageOwningCurrentUnit;
  ScopeRadioGroup.Items[3]:=lisFRIinAllOpenPackagesAndProjects;
  FFiles:=nil;
  LoadFromConfig;
end;

procedure TFindRenameIdentifierDialog.FormShow(Sender: TObject);
begin
  if NewEdit.CanFocus then
  begin
    NewEdit.SelectAll;
    NewEdit.SetFocus;
  end;
end;

procedure TFindRenameIdentifierDialog.HelpButtonClick(Sender: TObject);
begin
  OpenUrl('http://wiki.freepascal.org/IDE_Window:_Find_or_Rename_identifier');
end;

procedure TFindRenameIdentifierDialog.RenameCheckBoxChange(Sender: TObject);
begin
  if RenameCheckBox.Checked then
    ValidateNewName(Sender)
  else begin
    FNewIdentifier:=FOldIdentifier;
    NewEdit.Text:=FNewIdentifier;
    UpdateRename;
  end;
end;

procedure TFindRenameIdentifierDialog.ValidateNewName(Sender: TObject);
var
  ok: boolean;
  Err, dotPart:string;
  i: integer;
begin
  if FOldIdentifier='' then exit;
  Err:='';
  FNewIdentifier:=NewEdit.Text;
  if (FNode<>nil)
  and (FNode.Desc in [ctnProgram..ctnUnit,ctnUseUnitNamespace,ctnUseUnitClearName]) then
    ok:=IsValidDottedIdent(FNewIdentifier) //can be dotted
  else
    ok:=IsValidDottedIdent(FNewIdentifier,false);//not dotted for sure

  if not ok then begin
    if FNewIdentifier='' then
      Err:=lisIdentifierCannotBeEmpty
    else
      Err:= format(lisIdentifierIsInvalid,[FNewIdentifier]);
  end;

  if ok and (FTool<>nil) then begin
    i:=1;
    while ok and (i<=length(FNewIdentifier)) do begin
      dotPart:='';
      while (i<=length(FNewIdentifier)) do begin
        dotPart:=dotPart+FNewIdentifier[i];
        inc(i);
        if i>length(FNewIdentifier)then
          break;
        if FNewIdentifier[i]='.' then begin
          inc(i);
          break;
        end;
      end;
      ok:=not FTool.IsStringKeyWord(dotPart);
    end;
    if not ok then
      Err:=Format(lisIdentifierIsReservedWord,[dotPart]);
  end;

  if ok
  and (CompareDottedIdentifiers(PChar(FNewIdentifier),PChar(FOldIdentifier))<>0)
  then
    ok:=not NewIdentifierIsConflicted(Err);

  Err:=StringReplace(Err,'&','&&',[rfReplaceAll]);
  ButtonPanel1.OKButton.Enabled:=ok;
  if ok then begin
    NewGroupBox.Caption:=lisFRIRenaming;
    NewGroupBox.Font.Style:=NewGroupBox.Font.Style-[fsBold];
  end
  else begin
    NewGroupBox.Caption:=lisFRIRenaming+' - '+ Err;
    NewGroupBox.Font.Style:=NewGroupBox.Font.Style+[fsBold];
  end;

  UpdateRename;
end;

procedure TFindRenameIdentifierDialog.UpdateRename;
begin
  RenameCheckBox.Enabled:=AllowRename;
  if not RenameCheckBox.Checked then begin
    ButtonPanel1.OKButton.Enabled:=true;
    NewGroupBox.Caption:=lisFRIRenaming;
    NewGroupBox.Font.Style:=NewGroupBox.Font.Style-[fsBold];
  end;
  NewEdit.Enabled:=RenameCheckBox.Checked and RenameCheckBox.Enabled;
  ShowResultCheckBox.Enabled:=RenameCheckBox.Checked and RenameCheckBox.Enabled;
  if NewEdit.Enabled then
    ButtonPanel1.OKButton.Caption:=lisFRIRenameAllReferences
  else
    ButtonPanel1.OKButton.Caption:=lisFRIFindReferences;
  if RenameCheckBox.Checked and (FForbidden=nil) then
    GatherFiles;
end;

procedure TFindRenameIdentifierDialog.SetAllowRename(const AValue: boolean);
begin
  if FAllowRename=AValue then exit;
  FAllowRename:=AValue;
  UpdateRename;
end;

procedure TFindRenameIdentifierDialog.SetIsPrivate(const AValue: boolean);
begin
  if FIsPrivate=AValue then exit;
  FIsPrivate:=AValue;
  ExtraFilesGroupBox.Enabled:=not IsPrivate;
  ScopeRadioGroup.Enabled:=not IsPrivate;
  ScopeRadioGroup.ItemIndex:=0;
end;

procedure TFindRenameIdentifierDialog.SetFiles(const Files: TStringList);
begin
  if FFiles<>nil then exit; //already set
  if Files = nil then exit;
  if Files.Count = 0 then exit;
  if FFiles=nil then FFiles:=TStringList.Create;
  FFiles.Assign(Files);
end;

procedure TFindRenameIdentifierDialog.FindOrRenameButtonClick(Sender: TObject);
var
  Res:TModalResult;
  ACodeBuffer:TCodeBuffer;
  anItem: TIdentifierListItem;
  tmpNode: TCodeTreeNode;
  X,Y: integer;
  ErrInfo: string;
  isOK: boolean;
  CTB_IdentComplIncludeKeywords: Boolean;
  CTB_CodeCompletionTemplateFileName: string;
  CTB_IdentComplIncludeWords: TIdentComplIncludeWords;
  ContextPos: integer;

  function GetCodePos(var aPos: integer; out X,Y:integer;
    pushBack: boolean = true):boolean;
  var
    CodeTool: TCodeTool;
    CaretXY: TCodeXYPosition;
    aTop, amdPos: integer;
  begin
    X:=0;
    Y:=0;
    Result:=false;
    CodeToolBoss.Explore(ACodeBuffer,CodeTool,true);
    if CodeTool<>nil then begin
      CodeTool.MoveCursorToCleanPos(aPos);
      CodeTool.ReadNextAtom;
      if pushBack then begin
        CodeTool.ReadPriorAtom;
        if not (CodeTool.CurPos.Flag in [cafWord, cafEnd]) and (CodeTool.CurPos.StartPos>0) then
          CodeTool.ReadPriorAtom;
        if (CodeTool.CurPos.Flag=cafEnd) and (CodeTool.CurPos.StartPos>0) then
          CodeTool.ReadPriorAtom;
        CodeTool.ReadNextAtom;
      end;
      aPos:=CodeTool.CurPos.StartPos;

      if CodeTool.CleanPosToCaretAndTopLine(aPos, CaretXY, aTop) then begin
        X:=CaretXY.X;
        Y:=CaretXY.Y;
        Result:=true;
      end;
    end;
  end;

  function FindConflict: boolean;
  var
    aNode: TCodeTreeNode;
  begin
    anItem:=CodeToolBoss.IdentifierList.FindIdentifier(PChar(FNewIdentifier));
    Result:=(anItem<>nil) and
      (CompareDottedIdentifiers(PChar(FOldIdentifier), PChar(FNewIdentifier))<>0);
    if Result then begin
      if anItem.Node<>nil then begin
        ContextPos:=anItem.Node.StartPos;
        ErrInfo:= Format(lisIdentifierWasAlreadyUsed,[FNewIdentifier]);
      end else begin
        if anItem.ResultType='' then
          ErrInfo:= Format(lisIdentifierIsDeclaredCompilerProcedure,[FNewIdentifier])
        else
          ErrInfo:= Format(lisIdentifierIsDeclaredCompilerFunction,[FNewIdentifier]);
      end;
    end;
  end;
begin
  if RenameCheckBox.Checked then
    ModalResult:=mrNone
  else begin
    ModalResult:=mrOK;
    exit;
  end;

  CTB_IdentComplIncludeKeywords:=CodeToolBoss.IdentComplIncludeKeywords;
  CodeToolBoss.IdentComplIncludeKeywords:=false;

  CTB_CodeCompletionTemplateFileName:=
    CodeToolsOptions.CodeToolsOpts.CodeCompletionTemplateFileName;
  CodeToolsOptions.CodeToolsOpts.CodeCompletionTemplateFileName:='';

  CTB_IdentComplIncludeWords:=CodeToolsOptions.CodeToolsOpts.IdentComplIncludeWords;
  CodeToolsOptions.CodeToolsOpts.IdentComplIncludeWords:=icwIncludeFromAllUnits;

  try
    anItem:=nil;
    isOK:=true;
    CodeToolBoss.IdentifierList.Clear;

    Res:= LoadCodeBuffer(ACodeBuffer,IdentifierFileName,[lbfCheckIfText],false);
    //try declaration context
    if Res=mrOK then begin
      tmpNode:=FNode;
      while isOK and (tmpNode<>nil) do begin
        if (tmpNode.Parent<>nil) and (tmpNode.Parent.Desc in AllFindContextDescs)
        then begin
          ContextPos:=tmpNode.Parent.EndPos;//can point at the end of "end;"
          if GetCodePos(ContextPos,X,Y) then
            CodeToolBoss.GatherIdentifiers(ACodeBuffer, X, Y);
            isOK:=not FindConflict; //ErrInfo is set inside the function
          end;
        tmpNode:=tmpNode.Parent;
      end;
    end;
  if isOK then
    ModalResult:=mrOk;
  finally
    CodeToolBoss.IdentComplIncludeKeywords:=
      CTB_IdentComplIncludeKeywords;
    CodeToolsOptions.CodeToolsOpts.CodeCompletionTemplateFileName:=
      CTB_CodeCompletionTemplateFileName;
    CodeToolsOptions.CodeToolsOpts.IdentComplIncludeWords:=
      CTB_IdentComplIncludeWords;

    if RenameCheckBox.Checked then begin
      ButtonPanel1.OKButton.Enabled:=isOK;
      if isOK then begin
        NewGroupBox.Caption:=lisFRIRenaming;
        NewGroupBox.Font.Style:=NewGroupBox.Font.Style-[fsBold];
      end else begin
        ErrInfo:=StringReplace(ErrInfo,'&','&&',[rfReplaceAll]);
        NewGroupBox.Caption:=lisFRIRenaming+' - '+ ErrInfo;
        NewGroupBox.Font.Style:=NewGroupBox.Font.Style+[fsBold];
      end;
    end;
  end;
end;

procedure TFindRenameIdentifierDialog.FindRenameIdentifierDialogClose(
  Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveToConfig;
  IDEDialogLayoutList.SaveLayout(Self);
end;

procedure TFindRenameIdentifierDialog.LoadFromConfig;
begin
  LoadFromOptions(MiscellaneousOptions.FindRenameIdentifierOptions);
end;

procedure TFindRenameIdentifierDialog.SaveToConfig;
begin
  SaveToOptions(MiscellaneousOptions.FindRenameIdentifierOptions);
end;

procedure TFindRenameIdentifierDialog.LoadFromOptions(
  Options: TFindRenameIdentifierOptions);
begin
  RenameCheckBox.Checked:=Options.Rename;
  ExtraFilesEdit.Text:=StringListToText(Options.ExtraFiles,';',true);
  NewEdit.Text:=Options.RenameTo;
  ShowResultCheckBox.Checked:=Options.RenameShowResult;
  ScopeCommentsCheckBox.Checked:=Options.SearchInComments;
  ScopeOverridesCheckBox.Checked:=Options.Overrides;
  case Options.Scope of
  frCurrentUnit: ScopeRadioGroup.ItemIndex:=0;
  frProject: ScopeRadioGroup.ItemIndex:=1;
  frOwnerProjectPackage: ScopeRadioGroup.ItemIndex:=2;
  else
    ScopeRadioGroup.ItemIndex:=3;
  end;
  UpdateRename;
end;

procedure TFindRenameIdentifierDialog.SaveToOptions(
  Options: TFindRenameIdentifierOptions);
begin
  Options.Rename:=RenameCheckBox.Checked;
  if ExtraFilesGroupBox.Enabled then
    SplitString(ExtraFilesEdit.Text,';',Options.ExtraFiles,true);
  Options.RenameTo:=NewEdit.Text;
  Options.RenameShowResult := ShowResultCheckBox.Checked;
  Options.SearchInComments:=ScopeCommentsCheckBox.Checked;
  Options.Overrides:=ScopeOverridesCheckBox.Checked;
  if ScopeRadioGroup.Enabled then
    case ScopeRadioGroup.ItemIndex of
    0: Options.Scope:=frCurrentUnit;
    1: Options.Scope:=frProject;
    2: Options.Scope:=frOwnerProjectPackage;
    else Options.Scope:=frAllOpenProjectsAndPackages;
    end;
end;

procedure TFindRenameIdentifierDialog.SetIdentifier(
  const NewIdentifierFilename: string; var NewIdentifierPosition: TPoint);
var
  s: String;
  ACodeBuffer: TCodeBuffer;
  ListOfCodeBuffer: TFPList;
  i: Integer;
  CurCode: TCodeBuffer;
  Tool: TCodeTool;
  CodeXY: TCodeXYPosition;
  CleanPos: integer;
  Node: TCodeTreeNode;
begin
  FIdentifierFilename:=NewIdentifierFilename;
  FIdentifierPosition:=NewIdentifierPosition;
  FNode:=nil;
  //debugln(['TFindRenameIdentifierDialog.SetIdentifier ',FIdentifierFilename,' ',dbgs(FIdentifierPosition)]);
  CurrentListBox.Items.Clear;
  s:=IdentifierFilename
     +'('+IntToStr(IdentifierPosition.Y)+','+IntToStr(IdentifierPosition.X)+')';
  CurrentListBox.Items.Add(s);
  LoadCodeBuffer(ACodeBuffer,IdentifierFileName,[lbfCheckIfText],false);
  IsPrivate:=false;
  FOldIdentifier:='';
  if ACodeBuffer=nil then begin
    CurrentGroupBox.Caption:='?file not found?';
    exit;
  end;

  // Check if this is an include file and list files this unit/program
  CodeToolBoss.GetIncludeCodeChain(ACodeBuffer,true,ListOfCodeBuffer);
  if ListOfCodeBuffer<>nil then begin
    for i:=0 to ListOfCodeBuffer.Count-1 do begin
      CurCode:=TCodeBuffer(ListOfCodeBuffer[i]);
      if CurCode=ACodeBuffer then break;
      s:=CurCode.Filename;
      CurrentListBox.Items.Insert(0,s);
    end;
    ListOfCodeBuffer.Free;
  end;

  if CodeToolBoss.GetIdentifierAt(ACodeBuffer,
    NewIdentifierPosition.X,NewIdentifierPosition.Y,FOldIdentifier,FNode) then
  begin
    CurrentGroupBox.Caption:= Format(lisFRIIdentifier,[''])+EnforceAmp(FOldIdentifier);
    NewEdit.Text:=FOldIdentifier;
  end else
    FOldIdentifier:='';

  // check if in implementation or private section
  if CodeToolBoss.Explore(ACodeBuffer,Tool,false) then begin
    CodeXY:=CodeXYPosition(NewIdentifierPosition.X,NewIdentifierPosition.Y,ACodeBuffer);
    if Tool.CaretToCleanPos(CodeXY,CleanPos)=0 then begin
      Node:=Tool.BuildSubTreeAndFindDeepestNodeAtPos(CleanPos,false);
      if (Node=nil)
      or Node.HasParentOfType(ctnImplementation)
      or Node.HasParentOfType(ctnClassPrivate) then
        IsPrivate:=true;
    end;
  end;
end;
procedure TFindRenameIdentifierDialog.GatherFiles;
var
  StartSrcEdit: TSourceEditorInterface;
  DeclCode, StartSrcCode: TCodeBuffer;
  DeclX, DeclY, DeclTopLine, i: integer;
  LogCaretXY, DeclarationCaretXY: TPoint;
  OwnerList: TFPList;
  ExtraFiles: TStrings;
  Files: TStringList;
  CurUnitname: string;
  Graph: TUsesGraph;
  Node: TAVLTreeNode;
  UGUnit: TUGUnit;
  UnitInfo:TUnitInfo;
  Completed: boolean;
  ExternalProjectName, InternalProjectName, ProjMainFilename: string;
begin
  if not LazarusIDE.BeginCodeTools then exit;
  if Project1=nil then exit;
  if not AllowRename then exit;

  StartSrcEdit:=SourceEditorManagerIntf.ActiveEditor;
  StartSrcCode:=TCodeBuffer(StartSrcEdit.CodeToolsBuffer);
  //StartTopLine:=StartSrcEdit.TopLine;

  // find the main declaration
  LogCaretXY:=StartSrcEdit.CursorTextXY;
  if not CodeToolBoss.FindMainDeclaration(StartSrcCode,
    LogCaretXY.X,LogCaretXY.Y,
    DeclCode,DeclX,DeclY,DeclTopLine) then
  begin
    LazarusIDE.DoJumpToCodeToolBossError;
    exit;
  end;

  OwnerList:=nil;
  try
    FTool:=CodeToolBoss.FindCodeToolForSource(DeclCode);
    FForbidden:=TStringList.Create;
    Files:=TStringList.Create;

    ProjMainFilename:=Project1.MainFilename;
    if ProjMainFilename<>'' then begin
      InternalProjectName:=
        Project1.ProjectUnitWithFilename(ProjMainFilename).Unit_Name;
      ExternalProjectName:=ExtractFileNameOnly(ProjMainFilename);
      if ExternalProjectName<>'' then begin
        // units cannot have filename matching project file name - only warnings/problems,
        // projects source names can be changed to match its file names,
        // other identifiers can be renamed to project file name - if this differs from
        // project source name.
        if (FNode<>nil)
            and (FNode.Desc in [ctnUseUnit,ctnUseUnitNamespace,ctnUseUnitClearName,ctnUnit])
            and (CompareDottedIdentifiers(PChar(ExternalProjectName),
                                          PChar(InternalProjectName))<>0)
        then
          FForbidden.Add(ExternalProjectName);
      end;
    end;

    OwnerList:=TFPList.Create;
    OwnerList.Add(LazarusIDE.ActiveProject);

    // get source files of packages and projects
    ExtraFiles:=PackageEditingInterface.GetSourceFilesOfOwners(OwnerList);
    if ExtraFiles<>nil then
    begin
      // parse all used units
      Graph:=CodeToolBoss.CreateUsesGraph;
      try
        for i:=0 to ExtraFiles.Count-1 do
          Graph.AddStartUnit(ExtraFiles[i]);
        Graph.AddTargetUnit(DeclCode.Filename);
        Graph.Parse(true,Completed);
        Node:=Graph.FilesTree.FindLowest;
        while Node<>nil do begin
          UGUnit:=TUGUnit(Node.Data);
          Files.Add(UGUnit.Filename);
          Node:=Node.Successor;
        end;
      finally
        ExtraFiles.Free;
        Graph.Free;
      end;
    end;
    for i:=0 to Files.Count-1 do begin //get project/unit name
      UnitInfo:=Project1.UnitInfoWithFilename(Files[i]);
      if UnitInfo<>nil then
        CurUnitname:=UnitInfo.Unit_Name
      else
        CurUnitname:=ExtractFileNameOnly(Files[i]);
      FForbidden.Add(CurUnitname); //store for ValidateNewName
    end;
    SetFiles(Files);
  finally
    Files.Free;
    OwnerList.Free;
  end;
end;

function TFindRenameIdentifierDialog.NewIdentifierIsConflicted(var ErrMsg: string): boolean;
var
  i: integer;
  anItem: TIdentifierListItem;
begin
  Result:=false;
  ErrMsg:='';
  if not AllowRename then exit;
  if not (FNode.Desc in [ctnProgram..ctnUnit,ctnUseUnit,ctnUseUnitNamespace,ctnUseUnitClearName])
      and (Pos('.',FNewIdentifier)>0) then
  begin
    ErrMsg:=Format(lisIdentifierCannotBeDotted,[FNewIdentifier]);
    exit(true);
  end;
  if FNewIdentifier='' then begin
    ErrMsg:=lisIdentifierCannotBeEmpty;
    exit(true);
  end;
  if FForbidden=nil then exit;
  i:=0;
  while (i<=FForbidden.Count-1) and
    (CompareDottedIdentifiers(PChar(FNewIdentifier),PChar(FForbidden[i]))<>0) do
    inc(i);
  Result:= i<=FForbidden.Count-1;

  if Result then begin
    ErrMsg:=Format(lisIdentifierWasAlreadyUsed,[FNewIdentifier]);
    exit;
  end;
  // checking if there are existing other identifiers conflited with the new
  // will be executed when "Rename all References" button is clicked
end;

destructor TFindRenameIdentifierDialog.Destroy;
begin
  FreeAndNil(FForbidden);
  FreeAndNil(FFiles);
  inherited Destroy;
end;


function RenameUnitFromFileName(OldFileName: string; NewUnitName: string):
  TModalResult;
var
  AUnitInfoOld, UnitInfo : TUnitInfo;
  NewFileName: string;
  i:integer;
begin
  Result:=mrCancel;
  if not Assigned(Project1) then Exit;
  AUnitInfoOld:= Project1.UnitInfoWithFilename(OldFileName);
  if AUnitInfoOld=nil then Exit;
  AUnitInfoOld.ReadUnitSource(False,False);
  //OldUnitName:=AUnitInfoOld.Unit_Name;
  NewFileName:= ExtractFilePath(OldFileName)+
    lowerCase(NewUnitName + ExtractFileExt(OldFilename));
  if CompareFileNames(AUnitInfoOld.Filename,NewFileName)=0 then Exit;
  AUnitInfoOld.ClearModifieds;
  AUnitInfoOld.Unit_Name:=NewUnitName;
  Result:=SaveEditorFile(OldFileName,[sfProjectSaving,sfSaveAs,sfSkipReferences]);
  if Result = mrOK then
    DeleteFile(OldFileName);
end;

function ShowSaveProject(NewProjectName: string): TModalResult;
var
  AUnitInfoOld: TUnitInfo;
  Flags:TSaveFlags;
begin
  Result:=mrCancel;
  if not Assigned(Project1) then Exit;
  AUnitInfoOld:=Project1.MainUnitInfo;
  if AUnitInfoOld=nil then Exit;
  if Project1.MainUnitInfo.Unit_Name = NewProjectName then
    Flags:=[sfProjectSaving, sfSkipReferences]
  else begin
    Project1.MainUnitInfo.Unit_Name:= NewProjectName;
    Flags:=[sfSaveAs, sfProjectSaving, sfSkipReferences];
  end;
  Result:=SaveProject(Flags);
end;

function EnforceAmp(AmpString: string): string;
  var i, len: integer;
  begin
    Result:='';
    i:=1;
    len:= length(AmpString);
    while i<=len do begin
      if AmpString[i]='&' then begin
        Result:= Result + '&&';
        inc(i);
      end;
      if (i<=len) and (isIdentStartChar[AmpString[i]]) then
      while (i<=len) and isIdentChar[AmpString[i]] do begin
        Result:= Result + AmpString[i];
        inc(i);
      end;
      if (i>len) or (AmpString[i]<>'.') then break;
      Result:= Result + AmpString[i];
      inc(i);
    end;
  end;
end.


