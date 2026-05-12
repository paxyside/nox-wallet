// Package eth implements all usecase EthClient interfaces using pkg/ethkit.
// Each usecase defines its own interface; this adapter satisfies all of them.
package eth

import (
	"context"
	"math/big"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

// Adapter wraps ethkit.Client and exposes only what usecases need.
// It is intentionally stateless w.r.t. the loaded wallet — wallet state lives
// in the wallet usecase, which is the single source of truth.
type Adapter struct {
	client *ethkit.Client
	log    logger.Log
}

func New(client *ethkit.Client, log logger.Log) *Adapter {
	return &Adapter{client: client, log: log}
}

// ── wallet usecase interface ──────────────────────────────────────────────────

func (a *Adapter) ETHBalance(ctx context.Context, addr ethkit.Address) (ethkit.Amount, error) {
	return a.client.ETHBalance(ctx, addr)
}

func (a *Adapter) TokenBalance(ctx context.Context, addr ethkit.Address, token ethkit.Token) (ethkit.Amount, error) {
	return a.client.TokenBalance(ctx, addr, token)
}

func (a *Adapter) GasFees(ctx context.Context) (ethkit.GasInfo, error) {
	return a.client.GasFees(ctx)
}

func (a *Adapter) BlockNumber(ctx context.Context) (uint64, error) {
	return a.client.BlockNumber(ctx)
}

func (a *Adapter) ChainID() *big.Int {
	return a.client.ChainID()
}

func (a *Adapter) GasEstimateWithFees(
	ctx context.Context,
	req ethkit.TxRequest,
	sender ethkit.Address,
) (uint64, ethkit.GasInfo, ethkit.Amount, error) {
	return a.client.GasEstimateWithFees(ctx, req, sender)
}

func (a *Adapter) SendTx(ctx context.Context, w *ethkit.Wallet, req ethkit.TxRequest) (ethkit.TxReceipt, error) {
	return a.client.SendTx(ctx, w, req)
}

func (a *Adapter) TransferToken(
	ctx context.Context,
	w *ethkit.Wallet,
	token ethkit.Token,
	to ethkit.Address,
	amount ethkit.Amount,
) (ethkit.TxReceipt, error) {
	return a.client.TransferToken(ctx, w, token, to, amount)
}

func (a *Adapter) TransferTokenWithGas(
	ctx context.Context,
	w *ethkit.Wallet,
	token ethkit.Token,
	to ethkit.Address,
	amount ethkit.Amount,
	gasTip *ethkit.Amount,
	gasCap *ethkit.Amount,
) (ethkit.TxReceipt, error) {
	return a.client.TransferTokenWithGas(ctx, w, token, to, amount, gasTip, gasCap)
}

// ── swap usecase interface ────────────────────────────────────────────────────

func (a *Adapter) QuoteSwap(
	ctx context.Context,
	tokenIn, tokenOut ethkit.Token,
	amountIn ethkit.Amount,
	fee ethkit.PoolFee,
) (ethkit.SwapQuote, error) {
	return a.client.QuoteSwap(ctx, tokenIn, tokenOut, amountIn, fee)
}

func (a *Adapter) Swap(ctx context.Context, w *ethkit.Wallet, req ethkit.SwapRequest) (ethkit.TxReceipt, error) {
	return a.client.Swap(ctx, w, req)
}

// ── approvals usecase interface ────────────────────────────────────────────────

func (a *Adapter) ListApprovals(
	ctx context.Context,
	owner ethkit.Address,
	tokens []ethkit.Token,
	spenders []ethkit.Address,
) ([]ethkit.TokenApproval, error) {
	return a.client.ListApprovals(ctx, owner, tokens, spenders)
}

func (a *Adapter) RevokeApproval(
	ctx context.Context,
	wallet *ethkit.Wallet,
	token ethkit.Token,
	spender ethkit.Address,
) (ethkit.TxReceipt, error) {
	return a.client.RevokeApproval(ctx, wallet, token, spender)
}

// ── history / alchemy interface ───────────────────────────────────────────────

func (a *Adapter) GetAssetTransfers(
	ctx context.Context,
	params ethkit.GetAssetTransfersParams,
) (ethkit.AssetTransfersPage, error) {
	return a.client.GetAssetTransfers(ctx, params)
}

// GetReceipt fetches a mined transaction receipt (non-polling).
// Returns (receipt, true, nil) when found, (zero, false, nil) when pending.
func (a *Adapter) GetReceipt(ctx context.Context, txHashHex string) (ethkit.TxReceipt, bool, error) {
	return a.client.GetReceipt(ctx, txHashHex)
}

// ── watcher interface ─────────────────────────────────────────────────────────

func (a *Adapter) WatchBalance(
	ctx context.Context,
	addr ethkit.Address,
	pollInterval time.Duration,
) (<-chan ethkit.BalanceUpdate, error) {
	return a.client.WatchBalance(ctx, addr, pollInterval)
}

// ── token usecase interface ───────────────────────────────────────────────────

func (a *Adapter) TokenMetadata(ctx context.Context, addr ethkit.Address) (ethkit.Token, error) {
	return a.client.TokenMetadata(ctx, addr)
}

// DiscoverTokens returns ERC-20 tokens with a non-zero balance for addr, enriched with
// on-chain metadata (name, symbol, decimals). Tokens with an empty symbol or name are
// filtered out to avoid polluting the watchlist with spam/junk contracts.
func (a *Adapter) DiscoverTokens(ctx context.Context, addr ethkit.Address) ([]ethkit.Token, error) {
	balances, err := a.client.GetTokenBalances(ctx, addr)
	if err != nil {
		return nil, err
	}

	tokens := make([]ethkit.Token, 0, len(balances))
	for _, tb := range balances {
		meta, err := a.client.TokenMetadata(ctx, tb.ContractAddress)
		if err != nil {
			a.log.Warn("discover: token metadata fetch failed",
				"contract", tb.ContractAddress.Hex(), "error", err)

			continue
		}

		// Quality filter: skip tokens with empty symbol or name (spam/junk contracts).
		if meta.Symbol == "" || meta.Name == "" {
			continue
		}

		tokens = append(tokens, meta)
	}

	return tokens, nil
}

// ── Tx simulation ─────────────────────────────────────────────────────────────

func (a *Adapter) SimulateTx(
	ctx context.Context,
	sender ethkit.Address,
	req ethkit.TxRequest,
) (ethkit.SimulationResult, error) {
	return a.client.SimulateTx(ctx, sender, req)
}

// ── Pending tx tracker ────────────────────────────────────────────────────────

func (a *Adapter) PendingForAddress(addr ethkit.Address) []ethkit.PendingTx {
	return a.client.PendingForAddress(addr)
}

// RecentPendingForAddress includes pending entries that were cleared
// in the last few minutes — see ethkit.Client.RecentPendingForAddress
// for the rationale.
func (a *Adapter) RecentPendingForAddress(addr ethkit.Address) []ethkit.PendingTx {
	return a.client.RecentPendingForAddress(addr)
}

// ── Replacement transactions (speed-up / cancel) ──────────────────────────────

func (a *Adapter) SpeedUpTx(
	ctx context.Context,
	w *ethkit.Wallet,
	hash string,
) (string, error) {
	return a.client.SpeedUpTx(ctx, w, hash)
}

func (a *Adapter) CancelTx(
	ctx context.Context,
	w *ethkit.Wallet,
	hash string,
) (string, error) {
	return a.client.CancelTx(ctx, w, hash)
}

// ── ENS ──────────────────────────────────────────────────────────────────────

func (a *Adapter) ResolveENS(ctx context.Context, name string) (ethkit.Address, error) {
	return a.client.ResolveENS(ctx, name)
}

func (a *Adapter) ReverseENS(ctx context.Context, addr ethkit.Address) (string, error) {
	return a.client.ReverseENS(ctx, addr)
}
