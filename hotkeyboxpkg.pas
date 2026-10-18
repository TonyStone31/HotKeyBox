{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit HotKeyBoxPkg;

{$warn 5023 off : no warning about unused units}
interface

uses
  HotKeyBox, HotKeyBoxReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('HotKeyBoxReg', @HotKeyBoxReg.Register);
end;

initialization
  RegisterPackage('HotKeyBoxPkg', @Register);
end.
