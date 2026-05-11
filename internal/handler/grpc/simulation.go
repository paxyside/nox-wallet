package grpc

import (
	"context"
	"fmt"

	"github.com/shopspring/decimal"

	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
)

// SimulateSend dry-runs an outgoing transfer via eth_call so the UI can
// show success / revert + estimated gas before the user confirms a Send.
//
// Sets `token_address` to "" for native ETH; any other address triggers an
// ERC-20 `transfer(to, amount)` simulation. Decimals are resolved from
// the token contract — the UI passes a human-readable amount.
func (h *Handler) SimulateSend(
	ctx context.Context,
	req *pb.SimulateSendRequest,
) (*pb.SimulateSendResponse, error) {
	to, err := ethkit.NewAddress(req.GetTo())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err,
			liberrors.CodeInvalidArgument, "invalid to address"))
	}

	amount, err := decimal.NewFromString(req.GetAmount())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err,
			liberrors.CodeInvalidArgument, "invalid amount"))
	}

	var result ethkit.SimulationResult
	if req.GetTokenAddress() == "" {
		result, err = h.wallet.SimulateSendETH(ctx, to, ethkit.NewAmountFromETH(amount))
	} else {
		tokenAddr, addrErr := ethkit.NewAddress(req.GetTokenAddress())
		if addrErr != nil {
			return nil, h.HandleError(ctx, liberrors.Wrapf(addrErr,
				liberrors.CodeInvalidArgument, "invalid token address"))
		}
		result, err = h.wallet.SimulateSendToken(ctx, tokenAddr, to, amount)
	}
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	costEth := result.EstimatedCostWei.ToETH().StringFixed(8)

	costUsd := ""
	if ethPrice := h.prices.GetPrice(ctx, "ETH"); ethPrice > 0 {
		costFloat, _ := result.EstimatedCostWei.ToETH().Float64()
		costUsd = fmt.Sprintf("$%.4f", costFloat*ethPrice)
	}

	return &pb.SimulateSendResponse{
		WillRevert:   result.WillRevert,
		RevertReason: result.RevertReason,
		GasUnits:     result.GasUnits,
		GasCostEth:   costEth,
		GasCostUsd:   costUsd,
		AssetChanges: mapAssetChanges(result.AssetChanges),
	}, nil
}

func mapAssetChanges(in []ethkit.AssetChange) []*pb.SimulatedAssetChange {
	out := make([]*pb.SimulatedAssetChange, 0, len(in))
	for _, c := range in {
		out = append(out, &pb.SimulatedAssetChange{
			Kind:            string(c.Kind),
			ChangeType:      c.ChangeType,
			From:            c.From,
			To:              c.To,
			Amount:          c.AmountHuman,
			Symbol:          c.Symbol,
			Name:            c.Name,
			Decimals:        uint32(c.Decimals),
			ContractAddress: c.ContractAddress,
			TokenId:         c.TokenID,
		})
	}

	return out
}
