package watcher

import (
	"fmt"

	"google.golang.org/protobuf/types/known/timestamppb"

	pbevent "github.com/paxyside/nox-wallet/proto/gen/go/wallet/event"
)

// WalletEventToProto serialises a WalletEvent into the wire-level
// pbevent.WalletEvent. Lives in this package (not the gRPC handler)
// because the watcher itself needs to marshal events for SQLite
// persistence — keeping the mapper here avoids an import cycle between
// watcher and the grpc handler.
//
// Returns nil if the event's payload pointer is missing for a kind
// that requires one — the caller should treat that as "skip, don't
// emit". Defensive: a Kind=Transaction with nil Transaction is a
// programmer bug, but logging+drop beats panicking the watcher loop.
func WalletEventToProto(e WalletEvent) *pbevent.WalletEvent {
	switch e.Kind {
	case KindGasAlert:
		if e.GasAlert == nil {
			return nil
		}

		ga := e.GasAlert

		alertType := pbevent.GasAlertEvent_ALERT_TYPE_SPIKE
		if !ga.IsSpike {
			alertType = pbevent.GasAlertEvent_ALERT_TYPE_DROP
		}

		return &pbevent.WalletEvent{
			Payload: &pbevent.WalletEvent_GasAlert{
				GasAlert: &pbevent.GasAlertEvent{
					Type:         alertType,
					CurrentGwei:  fmt.Sprintf("%.2f", ga.CurrentGwei),
					PreviousGwei: fmt.Sprintf("%.2f", ga.PreviousGwei),
				},
			},
		}

	case KindLowBalance:
		if e.LowBalance == nil {
			return nil
		}

		lb := e.LowBalance

		return &pbevent.WalletEvent{
			Payload: &pbevent.WalletEvent_LowBalance{
				LowBalance: &pbevent.LowBalanceEvent{
					EthBalance:    lb.ETH.ToETH().StringFixed(8),
					EthBalanceWei: lb.ETH.Wei().String(),
				},
			},
		}

	case KindTransaction:
		return transactionEventToProto(e.Transaction)
	}

	return nil
}

func transactionEventToProto(d *TransactionData) *pbevent.WalletEvent {
	if d == nil {
		return nil
	}

	movements := make([]*pbevent.AssetMovement, 0, len(d.Movements))
	for _, m := range d.Movements {
		movements = append(movements, &pbevent.AssetMovement{
			Symbol:          m.Symbol,
			Name:            m.Name,
			ContractAddress: m.ContractAddress,
			Amount:          trimDecimalZeros(m.Amount),
			IsOutgoing:      m.IsOutgoing,
			Counterparty:    m.Counterparty,
		})
	}

	return &pbevent.WalletEvent{
		Payload: &pbevent.WalletEvent_Transaction{
			Transaction: &pbevent.TransactionEvent{
				TxHash:      d.TxHash,
				Role:        roleToProto(d.Role),
				Movements:   movements,
				IsOurs:      d.IsOurs,
				BlockNumber: d.BlockNumber,
				Timestamp:   timestamppb.New(d.Timestamp),
			},
		},
	}
}

func roleToProto(r TxRole) pbevent.TransactionEvent_Role {
	switch r {
	case RoleSendETH:
		return pbevent.TransactionEvent_ROLE_SEND_ETH
	case RoleReceiveETH:
		return pbevent.TransactionEvent_ROLE_RECEIVE_ETH
	case RoleSendToken:
		return pbevent.TransactionEvent_ROLE_SEND_TOKEN
	case RoleReceiveToken:
		return pbevent.TransactionEvent_ROLE_RECEIVE_TOKEN
	case RoleSwap:
		return pbevent.TransactionEvent_ROLE_SWAP
	case RoleSelfTransfer:
		return pbevent.TransactionEvent_ROLE_SELF_TRANSFER
	case RoleApprove:
		return pbevent.TransactionEvent_ROLE_APPROVE
	case RoleUnknown:
		return pbevent.TransactionEvent_ROLE_UNSPECIFIED
	default:
		return pbevent.TransactionEvent_ROLE_UNSPECIFIED
	}
}

// trimDecimalZeros removes unnecessary trailing zeros after the decimal
// point. e.g. "12.500000" -> "12.5", "100.000000" -> "100".
func trimDecimalZeros(s string) string {
	for i := len(s) - 1; i >= 0; i-- {
		if s[i] == '.' {
			return s[:i]
		}

		if s[i] != '0' {
			return s[:i+1]
		}
	}

	return s
}
