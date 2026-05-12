import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nox/core/backend/backend_process.dart';
import 'package:nox/core/network/grpc_client.dart';
import 'package:nox/core/router/router.dart';
import 'package:nox/core/services/app_icon_service.dart';
import 'package:nox/core/services/notification_history_provider.dart';
import 'package:nox/core/services/notification_service.dart';
import 'package:nox/core/services/notification_settings_provider.dart';
import 'package:nox/core/services/update_service.dart';
import 'package:nox/core/state/auth_provider.dart';
import 'package:nox/core/state/wallet_address_provider.dart';
import 'package:nox/core/theme/app_theme.dart';
import 'package:nox/core/theme/theme_provider.dart';
import 'package:nox/core/wallet_events/wallet_events_provider.dart';
import 'package:nox/core/widgets/idle_tracker.dart';
import 'package:nox/features/history/presentation/providers/history_provider.dart';
import 'package:nox/features/home/presentation/providers/home_provider.dart';
import 'package:nox/features/home/presentation/providers/recent_activity_provider.dart';
import 'package:nox/features/lock/presentation/screens/lock_screen.dart';
import 'package:nox/features/menubar/mini_widget.dart';
import 'package:nox/features/notifications/presentation/widgets/notification_center.dart';
import 'package:nox/features/tokens/presentation/providers/tokens_provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

// ---------------------------------------------------------------------------
// Full window / mini widget dimensions
// ---------------------------------------------------------------------------

const _fullSize = Size(1100, 720);
const _miniSize = Size(380, 660);

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Suppress noisy upstream Flutter macOS bug ────────────────────────────
  // HardwareKeyboard occasionally desyncs its `_pressedKeys` state when the
  // text-input focus jumps between TextField, dialogs, and the OS IME — most
  // visibly with the left Meta (Cmd) key. The framework asserts and prints a
  // huge stack trace per stray event but nothing actually breaks. Upstream
  // tracker: https://github.com/flutter/flutter/issues/136419. Until that is
  // fixed we filter only this exact assertion and let everything else through.
  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final msg = details.exception.toString();
    if (msg.contains('_pressedKeys.containsKey(event.physicalKey)') ||
        msg.contains(
          'A KeyDownEvent is dispatched, but the state shows that the physical key is already pressed',
        )) {
      return;
    }
    defaultOnError?.call(details);
  };

  // ── Window manager ───────────────────────────────────────────────────────
  // setPreventClose MUST be set before the window is shown — otherwise a
  // user who hits the red X faster than the post-show callback fires
  // bypasses our hide-instead-of-quit logic and the process exits. We
  // therefore `await` the readiness callback (the original code used
  // `unawaited(...)` which let runApp race ahead).
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: _fullSize,
      minimumSize: _fullSize,
      maximumSize: _fullSize,
      center: true,
      title: 'Nox',
      titleBarStyle: TitleBarStyle.normal,
    ),
    () async {
      await windowManager.setResizable(false);
      // PreventClose lets us intercept the native close button (and the
      // tray-click "hide" path) via onWindowClose; without this the OS
      // tears down the process and the tray icon vanishes.
      await windowManager.setPreventClose(true);
      await windowManager.show();
    },
  );

  // ── Tray icon — monochrome template image (auto-inverts for dark/light bar)
  await trayManager.setIcon('assets/images/tray_icon.png', isTemplate: true);
  await trayManager.setContextMenu(
    Menu(
      items: [
        MenuItem(key: 'open', label: 'Open Nox'),
        MenuItem.separator(),
        MenuItem(key: 'quit', label: 'Quit'),
      ],
    ),
  );

  // ── Backend / gRPC ───────────────────────────────────────────────────────
  await BackendProcess.start();
  GrpcClient.instance.init();
  await NotificationService.instance.init();

  // ── Sparkle auto-update ──────────────────────────────────────────────────
  // Fire-and-forget. UpdateService internally guards on platform and
  // swallows errors, so a misconfigured appcast / network glitch never
  // blocks app startup. The first scheduled check fires on Sparkle's
  // background queue per the interval baked into Info.plist.
  unawaited(UpdateService.init());

  runApp(const ProviderScope(child: WalletApp()));
}

// ---------------------------------------------------------------------------
// Root widget — handles all three states: locked / mini / full
// ---------------------------------------------------------------------------

class WalletApp extends ConsumerStatefulWidget {
  const WalletApp({super.key});

  @override
  ConsumerState<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends ConsumerState<WalletApp> with TrayListener, WindowListener {
  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);

    // Start balance watcher + notification history after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWatcher();
      _watchWalletExistence();
      ref
        // Kick-start the notification history so it listens from app launch.
        ..read(notificationHistoryProvider)
        // Eagerly load tokens + recent activity so they're ready when the user
        // lands on the home screen (without waiting to visit those tabs).
        ..read(tokensNotifierProvider)
        ..read(recentActivityProvider);

      // Sync Dock icon with the current theme immediately, then on every change.
      unawaited(AppIconService.setTheme(ref.read(themeModeNotifierProvider)));
      ref.listenManual<ThemeMode>(
        themeModeNotifierProvider,
        (prev, next) => unawaited(AppIconService.setTheme(next)),
      );
    });
  }

  // ── Wallet-existence watcher ─────────────────────────────────────────────
  // Several providers are keepAlive and were built BEFORE the user imported a
  // wallet — they returned empty results and stuck around. When a wallet
  // appears (or disappears), invalidate them so they re-fetch with the new
  // identity. Without this the Tokens screen and history list stayed empty
  // until the user manually pulled to refresh.
  ProviderSubscription<AsyncValue<bool>>? _walletExistsSub;

  void _watchWalletExistence() {
    bool? lastExists;
    _walletExistsSub = ref.listenManual<AsyncValue<bool>>(walletExistsProvider, (prev, next) {
      next.whenData((exists) {
        if (lastExists == exists) return;
        final wasExists = lastExists;
        lastExists = exists;
        _invalidateWalletScoped();

        // Going false→true means a brand-new wallet was just imported.
        // The backend kicks off an Alchemy sync that takes a few seconds
        // before ERC-20 tokens appear in the DB and history is populated.
        // The first invalidation above lands on still-empty data and the
        // keepAlive providers cache the empty list. We schedule a couple
        // of retries to catch the moment the seed actually completes.
        if (wasExists == false && exists) {
          // Importing/generating a wallet is itself proof of identity —
          // the user just supplied a mnemonic / private key / keystore
          // passphrase. Skip the post-startup Touch ID prompt that would
          // otherwise immediately greet them on the way back to the home
          // screen.
          ref.read(isUnlockedProvider.notifier).unlock();
          for (final delay in const [
            Duration(seconds: 2),
            Duration(seconds: 5),
            Duration(seconds: 10),
            Duration(seconds: 20),
            Duration(seconds: 30),
          ]) {
            Future.delayed(delay, () {
              if (!mounted) return;
              _invalidateWalletScoped();
            });
          }
        }
      });
    }, fireImmediately: true);
  }

  void _invalidateWalletScoped() {
    ref
      ..invalidate(walletAddressProvider)
      ..invalidate(tokensNotifierProvider)
      ..invalidate(homeDataProvider)
      ..invalidate(recentActivityProvider)
      ..invalidate(historyNotifierProvider);
  }

  @override
  void dispose() {
    _watcherSub?.close();
    _walletExistsSub?.close();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    BackendProcess.stop();
    super.dispose();
  }

  // ── Wallet events watcher ────────────────────────────────────────────────
  ProviderSubscription<AsyncValue<WalletEvent>>? _watcherSub;

  void _startWatcher() {
    _watcherSub = ref.listenManual<AsyncValue<WalletEvent>>(walletEventsProvider, (prev, next) {
      next.whenData((event) {
        // Refresh balances on any chain-state change.
        if (event.kind == WalletEventKind.transaction) {
          ref
            ..invalidate(homeDataProvider)
            ..invalidate(tokensNotifierProvider);
        }

        // OS notification — gated by the user's notification
        // settings (toasts on/off, mute system, play sound). Falls
        // back to defaults if the controller hasn't hydrated yet so
        // events that arrive in the first second after launch still
        // get surfaced rather than silently dropped.
        final settings =
            ref.read(notificationSettingsCtrlProvider).valueOrNull ??
            const NotificationSettings.defaults();
        unawaited(NotificationService.instance.notify(event, settings: settings));
      });
    }, fireImmediately: false);
  }

  // ── Tray events ──────────────────────────────────────────────────────────

  @override
  void onTrayIconMouseDown() => _toggleMini();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem item) {
    switch (item.key) {
      case 'open':
        unawaited(_openFull());
      case 'quit':
        // setPreventClose intercepts close-button → hide; Quit must
        // bypass that and actually exit. destroy() does so.
        unawaited(windowManager.destroy());
    }
  }

  // ── Window events ────────────────────────────────────────────────────────

  /// When the user clicks the red close button, hide instead of quit so
  /// the app keeps running in the tray. `setPreventClose(true)` (called
  /// at startup) makes this listener authoritative — without it, the OS
  /// would proceed with closing regardless of what we do here.
  @override
  Future<void> onWindowClose() async {
    await windowManager.hide();
  }

  // ── Mode switching ───────────────────────────────────────────────────────

  Future<void> _toggleMini() async {
    final isMini = ref.read(isMiniModeProvider);
    final isVisible = await windowManager.isVisible();

    if (isMini && isVisible) {
      // Mini is open → close it (hide window).
      await windowManager.hide();
      return;
    }

    if (!isMini) {
      // Currently in full mode — switch to mini.
      await _showMini();
    } else {
      // Currently in mini (but hidden) — show mini again.
      await windowManager.show();
      await windowManager.focus();
    }
  }

  Future<void> _showMini() async {
    ref.read(isMiniModeProvider.notifier).enter();

    await windowManager.setTitleBarStyle(TitleBarStyle.hidden, windowButtonVisibility: false);
    await windowManager.setSize(_miniSize);

    // Position just below tray icon (top-right corner).
    final trayBounds = await trayManager.getBounds();
    if (trayBounds != null) {
      await windowManager.setPosition(
        Offset(trayBounds.right - _miniSize.width, trayBounds.bottom + 4),
      );
    } else {
      // Fallback: position in top-right of screen.
      final display = await windowManager.getBounds();
      await windowManager.setPosition(Offset(display.right - _miniSize.width - 16, 32));
    }

    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _openFull() async {
    ref.read(isMiniModeProvider.notifier).exit();

    await windowManager.setTitleBarStyle(TitleBarStyle.normal, windowButtonVisibility: true);
    await windowManager.setMinimumSize(_fullSize);
    await windowManager.setMaximumSize(_fullSize);
    await windowManager.setSize(_fullSize);
    await windowManager.setResizable(false);
    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isUnlocked = ref.watch(isUnlockedProvider);
    final isMini = ref.watch(isMiniModeProvider);
    // Lock only protects an existing wallet — onboarding (no wallet yet) has
    // nothing sensitive to gate, so we skip the Touch ID prompt and let the
    // user set up their wallet first. We treat the loading state as "no
    // wallet yet" too: showing a Touch ID dialog before we even know whether
    // a wallet exists looks like a permission-grab on first run.
    final hasWallet = ref.watch(walletExistsProvider).valueOrNull ?? false;

    // ── Mini widget ──────────────────────────────────────────────────────
    if (isMini) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: MiniWidget(
          onOpenAt: (route) async {
            // Switch to full window first, then route once the router scope
            // exists. Reading the router synchronously after `_openFull` is
            // fine — the provider is keepAlive.
            await _openFull();
            if (!mounted) return;
            ref.read(routerProvider).go(route);
          },
          onOpenNotificationCenter: () async {
            // Same pattern as onOpenAt: ensure the full window scope
            // exists, then pop the modal on top of whatever route is
            // currently shown. We defer the modal-open into the next
            // frame so the router's Navigator (a different scope from
            // this MaterialApp) is mounted and we don't trip the
            // "BuildContext across async gap" lint.
            await _openFull();
            if (!mounted) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final navCtx = ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;
              if (navCtx == null) return;
              unawaited(showNotificationCenter(navCtx));
            });
          },
          onQuit: () => unawaited(windowManager.destroy()),
        ),
      );
    }

    // ── Lock screen ──────────────────────────────────────────────────────
    if (hasWallet && !isUnlocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const LockScreen(),
      );
    }

    // ── Full app ─────────────────────────────────────────────────────────
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Nox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => IdleTracker(child: child ?? const SizedBox.shrink()),
    );
  }
}
