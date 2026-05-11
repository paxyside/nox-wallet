package grpckit

import (
	"context"
	"log/slog"
	"runtime/debug"
	"strings"
	"time"

	"github.com/google/uuid"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// ── Context keys ──────────────────────────────────────────────────────────

type contextKey string

const requestIDKey contextKey = "request_id"

// Metadata header names used on the wire.
const (
	MetadataRequestID     = "x-request-id"
	MetadataAuthorization = "authorization"
)

// RequestID returns the request ID stamped onto ctx by RequestIDInterceptor.
func RequestID(ctx context.Context) string {
	if id, ok := ctx.Value(requestIDKey).(string); ok {
		return id
	}

	return ""
}

// ── Unary interceptors ────────────────────────────────────────────────────

// RequestIDInterceptor mints a request ID for each call (or reuses
// the inbound x-request-id header) and stamps it onto ctx + response
// trailers so log lines and client-side traces correlate.
func RequestIDInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, _ *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		requestID := extractRequestID(ctx)
		if requestID == "" {
			requestID = uuid.New().String()
		}

		ctx = context.WithValue(ctx, requestIDKey, requestID)
		_ = grpc.SetHeader(ctx, metadata.Pairs(MetadataRequestID, requestID))

		return handler(ctx, req)
	}
}

// LoggingInterceptor records duration + status for each unary call.
// The level is bumped to Error on internal failures and demoted to
// Debug for benign user-facing codes (NotFound on first launch, etc.)
// so normal output stays clean.
func LoggingInterceptor(l Log) grpc.UnaryServerInterceptor {
	sl := toSlog(l)

	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		start := time.Now()

		resp, err := handler(ctx, req)

		duration := time.Since(start)
		code := status.Code(err)

		level := slog.LevelInfo

		if code != codes.OK {
			//exhaustive:ignore // explicit ladder of severity buckets — `default` covers everything else.
			switch code {
			case codes.Unknown, codes.Internal:
				level = slog.LevelError
			case codes.NotFound, codes.AlreadyExists, codes.Canceled:
				// Benign user-facing outcomes — UI polls GetWallet on
				// onboarding (NOT_FOUND until import), submits dupes
				// the user retries (ALREADY_EXISTS), and cancels long
				// streams on tab switches. WARN is too loud; DEBUG keeps
				// them in dev logs without polluting normal output.
				level = slog.LevelDebug
			default:
				level = slog.LevelWarn
			}
		}

		sl.Log(ctx, level, "grpc request",
			slog.String("method", info.FullMethod),
			slog.String("code", code.String()),
			slog.Duration("duration", duration),
			slog.String("request_id", RequestID(ctx)),
		)

		return resp, err
	}
}

// RecoveryInterceptor turns panics into Internal errors so a single
// bad handler can't take down the server.
func RecoveryInterceptor(l Log) grpc.UnaryServerInterceptor {
	sl := toSlog(l)

	//nolint:nonamedreturns // required for recover to set err and have it returned
	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (resp any, err error) {
		defer func() {
			if r := recover(); r != nil {
				sl.Error("panic recovered",
					"error", r,
					"stack", string(debug.Stack()),
					"request_id", RequestID(ctx),
					"method", info.FullMethod,
				)

				err = status.Error(codes.Internal, "internal server error")
			}
		}()

		resp, err = handler(ctx, req)

		return resp, err
	}
}

// extractToken returns the Bearer token from incoming metadata.
func extractToken(ctx context.Context) (string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "missing metadata")
	}

	vals := md.Get(MetadataAuthorization)
	if len(vals) == 0 {
		return "", status.Error(codes.Unauthenticated, "missing authorization")
	}

	const prefix = "bearer "

	v := vals[0]
	if !strings.HasPrefix(strings.ToLower(v), prefix) {
		return "", status.Error(codes.Unauthenticated, "invalid authorization format")
	}

	return v[len(prefix):], nil
}

// StaticTokenAuthUnaryInterceptor enforces a fixed Bearer token. An
// empty expectedToken disables auth (useful in dev where the Flutter
// host is the only client).
func StaticTokenAuthUnaryInterceptor(expectedToken string) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, _ *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		if expectedToken == "" {
			return handler(ctx, req)
		}

		token, err := extractToken(ctx)
		if err != nil {
			return nil, err
		}

		if token != expectedToken {
			return nil, status.Error(codes.Unauthenticated, "invalid token")
		}

		return handler(ctx, req)
	}
}

// StaticTokenAuthStreamInterceptor is the stream variant of
// StaticTokenAuthUnaryInterceptor.
func StaticTokenAuthStreamInterceptor(expectedToken string) grpc.StreamServerInterceptor {
	return func(srv any, ss grpc.ServerStream, _ *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		if expectedToken == "" {
			return handler(srv, ss)
		}

		token, err := extractToken(ss.Context())
		if err != nil {
			return err
		}

		if token != expectedToken {
			return status.Error(codes.Unauthenticated, "invalid token")
		}

		return handler(srv, ss)
	}
}

// ErrorInterceptor converts plain errors to gRPC status errors via
// the supplied converter (in this app, errors.ToGRPCError). If the
// handler already returned a status error it's passed through.
func ErrorInterceptor(converter func(error) error) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, _ *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		resp, err := handler(ctx, req)
		if err == nil {
			return resp, nil
		}

		if _, ok := status.FromError(err); ok {
			return resp, err
		}

		if converter != nil {
			return resp, converter(err)
		}

		return resp, err
	}
}

// ── Stream interceptors ───────────────────────────────────────────────────

// RecoveryStreamInterceptor is the stream variant of RecoveryInterceptor.
func RecoveryStreamInterceptor(l Log) grpc.StreamServerInterceptor {
	sl := toSlog(l)

	//nolint:nonamedreturns // required for recover to set err and have it returned
	return func(srv any, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) (err error) {
		defer func() {
			if r := recover(); r != nil {
				sl.Error("stream panic recovered",
					"error", r,
					"stack", string(debug.Stack()),
					"method", info.FullMethod,
				)

				err = status.Error(codes.Internal, "internal server error")
			}
		}()

		return handler(srv, ss)
	}
}

// LoggingStreamInterceptor records duration + status for each stream call.
func LoggingStreamInterceptor(l Log) grpc.StreamServerInterceptor {
	sl := toSlog(l)

	return func(srv any, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		start := time.Now()

		err := handler(srv, ss)

		duration := time.Since(start)
		code := status.Code(err)

		level := slog.LevelInfo
		if code != codes.OK {
			level = slog.LevelWarn
		}

		sl.Log(ss.Context(), level, "grpc stream",
			slog.String("method", info.FullMethod),
			slog.String("code", code.String()),
			slog.Duration("duration", duration),
		)

		return err
	}
}

// ── Helpers ───────────────────────────────────────────────────────────────

func extractRequestID(ctx context.Context) string {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return ""
	}

	if ids := md.Get(MetadataRequestID); len(ids) > 0 {
		return ids[0]
	}

	return ""
}

// ── Standard stacks ───────────────────────────────────────────────────────

// StandardUnaryInterceptors returns the recovery → request-id → logging
// → error-conversion stack used by the app's gRPC server.
func StandardUnaryInterceptors(l Log, errorConverter func(error) error) []grpc.UnaryServerInterceptor {
	return []grpc.UnaryServerInterceptor{
		RecoveryInterceptor(l),
		RequestIDInterceptor(),
		LoggingInterceptor(l),
		ErrorInterceptor(errorConverter),
	}
}

// StandardStreamInterceptors returns the recovery → logging stack
// used by the app's gRPC server for streaming RPCs.
func StandardStreamInterceptors(l Log) []grpc.StreamServerInterceptor {
	return []grpc.StreamServerInterceptor{
		RecoveryStreamInterceptor(l),
		LoggingStreamInterceptor(l),
	}
}
