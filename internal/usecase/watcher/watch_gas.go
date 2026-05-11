package watcher

import (
	"context"
	"time"
)

// ── Gas alert watcher ─────────────────────────────────────────────────────────

func (u *Usecase) watchGas(ctx context.Context) {
	ticker := time.NewTicker(gasPollInterval)
	defer ticker.Stop()

	var prevGwei float64

	for {
		select {
		case <-ctx.Done():
			return

		case <-ticker.C:
			info, err := u.eth.GasFees(ctx)
			if err != nil {
				u.log.Warn("watcher: gas fees poll error", "error", err)
				continue
			}

			cur, _ := info.BaseFee.ToGwei().Float64()

			if prevGwei > 0 && cur > 0 {
				change := (cur - prevGwei) / prevGwei

				if change >= gasSpikePct {
					u.emitAndPersist(ctx, WalletEvent{
						Kind: KindGasAlert,
						GasAlert: &GasAlertData{
							IsSpike:      true,
							CurrentGwei:  cur,
							PreviousGwei: prevGwei,
						},
					})
				} else if change <= -gasDropPct {
					u.emitAndPersist(ctx, WalletEvent{
						Kind: KindGasAlert,
						GasAlert: &GasAlertData{
							IsSpike:      false,
							CurrentGwei:  cur,
							PreviousGwei: prevGwei,
						},
					})
				}
			}

			prevGwei = cur
		}
	}
}
