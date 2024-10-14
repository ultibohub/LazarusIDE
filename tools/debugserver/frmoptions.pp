{ Debug server options form

  Copyright (C) 2009 Michael Van Canneyt (michael@freepascal.org)

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.
}
unit frmOptions;

{$mode objfpc}{$H+}

interface

uses
  Forms, ButtonPanel, StdCtrls, Classes;

type

  { TOptionsForm }

  TOptionsForm = class(TForm)
    ButtonPanel:TButtonPanel;
    CBNewVisible: TCheckBox;
    CBCleanLogOnNewProcess: TCheckBox;
    CBShowOnStartUp: TCheckBox;
    CBShowOnMessage: TCheckBox;
    CBNewAtBottom: TCheckBox;
    GBWindow: TGroupBox;
    GBMessages: TGroupBox;
    procedure FormActivate(Sender:TObject);
  private
    FActivated: boolean;
    function GetB(AIndex: integer): Boolean;
    function GetCB(AIndex: Integer): TCheckBox;
    procedure SetB(AIndex: integer; const AValue: Boolean);
  public
    Property ShowOnStartup : Boolean Index 0 Read GetB Write SetB;
    Property ShowOnMessage : Boolean Index 1 Read GetB Write SetB;
    Property NewMessageAtBottom : Boolean Index 2 Read GetB Write SetB;
    Property NewMessageVisible: Boolean Index 3 Read GetB Write SetB;
    Property CleanLogOnNewProcess: Boolean Index 4 Read GetB Write SetB;
  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.lfm}

{ TOptionsForm }

procedure TOptionsForm.FormActivate(Sender:TObject);
begin
  if not FActivated then
  begin
    FActivated := true;
    AutoSize := false;
    ClientHeight := GBMessages.Top + GBMessages.Height +
      GBMessages.BorderSpacing.Around + GBMessages.BorderSpacing.Bottom +
      ButtonPanel.Height;
    ClientWidth := GBMessages.Left + GBMessages.Width + GBMessages.BorderSpacing.Around;
  end;
end;

function TOptionsForm.GetCB(AIndex : Integer) : TCheckBox;
begin
  Case AIndex of
    0 : Result:=CBShowOnStartUp;
    1 : Result:=CBShowOnMessage;
    2 : Result:=CBNewAtBottom;
    3 : Result:=CBNewVisible;
    4 : Result:=CBCleanLogOnNewProcess;
  end;
end;

function TOptionsForm.GetB(AIndex: integer): Boolean;
begin
  Result:=GetCb(AIndex).Checked;
end;

procedure TOptionsForm.SetB(AIndex: integer; const AValue: Boolean);
begin
  GetCb(AIndex).Checked:=AValue;
end;

end.

