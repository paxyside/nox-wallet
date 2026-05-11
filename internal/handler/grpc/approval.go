package grpc

import (
	"context"
	"fmt"
	"math/big"
	"strings"

	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
)

// ─────────────────────────────────────────────────────────────────────────────
// Approvals — list active ERC-20 allowances + revoke
// ─────────────────────────────────────────────────────────────────────────────

func (h *Handler) ListApprovals(
	ctx context.Context,
	_ *pb.ListApprovalsRequest,
) (*pb.ListApprovalsResponse, error) {
	list, err := h.approval.List(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	out := make([]*pb.TokenApproval, 0, len(list))
	for _, e := range list {
		p := approvalToProto(e.TokenApproval)
		p.TokenLogoUrl = e.LogoURL
		out = append(out, p)
	}

	return &pb.ListApprovalsResponse{Approvals: out}, nil
}

func (h *Handler) RevokeApproval(
	ctx context.Context,
	req *pb.RevokeApprovalRequest,
) (*pb.RevokeApprovalResponse, error) {
	tokenAddr, err := ethkit.NewAddress(req.GetTokenAddress())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err,
			liberrors.CodeInvalidArgument, "invalid token address"))
	}

	spender, err := ethkit.NewAddress(req.GetSpender())
	if err != nil {
		return nil, h.HandleError(ctx, liberrors.Wrapf(err,
			liberrors.CodeInvalidArgument, "invalid spender address"))
	}

	receipt, err := h.approval.Revoke(ctx, tokenAddr, spender)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.RevokeApprovalResponse{Receipt: receiptToProto(receipt)}, nil
}

// ── proto mapping ────────────────────────────────────────────────────────────

// spenderLabels maps known DEX router addresses (lowercased hex) to the
// human-readable name shown in the UI. Anything not in this map gets
// labelled by short address.
var spenderLabels = map[string]string{
	"0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45": "Uniswap V3",
	"0x7a250d5630b4cf539739df2c5dacb4c659f2488d": "Uniswap V2",
	"0x3fc91a3afd70395cd496c647d5a6cc9d4b2b7fad": "Uniswap Universal",
	"0x1111111254eeb25477b68fb85ed929f73a960582": "1inch v5",
	"0xdef1c0ded9bec7f1a1670819833240f027b25eff": "0x Exchange",
	"0x9008d19f58aabd9ed0d60971565aa8510560ab41": "CoW Protocol",
	"0xdef171fe48cf0115b1d80b88dc8eab59176fee57": "Paraswap",
}

func approvalToProto(a ethkit.TokenApproval) *pb.TokenApproval {
	spLower := strings.ToLower(a.Spender.Hex())
	label, ok := spenderLabels[spLower]
	if !ok {
		s := a.Spender.Hex()
		label = s[:10] + "…" + s[len(s)-6:]
	}

	return &pb.TokenApproval{
		TokenAddress:  a.Token.Address.Hex(),
		TokenSymbol:   a.Token.Symbol,
		TokenName:     a.Token.Name,
		TokenDecimals: uint32(a.Token.Decimals),
		Spender:       a.Spender.Hex(),
		SpenderLabel:  label,
		AmountRaw:     a.Amount.Wei().String(),
		AmountHuman:   formatApprovalAmount(a),
	}
}

// formatApprovalAmount picks "Unlimited" for the canonical max-uint256
// approval and a human-readable token-units string otherwise.
func formatApprovalAmount(a ethkit.TokenApproval) string {
	wei := a.Amount.Wei()
	// Anything within ~1% of max-uint256 is treated as unlimited — DEXs
	// sometimes use slightly-less to skirt SafeMath issues but the intent
	// is the same.
	if wei.BitLen() >= 252 {
		return "Unlimited"
	}
	if wei.Cmp(big.NewInt(0)) == 0 {
		return fmt.Sprintf("0 %s", a.Token.Symbol)
	}
	dec := int32(a.Token.Decimals)
	if dec > 6 {
		dec = 6
	}
	human := a.Amount.ToTokenUnits(a.Token.Decimals).StringFixed(dec)
	return fmt.Sprintf("%s %s", human, a.Token.Symbol)
}
