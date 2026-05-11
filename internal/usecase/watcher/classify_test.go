package watcher

import (
	"strings"
	"testing"
)

// classifyRole drives the OS-toast copy and the in-app icon —
// misclassification is user-visible and confusing. Lock the
// behaviour with a table-driven test that covers every branch.
func TestClassifyRole(t *testing.T) {
	const (
		usdcContract = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
		usdtContract = "0xdac17f958d2ee523a2206206994597c13d831ec7"
	)

	cases := []struct {
		name      string
		movements []AssetMovement
		want      TxRole
	}{
		{
			name:      "no movements → approve (allowance bump emits no Transfer log)",
			movements: nil,
			want:      RoleApprove,
		},
		{
			name: "single outgoing native ETH → SendETH",
			movements: []AssetMovement{
				{Symbol: "ETH", ContractAddress: "", IsOutgoing: true, Counterparty: "0xpeer"},
			},
			want: RoleSendETH,
		},
		{
			name: "single incoming native ETH → ReceiveETH",
			movements: []AssetMovement{
				{Symbol: "ETH", ContractAddress: "", IsOutgoing: false, Counterparty: "0xpeer"},
			},
			want: RoleReceiveETH,
		},
		{
			name: "single outgoing ERC-20 → SendToken",
			movements: []AssetMovement{
				{Symbol: "USDC", ContractAddress: usdcContract, IsOutgoing: true, Counterparty: "0xpeer"},
			},
			want: RoleSendToken,
		},
		{
			name: "single incoming ERC-20 → ReceiveToken",
			movements: []AssetMovement{
				{Symbol: "USDC", ContractAddress: usdcContract, IsOutgoing: false, Counterparty: "0xpeer"},
			},
			want: RoleReceiveToken,
		},
		{
			name: "out USDC + in USDT, different counterparty → Swap",
			movements: []AssetMovement{
				{Symbol: "USDC", ContractAddress: usdcContract, IsOutgoing: true, Counterparty: "0xrouter"},
				{Symbol: "USDT", ContractAddress: usdtContract, IsOutgoing: false, Counterparty: "0xrouter"},
			},
			want: RoleSwap,
		},
		{
			name: "out ETH + in ERC-20 (Uniswap-style) → Swap",
			movements: []AssetMovement{
				{Symbol: "ETH", ContractAddress: "", IsOutgoing: true, Counterparty: "0xrouter"},
				{Symbol: "USDC", ContractAddress: usdcContract, IsOutgoing: false, Counterparty: "0xrouter"},
			},
			want: RoleSwap,
		},
		{
			name: "multi-hop: 2 out + 1 in → still Swap",
			movements: []AssetMovement{
				{Symbol: "ETH", ContractAddress: "", IsOutgoing: true, Counterparty: "0xrouter1"},
				{Symbol: "USDC", ContractAddress: usdcContract, IsOutgoing: true, Counterparty: "0xrouter2"},
				{Symbol: "USDT", ContractAddress: usdtContract, IsOutgoing: false, Counterparty: "0xrouter2"},
			},
			want: RoleSwap,
		},
		{
			name: "all outgoing legs target empty counterparty + has incoming → SelfTransfer",
			movements: []AssetMovement{
				{Symbol: "ETH", ContractAddress: "", IsOutgoing: true, Counterparty: ""},
				{Symbol: "ETH", ContractAddress: "", IsOutgoing: false, Counterparty: ""},
			},
			want: RoleSelfTransfer,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := classifyRole(tc.movements)
			if got != tc.want {
				t.Fatalf("classifyRole = %d, want %d", got, tc.want)
			}
		})
	}
}

// isNative falls back to symbol matching when the contract address is
// empty (which Alchemy emits for native ETH transfers). Both signals
// must agree for ETH; otherwise the row is treated as a token.
func TestIsNative(t *testing.T) {
	cases := []struct {
		name string
		m    AssetMovement
		want bool
	}{
		{"empty contract → native", AssetMovement{ContractAddress: ""}, true},
		{
			"ETH symbol with contract → still native (defensive)",
			AssetMovement{Symbol: "ETH", ContractAddress: "0xabc"},
			true,
		},
		{"eth lowercase → native", AssetMovement{Symbol: strings.ToLower("ETH")}, true},
		{"USDC with contract → not native", AssetMovement{Symbol: "USDC", ContractAddress: "0xabc"}, false},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := isNative(tc.m); got != tc.want {
				t.Fatalf("isNative = %v, want %v", got, tc.want)
			}
		})
	}
}
