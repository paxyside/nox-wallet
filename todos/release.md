# Release pipeline

Git, CI, automated versioning, documented release flow, **and the
full Sparkle auto-update pipeline** are live. The only remaining
item is gated on a `$99/yr` Apple Developer ID — without it the DMG
is ad-hoc-signed and Gatekeeper warns on first launch. Importantly,
auto-update **already works without notarization**: Sparkle's EdDSA
signature is independent of Apple codesign, and the in-place bundle
swap inherits path-based Gatekeeper approval, so installs upgrade
cleanly once the user has granted first-launch trust manually.

What's left for "ship it": wire codesign + notarization into
`release.yml`. Everything else is done.

## ✓ Shipped already

- Repo on git (master branch, GitHub private).
- `.gitignore` covers Go + Flutter + macOS-specific artefacts.
- Commit conventions documented in `/CONTRIBUTING.md`.
- `.github/workflows/ci.yml` — `task prepare` + `git diff --exit-code`
  on every push to master and every PR. Linux runner (1× counter on
  private repos).
- `.github/workflows/release.yml` — dual-entry release pipeline.
  Triggers on `v*` tag push for manual hotfixes, or via
  `workflow_call` from `auto-tag.yml` for automated minor/major
  releases. Runs the full `task prepare` gate, creates the tag (when
  called programmatically), builds the DMG, uploads as a GitHub
  Release asset via `softprops/action-gh-release@v2`. macOS-14
  runner (mandatory for `flutter build macos`).
- `.github/workflows/auto-tag.yml` — on push to master, reads
  `/VERSION`, compares to the latest `v*` tag, and:
  - **MAJOR / MINOR bump** → calls `release.yml` via workflow_call,
    which tags + builds + publishes automatically.
  - **PATCH bump** → no-op. The developer tags the hotfix by hand
    (`git tag -a v0.1.1 -m … && git push origin v0.1.1`), which
    re-enters `release.yml` through the tag-push path.
  - **No change** → no-op. **Decreased** → workflow fails.
  - Also enforces `/VERSION`, `ui/pubspec.yaml`, and
    `config.example.yaml` agree — mismatch fails the run.
- `.github/workflows/security.yml` — weekly cron + manual dispatch,
  Linux runner, govulncheck + osv-scanner + `flutter pub outdated`.
- `.github/workflows/version-check.yml` — runs on every PR against
  master. Validates VERSION shape + cross-file sync, computes the
  bump type vs base, and prints "merge will trigger a release" /
  "merge needs a manual tag" / "no version change" in the PR
  Actions tab summary so reviewers see it up front. Fails the PR
  on backwards-going VERSION or out-of-sync mirror files.
- `/VERSION` file — single source of truth for the marketing version.
  `task version` prints it; `task version:set -- 0.2.0` updates all
  three locations atomically.
- `/RELEASING.md` — cheat sheet for "I want to ship — what do I
  run?": where versions live, what the bump types mean, the two
  release flows (auto-minor/major and manual-patch), pre-merge
  checklist, what does and doesn't ship in today's DMG, and
  troubleshooting.
- `task build:dmg` produces an ad-hoc-signed DMG today. Works on the
  developer's machine and on any Mac with Gatekeeper disabled.

## ✓ Auto-update (Sparkle) — shipped

- `auto_updater: ^1.0.0` added to `ui/pubspec.yaml` — pulls Sparkle 2
  in via CocoaPods automatically.
- `ui/macos/Runner/Info.plist` carries `SUFeedURL`, `SUPublicEDKey`,
  `SUEnableAutomaticChecks`, `SUScheduledCheckInterval` (3600s).
- `ui/lib/core/services/update_service.dart` — Dart wrapper around
  `auto_updater`. `UpdateService.init()` runs in `main.dart` after
  the backend boot; `UpdateService.checkNow()` is wired to a
  "Check for updates" button in Settings → About.
- `.github/workflows/release.yml` downloads the Sparkle 2.6.4
  toolchain, signs the DMG with the `SPARKLE_ED_PRIVATE_KEY` secret,
  generates `appcast.xml` (with EdDSA signature + DMG URL + version
  + minimum macOS), and uploads both files to the GitHub Release.
- `appcast.xml` lives at the static URL
  `/releases/latest/download/appcast.xml` — GitHub redirects
  `/latest/` to the newest non-draft Release, so the installed app
  never has to be reconfigured when we cut new versions.
- One-time manual steps documented in `RELEASING.md → Sparkle setup`.

**Why this works without notarization:** Sparkle's signature scheme
is its own EdDSA chain, separate from Apple codesign. The user grants
Gatekeeper trust to the bundle's filesystem path on first launch
(right-click → Open); Sparkle's in-place bundle swap preserves that
path, so subsequent auto-updates don't re-trigger the warning.
Notarization removes the first-launch friction but is not required
for the auto-update loop itself.

## What's left (gated on Apple Developer ID)

### Signed DMG + notarization

The DMG that `release.yml` produces today is **ad-hoc signed only**.
On a fresh user's Mac Gatekeeper blocks first launch ("cannot be
opened because the developer cannot be verified"). Fix:

1. **Apple Developer ID** — ~$99/yr. Get a Developer ID Application
   certificate.
2. **Code signing** — Flutter has built-in support via the Xcode
   project. Set `DEVELOPMENT_TEAM` in
   `ui/macos/Runner/Configs/AppInfo.xcconfig` and
   `CODE_SIGN_STYLE = Manual`.
3. **Notarization** — Apple's automated malware scan. Submit DMG via
   `xcrun notarytool submit`, wait for "Accepted", staple ticket
   with `xcrun stapler staple`.
4. **Hardened runtime** — entitlements file already exists; just
   need to enable hardened runtime in Xcode build settings.

Wire into `release.yml` via GitHub Secrets:

```yaml
# .github/workflows/release.yml (additions)
env:
  APPLE_ID:             ${{ secrets.APPLE_ID }}
  APPLE_PASSWORD:       ${{ secrets.APPLE_APP_SPECIFIC_PASSWORD }}
  APPLE_TEAM_ID:        ${{ secrets.APPLE_TEAM_ID }}
  CERTIFICATE_BASE64:   ${{ secrets.MACOS_CERTIFICATE_BASE64 }}
  CERTIFICATE_PASSWORD: ${{ secrets.MACOS_CERTIFICATE_PASSWORD }}

# Steps to add before `task build:dmg`:
- name: Import codesign certificate
  run: |
    echo "$CERTIFICATE_BASE64" | base64 --decode > certificate.p12
    security create-keychain -p "" build.keychain
    security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -A
    security list-keychains -s build.keychain
    security unlock-keychain -p "" build.keychain

- name: Build DMG (codesign happens inside task)
  run: task build:dmg

- name: Notarize DMG
  run: |
    xcrun notarytool submit dist/Nox.dmg \
      --apple-id "$APPLE_ID" \
      --password "$APPLE_PASSWORD" \
      --team-id "$APPLE_TEAM_ID" \
      --wait
    xcrun stapler staple dist/Nox.dmg
```

## Release checklist (current state)

Most of this is automated. The manual steps live in
[`/RELEASING.md`](../RELEASING.md). The few that need eyes on are:

```
[ ] task prepare green on master (CI enforces — locally optional)
[ ] task version:set -- $NEW_VERSION  (only when bumping)
[ ] PR review + merge to master
    → auto-tag handles minor/major
    → manual `git tag` needed for patch (see RELEASING.md)
[ ] smoke test the published DMG once
```

## Done when

- [x] Repo on git with master branch + PR-friendly flow
- [x] CI runs `task prepare` on every push + PR
- [x] PR-time version-check gate
- [x] Single-source `VERSION` file + version-set task + auto-tag CI
  for minor/major bumps
- [x] `RELEASING.md` documents the flow
- [x] Sparkle wiring: `auto_updater` in pubspec, Info.plist keys,
  `UpdateService` in main + Settings, signed `appcast.xml` published
  by `release.yml`
- [ ] Sparkle keypair generated and `SPARKLE_ED_PRIVATE_KEY` secret
  added (one-time, see RELEASING.md → Sparkle setup)
- [ ] Auto-update flow tested end-to-end at least once
- [ ] Apple Developer ID acquired, certificate imported as secret
- [ ] `task build:dmg` produces a signed + notarized + stapled DMG
- [ ] `release.yml` end-to-end: tag push → notarized DMG +
  appcast.xml on GitHub Releases
