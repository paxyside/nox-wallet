// Package grpckit wraps grpc.Server in a small builder that wires
// interceptors and a logger. The grpcserver runner consumes this
// builder; nothing else in the app talks to it directly.
package grpckit

import (
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

// Server wraps a grpc.Server with the resolved addr/logger/options
// from the builder. The grpcserver runner uses .Server() to register
// services and runs Serve/Stop directly — Start/Stop helpers are not
// needed here.
type Server struct {
	server *grpc.Server
	logger Log

	addr             string
	shutdownTimeout  time.Duration
	enableReflection bool
}

// ServerOption mutates the wrapper. Used by the builder via WithOptions.
type ServerOption func(*Server)

// WithLogger sets the logger used for startup/shutdown messages.
func WithLogger(l Log) ServerOption {
	return func(s *Server) { s.logger = l }
}

// WithShutdownTimeout sets the graceful-stop deadline.
func WithShutdownTimeout(d time.Duration) ServerOption {
	return func(s *Server) { s.shutdownTimeout = d }
}

// WithReflection toggles grpcurl-style reflection. On by default.
func WithReflection(enabled bool) ServerOption {
	return func(s *Server) { s.enableReflection = enabled }
}

// NewServer constructs a Server with the supplied grpc.ServerOptions
// (interceptors, stats handlers, …) plus the wrapper-level opts.
func NewServer(addr string, grpcOpts []grpc.ServerOption, opts ...ServerOption) *Server {
	s := &Server{
		addr:             addr,
		shutdownTimeout:  30 * time.Second,
		enableReflection: true,
	}

	for _, opt := range opts {
		opt(s)
	}

	s.server = grpc.NewServer(grpcOpts...)
	if s.enableReflection {
		reflection.Register(s.server)
	}

	return s
}

// Server returns the underlying grpc.Server for pb-service registration.
func (s *Server) Server() *grpc.Server {
	return s.server
}

// ── Builder ────────────────────────────────────────────────────────────────

// ServerBuilder collects interceptors / options before constructing the
// Server in Build(). The grpcserver runner uses it; tests can too.
type ServerBuilder struct {
	unaryInterceptors  []grpc.UnaryServerInterceptor
	streamInterceptors []grpc.StreamServerInterceptor
	serverOptions      []grpc.ServerOption
	options            []ServerOption
	addr               string
}

// NewServerBuilder creates a new builder bound to the given listen addr.
func NewServerBuilder(addr string) *ServerBuilder {
	return &ServerBuilder{addr: addr}
}

// WithUnaryInterceptors appends unary interceptors to the chain.
func (b *ServerBuilder) WithUnaryInterceptors(interceptors ...grpc.UnaryServerInterceptor) *ServerBuilder {
	b.unaryInterceptors = append(b.unaryInterceptors, interceptors...)
	return b
}

// WithStreamInterceptors appends stream interceptors to the chain.
func (b *ServerBuilder) WithStreamInterceptors(interceptors ...grpc.StreamServerInterceptor) *ServerBuilder {
	b.streamInterceptors = append(b.streamInterceptors, interceptors...)
	return b
}

// WithOptions adds wrapper-level options (logger, shutdown timeout, …).
func (b *ServerBuilder) WithOptions(opts ...ServerOption) *ServerBuilder {
	b.options = append(b.options, opts...)
	return b
}

// Build assembles the Server with the collected configuration.
func (b *ServerBuilder) Build() *Server {
	grpcOpts := b.serverOptions

	if len(b.unaryInterceptors) > 0 {
		grpcOpts = append(grpcOpts, grpc.ChainUnaryInterceptor(b.unaryInterceptors...))
	}

	if len(b.streamInterceptors) > 0 {
		grpcOpts = append(grpcOpts, grpc.ChainStreamInterceptor(b.streamInterceptors...))
	}

	return NewServer(b.addr, grpcOpts, b.options...)
}
