package ethkit

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/shopspring/decimal"
)

// GetAssetTransfersParams configures an alchemy_getAssetTransfers request.
type GetAssetTransfersParams struct {
	// FromAddress filters transfers where this address is the sender. Optional.
	FromAddress *Address
	// ToAddress filters transfers where this address is the receiver. Optional.
	ToAddress *Address
	// FromBlock is the starting block (hex string or "latest"). Default "0x0".
	FromBlock string
	// ToBlock is the ending block. Default "latest".
	ToBlock string
	// Categories to include. Default: all.
	Categories []AssetTransferCategory
	// ContractAddresses restricts ERC-20/721/1155 results to these contracts. Optional.
	ContractAddresses []Address
	// MaxCount is max results per page (1–1000). Default 100.
	MaxCount int
	// PageKey is the pagination cursor from a previous response.
	PageKey string
	// WithMetadata requests block timestamps when true.
	WithMetadata bool
}

// AssetTransfersPage is a paginated result from alchemy_getAssetTransfers.
type AssetTransfersPage struct {
	Transfers []AssetTransfer
	// PageKey is non-empty when more results exist; pass it back in GetAssetTransfersParams.
	PageKey string
}

// GetAssetTransfers calls alchemy_getAssetTransfers to fetch transaction history.
// This is Alchemy-specific and not part of the standard Ethereum JSON-RPC spec.
func (c *Client) GetAssetTransfers(ctx context.Context, params GetAssetTransfersParams) (AssetTransfersPage, error) {
	if c.cfg.HTTPURL == "" {
		return AssetTransfersPage{}, errors.New("ethkit: alchemy HTTPURL not configured")
	}

	if params.FromBlock == "" {
		params.FromBlock = "0x0"
	}

	if params.ToBlock == "" {
		params.ToBlock = "latest"
	}

	if params.MaxCount == 0 {
		params.MaxCount = 100
	}

	if len(params.Categories) == 0 {
		params.Categories = []AssetTransferCategory{
			CategoryExternal,
			CategoryInternal,
			CategoryERC20,
		}
	}

	reqBody := map[string]any{
		"id":      1,
		"jsonrpc": "2.0",
		"method":  "alchemy_getAssetTransfers",
		"params": []any{map[string]any{
			"fromBlock":        params.FromBlock,
			"toBlock":          params.ToBlock,
			"category":         params.Categories,
			"maxCount":         fmt.Sprintf("0x%x", params.MaxCount),
			"withMetadata":     params.WithMetadata,
			"excludeZeroValue": true,
		}},
	}

	if params.FromAddress != nil {
		reqBody["params"].([]any)[0].(map[string]any)["fromAddress"] = params.FromAddress.Hex()
	}

	if params.ToAddress != nil {
		reqBody["params"].([]any)[0].(map[string]any)["toAddress"] = params.ToAddress.Hex()
	}

	if params.PageKey != "" {
		reqBody["params"].([]any)[0].(map[string]any)["pageKey"] = params.PageKey
	}

	if len(params.ContractAddresses) > 0 {
		addrs := make([]string, len(params.ContractAddresses))
		for i, a := range params.ContractAddresses {
			addrs[i] = a.Hex()
		}

		reqBody["params"].([]any)[0].(map[string]any)["contractAddresses"] = addrs
	}

	raw, err := c.alchemyRPC(ctx, reqBody)
	if err != nil {
		return AssetTransfersPage{}, err
	}

	return parseAssetTransfers(raw)
}

// GetTokenBalances calls alchemy_getTokenBalances to get all ERC-20 balances for an address.
// Returns only non-zero balances. Token metadata is not populated — call TokenMetadata separately.
func (c *Client) GetTokenBalances(ctx context.Context, addr Address) ([]TokenBalance, error) {
	reqBody := map[string]any{
		"id":      1,
		"jsonrpc": "2.0",
		"method":  "alchemy_getTokenBalances",
		"params":  []any{addr.Hex(), "erc20"},
	}

	raw, err := c.alchemyRPC(ctx, reqBody)
	if err != nil {
		return nil, err
	}

	return parseTokenBalances(raw)
}

// TokenBalance is a raw token balance entry from alchemy_getTokenBalances.
type TokenBalance struct {
	ContractAddress Address
	Balance         Amount
}

// ── internal ──────────────────────────────────────────────────────────────────

func (c *Client) alchemyRPC(ctx context.Context, body map[string]any) (json.RawMessage, error) {
	encoded, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.cfg.HTTPURL, bytes.NewReader(encoded))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ethkit: alchemy rpc: %w", err)
	}
	defer resp.Body.Close()

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var envelope struct {
		Error  *struct{ Message string } `json:"error"`
		Result json.RawMessage           `json:"result"`
	}
	if err = json.Unmarshal(b, &envelope); err != nil {
		return nil, fmt.Errorf("ethkit: alchemy decode: %w", err)
	}

	if envelope.Error != nil {
		return nil, fmt.Errorf("ethkit: alchemy error: %s", envelope.Error.Message)
	}

	return envelope.Result, nil
}

type alchemyTransfer struct {
	BlockNum    string       `json:"blockNum"`
	UniqueID    string       `json:"uniqueId"` // canonical "<hash>:<category>:<index>"
	Hash        string       `json:"hash"`
	From        string       `json:"from"`
	To          string       `json:"to"`
	Value       *float64     `json:"value"`
	Asset       string       `json:"asset"`
	Category    string       `json:"category"`
	Metadata    *alchemyMeta `json:"metadata"`
	RawContract *struct {
		Value   string `json:"value"`
		Address string `json:"address"`
		Decimal string `json:"decimal"`
	} `json:"rawContract"`
}

type alchemyMeta struct {
	BlockTimestamp string `json:"blockTimestamp"`
}

func parseAssetTransfers(raw json.RawMessage) (AssetTransfersPage, error) {
	var result struct {
		Transfers []alchemyTransfer `json:"transfers"`
		PageKey   string            `json:"pageKey"`
	}
	if err := json.Unmarshal(raw, &result); err != nil {
		return AssetTransfersPage{}, fmt.Errorf("ethkit: parse transfers: %w", err)
	}

	transfers := make([]AssetTransfer, 0, len(result.Transfers))
	for _, t := range result.Transfers {
		at, err := convertTransfer(t)
		if err != nil {
			continue
		}

		transfers = append(transfers, at)
	}

	return AssetTransfersPage{
		Transfers: transfers,
		PageKey:   result.PageKey,
	}, nil
}

func convertTransfer(t alchemyTransfer) (AssetTransfer, error) {
	from, err := NewAddress(t.From)
	if err != nil {
		return AssetTransfer{}, err
	}

	to, err := NewAddress(t.To)
	if err != nil {
		return AssetTransfer{}, err
	}

	// Parse block number from hex.
	blockNum := uint64(0)
	if n, err := strconv.ParseUint(strings.TrimPrefix(t.BlockNum, "0x"), 16, 64); err == nil {
		blockNum = n
	}

	var ts time.Time
	if t.Metadata != nil && t.Metadata.BlockTimestamp != "" {
		ts, _ = time.Parse(time.RFC3339, t.Metadata.BlockTimestamp)
	}

	var val float64
	if t.Value != nil {
		val = *t.Value
	}

	uniqueID := t.UniqueID
	// Defensive fallback: if Alchemy didn't return uniqueId, synthesize one
	// so we can still distinguish multi-leg events (e.g. swap = 2 transfers).
	if uniqueID == "" {
		uniqueID = fmt.Sprintf("%s:%s:%s", t.Hash, t.Category, t.Asset)
	}

	at := AssetTransfer{
		BlockNumber: blockNum,
		Timestamp:   ts,
		Hash:        t.Hash,
		UniqueID:    uniqueID,
		From:        from,
		To:          to,
		Value:       floatToDecimal(val),
		Asset:       t.Asset,
		Category:    AssetTransferCategory(t.Category),
	}

	// Attach minimal token info for ERC-20 transfers.
	if t.Category == string(CategoryERC20) && t.RawContract != nil && t.RawContract.Address != "" {
		addr, err := NewAddress(t.RawContract.Address)
		if err == nil {
			decimals := uint8(18)

			if t.RawContract.Decimal != "" {
				if d, err := strconv.ParseUint(strings.TrimPrefix(t.RawContract.Decimal, "0x"), 16, 8); err == nil {
					decimals = uint8(d)
				}
			}

			at.Token = &Token{
				Address:  addr,
				Symbol:   t.Asset,
				Decimals: decimals,
			}
		}
	}

	return at, nil
}

func floatToDecimal(f float64) decimal.Decimal {
	return decimal.NewFromFloat(f)
}

func parseTokenBalances(raw json.RawMessage) ([]TokenBalance, error) {
	var result struct {
		TokenBalances []struct {
			ContractAddress string `json:"contractAddress"`
			TokenBalance    string `json:"tokenBalance"`
		} `json:"tokenBalances"`
	}
	if err := json.Unmarshal(raw, &result); err != nil {
		return nil, fmt.Errorf("ethkit: parse token balances: %w", err)
	}

	balances := make([]TokenBalance, 0, len(result.TokenBalances))
	for _, tb := range result.TokenBalances {
		addr, err := NewAddress(tb.ContractAddress)
		if err != nil {
			continue
		}
		// TokenBalance is a hex string.
		wei := new(big.Int)
		wei.SetString(strings.TrimPrefix(tb.TokenBalance, "0x"), 16)

		if wei.Sign() == 0 {
			continue // skip zero balances
		}

		balances = append(balances, TokenBalance{
			ContractAddress: addr,
			Balance:         NewAmountFromWei(wei),
		})
	}

	return balances, nil
}
