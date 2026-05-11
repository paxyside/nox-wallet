# Multi-wallet support

Today the app holds exactly one wallet at a time. `walletUC.wallet` is a
singleton. `LoadFromKeychain` loads the first stored record. UI has no
account-switcher.

This pairs well with [`chainkit-prep.md`](chainkit-prep.md) — once we
abstract chains, "wallet" becomes "wallet per chain", and the
account-switcher naturally shows e.g. "ETH-Mainnet 0x61bE…" /
"BNB 0x61bE…" / "Polygon 0xAB12…".

## Schema

`wallets` table already has the right shape (one row per wallet,
unique by address). What's missing:

```sql
ALTER TABLE wallets ADD COLUMN is_active INTEGER NOT NULL DEFAULT 0;
CREATE INDEX idx_wallets_active ON wallets(is_active);
```

Exactly one row should be `is_active=1` at any time. Switching
wallets is `UPDATE wallets SET is_active=0 WHERE is_active=1; UPDATE
wallets SET is_active=1 WHERE id=?` in a single transaction.

Keychain key naming changes too: today there's one entry under
`wallet_secret`. Need per-wallet keys: `wallet_secret_<wallet_id>`.
Migration moves the existing entry to the new naming.

## Backend changes

### `walletUC`

```go
type Usecase struct {
    // …
    wallet *ethkit.Wallet  // active wallet — gets reloaded on switch
}

func (u *Usecase) ListWallets(ctx) ([]*entity.Wallet, error)
func (u *Usecase) SetActiveWallet(ctx, walletID string) error  // reloads from keychain
func (u *Usecase) DeleteWallet(ctx, walletID string) error
```

`SetActiveWallet`:

1. Load the new wallet from DB + keychain.
2. Acquire `u.mu` (new — currently no lock on `wallet` field).
3. Replace `u.wallet`.
4. Notify subscribers — watcher restarts its monitors against the new
   address.

### Watcher

Watcher today loads address once at boot via `waitForWallet`. Needs an
"address change" signal:

```go
type AddressProvider interface {
    LoadedAddress() ethkit.Address
    AddressChanges() <-chan ethkit.Address  // new
}
```

On address change the watcher cancels its current monitor goroutines
and restarts them with the new address. SQLite tables filter by
address already (`from_address` / `to_address` indexes), so no schema
work needed for transactions.

### gRPC

```proto
service WalletService {
  rpc ListWallets(ListWalletsRequest) returns (ListWalletsResponse);
  rpc SetActiveWallet(SetActiveWalletRequest) returns (SetActiveWalletResponse);
  rpc DeleteWallet(DeleteWalletRequest) returns (DeleteWalletResponse);
  rpc UpdateWalletLabel(UpdateWalletLabelRequest) returns (UpdateWalletLabelResponse);
}

message Wallet {
  string id           = 1;
  string address      = 2;
  string label        = 3;
  bool   is_active    = 4;
  google.protobuf.Timestamp created_at = 5;
}
```

## Frontend changes

- New screen `features/wallets/` with the list, "Add wallet"
  (mnemonic / private key / generate), per-row Set Active / Rename /
  Delete actions.
- Account-switcher widget in the dashboard header — replaces the
  current static `PaxyWALLET` label with a dropdown showing label +
  address.
- `walletExistsProvider` becomes `activeWalletProvider`.
- All keepAlive providers that scope to wallet identity
  (`homeDataProvider`, `tokensNotifierProvider`, `historyProvider`,
  `recentActivityProvider`, `notificationHistoryProvider`) need to be
  invalidated on wallet switch — there's already a wallet-existence
  watcher in `main.dart`, generalize it.

## Lock per wallet?

Open question: Touch-ID lock today is global. Should each wallet have
its own lock state, or single lock for all?

I'd say single lock for the app — same pattern as 1Password (vault
unlock unlocks all items). Per-wallet lock adds friction without much
security benefit since they all live under the same OS user.

## Tests

- Switch wallet → balances refresh, history empties + repopulates
- Delete active wallet → app falls back to first remaining, or
  onboarding screen if none left
- Concurrent `SetActiveWallet` calls — second one wins, no torn state

## Done when

- [ ] User can hold N wallets, switch between them via account
  selector, see correct balances per wallet
- [ ] Watcher correctly re-binds on switch (no events from prior
  wallet leaking)
- [ ] All keepAlive providers invalidated on switch
- [ ] Notification history is per-wallet (filter by `wallet_address`
  in `notifications` table — needs schema migration)
- [ ] No race conditions detected by `go test -race`
