package ethkit

import (
	"context"
	"fmt"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"

	"github.com/paxyside/nox-wallet/pkg/ethkit/abis"
)

type erc20Caller struct {
	abi     abi.ABI
	client  *Client
	token   Token
	address common.Address
}

func newERC20Caller(c *Client, token Token) *erc20Caller {
	return &erc20Caller{
		abi:     abis.ERC20(),
		client:  c,
		token:   token,
		address: token.Address.Common(),
	}
}

func (e *erc20Caller) call(ctx context.Context, method string, args ...any) ([]byte, error) {
	data, err := e.abi.Pack(method, args...)
	if err != nil {
		return nil, fmt.Errorf("erc20 pack %s: %w", method, err)
	}

	var result []byte

	err = e.client.retrier.Do(ctx, func(ctx context.Context) error {
		result, err = e.client.http.CallContract(ctx, ethereum.CallMsg{
			To:   &e.address,
			Data: data,
		}, nil)

		return err
	})

	return result, err
}

// TokenMetadata fetches on-chain name, symbol, and decimals for a contract address.
func (c *Client) TokenMetadata(ctx context.Context, contractAddr Address) (Token, error) {
	a := abis.ERC20()

	callRaw := func(method string) ([]byte, error) {
		data, _ := a.Pack(method)
		addr := contractAddr.Common()

		var result []byte

		err := c.retrier.Do(ctx, func(ctx context.Context) error {
			var callErr error
			result, callErr = c.http.CallContract(ctx, ethereum.CallMsg{To: &addr, Data: data}, nil)

			return callErr
		})

		return result, err
	}

	nameRaw, err := callRaw("name")
	if err != nil {
		return Token{}, fmt.Errorf("ethkit: token name: %w", err)
	}

	symbolRaw, err := callRaw("symbol")
	if err != nil {
		return Token{}, fmt.Errorf("ethkit: token symbol: %w", err)
	}

	decimalsRaw, err := callRaw("decimals")
	if err != nil {
		return Token{}, fmt.Errorf("ethkit: token decimals: %w", err)
	}

	var (
		name, symbol string
		decimals     uint8
	)

	if err = a.UnpackIntoInterface(&name, "name", nameRaw); err != nil {
		return Token{}, fmt.Errorf("ethkit: unpack name: %w", err)
	}

	if err = a.UnpackIntoInterface(&symbol, "symbol", symbolRaw); err != nil {
		return Token{}, fmt.Errorf("ethkit: unpack symbol: %w", err)
	}

	if err = a.UnpackIntoInterface(&decimals, "decimals", decimalsRaw); err != nil {
		return Token{}, fmt.Errorf("ethkit: unpack decimals: %w", err)
	}

	return Token{
		Address:  contractAddr,
		Name:     name,
		Symbol:   symbol,
		Decimals: decimals,
	}, nil
}

// PackERC20Transfer encodes the ERC-20 `transfer(to, amount)` call data so
// callers (e.g. simulator) can construct a TxRequest without re-deriving
// the ABI binding.
func PackERC20Transfer(to Address, amount Amount) ([]byte, error) {
	data, err := abis.ERC20().Pack("transfer", to.Common(), amount.Wei())
	if err != nil {
		return nil, fmt.Errorf("ethkit: pack erc20 transfer: %w", err)
	}

	return data, nil
}

// TransferToken sends ERC-20 tokens from wallet to recipient using the
// network-suggested gas. For custom gas overrides, see TransferTokenWithGas.
func (c *Client) TransferToken(
	ctx context.Context,
	wallet *Wallet,
	token Token,
	to Address,
	amount Amount,
) (TxReceipt, error) {
	return c.TransferTokenWithGas(ctx, wallet, token, to, amount, nil, nil)
}

// TransferTokenWithGas is the generalized form: nil tip / cap fall back to
// network suggestion, set values force EIP-1559 overrides.
func (c *Client) TransferTokenWithGas(
	ctx context.Context,
	wallet *Wallet,
	token Token,
	to Address,
	amount Amount,
	gasTip *Amount,
	gasCap *Amount,
) (TxReceipt, error) {
	e := newERC20Caller(c, token)

	data, err := e.abi.Pack("transfer", to.Common(), amount.Wei())
	if err != nil {
		return TxReceipt{}, fmt.Errorf("ethkit: pack transfer: %w", err)
	}

	return c.SendTx(ctx, wallet, TxRequest{
		To:     token.Address,
		Data:   data,
		GasTip: gasTip,
		GasCap: gasCap,
		Kind:   "send",
	})
}

// ApproveToken approves spender to transfer up to amount of token on behalf of wallet.
func (c *Client) ApproveToken(
	ctx context.Context,
	wallet *Wallet,
	token Token,
	spender Address,
	amount Amount,
) (TxReceipt, error) {
	e := newERC20Caller(c, token)

	data, err := e.abi.Pack("approve", spender.Common(), amount.Wei())
	if err != nil {
		return TxReceipt{}, fmt.Errorf("ethkit: pack approve: %w", err)
	}

	return c.SendTx(ctx, wallet, TxRequest{To: token.Address, Data: data, Kind: "approve"})
}

// Allowance returns how many token units spender is allowed to spend on behalf of owner.
func (c *Client) Allowance(ctx context.Context, token Token, owner, spender Address) (Amount, error) {
	e := newERC20Caller(c, token)

	result, err := e.call(ctx, "allowance", owner.Common(), spender.Common())
	if err != nil {
		return ZeroAmount, fmt.Errorf("ethkit: allowance: %w", err)
	}

	val, err := decodeUint256(result)
	if err != nil {
		return ZeroAmount, err
	}

	return NewAmountFromWei(val), nil
}
