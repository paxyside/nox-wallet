package app

import (
	"context"

	"golang.org/x/sync/errgroup"

	appconfig "github.com/paxyside/nox-wallet/config"
	ethadapter "github.com/paxyside/nox-wallet/internal/adapter/eth"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/keychain"
	liblogger "github.com/paxyside/nox-wallet/pkg/logger"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

// App owns all components and manages their lifecycle.
type App struct {
	cfg     *appconfig.Config
	l       *liblogger.Logger
	dataDir string

	// Infrastructure
	sqlite       *sqlitekit.Client
	eth          *ethkit.Client
	adapter      *ethadapter.Adapter
	keychain     *keychain.Client
	pendingStore *ethadapter.PendingStore

	// Lifecycle
	runners []Runner
	closers []Closer
}

// New creates and fully initializes the application.
//
// dataDir is the directory where the SQLite database lives. The Flutter
// host passes a platform-specific app-support path via --data-dir; for
// `task run-be` style dev runs main.go falls back to ./.dev-data so the
// repo working tree stays clean.
func New(
	ctx context.Context,
	cfg *appconfig.Config,
	l *liblogger.Logger,
	dataDir string,
) (*App, error) {
	a := &App{
		cfg:     cfg,
		l:       l,
		dataDir: dataDir,
		runners: make([]Runner, 0),
		closers: make([]Closer, 0),
	}

	if err := a.initInfra(ctx); err != nil {
		return nil, err
	}

	svc, err := a.initServices(ctx)
	if err != nil {
		return nil, err
	}

	a.initGRPCServer(svc)

	l.Info("application initialized",
		"name", cfg.App.Name,
		"version", cfg.App.Version,
		"environment", cfg.App.Environment,
	)

	return a, nil
}

// Run starts all registered runners in parallel and blocks until done.
func (a *App) Run(ctx context.Context) error {
	g, ctx := errgroup.WithContext(ctx)

	for _, runner := range a.runners {
		r := runner

		g.Go(func() error { return r.Run(ctx) })
	}

	g.Go(func() error {
		<-ctx.Done()
		return a.shutdown()
	})

	return g.Wait()
}

func (a *App) shutdown() error {
	a.l.Info("shutting down application...")

	ctx, cancel := context.WithTimeout(context.Background(), a.cfg.App.ShutdownTimeout)
	defer cancel()

	for i := len(a.closers) - 1; i >= 0; i-- {
		if err := a.closers[i].Close(ctx); err != nil {
			a.l.Error("failed to close component", "error", err)
		}
	}

	if a.sqlite != nil {
		if err := a.sqlite.Close(); err != nil {
			a.l.Error("failed to close sqlite", "error", err)
		}
	}

	a.l.Info("shutdown complete")

	return nil
}
