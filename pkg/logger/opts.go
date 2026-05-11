package logger

import (
	"log/slog"
	"strings"
)

// Option mutates Options before New constructs the logger.
type Option func(*Options)

// WithLevelString sets the minimum log level from a string.
// Accepts: "debug", "info", "warn", "warning", "error". Anything
// else (including empty) falls back to info.
func WithLevelString(levelStr string) Option {
	return func(o *Options) { o.Level = parseLevel(levelStr) }
}

// WithAppName stamps the application name onto every record.
func WithAppName(name string) Option {
	return func(o *Options) { o.AppName = name }
}

// WithEnvironment stamps the environment ("local"/"production"/...)
// onto every record.
func WithEnvironment(env string) Option {
	return func(o *Options) { o.Environment = env }
}

// WithSource toggles source-line capture. The shortened path is
// added by the handler's ReplaceAttr — see logger.go.
func WithSource(enabled bool) Option {
	return func(o *Options) { o.AddSource = enabled }
}

// WithPrettyPrint switches the handler to the colorized variant in
// pretty.go. Off in production for log-shipper compatibility.
func WithPrettyPrint(enabled bool) Option {
	return func(o *Options) { o.PrettyPrint = enabled }
}

func parseLevel(s string) slog.Level {
	switch strings.ToLower(strings.TrimSpace(s)) {
	case "debug":
		return slog.LevelDebug
	case "info", "":
		return slog.LevelInfo
	case "warn", "warning":
		return slog.LevelWarn
	case "error":
		return slog.LevelError
	default:
		return slog.LevelInfo
	}
}
