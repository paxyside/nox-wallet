package entity

import (
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

type Contact struct {
	ID         string
	Address    ethkit.Address
	Name       string
	Notes      string
	IsFavorite bool
	CreatedAt  time.Time
	UpdatedAt  time.Time
}
