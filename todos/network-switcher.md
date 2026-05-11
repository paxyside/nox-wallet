# Network switcher + custom RPC + token icons

Currently `chain_id: 1` is hard-coded in `config.yaml`. The watcher
binds to a single chain at boot. Goal: let the user switch between
mainnet / testnets / EVM-compat chains without restarting + paste
their own RPC if Alchemy is unavailable.

## Network switcher (UI level)

- New top-level provider `currentNetworkProvider` keyed by chain id +
  (optional) custom RPC URL.
- Settings → Networks: list of presets (Mainnet, Sepolia, BNB, Avax,
  Polygon, Base, Arbitrum) + "Add custom" form.
- Selector widget in the dashboard header — replaces the static
  "Ethereum · Mainnet" chip with a dropdown.

The switcher *is* gated by `chainkit-prep.md` — until we abstract
EVM-compat chains, the switcher only flips RPC URL + chain id, not
the entire chain implementation.

## Custom RPC

Where to persist:

```sql
-- +goose Up
CREATE TABLE IF NOT EXISTS rpc_endpoints (
    id           TEXT PRIMARY KEY,
    chain_id     INTEGER NOT NULL,
    name         TEXT NOT NULL,           -- user label "My Infura node"
    http_url     TEXT NOT NULL,
    ws_url       TEXT NOT NULL DEFAULT '',
    is_default   INTEGER NOT NULL DEFAULT 0,
    is_active    INTEGER NOT NULL DEFAULT 0, -- only one is_active=1 globally
    added_at     DATETIME NOT NULL
);

CREATE INDEX idx_rpc_active ON rpc_endpoints(is_active);

-- +goose Down
DROP INDEX IF EXISTS idx_rpc_active;
DROP TABLE IF EXISTS rpc_endpoints;
```

Active endpoint replaces `config.ethereum.http_url` /
`config.ethereum.ws_url` at boot. Config file becomes a fallback if no
DB row is `is_active=1`.

Backend refactor:

- `internal/adapter/eth/adapter.go` reads from DB, not config.
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
  chain id. Warn if mismatch.
- WS endpoint must accept a subscription test. Optional — can fall
  back to HTTP polling.

## Token icon source

Today: hardcoded list + Alchemy metadata + fallback ETH glyph. Better:

[Trust Wallet asset CDN](https://github.com/trustwallet/assets):
`https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/{contract}/logo.png`.

Replace the lookup in `core/widgets/token_icon.dart` with a fetcher
that hits Trust Wallet's CDN, caches in
`~/Library/Caches/Nox/token-icons/`, falls back to Alchemy metadata,
falls back to a deterministic `avatarColorFor()` placeholder.

For multi-chain switch the path becomes
`blockchains/{chain}/assets/{contract}/logo.png` where `{chain}` is
`ethereum / smartchain / polygon / avalanchec / arbitrum / base`.

## Done when

- [ ] User can switch between Mainnet / Sepolia / BNB / Polygon /
  Avax / Arbitrum / Base via UI selector
- [ ] User can add a custom RPC endpoint, validation warns on chain
  id mismatch
- [ ] Watcher correctly re-binds on chain switch (cursor reset, no
  notifications from the old chain leaking)
- [ ] Token icons fetched from Trust Wallet CDN, cached on disk,
  fallback chain works
- [ ] Config file becomes optional — DB-stored endpoints take
  precedence
