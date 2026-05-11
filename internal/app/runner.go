package app

import "context"

// Runner is the interface for application components that run in goroutines.
type Runner interface {
	Run(ctx context.Context) error
}

// Closer is the interface for components that need graceful shutdown.
type Closer interface {
	Close(ctx context.Context) error
}

// RunnerCloser combines Runner and Closer interfaces.
type RunnerCloser interface {
	Runner
	Closer
}
