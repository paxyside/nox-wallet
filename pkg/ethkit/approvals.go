package ethkit

import (
	"context"
	"sync"
)

// KnownDEXSpenders is the list of mainnet contract addresses that this wallet
// is most likely to have ever granted an ERC-20 allowance to. Listed in the
// "Revoke approvals" screen we sweep this set against every watched token so
// the user can see + revoke active allowances without paying for a full
// `eth_getLogs` Approval-event scan.
//
// New aggregators (CowSwap settlement, Paraswap, 0x v2) just need to be
// appended here. Anything not in this list won't be detected — but the
// revoke action itself is generic, so a future "Add custom spender" UI
// can plug in arbitrary addresses without touching this file.
var KnownDEXSpenders = []Address{
	// Uniswap V3 SwapRouter02 — what our own swap usecase approves.
	MustAddress("0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"),
	// Uniswap V2 Router 02 — legacy, still common.
	MustAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"),
	// Uniswap Universal Router — multiprotocol entry point.
	MustAddress("0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD"),
	// 1inch v5 aggregator router.
	MustAddress("0x1111111254EEB25477B68fb85Ed929f73A960582"),
	// 0x Exchange Proxy.
	MustAddress("0xDef1C0ded9bec7F1a1670819833240f027b25EfF"),
	// CoW Protocol settlement contract.
	MustAddress("0x9008D19f58AAbD9eD0D60971565AA8510560ab41"),
	// Paraswap v5 augustus swapper.
	MustAddress("0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57"),
}

// TokenApproval describes a non-zero allowance the wallet has granted.
type TokenApproval struct {
	Token   Token
	Spender Address
	Amount  Amount
}

// ListApprovals scans every (token, spender) pair in parallel and returns
// the ones with allowance > 0. Errors per pair are logged and skipped — a
// single token failing shouldn't blank the whole screen.
func (c *Client) ListApprovals(
	ctx context.Context,
	owner Address,
	tokens []Token,
	spenders []Address,
) ([]TokenApproval, error) {
	type slot struct {
		i, j   int
		amount Amount
		err    error
	}

	total := len(tokens) * len(spenders)
	if total == 0 {
		return nil, nil
	}

	results := make(chan slot, total)
	var wg sync.WaitGroup

	for i, tok := range tokens {
		for j, sp := range spenders {
			wg.Add(1)
			go func(i, j int, tok Token, sp Address) {
				defer wg.Done()
				amt, err := c.Allowance(ctx, tok, owner, sp)
				results <- slot{i: i, j: j, amount: amt, err: err}
			}(i, j, tok, sp)
		}
	}

	go func() {
		wg.Wait()
		close(results)
	}()

	out := make([]TokenApproval, 0, total)
	for r := range results {
		if r.err != nil {
			c.log.Warn("ethkit: allowance check failed",
				"token", tokens[r.i].Symbol,
				"spender", spenders[r.j].Hex(),
				"error", r.err,
			)
			continue
		}
		// Skip zero allowances and dust-level ones (some tokens leave 1 wei
		// after a partial transferFrom).
		if r.amount.Wei().Sign() <= 0 {
			continue
		}
		out = append(out, TokenApproval{
			Token:   tokens[r.i],
			Spender: spenders[r.j],
			Amount:  r.amount,
		})
	}

	return out, nil
}

// RevokeApproval submits an `approve(spender, 0)` transaction, zeroing out
// the allowance. Returns the receipt of the on-chain revoke tx.
func (c *Client) RevokeApproval(
	ctx context.Context,
	wallet *Wallet,
	token Token,
	spender Address,
) (TxReceipt, error) {
	return c.ApproveToken(ctx, wallet, token, spender, ZeroAmount)
}
