package sqlitekit

// Logger is the minimal logging surface sqlitekit calls into. Defined here
// (not imported from the project's logger package) so this library has zero
// internal-project dependencies and can be reused standalone.
//
// The app wires its real logger via [WithLogger] at construction time.
type Logger interface {
	Debug(msg string, args ...any)
	Info(msg string, args ...any)
	Warn(msg string, args ...any)
	Error(msg string, args ...any)
}

// noopLogger silently drops every log call. Used when the caller did not
// supply a Logger via [WithLogger].
type noopLogger struct{}

func (noopLogger) Debug(string, ...any) {}
func (noopLogger) Info(string, ...any)  {}
func (noopLogger) Warn(string, ...any)  {}
func (noopLogger) Error(string, ...any) {}
