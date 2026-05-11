package watcher

import (
	"context"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// NotificationSink is the optional persistence target for emitted
// events. Decoupled from the concrete notification.Usecase so the
// watcher stays unaware of storage details (and so tests can inject a
// stub). Implementations must be safe for concurrent use; the watcher
// calls Save from multiple goroutines (one per monitor loop).
//
// Save returns the freshly minted row ID so the watcher can stamp it
// onto the in-memory WalletEvent before broadcasting — that lets the
// gRPC stream carry per-row identity matching what ListNotifications
// would later return, so the UI can key its read/unread state by ID
// regardless of which path the event came from.
type NotificationSink interface {
	Save(ctx context.Context, kind EventKind, txHash string, payload []byte, isOurs bool) (string, error)
}

// EventKind identifies what happened.
type EventKind uint8

// Numeric values are stable on disk — `notifications.kind` stores the
// uint8 directly, so reordering or reusing values would silently
// remap historical rows. Values 0 and 1 are reserved (formerly
// KindEthTransfer / KindTokenTransfer, removed in the canonical
// transaction-event refactor); a cleanup migration drops any rows
// still tagged with those.
const (
	KindGasAlert    EventKind = 2 // gas price spike or drop
	KindLowBalance  EventKind = 3 // ETH balance fell below threshold
	KindTransaction EventKind = 4 // an on-chain tx involving the wallet (canonical)
)

// WalletEvent is the unified event emitted on the Events() channel.
//
// `ID` is the persisted notification row ID stamped by the sink. Empty
// for events that bypass persistence (no sink configured, or marshal
// failed) — UI clients should treat empty-ID events as ephemeral.
type WalletEvent struct {
	ID   string
	Kind EventKind

	GasAlert    *GasAlertData
	LowBalance  *LowBalanceData
	Transaction *TransactionData
}

// GasAlertData carries gas price change info.
type GasAlertData struct {
	IsSpike      bool    // true = spike, false = drop
	CurrentGwei  float64 // baseFee in Gwei
	PreviousGwei float64
}

// LowBalanceData is emitted once when ETH drops below the warning threshold.
type LowBalanceData struct {
	Address ethkit.Address
	ETH     ethkit.Amount
}

// TxRole classifies what the transaction *means* for the wallet. The UI
// uses this to pick a notification template ("Sent X to Y", "Swapped
// A → B", etc.) and to decide whether to render an OS toast at all
// (we suppress for `IsOurs` user-initiated txs since the result modal
// already covered that case).
type TxRole uint8

const (
	RoleUnknown TxRole = iota
	RoleSendETH
	RoleReceiveETH
	RoleSendToken
	RoleReceiveToken
	RoleSwap
	RoleSelfTransfer
	RoleApprove
)

// AssetMovement is one in/out leg of a TransactionData. A simple Send
// produces a single outgoing leg; a Swap produces two legs (one out, one
// in); an Approve produces zero (no asset movement, only allowance update).
type AssetMovement struct {
	Symbol          string
	Name            string
	ContractAddress string // empty for native ETH
	Amount          string // human-readable, decimals already applied
	IsOutgoing      bool
	Counterparty    string // address of the other side of this leg
}

// TransactionData carries everything the UI needs to render one rich
// notification per on-chain tx. Replaces the chain-level Eth/Token
// transfer events that used to fire 2-4 separate notifications per
// user-action.
type TransactionData struct {
	TxHash      string
	Role        TxRole
	Movements   []AssetMovement
	IsOurs      bool // hash was in pendingTracker → we initiated this
	BlockNumber uint64
	Timestamp   time.Time
}

// PendingChecker is implemented by anything that can answer "is this
// hash currently or recently in the local pending-tx registry?". The
// watcher uses it to tag outgoing transactions as `IsOurs` and to
// read their original `Kind` tag (for the swap-leg deferral logic).
type PendingChecker interface {
	RecentPendingForAddress(addr ethkit.Address) []ethkit.PendingTx
}
