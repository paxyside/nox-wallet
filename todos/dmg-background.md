# Custom DMG installer background

The mounted DMG window currently shows a plain Finder layout: app
icon on the left, Applications shortcut on the right, dark grey
background. Functional but generic — every polished macOS app
(Figma, Slack, Bear, Cursor, …) ships a branded installer window.

## What's needed

A PNG background that:
- Matches the Nox brand (dark surface, primary purple/blue accents,
  maybe the logo + name top-center)
- Includes a visual arrow / dotted line from the Nox icon position
  to the Applications shortcut to communicate "drag here"
- Renders crisp on Retina — author at 2× (so for the current
  600×400 window, design at 1200×800 and save as `bg@2x.png` or use
  HiDPI metadata)
- Lives in `ui/macos/installer/` (new directory, alongside the rest
  of the macOS-specific assets)

## Wire-up

Add to `Taskfile.yml` → `build:dmg` → the `create-dmg` invocation:

```sh
create-dmg \
  --volname "Nox" \
  --volicon "..." \
  --background "ui/macos/installer/background@2x.png" \   # <— new
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "Nox.app" 150 185 \
  --hide-extension "Nox.app" \
  --app-drop-link 450 185 \
  ...
```

Icon positions (`--icon` and `--app-drop-link` coords) need to line
up with whatever's drawn on the background.

## Optional polish

- Replace `--volicon` PNG with an actual `.icns` for the volume icon
  (current PNG works but `.icns` is the macOS-native format).
- Bump window size to 660×400 or 720×460 with larger icons (128px)
  for a more spacious feel — matches the bigger-name apps.

## Why this is parked

Zero functional impact — purely a polish item. Slot in when the
brand identity is more settled (logo + colours feel final) and there's
bandwidth for design work. Could batch with first-launch onboarding
visuals.

## Done when

- [ ] `ui/macos/installer/background@2x.png` exists with the brand
      design
- [ ] DMG mounts and shows the custom background
- [ ] Icon positions on background match `--icon` / `--app-drop-link`
      coords in `Taskfile.yml`
- [ ] CI builds still produce a working DMG (verify
      `release.yml` doesn't choke on the new file path)
