package entity

import (
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

type WatchedToken struct {
	ID    string
	Token ethkit.Token

	// IsPinned controls dashboard prominence — pinned tokens render first
	// across Tokens, Dashboard portfolio, and Send asset selectors.
	IsPinned bool

	// IsHidden suppresses the token from user-visible lists without removing
	// it from the watchlist. Auto-seed dedup still sees hidden tokens (so
	// they aren't re-added on every history sync), but the UI filters them
	// out by default. Use Delete to permanently remove a token.
	IsHidden bool

	AddedAt time.Time
}
