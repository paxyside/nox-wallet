// Package ethkit provides a batteries-included Ethereum client for the wallet app.
// It wraps go-ethereum's ethclient with connection management, retries, and structured logging.
package ethkit

import (
	"context"
	"errors"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum/ethclient"
)

// Config holds connection parameters for the Ethereum client.
type Config struct {
	// HTTPURL is the Alchemy (or any JSON-RPC) HTTP endpoint.
	// Example: "https://eth-mainnet.g.alchemy.com/v2/<API_KEY>"
	HTTPURL string

	// ChainID is the EIP-155 chain identifier.
	// 1 = mainnet, 11155111 = Sepolia, 8453 = Base.
	ChainID int64

	// AlchemyAPIKey is extracted from HTTPURL automatically, but can be set
	// explicitly for Alchemy-specific RPC methods.
	AlchemyAPIKey string
}

// Client is a thread-safe Ethereum client backed by HTTP JSON-RPC.
//
// The watcher polls Alchemy `getAssetTransfers` over HTTP for transaction
// notifications and `eth_getBalance` for the low-balance latch — neither
// needs a WebSocket. We dropped WS plumbing entirely after the move to
// the unified TransactionEvent model; keep this in mind if you ever need
// real-time push (you'll have to add back a `WS()` accessor and the
// reconnect loop).
type Client struct {
	cfg     Config
	http    *ethclient.Client
	chainID *big.Int
	log     Logger
	retrier Retrier
	nonces  *nonceManager // per-client nonce tracking; initialised in New
	pending PendingStore
}

// Option configures the client.
type Option func(*Client)

// WithLogger attaches a logger to the client. If omitted, ethkit uses a no-op
// logger and stays silent.
func WithLogger(log Logger) Option {
	return func(c *Client) { c.log = log }
}

// WithRetrier sets the retry policy for RPC calls. If omitted, ethkit runs
// each call exactly once with no retries.
func WithRetrier(r Retrier) Option {
	return func(c *Client) { c.retrier = r }
}

// WithPendingStore swaps the default in-memory pending tracker for a
// caller-provided implementation — typically a SQLite-backed store
// that survives backend restarts. Pass nil to keep the default.
func WithPendingStore(s PendingStore) Option {
	return func(c *Client) {
		if s != nil {
			c.pending = s
		}
	}
}

// New connects the HTTP client and returns a ready Client.
func New(ctx context.Context, cfg Config, opts ...Option) (*Client, error) {
	c := &Client{
		cfg:     cfg,
		chainID: big.NewInt(cfg.ChainID),
		log:     noopLogger{},
		retrier: directRetrier{},
	}
	for _, opt := range opts {
		opt(c)
	}

	if cfg.HTTPURL == "" {
		return nil, errors.New("ethkit: HTTPURL is required")
	}

	var err error

	c.http, err = ethclient.DialContext(ctx, cfg.HTTPURL)
	if err != nil {
		return nil, fmt.Errorf("ethkit: dial HTTP: %w", err)
	}

	c.nonces = &nonceManager{pending: make(map[string]uint64), client: c}
	if c.pending == nil {
		// No external store wired via [WithPendingStore] — fall back
		// to the in-memory tracker. Suitable for tests and for the
		// dev backend that doesn't care about restart durability.
		c.pending = newPendingTracker()
	}

	c.startPendingJanitor(ctx)
	c.log.Info("ethkit: connected", "chainID", cfg.ChainID)

	return c, nil
}

// Close shuts down the HTTP connection.
func (c *Client) Close() {
	c.http.Close()
}

// HTTP returns the underlying HTTP ethclient for direct use when needed.
func (c *Client) HTTP() *ethclient.Client {
	return c.http
}

// ChainID returns the configured chain ID.
func (c *Client) ChainID() *big.Int {
	return new(big.Int).Set(c.chainID)
}

// BlockNumber returns the latest block number.
func (c *Client) BlockNumber(ctx context.Context) (uint64, error) {
	var n uint64

	err := c.retrier.Do(ctx, func(ctx context.Context) error {
		var err error

		n, err = c.http.BlockNumber(ctx)

		return err
	})

	return n, err
}
