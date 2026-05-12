import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/foundation.dart';

/// Sparkle-backed auto-update wrapper.
///
/// All configuration that varies per build (feed URL, public key,
/// check interval) lives in `ui/macos/Runner/Info.plist`. This class
/// is the Dart-side glue: it kicks off the very first check at boot
/// and exposes a "Check for updates now" entry-point for Settings.
///
/// Update flow when a new release is available:
///
///   1. Sparkle (running on a background queue) fetches the appcast
///      URL stamped in Info.plist (`SUFeedURL`).
///   2. The fetched XML lists the latest version + DMG URL + an
///      EdDSA signature (`sparkle:edSignature`) that CI computed
///      with the private key stored in the GitHub Secret
///      `SPARKLE_ED_PRIVATE_KEY`.
///   3. Sparkle verifies the signature against the public key
///      baked into the bundle (`SUPublicEDKey` in Info.plist). If
///      it mismatches, the update is rejected — protects against
///      a tampered DMG or a hijacked appcast URL.
///   4. User confirms in the dialog. Sparkle downloads, swaps the
///      bundle atomically (same install path, so macOS quarantine
///      / Gatekeeper approval state is inherited), and relaunches.
///
/// `auto_updater` only ships an integration for macOS and Windows.
/// On other platforms (`flutter test` headless on Linux, for
/// instance) the SDK no-ops gracefully — every call early-returns,
/// so we can leave the wiring unconditional.
class UpdateService {
  const UpdateService._();

  /// Wire the feed URL + check cadence and let Sparkle take it from
  /// there. Idempotent — calling twice is a no-op the second time
  /// (the values are already set on the native side).
  static Future<void> init() async {
    // `auto_updater` plugin throws if invoked on Linux; we ship a
    // macOS app but `flutter test` runs the smoke test on whatever
    // the CI host happens to be. Guard accordingly.
    if (!_isSupported) return;

    try {
      // The feed URL is also in Info.plist, but setFeedURL lets us
      // override at runtime — useful for staging / debug builds in
      // the future. Today we pass the prod URL unconditionally.
      await autoUpdater.setFeedURL(_prodFeedURL);
      await autoUpdater.setScheduledCheckInterval(_checkIntervalSeconds);
    } on Object catch (e, st) {
      // A broken Sparkle config (missing pubkey, malformed appcast)
      // shouldn't crash the app — log + carry on. The user just
      // won't get auto-updates until the next launch.
      debugPrint('UpdateService.init: $e\n$st');
    }
  }

  /// User-triggered "Check for updates" — surfaces the Sparkle
  /// dialog regardless of whether a newer version exists. Use this
  /// for an explicit Settings button; the background check fires on
  /// the interval set in `init()`.
  static Future<void> checkNow() async {
    if (!_isSupported) return;

    try {
      await autoUpdater.checkForUpdates();
    } on Object catch (e, st) {
      debugPrint('UpdateService.checkNow: $e\n$st');
    }
  }

  static const String _prodFeedURL =
      'https://github.com/paxyside/nox-wallet/releases/latest/download/appcast.xml';

  static const int _checkIntervalSeconds = 3600;

  /// auto_updater integrates Sparkle (macOS) and WinSparkle
  /// (Windows). On Linux / iOS / Android it's a no-op shell — we
  /// short-circuit so test runs on a Linux CI host don't crash.
  static bool get _isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }
}
