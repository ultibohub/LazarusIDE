{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazDebuggerFp;

{$warn 5023 off : no warning about unused units}
interface

uses
  FpDebugDebugger, FpDebugDebuggerUtils, FpDebugDebuggerWorkThreads, 
  FpDebugValueConvertors, FpDebugDebuggerBase, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('FpDebugDebugger', @FpDebugDebugger.Register);
end;

initialization
  RegisterPackage('LazDebuggerFp', @Register);
end.
