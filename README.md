# Nox

A self-custodial Ethereum wallet for macOS. Native Flutter UI, Go backend,
SQLite-backed state, Touch-ID unlock, tray-resident operation.

```
┌──────────────────┐  loopback gRPC  ┌──────────────────┐
│   Flutter UI     │ ◄─────────────► │   Go backend     │
│   (Riverpod,     │                 │   (use-cases,    │
│    go_router,    │                 │    domain,       │
│    Material)     │                 │    Alchemy +     │
│                  │                 │    SQLite)       │
└────────┬─────────┘                 └────────┬─────────┘
         │ NSUserNotification                  │  Apple Keychain
         │ NSSound, Touch ID                   │  (mnemonic / pk)
         │ tray, window_manager                │
         └───────────────────────────  macOS  ─┘
```

## What it does

- **Manage funds** — generate a new wallet, import via mnemonic / private key /
  encrypted keystore. Full ETH and ERC-20 balances with USD valuations.
- **Send & swap** — single-step ETH sends, ERC-20 transfers, on-chain swaps
  through Uniswap V3. Speed-up / cancel for stuck transactions.
- **Track history** — Alchemy-driven sync of every transfer the wallet ever
  participated in. Multi-leg swaps merged into a single visible row.
- **Live notifications** — watcher streams events as they happen. Per-row
  read/unread state survives restart. macOS toasts and an in-app chime
  configurable independently.
- **Menu-bar mode** — the entire app collapses into a 380×660 popover under
  the macOS tray icon. Quick balance check, send / swap quick actions,
  notification panel, and per-network gas info — all without opening the
  full window.
- **Touch-ID lock** — biometric unlock on launch and after idle timeout.
- **Theme-aware** — dark / light mode with a runtime-swappable Dock icon
  bundled per theme.

## Repo layout

```
nox-wallet/
├── cmd/app/                      Backend entrypoint
├── internal/
│   ├── app/                      Wiring + lifecycle (init, runners)
│   ├── handler/grpc/             gRPC transport adapters
│   ├── usecase/                  Business logic per domain
│   ├── domain/<name>/            Pure entities + storage interfaces
│   ├── adapter/{eth,price}/      External-system adapters
│   └── dal/sqlite/migrations/    Goose migrations (single 00001 init)
├── pkg/
│   ├── ethkit/                   Wallet, swap, ERC-20, pending tracker
│   ├── sqlitekit/                SQLite client + migration runner
│   ├── grpckit/                  Server builder, interceptors, status mapping
│   ├── keychain/                 macOS Keychain wrapper (go-keyring)
│   ├── logger/                   slog wrapper
│   └── common/{idx,timex,retryx} ULID/UUID, time, retry
├── proto/                        gRPC schemas + generated Go/Dart code
├── ui/                           Flutter app — see ui/README.md
├── config.example.yaml           Reference config
├── Taskfile.yml                  Task automation
└── go.mod / go.sum
```

Hexagonal layering on the backend: `usecase` is the only layer that imports
both `domain` and adapters; `domain` is pure; `handler` only imports usecase
contracts.

## Prerequisites

Tooling:

- **Go** 1.22+
- **Flutter** 3.32+ (with macOS desktop support enabled)
- **CocoaPods** (for the macOS Flutter pod install)
- **Xcode Command Line Tools**
- **[Task](https://taskfile.dev/)** runner (`brew install go-task`)
- **golangci-lint** (`brew install golangci-lint`) — for `task lint`
- **Docker** — only needed for `task proto:generate`
  (the proto toolchain runs in a container)

Accounts:

- **[Alchemy](https://dashboard.alchemy.com/)** — paid features (`getAssetTransfers`,
  WebSocket subscriptions). The free tier works for development.
- **[CoinGecko](https://www.coingecko.com/en/api/pricing)** — *optional* Demo
  plan key keeps the sparkline charts steady; without it the anonymous
  rate limit will throttle.

## Quick start

```sh
# 1. Pull the Alchemy / CoinGecko keys
cp config.example.yaml config.yaml
$EDITOR config.yaml         # paste your Alchemy key

# 2. Boot a fresh dev session (clean DB + caches, then run)
task dev:fresh

# Subsequent runs: keep your wallet, just rebuild
task dev
```

The first run will:

1. Build the Go backend into `build/backend`,
2. Build the Flutter app and copy `build/backend` into the
   `Nox.app/Contents/MacOS/` bundle so the UI can spawn it,
3. Open the macOS window, then prompt you to import / create a wallet.

## Common tasks

```sh
task                    # list everything

# Development
task dev                # build backend + run Flutter on macOS
task dev:fresh          # wipe DB + caches + run dev
task clean              # wipe DB, build artefacts, pods

# Quality (run before push)
task prepare            # tidy + dryrun build + lint + test +
                        # flutter format check + analyze + flutter test

# Individual gates
task test               # go test -v ./...
task lint               # golangci-lint run --fix
task flutter:analyze    # dart analyze (very_good_analysis preset)
task flutter:format     # dart format --line-length=100 lib/
task flutter:test       # widget + unit tests in ui/test

# Proto schema (Docker required)
task proto:all          # format + lint + generate Go and Dart bindings

# Release packaging
task flutter:build      # release .app bundle in ui/build/macos/...
task dmg                # signed DMG (requires `create-dmg`)
```

## How it works

### Process model

The Flutter app boots a Go backend as a child process and connects to it
on `127.0.0.1:50055`. The bundled binary lives at
`Contents/MacOS/backend` inside the `.app`. Killing the UI also kills the
backend (Go listens on the parent's stdout pipe and exits when it
closes).

Why not embed the Go runtime via FFI? The watcher and Alchemy syncers
spawn dozens of long-lived goroutines and a SQLite write loop that we'd
rather keep at arm's length from the Flutter event loop. A child process
also makes panics survivable.

### Storage

Single SQLite database at
`~/Library/Containers/com.nox.wallet/Data/Library/Application Support/WalletApp/wallet.db`.
Migrations are managed by [goose](https://github.com/pressly/goose) and
live in `internal/dal/sqlite/migrations/`. We deliberately keep the
schema in **a single migration file** (`00001_init.sql`) until first
release ship; subsequent changes will go in numbered migrations.

Tables: `wallets`, `contacts`, `watched_tokens`, `transactions`,
`notifications`, `notification_settings`. Secrets (mnemonic / private
key) never touch SQLite — they live exclusively in the macOS Keychain
under service `nox-wallet`.

### Live data

Three watchers drive real-time UX (one goroutine each, started after
`LoadFromKeychain` succeeds):

- **ETH balance** — drives the low-balance threshold latch.
- **Transactions** — polls Alchemy `getAssetTransfers` every 15 s with a
  3-block lookback, dedupes by hash, defers single-leg events that
  pending-tracker tagged as swaps until the second leg shows up
  (or 30 s elapses).
- **Gas** — polls base fee Gwei; emits spike / drop alerts.

Events flow `watcher → notification.Save → broadcast` and the gRPC
`WatchEvents` stream wraps each one in a `NotificationEnvelope`
carrying the freshly minted DB row id. The UI keys per-row read state
off that id, so reload-after-restart and live arrival both look the
same.

### gRPC

Local-only loopback server. Static-token auth available
(`grpc.authorization` in config) but unset by default — change in
`config.yaml` and pass the same token from the Flutter side if you need
inter-process auth. Reflection is enabled in dev (`grpcurl` works
without proto downloads); turn it off in `config.yaml` for release
builds.

## Security posture

- **Secrets** stored in Apple Keychain via `go-keyring`. Mnemonic /
  private key never logged or persisted to disk in plaintext anywhere
  else.
- **Touch ID** required on app start and after idle timeout. Re-prompt
  is gated by a one-shot pending flag, so window resize / mini-mode
  toggles don't trigger Touch-ID storms.
- **Sandboxed**: macOS app sandbox is on (`com.apple.security.app-sandbox`).
  Network client + server entitlements only.
- **Loopback-only** gRPC. The OS sandbox + 127.0.0.1 binding limits the
  attack surface to the local user account.
- **Reveal-secret RPC** prompts for confirmation in the UI before
  surfacing the mnemonic / private key. The user has to explicitly tap
  "Reveal" twice.
- **No telemetry**. No crash reporting, no analytics, no remote
  logging. The only outbound calls are to Alchemy, CoinGecko (if a
  key is configured), and Etherscan (only when the user explicitly
  clicks a transaction tile).

## Pre-release checklist

Before tagging a release:

```sh
task prepare              # all checks green
task flutter:build        # release bundle
task dmg                  # signed DMG
```

In `config.yaml` for the shipped binary:

- Set `grpc.reflection: false`
- Set `logger.level: "info"` (or `"warn"`) and `logger.pretty: false`
- Set `app.environment: "production"`
- If you ship with a default loopback token, set `grpc.authorization`

## License

TBD — see project owner.
