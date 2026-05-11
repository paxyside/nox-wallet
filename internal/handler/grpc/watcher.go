package grpc

import (
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbevent "github.com/paxyside/nox-wallet/proto/gen/go/wallet/event"
)

// WatchEvents — unified stream. Wraps every emit in a NotificationEnvelope
// (id + is_read + event) so the client can store live and historical
// events in the same shape. Live events always carry is_read=false on
// arrival — auto-mark-read is a server-side persistence flag that the
// client observes separately on the next ListNotifications hydration.
// Events that bypassed persistence (sink off, marshal error) ship with
// id="" and the UI treats them as ephemeral.
func (h *Handler) WatchEvents(_ *pb.WatchEventsRequest, stream pb.WalletService_WatchEventsServer) error {
	ctx := stream.Context()
	h.l.DebugContext(ctx, "WatchEvents: client connected")

	events, unsub := h.watcher.Subscribe()
	defer unsub()

	for {
		select {
		case <-ctx.Done():
			return nil

		case event, ok := <-events:
			if !ok {
				return nil
			}

			ev := walletEventToProto(event)
			if ev == nil {
				continue
			}

			env := &pb.NotificationEnvelope{
				Id:     event.ID,
				IsRead: false,
				Event:  ev,
			}

			if err := stream.Send(env); err != nil {
				return h.HandleError(ctx, err)
			}
		}
	}
}

// compile-time interface check.
var _ pb.WalletServiceServer = (*Handler)(nil)

// ensure pbevent import is used.
var _ *pbevent.WalletEvent
