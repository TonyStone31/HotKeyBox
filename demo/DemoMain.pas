unit DemoMain;

{$mode objfpc}{$H+}
// Copyright (c) 2026 Tony Stone. 0BSD; see LICENSE.

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Menus, LCLProc, HotKeyBox;

type

  { TDemoForm }

  TDemoForm = class(TForm)
    AnyLabel: TLabel;
    FileMenu: TMenuItem;
    HotKey1: THotKey;
    HotKey2: THotKey;
    MainMenu1: TMainMenu;
    PickLabel: TLabel;
    SaveItem: TMenuItem;
    ValueLabel: TLabel;
    Value2Label: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
    procedure HotKey2Change(Sender: TObject);
    procedure SaveItemClick(Sender: TObject);
  end;

var
  DemoForm: TDemoForm;

implementation

{$R *.lfm}

{ TDemoForm }

procedure TDemoForm.FormCreate(Sender: TObject);
begin
  HotKey1Change(nil);
  HotKey2Change(nil);
end;

// The menu item takes the shortcut the user picked.
procedure TDemoForm.HotKey1Change(Sender: TObject);
begin
  SaveItem.ShortCut := HotKey1.HotKey;
  ValueLabel.Caption := 'HotKey = ' + ShortCutToText(HotKey1.HotKey) + '; File > Save now answers to it';
end;

procedure TDemoForm.HotKey2Change(Sender: TObject);
begin
  Value2Label.Caption := 'HotKey = ' + ShortCutToText(HotKey2.HotKey);
end;

procedure TDemoForm.SaveItemClick(Sender: TObject);
begin
  ValueLabel.Caption := 'Save ran with ' + ShortCutToText(SaveItem.ShortCut);
end;

end.
