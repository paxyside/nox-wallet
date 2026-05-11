package grpc

import (
	"context"
	"fmt"
	"math/big"
	"strconv"

	"github.com/shopspring/decimal"

	swapuc "github.com/paxyside/nox-wallet/internal/usecase/swap"
	tokenuc "github.com/paxyside/nox-wallet/internal/usecase/token"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbswap "github.com/paxyside/nox-wallet/proto/gen/go/wallet/swap"
)

func (h *Handler) QuoteSwap(ctx context.Context, req *pb.QuoteSwapRequest) (*pb.QuoteSwapResponse, error) {
	tokenIn, err := h.swap.ResolveToken(ctx, req.GetTokenIn())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid token_in"))
	}

	tokenOut, err := h.swap.ResolveToken(ctx, req.GetTokenOut())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid token_out"))
	}

	d, err := decimal.NewFromString(req.GetAmountIn())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid amount_in"))
	}

	quote, err := h.swap.Quote(ctx, swapuc.QuoteParams{
		TokenIn:  tokenIn,
		TokenOut: tokenOut,
		AmountIn: ethkit.NewAmountFromTokenUnits(d, tokenIn.Decimals),
		Fee:      poolFeeFromProto(req.GetFee()),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	// Best-effort: compute gas cost in USD and capture maxFeeGwei.
	// gasCostUsd = gasUnits * maxFeeWei / 1e18 * ethPriceUSD
	gasCostUSD := ""

	maxFeeGwei := ""
	if gasInfo, err := h.swap.GasFees(ctx); err == nil {
		maxFeeGwei = gasInfo.MaxFee.ToGwei().StringFixed(2)

		ethPrice := h.prices.GetPrice(ctx, "ETH")
		if ethPrice > 0 {
			wei := new(big.Int).Mul(
				new(big.Int).SetUint64(quote.GasEstimate),
				gasInfo.MaxFee.Wei(),
			)
			costETH, _ := decimal.NewFromBigInt(wei, 0).
				Div(decimal.New(1, 18)).
				Float64()

			costUSD := costETH * ethPrice
			if costUSD < 0.01 {
				gasCostUSD = fmt.Sprintf("$%.4f", costUSD)
			} else {
				gasCostUSD = fmt.Sprintf("$%.2f", costUSD)
			}
		}
	}

	return &pb.QuoteSwapResponse{
		Quote: &pbswap.SwapQuote{
			AmountOut:      quote.AmountOut.ToTokenUnits(tokenOut.Decimals).String(),
			AmountOutRaw:   quote.AmountOut.String(),
			PriceImpactBps: "0",
			GasEstimate:    strconv.FormatUint(quote.GasEstimate, 10),
			GasCostUsd:     gasCostUSD,
			MaxFeeGwei:     maxFeeGwei,
		},
	}, nil
}

func (h *Handler) ExecuteSwap(ctx context.Context, req *pb.ExecuteSwapRequest) (*pb.ExecuteSwapResponse, error) {
	tokenIn, err := h.swap.ResolveToken(ctx, req.GetTokenIn())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid token_in"))
	}

	tokenOut, err := h.swap.ResolveToken(ctx, req.GetTokenOut())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid token_out"))
	}

	d, err := decimal.NewFromString(req.GetAmountIn())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err, liberrors.CodeInvalidArgument, "invalid amount_in"))
	}

	gas := gasOptionsFromProto(req.GetGas())
	gasTip, gasCap := gas.ToTipCap()

	receipt, err := h.swap.Execute(ctx, swapuc.ExecuteParams{
		TokenIn:     tokenIn,
		TokenOut:    tokenOut,
		AmountIn:    ethkit.NewAmountFromTokenUnits(d, tokenIn.Decimals),
		SlippageBps: 50,
		Fee:         poolFeeFromProto(req.GetFee()),
		GasTip:      gasTip,
		GasCap:      gasCap,
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	// Make sure both ends of the swap end up on the watchlist before
	// the history sync runs. Without this, an Alchemy-driven sync
	// filters ERC-20 transfers by `watchedContracts` and silently
	// drops the half of the swap whose token isn't tracked yet —
	// notably common in round-trip swaps (USDC → USDT → USDC) where
	// the intermediate token's balance lands back at zero, so token
	// auto-discovery (which keys off non-zero balances) never picks
	// it up. The user then sees two un-merged "Sent / Received" rows
	// instead of two SWAP rows. Both calls are idempotent so re-runs
	// are cheap.
	h.ensureSwapTokensWatchedAndSync(ctx, tokenIn, tokenOut)

	return &pb.ExecuteSwapResponse{Receipt: receiptToProto(receipt)}, nil
}

// ensureSwapTokensWatchedAndSync guarantees both legs of the swap will
// be visible in subsequent history syncs. Runs in a detached goroutine
// so the RPC response isn't blocked on the (slow) Alchemy round-trip.
func (h *Handler) ensureSwapTokensWatchedAndSync(
	_ context.Context,
	tokenIn, tokenOut ethkit.Token,
) {
	addr := h.wallet.LoadedAddress()
	if addr.IsZero() {
		return
	}

	// We deliberately fork to a fresh context here: the caller's ctx
	// is bound to the gRPC request and cancels the moment the response
	// is sent — but the post-swap sync runs minutes-long Alchemy pulls
	// that the user expects to keep going independently of the RPC.
	//
	//nolint:contextcheck,gosec // detached context is intentional, see above.
	go func() {
		bgCtx := context.Background() //nolint:contextcheck // see comment above.

		for _, t := range []ethkit.Token{tokenIn, tokenOut} {
			if t.Address.IsZero() {
				// Native ETH legs aren't watchlist tokens; their
				// transfers come from the unfiltered ETH-category
				// query in syncFromAlchemy.
				continue
			}

			if _, err := h.token.EnsureWatched(bgCtx, tokenuc.AddTokenParams{
				ContractAddress: t.Address,
				Symbol:          t.Symbol,
				Name:            t.Name,
				Decimals:        t.Decimals,
			}); err != nil {
				h.l.WarnContext(bgCtx, "post-swap ensure-watched failed",
					"contract", t.Address.Hex(), "error", err)
			}
		}

		// Re-fetch the (possibly expanded) watchlist so the sync
		// includes the newly-added side(s).
		var watchedContracts []ethkit.Address

		if list, err := h.token.List(bgCtx); err == nil {
			watchedContracts = make([]ethkit.Address, 0, len(list))
			for _, w := range list {
				watchedContracts = append(watchedContracts, w.Token.Address)
			}
		}

		if err := h.history.SyncForce(bgCtx, addr, watchedContracts); err != nil {
			h.l.WarnContext(bgCtx, "post-swap history sync failed", "error", err)
		}
	}()
}

func poolFeeFromProto(fee pbswap.PoolFee) ethkit.PoolFee {
	switch fee {
	case pbswap.PoolFee_POOL_FEE_100:
		return ethkit.PoolFee01
	case pbswap.PoolFee_POOL_FEE_500:
		return ethkit.PoolFee005
	case pbswap.PoolFee_POOL_FEE_3000:
		return ethkit.PoolFee03
	case pbswap.PoolFee_POOL_FEE_10000:
		return ethkit.PoolFee1
	case pbswap.PoolFee_POOL_FEE_UNSPECIFIED:
		return ethkit.PoolFee03 // sensible default for unspecified — middle tier.
	default:
		return ethkit.PoolFee03
	}
}
