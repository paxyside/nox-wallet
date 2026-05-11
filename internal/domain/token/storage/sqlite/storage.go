package sqlite

import (
	"context"
	"database/sql"
	"strings"
	"time"

	"github.com/paxyside/nox-wallet/internal/domain/token/entity"
	tokensvc "github.com/paxyside/nox-wallet/internal/domain/token/service"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

var _ tokensvc.Repository = (*Storage)(nil)

type Storage struct {
	db *sqlitekit.Client
}

func New(db *sqlitekit.Client) *Storage {
	return &Storage{db: db}
}

func (s *Storage) Create(ctx context.Context, t *entity.WatchedToken) error {
	_, err := s.db.Exec(
		ctx,
		`INSERT INTO watched_tokens (id, contract_address, symbol, name, decimals, is_pinned, is_hidden, added_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		t.ID,
		t.Token.Address.Hex(),
		t.Token.Symbol,
		t.Token.Name,
		t.Token.Decimals,
		t.IsPinned,
		t.IsHidden,
		t.AddedAt.UTC(),
	)
	if err != nil {
		if isUniqueConstraint(err) {
			return entity.ErrAlreadyExists
		}

		return liberrors.Wrapf(err, liberrors.CodeInternal, "insert watched token")
	}

	return nil
}

func (s *Storage) SetPinned(ctx context.Context, id string, pinned bool) error {
	res, err := s.db.Exec(ctx, `UPDATE watched_tokens SET is_pinned = ? WHERE id = ?`, pinned, id)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "set token pinned")
	}

	if n, _ := res.RowsAffected(); n == 0 {
		return entity.ErrNotFound
	}

	return nil
}

func (s *Storage) SetHidden(ctx context.Context, id string, hidden bool) error {
	res, err := s.db.Exec(ctx, `UPDATE watched_tokens SET is_hidden = ? WHERE id = ?`, hidden, id)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "set token hidden")
	}

	if n, _ := res.RowsAffected(); n == 0 {
		return entity.ErrNotFound
	}

	return nil
}

func (s *Storage) GetByID(ctx context.Context, id string) (*entity.WatchedToken, error) {
	row := s.db.QueryRow(
		ctx,
		`SELECT id, contract_address, symbol, name, decimals, is_pinned, is_hidden, added_at FROM watched_tokens WHERE id = ?`,
		id,
	)

	t, err := scanToken(row)
	if liberrors.Is(err, sql.ErrNoRows) {
		return nil, entity.ErrNotFound
	}

	return t, err
}

func (s *Storage) GetByAddress(
	ctx context.Context,
	contractAddress string,
) (*entity.WatchedToken, error) {
	row := s.db.QueryRow(
		ctx,
		`SELECT id, contract_address, symbol, name, decimals, is_pinned, is_hidden, added_at FROM watched_tokens WHERE contract_address = ?`,
		contractAddress,
	)

	t, err := scanToken(row)
	if liberrors.Is(err, sql.ErrNoRows) {
		return nil, entity.ErrNotFound
	}

	return t, err
}

func (s *Storage) Delete(ctx context.Context, id string) error {
	res, err := s.db.Exec(ctx, `DELETE FROM watched_tokens WHERE id = ?`, id)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "delete watched token")
	}

	if n, _ := res.RowsAffected(); n == 0 {
		return entity.ErrNotFound
	}

	return nil
}

func (s *Storage) List(ctx context.Context) ([]*entity.WatchedToken, error) {
	rows, err := s.db.Query(
		ctx,
		`SELECT id, contract_address, symbol, name, decimals, is_pinned, is_hidden, added_at FROM watched_tokens ORDER BY is_pinned DESC, symbol`,
	)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list watched tokens")
	}
	defer rows.Close()

	var out []*entity.WatchedToken

	for rows.Next() {
		t, err := scanToken(rows)
		if err != nil {
			return nil, err
		}

		out = append(out, t)
	}

	return out, rows.Err()
}

func scanToken(s interface{ Scan(dest ...any) error }) (*entity.WatchedToken, error) {
	var (
		t        entity.WatchedToken
		addrHex  string
		addedAt  time.Time
		isPinned int
		isHidden int
	)
	if err := s.Scan(
		&t.ID,
		&addrHex,
		&t.Token.Symbol,
		&t.Token.Name,
		&t.Token.Decimals,
		&isPinned,
		&isHidden,
		&addedAt,
	); err != nil {
		return nil, err
	}

	t.IsPinned = isPinned != 0
	t.IsHidden = isHidden != 0

	addr, err := ethkit.NewAddress(addrHex)
	if err != nil {
		return nil, liberrors.Wrapf(
			err,
			liberrors.CodeInternal,
			"invalid stored token address %q",
			addrHex,
		)
	}

	t.Token.Address = addr
	t.AddedAt = addedAt.UTC()

	return &t, nil
}

func isUniqueConstraint(err error) bool {
	return err != nil && strings.Contains(err.Error(), "UNIQUE constraint failed")
}
