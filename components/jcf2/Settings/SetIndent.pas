{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SetIndent.pas, released April 2000.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2008 Anthony Steele.
All Rights Reserved. 
Contributor(s): Anthony Steele. 

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

unit SetIndent;

{$mode delphi}

interface

uses JcfSetBase, SettingsStream, SettingsTypes;

type

  TSetIndent = class(TSetBase)
  private
    fiIndentSpaces: integer;
    fiFirstLevelIndent: integer;
    fbHasFirstLevelIndent: boolean;

    fbIndentBeginEnd: boolean;
    fiIndentBeginEndSpaces: integer;

    fbIndentLibraryProcs: boolean;
    fbIndentProcedureBody: boolean;

    fbKeepCommentsWithCodeInProcs: boolean;
    fbKeepCommentsWithCodeInGlobals: boolean;
    fbKeepCommentsWithCodeInClassDef: boolean;
    fbKeepCommentsWithCodeElsewhere: boolean;
    fbIndentElse: Boolean;
    fbIndentCaseLabels: Boolean;
    fbIndentCaseElse: Boolean;
    fbIndentNestedTypes: Boolean;
    fbIndentVarAndConstInClass: Boolean;
    fbIndentInterfaceGuid: boolean;
    fbIndentLabels:TIndentLabels;
    fbIndentExtraTryBlockKeyWords:boolean;
    fiIndentExtraTryBlockKeyWordsSpaces:integer;
    fbIndentEndTryBlockAsCode:boolean;
    fbIndentExtraOrphanTryBlocks:boolean;
  protected
  public
    constructor Create;

    procedure WriteToStream(const pcOut: TSettingsOutput); override;
    procedure ReadFromStream(const pcStream: TSettingsInput); override;

    function SpacesForIndentLevel(const piLevel: integer): integer;

    property IndentSpaces: integer Read fiIndentSpaces Write fiIndentSpaces;
    { first level can be indented differently }
    property FirstLevelIndent: integer Read fiFirstLevelIndent Write fiFirstLevelIndent;
    property HasFirstLevelIndent: boolean Read fbHasFirstLevelIndent
      Write fbHasFirstLevelIndent;

    property IndentBeginEnd: boolean Read fbIndentBeginEnd Write fbIndentBeginEnd;
    property IndentBeginEndSpaces: integer Read fiIndentBeginEndSpaces Write fiIndentBeginEndSpaces;

    property IndentLibraryProcs: boolean Read fbIndentLibraryProcs Write fbIndentLibraryProcs;
    property IndentProcedureBody: boolean Read fbIndentProcedureBody Write fbIndentProcedureBody;

    property KeepCommentsWithCodeInProcs: boolean
      Read fbKeepCommentsWithCodeInProcs Write fbKeepCommentsWithCodeInProcs;
    property KeepCommentsWithCodeInGlobals: boolean
      Read fbKeepCommentsWithCodeInGlobals Write fbKeepCommentsWithCodeInGlobals;
    property KeepCommentsWithCodeInClassDef: boolean
      Read fbKeepCommentsWithCodeInClassDef Write fbKeepCommentsWithCodeInClassDef;
    property KeepCommentsWithCodeElsewhere: boolean
      Read fbKeepCommentsWithCodeElsewhere Write fbKeepCommentsWithCodeElsewhere;

    property IndentElse: boolean read fbIndentElse write fbIndentElse;
    property IndentCaseLabels: boolean read fbIndentCaseLabels write fbIndentCaseLabels;
    property IndentCaseElse: boolean read fbIndentCaseElse write fbIndentCaseElse;
    property IndentInterfaceGuid: boolean read fbIndentInterfaceGuid write fbIndentInterfaceGuid;

    property IndentNestedTypes: Boolean read fbIndentNestedTypes write fbIndentNestedTypes;
    property IndentVarAndConstInClass: Boolean read fbIndentVarAndConstInClass write fbIndentVarAndConstInClass;
    property IndentLabels:TIndentLabels read fbIndentLabels write fbIndentLabels;
    property IndentExtraTryBlockKeyWords:boolean read fbIndentExtraTryBlockKeyWords write fbIndentExtraTryBlockKeyWords;
    property IndentExtraTryBlockKeyWordsSpaces:integer read fiIndentExtraTryBlockKeyWordsSpaces write fiIndentExtraTryBlockKeyWordsSpaces;
    property IndentEndTryBlockAsCode:boolean read fbIndentEndTryBlockAsCode write fbIndentEndTryBlockAsCode;
    property IndentExtraOrphanTryBlocks:boolean read fbIndentExtraOrphanTryBlocks write fbIndentExtraOrphanTryBlocks;
  end;

implementation

const
  REG_INDENTATION_SPACES = 'IndentationSpaces';

  REG_FIRST_LEVEL_INDENT     = 'FirstLevelIndent';
  REG_HAS_FIRST_LEVEL_INDENT = 'HasFirstLevelIndent';

  REG_INDENT_BEGIN_END = 'IndentBeginEnd';
  REG_INDENT_BEGIN_END_SPACES = 'IndentbeginEndSpaces';

  REG_INDENT_LIBRARY_PROCS = 'IndentLibraryProcs';
  REG_INDENT_PROCEDURE_BODY = 'IndentProcedureBody';

  REG_KEEP_COMMENTS_WITH_CODE_CLASS_DEF  = 'KeepCommentsWithCodeInClassDef';
  REG_KEEP_COMMENTS_WITH_CODE_IN_PROCS   = 'KeepCommentsWithCodeInProcs';
  REG_KEEP_COMMENTS_WITH_CODE_IN_GLOBALS = 'KeepCommentsWithCodeInGlobals';
  REG_KEEP_COMMENTS_WITH_CODE_ELSEWHERE = 'KeepCommentsWithCodeElsewhere';

  REG_INDENT_ELSE = 'IndentElse';
  REG_INDENT_CASE_LABELS = 'IndentCaseLabels';
  REG_INDENT_CASE_ELSE = 'IndentCaseElse';
  REG_INDENT_VAR_AND_CONST_IN_CLASS = 'IndentVarAndConstInClass';
  REG_INDENT_NESTED_TYPES = 'IndentNestedTypes';
  REG_INDENT_INTERFACE_GUID = 'IndentInterfaceGuid';
  REG_INDENT_LABELS = 'IndentLabels';
  REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS = 'IndentExtraTryBlockKeyWords';
  REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS_SPACES = 'IndentExtraTryBlockKeyWordsSpaces';
  REG_INDENT_END_TRY_BLOCK_AS_CODE = 'IndentEndTryBlockAsCode';
  REG_INDENT_EXTRA_ORPHAN_TRY_BLOCKS = 'IndentExtraOrphanTryBlocks';

constructor TSetIndent.Create;
begin
  inherited;
  SetSection('Indent');
end;

procedure TSetIndent.ReadFromStream(const pcStream: TSettingsInput);
begin
  Assert(pcStream <> nil);

  fiIndentSpaces := pcStream.Read(REG_INDENTATION_SPACES, 2);

  fiFirstLevelIndent    := pcStream.Read(REG_FIRST_LEVEL_INDENT, 2);
  fbHasFirstLevelIndent := pcStream.Read(REG_HAS_FIRST_LEVEL_INDENT, False);

  fbIndentBeginEnd := pcStream.Read(REG_INDENT_BEGIN_END, False);
  fiIndentBeginEndSpaces := pcStream.Read(REG_INDENT_BEGIN_END_SPACES, 1);

  if pcStream.HasTag(REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS) then
  begin
    fbIndentExtraTryBlockKeyWords := pcStream.Read(REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS, False);
    fiIndentExtraTryBlockKeyWordsSpaces :=pcStream.Read(REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS_SPACES, 1);
  end
  else
  begin
    fbIndentExtraTryBlockKeyWords := pcStream.Read(REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS, fbIndentBeginEnd);
    fiIndentExtraTryBlockKeyWordsSpaces := pcStream.Read(REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS_SPACES, fiIndentBeginEndSpaces);
  end;

  fbIndentLibraryProcs := pcStream.Read(REG_INDENT_LIBRARY_PROCS, True);
  fbIndentProcedureBody := pcStream.Read(REG_INDENT_PROCEDURE_BODY, False);

  fbKeepCommentsWithCodeInGlobals  :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_IN_GLOBALS, True);
  fbKeepCommentsWithCodeInProcs    :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_IN_PROCS, True);
  fbKeepCommentsWithCodeInClassDef :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_CLASS_DEF, True);
  fbKeepCommentsWithCodeElsewhere :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_ELSEWHERE, True);

  fbIndentElse := pcStream.Read(REG_INDENT_ELSE, False);
  fbIndentCaseLabels := pcStream.Read(REG_INDENT_CASE_LABELS, True);
  fbIndentCaseElse := pcStream.Read(REG_INDENT_CASE_ELSE, True);

  fbIndentNestedTypes := pcStream.Read(REG_INDENT_NESTED_TYPES, False);
  fbIndentVarAndConstInClass := pcStream.Read(REG_INDENT_VAR_AND_CONST_IN_CLASS, False);
  fbIndentInterfaceGuid := pcStream.Read(REG_INDENT_INTERFACE_GUID, True);
  fbIndentLabels := TIndentLabels(pcStream.Read(REG_INDENT_LABELS,Ord(eLabelIndentStatement)));
  fbIndentEndTryBlockAsCode := pcStream.Read(REG_INDENT_END_TRY_BLOCK_AS_CODE, False);
  fbIndentExtraOrphanTryBlocks := pcStream.Read(REG_INDENT_EXTRA_ORPHAN_TRY_BLOCKS, False);
end;

procedure TSetIndent.WriteToStream(const pcOut: TSettingsOutput);
begin
  Assert(pcOut <> nil);

  pcOut.Write(REG_INDENTATION_SPACES, fiIndentSpaces);

  pcOut.Write(REG_FIRST_LEVEL_INDENT, fiFirstLevelIndent);
  pcOut.Write(REG_HAS_FIRST_LEVEL_INDENT, fbHasFirstLevelIndent);

  pcOut.Write(REG_INDENT_BEGIN_END, fbIndentBeginEnd);
  pcOut.Write(REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS, fbIndentExtraTryBlockKeyWords);
  pcOut.Write(REG_INDENT_BEGIN_END_SPACES, fiIndentBeginEndSpaces);
  pcOut.Write(REG_INDENT_EXTRA_TRY_BLOCK_KEYWORDS_SPACES, fiIndentExtraTryBlockKeyWordsSpaces);

  pcOut.Write(REG_INDENT_LIBRARY_PROCS, fbIndentLibraryProcs);
  pcOut.Write(REG_INDENT_PROCEDURE_BODY, fbIndentProcedureBody);

  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_IN_GLOBALS, fbKeepCommentsWithCodeInGlobals);
  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_IN_PROCS, fbKeepCommentsWithCodeInProcs);
  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_CLASS_DEF, fbKeepCommentsWithCodeInClassDef);
  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_ELSEWHERE, fbKeepCommentsWithCodeElsewhere);

  pcOut.Write(REG_INDENT_ELSE, fbIndentElse);
  pcOut.Write(REG_INDENT_CASE_LABELS, fbIndentCaseLabels);
  pcOut.Write(REG_INDENT_CASE_ELSE, fbIndentCaseElse);

  pcOut.Write(REG_INDENT_NESTED_TYPES, fbIndentNestedTypes);
  pcOut.Write(REG_INDENT_VAR_AND_CONST_IN_CLASS, fbIndentVarAndConstInClass);
  pcOut.Write(REG_INDENT_INTERFACE_GUID, fbIndentInterfaceGuid);
  pcOut.Write(REG_INDENT_LABELS, Ord(fbIndentLabels));
  pcOut.Write(REG_INDENT_END_TRY_BLOCK_AS_CODE, fbIndentEndTryBlockAsCode);
  pcOut.Write(REG_INDENT_EXTRA_ORPHAN_TRY_BLOCKS, fbIndentExtraOrphanTryBlocks);
end;

function TSetIndent.SpacesForIndentLevel(const piLevel: integer): integer;
begin
  if piLevel <= 0 then
    Result := 0
  else if HasFirstLevelIndent then
    Result := FirstLevelIndent + ((piLevel - 1) * IndentSpaces)
  else
    Result := IndentSpaces * piLevel;
end;


end.
