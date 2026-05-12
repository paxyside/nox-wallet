package ethkit

import (
	"math/big"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestSlippageAmount(t *testing.T) {
	in := NewAmountFromWei(big.NewInt(1_000_000))
	cases := []struct {
		name string
		bps  uint64
		want string
	}{
		{"zero bps", 0, "1000000"},
		{"50 bps = 0.5%", 50, "995000"},
		{"100 bps = 1%", 100, "990000"},
		{"10000 bps = 100% reduction", 10000, "0"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			got := SlippageAmount(in, c.bps)
			assert.Equal(t, c.want, got.Wei().String())
		})
	}
}

// testClient builds a minimal Client carrying just a Network — enough
// to exercise resolveSwapAddresses without dialling a real RPC.
func testClient(t *testing.T) *Client {
	t.Helper()

	weth9 := MustAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")

	return &Client{network: Network{UniswapWrappedETH: weth9}}
}

func TestResolveSwapAddresses(t *testing.T) {
	c := testClient(t)

	usdc := Token{
		Address:  MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
		Symbol:   "USDC",
		Name:     "USD Coin",
		Decimals: 6,
	}
	usdt := Token{
		Address:  MustAddress("0xdAC17F958D2ee523a2206206994597C13D831ec7"),
		Symbol:   "USDT",
		Name:     "Tether USD",
		Decimals: 6,
	}
	weth9 := c.network.UniswapWrappedETH

	t.Run("ETH to ETH errors", func(t *testing.T) {
		_, _, err := c.resolveSwapAddresses(NativeETH, NativeETH)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "same")
	})

	t.Run("ETH to USDC substitutes wrapped-native", func(t *testing.T) {
		in, out, err := c.resolveSwapAddresses(NativeETH, usdc)
		require.NoError(t, err)
		assert.Equal(t, weth9.Common(), in, "tokenIn should be WETH for native ETH")
		assert.Equal(t, usdc.Address.Common(), out)
	})

	t.Run("USDC to USDT keeps both addresses", func(t *testing.T) {
		in, out, err := c.resolveSwapAddresses(usdc, usdt)
		require.NoError(t, err)
		assert.Equal(t, usdc.Address.Common(), in)
		assert.Equal(t, usdt.Address.Common(), out)
	})

	t.Run("USDC to ETH substitutes wrapped-native on output", func(t *testing.T) {
		in, out, err := c.resolveSwapAddresses(usdc, NativeETH)
		require.NoError(t, err)
		assert.Equal(t, usdc.Address.Common(), in)
		assert.Equal(t, weth9.Common(), out)
	})
}
