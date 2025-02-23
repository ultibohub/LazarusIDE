{
 *****************************************************************************
  This file is part of the EducationLaz package

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract:
    Dialog to setup the education package.
}
unit EduOptionsDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ButtonPanel, ComCtrls, ExtCtrls;

type

  { TEduOptionsDialog }

  TEduOptionsDialog = class(TForm)
    ButtonPanel1: TButtonPanel;
    FramePanel: TPanel;
    FramesTreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  EduOptionsDialog: TEduOptionsDialog;

procedure Register;

implementation

procedure Register;
begin

end;

{ TEduOptionsDialog }

procedure TEduOptionsDialog.FormCreate(Sender: TObject);
begin
  ButtonPanel1.OKButton.OnClick:=@ButtonPanel1Click;
end;

{$R *.lfm}

end.
