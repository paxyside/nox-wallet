package watcher

import (
	"testing"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

func TestIsSpamTransaction(t *testing.T) {
	// Verified list: only canonical USDC is "known".
	const usdc = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
	lookup := func(addrLower string) (ethkit.Token, bool) {
		if addrLower == usdc {
			return ethkit.Token{Symbol: "USDC"}, true
		}
		return ethkit.Token{}, false
	}

	tokenLeg := func(contract string) AssetMovement {
		return AssetMovement{ContractAddress: contract, IsOutgoing: true, Amount: "1725"}
	}
	ethLeg := AssetMovement{ContractAddress: "", IsOutgoing: true, Amount: "0.5"}

	cases := []struct {
		name     string
		lookup   TokenLookup
		tx       *TransactionData
		wantSpam bool
	}{
		{
			name:     "nil lookup fails open",
			lookup:   nil,
			tx:       &TransactionData{Movements: []AssetMovement{tokenLeg("0xfake")}},
			wantSpam: false,
		},
		{
			name:     "verified token kept",
			lookup:   lookup,
			tx:       &TransactionData{Movements: []AssetMovement{tokenLeg(usdc)}},
			wantSpam: false,
		},
		{
			name:   "unverified token is spam",
			lookup: lookup,
			tx: &TransactionData{
				Movements: []AssetMovement{tokenLeg("0xfakeUSDC0000000000000000000000000000beef")},
			},
			wantSpam: true,
		},
		{
			name:     "unverified token but ours is kept",
			lookup:   lookup,
			tx:       &TransactionData{IsOurs: true, Movements: []AssetMovement{tokenLeg("0xfake")}},
			wantSpam: false,
		},
		{
			name:     "pure ETH never spam",
			lookup:   lookup,
			tx:       &TransactionData{Movements: []AssetMovement{ethLeg}},
			wantSpam: false,
		},
		{
			name:   "any unverified leg taints the tx",
			lookup: lookup,
			tx: &TransactionData{Movements: []AssetMovement{
				tokenLeg(usdc),
				tokenLeg("0xfake"),
			}},
			wantSpam: true,
		},
	}

	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			u := &Usecase{tokenLookup: c.lookup}
			if got := u.isSpamTransaction(c.tx); got != c.wantSpam {
				t.Errorf("isSpamTransaction = %v, want %v", got, c.wantSpam)
			}
		})
	}
}
