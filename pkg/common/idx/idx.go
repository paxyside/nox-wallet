// Package idx generates UUID v4 and monotonic ULIDs for entity primary
// keys. The Generator is goroutine-safe; usecases hold a single
// instance and call ULID() / UUID() per row insertion.
package idx

import (
	"crypto/rand"
	"io"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/oklog/ulid/v2"
)

// Generator is the contract usecases consume — keeps the production
// generator and any test fakes interchangeable.
type Generator interface {
	UUID() string
	ULID() string
}

type generator struct {
	entropy io.Reader
	mu      sync.Mutex
}

// New returns a thread-safe Generator backed by crypto/rand entropy
// and monotonic ULIDs (lex-orderable within the same millisecond).
func New() Generator {
	return &generator{
		entropy: &lockedReader{r: ulid.Monotonic(rand.Reader, 0)},
	}
}

type lockedReader struct {
	mu sync.Mutex
	r  io.Reader
}

func (lr *lockedReader) Read(p []byte) (int, error) {
	lr.mu.Lock()
	defer lr.mu.Unlock()

	return lr.r.Read(p)
}

func (g *generator) UUID() string {
	return uuid.New().String()
}

func (g *generator) ULID() string {
	g.mu.Lock()
	defer g.mu.Unlock()

	return ulid.MustNew(ulid.Timestamp(time.Now()), g.entropy).String()
}
