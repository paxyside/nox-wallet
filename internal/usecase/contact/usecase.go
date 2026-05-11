package contact

import (
	"context"

	"github.com/paxyside/nox-wallet/internal/domain/contact/entity"
	contactservice "github.com/paxyside/nox-wallet/internal/domain/contact/service"
	"github.com/paxyside/nox-wallet/internal/usecase"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

type ContactService interface {
	Create(ctx context.Context, c *entity.Contact) error
	GetByID(ctx context.Context, id string) (*entity.Contact, error)
	GetByAddress(ctx context.Context, address string) (*entity.Contact, error)
	Update(ctx context.Context, c *entity.Contact) error
	SetFavorite(ctx context.Context, id string, favorite bool) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context) ([]*entity.Contact, error)
}

var _ ContactService = (*contactservice.Service)(nil)

type Usecase struct {
	*usecase.BaseUsecase
	log logger.Log
	svc ContactService
}

func New(base *usecase.BaseUsecase, log logger.Log, svc ContactService) *Usecase {
	return &Usecase{BaseUsecase: base, log: log, svc: svc}
}

func (u *Usecase) Create(ctx context.Context, p CreateParams) (*entity.Contact, error) {
	c := &entity.Contact{
		ID:        u.ULID(),
		Address:   p.Address,
		Name:      p.Name,
		Notes:     p.Notes,
		CreatedAt: u.NowUTC(),
		UpdatedAt: u.NowUTC(),
	}
	if err := u.svc.Create(ctx, c); err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "create contact")
	}

	return c, nil
}

func (u *Usecase) GetByID(ctx context.Context, id string) (*entity.Contact, error) {
	return u.svc.GetByID(ctx, id)
}

func (u *Usecase) Update(ctx context.Context, p UpdateParams) (*entity.Contact, error) {
	c, err := u.svc.GetByID(ctx, p.ID)
	if err != nil {
		return nil, err
	}

	c.Name = p.Name
	c.Notes = p.Notes

	c.UpdatedAt = u.NowUTC()
	if err := u.svc.Update(ctx, c); err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "update contact")
	}

	return c, nil
}

func (u *Usecase) SetFavorite(ctx context.Context, id string, favorite bool) error {
	return u.svc.SetFavorite(ctx, id, favorite)
}

func (u *Usecase) Delete(ctx context.Context, id string) error {
	return u.svc.Delete(ctx, id)
}

func (u *Usecase) List(ctx context.Context) ([]*entity.Contact, error) {
	return u.svc.List(ctx)
}
