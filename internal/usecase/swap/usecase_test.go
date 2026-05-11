package swap

import (
	"context"
	stderrors "errors"
	"io"
	"log/slog"
	"math/big"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/paxyside/nox-wallet/internal/usecase"
	"github.com/paxyside/nox-wallet/pkg/common/idx"
	"github.com/paxyside/nox-wallet/pkg/common/timex"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

type mockEthClient struct {
	quoteSwapFn     func(ctx context.Context, in, out ethkit.Token, amt ethkit.Amount, fee ethkit.PoolFee) (ethkit.SwapQuote, error)
	swapFn          func(ctx context.Context, w *ethkit.Wallet, req ethkit.SwapRequest) (ethkit.TxReceipt, error)
	tokenMetadataFn func(ctx context.Context, addr ethkit.Address) (ethkit.Token, error)
	gasFeesFn       func(ctx context.Context) (ethkit.GasInfo, error)
}

func (m *mockEthClient) QuoteSwap(
	ctx context.Context,
	in, out ethkit.Token,
	amt ethkit.Amount,
	fee ethkit.PoolFee,
) (ethkit.SwapQuote, error) {
	return m.quoteSwapFn(ctx, in, out, amt, fee)
}

func (m *mockEthClient) Swap(ctx context.Context, w *ethkit.Wallet, req ethkit.SwapRequest) (ethkit.TxReceipt, error) {
	return m.swapFn(ctx, w, req)
}

func (m *mockEthClient) TokenMetadata(ctx context.Context, addr ethkit.Address) (ethkit.Token, error) {
	return m.tokenMetadataFn(ctx, addr)
}

func (m *mockEthClient) GasFees(ctx context.Context) (ethkit.GasInfo, error) {
	return m.gasFeesFn(ctx)
}

type mockWalletProvider struct {
	addr ethkit.Address
	w    *ethkit.Wallet
}

func (m *mockWalletProvider) LoadedAddress() ethkit.Address { return m.addr }
func (m *mockWalletProvider) EthWallet() *ethkit.Wallet     { return m.w }

func newTestUsecase(eth EthClient, wp WalletProvider) *Usecase {
	base := usecase.NewBaseUsecase(idx.New(), timex.NewClock())
	log := logger.New(func(o *logger.Options) { o.Writer = io.Discard; o.Level = slog.LevelError })
	return New(base, log, eth, wp)
}

func TestResolveToken(t *testing.T) {
	t.Run("ETH literal", func(t *testing.T) {
		u := newTestUsecase(&mockEthClient{}, &mockWalletProvider{})
		tok, err := u.ResolveToken(context.Background(), "ETH")
		require.NoError(t, err)
		assert.Equal(t, "ETH", tok.Symbol)
		assert.Equal(t, uint8(18), tok.Decimals)
	})
	t.Run("empty string", func(t *testing.T) {
		u := newTestUsecase(&mockEthClient{}, &mockWalletProvider{})
		tok, err := u.ResolveToken(context.Background(), "")
		require.NoError(t, err)
		assert.Equal(t, "ETH", tok.Symbol)
		assert.Equal(t, uint8(18), tok.Decimals)
	})
	t.Run("erc20 fetches metadata", func(t *testing.T) {
		want := ethkit.Token{Symbol: "USDC", Decimals: 6}
		var calledWith ethkit.Address
		eth := &mockEthClient{
			tokenMetadataFn: func(_ context.Context, addr ethkit.Address) (ethkit.Token, error) {
				calledWith = addr
				return want, nil
			},
		}
		u := newTestUsecase(eth, &mockWalletProvider{})
		got, err := u.ResolveToken(context.Background(), "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
		require.NoError(t, err)
		assert.Equal(t, want.Symbol, got.Symbol)
		assert.False(t, calledWith.IsZero())
	})
	t.Run("invalid address", func(t *testing.T) {
		u := newTestUsecase(&mockEthClient{}, &mockWalletProvider{})
		_, err := u.ResolveToken(context.Background(), "not-hex")
		require.Error(t, err)
		assert.Equal(t, liberrors.CodeInvalidArgument, liberrors.GetCode(err))
	})
	t.Run("metadata error", func(t *testing.T) {
		eth := &mockEthClient{
			tokenMetadataFn: func(_ context.Context, _ ethkit.Address) (ethkit.Token, error) {
				return ethkit.Token{}, stderrors.New("rpc")
			},
		}
		u := newTestUsecase(eth, &mockWalletProvider{})
		_, err := u.ResolveToken(context.Background(), "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
		require.Error(t, err)
		assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
	})
}

func TestQuote(t *testing.T) {
	want := ethkit.SwapQuote{AmountOut: ethkit.NewAmountFromWei(big.NewInt(42))}
	eth := &mockEthClient{
		quoteSwapFn: func(_ context.Context, _, _ ethkit.Token, _ ethkit.Amount, _ ethkit.PoolFee) (ethkit.SwapQuote, error) {
			return want, nil
		},
	}
	u := newTestUsecase(eth, &mockWalletProvider{})
	got, err := u.Quote(context.Background(), QuoteParams{})
	require.NoError(t, err)
	assert.Equal(t, want.AmountOut.Wei().String(), got.AmountOut.Wei().String())
}

func TestQuoteError(t *testing.T) {
	eth := &mockEthClient{
		quoteSwapFn: func(_ context.Context, _, _ ethkit.Token, _ ethkit.Amount, _ ethkit.PoolFee) (ethkit.SwapQuote, error) {
			return ethkit.SwapQuote{}, stderrors.New("x")
		},
	}
	u := newTestUsecase(eth, &mockWalletProvider{})
	_, err := u.Quote(context.Background(), QuoteParams{})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
}

func TestExecute_NoWallet(t *testing.T) {
	u := newTestUsecase(&mockEthClient{}, &mockWalletProvider{w: nil})
	_, err := u.Execute(context.Background(), ExecuteParams{})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeFailedPrecondition, liberrors.GetCode(err))
}

func TestExecute_HappyPath(t *testing.T) {
	w, err := ethkit.NewWalletFromHex("0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")
	require.NoError(t, err)

	quoteOut := ethkit.NewAmountFromWei(big.NewInt(1_000_000))
	eth := &mockEthClient{
		quoteSwapFn: func(_ context.Context, _, _ ethkit.Token, _ ethkit.Amount, _ ethkit.PoolFee) (ethkit.SwapQuote, error) {
			return ethkit.SwapQuote{AmountOut: quoteOut}, nil
		},
		swapFn: func(_ context.Context, _ *ethkit.Wallet, req ethkit.SwapRequest) (ethkit.TxReceipt, error) {
			// 50 bps slippage on 1_000_000 → 995_000.
			assert.Equal(t, "995000", req.MinAmountOut.Wei().String())
			return ethkit.TxReceipt{Hash: "0x1"}, nil
		},
	}
	u := newTestUsecase(eth, &mockWalletProvider{w: w})

	rcpt, err := u.Execute(context.Background(), ExecuteParams{SlippageBps: 50})
	require.NoError(t, err)
	assert.Equal(t, "0x1", rcpt.Hash)
}

func TestExecute_QuoteError(t *testing.T) {
	w, err := ethkit.NewWalletFromHex("0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")
	require.NoError(t, err)

	eth := &mockEthClient{
		quoteSwapFn: func(_ context.Context, _, _ ethkit.Token, _ ethkit.Amount, _ ethkit.PoolFee) (ethkit.SwapQuote, error) {
			return ethkit.SwapQuote{}, stderrors.New("rpc")
		},
	}
	u := newTestUsecase(eth, &mockWalletProvider{w: w})

	_, err = u.Execute(context.Background(), ExecuteParams{})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
}

func TestGasFeesDelegation(t *testing.T) {
	want := ethkit.GasInfo{}
	eth := &mockEthClient{
		gasFeesFn: func(_ context.Context) (ethkit.GasInfo, error) { return want, nil },
	}
	u := newTestUsecase(eth, &mockWalletProvider{})
	_, err := u.GasFees(context.Background())
	require.NoError(t, err)
}
