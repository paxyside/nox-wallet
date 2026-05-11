package grpcserver

import (
	"context"
	"net"
	"time"

	"google.golang.org/grpc"

	appconfig "github.com/paxyside/nox-wallet/config"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	libgrpckit "github.com/paxyside/nox-wallet/pkg/grpckit"
	liblogger "github.com/paxyside/nox-wallet/pkg/logger"
)

// Runner is the gRPC server runner.
type Runner struct {
	cfg      appconfig.GRPC
	l        *liblogger.Logger
	server   *grpc.Server
	listener net.Listener
}

// New creates a new gRPC server runner.
func New(cfg appconfig.GRPC, l *liblogger.Logger) *Runner {
	unaryInterceptors := append(
		[]grpc.UnaryServerInterceptor{
			libgrpckit.StaticTokenAuthUnaryInterceptor(cfg.Authorization),
		},
		libgrpckit.StandardUnaryInterceptors(l, liberrors.ToGRPCError)...,
	)

	streamInterceptors := append(
		[]grpc.StreamServerInterceptor{
			libgrpckit.StaticTokenAuthStreamInterceptor(cfg.Authorization),
		},
		libgrpckit.StandardStreamInterceptors(l)...,
	)

	// Build server with grpckit builder
	builder := libgrpckit.NewServerBuilder(cfg.Addr()).
		WithUnaryInterceptors(unaryInterceptors...).
		WithStreamInterceptors(streamInterceptors...).
		WithOptions(
			libgrpckit.WithLogger(l),
			libgrpckit.WithShutdownTimeout(cfg.ShutdownTimeout),
			libgrpckit.WithReflection(cfg.Reflection),
		)

	grpcServer := builder.Build()

	return &Runner{
		cfg:    cfg,
		l:      l,
		server: grpcServer.Server(),
	}
}

// Run starts the gRPC server.
func (r *Runner) Run(ctx context.Context) error {
	lc := net.ListenConfig{}

	listener, err := lc.Listen(ctx, "tcp", r.cfg.Addr())
	if err != nil {
		return err
	}

	r.listener = listener
	r.l.Info("grpc server starting", "addr", r.cfg.Addr())

	errCh := make(chan error, 1)

	go func() {
		if serveErr := r.server.Serve(listener); serveErr != nil {
			errCh <- serveErr
		}
	}()

	select {
	case serveErr := <-errCh:
		return serveErr
	case <-ctx.Done():
		return nil
	}
}

// Close gracefully shuts down the gRPC server.
func (r *Runner) Close(_ context.Context) error {
	r.l.Info("grpc server shutting down")

	done := make(chan struct{})

	go func() {
		r.server.GracefulStop()
		close(done)
	}()

	select {
	case <-done:
	case <-time.After(r.cfg.ShutdownTimeout):
		r.l.Warn("grpc graceful shutdown timeout, forcing stop")
		r.server.Stop()
	}

	return nil
}

// Server returns the underlying gRPC server for service registration.
func (r *Runner) Server() *grpc.Server {
	return r.server
}
