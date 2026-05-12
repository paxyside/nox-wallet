package watcher

import (
	"context"
	"strconv"
	"strings"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// ── Token transfer watcher ────────────────────────────────────────────────────

// watchTransactions polls Alchemy `getAssetTransfers` once per
// `pollInterval`, groups every new movement (ETH external / internal /
// ERC-20) by tx hash, classifies the role from the (sent, received) leg
// counts + token type, and emits one `KindTransaction` event per hash.
//
// This replaces the old per-leg `watchETH` / `watchTokens` pair. The
// payoff is a 1:1 mapping between user-actions and notifications: a
// Swap is one event with two movements, not "ETH sent" + "USDC
// received"; a token send is one event, not "USDC sent" + "ETH sent
// (gas)". Approves carry no asset movement at all and surface as a
// SELF_TRANSFER-style ApproveEvent (handled in classifyRole).
func (u *Usecase) watchTransactions(ctx context.Context, addr ethkit.Address) {
	const (
		fetchPageSize = 50
		// lookbackBlocks lets each tick re-query the previous few blocks
		// so legs that Alchemy hadn't indexed on the prior tick (its
		// indexer can lag the chain head by 5-15 seconds for fresh logs)
		// can still be picked up. Combined with `emitted` dedup below
		// the overlap is free.
		lookbackBlocks = 3
		// maxDeferral caps how long we'll hold back an isOurs swap
		// waiting for the second leg before giving up and emitting
		// whatever we have. 30 s is comfortably longer than worst-case
		// Alchemy lag and short enough that the user doesn't perceive
		// the notification as missing.
		maxDeferral = 30 * time.Second
		// emittedCap bounds the dedup set; FIFO-evicted. 512 hashes
		// covers ~hours of activity at our poll interval, more than
		// enough — re-emitting an old hash after eviction is harmless
		// because Alchemy stops returning it past the lookback window.
		emittedCap = 512
	)

	categories := []ethkit.AssetTransferCategory{
		ethkit.CategoryExternal,
		ethkit.CategoryInternal,
		ethkit.CategoryERC20,
	}

	// Cursor: first poll just records the chain head; subsequent polls
	// query `(prev - lookback + 1, current]`. The lookback overlap is
	// what makes deferred swap emission viable.
	var lastBlock uint64
	initialized := false

	emitted := newEmittedSet(emittedCap)
	deferred := make(map[string]time.Time)

	ticker := time.NewTicker(u.pollInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			cur, err := u.eth.BlockNumber(ctx)
			if err != nil {
				u.log.Warn("watcher: block number poll", "error", err)

				continue
			}

			if !initialized {
				lastBlock = cur
				initialized = true

				continue
			}
			if cur <= lastBlock {
				continue
			}

			// Re-query a small overlap with the previous tick so late-indexed transfers from Alchemy can still be picked up. On
			// the very first iteration after init `lastBlock` may be
			// less than the lookback window — clamp.
			fromBlockNum := uint64(1)
			if lastBlock > lookbackBlocks {
				fromBlockNum = lastBlock - lookbackBlocks + 1
			}

			fromBlock := "0x" + strconv.FormatUint(fromBlockNum, 16)
			toBlock := "0x" + strconv.FormatUint(cur, 16)

			transfers, fetchErr := u.fetchTransfers(ctx, addr, fromBlock, toBlock, categories, fetchPageSize)
			if fetchErr != nil {
				u.log.Warn("watcher: getAssetTransfers", "error", fetchErr)
				// Don't advance the cursor — retry on the next tick.
				continue
			}

			u.processTick(ctx, addr, transfers, emitted, deferred, maxDeferral)

			// GC stale deferred entries that were never observed again
			// (rare — would require Alchemy to drop a hash from its
			// index after returning it once). Avoids a slow leak.
			for hash, firstSeen := range deferred {
				if time.Since(firstSeen) > maxDeferral*2 {
					delete(deferred, hash)
				}
			}

			lastBlock = cur
		}
	}
}

// processTick walks the transfers fetched on the current tick, decides
// per-hash whether to emit immediately, defer (probable swap waiting on
// its second leg), or skip (already emitted in a prior tick). Extracted
// from `watchTransactions` so the outer ticker loop stays readable —
// gocognit budget on the call site was the trigger.
func (u *Usecase) processTick(
	ctx context.Context,
	addr ethkit.Address,
	transfers []ethkit.AssetTransfer,
	emitted *emittedSet,
	deferred map[string]time.Time,
	maxDeferral time.Duration,
) {
	grouped := groupByHash(transfers)
	ourPending := indexPendingByHash(u.eth.RecentPendingForAddress(addr))

	ourPendingHashes := make(map[string]struct{}, len(ourPending))
	for h := range ourPending {
		ourPendingHashes[h] = struct{}{}
	}

	for hash, legs := range grouped {
		if emitted.has(hash) {
			continue
		}

		txEvent := u.buildTransactionEvent(ctx, addr, hash, legs, ourPendingHashes)

		if u.shouldDefer(hash, txEvent, ourPending, deferred, maxDeferral) {
			continue
		}

		u.emitAndPersist(ctx, WalletEvent{Kind: KindTransaction, Transaction: txEvent})
		emitted.add(hash)
		delete(deferred, hash)
	}
}

// shouldDefer returns true when the caller should hold off emission
// for this hash and try again on the next tick. Triggered when the
// pending tracker tagged the hash as a "swap" but only one direction
// of legs is currently visible — typically Alchemy lag. Times out
// after `maxDeferral` and lets the loop emit whatever's available.
func (u *Usecase) shouldDefer(
	hash string,
	txEvent *TransactionData,
	ourPending map[string]ethkit.PendingTx,
	deferred map[string]time.Time,
	maxDeferral time.Duration,
) bool {
	pending := ourPending[strings.ToLower(hash)]
	looksIncomplete := pending.Kind == "swap" &&
		txEvent.Role != RoleSwap &&
		txEvent.Role != RoleSelfTransfer
	if !looksIncomplete {
		return false
	}

	firstSeen, alreadyDeferred := deferred[hash]
	if !alreadyDeferred {
		deferred[hash] = time.Now()

		return true
	}

	if time.Since(firstSeen) < maxDeferral {
		return true
	}

	u.log.Warn("watcher: emitting incomplete swap after timeout",
		"hash", hash,
		"role", txEvent.Role,
		"waited", time.Since(firstSeen).String(),
	)

	return false
}

// emittedSet is a bounded FIFO set used to dedup hashes across tick
// boundaries when the lookback window overlaps previously-seen blocks.
// Plain map with a slice for eviction order; not concurrent-safe by
// design — only accessed from the watcher's monitor goroutine.
type emittedSet struct {
	set   map[string]struct{}
	order []string
	cap   int
}

func newEmittedSet(maxSize int) *emittedSet {
	return &emittedSet{
		set:   make(map[string]struct{}, maxSize),
		order: make([]string, 0, maxSize),
		cap:   maxSize,
	}
}

func (e *emittedSet) has(h string) bool {
	_, ok := e.set[h]

	return ok
}

func (e *emittedSet) add(h string) {
	if _, ok := e.set[h]; ok {
		return
	}

	if len(e.order) >= e.cap {
		evict := e.order[0]
		e.order = e.order[1:]
		delete(e.set, evict)
	}

	e.set[h] = struct{}{}
	e.order = append(e.order, h)
}

// fetchTransfers issues two parallel queries (out + in) to cover both
