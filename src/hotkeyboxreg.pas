unit HotKeyBoxReg;

{$mode objfpc}{$H+}
// Copyright (c) 2026 Tony Stone. 0BSD; see LICENSE.

interface

procedure Register;

implementation

uses Classes, LResources, HotKeyBox;

procedure Register;
begin
  RegisterComponents('Common Controls', [THotKey]);
end;

initialization
  {$I hotkeyboxpalette.lrs}
end.
