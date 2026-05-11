package retryx

import (
	"context"
	"errors"
	"testing"
	"time"
)

func TestDo_SuccessFirstAttempt(t *testing.T) {
	attempts := 0
	err := Do(context.Background(), func(_ context.Context) error {
		attempts++
		return nil
	})
	if err != nil {
		t.Errorf("Do() error = %v, want nil", err)
	}

	if attempts != 1 {
		t.Errorf("attempts = %d, want 1", attempts)
	}
}

func TestDo_SuccessAfterRetries(t *testing.T) {
	attempts := 0
	err := Do(context.Background(), func(_ context.Context) error {
		attempts++
		if attempts < 3 {
			return errors.New("transient")
		}

		return nil
	},
		WithMaxRetries(5),
		WithBaseDelay(1*time.Millisecond),
	)
	if err != nil {
		t.Errorf("Do() error = %v, want nil", err)
	}

	if attempts != 3 {
		t.Errorf("attempts = %d, want 3", attempts)
	}
}

func TestDo_MaxRetriesExceeded(t *testing.T) {
	attempts := 0
	err := Do(context.Background(), func(_ context.Context) error {
		attempts++
		return errors.New("persistent")
	},
		WithMaxRetries(3),
		WithBaseDelay(1*time.Millisecond),
	)
	if err == nil {
		t.Error("Do() should return error when max retries exceeded")
	}

	if attempts != 4 { // 1 initial + 3 retries
		t.Errorf("attempts = %d, want 4", attempts)
	}
}

func TestDo_ContextCancelled(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		time.Sleep(20 * time.Millisecond)
		cancel()
	}()

	err := Do(ctx, func(_ context.Context) error {
		return errors.New("error")
	},
		WithMaxRetries(-1),
		WithBaseDelay(5*time.Millisecond),
	)
	if err == nil {
		t.Error("Do() should return error when context cancelled")
	}
}

func TestDo_InvalidConfigZeroBaseDelay(t *testing.T) {
	err := Do(context.Background(), func(_ context.Context) error {
		return nil
	}, WithBaseDelay(0))
	if err == nil {
		t.Error("Do() should return error for zero base delay")
	}
}

func TestCalculateDelay_RespectsBounds(t *testing.T) {
	cfg := &Config{
		BaseDelay: 100 * time.Millisecond,
		MaxDelay:  10 * time.Second,
	}

	for i := range 5 {
		d := calculateDelay(cfg, i)
		if d < cfg.BaseDelay {
			t.Errorf("delay[%d] = %v, should be >= %v", i, d, cfg.BaseDelay)
		}

		if d > cfg.MaxDelay {
			t.Errorf("delay[%d] = %v, should be <= %v", i, d, cfg.MaxDelay)
		}
	}
}
