// Package sqlite implements the notification.Repository interface on
// top of the project's sqlitekit client. Mirrors the contact / token
// storage style: thin Exec/Query wrappers, errors wrapped with
// liberrors.Wrapf to keep the error chain useful in the handler logs.
package sqlite

import (
	"context"
	"strconv"
	"time"

	"github.com/paxyside/nox-wallet/internal/domain/notification/entity"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

// Repository is the storage contract consumed by the notification
// usecase. Declared here (alongside the only implementation) so the
// usecase package can import it without pulling in sqlitekit.
type Repository interface {
	Insert(ctx context.Context, n *entity.Notification) error
	List(ctx context.Context, limit int) ([]*entity.Notification, error)
	PruneOlderThan(ctx context.Context, keep int) error
	MarkRead(ctx context.Context, id string) error
	MarkAllRead(ctx context.Context) error
	DeleteAll(ctx context.Context) error
	DeleteOlderThanDays(ctx context.Context, days int32) (int64, error)

	GetSettings(ctx context.Context) (*entity.Settings, error)
	UpdateSettings(ctx context.Context, s *entity.Settings) error
}

// Storage is the sqlitekit-backed implementation of Repository.
type Storage struct {
	db *sqlitekit.Client
}

var _ Repository = (*Storage)(nil)

// New returns a Storage that writes to the given sqlitekit client.
func New(db *sqlitekit.Client) *Storage {
	return &Storage{db: db}
}

func (s *Storage) Insert(ctx context.Context, n *entity.Notification) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO notifications (id, event_kind, tx_hash, payload, is_ours, is_read, created_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?)`,
		n.ID,
		int(n.Kind),
		n.TxHash,
		n.Payload,
		boolToInt(n.IsOurs),
		boolToInt(n.IsRead),
		n.CreatedAt.UTC(),
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "insert notification")
	}

	return nil
}

func (s *Storage) List(ctx context.Context, limit int) ([]*entity.Notification, error) {
	rows, err := s.db.Query(ctx,
		`SELECT id, event_kind, tx_hash, payload, is_ours, is_read, created_at
		 FROM notifications
		 ORDER BY created_at DESC
		 LIMIT ?`,
		limit,
	)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list notifications")
	}
	defer rows.Close()

	out := make([]*entity.Notification, 0, limit)

	for rows.Next() {
		n, scanErr := scanNotification(rows)
		if scanErr != nil {
			return nil, scanErr
		}

		out = append(out, n)
	}

	return out, rows.Err()
}

// PruneOlderThan keeps the newest `keep` rows and deletes the rest.
// Called from the usecase right after every Insert to bound storage
// growth — the UI never paginates past this many entries anyway.
func (s *Storage) PruneOlderThan(ctx context.Context, keep int) error {
	_, err := s.db.Exec(ctx,
		`DELETE FROM notifications
		 WHERE id NOT IN (
		     SELECT id FROM notifications ORDER BY created_at DESC LIMIT ?
		 )`,
		keep,
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "prune notifications")
	}

	return nil
}

func (s *Storage) MarkRead(ctx context.Context, id string) error {
	_, err := s.db.Exec(ctx,
		`UPDATE notifications SET is_read = 1 WHERE id = ?`,
		id,
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "mark notification read")
	}

	return nil
}

func (s *Storage) MarkAllRead(ctx context.Context) error {
	_, err := s.db.Exec(ctx, `UPDATE notifications SET is_read = 1 WHERE is_read = 0`)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "mark all notifications read")
	}

	return nil
}

func (s *Storage) DeleteAll(ctx context.Context) error {
	_, err := s.db.Exec(ctx, `DELETE FROM notifications`)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "delete all notifications")
	}

	return nil
}

// DeleteOlderThanDays drops every row created more than `days` days
// ago. Returns the number of rows removed for logging visibility. A
// `days` value <= 0 is a no-op (auto-delete disabled).
func (s *Storage) DeleteOlderThanDays(ctx context.Context, days int32) (int64, error) {
	if days <= 0 {
		return 0, nil
	}

	res, err := s.db.Exec(ctx,
		`DELETE FROM notifications WHERE created_at < datetime('now', ?)`,
		// SQLite modifier: "-N days" subtracts N days from now().
		formatDaysModifier(days),
	)
	if err != nil {
		return 0, liberrors.Wrapf(err, liberrors.CodeInternal, "delete old notifications")
	}

	n, _ := res.RowsAffected()

	return n, nil
}

func (s *Storage) GetSettings(ctx context.Context) (*entity.Settings, error) {
	rows, err := s.db.Query(ctx,
		`SELECT play_sound, macos_toasts, auto_mark_read, auto_delete_days,
		        mute_system_alerts, updated_at
		 FROM notification_settings
		 WHERE id = 1`,
	)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "get notification settings")
	}
	defer rows.Close()

	if !rows.Next() {
		// Migration seeds id=1, so we shouldn't reach here unless the
		// row was deleted by hand. Return defaults rather than 500.
		return &entity.Settings{
			PlaySound:   true,
			MacOSToasts: true,
		}, rows.Err()
	}

	var (
		playSound        int
		macosToasts      int
		autoMarkRead     int
		autoDeleteDays   int32
		muteSystemAlerts int
		updatedAt        time.Time
	)

	if scanErr := rows.Scan(
		&playSound, &macosToasts, &autoMarkRead, &autoDeleteDays,
		&muteSystemAlerts, &updatedAt,
	); scanErr != nil {
		return nil, liberrors.Wrapf(scanErr, liberrors.CodeInternal, "scan notification settings")
	}

	return &entity.Settings{
		PlaySound:        playSound != 0,
		MacOSToasts:      macosToasts != 0,
		AutoMarkRead:     autoMarkRead != 0,
		AutoDeleteDays:   autoDeleteDays,
		MuteSystemAlerts: muteSystemAlerts != 0,
		UpdatedAt:        updatedAt.UTC(),
	}, rows.Err()
}

func (s *Storage) UpdateSettings(ctx context.Context, st *entity.Settings) error {
	_, err := s.db.Exec(ctx,
		`UPDATE notification_settings
		 SET play_sound = ?, macos_toasts = ?, auto_mark_read = ?,
		     auto_delete_days = ?, mute_system_alerts = ?, updated_at = ?
		 WHERE id = 1`,
		boolToInt(st.PlaySound),
		boolToInt(st.MacOSToasts),
		boolToInt(st.AutoMarkRead),
		st.AutoDeleteDays,
		boolToInt(st.MuteSystemAlerts),
		st.UpdatedAt.UTC(),
	)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "update notification settings")
	}

	return nil
}

func scanNotification(s interface{ Scan(dest ...any) error }) (*entity.Notification, error) {
	var (
		n         entity.Notification
		kind      int
		isOurs    int
		isRead    int
		createdAt time.Time
	)
	if err := s.Scan(&n.ID, &kind, &n.TxHash, &n.Payload, &isOurs, &isRead, &createdAt); err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "scan notification")
	}

	// Defensive bound: stored values originate from uint8 EventKind so
	// they always fit, but a corrupted row could carry junk — clamp
	// to 0 rather than wrap silently.
	if kind < 0 || kind > 255 {
		kind = 0
	}

	n.Kind = uint8(kind)
	n.IsOurs = isOurs != 0
	n.IsRead = isRead != 0
	n.CreatedAt = createdAt.UTC()

	return &n, nil
}

func boolToInt(b bool) int {
	if b {
		return 1
	}

	return 0
}

// formatDaysModifier builds the SQLite datetime() modifier string for
// "N days ago", e.g. days=7 → "-7 days". Used with `datetime('now', ?)`.
func formatDaysModifier(days int32) string {
	return "-" + strconv.FormatInt(int64(days), 10) + " days"
}
