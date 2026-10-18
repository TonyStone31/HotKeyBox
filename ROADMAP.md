# Roadmap

Status: the control, the package, the demo and the test suite exist and
pass on GTK3 (Linux, X11). Nothing has been checked on another widgetset
or operating system yet.

## Done

- [x] `TCustomHotKey` and `THotKey` with Delphi's types, property names
      and defaults; `Text` read-only; `OnChange`.
- [x] Key handling: every key with its modifiers, the `InvalidKeys` and
      `Modifiers` rules, modifier-alone display, Backspace and Delete to
      clear, Tab, Enter and Esc left to the form.
- [x] Streaming: a Delphi `.dfm` fragment loads; an `.lfm` round trip
      reads back the same; `hkExt` is kept and ignored.
- [x] Drawing through `ThemeServices` with a plain fallback; caret;
      disabled gray text; right-to-left alignment.
- [x] `AutoSize` height taken from a `TEdit` of the same font on the
      running widgetset, so the two line up.
- [x] Package `HotKeyBoxPkg` with the palette icon on Common Controls,
      documentation comments on every published property and event.
- [x] Demo with a menu item wired to the box, and `tests/run.sh` with the
      checks of the expected behavior.

## Next

- [ ] Look at the control beside a `TEdit` on Qt5, Win32 and Cocoa, and
      check the `teEditTextNormal` frame there; the Windows theme may
      want `teEditBorderNoScrollNormal` for the border.
- [ ] Cocoa: its `ThemeServices` reports themes enabled but draws no
      `teEdit` element, so the box is expected to show no frame there.
- [ ] Open the package in the IDE: palette icon, Object Inspector help
      for the published properties, the `TShortCut` editor on `HotKey`.
- [ ] A screenshot from a second widgetset beside the GTK3 one in the
      README.
- [ ] Load a `.dfm` through the IDE's Delphi converter end to end.

## Parked

- A headless test run: the LCL opens the display at startup on GTK3, so
  the checks need an X server; a nogui build of the LCL is not kept here.
- The macOS Command key: the LCL has `scMeta`, Delphi's `TShortCut` has
  not, so the box records Shift, Ctrl and Alt only.
- Mouse buttons, key sequences and `hkExt` as a real flag: no demonstrated
  need.
