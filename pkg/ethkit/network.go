package ethkit

// Network captures the chain-level constants ethkit needs at runtime —
// chain id plus the protocol addresses we call. The app's higher-level
// `config/networks` package owns the full per-chain catalog (token
// metadata, CoinGecko ids, …); this struct is the minimal slice ethkit
// itself needs.
//
// Wire it in via WithNetwork() at New(); the swap codepath reads from
// here instead of package-level vars so a future multi-chain
// implementation only changes the construction-site, not the
// implementation.
type Network struct {
	ChainID int64

	// Uniswap V3 protocol addresses on this chain. Empty addresses
	// mean "swap path disabled" — QuoteSwap / Swap will fail at the
	// resolve step rather than reaching out to the zero address.
	UniswapQuoterV2     Address
	UniswapSwapRouter02 Address
	UniswapWrappedETH   Address
}

// WithNetwork attaches a Network bundle to the client. Without it,
// the swap entry points return ErrNoNetwork.
func WithNetwork(n Network) Option {
	return func(c *Client) { c.network = n }
}

// ErrNoNetwork is returned by swap codepaths when the client was
// constructed without a Network — used by tests and by code that wants
// to opt into the wallet/transfer subset of ethkit only.
var ErrNoNetwork = constError("ethkit: no Network configured (use WithNetwork)")

type constError string

func (e constError) Error() string { return string(e) }
