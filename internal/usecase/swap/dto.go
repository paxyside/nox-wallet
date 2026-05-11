package swap

import "github.com/paxyside/nox-wallet/pkg/ethkit"

type QuoteParams struct {
	TokenIn  ethkit.Token
	TokenOut ethkit.Token
	AmountIn ethkit.Amount
	Fee      ethkit.PoolFee // 0 = auto
}

type ExecuteParams struct {
	TokenIn     ethkit.Token
	TokenOut    ethkit.Token
	AmountIn    ethkit.Amount
	SlippageBps uint64 // basis points, e.g. 50 = 0.5%
	Fee         ethkit.PoolFee

	// Optional gas overrides. Both nil = use auto-estimated values.
	GasTip *ethkit.Amount
	GasCap *ethkit.Amount
}
