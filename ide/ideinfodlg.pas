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
   IDE dialog showing stats about the IDE.
}
unit IDEInfoDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LazUtils
  LazFileUtils, LazUTF8, FPCAdds, LazLoggerBase, Translations,
  // LCL
  Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, ButtonPanel, LazHelpHTML,
  LazHelpIntf,
  // CodeTools
  CodeToolManager, DefineTemplates, LinkScanner,
  // IdeConfig
  TransferMacros, EnvironmentOpts, LazConf,
  // BuildIntf
  MacroDefIntf, IDEExternToolIntf,
  // IdeIntf
  IDEHelpIntf, IDEWindowIntf, LazIDEIntf,
  // IDE
  LazarusIDEStrConsts, Project, SourceEditor, InitialSetupProc,
  PackageSystem, PackageDefs;

type

  { TIDEInfoDialog }

  TIDEInfoDialog = class(TForm)
    ButtonPanel1: TButtonPanel;
    ExtToolMemo: TMemo;
    GeneralMemo: TMemo;
    MacrosMemo: TMemo;
    HelpMemo: TMemo;
    ModifiedMemo: TMemo;
    PageControl1: TPageControl;
    GeneralTabSheet: TTabSheet;
    ModifiedTabSheet: TTabSheet;
    HelpTabSheet: TTabSheet;
    ExtToolTabSheet: TTabSheet;
    MacroTabSheet: TTabSheet;
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    // general
    procedure GatherIDEVersion(sl: TStrings);
    procedure GatherParameters(sl: TStrings);
    procedure GatherSystemLanguageInfo(sl: TStrings);
    procedure GatherEnvironmentVars(sl: TStrings);
    procedure GatherGlobalOptions(sl: TStrings);
    // modified
    procedure GatherModifiedProject(AProject: TProject; sl: TStrings);
    procedure GatherModifiedPackages(sl: TStrings);
    procedure GatherModifiedSourceEditor(sl: TStrings);
    // help
    procedure GatherHelpDatabases(sl: TStrings);
    procedure GatherHelpViewers(sl: TStrings);
    procedure GatherHelpDB(Prefix: string; const HelpDB: THelpDatabase; const sl: TStrings);
    procedure GatherHelpViewer(Prefix: string; const Viewer: THelpViewer; const sl: TStrings);
    // external tools
    procedure GatherExternalTools(sl: TStrings);
  public
    procedure UpdateGeneralMemo;
    procedure UpdateMacrosMemo;
    procedure UpdateModifiedMemo;
    procedure UpdateHelpMemo;
    procedure UpdateExternalTools;
  end;

var
  IDEInfoDialog: TIDEInfoDialog;

function ShowIDEInfo: TModalResult;


implementation

function ShowIDEInfo: TModalResult;
var
  Dlg: TIDEInfoDialog;
begin
  Dlg:=TIDEInfoDialog.Create(nil);
  try
    Result:=Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

{$R *.lfm}

{ TIDEInfoDialog }

procedure TIDEInfoDialog.FormCreate(Sender: TObject);
begin
  Caption:=lisIDEInfoInformationAboutTheIDE;

  UpdateGeneralMemo;
  UpdateMacrosMemo;
  UpdateModifiedMemo;
  UpdateHelpMemo;
  UpdateExternalTools;
  PageControl1.PageIndex:=0;
  IDEDialogLayoutList.ApplyLayout(Self);
end;

procedure TIDEInfoDialog.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  IDEDialogLayoutList.SaveLayout(Self);
end;

procedure TIDEInfoDialog.GatherHelpDB(Prefix: string;
  const HelpDB: THelpDatabase; const sl: TStrings);
var
  DBIRegExprMessage: THelpDBIRegExprMessage;
  DBISourceDirectories: THelpDBISourceDirectories;
  DBISourceDirectory: THelpDBISourceDirectory;
  DBISourceFile: THelpDBISourceFile;
  DBItem: THelpDBItem;
  i: Integer;
  HTMLHelp: THTMLHelpDatabase;
begin
  sl.Add(Prefix+DbgSName(HelpDB));
  sl.Add(Prefix+'ID='+HelpDB.ID);
  sl.Add(Prefix+'LocalizedName='+dbgstr(HelpDB.GetLocalizedName));
  if HelpDB.BasePathObject<>nil then
    sl.Add(Prefix+'BasePathObject='+DbgSName(HelpDB.BasePathObject));
  sl.Add(Prefix+'Registered='+dbgs(HelpDB.Registered));
  if HelpDB.SupportedMimeTypes<>nil then begin
    sl.Add(Prefix+'SupportedMimeTypes: '+IntToStr(HelpDB.SupportedMimeTypes.Count));
    for i:=0 to HelpDB.SupportedMimeTypes.Count-1 do
      sl.Add(Prefix+'  '+HelpDB.SupportedMimeTypes[i]);
  end;
  if HelpDB is THTMLHelpDatabase then begin
    HTMLHelp:=THTMLHelpDatabase(HelpDB);
    sl.Add(Prefix+'BaseURL='+dbgstr(HTMLHelp.BaseURL));
    if HTMLHelp.BaseURL='' then
      sl.Add(Prefix+'DefaultBaseURL='+dbgstr(HTMLHelp.DefaultBaseURL));
    sl.Add(Prefix+'KeywordPrefix='+dbgstr(HTMLHelp.KeywordPrefix));
  end;

  // registered items
  sl.Add(Prefix+'Items:');
  for i:=0 to HelpDB.RegisteredItemCount-1 do begin
    DBItem:=HelpDB.GetRegisteredItem(i);
    sl.Add(Prefix+'  '+IntToStr(i+1)+'/'+IntToStr(HelpDB.RegisteredItemCount)+': '+DbgSName(
      DBItem));
    if DBItem is THelpDBISourceFile then begin
      DBISourceFile:=THelpDBISourceFile(DBItem);
      sl.Add(Prefix+'    Filename='+DBISourceFile.Filename);
      sl.Add(Prefix+'    FullFilename='+DBISourceFile.GetFullFilename);
      sl.Add(Prefix+'    BasePath='+DBISourceFile.GetBasePath);
      if DBISourceFile is THelpDBISourceDirectory then begin
        DBISourceDirectory:=THelpDBISourceDirectory(DBISourceFile);
        sl.Add(Prefix+'    FileMask='+DBISourceDirectory.FileMask);
        sl.Add(Prefix+'    WithSubDirectories='+dbgs(DBISourceDirectory.
          WithSubDirectories));
        if DBISourceDirectory is THelpDBISourceDirectories then begin
          DBISourceDirectories:=THelpDBISourceDirectories(DBISourceDirectory);
          sl.Add(Prefix+'    BaseDirectory='+DBISourceDirectories.BaseDirectory);
        end;
      end;
    end else if DBItem is THelpDBIClass then begin
      sl.Add(Prefix+'    Class='+DbgSName(THelpDBIClass(DBItem)));
    end else if DBItem is THelpDBIRegExprMessage then begin
      DBIRegExprMessage:=THelpDBIRegExprMessage(DBItem);
      sl.Add(Prefix+'    Expression='+DBIRegExprMessage.Expression);
      sl.Add(Prefix+'    ModifierStr='+DBIRegExprMessage.ModifierStr);
    end;
  end;
  sl.Add('');
end;

procedure TIDEInfoDialog.GatherHelpViewer(Prefix: string;
  const Viewer: THelpViewer; const sl: TStrings);
var
  i: Integer;
begin
  sl.Add(Prefix+DbgSName(Viewer));
  sl.Add(Prefix+'StorageName='+Viewer.StorageName);
  sl.Add(Prefix+'ParameterHelp='+Viewer.ParameterHelp);
  sl.Add(Prefix+'LocalizedName='+dbgstr(Viewer.GetLocalizedName));
  if Viewer.SupportedMimeTypes<>nil then begin
    sl.Add(Prefix+'SupportedMimeTypes: '+IntToStr(Viewer.SupportedMimeTypes.Count));
    for i:=0 to Viewer.SupportedMimeTypes.Count-1 do
      sl.Add(Prefix+'  '+Viewer.SupportedMimeTypes[i]);
  end;
  sl.Add('');
end;

procedure TIDEInfoDialog.GatherExternalTools(sl: TStrings);
var
  i, j: Integer;
  Tool: TAbstractExternalTool;
  View: TExtToolView;
  Parser: TExtToolParser;
begin
  sl.Add('External Tools: '+IntToStr(ExternalToolList.Count));
  for i:=0 to ExternalToolList.Count-1 do begin
    Tool:=ExternalToolList[i];
    sl.Add('Tool '+IntToStr(i)+'/'+IntToStr(ExternalToolList.Count)
      +' ParserCount='+IntToStr(Tool.ParserCount)+' ViewCount='+IntToStr(Tool.ViewCount));
    sl.Add('  Stage='+dbgs(Tool.Stage));
    sl.Add('  Process.Active='+dbgs(Tool.Process.Active));
    sl.Add('  Process.Executable='+AnsiQuotedStr(Tool.Process.Executable,'"'));
    sl.Add('  Process.CurrentDirectory='+AnsiQuotedStr(Tool.Process.CurrentDirectory,'"'));
    sl.Add('  Process.Running='+dbgs(Tool.Process.Running));
    sl.Add('  CmdLineParams='+AnsiQuotedStr(Tool.CmdLineParams,'"'));
    sl.Add('  ErrorMessage='+AnsiQuotedStr(Tool.ErrorMessage,'"'));
    sl.Add('  ExitCode='+IntToStr(Tool.ExitCode));
    sl.Add('  ExitStatus='+IntToStr(Tool.ExitStatus));
    sl.Add('  Terminated='+dbgs(Tool.Terminated));
    sl.Add('  ReadStdOutBeforeErr='+dbgs(Tool.ReadStdOutBeforeErr));
    sl.Add('  WorkerDirectory='+AnsiQuotedStr(Tool.WorkerDirectory,'"'));

    for j:=0 to Tool.ViewCount-1 do begin
      Parser:=Tool.Parsers[j];
      sl.Add('   Parser '+IntToStr(j)+'/'+IntToStr(Tool.ParserCount)+' '+Parser.ClassName);
    end;

    for j:=0 to Tool.ViewCount-1 do begin
      View:=Tool.Views[j];
      sl.Add('   View '+IntToStr(j)+'/'+IntToStr(Tool.ViewCount)+' '+AnsiQuotedStr(View.Caption,'"'));
    end;
    sl.Add('');
  end;
end;

procedure TIDEInfoDialog.GatherIDEVersion(sl: TStrings);
begin
  sl.Add('Lazarus version: '+LazarusVersionStr);
  sl.Add('Lazarus revision: '+LazarusRevisionStr);
  sl.Add('Lazarus build date: '+LazarusBuildDateStr+' '+LazarusBuildTimeStr);
  sl.Add('Lazarus was compiled for '+FPCAdds.GetCompiledTargetCPU+'-'+FPCAdds.GetCompiledTargetOS);
  sl.Add('Lazarus was compiled with FPC '+{$I %FPCVERSION%});
  sl.Add('');
end;

procedure TIDEInfoDialog.GatherParameters(sl: TStrings);
var
  i: Integer;
  loFileDateTime: TDateTime;
begin
  sl.Add('Working directory='+GetCurrentDirUTF8);
  sl.Add('Application.ExeName='+Application.ExeName);
  if FileAge(Application.ExeName, loFileDateTime) then
    sl.Add(FormatDateTime('yyyy/mm/dd hh:nn:ss',loFileDateTime));

  sl.Add('');
  sl.add('Parameters:');
  for i:=0 to Paramcount do
    sl.Add(ParamStrUTF8(i));
  sl.Add('');
end;

procedure TIDEInfoDialog.GatherSystemLanguageInfo(sl: TStrings);
var
  LangID: TLanguageID;
begin
  LangID:=GetLanguageID;
  sl.Add('System preferred language:');
  sl.Add('Language ID: '''+LangID.LanguageID+'''');
  sl.Add('Language code: '''+LangID.LanguageCode+'''');
  sl.Add('Country code: '''+LangID.CountryCode+'''');
  sl.Add('');
end;

procedure TIDEInfoDialog.GatherEnvironmentVars(sl: TStrings);
var
  i: Integer;
  TempList: TStringListUTF8Fast;
begin
  sl.Add('Environment variables:');
  TempList:=TStringListUTF8Fast.Create;
  for i:=0 to GetEnvironmentVariableCount-1 do
    TempList.Add(GetEnvironmentStringUTF8(i));
  TempList.Sort;
  sl.AddStrings(TempList);
  TempList.free;
  sl.Add('');
end;

procedure TIDEInfoDialog.GatherGlobalOptions(sl: TStrings);
var
  CfgCache: TPCTargetConfigCache;
  Note, aFilename: string;
  CompilerKind: TPascalCompiler;
begin
  sl.add('Global IDE options:');
  sl.Add('Primary config directory='+GetPrimaryConfigPath);
  sl.Add('Secondary config directory='+GetSecondaryConfigPath);

  sl.Add('LazarusDirectory='+EnvironmentOptions.LazarusDirectory);
  sl.Add('Real LazarusDirectory='+EnvironmentOptions.GetParsedLazarusDirectory);
  if CheckLazarusDirectoryQuality(EnvironmentOptions.GetParsedLazarusDirectory,Note)<>sddqCompatible
  then
    sl.Add('WARNING: '+Note);

  sl.Add('Default CompilerFilename='+EnvironmentOptions.CompilerFilename);
  sl.Add('Real Default CompilerFilename='+EnvironmentOptions.GetParsedCompilerFilename);
  if CheckFPCExeQuality(EnvironmentOptions.GetParsedCompilerFilename,Note,
                       CodeToolBoss.CompilerDefinesCache.TestFilename)<>sddqCompatible
  then
    sl.Add('WARNING: '+Note);

  if Project1<>nil then begin
    sl.Add('Project CompilerFilename='+Project1.CompilerOptions.CompilerPath);
    aFilename:=LazarusIDE.GetCompilerFilename;
    sl.Add('Real Project CompilerFilename='+aFilename);
    IsCompilerExecutable(aFilename,Note,CompilerKind,true);
    if CompilerKind=pcPas2js then begin
      if CheckPas2jsQuality(aFilename,Note,
                           CodeToolBoss.CompilerDefinesCache.TestFilename)<>sddqCompatible
      then
        sl.Add('WARNING: '+Note);
    end else begin
      if CheckFPCExeQuality(aFilename,Note,
                           CodeToolBoss.CompilerDefinesCache.TestFilename)<>sddqCompatible
      then
        sl.Add('WARNING: '+Note);
    end;
  end;

  sl.Add('CompilerMessagesFilename='+EnvironmentOptions.CompilerMessagesFilename);
  sl.Add('Real CompilerMessagesFilename='+EnvironmentOptions.GetParsedCompilerMessagesFilename);

  sl.Add('FPC source directory='+EnvironmentOptions.FPCSourceDirectory);
  sl.Add('Real FPC source directory='+EnvironmentOptions.GetParsedFPCSourceDirectory);
  CfgCache:=CodeToolBoss.CompilerDefinesCache.ConfigCaches.Find(
    LazarusIDE.GetFPCompilerFilename,true);
  if CheckFPCSrcDirQuality(EnvironmentOptions.GetParsedFPCSourceDirectory,Note,
    CfgCache.GetFPCVer)<>sddqCompatible
  then
    sl.Add('WARNING: '+Note);

  sl.Add('Test directory='+EnvironmentOptions.TestBuildDirectory);
  sl.Add('Real Test directory='+EnvironmentOptions.GetParsedTestBuildDirectory);
  sl.Add('');
end;

procedure TIDEInfoDialog.GatherModifiedProject(AProject: TProject; sl: TStrings);
var
  aFile: TUnitInfo;
  HeaderWritten: Boolean;
  s: String;
  i: Integer;
begin
  // summary
  if AProject.Modified then
    sl.Add('Project.Modified');
  if AProject.SessionModified then
    sl.Add('Project.SessionModified');
  if Project1.SomethingModified(true,false) then
    sl.Add('Project.SomethingModified Data');
  if Project1.SomethingModified(false,true) then
    sl.Add('Project.SomethingModified Session');
  if SourceEditorManager.SomethingModified(false) then
    sl.Add('SourceEditorManager.SomethingModified');
  if AProject.BuildModes.IsModified(false) then
    sl.Add('Project.BuildModes.IsModified data');
  if AProject.BuildModes.SharedMatrixOptions.Modified then
    sl.Add('Project.BuildModes.SharedMatrixOptions.Modified');
  if AProject.BuildModes.IsModified(true) then
    sl.Add('Project.BuildModes.IsModified session');
  if AProject.BuildModes.SessionMatrixOptions.Modified then
    sl.Add('Project.BuildModes.SessionMatrixOptions.Modified');
  for i:=0 to AProject.BuildModes.Count-1 do
    if AProject.BuildModes[i].Modified then
      sl.Add('Project.BuildModes['+dbgs(i)+'].Name='+AProject.BuildModes[i].Name+' InSession='+dbgs(AProject.BuildModes[i].InSession));
  sl.Add('');

  // details
  HeaderWritten:=false;
  aFile:=AProject.FirstPartOfProject;
  while aFile<>nil do begin
    if aFile.Modified or aFile.SessionModified
    or ((aFile.Source<>nil) and aFile.Source.Modified)
    then begin
      if not HeaderWritten then begin
        sl.Add('Project units:');
        HeaderWritten:=true;
      end;
      s:=aFile.GetShortFilename(true);
      if aFile.Modified then
        s:=s+' Modified';
      if aFile.SessionModified then
        s:=s+' SessionModified';
      if (aFile.Source<>nil) and (aFile.Source.Modified) then
        s:=s+' Source.Modified';
      sl.Add(s);
    end;
    aFile:=aFile.NextPartOfProject;
  end;
  if HeaderWritten then
    sl.Add('');
end;

procedure TIDEInfoDialog.GatherModifiedPackages(sl: TStrings);
var
  i: Integer;
  Pkg: TLazPackage;
  HeaderWritten: Boolean;
begin
  HeaderWritten:=false;
  for i:=0 to PackageGraph.Count-1 do begin
    Pkg:=PackageGraph[i];
    if Pkg.Modified then begin
      if not HeaderWritten then begin
        HeaderWritten:=true;
        sl.Add('Packages:');
      end;
      sl.Add(Pkg.Name);
    end;
  end;
  if HeaderWritten then
    sl.Add('');
end;

procedure TIDEInfoDialog.GatherModifiedSourceEditor(sl: TStrings);
var
  HeaderWritten: Boolean;
  i: Integer;
  SrcEdit: TSourceEditor;
begin
  HeaderWritten:=false;
  if SourceEditorManager.SomethingModified(false) then begin
    sl.Add('Source Editor:');
    for i:=0 to SourceEditorManager.SourceEditorCount-1 do
    begin
      SrcEdit:=SourceEditorManager.SourceEditors[i];
      if not SrcEdit.Modified then continue;
      sl.Add('  '+SrcEdit.Filename+' Component='+dbgs(SrcEdit.EditorComponent.Modified));
    end;
  end;
  if HeaderWritten then
    sl.Add('');
end;

procedure TIDEInfoDialog.GatherHelpDatabases(sl: TStrings);
var
  i: Integer;
begin
  sl.Add('LazarusHelp='+DbgSName(LazarusHelp));
  sl.Add('HelpDatabases='+DbgSName(HelpDatabases));
  for i:=0 to HelpDatabases.Count-1 do begin
    sl.Add('DB '+IntToStr(i+1)+'/'+IntToStr(HelpDatabases.Count));
    GatherHelpDB('  ',HelpDatabases.Items[i],sl);
  end;
end;

procedure TIDEInfoDialog.GatherHelpViewers(sl: TStrings);
var
  i: Integer;
begin
  sl.Add('HelpViewers='+DbgSName(HelpViewers));
  for i:=0 to HelpViewers.Count-1 do begin
    sl.Add('DB '+IntToStr(i+1)+'/'+IntToStr(HelpViewers.Count));
    GatherHelpViewer('  ',HelpViewers.Items[i],sl);
  end;
end;

procedure TIDEInfoDialog.UpdateGeneralMemo;
var
  sl: TStringList;
begin
  sl:=TStringList.Create;
  try
    GatherIDEVersion(sl);
    GatherGlobalOptions(sl);
    GatherParameters(sl);
    GatherSystemLanguageInfo(sl);
    GatherEnvironmentVars(sl);
    GeneralMemo.Lines.Assign(sl);
  finally
    sl.Free;
  end;
end;

procedure TIDEInfoDialog.UpdateMacrosMemo;
var
  i: integer;
  lTransferMacro: TTransferMacro;
  lMacroFunctionStr: String;
  lStr : string = '???';
  lData: PtrInt = 0;
  lAbort: boolean;
begin
  MacrosMemo.Lines.Clear;
  try
    for i := 0 to GlobalMacroList.Count - 1 do begin
      lTransferMacro := GlobalMacroList.Items[i];
      lStr := lTransferMacro.Name;
      { Skip user interactive method calls }
      if tmfInteractive in lTransferMacro.Flags then begin
        Str(tmfInteractive, lStr);
        lMacroFunctionStr := '['+lstr+'] function';
      end
      { Dont know exactly what's that, protect access }
      else try
        lAbort := False;
        lData := 0;
        if Assigned(lTransferMacro.MacroFunction) then
          lMacroFunctionStr := lTransferMacro.MacroFunction(lStr, lData, lAbort);
      except
        lMacroFunctionStr := '??? MacroFunction ???';
        lAbort := True;
      end;
      MacrosMemo.Lines.Add('$('+lTransferMacro.Name+')='+lMacroFunctionStr);
    end;
  finally
    ModifiedMemo.Lines.EndUpdate;
  end;
end;

procedure TIDEInfoDialog.UpdateModifiedMemo;
var
  sl: TStringList;
begin
  sl:=TStringList.Create;
  try
    GatherModifiedProject(Project1,sl);
    GatherModifiedPackages(sl);
    GatherModifiedSourceEditor(sl);
    ModifiedMemo.Lines.Assign(sl);
  finally
    sl.Free;
  end;
end;

procedure TIDEInfoDialog.UpdateHelpMemo;
var
  sl: TStringList;
begin
  sl:=TStringList.Create;
  try
    GatherHelpDatabases(sl);
    GatherHelpViewers(sl);
    HelpMemo.Lines.Assign(sl);
  finally
    sl.Free;
  end;
end;

procedure TIDEInfoDialog.UpdateExternalTools;
var
  sl: TStringList;
begin
  sl:=TStringList.Create;
  try
    GatherExternalTools(sl);
    ExtToolMemo.Lines.Assign(sl);
  finally
    sl.Free;
  end;
end;

end.

