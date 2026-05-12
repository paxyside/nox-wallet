package grpc

import (
	"context"
	"testing"

	"google.golang.org/protobuf/proto"

	notificationentity "github.com/paxyside/nox-wallet/internal/domain/notification/entity"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	liblogger "github.com/paxyside/nox-wallet/pkg/logger"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbevent "github.com/paxyside/nox-wallet/proto/gen/go/wallet/event"
)

// Each stub embeds the corresponding usecase interface so it
// trivially satisfies the contract without listing every method.
// Methods we actually invoke are explicitly defined; everything else
// would fall through to the nil-interface inside the embedded field
// and panic — which is exactly what we want for "shouldn't be called"
// assertions.

type stubWallet struct{ walletUsecase }

func (stubWallet) LoadedAddress() ethkit.Address { return ethkit.ZeroAddress }

// stubNotification implements every method of `notificationUsecase`
// directly so it satisfies the interface without needing an embed.
type stubNotification struct {
	listResp      []*notificationentity.Notification
	markReadCalls []string
	markAllCalls  int
	clearAllCalls int
	settingsResp  *notificationentity.Settings
	updateArg     *notificationentity.Settings
}

func (s *stubNotification) List(_ context.Context, _ int) ([]*notificationentity.Notification, error) {
	return s.listResp, nil
}

func (s *stubNotification) MarkRead(_ context.Context, id string) error {
	s.markReadCalls = append(s.markReadCalls, id)
	return nil
}

func (s *stubNotification) MarkAllRead(context.Context) error {
	s.markAllCalls++
	return nil
}

func (s *stubNotification) ClearAll(context.Context) error {
	s.clearAllCalls++
	return nil
}

func (s *stubNotification) GetSettings(context.Context) (*notificationentity.Settings, error) {
	return s.settingsResp, nil
}

func (s *stubNotification) UpdateSettings(_ context.Context, in *notificationentity.Settings) error {
	s.updateArg = in
	return nil
}

func newTestHandler(opts ...func(*Handler)) *Handler {
	h := New(
		liblogger.New(),
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
		1, nil, "",
	)
	for _, o := range opts {
		o(h)
	}

	return h
}

// GetBalances must short-circuit when no wallet is loaded — otherwise
// it would hammer Alchemy with the zero address and pollute the
// watchlist with spam tokens. Regression: this guard was added after
// the initial release.
func TestGetBalances_ZeroAddress_ReturnsEmpty(t *testing.T) {
	h := newTestHandler(func(h *Handler) {
		h.wallet = stubWallet{}
	})

	resp, err := h.GetBalances(context.Background(), &pb.GetBalancesRequest{WithTokens: true})
	if err != nil {
		t.Fatalf("GetBalances error: %v", err)
	}

	if resp == nil {
		t.Fatal("response is nil")
	}

	// Empty response — no ETH balance, no tokens, no USD value.
	// We don't hit the wallet usecase or the token list, so all
	// fields stay at their zero values.
	if resp.GetEthBalance() != "" || resp.GetEthBalanceWei() != "" {
		t.Errorf("zero-address response must skip balance lookup; got eth=%q wei=%q",
			resp.GetEthBalance(), resp.GetEthBalanceWei())
	}

	if len(resp.GetTokens()) != 0 {
		t.Errorf("zero-address response must skip tokens; got %d", len(resp.GetTokens()))
	}
}

// Same regression for ListTokensWithBalances.
func TestListTokensWithBalances_ZeroAddress_ReturnsEmpty(t *testing.T) {
	h := newTestHandler(func(h *Handler) {
		h.wallet = stubWallet{}
	})

	resp, err := h.ListTokensWithBalances(context.Background(), &pb.ListTokensWithBalancesRequest{})
	if err != nil {
		t.Fatalf("ListTokensWithBalances error: %v", err)
	}

	if len(resp.GetTokens()) != 0 {
		t.Errorf("zero-address response must be empty; got %d tokens", len(resp.GetTokens()))
	}
}

func TestListNotifications_MapsToEnvelopes(t *testing.T) {
	// Build a single proto WalletEvent so we can verify round-trip.
	originalEvent := &pbevent.WalletEvent{
		Payload: &pbevent.WalletEvent_GasAlert{
			GasAlert: &pbevent.GasAlertEvent{CurrentGwei: "42"},
		},
	}

	payload, err := proto.Marshal(originalEvent)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	stub := &stubNotification{
		listResp: []*notificationentity.Notification{
			{ID: "row-1", Kind: 3, Payload: payload, IsRead: true},
		},
	}

	h := newTestHandler(func(h *Handler) { h.notification = stub })

	resp, err := h.ListNotifications(context.Background(), &pb.ListNotificationsRequest{})
	if err != nil {
		t.Fatalf("ListNotifications: %v", err)
	}

	if len(resp.GetItems()) != 1 {
		t.Fatalf("want 1 envelope, got %d", len(resp.GetItems()))
	}

	got := resp.GetItems()[0]
	if got.GetId() != "row-1" {
		t.Errorf("id mismatch: %q", got.GetId())
	}

	if !got.GetIsRead() {
		t.Error("is_read must propagate to envelope")
	}

	if got.GetEvent().GetGasAlert().GetCurrentGwei() != "42" {
		t.Errorf("payload not unmarshalled: %+v", got.GetEvent())
	}
}

func TestListNotifications_DropsCorruptRows(t *testing.T) {
	stub := &stubNotification{
		listResp: []*notificationentity.Notification{
			{ID: "good", Kind: 3, Payload: marshalGasAlert(t)},
			{ID: "bad", Kind: 3, Payload: []byte{0xFF, 0xFF, 0xFF}},
			{ID: "good2", Kind: 3, Payload: marshalGasAlert(t)},
		},
	}

	h := newTestHandler(func(h *Handler) { h.notification = stub })

	resp, err := h.ListNotifications(context.Background(), &pb.ListNotificationsRequest{})
	if err != nil {
		t.Fatalf("ListNotifications: %v", err)
	}

	// One bad row shouldn't poison the whole list — handler logs and
	// skips. So we should see exactly 2 envelopes, both good.
	if len(resp.GetItems()) != 2 {
		t.Fatalf("want 2 envelopes, got %d", len(resp.GetItems()))
	}

	if resp.GetItems()[0].GetId() != "good" || resp.GetItems()[1].GetId() != "good2" {
		t.Errorf("expected good/good2 order: got %+v", resp.GetItems())
	}
}

func TestMarkNotificationRead_ForwardsID(t *testing.T) {
	stub := &stubNotification{}
	h := newTestHandler(func(h *Handler) { h.notification = stub })

	if _, err := h.MarkNotificationRead(context.Background(),
		&pb.MarkNotificationReadRequest{Id: "abc"},
	); err != nil {
		t.Fatalf("MarkNotificationRead: %v", err)
	}

	if len(stub.markReadCalls) != 1 || stub.markReadCalls[0] != "abc" {
		t.Errorf("MarkRead routing wrong: %+v", stub.markReadCalls)
	}
}

func TestMarkAllNotificationsRead_Idempotent(t *testing.T) {
	stub := &stubNotification{}
	h := newTestHandler(func(h *Handler) { h.notification = stub })

	for range 3 {
		if _, err := h.MarkAllNotificationsRead(context.Background(),
			&pb.MarkAllNotificationsReadRequest{},
		); err != nil {
			t.Fatalf("MarkAll error: %v", err)
		}
	}

	if stub.markAllCalls != 3 {
		t.Errorf("usecase should be invoked once per RPC; got %d", stub.markAllCalls)
	}
}

func TestClearNotifications_WipesAll(t *testing.T) {
	stub := &stubNotification{}
	h := newTestHandler(func(h *Handler) { h.notification = stub })

	if _, err := h.ClearNotifications(context.Background(),
		&pb.ClearNotificationsRequest{},
	); err != nil {
		t.Fatalf("Clear: %v", err)
	}

	if stub.clearAllCalls != 1 {
		t.Errorf("ClearAll should be called once; got %d", stub.clearAllCalls)
	}
}

func TestGetNotificationSettings_ReturnsSettings(t *testing.T) {
	stub := &stubNotification{
		settingsResp: &notificationentity.Settings{
			PlaySound:      true,
			MacOSToasts:    false,
			AutoMarkRead:   true,
			AutoDeleteDays: 30,
		},
	}
	h := newTestHandler(func(h *Handler) { h.notification = stub })

	resp, err := h.GetNotificationSettings(context.Background(),
		&pb.GetNotificationSettingsRequest{},
	)
	if err != nil {
		t.Fatalf("Get: %v", err)
	}

	got := resp.GetSettings()
	if !got.GetPlaySound() {
		t.Error("PlaySound flag lost")
	}

	if got.GetMacosToasts() {
		t.Error("MacosToasts should be false")
	}

	if got.GetAutoDeleteDays() != 30 {
		t.Errorf("AutoDeleteDays mismatch: got %d", got.GetAutoDeleteDays())
	}
}

func TestUpdateNotificationSettings_RoundTrips(t *testing.T) {
	stub := &stubNotification{}
	h := newTestHandler(func(h *Handler) { h.notification = stub })

	if _, err := h.UpdateNotificationSettings(context.Background(),
		&pb.UpdateNotificationSettingsRequest{
			Settings: &pb.NotificationSettings{
				PlaySound:        true,
				MacosToasts:      true,
				MuteSystemAlerts: false,
				AutoDeleteDays:   7,
			},
		},
	); err != nil {
		t.Fatalf("Update: %v", err)
	}

	if stub.updateArg == nil {
		t.Fatal("usecase.UpdateSettings was not called")
	}

	if !stub.updateArg.PlaySound || !stub.updateArg.MacOSToasts || stub.updateArg.AutoDeleteDays != 7 {
		t.Errorf("settings not propagated: %+v", stub.updateArg)
	}
}

func marshalGasAlert(t *testing.T) []byte {
	t.Helper()

	out, err := proto.Marshal(&pbevent.WalletEvent{
		Payload: &pbevent.WalletEvent_GasAlert{
			GasAlert: &pbevent.GasAlertEvent{CurrentGwei: "10"},
		},
	})
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	return out
}
