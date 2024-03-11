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

  Author: Sérgio Marcelo S. Gomes <smace at smace.com.br>
  Modified by Andrew Haines and Juha Manninen

  Abstract: Invert Assignment Code.

  Example: AValue := BValue  ->  BValue := AValue;
           AValue := True    ->  AValue := False;

}
unit InvertAssignTool;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  LazStringUtils;

function InvertAssignment(InText: string): string;

implementation


function GetIndent(ALine: String):Integer;
begin
  Result := Length(Aline) - Length(TrimLeft(ALine));
end;

procedure DivideLines(Lines: TStrings; var PreList, AList, BList, PostList: TStrings);
var
  ALine, TrueFalse: String;
  t, f: Boolean;
  X, I, EqPos, SemiPos, WordEndPos, BracketCount: Integer;
begin
  for X := 0 to Lines.Count-1 do begin
    ALine := Trim(Lines[X]);
    EqPos := Pos(':=', ALine);
    if EqPos > 0 then begin
      SemiPos := Pos(';', ALine);
      if SemiPos = 0 then
        SemiPos:=Length(ALine)+1;
      I := EqPos-1;
      while (I > 0) and (ALine[I] = ' ') do      // Skip initial spaces
        Dec(I);
      WordEndPos := I+1;
      BracketCount := 0;
      // Get the word before :=
      while I > 0 do begin
        if ALine[I] = ']' then
          Inc(BracketCount)
        else if ALine[I] = '[' then
          Dec(BracketCount);
        if (BracketCount = 0) and (ALine[I] = ' ') then
          Break;
        Dec(I);
      end;
      // I points now at beginning of word - 1
      Alist.Add(Copy(ALine, I+1, WordEndPos-(I+1)));
      BList.Add(Trim(Copy(ALine, EqPos+2, SemiPos-EqPos-2)));
      PreList.Add(Trim(Copy(ALine,1, I)));
      PostList.Add(Trim(Copy(ALine, SemiPos, Length(ALine)-(SemiPos-1))));
      if Length(PreList[X]) > 0 then
        PreList[X] := PreList[X] + ' ';
    end
    else begin  // not a valid line
      PreList.Add('');
      AList.Add(ALine);
      Blist.Add('');
      PostList.Add('');
    end;
    // Check if is being assigned true or false
    t := CompareText(BList[X], 'True') = 0;
    f := CompareText(BList[X], 'False') = 0;
    if t or f then begin
      TrueFalse := AList[X];
      AList[X] := BoolToStr(not t, 'True', 'False');
      BList[X] := TrueFalse;
    end;
  end;
end;

function InvertLine(PreVar, VarA, VarB, PostVar: String; LineStart, EqualPosition: Integer): String;
var
  fLength: Integer;
  X: Integer;
begin
  Result := '';
  for X := 1 to LineStart do
    Result := Result + ' ';
  if Length(Trim(VarB)) = 0 then   // is not a line with a ':='
    Result := Result + VarA
  else begin
    Result := Result + PreVar + VarB;
    fLength := Length(Trim(Result));
    if fLength < EqualPosition then
      for X := fLength+1 to EqualPosition do
        Result := Result + ' ';
    Result := Result + ' := ' + VarA + PostVar;
  end;
end;

function IsAWholeLine(const ALine: String): Boolean;
begin
  // This function is useful for when the text is put back
  // in the synedit, things like this don't happen:
  // begin
  //   if CallSomeFunction > 0
  //   then
  //     DoThis
  //   else
  //     Exit;
  // end;
  //
  // Would otherwise become this
  //
  // begin if CallSomeFunction > 0 then DoThis else exit;
  // end;
  Result := False;
  if (Pos(';', ALine) > 0)
  or (PosI('if ', ALine) > 0)
  or (PosI('begin', ALine) > 0)
  or (PosI('end', ALine) > 0)
  or (PosI('then', ALine) > 0)
  or (PosI('else', ALine) > 0)
  or (PosI('and', ALine) > 0)
  or (PosI('or', ALine) > 0)
  or (Pos('//', ALine) > 0)
  then Result := True;
end;


// This function inverts all Assignments operation.
// like valuea := valueb; to valueb := valuea;
// or valuea := False; to valuea := True;
function InvertAssignment(InText: string): string;
var
  InLines, TempLines: TStringList;
  PreList, AList, BList, PostList: TStrings;
  ALine: String;
  Indents: array of integer;
  X, Y, EqPos: Integer;
  HasLinefeed: Boolean;
begin
  if InText = '' then
    Exit('');
  HasLinefeed := InText[Length(InText)] in [#10,#13];
  InLines := TStringList.Create;
  InLines.Text := InText;
  SetLength(Indents{%H-}, InLines.Count);
  TempLines := TStringList.Create;

  // Join many lines to one
  ALine := '';
  for X := 0 to InLines.Count-1 do begin
    ALine := ALine + InLines[X];
    if IsAWholeLine(ALine) then begin
      Indents[TempLines.Add(ALine)] := GetIndent(ALine);
      ALine := '';
    end;
  end;
  if Length(ALine) > 0 then
    Indents[TempLines.Add(ALine)] := GetIndent(ALine);

  InLines.Clear;
  PreList := TStringList.Create;
  AList := TStringList.Create;
  BList := TStringList.Create;
  PostList := TStringList.Create;

  DivideLines(TempLines, PreList, AList, BList, PostList);
  TempLines.Free;

  // Find where the ':=' should be
  EqPos := 0;
  for X := 0 to BList.Count-1 do begin
    Y := Length(BList[X]);
    if Y > EqPos then
      EqPos := Y;
  end;

  for X := 0 to AList.Count-1 do
    InLines.Add(InvertLine(PreList[X],Alist[X],BList[X],PostList[X],Indents[X],EqPos));
  PreList.Free;
  AList.Free;
  BList.Free;
  PostList.Free;
  Result := InLines.Text;
  InLines.Free;
  if not HasLinefeed then begin
    while Result[Length(Result)] in [#10,#13] do
      SetLength(Result, Length(Result)-1);
  end;
end;

end.

