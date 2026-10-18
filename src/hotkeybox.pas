{ HotKeyBox: Delphi's THotKey for Lazarus, a box that takes a key
  combination and shows it as Shift+Ctrl+F9.  The control draws itself and
  depends on the LCL alone.

  Copyright (c) 2026 Tony Stone. 0BSD; see LICENSE. }
unit HotKeyBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, Types,
  // LCL
  LCLType, LCLIntf, LCLProc, LCLStrConsts, Controls, Graphics, StdCtrls, Themes;

type
  THKModifier = (hkShift, hkCtrl, hkAlt, hkExt);
  THKModifiers = set of THKModifier;
  THKInvalidKey = (hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl, hcShiftAlt,
    hcCtrlAlt, hcShiftCtrlAlt);
  THKInvalidKeys = set of THKInvalidKey;

  { TCustomHotKey }

  TCustomHotKey = class(TCustomControl)
  private
    FHotKey: TShortCut;
    FInvalidKeys: THKInvalidKeys;
    FModifiers: THKModifiers;
    FHeld: TShortCut;  // modifier bits down with no key yet, shown as 'Ctrl+'
    FOnChange: TNotifyEvent;
    function GetText: string;
    procedure SetHotKey(AValue: TShortCut);
    procedure SetInvalidKeys(AValue: THKInvalidKeys);
    procedure SetModifiers(AValue: THKModifiers);
    function ApplyRules(AShortCut: TShortCut): TShortCut;
    procedure PlaceCaret(const R: TRect; const S: string);
  protected
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure KeyUp(var Key: word; Shift: TShiftState); override;
    procedure UTF8KeyPress(var UTF8Key: TUTF8Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Paint; override;
    procedure Change; virtual;
    class function GetControlClassDefaultSize: TSize; override;
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
    // Published and documented in THotKey.
    property AutoSize default True;
    property HotKey: TShortCut read FHotKey write SetHotKey default $0041;
    property InvalidKeys: THKInvalidKeys read FInvalidKeys write SetInvalidKeys default [hcNone, hcShift];
    property Modifiers: THKModifiers read FModifiers write SetModifiers default [hkAlt];
    property TabStop default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AOwner: TComponent); override;
    // What the box shows: ShortCutToText of HotKey with the rules applied,
    // 'None' for 0, or the held modifiers with a trailing '+', as 'Ctrl+'.
    property Text: string read GetText;
  end;

  { THotKey }

  THotKey = class(TCustomHotKey)
  published
    // Places the box against an edge of its parent; alNone keeps Left and Top.
    property Align;
    // The parent edges the box keeps its distance to when the parent resizes.
    property Anchors;
    // Sets the height from the font, as a TEdit does, so the two line up.
    // The width stays as given.  Default True.
    property AutoSize;
    // A right-to-left mode right-aligns the text.
    property BiDiMode;
    // Space around the box, to its neighbors and to the parent's edges.
    property BorderSpacing;
    // Space between the border and the text, in pixels at 96 DPI.
    property BorderWidth;
    // Background.  clDefault is the edit box background of the widgetset.
    property Color;
    // Smallest and largest width and height the box may take.
    property Constraints;
    // False grays the text; the box then takes no focus and no keys.
    property Enabled;
    // The font of the text; with AutoSize the height follows it.
    property Font;
    // Tooltip text, shown when ShowHint is True.
    property Hint;
    // The key combination, a TShortCut as TMenuItem.ShortCut takes it.  0 is
    // no key.  Set in code it is stored as given; the InvalidKeys rules
    // apply to key presses only.  Default $0041, A, shown as Alt+A.
    property HotKey;
    // Modifier combinations the user may not choose; hcNone is a key with no
    // modifier.  A press of one of these gets Modifiers added.
    // Default [hcNone, hcShift].
    property InvalidKeys;
    // The modifiers added to a combination in InvalidKeys.  Default [hkAlt],
    // so A alone is stored as Alt+A.  hkExt is accepted for Delphi forms and
    // ignored.
    property Modifiers;
    // True takes BiDiMode from the parent.
    property ParentBiDiMode;
    // True takes Color from the parent.
    property ParentColor;
    // True takes Font from the parent.
    property ParentFont;
    // True takes ShowHint from the parent.
    property ParentShowHint;
    // The menu shown on a right click.
    property PopupMenu;
    // Shows Hint as a tooltip when the mouse rests on the box.
    property ShowHint;
    // The box's place in the form's Tab order.
    property TabOrder;
    // Tab moves the focus to the box.  Default True.
    property TabStop;
    // False hides the box.
    property Visible;
    // Fires once each time HotKey changes: from a key press, from Backspace
    // or Delete clearing it, or from code setting a different value.  Does
    // not fire while the form loads.
    property OnChange;
    // Fires before PopupMenu is shown; set Handled to True to show none.
    property OnContextPopup;
    // Fires when the box receives the focus.
    property OnEnter;
    // Fires when the box loses the focus.
    property OnExit;
    // Fires before the box handles the key; set Key to 0 to keep a key out.
    property OnKeyDown;
    // Fires for a character key; the box itself types nothing.
    property OnKeyPress;
    // Fires when a key is released.
    property OnKeyUp;
    // Fires when a mouse button is pressed over the box.
    property OnMouseDown;
    // Fires when the mouse moves onto the box.
    property OnMouseEnter;
    // Fires when the mouse leaves the box.
    property OnMouseLeave;
    // Fires when the mouse moves over the box.
    property OnMouseMove;
    // Fires when a mouse button is released over the box.
    property OnMouseUp;
    // Fires when the mouse wheel turns over the box.
    property OnMouseWheel;
    // Fires when the mouse wheel turns down over the box.
    property OnMouseWheelDown;
    // Fires when the mouse wheel turns up over the box.
    property OnMouseWheelUp;
    // Fires after the box changes size.
    property OnResize;
    // Fires for a character key as UTF-8; the box itself types nothing.
    property OnUTF8KeyPress;
  end;

resourcestring
  SHotKeyNone = 'None';

implementation

const
  // InvalidKeys entry for the modifier bits of a TShortCut shifted down
  // to 0..7: bit 0 Shift, bit 1 Ctrl, bit 2 Alt.
  Combination: array[0..7] of THKInvalidKey = (hcNone, hcShift, hcCtrl,
    hcShiftCtrl, hcAlt, hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt);
  ModifierBits = scShift or scCtrl or scAlt;
  ModifierKeys = [ssShift, ssCtrl, ssAlt];

// The modifier a modifier key stands for; [] for any other key.  Cocoa
// sends the left and right codes, the other widgetsets the plain ones.
function ModifierOf(Key: word): TShiftState;
begin
  case Key of
    VK_SHIFT, VK_LSHIFT, VK_RSHIFT: Result := [ssShift];
    VK_CONTROL, VK_LCONTROL, VK_RCONTROL: Result := [ssCtrl];
    VK_MENU, VK_LMENU, VK_RMENU: Result := [ssAlt];
    else
      Result := [];
  end;
end;

// 'Shift+Ctrl+' in ShortCutToText's spelling and order; ShortCutToText
// itself gives nothing useful without a key.
function ModifierNames(Bits: TShortCut): string;
begin
  Result := '';
  if Bits and scShift <> 0 then Result := Result + SmkcShift;
  if Bits and scCtrl <> 0 then Result := Result + SmkcCtrl;
  if Bits and scAlt <> 0 then Result := Result + SmkcAlt;
end;

{ TCustomHotKey }

constructor TCustomHotKey.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption];
  FHotKey := $0041;
  FInvalidKeys := [hcNone, hcShift];
  FModifiers := [hkAlt];
  TabStop := True;
  AutoSize := True;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, CX, CY);
end;

class function TCustomHotKey.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 121;
  Result.CY := 21;
end;

function TCustomHotKey.GetText: string;
begin
  if FHeld <> 0 then Result := ModifierNames(FHeld)
  else if FHotKey = 0 then Result := SHotKeyNone
  else
    Result := ShortCutToText(ApplyRules(FHotKey));
end;

function TCustomHotKey.ApplyRules(AShortCut: TShortCut): TShortCut;
var
  Added: TShortCut = 0;
begin
  if Combination[(AShortCut and ModifierBits) shr 13] in FInvalidKeys then
  begin
    if hkShift in FModifiers then Added := Added or scShift;
    if hkCtrl in FModifiers then Added := Added or scCtrl;
    if hkAlt in FModifiers then Added := Added or scAlt;
  end;
  Result := AShortCut or Added;
end;

procedure TCustomHotKey.SetHotKey(AValue: TShortCut);
begin
  if FHotKey = AValue then Exit;
  FHotKey := AValue;
  Invalidate;
  if not (csLoading in ComponentState) then Change;
end;

procedure TCustomHotKey.SetInvalidKeys(AValue: THKInvalidKeys);
begin
  if FInvalidKeys = AValue then Exit;
  FInvalidKeys := AValue;
  Invalidate;
end;

procedure TCustomHotKey.SetModifiers(AValue: THKModifiers);
begin
  if FModifiers = AValue then Exit;
  FModifiers := AValue;
  Invalidate;
end;

procedure TCustomHotKey.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TCustomHotKey.KeyDown(var Key: word; Shift: TShiftState);
var
  Mods: TShiftState;
begin
  inherited KeyDown(Key, Shift);
  if Key = 0 then Exit;
  // the shift state of a modifier's own press may not include it yet
  Mods := Shift * ModifierKeys + ModifierOf(Key);
  // the form keeps its focus keys and its default and cancel buttons
  case Key of
    VK_TAB: if Mods - [ssShift] = [] then Exit;
    VK_RETURN, VK_ESCAPE: if Mods = [] then Exit;
  end;
  if ModifierOf(Key) <> [] then FHeld := KeyToShortCut(0, Mods)
  else
  begin
    FHeld := 0;
    if (Mods = []) and ((Key = VK_BACK) or (Key = VK_DELETE)) then HotKey := 0
    else if (Mods <> []) or (Key <> VK_SPACE) then HotKey := ApplyRules(KeyToShortCut(Key, Mods));
  end;
  Key := 0;
  Invalidate;
end;

procedure TCustomHotKey.KeyUp(var Key: word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if FHeld = 0 then Exit;
  // the shift state of a release may still include the released modifier
  FHeld := KeyToShortCut(0, Shift * ModifierKeys - ModifierOf(Key));
  Invalidate;
end;

procedure TCustomHotKey.UTF8KeyPress(var UTF8Key: TUTF8Char);
begin
  inherited UTF8KeyPress(UTF8Key);
  UTF8Key := ''; // the key code from KeyDown is the value; nothing is typed
end;

procedure TCustomHotKey.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and CanSetFocus then SetFocus;
end;

procedure TCustomHotKey.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomHotKey.DoExit;
begin
  inherited DoExit;
  FHeld := 0;
  if HandleAllocated then DestroyCaret(Handle);
  Invalidate;
end;

// A text caret after the text, as in an edit box.
procedure TCustomHotKey.PlaceCaret(const R: TRect; const S: string);
var
  H, X: integer;
begin
  H := Canvas.TextHeight(S);
  if UseRightToLeftAlignment then X := R.Right - Canvas.TextWidth(S) - 1
  else
    X := R.Left + Canvas.TextWidth(S);
  CreateCaret(Handle, 0, 1, H);
  SetCaretPosEx(Handle, X, (R.Top + R.Bottom - H) div 2);
  ShowCaret(Handle);
end;

procedure TCustomHotKey.Paint;
var
  R, Inner: TRect;
  Details: TThemedElementDetails;
  Style: TTextStyle;
  S: string;
begin
  R := ClientRect;
  if not Enabled then Details := ThemeServices.GetElementDetails(teEditTextDisabled)
  else if Focused then Details := ThemeServices.GetElementDetails(teEditTextFocused)
  else
    Details := ThemeServices.GetElementDetails(teEditTextNormal);
  if ThemeServices.ThemesEnabled then
  begin
    ThemeServices.DrawElement(Canvas.Handle, Details, R);
    Inner := ThemeServices.ContentRect(Canvas.Handle, Details, R);
    if Color <> clDefault then
    begin
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Inner);
    end;
  end
  else
  begin
    // no theme, as on Windows classic
    if Color <> clDefault then Canvas.Brush.Color := Color
    else if Enabled then Canvas.Brush.Color := clWindow
    else
      Canvas.Brush.Color := clBtnFace;
    Canvas.Pen.Color := clWindowFrame;
    Canvas.Rectangle(R);
    Inner := R;
    InflateRect(Inner, -1, -1);
  end;
  // BorderWidth, then the edit box's own text margin
  InflateRect(Inner, -BorderWidth - Scale96ToFont(4), -BorderWidth);
  S := Text;
  Style := Canvas.TextStyle;
  Style.Layout := tlCenter;
  Style.SingleLine := True;
  Style.Clipping := True;
  Style.Opaque := False;
  Style.RightToLeft := UseRightToLeftReading;
  if UseRightToLeftAlignment then Style.Alignment := taRightJustify
  else
    Style.Alignment := taLeftJustify;
  if not Enabled then Canvas.Font.Color := clGrayText
  else if Font.Color = clDefault then Canvas.Font.Color := GetDefaultColor(dctFont)
  else
    Canvas.Font.Color := Font.Color;
  Canvas.TextRect(Inner, Inner.Left, Inner.Top, S, Style);
  if Focused then PlaceCaret(Inner, S);
end;

procedure TCustomHotKey.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
var
  Edit: TEdit;
  W: integer = 0;
begin
  // A TEdit with this font says how tall the widgetset makes an edit box.
  // Only the height is automatic, as with TEdit.
  PreferredWidth := 0;
  PreferredHeight := 0;
  Edit := TEdit.Create(nil);
  try
    Edit.Font := Font;
    Edit.Parent := Self;
    Edit.HandleNeeded;
    Edit.GetPreferredSize(W, PreferredHeight, False, WithThemeSpace);
  finally
    Edit.Free;
  end;
  if PreferredHeight > 0 then PreferredHeight := PreferredHeight + 2 * BorderWidth;
end;

end.
