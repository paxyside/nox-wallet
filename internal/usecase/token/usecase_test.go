package token

import (
	"context"
	stderrors "errors"
	"io"
	"log/slog"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/paxyside/nox-wallet/internal/adapter/price"
	"github.com/paxyside/nox-wallet/internal/domain/token/entity"
	"github.com/paxyside/nox-wallet/internal/usecase"
	"github.com/paxyside/nox-wallet/pkg/common/idx"
	"github.com/paxyside/nox-wallet/pkg/common/timex"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

type mockEth struct {
	tokenMetadataFn  func(ctx context.Context, addr ethkit.Address) (ethkit.Token, error)
	tokenBalanceFn   func(ctx context.Context, addr ethkit.Address, t ethkit.Token) (ethkit.Amount, error)
	discoverTokensFn func(ctx context.Context, addr ethkit.Address) ([]ethkit.Token, error)
}

func (m *mockEth) TokenMetadata(ctx context.Context, a ethkit.Address) (ethkit.Token, error) {
	return m.tokenMetadataFn(ctx, a)
}

func (m *mockEth) TokenBalance(ctx context.Context, a ethkit.Address, t ethkit.Token) (ethkit.Amount, error) {
	return m.tokenBalanceFn(ctx, a, t)
}

func (m *mockEth) DiscoverTokens(ctx context.Context, a ethkit.Address) ([]ethkit.Token, error) {
	return m.discoverTokensFn(ctx, a)
}

type mockTokenSvc struct {
	createFn    func(ctx context.Context, t *entity.WatchedToken) error
	getByIDFn   func(ctx context.Context, id string) (*entity.WatchedToken, error)
	setPinnedFn func(ctx context.Context, id string, pinned bool) error
	setHiddenFn func(ctx context.Context, id string, hidden bool) error
	deleteFn    func(ctx context.Context, id string) error
	listFn      func(ctx context.Context) ([]*entity.WatchedToken, error)
}

func (m *mockTokenSvc) Create(ctx context.Context, t *entity.WatchedToken) error {
	return m.createFn(ctx, t)
}

func (m *mockTokenSvc) GetByID(ctx context.Context, id string) (*entity.WatchedToken, error) {
	return m.getByIDFn(ctx, id)
}

func (m *mockTokenSvc) SetPinned(ctx context.Context, id string, p bool) error {
	return m.setPinnedFn(ctx, id, p)
}

func (m *mockTokenSvc) SetHidden(ctx context.Context, id string, h bool) error {
	if m.setHiddenFn == nil {
		return nil
	}
	return m.setHiddenFn(ctx, id, h)
}

func (m *mockTokenSvc) Delete(ctx context.Context, id string) error { return m.deleteFn(ctx, id) }
func (m *mockTokenSvc) List(ctx context.Context) ([]*entity.WatchedToken, error) {
	return m.listFn(ctx)
}

func newUC(eth EthClient, svc TokenService) *Usecase {
	base := usecase.NewBaseUsecase(idx.New(), timex.NewClock())
	log := logger.New(func(o *logger.Options) { o.Writer = io.Discard; o.Level = slog.LevelError })
	return New(base, log, eth, svc, price.New(price.Config{TTL: price.DefaultTTL}))
}

func TestAdd_ExplicitMetadataSkipsFetch(t *testing.T) {
	called := false
	eth := &mockEth{tokenMetadataFn: func(_ context.Context, _ ethkit.Address) (ethkit.Token, error) {
		called = true
		return ethkit.Token{}, nil
	}}
	svc := &mockTokenSvc{createFn: func(_ context.Context, _ *entity.WatchedToken) error { return nil }}

	u := newUC(eth, svc)
	got, err := u.Add(context.Background(), AddTokenParams{
		ContractAddress: ethkit.ZeroAddress, Symbol: "X", Name: "X-Coin", Decimals: 18,
	})
	require.NoError(t, err)
	assert.False(t, called, "metadata fetch should be skipped when fields are populated")
	assert.Equal(t, "X", got.Token.Symbol)
}

func TestAdd_FetchesMetadataWhenMissing(t *testing.T) {
	eth := &mockEth{tokenMetadataFn: func(_ context.Context, _ ethkit.Address) (ethkit.Token, error) {
		return ethkit.Token{Symbol: "USDC", Name: "USD Coin", Decimals: 6}, nil
	}}
	svc := &mockTokenSvc{createFn: func(_ context.Context, _ *entity.WatchedToken) error { return nil }}

	u := newUC(eth, svc)
	got, err := u.Add(context.Background(), AddTokenParams{ContractAddress: ethkit.ZeroAddress})
	require.NoError(t, err)
	assert.Equal(t, "USDC", got.Token.Symbol)
	assert.Equal(t, uint8(6), got.Token.Decimals)
}

func TestAdd_MetadataError(t *testing.T) {
	eth := &mockEth{tokenMetadataFn: func(_ context.Context, _ ethkit.Address) (ethkit.Token, error) {
		return ethkit.Token{}, stderrors.New("rpc")
	}}
	u := newUC(eth, &mockTokenSvc{})
	_, err := u.Add(context.Background(), AddTokenParams{})
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
}

func TestAdd_CreateError(t *testing.T) {
	eth := &mockEth{}
	svc := &mockTokenSvc{createFn: func(_ context.Context, _ *entity.WatchedToken) error {
		return stderrors.New("db")
	}}
	u := newUC(eth, svc)
	_, err := u.Add(context.Background(), AddTokenParams{Symbol: "X", Name: "X", Decimals: 1})
	require.Error(t, err)
}

func TestPinRemoveListDelegation(t *testing.T) {
	calls := map[string]bool{}
	svc := &mockTokenSvc{
		setPinnedFn: func(_ context.Context, _ string, _ bool) error { calls["pin"] = true; return nil },
		deleteFn:    func(_ context.Context, _ string) error { calls["del"] = true; return nil },
		listFn:      func(_ context.Context) ([]*entity.WatchedToken, error) { calls["list"] = true; return nil, nil },
	}
	u := newUC(&mockEth{}, svc)

	require.NoError(t, u.Pin(context.Background(), "id", true))
	require.NoError(t, u.Remove(context.Background(), "id"))
	_, err := u.List(context.Background())
	require.NoError(t, err)
	assert.Equal(t, map[string]bool{"pin": true, "del": true, "list": true}, calls)
}

func TestSeed_FiltersUnknownAndExisting(t *testing.T) {
	usdcAddr := ethkit.MustAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
	usdtAddr := ethkit.MustAddress("0xdAC17F958D2ee523a2206206994597C13D831ec7")
	scamAddr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")

	usdc := ethkit.Token{Address: usdcAddr, Symbol: "USDC", Decimals: 6}
	usdt := ethkit.Token{Address: usdtAddr, Symbol: "USDT", Decimals: 6}
	scam := ethkit.Token{Address: scamAddr, Symbol: "SCAM", Decimals: 18}

	eth := &mockEth{discoverTokensFn: func(_ context.Context, _ ethkit.Address) ([]ethkit.Token, error) {
		return []ethkit.Token{usdc, usdt, scam}, nil
	}}

	// Pretend USDC is already watched.
	created := []*entity.WatchedToken{}
	svc := &mockTokenSvc{
		listFn: func(_ context.Context) ([]*entity.WatchedToken, error) {
			return []*entity.WatchedToken{{ID: "x", Token: usdc}}, nil
		},
		createFn: func(_ context.Context, t *entity.WatchedToken) error {
			created = append(created, t)
			return nil
		},
	}

	u := newUC(eth, svc)
	addr, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	require.NoError(t, u.Seed(context.Background(), addr))

	require.Len(t, created, 1, "only USDT should be added (USDC already watched, SCAM not in whitelist)")
	assert.Equal(t, "USDT", created[0].Token.Symbol)
}

func TestSeed_DiscoverError(t *testing.T) {
	eth := &mockEth{discoverTokensFn: func(_ context.Context, _ ethkit.Address) ([]ethkit.Token, error) {
		return nil, stderrors.New("rpc")
	}}
	u := newUC(eth, &mockTokenSvc{})
	addr, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	err := u.Seed(context.Background(), addr)
	require.Error(t, err)
	assert.Equal(t, liberrors.CodeInternal, liberrors.GetCode(err))
}
