{
   File generated automatically by Lazarus Package Manager

   fpmake.pp for LazEdit 0.0

   This file was generated on 11/09/2023
}

{$ifndef ALLPACKAGES} 
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;
{$endif ALLPACKAGES}

procedure add_LazEdit(const ADirectory: string);

var
  P : TPackage;
  T : TTarget;
  D : TDependency;

begin
  with Installer do
    begin
    P:=AddPackage('lazedit');
    P.Version:='<none>';

    P.Directory:=ADirectory;

    P.Author:='See each unit';
    P.License:='modified LGPL-2'#13#10'Additional licenses may be granted in each individual file. See the headers in each file.';
    P.Description:='Tools/Units to be used by SynEdit (or other editors)';

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
    T:=P.Targets.AddUnit('lazedit.pas');
    t.Dependencies.AddUnit('textmategrammar');
    t.Dependencies.AddUnit('xHyperLinksDecorator');
    t.Dependencies.AddUnit('xregexpr');
    t.Dependencies.AddUnit('xregexpr_unicodedata');

    T:=P.Targets.AddUnit('textmategrammar.pas');
    T:=P.Targets.AddUnit('xHyperLinksDecorator.pas');
    T:=P.Targets.AddUnit('xregexpr.pas');
    T:=P.Targets.AddUnit('xregexpr_unicodedata.pas');

    // copy the compiled file, so the IDE knows how the package was compiled
    P.Sources.AddSrc('lazedit.compiled');
    P.InstallFiles.Add('lazedit.compiled',AllOSes,'$(unitinstalldir)');

    end;
end;

{$ifndef ALLPACKAGES}
begin
  add_LazEdit('');
  Installer.Run;
end.
{$endif ALLPACKAGES}
