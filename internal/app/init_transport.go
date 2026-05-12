package app

import (
	"context"
	"fmt"

	"github.com/paxyside/nox-wallet/internal/app/runners/grpcserver"
	grpchandler "github.com/paxyside/nox-wallet/internal/handler/grpc"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
)

func (a *App) initGRPCServer(svc *services) {
	if !a.cfg.GRPC.Enabled {
		a.l.Debug("grpc server disabled, skipping")
		return
	}

	server := grpcserver.New(a.cfg.GRPC, a.l)

	handler := grpchandler.New(
		a.l,
		svc.wallet,
		svc.swap,
		svc.history,
		svc.contact,
		svc.token,
		svc.approval,
		svc.watcher,
		svc.notification,
		svc.priceFeed,
		a.network.ChainID,
		a.tokenList,
		a.network.Native.LogoURI,
	)
	pb.RegisterWalletServiceServer(server.Server(), handler)

	// Watcher runs as a background goroutine alongside the gRPC server.
	a.runners = append(a.runners, watcherRunner{svc.watcher})

	// PendingStore GC sweep — drops stale rows past the recent-TTL
	// window so the table doesn't grow unbounded if the user does a
	// lot of small txs.
	if a.pendingStore != nil {
		a.runners = append(a.runners, pendingStoreRunner{store: a.pendingStore})
	}

	a.runners = append(a.runners, server)
	a.closers = append(a.closers, server)
}

// watcherRunner adapts watcher.Usecase to the Runner interface.
type watcherRunner struct {
	uc interface {
		Start(ctx context.Context) error
	}
}

func (w watcherRunner) Run(ctx context.Context) error {
	return w.uc.Start(ctx)
}

// pendingStoreRunner adapts ethadapter.PendingStore.Run.
type pendingStoreRunner struct {
	store interface {
		Run(ctx context.Context) error
	}
}

func (p pendingStoreRunner) Run(ctx context.Context) error {
	if err := p.store.Run(ctx); err != nil {
		return fmt.Errorf("pending store run: %w", err)
	}

	return nil
}
