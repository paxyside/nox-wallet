package app

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"time"

	ethadapter "github.com/paxyside/nox-wallet/internal/adapter/eth"
	"github.com/paxyside/nox-wallet/internal/dal/sqlite"
	"github.com/paxyside/nox-wallet/pkg/common/retryx"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/keychain"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

func (a *App) initInfra(ctx context.Context) error {
	if err := a.initSQLite(ctx); err != nil {
		return fmt.Errorf("init sqlite: %w", err)
	}

	if err := a.initEth(ctx); err != nil {
		return fmt.Errorf("init eth client: %w", err)
	}

	return nil
}

func (a *App) initSQLite(ctx context.Context) error {
	if a.dataDir == "" {
		return errors.New("data dir is empty; pass --data-dir at startup")
	}

	path := filepath.Join(a.dataDir, "wallet.db")

	// 0o750 keeps the DB private to the running user — wallet data must not be
	// world- or group-readable.
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return fmt.Errorf("create db dir: %w", err)
	}

	client, err := sqlitekit.New(ctx, path, sqlitekit.WithLogger(a.l))
	if err != nil {
		return fmt.Errorf("open sqlite: %w", err)
	}

	a.sqlite = client

	if err := sqlite.Migrate(ctx, client.DB()); err != nil {
		return fmt.Errorf("migrate: %w", err)
	}

	a.l.Info("sqlite initialized", "path", path)

	return nil
}

func (a *App) initEth(ctx context.Context) error {
	cfg := ethkit.Config{
		HTTPURL:       a.cfg.Ethereum.HTTPUrl,
		ChainID:       a.cfg.Ethereum.ChainID,
		AlchemyAPIKey: a.cfg.Ethereum.AlchemyAPIKey,
	}

	retrier := retryx.NewRetrier(
		retryx.WithMaxRetries(3),
		retryx.WithBaseDelay(500*time.Millisecond),
	)

	// SQLite-backed pending tracker so the user-action `Kind` tag
	// (swap / send / approve) survives a backend restart. Watcher's
	// deferred-emit logic for swaps relies on this tag — without
	// persistence, the first swap submitted before a crash gets
	// misclassified after restart.
	pendingStore, err := ethadapter.NewPendingStore(ctx, a.sqlite, a.l)
	if err != nil {
		return fmt.Errorf("init pending store: %w", err)
	}

	a.pendingStore = pendingStore

	client, err := ethkit.New(ctx, cfg,
		ethkit.WithLogger(a.l),
		ethkit.WithRetrier(retrier),
		ethkit.WithPendingStore(pendingStore),
	)
	if err != nil {
		return fmt.Errorf("ethkit new: %w", err)
	}

	a.eth = client
	a.adapter = ethadapter.New(client, a.l)
	a.keychain = keychain.New(a.cfg.App.Name)
	a.l.Info("eth client initialized", "chain_id", cfg.ChainID)

	return nil
}
