package watcher

import (
	"context"
	"testing"
	"time"

	"github.com/paxyside/nox-wallet/pkg/ethkit"
)

// stubEth embeds EthClient so we get nil-method fallbacks for
// everything we don't override. Tests only invoke
// RecentPendingForAddress; other methods will panic if accidentally
// reached, which is exactly the assertion we want.
type stubEth struct {
	EthClient

	pending []ethkit.PendingTx
}

func (s *stubEth) RecentPendingForAddress(_ ethkit.Address) []ethkit.PendingTx {
	return s.pending
}

// recordingSink stores every event that emitAndPersist's
// NotificationSink would have written. Tests only check the count
// and emit ordering — the proto payload is opaque here.
type recordingSink struct {
	saved []recorded
}

type recorded struct {
	hash string
	kind EventKind
}

func (r *recordingSink) Save(_ context.Context, kind EventKind, txHash string, _ []byte, _ bool) (string, error) {
	r.saved = append(r.saved, recorded{hash: txHash, kind: kind})
	return "stub-id", nil
}

// newProcessTickHarness wires a Usecase + sink + stub EthClient and
// returns helpers a test can drive directly. Tests that want to
// inspect emitted events should read sink.saved after each tick.
type harness struct {
	uc          *Usecase
	sink        *recordingSink
	eth         *stubEth
	subscribed  []WalletEvent
	emitted     *emittedSet
	deferred    map[string]time.Time
	maxDeferral time.Duration
}

func newHarness(t *testing.T) *harness {
	t.Helper()

	eth := &stubEth{}
	sink := &recordingSink{}

	// New takes a NotificationSink, our recording sink fits because
	// we declared NotificationSink as `Save(ctx, kind EventKind, ...)`.
	uc := New(noopLog{}, eth, &stubAddrProvider{}, sink)

	// Subscribe before the first tick so we can verify the broadcast
	// half (sink covers persistence half). Tests can poll subscribed
	// via a goroutine; we keep it simple here and read the channel
	// directly after each tick.
	ch, _ := uc.Subscribe()

	h := &harness{
		uc:          uc,
		sink:        sink,
		eth:         eth,
		emitted:     newEmittedSet(64),
		deferred:    map[string]time.Time{},
		maxDeferral: 30 * time.Second,
	}

	go func() {
		for ev := range ch {
			h.subscribed = append(h.subscribed, ev)
		}
	}()

	return h
}

type stubAddrProvider struct{}

func (stubAddrProvider) LoadedAddress() ethkit.Address {
	return ethkit.ZeroAddress
}

// makeLeg builds a synthetic ETH-only transfer (no Token) so the
// watcher's buildMovement path doesn't need a TokenMetadata stub.
// `legIdx` is appended to the UniqueID so multiple legs of the same
// hash don't get deduplicated by `groupByHash` — Alchemy mints unique
// IDs per leg in production for the same reason.
func makeLeg(hash, fromHex, toHex string, legIdx int) ethkit.AssetTransfer {
	from, _ := ethkit.NewAddress(fromHex)
	to, _ := ethkit.NewAddress(toHex)

	return ethkit.AssetTransfer{
		Hash:        hash,
		UniqueID:    hash + ":external:" + itoa(legIdx),
		From:        from,
		To:          to,
		Asset:       "ETH",
		BlockNumber: 1,
	}
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}

	const digits = "0123456789"

	var out []byte

	for i > 0 {
		out = append([]byte{digits[i%10]}, out...)
		i /= 10
	}

	return string(out)
}

// Tick 1 sees a fresh hash with both legs of a swap, complete role
// classification on first observation → emit immediately, no deferral.
func TestProcessTick_HappySwap(t *testing.T) {
	h := newHarness(t)
	wallet, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	router, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")

	h.eth.pending = []ethkit.PendingTx{
		{Hash: "0xswap", From: wallet, Kind: "swap"},
	}

	transfers := []ethkit.AssetTransfer{
		makeLeg("0xswap", wallet.Hex(), router.Hex(), 0), // out
		makeLeg("0xswap", router.Hex(), wallet.Hex(), 1), // in
	}

	h.uc.processTick(context.Background(), wallet, transfers,
		h.emitted, h.deferred, h.maxDeferral)

	if len(h.sink.saved) != 1 {
		t.Fatalf("want 1 emitted event, got %d", len(h.sink.saved))
	}

	if !h.emitted.has("0xswap") {
		t.Error("hash must be recorded in emittedSet after emit")
	}

	if _, deferred := h.deferred["0xswap"]; deferred {
		t.Error("happy-path swap should NOT be in deferred")
	}
}

// Tick 1 sees only the incoming leg of a pending-swap; should defer,
// not emit. Tick 2 sees both legs → emit.
func TestProcessTick_DeferredSwapResolvesOnSecondTick(t *testing.T) {
	h := newHarness(t)
	wallet, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	router, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")

	h.eth.pending = []ethkit.PendingTx{
		{Hash: "0xswap", From: wallet, Kind: "swap"},
	}

	// Tick 1: only incoming visible (Alchemy lag). Should defer.
	tick1 := []ethkit.AssetTransfer{
		makeLeg("0xswap", router.Hex(), wallet.Hex(), 0),
	}

	h.uc.processTick(context.Background(), wallet, tick1,
		h.emitted, h.deferred, h.maxDeferral)

	if len(h.sink.saved) != 0 {
		t.Errorf("incomplete swap on first tick must NOT emit; got %d events",
			len(h.sink.saved))
	}

	if _, deferred := h.deferred["0xswap"]; !deferred {
		t.Error("incomplete swap should be deferred for next tick")
	}

	// Tick 2: both legs now visible.
	tick2 := []ethkit.AssetTransfer{
		makeLeg("0xswap", wallet.Hex(), router.Hex(), 0),
		makeLeg("0xswap", router.Hex(), wallet.Hex(), 1),
	}

	h.uc.processTick(context.Background(), wallet, tick2,
		h.emitted, h.deferred, h.maxDeferral)

	if len(h.sink.saved) != 1 {
		t.Fatalf("second tick must emit complete swap; got %d events",
			len(h.sink.saved))
	}

	if _, stillDeferred := h.deferred["0xswap"]; stillDeferred {
		t.Error("deferred entry must be cleared after emit")
	}
}

// Pending-tracker tags this hash as a swap, but Alchemy never
// returns the second leg. After maxDeferral elapses we emit
// whatever's available — better wrong-classification than nothing.
func TestProcessTick_DeferralTimeoutEmitsIncomplete(t *testing.T) {
	h := newHarness(t)
	wallet, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	router, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")

	h.eth.pending = []ethkit.PendingTx{
		{Hash: "0xstuck", From: wallet, Kind: "swap"},
	}

	// Pre-populate deferred with a stale timestamp past the
	// deferral window.
	h.deferred["0xstuck"] = time.Now().Add(-time.Hour)

	transfers := []ethkit.AssetTransfer{
		makeLeg("0xstuck", router.Hex(), wallet.Hex(), 0),
	}

	h.uc.processTick(context.Background(), wallet, transfers,
		h.emitted, h.deferred, h.maxDeferral)

	if len(h.sink.saved) != 1 {
		t.Errorf("timeout must emit even incomplete swap; got %d events",
			len(h.sink.saved))
	}

	if _, stillDeferred := h.deferred["0xstuck"]; stillDeferred {
		t.Error("after timeout-emit, deferred must be cleared")
	}
}

// A regular Send tagged Kind="send" is genuinely single-leg — must
// emit immediately, never defer.
func TestProcessTick_SendKindEmitsImmediately(t *testing.T) {
	h := newHarness(t)
	wallet, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	peer, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")

	h.eth.pending = []ethkit.PendingTx{
		{Hash: "0xsend", From: wallet, Kind: "send"},
	}

	transfers := []ethkit.AssetTransfer{
		makeLeg("0xsend", wallet.Hex(), peer.Hex(), 0),
	}

	h.uc.processTick(context.Background(), wallet, transfers,
		h.emitted, h.deferred, h.maxDeferral)

	if len(h.sink.saved) != 1 {
		t.Errorf("send must emit on first tick; got %d events", len(h.sink.saved))
	}

	if _, deferred := h.deferred["0xsend"]; deferred {
		t.Error("Kind=send must never enter deferred map")
	}
}

// Hash already recorded in emittedSet from a prior tick (lookback
// overlap). Must skip — no double emit.
func TestProcessTick_DedupesViaEmittedSet(t *testing.T) {
	h := newHarness(t)
	wallet, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	peer, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")

	h.emitted.add("0xrepeat")

	transfers := []ethkit.AssetTransfer{
		makeLeg("0xrepeat", peer.Hex(), wallet.Hex(), 0),
	}

	h.uc.processTick(context.Background(), wallet, transfers,
		h.emitted, h.deferred, h.maxDeferral)

	if len(h.sink.saved) != 0 {
		t.Errorf("already-emitted hash must be skipped; got %d events",
			len(h.sink.saved))
	}
}

// External transaction (not in our pending tracker) — single leg,
// any role, emit immediately.
func TestProcessTick_ExternalReceiveEmits(t *testing.T) {
	h := newHarness(t)
	wallet, _ := ethkit.NewAddress("0x1111111111111111111111111111111111111111")
	peer, _ := ethkit.NewAddress("0x2222222222222222222222222222222222222222")

	// pending list is empty — this isn't our action.
	transfers := []ethkit.AssetTransfer{
		makeLeg("0xexternal", peer.Hex(), wallet.Hex(), 0),
	}

	h.uc.processTick(context.Background(), wallet, transfers,
		h.emitted, h.deferred, h.maxDeferral)

	if len(h.sink.saved) != 1 {
		t.Errorf("external receive must emit; got %d events", len(h.sink.saved))
	}
}
