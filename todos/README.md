# Roadmap

Living plans for things we agreed to do but parked. Each file is
self-contained — pick one up, read, execute, tick off. Nothing here is
strict — if priorities shift, edit the file in place.

## Index — recommended order

| # | File                                       | Theme                                                      | Estimate  |
|---|--------------------------------------------|------------------------------------------------------------|-----------|
| 1 | [release.md](release.md)                   | Signed + notarized DMG, auto-update (CI already in place)  | 1–2 days  |
| 2 | [chainkit-prep.md](chainkit-prep.md)       | Per-chain `Chain` abstraction (config layer already done)  | 4–6 days  |
| 3 | [multi-wallet.md](multi-wallet.md)         | Multiple ETH wallets in one app                            | 4–5 days  |
| 4 | [network-switcher.md](network-switcher.md) | Network selector UI + custom RPC                           | 2 days    |
| 5 | [walletconnect.md](walletconnect.md)       | WalletConnect v2 integration                               | 1 week    |

## Why this order

**Release first** — git + CI shipped already, but the DMG isn't signed
or notarized. Without that, a fresh user has to right-click → Open on
first launch. The auto-update path is also unwired. Closing that
makes every later release a one-tag push instead of a manual ritual.

**chainkit-prep** before multi-wallet / network-switcher — both later
features assume the per-chain abstraction exists. The config layer
(`config/networks/networks.yaml` + `pkg/ethkit/network.go`) is already
in place; what's left is multiplexing the ethkit Client per chain
(today there's one `*ethkit.Client` bound to the active network at
boot). After that, multi-wallet / network-switcher become UI work.

**Multi-wallet** before network-switcher — wallets have a more
contained scope; network-switcher requires per-network DB partitioning
which gets messier without multi-wallet's per-row scoping in place.

**WalletConnect last** — biggest security surface in the whole app.
Phishing dApps can ask the user to sign permits / setApprovalForAll /
calldata — without a mature ABI decoder + sandbox UX, it's risky to
ship. Land this when there's bandwidth for proper review + tests.

## Conventions

- **Estimate** is solo full-time. Multiply by 1.5–2 if work is interleaved.
- **Each file** ends with a "Done when" checklist so it's obvious
  what "complete" looks like.

## Already done (removed from this folder)

For history — what we shipped during the consolidation:

### Backend hardening

- ✓ `history-parallel.md` — `errgroup` + global `semaphore.Weighted(8)`
  + single-flight `SyncForce`. `internal/usecase/history/usecase.go`.
- ✓ `pending-persistence.md` — SQLite-backed `ethkit.PendingStore` so
  the `Kind="swap"` tag survives backend restarts.
  `internal/adapter/eth/pending_store.go` + the schema is now part of
  the unified `00001_init.sql` migration.
- ✓ `tests.md` — backend coverage gap closed:
  `internal/usecase/notification/usecase_test.go`,
  `internal/adapter/eth/pending_store_test.go` (incl. `-race`),
  `internal/handler/grpc/handlers_test.go`,
  `internal/usecase/watcher/process_tick_test.go`. Earlier watcher
  unit tests (`classify_test.go`, `emitted_set_test.go`,
  `should_defer_test.go`, `merge_swaps_test.go`) shipped previously.

### Code quality / cleanup

- ✓ `decomposition.md` — `mini_widget.dart` (1812 → 117 + 8 parts),
  `notification_center.dart` (1084 → 222 + 4 parts),
  `wallet_notification_panel.dart` (777 → 164 + 5 parts),
  `watcher/usecase.go` (927 → 213 + 7 siblings); later
  `address_field.dart` and `contact_card.dart` split into 4 part-of
  files.
- ✓ **Dead-code sweep** — `deadcode ./...` returns zero across the
  whole module. `pkg/common/timex`, `pkg/logger`, `pkg/errors`,
  `pkg/grpckit`, `pkg/config` trimmed from kitchen-sink utilities
  down to just what `cmd/app/main.go` actually reaches.
- ✓ **Deprecated event kinds removed** — `KindEthTransfer` /
  `KindTokenTransfer` and their proto fields (the watcher emits only
  `KindTransaction` / `KindGasAlert` / `KindLowBalance` now).
- ✓ **Proto enum naming** — `Role.UNKNOWN` → `Role.ROLE_UNSPECIFIED`,
  `AlertType.SPIKE` → `AlertType.ALERT_TYPE_SPIKE`, etc. STANDARD
  buf-lint passes.
- ✓ **Module rename** — `github.com/paxyside/walletapp` →
  `github.com/paxyside/nox-wallet`. Bundle id stays `com.nox.wallet`.

### Networking / data layer

- ✓ **Network catalog** (`config/networks/`) — per-chain id, protocol
  contracts (Uniswap V3 router / quoter / WETH9), native asset
  metadata embedded in YAML. Foundation for `chainkit-prep.md`.
- ✓ **Embedded Uniswap Default Token List** (~386 mainnet tokens) —
  drives both watcher metadata-lookup and the UI verified-badge.
  `task update:tokenlist` refreshes the snapshot.
- ✓ **Token logos** — every gRPC token response carries a `logo_url`
  stamped from the embedded list; UI's `TokenIcon` widget renders
  them directly. Killed three parallel paths (hardcoded
  `wellKnownTokens` map, Alchemy `getTokenMetadata` round-trip, Trust
  Wallet CDN URL construction).
- ✓ **Pricefeed by contract** — ERC-20 prices fetched via CoinGecko's
  contract endpoint, native asset via symbol-id map seeded from the
  network catalog. No more hand-maintained `symbolToID` map.
- ✓ **ABI files** — ERC-20 + Uniswap Quoter / Router moved from
  inline Go consts to `pkg/ethkit/abis/*.json` with `//go:embed`,
  parsed once at init.

### Repository / infra

- ✓ **Git + GitHub** — repo private, master branch live.
- ✓ **CI workflows** — `.github/workflows/{ci,release,security}.yml`.
  Linux runner for `task prepare` + working-tree check; macOS runner
  reserved for tagged releases; weekly security cron with govulncheck
  + osv-scanner + flutter pub outdated.
- ✓ **Repo docs** — `README.md` (concise pitch + badges + mermaid +
  links), `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `docs/{architecture,backend,frontend,development}.md` deep dives.

### Removed for being unnecessary

- ✓ `sentry.md` — opt-in crash reporting was wired (`pkg/crashreport/`
  + `ui/lib/core/services/crash_reporter.dart`) then **deliberately
  removed** before first release. No users yet, no useful signal, and
  every telemetry surface in a wallet is a separate threat model. To
  bring it back later: see git history, the implementation was
  ~95 Go + ~130 Dart lines with sanitiser tests.
- ✓ **SQLite path config** — removed `sqlite.path` yaml setting in
  favour of a single `--data-dir` flag (Flutter passes the macOS
  app-support path in prod; dev runs use `./.dev-data`).
