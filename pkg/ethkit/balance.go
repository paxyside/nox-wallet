package ethkit

import (
	"context"
	"fmt"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
)

const erc20BalanceOfABI = `[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"}]`

// ETHBalance returns the native ETH balance of addr at the latest block.
func (c *Client) ETHBalance(ctx context.Context, addr Address) (Amount, error) {
	var bal *big.Int

	err := c.retrier.Do(ctx, func(ctx context.Context) error {
		var err error

		bal, err = c.http.BalanceAt(ctx, addr.Common(), nil)

		return err
	})
	if err != nil {
		return ZeroAmount, fmt.Errorf("ethkit: eth balance: %w", err)
	}

	return NewAmountFromWei(bal), nil
}

// TokenBalance returns the ERC-20 balance of addr for the given token.
func (c *Client) TokenBalance(ctx context.Context, addr Address, token Token) (Amount, error) {
	if token.IsNative() {
		return c.ETHBalance(ctx, addr)
	}

	data, err := erc20BalanceOfData(addr.Common())
	if err != nil {
		return ZeroAmount, err
	}

	var result []byte

	err = c.retrier.Do(ctx, func(ctx context.Context) error {
		result, err = c.http.CallContract(ctx, ethereum.CallMsg{
			To:   new(token.Address.Common()),
			Data: data,
		}, nil)

		return err
	})
	if err != nil {
		return ZeroAmount, fmt.Errorf("ethkit: token balance %s: %w", token.Symbol, err)
	}

	bal, err := decodeUint256(result)
	if err != nil {
		return ZeroAmount, fmt.Errorf("ethkit: decode token balance: %w", err)
	}

	return NewAmountFromWei(bal), nil
}

// MultiTokenBalance returns balances for multiple tokens in separate calls.
// The result map uses token.Symbol as key. Native ETH is supported (Token.IsNative()).
func (c *Client) MultiTokenBalance(ctx context.Context, addr Address, tokens []Token) (map[string]Amount, error) {
	result := make(map[string]Amount, len(tokens))
	for _, token := range tokens {
		bal, err := c.TokenBalance(ctx, addr, token)
		if err != nil {
			return result, err
		}

		result[token.Symbol] = bal
	}

	return result, nil
}

// ── helpers ───────────────────────────────────────────────────────────────────

func erc20BalanceOfData(owner common.Address) ([]byte, error) {
	a, err := abi.JSON(strings.NewReader(erc20BalanceOfABI))
	if err != nil {
		return nil, err
	}

	return a.Pack("balanceOf", owner)
}

func decodeUint256(data []byte) (*big.Int, error) {
	if len(data) < 32 {
		return nil, fmt.Errorf("response too short: %d bytes", len(data))
	}

	return new(big.Int).SetBytes(data[:32]), nil
}
