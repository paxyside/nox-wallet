-- +goose Up

CREATE TABLE IF NOT EXISTS contacts (
    id          TEXT PRIMARY KEY,
    address     TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    notes       TEXT NOT NULL DEFAULT '',
    is_favorite INTEGER NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL,
    updated_at  DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS watched_tokens (
    id               TEXT PRIMARY KEY,
    contract_address TEXT NOT NULL UNIQUE,
    symbol           TEXT NOT NULL,
    name             TEXT NOT NULL,
    decimals         INTEGER NOT NULL,
    is_pinned        INTEGER NOT NULL DEFAULT 0,
    -- Hidden tokens stay in the watchlist (so the auto-seed dedup map still
    -- recognises them and doesn't re-add them on every history sync) but are
    -- excluded from the user-visible Tokens / Dashboard / Send lists. Lets
    -- the user banish address-poisoning spam without permanently deleting it.
    is_hidden        INTEGER NOT NULL DEFAULT 0,
    added_at         DATETIME NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_watched_tokens_hidden ON watched_tokens(is_hidden);

CREATE TABLE IF NOT EXISTS transactions (
    id           TEXT PRIMARY KEY,
    -- unique_id is Alchemy's "<hash>:<category>:<log_index>" — needed because
    -- a single tx hash can carry multiple ERC-20 transfer entries (e.g. a
    -- Uniswap swap is one hash but two transfers: USDC out + OTHER in).
    unique_id    TEXT NOT NULL UNIQUE,
    hash         TEXT NOT NULL,
    from_address TEXT NOT NULL,
    to_address   TEXT NOT NULL,
    value        TEXT NOT NULL,
    asset        TEXT NOT NULL,
    category     TEXT NOT NULL,
    block_number INTEGER NOT NULL,
    timestamp    DATETIME NOT NULL,
    cached_at    DATETIME NOT NULL,
    gas_fee_eth  TEXT NOT NULL DEFAULT '',
    gas_fee_usd  TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_transactions_from ON transactions(from_address);
CREATE INDEX IF NOT EXISTS idx_transactions_to   ON transactions(to_address);
CREATE INDEX IF NOT EXISTS idx_transactions_ts   ON transactions(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_hash ON transactions(hash);

CREATE TABLE IF NOT EXISTS wallets (
    id          TEXT PRIMARY KEY,
    address     TEXT NOT NULL UNIQUE,
    label       TEXT NOT NULL DEFAULT '',
    secret_type TEXT NOT NULL DEFAULT 'privatekey',
    created_at  DATETIME NOT NULL
);

-- Notifications persists every WalletEvent the watcher emits so the UI
-- can hydrate its notification panel on cold start (Subscribe-channels
-- are broadcast-and-forget). The payload is the proto-serialised
-- WalletEvent, which keeps this table fully decoupled from the Go
-- domain types and lets the gRPC layer hand bytes straight to clients
-- via proto.Unmarshal.
--
-- No UNIQUE constraint on tx_hash: a single hash can legitimately
-- produce multiple events (e.g. re-org + re-emit, or two distinct
-- KindTransaction events from the same hash within different watcher
-- ticks). The id is a server-side ULID — its lex order matches
-- created_at, so created_at-DESC paging is stable.
CREATE TABLE IF NOT EXISTS notifications (
    id          TEXT PRIMARY KEY,
    event_kind  INTEGER NOT NULL,
    tx_hash     TEXT NOT NULL DEFAULT '',
    payload     BLOB NOT NULL,
    is_ours     INTEGER NOT NULL DEFAULT 0,
    -- Per-row read flag. Flips to 1 via MarkRead / MarkAllRead RPCs.
    -- Storing it on the row (rather than a single "last-seen ID" KV
    -- pointer) lets the UI render mixed read/unread sequences after
    -- the user has scrolled past some entries — handy for the
    -- "Unread only" filter in the notification center.
    is_read     INTEGER NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(is_read, created_at DESC);

-- Single-row table holding the user's notification preferences. The
-- CHECK constraint enforces the singleton pattern: the storage layer
-- always writes id=1, so a corrupted multi-row state can't occur.
-- Defaults reflect the most conservative behaviour: sounds and macOS
-- toasts on, no auto-mark-read, no auto-delete, system alerts not
-- muted. The seed row is inserted unconditionally so first-launch
-- code can read settings without a NULL-check branch.
CREATE TABLE IF NOT EXISTS notification_settings (
    id                 INTEGER PRIMARY KEY CHECK (id = 1),
    play_sound         INTEGER NOT NULL DEFAULT 1,
    macos_toasts       INTEGER NOT NULL DEFAULT 1,
    auto_mark_read     INTEGER NOT NULL DEFAULT 0,
    -- 0 means "never auto-delete".
    auto_delete_days   INTEGER NOT NULL DEFAULT 0,
    mute_system_alerts INTEGER NOT NULL DEFAULT 0,
    updated_at         DATETIME NOT NULL
);

INSERT OR IGNORE INTO notification_settings (id, updated_at)
VALUES (1, CURRENT_TIMESTAMP);

-- pending_txs persists in-flight transactions across backend restarts.
-- The in-memory pendingTracker (pkg/ethkit/pending.go) used to lose
-- state on a crash, which made the watcher misclassify swaps that
-- mined right after the restart (no `Kind="swap"` tag → no deferred
-- emission → user sees "Sent USDC" + "Received USDT" instead of one
-- "Swap" entry).
--
-- Active rows have `removed_at IS NULL`. Once `waitForReceipt` returns
-- the row gets stamped with `removed_at` and lingers for a few minutes
-- so the watcher's lookback window can still associate fresh on-chain
-- hashes with the original Kind tag — same TTL as the in-memory
-- `recent` map.
CREATE TABLE IF NOT EXISTS pending_txs (
    hash         TEXT PRIMARY KEY,
    from_address TEXT NOT NULL,
    to_address   TEXT NOT NULL,
    value        TEXT NOT NULL,
    nonce        INTEGER NOT NULL,
    gas_tip_wei  TEXT NOT NULL,
    gas_cap_wei  TEXT NOT NULL,
    kind         TEXT NOT NULL DEFAULT '',
    submitted_at DATETIME NOT NULL,
    removed_at   DATETIME
);

CREATE INDEX IF NOT EXISTS idx_pending_txs_from    ON pending_txs(from_address);
CREATE INDEX IF NOT EXISTS idx_pending_txs_removed ON pending_txs(removed_at);

-- +goose Down
DROP INDEX IF EXISTS idx_pending_txs_removed;
DROP INDEX IF EXISTS idx_pending_txs_from;
DROP TABLE IF EXISTS pending_txs;
DROP TABLE IF EXISTS notification_settings;
DROP INDEX IF EXISTS idx_notifications_unread;
DROP INDEX IF EXISTS idx_notifications_created;
DROP TABLE IF EXISTS notifications;
DROP INDEX IF EXISTS idx_transactions_hash;
DROP INDEX IF EXISTS idx_transactions_ts;
DROP INDEX IF EXISTS idx_transactions_to;
DROP INDEX IF EXISTS idx_transactions_from;
DROP TABLE IF EXISTS transactions;
DROP INDEX IF EXISTS idx_watched_tokens_hidden;
DROP TABLE IF EXISTS watched_tokens;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS wallets;
