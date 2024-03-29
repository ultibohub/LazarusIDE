program mssqlconnsample;

{
Demonstrates connecting to a Sybase ASE or MS SQL Server database.
Allows user to specify username/password, server, port and db in separate form.
See readme.txt for details on required drivers.
}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, dbform, dbloginform
  { you can add units after this };

begin
  Application.Title:='MSSQLConn';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

