package history

import (
	"context"
	"strconv"
	"strings"
	"sync"
	"time"

	"golang.org/x/sync/errgroup"
	"golang.org/x/sync/semaphore"

	"github.com/paxyside/nox-wallet/internal/domain/transaction/entity"
	txservice "github.com/paxyside/nox-wallet/internal/domain/transaction/service"
	"github.com/paxyside/nox-wallet/internal/usecase"
	liberrors "github.com/paxyside/nox-wallet/pkg/errors"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	"github.com/paxyside/nox-wallet/pkg/logger"
)

// syncCooldown is the minimum interval between background Alchemy syncs.
const syncCooldown = 30 * time.Second

// alchemyConcurrency caps how many getAssetTransfers / getReceipt calls
// can be in-flight against Alchemy at once. The free tier rate-limits
// to ~25 RPS; staying at 8 leaves headroom for unrelated calls (gas
// fees, balance polls, watcher's own poll loop) firing in parallel.
const alchemyConcurrency = 8

// normalizeAsset strips every character that is not a plain ASCII letter or digit and
// uppercases the result. This removes Unicode homoglyphs that spammers/scammers use to
// impersonate well-known token symbols (e.g. "ÚЅDС" → "DC", "υꓢⅮС" → "").
// ETH and real ERC-20 symbols (USDC, WBTC, …) contain only ASCII, so they pass through unchanged.
func normalizeAsset(s string) string {
	var b strings.Builder

	for _, r := range s {
		switch {
		case r >= 'A' && r <= 'Z':
			b.WriteRune(r)
		case r >= 'a' && r <= 'z':
			b.WriteRune(r - 32)
		case r >= '0' && r <= '9':
			b.WriteRune(r)
		}
	}

	return b.String()
}

type AlchemyClient interface {
	GetAssetTransfers(ctx context.Context, params ethkit.GetAssetTransfersParams) (ethkit.AssetTransfersPage, error)
}

// ReceiptFetcher fetches a mined transaction receipt without polling.
type ReceiptFetcher interface {
	GetReceipt(ctx context.Context, txHashHex string) (ethkit.TxReceipt, bool, error)
}

type TxService interface {
	Upsert(ctx context.Context, tx *entity.Transaction) error
	ListByAddress(ctx context.Context, address string, limit, offset int) ([]*entity.Transaction, error)
	CountByAddress(ctx context.Context, address string) (int, error)
	UpdateGasFees(ctx context.Context, hash, gasFeeEth, gasFeeUsd string) error
}

var _ TxService = (*txservice.Service)(nil)

type Usecase struct {
	*usecase.BaseUsecase
	log     logger.Log
	alchemy AlchemyClient
	eth     ReceiptFetcher
	txSvc   TxService

	mu       sync.Mutex
	lastSync time.Time
	// syncing guards against overlapping syncFromAlchemy invocations —
	// notably from rapid back-to-back SyncForce calls (post-swap +
	// post-send within seconds). Without this, two parallel sync runs
	// race on the SQLite UPSERTs and double the Alchemy bill.
	syncing bool

	// alchemySem caps total in-flight Alchemy queries — shared by all
	// the parallel direction goroutines inside syncFromAlchemy and by
	// the gas-receipt enrichment path inside fetchAllPages.
	alchemySem *semaphore.Weighted
}

func New(
	base *usecase.BaseUsecase,
	log logger.Log,
	alchemy AlchemyClient,
	eth ReceiptFetcher,
	txSvc TxService,
) *Usecase {
	return &Usecase{
		BaseUsecase: base,
		log:         log,
		alchemy:     alchemy,
		eth:         eth,
		txSvc:       txSvc,
		alchemySem:  semaphore.NewWeighted(alchemyConcurrency),
	}
}

func (u *Usecase) GetHistory(ctx context.Context, p GetHistoryParams) (GetHistoryResult, error) {
	if p.Limit == 0 {
		p.Limit = 20
	}

	// Cursor encodes the DB offset as a decimal string ("0", "20", "40", …).
	offset := 0

	if p.Cursor != "" {
		if n, err := strconv.Atoi(p.Cursor); err == nil && n > 0 {
			offset = n
		}
	}

	// Kick off a background sync only if the cooldown has elapsed.
	// The DB cache is returned immediately regardless.
	u.mu.Lock()

	shouldSync := time.Since(u.lastSync) > syncCooldown
	if shouldSync {
		u.lastSync = time.Now()
	}
	u.mu.Unlock()

	if shouldSync {
		addr := p.Address
		contracts := p.WatchedContracts

		// Background sync continues past the request — must use a fresh context
		// so client cancellation doesn't abort partial syncs to Alchemy.
		go func() {
			bgCtx := context.Background()
			if err := u.syncFromAlchemy(bgCtx, addr, contracts); err != nil {
				u.log.Warn("history: alchemy sync failed", "error", err)
			}
		}()
	}

	txs, err := u.txSvc.ListByAddress(ctx, p.Address.Hex(), p.Limit, offset)
	if err != nil {
		return GetHistoryResult{}, liberrors.Wrapf(err, liberrors.CodeInternal, "list transactions")
	}

	// hasMore must be evaluated against the raw row count, not the merged
	// view: mergeSwapLegs collapses two same-hash legs into one synthetic
	// entry, so a full page of 20 raw rows can shrink to ~18 merged ones.
	// Comparing the merged length against `p.Limit` would falsely declare
	// the page the last and the UI would never paginate past it.
	rawCount := len(txs)

	// Merge swap legs (two same-hash transfers crossing a known DEX router)
	// into a single synthetic SWAP entry. Storage keeps both legs as-is —
	// the merge is purely a presentation step. See entity.Transaction docs
	// for the synthetic fields.
	txs = mergeSwapLegs(txs, p.Address.Hex())

	total, err := u.txSvc.CountByAddress(ctx, p.Address.Hex())
	if err != nil {
		total = len(txs) // fallback: don't fail the whole request over a count query
	}

	nextCursor := ""

	hasMore := rawCount == p.Limit
	if hasMore {
		nextCursor = strconv.Itoa(offset + p.Limit)
	}

	return GetHistoryResult{
		Transactions: txs,
		Total:        total,
		NextCursor:   nextCursor,
		HasMore:      hasMore,
	}, nil
}

// Sync exposes the Alchemy-driven history sync as a standalone entrypoint so
// callers (e.g. wallet-import handlers) can preheat the cache without going
// through GetHistory. Honors the same cooldown as GetHistory does.
func (u *Usecase) Sync(ctx context.Context, addr ethkit.Address, watchedContracts []ethkit.Address) error {
	u.mu.Lock()

	if time.Since(u.lastSync) <= syncCooldown {
		u.mu.Unlock()
		return nil
	}
	u.lastSync = time.Now()
	u.mu.Unlock()

	return u.syncFromAlchemy(ctx, addr, watchedContracts)
}

// SyncForce bypasses [syncCooldown] and always pulls from Alchemy.
// Used by post-swap / post-send handlers that need the fresh tx to
// appear in history immediately even if a routine sync just ran.
// Updates `lastSync` so the next regular Sync respects the new floor.
//
// Single-flight: if another sync is already running, this call short-circuits and returns nil — the in-flight sync will pick up the new
// transaction on its existing pages. Two parallel SyncForce calls
// would otherwise UPSERT the same rows twice and double the Alchemy
// bill for no benefit.
func (u *Usecase) SyncForce(ctx context.Context, addr ethkit.Address, watchedContracts []ethkit.Address) error {
	u.mu.Lock()
	if u.syncing {
		u.mu.Unlock()

		return nil
	}

	u.syncing = true
	u.lastSync = time.Now()
	u.mu.Unlock()

	defer func() {
		u.mu.Lock()
		u.syncing = false
		u.mu.Unlock()
	}()

	return u.syncFromAlchemy(ctx, addr, watchedContracts)
}

func (u *Usecase) syncFromAlchemy(
	ctx context.Context,
	addr ethkit.Address,
	watchedContracts []ethkit.Address,
) error {
	now := u.NowUTC()

	// Build the full set of independent fetch directions and run them
	// in parallel. Each direction is its own pageKey-paginated stream;
	// they share only the SQLite UPSERT path (which dedupes by
	// `unique_id`, so concurrent inserts are safe). Total throughput
	// is bounded by `alchemySem` to keep us under Alchemy rate limits.
	ethCategories := []ethkit.AssetTransferCategory{
		ethkit.CategoryExternal,
		ethkit.CategoryInternal,
	}

	directions := []ethkit.GetAssetTransfersParams{
		{ToAddress: &addr, FromBlock: "0x0", WithMetadata: true, Categories: ethCategories},
		{FromAddress: &addr, FromBlock: "0x0", WithMetadata: true, Categories: ethCategories},
	}

	if len(watchedContracts) > 0 {
		erc20Categories := []ethkit.AssetTransferCategory{ethkit.CategoryERC20}
		directions = append(directions,
			ethkit.GetAssetTransfersParams{
				ToAddress: &addr, FromBlock: "0x0", WithMetadata: true,
				Categories: erc20Categories, ContractAddresses: watchedContracts,
			},
			ethkit.GetAssetTransfersParams{
				FromAddress: &addr, FromBlock: "0x0", WithMetadata: true,
				Categories: erc20Categories, ContractAddresses: watchedContracts,
			},
		)
	}

	g, gctx := errgroup.WithContext(ctx)
	for _, base := range directions {
		g.Go(func() error {
			return u.fetchAllPages(gctx, base, now)
		})
	}

	return g.Wait()
}

// fetchAllPages follows Alchemy pageKey pagination until all results
// are stored. Each `GetAssetTransfers` and each post-insert
// `getTransactionReceipt` acquires from the shared `alchemySem` so
// the total RPS against Alchemy stays bounded across all concurrent
// directions running inside [syncFromAlchemy]. Pages within a single
// direction stay sequential — pageKey is opaque, you can't fetch page
// N+1 without page N.
func (u *Usecase) fetchAllPages(ctx context.Context, base ethkit.GetAssetTransfersParams, now time.Time) error {
	var wg sync.WaitGroup

	params := base
	for {
		if err := u.alchemySem.Acquire(ctx, 1); err != nil {
			return err
		}

		page, err := u.alchemy.GetAssetTransfers(ctx, params)
		u.alchemySem.Release(1)

		if err != nil {
			return err
		}

		for _, t := range page.Transfers {
			if err := u.txSvc.Upsert(ctx, alchemyToEntity(u.ULID(), t, now)); err != nil {
				u.log.Warn("history: upsert tx failed", "hash", t.Hash, "error", err)
				continue
			}

			hash := t.Hash

			wg.Add(1)

			go func() {
				defer wg.Done()

				// Detached context — gas-fee enrichment must survive
				// the sync context being canceled mid-page. Acquire
				// the semaphore on the detached ctx so a canceled
				// parent doesn't poison this branch.
				bgCtx := context.Background()
				if err := u.alchemySem.Acquire(bgCtx, 1); err != nil {
					return
				}
				defer u.alchemySem.Release(1)

				u.enrichGasFee(bgCtx, hash)
			}()
		}

		if page.PageKey == "" {
			break
		}

		params.PageKey = page.PageKey
	}

	wg.Wait()

	return nil
}

// enrichGasFee fetches the receipt for hash and stores gas_fee_eth in the DB.
// It is a best-effort call — errors are only logged.
func (u *Usecase) enrichGasFee(ctx context.Context, hash string) {
	receipt, found, err := u.eth.GetReceipt(ctx, hash)
	if err != nil {
		u.log.Warn("history: get receipt failed", "hash", hash, "error", err)
		return
	}

	if !found {
		return // tx not yet mined (shouldn't happen for historical txs)
	}

	// Format ETH gas cost with 8 decimal places, e.g. "0.00004200".
	gasFeeEth := receipt.GasCost.ToETH().StringFixed(8)

	if err := u.txSvc.UpdateGasFees(ctx, hash, gasFeeEth, ""); err != nil {
		u.log.Warn("history: update gas fees failed", "hash", hash, "error", err)
	}
}

func alchemyToEntity(id string, t ethkit.AssetTransfer, now time.Time) *entity.Transaction {
	return &entity.Transaction{
		ID:          id,
		UniqueID:    t.UniqueID,
		Hash:        t.Hash,
		From:        t.From,
		To:          t.To,
		Value:       t.Value,
		Asset:       normalizeAsset(t.Asset),
		Category:    t.Category,
		BlockNumber: t.BlockNumber,
		Timestamp:   t.Timestamp,
		CachedAt:    now,
	}
}
