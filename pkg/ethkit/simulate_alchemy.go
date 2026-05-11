package ethkit

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"strconv"
	"strings"
)

// simulateAssetChanges calls Alchemy's `alchemy_simulateAssetChanges` to
// preview both the gas consumed and the net asset diff (NATIVE/ERC-20/NFT)
// the transaction would produce. Returns (result, true, nil) on success,
// (zero, false, nil) when the RPC isn't supported or the response shape was
// unexpected — both signal "use the eth_call fallback". A non-nil error
// means a hard network/transport failure.
func (c *Client) simulateAssetChanges(
	ctx context.Context,
	sender Address,
	req TxRequest,
) (SimulationResult, bool, error) {
	to := req.To.Hex()
	value := bigToHex(req.Value.Wei())
	data := bytesToHex(req.Data)

	params := map[string]any{
		"from":  sender.Hex(),
		"to":    to,
		"value": value,
	}
	if data != "0x" {
		params["data"] = data
	}

	body := map[string]any{
		"id":      1,
		"jsonrpc": "2.0",
		"method":  "alchemy_simulateAssetChanges",
		"params":  []any{params},
	}

	raw, err := c.alchemyRPC(ctx, body)
	if err != nil {
		// "method not found" / "not supported" — treat as "fallback please"
		// rather than a hard error. The fallback path still works.
		if isMethodNotSupported(err) {
			return SimulationResult{}, false, nil
		}

		return SimulationResult{}, false, err
	}

	var resp simulateAssetChangesResponse
	if err = json.Unmarshal(raw, &resp); err != nil {
		return SimulationResult{}, false, fmt.Errorf("ethkit: simulate decode: %w", err)
	}

	// Alchemy reports an inline error when the simulated tx would revert.
	if resp.Error != nil {
		return SimulationResult{
			WillRevert:   true,
			RevertReason: trimRevertPrefix(resp.Error.Message),
		}, true, nil
	}

	gasUnits, gasErr := hexToUint64(resp.GasUsed)
	if gasErr != nil {
		// Malformed payload — log and fall back to eth_call.
		c.log.Warn("ethkit: alchemy gasUsed parse failed", "error", gasErr)

		return SimulationResult{}, false, nil
	}

	// Estimated cost = gasUsed × maxFeePerGas. We need a separate fee call;
	// alchemy_simulateAssetChanges doesn't report fees back.
	gas, err := c.GasFees(ctx)
	if err != nil {
		return SimulationResult{}, false, fmt.Errorf("ethkit: gas fees: %w", err)
	}

	costWei := new(big.Int).Mul(gas.MaxFee.Wei(), new(big.Int).SetUint64(gasUnits))

	changes := make([]AssetChange, 0, len(resp.Changes))
	for _, ch := range resp.Changes {
		changes = append(changes, ch.toAssetChange())
	}

	return SimulationResult{
		GasUnits:         gasUnits,
		EstimatedCostWei: NewAmountFromWei(costWei),
		AssetChanges:     changes,
	}, true, nil
}

// simulateAssetChangesResponse mirrors the JSON shape Alchemy returns. We
// keep it private — callers consume the higher-level AssetChange instead.
type simulateAssetChangesResponse struct {
	Changes []alchemyAssetChange `json:"changes"`
	GasUsed string               `json:"gasUsed"`
	Error   *struct {
		Message string `json:"message"`
	} `json:"error"`
}

type alchemyAssetChange struct {
	AssetType       string `json:"assetType"`
	ChangeType      string `json:"changeType"`
	From            string `json:"from"`
	To              string `json:"to"`
	Amount          string `json:"amount"`
	Symbol          string `json:"symbol"`
	Name            string `json:"name"`
	Decimals        uint8  `json:"decimals"`
	ContractAddress string `json:"contractAddress"`
	TokenID         string `json:"tokenId"`
}

func (a alchemyAssetChange) toAssetChange() AssetChange {
	return AssetChange{
		Kind:            AssetChangeKind(a.AssetType),
		ChangeType:      a.ChangeType,
		From:            a.From,
		To:              a.To,
		AmountHuman:     a.Amount,
		Symbol:          a.Symbol,
		Name:            a.Name,
		Decimals:        a.Decimals,
		ContractAddress: a.ContractAddress,
		TokenID:         a.TokenID,
	}
}

func bigToHex(n *big.Int) string {
	if n == nil || n.Sign() == 0 {
		return "0x0"
	}

	return "0x" + n.Text(16)
}

func bytesToHex(b []byte) string {
	if len(b) == 0 {
		return "0x"
	}

	return "0x" + bytesToHexString(b)
}

func bytesToHexString(b []byte) string {
	const hex = "0123456789abcdef"
	out := make([]byte, len(b)*2)
	for i, v := range b {
		out[i*2] = hex[v>>4]
		out[i*2+1] = hex[v&0x0f]
	}

	return string(out)
}

func hexToUint64(s string) (uint64, error) {
	s = strings.TrimPrefix(s, "0x")
	if s == "" {
		return 0, nil
	}

	return strconv.ParseUint(s, 16, 64)
}

// isMethodNotSupported reports whether an alchemy_* RPC error is the
// node's way of saying "I don't speak this method" (e.g. on Sepolia when
// simulateAssetChanges is mainnet-only). Cheap string sniff: there's no
// dedicated error code in the JSON-RPC response.
func isMethodNotSupported(err error) bool {
	if err == nil {
		return false
	}
	msg := strings.ToLower(err.Error())

	return strings.Contains(msg, "method not found") ||
		strings.Contains(msg, "not supported") ||
		strings.Contains(msg, "does not support")
}
