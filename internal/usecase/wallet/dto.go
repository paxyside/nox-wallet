package wallet

import (
	"github.com/shopspring/decimal"

	"github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// ── import ────────────────────────────────────────────────────────────────────

type ImportPrivateKeyParams struct {
	PrivateKeyHex string
	Label         string
}

type ImportMnemonicParams struct {
	Mnemonic       string
	DerivationPath string // empty → DefaultDerivationPath
	Label          string
}

type ImportKeystoreParams struct {
	KeystoreJSON []byte
	Passphrase   string
	Label        string
}

// ── generate ──────────────────────────────────────────────────────────────────

type GenerateWalletParams struct {
	Label string
}

type GenerateWalletResult struct {
	Address  ethkit.Address
	Mnemonic string // shown once, stored in keychain
}

// ── reveal ────────────────────────────────────────────────────────────────────

type RevealSecretResult struct {
	Secret     string
	SecretType entity.SecretType
}

// ── export ────────────────────────────────────────────────────────────────────

type ExportKeystoreParams struct {
	Passphrase string
}

// ── balances / fees ───────────────────────────────────────────────────────────

type GetBalancesParams struct {
	Address ethkit.Address
	Tokens  []ethkit.Token
}

type TokenBalance struct {
	Token   ethkit.Token
	Balance ethkit.Amount
}

type GetBalancesResult struct {
	ETH    ethkit.Amount
	Tokens []TokenBalance
}

type GetGasFeesResult struct {
	GasInfo     ethkit.GasInfo
	TransferETH ethkit.Amount
	BlockNumber uint64
	ChainID     int64
}

// ── send ──────────────────────────────────────────────────────────────────────

type SendETHParams struct {
	To    ethkit.Address
	Value ethkit.Amount
	Gas   GasOverride
}

// SendTokenParams takes the token contract address and a human-readable amount
// (e.g. 100.5 USDC). The usecase resolves the token's on-chain decimals before
// converting to wei — callers MUST NOT pre-convert.
type SendTokenParams struct {
	TokenAddress ethkit.Address
	To           ethkit.Address
	Amount       decimal.Decimal
	Gas          GasOverride
}

// GasOverride lets callers replace the auto-estimated EIP-1559 gas params.
// Both fields are optional: nil means "use the network suggestion". Both
// are denominated in gwei — keep the unit consistent with how the user
// types it in the UI gas selector.
type GasOverride struct {
	PriorityGwei *decimal.Decimal // tip to validators
	MaxGwei      *decimal.Decimal // total fee per gas (cap)
}

// IsZero reports whether the override carries any values.
func (g GasOverride) IsZero() bool {
	return g.PriorityGwei == nil && g.MaxGwei == nil
}

// ToTipCap converts the override into the (tip, cap) wei pair the swap
// usecase passes through to ethkit. Both nil = let the network suggestion
// stand.
func (g GasOverride) ToTipCap() (*ethkit.Amount, *ethkit.Amount) {
	var tip, gasCap *ethkit.Amount
	if g.PriorityGwei != nil {
		tip = new(ethkit.NewAmountFromGwei(*g.PriorityGwei))
	}
	if g.MaxGwei != nil {
		gasCap = new(ethkit.NewAmountFromGwei(*g.MaxGwei))
	}
	return tip, gasCap
}
