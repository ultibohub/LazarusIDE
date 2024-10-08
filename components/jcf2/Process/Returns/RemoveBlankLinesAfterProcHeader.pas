unit RemoveBlankLinesAfterProcHeader;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is RemoveBlankLinesAfterProcHeader, released May 2003.
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

uses SourceToken, SwitchableVisitor;

type
  TRemoveBlankLinesAfterProcHeader = class(TSwitchableVisitor)
  protected
    function EnabledVisitSourceToken(const pcNode: TObject): Boolean; override;

  public
    constructor Create; override;

    function IsIncludedInSettings: boolean; override;
  end;

implementation

uses
  JcfSettings, FormatFlags, Tokens, TokenUtils,
  ParseTreeNodeType, ParseTreeNode;

function IsPlaceForBlankLineRemoval(const ptToken, ptNextSolidToken:
  TSourceToken): boolean;
begin
  Result := False;

  if (ptToken = nil) or (ptNextSolidToken = nil) then
    exit;

  { assume we're already under a procedure decl as tested below }

  { before the begin }
  if ptToken.HasParentNode([nCompoundStatement] + ProcedureNodes) and
    (ptNextSolidToken.TokenType = ttBegin) then
  begin
    Result := True;
    exit;
  end;

  { before the type, const, label, val }
  if ptToken.HasParentNode(nDeclSection) and
    (ptNextSolidToken.TokenType in [ttType, ttVar, ttConst, ttLabel]) then
  begin
    Result := True;
    exit;
  end;
end;

{ TRemoveBlankLinesAfterProcHeader }

constructor TRemoveBlankLinesAfterProcHeader.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveReturn];
end;

function TRemoveBlankLinesAfterProcHeader.EnabledVisitSourceToken(
  const pcNode: TObject): Boolean;
var
  lcSourceToken:  TSourceToken;
  lcNext, lcTest: TSourceToken;
  liReturnCount:  integer;
  liMaxReturns:   integer;
  lcBlock: TParseTreeNode;
  lcDeclSection: TParseTreeNode;
begin
  Result := False;
  lcSourceToken := TSourceToken(pcNode);

  { must be in procedure declarations or directives}
  if not lcSourceToken.HasParentNode(ProcedureNodes) then
    exit;

  if lcSourceToken.TokenType <> ttReturn then
    exit;

  lcNext := lcSourceToken.NextTokenWithExclusions([ttWhiteSpace, ttReturn]);
  if lcNext=nil then
    exit;

  { it must be a 'var', 'const', 'type' or 'begin'
   in the procedure defs/body section }


  { can be type, var etc. var}
  if not IsPlaceForBlankLineRemoval(lcSourceToken, lcNext) then
    exit;

  liReturnCount := 0;
  liMaxReturns := FormattingSettings.Returns.MaxBlankLinesInSection + 1;
  lcTest := lcSourceToken;

  // function fooo;
  // --> no blank lines beetwen function/procedure declaration and sections.
  // var, const, type, begin.

  // find nBlock, can be grandfader or great-grandfather of node
  lcDeclSection:=nil;
  lcDeclSection:=lcNext.Parent;
  if (lcDeclSection<>nil) and  not (lcDeclSection.NodeType in [nDeclSection,nCompoundStatement]) then
    lcDeclSection:=lcDeclSection.Parent;
  if (lcDeclSection<>nil) and  not (lcDeclSection.NodeType in [nDeclSection,nCompoundStatement]) then
    lcDeclSection:=lcDeclSection.Parent;
  if lcDeclSection<>nil then
  begin
    lcBlock:=lcDeclSection.Parent;
    if (lcBlock<>nil) and (lcBlock.NodeType=nBlock) then
    begin
      //if lcBlock.IndexOfChild(lcDeclSection)=0 then //Only the first section of nBlock
      liMaxREturns:=1;
    end;
  end;

  { remove all returns up to that point (except one) }
  while (lcTest <> lcNext) do
  begin
    if (lcTest.TokenType = ttReturn) then
    begin
      // allow two returns -> 1 blank line
      Inc(liReturnCount);
      if (liReturnCount > liMaxReturns) then
        BlankToken(lcTest);
    end;
    lcTest := lcTest.NextToken;
  end;

end;

function TRemoveBlankLinesAfterProcHeader.IsIncludedInSettings: boolean;
begin
  Result := FormattingSettings.Returns.RemoveProcedureDefReturns;
end;

end.
