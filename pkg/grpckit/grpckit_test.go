package grpckit

import (
	"context"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TestRequestID_EmptyContext(t *testing.T) {
	if got := RequestID(context.Background()); got != "" {
		t.Errorf("expected empty string, got %q", got)
	}
}

func TestRequestID_ReturnsStampedValue(t *testing.T) {
	ctx := context.WithValue(context.Background(), requestIDKey, "test-id")
	if got := RequestID(ctx); got != "test-id" {
		t.Errorf("expected test-id, got %q", got)
	}
}

func TestRequestIDInterceptor_StampsCtx(t *testing.T) {
	interceptor := RequestIDInterceptor()

	var captured string

	handler := func(ctx context.Context, _ any) (any, error) {
		captured = RequestID(ctx)
		return nil, status.Error(codes.Internal, "test error")
	}

	info := &grpc.UnaryServerInfo{FullMethod: "/test/Method"}
	if _, err := interceptor(context.Background(), nil, info, handler); err == nil {
		t.Fatal("expected handler error to propagate")
	}

	if captured == "" {
		t.Error("request ID should be generated")
	}
}

func TestRecoveryInterceptor_TurnsPanicIntoInternal(t *testing.T) {
	interceptor := RecoveryInterceptor(nil)

	handler := func(_ context.Context, _ any) (any, error) {
		panic("test panic")
	}

	info := &grpc.UnaryServerInfo{FullMethod: "/test/Method"}

	_, err := interceptor(context.Background(), nil, info, handler)
	if err == nil {
		t.Fatal("should return error after panic")
	}

	if s, ok := status.FromError(err); !ok || s.Code() != codes.Internal {
		t.Errorf("expected Internal code, got %v", err)
	}
}

func TestErrorInterceptor_PassThroughStatusErrors(t *testing.T) {
	interceptor := ErrorInterceptor(nil)
	info := &grpc.UnaryServerInfo{FullMethod: "/test/Method"}

	handler := func(_ context.Context, _ any) (any, error) {
		return nil, status.Error(codes.NotFound, "not found")
	}

	_, err := interceptor(context.Background(), nil, info, handler)

	s, ok := status.FromError(err)
	if !ok || s.Code() != codes.NotFound {
		t.Errorf("expected NotFound, got %v", err)
	}
}

func TestErrorInterceptor_NoError(t *testing.T) {
	interceptor := ErrorInterceptor(func(err error) error {
		return status.Error(codes.Unknown, err.Error())
	})
	info := &grpc.UnaryServerInfo{FullMethod: "/test/Method"}

	handler := func(_ context.Context, _ any) (any, error) {
		return "result", nil
	}

	resp, err := interceptor(context.Background(), nil, info, handler)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}

	if resp != "result" {
		t.Errorf("want result, got %v", resp)
	}
}

func TestLoggingInterceptor_DoesNotShadowResult(t *testing.T) {
	interceptor := LoggingInterceptor(nil)

	handler := func(_ context.Context, _ any) (any, error) {
		return "result", nil
	}

	info := &grpc.UnaryServerInfo{FullMethod: "/test/Method"}

	resp, err := interceptor(context.Background(), nil, info, handler)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}

	if resp != "result" {
		t.Errorf("want result, got %v", resp)
	}
}

func TestServerBuilder_BuildsServer(t *testing.T) {
	server := NewServerBuilder(":50051").
		WithUnaryInterceptors(RequestIDInterceptor()).
		WithStreamInterceptors(RecoveryStreamInterceptor(nil)).
		WithOptions(WithReflection(true)).
		Build()

	if server == nil {
		t.Fatal("Build returned nil")
	}

	if server.Server() == nil {
		t.Error("server.Server() returned nil")
	}
}

func TestStandardInterceptors_NonEmpty(t *testing.T) {
	if len(StandardUnaryInterceptors(nil, func(err error) error { return err })) == 0 {
		t.Error("StandardUnaryInterceptors returned empty slice")
	}

	if len(StandardStreamInterceptors(nil)) == 0 {
		t.Error("StandardStreamInterceptors returned empty slice")
	}
}
