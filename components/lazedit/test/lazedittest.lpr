program LazEditTest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, TestTextMateGrammar;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

