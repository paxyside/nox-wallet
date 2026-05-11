package watcher

import "testing"

// emittedSet is the FIFO-bounded dedup cache that keeps `processTick`
// from re-emitting hashes whose lookback window overlapped with a
// previous tick. Boundary semantics matter: oldest entry must be
// evicted when capacity is reached, and re-adding an existing hash
// must NOT bump it forward (otherwise a hot-hash repeatedly seen in
// the lookback window keeps refreshing its slot and the FIFO degrades
// to LRU).
func TestEmittedSet_FIFOEviction(t *testing.T) {
	s := newEmittedSet(3)

	s.add("a")
	s.add("b")
	s.add("c")

	if !s.has("a") || !s.has("b") || !s.has("c") {
		t.Fatalf("first three adds must be present")
	}

	// d evicts a (oldest), b/c stay
	s.add("d")
	if s.has("a") {
		t.Fatalf("a should be evicted as oldest")
	}

	if !s.has("b") || !s.has("c") || !s.has("d") {
		t.Fatalf("b/c/d must remain")
	}
}

func TestEmittedSet_AddIdempotent(t *testing.T) {
	s := newEmittedSet(3)

	s.add("a")
	s.add("a")
	s.add("a")

	// re-adding the same hash three times mustn't push out future
	// slots — set still has room for two more
	s.add("b")
	s.add("c")

	if !s.has("a") || !s.has("b") || !s.has("c") {
		t.Fatalf("idempotent add: a/b/c all present, got a=%v b=%v c=%v",
			s.has("a"), s.has("b"), s.has("c"))
	}

	// adding a fourth fresh hash now evicts a (still the oldest by
	// insertion order, even though we re-added it)
	s.add("d")
	if s.has("a") {
		t.Fatalf("a should be evicted, idempotent re-add must not refresh slot")
	}
}

func TestEmittedSet_HasMissing(t *testing.T) {
	s := newEmittedSet(2)
	if s.has("x") {
		t.Fatal("empty set must report missing")
	}
}
