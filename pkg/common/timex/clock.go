// Package timex exposes a Clock implementation backed by the system
// wall clock. The interface itself lives in `internal/usecase` (Clock
// in base.go) so usecases can swap in fakes for tests; this package
// just provides the production wiring.
package timex

import "time"

type realClock struct{}

// NewClock returns the system wall-clock implementation. Usecases
// consume it via the local Clock interface in internal/usecase.
func NewClock() *realClock { //nolint:revive // returning the unexported type is intentional — callers use the structural usecase.Clock interface, never the concrete type by name
	return &realClock{}
}

func (*realClock) Now() time.Time      { return time.Now() }
func (*realClock) NowUTC() time.Time   { return time.Now().UTC() }
func (*realClock) NowUnix() int64      { return time.Now().Unix() }
func (*realClock) NowUnixMilli() int64 { return time.Now().UnixMilli() }
func (*realClock) NowUnixMicro() int64 { return time.Now().UnixMicro() }
func (*realClock) NowUnixNano() int64  { return time.Now().UnixNano() }
