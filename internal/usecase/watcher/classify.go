package watcher

import (
	"strings"
)

// classifyRole picks the TxRole for a transaction based on the wallet's
// asset movements and the wallet's own address (for self-transfer
// detection). Zero movements means an APPROVE tx — Alchemy doesn't
// emit a Transfer for `approve(spender, amount)`, so the watcher sees
// the receipt without any asset leg.
func classifyRole(movements []AssetMovement, walletHex string) TxRole {
	if len(movements) == 0 {
		return RoleApprove
	}

	var (
		outgoing []AssetMovement
		incoming []AssetMovement
	)
	for _, m := range movements {
		if m.IsOutgoing {
			outgoing = append(outgoing, m)
		} else {
			incoming = append(incoming, m)
		}
	}

	hasOut := len(outgoing) > 0
	hasIn := len(incoming) > 0

	if hasOut && hasIn {
		// Self-transfer if every outgoing leg's counterparty is the
		// wallet itself — the user moved funds between their own
		// addresses (or just sent to themselves, e.g. for a test).
		// Otherwise it's a swap (or wrapped-native equivalent).
		allSelf := true
		for _, m := range outgoing {
			if !strings.EqualFold(m.Counterparty, walletHex) {
				allSelf = false

				break
			}
		}
		if allSelf {
			return RoleSelfTransfer
		}

		return RoleSwap
	}

	if hasOut {
		if isNative(outgoing[0]) {
			return RoleSendETH
		}

		return RoleSendToken
	}

	// hasIn
	if isNative(incoming[0]) {
		return RoleReceiveETH
	}

	return RoleReceiveToken
}

func isNative(m AssetMovement) bool {
	return m.ContractAddress == "" || strings.EqualFold(m.Symbol, "ETH")
}
