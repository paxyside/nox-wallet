package history

import (
	"github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

type GetHistoryParams struct {
	Address ethkit.Address
	Limit   int

	// Cursor is an opaque string encoding the DB offset ("0", "20", "40", …).
	// Empty string means first page.
	Cursor string

	// WatchedContracts is the list of ERC-20 contract addresses the user cares about.
	// Only transfers involving these contracts are synced from Alchemy.
	// If empty, ERC-20 transfers are skipped entirely (ETH-only history).
	WatchedContracts []ethkit.Address
}

type GetHistoryResult struct {
	Transactions []*entity.Transaction
	Total        int
	NextCursor   string
	HasMore      bool
}
