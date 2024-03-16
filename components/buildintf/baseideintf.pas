{ Copyright (C) 2004

 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract: Base classes of the IDEIntf.
}
unit BaseIDEIntf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LazUtils
  LazUTF8, LazConfigStorage, AvgLvlTree,
  // BuildIntf
  MacroIntf;
  
type
  TScanModeFPCSources = (
    smsfsSkip,
    smsfsWaitTillDone, // scan now and wait till finished
    smsfsBackground    // start in background
    );

  // new filename flags
  // Normally you don't need to pass any flags.
  TSearchIDEFileFlag = (
    siffDoNotCheckAllPackages, // do not search filename in unrelated packages (e.g. installed but not used by project)
    siffCheckAllProjects, // search filename in all loaded projects
    siffCaseSensitive,  // check case sensitive, otherwise use Pascal case insensitivity (CompareText)
    siffDoNotCheckOpenFiles,  // do not search in files opened in source editor
    siffIgnoreExtension  // compare only filename, ignore file extension
    );
  TSearchIDEFileFlags = set of TSearchIDEFileFlag;

  TLazBuildingFinishedEvent = procedure(Sender: TObject; BuildSuccessful: Boolean) of object;
  TLazLoadSaveCustomDataEvent = procedure(Sender: TObject; Load: boolean;
    CustomData: TStringToStringTree; // on save this is a temporary clone free for altering
    PathDelimChanged: boolean
    ) of object;

  TGetIDEConfigStorage = function(const Filename: string; LoadFromDisk: Boolean
                                  ): TConfigStorage;

var
  // will be set by the IDE
  DefaultConfigClass: TConfigStorageClass = nil;
  GetIDEConfigStorage: TGetIDEConfigStorage = nil; // load errors: raises exceptions

function EnvironmentAsStringList: TStringList;
procedure AssignEnvironmentTo(DestStrings, Overrides: TStrings);

implementation

function EnvironmentAsStringList: TStringList;
var
  i, SysVarCount, e: integer;
  Variable, Value: string;
Begin
  Result:=TStringList.Create;
  SysVarCount:=GetEnvironmentVariableCount;
  for i:=0 to SysVarCount-1 do begin
    Variable:=GetEnvironmentStringUTF8(i+1);
    // On windows some (hidden) environment variables can be returned by
    // GetEnvironmentStringUTF8. These kind of variables start with a =
    if (length(Variable)>0) and (Variable[1]<>'=') then begin
      e:=1;
      while (e<=length(Variable)) and (Variable[e]<>'=') do inc(e);
      Value:=copy(Variable,e+1,length(Variable)-e);
      Variable:=LeftStr(Variable,e-1);
      Result.Values[Variable]:=Value;
    end;
  end;
end;

procedure AssignEnvironmentTo(DestStrings, Overrides: TStrings);
var
  EnvList: TStringList;
  i: integer;
  Variable, Value: string;
begin
  // get system environment
  EnvList:=EnvironmentAsStringList;
  try
    if Overrides<>nil then begin
      // merge overrides
      for i:=0 to Overrides.Count-1 do begin
        Variable:=Overrides.Names[i];
        Value:=Overrides.Values[Variable];
        if Assigned(IDEMacros) then
          IDEMacros.SubstituteMacros(Value);
        EnvList.Values[Variable]:=Value;
      end;
    end;
    DestStrings.Assign(EnvList);
  finally
    EnvList.Free;
  end;
end;

end.

