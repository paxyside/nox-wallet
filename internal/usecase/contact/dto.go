package contact

import "github.com/paxyside/nox-wallet/pkg/ethkit"

type CreateParams struct {
	Address ethkit.Address
	Name    string
	Notes   string
}

type UpdateParams struct {
	ID    string
	Name  string
	Notes string
}
