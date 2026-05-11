# Release pipeline

When the project moves to git this becomes urgent. Until then, keep
the manual `task dmg` flow but document the gaps.

## Repo

- Init `git init` + `.gitignore` (Go + Flutter + macOS-specific:
  `.DS_Store`, `build/`, `ui/build/`, `ui/.dart_tool/`,
  `ui/macos/Pods/`, `ui/macos/Flutter/ephemeral/`,
  `ui/macos/Podfile.lock` is debatable — the lockfile typically *is*
  committed).
- `git lfs` for the icon PNGs? Probably not needed at this size, but
  keep in mind for future large assets.
- Branching model: `main` always green, `feat/*` for work, PRs
  required. Merge style: squash to keep `main` history readable.

## CI

GitHub Actions workflow `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  prepare:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.22"
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.32.x"
      - run: brew install go-task golangci-lint
      - run: task tidy
      - run: task lint
      - run: go test -race ./...
      - run: task flutter:format:check
      - run: task flutter:analyze
      - run: task flutter:test
```

Cache `go mod` and `flutter pub` between runs to keep CI under 5 min.

## Versioning

Single source of truth: a `VERSION` file at the root.

```
1.0.0
```

A `task version:bump LEVEL=minor` command (or just hand-edited)
updates:

- `VERSION`
- `config.yaml` `app.version` (and `config.example.yaml`)
- `ui/pubspec.yaml` `version: 1.0.0+1` — increment build number too
- `ui/macos/Runner/Configs/AppInfo.xcconfig` — `MARKETING_VERSION`,
  `CURRENT_PROJECT_VERSION`

Then tag: `git tag -a v1.0.0 -m "Release 1.0.0"`.

## Signed DMG

Current `task dmg` produces an unsigned DMG — Gatekeeper will warn on
launch. For a real release:

1. **Apple Developer ID** — ~$99/yr. Get a Developer ID Application
   certificate.
2. **Code signing** — Flutter has built-in support via the Xcode
   project. Set `DEVELOPMENT_TEAM` in `AppInfo.xcconfig` and
   `CODE_SIGN_STYLE = Manual`.
3. **Notarization** — Apple's automated malware scan. Submit DMG via
   `xcrun notarytool submit`, wait for "Accepted", staple ticket
   with `xcrun stapler staple`.
4. **Hardened runtime** — entitlements file already exists; just
   need to enable hardened runtime in Xcode build settings.

Add a `task release` that bundles all of this:

```yaml
release:
  desc: Build, sign, notarize and produce a stamped DMG
  cmds:
    - task: flutter:build
    - task: codesign
    - task: notarize
    - task: dmg
    - task: stapleDmg
```

## Auto-update

[`auto_updater`](https://pub.dev/packages/auto_updater) — Sparkle 2
under the hood. Plan:

1. Host an `appcast.xml` on a static URL (GitHub release asset is
   fine, or S3 / CloudFront).
2. Each release uploads:
   - `Nox-1.0.0.dmg`
   - `Nox-1.0.0.dmg.signature` (EdDSA signature with the app's
     update key)
   - Updates `appcast.xml` with version + URL + release notes
3. App on launch: `await autoUpdater.checkForUpdates()`. If newer
   version found → "Update available" dialog → user confirms →
   download + verify signature + replace + relaunch.

The EdDSA key is a separate keypair from the Apple signing cert.
Generated once with `sign_update --generate-keys`. Public key
embedded in the app at build time; private key kept offline (1Password
/ similar).

## Release checklist (manual until automated)

```
[ ] task prepare green on main
[ ] git tag -a v$VERSION -m "Release $VERSION"
[ ] git push origin v$VERSION
[ ] task release  # build + sign + notarize + DMG + appcast
[ ] Upload DMG + sig + appcast to release CDN
[ ] Verify auto-update from previous version → new version works
[ ] Smoke test: import wallet, send ETH, swap, mark notifications
[ ] Post release notes
```

## Done when

- [ ] Repo on git with main-protected branch + PR-required flow
- [ ] CI runs `task prepare` + race detector on every PR
- [ ] Single-source `VERSION` file, version-bump task
- [ ] `task release` produces signed + notarized + stapled DMG
- [ ] Auto-update flow tested end-to-end at least once
- [ ] Release notes template in `RELEASING.md`
