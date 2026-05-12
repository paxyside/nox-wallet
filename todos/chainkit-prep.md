# `chainkit` abstraction + EVM-compatible chains

User decision: not adding non-EVM (Solana / TON / BTC) for now —
those need separate SDKs and the cost-benefit doesn't pencil out. But
**EVM-compatible chains** (BNB Smart Chain, Avalanche C-Chain, Polygon,
Arbitrum, Base, Optimism) all speak the same JSON-RPC, accept
secp256k1 keys, run Solidity, have Uniswap V3 deployments — adding
them is mostly config-level work *if* the per-chain seams are cut
cleanly.

This is **prep work**: nothing user-visible ships until phase D, but
every later multichain feature gets cheaper.

## ✓ Shipped already (config / data layer)

A significant chunk of the original "chainkit" plan landed during
the token-list refactor. Specifically:

- ✓ **Per-chain config** lives in `config/networks/networks.yaml`
  (embedded by default, file override via `ethereum.networks_file`):
  chain id, name, explorer, native asset metadata, protocol contract
  addresses (Uniswap V3 quoter / router / wrapped-native).
- ✓ **`ethkit.Network` struct** + `WithNetwork` option — the Client
  carries chain id + protocol addresses, swap codepath reads from
  there instead of package-level vars.
- ✓ **Embedded Uniswap Default Token List** — per-chain verified
  registry (`config/networks/tokenlist_uniswap.json`, ~1450 entries
  covering 24 chains). `task update:tokenlist` refreshes the
  snapshot.
- ✓ **CoinGecko id per chain** — pricefeed reads native-asset id
  from `network.Native.CoinGeckoID`; ERC-20 prices via the
  contract-address endpoint (chain-agnostic on the consumer side).
- ✓ **Watcher token lookup** decoupled from a hardcoded map — takes
  a `TokenLookup` injected at construction (network-scoped tokenlist
  adapter in `init_domain.go`).

So the **config-layer foundation is done**. What's left is the
harder structural piece: making the app hold more than one chain
simultaneously.

## What's left

### Phase A — multi-chain Client

Today `ethkit.Client` is a singleton bound to one chain via
`ethkit.WithNetwork(net)` at startup. To run two chains in parallel
we need either:

1. **One Client per chain** (preferred) — keep the existing struct,
   but the app wiring constructs N clients (one per registered
   network) and the adapter routes by chain id. Nonce manager,
   pending tracker, retrier are per-chain anyway.
2. **Chain-aware Client** — single instance, methods take a chain id.
   Internally splits state per chain. Worse: harder to reason about,
   harder to test.

Going with option 1. Required changes:

- `internal/app/init_infra.go` — load every entry in
  `cfg.Ethereum.Networks []NetworkRef` instead of a single
  `cfg.Ethereum.Network` string. Each gets its own `*ethkit.Client`
  and pending-store SQLite namespace.
- `internal/adapter/eth/adapter.go` — `Adapter` becomes a thin
  per-chain wrapper; a new `Registry` indexes them by chain id.
  Usecases that need cross-chain (history aggregation) accept the
  registry; usecases that operate on one chain (current dashboard)
  accept the active `*Adapter`.
- `usecase/wallet` — `LoadFromKeychain` becomes chain-aware. Same
  private key, but `Wallet.Address` is checksummed identically across
  EVM chains, so this is mostly plumbing.

Roughly 2 days of work plus a careful QA pass.

### Phase B — domain `chain_id` column

The domain entities are still chain-agnostic by accident — they
just don't track chain. Need:

- `chain_id` column on `transactions`, `notifications`,
  `watched_tokens`, `pending_txs`. Default to 1 for the existing
  data on first migration; downstream reads filter by active chain.
- Storage interfaces and queries updated to pass `chainID` through.
- gRPC envelope: include `chain_id` on every notification /
  transaction so the UI can scope history to the active chain.

The heaviest piece — touches every storage scan/insert. ~2 days.

### Phase C — chain registry

```go
// pkg/ethkit (or new pkg/chainregistry)

type Registry struct {
    chains map[int64]*Adapter
    mu     sync.RWMutex
    active int64
}

func (r *Registry) Get(chainID int64) (*Adapter, bool)
func (r *Registry) Active() *Adapter
func (r *Registry) SetActive(chainID int64) error
```

Wired in `init_domain.go`. Watcher / wallet usecase / handler / etc.
all read through the registry's `Active()` for single-chain calls,
and through `Get(chainID)` for chain-scoped reads (history rows from
a non-active chain still need to render correctly).

### Phase D — second chain end-to-end

Once A–C land, adding Polygon is one yaml block:

```yaml
networks:
  ethereum: { ... }
  polygon:
    chain_id: 137
    name: "Polygon"
    explorer: "https://polygonscan.com"
    native:
      symbol: "MATIC"
      name: "Polygon"
      decimals: 18
      coingecko_id: "matic-network"
      logo_uri: "..."
    protocols:
      uniswap_v3:
        swap_router_02: "0x..."
        quoter_v2:      "0x..."
        wrapped_native: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"
```

Plus a config-level mention which chains to **load** (currently we
load one, named in `cfg.Ethereum.Network`):

```yaml
ethereum:
  active: "ethereum"      # the chain selected on first launch
  load: ["ethereum", "polygon"]
```

### Phase E — bridges (optional, later)

Once two chains are live:

- LI.FI / Across / Socket — each has a JSON-RPC API for cross-chain
  swaps. The token-list `extensions.bridgeInfo` field gives us the
  destination-chain contract addresses for every mainnet token, so
  the integration is mostly UI work + one bridge SDK pin.
- New "Bridge" quick-action in the dashboard: source-chain dropdown
  + destination-chain dropdown + amount + estimated fee + ETA.

Requires Phase D. Estimate: 1 week for a single bridge integration,
~3 days per additional bridge.

## Risk

- Domain decoupling (Phase B) is invasive — every storage type
  changes. Tests will catch most regressions but plan a long QA pass
  on history sync.
- Need to keep the existing single-chain code path working through
  the refactor — don't bigbang it. Suggested order: A → ship → B →
  ship → C → ship → D.

## Done when

- [x] `config/networks/` package with per-chain protocol addresses +
  native asset metadata
- [x] `ethkit.Network` struct passed via `WithNetwork` option
- [x] Embedded Uniswap Default List for token metadata lookups
- [ ] `Registry` of `*ethkit.Client` instances keyed by chain id
- [ ] All usecase / handler / storage code chain-aware (`chain_id`
  threaded through)
- [ ] At least one second EVM-compat chain (e.g. Polygon) running
  end-to-end as proof
- [ ] Single-bridge integration shipped (e.g. LI.FI for ETH ↔ Polygon)
