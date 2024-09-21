unit BasicStats;

(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is BasicStats, released May 2003.
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

{$mode delphi}

interface

{
  AFS 25 March 03
  Basic stats on the unit
  Proof of concept to do crude code analysis on the unit

  Since it doesn't alter anything and wants to read the entire unit
  it is not a switchable visitor }

{(*}

uses
  SysUtils,
  BaseVisitor;

type
  TBasicStats = class(TBaseTreeNodeVisitor)
  private
    fiTotalTokens, fiTotalChars: integer;

    // tokens can be divided into 3 categories - comments, spaces&rets, code
    fiSpaceTokens, fiCommentTokens, fiSolidTokens: integer;
    fiSpaceChars, fiCommentChars, fiSolidChars: integer;

    fiLines: integer;

    fiConsts, fiTypes, fiClasses, fiInterfaces, fiAllProcs: integer;
    liInterfaceGlobalVars, liGlobalVars: integer;
    fiInterfaceProcs: integer;

  protected
  public
    constructor Create; override;

    procedure PreVisitParseTreeNode(const pcNode: TObject); override;
    function VisitSourceToken(const pcNode: TObject): Boolean; override;
    function FinalSummary(out psMessage: string): boolean; override;

    function IsIncludedInSettings: boolean; override;
  end;

implementation

uses
  { JCF  }
  JcfStringUtils,
  SourceToken, Tokens, ParseTreeNode, ParseTreeNodeType, TokenUtils,
  JcfRegistrySettings, jcfbaseConsts;

function DisplayFloat(const ex: extended): string;
begin
  // use the localised version for display
  Result := FloatToStrF(ex, ffNumber, 9, 2);
end;

function DisplayRatio(const exNum, exDenom: extended): string;
begin
  if exDenom = 0 then
    Result := '-'
  else
    Result := DisplayFloat(exNum / exDenom);
end;

function DisplayPercent(const exNum, exDenom: extended): string;
begin
  if exDenom = 0 then
    Result := '-'
  else
    Result := DisplayFloat(exNum * 100 / exDenom) + '%';
end;



constructor TBasicStats.Create;
begin
  inherited;

  HasPreVisit := True;
  HasPostVisit := False;
  HasSourceTokenVisit := True;
end;

procedure TBasicStats.PreVisitParseTreeNode(const pcNode: TObject);
var
  lcNode: TParseTreeNode;
begin
  lcNode := TParseTreeNode(pcNode);

  case lcNode.NodeType of
    nTypeDecl:
      Inc(fiTypes);
    nConstDecl:
      Inc(fiConsts);
    nClassType:
      Inc(fiClasses);
    nInterfaceType:
      Inc(fiInterfaces);
    else; // no nothing
  end;

  { procedure/fn/constructor/destructor }
  if (lcNode.NodeType in ProcedureNodes) and lcNode.HasChildNode(nBlock) then
    { if it has a block of code under it, it counts as a proc }
    Inc(fiAllProcs);

  { can only export a global procedure or function - not a constructor or destructor
    don't count procs in a class or itnerface def }
  if (lcNode.NodeType in [nFunctionHeading, nProcedureHeading]) and
    lcNode.HasParentNode(nInterfaceSection) and
    ( not lcNode.HasParentNode([nClassType, nInterfaceType, nProcedureType])) then
    Inc(fiInterfaceProcs);

  // find global vars
  if (lcNode.NodeType = nVarDecl) and ( not lcNode.HasParentNode(nClassType)) and
    ( not lcNode.HasParentNode(nblock)) then
  begin

    if lcNode.HasParentNode(nInterfaceSection) then
      liInterfaceGlobalVars := liInterfaceGlobalVars + VarIdentCount(lcNode)
    else
      liGlobalVars := liGlobalVars + VarIdentCount(lcNode);
  end;

end;

function TBasicStats.VisitSourceToken(const pcNode: TObject): Boolean;
var
  lcSourceToken: TSourceToken;
  liLen: integer;
begin
  Result := False;
  lcSourceToken := TSourceToken(pcNode);

  // a file with no returns has one line
  if (fiLines = 0) then
    fiLines := 1;

  Inc(fiTotalTokens);
  liLen := Length(lcSourceToken.SourceCode);
  fiTotalChars := fiTotalChars + liLen;

  case lcSourceToken.TokenType of
    ttComment:
    begin
      Inc(fiCommentTokens);
      fiCommentChars := fiCommentChars + liLen;

      fiLines := fiLines + StrStrCount(lcSourceToken.SourceCode, NativeLineBreak);
    end;
    ttReturn:
    begin
      Inc(fiLines);
      Inc(fiSpaceTokens);
      fiSpaceChars := fiSpaceChars + liLen;
    end;
    ttWhiteSpace:
    begin
      Inc(fiSpaceTokens);
      fiSpaceChars := fiSpaceChars + liLen;
    end;
    else
    begin
      Inc(fiSolidTokens);
      fiSolidChars := fiSolidChars + liLen;
    end;
  end;
end;

function TBasicStats.FinalSummary(out psMessage: string): boolean;
begin
  Result := True;

  psMessage := NativeLineBreak + lisMsgStatsBasicNumbers + NativeLineBreak +
    Format(lisMsgStatsLinesLong, [fiLines]) + NativeLineBreak +
    Format(lisMsgStatsUnitHasTokens, [fiTotalTokens, fiTotalChars]) + NativeLineBreak +
    Format(lisMsgStatsCharsPerToken, [DisplayRatio(fiTotalChars, fiTotalTokens)]) + NativeLineBreak +
    Format(lisMsgStatsCharsPerLine, [DisplayRatio(fiTotalChars, fiLines)]) + NativeLineBreak +
    Format(lisMsgStatsTokensPerLine, [DisplayRatio(fiTotalTokens, fiLines)]) + NativeLineBreak + NativeLineBreak;

  psMessage := psMessage +
    Format(lisMsgStatsCommentsIn,[fiCommentTokens, fiCommentChars]) + NativeLineBreak +
    Format(lisMsgStatsCharsPerComment, [DisplayRatio(fiCommentChars, fiCommentTokens)]) + NativeLineBreak +
    Format(lisMsgStatsCharsAreComments, [DisplayPercent(fiCommentChars, fiTotalChars)]) +
    NativeLineBreak + NativeLineBreak;

  psMessage := psMessage +
    Format(lisMsgStatsSpacingAndReturnTokens, [fiSpaceTokens, fiSpaceChars]) + NativeLineBreak +
    Format(lisMsgStatsCharsPerToken, [DisplayRatio(fiSpaceChars, fiSpaceTokens)]) + NativeLineBreak +
    Format(lisMsgStatsCharsAreSpacing, [DisplayPercent(fiSpaceChars, fiTotalChars)]) +
    NativeLineBreak + NativeLineBreak;

  psMessage := psMessage +
    Format(lisMsgStatsSolidTokens, [fiSolidTokens, fiSolidChars]) + NativeLineBreak +
    Format(lisMsgStatsCharsPerToken, [DisplayRatio(fiSolidChars, fiSolidTokens)]) + NativeLineBreak +
    Format(lisMsgStatsCharsAreSolid, [DisplayPercent(fiSolidChars, fiTotalChars)]) + NativeLineBreak +
    Format(lisMsgStatsTokensAreSolid, [DisplayPercent(fiSolidTokens, fiTotalTokens)]) +
    NativeLineBreak + NativeLineBreak;

  psMessage := psMessage +
    Format(lisMsgStatsConstants, [fiConsts]) + NativeLineBreak +
    Format(lisMsgStatsTypes, [fiTypes]) + NativeLineBreak +
    Format(lisMstStatsClasses, [fiClasses]) + NativeLineBreak +
    Format(lisMsgStatsInterfaces, [fiInterfaces])+ NativeLineBreak +
    Format(lisMsgStatsProcedures, [fiAllProcs]) + NativeLineBreak + NativeLineBreak;

  psMessage := psMessage +
    Format(lisMsgStatsGlobalVarsInInterface, [liInterfaceGlobalVars]) + NativeLineBreak +
    Format(lisMsgStatsGlobalVarsInRestOfUnit, [liGlobalVars]) + NativeLineBreak +
    Format(lisMsgStatsProceduresInInterface, [fiInterfaceProcs]) +
    NativeLineBreak + NativeLineBreak;

end;


function TBasicStats.IsIncludedInSettings: boolean;
begin
  Result := GetRegSettings.LogStats;
end;

end.
