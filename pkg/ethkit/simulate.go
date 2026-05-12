package ethkit

import (
	"context"
	"errors"
	"fmt"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum"
)

// SimulationResult is the outcome of a pre-flight simulation.
//
// We try `alchemy_simulateAssetChanges` first to also surface post-state
// balance diffs (so the UI can show "you'll receive 1.2 USDC, send 0.001
// ETH"). If Alchemy isn't reachable or the chain isn't supported, we fall
// back to `eth_call` + `eth_estimateGas` — gas + revert detection alone is
// still enough to catch the common mistakes (insufficient allowance,
// slippage too tight, swap pool drained).
type SimulationResult struct {
	// WillRevert is true when the transaction would revert if submitted now.
	WillRevert bool

	// RevertReason is decoded from the revert payload when available; empty
	// for non-revert paths or when the contract didn't include a Revert
	// string.
	RevertReason string

	// GasUnits is the estimated gas the transaction would consume, in units.
	// 0 if the tx would revert (no point estimating).
	GasUnits uint64

	// EstimatedCostWei is GasUnits × maxFeePerGas, i.e. the upper bound on
	// what the user pays.
	EstimatedCostWei Amount

	// AssetChanges enumerates net balance diffs the simulated tx would
	// produce. Populated by `alchemy_simulateAssetChanges` only — the
	// fallback eth_call path leaves it empty. From the sender's perspective,
	// outgoing transfers have negative human-readable amounts (we keep the
	// sign on the parsed Amount via IsNegative when applicable).
	AssetChanges []AssetChange
}

// AssetChangeKind classifies a row in alchemy_simulateAssetChanges.
// Values come from Alchemy verbatim: "NATIVE", "ERC20", "ERC721",
// "ERC1155", "SPECIAL". We don't predeclare named constants — the UI
// matches on the string form when it cares about the variant.
type AssetChangeKind string

// AssetChange is one entry from alchemy_simulateAssetChanges. Strings stay
// in their human-friendly form ("0.001234"); we don't reparse to Amount
// because some entries (NFT mints) lack a meaningful numeric amount.
type AssetChange struct {
	// Kind: NATIVE / ERC20 / ERC721 / ERC1155 / SPECIAL.
	Kind AssetChangeKind
	// ChangeType is "TRANSFER" or "APPROVE" — Alchemy reports both.
	ChangeType string
	// From / To raw hex addresses. NATIVE always has the wallet on one side.
	From string
	To   string
	// AmountHuman is the decimal-formatted amount ("1.234"). Empty for
	// NFT-only changes.
	AmountHuman string
	// Symbol / Name / Decimals come from on-chain metadata that Alchemy
	// resolves for us — saves the UI a round-trip.
	Symbol   string
	Name     string
	Decimals uint8
	// ContractAddress is non-empty for non-native changes.
	ContractAddress string
	// TokenID is non-empty for ERC-721 / ERC-1155 entries.
	TokenID string
}

// SimulateTx runs a pre-flight simulation. Primary path is Alchemy's
// `alchemy_simulateAssetChanges` which returns asset diffs + gasUsed +
// revert info in one round-trip. If Alchemy isn't available or the response
// signals a transient failure we fall back to `eth_call` + `eth_estimateGas`
// (no asset diffs, but enough for revert/gas).
//
// Returns a non-nil result for both success and revert cases; only
// network-level errors bubble out.
func (c *Client) SimulateTx(
	ctx context.Context,
	sender Address,
	req TxRequest,
) (SimulationResult, error) {
	if c.cfg.HTTPURL != "" {
		if res, ok, err := c.simulateAssetChanges(ctx, sender, req); err != nil {
			c.log.Warn(
				"ethkit: alchemy simulate failed, falling back to eth_call",
				"error", err,
			)
		} else if ok {
			return res, nil
		}
	}

	return c.simulateETHCall(ctx, sender, req)
}

// simulateETHCall is the fallback path: eth_call to detect reverts +
// eth_estimateGas + gas suggestion → cost. No asset-change info.
func (c *Client) simulateETHCall(
	ctx context.Context,
	sender Address,
	req TxRequest,
) (SimulationResult, error) {
	msg := ethereum.CallMsg{
		From:  sender.Common(),
		To:    new(req.To.Common()),
		Value: req.Value.Wei(),
		Data:  req.Data,
	}

	// 1. eth_call — does the contract revert?
	if _, err := c.http.CallContract(ctx, msg, nil); err != nil {
		// Differentiate "execution reverted: $reason" (contract reject —
		// expected, surface to user) from network errors (bubble up).
		reason := decodeRevert(err)
		if reason != "" {
			return SimulationResult{
				WillRevert:   true,
				RevertReason: reason,
			}, nil
		}
		// Some nodes return "execution reverted" without a string when the
		// reason isn't present — still surface as expected revert, not a
		// hard error. Our heuristic: any error containing "revert".
		if strings.Contains(strings.ToLower(err.Error()), "revert") {
			return SimulationResult{
				WillRevert:   true,
				RevertReason: trimRevertPrefix(err.Error()),
			}, nil
		}
		return SimulationResult{}, fmt.Errorf("ethkit: simulate call: %w", err)
	}

	// 2. eth_estimateGas + current gas suggestion → cost.
	gasUnits, err := c.http.EstimateGas(ctx, msg)
	if err != nil {
		return SimulationResult{}, fmt.Errorf("ethkit: estimate gas: %w", err)
	}

	gas, err := c.GasFees(ctx)
	if err != nil {
		return SimulationResult{}, fmt.Errorf("ethkit: gas fees: %w", err)
	}

	costWei := new(big.Int).Mul(gas.MaxFee.Wei(), big.NewInt(int64(gasUnits)))

	return SimulationResult{
		WillRevert:       false,
		GasUnits:         gasUnits,
		EstimatedCostWei: NewAmountFromWei(costWei),
	}, nil
}

// decodeRevert extracts the revert reason string from an eth_call error.
// go-ethereum's `rpc.DataError` carries a `Data()` method that returns the
// raw revert bytes; we decode the standard `Error(string)` (selector
// 0x08c379a0) layout.
func decodeRevert(err error) string {
	type dataError interface {
		ErrorData() any
	}
	var de dataError
	if !errors.As(err, &de) {
		return ""
	}
	raw, ok := de.ErrorData().(string)
	if !ok {
		return ""
	}
	if !strings.HasPrefix(raw, "0x08c379a0") {
		// Unknown revert layout — return raw payload truncated.
		if len(raw) > 12 {
			return raw[:12] + "…"
		}
		return raw
	}
	// 4 bytes selector + 32 bytes offset + 32 bytes length + payload.
	// Skip "0x" + 8 chars selector + 64 chars offset + read 64 chars length,
	// then convert hex pairs to chars up to length.
	if len(raw) < 2+8+64+64 {
		return ""
	}
	lengthHex := raw[2+8+64 : 2+8+64+64]
	length, ok2 := new(big.Int).SetString(lengthHex, 16)
	if !ok2 {
		return ""
	}
	bytesLen := length.Int64()
	dataStart := 2 + 8 + 64 + 64
	dataEnd := dataStart + int(bytesLen)*2
	if dataEnd > len(raw) {
		return ""
	}
	out := make([]byte, 0, bytesLen)
	for i := dataStart; i < dataEnd; i += 2 {
		var b uint8
		if _, err := fmt.Sscanf(raw[i:i+2], "%x", &b); err != nil {
			return ""
		}
		out = append(out, b)
	}
	return string(out)
}

func trimRevertPrefix(s string) string {
	for _, p := range []string{
		"execution reverted: ",
		"execution reverted",
	} {
		if strings.HasPrefix(s, p) {
			return strings.TrimSpace(strings.TrimPrefix(s, p))
		}
	}
	return s
}
