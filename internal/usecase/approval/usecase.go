// Package approval implements the "Revoke approvals" feature: list active
// ERC-20 allowances the wallet has granted to known DEX routers, and let the
// user zero them out.
package approval

import (
	"context"
	"sync"

	walletuc "github.com/paxyside/nox-wallet/internal/usecase/wallet"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

// EthClient is the subset of ethkit.Client this usecase touches.
type EthClient interface {
	ListApprovals(
		ctx context.Context,
		owner ethkit.Address,
		tokens []ethkit.Token,
		spenders []ethkit.Address,
	) ([]ethkit.TokenApproval, error)
	RevokeApproval(
		ctx context.Context,
		wallet *ethkit.Wallet,
		token ethkit.Token,
		spender ethkit.Address,
	) (ethkit.TxReceipt, error)
	TokenLogoURL(ctx context.Context, addr ethkit.Address) (string, error)
}

// Entry is an approval row enriched with metadata that doesn't live in
// the on-chain allowance call (logo URL via Alchemy). Returned by List.
type Entry struct {
	ethkit.TokenApproval
	LogoURL string
}

// WalletProvider exposes the currently-loaded wallet.
type WalletProvider interface {
	EthWallet() *ethkit.Wallet
	LoadedAddress() ethkit.Address
}

var _ WalletProvider = (*walletuc.Usecase)(nil)

// TokenLister returns the user's watched ERC-20 tokens (used as the
// candidate set we sweep allowances against).
type TokenLister interface {
	ListEthTokens(ctx context.Context) ([]ethkit.Token, error)
}

type Usecase struct {
	log    logger.Log
	eth    EthClient
	wallet WalletProvider
	tokens TokenLister
}

func New(log logger.Log, eth EthClient, wallet WalletProvider, tokens TokenLister) *Usecase {
	return &Usecase{log: log, eth: eth, wallet: wallet, tokens: tokens}
}

// List sweeps every (watchedToken, knownSpender) pair against the on-chain
// allowance and returns the non-zero results, enriched with Alchemy logo
// URLs (one parallel fetch per unique token contract — cheap).
func (u *Usecase) List(ctx context.Context) ([]Entry, error) {
	addr := u.wallet.LoadedAddress()
	if addr.IsZero() {
		return nil, liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}

	tokens, err := u.tokens.ListEthTokens(ctx)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list tokens for approval scan")
	}

	if len(tokens) == 0 {
		return nil, nil
	}

	res, err := u.eth.ListApprovals(ctx, addr, tokens, ethkit.KnownDEXSpenders)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list approvals")
	}

	return u.enrichWithLogos(ctx, res), nil
}

// enrichWithLogos resolves an Alchemy logo URL per unique token contract
// and folds it into Entry rows. Logo fetches are best-effort: failures get
// logged and the entry stays with LogoURL="".
func (u *Usecase) enrichWithLogos(
	ctx context.Context,
	approvals []ethkit.TokenApproval,
) []Entry {
	logos := make(map[string]string, len(approvals))

	var (
		mu sync.Mutex
		wg sync.WaitGroup
	)

	seen := make(map[string]bool, len(approvals))
	for _, a := range approvals {
		key := a.Token.Address.Hex()
		if seen[key] {
			continue
		}
		seen[key] = true

		wg.Add(1)

		go func(addr ethkit.Address) {
			defer wg.Done()

			logo, err := u.eth.TokenLogoURL(ctx, addr)
			if err != nil {
				u.log.Warn("approval: token logo fetch failed",
					"contract", addr.Hex(), "error", err)

				return
			}

			mu.Lock()
			logos[addr.Hex()] = logo
			mu.Unlock()
		}(a.Token.Address)
	}

	wg.Wait()

	out := make([]Entry, 0, len(approvals))
	for _, a := range approvals {
		out = append(out, Entry{
			TokenApproval: a,
			LogoURL:       logos[a.Token.Address.Hex()],
		})
	}

	return out
}

// Revoke submits `approve(spender, 0)` for the given token.
func (u *Usecase) Revoke(
	ctx context.Context,
	tokenAddress ethkit.Address,
	spender ethkit.Address,
) (ethkit.TxReceipt, error) {
	w := u.wallet.EthWallet()
	if w == nil {
		return ethkit.TxReceipt{}, liberrors.New(liberrors.CodeFailedPrecondition, "no wallet loaded")
	}

	tokens, err := u.tokens.ListEthTokens(ctx)
	if err != nil {
		return ethkit.TxReceipt{}, liberrors.Wrapf(err, liberrors.CodeInternal, "list tokens")
	}

	var token ethkit.Token
	for _, t := range tokens {
		if t.Address.Hex() == tokenAddress.Hex() {
			token = t
			break
		}
	}
	if token.Address.IsZero() {
		return ethkit.TxReceipt{}, liberrors.Newf(liberrors.CodeNotFound,
			"token %s not in watchlist", tokenAddress.Hex())
	}

	receipt, err := u.eth.RevokeApproval(ctx, w, token, spender)
	if err != nil {
		return ethkit.TxReceipt{}, liberrors.Wrapf(err, liberrors.CodeInternal, "revoke approval")
	}

	return receipt, nil
}
