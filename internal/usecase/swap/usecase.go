package swap

import (
	"context"

	"github.com/paxyside/nox-wallet/internal/usecase"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

type EthClient interface {
	QuoteSwap(
		ctx context.Context,
		tokenIn, tokenOut ethkit.Token,
		amountIn ethkit.Amount,
		fee ethkit.PoolFee,
	) (ethkit.SwapQuote, error)
	Swap(ctx context.Context, w *ethkit.Wallet, req ethkit.SwapRequest) (ethkit.TxReceipt, error)
	TokenMetadata(ctx context.Context, addr ethkit.Address) (ethkit.Token, error)
	GasFees(ctx context.Context) (ethkit.GasInfo, error)
}

type WalletProvider interface {
	LoadedAddress() ethkit.Address
	EthWallet() *ethkit.Wallet
}

type Usecase struct {
	*usecase.BaseUsecase
	log    logger.Log
	eth    EthClient
	wallet WalletProvider
}

func New(base *usecase.BaseUsecase, log logger.Log, eth EthClient, wallet WalletProvider) *Usecase {
	return &Usecase{BaseUsecase: base, log: log, eth: eth, wallet: wallet}
}

// ResolveToken returns a Token with correct decimals for the given address string.
// "ETH" / "" → native ETH (18 decimals).
// Any other string is treated as an ERC-20 contract address and metadata is fetched on-chain.
func (u *Usecase) ResolveToken(ctx context.Context, addr string) (ethkit.Token, error) {
	if addr == "" || addr == "ETH" {
		return ethkit.Token{Symbol: "ETH", Decimals: 18}, nil
	}

	a, err := ethkit.NewAddress(addr)
	if err != nil {
		return ethkit.Token{}, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid token address")
	}

	tok, err := u.eth.TokenMetadata(ctx, a)
	if err != nil {
		return ethkit.Token{}, liberrors.Wrapf(err, liberrors.CodeInternal, "token metadata")
	}

	return tok, nil
}

func (u *Usecase) GasFees(ctx context.Context) (ethkit.GasInfo, error) {
	return u.eth.GasFees(ctx)
}

func (u *Usecase) Quote(ctx context.Context, p QuoteParams) (ethkit.SwapQuote, error) {
	if err := validateSwapPair(p.TokenIn, p.TokenOut); err != nil {
		return ethkit.SwapQuote{}, err
	}

	quote, err := u.eth.QuoteSwap(ctx, p.TokenIn, p.TokenOut, p.AmountIn, p.Fee)
	if err != nil {
		return ethkit.SwapQuote{}, liberrors.Wrapf(err, liberrors.CodeInternal, "swap quote")
	}

	return quote, nil
}

// validateSwapPair short-circuits the obviously-invalid pairs that Uniswap
// can't quote at all (same token both sides; ETH↔WETH which is wrap/unwrap,
// not a swap, and has no v3 pool). Without this they get reported as opaque
// internal errors from the Quoter contract — turning them into 4xx-class
// validation errors lets the UI show a useful message.
func validateSwapPair(in, out ethkit.Token) error {
	if in.IsNative() && out.Symbol == "WETH" {
		return liberrors.New(liberrors.CodeInvalidArgument,
			"ETH and WETH are 1:1 — use wrap/unwrap, not swap")
	}
	if out.IsNative() && in.Symbol == "WETH" {
		return liberrors.New(liberrors.CodeInvalidArgument,
			"ETH and WETH are 1:1 — use wrap/unwrap, not swap")
	}
	if !in.IsNative() && !out.IsNative() &&
		in.Address.Hex() == out.Address.Hex() {
		return liberrors.New(liberrors.CodeInvalidArgument,
			"tokenIn and tokenOut must be different")
	}
	return nil
}

func (u *Usecase) Execute(ctx context.Context, p ExecuteParams) (ethkit.TxReceipt, error) {
	w := u.wallet.EthWallet()
	if w == nil {
		return ethkit.TxReceipt{}, liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}

	if err := validateSwapPair(p.TokenIn, p.TokenOut); err != nil {
		return ethkit.TxReceipt{}, err
	}

	quote, err := u.eth.QuoteSwap(ctx, p.TokenIn, p.TokenOut, p.AmountIn, p.Fee)
	if err != nil {
		return ethkit.TxReceipt{}, liberrors.Wrapf(err, liberrors.CodeInternal, "pre-swap quote")
	}

	minOut := ethkit.SlippageAmount(quote.AmountOut, p.SlippageBps)

	return u.eth.Swap(ctx, w, ethkit.SwapRequest{
		TokenIn:      p.TokenIn,
		TokenOut:     p.TokenOut,
		AmountIn:     p.AmountIn,
		MinAmountOut: minOut,
		Fee:          p.Fee,
		GasTip:       p.GasTip,
		GasCap:       p.GasCap,
	})
}
