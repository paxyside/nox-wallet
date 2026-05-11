package service

import (
	"context"

	"github.com/paxyside/nox-wallet/internal/domain/contact/entity"
)

// Repository is implemented by storage/sqlite.
type Repository interface {
	Create(ctx context.Context, c *entity.Contact) error
	GetByID(ctx context.Context, id string) (*entity.Contact, error)
	GetByAddress(ctx context.Context, address string) (*entity.Contact, error)
	Update(ctx context.Context, c *entity.Contact) error
	SetFavorite(ctx context.Context, id string, favorite bool) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context) ([]*entity.Contact, error)
}

type Service struct {
	repo Repository
}

func New(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Create(ctx context.Context, c *entity.Contact) error {
	return s.repo.Create(ctx, c)
}

func (s *Service) GetByID(ctx context.Context, id string) (*entity.Contact, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *Service) GetByAddress(ctx context.Context, address string) (*entity.Contact, error) {
	return s.repo.GetByAddress(ctx, address)
}

func (s *Service) Update(ctx context.Context, c *entity.Contact) error {
	return s.repo.Update(ctx, c)
}

func (s *Service) SetFavorite(ctx context.Context, id string, favorite bool) error {
	return s.repo.SetFavorite(ctx, id, favorite)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}

func (s *Service) List(ctx context.Context) ([]*entity.Contact, error) {
	return s.repo.List(ctx)
}
