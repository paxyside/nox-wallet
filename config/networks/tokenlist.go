package networks

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

//go:embed tokenlist_uniswap.json
var defaultTokenListJSON []byte

// ListedToken is one entry in a [Uniswap Token List].
// Address is normalized to lowercase on load. Decimals is the
// on-chain `decimals()` value the symbol's contract reports.
//
// [Uniswap Token List]: https://uniswap.org/tokenlist.schema.json
type ListedToken struct {
	ChainID  int64  `json:"chainId"`
	Address  string `json:"address"`
	Symbol   string `json:"symbol"`
	Name     string `json:"name"`
	Decimals uint8  `json:"decimals"`
	LogoURI  string `json:"logoURI"`
}

// TokenList is the parsed verified-token registry. The watcher uses
// it as a fast metadata cache; the UI consults it to badge tokens as
// "verified" (in the list) vs "unknown" (auto-discovered, not in the
// list). Anti-spam flows downstream of those two states.
//
// One TokenList instance covers every chain shipped in the file —
// callers always scope lookups by ChainID, so we can't accidentally
// resolve a Polygon USDC entry against a mainnet contract address.
type TokenList struct {
	Name      string
	Version   string
	Timestamp string

	// byChain: chainID → lowercase address → entry.
	byChain map[int64]map[string]ListedToken
}

// TokenByAddress returns the verified entry for the given (chainID,
// address). Address matching is case-insensitive.
func (tl *TokenList) TokenByAddress(chainID int64, address string) (ListedToken, bool) {
	if tl == nil || address == "" {
		return ListedToken{}, false
	}

	chain, ok := tl.byChain[chainID]
	if !ok {
		return ListedToken{}, false
	}

	t, ok := chain[strings.ToLower(address)]

	return t, ok
}

// AddressBySymbol returns the first verified contract address whose
// symbol matches (case-insensitive). Used by callers that only carry
// a symbol — e.g. history rows persist `asset = "USDC"` without the
// address. The lookup is O(N) over the chain's tokens; tolerable for
// the current ~386-entry mainnet list.
//
// On collision (same symbol, different addresses) the first hit wins.
// In the Uniswap Default List symbol collisions are vanishingly rare
// because the list itself is curated to avoid them.
func (tl *TokenList) AddressBySymbol(chainID int64, symbol string) (string, bool) {
	if tl == nil || symbol == "" {
		return "", false
	}

	chain, ok := tl.byChain[chainID]
	if !ok {
		return "", false
	}

	want := strings.ToUpper(symbol)
	for addr, t := range chain {
		if strings.ToUpper(t.Symbol) == want {
			return addr, true
		}
	}

	return "", false
}

// SizeByChain returns {chainID → token count}. Diagnostic; useful for
// the startup log line and the `task update:tokenlist` summary.
func (tl *TokenList) SizeByChain() map[int64]int {
	out := make(map[int64]int, len(tl.byChain))
	for chain, tokens := range tl.byChain {
		out[chain] = len(tokens)
	}

	return out
}

// LoadDefaultTokenList parses the Uniswap Default List embedded at
// build time. Always succeeds — the JSON is fixture-tested.
func LoadDefaultTokenList() (*TokenList, error) {
	return parseTokenList(defaultTokenListJSON, "embedded")
}

// LoadTokenList reads a token list from `path`. Empty path falls back
// to the embedded default. Use this if operators want to ship a
// non-Uniswap curated list (CoinGecko, custom internal list, …).
func LoadTokenList(path string) (*TokenList, error) {
	if path == "" {
		return LoadDefaultTokenList()
	}

	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("tokenlist: read %s: %w", path, err)
	}

	return parseTokenList(data, path)
}

// ── internals ─────────────────────────────────────────────────────────

type tokenListFile struct {
	Name      string `json:"name"`
	Timestamp string `json:"timestamp"`
	Version   struct {
		Major int `json:"major"`
		Minor int `json:"minor"`
		Patch int `json:"patch"`
	} `json:"version"`
	Tokens []ListedToken `json:"tokens"`
}

func parseTokenList(data []byte, source string) (*TokenList, error) {
	var raw tokenListFile
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("tokenlist: parse %s: %w", source, err)
	}

	if len(raw.Tokens) == 0 {
		return nil, fmt.Errorf("tokenlist: %s contains no tokens", source)
	}

	byChain := make(map[int64]map[string]ListedToken)

	for _, t := range raw.Tokens {
		if t.Address == "" || t.ChainID == 0 {
			// Skip malformed rows — the embedded list is curated, but
			// a custom override file might contain typos. Don't fail
			// the whole load over a single bad row.
			continue
		}

		t.Address = strings.ToLower(t.Address)

		if _, ok := byChain[t.ChainID]; !ok {
			byChain[t.ChainID] = make(map[string]ListedToken)
		}

		byChain[t.ChainID][t.Address] = t
	}

	return &TokenList{
		Name:      raw.Name,
		Version:   fmt.Sprintf("%d.%d.%d", raw.Version.Major, raw.Version.Minor, raw.Version.Patch),
		Timestamp: raw.Timestamp,
		byChain:   byChain,
	}, nil
}
