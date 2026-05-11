package grpc

import (
	"context"

	"google.golang.org/protobuf/proto"

	notificationentity "github.com/paxyside/nox-wallet/internal/domain/notification/entity"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbevent "github.com/paxyside/nox-wallet/proto/gen/go/wallet/event"
)

const (
	// notificationsDefaultLimit is applied when the client passes 0 — the
	// usual case for "give me the panel contents". Lower than the
	// max-stored ceiling so the response stays cheap.
	notificationsDefaultLimit = 100
	notificationsMaxLimit     = 200
)

// ListNotifications returns the persisted history wrapped in
// NotificationEnvelopes (id + is_read + WalletEvent), newest first.
// The wire format matches what WatchEvents streams live, so the client
// can store both lists in a single Riverpod-managed collection without
// branching on origin.
func (h *Handler) ListNotifications(
	ctx context.Context,
	req *pb.ListNotificationsRequest,
) (*pb.ListNotificationsResponse, error) {
	limit := clampNotificationsLimit(int(req.GetLimit()))

	rows, err := h.notification.List(ctx, limit)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	items := make([]*pb.NotificationEnvelope, 0, len(rows))

	for _, n := range rows {
		ev := &pbevent.WalletEvent{}
		if unmarshalErr := proto.Unmarshal(n.Payload, ev); unmarshalErr != nil {
			// One bad row shouldn't poison the whole list — log and
			// skip. The persisted payload format is purely server-
			// owned, so a corrupt row is a programmer / migration
			// bug rather than user input.
			h.l.WarnContext(ctx, "list notifications: unmarshal payload",
				"id", n.ID,
				"error", liberrors.Wrapf(unmarshalErr, liberrors.CodeInternal, "unmarshal notification payload"),
			)

			continue
		}

		items = append(items, &pb.NotificationEnvelope{
			Id:     n.ID,
			IsRead: n.IsRead,
			Event:  ev,
		})
	}

	return &pb.ListNotificationsResponse{Items: items}, nil
}

// MarkNotificationRead flips a single row to is_read=1. Idempotent —
// re-marking a read row is a no-op.
func (h *Handler) MarkNotificationRead(
	ctx context.Context,
	req *pb.MarkNotificationReadRequest,
) (*pb.MarkNotificationReadResponse, error) {
	if err := h.notification.MarkRead(ctx, req.GetId()); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.MarkNotificationReadResponse{}, nil
}

// MarkAllNotificationsRead marks every unread row as read in a single
// statement. Returns immediately even when there's nothing to update.
func (h *Handler) MarkAllNotificationsRead(
	ctx context.Context,
	_ *pb.MarkAllNotificationsReadRequest,
) (*pb.MarkAllNotificationsReadResponse, error) {
	if err := h.notification.MarkAllRead(ctx); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.MarkAllNotificationsReadResponse{}, nil
}

// ClearNotifications wipes the entire notification table. Wired to the
// "Clear all" button in the notification center — the UI confirms with
// the user before calling this.
func (h *Handler) ClearNotifications(
	ctx context.Context,
	_ *pb.ClearNotificationsRequest,
) (*pb.ClearNotificationsResponse, error) {
	if err := h.notification.ClearAll(ctx); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.ClearNotificationsResponse{}, nil
}

// GetNotificationSettings reads the singleton settings row. The
// migration seeds it on first run, so this RPC always returns
// something sensible (defaults if hand-deleted).
func (h *Handler) GetNotificationSettings(
	ctx context.Context,
	_ *pb.GetNotificationSettingsRequest,
) (*pb.GetNotificationSettingsResponse, error) {
	s, err := h.notification.GetSettings(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.GetNotificationSettingsResponse{Settings: settingsToProto(s)}, nil
}

// UpdateNotificationSettings writes the entire settings struct in one
// statement. The response echoes the persisted values so the client
// doesn't need a separate Get round-trip after a save.
func (h *Handler) UpdateNotificationSettings(
	ctx context.Context,
	req *pb.UpdateNotificationSettingsRequest,
) (*pb.UpdateNotificationSettingsResponse, error) {
	in := req.GetSettings()
	if in == nil {
		return &pb.UpdateNotificationSettingsResponse{}, nil
	}

	domain := settingsFromProto(in)
	if err := h.notification.UpdateSettings(ctx, domain); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.UpdateNotificationSettingsResponse{Settings: settingsToProto(domain)}, nil
}

func clampNotificationsLimit(in int) int {
	if in <= 0 {
		return notificationsDefaultLimit
	}

	if in > notificationsMaxLimit {
		return notificationsMaxLimit
	}

	return in
}

func settingsToProto(s *notificationentity.Settings) *pb.NotificationSettings {
	if s == nil {
		return &pb.NotificationSettings{}
	}

	return &pb.NotificationSettings{
		PlaySound:        s.PlaySound,
		MacosToasts:      s.MacOSToasts,
		AutoMarkRead:     s.AutoMarkRead,
		AutoDeleteDays:   s.AutoDeleteDays,
		MuteSystemAlerts: s.MuteSystemAlerts,
	}
}

func settingsFromProto(p *pb.NotificationSettings) *notificationentity.Settings {
	return &notificationentity.Settings{
		PlaySound:        p.GetPlaySound(),
		MacOSToasts:      p.GetMacosToasts(),
		AutoMarkRead:     p.GetAutoMarkRead(),
		AutoDeleteDays:   p.GetAutoDeleteDays(),
		MuteSystemAlerts: p.GetMuteSystemAlerts(),
	}
}
