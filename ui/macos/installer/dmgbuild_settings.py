# dmgbuild settings for Nox.dmg
# ----------------------------------------------------------------------------
# Run via `task build:dmg`. Replaces our earlier `create-dmg` invocation
# which couldn't reliably:
#   - Render the /Applications symlink as a real Finder folder icon
#     (it showed up as a dashed-border placeholder).
#   - Attach a custom icon to the .dmg FILE itself (downloads showed
#     the generic disk-image icon).
#
# dmgbuild generates the same kind of DMG (HFS+ → UDZO compressed) but
# writes the .DS_Store entries and resource forks needed for both fixes
# in one pass. Settings file is plain Python eval'd by dmgbuild — the
# variables below are picked up by name.
# ----------------------------------------------------------------------------

import os

# DMG payload — the built .app bundle. The Taskfile passes the path as
# the DMGBUILD_APP define so this file stays portable across local dev
# and CI without hard-coding `build/macos/...`.
application = defines.get("app", "build/macos/Build/Products/Release/Nox.app")
appname = os.path.basename(application)

# ── DMG-level settings ──────────────────────────────────────────────────────

# UDZO = compressed, read-only, broadly compatible. Same format
# `create-dmg` produced; mounts cleanly on every macOS we care about.
format = "UDZO"

# Auto-size: dmgbuild picks a slightly-larger-than-app size so the
# install media isn't bloated. Explicit `size` override only needed
# if we ever ship extra resources alongside the app.
size = None

# Volume icon — the Apple-canonical .icns is what Finder reads for
# BOTH the mounted-volume icon (in the sidebar / Desktop) AND the
# .dmg file icon when sitting in Downloads. One file → both surfaces
# branded.
icon = "ui/macos/installer/nox.icns"

# ── Files in the install media ──────────────────────────────────────────────

# The .app payload + a /Applications symlink for drag-to-install. The
# `symlinks` dict tells dmgbuild to generate a REAL Finder alias (with
# the proper `bookmark` data in the .DS_Store) rather than a dangling
# symlink — that's why this approach actually renders the Applications
# folder icon, where `create-dmg --app-drop-link` left a placeholder.
files = [application]
symlinks = {"Applications": "/Applications"}

# ── Finder view layout ──────────────────────────────────────────────────────

# Icon view (vs list/column) — same shape `create-dmg` produced.
default_view = "icon-view"
show_icon_preview = False
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False
sidebar_width = 0

# Window geometry — matches the dimensions baked into our background
# PNG (600×400 logical, 1200×800 @2x), so the dotted-arrow art lines
# up with the icon coordinates below. ((x, y), (w, h)).
window_rect = ((200, 120), (600, 400))

icon_size = 100
text_size = 12

# Positions of the two visible icons. The background PNG draws the
# "Nox → Applications" dotted arrow between these two anchor points;
# nudging them invalidates the visual cue.
icon_locations = {
    appname: (150, 185),
    "Applications": (450, 185),
}

background = "ui/macos/installer/background@2x.png"
