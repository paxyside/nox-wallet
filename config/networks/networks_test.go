package networks

import (
	"strings"
	"testing"
)

func TestLoadDefault_Succeeds(t *testing.T) {
	cat, err := LoadDefault()
	if err != nil {
		t.Fatalf("LoadDefault: %v", err)
	}

	eth, err := cat.Network("ethereum")
	if err != nil {
		t.Fatalf("ethereum network missing: %v", err)
	}

	if eth.ChainID != 1 {
		t.Errorf("chain_id = %d, want 1", eth.ChainID)
	}

	if !strings.EqualFold(eth.Native.Symbol, "ETH") {
		t.Errorf("native = %q, want ETH", eth.Native.Symbol)
	}

	if eth.Native.CoinGeckoID != "ethereum" {
		t.Errorf("native coingecko_id = %q, want ethereum", eth.Native.CoinGeckoID)
	}

	if eth.Protocols.UniswapV3.SwapRouter02 == "" {
		t.Error("uniswap_v3.swap_router_02 must not be empty")
	}
}

func TestParse_RejectsMissingChainID(t *testing.T) {
	yaml := []byte(`
networks:
  bogus:
    name: "x"
    native: {symbol: "X", name: "x", decimals: 18}
    protocols:
      uniswap_v3:
        swap_router_02: "0x0000000000000000000000000000000000000001"
        quoter_v2:      "0x0000000000000000000000000000000000000002"
        wrapped_native: "0x0000000000000000000000000000000000000003"
`)
	if _, err := parse(yaml, "test"); err == nil {
		t.Fatal("expected error for missing chain_id")
	}
}

func TestParse_RejectsMissingNativeSymbol(t *testing.T) {
	yaml := []byte(`
networks:
  bogus:
    chain_id: 1
    name: "x"
    native: {name: "x", decimals: 18}
    protocols:
      uniswap_v3:
        swap_router_02: "0x0000000000000000000000000000000000000001"
        quoter_v2:      "0x0000000000000000000000000000000000000002"
        wrapped_native: "0x0000000000000000000000000000000000000003"
`)
	if _, err := parse(yaml, "test"); err == nil {
		t.Fatal("expected error for missing native.symbol")
	}
}

func TestParse_RejectsMissingProtocols(t *testing.T) {
	yaml := []byte(`
networks:
  bogus:
    chain_id: 1
    name: "x"
    native: {symbol: "X", name: "x", decimals: 18}
`)
	if _, err := parse(yaml, "test"); err == nil {
		t.Fatal("expected error for missing uniswap_v3 protocol addresses")
	}
}
