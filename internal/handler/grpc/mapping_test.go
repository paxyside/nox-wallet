package grpc

import (
	"math/big"
	"testing"
	"time"

	"github.com/shopspring/decimal"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pricefeed "github.com/paxyside/nox-wallet/internal/adapter/price"
	contactentity "github.com/paxyside/nox-wallet/internal/domain/contact/entity"
	tokenentity "github.com/paxyside/nox-wallet/internal/domain/token/entity"
	transactionentity "github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
	walletentity "github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	historyuc "github.com/paxyside/nox-wallet/internal/usecase/history"
	tokenuc "github.com/paxyside/nox-wallet/internal/usecase/token"
	walletuc "github.com/paxyside/nox-wallet/internal/usecase/wallet"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pbwallet "github.com/paxyside/nox-wallet/proto/gen/go/wallet/wallet"
)

func TestWalletToProto(t *testing.T) {
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")
	now := time.Now()
	w := &walletentity.Wallet{
		ID: "id-1", Address: addr, Label: "main",
		SecretType: walletentity.SecretTypeMnemonic,
		CreatedAt:  now,
	}
	got := walletToProto(w)
	require.NotNil(t, got)
	assert.Equal(t, "id-1", got.GetId())
	assert.Equal(t, addr.Hex(), got.GetAddress())
	assert.Equal(t, "main", got.GetLabel())
	assert.Equal(t, pbwallet.SecretType_SECRET_TYPE_MNEMONIC, got.GetSecretType())
}

func TestSecretTypeToProto(t *testing.T) {
	assert.Equal(t, pbwallet.SecretType_SECRET_TYPE_MNEMONIC, secretTypeToProto(walletentity.SecretTypeMnemonic))
	assert.Equal(t, pbwallet.SecretType_SECRET_TYPE_PRIVATE_KEY, secretTypeToProto(walletentity.SecretTypePrivateKey))
	assert.Equal(t, pbwallet.SecretType_SECRET_TYPE_UNSPECIFIED, secretTypeToProto("bogus"))
}

func TestBalancesToProto(t *testing.T) {
	usdcAddr := ethkit.MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
	usdc := ethkit.Token{Address: usdcAddr, Symbol: "USDC", Name: "USD Coin", Decimals: 6}
	r := walletuc.GetBalancesResult{
		ETH: ethkit.NewAmountFromETH(decimal.NewFromFloat(2.5)),
		Tokens: []walletuc.TokenBalance{
			{Token: usdc, Balance: ethkit.NewAmountFromTokenUnits(decimal.NewFromInt(100), 6)},
		},
	}
	prices := pricefeed.Prices{"USDC": 1.0, "ETH": 2000}

	ethDec, ethStr, tokens := (&Handler{}).balancesToProto(r, prices)
	assert.Equal(t, "2.5", ethDec)
	assert.Contains(t, ethStr, "ETH")
	require.Len(t, tokens, 1)
	assert.Equal(t, "USDC", tokens[0].GetSymbol())
	assert.Equal(t, "USD Coin", tokens[0].GetName())
	assert.Equal(t, "$100.00", tokens[0].GetUsdValue())
}

func TestFormatUSD(t *testing.T) {
	cases := []struct {
		in   float64
		want string
	}{
		{12.345, "$12.35"},
		{0.5, "$0.50"},
		{0.01, "$0.01"},
		{0.005, "$0.005000"}, // below threshold uses 6 decimals
		{0, "$0.000000"},
	}
	for _, c := range cases {
		assert.Equal(t, c.want, formatUSD(c.in))
	}
}

func TestGasFeesToProto(t *testing.T) {
	r := walletuc.GetGasFeesResult{
		GasInfo: ethkit.GasInfo{
			BaseFee:     ethkit.NewAmountFromGwei(decimal.NewFromInt(20)),
			PriorityFee: ethkit.NewAmountFromGwei(decimal.NewFromInt(2)),
			MaxFee:      ethkit.NewAmountFromGwei(decimal.NewFromInt(40)),
		},
	}
	got := gasFeesToProto(r)
	require.NotNil(t, got)
	assert.Equal(t, uint64(21_000), got.GetEstimatedGas())
	assert.Contains(t, got.GetBaseFeeGwei(), "20")
	assert.Contains(t, got.GetMaxPriorityFeeGwei(), "2")
	assert.Contains(t, got.GetMaxFeeGwei(), "40")
}

func TestReceiptToProto(t *testing.T) {
	r := ethkit.TxReceipt{
		Hash: "0xdeadbeef", BlockNumber: 100, GasUsed: 21000,
		GasCost: ethkit.NewAmountFromGwei(decimal.NewFromInt(15)),
		Status:  ethkit.TxStatusSuccess,
	}
	got := receiptToProto(r)
	require.NotNil(t, got)
	assert.Equal(t, "0xdeadbeef", got.GetTxHash())
	assert.True(t, got.GetSuccess())
	assert.Equal(t, uint64(21000), got.GetGasUsed())
	assert.Equal(t, uint64(100), got.GetBlockNumber())

	failed := receiptToProto(ethkit.TxReceipt{Status: ethkit.TxStatusFailed})
	assert.False(t, failed.GetSuccess())
}

func TestHistoryToProto(t *testing.T) {
	now := time.Now()
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")
	r := historyuc.GetHistoryResult{
		Transactions: []*transactionentity.Transaction{
			{
				Hash: "0xa", From: addr, To: addr,
				Asset: "ETH", Value: decimal.NewFromFloat(0.5),
				BlockNumber: 1, Timestamp: now, GasFeeEth: "0.001",
			},
			{
				Hash: "0xb", From: addr, To: addr,
				Asset: "", Value: decimal.NewFromInt(100), Timestamp: now,
			},
		},
	}
	prices := pricefeed.Prices{"ETH": 2000}
	got := historyToProto(r, prices)
	require.Len(t, got, 2)
	assert.Equal(t, "0xa", got[0].GetTxHash())
	assert.Equal(t, "$1000.00", got[0].GetValueUsd())
	assert.Equal(t, "$2.00", got[0].GetGasFeeUsd())
	// Empty asset still maps "ETH" symbol for pricing.
	assert.Equal(t, "$200000.00", got[1].GetValueUsd())
}

func TestContactToProto(t *testing.T) {
	now := time.Now()
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")
	c := &contactentity.Contact{
		ID: "id-1", Address: addr, Name: "Bob", Notes: "note",
		IsFavorite: true, CreatedAt: now, UpdatedAt: now,
	}
	got := contactToProto(c)
	require.NotNil(t, got)
	assert.Equal(t, "id-1", got.GetId())
	assert.Equal(t, "Bob", got.GetName())
	assert.Equal(t, addr.Hex(), got.GetAddress())
	assert.Equal(t, "note", got.GetNote())
	assert.True(t, got.GetIsFavorite())
}

func TestWatchedTokenToProto(t *testing.T) {
	addr := ethkit.MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
	wt := &tokenentity.WatchedToken{
		ID: "id", Token: ethkit.Token{Address: addr, Symbol: "USDC", Name: "USD Coin", Decimals: 6},
		IsPinned: true, AddedAt: time.Now(),
	}
	got := (&Handler{}).watchedTokenToProto(wt)
	require.NotNil(t, got)
	assert.Equal(t, "id", got.GetId())
	assert.Equal(t, "USDC", got.GetSymbol())
	assert.Equal(t, uint32(6), got.GetDecimals())
	assert.True(t, got.GetIsPinned())
}

func TestTokenWithBalanceToProto(t *testing.T) {
	addr := ethkit.MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
	tok := ethkit.Token{Address: addr, Symbol: "USDC", Name: "USD Coin", Decimals: 6}

	t.Run("with market data", func(t *testing.T) {
		twb := tokenuc.TokenWithBalance{
			ID: "id", Token: tok,
			Balance:        ethkit.NewAmountFromWei(big.NewInt(1000_000)), // 1 USDC
			IsPinned:       true,
			PriceUSD:       1.001,
			Change24hPct:   0.5,
			ChangePositive: true,
			Sparkline7d:    []float64{1, 2, 3},
			Sparkline30d:   []float64{1, 2, 3, 4},
			BalanceUSD:     1.001,
		}
		got := (&Handler{}).tokenWithBalanceToProto(twb)
		require.NotNil(t, got)
		require.NotNil(t, got.GetMarket())
		assert.True(t, got.GetMarket().GetChangePositive())
		assert.Equal(t, "+0.50", got.GetMarket().GetChange_24HPct())
		assert.Len(t, got.GetMarket().GetSparkline_7D(), 3)
		assert.Equal(t, "$1.00", got.GetBalanceUsd())
		assert.Equal(t, "USDC", got.GetToken().GetSymbol())
	})

	t.Run("no market", func(t *testing.T) {
		twb := tokenuc.TokenWithBalance{Token: tok}
		got := (&Handler{}).tokenWithBalanceToProto(twb)
		require.NotNil(t, got)
		assert.Nil(t, got.GetMarket())
		assert.Empty(t, got.GetBalanceUsd())
	})

	t.Run("negative change", func(t *testing.T) {
		twb := tokenuc.TokenWithBalance{Token: tok, PriceUSD: 1, Change24hPct: -3.21, ChangePositive: false}
		got := (&Handler{}).tokenWithBalanceToProto(twb)
		require.NotNil(t, got.GetMarket())
		assert.Equal(t, "-3.21", got.GetMarket().GetChange_24HPct())
		assert.False(t, got.GetMarket().GetChangePositive())
	})
}
