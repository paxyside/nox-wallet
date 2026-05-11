package eth

import (
	"context"
	"path/filepath"
	"sync"
	"testing"
	"time"

	dalsqlite "github.com/paxyside/nox-wallet/internal/dal/sqlite"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

// nopLog satisfies liblogger.Log without doing anything. Tests don't
// want stderr noise from PendingStore's "insert failed" warnings on
// the negative-path tests (we explicitly close the DB to trigger them).
type nopLog struct{}

func (nopLog) Debug(string, ...any)                         {}
func (nopLog) Info(string, ...any)                          {}
func (nopLog) Warn(string, ...any)                          {}
func (nopLog) Error(string, ...any)                         {}
func (nopLog) DebugContext(context.Context, string, ...any) {}
func (nopLog) InfoContext(context.Context, string, ...any)  {}
func (nopLog) WarnContext(context.Context, string, ...any)  {}
func (nopLog) ErrorContext(context.Context, string, ...any) {}

// newTestStore opens a fresh SQLite DB in a temp dir, applies
// migrations, and returns a wired PendingStore. Cleanup is registered
// via t.Cleanup so callers don't have to remember to close.
func newTestStore(t *testing.T) (*PendingStore, *sqlitekit.Client) {
	t.Helper()

	dbPath := filepath.Join(t.TempDir(), "test.db")

	ctx := context.Background()

	client, err := sqlitekit.New(ctx, dbPath)
	if err != nil {
		t.Fatalf("sqlitekit.New: %v", err)
	}

	t.Cleanup(func() { _ = client.Close() })

	if migErr := dalsqlite.Migrate(ctx, client.DB()); migErr != nil {
		t.Fatalf("migrate: %v", migErr)
	}

	store, err := NewPendingStore(ctx, client, nopLog{})
	if err != nil {
		t.Fatalf("NewPendingStore: %v", err)
	}

	return store, client
}

func makeTx(hashHex string, kind string) ethkit.PendingTx {
	from, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	to, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")

	return ethkit.PendingTx{
		Hash:        hashHex,
		From:        from,
		To:          to,
		Value:       ethkit.ZeroAmount,
		Nonce:       42,
		GasTipWei:   ethkit.ZeroAmount,
		GasCapWei:   ethkit.ZeroAmount,
		Kind:        kind,
		SubmittedAt: time.Now().UTC(),
	}
}

func TestPendingStore_AddListRecent(t *testing.T) {
	store, _ := newTestStore(t)

	store.Add(makeTx("0xa", "swap"))
	store.Add(makeTx("0xb", "send"))

	if got := len(store.List()); got != 2 {
		t.Fatalf("List want 2, got %d", got)
	}

	if got := len(store.Recent()); got != 2 {
		t.Fatalf("Recent want 2 (active counts as recent), got %d", got)
	}
}

func TestPendingStore_RemoveTransitionsToRecent(t *testing.T) {
	store, _ := newTestStore(t)

	store.Add(makeTx("0xa", "swap"))
	store.Remove("0xa")

	if got := len(store.List()); got != 0 {
		t.Errorf("after Remove, List should be empty; got %d", got)
	}

	// Within RecentTTL, Recent still surfaces it so the watcher
	// lookback can still associate the freshly-mined hash.
	if got := len(store.Recent()); got != 1 {
		t.Errorf("Recent should keep removed entries until TTL; got %d", got)
	}
}

func TestPendingStore_HydrateRebuildsState(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "test.db")
	ctx := context.Background()

	client, err := sqlitekit.New(ctx, dbPath)
	if err != nil {
		t.Fatalf("open: %v", err)
	}

	if err := dalsqlite.Migrate(ctx, client.DB()); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	// First store: write some entries, drop one, close.
	first, err := NewPendingStore(ctx, client, nopLog{})
	if err != nil {
		t.Fatalf("first NewPendingStore: %v", err)
	}

	first.Add(makeTx("0xa", "swap"))
	first.Add(makeTx("0xb", "send"))
	first.Remove("0xa")

	// Second store: same DB, fresh in-memory snapshot. Should pull
	// 0xa as removed (still in Recent) and 0xb as active.
	second, err := NewPendingStore(ctx, client, nopLog{})
	if err != nil {
		t.Fatalf("second NewPendingStore: %v", err)
	}

	if got := len(second.List()); got != 1 {
		t.Errorf("second.List want 1 (0xb only), got %d", got)
	}

	if got := len(second.Recent()); got != 2 {
		t.Errorf("second.Recent want 2 (0xa+0xb both within TTL), got %d", got)
	}
}

func TestPendingStore_HydrateDropsExpiredRows(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "test.db")
	ctx := context.Background()

	client, err := sqlitekit.New(ctx, dbPath)
	if err != nil {
		t.Fatalf("open: %v", err)
	}

	if err := dalsqlite.Migrate(ctx, client.DB()); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	// Insert a row with a removed_at older than RecentTTL via raw SQL.
	old := time.Now().Add(-2 * ethkit.RecentTTL).UTC()
	if _, err := client.Exec(ctx,
		`INSERT INTO pending_txs
			(hash, from_address, to_address, value, nonce,
			 gas_tip_wei, gas_cap_wei, kind, submitted_at, removed_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		"0xstale", "0xfrom", "0xto", "0", int64(0),
		"0", "0", "send", old, old,
	); err != nil {
		t.Fatalf("seed stale row: %v", err)
	}

	// Hydrate should DELETE that row in its first pass.
	store, err := NewPendingStore(ctx, client, nopLog{})
	if err != nil {
		t.Fatalf("NewPendingStore: %v", err)
	}

	if got := len(store.Recent()); got != 0 {
		t.Errorf("stale row must be evicted on hydrate; Recent has %d", got)
	}

	row := client.QueryRow(ctx, `SELECT COUNT(*) FROM pending_txs`)
	var count int
	if err := row.Scan(&count); err != nil {
		t.Fatalf("count: %v", err)
	}

	if count != 0 {
		t.Errorf("stale row must be deleted from SQLite; count=%d", count)
	}
}

func TestPendingStore_GCDeletesExpired(t *testing.T) {
	store, client := newTestStore(t)

	// Seed an old removed_at row directly.
	old := time.Now().Add(-2 * ethkit.RecentTTL).UTC()
	if _, err := client.Exec(context.Background(),
		`INSERT INTO pending_txs
			(hash, from_address, to_address, value, nonce,
			 gas_tip_wei, gas_cap_wei, kind, submitted_at, removed_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		"0xstale-gc", "0xfrom", "0xto", "0", int64(0),
		"0", "0", "send", old, old,
	); err != nil {
		t.Fatalf("seed: %v", err)
	}

	// Force the in-memory snapshot to think the entry exists too,
	// otherwise GC has nothing to remove from memory and the test
	// only validates the SQL side.
	store.mu.Lock()
	store.recent["0xstale-gc"] = recentSnapshotEntry{
		tx:        makeTx("0xstale-gc", "send"),
		removedAt: old,
	}
	store.mu.Unlock()

	store.gc(context.Background())

	if _, ok := store.recent["0xstale-gc"]; ok {
		t.Error("gc must drop in-memory expired entries")
	}

	row := client.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM pending_txs WHERE hash = ?`, "0xstale-gc",
	)

	var count int
	if err := row.Scan(&count); err != nil {
		t.Fatalf("scan: %v", err)
	}

	if count != 0 {
		t.Errorf("gc must DELETE expired row from SQLite; count=%d", count)
	}
}

func TestPendingStore_RecentExcludesPastTTL(t *testing.T) {
	store, _ := newTestStore(t)

	store.Add(makeTx("0xa", "swap"))
	store.Remove("0xa")

	// Manually backdate the removal time past TTL.
	store.mu.Lock()
	e := store.recent["0xa"]
	e.removedAt = time.Now().Add(-2 * ethkit.RecentTTL)
	store.recent["0xa"] = e
	store.mu.Unlock()

	if got := len(store.Recent()); got != 0 {
		t.Errorf("Recent must exclude entries past TTL; got %d", got)
	}
}

// Run the store under concurrent Add / Remove / List / Recent calls
// from multiple goroutines and confirm there's no race.
//
// `go test -race` will trip if the locks aren't right.
func TestPendingStore_ConcurrentAccess(t *testing.T) {
	store, _ := newTestStore(t)

	const goroutines = 16
	const iterations = 50

	var wg sync.WaitGroup

	for g := range goroutines {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			for i := range iterations {
				hash := makeHash(id, i)
				store.Add(makeTx(hash, "send"))

				if i%3 == 0 {
					store.Remove(hash)
				}

				_ = store.List()
				_ = store.Recent()
			}
		}(g)
	}

	wg.Wait()
}

func makeHash(g, i int) string {
	const hex = "0123456789abcdef"
	out := []byte("0x")
	for range 40 {
		out = append(out, hex[(g+i)%16])
	}

	return string(out)
}
