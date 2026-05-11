// Package retryx runs operations with exponential backoff and jitter.
// Used by the ethkit client to wrap RPC calls so transient failures
// (rate limits, momentary disconnects) don't bubble up as errors.
//
//	r := retryx.NewRetrier(
//	    retryx.WithMaxRetries(3),
//	    retryx.WithBaseDelay(500 * time.Millisecond),
//	)
//	ethkit.New(ctx, cfg, ethkit.WithRetrier(r))
//
// Consumers define a local interface with a single Do method, so
// retryx has no cross-package coupling.
package retryx

import (
	"context"
	"crypto/rand"
	"errors"
	"fmt"
	"math"
	"math/big"
	"time"
)

const (
	defaultBaseDelay  = 100 * time.Millisecond
	defaultMaxDelay   = 10 * time.Second
	defaultMaxRetries = 3
)

// Config carries the resolved retry parameters used by Do.
type Config struct {
	BaseDelay  time.Duration
	MaxDelay   time.Duration
	MaxRetries int // -1 = infinite
}

// Option mutates Config — pass to NewRetrier or Do.
type Option func(*Config)

// WithBaseDelay sets the minimum delay before the first retry.
func WithBaseDelay(d time.Duration) Option {
	return func(c *Config) { c.BaseDelay = d }
}

// WithMaxRetries sets the cap on retry attempts. Pass -1 for infinite.
func WithMaxRetries(n int) Option {
	return func(c *Config) { c.MaxRetries = n }
}

// Operation is the unit of work Do retries.
type Operation func(ctx context.Context) error

// Retrier holds a frozen set of options so callers can pass one
// instance through DI and reuse the same retry policy everywhere.
type Retrier struct {
	opts []Option
}

// NewRetrier returns a Retrier whose Do method applies the given
// options on every call.
func NewRetrier(opts ...Option) *Retrier {
	return &Retrier{opts: opts}
}

// Do executes op with the Retrier's configured policy.
func (r *Retrier) Do(ctx context.Context, op func(context.Context) error) error {
	return Do(ctx, op, r.opts...)
}

// Do runs op with exponential backoff retry. Cancellation via ctx
// short-circuits the wait — callers don't need a separate timeout.
func Do(ctx context.Context, op Operation, opts ...Option) error {
	cfg := &Config{
		BaseDelay:  defaultBaseDelay,
		MaxDelay:   defaultMaxDelay,
		MaxRetries: defaultMaxRetries,
	}

	for _, opt := range opts {
		opt(cfg)
	}

	if err := cfg.validate(); err != nil {
		return err
	}

	var lastErr error

	for attempt := 0; cfg.MaxRetries < 0 || attempt <= cfg.MaxRetries; attempt++ {
		if err := op(ctx); err != nil {
			lastErr = err

			if cfg.MaxRetries >= 0 && attempt >= cfg.MaxRetries {
				return fmt.Errorf("max retries (%d) exceeded: %w", cfg.MaxRetries, err)
			}

			delay := calculateDelay(cfg, attempt)

			select {
			case <-ctx.Done():
				return fmt.Errorf("context cancelled during retry: %w", ctx.Err())
			case <-time.After(delay):
			}

			continue
		}

		return nil
	}

	return lastErr
}

func (c *Config) validate() error {
	if c.BaseDelay <= 0 {
		return errors.New("base delay must be positive")
	}

	if c.MaxDelay <= 0 {
		return errors.New("max delay must be positive")
	}

	if c.MaxDelay < c.BaseDelay {
		return errors.New("max delay must be >= base delay")
	}

	return nil
}

func calculateDelay(cfg *Config, attempt int) time.Duration {
	exp := math.Pow(2, float64(attempt))

	backoff := time.Duration(float64(cfg.BaseDelay) * exp)
	if backoff > cfg.MaxDelay || backoff <= 0 {
		backoff = cfg.MaxDelay
	}

	if backoff <= cfg.BaseDelay {
		return cfg.BaseDelay
	}

	jitterRange := int64(backoff - cfg.BaseDelay)
	jitterBig, _ := rand.Int(rand.Reader, big.NewInt(jitterRange))
	jitter := time.Duration(jitterBig.Int64())

	return cfg.BaseDelay + jitter
}
