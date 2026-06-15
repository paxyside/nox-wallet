package wallet

import (
	"context"
	stderrors "errors"
	"io"
	"log/slog"
	"math/big"
	"testing"

	"github.com/shopspring/decimal"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	"github.com/paxyside/nox-wallet/internal/usecase"
	"github.com/paxyside/nox-wallet/pkg/common/idx"
	"github.com/paxyside/nox-wallet/pkg/common/timex"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

// ── mocks ────────────────────────────────────────────────────────────────────

type mockEthClient struct {
	ethBalanceFn     func(ctx context.Context, addr ethkit.Address) (ethkit.Amount, error)
	tokenBalanceFn   func(ctx context.Context, addr ethkit.Address, token ethkit.Token) (ethkit.Amount, error)
	gasFeesFn        func(ctx context.Context) (ethkit.GasInfo, error)
	blockNumberFn    func(ctx context.Context) (uint64, error)
	gasEstWithFeesFn func(ctx context.Context, req ethkit.TxRequest, sender ethkit.Address) (uint64, ethkit.GasInfo, ethkit.Amount, error)
	sendTxFn         func(ctx context.Context, w *ethkit.Wallet, req ethkit.TxRequest) (ethkit.TxReceipt, error)
	transferTokenFn  func(ctx context.Context, w *ethkit.Wallet, token ethkit.Token, to ethkit.Address, amount ethkit.Amount) (ethkit.TxReceipt, error)
	tokenMetadataFn  func(ctx context.Context, addr ethkit.Address) (ethkit.Token, error)
}

func (m *mockEthClient) ETHBalance(ctx context.Context, addr ethkit.Address) (ethkit.Amount, error) {
	return m.ethBalanceFn(ctx, addr)
}

func (m *mockEthClient) TokenBalance(
	ctx context.Context,
	addr ethkit.Address,
	token ethkit.Token,
) (ethkit.Amount, error) {
	return m.tokenBalanceFn(ctx, addr, token)
}

func (m *mockEthClient) GasFees(ctx context.Context) (ethkit.GasInfo, error) {
	return m.gasFeesFn(ctx)
}

func (m *mockEthClient) ChainID() *big.Int { return big.NewInt(1) }

func (m *mockEthClient) ResolveENS(_ context.Context, _ string) (ethkit.Address, error) {
	return ethkit.Address{}, ethkit.ErrENSNotFound
}

func (m *mockEthClient) ReverseENS(_ context.Context, _ ethkit.Address) (string, error) {
	return "", ethkit.ErrENSNotFound
}

func (m *mockEthClient) SpeedUpTx(_ context.Context, _ *ethkit.Wallet, _ string) (string, error) {
	return "", nil
}

func (m *mockEthClient) CancelTx(_ context.Context, _ *ethkit.Wallet, _ string) (string, error) {
	return "", nil
}

func (m *mockEthClient) SimulateTx(
	_ context.Context,
	_ ethkit.Address,
	_ ethkit.TxRequest,
) (ethkit.SimulationResult, error) {
	return ethkit.SimulationResult{}, nil
}

func (m *mockEthClient) BlockNumber(ctx context.Context) (uint64, error) {
	return m.blockNumberFn(ctx)
}

func (m *mockEthClient) GasEstimateWithFees(
	ctx context.Context,
	req ethkit.TxRequest,
	sender ethkit.Address,
) (uint64, ethkit.GasInfo, ethkit.Amount, error) {
	return m.gasEstWithFeesFn(ctx, req, sender)
}

func (m *mockEthClient) SendTx(ctx context.Context, w *ethkit.Wallet, req ethkit.TxRequest) (ethkit.TxReceipt, error) {
	return m.sendTxFn(ctx, w, req)
}

func (m *mockEthClient) TransferToken(
	ctx context.Context,
	w *ethkit.Wallet,
	token ethkit.Token,
	to ethkit.Address,
	amount ethkit.Amount,
) (ethkit.TxReceipt, error) {
	return m.transferTokenFn(ctx, w, token, to, amount)
}

func (m *mockEthClient) TransferTokenWithGas(
	ctx context.Context,
	w *ethkit.Wallet,
	token ethkit.Token,
	to ethkit.Address,
	amount ethkit.Amount,
	_ *ethkit.Amount,
	_ *ethkit.Amount,
) (ethkit.TxReceipt, error) {
	return m.transferTokenFn(ctx, w, token, to, amount)
}

func (m *mockEthClient) TokenMetadata(ctx context.Context, addr ethkit.Address) (ethkit.Token, error) {
	return m.tokenMetadataFn(ctx, addr)
}

func (m *mockEthClient) PendingForAddress(_ ethkit.Address) []ethkit.PendingTx {
	return nil
}

type mockWalletService struct {
	saveFn   func(ctx context.Context, w *entity.Wallet) error
	getFn    func(ctx context.Context) (*entity.Wallet, error)
	deleteFn func(ctx context.Context) error
	resetFn  func(ctx context.Context) error
}

func (m *mockWalletService) Save(ctx context.Context, w *entity.Wallet) error {
	return m.saveFn(ctx, w)
}

func (m *mockWalletService) Get(ctx context.Context) (*entity.Wallet, error) { return m.getFn(ctx) }
func (m *mockWalletService) Delete(ctx context.Context) error                { return m.deleteFn(ctx) }

func (m *mockWalletService) Reset(ctx context.Context) error {
	if m.resetFn == nil {
		return nil
	}
	return m.resetFn(ctx)
}

// ── helpers ───────────────────────────────────────────────────────────────────

func newTestUsecase(eth EthClient, svc WalletService) *Usecase {
	base := usecase.NewBaseUsecase(idx.New(), timex.NewClock())
	log := logger.New(func(o *logger.Options) { o.Writer = io.Discard; o.Level = slog.LevelError })
	return &Usecase{BaseUsecase: base, log: log, eth: eth, svc: svc}
}

// ── tests ─────────────────────────────────────────────────────────────────────

func TestGetBalances(t *testing.T) {
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")
	tok1 := ethkit.Token{
		Symbol:   "USDC",
		Decimals: 6,
		Address:  ethkit.MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
	}
	tok2 := ethkit.Token{
		Symbol:   "BAD",
		Decimals: 6,
		Address:  ethkit.MustAddress("0xdAC17F958D2ee523a2206206994597C13D831ec7"),
	}

	eth := &mockEthClient{
		ethBalanceFn: func(_ context.Context, _ ethkit.Address) (ethkit.Amount, error) {
			return ethkit.NewAmountFromWei(big.NewInt(1000)), nil
		},
		tokenBalanceFn: func(_ context.Context, _ ethkit.Address, token ethkit.Token) (ethkit.Amount, error) {
			if token.Symbol == "BAD" {
				return ethkit.ZeroAmount, stderrors.New("rpc fail")
			}
			return ethkit.NewAmountFromWei(big.NewInt(2000)), nil
		},
	}
	u := newTestUsecase(eth, nil)

	res, err := u.GetBalances(context.Background(), GetBalancesParams{
		Address: addr, Tokens: []ethkit.Token{tok1, tok2},
	})
	require.NoError(t, err)
	assert.Equal(t, "1000", res.ETH.Wei().String())
	require.Len(t, res.Tokens, 1, "BAD token failure should be tolerated and skipped")
	assert.Equal(t, "USDC", res.Tokens[0].Token.Symbol)
}

func TestGetBalances_ETHError(t *testing.T) {
	eth := &mockEthClient{
		ethBalanceFn: func(_ context.Context, _ ethkit.Address) (ethkit.Amount, error) {
			return ethkit.ZeroAmount, stderrors.New("eth err")
		},
	}
	u := newTestUsecase(eth, nil)
	_, err := u.GetBalances(context.Background(), GetBalancesParams{Address: ethkit.ZeroAddress})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
}

func TestGetGasFees(t *testing.T) {
	gas := ethkit.GasInfo{
		BaseFee:     ethkit.NewAmountFromGwei(decimal.NewFromInt(20)),
		PriorityFee: ethkit.NewAmountFromGwei(decimal.NewFromInt(2)),
		MaxFee:      ethkit.NewAmountFromGwei(decimal.NewFromInt(40)),
		GasPrice:    ethkit.NewAmountFromGwei(decimal.NewFromInt(22)),
	}
	eth := &mockEthClient{
		gasFeesFn:     func(_ context.Context) (ethkit.GasInfo, error) { return gas, nil },
		blockNumberFn: func(_ context.Context) (uint64, error) { return 12345, nil },
	}
	u := newTestUsecase(eth, nil)

	res, err := u.GetGasFees(context.Background())
	require.NoError(t, err)
	assert.Equal(t, uint64(12345), res.BlockNumber)
	// TransferETH should equal MaxFee * 21000.
	expected := gas.EstimatedCost(21_000)
	assert.True(t, res.TransferETH.Equal(expected))
}

func TestGetGasFees_ErrorPaths(t *testing.T) {
	t.Run("gas error", func(t *testing.T) {
		eth := &mockEthClient{
			gasFeesFn:     func(_ context.Context) (ethkit.GasInfo, error) { return ethkit.GasInfo{}, stderrors.New("x") },
			blockNumberFn: func(_ context.Context) (uint64, error) { return 1, nil },
		}
		u := newTestUsecase(eth, nil)
		_, err := u.GetGasFees(context.Background())
		require.Error(t, err)
	})
	t.Run("block error", func(t *testing.T) {
		eth := &mockEthClient{
			gasFeesFn:     func(_ context.Context) (ethkit.GasInfo, error) { return ethkit.GasInfo{}, nil },
			blockNumberFn: func(_ context.Context) (uint64, error) { return 0, stderrors.New("y") },
		}
		u := newTestUsecase(eth, nil)
		_, err := u.GetGasFees(context.Background())
		require.Error(t, err)
	})
}

func TestLoadedAddressNoWallet(t *testing.T) {
	u := newTestUsecase(&mockEthClient{}, nil)
	assert.True(t, u.LoadedAddress().IsZero())
	assert.Nil(t, u.EthWallet())
}

func TestSendETH_NoWallet(t *testing.T) {
	u := newTestUsecase(&mockEthClient{}, nil)
	_, err := u.SendETH(context.Background(), SendETHParams{To: ethkit.ZeroAddress})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeFailedPrecondition, liberrors.GetCode(err))
}

func TestSendToken_NoWallet(t *testing.T) {
	u := newTestUsecase(&mockEthClient{}, nil)
	_, err := u.SendToken(context.Background(), SendTokenParams{})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeFailedPrecondition, liberrors.GetCode(err))
}

func TestSendToken_LoadedHappyPath(t *testing.T) {
	// Build a real wallet from a deterministic test key.
	w, err := ethkit.NewWalletFromHex("0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")
	require.NoError(t, err)

	tokAddr := ethkit.MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
	usdc := ethkit.Token{Address: tokAddr, Symbol: "USDC", Decimals: 6, Name: "USD Coin"}

	var transferCalled bool
	eth := &mockEthClient{
		tokenMetadataFn: func(_ context.Context, _ ethkit.Address) (ethkit.Token, error) {
			return usdc, nil
		},
		transferTokenFn: func(_ context.Context, _ *ethkit.Wallet, token ethkit.Token, _ ethkit.Address, amount ethkit.Amount) (ethkit.TxReceipt, error) {
			transferCalled = true
			assert.Equal(t, "USDC", token.Symbol)
			// 100 USDC × 10^6 = 100_000_000.
			assert.Equal(t, "100000000", amount.Wei().String())
			return ethkit.TxReceipt{Hash: "0xdeadbeef", Status: ethkit.TxStatusSuccess}, nil
		},
	}

	u := newTestUsecase(eth, nil)
	u.SetWalletForTest(w)

	rcpt, err := u.SendToken(context.Background(), SendTokenParams{
		TokenAddress: tokAddr, To: ethkit.ZeroAddress, Amount: decimal.NewFromInt(100),
	})
	require.NoError(t, err)
	assert.Equal(t, "0xdeadbeef", rcpt.Hash)
	assert.True(t, transferCalled)
}

func TestSendToken_MetadataError(t *testing.T) {
	w, err := ethkit.NewWalletFromHex("0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")
	require.NoError(t, err)

	eth := &mockEthClient{
		tokenMetadataFn: func(_ context.Context, _ ethkit.Address) (ethkit.Token, error) {
			return ethkit.Token{}, stderrors.New("rpc")
		},
	}
	u := newTestUsecase(eth, nil)
	u.SetWalletForTest(w)

	_, err = u.SendToken(context.Background(), SendTokenParams{Amount: decimal.NewFromInt(1)})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
}

func TestSendETH_LoadedHappyPath(t *testing.T) {
	w, err := ethkit.NewWalletFromHex("0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")
	require.NoError(t, err)

	eth := &mockEthClient{
		sendTxFn: func(_ context.Context, _ *ethkit.Wallet, req ethkit.TxRequest) (ethkit.TxReceipt, error) {
			assert.Equal(t, "1000", req.Value.Wei().String())
			return ethkit.TxReceipt{Hash: "0xabc", Status: ethkit.TxStatusSuccess}, nil
		},
	}
	u := newTestUsecase(eth, nil)
	u.SetWalletForTest(w)

	rcpt, err := u.SendETH(context.Background(), SendETHParams{
		To: ethkit.ZeroAddress, Value: ethkit.NewAmountFromWei(big.NewInt(1000)),
	})
	require.NoError(t, err)
	assert.Equal(t, "0xabc", rcpt.Hash)
}

func TestGetWalletDelegates(t *testing.T) {
	want := &entity.Wallet{ID: "x"}
	svc := &mockWalletService{
		getFn: func(_ context.Context) (*entity.Wallet, error) { return want, nil },
	}
	u := newTestUsecase(&mockEthClient{}, svc)

	got, err := u.GetWallet(context.Background())
	require.NoError(t, err)
	assert.Same(t, want, got)
}
