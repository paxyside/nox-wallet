# Releasing

Cheat-sheet for cutting a release. The full design lives in
[`todos/release.md`](todos/release.md); this file is the
"I want to ship — what do I run?" reference.

## Where the version lives

Three files, all in sync, enforced by CI:

| File                   | Format        | Source of truth |
|------------------------|---------------|-----------------|
| `/VERSION`             | `0.1.0`       | **Yes** — `task version:set` writes this first |
| `ui/pubspec.yaml`      | `0.1.0+1`     | Mirrored        |
| `config.example.yaml`  | `"0.1.0"`     | Mirrored        |

Update all three with one command:

```sh
task version:set -- 0.2.0
```

`version-check.yml` (PR) and `auto-tag.yml` (master) both refuse to
proceed if the three drift apart — `task version:set` keeps them
honest.

## How a release fires

Every push to master runs `auto-tag.yml`. It diffs `/VERSION` against
the latest `v*` tag and decides what to do.

| Bump            | What happens                                                                                                                 |
|-----------------|------------------------------------------------------------------------------------------------------------------------------|
| **none**        | No-op. Most PRs don't bump version.                                                                                          |
| **patch**       | No-op. Patch releases are deliberate hotfixes — tag by hand (`git tag -a v0.1.1 -m … && git push origin v0.1.1`). This triggers `release.yml`'s tag-push path. |
| **minor**       | Automatic. `auto-tag.yml` invokes `release.yml` via `workflow_call`. The release pipeline tags, builds the DMG, and publishes a GitHub Release with auto-generated notes. |
| **major**       | Same as minor — fully automatic.                                                                                             |
| **decrease**    | Workflow fails. VERSION can't go backwards.                                                                                  |

## Release workflows

### Minor / major (automatic)

1. Open a PR. Last commit on the branch bumps VERSION:

   ```sh
   task version:set -- 0.2.0
   git add VERSION ui/pubspec.yaml config.example.yaml
   git commit -m "chore: bump version to 0.2.0"
   ```

2. Push, open PR. `version-check.yml` validates the bump and reports
   the planned outcome in the PR's Actions tab summary.
3. Merge the PR. `auto-tag.yml` runs on master, tags `v0.2.0`,
   triggers `release.yml`, which builds and uploads the DMG.
4. Verify the [Releases page](https://github.com/paxyside/nox-wallet/releases)
   has a new entry with `Nox.dmg` attached.

### Patch / hotfix (manual)

1. Branch off master. Make the fix. Bump:

   ```sh
   task version:set -- 0.1.1
   ```

2. PR, review, merge. `auto-tag.yml` detects the patch bump and does
   nothing (by design).
3. From master after the merge:

   ```sh
   git pull
   git tag -a v0.1.1 -m "Release v0.1.1"
   git push origin v0.1.1
   ```

   This triggers `release.yml` via the tag-push path. Same build, same
   upload as a minor.

## Sparkle setup (one-time)

Sparkle auto-update verifies each downloaded DMG against an **EdDSA
public key** baked into the installed bundle. The private half lives
only on GitHub as `SPARKLE_ED_PRIVATE_KEY`; the workflow uses it to
sign the DMG and writes the signature into `appcast.xml`. This is a
separate trust chain from Apple's codesign — auto-update works today
without a Developer ID account.

Run this **once**, before the first 0.1.0 release:

1. Download Sparkle's tools (matches the version pinned in
   `release.yml`):

   ```sh
   curl -fsSL -o sparkle.tar.xz \
     https://github.com/sparkle-project/Sparkle/releases/download/2.6.4/Sparkle-2.6.4.tar.xz
   mkdir -p /tmp/sparkle && tar -xJf sparkle.tar.xz -C /tmp/sparkle
   ```

2. Generate the keypair. `generate_keys` stores the private key in
   the macOS Keychain and prints the public key:

   ```sh
   /tmp/sparkle/bin/generate_keys
   # Output: A pair of keys has been generated...
   #         Public key: <BASE64_PUBLIC_KEY>
   ```

3. Paste the **public key** into `ui/macos/Runner/Info.plist`,
   replacing the `REPLACE_WITH_SPARKLE_PUBLIC_KEY` placeholder under
   the `SUPublicEDKey` entry.

4. Export the **private key** as a single line and add it to GitHub:

   ```sh
   /tmp/sparkle/bin/generate_keys -x ~/sparkle_private_key.pem
   cat ~/sparkle_private_key.pem
   ```

   - GitHub → Settings → Secrets and variables → Actions → New
     repository secret.
   - Name: `SPARKLE_ED_PRIVATE_KEY`
   - Value: the private key contents (`sign_update -s` accepts the
     base64-encoded private key directly; `generate_keys -x` writes
     the same format `sign_update` expects).

5. **Store a backup** of the private key in 1Password / similar. If
   it's lost, you can never push an update that existing installs
   will accept — they'll keep working on whatever version they have,
   but auto-update breaks until users re-install from a freshly-keyed
   build.

6. Delete `~/sparkle_private_key.pem` from disk once it's safe in the
   secret store + your password manager.

## Pre-merge checklist

Run locally before pushing the version-bump commit:

- [ ] `task prepare` is green.
- [ ] `task version` matches what you typed in `task version:set`.
- [ ] Smoke test on dev: import wallet, send ETH, swap, mark
      notifications. The DMG that lands on Releases ships whatever's
      on master at the merge point.
- [ ] If the release touches the data schema, dev-DB wipe still
      works (`task clean && task dev`).

## What ships in the DMG today

- Flutter macOS bundle built with `flutter build macos --release`.
- Go backend at `Contents/MacOS/backend`.
- Bundled Uniswap Default Token List + per-chain network catalog.
- Embedded ABIs for ERC-20 + Uniswap V3.

What does **NOT** ship yet:

- **Notarized signing.** The DMG is ad-hoc-signed only. On a fresh
  user's Mac, Gatekeeper blocks first launch — they have to
  right-click → Open. Fix is gated on an Apple Developer ID
  account (~$99/yr); see `todos/release.md` for the wiring once
  that's in place.
What **does** ship now (was previously blocked):

- **Auto-update via Sparkle.** Every release uploads `Nox.dmg` plus
  an `appcast.xml` signed with the project's EdDSA private key. The
  installed app polls `releases/latest/download/appcast.xml` once an
  hour; if a newer signed entry is found the user gets the Sparkle
  update dialog. EdDSA verification is independent of Apple codesign,
  so this works today on ad-hoc-signed builds — Sparkle's in-place
  bundle swap preserves the path-based Gatekeeper approval the user
  granted on first launch.

## When something goes wrong

| Symptom | Fix |
|---|---|
| Workflow fails: "VERSION went backwards" | Someone landed a regression. Bump VERSION on master to the highest known value (`task version:set -- 0.3.0`) and re-merge. |
| Workflow fails: "VERSION out of sync" | Run `task version:set -- $(cat VERSION)` to re-sync pubspec and config.example. |
| `auto-tag.yml` thinks bump is `none` but I expected a release | Likely forgot to bump VERSION. Open a PR with `task version:set`. |
| Tag exists already, build fails to push | Delete the stale tag on origin (`git push origin :refs/tags/v0.2.0`), bump VERSION, re-merge. |
| `release.yml` succeeded but Releases page is empty | Check the Actions log for the `softprops/action-gh-release@v2` step. Usually a token-permission issue — `contents: write` is set at the workflow level. |
