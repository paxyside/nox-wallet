package watcher

import (
	"context"

	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// ── ETH balance watcher (low-balance latch only) ──────────────────────────────
//
// Subscribes to BalanceUpdate events and drives the "ETH balance below
// `lowBalanceThresholdETH`" alert. The latch flips to `true` on the
// first crossing under the threshold and stays there until the
// balance recovers above the threshold — without that, every
// subsequent balance update under threshold would re-emit and spam
// the user.
//
// Per-tx "ETH sent / received" notifications are NOT emitted from
// here anymore — the canonical [Usecase.watchTransactions] watcher
// covers those via Alchemy `getAssetTransfers`. We're only here for
// the low-balance signal.

func (u *Usecase) watchBalanceForLowAlert(ctx context.Context, addr ethkit.Address) error {
	updates, err := u.eth.WatchBalance(ctx, addr, u.pollInterval)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "subscribe balance updates")
	}

	// `latched` flips true the first time ETH falls below the
	// threshold, false again when it recovers. Prevents repeat
	// notifications while balance hovers near the threshold.
	var latched bool

	for {
		select {
		case <-ctx.Done():
			return nil

		case update, ok := <-updates:
			if !ok {
				return nil
			}

			ethBalance, _ := update.Balance.ToETH().Float64()

			if ethBalance < lowBalanceThresholdETH && !latched {
				latched = true
				u.emitAndPersist(ctx, WalletEvent{
					Kind:       KindLowBalance,
					LowBalance: &LowBalanceData{Address: addr, ETH: update.Balance},
				})

				continue
			}

			if ethBalance >= lowBalanceThresholdETH && latched {
				latched = false
			}
		}
	}
}
