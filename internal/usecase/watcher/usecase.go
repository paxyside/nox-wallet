package watcher

import (
	"context"
	"sync"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

const (
	defaultPollInterval = 15 * time.Second
	gasPollInterval     = 30 * time.Second

	// lowBalanceThresholdETH — alert when balance drops below this value.
	lowBalanceThresholdETH = 0.005

	// gasSpikePct — alert when baseFee rises by this fraction (50%).
	gasSpikePct = 0.50
	// gasDropPct — alert when baseFee drops by this fraction (30%).
	gasDropPct = 0.30
)

// EthClient is the subset of ethkit.Client this usecase needs.
type EthClient interface {
	WatchBalance(
		ctx context.Context,
		addr ethkit.Address,
		pollInterval time.Duration,
	) (<-chan ethkit.BalanceUpdate, error)

	GasFees(ctx context.Context) (ethkit.GasInfo, error)

	BlockNumber(ctx context.Context) (uint64, error)

	// TokenMetadata fetches name/symbol/decimals from the contract. Used to
	// enrich transfer rows for tokens not in the hardcoded wellKnownTokens
	// map (so the UI doesn't fall back to "0xabc…" as the symbol).
	TokenMetadata(ctx context.Context, addr ethkit.Address) (ethkit.Token, error)

	// GetAssetTransfers is the canonical chain-data source for the Tx
	// watcher: it returns one row per asset movement (ETH / ERC-20 /
	// internal) tagged with the parent tx hash, so we can group all
	// movements of a single user-action ("Swap A → B" = 2 legs, same
	// hash) into one notification.
	GetAssetTransfers(
		ctx context.Context,
		params ethkit.GetAssetTransfersParams,
	) (ethkit.AssetTransfersPage, error)

	// RecentPendingForAddress returns active and recently-cleared
	// pending entries (within the last few minutes). The watcher uses
	// this to tag freshly-observed on-chain hashes as `IsOurs` and to
	// read the original submission's `Kind` tag — both signals must
	// stay available even after `waitForReceipt` drops the entry from
	// the live pending map, since the watcher's poll cadence (every
	// 15s) can race a 12-15s mine time.
	RecentPendingForAddress(addr ethkit.Address) []ethkit.PendingTx
}

// AddressProvider returns the currently loaded wallet address.
type AddressProvider interface {
	LoadedAddress() ethkit.Address
}

// Usecase starts all watchers and broadcasts events to all subscribers.
type Usecase struct {
	log          logger.Log
	eth          EthClient
	wallet       AddressProvider
	sink         NotificationSink // optional; nil = no persistence
	mu           sync.RWMutex
	subscribers  []chan WalletEvent
	pollInterval time.Duration

	// tokenMetaCache stores resolved (name, symbol, decimals) per contract
	// so we don't re-hit the chain on every transfer of the same token.
	// Process-local; reset on restart.
	metaMu         sync.RWMutex
	tokenMetaCache map[string]ethkit.Token
}

// New constructs the watcher. `sink` is optional — pass nil if event
// persistence isn't wired (e.g. in narrow unit tests). When non-nil,
// every emitted event is also written through the sink in addition to
// being broadcast to Subscribe channels; sink failures are logged but
// never block the live broadcast.
func New(log logger.Log, eth EthClient, wallet AddressProvider, sink NotificationSink) *Usecase {
	return &Usecase{
		log:            log,
		eth:            eth,
		wallet:         wallet,
		sink:           sink,
		pollInterval:   defaultPollInterval,
		tokenMetaCache: make(map[string]ethkit.Token),
	}
}

// Subscribe returns a channel that receives all wallet events and an unsubscribe
// function that must be called when the subscriber is done.
func (u *Usecase) Subscribe() (<-chan WalletEvent, func()) {
	ch := make(chan WalletEvent, 64)

	u.mu.Lock()
	u.subscribers = append(u.subscribers, ch)
	u.mu.Unlock()

	unsub := func() {
		u.mu.Lock()
		defer u.mu.Unlock()

		for i, sub := range u.subscribers {
			if sub == ch {
				u.subscribers = append(u.subscribers[:i], u.subscribers[i+1:]...)

				close(ch)

				return
			}
		}
	}

	return ch, unsub
}

// Start blocks until a wallet is loaded and then runs the monitor loop
// until ctx is cancelled. Polls the AddressProvider every two seconds
// while no wallet is present — covers the fresh-install / DB-wipe case
// where the app boots before the user has imported a wallet. Without
// this, an early return here would leave the process running with no
// active watchers, and notifications would silently stop appearing
// until the next full restart.
func (u *Usecase) Start(ctx context.Context) error {
	addr := u.waitForWallet(ctx)
	if addr.IsZero() {
		// ctx cancelled before a wallet showed up.
		return nil
	}

	u.log.Info("watcher: starting all monitors", "address", addr.Short())

	var wg sync.WaitGroup

	// 1. ETH balance watcher — drives low-balance latch only. The chain-
	//    level "balance changed" event is no longer surfaced as a separate
	//    notification (gas burns from token / approve txs were generating
	//    confusing duplicates). The Tx watcher below covers the meaningful
	//    "ETH sent / received" cases via Alchemy.
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := u.watchBalanceForLowAlert(ctx, addr); err != nil && ctx.Err() == nil {
			u.log.Error("watcher: ETH monitor stopped", "error", err)
		}
	}()

	// 2. Canonical transaction watcher: polls Alchemy `getAssetTransfers`,
	//    groups movements by tx hash, classifies role (Send / Receive /
	//    Swap / Approve / SelfTransfer), and emits one rich event per tx.
	wg.Add(1)
	go func() {
		defer wg.Done()
		u.watchTransactions(ctx, addr)
	}()

	// 3. Gas alerts (independent — purely market-state).
	wg.Add(1)
	go func() {
		defer wg.Done()
		u.watchGas(ctx)
	}()

	wg.Wait()
	u.log.Info("watcher: all monitors stopped", "address", addr.Short())

	return nil
}

// waitForWallet polls the address provider until a non-zero address is
// observed or ctx is cancelled. Returns the zero address only on
// cancellation. Logs once on entry so cold-start logs don't get spammed.
func (u *Usecase) waitForWallet(ctx context.Context) ethkit.Address {
	if addr := u.wallet.LoadedAddress(); !addr.IsZero() {
		return addr
	}

	u.log.Info("watcher: no wallet loaded yet, waiting for import")

	const pollInterval = 2 * time.Second

	ticker := time.NewTicker(pollInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ethkit.Address{}
		case <-ticker.C:
			if addr := u.wallet.LoadedAddress(); !addr.IsZero() {
				return addr
			}
		}
	}
}
