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
