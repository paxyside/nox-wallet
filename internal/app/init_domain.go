package app

import (
	"context"
	"fmt"

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

	feed := pricefeed.New(pricefeed.Config{
		TTL:    pricefeed.DefaultTTL,
		APIKey: a.cfg.Pricefeed.CoinGeckoKey,
		Plan:   a.cfg.Pricefeed.CoinGeckoPlan,
	})

	walletUC := walletuc.New(base, a.l, a.adapter, walletDomainSvc, a.keychain)
	swapUC := swapuc.New(base, a.l, a.adapter, walletUC)
	historyUC := historyuc.New(base, a.l, a.adapter, a.adapter, txDomainSvc)
	contactUC := contactuc.New(base, a.l, contactDomainSvc)
	tokenUC := tokenuc.New(base, a.l, a.adapter, tokenDomainSvc, feed)
	approvalUC := approvaluc.New(a.l, a.adapter, walletUC, tokenUC)
	notificationUC := notificationuc.New(base, a.l, notificationStore)
	// One-shot retention sweep so quiet wallets don't accumulate stale
	// rows even when no new events trigger the per-Save prune. Best-
	// effort — failures are logged inside SweepOnStartup.
	notificationUC.SweepOnStartup(ctx)
	// Adapt the notification usecase to the watcher's NotificationSink
	// interface (its Save takes uint8 to dodge an import cycle).
	watcherUC := watcheruc.New(a.l, a.adapter, walletUC, notificationSink{uc: notificationUC})

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
