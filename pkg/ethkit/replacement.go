package ethkit

import (
	"context"
	"errors"
	"fmt"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
)

// ErrTxAlreadyMined is returned when SpeedUpTx / CancelTx is asked to bump a
// transaction that has already landed on chain. The mempool is no longer
// holding it, so a replacement at the same nonce would just be a regular
// new tx (different effect, possibly costly mistake) — we error out instead.
var ErrTxAlreadyMined = errors.New("ethkit: transaction already mined")

// ErrTxNotFound is returned when the original hash isn't in the mempool or
// chain history (e.g. typo, or the node lost track after a restart).
var ErrTxNotFound = errors.New("ethkit: transaction not found")

// SpeedUpTx resubmits a pending transaction with the same nonce and bumped
// EIP-1559 gas, prompting validators to mine the new replacement instead of
// the slow original. The bump multiplier defaults to 1.2× on tip and 1.1×
// on max fee — those are the canonical "minimum visible jump" values most
// nodes accept as a valid replacement.
//
// Returns the new transaction hash. The caller is responsible for keeping
// track of which hash is currently active for UI purposes — both will live
// in the mempool until one mines and orphans the other.
func (c *Client) SpeedUpTx(
	ctx context.Context,
	wallet *Wallet,
	originalHashHex string,
) (string, error) {
	return c.replaceTx(ctx, wallet, originalHashHex, false)
}

// CancelTx submits a self-transfer at the original transaction's nonce with
// 0 ETH value and bumped gas. When this lands first the original tx is
// orphaned and effectively cancelled.
//
// Note: cancellation is best-effort — if the original gets included in the
// next block before the cancel, the original wins.
func (c *Client) CancelTx(
	ctx context.Context,
	wallet *Wallet,
	originalHashHex string,
) (string, error) {
	return c.replaceTx(ctx, wallet, originalHashHex, true)
}

func (c *Client) replaceTx(
	ctx context.Context,
	wallet *Wallet,
	originalHashHex string,
	cancel bool,
) (string, error) {
	hash := common.HexToHash(originalHashHex)
	tx, isPending, err := c.http.TransactionByHash(ctx, hash)
	if err != nil {
		// Original was dropped from the mempool — janitor would clean
		// the tracker eventually, but do it eagerly so the next UI poll
		// sees an empty pending strip without surfacing a confusing
		// "tx not found" error to the user later.
		c.pending.Remove(originalHashHex)

		return "", fmt.Errorf("%w: %w", ErrTxNotFound, err)
	}
	if !isPending {
		// Already mined — same eager cleanup. The user usually triggered
		// Speed up / Cancel right when the tx landed, racing the
		// 10-second janitor.
		c.pending.Remove(originalHashHex)

		return "", ErrTxAlreadyMined
	}

	// Bump EIP-1559 fees by 20% / 10%. Below 10% the node usually rejects
	// the replacement as "fee too low".
	bumpedTip := new(big.Int).Div(
		new(big.Int).Mul(tx.GasTipCap(), big.NewInt(120)),
		big.NewInt(100),
	)
	bumpedCap := new(big.Int).Div(
		new(big.Int).Mul(tx.GasFeeCap(), big.NewInt(110)),
		big.NewInt(100),
	)

	// Cancel = self-transfer at the same nonce with zero value and no data.
	// Keep gas units high enough for a basic transfer (21k) — plenty.
	newTx := &types.DynamicFeeTx{
		ChainID:   c.ChainID(),
		Nonce:     tx.Nonce(),
		GasTipCap: bumpedTip,
		GasFeeCap: bumpedCap,
		Gas:       tx.Gas(),
		To:        tx.To(),
		Value:     tx.Value(),
		Data:      tx.Data(),
	}
	if cancel {
		newTx.To = new(wallet.Address().Common())
		newTx.Value = big.NewInt(0)
		newTx.Data = nil
		newTx.Gas = 21_000
	}

	signed, err := wallet.SignTx(types.NewTx(newTx), c.ChainID())
	if err != nil {
		return "", fmt.Errorf("ethkit: sign replacement: %w", err)
	}

	if err := c.retrier.Do(ctx, func(ctx context.Context) error {
		return c.http.SendTransaction(ctx, signed)
	}); err != nil {
		return "", fmt.Errorf("ethkit: broadcast replacement: %w", err)
	}

	newHash := signed.Hash().Hex()
	c.log.Info("ethkit: replacement tx sent",
		"action", map[bool]string{false: "speed-up", true: "cancel"}[cancel],
		"original", originalHashHex,
		"new", newHash,
	)

	// Track the replacement as a fresh pending tx. The original is still
	// in the mempool too — both will resolve when one mines and the other
	// is dropped. We don't know `to`/`value` from the new envelope without
	// re-decoding signed.Tx; the tracker uses *newTx as the source of
	// truth.
	to := AddressFromCommon(common.Address{})
	if newTx.To != nil {
		to = AddressFromCommon(*newTx.To)
	}
	c.pending.Add(PendingTx{
		Hash:        newHash,
		From:        wallet.Address(),
		To:          to,
		Value:       NewAmountFromWei(newTx.Value),
		Nonce:       newTx.Nonce,
		GasTipWei:   NewAmountFromWei(newTx.GasTipCap),
		GasCapWei:   NewAmountFromWei(newTx.GasFeeCap),
		SubmittedAt: time.Now().UTC(),
		Kind:        map[bool]string{false: "speed-up", true: "cancel"}[cancel],
	})

	return newHash, nil
}
