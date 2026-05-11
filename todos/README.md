# Roadmap

Living plans for things we agreed to do but parked. Each file is
self-contained — pick one up, read, execute, tick off. Nothing here is
strict — if priorities shift, edit the file in place.

## Index — recommended order

| # | File | Theme | Estimate |
|---|---|---|---|
| 1 | [release.md](release.md) | Git, versioning, signed DMG, auto-update | 2–3 days |
| 2 | [chainkit-prep.md](chainkit-prep.md) | EVM abstraction (prep for multi-chain) | 1–2 weeks |
| 3 | [multi-wallet.md](multi-wallet.md) | Multiple ETH wallets in one app | 4–5 days |
| 4 | [network-switcher.md](network-switcher.md) | Network selector + custom RPC + token icons | 3 days |
| 5 | [walletconnect.md](walletconnect.md) | WalletConnect v2 integration | 1 week |

## Why this order

**Release first** — now that tests are green and crash reporting is
wired, set up git + CI + signed DMG + auto-update. After this point
new versions can ship without manual `task fresh:install` rituals on
every install.

**chainkit-prep** before multi-wallet / network-switcher — both later
features assume the abstraction layer exists. Doing the heavy
refactor first means the user-facing features become config + UI work,
not architectural work.

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

- ✓ `history-parallel.md` — `errgroup` + global `semaphore.Weighted(8)`
  + single-flight `SyncForce`. `internal/usecase/history/usecase.go`.
- ✓ `pending-persistence.md` — SQLite-backed `ethkit.PendingStore` so
  the `Kind="swap"` tag survives backend restarts.
  `internal/adapter/eth/pending_store.go` + migration `00002`.
- ✓ `decomposition.md` — `mini_widget.dart` (1812 → 117 + 8 parts),
  `notification_center.dart` (1084 → 222 + 4 parts),
  `wallet_notification_panel.dart` (777 → 164 + 5 parts),
  `watcher/usecase.go` (927 → 213 + 7 siblings).
- ✓ `sentry.md` — opt-in crash reporting via `SENTRY_DSN`.
  `pkg/crashreport/` (Go) + `ui/lib/core/services/crash_reporter.dart`
  (Flutter), with sanitiser stripping addresses / hashes / mnemonics
  before upload. README updated.
- ✓ `tests.md` — backend coverage gap closed:
  `internal/usecase/notification/usecase_test.go`,
  `internal/adapter/eth/pending_store_test.go` (incl. `-race`),
  `internal/handler/grpc/handlers_test.go`,
  `internal/usecase/watcher/process_tick_test.go`. Earlier watcher
  unit tests (`classify_test.go`, `emitted_set_test.go`,
  `should_defer_test.go`, `merge_swaps_test.go`) shipped previously.
