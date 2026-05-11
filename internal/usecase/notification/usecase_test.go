package notification

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/paxyside/nox-wallet/internal/domain/notification/entity"
	"github.com/paxyside/nox-wallet/internal/usecase"
)

// fakeRepo is a hand-rolled stub matching the Repository contract.
// Records every call so tests can assert ordering, arguments, and
// arity. Failure injection: set the *Err fields to return errors
// from specific methods.
type fakeRepo struct {
	notifications []*entity.Notification
	settings      *entity.Settings

	insertErr     error
	pruneErr      error
	pruneCalled   int
	deleteOldErr  error
	deleteOldCall int
	deleteOldRows int64

	markReadCalls    []string
	markAllReadCalls int
	deleteAllCalls   int

	getSettingsErr    error
	updateSettingsArg *entity.Settings
}

func (f *fakeRepo) Insert(_ context.Context, n *entity.Notification) error {
	if f.insertErr != nil {
		return f.insertErr
	}

	f.notifications = append(f.notifications, n)

	return nil
}

func (f *fakeRepo) List(_ context.Context, limit int) ([]*entity.Notification, error) {
	if limit <= 0 || limit >= len(f.notifications) {
		return f.notifications, nil
	}

	return f.notifications[:limit], nil
}

func (f *fakeRepo) PruneOlderThan(_ context.Context, _ int) error {
	f.pruneCalled++
	return f.pruneErr
}

func (f *fakeRepo) MarkRead(_ context.Context, id string) error {
	f.markReadCalls = append(f.markReadCalls, id)
	return nil
}

func (f *fakeRepo) MarkAllRead(_ context.Context) error {
	f.markAllReadCalls++
	return nil
}

func (f *fakeRepo) DeleteAll(_ context.Context) error {
	f.deleteAllCalls++
	return nil
}

func (f *fakeRepo) DeleteOlderThanDays(_ context.Context, _ int32) (int64, error) {
	f.deleteOldCall++
	return f.deleteOldRows, f.deleteOldErr
}

func (f *fakeRepo) GetSettings(_ context.Context) (*entity.Settings, error) {
	if f.getSettingsErr != nil {
		return nil, f.getSettingsErr
	}

	return f.settings, nil
}

func (f *fakeRepo) UpdateSettings(_ context.Context, s *entity.Settings) error {
	f.updateSettingsArg = s
	return nil
}

// stubIDx + stubClock — minimal BaseUsecase deps. Deterministic IDs
// and timestamps simplify assertions.
type stubIDx struct{ next int }

func (s *stubIDx) UUID() string {
	s.next++
	return "uuid-stub"
}

func (s *stubIDx) ULID() string {
	s.next++
	return "ulid-stub"
}

type stubClock struct{ now time.Time }

func (c stubClock) Now() time.Time      { return c.now }
func (c stubClock) NowUTC() time.Time   { return c.now.UTC() }
func (c stubClock) NowUnix() int64      { return c.now.Unix() }
func (c stubClock) NowUnixMilli() int64 { return c.now.UnixMilli() }
func (c stubClock) NowUnixMicro() int64 { return c.now.UnixMicro() }
func (c stubClock) NowUnixNano() int64  { return c.now.UnixNano() }

type silentLog struct{}

func (silentLog) Debug(string, ...any)                         {}
func (silentLog) Info(string, ...any)                          {}
func (silentLog) Warn(string, ...any)                          {}
func (silentLog) Error(string, ...any)                         {}
func (silentLog) DebugContext(context.Context, string, ...any) {}
func (silentLog) InfoContext(context.Context, string, ...any)  {}
func (silentLog) WarnContext(context.Context, string, ...any)  {}
func (silentLog) ErrorContext(context.Context, string, ...any) {}

func newTestUsecase(repo Repository) *Usecase {
	base := usecase.NewBaseUsecase(&stubIDx{}, stubClock{now: time.Unix(1_700_000_000, 0).UTC()})
	return New(base, silentLog{}, repo)
}

func TestSave_PersistsAndPrunes(t *testing.T) {
	repo := &fakeRepo{}
	uc := newTestUsecase(repo)

	id, err := uc.Save(context.Background(), 7, "0xhash", []byte("payload"), false)
	if err != nil {
		t.Fatalf("Save error: %v", err)
	}

	if id != "ulid-stub" {
		t.Errorf("want id from BaseUsecase, got %q", id)
	}

	if len(repo.notifications) != 1 {
		t.Fatalf("want 1 notification persisted, got %d", len(repo.notifications))
	}

	got := repo.notifications[0]
	if got.Kind != 7 || got.TxHash != "0xhash" || got.IsOurs {
		t.Errorf("notification fields wrong: %+v", got)
	}

	if got.IsRead {
		t.Error("default settings → is_read should be false")
	}

	if repo.pruneCalled != 1 {
		t.Errorf("Save must prune; calls=%d", repo.pruneCalled)
	}
}

func TestSave_AutoMarkRead(t *testing.T) {
	repo := &fakeRepo{
		settings: &entity.Settings{AutoMarkRead: true},
	}
	uc := newTestUsecase(repo)

	if _, err := uc.Save(context.Background(), 1, "", nil, false); err != nil {
		t.Fatalf("Save error: %v", err)
	}

	if !repo.notifications[0].IsRead {
		t.Error("AutoMarkRead=true → row should land already read")
	}
}

func TestSave_TriggersAutoDeleteSweep(t *testing.T) {
	repo := &fakeRepo{
		settings:      &entity.Settings{AutoDeleteDays: 30},
		deleteOldRows: 5,
	}
	uc := newTestUsecase(repo)

	if _, err := uc.Save(context.Background(), 1, "", nil, false); err != nil {
		t.Fatalf("Save error: %v", err)
	}

	if repo.deleteOldCall != 1 {
		t.Errorf("AutoDeleteDays>0 must trigger DeleteOlderThanDays; got %d calls",
			repo.deleteOldCall)
	}
}

func TestSave_NoSweepWhenAutoDeleteDisabled(t *testing.T) {
	repo := &fakeRepo{
		settings: &entity.Settings{AutoDeleteDays: 0},
	}
	uc := newTestUsecase(repo)

	if _, err := uc.Save(context.Background(), 1, "", nil, false); err != nil {
		t.Fatalf("Save error: %v", err)
	}

	if repo.deleteOldCall != 0 {
		t.Errorf("AutoDeleteDays=0 must NOT call DeleteOlderThanDays; got %d calls",
			repo.deleteOldCall)
	}
}

func TestSave_PruneFailureIsNonFatal(t *testing.T) {
	repo := &fakeRepo{pruneErr: errors.New("prune broke")}
	uc := newTestUsecase(repo)

	id, err := uc.Save(context.Background(), 1, "", nil, false)
	if err != nil {
		t.Fatalf("Save must not fail when prune fails (just log): %v", err)
	}

	if id == "" {
		t.Error("Save still returned an empty ID")
	}
}

func TestSave_InsertFailurePropagates(t *testing.T) {
	repo := &fakeRepo{insertErr: errors.New("disk full")}
	uc := newTestUsecase(repo)

	id, err := uc.Save(context.Background(), 1, "", nil, false)
	if err == nil {
		t.Fatal("Insert error should propagate to caller")
	}

	if id != "" {
		t.Errorf("ID should be empty on insert failure, got %q", id)
	}
}

func TestMarkReadAndAllAndClear(t *testing.T) {
	repo := &fakeRepo{}
	uc := newTestUsecase(repo)

	_ = uc.MarkRead(context.Background(), "abc")
	_ = uc.MarkRead(context.Background(), "xyz")
	_ = uc.MarkAllRead(context.Background())
	_ = uc.ClearAll(context.Background())

	if len(repo.markReadCalls) != 2 || repo.markReadCalls[0] != "abc" {
		t.Errorf("MarkRead routing wrong: %+v", repo.markReadCalls)
	}

	if repo.markAllReadCalls != 1 {
		t.Errorf("MarkAllRead should be called once, got %d", repo.markAllReadCalls)
	}

	if repo.deleteAllCalls != 1 {
		t.Errorf("ClearAll should be called once, got %d", repo.deleteAllCalls)
	}
}

func TestGetSettings_DefaultsOnRepoErr(t *testing.T) {
	// When the storage layer can't return a row at all we'd rather
	// surface a sensible default than 500 the request — the user can
	// still operate the app while we figure out what's wrong.
	repo := &fakeRepo{getSettingsErr: errors.New("disk full")}
	uc := newTestUsecase(repo)

	_, err := uc.GetSettings(context.Background())
	if err == nil {
		t.Fatal("repo error must propagate (not silently masked)")
	}
}

func TestGetSettings_PassesThrough(t *testing.T) {
	repo := &fakeRepo{
		settings: &entity.Settings{PlaySound: true, MacOSToasts: false, AutoDeleteDays: 7},
	}
	uc := newTestUsecase(repo)

	got, err := uc.GetSettings(context.Background())
	if err != nil {
		t.Fatalf("GetSettings: %v", err)
	}

	if got.AutoDeleteDays != 7 || !got.PlaySound || got.MacOSToasts {
		t.Errorf("settings round-trip wrong: %+v", got)
	}
}

func TestUpdateSettings_StampsUpdatedAt(t *testing.T) {
	now := time.Unix(1_700_000_000, 0).UTC()
	repo := &fakeRepo{}
	uc := New(
		usecase.NewBaseUsecase(&stubIDx{}, stubClock{now: now}),
		silentLog{},
		repo,
	)

	in := &entity.Settings{PlaySound: true}
	if err := uc.UpdateSettings(context.Background(), in); err != nil {
		t.Fatalf("UpdateSettings: %v", err)
	}

	if repo.updateSettingsArg == nil {
		t.Fatal("repo.UpdateSettings was not called")
	}

	if !repo.updateSettingsArg.UpdatedAt.Equal(now) {
		t.Errorf("UpdatedAt not stamped from clock: got %v, want %v",
			repo.updateSettingsArg.UpdatedAt, now)
	}
}

func TestSweepOnStartup_NoOpWhenDisabled(t *testing.T) {
	repo := &fakeRepo{settings: &entity.Settings{AutoDeleteDays: 0}}
	uc := newTestUsecase(repo)

	uc.SweepOnStartup(context.Background())

	if repo.deleteOldCall != 0 {
		t.Errorf("AutoDeleteDays=0 → SweepOnStartup must skip; calls=%d",
			repo.deleteOldCall)
	}
}

func TestSweepOnStartup_RunsWhenEnabled(t *testing.T) {
	repo := &fakeRepo{
		settings:      &entity.Settings{AutoDeleteDays: 90},
		deleteOldRows: 3,
	}
	uc := newTestUsecase(repo)

	uc.SweepOnStartup(context.Background())

	if repo.deleteOldCall != 1 {
		t.Errorf("SweepOnStartup must call DeleteOlderThanDays once; got %d",
			repo.deleteOldCall)
	}
}

func TestSweepOnStartup_SwallowsRepoErr(t *testing.T) {
	repo := &fakeRepo{
		settings:     &entity.Settings{AutoDeleteDays: 7},
		deleteOldErr: errors.New("disk full"),
	}
	uc := newTestUsecase(repo)

	// Should not panic, should not propagate — sweep is best-effort.
	uc.SweepOnStartup(context.Background())
}
