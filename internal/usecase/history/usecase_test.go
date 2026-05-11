package history

import (
	"context"
	stderrors "errors"
	"io"
	"log/slog"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
	"github.com/paxyside/nox-wallet/internal/usecase"
	"github.com/paxyside/nox-wallet/pkg/common/idx"
	"github.com/paxyside/nox-wallet/pkg/common/timex"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

type mockAlchemy struct {
	getAssetTransfersFn func(ctx context.Context, p ethkit.GetAssetTransfersParams) (ethkit.AssetTransfersPage, error)
}

func (m *mockAlchemy) GetAssetTransfers(
	ctx context.Context,
	p ethkit.GetAssetTransfersParams,
) (ethkit.AssetTransfersPage, error) {
	return m.getAssetTransfersFn(ctx, p)
}

type mockReceiptFetcher struct {
	getReceiptFn func(ctx context.Context, hash string) (ethkit.TxReceipt, bool, error)
}

func (m *mockReceiptFetcher) GetReceipt(ctx context.Context, h string) (ethkit.TxReceipt, bool, error) {
	return m.getReceiptFn(ctx, h)
}

type mockTxSvc struct {
	upsertFn         func(ctx context.Context, tx *entity.Transaction) error
	listByAddressFn  func(ctx context.Context, addr string, limit, offset int) ([]*entity.Transaction, error)
	countByAddressFn func(ctx context.Context, addr string) (int, error)
	updateGasFeesFn  func(ctx context.Context, hash, eth, usd string) error

	listCalls atomic.Int64
}

func (m *mockTxSvc) Upsert(ctx context.Context, tx *entity.Transaction) error {
	return m.upsertFn(ctx, tx)
}

func (m *mockTxSvc) ListByAddress(ctx context.Context, addr string, limit, offset int) ([]*entity.Transaction, error) {
	m.listCalls.Add(1)
	return m.listByAddressFn(ctx, addr, limit, offset)
}

func (m *mockTxSvc) CountByAddress(ctx context.Context, addr string) (int, error) {
	return m.countByAddressFn(ctx, addr)
}

func (m *mockTxSvc) UpdateGasFees(ctx context.Context, h, e, u string) error {
	return m.updateGasFeesFn(ctx, h, e, u)
}

func newUC(a AlchemyClient, r ReceiptFetcher, tx TxService) *Usecase {
	base := usecase.NewBaseUsecase(idx.New(), timex.NewClock())
	log := logger.New(func(o *logger.Options) { o.Writer = io.Discard; o.Level = slog.LevelError })
	return New(base, log, a, r, tx)
}

func TestNormalizeAsset(t *testing.T) {
	cases := []struct{ in, want string }{
		{"ETH", "ETH"},
		{"usdc", "USDC"},
		{"USDC", "USDC"},
		{"  USDC  ", "USDC"},
		{"USD-C", "USDC"},
		{"123abc", "123ABC"},
		{"", ""},
		{"ÚЅDС", "D"}, // Ú/Ѕ/С are non-ASCII; only "D" passes the ASCII filter.
	}
	for _, c := range cases {
		t.Run(c.in, func(t *testing.T) {
			assert.Equal(t, c.want, normalizeAsset(c.in))
		})
	}
}

func TestGetHistory_DefaultsAndCursor(t *testing.T) {
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")

	// Make alchemy a no-op (sync runs in background; we don't assert on it here).
	alc := &mockAlchemy{
		getAssetTransfersFn: func(_ context.Context, _ ethkit.GetAssetTransfersParams) (ethkit.AssetTransfersPage, error) {
			return ethkit.AssetTransfersPage{}, nil
		},
	}
	rf := &mockReceiptFetcher{}

	tx := &mockTxSvc{
		listByAddressFn: func(_ context.Context, _ string, limit, offset int) ([]*entity.Transaction, error) {
			// Return exactly `limit` rows so HasMore=true.
			out := make([]*entity.Transaction, limit)
			for i := range out {
				out[i] = &entity.Transaction{ID: "x", Hash: "h"}
			}
			_ = offset
			return out, nil
		},
		countByAddressFn: func(_ context.Context, _ string) (int, error) { return 100, nil },
		upsertFn:         func(_ context.Context, _ *entity.Transaction) error { return nil },
		updateGasFeesFn:  func(_ context.Context, _, _, _ string) error { return nil },
	}

	u := newUC(alc, rf, tx)

	// Default limit = 20, no cursor.
	res, err := u.GetHistory(context.Background(), GetHistoryParams{Address: addr})
	require.NoError(t, err)
	assert.Len(t, res.Transactions, 20)
	assert.Equal(t, 100, res.Total)
	assert.True(t, res.HasMore)
	assert.Equal(t, "20", res.NextCursor)

	// Cursor "20" → offset 20, hasMore still true → cursor 40.
	res2, err := u.GetHistory(context.Background(), GetHistoryParams{Address: addr, Cursor: "20", Limit: 10})
	require.NoError(t, err)
	assert.Equal(t, "30", res2.NextCursor)

	// Bad cursor falls back to 0.
	res3, err := u.GetHistory(context.Background(), GetHistoryParams{Address: addr, Cursor: "bad", Limit: 5})
	require.NoError(t, err)
	assert.True(t, res3.HasMore)
}

func TestGetHistory_NoMore(t *testing.T) {
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")

	tx := &mockTxSvc{
		listByAddressFn: func(_ context.Context, _ string, _, _ int) ([]*entity.Transaction, error) {
			return []*entity.Transaction{{ID: "1"}}, nil // less than limit
		},
		countByAddressFn: func(_ context.Context, _ string) (int, error) { return 1, nil },
	}
	alc := &mockAlchemy{
		getAssetTransfersFn: func(_ context.Context, _ ethkit.GetAssetTransfersParams) (ethkit.AssetTransfersPage, error) {
			return ethkit.AssetTransfersPage{}, nil
		},
	}
	u := newUC(alc, &mockReceiptFetcher{}, tx)

	res, err := u.GetHistory(context.Background(), GetHistoryParams{Address: addr, Limit: 20})
	require.NoError(t, err)
	assert.False(t, res.HasMore)
	assert.Empty(t, res.NextCursor)
}

func TestGetHistory_CountFallback(t *testing.T) {
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")

	tx := &mockTxSvc{
		listByAddressFn: func(_ context.Context, _ string, _, _ int) ([]*entity.Transaction, error) {
			return []*entity.Transaction{{ID: "1"}, {ID: "2"}}, nil
		},
		countByAddressFn: func(_ context.Context, _ string) (int, error) {
			return 0, stderrors.New("count err")
		},
	}
	alc := &mockAlchemy{
		getAssetTransfersFn: func(_ context.Context, _ ethkit.GetAssetTransfersParams) (ethkit.AssetTransfersPage, error) {
			return ethkit.AssetTransfersPage{}, nil
		},
	}
	u := newUC(alc, &mockReceiptFetcher{}, tx)

	res, err := u.GetHistory(context.Background(), GetHistoryParams{Address: addr, Limit: 5})
	require.NoError(t, err)
	assert.Equal(t, 2, res.Total, "count fallback should use len(txs)")
}

func TestGetHistory_ListError(t *testing.T) {
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")
	tx := &mockTxSvc{
		listByAddressFn: func(_ context.Context, _ string, _, _ int) ([]*entity.Transaction, error) {
			return nil, stderrors.New("db")
		},
	}
	alc := &mockAlchemy{
		getAssetTransfersFn: func(_ context.Context, _ ethkit.GetAssetTransfersParams) (ethkit.AssetTransfersPage, error) {
			return ethkit.AssetTransfersPage{}, nil
		},
	}
	u := newUC(alc, &mockReceiptFetcher{}, tx)
	_, err := u.GetHistory(context.Background(), GetHistoryParams{Address: addr})
	require.Error(t, err)
}

func TestGetHistory_NoSyncWhenInCooldown(t *testing.T) {
	addr := ethkit.MustAddress("0x52908400098527886e0f7030069857d2e4169ee7")

	var alchemyHits atomic.Int64
	alc := &mockAlchemy{
		getAssetTransfersFn: func(_ context.Context, _ ethkit.GetAssetTransfersParams) (ethkit.AssetTransfersPage, error) {
			alchemyHits.Add(1)
			return ethkit.AssetTransfersPage{}, nil
		},
	}
	tx := &mockTxSvc{
		listByAddressFn: func(_ context.Context, _ string, _, _ int) ([]*entity.Transaction, error) {
			return nil, nil
		},
		countByAddressFn: func(_ context.Context, _ string) (int, error) { return 0, nil },
		upsertFn:         func(_ context.Context, _ *entity.Transaction) error { return nil },
	}
	u := newUC(alc, &mockReceiptFetcher{}, tx)

	// Force lastSync to "now" so cooldown is active and sync should be skipped.
	u.lastSync = time.Now()

	_, err := u.GetHistory(context.Background(), GetHistoryParams{Address: addr})
	require.NoError(t, err)

	// Give any spurious goroutine a beat to fire (it shouldn't).
	time.Sleep(50 * time.Millisecond)
	assert.Equal(t, int64(0), alchemyHits.Load(), "sync must not run within cooldown")
}
