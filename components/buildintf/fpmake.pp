{
   File generated automatically by Lazarus Package Manager

   fpmake.pp for BuildIntf 1.0

   This file was generated on 12.03.2024
}

{$ifndef ALLPACKAGES} 
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;
{$endif ALLPACKAGES}

procedure add_BuildIntf(const ADirectory: string);

var
  P : TPackage;
  T : TTarget;
  D : TDependency;

begin
  with Installer do
    begin
    P:=AddPackage('buildintf');
    P.Version:='1.0.0-0';

    P.Directory:=ADirectory;

    P.Author:='Lazarus';
    P.License:='Modified LGPL2';
    P.Description:='BuildIntf - Non-GUI interface units.';

    P.Flags.Add('LazarusDsgnPkg');

    D := P.Dependencies.Add('lazutils');
    D := P.Dependencies.Add('fcl');
    P.Options.Add('-MObjFPC');
    P.Options.Add('-Scghi');
    P.Options.Add('-O1');
    P.Options.Add('-g');
    P.Options.Add('-gl');
    P.Options.Add('-l');
    P.Options.Add('-vewnhibq');
    P.UnitPath.Add('.');
    T:=P.Targets.AddUnit('buildintf.pas');
    t.Dependencies.AddUnit('baseideintf');
    t.Dependencies.AddUnit('buildstrconsts');
    t.Dependencies.AddUnit('componentreg');
    t.Dependencies.AddUnit('compoptsintf');
    t.Dependencies.AddUnit('fppkgintf');
    t.Dependencies.AddUnit('ideexterntoolintf');
    t.Dependencies.AddUnit('ideoptionsintf');
    t.Dependencies.AddUnit('lazmsgworker');
    t.Dependencies.AddUnit('macrodefintf');
    t.Dependencies.AddUnit('macrointf');
    t.Dependencies.AddUnit('newitemintf');
    t.Dependencies.AddUnit('packagedependencyintf');
    t.Dependencies.AddUnit('packageintf');
    t.Dependencies.AddUnit('packagelinkintf');
    t.Dependencies.AddUnit('projectintf');
    t.Dependencies.AddUnit('projectresourcesintf');
    t.Dependencies.AddUnit('projpackintf');
    t.Dependencies.AddUnit('publishmoduleintf');

    T:=P.Targets.AddUnit('baseideintf.pas');
    T:=P.Targets.AddUnit('buildstrconsts.pas');
    T:=P.Targets.AddUnit('componentreg.pas');
    T:=P.Targets.AddUnit('compoptsintf.pas');
    T:=P.Targets.AddUnit('fppkgintf.pas');
    T:=P.Targets.AddUnit('ideexterntoolintf.pas');
    T:=P.Targets.AddUnit('ideoptionsintf.pas');
    T:=P.Targets.AddUnit('lazmsgworker.pas');
    T:=P.Targets.AddUnit('macrodefintf.pas');
    T:=P.Targets.AddUnit('macrointf.pas');
    T:=P.Targets.AddUnit('newitemintf.pas');
    T:=P.Targets.AddUnit('packagedependencyintf.pas');
    T:=P.Targets.AddUnit('packageintf.pas');
    T:=P.Targets.AddUnit('packagelinkintf.pas');
    T:=P.Targets.AddUnit('projectintf.pas');
    T:=P.Targets.AddUnit('projectresourcesintf.pas');
    T:=P.Targets.AddUnit('projpackintf.pas');
    T:=P.Targets.AddUnit('publishmoduleintf.pas');

    // copy the compiled file, so the IDE knows how the package was compiled
    P.Sources.AddSrc('buildintf.compiled');
    P.InstallFiles.Add('buildintf.compiled',AllOSes,'$(unitinstalldir)');

    end;
end;

{$ifndef ALLPACKAGES}
begin
  add_BuildIntf('');
  Installer.Run;
end.
{$endif ALLPACKAGES}
