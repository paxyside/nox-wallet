package contact

import (
	"context"
	stderrors "errors"
	"io"
	"log/slog"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/paxyside/nox-wallet/internal/domain/contact/entity"
	"github.com/paxyside/nox-wallet/internal/usecase"
	"github.com/paxyside/nox-wallet/pkg/common/idx"
	"github.com/paxyside/nox-wallet/pkg/common/timex"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

type mockSvc struct {
	createFn       func(ctx context.Context, c *entity.Contact) error
	getByIDFn      func(ctx context.Context, id string) (*entity.Contact, error)
	getByAddressFn func(ctx context.Context, addr string) (*entity.Contact, error)
	updateFn       func(ctx context.Context, c *entity.Contact) error
	setFavoriteFn  func(ctx context.Context, id string, fav bool) error
	deleteFn       func(ctx context.Context, id string) error
	listFn         func(ctx context.Context) ([]*entity.Contact, error)
}

func (m *mockSvc) Create(ctx context.Context, c *entity.Contact) error { return m.createFn(ctx, c) }
func (m *mockSvc) GetByID(ctx context.Context, id string) (*entity.Contact, error) {
	return m.getByIDFn(ctx, id)
}

func (m *mockSvc) GetByAddress(ctx context.Context, a string) (*entity.Contact, error) {
	return m.getByAddressFn(ctx, a)
}

func (m *mockSvc) Update(ctx context.Context, c *entity.Contact) error { return m.updateFn(ctx, c) }
func (m *mockSvc) SetFavorite(ctx context.Context, id string, fav bool) error {
	return m.setFavoriteFn(ctx, id, fav)
}

func (m *mockSvc) Delete(ctx context.Context, id string) error         { return m.deleteFn(ctx, id) }
func (m *mockSvc) List(ctx context.Context) ([]*entity.Contact, error) { return m.listFn(ctx) }

func newUC(svc ContactService) *Usecase {
	base := usecase.NewBaseUsecase(idx.New(), timex.NewClock())
	log := logger.New(func(o *logger.Options) { o.Writer = io.Discard; o.Level = slog.LevelError })
	return New(base, log, svc)
}

func TestCreate(t *testing.T) {
	t.Run("success", func(t *testing.T) {
		svc := &mockSvc{createFn: func(_ context.Context, c *entity.Contact) error {
			assert.NotEmpty(t, c.ID)
			assert.Equal(t, "Bob", c.Name)
			return nil
		}}
		u := newUC(svc)
		got, err := u.Create(context.Background(), CreateParams{Address: ethkit.ZeroAddress, Name: "Bob"})
		require.NoError(t, err)
		assert.Equal(t, "Bob", got.Name)
	})

	t.Run("error wraps to internal", func(t *testing.T) {
		svc := &mockSvc{createFn: func(_ context.Context, _ *entity.Contact) error {
			return stderrors.New("db")
		}}
		u := newUC(svc)
		_, err := u.Create(context.Background(), CreateParams{})
		require.Error(t, err)
		assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
	})
}

func TestUpdate(t *testing.T) {
	existing := &entity.Contact{ID: "id", Name: "old"}
	t.Run("success", func(t *testing.T) {
		svc := &mockSvc{
			getByIDFn: func(_ context.Context, _ string) (*entity.Contact, error) { return existing, nil },
			updateFn:  func(_ context.Context, _ *entity.Contact) error { return nil },
		}
		u := newUC(svc)
		got, err := u.Update(context.Background(), UpdateParams{ID: "id", Name: "new", Notes: "n"})
		require.NoError(t, err)
		assert.Equal(t, "new", got.Name)
		assert.Equal(t, "n", got.Notes)
	})
	t.Run("get fails", func(t *testing.T) {
		svc := &mockSvc{
			getByIDFn: func(_ context.Context, _ string) (*entity.Contact, error) {
				return nil, entity.ErrNotFound
			},
		}
		u := newUC(svc)
		_, err := u.Update(context.Background(), UpdateParams{ID: "x"})
		require.Error(t, err)
		assert.True(t, liberrors.Is(err, entity.ErrNotFound))
	})
	t.Run("update fails wraps", func(t *testing.T) {
		svc := &mockSvc{
			getByIDFn: func(_ context.Context, _ string) (*entity.Contact, error) { return existing, nil },
			updateFn:  func(_ context.Context, _ *entity.Contact) error { return stderrors.New("x") },
		}
		u := newUC(svc)
		_, err := u.Update(context.Background(), UpdateParams{ID: "id"})
		require.Error(t, err)
		assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
	})
}

func TestSetFavorite(t *testing.T) {
	called := false
	svc := &mockSvc{setFavoriteFn: func(_ context.Context, id string, fav bool) error {
		called = true
		assert.Equal(t, "id", id)
		assert.True(t, fav)
		return nil
	}}
	u := newUC(svc)
	require.NoError(t, u.SetFavorite(context.Background(), "id", true))
	assert.True(t, called)
}

func TestDelete(t *testing.T) {
	svc := &mockSvc{deleteFn: func(_ context.Context, _ string) error { return nil }}
	u := newUC(svc)
	require.NoError(t, u.Delete(context.Background(), "id"))
}

func TestList(t *testing.T) {
	want := []*entity.Contact{{ID: "1"}, {ID: "2"}}
	svc := &mockSvc{listFn: func(_ context.Context) ([]*entity.Contact, error) { return want, nil }}
	u := newUC(svc)
	got, err := u.List(context.Background())
	require.NoError(t, err)
	assert.Len(t, got, 2)
}

func TestGetByID(t *testing.T) {
	want := &entity.Contact{ID: "x"}
	svc := &mockSvc{getByIDFn: func(_ context.Context, _ string) (*entity.Contact, error) {
		return want, nil
	}}
	u := newUC(svc)
	got, err := u.GetByID(context.Background(), "x")
	require.NoError(t, err)
	assert.Same(t, want, got)
}
