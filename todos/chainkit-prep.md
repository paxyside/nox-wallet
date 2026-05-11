# `chainkit` abstraction + EVM-compatible chains

User decision: not adding non-EVM (Solana / TON / BTC) for now —
those need separate SDKs and the cost-benefit doesn't pencil out. But
**EVM-compatible chains** (BNB Smart Chain, Avalanche C-Chain, Polygon,
Arbitrum, Base, Optimism) all speak the same JSON-RPC, accept
secp256k1 keys, run Solidity, have Uniswap V3 deployments — adding
them is mostly config-level work *if* we abstract `ethkit` cleanly
now.

This is **prep work**: nothing user-visible ships, but every later
multi-chain feature gets cheaper.

## Goal

Replace this dependency:

```
usecase/wallet  ──depends on──►  pkg/ethkit (EVM-specific types)
```

with:

```
usecase/wallet  ──depends on──►  pkg/chainkit (Chain interface)
                                       ▲
                                       │ implements
                  pkg/ethkit ──────────┘   (EVM impl, current code)
```

Future Solana support would be `pkg/solanakit` — no changes to
usecase / domain.

## Phase 1: `chainkit` interface

Define the surface every chain provider must satisfy.

```go
// pkg/chainkit/chainkit.go

type Address interface {
    Hex() string
    Bytes() []byte
    Short() string
    Equals(other Address) bool
    IsZero() bool
}

type Amount interface {
    Wei() *big.Int       // smallest unit
    Decimals() uint8
    String() string      // human-readable, e.g. "0.001234"
    StringFixed(d int8) string
    IsZero() bool
}

type Wallet interface {
    Address() Address
    PrivateKeyHex() string  // for keystore export
    SignTx(req TxRequest) (SignedTx, error)
    SignMessage(message []byte) ([]byte, error)
}

type Chain interface {
    ID() int64                   // EIP-155 chain id, or analogue
    Name() string                // "Ethereum Mainnet", "BNB", …
    NativeSymbol() string        // "ETH", "BNB", "MATIC"

    NewWalletFromMnemonic(mnemonic, path string) (Wallet, error)
    NewWalletFromHex(hex string) (Wallet, error)

    Balance(ctx, addr Address) (Amount, error)
    TokenBalance(ctx, addr Address, token Token) (Amount, error)
    GetGasFees(ctx) (GasInfo, error)

    SendNative(ctx, w Wallet, to Address, value Amount) (TxReceipt, error)
    SendToken(ctx, w Wallet, token Token, to Address, value Amount) (TxReceipt, error)
    Swap(ctx, w Wallet, req SwapRequest) (TxReceipt, error)

    ListHistory(ctx, addr Address, opts HistoryOpts) ([]Transfer, error)
    WatchBalance(ctx, addr Address, interval time.Duration) (<-chan BalanceEvent, error)

    // Pending tracker is per-chain too.
    PendingForAddress(addr Address) []PendingTx
    RecentPendingForAddress(addr Address) []PendingTx
}
```

Most types stay the same as today; `Address` and `Amount` become
interfaces so a Solana impl can use base58-encoded strings + lamports.
Until then, `chainkit.Address = ethkit.Address` (alias).

## Phase 2: `ethkit` implements `chainkit.Chain`

Add a thin wrapper:

```go
// pkg/ethkit/chain.go

type Chain struct {
    *Client
    chainID int64
    name    string
}

func NewChain(cfg ChainConfig) (*Chain, error) { … }

func (c *Chain) ID() int64 { return c.chainID }
func (c *Chain) Name() string { return c.name }
func (c *Chain) NativeSymbol() string { return "ETH" }
// …
var _ chainkit.Chain = (*Chain)(nil)
```

All current `ethkit` methods stay. The `Chain` struct just satisfies
the interface. Adapter / usecase code can switch from
`*ethkit.Client` to `chainkit.Chain` without behaviour change.

## Phase 3: domain decoupling

Domain types currently embed EVM specifics:

- `entity.Wallet.Address ethkit.Address` → `chainkit.Address`
- `entity.Transaction.From / To ethkit.Address` → `chainkit.Address`
- `chain_id` column added to `wallets`, `transactions`,
  `watched_tokens`, `notifications`. Defaults to 1.

This is the heavy part — touches every storage scan/insert. ~2 days.

## Phase 4: chain registry

A registry that maps chain id → Chain instance:

```go
// pkg/chainkit/registry.go

type Registry struct {
    chains map[int64]Chain
    mu     sync.RWMutex
}

func (r *Registry) Register(c Chain)
func (r *Registry) Get(chainID int64) (Chain, bool)
func (r *Registry) Active() Chain         // current selected
func (r *Registry) SetActive(chainID int64) error
```

Wired in `init_domain.go`. Watcher / wallet usecase / handler / etc.
all read through the registry.

## Phase 5: ship EVM-compat presets

Once 1–4 land, adding BNB / Avax / Polygon is just config:

```yaml
# config.yaml
networks:
  - chain_id: 1
    name: "Ethereum Mainnet"
    native_symbol: "ETH"
    http_url: "https://eth-mainnet.g.alchemy.com/v2/$KEY"
    ws_url:   "wss://eth-mainnet.g.alchemy.com/v2/$KEY"
    uniswap_router: "0xE592427A0AEce92De3Edee1F18E0157C05861564"
  - chain_id: 56
    name: "BNB Smart Chain"
    native_symbol: "BNB"
    http_url: "https://bsc-dataseed.binance.org/"
    ws_url:   ""
    uniswap_router: "0xB971eF87ede563556b2ED4b1C0b0019111Dd85d2"
  - chain_id: 43114
    name: "Avalanche"
    # …
```

Or — better — let users add chains at runtime via the
[`network-switcher.md`](network-switcher.md) flow.

## Phase 6: bridges

Once two chains are live:

- LiFi / Socket / Across — each has a JSON-RPC API for cross-chain
  swaps. Pick one, expose as a `Bridge` interface, add a "Bridge"
  quick-action in the dashboard.
- UI: source-chain dropdown + destination-chain dropdown + amount +
  show bridge fee + estimated time.

Requires Phase 5 to be done first. Estimate: 1 week for a single
bridge integration, ~3 days per additional bridge route.

## Risk

- Domain decoupling (Phase 3) is invasive — every storage type
  changes. Tests will catch most regressions but plan a long QA pass
  on history sync.
- Need to keep the existing single-chain code path working through
  the refactor — don't bigbang it. Suggested order: Phase 1 → 2 →
  ship → Phase 3 → ship → Phase 4 → ship.

## Done when

- [ ] `pkg/chainkit/` interfaces compile and `ethkit` satisfies them
- [ ] All usecase / handler / domain code talks to `chainkit.Chain`
  rather than `*ethkit.Client`
- [ ] `chain_id` column on relevant tables, defaulting to 1
- [ ] Registry pattern in place; today only one chain registered
- [ ] At least one second EVM-compat chain (e.g. Polygon) running
  end-to-end as proof
- [ ] Single-bridge integration shipped (e.g. LiFi for ETH ↔ Polygon)
