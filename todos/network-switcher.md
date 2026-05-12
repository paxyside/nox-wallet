# Network switcher + custom RPC

The active chain id no longer comes from a hardcoded constant —
the app reads it from `config/networks/networks.yaml` and the
selected network name in `ethereum.network`. The watcher,
pricefeed, swap codepath, and the per-token logo lookup are all
network-scoped. **What's missing is the user-facing switcher** and
the custom-RPC plumbing.

This file is gated by [`chainkit-prep.md`](chainkit-prep.md) — until
the app holds N chains in parallel, the switcher can only flip the
single active chain (basically a "restart with different
`ethereum.network`" UX). Doing it sooner gives early feedback on the
selector ergonomics; doing it later (after chainkit phases A–C) lets
the switch happen live without a restart.

## ✓ Shipped already

- Per-chain catalog (`config/networks/networks.yaml`): chain id,
  name, explorer, native asset metadata, Uniswap V3 protocol
  addresses. Operator-overridable via `ethereum.networks_file`.
- Embedded Uniswap Default Token List drives the token icons across
  every chain in the catalog (`config/networks/tokenlist_uniswap.json`,
  ~1450 entries / 24 chains).
- `TokenIcon` widget consumes `logoUrl` from gRPC token responses;
  the backend stamps it from the tokenlist or `native.logo_uri`.
  No more Trust Wallet CDN URL construction.
- `task update:tokenlist` keeps the snapshot fresh.

## Network switcher (UI level)

- New top-level provider `currentNetworkProvider` keyed by chain id.
- Settings → Networks: list of networks from the catalog +
  "Add custom" form. Default presets come from
  `config/networks/networks.yaml`; the catalog ships with mainnet
  out of the box, second presets land alongside Phase D of
  chainkit-prep.
- Selector widget in the dashboard header — replaces the static
  "Ethereum · Mainnet" chip with a dropdown.

The switcher *is* gated by chainkit Phase C — until the app has a
chain Registry, "switch" means restart with a different yaml value.

## Custom RPC

Where to persist:

```sql
-- +goose Up
CREATE TABLE IF NOT EXISTS rpc_endpoints (
    id           TEXT PRIMARY KEY,
    chain_id     INTEGER NOT NULL,
    name         TEXT NOT NULL,           -- user label "My Infura node"
    http_url     TEXT NOT NULL,
    is_default   INTEGER NOT NULL DEFAULT 0,
    is_active    INTEGER NOT NULL DEFAULT 0, -- one is_active=1 per chain
    added_at     DATETIME NOT NULL
);

CREATE UNIQUE INDEX idx_rpc_active_per_chain
  ON rpc_endpoints(chain_id) WHERE is_active = 1;

-- +goose Down
DROP INDEX IF EXISTS idx_rpc_active_per_chain;
DROP TABLE IF EXISTS rpc_endpoints;
```

Active endpoint replaces `config.ethereum.http_url` at boot. Config
file becomes a fallback if no DB row is `is_active=1` for the active
chain.

Backend refactor:

- `internal/adapter/eth/adapter.go` reads endpoint from DB, not config.
- `Adapter.Reconnect(ctx, endpoint)` — close current `ethkit.Client`
  and open new with new endpoint. UI calls `SetActiveRpc(id)` →
  triggers reconnect → watcher re-binds.

Be careful with the watcher — it holds `lastBlock` cursor which is
only meaningful per-chain. On chain switch, the cursor needs to reset.

### gRPC additions

```proto
service WalletService {
  // …
  rpc ListRpcEndpoints(ListRpcEndpointsRequest) returns (ListRpcEndpointsResponse);
  rpc AddRpcEndpoint(AddRpcEndpointRequest) returns (AddRpcEndpointResponse);
  rpc RemoveRpcEndpoint(RemoveRpcEndpointRequest) returns (RemoveRpcEndpointResponse);
  rpc SetActiveRpcEndpoint(SetActiveRpcEndpointRequest) returns (SetActiveRpcEndpointResponse);
}
```

### Validation

- HTTP endpoint must respond to `eth_chainId` and return the expected
  chain id. Warn if mismatched.

## Done when

- [x] Token icons sourced from a single, on-the-fly-refreshable
  registry (Uniswap Default List) — replaces the Trust Wallet CDN
  URL construction
- [ ] User can switch between the chains present in
  `networks.yaml` via UI selector
- [ ] User can add a custom RPC endpoint, validation warns on chain
  id mismatch
- [ ] Watcher correctly re-binds on chain switch (cursor reset, no
  notifications from the old chain leaking)
- [ ] Config file becomes optional — DB-stored endpoints take
  precedence
