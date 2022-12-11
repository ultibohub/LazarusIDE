{
 /***************************************************************************
                            makeresstrdlg.pas
                            -----------------


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
 
 Author: Mattias Gaertner
 
 Abstract:
   TMakeResStrDialog is the dialog to setup how to convert a string constant
   into a pascal resourcestring.
 
}
unit MakeResStrDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  LCLProc, Forms, Controls, StdCtrls, Dialogs, ExtCtrls, ButtonPanel,
  // SynEdit
  SynHighlighterPas, SynEdit,
  // CodeTools
  CodeToolManager, CodeToolsStructs, CodeCache,
  // IdeIntf
  IDEWindowIntf, IDEHelpIntf, IDEDialogs,
  // IDE
  LazarusIDEStrConsts, EditorOptions, InputHistory, MiscOptions, IDEProcs,
  RecentListProcs;

type

  { TMakeResStrDialog }

  TMakeResStrDialog = class(TForm)
    ButtonPanel1: TButtonPanel;
    CustomIdentifierCheckBox: TCheckBox;
    IdentifierGroupBox: TGroupBox;
    IdentifierEdit: TEdit;
    IdentLengthComboBox: TComboBox;
    IdentLengthLabel: TLabel;
    IdentPrefixComboBox: TComboBox;
    IdentPrefixLabel: TLabel;
    
    // options
    ConversionGroupBox: TGroupBox;
    CodePanel: TPanel;
    // resourcestring section
    ResStrSectionLabel: TLabel;
    ResStrSectionComboBox: TComboBox;
    // resourcestrings with same value
    ResStrWithSameValueLabel: TLabel;
    ResStrWithSameValuesCombobox: TComboBox;
    // insert position type
    AppendResStrRadioButton: TRadioButton;
    InsertAlphabeticallyResStrRadioButton: TRadioButton;
    InsertContextSensitiveRadioButton: TRadioButton;

    Splitter1: TSplitter;
    SrcPreviewGroupBox: TGroupBox;
    SrcPreviewSynEdit: TSynEdit;
    StringConstGroupBox: TGroupBox;
    StringConstSynEdit: TSynEdit;

    // highlighter
    SynPasSyn: TSynPasSyn;


    procedure CustomIdentifierCheckBoxClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure IdentLengthComboBoxChange(Sender: TObject);
    procedure IdentPrefixComboBoxChange(Sender: TObject);
    procedure IdentifierEditChange(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure ResStrSectionComboBoxChange(Sender: TObject);
    procedure ResStrWithSameValuesComboboxChange(Sender: TObject);
  private
    procedure SetupComponents;
  public
    DefaultIdentifier: string;
    Code: TCodeBuffer;
    StartPos, EndPos: TPoint;
    Positions: TCodeXYPositions;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure FillResourceStringSections(NewPositions: TCodeXYPositions);
    procedure FillIdentPrefixes;
    procedure FillIdentLengths;
    procedure FillStringsWithSameValue;
    procedure UpdateIdentifier;
    procedure UpdateSourcePreview;
    function GetIdentifier: string;
    function GetDefaultIdentifier: string;
    procedure SetSource(NewCode: TCodeBuffer;
      const NewStartPos, NewEndPos: TPoint);
    function ResStrExistsInCurrentSection(const Identifier: string): boolean;
    function ResStrExistsInAnySection(const Identifier: string): boolean;
    function ResStrExistsWithSameValue(const Identifier: string): boolean;
    procedure GetNewSource(out NewSource, ResourceStringValue: string);
    procedure Init;
    procedure SaveHistories;
    procedure SaveIdentPrefixes;
    procedure SaveIdentLengths;
    procedure Save;
  end;
  
function ShowMakeResStrDialog(
  const StartPos, EndPos: TPoint; Code: TCodeBuffer;
  out NewIdentifier, NewIdentifierValue: string;
  out NewSourceLines: string;
  out ResStrSectionCode: TCodeBuffer;
  out ResStrSectionXY: TPoint;
  out InsertPolicy: TResourcestringInsertPolicy): TModalResult;

implementation

{$R *.lfm}


function ShowMakeResStrDialog(const StartPos, EndPos: TPoint;
  Code: TCodeBuffer; out NewIdentifier, NewIdentifierValue: string; out
  NewSourceLines: string; out ResStrSectionCode: TCodeBuffer; out
  ResStrSectionXY: TPoint; out InsertPolicy: TResourcestringInsertPolicy
  ): TModalResult;
var
  MakeResStrDialog: TMakeResStrDialog;
  Section: PCodeXYPosition;
  ResourcestringSectionID: Integer;
begin
  //debugln('ShowMakeResStrDialog StartPos=',dbgs(StartPos),' EndPos=',dbgs(EndPos),' ');
  NewIdentifier:='';
  NewIdentifierValue:='';
  NewSourceLines:='';
  ResStrSectionCode:=nil;
  ResStrSectionXY:=Point(0,0);
  InsertPolicy:=rsipNone;

  MakeResStrDialog:=TMakeResStrDialog.Create(nil);
  MakeResStrDialog.Positions:=CodeToolBoss.Positions.CreateCopy;
  MakeResStrDialog.SetSource(Code,StartPos,EndPos);
  MakeResStrDialog.Init;

  // show dialog
  Result:=MakeResStrDialog.ShowModal;
  if Result=mrOk then begin
    // return results
    NewIdentifier:=MakeResStrDialog.GetIdentifier;
    MakeResStrDialog.GetNewSource(NewSourceLines,NewIdentifierValue);
    if MakeResStrDialog.ResStrExistsWithSameValue(NewIdentifier) then
      InsertPolicy:=rsipNone
    else begin
      if MakeResStrDialog.InsertAlphabeticallyResStrRadioButton.Checked then
        InsertPolicy:=rsipAlphabetically
      else if MakeResStrDialog.InsertContextSensitiveRadioButton.Checked then
        InsertPolicy:=rsipContext
      else
        InsertPolicy:=rsipAppend;
    end;
    ResourcestringSectionID:=MakeResStrDialog.ResStrSectionComboBox.ItemIndex;
    Section:=CodeToolBoss.Positions[ResourcestringSectionID];
    ResStrSectionCode:=Section^.Code;
    ResStrSectionXY:=Point(Section^.X,Section^.Y);
  end;

  // save settings and clean up
  IDEDialogLayoutList.SaveLayout(MakeResStrDialog);

  MakeResStrDialog.Positions.Free;
  MakeResStrDialog.Free;
end;

{ TMakeResStrDialog }

procedure TMakeResStrDialog.CustomIdentifierCheckBoxClick(Sender: TObject);
begin
  UpdateIdentifier;
end;

procedure TMakeResStrDialog.HelpButtonClick(Sender: TObject);
begin
  LazarusHelp.ShowHelpForIDEControl(Self);
end;

procedure TMakeResStrDialog.IdentLengthComboBoxChange(Sender: TObject);
begin
  UpdateIdentifier;
  UpdateSourcePreview;
end;

procedure TMakeResStrDialog.IdentPrefixComboBoxChange(Sender: TObject);
begin
  UpdateIdentifier;
  UpdateSourcePreview;
end;

procedure TMakeResStrDialog.IdentifierEditChange(Sender: TObject);
begin
  UpdateIdentifier;
  UpdateSourcePreview;
end;

procedure TMakeResStrDialog.OkButtonClick(Sender: TObject);
var
  Index: Integer;
begin
  Index:=ResStrSectionComboBox.ItemIndex;
  if (Index<0) or (Index>=Positions.Count) then begin
    IDEMessageDialog(lisMakeResStrInvalidResourcestringSect,
      lisMakeResStrPleaseChooseAResourcestring,
      mtError,[mbCancel]);
    exit;
  end;
  if ResStrExistsInAnySection(IdentifierEdit.Text)
  and (not ResStrExistsWithSameValue(IdentifierEdit.Text)) then begin
    if IDEMessageDialog(lisMakeResStrResourcestringAlreadyExis,
      Format(lisMakeResStrChooseAnotherName,[IdentifierEdit.Text,LineEnding,LineEnding]),
      mtWarning,[mbOk,mbIgnore]) = mrOk
    then
      exit;
  end;
  Save;
  ModalResult:=mrOk;
end;

procedure TMakeResStrDialog.ResStrSectionComboBoxChange(Sender: TObject);
begin
  UpdateIdentifier;
  UpdateSourcePreview;
end;

procedure TMakeResStrDialog.ResStrWithSameValuesComboboxChange(Sender: TObject);
var
  NewIdentifier: String;
  i: Integer;
begin
  NewIdentifier:=ResStrWithSameValuesCombobox.Text;
  i:=ResStrWithSameValuesCombobox.Items.IndexOf(NewIdentifier);
  if i<0 then exit;
  IdentifierEdit.Text:=NewIdentifier;
end;

procedure TMakeResStrDialog.SetupComponents;
begin
  // source
  AppendResStrRadioButton.Caption:=lisMakeResStrAppendToSection;
  ConversionGroupBox.Caption:=lisMakeResStrConversionOptions;
  CustomIdentifierCheckBox.Caption:=lisMakeResStrCustomIdentifier;
  IdentifierGroupBox.Caption := lisMakeResStrDialogIdentifier;
  IdentLengthLabel.Caption:=lisMakeResStrIdentifierLength;
  IdentPrefixLabel.Caption:=lisMakeResStrIdentifierPrefix;
  InsertAlphabeticallyResStrRadioButton.Caption:=lisMakeResStrInsertAlphabetically;
  InsertContextSensitiveRadioButton.Caption:=lisMakeResStrInsertContexttSensitive;
  ResStrSectionLabel.Caption:=lisMakeResStrResourcestringSection;
  ResStrWithSameValueLabel.Caption:=lisMakeResStrStringsWithSameValue;
  SrcPreviewGroupBox.Caption:=lisMakeResStrSourcePreview;
  StringConstGroupBox.Caption:=lisMakeResStrStringConstantInSource;

  // OK, Cancel, Help buttons
  ButtonPanel1.OkButton.Caption:=lisMenuOk;
  ButtonPanel1.CancelButton.Caption:=lisCancel;
  ButtonPanel1.HelpButton.Caption:=lisMenuHelp;
end;

constructor TMakeResStrDialog.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  Caption := lisMakeResourceString;
  SetupComponents;

  IDEDialogLayoutList.ApplyLayout(Self,550,400);

  EditorOpts.GetHighlighterSettings(SynPasSyn);
  EditorOpts.GetSynEditSettings(StringConstSynEdit);
  StringConstSynEdit.ReadOnly:=true;
  StringConstSynEdit.Gutter.Visible:=false;
  EditorOpts.GetSynEditSettings(SrcPreviewSynEdit);
  SrcPreviewSynEdit.ReadOnly:=true;
  SrcPreviewSynEdit.Gutter.Visible:=false;
end;

destructor TMakeResStrDialog.Destroy;
begin
  inherited Destroy;
end;

procedure TMakeResStrDialog.FillResourceStringSections(
  NewPositions: TCodeXYPositions);
var
  i: Integer;
  p: PCodeXYPosition;
  s: String;
begin
  Positions:=NewPositions;
  // the history list contains the filenames plus the
  with ResStrSectionComboBox do begin
    Text:='';
    Items.BeginUpdate;
    for i:=0 to Positions.Count-1 do begin
      p:=Positions[i];
      s:=p^.Code.Filename+' ('+IntToStr(p^.Y)+','+IntToStr(p^.X)+')';
      if i<Items.Count then
        Items[i]:=s
      else
        Items.Add(s);
    end;
    while Items.Count>Positions.Count do
      Items.Delete(Items.Count-1);
    Items.EndUpdate;
    ItemIndex:=0;
  end;
end;

procedure TMakeResStrDialog.FillIdentPrefixes;
var
  HistoryList: THistoryList;
begin
  // get the Prefixes history list
  HistoryList:=
         InputHistories.HistoryLists.GetList(hlMakeResourceStringPrefixes,true,
                                             rltCaseSensitive);
  IdentPrefixComboBox.Items.Assign(HistoryList);
  if IdentPrefixComboBox.Items.Count>0 then
    IdentPrefixComboBox.Text:=IdentPrefixComboBox.Items[0]
  else
    IdentPrefixComboBox.Text:='rs';
end;

procedure TMakeResStrDialog.FillIdentLengths;
var
  HistoryList: THistoryList;
begin
  // get the Length history list
  HistoryList:=
    InputHistories.HistoryLists.GetList(hlMakeResourceStringLengths,true,
                                        rltCaseSensitive);
  IdentLengthComboBox.Items.Assign(HistoryList);
  if IdentLengthComboBox.Items.Count>0 then
    IdentLengthComboBox.Text:=IdentLengthComboBox.Items[0]
  else begin
    with IdentLengthComboBox.Items do begin
      Add('8');
      Add('12');
      Add('20');
      Add('50');
    end;
    IdentLengthComboBox.Text:='12';
  end;
end;

procedure TMakeResStrDialog.FillStringsWithSameValue;
var
  i: Integer;
  CurSection: TCodeXYPosition;
  NewSource, ResourceStringValue: string;
  StringConstPositions: TCodeXYPositions;
  ExistingIdentifier: string;
begin
  // get value of the new resourcestring
  GetNewSource(NewSource, ResourceStringValue);
  // get all existing resourcestrings with same value
  StringConstPositions:=TCodeXYPositions.Create;
  for i:=0 to Positions.Count-1 do begin
    CurSection:=Positions[i]^;
    CodeToolBoss.GatherResourceStringsWithValue(
      CurSection.Code,CurSection.X,CurSection.Y,
      ResourceStringValue,StringConstPositions);
  end;
  // fill combobox
  ResStrWithSameValuesCombobox.Items.Clear;
  for i:=0 to StringConstPositions.Count-1 do begin
    CurSection:=StringConstPositions[i]^;
    CodeToolBoss.GetIdentifierAt(CurSection.Code,CurSection.X,CurSection.Y,
                                 ExistingIdentifier);
    if ExistingIdentifier<>'' then
      ResStrWithSameValuesCombobox.Items.Add(ExistingIdentifier);
  end;
  // enable components for selection
  if ResStrWithSameValuesCombobox.Items.Count>0 then begin
    ResStrWithSameValuesCombobox.Text:=ResStrWithSameValuesCombobox.Items[0];
    ResStrWithSameValuesCombobox.Enabled:=true;
  end else begin
    ResStrWithSameValuesCombobox.Text:='';
    ResStrWithSameValuesCombobox.Enabled:=false;
  end;
  ResStrWithSameValueLabel.Enabled:=ResStrWithSameValuesCombobox.Enabled;
  // clean up
  StringConstPositions.Free;
end;

procedure TMakeResStrDialog.UpdateIdentifier;
var
  CustomIdent: Boolean;
begin
  CustomIdent:=CustomIdentifierCheckBox.Checked;
  IdentifierEdit.Enabled:=CustomIdent;
  IdentPrefixLabel.Enabled:=not CustomIdent;
  IdentPrefixComboBox.Enabled:=not CustomIdent;
  IdentLengthLabel.Enabled:=not CustomIdent;
  IdentLengthComboBox.Enabled:=not CustomIdent;
  if not CustomIdent then
    IdentifierEdit.Text:=GetDefaultIdentifier;
end;

procedure TMakeResStrDialog.UpdateSourcePreview;
var
  NewSource, NewValue: string;
begin
  GetNewSource(NewSource,NewValue);
  SrcPreviewSynEdit.Text:=NewSource+LineEnding
     +StringOfChar('-',
                  CodeToolBoss.SourceChangeCache.BeautifyCodeOptions.LineLength)
     +LineEnding
     +CodeToolBoss.SourceChangeCache.BeautifyCodeOptions.BeautifyStatement(
        GetIdentifier+' = '''+NewValue+'''',0);
end;

function TMakeResStrDialog.GetIdentifier: string;
begin
  Result:=IdentifierEdit.Text;
  if Result='' then Result:=GetDefaultIdentifier;
end;

function TMakeResStrDialog.GetDefaultIdentifier: string;
var
  DefIdenLength: Integer;
  i: Integer;
begin
  if ResStrWithSameValuesCombobox.Items.Count>0 then begin
    Result:=ResStrWithSameValuesCombobox.Items[0];
    exit;
  end;
  DefIdenLength:=StrToIntDef(IdentLengthComboBox.Text,8);
  if DefIdenLength<1 then DefIdenLength:=1;
  if DefIdenLength>80 then DefIdenLength:=80;
  Result:=IdentPrefixComboBox.Text+copy(DefaultIdentifier,1,DefIdenLength);
  if ResStrExistsInCurrentSection(Result) then begin
    i:=2;
    while ResStrExistsInCurrentSection(Result+IntToStr(i)) do inc(i);
    Result:=Result+IntToStr(i);
  end;
end;

procedure TMakeResStrDialog.SetSource(NewCode: TCodeBuffer; const NewStartPos,
  NewEndPos: TPoint);
begin
  Code:=NewCode;
  StartPos:=NewStartPos;
  EndPos:=NewEndPos;
end;

function TMakeResStrDialog.ResStrExistsInCurrentSection(const Identifier: string
  ): boolean;
var
  CodeXY: PCodeXYPosition;
  Index: Integer;
begin
  Result:=false;
  Index:=ResStrSectionComboBox.ItemIndex;
  if (Index<0) or (Index>=Positions.Count) then exit;
  CodeXY:=Positions.Items[Index];
  Result:=CodeToolBoss.IdentifierExistsInResourceStringSection(
                                CodeXY^.Code,CodeXY^.X,CodeXY^.Y,Identifier);
end;

function TMakeResStrDialog.ResStrExistsInAnySection(const Identifier: string
  ): boolean;
var
  CodeXY: PCodeXYPosition;
  Index: Integer;
begin
  Result:=false;
  for Index:=0 to Positions.Count-1 do begin
    CodeXY:=Positions.Items[Index];
    Result:=CodeToolBoss.IdentifierExistsInResourceStringSection(
                                   CodeXY^.Code,CodeXY^.X,CodeXY^.Y,Identifier);
    if Result then exit;
  end;
end;

function TMakeResStrDialog.ResStrExistsWithSameValue(const Identifier: string
  ): boolean;
var
  i: Integer;
begin
  if Identifier<>'' then begin
    for i:=0 to ResStrWithSameValuesCombobox.Items.Count-1 do begin
      if CompareText(Identifier,ResStrWithSameValuesCombobox.Items[i])=0
      then begin
        Result:=true;
        exit;
      end;
    end;
  end;
  Result:=false;
end;

procedure TMakeResStrDialog.GetNewSource(out NewSource,
  ResourceStringValue: string);
var
  FormatStringConstant: string;
  FormatParameters: string;
  LeftSide: String;
  LastLine: string;
  NewString: String;
  RightSide: String;
  StartInStringConst, EndInStringConst: boolean;
begin
  NewSource:='';
  ResourceStringValue:='';
  if not CodeToolBoss.StringConstToFormatString(Code,StartPos.X,StartPos.Y,
     Code,EndPos.X,EndPos.Y,FormatStringConstant,FormatParameters,
     StartInStringConst,EndInStringConst)
  then begin
    SrcPreviewSynEdit.Text:=lisCCOErrorCaption+':'#13+CodeToolBoss.ErrorMessage;
    exit;
  end;
  if FormatParameters='' then
    NewString:=GetIdentifier
  else
    NewString:='Format('+GetIdentifier+',['+FormatParameters+'])';
  if StartInStringConst then
    NewString:='''+'+NewString;
  if EndInStringConst then
    NewString:=NewString+'+''';
  LeftSide:=copy(StringConstSynEdit.Lines[0],1,StartPos.X-1);
  LastLine:=StringConstSynEdit.Lines[EndPos.Y-StartPos.Y];
  RightSide:=copy(LastLine,EndPos.X,length(LastLine)-EndPos.X+1);

  NewSource:=LeftSide+NewString+RightSide;
  with CodeToolBoss.SourceChangeCache.BeautifyCodeOptions do
    NewSource:=BeautifyStatement(NewSource,0);

  ResourceStringValue:=FormatStringConstant;
end;

procedure TMakeResStrDialog.Init;
var
  InsertPolicy: TResourcestringInsertPolicy;
begin
  // string constant
  StringConstSynEdit.Text:=Code.GetLines(StartPos.Y,EndPos.Y);
  // reachable resourcestring sections
  FillResourceStringSections(Positions);
  // identifier prefixes
  FillIdentPrefixes;
  // identifier lengths
  FillIdentLengths;
  // existing resource strings with same value
  FillStringsWithSameValue;
  // identifier
  CustomIdentifierCheckBox.Checked:=false;
  CodeToolBoss.CreateIdentifierFromStringConst(Code,StartPos.X,StartPos.Y,
     Code,EndPos.X,EndPos.Y,DefaultIdentifier,50);
  UpdateIdentifier;
  // insert policy
  InsertPolicy:=MiscellaneousOptions.MakeResourceStringInsertPolicy;
  case InsertPolicy of
  rsipAlphabetically: InsertAlphabeticallyResStrRadioButton.Checked:=true;
  rsipContext:        InsertContextSensitiveRadioButton.Checked:=true;
  else                AppendResStrRadioButton.Checked:=true;
  end;
  // show new source
  UpdateSourcePreview;
end;

procedure TMakeResStrDialog.SaveHistories;
begin
  SaveIdentPrefixes;
  SaveIdentLengths;
end;

procedure TMakeResStrDialog.SaveIdentPrefixes;
var
  HistoryList: THistoryList;
begin
  if CustomIdentifierCheckBox.Checked
  or (IdentPrefixComboBox.Text='') then
    exit;
  HistoryList:=
    InputHistories.HistoryLists.GetList(hlMakeResourceStringPrefixes,true,rltCaseSensitive);
  if HistoryList.Count=0 then
    HistoryList.Assign(IdentPrefixComboBox.Items);
  HistoryList.Push(IdentPrefixComboBox.Text);
end;

procedure TMakeResStrDialog.SaveIdentLengths;
var
  HistoryList: THistoryList;
begin
  if CustomIdentifierCheckBox.Checked
  or (IdentLengthComboBox.Text='') then
    exit;
  HistoryList:=
    InputHistories.HistoryLists.GetList(hlMakeResourceStringLengths,true,rltCaseSensitive);
  if HistoryList.Count=0 then
    HistoryList.Assign(IdentLengthComboBox.Items);
  HistoryList.Push(IdentLengthComboBox.Text);
end;

procedure TMakeResStrDialog.Save;
var
  InsertPolicy: TResourcestringInsertPolicy;
begin
  SaveHistories;
  if InsertContextSensitiveRadioButton.Checked then
    InsertPolicy:=rsipContext
  else if InsertAlphabeticallyResStrRadioButton.Checked then
    InsertPolicy:=rsipAlphabetically
  else
    InsertPolicy:=rsipAppend;
  MiscellaneousOptions.MakeResourceStringInsertPolicy:=InsertPolicy;
  MiscellaneousOptions.Save;
end;

end.

