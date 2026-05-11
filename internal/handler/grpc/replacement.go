package grpc

import (
	"context"

	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
)

// SpeedUpTx asks the chain to mine a higher-gas replacement of the given
// pending transaction. The new hash is returned; the original may still
// land first if the bump isn't enough — that's an expected race outcome.
func (h *Handler) SpeedUpTx(
	ctx context.Context,
	req *pb.SpeedUpTxRequest,
) (*pb.SpeedUpTxResponse, error) {
	newHash, err := h.wallet.SpeedUpTx(ctx, req.GetTxHash())
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}
	return &pb.SpeedUpTxResponse{NewTxHash: newHash}, nil
}

// CancelTx submits a 0-value self-transfer at the original transaction's
// nonce with bumped gas. If it lands first, the original is orphaned.
func (h *Handler) CancelTx(
	ctx context.Context,
	req *pb.CancelTxRequest,
) (*pb.CancelTxResponse, error) {
	newHash, err := h.wallet.CancelTx(ctx, req.GetTxHash())
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}
	return &pb.CancelTxResponse{NewTxHash: newHash}, nil
}
