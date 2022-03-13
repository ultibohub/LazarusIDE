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
}
unit editor_multiwindow_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  LCLType, StdCtrls, ExtCtrls, CheckLst, ComCtrls, Dialogs, Spin, Controls,
  // IdeIntf
  IDEOptionsIntf, IDEOptEditorIntf, IDEUtils,
  // IDE
  EditorOptions, LazarusIDEStrConsts, SourceEditor;

type

  { TEditorMultiWindowOptionsFrame }

  TEditorMultiWindowOptionsFrame = class(TAbstractIDEOptionsEditor)
    Bevel1: TBevel;
    Bevel1a: TBevel;
    Bevel2a: TBevel;
    Bevel2: TBevel;
    CenterLabel: TLabel;
    cgCloseOther: TCheckGroup;
    cgCloseRight: TCheckGroup;
    chkShowFileNameInCaption: TCheckBox;
    chkMultiLine: TCheckBox;
    chkUseTabHistory: TCheckBox;
    chkShowCloseBtn: TCheckBox;
    chkShowNumbers: TCheckBox;
    chkHideSingleTab: TCheckBox;
    DisableAntialiasingCheckBox: TCheckBox;
    TabFontButton: TButton;
    TabFontComboBox: TComboBox;
    TabFontGroupBox: TGroupBox;
    TabFontSizeSpinEdit: TSpinEdit;
    EditorTabPositionCheckBox: TComboBox;
    EditorTabPositionLabel: TLabel;
    lblAccessTypeDesc: TLabel;
    lblMultiWinTabSection: TLabel;
    listAccessType: TCheckListBox;
    AccessTypePanel: TPanel;
    lblEditActivationOrderSection: TLabel;
    lblAccessOrder: TLabel;
    lblAccessType: TLabel;
    Panel1: TPanel;
    pnlNBTabs: TPanel;
    radioAccessOrderEdit: TRadioButton;
    radioAccessOrderWin: TRadioButton;
    Panel2: TPanel;
    Splitter1: TSplitter;
    procedure listAccessTypeClickCheck(Sender: TObject);
    procedure listAccessTypeKeyUp(Sender: TObject; var {%H-}Key: Word; {%H-}Shift: TShiftState);
    procedure radioAccessOrderEditChange(Sender: TObject);
    procedure TabFontButtonClick(Sender: TObject);
    procedure TabFontComboBoxChange(Sender: TObject);
    procedure TabFontSizeSpinEditChange(Sender: TObject);
    procedure SetTabFontSizeSpinEditValue(FontSize: Integer);
  private
    FMultiWinEditAccessOrder: TEditorOptionsEditAccessOrderList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetTitle: String; override;
    procedure Setup({%H-}ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings(AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings(AOptions: TAbstractIDEOptions); override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
  end;

implementation

{$R *.lfm}

{ TEditorMultiWindowOptionsFrame }

procedure TEditorMultiWindowOptionsFrame.listAccessTypeClickCheck(Sender: TObject);
var
  i: Integer;
begin
  i := listAccessType.ItemIndex;
  lblAccessTypeDesc.Caption := FMultiWinEditAccessOrder[i].Desc;
  for i := 0 to FMultiWinEditAccessOrder.Count - 1 do begin
    if FMultiWinEditAccessOrder[i].IsFallback then
      listAccessType.Checked[i] := True;
    FMultiWinEditAccessOrder[i].Enabled := listAccessType.Checked[i];
  end;
end;

procedure TEditorMultiWindowOptionsFrame.listAccessTypeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  listAccessTypeClickCheck(Sender);
end;

procedure TEditorMultiWindowOptionsFrame.radioAccessOrderEditChange(Sender: TObject);
begin
  if radioAccessOrderEdit.Checked then
    FMultiWinEditAccessOrder.SearchOrder := eoeaOrderByEditFocus;
  if radioAccessOrderWin.Checked then
    FMultiWinEditAccessOrder.SearchOrder := eoeaOrderByWindowFocus;
end;

procedure TEditorMultiWindowOptionsFrame.TabFontButtonClick(Sender: TObject);
var
  FontDialog: TFontDialog;
  fs: Integer;
begin
  FontDialog := TFontDialog.Create(nil);
  try
    with FontDialog do
    begin
      Font.Name := TabFontComboBox.Text;
      if TabFontSizeSpinEdit.Value < 0 then
        Font.Height := -TabFontSizeSpinEdit.Value
      else
        Font.Size := TabFontSizeSpinEdit.Value;
      if Execute then begin
        SetComboBoxText(TabFontComboBox, Font.Name, cstCaseInsensitive);
        fs := Font.Size;
        RepairEditorFontSize(fs);
        SetTabFontSizeSpinEditValue(fs);
      end;
    end;
  finally
    FontDialog.Free;
  end;
end;

procedure TEditorMultiWindowOptionsFrame.TabFontComboBoxChange(Sender: TObject);
begin
  TabFontSizeSpinEdit.Enabled := TabFontComboBox.Text <> '';
  DisableAntialiasingCheckBox.Enabled := TabFontComboBox.Text <> '';
end;

procedure TEditorMultiWindowOptionsFrame.TabFontSizeSpinEditChange(
  Sender: TObject);
var
  s: TCaption;
begin
  s := TabFontSizeSpinEdit.Text;
  if copy(trim(s),1,1) = '-' then begin
    if TabFontSizeSpinEdit.MinValue > 0 then begin
      TabFontSizeSpinEdit.MinValue := -100;
      TabFontSizeSpinEdit.MaxValue := -EditorOptionsMinimumFontSize;
      TabFontSizeSpinEdit.Text := s;
    end
    else
    if TabFontSizeSpinEdit.Value > -EditorOptionsMinimumFontSize then
      TabFontSizeSpinEdit.Value := -EditorOptionsMinimumFontSize;
  end
  else begin
    if TabFontSizeSpinEdit.MinValue < 0 then begin
      TabFontSizeSpinEdit.MaxValue := 100;
      TabFontSizeSpinEdit.MinValue := EditorOptionsMinimumFontSize;
      TabFontSizeSpinEdit.Text := s;
    end
    else
    if TabFontSizeSpinEdit.Value < EditorOptionsMinimumFontSize then
      TabFontSizeSpinEdit.Value := EditorOptionsMinimumFontSize;
  end;
end;

procedure TEditorMultiWindowOptionsFrame.SetTabFontSizeSpinEditValue(
  FontSize: Integer);
begin
  if FontSize < 0 then begin
    TabFontSizeSpinEdit.MinValue := -100;
    TabFontSizeSpinEdit.MaxValue := -EditorOptionsMinimumFontSize;
  end
  else begin
    TabFontSizeSpinEdit.MaxValue := 100;
    TabFontSizeSpinEdit.MinValue := EditorOptionsMinimumFontSize;
  end;
  TabFontSizeSpinEdit.Value := FontSize;
end;

constructor TEditorMultiWindowOptionsFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMultiWinEditAccessOrder := TEditorOptionsEditAccessOrderList.Create;
end;

destructor TEditorMultiWindowOptionsFrame.Destroy;
begin
  FreeAndNil(FMultiWinEditAccessOrder);
  inherited Destroy;
end;

function TEditorMultiWindowOptionsFrame.GetTitle: String;
begin
  Result := dlgMultiWinOptions;
end;

procedure TEditorMultiWindowOptionsFrame.Setup(ADialog: TAbstractOptionsEditorDialog);
var
  TmpNB: TSourceNotebook;
begin
  TmpNB := TSourceNotebook.Create(nil, -1);
  chkShowCloseBtn.Enabled := nbcShowCloseButtons in TmpNB.GetCapabilities;
  chkMultiLine.Enabled := nbcMultiLine in TmpNB.GetCapabilities;
  TmpNB.Free;

  lblMultiWinTabSection.Caption := dlgMultiWinTabGroup;
  lblEditActivationOrderSection.Caption := dlgMultiWinAccessGroup;
  lblAccessOrder.Caption := dlgMultiWinAccessOrder;
  radioAccessOrderEdit.Caption := dlgMultiWinAccessOrderEdit;
  radioAccessOrderWin.Caption := dlgMultiWinAccessOrderWin;
  lblAccessType.Caption := dlgMultiWinAccessType;
  chkHideSingleTab.Caption := dlgHideSingleTabInNotebook;
  chkShowNumbers.Caption := dlgTabNumbersNotebook;
  chkShowCloseBtn.Caption := dlgCloseButtonsNotebook;
  chkUseTabHistory.Caption := dlgUseTabsHistory;
  chkShowFileNameInCaption.Caption := dlgShowFileNameInCaption;
  chkMultiLine.Caption := dlgSourceEditTabMultiLine;
  EditorTabPositionCheckBox.Items.Add(lisNotebookTabPosTop);
  EditorTabPositionCheckBox.Items.Add(lisNotebookTabPosBottom);
  EditorTabPositionCheckBox.Items.Add(lisNotebookTabPosLeft);
  EditorTabPositionCheckBox.Items.Add(lisNotebookTabPosRight);
  EditorTabPositionLabel.Caption := dlgNotebookTabPos;
  TabFontGroupBox.Caption := dlgDefaultTabFont;
  DisableAntialiasingCheckBox.Caption := dlgDisableAntialiasing;
  cgCloseOther.Caption := dlgMiddleTabCloseOtherPagesMod;
  cgCloseRight.Caption := dlgMiddleTabCloseRightPagesMod;
end;

procedure TEditorMultiWindowOptionsFrame.ReadSettings(AOptions: TAbstractIDEOptions);
const
  TabPosToIndex : Array [TTabPosition] of Integer = (0, 1, 2, 3);
var
  i: Integer;
begin
  with TEditorOptions(AOptions) do begin
    chkHideSingleTab.Checked := HideSingleTabInWindow;
    chkShowNumbers.Checked := ShowTabNumbers;
    chkShowCloseBtn.Checked := ShowTabCloseButtons and chkShowCloseBtn.Enabled;
    chkUseTabHistory.Checked := UseTabHistory;
    cgCloseOther.Checked[0] := ssShift in MiddleTabClickClosesOthersModifier;
    cgCloseOther.Checked[1] := ssCtrl in MiddleTabClickClosesOthersModifier;
    cgCloseOther.Checked[2] := ssAlt in MiddleTabClickClosesOthersModifier;
    cgCloseRight.Checked[0] := ssShift in MiddleTabClickClosesToRightModifier;
    cgCloseRight.Checked[1] := ssCtrl in MiddleTabClickClosesToRightModifier;
    cgCloseRight.Checked[2] := ssAlt in MiddleTabClickClosesToRightModifier;

    chkShowFileNameInCaption.Checked := ShowFileNameInCaption;
    chkMultiLine.Checked := MultiLineTab;
    EditorTabPositionCheckBox.ItemIndex := TabPosToIndex[TabPosition];

    SetComboBoxText(TabFontComboBox, TabFont, cstCaseInsensitive);
    SetTabFontSizeSpinEditValue(TabFontSize);
    DisableAntialiasingCheckBox.Checked := TabFontDisableAntialiasing;
  end;
  FMultiWinEditAccessOrder.Assign(TEditorOptions(AOptions).MultiWinEditAccessOrder);

  radioAccessOrderEdit.Checked := FMultiWinEditAccessOrder.SearchOrder = eoeaOrderByEditFocus;
  radioAccessOrderWin.Checked := FMultiWinEditAccessOrder.SearchOrder = eoeaOrderByWindowFocus;

  listAccessType.Clear;
  for i := 0 to FMultiWinEditAccessOrder.Count - 1 do begin
    listAccessType.Items.Add(FMultiWinEditAccessOrder[i].Caption);
    listAccessType.Checked[i] := FMultiWinEditAccessOrder[i].Enabled;
  end;
  listAccessType.ItemIndex := 0;
  listAccessTypeClickCheck(nil);
end;

procedure TEditorMultiWindowOptionsFrame.WriteSettings(AOptions: TAbstractIDEOptions);
const
  TabIndexToPos : Array [0..3] of TTabPosition = (tpTop, tpBottom, tpLeft, tpRight);
begin
  TEditorOptions(AOptions).MultiWinEditAccessOrder.Assign(FMultiWinEditAccessOrder);
  with TEditorOptions(AOptions) do begin
    HideSingleTabInWindow := chkHideSingleTab.Checked;
    ShowTabNumbers := chkShowNumbers.Checked;
    ShowTabCloseButtons := chkShowCloseBtn.Checked;
    UseTabHistory := chkUseTabHistory.Checked;

    MiddleTabClickClosesOthersModifier := [];
    if cgCloseOther.Checked[0] then MiddleTabClickClosesOthersModifier := MiddleTabClickClosesOthersModifier + [ssShift];
    if cgCloseOther.Checked[1] then MiddleTabClickClosesOthersModifier := MiddleTabClickClosesOthersModifier + [ssCtrl];
    if cgCloseOther.Checked[2] then MiddleTabClickClosesOthersModifier := MiddleTabClickClosesOthersModifier + [ssAlt];
    MiddleTabClickClosesToRightModifier := [];
    if cgCloseRight.Checked[0] then MiddleTabClickClosesToRightModifier := MiddleTabClickClosesToRightModifier + [ssShift];
    if cgCloseRight.Checked[1] then MiddleTabClickClosesToRightModifier := MiddleTabClickClosesToRightModifier + [ssCtrl];
    if cgCloseRight.Checked[2] then MiddleTabClickClosesToRightModifier := MiddleTabClickClosesToRightModifier + [ssAlt];

    ShowFileNameInCaption := chkShowFileNameInCaption.Checked;
    MultiLineTab := chkMultiLine.Checked;
    TabPosition := TabIndexToPos[EditorTabPositionCheckBox.ItemIndex];

    TabFont := TabFontComboBox.Text;
    TabFontSize := TabFontSizeSpinEdit.Value;
    TabFontDisableAntialiasing := DisableAntialiasingCheckBox.Checked;
  end;
end;

class function TEditorMultiWindowOptionsFrame.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result := TEditorOptions;
end;

initialization
  RegisterIDEOptionsEditor(GroupEditor, TEditorMultiWindowOptionsFrame, EdtOptionsMultiWindow);
end.

