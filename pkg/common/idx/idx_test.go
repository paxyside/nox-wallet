package idx

import "testing"

func TestGenerator_ProducesUnique(t *testing.T) {
	gen := New()

	if a, b := gen.UUID(), gen.UUID(); a == b {
		t.Error("UUIDs should be unique")
	}

	if a, b := gen.ULID(), gen.ULID(); a == b {
		t.Error("ULIDs should be unique")
	}
}

func TestGenerator_LengthsMatchSpec(t *testing.T) {
	gen := New()

	if got := len(gen.UUID()); got != 36 {
		t.Errorf("UUID length = %d, want 36", got)
	}

	if got := len(gen.ULID()); got != 26 {
		t.Errorf("ULID length = %d, want 26", got)
	}
}
