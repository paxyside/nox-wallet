package eth

import (
	"context"
	"database/sql"
	"math/big"
	"sync"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
	liblogger "github.com/paxyside/nox-wallet/pkg/logger"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

// PendingStore mirrors ethkit's in-memory pending registry into SQLite
// so the `Kind` tag (and the rest of [ethkit.PendingTx]) survives a
// backend restart. Without persistence, the watcher's deferred-emit
// logic for swaps breaks the moment we lose the in-flight tag —
// which happens reliably on every dev cycle (`task clean && task dev`)
// and on any backend crash mid-mining.
//
// Architecture: the store keeps an in-memory snapshot for fast reads
// (the watcher reads `Recent` on every poll tick — must be cheap) and
// writes through to SQLite on every mutation. On startup, it hydrates
// the snapshot from the DB. A janitor goroutine deletes rows past the
// recent-TTL window so the table stays bounded.
type PendingStore struct {
	db  *sqlitekit.Client
	log liblogger.Log

	mu     sync.RWMutex
	active map[string]ethkit.PendingTx    // hash → currently-pending
	recent map[string]recentSnapshotEntry // hash → recently-removed (within TTL)
}

type recentSnapshotEntry struct {
	tx        ethkit.PendingTx
	removedAt time.Time
}

// NewPendingStore opens or creates the pending_txs-backed store and
// hydrates its in-memory cache. Caller must invoke [Run] in a
// goroutine to enable the periodic GC sweep.
func NewPendingStore(ctx context.Context, db *sqlitekit.Client, log liblogger.Log) (*PendingStore, error) {
	s := &PendingStore{
		db:     db,
		log:    log,
		active: make(map[string]ethkit.PendingTx),
		recent: make(map[string]recentSnapshotEntry),
	}

	if err := s.hydrate(ctx); err != nil {
		return nil, err
	}

	return s, nil
}

// Compile-time check.
var _ ethkit.PendingStore = (*PendingStore)(nil)

// Run starts a periodic GC pass that deletes rows past the recent-TTL
// window. Returns when ctx is canceled. Call once from the app's
// runner group.
func (s *PendingStore) Run(ctx context.Context) error {
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			s.gc(ctx)
		}
	}
}

// Add stamps a new pending tx in the in-memory snapshot and writes
// through to SQLite. Errors during to write are logged — the
// in-memory state still reflects the live registry, so the user-visible flow doesn't break, but the persistence guarantee weakens
// for that one tx.
func (s *PendingStore) Add(tx ethkit.PendingTx) {
	s.mu.Lock()
	s.active[tx.Hash] = tx
	s.recent[tx.Hash] = recentSnapshotEntry{tx: tx}
	s.mu.Unlock()

	_, err := s.db.Exec(context.Background(),
		`INSERT OR REPLACE INTO pending_txs
			(hash, from_address, to_address, value, nonce,
			 gas_tip_wei, gas_cap_wei, kind, submitted_at, removed_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)`,
		tx.Hash,
		tx.From.Hex(),
		tx.To.Hex(),
		tx.Value.Wei().String(),
		// Nonce comes from go-ethereum (uint64) — overflow into int64
		// is theoretically possible at ~9.2 quintillion, which is
		// 18× the total ETH txs ever broadcast. We accept the risk.
		int64(tx.Nonce), //nolint:gosec // see comment above
		tx.GasTipWei.Wei().String(),
		tx.GasCapWei.Wei().String(),
		tx.Kind,
		tx.SubmittedAt.UTC(),
	)
	if err != nil {
		s.log.Warn("pending_store: insert failed", "hash", tx.Hash, "error", err)
	}
}

// Remove transitions a tx out of the active set. The row stays in
// SQLite with a stamped `removed_at` so the watcher's lookback can
// still see it for the [ethkit.RecentTTL] window before the GC sweep
// purges it.
func (s *PendingStore) Remove(hash string) {
	s.mu.Lock()
	if tx, ok := s.active[hash]; ok {
		s.recent[hash] = recentSnapshotEntry{tx: tx, removedAt: time.Now()}
	}
	delete(s.active, hash)
	s.mu.Unlock()

	_, err := s.db.Exec(context.Background(),
		`UPDATE pending_txs SET removed_at = ? WHERE hash = ?`,
		time.Now().UTC(), hash,
	)
	if err != nil {
		s.log.Warn("pending_store: stamp remove failed", "hash", hash, "error", err)
	}
}

// List returns currently-active pending transactions. Reads from the
// in-memory snapshot — the SQLite copy is the durable mirror, not the
// hot read path.
func (s *PendingStore) List() []ethkit.PendingTx {
	s.mu.RLock()
	defer s.mu.RUnlock()

	out := make([]ethkit.PendingTx, 0, len(s.active))
	for _, tx := range s.active {
		out = append(out, tx)
	}

	return out
}

// Recent returns active + recently-removed txs (within
// [ethkit.RecentTTL]). Same hot-path semantics as [List].
func (s *PendingStore) Recent() []ethkit.PendingTx {
	s.mu.RLock()
	defer s.mu.RUnlock()

	out := make([]ethkit.PendingTx, 0, len(s.recent))
	now := time.Now()

	for _, e := range s.recent {
		if !e.removedAt.IsZero() && now.Sub(e.removedAt) > ethkit.RecentTTL {
			continue
		}

		out = append(out, e.tx)
	}

	return out
}

// hydrate populates the in-memory snapshot from SQLite at startup.
// Rows past the TTL get deleted in the same pass so the snapshot
// stays clean from the first call.
func (s *PendingStore) hydrate(ctx context.Context) error {
	cutoff := time.Now().Add(-ethkit.RecentTTL).UTC()

	if _, err := s.db.Exec(ctx,
		`DELETE FROM pending_txs WHERE removed_at IS NOT NULL AND removed_at < ?`,
		cutoff,
	); err != nil {
		return err
	}

	rows, err := s.db.Query(ctx,
		`SELECT hash, from_address, to_address, value, nonce,
		        gas_tip_wei, gas_cap_wei, kind, submitted_at, removed_at
		 FROM pending_txs`,
	)
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		var (
			hash, fromHex, toHex, valueStr, gasTipStr, gasCapStr, kind string
			nonce                                                      int64
			submittedAt                                                time.Time
			removedAt                                                  sql.NullTime
		)

		if scanErr := rows.Scan(
			&hash, &fromHex, &toHex, &valueStr, &nonce,
			&gasTipStr, &gasCapStr, &kind, &submittedAt, &removedAt,
		); scanErr != nil {
			return scanErr
		}

		from, err := ethkit.NewAddress(fromHex)
		if err != nil {
			s.log.Warn("pending_store: drop row with bad from address",
				"hash", hash, "from", fromHex)

			continue
		}

		to, err := ethkit.NewAddress(toHex)
		if err != nil {
			s.log.Warn("pending_store: drop row with bad to address",
				"hash", hash, "to", toHex)

			continue
		}

		tx := ethkit.PendingTx{
			Hash:  hash,
			From:  from,
			To:    to,
			Value: parseWei(valueStr),
			// Inverse of the int64(uint64) cast on insert; overflow
			// is impossible at realistic nonce values (see Add).
			Nonce:       uint64(nonce), //nolint:gosec // see comment above
			GasTipWei:   parseWei(gasTipStr),
			GasCapWei:   parseWei(gasCapStr),
			SubmittedAt: submittedAt.UTC(),
			Kind:        kind,
		}

		if removedAt.Valid {
			s.recent[hash] = recentSnapshotEntry{tx: tx, removedAt: removedAt.Time.UTC()}
		} else {
			s.active[hash] = tx
			s.recent[hash] = recentSnapshotEntry{tx: tx}
		}
	}

	if err := rows.Err(); err != nil {
		return err
	}

	s.log.Info("pending_store: hydrated",
		"active", len(s.active),
		"recent", len(s.recent)-len(s.active),
	)

	return nil
}

// gc deletes rows past the recent-TTL window from SQLite and prunes
// the in-memory snapshot accordingly. Run on a one-minute ticker.
func (s *PendingStore) gc(ctx context.Context) {
	cutoff := time.Now().Add(-ethkit.RecentTTL).UTC()

	if _, err := s.db.Exec(ctx,
		`DELETE FROM pending_txs WHERE removed_at IS NOT NULL AND removed_at < ?`,
		cutoff,
	); err != nil {
		s.log.Warn("pending_store: gc delete failed", "error", err)
		return
	}

	s.mu.Lock()
	now := time.Now()

	for h, e := range s.recent {
		if !e.removedAt.IsZero() && now.Sub(e.removedAt) > ethkit.RecentTTL {
			delete(s.recent, h)
		}
	}
	s.mu.Unlock()
}

// parseWei is a defensive helper — bad data shouldn't crash the
// hydrate path. Returns zero Amount on parse failure.
func parseWei(s string) ethkit.Amount {
	n, ok := new(big.Int).SetString(s, 10)
	if !ok {
		return ethkit.NewAmountFromWei(big.NewInt(0))
	}

	return ethkit.NewAmountFromWei(n)
}
