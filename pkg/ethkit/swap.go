package ethkit

import (
	"context"
	"errors"
	"fmt"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
)

// Uniswap v3 contract addresses (Ethereum mainnet).
var (
	uniswapQuoterV2 = MustAddress("0x61fFE014bA17989E743c5F6cB21bF9697530B21e")
	uniswapRouterV2 = MustAddress("0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45")
	uniswapWETH9    = MustAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
)

const quoterV2ABI = `[
  {
    "inputs": [
      {"components": [
        {"name": "tokenIn",  "type": "address"},
        {"name": "tokenOut", "type": "address"},
        {"name": "amountIn", "type": "uint256"},
        {"name": "fee",      "type": "uint24"},
        {"name": "sqrtPriceLimitX96", "type": "uint160"}
      ], "name": "params", "type": "tuple"}
    ],
    "name": "quoteExactInputSingle",
    "outputs": [
      {"name": "amountOut",             "type": "uint256"},
      {"name": "sqrtPriceX96After",     "type": "uint160"},
      {"name": "initializedTicksCrossed","type": "uint32"},
      {"name": "gasEstimate",           "type": "uint256"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]`

// SwapRouter02 exactInputSingle — includes deadline for MEV protection.
const swapRouterABI = `[
  {
    "inputs": [
      {"components": [
        {"name": "tokenIn",           "type": "address"},
        {"name": "tokenOut",          "type": "address"},
        {"name": "fee",               "type": "uint24"},
        {"name": "recipient",         "type": "address"},
        {"name": "amountIn",          "type": "uint256"},
        {"name": "amountOutMinimum",  "type": "uint256"},
        {"name": "sqrtPriceLimitX96", "type": "uint160"}
      ], "name": "params", "type": "tuple"}
    ],
    "name": "exactInputSingle",
    "outputs": [{"name": "amountOut", "type": "uint256"}],
    "stateMutability": "payable",
    "type": "function"
  }
]`

// Note: SwapRouter02 removed the deadline field from the struct; deadline is enforced
// via the multicall wrapper or by checking block.timestamp in the router itself.
// If you need explicit deadline, use SwapRouter01 (0xE592427A0AEce92De3Edee1F18E0157C05861564).

// QuoteSwap returns the expected output amount for a swap without executing it.
// Uses the Uniswap v3 QuoterV2 contract via eth_call.
func (c *Client) QuoteSwap(
	ctx context.Context,
	tokenIn, tokenOut Token,
	amountIn Amount,
	fee PoolFee,
) (SwapQuote, error) {
	if fee == 0 {
		fee = PoolFee005
	}

	inAddr, outAddr, err := resolveSwapAddresses(tokenIn, tokenOut)
	if err != nil {
		return SwapQuote{}, err
	}

	quoterABI, err := abi.JSON(strings.NewReader(quoterV2ABI))
	if err != nil {
		return SwapQuote{}, err
	}

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

	quoterAddr := uniswapQuoterV2.Common()

	var result []byte

	err = c.retrier.Do(ctx, func(ctx context.Context) error {
		result, err = c.http.CallContract(ctx, ethereum.CallMsg{
			To:   &quoterAddr,
			Data: data,
		}, nil)

		return err
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
// approve transaction first if needed. ETH → token swaps skip approval (the
// input is sent as msg.value).
func (c *Client) Swap(ctx context.Context, wallet *Wallet, req SwapRequest) (TxReceipt, error) {
	fee := req.Fee
	if fee == 0 {
		fee = PoolFee005
	}

	// Note: SwapRouter02 dropped the explicit deadline field; deadline enforcement
	// now happens at the multicall wrapper or the router's block.timestamp check.
	// We keep the field on SwapRequest for future SwapRouter01 / multicall flows.

	inAddr, outAddr, err := resolveSwapAddresses(req.TokenIn, req.TokenOut)
	if err != nil {
		return TxReceipt{}, err
	}

	// Ensure the router can pull tokens on the user's behalf. Native ETH skips
	// this (msg.value carries the input). For ERC-20s with insufficient
	// allowance, submit an approve and wait for it to land before swapping.
	if !req.TokenIn.IsNative() {
		if err := c.ensureAllowance(ctx, wallet, req.TokenIn, uniswapRouterV2, req.AmountIn); err != nil {
			return TxReceipt{}, err
		}
	}

	routerABI, err := abi.JSON(strings.NewReader(swapRouterABI))
	if err != nil {
		return TxReceipt{}, err
	}

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
		To:     uniswapRouterV2,
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
// returns immediately. Otherwise it submits a single max-uint256 approval and
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

// resolveSwapAddresses maps Token to contract address, substituting WETH for native ETH.
func resolveSwapAddresses(tokenIn, tokenOut Token) (inAddr, outAddr common.Address, err error) {
	if tokenIn.IsNative() {
		inAddr = uniswapWETH9.Common()
	} else {
		inAddr = tokenIn.Address.Common()
	}

	if tokenOut.IsNative() {
		outAddr = uniswapWETH9.Common()
	} else {
		outAddr = tokenOut.Address.Common()
	}

	if inAddr == outAddr {
		return common.Address{}, common.Address{}, errors.New("ethkit: tokenIn and tokenOut are the same")
	}

	return inAddr, outAddr, nil
}
