package watcher

import "testing"

func TestTrimDecimalZeros(t *testing.T) {
	cases := []struct{ in, want string }{
		// Integers — trailing zeros are significant, must be untouched.
		// This is the regression: "1550" used to become "155".
		{"1550", "1550"},
		{"100", "100"},
		{"2000", "2000"},
		{"10", "10"},
		{"0", "0"},
		{"5", "5"},
		// Decimals — trailing zeros after the point are dropped.
		{"12.500000", "12.5"},
		{"100.000000", "100"},
		{"1.0", "1"},
		{"0.997501", "0.997501"},
		{"1550.50", "1550.5"},
	}

	for _, c := range cases {
		if got := trimDecimalZeros(c.in); got != c.want {
			t.Errorf("trimDecimalZeros(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}
