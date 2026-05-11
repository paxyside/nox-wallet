package ethkit

import (
	"context"
	"fmt"
	"math/big"
	"sync"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
)

// nonceManager tracks pending nonces per address to avoid conflicts
// when multiple transactions are sent in quick succession from the same Client.
type nonceManager struct {
	mu      sync.Mutex
	pending map[string]uint64 // key: checksummed address hex
	client  *Client
}

func (nm *nonceManager) next(ctx context.Context, addr common.Address) (uint64, error) {
	key := addr.Hex()

	nm.mu.Lock()
	defer nm.mu.Unlock()

	if _, ok := nm.pending[key]; !ok {
		n, err := nm.client.http.PendingNonceAt(ctx, addr)
		if err != nil {
			return 0, fmt.Errorf("ethkit: get nonce: %w", err)
		}

		nm.pending[key] = n
	}

	nonce := nm.pending[key]
	nm.pending[key]++

	return nonce, nil
}

func (nm *nonceManager) reset(addr common.Address) {
	nm.mu.Lock()
	delete(nm.pending, addr.Hex())
	nm.mu.Unlock()
}

// SendTx builds, signs, and broadcasts a transaction, then waits for the receipt.
func (c *Client) SendTx(ctx context.Context, wallet *Wallet, req TxRequest) (TxReceipt, error) {
	nonce, err := c.nonces.next(ctx, wallet.Address().Common())
	if err != nil {
		return TxReceipt{}, err
	}

	gasUnits, gasInfo, _, err := c.GasEstimateWithFees(ctx, req, wallet.Address())
	if err != nil {
		return TxReceipt{}, err
	}

	tip := gasInfo.PriorityFee.Wei()
	if req.GasTip != nil {
		tip = req.GasTip.Wei()
	}

	maxFee := gasInfo.MaxFee.Wei()
	if req.GasCap != nil {
		maxFee = req.GasCap.Wei()
	}

	if req.GasLimit != 0 {
		gasUnits = req.GasLimit
	}

	rawTx := types.NewTx(&types.DynamicFeeTx{
		ChainID:   c.ChainID(),
		Nonce:     nonce,
		GasTipCap: tip,
		GasFeeCap: maxFee,
		Gas:       gasUnits,
		To:        new(req.To.Common()),
		Value:     req.Value.Wei(),
		Data:      req.Data,
	})

	signed, err := wallet.SignTx(rawTx, c.ChainID())
	if err != nil {
		return TxReceipt{}, err
	}

	err = c.retrier.Do(ctx, func(ctx context.Context) error {
		return c.http.SendTransaction(ctx, signed)
	})
	if err != nil {
		c.nonces.reset(wallet.Address().Common())
		return TxReceipt{}, fmt.Errorf("ethkit: broadcast tx: %w", err)
	}

	txHash := signed.Hash()
	c.log.Info("ethkit: tx sent", "hash", txHash.Hex())

	// Register in the pending tracker so the UI can show "in mempool" rows
	// + offer Speed up / Cancel actions until the receipt comes in.
	c.pending.Add(PendingTx{
		Hash:        txHash.Hex(),
		From:        wallet.Address(),
		To:          req.To,
		Value:       req.Value,
		Nonce:       nonce,
		GasTipWei:   NewAmountFromWei(tip),
		GasCapWei:   NewAmountFromWei(maxFee),
		SubmittedAt: time.Now().UTC(),
		Kind:        req.Kind,
	})
	defer c.pending.Remove(txHash.Hex())

	return c.waitForReceipt(ctx, txHash)
}

// WaitForReceipt polls until the transaction is mined or ctx is cancelled.
func (c *Client) WaitForReceipt(ctx context.Context, txHashHex string) (TxReceipt, error) {
	return c.waitForReceipt(ctx, common.HexToHash(txHashHex))
}

func (c *Client) waitForReceipt(ctx context.Context, hash common.Hash) (TxReceipt, error) {
	ticker := time.NewTicker(3 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return TxReceipt{}, ctx.Err()
		case <-ticker.C:
			receipt, err := c.http.TransactionReceipt(ctx, hash)
			if err != nil {
				continue // not mined yet
			}

			status := TxStatusSuccess
			if receipt.Status == types.ReceiptStatusFailed {
				status = TxStatusFailed
			}

			effectiveGasPrice := receipt.EffectiveGasPrice
			if effectiveGasPrice == nil {
				effectiveGasPrice = new(big.Int)
			}

			gasCost := new(big.Int).Mul(effectiveGasPrice, big.NewInt(int64(receipt.GasUsed)))

			return TxReceipt{
				Hash:        hash.Hex(),
				Status:      status,
				BlockNumber: receipt.BlockNumber.Uint64(),
				GasUsed:     receipt.GasUsed,
				GasCost:     NewAmountFromWei(gasCost),
			}, nil
		}
	}
}

// GetReceipt fetches the receipt for an already-mined transaction.
// Returns (receipt, true, nil) on success, (zero, false, nil) when the tx is
// not yet mined, and (zero, false, err) on any RPC error.
func (c *Client) GetReceipt(ctx context.Context, txHashHex string) (TxReceipt, bool, error) {
	hash := common.HexToHash(txHashHex)

	receipt, err := c.http.TransactionReceipt(ctx, hash)
	if err != nil {
		// go-ethereum returns ethereum.NotFound (wrapped as "not found") when pending.
		if err.Error() == "not found" {
			return TxReceipt{}, false, nil
		}

		return TxReceipt{}, false, fmt.Errorf("ethkit: get receipt: %w", err)
	}

	status := TxStatusSuccess
	if receipt.Status == types.ReceiptStatusFailed {
		status = TxStatusFailed
	}

	effectiveGasPrice := receipt.EffectiveGasPrice
	if effectiveGasPrice == nil {
		effectiveGasPrice = new(big.Int)
	}

	gasCost := new(big.Int).Mul(effectiveGasPrice, big.NewInt(int64(receipt.GasUsed)))

	return TxReceipt{
		Hash:        hash.Hex(),
		Status:      status,
		BlockNumber: receipt.BlockNumber.Uint64(),
		GasUsed:     receipt.GasUsed,
		GasCost:     NewAmountFromWei(gasCost),
	}, true, nil
}

// GetTx returns a transaction by hash. isPending is true if not yet mined.
func (c *Client) GetTx(ctx context.Context, txHashHex string) (*types.Transaction, bool, error) {
	hash := common.HexToHash(txHashHex)

	tx, isPending, err := c.http.TransactionByHash(ctx, hash)
	if err != nil {
		return nil, false, fmt.Errorf("ethkit: get tx: %w", err)
	}

	return tx, isPending, nil
}
