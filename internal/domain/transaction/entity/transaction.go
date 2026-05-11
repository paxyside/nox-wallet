package entity

import (
	"time"

	"github.com/shopspring/decimal"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

type Transaction struct {
	ID string
	// UniqueID is Alchemy's "<hash>:<category>:<log_index>" — disambiguates
	// multi-leg events (e.g. a swap = USDC out + OTHER in, same Hash,
	// different UniqueID). Used as the upsert key in storage.
	UniqueID    string
	Hash        string
	From        ethkit.Address
	To          ethkit.Address
	Value       decimal.Decimal // human-readable units
	Asset       string          // "ETH", "USDC", etc.
	Category    ethkit.AssetTransferCategory
	BlockNumber uint64
	Timestamp   time.Time
	CachedAt    time.Time

	// Gas fee fields — populated asynchronously from eth_getTransactionReceipt.
	// Empty string means "not yet fetched".
	GasFeeEth string // e.g. "0.000042"
	GasFeeUsd string // e.g. "$0.11"

	// Swap synthetic fields — populated by the history usecase after grouping
	// two same-hash legs that touch a known DEX router. Persisted rows always
	// have these empty; the merger fills them on read. UI uses IsSwap to pick
	// the swap rendering path.
	IsSwap      bool
	TokenInSym  string // sent token, e.g. "USDC"
	TokenInVal  string // sent amount, e.g. "27.39"
	TokenOutSym string // received token, e.g. "USDT"
	TokenOutVal string // received amount, e.g. "26.91"
}
