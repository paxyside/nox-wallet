package watcher

import (
	"context"
	"strings"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// TransactionData ready to ship over gRPC.
func (u *Usecase) buildTransactionEvent(
	ctx context.Context,
	wallet ethkit.Address,
	hash string,
	legs []ethkit.AssetTransfer,
	ourPending map[string]struct{},
) *TransactionData {
	movements := make([]AssetMovement, 0, len(legs))
	walletHex := strings.ToLower(wallet.Hex())

	var (
		blockNumber uint64
		ts          time.Time
	)

	for _, leg := range legs {
		movements = append(movements, u.buildMovement(ctx, walletHex, leg))

		if leg.BlockNumber > blockNumber {
			blockNumber = leg.BlockNumber
		}
		if leg.Timestamp.After(ts) {
			ts = leg.Timestamp
		}
	}

	role := classifyRole(movements, walletHex)
	_, isOurs := ourPending[strings.ToLower(hash)]

	// Alchemy occasionally omits `blockTimestamp` on freshly-mined
	// transfers (the indexer races the metadata fetch). Without a
	// fallback here, the proto Timestamp goes out as the zero value and
	// the client renders "Jan 1" (1970-01-01) in the notification panel.
	// "Right now" is a closer approximation than the unix epoch when
	// the leg is something we just observed in the latest block range.
	if ts.IsZero() {
		ts = time.Now().UTC()
	}

	return &TransactionData{
		TxHash:      hash,
		Role:        role,
		Movements:   movements,
		IsOurs:      isOurs,
		BlockNumber: blockNumber,
		Timestamp:   ts,
	}
}

// buildMovement converts one Alchemy transfer leg into a domain
// AssetMovement: classifies in/out direction, resolves the token
// metadata (with on-chain fallback for unknown contracts), and shorts
// the counterparty so the panel doesn't render a 42-char hex.
func (u *Usecase) buildMovement(
	ctx context.Context,
	walletHex string,
	leg ethkit.AssetTransfer,
) AssetMovement {
	fromHex := strings.ToLower(leg.From.Hex())
	toHex := strings.ToLower(leg.To.Hex())

	isOutgoing := fromHex == walletHex
	counterparty := fromHex
	if isOutgoing {
		counterparty = toHex
	}

	symbol, name, contract := u.resolveAsset(ctx, leg)

	return AssetMovement{
		Symbol:          symbol,
		Name:            name,
		ContractAddress: contract,
		Amount:          leg.Value.String(),
		IsOutgoing:      isOutgoing,
		Counterparty:    counterparty,
	}
}

// resolveAsset returns the (symbol, name, contract) triple for one
// transfer leg. ETH legs come back with empty contract; ERC-20 legs
// either use Alchemy's enriched fields or fall back to an on-chain
// `TokenMetadata` lookup when the response was missing symbol/name
// (typical for scam / non-standard contracts).
func (u *Usecase) resolveAsset(
	ctx context.Context,
	leg ethkit.AssetTransfer,
) (symbol, name, contract string) {
	symbol = leg.Asset
	if leg.Token == nil {
		return symbol, "", ""
	}

	symbol = leg.Token.Symbol
	name = leg.Token.Name
	contract = strings.ToLower(leg.Token.Address.Hex())

	if symbol != "" && name != "" {
		return symbol, name, contract
	}

	meta := u.lookupTokenMeta(ctx, leg.Token.Address)
	if meta == nil {
		return symbol, name, contract
	}
	if symbol == "" {
		symbol = meta.Symbol
	}
	if name == "" {
		name = meta.Name
	}

	return symbol, name, contract
}

// lookupTokenMeta is the cache-aware fetcher we already use for the old
// token watcher. Reused here for the same "Unknown" → real-symbol
// resolution.
func (u *Usecase) lookupTokenMeta(ctx context.Context, addr ethkit.Address) *ethkit.Token {
	key := strings.ToLower(addr.Hex())

	if u.tokenLookup != nil {
		if meta, ok := u.tokenLookup(key); ok {
			return &meta
		}
	}

	u.metaMu.RLock()
	cached, hit := u.tokenMetaCache[key]
	u.metaMu.RUnlock()
	if hit {
		return &cached
	}

	meta, err := u.eth.TokenMetadata(ctx, addr)
	if err != nil {
		return nil
	}

	u.metaMu.Lock()
	u.tokenMetaCache[key] = meta
	u.metaMu.Unlock()

	return &meta
}

// classifyRole picks the canonical TxRole from the set of movements.
// One outgoing native leg → SendETH; one incoming → ReceiveETH; one
// outgoing token → SendToken; etc. A tx with both outgoing and incoming
// legs (typical Uniswap swap) becomes Swap. From == To for the wallet
