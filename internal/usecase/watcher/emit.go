package watcher

import (
	"context"

	"google.golang.org/protobuf/proto"
)

// ── helpers ───────────────────────────────────────────────────────────────────

func (u *Usecase) emit(e WalletEvent) {
	u.mu.RLock()
	defer u.mu.RUnlock()

	for _, ch := range u.subscribers {
		select {
		case ch <- e:
		default:
			u.log.Warn("watcher: subscriber channel full, dropping event", "kind", e.Kind)
		}
	}
}

// emitAndPersist writes the event to the optional NotificationSink
// before broadcasting to Subscribe-channels. Persistence is best-effort
// — a sink error is logged at warn level but never blocks the live
// stream, since the UI's real-time path is more important than the
// cold-start cache.
//
// txHash is extracted from the payload when the event carries one
// (KindTransaction); empty otherwise.
func (u *Usecase) emitAndPersist(ctx context.Context, e WalletEvent) {
	id := u.persist(ctx, e)
	if id != "" {
		e.ID = id
	}

	u.emit(e)
}

// persist marshals the event and forwards it to the sink. Split out
// from emitAndPersist to keep that function flat (lint: nestif) and to
// give the marshal/save error handling a single home. Returns the
// freshly minted row ID, or "" when persistence was skipped or failed.
func (u *Usecase) persist(ctx context.Context, e WalletEvent) string {
	if u.sink == nil {
		return ""
	}

	pb := WalletEventToProto(e)
	if pb == nil {
		return ""
	}

	payload, err := proto.Marshal(pb)
	if err != nil {
		u.log.Warn("watcher: marshal event for persistence", "kind", e.Kind, "error", err)
		return ""
	}

	id, saveErr := u.sink.Save(ctx, e.Kind, txHashOf(e), payload, isOursOf(e))
	if saveErr != nil {
		u.log.Warn("watcher: persist notification", "kind", e.Kind, "error", saveErr)
		return ""
	}

	return id
}

// txHashOf pulls a tx hash out of the event payload when the kind has
// one. Returns "" for hash-less kinds (gas alerts, low balance).
func txHashOf(e WalletEvent) string {
	if e.Transaction != nil {
		return e.Transaction.TxHash
	}

	return ""
}

// isOursOf returns the IsOurs flag for kinds that track it; false
// otherwise.
func isOursOf(e WalletEvent) bool {
	if e.Transaction != nil {
		return e.Transaction.IsOurs
	}

	return false
}
