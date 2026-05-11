package watcher

import (
	"context"
	"fmt"
	"strings"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// fromAddress / toAddress per call. Results are merged.
func (u *Usecase) fetchTransfers(
	ctx context.Context,
	addr ethkit.Address,
	fromBlock, toBlock string,
	categories []ethkit.AssetTransferCategory,
	maxCount int,
) ([]ethkit.AssetTransfer, error) {
	out, err := u.eth.GetAssetTransfers(ctx, ethkit.GetAssetTransfersParams{
		FromAddress:  &addr,
		FromBlock:    fromBlock,
		ToBlock:      toBlock,
		Categories:   categories,
		MaxCount:     maxCount,
		WithMetadata: true,
	})
	if err != nil {
		return nil, fmt.Errorf("outgoing transfers: %w", err)
	}

	in, err := u.eth.GetAssetTransfers(ctx, ethkit.GetAssetTransfersParams{
		ToAddress:    &addr,
		FromBlock:    fromBlock,
		ToBlock:      toBlock,
		Categories:   categories,
		MaxCount:     maxCount,
		WithMetadata: true,
	})
	if err != nil {
		return nil, fmt.Errorf("incoming transfers: %w", err)
	}

	merged := make([]ethkit.AssetTransfer, 0, len(out.Transfers)+len(in.Transfers))
	merged = append(merged, out.Transfers...)
	merged = append(merged, in.Transfers...)

	return merged, nil
}

// groupByHash buckets transfer legs by their parent tx hash. Alchemy
// can return the same row twice (once via FromAddress query, once via
// ToAddress) when wallet appears on both ends — we de-dup by UniqueID.
func groupByHash(transfers []ethkit.AssetTransfer) map[string][]ethkit.AssetTransfer {
	out := make(map[string][]ethkit.AssetTransfer)
	seen := make(map[string]struct{})

	for _, t := range transfers {
		if _, dup := seen[t.UniqueID]; dup {
			continue
		}
		seen[t.UniqueID] = struct{}{}
		out[t.Hash] = append(out[t.Hash], t)
	}

	return out
}

// indexPendingByHash turns the slice of pending txs into a hash → tx
// map for O(1) IsOurs lookup plus access to the `Kind` tag (used by
// the watcher to know whether to expect 2 legs for swaps). Hashes are
// normalised to lowercase to dodge case mismatches between Alchemy and
// the local tracker.
func indexPendingByHash(pending []ethkit.PendingTx) map[string]ethkit.PendingTx {
	out := make(map[string]ethkit.PendingTx, len(pending))
	for _, p := range pending {
		out[strings.ToLower(p.Hash)] = p
	}

	return out
}
