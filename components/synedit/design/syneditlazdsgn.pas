{
 /***************************************************************************
                            syneditlazdsgn.pas
                            ------------------


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
}
unit SynEditLazDsgn;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  SynGutter, SynGutterCodeFolding, SynGutterChanges, SynGutterLineNumber,
  SynGutterMarks, SynGutterBase, SynEditMouseCmds, SynEditTypes,
  {$IFDEF DesignSynGutterLineOverview} SynGutterLineOverview, {$ENDIF}
  SynEditKeyCmds, SynEdit, SynCompletion, SynExportHTML, SynMacroRecorder,
  SynMemo, SynHighlighterPas, SynHighlighterCPP, SynHighlighterJava,
  SynHighlighterPerl, SynHighlighterHTML, SynHighlighterXML,
  SynHighlighterLFM, SynHighlighterMulti, SynHighlighterUNIXShellScript,
  SynHighlighterCss, SynHighlighterPHP, SynHighlighterTeX, SynHighlighterSQL,
  SynHighlighterPython, SynHighlighterVB, SynHighlighterAny, SynHighlighterDiff,
  SynHighlighterBat, SynHighlighterIni, SynHighlighterPo,
  SynPluginSyncroEdit, SynPopupMenu,
  SynPropertyEditObjectList, SynDesignStringConstants, SynHighlighterJScript,
  LazarusPackageIntf, LResources, PropEdits, ComponentEditors;

procedure Register;

implementation

{$R syneditlazdsgn.res}

procedure RegisterSynCompletion;
begin
  RegisterComponents('SynEdit',[TSynCompletion]);
  RegisterComponents('SynEdit',[TSynAutoComplete]);
end;

procedure RegisterSynEdit;
begin
  RegisterComponents('SynEdit',[TSynEdit]);
end;

procedure RegisterSynSyncroEdit;
begin
  RegisterComponents('SynEdit',[TSynPluginSyncroEdit]);
end;

procedure RegisterSynExportHTML;
begin
  RegisterComponents('SynEdit',[TSynExporterHTML]);
end;

procedure RegisterSynMacroRecorder;
begin
  RegisterComponents('SynEdit',[TSynMacroRecorder]);
end;

procedure RegisterSynMemo;
begin
  {$IfDef WithSynMemo}
  RegisterComponents('SynEdit',[TSynMemo]);
  {$Else}
  RegisterNoIcon([TSynMemo]);
  {$EndIF}
end;

procedure RegisterSynPopupMenu;
begin
  RegisterComponents('SynEdit',[TSynPopupMenu]);
end;

procedure RegisterSynHighlighterPas;
begin
  RegisterComponents('SynEdit',[TSynPasSyn, TSynFreePascalSyn]);
end;

procedure RegisterSynHighlighterJava;
begin
  RegisterComponents('SynEdit',[TSynJavaSyn]);
end;

procedure RegisterSynHighlighterJScript;
begin
  RegisterComponents('SynEdit',[TSynJScriptSyn]);
end;

procedure RegisterSynHighlighterCPP;
begin
  RegisterComponents('SynEdit',[TSynCPPSyn]);
end;

procedure RegisterSynHighlighterPerl;
begin
  RegisterComponents('SynEdit',[TSynPerlSyn]);
end;

procedure RegisterSynHighlighterHTML;
begin
  RegisterComponents('SynEdit',[TSynHTMLSyn]);
end;

procedure RegisterSynHighlighterXML;
begin
  RegisterComponents('SynEdit',[TSynXMLSyn]);
end;

procedure RegisterSynHighlighterLFM;
begin
  RegisterComponents('SynEdit',[TSynLFMSyn]);
end;

procedure RegisterSynHighlighterDiff;
begin
  RegisterComponents('SynEdit',[TSynDiffSyn]);
end;

procedure RegisterSynHighlighterUNIXShellScript;
begin
  RegisterComponents('SynEdit',[TSynUNIXShellScriptSyn]);
end;

procedure RegisterSynHighlighterCSS;
begin
  RegisterComponents('SynEdit',[TSynCssSyn]);
end;

procedure RegisterSynHighlighterPHP;
begin
  RegisterComponents('SynEdit',[TSynPHPSyn]);
end;

procedure RegisterSynHighlighterTeX;
begin
  RegisterComponents('SynEdit',[TSynTeXSyn]);
end;

procedure RegisterSynHighlighterSQL;
begin
  RegisterComponents('SynEdit',[TSynSQLSyn]);
end;

procedure RegisterSynHighlighterPython;
begin
  RegisterComponents('SynEdit',[TSynPythonSyn]);
end;

procedure RegisterSynHighlighterAny;
begin
  RegisterComponents('SynEdit',[TSynAnySyn]);
end;

procedure RegisterSynHighlighterMulti;
begin
  RegisterComponents('SynEdit',[TSynMultiSyn]);
end;

procedure RegisterSynHighlighterBat;
begin
  RegisterComponents('SynEdit',[TSynBatSyn]);
end;

procedure RegisterSynHighlighterIni;
begin
  RegisterComponents('SynEdit',[TSynIniSyn]);
end;

procedure RegisterSynHighlighterPo;
begin
  RegisterComponents('SynEdit',[TSynPoSyn]);
end;

procedure RegisterSynHighlighterVB;
begin
  RegisterComponents('SynEdit',[TSynVBSyn]);
end;

procedure RegisterSynGutter;
begin
  RegisterNoIcon([TSynGutterPartList, TSynGutterSeparator]);
end;

procedure RegisterSynGutterCodeFolding;
begin
  RegisterNoIcon([TSynGutterCodeFolding]);
end;

procedure RegisterSynGutterChanges;
begin
  RegisterNoIcon([TSynGutterChanges]);
end;

procedure RegisterSynGutterLineNumber;
begin
  RegisterNoIcon([TSynGutterLineNumber]);
end;

procedure RegisterSynGutterMarks;
begin
  RegisterNoIcon([TSynGutterMarks]);
end;

procedure Register;
begin
  RegisterSynGutter;
  RegisterSynGutterCodeFolding;
  RegisterSynGutterLineNumber;
  RegisterSynGutterChanges;
  RegisterSynGutterMarks;

  RegisterSynEdit;
  RegisterSynMemo;

  RegisterSynCompletion;
  RegisterSynMacroRecorder;
  RegisterSynExportHTML;
  RegisterSynSyncroEdit;
  RegisterSynPopupMenu;

  RegisterSynHighlighterPas;;
  RegisterSynHighlighterCPP;
  RegisterSynHighlighterJava;
  RegisterSynHighlighterJScript;
  RegisterSynHighlighterPerl;
  RegisterSynHighlighterHTML;
  RegisterSynHighlighterXML;
  RegisterSynHighlighterLFM;
  RegisterSynHighlighterDiff;
  RegisterSynHighlighterUNIXShellScript;
  RegisterSynHighlighterCSS;
  RegisterSynHighlighterPHP;
  RegisterSynHighlighterTeX;
  RegisterSynHighlighterSQL;
  RegisterSynHighlighterPython;
  RegisterSynHighlighterVB;

  RegisterSynHighlighterAny;
  RegisterSynHighlighterMulti;
  RegisterSynHighlighterBat;
  RegisterSynHighlighterIni;
  RegisterSynHighlighterPo;

  RegisterClasses([TSynGutterPartList, TSynGutterSeparator, TSynGutterCodeFolding,
                  TSynGutterLineNumber, TSynGutterChanges, TSynGutterMarks]);

  RegisterComponentEditor(TCustomSynEdit, TSynEditComponentEditor);

  // property editor, with filter for deprecated values
  RegisterPropertyEditor(TypeInfo(TSynEditorOptions), nil,
    '', TSynEdOptionsPropertyEditor);

  RegisterPropertyEditor(ClassTypeInfo(TSynGutterPartListBase), nil,
    '', TSynPropertyEditGutterPartList);
  RegisterPropertyEditor(TypeInfo(TSynEditorMouseCommand), nil,
    '', TSynMouseCommandPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TSynEditorCommand), nil,
    '', TSynKeyCommandPropertyEditor);

  RegisterGutterPartClass(TSynGutterLineNumber, syndsLineNumbers);
  RegisterGutterPartClass(TSynGutterCodeFolding, syndsCodeFolding);
  RegisterGutterPartClass(TSynGutterChanges, syndsChangeMarker);
  RegisterGutterPartClass(TSynGutterMarks, syndsBookmarks);
  RegisterGutterPartClass(TSynGutterSeparator, syndsSeparator);
  {$IFDEF DesignSynGutterLineOverview}
  RegisterGutterPartClass(TSynGutterLineOverview, syndsLineOverview);
  {$ENDIF}
end;

end.

