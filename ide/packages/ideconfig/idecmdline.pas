{
 /***************************************************************************
                              idecmdline.pas
                             --------------------
               A unit to manage command lines issue used inside the ide

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
 
 Author: Ido Kanner

  This unit manages the commandline utils that are used across Lazarus.
  It was created for avoding duplicates and easier access for commandline utils
  that are required by the IDE.
}
unit IDECmdLine;

{$mode objfpc}{$H+}

interface

uses 
  Classes, SysUtils,
  // LazUtils
  FileUtil, LazFileUtils, LazStringUtils, LazUtilities, LazUTF8, LazLogger,
  // IdeConfig
  LazConf;

// Checks at startup that can be skipped
// Packages may add there own...
type
  TSkipAbleChecks = (
    skcLazDir,         // Correct Lazarus-dir / CheckLazarusDirectoryQuality
    skcFpcExe,         // fpc.exe / CheckFPCExeQuality
    skcFpcSrc,         // fpc source dir / CheckFPCSrcDirQuality
    skcMake,           // make.exe / CheckMakeExeQuality
    skcDebugger,       // CheckDebuggerQuality
    skcFppkg,          // CheckFppkgConfiguration
    skcSetup,          // **All** of the above
    skcMissingPackageFile, // lisPkgSysPackageFileNotFound = 'Package file not found';
    skcLastCalled,     // Config was last used by this/other installation
    skcUniqueInstance, // Other running IDE // Attempt to get lock file
    skcAll             // **ALL**
  );
const
  // IDE cmd line options (long options are case insensitive)
  ShowSetupDialogOptLong='--setup';
  PrimaryConfPathOptLong='--primary-config-path=';
  PrimaryConfPathOptShort='--pcp=';
  SecondaryConfPathOptLong='--secondary-config-path=';
  SecondaryConfPathOptShort='--scp=';
  NoSplashScreenOptLong='--no-splash-screen';
  NoSplashScreenOptShort='--nsc';
  StartedByStartLazarusOpt='--started-by-startlazarus';
  ForceNewInstanceOpt='--force-new-instance';
  SkipLastProjectOpt='--skip-last-project';
  DebugLogOpt='--debug-log=';
  DebugLogCloseLogOpt='--debug-close-log';
  DebugLogOptEnable='--debug-enable=';
  LanguageOpt='--language=';
  LazarusDirOpt ='--lazarusdir=';
  SkipChecksOptLong='--skip-checks=';
  SkipChecksKeys: array[TSkipAbleChecks] of string = (
    'LazarusDir',
    'FpcExe',
    'FpcSrc',
    'Make',
    'Debugger',
    'Fppkg',
    'Setup',
    'MissingPackageFile',
    'InstallDir',
    'SingleInstance',
    'All'
  );
  DisableDockingOpt = '--disabledocking'; //Ultibo
  // lazbuild cmd line options (long options are case insensitive)
  CompilerOptLong = '--compiler';
  AddPackageLink = '--add-package-link';

  LazFileOpts: array[1..7] of string = (
    PrimaryConfPathOptLong,PrimaryConfPathOptShort,
    SecondaryConfPathOptLong,SecondaryConfPathOptShort,
    LazarusDirOpt,
    CompilerOptLong,
    AddPackageLink
  );

const
  // startlazarus options
  StartLazarusPidOpt   = '--lazarus-pid=';
  StartLazarusDebugOpt = '--debug';

procedure ParseCommandLine(aCmdLineParams: TStrings; out IDEPid : Integer;
            out ShowSplashScreen: boolean);
function GetCommandLineParameters(aCmdLineParams: TStrings;
            isStartLazarus: Boolean = False) : string;
function ExtractPrimaryConfigPath(aCmdLineParams: TStrings): string;
function ExpandParamFile(const s: string): string;

function IsHelpRequested : Boolean;
function IsVersionRequested : boolean;
function GetLanguageSpecified : string;
function ParamIsOption(ParamIndex : integer; const Option : string) : boolean; overload; // case insensitive
function ParamIsOption(ParamIndex : integer; const OptionShort, OptionLong: string) : boolean; overload; // case insensitive
function ParamIsOptionPlusValue(ParamIndex : integer;
            const Option : string; out AValue : string) : boolean;

procedure ParseNoGuiCmdLineParams;

function ExtractCmdLineFilenames : TStrings;

// options from CFG file
function GetCfgFileName: string;
function GetCfgFileContent: TStrings;
function GetParamsAndCfgFile: TStrings;
function ParamsAndCfgCount: Integer;
function ParamsAndCfgStr(Idx: Integer): String;
procedure ResetParamsAndCfg;

function GetSkipCheck(AKey: TSkipAbleChecks): Boolean;
function GetSkipCheckByKey(AKey: String): Boolean;


implementation

var
  CfgFileDone: Boolean = False;
  CfgFileContent: TStrings = nil;
  ParamsAndCfgFileContent: TStrings = nil;

function GetCfgFileName: string;
begin
  result := AppendPathDelim(ProgramDirectoryWithBundle) + 'lazarus.cfg';
end;

function GetCfgFileContent: TStrings;
begin
  Result := CfgFileContent;
  if CfgFileDone then
    exit;
  CfgFileDone := True;
  if FileExistsUTF8(GetCfgFileName) then begin
    CfgFileContent := TStringList.Create;
    CfgFileContent.LoadFromFile(GetCfgFileName);
  end;
  Result := CfgFileContent;
end;

function GetParamsAndCfgFile: TStrings;
var
  CfgDir: string;

  procedure ExpandCfgFilename(var aParam: string);
  // expand relative filenames in lazarus.cfg using the path of the cfg, not the currentdir
  var
    i: Integer;
    aFilename: String;
  begin
    for i:=low(LazFileOpts) to high(LazFileOpts) do
      if LazStartsText(LazFileOpts[i],aParam) then begin
        aFilename:=copy(aParam,length(LazFileOpts[i])+1,length(aParam));
        aFilename:=ExpandFileNameUTF8(aFilename,CfgDir);
        aParam:=LazFileOpts[i]+aFilename;
        //debugln(['ExpandCfgFilename ',aParam]);
        exit;
      end;
  end;

  procedure CleanDuplicates(const ParamNames: array of string);
  // keep the last and delete the rest
  var
    i, j, Found: Integer;
    s: String;
  begin
    // ParamsAndCfgFileContent[0] is the exe -> never delete that
    Found:=-1;
    i:=ParamsAndCfgFileContent.Count-1;
    while i>0 do begin
      s:=ParamsAndCfgFileContent[i];
      for j:=0 to high(ParamNames) do begin
        if LazStartsText(ParamNames[j],s) then begin
          if Found<1 then
            Found:=i
          else
            ParamsAndCfgFileContent.Delete(i);
        end;
      end;
      dec(i);
    end;
  end;

var
  Cfg: TStrings;
  i: Integer;
  s: String;
  Warn: String;
begin
  Result := ParamsAndCfgFileContent;
  if Result <> nil then
    exit;
  ParamsAndCfgFileContent := TStringList.Create;
  ParamsAndCfgFileContent.Add(ParamStrUTF8(0));

  Cfg := GetCfgFileContent;
  if Cfg <> nil then begin
    Warn := '';
    // insert Cfg at start. For duplicates the latest occurrence takes precedence
    CfgDir:=ExtractFilePath(GetCfgFileName);
    for i := 0 to Cfg.Count - 1 do begin
      s := Cfg[i];
      if (s <> '') and (s[1] = '-') then
        begin
          s := Trim(s);
          {$ifdef windows}
          //cfg file is made by Windows installer and probably is Windows default codepage
          if FindInvalidUTF8Codepoint(PChar(s), Length(s), True) > 0 then
            s := WinCPToUtf8(s);
          {$endif windows}

          ExpandCfgFilename(s);

          ParamsAndCfgFileContent.Add(s);
        end
      else
      if (Trim(s) <> '') and (s[1] <> '#') then
        Warn := Warn + IntToStr(i)+': ' + s + LineEnding;
    end;
    if Warn<>'' then begin
      debugln('WARNING: invalid lines in lazarus.cfg:');
      debugln(Warn);
    end;
  end;

  // append the cmd line params
  for i := 1 to Paramcount do
    ParamsAndCfgFileContent.Add(ParamStrUTF8(i));

  // delete duplicates, last wins
  CleanDuplicates([PrimaryConfPathOptShort,PrimaryConfPathOptLong]);
  CleanDuplicates([SecondaryConfPathOptShort,SecondaryConfPathOptLong]);
  CleanDuplicates([LanguageOpt]);
  CleanDuplicates([LazarusDirOpt]);

  Result := ParamsAndCfgFileContent;
end;

function ParamsAndCfgCount: Integer;
begin
  Result := GetParamsAndCfgFile.Count;
end;

function ParamsAndCfgStr(Idx: Integer): String;
begin
  if (Idx < 0) or (Idx >= GetParamsAndCfgFile.Count) then
    Result := ''
  else
    Result := GetParamsAndCfgFile[Idx];
end;

procedure ResetParamsAndCfg;
begin
  FreeAndNil(ParamsAndCfgFileContent);
end;

function GetSkipCheck(AKey: TSkipAbleChecks): Boolean;
begin
  Result := GetSkipCheckByKey(SkipChecksKeys[AKey]);
end;

function GetSkipCheckByKey(AKey: String): Boolean;
var
  i: integer;
  AValue: string;
begin
  // return language specified in command line (empty string if no language specified)
  Result := False;
  AKey := ','+UpperCase(AKey)+',';
  AValue := '';
  i := 1;
  while i <= ParamsAndCfgCount do
  begin
    if ParamIsOptionPlusValue(i, SkipChecksOptLong, AValue) = true then
    begin
      AValue := ','+UpperCase(AValue)+',';
      Result := Pos(AKey, AValue) > 0;
      if Result then
        exit;
    end;
    inc(i);
  end;
end;

procedure ParseCommandLine(aCmdLineParams: TStrings; out IDEPid: Integer; out
  ShowSplashScreen: boolean);
var
  i     : Integer;
  Param : string;
  HasDebugLog: Boolean;
begin
  IDEPid := 0;
  HasDebugLog := False;
  for i := 1 to ParamsAndCfgCount do begin
    Param := ParamsAndCfgStr(i);
    if Param='' then continue;
    if SysUtils.CompareText(LeftStr(Param, length(DebugLogOpt)), DebugLogOpt) = 0 then
      HasDebugLog := HasDebugLog or (length(Param) > length(DebugLogOpt));
    if (Param=StartLazarusDebugOpt) and (not HasDebugLog) then begin
      aCmdLineParams.Add('--debug-log=' +
                         AppendPathDelim(UTF8ToSys(GetPrimaryConfigPath)) + 'debug.log');
    end;
    if LeftStr(Param,length(StartLazarusPidOpt))=StartLazarusPidOpt then begin
      try
        IDEPid :=
          StrToInt(RightStr(Param,Length(Param)-Length(StartLazarusPidOpt)));
      except
        DebugLn('Failed to parse %s',[Param]);
        IDEPid := 0;
      end;
    end
    else if ParamIsOption(i, NoSplashScreenOptShort,NoSplashScreenOptLong) then
    begin
      ShowSplashScreen := false;
    end
    else begin
      // Do not add file to the parameter list
      if not (Copy(Param,1,1) = '-') and (FileExistsUTF8(ExpandFileNameUTF8(Param))) then
      begin
        DebugLn('%s is a file', [Param]);
        continue;
      end;

      // pass these parameters to Lazarus
      DebugLn('Adding "%s" as a parameter', [Param]);
      aCmdLineParams.Add(Param);
    end;
  end;
end;

function GetCommandLineParameters(aCmdLineParams : TStrings; isStartLazarus : Boolean = False) : String;
var
  i: Integer;
  s: String;
begin
  if isStartLazarus then
    Result := ' '+NoSplashScreenOptLong+' '+StartedByStartLazarusOpt
  else
    Result := '';
  for i := 0 to aCmdLineParams.Count - 1 do begin
    s := aCmdLineParams[i];
    // make sure that command line parameters are still
    // double quoted, if they contain spaces
    if pos(' ', s) > 0 then
      s := '"' + s + '"';
    Result := Result + ' ' + s;
  end;
end;

function ExtractPrimaryConfigPath(aCmdLineParams: TStrings): string;

  function GetParam(const Param, Prefix: string): boolean;
  begin
    if not LazStartsText(Prefix,Param) then exit(false);
    ExtractPrimaryConfigPath:=copy(Param,length(Prefix)+1,length(Param));
  end;

var
  i: Integer;
begin
  Result:='';
  for i:=aCmdLineParams.Count-1 downto 0 do
  begin
    if GetParam(aCmdLineParams[i],PrimaryConfPathOptLong) then exit;
    if GetParam(aCmdLineParams[i],PrimaryConfPathOptShort) then exit;
  end;
end;

function ExpandParamFile(const s: string): string;
var
  p: string;
begin
  Result:=s;
  for p in LazFileOpts do
    if LazStartsText(p,Result) then
    begin
    Result:=LeftStr(Result,length(p))+ExpandFileNameUTF8(copy(Result,length(p)+1,length(Result)));
    exit;
    end;
end;

function IsHelpRequested : Boolean;
var
  i: integer;
begin
  Result := false;
  i:=1;
  while (i <= ParamsAndCfgCount) and (Result = false) do
  begin
    Result := ParamIsOption(i, '--help') or
              ParamIsOption(i, '-help')  or
              ParamIsOption(i, '-?')     or
              ParamIsOption(i, '-h');
    inc(i);
  end;
end;

function IsVersionRequested: boolean;
begin
  Result := (ParamCount=1) and
            ((ParamStr(1)='--version') or
            (ParamStr(1)='-v'));
end;

function GetLanguageSpecified : string;
var
  i: integer;
  AValue: string;
begin
  // return language specified in command line (empty string if no language specified)
  Result := '';
  AValue := '';
  i := 1;
  while i <= ParamsAndCfgCount do
  begin
    if ParamIsOptionPlusValue(i, LanguageOpt, AValue) = true then
    begin
      Result := AValue;
      exit;
    end;
    inc(i);
  end;
end;

function ParamIsOption(ParamIndex : integer; const Option : string) : boolean;
begin
  Result:=SysUtils.CompareText(ParamsAndCfgStr(ParamIndex),Option) = 0;
end;

function ParamIsOption(ParamIndex: integer; const OptionShort,
  OptionLong: string): boolean;
var
  s: String;
begin
  s:=ParamsAndCfgStr(ParamIndex);
  Result:=SameText(s,OptionShort) or SameText(s,OptionLong);
end;

function ParamIsOptionPlusValue(ParamIndex : integer;
    const Option : string; out AValue : string) : boolean;
var
  p : String;
begin
 p      := ParamsAndCfgStr(ParamIndex);
 Result := SysUtils.CompareText(LeftStr(p, length(Option)), Option) = 0;
 if Result then
   AValue := copy(p, length(Option) + 1, length(p))
 else
   AValue := '';
end;

procedure ParseNoGuiCmdLineParams;
var
  i      : integer;
  AValue : String;
begin
  for i:=1 to ParamsAndCfgCount do
  begin
    //DebugLn(['ParseNoGuiCmdLineParams ',i,' "',ParamsAndCfgStr(i),'"']);
    if ParamIsOptionPlusValue(i, PrimaryConfPathOptLong, AValue) then
      SetPrimaryConfigPath(AValue)
    else if ParamIsOptionPlusValue(i, PrimaryConfPathOptShort, AValue) then
      SetPrimaryConfigPath(AValue)
    else if ParamIsOptionPlusValue(i, SecondaryConfPathOptLong, AValue) then
      SetSecondaryConfigPath(AValue)
    else if ParamIsOptionPlusValue(i, SecondaryConfPathOptShort, AValue) then
      SetSecondaryConfigPath(AValue);
  end;
end;

function ExtractCmdLineFilenames : TStrings;
var
  i        : LongInt;
  Filename : String;
  
begin
  Result := nil;
  for i := 1 to ParamsAndCfgCount do
   begin
     Filename := ParamsAndCfgStr(i);
     if (Filename = '') or (Filename[1] = '-') then
       continue;
     if Result = nil then
       Result := TStringList.Create;
     Result.Add(Filename);
    end;
end;

procedure InitLogger;
var
  i      : integer;
  AValue : String;
begin
  for i:= 1 to ParamsAndCfgCount do
  begin
    if ParamIsOptionPlusValue(i, DebugLogOpt, AValue) then
      LazLogger.DebugLogger.LogName := AValue
    else if ParamIsOption(i, DebugLogCloseLogOpt) then
      LazLogger.DebugLogger.CloseLogFileBetweenWrites := true;
  end;
end;

initialization
  InitLogger;
  SetSkipCheckByKeyProc(@GetSkipCheckByKey);
finalization
  FreeAndNil(CfgFileContent);
  FreeAndNil(ParamsAndCfgFileContent);
end.

