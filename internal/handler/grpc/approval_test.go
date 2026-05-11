package grpc

import (
	"math/big"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

func TestFormatApprovalAmount_Unlimited(t *testing.T) {
	maxU256 := new(big.Int).Sub(new(big.Int).Lsh(big.NewInt(1), 256), big.NewInt(1))

	a := ethkit.TokenApproval{
		Token:   ethkit.Token{Symbol: "USDC", Decimals: 6},
		Amount:  ethkit.NewAmountFromWei(maxU256),
		Spender: ethkit.MustAddress("0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"),
	}

	got := formatApprovalAmount(a)
	assert.Equal(t, "Unlimited", got, "max-uint256 should map to Unlimited")
}

func TestFormatApprovalAmount_Finite(t *testing.T) {
	// 100.5 USDC = 100_500_000 wei (USDC has 6 decimals)
	a := ethkit.TokenApproval{
		Token:   ethkit.Token{Symbol: "USDC", Decimals: 6},
		Amount:  ethkit.NewAmountFromWei(big.NewInt(100_500_000)),
		Spender: ethkit.MustAddress("0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"),
	}

	got := formatApprovalAmount(a)
	assert.Equal(t, "100.500000 USDC", got)
}

func TestApprovalToProto_KnownSpenderLabel(t *testing.T) {
	a := ethkit.TokenApproval{
		Token: ethkit.Token{
			Symbol:   "USDC",
			Name:     "USD Coin",
			Decimals: 6,
			Address:  ethkit.MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
		},
		Amount:  ethkit.NewAmountFromWei(big.NewInt(1_000_000)),
		Spender: ethkit.MustAddress("0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"),
	}

	got := approvalToProto(a)
	assert.Equal(t, "USDC", got.GetTokenSymbol())
	assert.Equal(t, "Uniswap V3", got.GetSpenderLabel(),
		"known router should get human label")
	assert.Equal(t, uint32(6), got.GetTokenDecimals())
}

func TestApprovalToProto_UnknownSpenderShortened(t *testing.T) {
	a := ethkit.TokenApproval{
		Token: ethkit.Token{
			Symbol:   "DAI",
			Name:     "Dai",
			Decimals: 18,
			Address:  ethkit.MustAddress("0x6B175474E89094C44Da98b954EedeAC495271d0F"),
		},
		Amount:  ethkit.NewAmountFromWei(big.NewInt(0).Mul(big.NewInt(1), big.NewInt(1e18))),
		Spender: ethkit.MustAddress("0x1234567890123456789012345678901234567890"),
	}

	got := approvalToProto(a)
	assert.Contains(t, got.GetSpenderLabel(), "…",
		"unknown spender should be shortened with ellipsis")
}
