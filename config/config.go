package config

import (
	"fmt"
	"time"

	libconfig "github.com/paxyside/nox-wallet/pkg/config"
)

type Config struct {
	App       App       `yaml:"app"       env-prefix:"APP_"`
	GRPC      GRPC      `yaml:"grpc"      env-prefix:"GRPC_"`
	Logger    Logger    `yaml:"logger"    env-prefix:"LOG_"`
	Ethereum  Ethereum  `yaml:"ethereum"  env-prefix:"ETH_"`
	Pricefeed Pricefeed `yaml:"pricefeed" env-prefix:"PRICEFEED_"`
}

// Load loads configuration from config.yaml and environment variables.
// Optional libconfig.Option values (e.g. WithConfigPaths) can override defaults.
func Load(opts ...libconfig.Option) (*Config, error) {
	var cfg Config

	if err := libconfig.Load(&cfg, opts...); err != nil {
		return nil, fmt.Errorf("failed to load config: %w", err)
	}

	return &cfg, nil
}

// -----------------------------------------------------------------------------
// Application
// -----------------------------------------------------------------------------

type App struct {
	Name            string        `yaml:"name"             env:"NAME"`
	Version         string        `yaml:"version"          env:"VERSION"`
	Environment     string        `yaml:"environment"      env:"ENV"`
	ShutdownTimeout time.Duration `yaml:"shutdown_timeout" env:"SHUTDOWN_TIMEOUT"`
	Retry           AppRetry      `yaml:"retry"                                   env-prefix:"RETRY_"`
}

// AppRetry configures the shared retrier for infra calls.
type AppRetry struct {
	MaxRetries int           `yaml:"max_retries" env:"MAX_RETRIES"`
	BaseDelay  time.Duration `yaml:"base_delay"  env:"BASE_DELAY"`
	MaxDelay   time.Duration `yaml:"max_delay"   env:"MAX_DELAY"`
}

// -----------------------------------------------------------------------------
// gRPC Server
// -----------------------------------------------------------------------------

type GRPC struct {
	Enabled         bool          `yaml:"enabled"          env:"ENABLED"`
	Host            string        `yaml:"host"             env:"HOST"`
	Port            int           `yaml:"port"             env:"PORT"`
	Authorization   string        `yaml:"authorization"    env:"AUTHORIZATION"`
	Reflection      bool          `yaml:"reflection"       env:"REFLECTION"`
	ShutdownTimeout time.Duration `yaml:"shutdown_timeout" env:"SHUTDOWN_TIMEOUT"`
}

// Addr returns gRPC server address.
func (g *GRPC) Addr() string {
	return fmt.Sprintf("%s:%d", g.Host, g.Port)
}

// -----------------------------------------------------------------------------
// Logger
// -----------------------------------------------------------------------------

type Logger struct {
	Level     string `yaml:"level"      env:"LEVEL"`
	Format    string `yaml:"format"     env:"FORMAT"`
	AddSource bool   `yaml:"add_source" env:"ADD_SOURCE"`
	Pretty    bool   `yaml:"pretty"     env:"PRETTY"`
}

// -----------------------------------------------------------------------------
// Ethereum
// -----------------------------------------------------------------------------

type Ethereum struct {
	HTTPUrl       string `yaml:"http_url"    env:"HTTP_URL"`
	ChainID       int64  `yaml:"chain_id"    env:"CHAIN_ID"`
	AlchemyAPIKey string `yaml:"alchemy_key" env:"ALCHEMY_KEY"`
}

// -----------------------------------------------------------------------------
// Pricefeed (CoinGecko)
// -----------------------------------------------------------------------------

// Pricefeed configures the upstream price provider. CoinGecko's anonymous tier
// rate-limits aggressively (~10–30 req/min) which causes sparkline charts to
// flicker. Sign up for a free Demo plan at https://www.coingecko.com/en/api/pricing
// (~30 req/min, more reliable) and set CoinGeckoKey + Plan="demo". For Pro
// keys use Plan="pro" — that switches the base URL to pro-api.coingecko.com.
type Pricefeed struct {
	CoinGeckoKey  string `yaml:"coingecko_key"  env:"COINGECKO_KEY"`
	CoinGeckoPlan string `yaml:"coingecko_plan" env:"COINGECKO_PLAN"` // "" | "demo" | "pro"
}
