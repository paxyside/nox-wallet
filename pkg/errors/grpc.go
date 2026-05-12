package errors

import (
	stderrors "errors"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// grpcCode maps an internal Code to the matching grpc code.
func grpcCode(code Code) codes.Code {
	switch code {
	case CodeOK:
		return codes.OK
	case CodeNotFound:
		return codes.NotFound
	case CodeAlreadyExists:
		return codes.AlreadyExists
	case CodeInvalidArgument, CodeValidation:
		return codes.InvalidArgument
	case CodeUnauthenticated:
		return codes.Unauthenticated
	case CodePermissionDenied:
		return codes.PermissionDenied
	case CodeUnavailable:
		return codes.Unavailable
	case CodeTimeout:
		return codes.DeadlineExceeded
	case CodeCanceled:
		return codes.Canceled
	case CodeConflict:
		return codes.Aborted
	case CodeTooManyRequests:
		return codes.ResourceExhausted
	case CodeInternal, CodeUnknown:
		return codes.Internal
	case CodeFailedPrecondition:
		return codes.FailedPrecondition
	case CodeOutOfRange:
		return codes.OutOfRange
	case CodeUnimplemented:
		return codes.Unimplemented
	case CodeDataLoss:
		return codes.DataLoss
	default:
		return codes.Unknown
	}
}

// grpcCodeToCode is the inverse — used by GetCode when an error came
// back from a remote gRPC call, and we want to keep treating it as our
// internal Code.
func grpcCodeToCode(c codes.Code) Code {
	switch c {
	case codes.OK:
		return CodeOK
	case codes.NotFound:
		return CodeNotFound
	case codes.AlreadyExists:
		return CodeAlreadyExists
	case codes.InvalidArgument:
		return CodeInvalidArgument
	case codes.Unauthenticated:
		return CodeUnauthenticated
	case codes.PermissionDenied:
		return CodePermissionDenied
	case codes.Unavailable:
		return CodeUnavailable
	case codes.DeadlineExceeded:
		return CodeTimeout
	case codes.Canceled:
		return CodeCanceled
	case codes.Aborted:
		return CodeConflict
	case codes.ResourceExhausted:
		return CodeTooManyRequests
	case codes.Internal:
		return CodeInternal
	case codes.Unknown:
		return CodeUnknown
	case codes.FailedPrecondition:
		return CodeFailedPrecondition
	case codes.OutOfRange:
		return CodeOutOfRange
	case codes.Unimplemented:
		return CodeUnimplemented
	case codes.DataLoss:
		return CodeDataLoss
	default:
		return CodeUnknown
	}
}

// ToGRPCError converts any error to a gRPC status.Error. The grpc
// server's ErrorInterceptor calls this so handlers can return plain
// `*Error` (or wrapped chains) and the wire format stays correct.
//
// The wrapped cause's message is appended to the public payload so
// clients get "swap quote: no pool" instead of just "swap quote" —
// without the cause text the UI shows useless one-word errors.
func ToGRPCError(err error) error {
	if err == nil {
		return nil
	}

	var e *Error
	if !stderrors.As(err, &e) {
		return status.Error(codes.Unknown, err.Error())
	}

	msg := e.message
	if e.cause != nil {
		if cm := e.cause.Error(); cm != "" && cm != msg {
			msg = msg + ": " + cm
		}
	}

	return status.Error(grpcCode(e.code), msg)
}
