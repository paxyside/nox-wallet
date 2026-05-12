// Package grpc implements the gRPC transport layer.
// Interfaces are defined here (consumer side) — concrete usecase types are not imported.
package grpc

import (
	"context"
	"fmt"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"github.com/shopspring/decimal"

	"github.com/paxyside/nox-wallet/config/networks"
	pricefeed "github.com/paxyside/nox-wallet/internal/adapter/price"
	contactentity "github.com/paxyside/nox-wallet/internal/domain/contact/entity"
	notificationentity "github.com/paxyside/nox-wallet/internal/domain/notification/entity"
	tokenentity "github.com/paxyside/nox-wallet/internal/domain/token/entity"
	walletentity "github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	contactuc "github.com/paxyside/nox-wallet/internal/usecase/contact"
	historyuc "github.com/paxyside/nox-wallet/internal/usecase/history"
	swapuc "github.com/paxyside/nox-wallet/internal/usecase/swap"
	tokenuc "github.com/paxyside/nox-wallet/internal/usecase/token"
	walletuc "github.com/paxyside/nox-wallet/internal/usecase/wallet"
	watcheruc "github.com/paxyside/nox-wallet/internal/usecase/watcher"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	liblogger "github.com/paxyside/nox-wallet/pkg/logger"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
)

// ── usecase interfaces ────────────────────────────────────────────────────────

type walletUsecase interface {
	GenerateWallet(
		ctx context.Context,
		p walletuc.GenerateWalletParams,
	) (walletuc.GenerateWalletResult, error)
	ImportMnemonic(
		ctx context.Context,
		p walletuc.ImportMnemonicParams,
	) (*walletentity.Wallet, error)
	ImportPrivateKey(
		ctx context.Context,
		p walletuc.ImportPrivateKeyParams,
	) (*walletentity.Wallet, error)
	ImportKeystore(
		ctx context.Context,
		p walletuc.ImportKeystoreParams,
	) (*walletentity.Wallet, error)
	ExportKeystore(p walletuc.ExportKeystoreParams) ([]byte, error)
	RevealSecret(ctx context.Context) (walletuc.RevealSecretResult, error)
	GetWallet(ctx context.Context) (*walletentity.Wallet, error)
	GetBalances(
		ctx context.Context,
		p walletuc.GetBalancesParams,
	) (walletuc.GetBalancesResult, error)
	GetGasFees(ctx context.Context) (walletuc.GetGasFeesResult, error)
	ResolveENS(ctx context.Context, name string) (ethkit.Address, error)
	ReverseENS(ctx context.Context, addr ethkit.Address) (string, error)
	SpeedUpTx(ctx context.Context, hash string) (string, error)
	CancelTx(ctx context.Context, hash string) (string, error)
	SimulateSendETH(
		ctx context.Context,
		to ethkit.Address,
		value ethkit.Amount,
	) (ethkit.SimulationResult, error)
	SimulateSendToken(
		ctx context.Context,
		tokenAddr ethkit.Address,
		to ethkit.Address,
		amount decimal.Decimal,
	) (ethkit.SimulationResult, error)
	SendETH(ctx context.Context, p walletuc.SendETHParams) (ethkit.TxReceipt, error)
	SendToken(ctx context.Context, p walletuc.SendTokenParams) (ethkit.TxReceipt, error)
	ListPending() []ethkit.PendingTx
	LoadedAddress() ethkit.Address
}

type swapUsecase interface {
	Quote(ctx context.Context, p swapuc.QuoteParams) (ethkit.SwapQuote, error)
	Execute(ctx context.Context, p swapuc.ExecuteParams) (ethkit.TxReceipt, error)
	ResolveToken(ctx context.Context, addr string) (ethkit.Token, error)
	GasFees(ctx context.Context) (ethkit.GasInfo, error)
}

type historyUsecase interface {
	GetHistory(
		ctx context.Context,
		p historyuc.GetHistoryParams,
	) (historyuc.GetHistoryResult, error)
	Sync(ctx context.Context, addr ethkit.Address, watchedContracts []ethkit.Address) error
	SyncForce(ctx context.Context, addr ethkit.Address, watchedContracts []ethkit.Address) error
}

type contactUsecase interface {
	Create(ctx context.Context, p contactuc.CreateParams) (*contactentity.Contact, error)
	GetByID(ctx context.Context, id string) (*contactentity.Contact, error)
	Update(ctx context.Context, p contactuc.UpdateParams) (*contactentity.Contact, error)
	SetFavorite(ctx context.Context, id string, favorite bool) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context) ([]*contactentity.Contact, error)
}

type tokenUsecase interface {
	Add(ctx context.Context, p tokenuc.AddTokenParams) (*tokenentity.WatchedToken, error)
	EnsureWatched(ctx context.Context, p tokenuc.AddTokenParams) (*tokenentity.WatchedToken, error)
	Remove(ctx context.Context, id string) error
	Pin(ctx context.Context, id string, pinned bool) error
	Hide(ctx context.Context, id string, hidden bool) error
	ListWithBalances(ctx context.Context, addr ethkit.Address) ([]tokenuc.TokenWithBalance, error)
	List(ctx context.Context) ([]*tokenentity.WatchedToken, error)
	Seed(ctx context.Context, addr ethkit.Address) error
}

type watcherUsecase interface {
	Subscribe() (<-chan watcheruc.WalletEvent, func())
}

type approvalUsecase interface {
	List(ctx context.Context) ([]ethkit.TokenApproval, error)
	Revoke(ctx context.Context, tokenAddress, spender ethkit.Address) (ethkit.TxReceipt, error)
}

type notificationUsecase interface {
	List(ctx context.Context, limit int) ([]*notificationentity.Notification, error)
	MarkRead(ctx context.Context, id string) error
	MarkAllRead(ctx context.Context) error
	ClearAll(ctx context.Context) error
	GetSettings(ctx context.Context) (*notificationentity.Settings, error)
	UpdateSettings(ctx context.Context, s *notificationentity.Settings) error
}

// ── Handler ───────────────────────────────────────────────────────────────────

type Handler struct {
	pb.UnimplementedWalletServiceServer

	l            *liblogger.Logger
	wallet       walletUsecase
	swap         swapUsecase
	history      historyUsecase
	contact      contactUsecase
	token        tokenUsecase
	approval     approvalUsecase
	watcher      watcherUsecase
	notification notificationUsecase
	prices       *pricefeed.Feed
	// chainID + tokenList feed the logo-url stamping path so the
	// handler doesn't have to take a full *networks.Network — the
	// only two pieces it needs are the chain id (for per-chain
	// lookups) and the verified token registry.
	chainID   int64
	tokenList *networks.TokenList
	// nativeLogoURL is the chain's native asset logo URL pulled
	// from the active network config. Stamped on
	// GetBalances.eth_logo_url so the UI doesn't need a hardcoded
	// URL per native asset.
	nativeLogoURL string
}

func New(
	l *liblogger.Logger,
	wallet walletUsecase,
	swap swapUsecase,
	history historyUsecase,
	contact contactUsecase,
	token tokenUsecase,
	approval approvalUsecase,
	watcher watcherUsecase,
	notification notificationUsecase,
	prices *pricefeed.Feed,
	chainID int64,
	tokenList *networks.TokenList,
	nativeLogoURL string,
) *Handler {
	return &Handler{
		l:             l,
		wallet:        wallet,
		swap:          swap,
		history:       history,
		contact:       contact,
		token:         token,
		approval:      approval,
		watcher:       watcher,
		notification:  notification,
		prices:        prices,
		chainID:       chainID,
		tokenList:     tokenList,
		nativeLogoURL: nativeLogoURL,
	}
}

// tokenLogoURL resolves a contract address against the embedded
// verified token list. Empty string when the token isn't verified —
// UI shows a letter avatar in that case.
func (h *Handler) tokenLogoURL(address string) string {
	if h.tokenList == nil || address == "" {
		return ""
	}

	tok, ok := h.tokenList.TokenByAddress(h.chainID, address)
	if !ok {
		return ""
	}

	return tok.LogoURI
}

// HandleError maps domain and app errors to gRPC status codes.
func (h *Handler) HandleError(ctx context.Context, err error) error {
	if err == nil {
		return nil
	}

	switch {
	case liberrors.Is(err, walletentity.ErrNotFound),
		liberrors.Is(err, contactentity.ErrNotFound),
		liberrors.Is(err, tokenentity.ErrNotFound):
		h.l.DebugContext(ctx, "entity not found", "error", err)
		return status.Error(codes.NotFound, "not found")

	case liberrors.Is(err, contactentity.ErrAlreadyExists),
		liberrors.Is(err, tokenentity.ErrAlreadyExists):
		h.l.DebugContext(ctx, "entity already exists", "error", err)
		return status.Error(codes.AlreadyExists, "already exists")
	}

	var appErr *liberrors.Error
	if liberrors.As(err, &appErr) {
		// Internal-class errors are user-visible only as "internal error",
		// but the team needs the full chain in the log to debug. Other
		// classes (NotFound, InvalidArgument, …) are already self-describing
		// for the user — just log them at debug level for traceability.
		if appErr.Code() == liberrors.CodeInternal ||
			appErr.Code() == liberrors.CodeUnknown {
			h.l.ErrorContext(ctx, "handler error",
				"error", err.Error(),
				"error_type", fmt.Sprintf("%T", err),
				"error_chain", liblogger.ErrorChain(err),
			)
		} else {
			h.l.DebugContext(ctx, "handler error",
				"code", appErr.Code(),
				"error", err.Error(),
			)
		}
		return liberrors.ToGRPCError(appErr)
	}

	h.l.ErrorContext(ctx, "internal error",
		"error", err.Error(),
		"error_type", fmt.Sprintf("%T", err),
		"error_chain", liblogger.ErrorChain(err),
	)

	return status.Error(codes.Internal, "internal error")
}
