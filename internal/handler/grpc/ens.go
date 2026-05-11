package grpc

import (
	"context"

	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
)

// ResolveENS turns an ENS name into an address. Returns an empty string on
// "name not found" (vs an error) so the UI can render a quiet "no record"
// state without an error toast.
func (h *Handler) ResolveENS(
	ctx context.Context,
	req *pb.ResolveENSRequest,
) (*pb.ResolveENSResponse, error) {
	addr, err := h.wallet.ResolveENS(ctx, req.GetName())
	if err != nil {
		if liberrors.GetCode(err) == liberrors.CodeNotFound {
			return &pb.ResolveENSResponse{Address: ""}, nil
		}
		return nil, h.HandleError(ctx, err)
	}
	return &pb.ResolveENSResponse{Address: addr.Hex()}, nil
}

// ReverseENS returns the primary ENS name for an address, or an empty string
// when none is set.
func (h *Handler) ReverseENS(
	ctx context.Context,
	req *pb.ReverseENSRequest,
) (*pb.ReverseENSResponse, error) {
	addr, err := ethkit.NewAddress(req.GetAddress())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err,
			liberrors.CodeInvalidArgument, "invalid address"))
	}

	name, err := h.wallet.ReverseENS(ctx, addr)
	if err != nil {
		if liberrors.GetCode(err) == liberrors.CodeNotFound {
			return &pb.ReverseENSResponse{Name: ""}, nil
		}
		return nil, h.HandleError(ctx, err)
	}
	return &pb.ReverseENSResponse{Name: name}, nil
}
