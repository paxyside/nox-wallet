package sqlite

import (
	"context"
	"database/sql"
	"time"

	"github.com/shopspring/decimal"

	"github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
	txsvc "github.com/paxyside/nox-wallet/internal/domain/transaction/service"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

var _ txsvc.Repository = (*Storage)(nil)

type Storage struct {
	db *sqlitekit.Client
}

func New(db *sqlitekit.Client) *Storage {
	return &Storage{db: db}
}

func (s *Storage) Upsert(ctx context.Context, tx *entity.Transaction) error {
	// Conflict key is `unique_id` (Alchemy's "<hash>:<category>:<log_index>")
	// rather than `hash` — a single Ethereum tx (one hash) can emit multiple
	// ERC-20 transfer entries (e.g. a Uniswap swap is one hash but two legs:
	// USDC out + OTHER in). Each leg gets its own row, so neither overwrites
	// the other's asset / value / direction.
	_, err := s.db.Exec(ctx, `
		INSERT INTO transactions
			(id, unique_id, hash, from_address, to_address, value, asset, category, block_number,
			 timestamp, cached_at, gas_fee_eth, gas_fee_usd)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(unique_id) DO UPDATE SET
			cached_at = excluded.cached_at`,
		tx.ID, tx.UniqueID, tx.Hash, tx.From.Hex(), tx.To.Hex(),
		tx.Value.String(), tx.Asset, string(tx.Category),
		tx.BlockNumber, tx.Timestamp.UTC(), tx.CachedAt.UTC(),
		tx.GasFeeEth, tx.GasFeeUsd,
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "upsert transaction")
	}

	return nil
}

// UpdateGasFees stores gas fee values for an existing transaction row.
// It is a no-op if the row does not exist.
func (s *Storage) UpdateGasFees(ctx context.Context, hash, gasFeeEth, gasFeeUsd string) error {
	_, err := s.db.Exec(ctx,
		`UPDATE transactions SET gas_fee_eth = ?, gas_fee_usd = ? WHERE hash = ?`,
		gasFeeEth, gasFeeUsd, hash,
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "update gas fees")
	}

	return nil
}

const txSelectColumns = `id, unique_id, hash, from_address, to_address, value, asset, category,
	block_number, timestamp, cached_at, gas_fee_eth, gas_fee_usd`

func (s *Storage) GetByHash(ctx context.Context, hash string) (*entity.Transaction, error) {
	row := s.db.QueryRow(ctx,
		`SELECT `+txSelectColumns+` FROM transactions WHERE hash = ? LIMIT 1`, hash)

	tx, err := scanTx(row)
	if liberrors.Is(err, sql.ErrNoRows) {
		return nil, liberrors.Newf(liberrors.CodeNotFound, "transaction not found: %s", hash)
	}

	return tx, err
}

func (s *Storage) ListByAddress(ctx context.Context, address string, limit, offset int) ([]*entity.Transaction, error) {
	rows, err := s.db.Query(ctx,
		`SELECT `+txSelectColumns+` FROM transactions
		 WHERE from_address = ? OR to_address = ?
		 ORDER BY timestamp DESC, unique_id ASC
		 LIMIT ? OFFSET ?`,
		address, address, limit, offset,
	)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list transactions")
	}
	defer rows.Close()

	var out []*entity.Transaction

	for rows.Next() {
		tx, err := scanTx(rows)
		if err != nil {
			return nil, err
		}

		out = append(out, tx)
	}

	return out, rows.Err()
}

// CountByAddress counts the number of *user-visible* history entries for the
// address. We deliberately collapse multi-leg rows that share a transaction
// hash (e.g. a swap = USDC out + WBTC in, same hash, two rows) into one — the
// UI merges those legs into a single SWAP entry, so a raw COUNT(*) would
// over-count and the "Showing 12 of 47" footer would never match the visible
// list. COUNT(DISTINCT hash) tracks the real number of on-chain transactions
// the wallet participated in.
func (s *Storage) CountByAddress(ctx context.Context, address string) (int, error) {
	var count int

	row := s.db.QueryRow(ctx,
		`SELECT COUNT(DISTINCT hash) FROM transactions WHERE from_address = ? OR to_address = ?`,
		address, address,
	)
	if err := row.Scan(&count); err != nil {
		return 0, liberrors.Wrapf(err, liberrors.CodeInternal, "count transactions")
	}

	return count, nil
}

func (s *Storage) DeleteOlderThan(ctx context.Context, before time.Time) (int64, error) {
	res, err := s.db.Exec(ctx, `DELETE FROM transactions WHERE timestamp < ?`, before.UTC())
	if err != nil {
		return 0, liberrors.Wrapf(err, liberrors.CodeInternal, "delete old transactions")
	}

	n, _ := res.RowsAffected()

	return n, nil
}

func scanTx(s interface{ Scan(dest ...any) error }) (*entity.Transaction, error) {
	var (
		tx        entity.Transaction
		fromHex   string
		toHex     string
		valueStr  string
		category  string
		timestamp time.Time
		cachedAt  time.Time
	)
	if err := s.Scan(
		&tx.ID, &tx.UniqueID, &tx.Hash, &fromHex, &toHex, &valueStr,
		&tx.Asset, &category, &tx.BlockNumber, &timestamp, &cachedAt,
		&tx.GasFeeEth, &tx.GasFeeUsd,
	); err != nil {
		return nil, err
	}

	from, err := ethkit.NewAddress(fromHex)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "invalid from address")
	}

	to, err := ethkit.NewAddress(toHex)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "invalid to address")
	}

	val, err := decimal.NewFromString(valueStr)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "invalid value")
	}

	tx.From = from
	tx.To = to
	tx.Value = val
	tx.Category = ethkit.AssetTransferCategory(category)
	tx.Timestamp = timestamp.UTC()
	tx.CachedAt = cachedAt.UTC()

	return &tx, nil
}
