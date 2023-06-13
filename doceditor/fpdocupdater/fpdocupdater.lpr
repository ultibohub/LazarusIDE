program FPDocUpdater;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  MainUnit, UnitMove, UnitSummary, FPDocFiles;

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormMove, FormMove);
  Application.CreateForm(TFormSummary, FormSummary);
  Application.Run;
end.

