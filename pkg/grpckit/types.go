// Package grpckit: interfaces used by the package. Implementations are provided
// by the application (e.g. go-toolkit/logger, go-toolkit/errors).

package grpckit

import (
	"log/slog"
)

// Log is the logging interface used by server and client.
// *slog.Logger and go-toolkit/logger.Logger implement this.
type Log interface {
	Debug(msg string, args ...any)
	Info(msg string, args ...any)
	Warn(msg string, args ...any)
	Error(msg string, args ...any)
}

// SlogProvider provides the underlying *slog.Logger for context-aware logging.
type SlogProvider interface {
	Slog() *slog.Logger
}

// toSlog returns *slog.Logger from Log.
func toSlog(l Log) *slog.Logger {
	if l == nil {
		return slog.Default()
	}

	if sp, ok := l.(SlogProvider); ok {
		return sp.Slog()
	}

	if sl, ok := l.(*slog.Logger); ok {
		return sl
	}

	return slog.Default()
}
