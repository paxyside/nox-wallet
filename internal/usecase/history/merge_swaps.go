package history

import (
	"strings"

	"github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
)

// mergeSwapLegs collapses two transfers with the same hash where one leg is
// outbound from the wallet and the other inbound to the wallet, with different
// assets — into a single synthetic SWAP entry. The wallet's outbound leg
// becomes the "tokenIn" half; the inbound leg becomes "tokenOut".
//
// The previous version required at least one leg to touch a hard-coded set of
// DEX router addresses (Uniswap, 1inch, 0x). That whitelist couldn't scale —
// every new aggregator (CoW, Paraswap, 0x v2 settlement, MEV-boost rebates,
// random routers via Uniswap UniversalRouter) broke the heuristic. The shape
// itself is the strongest signal: a regular send produces one leg
// (wallet→peer); a regular receive produces one leg (peer→wallet); only a
// swap-like operation atomically produces both legs in one hash with
// different assets.
//
// Single-leg / non-DEX transactions pass through unchanged. Edge cases:
//   - hash with only one leg loaded (page boundary) → emitted as-is, raw row;
//   - more than two legs (rare, e.g. swap-then-transfer aggregator) → emit
//     all legs raw; presenting them as one swap would be misleading.
//
// The returned slice preserves chronological order: each merged swap takes
// the timestamp of the earliest leg in the group.
func mergeSwapLegs(txs []*entity.Transaction, walletAddress string) []*entity.Transaction {
	if len(txs) == 0 {
		return txs
	}

	walletLower := strings.ToLower(walletAddress)

	// Group rows by hash, preserving first-seen order.
	type group struct {
		hash    string
		entries []*entity.Transaction
	}

	groupIdx := make(map[string]int, len(txs))
	groups := make([]group, 0, len(txs))

	for _, t := range txs {
		idx, ok := groupIdx[t.Hash]
		if !ok {
			groupIdx[t.Hash] = len(groups)
			groups = append(groups, group{hash: t.Hash, entries: []*entity.Transaction{t}})

			continue
		}

		groups[idx].entries = append(groups[idx].entries, t)
	}

	out := make([]*entity.Transaction, 0, len(txs))

	for _, g := range groups {
		merged := tryMergeSwap(g.entries, walletLower)
		if merged != nil {
			out = append(out, merged)
			continue
		}

		out = append(out, g.entries...)
	}

	return out
}

// tryMergeSwap returns a synthetic swap entry when the group looks like a
// single swap: exactly two legs, one leg sends from the wallet and one
// receives into it, with different asset symbols. Otherwise returns nil so
// the caller emits the raw legs.
func tryMergeSwap(entries []*entity.Transaction, walletLower string) *entity.Transaction {
	if len(entries) != 2 {
		return nil
	}

	// Identify the outbound leg (wallet -> ...) and the inbound leg (... -> wallet).
	var sent, recv *entity.Transaction

	for _, e := range entries {
		fromLower := strings.ToLower(e.From.Hex())
		toLower := strings.ToLower(e.To.Hex())

		switch {
		case fromLower == walletLower && sent == nil:
			sent = e
		case toLower == walletLower && recv == nil:
			recv = e
		}
	}

	if sent == nil || recv == nil {
		return nil
	}

	// Same asset on both legs is almost certainly a wrap/unwrap (e.g. ETH↔WETH
	// shows up as one ETH leg + one WETH leg with same hash) or a self-transfer
	// — keep these as raw legs so the user sees the actual movement.
	if strings.EqualFold(sent.Asset, recv.Asset) {
		return nil
	}

	// Build a synthetic row. Use the receive leg as the base so the row
	// inherits a recognisable identity (block, hash, gas), then layer
	// swap-specific fields on top.
	swap := *recv
	swap.IsSwap = true
	swap.TokenInSym = sent.Asset
	swap.TokenInVal = sent.Value.String()
	swap.TokenOutSym = recv.Asset
	swap.TokenOutVal = recv.Value.String()

	// Preserve earliest timestamp in case of clock skew between legs.
	if sent.Timestamp.Before(recv.Timestamp) {
		swap.Timestamp = sent.Timestamp
	}

	return &swap
}
