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

func TestResolveSwapAddresses(t *testing.T) {
	t.Run("ETH to ETH errors", func(t *testing.T) {
		_, _, err := resolveSwapAddresses(NativeETH, NativeETH)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "same")
	})

	t.Run("ETH to USDC substitutes WETH", func(t *testing.T) {
		in, out, err := resolveSwapAddresses(NativeETH, USDC)
		require.NoError(t, err)
		assert.Equal(t, uniswapWETH9.Common(), in, "tokenIn should be WETH for native ETH")
		assert.Equal(t, USDC.Address.Common(), out)
	})

	t.Run("USDC to USDT", func(t *testing.T) {
		in, out, err := resolveSwapAddresses(USDC, USDT)
		require.NoError(t, err)
		assert.Equal(t, USDC.Address.Common(), in)
		assert.Equal(t, USDT.Address.Common(), out)
	})

	t.Run("USDC to ETH substitutes WETH on output", func(t *testing.T) {
		in, out, err := resolveSwapAddresses(USDC, NativeETH)
		require.NoError(t, err)
		assert.Equal(t, USDC.Address.Common(), in)
		assert.Equal(t, uniswapWETH9.Common(), out)
	})
}
