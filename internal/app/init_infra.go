package app

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/paxyside/nox-wallet/config/networks"
	ethadapter "github.com/paxyside/nox-wallet/internal/adapter/eth"
	"github.com/paxyside/nox-wallet/internal/dal/sqlite"
	"github.com/paxyside/nox-wallet/pkg/common/retryx"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/keychain"
	"github.com/paxyside/nox-wallet/pkg/sqlitekit"
)

func (a *App) initInfra(ctx context.Context) error {
	if err := a.initNetwork(); err != nil {
		return fmt.Errorf("init network: %w", err)
	}

	if err := a.initSQLite(ctx); err != nil {
		return fmt.Errorf("init sqlite: %w", err)
	}

	if err := a.initEth(ctx); err != nil {
		return fmt.Errorf("init eth client: %w", err)
	}

	return nil
}

// initNetwork loads the chain catalog (embedded by default, file path
// override via `ethereum.networks_file`) and the verified TokenList
// (embedded Uniswap Default List by default, override via
// `ethereum.tokenlist_file`). Stored on the app for downstream
// wiring — the watcher, pricefeed, and swap codepath all consume them.
func (a *App) initNetwork() error {
	id := a.cfg.Ethereum.Network
	if id == "" {
		id = "ethereum"
	}

	catalog, err := networks.Load(a.cfg.Ethereum.NetworksFile)
	if err != nil {
		return fmt.Errorf("load networks: %w", err)
	}

	net, err := catalog.Network(id)
	if err != nil {
		return fmt.Errorf("select network %q: %w", id, err)
	}

	tokenList, err := networks.LoadTokenList(a.cfg.Ethereum.TokenListFile)
	if err != nil {
		return fmt.Errorf("load tokenlist: %w", err)
	}

	a.network = net
	a.tokenList = tokenList

	a.l.Info("network catalog loaded",
		"id", net.ID,
		"chain_id", net.ChainID,
	)

	a.l.Info("token list loaded",
		"name", tokenList.Name,
		"version", tokenList.Version,
		"verified_for_chain", tokenList.SizeByChain()[net.ChainID],
	)

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
		ChainID:       a.network.ChainID,
		AlchemyAPIKey: a.cfg.Ethereum.AlchemyAPIKey,
	}

	// Translate the network catalog into the minimal address bundle
	// ethkit consumes. Empty strings (would-be MustAddress crashes)
	// are caught here rather than at the swap call site.
	netForEthkit := ethkit.Network{
		ChainID:             a.network.ChainID,
		UniswapQuoterV2:     ethkit.MustAddress(a.network.Protocols.UniswapV3.QuoterV2),
		UniswapSwapRouter02: ethkit.MustAddress(a.network.Protocols.UniswapV3.SwapRouter02),
		UniswapWrappedETH:   ethkit.MustAddress(a.network.Protocols.UniswapV3.WrappedNative),
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
		ethkit.WithNetwork(netForEthkit),
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
