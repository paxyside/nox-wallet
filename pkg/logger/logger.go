// Package logger wraps log/slog with the small set of conveniences
// the app needs: a structured `Log` interface, a Logger that satisfies
// it, configurable JSON or pretty-print output, and `ErrorChain`
// helper for unwrapping. Every other slog-flavored helper that lived
// here was unused and got pruned.
package logger

import (
	"context"
	"io"
	"log/slog"
	"os"
	"strconv"
)

// Log is the interface the app's components consume. Both *Logger
// (this package) and *slog.Logger satisfy it, so wiring is uniform
// regardless of which concrete logger a caller has.
type Log interface {
	Debug(msg string, args ...any)
	Info(msg string, args ...any)
	Warn(msg string, args ...any)
	Error(msg string, args ...any)

	DebugContext(ctx context.Context, msg string, args ...any)
	InfoContext(ctx context.Context, msg string, args ...any)
	WarnContext(ctx context.Context, msg string, args ...any)
	ErrorContext(ctx context.Context, msg string, args ...any)
}

// SlogProvider exposes the underlying *slog.Logger for libraries that
// expect slog directly (e.g. the gRPC interceptors in pkg/grpckit).
type SlogProvider interface {
	Slog() *slog.Logger
}

var (
	_ Log          = (*Logger)(nil)
	_ SlogProvider = (*Logger)(nil)
)

// Logger is a thin wrapper around *slog.Logger that adds the
// SlogProvider escape hatch.
type Logger struct {
	base *slog.Logger
}

// Options carries the resolved configuration produced by `New`.
type Options struct {
	Writer      io.Writer
	Level       slog.Leveler
	AppName     string
	AddSource   bool
	PrettyPrint bool
	Environment string
}

// New constructs a Logger from the given options. Defaults: stderr,
// debug level, source on. Pretty-printing falls back to JSON when
// disabled — production builds run with PrettyPrint=false.
func New(opts ...Option) *Logger {
	o := Options{
		Writer:    os.Stderr,
		Level:     slog.LevelDebug,
		AddSource: true,
	}

	for _, fn := range opts {
		if fn != nil {
			fn(&o)
		}
	}

	handlerOpts := &slog.HandlerOptions{
		Level:     o.Level,
		AddSource: o.AddSource,
		ReplaceAttr: func(_ []string, a slog.Attr) slog.Attr {
			if a.Key == slog.SourceKey {
				if src, ok := a.Value.Any().(*slog.Source); ok {
					a.Value = slog.StringValue(shortSource(src))
				}
			}

			return a
		},
	}

	var h slog.Handler
	if o.PrettyPrint {
		h = NewPrettyHandler(o.Writer, handlerOpts)
	} else {
		h = slog.NewJSONHandler(o.Writer, handlerOpts)
	}

	var baseAttrs []any

	if o.AppName != "" {
		baseAttrs = append(baseAttrs, slog.String("app", o.AppName))
	}

	if o.Environment != "" {
		baseAttrs = append(baseAttrs, slog.String("env", o.Environment))
	}

	l := slog.New(h)
	if len(baseAttrs) > 0 {
		l = l.With(baseAttrs...)
	}

	return &Logger{base: l}
}

// Slog returns the underlying *slog.Logger so callers can hand it to
// libraries that take slog directly.
func (l *Logger) Slog() *slog.Logger { return l.base }

// ── Logging methods ──────────────────────────────────────────────────────

func (l *Logger) Debug(msg string, args ...any) { l.base.Debug(msg, args...) }
func (l *Logger) Info(msg string, args ...any)  { l.base.Info(msg, args...) }
func (l *Logger) Warn(msg string, args ...any)  { l.base.Warn(msg, args...) }
func (l *Logger) Error(msg string, args ...any) { l.base.Error(msg, args...) }

func (l *Logger) DebugContext(ctx context.Context, msg string, args ...any) {
	l.base.DebugContext(ctx, msg, args...)
}

func (l *Logger) InfoContext(ctx context.Context, msg string, args ...any) {
	l.base.InfoContext(ctx, msg, args...)
}

func (l *Logger) WarnContext(ctx context.Context, msg string, args ...any) {
	l.base.WarnContext(ctx, msg, args...)
}

func (l *Logger) ErrorContext(ctx context.Context, msg string, args ...any) {
	l.base.ErrorContext(ctx, msg, args...)
}

func shortSource(src *slog.Source) string {
	short := src.File
	for i := len(short) - 1; i > 0; i-- {
		if short[i] == '/' {
			short = short[i+1:]
			break
		}
	}

	return short + ":" + strconv.Itoa(src.Line)
}
