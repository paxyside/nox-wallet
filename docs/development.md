# Development

How to set the repo up, run it locally, and pass CI on the first try.
For why things are shaped the way they are, see
[`architecture.md`](architecture.md). For the deep dives, see
[`backend.md`](backend.md) and [`frontend.md`](frontend.md).

## Prerequisites

**Tooling** (Homebrew is the easy path on macOS):

| Tool                          | Version              | Why                                                   |
|-------------------------------|----------------------|-------------------------------------------------------|
| Go                            | 1.22+ (CI uses 1.26) | the backend                                           |
| Flutter                       | 3.41.9 (CI pin)      | the UI; older 3.32+ may work, CI tests against 3.41.9 |
| CocoaPods                     | latest               | macOS Flutter plugins                                 |
| Xcode Command Line Tools      | latest               | clang for cgo-sqlite                                  |
| [Task](https://taskfile.dev/) | latest               | `brew install go-task` — task runner                  |
| golangci-lint                 | 2.x                  | `brew install golangci-lint`                          |
| Docker                        | latest               | only for `task proto:generate`                        |

**Accounts**:

- **[Alchemy](https://dashboard.alchemy.com/)** — paid endpoints
  (`getAssetTransfers`, token metadata). Free tier works for dev.
- **[CoinGecko](https://www.coingecko.com/en/api/pricing)** —
  *optional* Demo plan key. Without it, anonymous-tier rate
  limiting throttles sparkline charts.

## Setup

```sh
git clone git@github.com:paxyside/nox-wallet.git
cd nox-wallet

# 1. Copy the config and paste keys
cp config.example.yaml config.yaml
$EDITOR config.yaml     # set ethereum.alchemy_key (and ws_url + http_url with the same key)
                        # optionally set pricefeed.coingecko_key + pricefeed.coingecko_plan

# 2. Build the proto-gen Docker image once
task proto:image        # ~3 min the first time, cached after

# 3. First run: builds the Go backend, builds the Flutter app,
#    spawns the backend as a child process, opens the macOS window.
task dev
```

The first time you launch the app you'll see the onboarding screen:
generate a new wallet or import an existing one.

## The dev loop

```sh
task dev                # build backend + run Flutter on macOS in debug
task clean              # nuclear wipe: builds, caches, sandbox container,
                        # installed app, keychain entry
```

`task dev` rebuilds the Go backend (`build/backend`), then runs
`flutter run -d macos`. The bundled `.app` includes the backend
binary at `Contents/MacOS/backend` — the Flutter side spawns it as a
child process and waits for `127.0.0.1:50055` to come up.

If you want a wholly clean state — fresh wallet, fresh SQLite, fresh
keychain entry — run `task clean` before `task dev`.

## Quality gates

```sh
task prepare            # the meta-runner: must pass before every push
```

`task prepare` runs, in order:

1. `go mod tidy` — drops unused require lines, adds missing ones.
2. `go mod vendor` — re-sync the vendored copy.
3. `go build ./...` — every package compiles.
4. `golangci-lint run --fix` — applies auto-fixable lint issues.
5. `CGO_ENABLED=1 go test ./...` — full Go test suite.
6. `dart format --line-length=100 --set-exit-if-changed lib/` —
   formatter is a hard gate. Will fail (with the formatted result
   written to disk) if anything was out of style.
7. `cd ui && flutter analyze` — `very_good_analysis` preset.
8. `cd ui && flutter test` — widget + unit tests.

The CI pipeline runs the same steps and additionally checks
`git diff --exit-code` afterwards — if `task prepare` mutated any
tracked file you forgot to commit, CI fails with a clear message.

Individual gates:

```sh
task test               # CGO_ENABLED=1 go test ./...
task lint               # golangci-lint run --fix
task flutter:analyze    # dart analyze (very_good_analysis preset)
task flutter:format     # dart format --line-length=100 lib/
```

## Proto regeneration

```sh
task proto:image        # build the buf Docker image (once)
task proto:generate     # format + lint + regen Go and Dart bindings
```

The proto toolchain runs in a container so contributors don't have
to install `buf`, `protoc-gen-go`, and `protoc-gen-dart` locally.
Generated files live in `proto/gen/go/` (Go) and
`ui/packages/wallet_proto/` (Dart) and are committed — CI verifies
they're up-to-date via `git diff --exit-code`.

## Release packaging

```sh
task build:backend      # just the Go binary → build/backend
task build              # backend + Flutter release Nox.app
task build:dmg          # full DMG, ad-hoc codesigned
```

The DMG is **ad-hoc codesigned only** — it works on the developer's
machine and any Mac where Gatekeeper assessment is off, but isn't
notarized. Notarization needs an Apple Developer ID ($99/year);
see `todos/release.md` for the wiring once you have one.

## Configuration

Two layers, in priority order:

1. **Environment variables** — `APP_NAME`, `GRPC_PORT`,
   `ETH_HTTP_URL`, etc. Match the `env:` tags in
   [`config/config.go`](../config/config.go).
2. **`config.yaml`** in the working directory (or override via
   `--config /path/to/file.yaml`).

The `--data-dir` CLI flag overrides the SQLite location at runtime.
The Flutter host passes a platform-specific app-support path in
production; `task dev` runs the backend without `--data-dir`, so
`./.dev-data/wallet.db` is used.

Secrets (mnemonic, private key) never go in `config.yaml`. They're
stored in the macOS Keychain under service `nox-wallet`. `task clean`
zaps that entry.

## Pre-commit checklist

Before pushing to master:

```sh
task prepare        # everything green
git status          # working tree clean
git log -1          # commit message reads sanely without context
```

Things that go wrong if you skip:

- **`dart format` reformatted files** — running locally first
  surfaces these as a separate commit. Skipping means CI applies
  the format then `git diff --exit-code` fails.
- **`go mod tidy` modified `go.sum`** — usually means a new import
  in your code; commit the sum change with the code.
- **`vendor/` drifted** — run `go mod vendor` and commit. Doesn't
  happen often because we sync vendor on every `task prepare`.

## Common gotchas

- **macOS Touch ID prompt on every cmd-W** — that's the prompt
  guard in `lockPromptPendingProvider` failing. Should only fire
  on launch and after idle timeout. If it's happening on window
  resize, check that the LockScreen mount uses `consume()`.
- **`go.sum` mismatch errors** — usually after a rebase. Run
  `go mod tidy` then `go mod vendor`.
- **Flutter `pubspec.lock` conflict** — `flutter pub get` regenerates
  it. Commit the regenerated version.
- **Backend exits immediately on `task dev`** — usually a port
  collision (someone else is on 50055). Either kill the other
  process or change `grpc.port` in `config.yaml`.
- **`task clean` says "permission denied"** on
  `~/Library/Containers/com.nox.wallet/...` — macOS's
  containermanagerd owns those subtrees. The wipe target
  intentionally `2>/dev/null || true`s every container line — the
  files inside `Data/` get wiped, the metadata is rebuilt on next
  launch.
- **`internal/dal/sqlite/db/wallet.db` lingering** — pre-`.dev-data/`
  artefact. `.gitignore` covers the path as a safety net, but you
  can delete the file safely; nothing reads from it anymore.

## CI / GitHub Actions

Three workflows in `.github/workflows/`:

| Workflow       | Trigger                              | Runner          | What                                                         |
|----------------|--------------------------------------|-----------------|--------------------------------------------------------------|
| `ci.yml`       | push to `master` + PR                | `ubuntu-latest` | `task prepare` + `git diff --exit-code`                      |
| `release.yml`  | push tag `v*`                        | `macos-14`      | `task prepare` + `task build:dmg` + upload to GitHub Release |
| `security.yml` | weekly cron (Mon 06:00 UTC) + manual | `ubuntu-latest` | `govulncheck` + `osv-scanner` + `flutter pub outdated`       |

CI minutes math: on a private repo, Linux = 1× counter, macOS = 10×.
`ci` runs ~3 min/push × 30 pushes/month ≈ 90 min. Free tier is 2000.

If CI fails on `flutter analyze` or `flutter test` because a
Linux-only runner can't load the macOS plugins, the fix is to switch
`ci.yml` to `macos-14` — the test suite was designed to be
platform-agnostic but plugin transitively-Dart compilation may
disagree. We'll know on the first run.
