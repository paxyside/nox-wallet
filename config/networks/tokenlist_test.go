package networks

import "testing"

func TestLoadDefaultTokenList_Smoke(t *testing.T) {
	tl, err := LoadDefaultTokenList()
	if err != nil {
		t.Fatalf("LoadDefaultTokenList: %v", err)
	}

	if tl.Name == "" {
		t.Error("Name must not be empty")
	}

	sizes := tl.SizeByChain()
	mainnetCount := sizes[1]
	if mainnetCount < 100 {
		t.Errorf("expected at least 100 mainnet tokens, got %d", mainnetCount)
	}
}

func TestTokenList_TokenByAddress_USDC(t *testing.T) {
	tl, _ := LoadDefaultTokenList()

	const usdcMainnet = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

	tok, ok := tl.TokenByAddress(1, usdcMainnet)
	if !ok {
		t.Fatalf("USDC must be in the Uniswap default list on mainnet")
	}

	if tok.Symbol != "USDC" {
		t.Errorf("symbol = %q, want USDC", tok.Symbol)
	}

	if tok.Decimals != 6 {
		t.Errorf("decimals = %d, want 6", tok.Decimals)
	}
}

func TestTokenList_TokenByAddress_WrongChain(t *testing.T) {
	tl, _ := LoadDefaultTokenList()

	const usdcMainnet = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

	// USDC's mainnet address won't resolve on Polygon (chain id 137).
	// Different contract address on Polygon — the list scopes by chain.
	if _, ok := tl.TokenByAddress(137, usdcMainnet); ok {
		t.Error("mainnet USDC address must not match on Polygon")
	}
}

func TestTokenList_TokenByAddress_NoMatch(t *testing.T) {
	tl, _ := LoadDefaultTokenList()

	// Random address that almost certainly isn't in the list.
	if _, ok := tl.TokenByAddress(1, "0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"); ok {
		t.Error("unknown address must not resolve")
	}
}

func TestTokenList_TokenByAddress_CaseInsensitive(t *testing.T) {
	tl, _ := LoadDefaultTokenList()

	// All upper-case — the upstream list ships in checksummed mixed
	// case, our index lowercases; lookup must match regardless.
	const upper = "0xA0B86991C6218B36C1D19D4A2E9EB0CE3606EB48"

	if _, ok := tl.TokenByAddress(1, upper); !ok {
		t.Error("upper-case address must resolve same as lower-case")
	}
}

func TestParseTokenList_RejectsEmpty(t *testing.T) {
	if _, err := parseTokenList([]byte(`{"tokens": []}`), "test"); err == nil {
		t.Fatal("expected error for empty tokens array")
	}
}

func TestParseTokenList_SkipsMalformedRows(t *testing.T) {
	// Valid + one malformed (missing chainId) — parser drops the bad
	// one and keeps the good one rather than failing the whole load.
	json := []byte(`{
        "name": "test",
        "version": {"major": 1, "minor": 0, "patch": 0},
        "tokens": [
            {"chainId": 1, "address": "0x1111111111111111111111111111111111111111", "symbol": "ONE", "name": "One", "decimals": 18},
            {"address": "0x2222222222222222222222222222222222222222", "symbol": "BAD"}
        ]
    }`)

	tl, err := parseTokenList(json, "test")
	if err != nil {
		t.Fatalf("parse: %v", err)
	}

	if _, ok := tl.TokenByAddress(1, "0x1111111111111111111111111111111111111111"); !ok {
		t.Error("good row must be indexed")
	}

	if got := tl.SizeByChain()[1]; got != 1 {
		t.Errorf("chain 1 should have 1 token, got %d", got)
	}
}
