{
   File generated automatically by Lazarus Package Manager
   Created with the Fppkgpackagemanager package installed

   fpmake.pp for IdeDebugger 0.0.1

   This file was generated on 08/01/2022
}

{$ifndef ALLPACKAGES} 
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;
{$endif ALLPACKAGES}

procedure add_IdeDebugger(const ADirectory: string);

var
  P : TPackage;
  T : TTarget;
  D : TDependency;

begin
  with Installer do
    begin
    P:=AddPackage('idedebugger');
    P.Version:='0.0.1-0';

    P.Directory:=ADirectory;

    P.Author:='Lazarus Team';
    P.License:='GPL-2';
    P.Description:='GUI Debugger Frontend for the IDE';

    P.Flags.Add('LazarusDsgnPkg');

    D := P.Dependencies.Add('debuggerintf');
    D := P.Dependencies.Add('fcl');
    P.Options.Add('-MObjFPC');
    P.Options.Add('-Scghi');
    P.Options.Add('-O1');
    P.Options.Add('-g');
    P.Options.Add('-gl');
    P.Options.Add('-l');
    P.Options.Add('-vewnhibq');
    P.UnitPath.Add('.');
    T:=P.Targets.AddUnit('idedebuggerpackage.pas');
    D := T.Dependencies.AddUnit('IdeDebuggerBase');
    T := P.Targets.AddImplicitUnit('idedebuggerbase.pas');

    // copy the compiled file, so the IDE knows how the package was compiled
    P.Sources.AddSrc('IdeDebugger.compiled');
    P.InstallFiles.Add('IdeDebugger.compiled',AllOSes,'$(unitinstalldir)');

    end;
end;

{$ifndef ALLPACKAGES}
begin
  add_IdeDebugger('');
  Installer.Run;
end.
{$endif ALLPACKAGES}
