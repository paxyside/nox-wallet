package ethkit

import (
	"math/big"
	"testing"

	"github.com/ethereum/go-ethereum/common"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/paxyside/nox-wallet/pkg/ethkit/abis"
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

// TestRouterMulticallEncoding pins down the ABI encoding for the
// ERC-20 → native-ETH path: a multicall containing exactInputSingle
// followed by unwrapWETH9. Catches accidents like a missing entry in
// the embedded router ABI JSON or a typo in the method names.
func TestRouterMulticallEncoding(t *testing.T) {
	routerABI := abis.UniswapSwapRouter02()

	swapData, err := routerABI.Pack("exactInputSingle", struct {
		TokenIn           common.Address
		TokenOut          common.Address
		Fee               *big.Int
		Recipient         common.Address
		AmountIn          *big.Int
		AmountOutMinimum  *big.Int
		SqrtPriceLimitX96 *big.Int
	}{
		TokenIn:           common.HexToAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
		TokenOut:          common.HexToAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"),
		Fee:               big.NewInt(500),
		Recipient:         common.HexToAddress("0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"),
		AmountIn:          big.NewInt(1_000_000),
		AmountOutMinimum:  big.NewInt(0),
		SqrtPriceLimitX96: big.NewInt(0),
	})
	require.NoError(t, err, "exactInputSingle should encode")

	unwrapData, err := routerABI.Pack(
		"unwrapWETH9",
		big.NewInt(123),
		common.HexToAddress("0x61bE3BB037a2eeA06D6f3619be8662BB972a2BE7"),
	)
	require.NoError(t, err, "unwrapWETH9 should encode")
	// Each function selector is 4 bytes — sanity-check we got more
	// than just the selector (i.e. encoding actually emitted args).
	assert.Greater(t, len(unwrapData), 4)

	multicallData, err := routerABI.Pack("multicall", [][]byte{swapData, unwrapData})
	require.NoError(t, err, "multicall should encode")
	assert.Greater(t, len(multicallData), len(swapData)+len(unwrapData))
}
