// Package entity defines the persisted notification domain object. A
// Notification is one row in the SQLite cache that mirrors a single
// watcher.WalletEvent broadcast — kept separate from the in-flight
// event type so the storage schema can evolve independently of the
// in-memory pub/sub DTOs.
package entity

import "time"

// Notification is the persisted form of a watcher event. Payload is
// the proto-serialized wallet.event.WalletEvent so the gRPC layer can
// re-emit the row to clients without reconstructing rich Go DTOs.
type Notification struct {
	ID        string
	Kind      uint8 // mirrors watcher.EventKind; uint8 to avoid an import cycle
	TxHash    string
	Payload   []byte
	IsOurs    bool
	IsRead    bool
	CreatedAt time.Time
}

// Settings is the user's per-installation notification preferences.
// All fields are mutable; defaults are seeded at migration time. Kept
// as a single struct (rather than separate getters) so the gRPC layer
// can map it 1:1 to its own Settings message.
type Settings struct {
	PlaySound        bool
	MacOSToasts      bool
	AutoMarkRead     bool
	AutoDeleteDays   int32 // 0 = never auto-delete
	MuteSystemAlerts bool
	UpdatedAt        time.Time
}
