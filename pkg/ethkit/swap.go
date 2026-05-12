package ethkit

import (
	"context"
	"errors"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/common"

	"github.com/paxyside/nox-wallet/pkg/ethkit/abis"
)

// Swap-codepath note: SwapRouter02 dropped the explicit `deadline`
// field from the exactInputSingle struct; deadline is enforced via
// the multicall wrapper or by the router checking block.timestamp
// itself. If you ever need the explicit-deadline form, use
// SwapRouter01 at 0xE592427A0AEce92De3Edee1F18E0157C05861564.

// QuoteSwap returns the expected output amount for a swap without executing it.
// Uses the Uniswap v3 QuoterV2 contract via eth_call.
func (c *Client) QuoteSwap(
	ctx context.Context,
	tokenIn, tokenOut Token,
	amountIn Amount,
	fee PoolFee,
) (SwapQuote, error) {
	if c.network.UniswapQuoterV2 == ZeroAddress {
		return SwapQuote{}, ErrNoNetwork
	}

	if fee == 0 {
		fee = PoolFee005
	}

	inAddr, outAddr, err := c.resolveSwapAddresses(tokenIn, tokenOut)
	if err != nil {
		return SwapQuote{}, err
	}

	quoterABI := abis.UniswapQuoterV2()

	type quoteParams struct {
		TokenIn           common.Address
		TokenOut          common.Address
		AmountIn          *big.Int
		Fee               *big.Int
		SqrtPriceLimitX96 *big.Int
	}

	data, err := quoterABI.Pack("quoteExactInputSingle", quoteParams{
		TokenIn:           inAddr,
		TokenOut:          outAddr,
		AmountIn:          amountIn.Wei(),
		Fee:               big.NewInt(int64(fee)),
		SqrtPriceLimitX96: big.NewInt(0),
	})
	if err != nil {
		return SwapQuote{}, fmt.Errorf("ethkit: pack quote: %w", err)
	}

	quoterAddr := c.network.UniswapQuoterV2.Common()

	var result []byte

	err = c.retrier.Do(ctx, func(ctx context.Context) error {
		var callErr error
		result, callErr = c.http.CallContract(ctx, ethereum.CallMsg{
			To:   &quoterAddr,
			Data: data,
		}, nil)

		return callErr
	})
	if err != nil {
		return SwapQuote{}, fmt.Errorf("ethkit: quote swap call: %w", err)
	}

	type quoteResult struct {
		AmountOut               *big.Int
		SqrtPriceX96After       *big.Int
		InitializedTicksCrossed uint32
		GasEstimate             *big.Int
	}

	var out quoteResult
	if err = quoterABI.UnpackIntoInterface(&out, "quoteExactInputSingle", result); err != nil {
		return SwapQuote{}, fmt.Errorf("ethkit: unpack quote: %w", err)
	}

	gasEst := uint64(0)
	if out.GasEstimate != nil {
		gasEst = out.GasEstimate.Uint64()
	}

	return SwapQuote{
		TokenIn:     tokenIn,
		TokenOut:    tokenOut,
		AmountIn:    amountIn,
		AmountOut:   NewAmountFromWei(out.AmountOut),
		Fee:         fee,
		GasEstimate: gasEst,
	}, nil
}

// Swap executes an exact-input single-hop swap via Uniswap v3 SwapRouter02.
// req.MinAmountOut is the slippage floor — the transaction reverts if output < MinAmountOut.
//
// For ERC-20 inputs, ensures the router has sufficient allowance and submits an
// approval transaction first if needed. ETH → token swaps skip approval (the
// input is sent as msg.value).
func (c *Client) Swap(ctx context.Context, wallet *Wallet, req SwapRequest) (TxReceipt, error) {
	if c.network.UniswapSwapRouter02 == ZeroAddress {
		return TxReceipt{}, ErrNoNetwork
	}

	fee := req.Fee
	if fee == 0 {
		fee = PoolFee005
	}

	inAddr, outAddr, err := c.resolveSwapAddresses(req.TokenIn, req.TokenOut)
	if err != nil {
		return TxReceipt{}, err
	}

	router := c.network.UniswapSwapRouter02

	// Ensure the router can pull tokens on the user's behalf. Native ETH skips
	// this (msg.value carries the input). For ERC-20s with insufficient
	// allowance, submit an approval and wait for it to land before swapping.
	if !req.TokenIn.IsNative() {
		if err := c.ensureAllowance(ctx, wallet, req.TokenIn, router, req.AmountIn); err != nil {
			return TxReceipt{}, err
		}
	}

	routerABI := abis.UniswapSwapRouter02()

	type exactInputParams struct {
		TokenIn           common.Address
		TokenOut          common.Address
		Fee               *big.Int
		Recipient         common.Address
		AmountIn          *big.Int
		AmountOutMinimum  *big.Int
		SqrtPriceLimitX96 *big.Int
	}

	data, err := routerABI.Pack("exactInputSingle", exactInputParams{
		TokenIn:           inAddr,
		TokenOut:          outAddr,
		Fee:               big.NewInt(int64(fee)),
		Recipient:         wallet.Address().Common(),
		AmountIn:          req.AmountIn.Wei(),
		AmountOutMinimum:  req.MinAmountOut.Wei(),
		SqrtPriceLimitX96: big.NewInt(0),
	})
	if err != nil {
		return TxReceipt{}, fmt.Errorf("ethkit: pack swap: %w", err)
	}

	// When swapping native ETH → token, attach ETH as msg.value.
	txValue := ZeroAmount
	if req.TokenIn.IsNative() {
		txValue = req.AmountIn
	}

	return c.SendTx(ctx, wallet, TxRequest{
		To:     router,
		Value:  txValue,
		Data:   data,
		GasTip: req.GasTip,
		GasCap: req.GasCap,
		Kind:   "swap",
	})
}

// SlippageAmount returns amountOut reduced by slippageBps basis points.
// Example: SlippageAmount(quote.AmountOut, 50) → 0.5% slippage floor.
func SlippageAmount(amount Amount, slippageBps uint64) Amount {
	// floor = amount * (10000 - bps) / 10000
	numerator := new(big.Int).Mul(amount.Wei(), big.NewInt(int64(10000-slippageBps)))
	floor := new(big.Int).Div(numerator, big.NewInt(10000))

	return NewAmountFromWei(floor)
}

// maxUint256 is 2^256 - 1, the standard "unlimited" allowance value used by
// every major DEX/wallet UI (Uniswap, MetaMask, 1inch).
var maxUint256 = func() *big.Int {
	v := new(big.Int).Lsh(big.NewInt(1), 256)
	return new(big.Int).Sub(v, big.NewInt(1))
}()

// ensureAllowance makes sure `spender` can pull at least `amount` of `token`
// from the user's wallet. If the current allowance is already sufficient, it
// returns immediately. Otherwise, it submits a single max-uint256 approval and
// blocks until that approve is mined.
//
// Unlimited allowance mirrors the standard DEX UX: one approve per (token,
// spender) pair forever. Subsequent swaps of the same token are a single tx.
// The router (Uniswap V3 SwapRouter02) is an audited official contract — the
// trust trade-off is the industry default for this class of app.
func (c *Client) ensureAllowance(
	ctx context.Context,
	wallet *Wallet,
	token Token,
	spender Address,
	amount Amount,
) error {
	current, err := c.Allowance(ctx, token, wallet.Address(), spender)
	if err != nil {
		return fmt.Errorf("ethkit: check allowance: %w", err)
	}

	if current.Wei().Cmp(amount.Wei()) >= 0 {
		return nil
	}

	c.log.Info("ethkit: approving token for swap",
		"token", token.Symbol,
		"spender", spender.Hex(),
	)

	receipt, err := c.ApproveToken(ctx, wallet, token, spender, NewAmountFromWei(maxUint256))
	if err != nil {
		return fmt.Errorf("ethkit: approve token: %w", err)
	}

	if receipt.Status != TxStatusSuccess {
		return fmt.Errorf("ethkit: approve reverted (tx %s)", receipt.Hash)
	}

	c.log.Info("ethkit: approval mined", "tx", receipt.Hash)

	return nil
}

// resolveSwapAddresses maps Token to contract address, substituting the
// chain's wrapped-native (e.g. WETH on mainnet) for the native asset.
func (c *Client) resolveSwapAddresses(tokenIn, tokenOut Token) (inAddr, outAddr common.Address, err error) {
	wrappedNative := c.network.UniswapWrappedETH.Common()

	if tokenIn.IsNative() {
		inAddr = wrappedNative
	} else {
		inAddr = tokenIn.Address.Common()
	}

	if tokenOut.IsNative() {
		outAddr = wrappedNative
	} else {
		outAddr = tokenOut.Address.Common()
	}

	if inAddr == outAddr {
		return common.Address{}, common.Address{}, errors.New("ethkit: tokenIn and tokenOut are the same")
	}

	return inAddr, outAddr, nil
}
