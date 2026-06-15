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
	// enrich transfer rows for tokens the TokenLookup couldn't resolve
	// (so the UI doesn't fall back to "0xabc…" as the symbol).
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
	// the lives pending map, since the watcher's poll cadence (every
	// 15s) can race a 12-15s mine time.
	RecentPendingForAddress(addr ethkit.Address) []ethkit.PendingTx
}

// AddressProvider returns the currently loaded wallet address.
type AddressProvider interface {
	LoadedAddress() ethkit.Address
}

// TokenLookup resolves token metadata by lowercase contract address.
// The watcher tries this before falling back to an on-chain
// TokenMetadata RPC, so well-known tokens (from the network catalog)
// never incur an extra round-trip per transfer.
type TokenLookup func(addressLower string) (ethkit.Token, bool)

// Usecase starts all watchers and broadcasts events to all subscribers.
type Usecase struct {
	log          logger.Log
	eth          EthClient
	wallet       AddressProvider
	sink         NotificationSink // optional; nil = no persistence
	tokenLookup  TokenLookup      // optional; nil = always fall back to eth.TokenMetadata
	mu           sync.RWMutex
	subscribers  []chan WalletEvent
	pollInterval time.Duration

	// tokenMetaCache stores resolved (name, symbol, decimals) per contract
	// so we don't re-hit the chain on every transfer of the same token.
	// Process-local; reset on restart.
	metaMu         sync.RWMutex
	tokenMetaCache map[string]ethkit.Token
}

// Option configures the watcher.
type Option func(*Usecase)

// WithTokenLookup wires a fast in-memory resolver for well-known
// tokens. Production wires this with `network.TokenByAddress`; tests
// can leave it unset and let the stub EthClient.TokenMetadata answer.
func WithTokenLookup(lookup TokenLookup) Option {
	return func(u *Usecase) { u.tokenLookup = lookup }
}

// New constructs the watcher. `sink` is optional — pass nil if event
// persistence isn't wired (e.g. in narrow unit tests). When non-nil,
// every emitted event is also written through the sink in addition to
// being broadcast to Subscribe channels; sink failures are logged but
// never block the live broadcast.
func New(
	log logger.Log,
	eth EthClient,
	wallet AddressProvider,
	sink NotificationSink,
	opts ...Option,
) *Usecase {
	u := &Usecase{
		log:            log,
		eth:            eth,
		wallet:         wallet,
		sink:           sink,
		pollInterval:   defaultPollInterval,
		tokenMetaCache: make(map[string]ethkit.Token),
	}

	for _, opt := range opts {
		opt(u)
	}

	return u
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
// until ctx is canceled. Polls the AddressProvider every two seconds
// while no wallet is present — covers the fresh-install / DB-wipe case
// where the app boots before the user has imported a wallet. Without
// this, an early return here would leave the process running with no
// active watchers, and notifications would silently stop appearing
// until the next full restart.
func (u *Usecase) Start(ctx context.Context) error {
	var wg sync.WaitGroup

	// Gas alerts are market-state, address-independent — run once for
	// the whole session, never restarted on a wallet change.
	wg.Add(1)
	go func() {
		defer wg.Done()
		u.watchGas(ctx)
	}()

	// Address-scoped monitors (balance + transactions) (re)start whenever
	// the loaded wallet address changes — initial import OR a Danger-Zone
	// replace. runAddressMonitors owns that retarget loop.
	wg.Add(1)
	go func() {
		defer wg.Done()
		u.runAddressMonitors(ctx)
	}()

	wg.Wait()
	u.log.Info("watcher: all monitors stopped")

	return nil
}

// runAddressMonitors keeps the address-scoped monitors pointed at the
// currently-loaded wallet. On a wallet replace the in-memory address
// flips (walletUC.persistWallet reassigns it), so we cancel the old
// wallet's monitors and restart on the new address — otherwise the
// watcher would keep polling the previous wallet forever and the new
// one would never get notifications.
func (u *Usecase) runAddressMonitors(ctx context.Context) {
	for {
		addr := u.waitForWallet(ctx)
		if addr.IsZero() {
			return // ctx canceled before a wallet showed up
		}

		u.log.Info("watcher: starting address monitors", "address", addr.Short())

		// Child ctx scoped to this address — canceled when the address
		// changes so both monitors below unwind cleanly.
		monCtx, cancel := context.WithCancel(ctx)

		var mwg sync.WaitGroup
		mwg.Add(2)

		// ETH balance watcher — drives the low-balance latch only.
		go func() {
			defer mwg.Done()
			if err := u.watchBalanceForLowAlert(monCtx, addr); err != nil && monCtx.Err() == nil {
				u.log.Error("watcher: ETH monitor stopped", "error", err)
			}
		}()

		// Canonical transaction watcher: polls Alchemy getAssetTransfers,
		// groups movements by tx hash, classifies role, emits one event
		// per tx.
		go func() {
			defer mwg.Done()
			u.watchTransactions(monCtx, addr)
		}()

		u.waitForAddressChange(ctx, addr)
		cancel()
		mwg.Wait()
		u.log.Info("watcher: address monitors stopped", "address", addr.Short())

		if ctx.Err() != nil {
			return
		}
	}
}

// waitForAddressChange blocks until the loaded wallet address differs
// from current (a replace happened) or ctx is canceled.
func (u *Usecase) waitForAddressChange(ctx context.Context, current ethkit.Address) {
	const pollInterval = 2 * time.Second

	ticker := time.NewTicker(pollInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if u.wallet.LoadedAddress() != current {
				return
			}
		}
	}
}

// waitForWallet polls the address provider until a non-zero address is
// observed or ctx is canceled. Returns the zero address only on
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
