// Package errors is the app's structured error type. Every layer
// (domain, usecase, repo, adapter) wraps faults with a Code +
// message; the gRPC edge converts those to status errors via
// ToGRPCError. Domain packages declare their own sentinel `Err*`
// vars built on top of New / CodeXxx — see e.g.
// internal/domain/wallet/entity/errors.go.
package errors

import (
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"

	"google.golang.org/grpc/status"
)

// Code labels an Error so transport layers can map it to HTTP/gRPC
// codes without sniffing message strings.
type Code string

const (
	CodeUnknown            Code = "UNKNOWN"
	CodeOK                 Code = "OK"
	CodeNotFound           Code = "NOT_FOUND"
	CodeAlreadyExists      Code = "ALREADY_EXISTS"
	CodeInvalidArgument    Code = "INVALID_ARGUMENT"
	CodeUnauthenticated    Code = "UNAUTHENTICATED"
	CodePermissionDenied   Code = "PERMISSION_DENIED"
	CodeInternal           Code = "INTERNAL"
	CodeUnavailable        Code = "UNAVAILABLE"
	CodeTimeout            Code = "TIMEOUT"
	CodeCanceled           Code = "CANCELED"
	CodeConflict           Code = "CONFLICT"
	CodeTooManyRequests    Code = "TOO_MANY_REQUESTS"
	CodeValidation         Code = "VALIDATION_FAILED"
	CodeFailedPrecondition Code = "FAILED_PRECONDITION"
	CodeOutOfRange         Code = "OUT_OF_RANGE"
	CodeUnimplemented      Code = "UNIMPLEMENTED"
	CodeDataLoss           Code = "DATA_LOSS"
)

// Error is a code-tagged error with an optional cause and structured
// details. Implements the standard `error`, `errors.Unwrap`, and
// `slog.LogValuer` so wrapping/unwrapping/logging all work uniformly.
type Error struct {
	code    Code
	message string
	cause   error
	details map[string]any
}

// New builds an Error from a code and message.
func New(code Code, message string) *Error {
	return &Error{code: code, message: message}
}

// Newf builds an Error from a code and a format string.
func Newf(code Code, format string, args ...any) *Error {
	return &Error{code: code, message: fmt.Sprintf(format, args...)}
}

// Wrapf wraps an existing error with a code + formatted message.
// Returns nil when err is nil so callers can `return Wrapf(err, ...)`
// without a manual nil-check on the happy path.
func Wrapf(err error, code Code, format string, args ...any) *Error {
	if err == nil {
		return nil
	}

	return &Error{
		code:    code,
		message: fmt.Sprintf(format, args...),
		cause:   err,
	}
}

// Error implements the standard error interface.
func (e *Error) Error() string {
	if e.cause != nil {
		return fmt.Sprintf("%s: %s: %v", e.code, e.message, e.cause)
	}

	return fmt.Sprintf("%s: %s", e.code, e.message)
}

// LogValue makes structured loggers render the unexported fields
// instead of the empty `{}` they'd otherwise emit.
func (e *Error) LogValue() slog.Value {
	if e == nil {
		return slog.AnyValue(nil)
	}

	attrs := []slog.Attr{
		slog.String("code", string(e.code)),
		slog.String("message", e.message),
	}
	if e.cause != nil {
		attrs = append(attrs, slog.String("cause", e.cause.Error()))
	}

	if len(e.details) > 0 {
		attrs = append(attrs, slog.Any("details", e.details))
	}

	return slog.GroupValue(attrs...)
}

// MarshalJSON keeps the JSON shape symmetric with LogValue for HTTP
// debug dumps and any non-slog encoder that walks the error.
func (e *Error) MarshalJSON() ([]byte, error) {
	if e == nil {
		return []byte("null"), nil
	}

	type payload struct {
		Code    Code           `json:"code"`
		Message string         `json:"message"`
		Cause   string         `json:"cause,omitempty"`
		Details map[string]any `json:"details,omitempty"`
	}

	p := payload{Code: e.code, Message: e.message, Details: e.details}
	if e.cause != nil {
		p.Cause = e.cause.Error()
	}

	return json.Marshal(p)
}

// Code returns the error code.
func (e *Error) Code() Code { return e.code }

// Unwrap implements errors.Unwrap so errors.Is / errors.As walk into
// the cause.
func (e *Error) Unwrap() error { return e.cause }

// Is matches errors with the same code — domain sentinels rely on
// this so `errors.Is(err, entity.ErrNotFound)` works regardless of
// whether the error was wrapped along the way.
func (e *Error) Is(target error) bool {
	if t, ok := errors.AsType[*Error](target); ok {
		return e.code == t.code
	}

	return false
}

// Is re-exports errors.Is so consumers can avoid importing the stdlib
// `errors` package alongside this one.
func Is(err, target error) bool { return errors.Is(err, target) }

// As re-exports errors.As (same rationale as Is). Callers pass a
// pointer-to-pointer as `target` exactly the way the stdlib expects —
// we forward it verbatim. Taking the address here would wrap it once
// more and silently fail to populate the caller's variable.
func As(err error, target any) bool { return errors.As(err, target) }

// GetCode returns the Code of err, walking the wrap chain. Falls
// through to gRPC status mapping for cross-process errors so the
// caller can keep treating `*Error` and gRPC-origin errors uniformly.
func GetCode(err error) Code {
	if err == nil {
		return CodeUnknown
	}

	if e, ok := errors.AsType[*Error](err); ok {
		return e.code
	}

	if s, ok := status.FromError(err); ok {
		return grpcCodeToCode(s.Code())
	}

	return CodeUnknown
}
