// Package sqlitekit provides a thin SQLite client for local storage.
// Uses modernc.org/sqlite (pure Go, no CGO) — safe to bundle inside a macOS .app.
//
// WAL mode and foreign key enforcement are enabled automatically on every connection.
// Use Client.DB() if you need the raw *sql.DB for migrations or advanced queries.
package sqlitekit

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "modernc.org/sqlite" // register "sqlite" driver
)

// Client wraps *sql.DB with context-aware helpers and sane SQLite defaults.
type Client struct {
	db  *sql.DB
	log Logger
}

// Option configures the client.
type Option func(*config)

type config struct {
	log         Logger
	busyTimeout time.Duration
	maxOpenConn int
}

// WithLogger attaches a logger. If omitted, sqlitekit stays silent.
func WithLogger(l Logger) Option {
	return func(c *config) { c.log = l }
}

// New opens (or creates) a SQLite database at path and applies sane defaults:
//   - WAL journal mode — concurrent reads while writing
//   - Foreign key enforcement
//   - Busy timeout (default 5 s)
//
// The context is used for the initial pragma exec; pass a request-scoped or
// startup-scoped context here.
func New(ctx context.Context, path string, opts ...Option) (*Client, error) {
	cfg := &config{
		log:         noopLogger{},
		busyTimeout: 5 * time.Second,
		maxOpenConn: 1,
	}
	for _, o := range opts {
		o(cfg)
	}

	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, fmt.Errorf("sqlitekit: open %s: %w", path, err)
	}

	// SQLite only allows one concurrent writer — enforce it at the driver level.
	db.SetMaxOpenConns(cfg.maxOpenConn)

	c := &Client{db: db, log: cfg.log}

	if err := c.applyPragmas(ctx, cfg.busyTimeout); err != nil {
		_ = db.Close()
		return nil, err
	}

	cfg.log.Info("sqlitekit: connected", "path", path)

	return c, nil
}

func (c *Client) applyPragmas(ctx context.Context, busyTimeout time.Duration) error {
	pragmas := []string{
		"PRAGMA journal_mode=WAL",
		"PRAGMA foreign_keys=ON",
		fmt.Sprintf("PRAGMA busy_timeout=%d", busyTimeout.Milliseconds()),
		"PRAGMA synchronous=NORMAL", // safe with WAL; faster than FULL
	}
	for _, p := range pragmas {
		if _, err := c.db.ExecContext(ctx, p); err != nil {
			return fmt.Errorf("sqlitekit: pragma %q: %w", p, err)
		}
	}

	return nil
}

// DB returns the underlying *sql.DB for direct use (e.g. migrations).
func (c *Client) DB() *sql.DB {
	return c.db
}

// Close closes the database.
func (c *Client) Close() error {
	return c.db.Close()
}

// Exec executes a statement that does not return rows (INSERT, UPDATE, DELETE).
func (c *Client) Exec(ctx context.Context, query string, args ...any) (sql.Result, error) {
	result, err := c.db.ExecContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("sqlitekit exec: %w", err)
	}

	return result, nil
}

// QueryRow executes a query expected to return at most one row.
// Caller must call .Scan() on the returned *sql.Row; a missing row surfaces as sql.ErrNoRows.
func (c *Client) QueryRow(ctx context.Context, query string, args ...any) *sql.Row {
	return c.db.QueryRowContext(ctx, query, args...)
}

// Query executes a query that returns multiple rows.
// Caller is responsible for calling rows.Close().
func (c *Client) Query(ctx context.Context, query string, args ...any) (*sql.Rows, error) {
	rows, err := c.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("sqlitekit query: %w", err)
	}

	return rows, nil
}

// WithTx runs fn inside a transaction. Commits on nil return, rolls back on error or panic.
func (c *Client) WithTx(ctx context.Context, fn func(tx *Tx) error) error {
	sqlTx, err := c.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("sqlitekit: begin tx: %w", err)
	}

	defer func() {
		if p := recover(); p != nil {
			_ = sqlTx.Rollback()

			panic(p)
		}
	}()

	if err := fn(&Tx{tx: sqlTx}); err != nil {
		_ = sqlTx.Rollback()
		return err
	}

	if err := sqlTx.Commit(); err != nil {
		return fmt.Errorf("sqlitekit: commit: %w", err)
	}

	return nil
}

// Tx wraps *sql.Tx with the same Exec/QueryRow/Query surface as Client.
type Tx struct {
	tx *sql.Tx
}

// Exec executes a statement inside the transaction.
func (t *Tx) Exec(ctx context.Context, query string, args ...any) (sql.Result, error) {
	result, err := t.tx.ExecContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("sqlitekit tx exec: %w", err)
	}

	return result, nil
}

// QueryRow executes a single-row query inside the transaction.
func (t *Tx) QueryRow(ctx context.Context, query string, args ...any) *sql.Row {
	return t.tx.QueryRowContext(ctx, query, args...)
}

// Query executes a multi-row query inside the transaction.
func (t *Tx) Query(ctx context.Context, query string, args ...any) (*sql.Rows, error) {
	rows, err := t.tx.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("sqlitekit tx query: %w", err)
	}

	return rows, nil
}
