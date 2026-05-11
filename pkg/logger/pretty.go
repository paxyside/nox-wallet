package logger

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"strings"
	"sync"
	"time"
)

// ANSI color codes.
const (
	colorReset  = "\033[0m"
	colorRed    = "\033[31m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorBlue   = "\033[34m"
	colorPurple = "\033[35m"
	colorCyan   = "\033[36m"
	colorGray   = "\033[90m"
	colorWhite  = "\033[97m"

	colorBoldRed    = "\033[1;31m"
	colorBoldYellow = "\033[1;33m"
	colorBoldGreen  = "\033[1;32m"
	colorBoldBlue   = "\033[1;34m"
)

// PrettyHandler is a slog handler that outputs colorized, human-readable logs.
type PrettyHandler struct {
	opts      *slog.HandlerOptions
	writer    io.Writer
	mu        *sync.Mutex
	attrs     []slog.Attr
	groupName string
}

// NewPrettyHandler creates a new PrettyHandler.
func NewPrettyHandler(w io.Writer, opts *slog.HandlerOptions) *PrettyHandler {
	if opts == nil {
		opts = &slog.HandlerOptions{}
	}

	return &PrettyHandler{
		opts:   opts,
		writer: w,
		mu:     &sync.Mutex{},
	}
}

// Enabled reports whether the handler handles records at the given level.
func (h *PrettyHandler) Enabled(_ context.Context, level slog.Level) bool {
	minLevel := slog.LevelInfo
	if h.opts.Level != nil {
		minLevel = h.opts.Level.Level()
	}

	return level >= minLevel
}

// Handle handles the Record.
func (h *PrettyHandler) Handle(_ context.Context, r slog.Record) error {
	h.mu.Lock()
	defer h.mu.Unlock()

	// Time
	timeStr := r.Time.Format("15:04:05.000")

	// Level with color
	levelStr, levelColor := h.formatLevel(r.Level)

	// Message
	msg := r.Message

	// Build the log line
	line := fmt.Sprintf("%s%s%s %s%-5s%s %s%s%s",
		colorGray, timeStr, colorReset,
		levelColor, levelStr, colorReset,
		colorWhite, msg, colorReset,
	)

	// Collect attributes
	attrs := make(map[string]any)

	// Add handler attrs first
	for _, attr := range h.attrs {
		h.addAttrToMap(attrs, attr, h.groupName)
	}

	// Add record attrs
	r.Attrs(func(a slog.Attr) bool {
		h.addAttrToMap(attrs, a, h.groupName)
		return true
	})

	// Format attributes
	if len(attrs) > 0 {
		attrStr := h.formatAttrs(attrs)
		line += " " + attrStr
	}

	// Write
	_, err := fmt.Fprintln(h.writer, line)

	return err
}

// WithAttrs returns a new handler with the given attributes.
func (h *PrettyHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	newAttrs := make([]slog.Attr, len(h.attrs)+len(attrs))
	copy(newAttrs, h.attrs)
	copy(newAttrs[len(h.attrs):], attrs)

	return &PrettyHandler{
		opts:      h.opts,
		writer:    h.writer,
		mu:        h.mu,
		attrs:     newAttrs,
		groupName: h.groupName,
	}
}

// WithGroup returns a new handler with the given group name.
func (h *PrettyHandler) WithGroup(name string) slog.Handler {
	newGroupName := name
	if h.groupName != "" {
		newGroupName = h.groupName + "." + name
	}

	return &PrettyHandler{
		opts:      h.opts,
		writer:    h.writer,
		mu:        h.mu,
		attrs:     h.attrs,
		groupName: newGroupName,
	}
}

func (h *PrettyHandler) formatLevel(level slog.Level) (string, string) {
	switch {
	case level >= slog.LevelError:
		return "ERROR", colorBoldRed
	case level >= slog.LevelWarn:
		return "WARN", colorBoldYellow
	case level >= slog.LevelInfo:
		return "INFO", colorBoldGreen
	default:
		return "DEBUG", colorBoldBlue
	}
}

func (h *PrettyHandler) addAttrToMap(m map[string]any, attr slog.Attr, prefix string) {
	key := attr.Key
	if prefix != "" {
		key = prefix + "." + key
	}

	switch attr.Value.Kind() {
	case slog.KindGroup:
		for _, ga := range attr.Value.Group() {
			h.addAttrToMap(m, ga, key)
		}
	case slog.KindAny, slog.KindBool, slog.KindDuration, slog.KindFloat64, slog.KindInt64,
		slog.KindString, slog.KindTime, slog.KindUint64, slog.KindLogValuer:
		m[key] = attr.Value.Any()
	}
}

func (h *PrettyHandler) formatAttrs(attrs map[string]any) string {
	if len(attrs) == 0 {
		return ""
	}

	// For simple cases, format inline
	if len(attrs) <= 3 && !hasComplexValues(attrs) {
		return h.formatAttrsInline(attrs)
	}

	// For complex cases, use JSON
	return h.formatAttrsJSON(attrs)
}

func hasComplexValues(attrs map[string]any) bool {
	for _, v := range attrs {
		switch v.(type) {
		case map[string]any, []any:
			return true
		}
	}

	return false
}

func (h *PrettyHandler) formatAttrsInline(attrs map[string]any) string {
	result := colorGray + "{"

	first := true

	var resultSb194 strings.Builder

	for k, v := range attrs {
		if !first {
			resultSb194.WriteString(", ")
		}

		first = false

		fmt.Fprintf(&resultSb194, "%s%s%s=%s%v%s",
			colorCyan, k, colorGray,
			colorPurple, h.formatValue(v), colorGray)
	}

	result += resultSb194.String()

	result += "}" + colorReset

	return result
}

func (h *PrettyHandler) formatAttrsJSON(attrs map[string]any) string {
	data, err := json.Marshal(attrs)
	if err != nil {
		return fmt.Sprintf("%s%v%s", colorGray, attrs, colorReset)
	}

	return colorGray + string(data) + colorReset
}

func (h *PrettyHandler) formatValue(v any) string {
	switch val := v.(type) {
	case string:
		return fmt.Sprintf("%q", val)
	case time.Time:
		return val.Format(time.RFC3339)
	case time.Duration:
		return val.String()
	case error:
		return val.Error()
	default:
		return fmt.Sprintf("%v", val)
	}
}
