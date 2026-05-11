package service

import (
	"context"
	"time"

	"github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
)

// Repository is implemented by storage/sqlite.
type Repository interface {
	Upsert(ctx context.Context, tx *entity.Transaction) error
	GetByHash(ctx context.Context, hash string) (*entity.Transaction, error)
	ListByAddress(ctx context.Context, address string, limit, offset int) ([]*entity.Transaction, error)
	CountByAddress(ctx context.Context, address string) (int, error)
	UpdateGasFees(ctx context.Context, hash, gasFeeEth, gasFeeUsd string) error
	DeleteOlderThan(ctx context.Context, before time.Time) (int64, error)
}

type Service struct {
	repo Repository
}

func New(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Upsert(ctx context.Context, tx *entity.Transaction) error {
	return s.repo.Upsert(ctx, tx)
}

func (s *Service) GetByHash(ctx context.Context, hash string) (*entity.Transaction, error) {
	return s.repo.GetByHash(ctx, hash)
}

func (s *Service) ListByAddress(ctx context.Context, address string, limit, offset int) ([]*entity.Transaction, error) {
	return s.repo.ListByAddress(ctx, address, limit, offset)
}

func (s *Service) CountByAddress(ctx context.Context, address string) (int, error) {
	return s.repo.CountByAddress(ctx, address)
}

func (s *Service) UpdateGasFees(ctx context.Context, hash, gasFeeEth, gasFeeUsd string) error {
	return s.repo.UpdateGasFees(ctx, hash, gasFeeEth, gasFeeUsd)
}

func (s *Service) DeleteOlderThan(ctx context.Context, before time.Time) (int64, error) {
	return s.repo.DeleteOlderThan(ctx, before)
}
