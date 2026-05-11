package grpc

import (
	"context"
	stderrors "errors"
	"io"
	"log/slog"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	contactentity "github.com/paxyside/nox-wallet/internal/domain/contact/entity"
	tokenentity "github.com/paxyside/nox-wallet/internal/domain/token/entity"
	walletentity "github.com/paxyside/nox-wallet/internal/domain/wallet/entity"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

func newHandler() *Handler {
	log := logger.New(func(o *logger.Options) { o.Writer = io.Discard; o.Level = slog.LevelError })
	return &Handler{l: log}
}

func TestHandleErrorNil(t *testing.T) {
	h := newHandler()
	assert.NoError(t, h.HandleError(context.Background(), nil))
}

func TestHandleErrorEntityNotFound(t *testing.T) {
	h := newHandler()
	for _, e := range []error{walletentity.ErrNotFound, contactentity.ErrNotFound, tokenentity.ErrNotFound} {
		err := h.HandleError(context.Background(), e)
		require.Error(t, err)
		st, ok := status.FromError(err)
		require.True(t, ok)
		assert.Equal(t, codes.NotFound, st.Code())
	}
}

func TestHandleErrorAlreadyExists(t *testing.T) {
	h := newHandler()
	for _, e := range []error{contactentity.ErrAlreadyExists, tokenentity.ErrAlreadyExists} {
		err := h.HandleError(context.Background(), e)
		require.Error(t, err)
		st, ok := status.FromError(err)
		require.True(t, ok)
		assert.Equal(t, codes.AlreadyExists, st.Code())
	}
}

func TestHandleError_AppErrCodes(t *testing.T) {
	h := newHandler()
	cases := []struct {
		code liberrors.Code
		want codes.Code
	}{
		{liberrors.CodeInvalidArgument, codes.InvalidArgument},
		{liberrors.CodeUnauthenticated, codes.Unauthenticated},
		{liberrors.CodePermissionDenied, codes.PermissionDenied},
		{liberrors.CodeUnavailable, codes.Unavailable},
		{liberrors.CodeFailedPrecondition, codes.FailedPrecondition},
		{liberrors.CodeInternal, codes.Internal},
	}
	for _, c := range cases {
		t.Run(string(c.code), func(t *testing.T) {
			err := h.HandleError(context.Background(), liberrors.New(c.code, "x"))
			require.Error(t, err)
			st, ok := status.FromError(err)
			require.True(t, ok)
			assert.Equal(t, c.want, st.Code())
		})
	}
}

func TestHandleError_PlainError(t *testing.T) {
	h := newHandler()
	err := h.HandleError(context.Background(), stderrors.New("boom"))
	require.Error(t, err)
	st, ok := status.FromError(err)
	require.True(t, ok)
	assert.Equal(t, codes.Internal, st.Code())
}
