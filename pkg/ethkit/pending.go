package ethkit

import (
	"context"
	"sync"
	"time"

	"github.com/ethereum/go-ethereum/common"
)

// PendingTx is a transaction that has been broadcast but not yet mined.
// We capture enough metadata for the UI to render a useful pending row
// (recipient, value, nonce — for Speed up / Cancel) without re-querying
// the chain.
type PendingTx struct {
	Hash        string
	From        Address
	To          Address
	Value       Amount
	Nonce       uint64
	GasTipWei   Amount
	GasCapWei   Amount
	SubmittedAt time.Time

	// Optional human-friendly label used by the UI when the tx came from a
	// known flow ("send", "swap", "approve") — saves the UI from decoding
	// the raw input data.
	Kind string
}

// PendingStore is the contract every backing implementation of the
// pending-tx registry must satisfy. The default is the in-memory
// pendingTracker below; the SQLite-backed wrapper used in production
// (internal/adapter/eth/pending_store.go) implements the same
// methods so the rest of ethkit doesn't care which it talks to.
//
//   - Add stamps a freshly-broadcast tx. Idempotent for the same hash.
//   - Remove transitions a tx to the "recent" set — it stops appearing
//     in List but stays visible to Recent for [recentTTL] so the
//     watcher's lookback can still associate freshly-mined hashes
//     with their original Kind tag.
//   - List returns currently-active (not yet removed) entries — what
//     the UI's "in flight" strip renders.
//   - Recent returns active + recently-removed entries — what the
//     watcher reads when classifying new on-chain events.
type PendingStore interface {
	Add(tx PendingTx)
	Remove(hash string)
	List() []PendingTx
	Recent() []PendingTx
}

// pendingTracker is the default in-memory implementation of
// PendingStore. Registered on broadcast, removed on receipt (success
// or revert).
//
// Lives at the ethkit.Client level so every code path that goes through
// SendTx is automatically tracked — no risk of forgetting to register
// from a new caller.
//
// `recent` holds a copy of every tx that passed through Add for
// `recentTTL` past its removal timestamp. The watcher reads from
// recent (not the live `txs` map) so it can still tag a freshly-mined
// hash as "ours" even when SendTx already returned and pending was
// cleared. Without this the 15s poll cadence races the typical 12-15s
// inclusion time and isOurs detection becomes flaky.
type pendingTracker struct {
	mu sync.RWMutex
	// Keyed by lowercased hash for O(1) lookup on receipt.
	txs    map[string]PendingTx
	recent map[string]recentEntry
}

type recentEntry struct {
	tx        PendingTx
	removedAt time.Time
}

// RecentTTL is how long a removed pending entry stays visible to
// [PendingStore.Recent]. Both the in-memory tracker and the SQLite-
// backed wrapper honour this value.
const RecentTTL = 5 * time.Minute

func newPendingTracker() *pendingTracker {
	return &pendingTracker{
		txs:    make(map[string]PendingTx),
		recent: make(map[string]recentEntry),
	}
}

// Add stamps a freshly-broadcast tx. Idempotent for the same hash.
func (p *pendingTracker) Add(tx PendingTx) {
	p.mu.Lock()
	p.txs[tx.Hash] = tx
	// Mirror into recent without `removedAt` — the GC pass treats
	// zero-time entries as "still live" and skips them.
	p.recent[tx.Hash] = recentEntry{tx: tx}
	p.mu.Unlock()
}

// Remove transitions a tx out of the active set into "recent",
// stamping the current time. Stale entries past [RecentTTL] are GC'd
// opportunistically here so the map stays bounded without a separate
// goroutine.
func (p *pendingTracker) Remove(hash string) {
	p.mu.Lock()
	if tx, ok := p.txs[hash]; ok {
		p.recent[hash] = recentEntry{tx: tx, removedAt: time.Now()}
	}
	delete(p.txs, hash)
	now := time.Now()
	for h, e := range p.recent {
		if !e.removedAt.IsZero() && now.Sub(e.removedAt) > RecentTTL {
			delete(p.recent, h)
		}
	}
	p.mu.Unlock()
}

// Recent returns every tx that's currently pending OR was pending
// within the last [RecentTTL]. The watcher reads this to associate
// freshly-observed on-chain hashes with their original [PendingTx.Kind]
// tag even after `waitForReceipt` removed them from the active set.
func (p *pendingTracker) Recent() []PendingTx {
	p.mu.RLock()
	defer p.mu.RUnlock()

	out := make([]PendingTx, 0, len(p.recent))

	now := time.Now()
	for _, e := range p.recent {
		if !e.removedAt.IsZero() && now.Sub(e.removedAt) > RecentTTL {
			continue
		}

		out = append(out, e.tx)
	}

	return out
}

// List returns a snapshot of currently-active pending transactions.
// The caller is free to filter by sender or sort however it wants —
// the tracker itself doesn't care.
func (p *pendingTracker) List() []PendingTx {
	p.mu.RLock()
	defer p.mu.RUnlock()

	out := make([]PendingTx, 0, len(p.txs))
	for _, tx := range p.txs {
		out = append(out, tx)
	}

	return out
}

// Compile-time check that the in-memory tracker satisfies the public
// interface. Swap-in implementations (e.g. SQLite-backed) reuse the
// same contract.
var _ PendingStore = (*pendingTracker)(nil)

// ListPending returns every transaction currently in the broadcast-but-not-
// mined window. Result is unsorted — callers (UI) sort by SubmittedAt.
func (c *Client) ListPending() []PendingTx {
	if c.pending == nil {
		return nil
	}

	return c.pending.List()
}

// PendingForAddress narrows the result to transactions sent from `from`.
// Useful for multi-wallet setups (currently single-wallet, but cheap to
// support upfront).
func (c *Client) PendingForAddress(from Address) []PendingTx {
	all := c.ListPending()
	out := make([]PendingTx, 0, len(all))
	for _, tx := range all {
		if tx.From.Hex() == from.Hex() {
			out = append(out, tx)
		}
	}
	return out
}

// RecentPendingForAddress is like [PendingForAddress] but also returns
// transactions that were removed from the live pending map within the
// last few minutes. The watcher uses this to associate freshly-mined
// on-chain hashes with the original submission's [PendingTx.Kind] tag,
// which can lag the actual chain inclusion by one or two ticks.
func (c *Client) RecentPendingForAddress(from Address) []PendingTx {
	if c.pending == nil {
		return nil
	}

	all := c.pending.Recent()

	out := make([]PendingTx, 0, len(all))
	for _, tx := range all {
		if tx.From.Hex() == from.Hex() {
			out = append(out, tx)
		}
	}

	return out
}

// pruneStalePending walks every entry in the tracker and removes hashes
// that are no longer relevant. Three signals trigger eviction:
//
//  1. **Mined** — `TransactionByHash` returns isPending=false. Receipt is
//     on chain.
//  2. **Dropped** — `TransactionByHash` errors (typically "not found").
//     Tx evicted from the mempool (low gas, parent tx replaced it).
//  3. **Nonce stale** — wallet's latest confirmed nonce already exceeds
//     the tracker entry's nonce. This is the only signal that catches
//     *orphaned replacements*: when a Speed-up/Cancel races the original
//     and the original mines first, the replacement stays in the mempool
//     forever as `isPending=true` — no node will mine it (nonce already
//     used) but the pool also doesn't always evict it. Comparing against
//     the wallet's confirmed nonce is decisive.
//
// Run periodically by `Client.New` so the UI's pending strip self-heals
// without forcing the user to refresh.
func (c *Client) pruneStalePending(ctx context.Context) {
	pending := c.ListPending()
	if len(pending) == 0 {
		return
	}

	// Cache the confirmed nonce per `from` address so a strip with N
	// pending txs from one wallet still only does one nonce lookup.
	confirmedNonce := make(map[string]uint64, 1)
	nonceFor := func(from Address) (uint64, bool) {
		key := from.Hex()
		if n, ok := confirmedNonce[key]; ok {
			return n, true
		}
		n, err := c.http.NonceAt(ctx, from.Common(), nil)
		if err != nil {
			return 0, false
		}
		confirmedNonce[key] = n

		return n, true
	}

	for _, tx := range pending {
		// Step 1: nonce check — fastest, decisive for orphaned replacements.
		if n, ok := nonceFor(tx.From); ok && tx.Nonce < n {
			c.pending.Remove(tx.Hash)

			continue
		}

		hash := common.HexToHash(tx.Hash)
		_, isPending, err := c.http.TransactionByHash(ctx, hash)
		switch {
		case err != nil:
			// Dropped — replacement mined or evicted by gas-price race.
			c.pending.Remove(tx.Hash)
		case !isPending:
			// Mined — receipt is on chain.
			c.pending.Remove(tx.Hash)
		}
	}
}

// startPendingJanitor kicks off the prune loop. Cancellation flows from
// the context passed to `New`, so the goroutine exits with the client.
func (c *Client) startPendingJanitor(ctx context.Context) {
	const interval = 10 * time.Second
	go func() {
		ticker := time.NewTicker(interval)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				c.pruneStalePending(ctx)
			}
		}
	}()
}
