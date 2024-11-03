unit frClarifyIndent;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is frClarify.pas, released April 2000.
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

uses
  Classes, StdCtrls, Spin,
  IDEOptionsIntf, IDEOptEditorIntf;

type

  { TfClarifyIndent }

  TfClarifyIndent = class(TAbstractIDEOptionsEditor)
    cbIndentEndTryBlockAsCode: TCheckBox;
    cbIndentExtraOrphanTryBlocks: TCheckBox;
    cbIndentExtraTryBlockKeywords: TCheckBox;
    cbIndentCaseLabels: TCheckBox;
    cbIndentInterfaceGuid: TCheckBox;
    cbIndentLabels: TComboBox;
    eIndentTryFinallyExceptSpaces: TSpinEdit;
    Label2: TLabel;
    edtIndentSpaces: TSpinEdit;
    gbOptions: TGroupBox;
    cbIndentBeginEnd: TCheckBox;
    eIndentBeginEndSpaces: TSpinEdit;
    cbHasFirstLevelIndent: TCheckBox;
    eFirstLevelIndent: TSpinEdit;
    cbKeepWithInProc: TCheckBox;
    cbKeepWithInGlobals: TCheckBox;
    cbKeepWithInClassDef: TCheckBox;
    cbKeepWithElsewhere: TCheckBox;
    cbIndentIfElse: TCheckBox;
    cbIndentCaseElse: TCheckBox;
    cbIndentLibraryProcs: TCheckBox;
    cbIndentProcedureBody: TCheckBox;
    cbIndentNestedTypes: TCheckBox;
    cbIndentVarAndConstInClass: TCheckBox;
    lbIndentLabels: TLabel;
    procedure cbIndentBeginEndClick(Sender: TObject);
    procedure cbHasFirstLevelIndentClick(Sender: TObject);
    procedure cbIndentExtraTryBlockKeywordsClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    function GetTitle: String; override;
    procedure Setup({%H-}ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings({%H-}AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings({%H-}AOptions: TAbstractIDEOptions); override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
  end;

implementation

{$R *.lfm}

uses
  JcfSettings, JcfUIConsts, JcfIdeRegister, SettingsTypes;

constructor TfClarifyIndent.Create(AOwner: TComponent);
begin
  inherited;
  //fiHelpContext := HELP_CLARIFY_INDENTATION;
end;

function TfClarifyIndent.GetTitle: String;
begin
  Result := lisIndentIndentation;
end;

procedure TfClarifyIndent.Setup(ADialog: TAbstractOptionsEditorDialog);
begin
  Label2.Caption := lisIndentBlockIndentationSpaces;
  gbOptions.Caption := lisIndentOptions;
  cbIndentBeginEnd.Caption := lisIndentExtraIndentForBeginEnd;
  cbHasFirstLevelIndent.Caption := lisIndentDifferentIndentForFirstLevel;
  cbKeepWithInProc.Caption := lisIndentKeepSingleLineCommentsWithCodeInProcs;
  cbKeepWithInGlobals.Caption :=
    lisIndentKeepSingleLineCommentsWithCodeInGlobals;
  cbKeepWithInClassDef.Caption :=
    lisIndentKeepSingleLineCommentsWithCodeInClassDefs;
  cbKeepWithElsewhere.Caption :=
    lisIndentKeepSingleLineCommentsWithCodeElsewhere;
  cbIndentIfElse.Caption := lisIndentExtraIndentForIfElseBlocks;
  cbIndentCaseElse.Caption := lisIndentExtraIndentForCaseElseBlocks;
  cbIndentCaseLabels.Caption := lisIndentExtraIndentForCaseLabels;
  cbIndentLibraryProcs.Caption := lisIndentIndentForProceduresInLibrary;
  cbIndentProcedureBody.Caption := lisIndentIndentForProcedureBody;
  cbIndentNestedTypes.Caption := lisIndentIndentNestedTypes;
  cbIndentVarAndConstInClass.Caption := lisIndentIndentVarAndConstInClass;
  cbIndentInterfaceGuid.Caption := lisIndentExtraIndentForInterfaceGuid;

  lbIndentLabels.Caption := lisIndentLabels;

  cbIndentLabels.Items.Clear;
  cbIndentLabels.Items.Add(lisIndentLabelsStatement);
  cbIndentLabels.Items.Add(lisIndentLabelsDontIndent);
  cbIndentLabels.Items.Add(lisIndentLabelsIndentPrevLevel);;
  cbIndentLabels.Items.Add(lisIndentLabelslIndentToProcedure);
  cbIndentLabels.Items.Add(lisIndentLabelsIndentX0);

  cbIndentExtraTryBlockKeywords.Caption := lisIndentTryFinallyExcept;
  cbIndentEndTryBlockAsCode.Caption := lisIndentEndTryBlockAsCode;
  cbIndentExtraOrphanTryBlocks.Caption := lisIndentExtraOrphanTryBlocks;
end;

{-------------------------------------------------------------------------------
  worker procs }

procedure TfClarifyIndent.ReadSettings(AOptions: TAbstractIDEOptions);
begin
  with FormattingSettings.Indent do
  begin
    edtIndentSpaces.Value    := IndentSpaces;
    cbIndentBeginEnd.Checked := IndentBeginEnd;
    eIndentBeginEndSpaces.Value := IndentBeginEndSpaces;

    cbIndentLibraryProcs.Checked := IndentLibraryProcs;

    cbHasFirstLevelIndent.Checked := HasFirstLevelIndent;
    eFirstLevelIndent.Value := FirstLevelIndent;

    cbKeepWithInProc.Checked     := KeepCommentsWithCodeInProcs;
    cbKeepWithInGlobals.Checked  := KeepCommentsWithCodeInGlobals;
    cbKeepWithInClassDef.Checked := KeepCommentsWithCodeInClassDef;
    cbKeepWithElsewhere.Checked  := KeepCommentsWithCodeElsewhere;
    cbIndentIfElse.Checked := IndentElse;
    cbIndentCaseLabels.Checked := IndentCaseLabels;
    cbIndentCaseElse.Checked := IndentCaseElse;
    cbIndentProcedureBody.Checked := IndentProcedureBody;

    cbIndentNestedTypes.Checked := IndentNestedTypes;
    cbIndentVarAndConstInClass.Checked := IndentVarAndConstInClass;
    cbIndentInterfaceGuid.Checked := IndentInterfaceGuid;
    cbIndentLabels.ItemIndex := Ord(IndentLabels);

    cbIndentExtraTryBlockKeywords.Checked := IndentExtraTryBlockKeyWords;
    eIndentTryFinallyExceptSpaces.Value := IndentExtraTryBlockKeyWordsSpaces;
    eIndentTryFinallyExceptSpaces.Enabled := IndentExtraTryBlockKeyWords;
    cbIndentEndTryBlockAsCode.Checked := IndentEndTryBlockAsCode;
    cbIndentExtraOrphanTryBlocks.Checked := IndentExtraOrphanTryBlocks;
  end;

  cbIndentBeginEndClick(nil);
  cbHasFirstLevelIndentClick(nil);
end;

procedure TfClarifyIndent.WriteSettings(AOptions: TAbstractIDEOptions);
begin

  with FormattingSettings.Indent do
  begin
    IndentSpaces   := edtIndentSpaces.Value;
    IndentBeginEnd := cbIndentBeginEnd.Checked;
    IndentBeginEndSpaces := eIndentBeginEndSpaces.Value;

    IndentLibraryProcs := cbIndentLibraryProcs.Checked;

    HasFirstLevelIndent := cbHasFirstLevelIndent.Checked;
    FirstLevelIndent    := eFirstLevelIndent.Value;

    KeepCommentsWithCodeInProcs    := cbKeepWithInProc.Checked;
    KeepCommentsWithCodeInGlobals  := cbKeepWithInGlobals.Checked;
    KeepCommentsWithCodeInClassDef := cbKeepWithInClassDef.Checked;
    KeepCommentsWithCodeElsewhere  := cbKeepWithElsewhere.Checked;
    IndentElse := cbIndentIfElse.Checked;
    IndentCaseLabels := cbIndentCaseLabels.Checked;
    IndentCaseElse := cbIndentCaseElse.Checked;
    IndentProcedureBody := cbIndentProcedureBody.Checked;

    IndentNestedTypes := cbIndentNestedTypes.Checked;
    IndentVarAndConstInClass := cbIndentVarAndConstInClass.Checked;
    IndentInterfaceGuid := cbIndentInterfaceGuid.Checked;
    IndentLabels := TIndentLabels(cbIndentLabels.ItemIndex);

    IndentExtraTryBlockKeyWords := cbIndentExtraTryBlockKeywords.Checked;
    IndentExtraTryBlockKeyWordsSpaces := eIndentTryFinallyExceptSpaces.Value;
    IndentEndTryBlockAsCode := cbIndentEndTryBlockAsCode.Checked;
    IndentExtraOrphanTryBlocks := cbIndentExtraOrphanTryBlocks.Checked;

  end;
end;

class function TfClarifyIndent.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result := TIDEFormattingSettings;
end;

{-------------------------------------------------------------------------------
  event handlers }

procedure TfClarifyIndent.cbIndentBeginEndClick(Sender: TObject);
begin
  eIndentBeginEndSpaces.Enabled := cbIndentBeginEnd.Checked;
end;

procedure TfClarifyIndent.cbHasFirstLevelIndentClick(Sender: TObject);
begin
  eFirstLevelIndent.Enabled := cbHasFirstLevelIndent.Checked;
end;

procedure TfClarifyIndent.cbIndentExtraTryBlockKeywordsClick(Sender: TObject);
begin
  eIndentTryFinallyExceptSpaces.Enabled := cbIndentExtraTryBlockKeywords.Checked;
end;

initialization
  RegisterIDEOptionsEditor(JCFOptionsGroup, TfClarifyIndent, JCFOptionIndentation, JCFOptionClarify);
end.
