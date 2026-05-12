package ethkit

import (
	"time"

	"github.com/shopspring/decimal"
)

// NativeETH is the chain-agnostic native-asset sentinel. The actual
// symbol/decimals come from the network config — this var only carries
// the empty-address shape so callers can compare via Token.IsNative()
// without importing the higher-level networks package.
//
// All other well-known tokens (USDC, WETH, USDT, …) live in the
// network catalog at config/networks/. Look them up via
// network.TokenBySymbol() / TokenByAddress() rather than hardcoding
// addresses in ethkit.
var NativeETH = Token{Symbol: "ETH", Name: "Ether", Decimals: 18}

// ── Token ─────────────────────────────────────────────────────────────────────

// Token describes an ERC-20 token (or native ETH when Address.IsZero()).
type Token struct {
	Address  Address
	Symbol   string
	Name     string
	Decimals uint8
}

// IsNative reports whether this token represents native ETH.
func (t Token) IsNative() bool {
	return t.Address.IsZero()
}

// FormatAmount returns amount.ToTokenUnits(t.Decimals) as a string with the token symbol.
func (t Token) FormatAmount(a Amount) string {
	return a.ToTokenUnits(t.Decimals).StringFixed(int32(t.Decimals)) + " " + t.Symbol
}

// ── Gas ───────────────────────────────────────────────────────────────────────

// GasInfo holds EIP-1559 fee market data for a single block.
type GasInfo struct {
	BaseFee     Amount // current base fee (burned)
	PriorityFee Amount // suggested max priority fee (tip to validator)
	MaxFee      Amount // suggested max total fee (baseFee*2 + priorityFee)
	GasPrice    Amount // legacy gas price (baseFee + priorityFee)
}

// EstimatedCost returns the cost of a transaction consuming gasUsed units.
func (g GasInfo) EstimatedCost(gasUsed uint64) Amount {
	return NewAmountFromWei(g.MaxFee.Wei()).MulInt(int64(gasUsed))
}

// ── Transaction ───────────────────────────────────────────────────────────────

// TxRequest describes a transaction to be built and sent.
type TxRequest struct {
	To       Address
	Value    Amount  // ETH value to send (zero for token-only calls)
	Data     []byte  // encoded call data (nil for plain ETH transfer)
	GasLimit uint64  // 0 = estimate automatically
	GasTip   *Amount // nil = use suggested priority fee
	GasCap   *Amount // nil = use suggested max fee
	// Kind labels the high-level intent so downstream observers can
	// reason about expected on-chain shape — e.g. "swap" produces two
	// asset transfer legs (in + out) and the watcher uses this to
	// defer emission until both legs are visible from Alchemy.
	// Free-form string; current values: "swap", "send", "approve",
	// "speedup", "cancel". Empty falls through to no special handling.
	Kind string
}

// TxStatus represents the on-chain outcome of a transaction.
type TxStatus uint8

const (
	TxStatusPending TxStatus = iota
	TxStatusSuccess
	TxStatusFailed
)

func (s TxStatus) String() string {
	switch s {
	case TxStatusPending:
		return "pending"
	case TxStatusSuccess:
		return "success"
	case TxStatusFailed:
		return "failed"
	default:
		return "unknown"
	}
}

// TxReceipt is the confirmed result of a sent transaction.
type TxReceipt struct {
	Hash        string
	Status      TxStatus
	BlockNumber uint64
	GasUsed     uint64
	GasCost     Amount // GasUsed * effective gas price in Wei
}

// ── Events ────────────────────────────────────────────────────────────────────

// BalanceUpdate is emitted by WatchBalance when an address balance changes.
type BalanceUpdate struct {
	Address Address
	Token   *Token // nil = native ETH
	Balance Amount
	Delta   Amount // positive = received, negative = sent
}

// ── Alchemy asset transfers ───────────────────────────────────────────────────

// AssetTransferCategory mirrors Alchemy's category field.
type AssetTransferCategory string

// We deliberately only declare the categories the app actually pulls
// (external + internal + erc20). NFT transfers (erc721 / erc1155) are
// out of scope at v0 — when they come back in, add the consts and
// pass them in the `Category` slice of GetAssetTransfersParams.
const (
	CategoryExternal AssetTransferCategory = "external"
	CategoryInternal AssetTransferCategory = "internal"
	CategoryERC20    AssetTransferCategory = "erc20"
)

// AssetTransfer is a single transfer entry from alchemy_getAssetTransfers.
type AssetTransfer struct {
	BlockNumber uint64
	Timestamp   time.Time
	Hash        string
	// UniqueID is "<hash>:<category>:<log_index>" — canonical Alchemy id.
	// One Ethereum tx (one Hash) can emit multiple ERC-20 transfers (e.g. a
	// Uniswap swap = USDC out + USDT in, same Hash, different UniqueID).
	UniqueID string
	From     Address
	To       Address
	Value    decimal.Decimal // human-readable units
	Asset    string          // "ETH", "USDC", etc.
	Category AssetTransferCategory
	Token    *Token // populated for ERC-20; nil for native ETH
}

// ── Swap ──────────────────────────────────────────────────────────────────────

// PoolFee represents a Uniswap v3 fee tier.
type PoolFee uint32

const (
	PoolFee01  PoolFee = 100   // 0.01% — stable pairs
	PoolFee005 PoolFee = 500   // 0.05% — ETH/USDC
	PoolFee03  PoolFee = 3000  // 0.3%  — standard
	PoolFee1   PoolFee = 10000 // 1%    — exotic
)

// SwapQuote holds the result of a Uniswap v3 quote.
type SwapQuote struct {
	TokenIn     Token
	TokenOut    Token
	AmountIn    Amount
	AmountOut   Amount
	Fee         PoolFee
	GasEstimate uint64
}

// SwapRequest describes a swap to execute.
type SwapRequest struct {
	TokenIn         Token
	TokenOut        Token
	AmountIn        Amount
	MinAmountOut    Amount  // slippage floor — revert if output < this
	Fee             PoolFee // 0 = auto-detect best pool
	DeadlineSeconds uint64  // 0 = 3 minutes

	// Optional EIP-1559 gas overrides — nil = use auto-estimated values.
	GasTip *Amount
	GasCap *Amount
}
