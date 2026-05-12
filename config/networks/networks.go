// Package networks owns the per-chain configuration the rest of the
// app uses to decide which router to call and what CoinGecko ID maps
// to the native asset. The catalog is embedded by default; users with
// custom chains or replacement RPCs can pass an override path at
// startup and a YAML on disk takes precedence.
//
// Why a separate package: the data is read by ethkit (protocols) and
// the price feed (native CoinGecko id). Having a single source of
// truth here means adding a network is a one-file edit, and switching
// chains in v1 becomes a config change rather than a refactor.
//
// Verified ERC-20 metadata lives in `tokenlist.go` / the embedded
// Uniswap Default Token List — this file only carries chain-level
// constants and the chain's native asset.
package networks

import (
	_ "embed"
	"errors"
	"fmt"
	"os"
	"strings"

	"gopkg.in/yaml.v3"
)

//go:embed networks.yaml
var defaultYAML []byte

// Token describes the chain's native asset. ERC-20 entries no longer
// live in network configs — that registry moved to TokenList.
type Token struct {
	Symbol      string `yaml:"symbol"`
	Name        string `yaml:"name"`
	Decimals    uint8  `yaml:"decimals"`
	CoinGeckoID string `yaml:"coingecko_id"`
	// LogoURI for the native asset. Stamped onto the gRPC balance
	// response so the UI can render the same `Image.network` widget
	// it uses for ERC-20 tokens — no hardcoded ETH PNG in Dart code.
	LogoURI string `yaml:"logo_uri"`
}

// UniswapV3 holds the Uniswap V3 contract addresses on a chain.
// SwapRouter02 + QuoterV2 are the two we call; WrappedNative is the
// wrapped-ether-equivalent used to route swaps where one side is
// native (ETH ↔ token = ETH → WETH → token).
type UniswapV3 struct {
	SwapRouter02  string `yaml:"swap_router_02"`
	QuoterV2      string `yaml:"quoter_v2"`
	WrappedNative string `yaml:"wrapped_native"`
}

// Protocols groups every protocol the wallet integrates with. Add
// new ones here (one field per protocol) and the YAML schema gains
// the matching block automatically.
type Protocols struct {
	UniswapV3 UniswapV3 `yaml:"uniswap_v3"`
}

// Network is the parsed entry for one chain. Identifies the chain
// and carries the protocol-level addresses (Uniswap V3 contracts) +
// native-asset metadata (symbol, decimals, CoinGecko id).
type Network struct {
	ID        string    `yaml:"-"` // key in the networks map
	ChainID   int64     `yaml:"chain_id"`
	Name      string    `yaml:"name"`
	Explorer  string    `yaml:"explorer"`
	Native    Token     `yaml:"native"`
	Protocols Protocols `yaml:"protocols"`
}

// Catalog wraps the parsed YAML so callers can look up networks by id
// without exposing the underlying map (which would let consumers
// mutate it).
type Catalog struct {
	networks map[string]*Network
}

// Network returns the parsed entry for the given id ("ethereum"),
// or an error if the id isn't in the catalog.
func (c *Catalog) Network(id string) (*Network, error) {
	n, ok := c.networks[id]
	if !ok {
		return nil, fmt.Errorf("networks: unknown network %q", id)
	}

	return n, nil
}

// LoadDefault parses the catalog embedded at build time. Always
// succeeds because the YAML is fixture-tested.
func LoadDefault() (*Catalog, error) {
	return parse(defaultYAML, "embedded")
}

// Load reads the catalog from `path`. If `path` is empty, falls back
// to the embedded default. Use this to let operators ship a custom
// networks file alongside the binary.
func Load(path string) (*Catalog, error) {
	if path == "" {
		return LoadDefault()
	}

	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("networks: read %s: %w", path, err)
	}

	return parse(data, path)
}

// ── internals ─────────────────────────────────────────────────────────

type rawCatalog struct {
	Networks map[string]*Network `yaml:"networks"`
}

func parse(data []byte, source string) (*Catalog, error) {
	var raw rawCatalog

	if err := yaml.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("networks: parse %s: %w", source, err)
	}

	if len(raw.Networks) == 0 {
		return nil, fmt.Errorf("networks: %s contains no networks", source)
	}

	for id, n := range raw.Networks {
		n.ID = id
		if err := n.validate(); err != nil {
			return nil, fmt.Errorf("networks: %s: network %q: %w", source, id, err)
		}
	}

	return &Catalog{networks: raw.Networks}, nil
}

func (n *Network) validate() error {
	if n.ChainID <= 0 {
		return fmt.Errorf("chain_id must be positive, got %d", n.ChainID)
	}

	if strings.TrimSpace(n.Native.Symbol) == "" {
		return errors.New("native.symbol must not be empty")
	}

	if n.Protocols.UniswapV3.SwapRouter02 == "" ||
		n.Protocols.UniswapV3.QuoterV2 == "" ||
		n.Protocols.UniswapV3.WrappedNative == "" {
		return errors.New("protocols.uniswap_v3: swap_router_02, quoter_v2, wrapped_native all required")
	}

	return nil
}
