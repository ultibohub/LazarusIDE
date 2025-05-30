{
 /***************************************************************************
                       idemacros.pp  -  macros for tools
                       ---------------------------------

 ***************************************************************************/

 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract:
    This unit defines the classes TTransferMacro and TTransferMacroList. These
    classes store and substitute macros in strings. Transfer macros are an
    easy way to transfer some ide variables to programs like the compiler,
    the debugger and all the other tools.
    Transfer macros have the form $(macro_name). It is also possible to define
    macro functions, which have the form $macro_func_name(parameter).
    The default macro functions are:
      $Ext(filename) - equal to ExtractFileExt
      $Path(filename) - equal to ExtractFilePath
      $Name(filename) - equal to ExtractFileName
      $NameOnly(filename) - equal to ExtractFileName but without extension.
      $MakeDir(filename) - append path delimiter
      $MakeFile(filename) - chomp path delimiter
      $Trim(filename) - equal to TrimFilename
}
unit TransferMacros;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LazUtils
  LazFileUtils, LazUTF8, LazFileCache, LazConfigStorage,
  // CodeTools
  FileProcs, CodeToolManager,
  // BuildIntf
  MacroIntf, MacroDefIntf, BaseIDEIntf,
  // IdeConfig
  LazConf, IdeConfStrConsts;

const
  LazbuildMacrosFileName = 'lazbuildmacros.xml';

type

  { TTransferMacroList }

  TTransferMacroList = class
  private
    fItems: TFPList;  // list of TTransferMacro
    FMarkUnhandledMacros: boolean;
    FMaxUsePerMacro: integer;
    fOnSubstitution: TOnSubstitution;
    procedure SetMarkUnhandledMacros(const AValue: boolean);
  protected
    function GetItems(Index: integer): TTransferMacro;
    procedure SetItems(Index: integer; NewMacro: TTransferMacro);
  protected
    function MF_Ext(const Filename:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    function MF_Path(const Filename:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    function MF_Name(const Filename:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    function MF_NameOnly(const Filename:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    function MF_MakeDir(const Filename:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    function MF_MakeFile(const Filename:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    function MF_EncloseBracket(const Text:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    function MF_Trim(const Filename:string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean):string; virtual;
    procedure DoSubstitution(TheMacro: TTransferMacro; const MacroName: string;
      var s:string; const Data: PtrInt; var Handled, Abort: boolean;
      Depth: integer); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: integer;
    property Items[Index: integer]: TTransferMacro read GetItems write SetItems; default;
    procedure SetValue(const MacroName, NewValue: string);
    procedure Clear;
    procedure Delete(Index: integer);
    procedure Add(NewMacro: TTransferMacro);
    function FindByName(const MacroName: string): TTransferMacro;
    function SubstituteStr(var s: string; const Data: PtrInt = 0;
      Depth: integer = 0; SkipInteractive: Boolean = False): boolean;
    procedure ExecuteMacro(const MacroName: string;
      var MacroParam: string; const Data: PtrInt; out Handled, Abort: boolean;
      Depth: integer; SkipInteractive: boolean = False);
    class function StrHasMacros(const s: string): boolean;
    property OnSubstitution: TOnSubstitution read fOnSubstitution write fOnSubstitution;
    // error handling and loop detection
    property MarkUnhandledMacros: boolean read FMarkUnhandledMacros
                                          write SetMarkUnhandledMacros default true;
    property MaxUsePerMacro: integer read FMaxUsePerMacro write FMaxUsePerMacro default 3;
  end;
  TTransferMacroListClass = class of TTransferMacroList;

  { TLazIDEMacros }

  TLazIDEMacros = class(TIDEMacros)
  private
    FLazbuildMacroFileAge: longint; // file age when last time the lazbuild macros were stored
    FLazbuildMacros: TStringListUTF8Fast; // last stored lazbuild macros
  public
    destructor Destroy; override;
    function StrHasMacros(const s: string): boolean; override;
    function SubstituteMacros(var s: string): boolean; override;
    function IsMacro(const Name: string): boolean; override;
    procedure Add(NewMacro: TTransferMacro);override; overload;
  public
    // lazbuild macros
    procedure LoadLazbuildMacros; // called by lazbuild
    procedure SaveLazbuildMacros; // called by IDE
  end;

//type
//  TCompilerParseStampIncreasedEvent = procedure of object;
var
  //CompilerParseStampIncreased: TCompilerParseStampIncreasedEvent = nil;
  GlobalMacroListClass: TTransferMacroListClass = TTransferMacroList;
  GlobalMacroList: TTransferMacroList = nil;

  CompilerParseStamp: integer = 0; // TimeStamp of base value for macros
  BuildMacroChangeStamp: integer = 0; // TimeStamp of base value for build macros

procedure IncreaseCompilerParseStamp;
// Called when a package dependency changes or when project build macro values change.
//  Automatically calls IncreaseCompilerParseStamp
procedure IncreaseBuildMacroChangeStamp;


implementation

var
  IsIdentChar: array[char] of boolean;

procedure IncreaseCompilerParseStamp;
begin
  if IDEMacros<>nil then
    IDEMacros.IncreaseBaseStamp;
  CTIncreaseChangeStamp(CompilerParseStamp);
  CodeToolBoss.DefineTree.ClearCache;
  //if Assigned(CompilerParseStampIncreased) then
  //  CompilerParseStampIncreased();
end;

procedure IncreaseBuildMacroChangeStamp;
begin
  if IDEMacros<>Nil then
    IDEMacros.IncreaseGraphStamp;
  IncreaseCompilerParseStamp;
  CTIncreaseChangeStamp(BuildMacroChangeStamp);
end;

{ TTransferMacroList }

constructor TTransferMacroList.Create;
begin
  inherited Create;
  fItems:=TFPList.Create;
  FMarkUnhandledMacros:=true;
  FMaxUsePerMacro:=3;
  Add(TTransferMacro.Create('Ext', '', lisTMFunctionExtractFileExtension, @MF_Ext, []));
  Add(TTransferMacro.Create('Path', '', lisTMFunctionExtractFilePath, @MF_Path, []));
  Add(TTransferMacro.Create('Name', '', lisTMFunctionExtractFileNameExtension, @MF_Name,[]));
  Add(TTransferMacro.Create('NameOnly', '', lisTMFunctionExtractFileNameOnly, @MF_NameOnly,[]));
  Add(TTransferMacro.Create('MakeDir', '', lisTMFunctionAppendPathDelimiter, @MF_MakeDir,[]));
  Add(TTransferMacro.Create('MakeFile', '', lisTMFunctionChompPathDelimiter, @MF_MakeFile,[]));
  Add(TTransferMacro.Create('EncloseBracket', '', lisTMFunctionEncloseBrackets, @MF_EncloseBracket,[]));
end;

destructor TTransferMacroList.Destroy;
begin
  Clear;
  FreeAndNil(fItems);
  inherited Destroy;
end;

function TTransferMacroList.GetItems(Index: integer): TTransferMacro;
begin
  Result:=TTransferMacro(fItems[Index]);
end;

procedure TTransferMacroList.SetItems(Index: integer; NewMacro: TTransferMacro);
begin
  fItems[Index]:=NewMacro;
end;

procedure TTransferMacroList.SetMarkUnhandledMacros(const AValue: boolean);
begin
  if FMarkUnhandledMacros=AValue then exit;
  FMarkUnhandledMacros:=AValue;
end;

procedure TTransferMacroList.SetValue(const MacroName, NewValue: string);
var AMacro:TTransferMacro;
begin
  AMacro:=FindByName(MacroName);
  if AMacro<>nil then AMacro.Value:=NewValue;
end;

function TTransferMacroList.Count: integer;
begin
  Result:=fItems.Count;
end;

procedure TTransferMacroList.Clear;
var i:integer;
begin
  for i:=0 to fItems.Count-1 do Items[i].Free;
  fItems.Clear;
end;

procedure TTransferMacroList.Delete(Index: integer);
begin
  Items[Index].Free;
  fItems.Delete(Index);
end;

procedure TTransferMacroList.Add(NewMacro: TTransferMacro);
var
  l: Integer;
  r: Integer;
  m: Integer;
  cmp: Integer;
begin
  l:=0;
  r:=fItems.Count-1;
  m:=0;
  while l<=r do begin
    m:=(l+r) shr 1;
    cmp:=AnsiCompareText(NewMacro.Name,Items[m].Name);
    if cmp<0 then
      r:=m-1
    else if cmp>0 then
      l:=m+1
    else
      break;
  end;
  if (m<fItems.Count) and (AnsiCompareText(NewMacro.Name,Items[m].Name)>0) then
    inc(m);
  fItems.Insert(m,NewMacro);
  //if NewMacro.MacroFunction<>nil then
  //  debugln('TTransferMacroList.Add A ',NewMacro.Name);
end;

function TTransferMacroList.SubstituteStr(var s: string; const Data: PtrInt; Depth: integer;
  SkipInteractive: Boolean): boolean;

  function SearchBracketClose(Position: integer): integer;
  var BracketClose: char;
  begin
    if s[Position]='(' then BracketClose:=')'
    else BracketClose:='}';
    inc(Position);
    while (Position<=length(s)) and (s[Position]<>BracketClose) do begin
      if (s[Position] in ['(','{']) then
        Position:=SearchBracketClose(Position);
      inc(Position);
    end;
    Result:=Position;
  end;

var
  MacroStart, MacroEnd: integer;
  MacroName, MacroStr, MacroParam: string;
  Handled, Abort: boolean;
  sLen, OldMacroLen: Integer;
begin
  if Depth>10 then begin
    s:='(macro loop detected)'+s;
    exit(false);
  end;
  Result:=true;
  sLen:=length(s);
  MacroStart:=1;
  repeat
    while (MacroStart<sLen) do begin
      if (s[MacroStart]<>'$') then
        inc(MacroStart)
      else if (s[MacroStart+1]='$') then // skip $$
        inc(MacroStart,2)
      else
        break;
    end;
    if MacroStart>=sLen then break;
    
    MacroEnd:=MacroStart+1;
    while (MacroEnd<=sLen) and (IsIdentChar[s[MacroEnd]]) do
      inc(MacroEnd);

    if (MacroEnd<sLen) and (s[MacroEnd] in ['(','{']) then begin
      MacroName:=copy(s,MacroStart+1,MacroEnd-MacroStart-1);
      //debugln(['TTransferMacroList.SubstituteStr FUNC ',MacroName]);
      MacroEnd:=SearchBracketClose(MacroEnd)+1;
      if MacroEnd>sLen+1 then
      begin
        result := false;
        break; // missing closing bracket
      end;
      OldMacroLen:=MacroEnd-MacroStart;
      MacroStr:=copy(s,MacroStart,OldMacroLen);
      // Macro found
      if MacroName='' then begin
        // Macro variable
        MacroName:=copy(s,MacroStart+2,OldMacroLen-3);
        MacroParam:='';
      end else begin
        // Macro function -> substitute macro parameter first
        //if MacroName='LCLWidgetSet' then DebugLn(['TTransferMacroList.SubstituteStr MacroStr="',MacroStr,'"']);
        MacroParam:=copy(MacroStr,length(MacroName)+3,
                                  length(MacroStr)-length(MacroName)-3);
      end;
      //if MacroName='PATH' then
      //  debugln(['TTransferMacroList.SubstituteStr START MacroName=',MacroName,' Param="',MacroParam,'"']);
      if MacroParam<>'' then begin
        // substitute param
        if not SubstituteStr(MacroParam,Data,Depth+1) then // Recursive call.
          exit(false);
      end;
      // find macro and get value
      Handled:=false;
      Abort:=false;
      ExecuteMacro(MacroName,MacroParam,Data,Handled,Abort,Depth+1, SkipInteractive);
      if Abort then
        exit(false);
      if not Handled then
        result := false; // set error, but continue parsing
      MacroStr:=MacroParam;

      // substitute result
      if not SubstituteStr(MacroStr,Data,Depth+1) then // Recursive call.
        exit(false);

      // mark unhandled macros
      if not Handled and MarkUnhandledMacros then begin
        MacroStr:=Format(lisTMunknownMacro, [MacroStr]);
        Handled:=true;
      end;
      // replace macro with new value
      if Handled then begin
        s:=copy(s,1,MacroStart-1)+MacroStr+copy(s,MacroEnd,length(s));
        sLen:=length(s);
        // continue behind replacement
        MacroEnd:=MacroStart+length(MacroStr);
      end;
    end;
    MacroStart:=MacroEnd;
  until false;

  // convert $$ chars
  MacroStart:=2;
  while (MacroStart<sLen) do begin
    if (s[MacroStart]='$') and (s[MacroStart+1]='$') then begin
      System.Delete(s,MacroStart,1);
      dec(sLen);
    end;
    inc(MacroStart);
  end;
end;

procedure TTransferMacroList.ExecuteMacro(const MacroName: string; var MacroParam: string;
  const Data: PtrInt; out Handled, Abort: boolean; Depth: integer; SkipInteractive: boolean);
var
  Macro: TTransferMacro;
begin
  Handled:=false;
  Abort:=false;
  Macro:=FindByName(MacroName);
  if SkipInteractive and (Macro <> nil) and (tmfInteractive in Macro.Flags) then
    exit;
  DoSubstitution(Macro,MacroName,MacroParam,Data,Handled,Abort,Depth);
  if Abort or Handled then exit;
  if Macro=nil then exit;
  if Assigned(Macro.MacroFunction) then begin
    MacroParam:=Macro.MacroFunction(MacroParam,Data,Abort);
    if Abort then exit;
  end else begin
    MacroParam:=Macro.Value;
  end;
  Handled:=true;
end;

class function TTransferMacroList.StrHasMacros(const s: string): boolean;
// search for $( or $xxx(
var
  p: Integer;
  Len: Integer;
begin
  Result:=false;
  p:=1;
  Len:=length(s);
  while (p<Len) do begin
    if s[p]='$' then begin
      inc(p);
      if (p<Len) and (s[p]<>'$') then begin
        // skip macro function name
        while (p<Len) and (s[p]<>'(') do inc(p);
        if (p<Len) then begin
          Result:=true;
          exit;
        end;
      end else begin
        // $$ is not a macro
        inc(p);
      end;
    end else
      inc(p);
  end;
end;

function TTransferMacroList.FindByName(const MacroName: string): TTransferMacro;
var
  l: Integer;
  r: Integer;
  m: Integer;
  cmp: Integer;
begin
  l:=0;
  r:=fItems.Count-1;
  m:=0;
  while l<=r do begin
    m:=(l+r) shr 1;
    Result:=Items[m];
    cmp:=AnsiCompareText(MacroName,Result.Name);
    if cmp<0 then
      r:=m-1
    else if cmp>0 then
      l:=m+1
    else begin
      exit;
    end;
  end;
  Result:=nil;
end;

function TTransferMacroList.MF_Ext(const Filename:string;
  const Data: PtrInt; var Abort: boolean):string;
begin
  Result:=ExtractFileExt(Filename);
end;

function TTransferMacroList.MF_Path(const Filename:string; 
  const Data: PtrInt; var Abort: boolean):string;
begin
  Result:=TrimFilename(ExtractFilePath(Filename));
  //debugln(['TTransferMacroList.MF_Path ',Filename,' Result=',Result]);
end;

function TTransferMacroList.MF_Name(const Filename:string; 
  const Data: PtrInt; var Abort: boolean):string;
begin
  Result:=ExtractFilename(Filename);
end;

function TTransferMacroList.MF_NameOnly(const Filename:string;
  const Data: PtrInt; var Abort: boolean):string;
begin
  Result:=ChangeFileExt(ExtractFileName(Filename),'');
end;

function TTransferMacroList.MF_MakeDir(const Filename: string;
  const Data: PtrInt; var Abort: boolean): string;
begin
  Result:=Filename;
  if (Result<>'') and (Result[length(Result)]<>PathDelim) then
    Result:=Result+PathDelim;
  Result:=TrimFilename(Result);
end;

function TTransferMacroList.MF_MakeFile(const Filename: string;
  const Data: PtrInt; var Abort: boolean): string;
var
  ChompLen: integer;
begin
  Result:=Filename;
  ChompLen:=0;
  while (length(Filename)>ChompLen)
  and (Filename[length(Filename)-ChompLen]=PathDelim) do
    inc(ChompLen);
  if ChompLen>0 then
    Result:=LeftStr(Result,length(Filename)-ChompLen);
  Result:=TrimFilename(Result);
end;

function TTransferMacroList.MF_EncloseBracket(const Text: string; const Data: PtrInt;
  var Abort: boolean): string;
begin
  Result := Text;
  if Result <> '' then
    Result := '(' + Result + ')';
end;

function TTransferMacroList.MF_Trim(const Filename: string; const Data: PtrInt;
  var Abort: boolean): string;
begin
  Result:=TrimFilename(Filename);
end;

procedure TTransferMacroList.DoSubstitution(TheMacro: TTransferMacro;
  const MacroName: string; var s: string; const Data: PtrInt; var Handled,
  Abort: boolean; Depth: integer);
begin
  if Assigned(OnSubstitution) then
    OnSubstitution(TheMacro,MacroName,s,Data,Handled,Abort,Depth);
end;

{ TLazIDEMacros }

destructor TLazIDEMacros.Destroy;
begin
  FreeAndNil(FLazbuildMacros);
  inherited Destroy;
end;

function TLazIDEMacros.StrHasMacros(const s: string): boolean;
begin
  Result:=GlobalMacroList.StrHasMacros(s);
end;

function TLazIDEMacros.SubstituteMacros(var s: string): boolean;
begin
  Result:=GlobalMacroList.SubstituteStr(s);
end;

function TLazIDEMacros.IsMacro(const Name: string): boolean;
begin
  Result:=GlobalMacroList.FindByName(Name)<>nil;
end;

procedure TLazIDEMacros.Add(NewMacro: TTransferMacro);
Begin
  GlobalMacroList.Add(NewMacro);
end;

procedure TLazIDEMacros.LoadLazbuildMacros;
var
  aFilename, s, aMacroName, Value: String;
  Macros: TTransferMacroList;
  Cfg: TConfigStorage;
  i: Integer;
  p: SizeInt;
  EnvVars: TStringListUTF8Fast;
  aMacro: TTransferMacro;
begin
  aFilename:=AppendPathDelim(GetPrimaryConfigPath)+LazbuildMacrosFileName;
  if not FileExistsCached(aFilename) then exit;

  Macros:=GlobalMacroList;
  FLazbuildMacros:=TStringListUTF8Fast.Create;
  EnvVars:=TStringListUTF8Fast.Create;
  Cfg:=GetIDEConfigStorage(aFilename,true);
  try
    Cfg.GetValue('Macros',FLazbuildMacros);

    for i:=0 to FLazbuildMacros.Count-1 do
    begin
      s:=FLazbuildMacros[i];
      p:=Pos('=',s);
      if (p<2) then continue;
      aMacroName:=LeftStr(s,p-1);
      Value:=copy(s,p+1,length(s));
      aMacro:=Macros.FindByName(aMacroName);
      if aMacro<>nil then
        continue; // macro exists
      Macros.Add(TTransferMacro.Create(aMacroName,Value,'From IDE lazbuild macro list',nil,[]));
    end;
  finally
    EnvVars.Free;
    Cfg.Free;
  end;
end;

procedure TLazIDEMacros.SaveLazbuildMacros;
var
  aFilename, Value, s, aMacroName: String;
  i: Integer;
  aMacro: TTransferMacro;
  NeedSave: Boolean;
  Cfg: TConfigStorage;
  Macros: TTransferMacroList;
  p: SizeInt;
begin
  aFilename:=AppendPathDelim(GetPrimaryConfigPath)+LazbuildMacrosFileName;

  Macros:=GlobalMacroList;

  NeedSave:=false;

  // load old config
  if FLazbuildMacros=nil then
  begin
    FLazbuildMacros:=TStringListUTF8Fast.Create;
    Cfg:=GetIDEConfigStorage(aFilename,true);
    try
      Cfg.GetValue('Macros',FLazbuildMacros);
    finally
      Cfg.Free;
    end;
    FLazbuildMacroFileAge:=FileAgeUTF8(aFilename);
  end;

  // clean up old macros
  for i:=FLazbuildMacros.Count-1 downto 0 do begin
    s:=FLazbuildMacros[i];
    p:=Pos('=',s);
    if (p>1) then
    begin
      aMacroName:=LeftStr(s,p-1);
      aMacro:=Macros.FindByName(aMacroName);
      if (aMacro<>nil) and (tmfLazbuild in aMacro.Flags) then
        continue;
    end;
    FLazbuildMacros.Delete(i);
    NeedSave:=true;
  end;

  // check new values
  for i:=0 to Macros.Count-1 do
  begin
    aMacro:=Macros[i];
    if not (tmfLazbuild in aMacro.Flags) then continue;
    if aMacro.LazbuildValue<>'' then
      Value:=aMacro.LazbuildValue
    else
      Value:=aMacro.Value;
    if Value='' then
    begin
      // currently the macro is not set -> keep the old value
      continue;
    end;
    if FLazbuildMacros.Values[aMacro.Name]<>Value then
    begin
      FLazbuildMacros.Values[aMacro.Name]:=Value;
      NeedSave:=true;
    end;
  end;

  if FLazbuildMacros.Count=0 then
  begin
    // no lazbuild macros -> delete config
    if FileExistsCached(aFilename) then
      DeleteFile(aFilename);
    exit;
  end;

  if (not NeedSave) then
  begin
    if (not FileExistsCached(aFilename))
        or ((FLazbuildMacroFileAge<>0) and (FileAgeCached(aFilename)<>FLazbuildMacroFileAge)) then
      NeedSave:=true;
  end;

  if not NeedSave then exit;

  Cfg:=GetIDEConfigStorage(aFilename,false);
  try
    FLazbuildMacros.Clear;
    for i:=0 to Macros.Count-1 do
    begin
      aMacro:=Macros[i];
      if not (tmfLazbuild in aMacro.Flags) then continue;
      if aMacro.LazbuildValue<>'' then
        Value:=aMacro.LazbuildValue
      else
        Value:=aMacro.Value;
      FLazbuildMacros.Add(aMacro.Name+'='+Value);
    end;
    Cfg.SetValue('Macros',FLazbuildMacros);
  finally
    Cfg.Free;
  end;
  FLazbuildMacroFileAge:=FileAgeUTF8(aFilename);
end;


procedure InternalInit;
var
  c: char;
begin
  for c:=Low(char) to High(char) do begin
    IsIdentChar[c]:=c in ['a'..'z','A'..'Z','0'..'9','_'];
  end;
end;

initialization
  InternalInit;

end.
