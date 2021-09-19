unit opkman_colorsfrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ButtonPanel, Buttons,
  // IdeIntf
  IDEImagesIntf;

type

  { TColorsFrm }

  TColorsFrm = class(TForm)
    bp: TButtonPanel;
    CD: TColorDialog;
    lbLicense: TLabel;
    lbDescription: TLabel;
    lbName: TLabel;
    shName: TShape;
    shDescription: TShape;
    shLicense: TShape;
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure shNameMouseUp(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
  private
  public
    procedure LoadColors(AColList: TStringList);
  end;

var
  ColorsFrm: TColorsFrm;

implementation
uses opkman_const, opkman_options;

{$R *.lfm}

{ TColorsFrm }

procedure TColorsFrm.FormCreate(Sender: TObject);
begin
  Caption := rsColors_Caption;
  lbName.Caption := rsRepositoryDetailsFrm_lbName_Caption;
  lbDescription.Caption := rsMainFrm_VSTText_Description;
  lbLicense.Caption := rsMainFrm_VSTText_License;
  CD.Title := rsColors_CD_Title;
  bp.HelpButton.Caption := rsOptions_bpOptions_bHelp;
  IDEImages.AssignImage(bp.HelpButton, 'restore_defaults');
  bp.HelpButton.Kind := bkCustom;
  bp.HelpButton.Glyph.Clear;
end;

procedure TColorsFrm.HelpButtonClick(Sender: TObject);
var
  CL: TStringList;
begin
  CL := TStringList.Create;
  Options.GetDefaultColors(CL);
  shName.Brush.Color := StringToColor(CL.Strings[0]);
  shDescription.Brush.Color := StringToColor(CL.Strings[1]);
  shLicense.Brush.Color := StringToColor(CL.Strings[2]);
  CL.Free;
end;

procedure TColorsFrm.shNameMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if CD.Execute then
    (Sender as TShape).Brush.Color := CD.Color;
end;

procedure TColorsFrm.LoadColors(AColList: TStringList);
begin
  if AColList.Count <> HintColCnt then
    Options.GetDefaultColors(AColList);
  shName.Brush.Color := StringToColor(AColList.Strings[0]);
  shDescription.Brush.Color := StringToColor(AColList.Strings[1]);
  shLicense.Brush.Color := StringToColor(AColList.Strings[2]);
end;

end.

