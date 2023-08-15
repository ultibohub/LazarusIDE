{ Copyright (C) 2007 Vincent Snijders

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
unit TestGlobals;

{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry,
  classes, sysutils, process;

var
  Compiler: string;
  PrimaryConfigPath: string;
  BugsTestSuite: TTestSuite;
  LazUtilsTestSuite: TTestSuite;
  LCLTestSuite: TTestSuite;
  IDEIntfTestSuite: TTestSuite;
  SemiAutoTestSuite: TTestSuite;

// reads the output from a process and puts it in a memory stream
function ReadOutput(AProcess:TProcess): TStringList;

procedure AddToBugsTestSuite(ATest: TTest);
procedure AddToLazUtilsTestSuite(ATestClass: TClass);
procedure AddToLCLTestSuite(ATestClass: TClass);
procedure AddToIDEIntfTestSuite(ATestClass: TClass);
procedure AddToSemiAutoTestSuite(ATestClass: TClass);

implementation

const
  // Maximal number of bytes read from stream
  READ_BYTES = 4096;
  // Maximal run time for a test program
  TIME_OUT = 120;

function ReadOutput(AProcess:TProcess): TStringList;
var
  BytesRead: Integer;
  n: Integer;
  EndTime: TDateTime;
  OutputStream: TMemoryStream;
begin
  OutputStream := TMemoryStream.Create;
  BytesRead := 0;
  EndTime := Now + TIME_OUT / (24 * 60 * 60);
  while AProcess.Running and (Now<EndTime) do
  begin
    // make sure we have room
    OutputStream.SetSize(BytesRead + READ_BYTES);

    // try reading it
    if AProcess.Output.NumBytesAvailable>0 then begin
      n := AProcess.Output.Read((OutputStream.Memory + BytesRead)^, READ_BYTES);
      Inc(BytesRead, n)
    end
    else
      // no data, wait 100 ms
      Sleep(100);
  end;
  // read last part
  repeat
    // make sure we have room
    OutputStream.SetSize(BytesRead + READ_BYTES);
    // try reading it
    if AProcess.Output.NumBytesAvailable>0 then begin
      n := AProcess.Output.Read((OutputStream.Memory + BytesRead)^, READ_BYTES);
      Inc(BytesRead, n);
    end
    else
      n := 0;
  until n <= 0;
  OutputStream.SetSize(BytesRead);
  OutputStream.Position:=0;
  Result := TStringList.Create;
  Result.LoadFromStream(OutputStream);
  OutputStream.Free;
end;

procedure AddToBugsTestSuite(ATest: TTest);
begin
  BugsTestSuite.AddTest(ATest);
end;

procedure AddToLazUtilsTestSuite(ATestClass: TClass);
begin
  LazUtilsTestSuite.AddTestSuiteFromClass(ATestClass);
end;

procedure AddToLCLTestSuite(ATestClass: TClass);
begin
  LCLTestSuite.AddTestSuiteFromClass(ATestClass);
end;

procedure AddToIDEIntfTestSuite(ATestClass: TClass);
begin
  IDEIntfTestSuite.AddTestSuiteFromClass(ATestClass);
end;

procedure AddToSemiAutoTestSuite(ATestClass: TClass);
begin
  SemiAutoTestSuite.AddTestSuiteFromClass(ATestClass);
end;

initialization
  GetTestRegistry.TestName := 'All tests';
  BugsTestSuite := TTestSuite.Create('Bugs');
  GetTestRegistry.AddTest(BugsTestSuite);
  LazUtilsTestSuite := TTestSuite.Create('LazUtils tests');
  GetTestRegistry.AddTest(LazUtilsTestSuite);
  LCLTestSuite := TTestSuite.Create('LCL tests');
  GetTestRegistry.AddTest(LCLTestSuite);
  IDEIntfTestSuite := TTestSuite.Create('IDEIntf tests');
  GetTestRegistry.AddTest(IDEIntfTestSuite);
  SemiAutoTestSuite := TTestSuite.Create('Semi Automatic tests');
  GetTestRegistry.AddTest(SemiAutoTestSuite);

end.

