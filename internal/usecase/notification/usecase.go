// Package notification persists watcher events to SQLite so the UI can
// hydrate its notification panel on cold start. The usecase intentionally
// accepts `kind uint8` rather than watcher.EventKind to avoid a cyclic
// import: watcher itself depends on this package as a `NotificationSink`.
package notification

import (
	"context"

	"github.com/paxyside/nox-wallet/internal/domain/notification/entity"
	notificationsqlite "github.com/paxyside/nox-wallet/internal/domain/notification/storage/sqlite"
	"github.com/paxyside/nox-wallet/internal/usecase"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

// maxStored caps the persisted notification history. Anything beyond
// this gets pruned on the next Save — the UI never paginates that far.
const maxStored = 200

// Repository abstracts the storage layer so the usecase doesn't bind
// to the concrete sqlite type at compile time.
type Repository = notificationsqlite.Repository

// Usecase persists wallet events and serves them back to the gRPC
// handler.
type Usecase struct {
	*usecase.BaseUsecase
	log  logger.Log
	repo Repository
}

// New wires the notification usecase. `base` provides ULID + clock so
// that ID generation and timestamps stay consistent with the rest of
// the codebase (see internal/usecase/contact/usecase.go for the
// canonical pattern).
func New(base *usecase.BaseUsecase, log logger.Log, repo Repository) *Usecase {
	return &Usecase{BaseUsecase: base, log: log, repo: repo}
}

// Save persists a single wallet event. `kind` is the numeric value of
// watcher.EventKind — kept untyped here to avoid an import cycle (the
// watcher takes *this* package as a sink). `payload` is the
// proto-serialized wallet.event.WalletEvent ready for re-emission to
// gRPC clients. Returns the row ID so the caller (watcher fan-out) can
// stamp the live event envelope before broadcasting it to subscribers.
//
// When `auto_mark_read` is enabled in settings, the row is stored with
// is_read=1. This is the user-visible "auto-mark on arrival" toggle —
// useful for users who treat the panel as an audit log rather than an
// inbox. Failure to read settings degrades gracefully to is_read=0.
func (u *Usecase) Save(
	ctx context.Context,
	kind uint8,
	txHash string,
	payload []byte,
	isOurs bool,
) (string, error) {
	autoRead := false

	if s, err := u.repo.GetSettings(ctx); err == nil && s != nil {
		autoRead = s.AutoMarkRead
	}

	n := &entity.Notification{
		ID:        u.ULID(),
		Kind:      kind,
		TxHash:    txHash,
		Payload:   payload,
		IsOurs:    isOurs,
		IsRead:    autoRead,
		CreatedAt: u.NowUTC(),
	}

	if err := u.repo.Insert(ctx, n); err != nil {
		return "", liberrors.Wrapf(err, liberrors.CodeInternal, "save notification")
	}

	// Prune in the same call so the table stays bounded without a
	// separate background job. A failed prune is non-fatal — the row
	// is already saved and the next Save will retry.
	if err := u.repo.PruneOlderThan(ctx, maxStored); err != nil {
		u.log.Warn("notification: prune failed", "error", err)
	}

	// Honor the user's auto-delete preference best-effort. Only runs
	// when the setting is positive, and we already paid for one settings
	// fetch above — but we re-read here to keep the previous block
	// independent of this one's failure mode.
	if s, err := u.repo.GetSettings(ctx); err == nil && s != nil && s.AutoDeleteDays > 0 {
		if removed, delErr := u.repo.DeleteOlderThanDays(ctx, s.AutoDeleteDays); delErr != nil {
			u.log.Warn("notification: auto-delete failed", "error", delErr)
		} else if removed > 0 {
			u.log.Info("notification: auto-delete pruned", "rows", removed, "days", s.AutoDeleteDays)
		}
	}

	return n.ID, nil
}

// List returns up to `limit` newest-first notifications.
func (u *Usecase) List(ctx context.Context, limit int) ([]*entity.Notification, error) {
	out, err := u.repo.List(ctx, limit)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list notifications")
	}

	return out, nil
}

// MarkRead flips a single notification's read flag to true. Idempotent.
func (u *Usecase) MarkRead(ctx context.Context, id string) error {
	if err := u.repo.MarkRead(ctx, id); err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "mark notification read")
	}

	return nil
}

// MarkAllRead bulk-flips every is_read=0 row to is_read=1.
func (u *Usecase) MarkAllRead(ctx context.Context) error {
	if err := u.repo.MarkAllRead(ctx); err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "mark all read")
	}

	return nil
}

// ClearAll wipes the entire notification history. Used by the user-initiated "Clear all" action in the notification center.
func (u *Usecase) ClearAll(ctx context.Context) error {
	if err := u.repo.DeleteAll(ctx); err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "clear notifications")
	}

	return nil
}

// GetSettings reads the singleton notification preferences row.
func (u *Usecase) GetSettings(ctx context.Context) (*entity.Settings, error) {
	out, err := u.repo.GetSettings(ctx)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "get notification settings")
	}

	return out, nil
}

// UpdateSettings stamps `updated_at` with the usecase clock and
// persists. The caller passes a fully-populated Settings — the storage
// layer doesn't merge with the existing row.
func (u *Usecase) UpdateSettings(ctx context.Context, s *entity.Settings) error {
	s.UpdatedAt = u.NowUTC()

	if err := u.repo.UpdateSettings(ctx, s); err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "update notification settings")
	}

	return nil
}

// SweepOnStartup honors the user's `auto_delete_days` retention window
// once at process boot. The per-Save sweep in [Save] only fires when a
// new event arrives — for users on quiet wallets that could leave
// stale rows around indefinitely, so we run a one-shot sweep at
// startup as a safety net. Errors are logged but never returned: a
// failed sweep is a maintenance hiccup, not a startup blocker.
func (u *Usecase) SweepOnStartup(ctx context.Context) {
	s, err := u.repo.GetSettings(ctx)
	if err != nil || s == nil || s.AutoDeleteDays <= 0 {
		return
	}

	removed, err := u.repo.DeleteOlderThanDays(ctx, s.AutoDeleteDays)
	if err != nil {
		u.log.Warn("notification: startup sweep failed", "error", err)
		return
	}

	if removed > 0 {
		u.log.Info("notification: startup sweep removed rows", "rows", removed, "days", s.AutoDeleteDays)
	}
}
