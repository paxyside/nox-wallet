// Package abis embeds the JSON ABI definitions used elsewhere in
// ethkit. Each contract has its own `.json` next to this file so the
// IDE highlights it as JSON, diffs are clean, and downstream Go code
// reads the parsed `abi.ABI` via the exported accessors here.
//
// ABIs are loaded once at init() and cached — `abi.JSON` does real
// work (deserialise + index by selector), no point repeating it on
// every contract call.
package abis

import (
	_ "embed"
	"fmt"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
)

//go:embed erc20.json
var erc20JSON string

//go:embed uniswap_quoter_v2.json
var uniswapQuoterV2JSON string

//go:embed uniswap_swap_router_02.json
var uniswapSwapRouter02JSON string

// Parsed ABIs are package-level cached values. We MustParse at init()
// so a malformed JSON file fails fast at startup rather than masking
// itself as "swap doesn't work in production".
var (
	erc20Cached               abi.ABI
	uniswapQuoterV2Cached     abi.ABI
	uniswapSwapRouter02Cached abi.ABI
)

func init() {
	erc20Cached = mustParse("erc20", erc20JSON)
	uniswapQuoterV2Cached = mustParse("uniswap_quoter_v2", uniswapQuoterV2JSON)
	uniswapSwapRouter02Cached = mustParse("uniswap_swap_router_02", uniswapSwapRouter02JSON)
}

// ERC20 returns the parsed ABI for the ERC-20 standard interface
// (balanceOf, transfer, approve, allowance, decimals, symbol, name,
// plus the Transfer event).
func ERC20() abi.ABI { return erc20Cached }

// UniswapQuoterV2 returns the parsed ABI for QuoterV2 — a single
// method, `quoteExactInputSingle`, used to price swaps without
// executing them.
func UniswapQuoterV2() abi.ABI { return uniswapQuoterV2Cached }

// UniswapSwapRouter02 returns the parsed ABI for SwapRouter02 — the
// `exactInputSingle` entry the swap usecase calls to execute single-hop
// trades.
func UniswapSwapRouter02() abi.ABI { return uniswapSwapRouter02Cached }

func mustParse(name, json string) abi.ABI {
	a, err := abi.JSON(strings.NewReader(json))
	if err != nil {
		panic(fmt.Sprintf("ethkit/abis: parse %s ABI: %v", name, err))
	}

	return a
}
