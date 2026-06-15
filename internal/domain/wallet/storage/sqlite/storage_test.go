package sqlite

import (
	"context"
	"path/filepath"
	"testing"
	"time"

	dalsqlite "github.com/paxyside/nox-wallet/internal/dal/sqlite"
	"github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

// newTestStorage opens a migrated SQLite DB in a temp dir and returns a
// wired Storage plus the raw client (for asserting cross-table state).
func newTestStorage(t *testing.T) (*Storage, *sqlitekit.Client) {
	t.Helper()

	ctx := context.Background()
	client, err := sqlitekit.New(ctx, filepath.Join(t.TempDir(), "test.db"))
	if err != nil {
		t.Fatalf("sqlitekit.New: %v", err)
	}
	t.Cleanup(func() { _ = client.Close() })

	if err := dalsqlite.Migrate(ctx, client.DB()); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	return New(client), client
}

func countRows(t *testing.T, c *sqlitekit.Client, table string) int {
	t.Helper()

	var n int
	if err := c.QueryRow(context.Background(), "SELECT COUNT(*) FROM "+table).Scan(&n); err != nil {
		t.Fatalf("count %s: %v", table, err)
	}

	return n
}

func TestReset(t *testing.T) {
	ctx := context.Background()
	s, c := newTestStorage(t)

	addr, err := ethkit.NewAddress("0x61bE3BB037a2eeA06D6f3619be8662BB972a2BE7")
	if err != nil {
		t.Fatalf("addr: %v", err)
	}

	// Seed the wallet row plus one row in every wallet-scoped table and
	// one row in each table Reset must PRESERVE (contacts, settings).
	if err := s.Save(ctx, &entity.Wallet{
		ID:         "w1",
		Address:    addr,
		Label:      "Test",
		SecretType: entity.SecretTypeMnemonic,
		CreatedAt:  time.Now().UTC(),
	}); err != nil {
		t.Fatalf("save wallet: %v", err)
	}

	seed := []struct {
		query string
		args  []any
	}{
		{`INSERT INTO watched_tokens (id, contract_address, symbol, name, decimals, added_at)
		  VALUES (?, ?, ?, ?, ?, ?)`, []any{"t1", "0xtoken", "USDC", "USD Coin", 6, time.Now().UTC()}},
		{
			`INSERT INTO transactions (id, unique_id, hash, from_address, to_address, value, asset,
		  category, block_number, timestamp, cached_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
			[]any{
				"tx1",
				"u1",
				"0xhash",
				"0xfrom",
				"0xto",
				"1",
				"ETH",
				"external",
				1,
				time.Now().UTC(),
				time.Now().UTC(),
			},
		},
		{
			`INSERT INTO notifications (id, event_kind, payload, created_at) VALUES (?,?,?,?)`,
			[]any{"n1", 1, []byte("x"), time.Now().UTC()},
		},
		{
			`INSERT INTO pending_txs (hash, from_address, to_address, value, nonce, gas_tip_wei,
		  gas_cap_wei, submitted_at) VALUES (?,?,?,?,?,?,?,?)`,
			[]any{"0xp1", "0xfrom", "0xto", "1", 1, "0", "0", time.Now().UTC()},
		},
		{
			`INSERT INTO contacts (id, address, name, created_at, updated_at) VALUES (?,?,?,?,?)`,
			[]any{"c1", "0xcontact", "Alice", time.Now().UTC(), time.Now().UTC()},
		},
	}
	for _, q := range seed {
		if _, err := c.Exec(ctx, q.query, q.args...); err != nil {
			t.Fatalf("seed: %v", err)
		}
	}

	if err := s.Reset(ctx); err != nil {
		t.Fatalf("reset: %v", err)
	}

	// Wallet-scoped tables must be empty.
	for _, table := range resetTables {
		if got := countRows(t, c, table); got != 0 {
			t.Errorf("table %s should be empty after Reset, got %d rows", table, got)
		}
	}

	// Global tables must survive.
	if got := countRows(t, c, "contacts"); got != 1 {
		t.Errorf("contacts should survive Reset, got %d rows", got)
	}
	if got := countRows(t, c, "notification_settings"); got != 1 {
		t.Errorf("notification_settings should survive Reset, got %d rows", got)
	}
}
