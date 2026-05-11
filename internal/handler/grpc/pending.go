package grpc

import (
	"context"

	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
)

// ListPendingTxs returns the in-flight transactions broadcast from the loaded
// wallet that haven't been mined yet. Used by the History screen to render
// pending rows above confirmed history with Speed up / Cancel actions.
func (h *Handler) ListPendingTxs(
	_ context.Context,
	_ *pb.ListPendingTxsRequest,
) (*pb.ListPendingTxsResponse, error) {
	pending := h.wallet.ListPending()

	out := make([]*pb.PendingTx, 0, len(pending))
	for _, p := range pending {
		out = append(out, &pb.PendingTx{
			TxHash:      p.Hash,
			From:        p.From.Hex(),
			To:          p.To.Hex(),
			Value:       p.Value.ToETH().String(),
			Nonce:       p.Nonce,
			GasTipGwei:  weiToGwei(p.GasTipWei),
			GasCapGwei:  weiToGwei(p.GasCapWei),
			Kind:        p.Kind,
			SubmittedAt: timestamppb.New(p.SubmittedAt),
		})
	}

	return &pb.ListPendingTxsResponse{Pending: out}, nil
}

func weiToGwei(a ethkit.Amount) string {
	return a.ToGwei().StringFixedBank(2)
}
