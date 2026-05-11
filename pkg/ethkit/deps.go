package ethkit

import "context"

// Logger is the minimal logging surface ethkit calls into. Defined here (not
// imported from the project's logger package) so this library has zero
// internal-project dependencies and can be reused standalone.
//
// The app wires its real logger via [WithLogger] at construction time.
type Logger interface {
	Debug(msg string, args ...any)
	Info(msg string, args ...any)
	Warn(msg string, args ...any)
	Error(msg string, args ...any)
}

// Retrier wraps a retry policy. Implementations should re-invoke `fn` on
// transient errors and respect the context's deadline / cancellation.
//
// Defined here as an interface so callers can plug in any policy library
// (`pkg/common/retryx`, vendored impl, no-op, …) without ethkit depending
// on a concrete one.
type Retrier interface {
	Do(ctx context.Context, fn func(ctx context.Context) error) error
}

// ── default no-op fallbacks ──────────────────────────────────────────────────

// noopLogger silently drops every log call. Used when the caller did not
// supply a Logger via [WithLogger] — keeps ethkit usable in tests / scripts
// without forcing them to wire up a logger.
type noopLogger struct{}

func (noopLogger) Debug(string, ...any) {}
func (noopLogger) Info(string, ...any)  {}
func (noopLogger) Warn(string, ...any)  {}
func (noopLogger) Error(string, ...any) {}

// directRetrier runs `fn` exactly once. Acceptable as a default for
// non-production usage; production callers always inject a real retrier.
type directRetrier struct{}

func (directRetrier) Do(ctx context.Context, fn func(ctx context.Context) error) error {
	return fn(ctx)
}
