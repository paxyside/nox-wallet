package sqlite

import (
	"context"
	"database/sql"
	"time"

	"github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	walletsvc "github.com/paxyside/nox-wallet/internal/domain/wallet/service"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

var _ walletsvc.Repository = (*Storage)(nil)

type Storage struct {
	db *sqlitekit.Client
}

func New(db *sqlitekit.Client) *Storage {
	return &Storage{db: db}
}

func (s *Storage) Save(ctx context.Context, w *entity.Wallet) error {
	_, err := s.db.Exec(ctx, `
		INSERT INTO wallets (id, address, label, secret_type, created_at) VALUES (?, ?, ?, ?, ?)
		ON CONFLICT(address) DO UPDATE SET label = excluded.label, secret_type = excluded.secret_type`,
		w.ID, w.Address.Hex(), w.Label, string(w.SecretType), w.CreatedAt.UTC(),
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "save wallet")
	}

	return nil
}

func (s *Storage) Get(ctx context.Context) (*entity.Wallet, error) {
	row := s.db.QueryRow(ctx,
		`SELECT id, address, label, secret_type, created_at FROM wallets ORDER BY created_at LIMIT 1`)

	var (
		w          entity.Wallet
		addrHex    string
		secretType string
		createdAt  time.Time
	)
	if err := row.Scan(&w.ID, &addrHex, &w.Label, &secretType, &createdAt); err != nil {
		if liberrors.Is(err, sql.ErrNoRows) {
			return nil, entity.ErrNotFound
		}

		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "get wallet")
	}

	addr, err := ethkit.NewAddress(addrHex)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "invalid stored wallet address")
	}

	w.Address = addr
	w.SecretType = entity.SecretType(secretType)
	w.CreatedAt = createdAt.UTC()

	return &w, nil
}

func (s *Storage) Delete(ctx context.Context) error {
	_, err := s.db.Exec(ctx, `DELETE FROM wallets`)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "delete wallet")
	}

	return nil
}

// resetTables lists every wallet-scoped table wiped by Reset. Order is
// irrelevant — there are no cross-table foreign keys — but keeping the
// wallet row last reads as "and finally the wallet itself".
//
// Deliberately excluded:
//   - contacts: a personal address book, not tied to any one wallet.
//   - notification_settings: a global singleton preference row.
var resetTables = []string{
	"watched_tokens",
	"transactions",
	"notifications",
	"pending_txs",
	"wallets",
}

// Reset wipes all wallet-scoped state in a single transaction. Called
// when the user replaces their wallet (Settings → Import new wallet):
// the new wallet starts from a clean slate rather than inheriting the
// previous wallet's token watchlist, transaction history, notification
// feed, and in-flight pending txs — all of which belong to a different
// address and would otherwise show stale, misleading data.
func (s *Storage) Reset(ctx context.Context) error {
	err := s.db.WithTx(ctx, func(tx *sqlitekit.Tx) error {
		for _, table := range resetTables {
			if _, err := tx.Exec(ctx, "DELETE FROM "+table); err != nil {
				return liberrors.Wrapf(err, liberrors.CodeInternal, "reset %s", table)
			}
		}

		return nil
	})
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "reset wallet state")
	}

	return nil
}
