package ethkit

import (
	"context"
	"errors"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/common"
)

// GasEstimate returns the gas units needed for req, simulating the call from sender.
func (c *Client) GasEstimate(ctx context.Context, req TxRequest, sender Address) (uint64, error) {
	msg := ethereum.CallMsg{
		From:  sender.Common(),
		To:    new(req.To.Common()),
		Value: req.Value.Wei(),
		Data:  req.Data,
	}

	var gas uint64

	err := c.retrier.Do(ctx, func(ctx context.Context) error {
		var err error

		gas, err = c.http.EstimateGas(ctx, msg)

		return err
	})
	if err != nil {
		return 0, fmt.Errorf("ethkit: estimate gas: %w", err)
	}

	return gas, nil
}

// GasEstimateAnonymous estimates gas without a known sender (uses zero address).
// Suitable for read-only fee previews before the wallet is loaded.
func (c *Client) GasEstimateAnonymous(ctx context.Context, req TxRequest) (uint64, error) {
	return c.GasEstimate(ctx, req, AddressFromCommon(common.Address{}))
}

// GasFees returns current EIP-1559 fee market data.
// BaseFee comes from the latest block; PriorityFee from eth_maxPriorityFeePerGas.
func (c *Client) GasFees(ctx context.Context) (GasInfo, error) {
	header, err := c.http.HeaderByNumber(ctx, nil)
	if err != nil {
		return GasInfo{}, fmt.Errorf("ethkit: fetch header: %w", err)
	}

	if header.BaseFee == nil {
		return GasInfo{}, errors.New("ethkit: node does not support EIP-1559 (no base fee)")
	}

	var tip *big.Int

	err = c.retrier.Do(ctx, func(ctx context.Context) error {
		var err error

		tip, err = c.http.SuggestGasTipCap(ctx)

		return err
	})
	if err != nil {
		return GasInfo{}, fmt.Errorf("ethkit: suggest gas tip: %w", err)
	}

	baseFee := header.BaseFee
	maxFee := new(big.Int).Add(new(big.Int).Mul(baseFee, big.NewInt(2)), tip)
	gasPrice := new(big.Int).Add(baseFee, tip)

	return GasInfo{
		BaseFee:     NewAmountFromWei(baseFee),
		PriorityFee: NewAmountFromWei(tip),
		MaxFee:      NewAmountFromWei(maxFee),
		GasPrice:    NewAmountFromWei(gasPrice),
	}, nil
}

// GasEstimateWithFees returns gas units, fee info, and total ETH cost for req sent by sender.
func (c *Client) GasEstimateWithFees(
	ctx context.Context,
	req TxRequest,
	sender Address,
) (uint64, GasInfo, Amount, error) {
	gasInfo, err := c.GasFees(ctx)
	if err != nil {
		return 0, GasInfo{}, ZeroAmount, err
	}

	gasUnits := req.GasLimit
	if gasUnits == 0 {
		gasUnits, err = c.GasEstimate(ctx, req, sender)
		if err != nil {
			return 0, GasInfo{}, ZeroAmount, err
		}
		// 20% buffer to avoid out-of-gas on state changes.
		gasUnits = gasUnits * 12 / 10
	}

	totalCost := NewAmountFromWei(new(big.Int).Mul(gasInfo.MaxFee.Wei(), big.NewInt(int64(gasUnits))))

	return gasUnits, gasInfo, totalCost, nil
}
