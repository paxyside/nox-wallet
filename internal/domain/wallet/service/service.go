package service

import (
	"context"

	"github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
)

// Repository is implemented by storage/sqlite.
type Repository interface {
	Save(ctx context.Context, w *entity.Wallet) error
	Get(ctx context.Context) (*entity.Wallet, error) // single-wallet app — no ID needed
	Delete(ctx context.Context) error
}

type Service struct {
	repo Repository
}

func New(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Save(ctx context.Context, w *entity.Wallet) error {
	return s.repo.Save(ctx, w)
}

func (s *Service) Get(ctx context.Context) (*entity.Wallet, error) {
	return s.repo.Get(ctx)
}

func (s *Service) Delete(ctx context.Context) error {
	return s.repo.Delete(ctx)
}
