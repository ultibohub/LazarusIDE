program fontenumeration;

{$mode objfpc}{$H+}

uses
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here }, mainunit;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='project1';
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

