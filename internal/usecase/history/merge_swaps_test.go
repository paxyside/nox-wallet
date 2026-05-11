package history

import (
	"testing"

	"github.com/shopspring/decimal"

	"github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// mergeSwapLegs collapses two same-hash legs (one out, one in,
// different assets) into a single synthetic Swap row. Edge cases that
// must NOT merge:
//
//   - single-leg rows (regular send / receive)
//   - same-asset same-hash pairs (wrap/unwrap, internal self-transfer)
//   - 3+ legs (rare aggregator path — keep raw)
//   - both legs going the same direction (out+out or in+in)
func TestMergeSwapLegs(t *testing.T) {
	wallet, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	router, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")
	peer, _ := ethkit.NewAddress("0x3333333333333333333333333333333333333333")

	makeTx := func(hash, asset string, from, to ethkit.Address, value string) *entity.Transaction {
		v, _ := decimal.NewFromString(value)

		return &entity.Transaction{
			Hash:  hash,
			From:  from,
			To:    to,
			Asset: asset,
			Value: v,
		}
	}

	t.Run("empty input → empty output", func(t *testing.T) {
		got := mergeSwapLegs(nil, wallet.Hex())
		if len(got) != 0 {
			t.Fatalf("want empty, got %d", len(got))
		}
	})

	t.Run("single tx passes through unchanged", func(t *testing.T) {
		in := []*entity.Transaction{makeTx("0xa", "ETH", peer, wallet, "1.0")}
		got := mergeSwapLegs(in, wallet.Hex())
		if len(got) != 1 {
			t.Fatalf("want 1 row, got %d", len(got))
		}
		if got[0].IsSwap {
			t.Fatal("single leg must not be marked as swap")
		}
	})

	t.Run("wallet → router (USDC) + router → wallet (USDT) → merged Swap", func(t *testing.T) {
		in := []*entity.Transaction{
			makeTx("0xswap", "USDC", wallet, router, "1.0"),
			makeTx("0xswap", "USDT", router, wallet, "0.99"),
		}

		got := mergeSwapLegs(in, wallet.Hex())
		if len(got) != 1 {
			t.Fatalf("want 1 merged row, got %d", len(got))
		}

		swap := got[0]
		if !swap.IsSwap {
			t.Fatal("should be marked IsSwap")
		}

		if swap.TokenInSym != "USDC" || swap.TokenInVal != "1" {
			t.Fatalf("tokenIn USDC/1, got %s/%s", swap.TokenInSym, swap.TokenInVal)
		}

		if swap.TokenOutSym != "USDT" || swap.TokenOutVal != "0.99" {
			t.Fatalf("tokenOut USDT/0.99, got %s/%s", swap.TokenOutSym, swap.TokenOutVal)
		}
	})

	t.Run("same-asset same-hash → not merged (wrap/unwrap shape)", func(t *testing.T) {
		in := []*entity.Transaction{
			makeTx("0xwrap", "ETH", wallet, router, "1.0"),
			makeTx("0xwrap", "ETH", router, wallet, "1.0"),
		}

		got := mergeSwapLegs(in, wallet.Hex())
		if len(got) != 2 {
			t.Fatalf("same-asset pair must stay raw, got %d rows", len(got))
		}

		for _, r := range got {
			if r.IsSwap {
				t.Fatal("same-asset legs must not be merged")
			}
		}
	})

	t.Run("3 legs same hash → not merged (aggregator)", func(t *testing.T) {
		in := []*entity.Transaction{
			makeTx("0xaggr", "ETH", wallet, router, "1.0"),
			makeTx("0xaggr", "USDC", router, wallet, "1500"),
			makeTx("0xaggr", "USDT", router, wallet, "200"),
		}

		got := mergeSwapLegs(in, wallet.Hex())
		if len(got) != 3 {
			t.Fatalf("3-leg group must stay raw, got %d rows", len(got))
		}
	})

	t.Run("two outgoing legs same hash → not merged", func(t *testing.T) {
		in := []*entity.Transaction{
			makeTx("0xboth-out", "USDC", wallet, peer, "1.0"),
			makeTx("0xboth-out", "USDT", wallet, router, "0.5"),
		}

		got := mergeSwapLegs(in, wallet.Hex())
		if len(got) != 2 {
			t.Fatalf("both-outgoing pair must stay raw, got %d rows", len(got))
		}
	})

	t.Run("mix of swap pairs and singles → correct partition", func(t *testing.T) {
		in := []*entity.Transaction{
			makeTx("0xs", "USDC", wallet, router, "1.0"),
			makeTx("0xs", "USDT", router, wallet, "0.99"),
			makeTx("0xsend", "ETH", wallet, peer, "0.5"),
		}

		got := mergeSwapLegs(in, wallet.Hex())
		if len(got) != 2 {
			t.Fatalf("expect 2 rows (1 merged + 1 raw), got %d", len(got))
		}
	})
}
