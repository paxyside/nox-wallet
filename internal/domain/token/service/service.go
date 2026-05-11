package service

import (
	"context"

	"github.com/paxyside/nox-wallet/internal/domain/token/entity"
)

// Repository is implemented by storage/sqlite.
type Repository interface {
	Create(ctx context.Context, t *entity.WatchedToken) error
	GetByID(ctx context.Context, id string) (*entity.WatchedToken, error)
	GetByAddress(ctx context.Context, contractAddress string) (*entity.WatchedToken, error)
	SetPinned(ctx context.Context, id string, pinned bool) error
	SetHidden(ctx context.Context, id string, hidden bool) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context) ([]*entity.WatchedToken, error)
}

type Service struct {
	repo Repository
}

func New(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Create(ctx context.Context, t *entity.WatchedToken) error {
	return s.repo.Create(ctx, t)
}

func (s *Service) GetByID(ctx context.Context, id string) (*entity.WatchedToken, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *Service) GetByAddress(ctx context.Context, contractAddress string) (*entity.WatchedToken, error) {
	return s.repo.GetByAddress(ctx, contractAddress)
}

func (s *Service) SetPinned(ctx context.Context, id string, pinned bool) error {
	return s.repo.SetPinned(ctx, id, pinned)
}

func (s *Service) SetHidden(ctx context.Context, id string, hidden bool) error {
	return s.repo.SetHidden(ctx, id, hidden)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}

func (s *Service) List(ctx context.Context) ([]*entity.WatchedToken, error) {
	return s.repo.List(ctx)
}
