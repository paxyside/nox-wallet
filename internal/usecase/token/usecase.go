package token

import (
	"context"
	"strings"
	"sync"

	"github.com/paxyside/nox-wallet/internal/adapter/price"
	"github.com/paxyside/nox-wallet/internal/domain/token/entity"
	tokenservice "github.com/paxyside/nox-wallet/internal/domain/token/service"
	"github.com/paxyside/nox-wallet/internal/usecase"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

type EthClient interface {
	TokenMetadata(ctx context.Context, addr ethkit.Address) (ethkit.Token, error)
	TokenBalance(ctx context.Context, addr ethkit.Address, token ethkit.Token) (ethkit.Amount, error)
	DiscoverTokens(ctx context.Context, addr ethkit.Address) ([]ethkit.Token, error)
}

type TokenService interface {
	Create(ctx context.Context, t *entity.WatchedToken) error
	GetByID(ctx context.Context, id string) (*entity.WatchedToken, error)
	SetPinned(ctx context.Context, id string, pinned bool) error
	SetHidden(ctx context.Context, id string, hidden bool) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context) ([]*entity.WatchedToken, error)
}

var _ TokenService = (*tokenservice.Service)(nil)

type Usecase struct {
	*usecase.BaseUsecase
	log   logger.Log
	eth   EthClient
	svc   TokenService
	price *price.Feed
}

func New(base *usecase.BaseUsecase, log logger.Log, eth EthClient, svc TokenService, priceFeed *price.Feed) *Usecase {
	return &Usecase{BaseUsecase: base, log: log, eth: eth, svc: svc, price: priceFeed}
}

func (u *Usecase) Add(ctx context.Context, p AddTokenParams) (*entity.WatchedToken, error) {
	tok := ethkit.Token{
		Address:  p.ContractAddress,
		Symbol:   p.Symbol,
		Name:     p.Name,
		Decimals: p.Decimals,
	}

	if tok.Symbol == "" || tok.Name == "" || tok.Decimals == 0 {
		meta, err := u.eth.TokenMetadata(ctx, p.ContractAddress)
		if err != nil {
			return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "fetch token metadata")
		}

		if tok.Symbol == "" {
			tok.Symbol = meta.Symbol
		}

		if tok.Name == "" {
			tok.Name = meta.Name
		}

		if tok.Decimals == 0 {
			tok.Decimals = meta.Decimals
		}
	}

	wt := &entity.WatchedToken{
		ID:      u.ULID(),
		Token:   tok,
		AddedAt: u.NowUTC(),
	}
	if err := u.svc.Create(ctx, wt); err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "add token")
	}

	return wt, nil
}

// EnsureWatched is the idempotent companion to [Add]. If a token with
// the same contract address is already on the watchlist, it returns
// the existing entry without touching the row (preserves user-set
// flags like is_pinned / is_hidden). Otherwise it adds the token via
// the same flow as Add — including on-chain metadata enrichment when
// the caller passes only the address.
//
// Used by post-swap and post-send flows to guarantee both ends of a
// transaction are tracked, so the history sync's `watchedContracts`
// filter doesn't accidentally drop legs of user-initiated swaps. See
// the bug discussion in the Sept review: a USDT round-trip swap (USDC
// → USDT → USDC) would otherwise leave USDT untracked once the
// balance returned to zero, causing the history page to show two
// "Sent USDC" / "Received USDC" rows instead of two merged Swap rows.
func (u *Usecase) EnsureWatched(ctx context.Context, p AddTokenParams) (*entity.WatchedToken, error) {
	existing, err := u.svc.List(ctx)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list watched tokens")
	}

	addrHex := strings.ToLower(p.ContractAddress.Hex())
	for _, w := range existing {
		if strings.ToLower(w.Token.Address.Hex()) == addrHex {
			return w, nil
		}
	}

	return u.Add(ctx, p)
}

func (u *Usecase) Remove(ctx context.Context, id string) error {
	return u.svc.Delete(ctx, id)
}

func (u *Usecase) Pin(ctx context.Context, id string, pinned bool) error {
	return u.svc.SetPinned(ctx, id, pinned)
}

// Hide flips the hidden flag on a watched token. Hidden tokens stay in the DB
// (so the auto-seed dedup map still recognises them and doesn't re-add them
// on every history sync) but are filtered out from user-visible lists.
func (u *Usecase) Hide(ctx context.Context, id string, hidden bool) error {
	return u.svc.SetHidden(ctx, id, hidden)
}

func (u *Usecase) ListWithBalances(ctx context.Context, addr ethkit.Address) ([]TokenWithBalance, error) {
	all, err := u.svc.List(ctx)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list tokens")
	}

	// Filter hidden — they remain in storage for dedup but the UI never
	// sees them. A future "Show hidden" toggle can use Service.List directly.
	tokens := make([]*entity.WatchedToken, 0, len(all))
	for _, t := range all {
		if !t.IsHidden {
			tokens = append(tokens, t)
		}
	}

	// ── Fetch balances concurrently ──────────────────────────────────────────
	type balResult struct {
		idx int
		bal ethkit.Amount
	}

	balCh := make(chan balResult, len(tokens))
	for i, wt := range tokens {
		go func(idx int, wt *entity.WatchedToken) {
			bal, err := u.eth.TokenBalance(ctx, addr, wt.Token)
			if err != nil {
				u.log.WarnContext(ctx, "token balance fetch failed",
					"token", wt.Token.Symbol, "error", err)

				bal = ethkit.ZeroAmount
			}

			balCh <- balResult{idx, bal}
		}(i, wt)
	}

	balances := make([]ethkit.Amount, len(tokens))
	for range tokens {
		r := <-balCh
		balances[r.idx] = r.bal
	}

	// ── Fetch market prices (batch call) ─────────────────────────────────────
	addrs := make([]string, len(tokens))
	for i, wt := range tokens {
		addrs[i] = strings.ToLower(wt.Token.Address.Hex())
	}

	tokenPrices := u.price.GetTokenPrices(ctx, addrs)

	// ── Fetch sparklines concurrently (7d + 30d, goroutine per token, cached) ─
	sparklines7d := make([][]float64, len(tokens))
	sparklines30d := make([][]float64, len(tokens))

	var wg sync.WaitGroup
	for i, wt := range tokens {
		wg.Add(2)

		go func(idx int, wt *entity.WatchedToken) {
			defer wg.Done()

			sparklines7d[idx] = u.price.GetSparkline(ctx, wt.Token.Address.Hex(), 7)
		}(i, wt)
		go func(idx int, wt *entity.WatchedToken) {
			defer wg.Done()

			sparklines30d[idx] = u.price.GetSparkline(ctx, wt.Token.Address.Hex(), 30)
		}(i, wt)
	}

	wg.Wait()

	// ── Assemble result ───────────────────────────────────────────────────────
	result := make([]TokenWithBalance, 0, len(tokens))
	for i, wt := range tokens {
		bal := balances[i]
		md := tokenPrices[strings.ToLower(wt.Token.Address.Hex())]

		twb := TokenWithBalance{
			ID:           wt.ID,
			Token:        wt.Token,
			Balance:      bal,
			IsPinned:     wt.IsPinned,
			IsHidden:     wt.IsHidden,
			Sparkline7d:  sparklines7d[i],
			Sparkline30d: sparklines30d[i],
		}
		if md != nil {
			balFloat := bal.ToTokenUnits(wt.Token.Decimals).InexactFloat64()
			twb.PriceUSD = md.PriceUSD
			twb.Change24hPct = md.Change24hPct
			twb.ChangePositive = md.ChangePositive
			twb.BalanceUSD = balFloat * md.PriceUSD
		}

		// CoinGecko's free `simple/token_price` endpoint frequently omits the
		// `usd_24h_change` field for newer/long-tail tokens (and occasionally
		// drops it under rate-limit). Fall back to deriving the 24h change
		// from the 7-day hourly sparkline: compare the latest point with the
		// point ~24h prior.
		if twb.Change24hPct == 0 && len(twb.Sparkline7d) >= 25 {
			latest := twb.Sparkline7d[len(twb.Sparkline7d)-1]
			prior := twb.Sparkline7d[len(twb.Sparkline7d)-25] // 24h ago (hourly)
			if prior > 0 {
				twb.Change24hPct = (latest - prior) / prior * 100
				twb.ChangePositive = twb.Change24hPct >= 0
			}
		}

		result = append(result, twb)
	}

	return result, nil
}

func (u *Usecase) List(ctx context.Context) ([]*entity.WatchedToken, error) {
	return u.svc.List(ctx)
}

// ListEthTokens flattens the watchlist into the ethkit.Token form needed by
// chain-level usecases (e.g. Revoke approvals scans every (token, spender)
// pair). Hidden tokens are still included — the user may want to see / revoke
// allowances on a token they hid because it looked spammy.
func (u *Usecase) ListEthTokens(ctx context.Context) ([]ethkit.Token, error) {
	wts, err := u.svc.List(ctx)
	if err != nil {
		return nil, liberrors.Wrapf(err, liberrors.CodeInternal, "list tokens")
	}

	out := make([]ethkit.Token, 0, len(wts))
	for _, wt := range wts {
		out = append(out, wt.Token)
	}

	return out, nil
}

// autoSeedSymbols is the set of well-known ERC-20 symbols that Seed will auto-add.
// Tokens outside this list are skipped to avoid polluting the watchlist with
// spam/airdrop contracts. Users can always add any token manually via the UI.
var autoSeedSymbols = map[string]struct{}{
	// Stablecoins
	"USDC": {}, "USDT": {}, "DAI": {}, "FRAX": {}, "TUSD": {}, "BUSD": {}, "LUSD": {}, "SUSD": {},
	// Wrapped / liquid staking
	"WETH": {}, "WBTC": {}, "STETH": {}, "WSTETH": {}, "CBETH": {}, "RETH": {},
	// Major DeFi
	"UNI": {}, "AAVE": {}, "MKR": {}, "COMP": {}, "CRV": {}, "CVX": {}, "BAL": {},
	"SNX": {}, "LDO": {}, "FXS": {}, "RPL": {}, "1INCH": {},
	// Layer-2 / infrastructure
	"MATIC": {}, "ARB": {}, "OP": {},
	// Other well-known
	"LINK": {}, "SHIB": {}, "PEPE": {}, "APE": {},
}

// Seed discovers ERC-20 tokens with non-zero balance for addr via Alchemy and adds any
// tokens that are not yet on the watchlist. Only tokens in autoSeedSymbols are eligible —
// this prevents spam/airdrop contracts from polluting the list automatically.
func (u *Usecase) Seed(ctx context.Context, addr ethkit.Address) error {
	// Defence in depth: skip silently when no wallet is loaded. Multiple
	// callers (GetBalances(WithTokens), kickoffWalletSeed, ListTokensWith
	// Balances on cold start) read LoadedAddress() and wire it through —
	// during onboarding that address is zero, and Alchemy happily returns
	// random spam tokens for the zero address, polluting logs with "seed:
	// skipping unknown token" entries.
	if addr.IsZero() {
		return nil
	}

	discovered, err := u.eth.DiscoverTokens(ctx, addr)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "discover tokens")
	}

	existing, err := u.svc.List(ctx)
	if err != nil {
		return liberrors.Wrapf(err, liberrors.CodeInternal, "list watched tokens")
	}

	// Build a set of already-watched contract addresses.
	watched := make(map[string]struct{}, len(existing))
	for _, wt := range existing {
		watched[wt.Token.Address.Hex()] = struct{}{}
	}

	for _, tok := range discovered {
		// Skip tokens not in the known-symbol whitelist.
		sym := strings.ToUpper(tok.Symbol)
		if _, known := autoSeedSymbols[sym]; !known {
			u.log.DebugContext(ctx, "seed: skipping unknown token", "symbol", tok.Symbol)
			continue
		}

		if _, already := watched[tok.Address.Hex()]; already {
			continue
		}

		wt := &entity.WatchedToken{
			ID:      u.ULID(),
			Token:   tok,
			AddedAt: u.NowUTC(),
		}
		if err := u.svc.Create(ctx, wt); err != nil {
			u.log.WarnContext(ctx, "seed: add token failed",
				"symbol", tok.Symbol, "error", err)
			continue
		}

		u.log.InfoContext(ctx, "seed: discovered new token",
			"symbol", tok.Symbol, "address", tok.Address.Hex())
	}

	return nil
}
