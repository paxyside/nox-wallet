package ethkit

import (
	"context"
	"time"
)

// WatchBalance polls the native ETH balance of addr on every tick and
// emits a BalanceUpdate whenever it changes. The first poll is a
// silent baseline snapshot so app startup doesn't produce a phantom
// "received <whole balance>" notification.
func (c *Client) WatchBalance(
	ctx context.Context,
	addr Address,
	pollInterval time.Duration,
) (<-chan BalanceUpdate, error) {
	if pollInterval <= 0 {
		pollInterval = 15 * time.Second
	}

	updates := make(chan BalanceUpdate, 8)

	go func() {
		defer close(updates)

		var prev Amount

		initialized := false

		ticker := time.NewTicker(pollInterval)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				bal, err := c.ETHBalance(ctx, addr)
				if err != nil {
					c.log.Warn("ethkit: watch balance poll error", "error", err)
					continue
				}

				if !initialized {
					prev = bal
					initialized = true

					continue
				}

				if bal.Equal(prev) {
					continue
				}

				delta := bal.Sub(prev)
				prev = bal

				select {
				case updates <- BalanceUpdate{Address: addr, Balance: bal, Delta: delta}:
				case <-ctx.Done():
					return
				}
			}
		}
	}()

	return updates, nil
}
