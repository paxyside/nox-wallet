// Package price fetches token USD prices from CoinGecko.
// Results are cached in memory with a configurable TTL (default 60s).
package price

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/paxyside/nox-wallet/pkg/cache"
)

const (
	// CoinGecko's free tier rate-limits aggressively (~10–30 req/min). 5 minutes
	// of cache freshness keeps us well under that for typical wallet usage —
	// prices are only fetched when the user actively browses tokens. When a
	// fetch fails we fall back to stale data via cache.GetStale, so the UI
	// never shows empty rows. Setting a CoinGecko Demo or Pro API key (see
	// Plan*) raises the limit substantially and stops the sparkline flicker.
	DefaultTTL   = 5 * time.Minute
	SparklineTTL = 30 * time.Minute

	// Anonymous (no key). Aggressively rate-limited.
	publicBaseURL = "https://api.coingecko.com/api/v3"
	// Demo plan — free, signup required, higher per-minute quota.
	demoBaseURL = "https://api.coingecko.com/api/v3"
	// Pro plan — paid; uses a different host.
	proBaseURL = "https://pro-api.coingecko.com/api/v3"

	// API key plan identifiers (case-insensitive).
	PlanPublic = ""
	PlanDemo   = "demo"
	PlanPro    = "pro"

	cacheKey = "prices"
)

// symbolToID maps uppercase token symbols to CoinGecko IDs.
var symbolToID = map[string]string{
	"ETH":   "ethereum",
	"WETH":  "weth",
	"USDC":  "usd-coin",
	"USDT":  "tether",
	"DAI":   "dai",
	"WBTC":  "wrapped-bitcoin",
	"LINK":  "chainlink",
	"UNI":   "uniswap",
	"AAVE":  "aave",
	"MKR":   "maker",
	"COMP":  "compound-governance-token",
	"MATIC": "matic-network",
	"SHIB":  "shiba-inu",
	"ARB":   "arbitrum",
	"OP":    "optimism",
}

// Prices maps uppercase symbol → USD price.
type Prices map[string]float64

// TokenMarketData holds price + 24h change + sparkline for one ERC-20 token.
type TokenMarketData struct {
	PriceUSD       float64
	Change24hPct   float64
	ChangePositive bool
	Sparkline7d    []float64 // ~168 hourly data points
}

// TokenPrices maps lowercase contract address → TokenMarketData.
type TokenPrices map[string]*TokenMarketData

// Feed fetches and caches token prices.
type Feed struct {
	client         *http.Client
	cache          *cache.Cache[string, Prices]
	tokenCache     *cache.Cache[string, TokenPrices]
	sparklineCache *cache.Cache[string, []float64]

	baseURL    string
	apiKey     string
	apiKeyName string // request header name for the key, "" if anonymous
}

// Config bundles the configurable parameters for a Feed.
type Config struct {
	TTL    time.Duration // default DefaultTTL
	APIKey string        // CoinGecko key, "" for anonymous tier
	Plan   string        // PlanPublic / PlanDemo / PlanPro (default = public)
}

// New creates a Feed with the given configuration.
func New(cfg Config) *Feed {
	ttl := cfg.TTL
	if ttl <= 0 {
		ttl = DefaultTTL
	}

	baseURL := publicBaseURL
	headerName := ""

	if cfg.APIKey != "" {
		switch strings.ToLower(cfg.Plan) {
		case PlanPro:
			baseURL = proBaseURL
			headerName = "x-cg-pro-api-key"
		case PlanDemo, PlanPublic:
			baseURL = demoBaseURL
			headerName = "x-cg-demo-api-key"
		}
	}

	return &Feed{
		client:         &http.Client{Timeout: 10 * time.Second},
		cache:          cache.New[string, Prices](ttl),
		tokenCache:     cache.New[string, TokenPrices](ttl),
		sparklineCache: cache.New[string, []float64](SparklineTTL),
		baseURL:        baseURL,
		apiKey:         cfg.APIKey,
		apiKeyName:     headerName,
	}
}

// authHeaders attaches the CoinGecko API-key header when configured. No-op for
// the anonymous tier.
func (f *Feed) authHeaders(req *http.Request) {
	if f.apiKey != "" && f.apiKeyName != "" {
		req.Header.Set(f.apiKeyName, f.apiKey)
	}
	req.Header.Set("Accept", "application/json")
}

// GetPrices returns USD prices for the given uppercase symbols.
// Unknown symbols are silently omitted from the result.
//
// Uses a stale-while-error strategy: fresh data is fetched when the cache
// expires, but if the upstream call fails (rate-limited, offline, decode
// error) the previously-cached values are returned anyway so the UI keeps
// rendering. Only when there's never been a successful response do we
// return an empty map.
func (f *Feed) GetPrices(ctx context.Context, symbols []string) Prices {
	if cached, ok := f.cache.Get(cacheKey); ok {
		return filterSymbols(cached, symbols)
	}

	fresh, err := f.fetch(ctx)
	if err == nil {
		f.cache.Set(cacheKey, fresh)
		return filterSymbols(fresh, symbols)
	}

	// Fetch failed — fall back to stale cache if any.
	if stale, ok := f.cache.GetStale(cacheKey); ok {
		return filterSymbols(stale, symbols)
	}

	return Prices{}
}

// GetPrice returns the USD price for a single symbol, or 0 if unknown.
func (f *Feed) GetPrice(ctx context.Context, symbol string) float64 {
	prices := f.GetPrices(ctx, []string{symbol})
	return prices[strings.ToUpper(symbol)]
}

// ── internal ──────────────────────────────────────────────────────────────────

func (f *Feed) fetch(ctx context.Context) (Prices, error) {
	ids := make([]string, 0, len(symbolToID))
	for _, id := range symbolToID {
		ids = append(ids, id)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, f.baseURL+"/simple/price", nil)
	if err != nil {
		return nil, err
	}

	q := req.URL.Query()
	q.Set("ids", strings.Join(ids, ","))
	q.Set("vs_currencies", "usd")
	req.URL.RawQuery = q.Encode()
	f.authHeaders(req)

	resp, err := f.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("pricefeed: request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("pricefeed: status %d", resp.StatusCode)
	}

	// Response: {"ethereum":{"usd":2345.67}, "usd-coin":{"usd":1.00}, ...}
	var raw map[string]map[string]float64
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("pricefeed: decode: %w", err)
	}

	result := make(Prices, len(symbolToID))
	for sym, id := range symbolToID {
		if usd, ok := raw[id]["usd"]; ok && usd > 0 {
			result[sym] = usd
		}
	}

	return result, nil
}

func filterSymbols(all Prices, symbols []string) Prices {
	if len(symbols) == 0 {
		return all
	}

	out := make(Prices, len(symbols))
	for _, s := range symbols {
		s = strings.ToUpper(s)
		if p, ok := all[s]; ok {
			out[s] = p
		}
	}

	return out
}

// ── ERC-20 token prices by contract address ───────────────────────────────────

// GetTokenPrices fetches USD price + 24h change for a list of ERC-20 contract
// addresses (lowercase hex). Returns partial results on error.
func (f *Feed) GetTokenPrices(ctx context.Context, addresses []string) TokenPrices {
	if len(addresses) == 0 {
		return TokenPrices{}
	}

	cacheK := "tok:" + strings.Join(sortedUniq(addresses), ",")
	if cached, ok := f.tokenCache.Get(cacheK); ok {
		return cached
	}

	result, err := f.fetchTokenPrices(ctx, addresses)
	if err == nil && result != nil {
		f.tokenCache.Set(cacheK, result)
		return result
	}

	// Fetch failed — fall back to stale data so the UI keeps rendering.
	if stale, ok := f.tokenCache.GetStale(cacheK); ok {
		return stale
	}

	return TokenPrices{}
}

func (f *Feed) fetchTokenPrices(ctx context.Context, addresses []string) (TokenPrices, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, f.baseURL+"/simple/token_price/ethereum", nil)
	if err != nil {
		return nil, err
	}

	q := req.URL.Query()
	q.Set("contract_addresses", strings.Join(addresses, ","))
	q.Set("vs_currencies", "usd")
	q.Set("include_24hr_change", "true")
	req.URL.RawQuery = q.Encode()
	f.authHeaders(req)

	resp, err := f.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("pricefeed/token: request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("pricefeed/token: status %d", resp.StatusCode)
	}

	// Response: {"0xabc...": {"usd": 1.0023, "usd_24h_change": 0.12}}
	var raw map[string]map[string]float64
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("pricefeed/token: decode: %w", err)
	}

	out := make(TokenPrices, len(raw))
	for addr, vals := range raw {
		change := vals["usd_24h_change"]
		out[strings.ToLower(addr)] = &TokenMarketData{
			PriceUSD:       vals["usd"],
			Change24hPct:   change,
			ChangePositive: change >= 0,
		}
	}

	return out, nil
}

// ── Sparkline ─────────────────────────────────────────────────────────────────

// GetSparkline returns hourly (7d) or daily (30d) USD price points for a token.
// Result is cached for SparklineTTL per (address, days) pair.
//
// Uses a stale-while-error strategy: when the fetch fails (rate-limited,
// network), the previously-cached points are returned instead of nil so
// charts don't disappear under transient errors.
func (f *Feed) GetSparkline(ctx context.Context, contractAddress string, days int) []float64 {
	addr := strings.ToLower(contractAddress)

	key := fmt.Sprintf("%s:%dd", addr, days)
	if cached, ok := f.sparklineCache.Get(key); ok {
		return cached
	}

	points, err := f.fetchSparkline(ctx, addr, days)
	if err == nil && len(points) > 0 {
		f.sparklineCache.Set(key, points)
		return points
	}

	if stale, ok := f.sparklineCache.GetStale(key); ok {
		return stale
	}

	return nil
}

func (f *Feed) fetchSparkline(ctx context.Context, address string, days int) ([]float64, error) {
	url := fmt.Sprintf("%s/coins/ethereum/contract/%s/market_chart", f.baseURL, address)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}

	q := req.URL.Query()
	q.Set("vs_currency", "usd")
	q.Set("days", strconv.Itoa(days))
	req.URL.RawQuery = q.Encode()
	f.authHeaders(req)

	resp, err := f.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("pricefeed/sparkline: request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("pricefeed/sparkline: status %d", resp.StatusCode)
	}

	// Response: {"prices": [[timestamp_ms, price], ...]}
	var raw struct {
		Prices [][2]float64 `json:"prices"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("pricefeed/sparkline: decode: %w", err)
	}

	out := make([]float64, len(raw.Prices))
	for i, p := range raw.Prices {
		out[i] = p[1]
	}

	return out, nil
}

// sortedUniq returns a sorted, deduplicated copy of ss.
func sortedUniq(ss []string) []string {
	seen := make(map[string]struct{}, len(ss))

	out := make([]string, 0, len(ss))
	for _, s := range ss {
		s = strings.ToLower(s)
		if _, ok := seen[s]; !ok {
			seen[s] = struct{}{}
			out = append(out, s)
		}
	}
	// Simple insertion sort (small slices).
	for i := 1; i < len(out); i++ {
		for j := i; j > 0 && out[j] < out[j-1]; j-- {
			out[j], out[j-1] = out[j-1], out[j]
		}
	}

	return out
}
