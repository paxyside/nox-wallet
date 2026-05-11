package watcher

import (
	"context"
	"log/slog"
	"strings"
	"testing"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
	liblogger "github.com/paxyside/nox-wallet/pkg/logger"
)

// noopLog is a Log implementation that swallows everything — used so
// the deferred-emit warning in [Usecase.shouldDefer] doesn't pollute
// test output. We can't use [logger.New] here because it writes to
// stderr; nothing in the project exposes a "discard" preset, so we
// hand-roll one.
type noopLog struct{}

var _ liblogger.Log = noopLog{}

func (noopLog) Debug(string, ...any)                            {}
func (noopLog) Info(string, ...any)                             {}
func (noopLog) Warn(string, ...any)                             {}
func (noopLog) Error(string, ...any)                            {}
func (noopLog) DebugContext(context.Context, string, ...any)    {}
func (noopLog) InfoContext(context.Context, string, ...any)     {}
func (noopLog) WarnContext(context.Context, string, ...any)     {}
func (noopLog) ErrorContext(context.Context, string, ...any)    {}
func (noopLog) Log(context.Context, slog.Level, string, ...any) {}
func (noopLog) Enabled(context.Context, slog.Level) bool        { return false }

// shouldDefer controls whether `processTick` holds back a hash for
// the next iteration in case Alchemy hasn't indexed all legs yet.
// The contract:
//
//   - non-pending hashes are always emitted immediately
//   - pending hashes tagged Kind="send" are always emitted
//   - pending hashes tagged Kind="swap" with role != Swap / SelfTransfer
//     get deferred up to maxDeferral, then emitted with whatever's there
//   - already-Swap-classified hashes never defer (we have what we need)
func TestShouldDefer(t *testing.T) {
	const hash = "0xabc"

	u := &Usecase{log: noopLog{}}

	makePending := func(kind string) map[string]ethkit.PendingTx {
		return map[string]ethkit.PendingTx{
			strings.ToLower(hash): {Hash: hash, Kind: kind},
		}
	}

	t.Run("non-pending hash never defers", func(t *testing.T) {
		ev := &TransactionData{Role: RoleReceiveToken}
		deferred := map[string]time.Time{}

		if u.shouldDefer(hash, ev, map[string]ethkit.PendingTx{}, deferred, time.Second) {
			t.Fatal("non-pending should never defer")
		}
	})

	t.Run("send kind, single leg, never defers", func(t *testing.T) {
		ev := &TransactionData{Role: RoleSendETH}
		deferred := map[string]time.Time{}

		if u.shouldDefer(hash, ev, makePending("send"), deferred, time.Second) {
			t.Fatal("send-kind hashes should emit immediately")
		}
	})

	t.Run("swap kind, role already Swap, never defers", func(t *testing.T) {
		ev := &TransactionData{Role: RoleSwap}
		deferred := map[string]time.Time{}

		if u.shouldDefer(hash, ev, makePending("swap"), deferred, time.Second) {
			t.Fatal("complete swap classification should emit immediately")
		}
	})

	t.Run("swap kind + only one leg = first defer + record firstSeen", func(t *testing.T) {
		ev := &TransactionData{Role: RoleReceiveToken}
		deferred := map[string]time.Time{}

		ok := u.shouldDefer(hash, ev, makePending("swap"), deferred, 30*time.Second)
		if !ok {
			t.Fatal("first observation of incomplete swap should defer")
		}

		if _, ok := deferred[hash]; !ok {
			t.Fatal("firstSeen timestamp must be recorded")
		}
	})

	t.Run("swap kind + still incomplete within deferral window = keep deferring", func(t *testing.T) {
		ev := &TransactionData{Role: RoleSendToken}
		deferred := map[string]time.Time{
			hash: time.Now(),
		}

		if !u.shouldDefer(hash, ev, makePending("swap"), deferred, 30*time.Second) {
			t.Fatal("within deferral window should keep deferring")
		}
	})

	t.Run("swap kind + incomplete past deferral window = emit (don't defer)", func(t *testing.T) {
		ev := &TransactionData{Role: RoleReceiveToken}
		deferred := map[string]time.Time{
			hash: time.Now().Add(-time.Hour),
		}

		if u.shouldDefer(hash, ev, makePending("swap"), deferred, 30*time.Second) {
			t.Fatal("past deferral window should give up and emit")
		}
	})

	t.Run("swap kind, SelfTransfer role, never defers (treat as legitimate)", func(t *testing.T) {
		ev := &TransactionData{Role: RoleSelfTransfer}
		deferred := map[string]time.Time{}

		if u.shouldDefer(hash, ev, makePending("swap"), deferred, time.Second) {
			t.Fatal("SelfTransfer is a complete classification, should emit")
		}
	})
}
