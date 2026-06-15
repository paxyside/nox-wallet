package app

import (
	"context"
	"fmt"

	"github.com/paxyside/nox-wallet/config/networks"
	pricefeed "github.com/paxyside/nox-wallet/internal/adapter/price"
	contactsvc "github.com/paxyside/nox-wallet/internal/domain/contact/service"
	contactsqlite "github.com/paxyside/nox-wallet/internal/domain/contact/storage/sqlite"
	notificationsqlite "github.com/paxyside/nox-wallet/internal/domain/notification/storage/sqlite"
	tokensvc "github.com/paxyside/nox-wallet/internal/domain/token/service"
	tokensqlite "github.com/paxyside/nox-wallet/internal/domain/token/storage/sqlite"
	txsvc "github.com/paxyside/nox-wallet/internal/domain/transaction/service"
	txsqlite "github.com/paxyside/nox-wallet/internal/domain/transaction/storage/sqlite"
	walletsvc "github.com/paxyside/nox-wallet/internal/domain/wallet/service"
	walletsqlite "github.com/paxyside/nox-wallet/internal/domain/wallet/storage/sqlite"
	"github.com/paxyside/nox-wallet/internal/usecase"
	approvaluc "github.com/paxyside/nox-wallet/internal/usecase/approval"
	contactuc "github.com/paxyside/nox-wallet/internal/usecase/contact"
	historyuc "github.com/paxyside/nox-wallet/internal/usecase/history"
	notificationuc "github.com/paxyside/nox-wallet/internal/usecase/notification"
	swapuc "github.com/paxyside/nox-wallet/internal/usecase/swap"
	tokenuc "github.com/paxyside/nox-wallet/internal/usecase/token"
	walletuc "github.com/paxyside/nox-wallet/internal/usecase/wallet"
	watcheruc "github.com/paxyside/nox-wallet/internal/usecase/watcher"
	"github.com/paxyside/nox-wallet/pkg/common/idx"
	"github.com/paxyside/nox-wallet/pkg/common/timex"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

type services struct {
	wallet       *walletuc.Usecase
	swap         *swapuc.Usecase
	history      *historyuc.Usecase
	contact      *contactuc.Usecase
	token        *tokenuc.Usecase
	approval     *approvaluc.Usecase
	watcher      *watcheruc.Usecase
	notification *notificationuc.Usecase
	priceFeed    *pricefeed.Feed
}

func (a *App) initServices(ctx context.Context) (*services, error) {
	idGen := idx.New()
	clock := timex.NewClock()
	base := usecase.NewBaseUsecase(idGen, clock)

	// ── storages ──────────────────────────────────────────────────────────────

	contactStore := contactsqlite.New(a.sqlite)
	tokenStore := tokensqlite.New(a.sqlite)
	txStore := txsqlite.New(a.sqlite)
	walletStore := walletsqlite.New(a.sqlite)
	notificationStore := notificationsqlite.New(a.sqlite)

	// ── domain services ───────────────────────────────────────────────────────

	contactDomainSvc := contactsvc.New(contactStore)
	tokenDomainSvc := tokensvc.New(tokenStore)
	txDomainSvc := txsvc.New(txStore)
	walletDomainSvc := walletsvc.New(walletStore)

	// ── usecases ──────────────────────────────────────────────────────────────

	// Symbol→CoinGecko-id map carries only the chain's native asset
	// (e.g. ETH → "ethereum"). ERC-20s are priced through the
	// contract-address endpoint inside GetPricesForTokens, which
	// works for any token without a hardcoded list.
	nativeSymbolID := map[string]string{}
	if a.network.Native.CoinGeckoID != "" {
		nativeSymbolID[a.network.Native.Symbol] = a.network.Native.CoinGeckoID
	}

	feed := pricefeed.New(pricefeed.Config{
		TTL:        pricefeed.DefaultTTL,
		APIKey:     a.cfg.Pricefeed.CoinGeckoKey,
		Plan:       a.cfg.Pricefeed.CoinGeckoPlan,
		SymbolToID: nativeSymbolID,
	})

	walletUC := walletuc.New(base, a.l, a.adapter, walletDomainSvc, a.keychain)
	swapUC := swapuc.New(base, a.l, a.adapter, walletUC)
	historyUC := historyuc.New(base, a.l, a.adapter, a.adapter, txDomainSvc,
		historyuc.WithVerifiedToken(verifiedTokenPredicate(a.tokenList, a.network.ChainID)),
	)
	contactUC := contactuc.New(base, a.l, contactDomainSvc)
	tokenUC := tokenuc.New(base, a.l, a.adapter, tokenDomainSvc, feed)
	approvalUC := approvaluc.New(a.l, a.adapter, walletUC, tokenUC)
	notificationUC := notificationuc.New(base, a.l, notificationStore)
	// One-shot retention sweep so quiet wallets don't accumulate stale
	// rows even when no new events trigger the per-Save prune. Best-effort — failures are logged inside SweepOnStartup.
	notificationUC.SweepOnStartup(ctx)
	// Adapt the notification usecase to the watcher's NotificationSink
	// interface (its Save takes uint8 to dodge an import cycle).
	// `WithTokenLookup` wires the verified token registry (Uniswap
	// Default List) so the watcher resolves well-known tokens
	// locally instead of hitting `eth_call` for every transfer of
	// USDC, USDT, …
	watcherUC := watcheruc.New(
		a.l, a.adapter, walletUC, notificationSink{uc: notificationUC},
		watcheruc.WithTokenLookup(tokenListLookup(a.tokenList, a.network.ChainID)),
	)

	// Restore wallet from keychain if previously imported.
	if err := walletUC.LoadFromKeychain(ctx); err != nil {
		return nil, fmt.Errorf("load wallet from keychain: %w", err)
	}

	a.l.Info("services initialized")

	return &services{
		wallet:       walletUC,
		swap:         swapUC,
		history:      historyUC,
		contact:      contactUC,
		token:        tokenUC,
		approval:     approvalUC,
		watcher:      watcherUC,
		notification: notificationUC,
		priceFeed:    feed,
	}, nil
}

// notificationSink bridges the notification usecase (which takes a
// plain uint8 to avoid importing the watcher package) to the watcher's
// strongly-typed NotificationSink interface. Lives here in the wiring
// layer where both packages are already imported.
type notificationSink struct {
	uc *notificationuc.Usecase
}

func (s notificationSink) Save(
	ctx context.Context,
	kind watcheruc.EventKind,
	txHash string,
	payload []byte,
	isOurs bool,
) (string, error) {
	id, err := s.uc.Save(ctx, uint8(kind), txHash, payload, isOurs)
	if err != nil {
		return "", fmt.Errorf("notification sink save: %w", err)
	}

	return id, nil
}

// verifiedTokenPredicate adapts the TokenList registry to the history
// usecase's VerifiedToken signature — a simple "is this contract in
// the verified list for our chain?" boolean used to drop
// address-poisoning spam before it's cached.
func verifiedTokenPredicate(tl *networks.TokenList, chainID int64) historyuc.VerifiedToken {
	return func(contractLower string) bool {
		_, ok := tl.TokenByAddress(chainID, contractLower)
		return ok
	}
}

// tokenListLookup adapts the verified TokenList registry to the
// watcher's TokenLookup signature. ChainID is captured at wiring
// time so the lookup can't accidentally resolve a Polygon USDC entry
// against a mainnet contract address.
func tokenListLookup(tl *networks.TokenList, chainID int64) watcheruc.TokenLookup {
	return func(addressLower string) (ethkit.Token, bool) {
		tok, ok := tl.TokenByAddress(chainID, addressLower)
		if !ok {
			return ethkit.Token{}, false
		}

		return ethkit.Token{
			Address:  ethkit.MustAddress(tok.Address),
			Symbol:   tok.Symbol,
			Name:     tok.Name,
			Decimals: tok.Decimals,
		}, true
	}
}
