package grpc

import (
	"context"

	tokenuc "github.com/paxyside/nox-wallet/internal/usecase/token"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbtoken "github.com/paxyside/nox-wallet/proto/gen/go/wallet/token"
)

func (h *Handler) AddToken(ctx context.Context, req *pb.AddTokenRequest) (*pb.AddTokenResponse, error) {
	addr, err := ethkit.NewAddress(req.GetAddress())
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	t, err := h.token.Add(ctx, tokenuc.AddTokenParams{
		ContractAddress: addr,
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.AddTokenResponse{Token: watchedTokenToProto(t)}, nil
}

func (h *Handler) RemoveToken(ctx context.Context, req *pb.RemoveTokenRequest) (*pb.RemoveTokenResponse, error) {
	if err := h.token.Remove(ctx, req.GetId()); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.RemoveTokenResponse{}, nil
}

func (h *Handler) ListTokens(ctx context.Context, _ *pb.ListTokensRequest) (*pb.ListTokensResponse, error) {
	list, err := h.token.List(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	tokens := make([]*pbtoken.WatchedToken, 0, len(list))
	for _, t := range list {
		tokens = append(tokens, watchedTokenToProto(t))
	}

	return &pb.ListTokensResponse{Tokens: tokens}, nil
}

func (h *Handler) ListTokensWithBalances(
	ctx context.Context,
	_ *pb.ListTokensWithBalancesRequest,
) (*pb.ListTokensWithBalancesResponse, error) {
	addr := h.wallet.LoadedAddress()
	if addr.IsZero() {
		// Onboarding-time call before any wallet exists. Skip the Alchemy
		// round-trip; the UI re-polls once GetWallet starts returning a
		// real address.
		return &pb.ListTokensWithBalancesResponse{}, nil
	}

	list, err := h.token.ListWithBalances(ctx, addr)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	tokens := make([]*pbtoken.WatchedTokenWithBalance, 0, len(list))
	for _, t := range list {
		tokens = append(tokens, tokenWithBalanceToProto(t))
	}

	return &pb.ListTokensWithBalancesResponse{Tokens: tokens}, nil
}

func (h *Handler) PinToken(ctx context.Context, req *pb.PinTokenRequest) (*pb.PinTokenResponse, error) {
	if err := h.token.Pin(ctx, req.GetId(), req.GetPinned()); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.PinTokenResponse{}, nil
}

func (h *Handler) HideToken(ctx context.Context, req *pb.HideTokenRequest) (*pb.HideTokenResponse, error) {
	if err := h.token.Hide(ctx, req.GetId(), req.GetHidden()); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.HideTokenResponse{}, nil
}
