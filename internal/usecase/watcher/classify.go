package watcher

import (
	"strings"
)

// updated allowance state, no Transfer logs were emitted).
func classifyRole(movements []AssetMovement) TxRole {
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
		// Self-transfer if every movement's counterparty is the wallet
		// itself. Otherwise it's a swap (or a wrapped native equivalent).
		allSelf := true
		for _, m := range movements {
			if !m.IsOutgoing {
				continue
			}
			if !equalAddrLower(m.Counterparty, "") && hasIn {
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

func equalAddrLower(a, b string) bool {
	return strings.EqualFold(a, b)
}
