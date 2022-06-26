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

  Author: Mattias Gaertner

  Abstract:
    Dialog to choose an IDE keymapping scheme.
}
unit KeymapSchemeDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, KeyMapping, LazarusIDEStrConsts, ButtonPanel,
  IDEHelpIntf;

type

  { TChooseKeySchemeDlg }

  TChooseKeySchemeDlg = class(TForm)
    ButtonPanel: TButtonPanel;
    NoteLabel: TLABEL;
    SchemeRadiogroup: TRADIOGROUP;
    procedure ChooseKeySchemeDlgCREATE(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
  private
    function GetKeymapScheme: string;
    procedure SetKeymapScheme(const AValue: string);
    procedure UpdateColumns;
  public
    property KeymapScheme: string read GetKeymapScheme write SetKeymapScheme;// untranslated
  end;

function ShowChooseKeySchemeDialog(var NewScheme: string): TModalResult;

implementation

{$R *.lfm}

function ShowChooseKeySchemeDialog(var NewScheme: string): TModalResult;
var
  ChooseKeySchemeDlg: TChooseKeySchemeDlg;
begin
  ChooseKeySchemeDlg:=TChooseKeySchemeDlg.Create(nil);
  ChooseKeySchemeDlg.KeymapScheme:=NewScheme;
  Result:=ChooseKeySchemeDlg.ShowModal;
  if Result=mrOk then
    NewScheme:=ChooseKeySchemeDlg.KeymapScheme;
  ChooseKeySchemeDlg.Free;
end;

{ TChooseKeySchemeDlg }

procedure TChooseKeySchemeDlg.ChooseKeySchemeDlgCREATE(Sender: TObject);
var
  i : integer;
begin
  Caption:=lisKMChooseKeymappingScheme;
  NoteLabel.Caption:=lisKMNoteAllKeysWillBeSetToTheValuesOfTheChosenScheme;
  SchemeRadiogroup.Caption:=lisKMKeymappingScheme;

  ButtonPanel.HelpButton.OnClick := @HelpButtonClick;

  with SchemeRadiogroup.Items do begin
    Clear;
    // keep order of TKeyMapScheme
    Add(lisKMLazarusDefault);
    Add(lisKMClassic);
    Add(lisKMMacOSXApple);
    Add(lisKMMacOSXLaz);
    Add(lisKMDefaultToOSX);
    // do not add custom
  end;
  // searching configuration files on the main thread is not really good
  LoadCustomKeySchemas;

  for i:=0 to CustomKeySchemas.Count-1 do
    SchemeRadiogroup.Items.Add(CustomKeySchemas[i]);
  UpdateColumns;
end;

procedure TChooseKeySchemeDlg.HelpButtonClick(Sender: TObject);
begin
  LazarusHelp.ShowHelpForIDEControl(Self);
end;

function TChooseKeySchemeDlg.GetKeymapScheme: string;
begin
  if SchemeRadiogroup.ItemIndex<0 then
    Result:=KeyMapSchemeNames[kmsLazarus]
  else if SchemeRadiogroup.ItemIndex<ord(kmsCustom) then
    Result:=KeyMapSchemeNames[TKeyMapScheme(SchemeRadiogroup.ItemIndex)]
  else
    Result:=SchemeRadiogroup.Items[SchemeRadiogroup.ItemIndex];
end;

procedure TChooseKeySchemeDlg.SetKeymapScheme(const AValue: string);
var
  kms: TKeyMapScheme;
  i : integer;
begin
  kms:=KeySchemeNameToSchemeType(AValue);
  if kms=kmsCustom then begin
    i := CustomKeySchemas.IndexOf(AValue);
    if i < 0 then begin
      if (SchemeRadiogroup.Items.IndexOf(AValue)<0) then
        i := SchemeRadiogroup.Items.Add(AValue)
      else
        i := SchemeRadiogroup.Items.Count-1;
    end else
      i := i + Ord(kmsCustom);
  end else
    i := ord(kms);
  SchemeRadiogroup.ItemIndex:=i;
  UpdateColumns;
end;

procedure TChooseKeySchemeDlg.UpdateColumns;
begin
  if (SchemeRadiogroup.Items.Count>8) then
    SchemeRadiogroup.Columns := 2
  else
    SchemeRadiogroup.Columns := 1;
end;

end.

