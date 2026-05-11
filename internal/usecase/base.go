package usecase

import "time"

type IDx interface {
	UUID() string
	ULID() string
}

type Clock interface {
	// Now returns the current time in local timezone.
	Now() time.Time
	// NowUTC returns the current time in UTC.
	NowUTC() time.Time
	// NowUnix returns the current Unix timestamp (seconds).
	NowUnix() int64
	// NowUnixMilli returns the current Unix timestamp (milliseconds).
	NowUnixMilli() int64
	// NowUnixMicro returns the current Unix timestamp (microseconds).
	NowUnixMicro() int64
	// NowUnixNano returns the current Unix timestamp (nanoseconds).
	NowUnixNano() int64
}

type BaseUsecase struct {
	IDx
	Clock
}

func NewBaseUsecase(id IDx, clock Clock) *BaseUsecase {
	return &BaseUsecase{
		IDx:   id,
		Clock: clock,
	}
}
