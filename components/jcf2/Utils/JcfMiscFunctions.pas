unit JcfMiscFunctions;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is JcfMiscFunctions, released May 2003.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 1999-2008 Anthony Steele.
All Rights Reserved.
Contributor(s):
Anthony Steele.
functions Str2Float and Float2Str from Ralf Steinhaeusser
procedures AdvanceTextPos and LastLineLength rewritten for speed by Adem Baba
SetObjectFontToSystemFont by Jean-Fabien Connault

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations
under the License.

Alternatively, the contents of this file may be used under the terms of
the GNU General Public License Version 2 or later (the "GPL") 
See http://www.gnu.org/licenses/gpl.html
------------------------------------------------------------------------------*)
{*)}


{ AFS 15 Jan 2k

  This project uses very little in the way of internal function libs
  as most is covered by JCL
  I was using ComponentFunctions from my JEDI VCL kit
  however that is causing linkage problems with the IDE plugin - it is a package
  and 2 packages can't package the same stuff,
  also it creates version dependencies - it bombed with the different version
  of ComponentFunctions that I have at work

  So I am importing just what I need from ComponentFunctions here
}

{$mode delphi}

interface

uses
  Classes, SysUtils, JcfStringUtils, lconvencoding;

type
  GetConfigFileNameFunction=function:string;

function GetApplicationFolder: string;

function GetLastDir(psPath: string): string;

function Str2Float(s: string): double;
function Float2Str(const d: double): string;


{not really a file fn - string file name manipulation}
function SetFileNameExtension(const psFileName, psExt: string): string;

procedure AdvanceTextPos(const AText: String; var ARow, ACol: integer);
function LastLineLength(const AString: string): integer;
function ReadFileToUTF8String(AFilename: string): string;
function GetConfigFileNameJcf:string;
function CheckIfFileExistsWithStdIncludeExtensions(var AIncludeFile:string):boolean;

var
  GetConfigFileNameJcfFunction:GetConfigFileNameFunction = nil;

implementation

uses
  jcfbaseConsts;

function GetApplicationFolder: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

{ these come from Ralf Steinhaeusser
  you see, in Germany, the default decimal sep char is a ',' not a '.'
  values with a '.' will not be read correctly  by StrToFloat
  and values written will contain a ','

  We want the config files to be portable so
  *always* use the '.' character when reading or writing
  This is not for localised display, but for consistent storage
}
//  like StrToFloat but expects a "." instead of the decimal-seperator-character
function Str2Float(s: string): double;
var
  code: integer;
begin
  // de-localise the string if need be
  if (DefaultFormatSettings.DecimalSeparator <> '.')
  and (Pos(DefaultFormatSettings.DecimalSeparator, s) > 0) then
  begin
    StrReplace(s, DefaultFormatSettings.DecimalSeparator, '.');
  end;

  Val(s, Result, Code);
  if code <> 0 then
    raise EConvertError.Create(Format(lisMsgNotValidFloatingPointString, [s]));
end;

// Like FloatToStr, but gives back a dot (.) as decimalseparator
function Float2Str(const d: double): string;
var
  OrgSep: char;
begin
  OrgSep := DefaultFormatSettings.DecimalSeparator;
  DefaultFormatSettings.DecimalSeparator := '.';
  Result := FloatToStr(d);
  DefaultFormatSettings.DecimalSeparator := OrgSep;
end;


function GetLastDir(psPath: string): string;
var
  liPos: integer;
begin
  Result := '';
  if psPath = '' then
    exit;

  { is this a path ? }
  if not (DirectoryExists(psPath)) and FileExists(psPath) then
  begin
    // must be a file - remove the last bit
    liPos := StrLastPos(DirDelimiter, psPath);
    if liPos > 0 then
      psPath := StrLeft(psPath, liPos - 1);
  end;

  liPos := StrLastPos(DirDelimiter, psPath);
  if liPos > 0 then
    Result := StrRestOf(psPath, liPos + 1);
end;

function SetFileNameExtension(const psFileName, psExt: string): string;
var
  liMainFileNameLength: integer;
  lsOldExt: string;
begin
  if PathExtractFileNameNoExt(psFileName) = '' then
  begin
    Result := '';
    exit;
  end;

  lsOldExt := ExtractFileExt(psFileName);
  liMainFileNameLength := Length(psFileName) - Length(lsOldExt);
  Result   := StrLeft(psFileName, liMainFileNameLength);

  Result := Result + '.' + psExt;
end;

function PosLast(const ASubString, AString: string;
  const ALastPos: integer = 0): integer; {AdemBaba}
var
  {This is at least two or three times faster than Jedi's StrLastPos. I tested it}
  LastChar1: Char;
  Index1:    integer;
  Index2:    integer;
  Index3:    integer;
  Length1:   integer;
  Length2:   integer;
  Found1:    boolean;
begin
  Result  := 0;
  Length1 := Length(AString);
  Length2 := Length(ASubString);
  if ALastPos <> 0 then
    Length1 := ALastPos;
  if Length2 > Length1 then
    Exit
  else
  begin
    LastChar1 := ASubString[Length2];
    Index1    := Length1;
    while Index1 > 0 do
    begin
      if (AString[Index1] = LastChar1) then
      begin
        Index2 := Index1;
        Index3 := Length2;
        Found1 := Index2 >= Length2;
        while Found1 and (Index2 > 0) and (Index3 > 0) do
        begin
          Found1 := (AString[Index2] = ASubString[Index3]);
          Dec(Index2);
          Dec(Index3);
        end;
        if Found1 then
        begin
          Result := Index2 + 1;
          Exit;
        end;
      end;
      Dec(Index1);
    end;
  end;
end;

procedure PosLastAndCount(const ASubString, AString: String;
  out ALastPos: integer; out ACount: integer);
var
  {This gets the last occurrence and count in one go. It saves time}
  LastChar1: Char;
  Index1:    integer;
  Index2:    integer;
  Index3:    integer;
  Length1:   integer;
  Length2:   integer;
  Found1:    boolean;
begin
  ACount   := 0;
  ALastPos := 0;
  Length1  := Length(AString);
  Length2  := Length(ASubString);
  if Length2 > Length1 then
    Exit
  else
  begin
    LastChar1 := ASubString[Length2];
    Index1    := Length1;
    while Index1 > 0 do
    begin
      if (AString[Index1] = LastChar1) then
      begin
        Index2 := Index1;
        Index3 := Length2;
        Found1 := Index2 >= Length2;
        while Found1 and (Index2 > 0) and (Index3 > 0) do
        begin
          Found1 := (AString[Index2] = ASubString[Index3]);
          Dec(Index2);
          Dec(Index3);
        end;
        if Found1 then
        begin
          if ALastPos = 0 then
            ALastPos := Index2 + 1;
          Inc(ACount);
          Index1 := Index2;
          Continue;
        end;
      end;
      Dec(Index1);
    end;
  end;
end;

{ given an existing source pos, and a text string that adds at that pos,
  calculate the new text pos
  - if the text does not contain a newline, add its length onto the Xpos
  - if the text contains newlines, then add on to the Y pos, and
    set the X pos to the text length after the last newline }
{AdemBaba}
procedure AdvanceTextPos(const AText: String; var ARow, ACol: integer);
var
  Length1: integer;
  Count1:  integer;
  Pos1:    integer;
begin
  {This is more than 3 times faster than the original.
  I have meticilously checked that it conforms with the original}
  Length1 := Length(AText);
  case Length1 of
    0: ; {Trivial case}
    1:
    begin
      case ord(AText[1]) of
        ord(NativeCarriageReturn), ord(NativeLineFeed):
        begin {#13 or #10}
          Inc(ACol);
          ARow := 1; // XPos is indexed from 1
        end;
        else
          Inc(ARow, Length1)
      end;
    end;
    2:
    begin
      if (ord(AText[1]) = ord(NativeCarriageReturn)) and (ord(AText[2]) = ord(NativeLineFeed)) then
      begin
        Inc(ACol);
        ARow := 1; // XPos is indexed from 1
      end
      else
        Inc(ARow, Length1);
    end;
    else
      PosLastAndCount(NativeLineBreak, AText, Pos1, Count1);
      if Pos1 <= 0 then
        Inc(ARow, Length1)
      else
      begin // multiline
        Inc(ACol, Count1);
        ARow := Length1 - (Pos1 + 1); {2 = Length(AnsiLineBreak)}

        if ARow < 1 then
          ARow := 1;
      end;
  end;
end;

function LastLineLength(const AString: string): integer;
var { in a multiline sting, how many chars on last line (after last return) }
  Pos1: integer;
begin
  Pos1 := PosLast(NativeLineBreak, AString); {AdemBaba}
  if Pos1 <= 0 then
    Result := Length(AString)
  else
    Result := Length(AString) - (Pos1 + Length(NativeLineBreak));
end;

{$push}{$warn 5091 off}
function ReadFileToUTF8String(AFilename: string): string;
var
  lMs: TMemorystream;
  lS: string;
begin
  lMs := TMemoryStream.Create;
  Result := '';
  try
    lMs.LoadFromFile(AFileName);
    SetLength(lS, lMs.Size);
    lMs.ReadBuffer(lS[1], lMs.Size);
    Result := ConvertEncoding(lS, GuessEncoding(lS), EncodingUTF8);
  finally
    lMs.Free;
  end;
end;
{$pop}

function JcfApplicationName: string;
begin
  Result := 'JediCodeFormat';
end;

function GetConfigFileNameJcf: string;
var
  lOld: TGetAppNameEvent;
begin
  if Assigned(GetConfigFileNameJcfFunction) then
    Exit(GetConfigFileNameJcfFunction());

  lOld := OnGetApplicationName;
  OnGetApplicationName := @JcfApplicationName;
  try
    Result := GetAppConfigDir(True) + 'JediCodeFormat.ini';
  finally
    OnGetApplicationName := lOld;
  end;
end;

function CheckIfFileExistsWithStdIncludeExtensions(var AIncludeFile: string): boolean;
var
  fileext: string;
  found: boolean;
  filename: string;
begin
  if FileExists(AIncludeFile) then
    exit(True);
  found := False;
  filename := AIncludeFile;
  fileext := LowerCase(ExtractFileExt(AIncludeFile));
  if (not found) and ((fileext <> '.inc') and (fileext <> '.pp') and (fileext <> '.pas')) then
  begin
    { try default extensions .inc , .pp and .pas }
    filename := AIncludeFile + '.inc';
    found := FileExists(filename);
    if not found then
    begin
      filename := AIncludeFile + '.pp';
      found := FileExists(filename);
    end;
    if not found then
    begin
      filename := AIncludeFile + '.pas';
      found := FileExists(filename);
    end;
  end;
  if (not found) and (fileext = ExtensionSeparator) and (Length(AIncludeFile) >= 2) then
  begin
    filename := Copy(AIncludeFile, 1, Length(AIncludeFile) - 1);
    found := FileExists(filename);
  end;
  if found then
    AIncludeFile := filename;
  Result := found;
end;

end.
