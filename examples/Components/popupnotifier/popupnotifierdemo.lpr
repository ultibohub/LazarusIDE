program popupnotifierdemo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { add your units here }, unit1;

begin
  Application.Title:='PopupNotifierDemo';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

