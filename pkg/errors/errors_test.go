package errors

import (
	"errors"
	"testing"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TestNew_StoresCodeAndMessage(t *testing.T) {
	err := New(CodeNotFound, "user not found")

	if err.Code() != CodeNotFound {
		t.Errorf("code = %s, want %s", err.Code(), CodeNotFound)
	}

	if !errors.Is(err, New(CodeNotFound, "different msg")) {
		t.Error("errors.Is should match by code, ignoring message")
	}
}

func TestNewf_FormatsMessage(t *testing.T) {
	err := Newf(CodeNotFound, "user %s not found", "123")
	if got, want := err.Error(), "NOT_FOUND: user 123 not found"; got != want {
		t.Errorf("Error() = %q, want %q", got, want)
	}
}

func TestWrapf_NilStaysNil(t *testing.T) {
	if Wrapf(nil, CodeInternal, "ignored") != nil {
		t.Error("Wrapf(nil, …) must return nil")
	}
}

func TestWrapf_PreservesCauseChain(t *testing.T) {
	cause := errors.New("database error")
	err := Wrapf(cause, CodeInternal, "failed to get user")

	if !errors.Is(err, cause) {
		t.Error("errors.Is should walk the wrap chain")
	}

	if got := errors.Unwrap(err); !errors.Is(got, cause) {
		t.Errorf("Unwrap() = %v, want %v", got, cause)
	}
}

func TestGetCode_FromAppError(t *testing.T) {
	err := New(CodeAlreadyExists, "duplicate")
	if got := GetCode(err); got != CodeAlreadyExists {
		t.Errorf("GetCode = %s, want %s", got, CodeAlreadyExists)
	}
}

func TestGetCode_FromGRPCStatus(t *testing.T) {
	err := status.Error(codes.NotFound, "missing")
	if got := GetCode(err); got != CodeNotFound {
		t.Errorf("GetCode = %s, want %s", got, CodeNotFound)
	}
}

func TestGetCode_NilReturnsUnknown(t *testing.T) {
	if got := GetCode(nil); got != CodeUnknown {
		t.Errorf("GetCode(nil) = %s, want %s", got, CodeUnknown)
	}
}

func TestToGRPCError_MapsCodeAndAppendsCause(t *testing.T) {
	cause := errors.New("no pool")
	err := Wrapf(cause, CodeFailedPrecondition, "swap quote")

	gerr := ToGRPCError(err)

	st, ok := status.FromError(gerr)
	if !ok {
		t.Fatalf("ToGRPCError must return a gRPC status error, got %v", gerr)
	}

	if st.Code() != codes.FailedPrecondition {
		t.Errorf("code = %s, want FailedPrecondition", st.Code())
	}

	if got := st.Message(); got != "swap quote: no pool" {
		t.Errorf("message = %q, want %q", got, "swap quote: no pool")
	}
}

func TestToGRPCError_NilStaysNil(t *testing.T) {
	if ToGRPCError(nil) != nil {
		t.Error("ToGRPCError(nil) must return nil")
	}
}

func TestToGRPCError_NonAppErrorBecomesUnknown(t *testing.T) {
	gerr := ToGRPCError(errors.New("plain"))

	st, ok := status.FromError(gerr)
	if !ok {
		t.Fatalf("expected gRPC status, got %v", gerr)
	}

	if st.Code() != codes.Unknown {
		t.Errorf("code = %s, want Unknown", st.Code())
	}
}
