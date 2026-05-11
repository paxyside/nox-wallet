package main

import (
	"context"
	"flag"
	"os"
	"os/signal"
	"syscall"

	appconfig "github.com/paxyside/nox-wallet/config"
	applayer "github.com/paxyside/nox-wallet/internal/app"
	libconfig "github.com/paxyside/nox-wallet/pkg/config"
	liblogger "github.com/paxyside/nox-wallet/pkg/logger"
)

func main() {
	os.Exit(run())
}

func run() int {
	var configPath, dataDir string

	flag.StringVar(
		&configPath,
		"config",
		"",
		"path to config.yaml (default: search in working directory)",
	)

	flag.StringVar(
		&dataDir,
		"data-dir",
		"",
		"path to data directory; SQLite DB is stored as wallet.db inside it. "+
			"Defaults to ./.dev-data when empty (suitable for `task run-be`); "+
			"the Flutter host passes a platform-specific app-support path in production.",
	)

	flag.Parse()

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	var opts []libconfig.Option
	if configPath != "" {
		opts = append(opts, libconfig.WithConfigPaths(configPath))
	}

	cfg, err := appconfig.Load(opts...)
	if err != nil {
		tmpLog := liblogger.New()
		tmpLog.Error("failed to load configuration", "error", err)

		return 1
	}

	if dataDir == "" {
		dataDir = ".dev-data"
	}

	l := liblogger.New(
		liblogger.WithAppName(cfg.App.Name),
		liblogger.WithEnvironment(cfg.App.Environment),
		liblogger.WithLevelString(cfg.Logger.Level),
		liblogger.WithSource(cfg.Logger.AddSource),
		liblogger.WithPrettyPrint(cfg.Logger.Pretty),
	)

	application, appErr := applayer.New(ctx, cfg, l, dataDir)
	if appErr != nil {
		l.Error("failed to create application", "error", appErr)

		return 1
	}

	if runErr := application.Run(ctx); runErr != nil {
		l.Error("application stopped with error", "error", runErr)

		return 1
	}

	l.Info("application stopped gracefully")

	return 0
}
