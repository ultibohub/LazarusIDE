{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit AnchorDockingDsgn;

{$warn 5023 off : no warning about unused units}
interface

uses
  RegisterAnchorDocking, AnchorDesktopOptions, AnchorDockDsgnInitialSetupFrame, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('RegisterAnchorDocking', @RegisterAnchorDocking.Register);
end;

initialization
  RegisterPackage('AnchorDockingDsgn', @Register);
end.
