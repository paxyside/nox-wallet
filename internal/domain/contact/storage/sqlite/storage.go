package sqlite

import (
	"context"
	"database/sql"
	"strings"
	"time"

	"github.com/paxyside/nox-wallet/internal/domain/contact/entity"
	contactsvc "github.com/paxyside/nox-wallet/internal/domain/contact/service"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

var _ contactsvc.Repository = (*Storage)(nil)

type Storage struct {
	db *sqlitekit.Client
}

func New(db *sqlitekit.Client) *Storage {
	return &Storage{db: db}
}

func (s *Storage) Create(ctx context.Context, c *entity.Contact) error {
	_, err := s.db.Exec(
		ctx,
		`INSERT INTO contacts (id, address, name, notes, is_favorite, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)`,
		c.ID,
		c.Address.Hex(),
		c.Name,
		c.Notes,
		boolToInt(c.IsFavorite),
		c.CreatedAt.UTC(),
		c.UpdatedAt.UTC(),
	)
	if err != nil {
		if isUniqueConstraint(err) {
			return entity.ErrAlreadyExists
		}

		return liberrors.Wrapf(err, liberrors.CodeInternal, "insert contact")
	}

	return nil
}

func (s *Storage) GetByID(ctx context.Context, id string) (*entity.Contact, error) {
	row := s.db.QueryRow(ctx,
		`SELECT id, address, name, notes, is_favorite, created_at, updated_at FROM contacts WHERE id = ?`, id)

	c, err := scanContact(row)
	if liberrors.Is(err, sql.ErrNoRows) {
		return nil, entity.ErrNotFound
	}

	return c, err
}

func (s *Storage) GetByAddress(ctx context.Context, address string) (*entity.Contact, error) {
	row := s.db.QueryRow(ctx,
		`SELECT id, address, name, notes, is_favorite, created_at, updated_at FROM contacts WHERE address = ?`, address)

	c, err := scanContact(row)
	if liberrors.Is(err, sql.ErrNoRows) {
		return nil, entity.ErrNotFound
	}

	return c, err
}

func (s *Storage) Update(ctx context.Context, c *entity.Contact) error {
	res, err := s.db.Exec(ctx,
		`UPDATE contacts SET name = ?, notes = ?, updated_at = ? WHERE id = ?`,
		c.Name, c.Notes, c.UpdatedAt.UTC(), c.ID,
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "update contact")
	}

	if n, _ := res.RowsAffected(); n == 0 {
		return entity.ErrNotFound
	}

	return nil
}

func (s *Storage) SetFavorite(ctx context.Context, id string, favorite bool) error {
	res, err := s.db.Exec(ctx,
		`UPDATE contacts SET is_favorite = ? WHERE id = ?`,
		boolToInt(favorite), id,
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "set favorite contact")
	}

	if n, _ := res.RowsAffected(); n == 0 {
		return entity.ErrNotFound
	}

	return nil
}

func (s *Storage) Delete(ctx context.Context, id string) error {
	res, err := s.db.Exec(ctx, `DELETE FROM contacts WHERE id = ?`, id)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "delete contact")
	}

	if n, _ := res.RowsAffected(); n == 0 {
		return entity.ErrNotFound
	}

	return nil
}

func (s *Storage) List(ctx context.Context) ([]*entity.Contact, error) {
	rows, err := s.db.Query(
		ctx,
		`SELECT id, address, name, notes, is_favorite, created_at, updated_at FROM contacts ORDER BY is_favorite DESC, name`,
	)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list contacts")
	}
	defer rows.Close()

	var out []*entity.Contact

	for rows.Next() {
		c, err := scanContact(rows)
		if err != nil {
			return nil, err
		}

		out = append(out, c)
	}

	return out, rows.Err()
}

func scanContact(s interface{ Scan(dest ...any) error }) (*entity.Contact, error) {
	var (
		c          entity.Contact
		addrHex    string
		isFavorite int
		createdAt  time.Time
		updatedAt  time.Time
	)
	if err := s.Scan(&c.ID, &addrHex, &c.Name, &c.Notes, &isFavorite, &createdAt, &updatedAt); err != nil {
		return nil, err
	}

	addr, err := ethkit.NewAddress(addrHex)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "invalid stored address %q", addrHex)
	}

	c.Address = addr
	c.IsFavorite = isFavorite != 0
	c.CreatedAt = createdAt.UTC()
	c.UpdatedAt = updatedAt.UTC()

	return &c, nil
}

func boolToInt(b bool) int {
	if b {
		return 1
	}

	return 0
}

func isUniqueConstraint(err error) bool {
	return err != nil && strings.Contains(err.Error(), "UNIQUE constraint failed")
}
