package token

import "github.com/paxyside/nox-wallet/pkg/ethkit"

type AddTokenParams struct {
	ContractAddress ethkit.Address
	// Symbol/Name/Decimals populated from chain if empty.
	Symbol   string
	Name     string
	Decimals uint8
}

type TokenWithBalance struct {
	ID       string
	Token    ethkit.Token
	Balance  ethkit.Amount
	IsPinned bool
	IsHidden bool
	// Market data — may be zero-value if unavailable.
	PriceUSD       float64
	Change24hPct   float64
	ChangePositive bool
	Sparkline7d    []float64
	Sparkline30d   []float64
	BalanceUSD     float64
}
