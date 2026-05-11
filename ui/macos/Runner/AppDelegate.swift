import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard
      let controller = mainFlutterWindow?.contentViewController as? FlutterViewController
    else { return }

    // ── App icon channel ─────────────────────────────────────────────────────
    // Flutter calls setTheme(bool isDark) to swap the Dock icon in sync with
    // the in-app theme toggle, independently of the macOS system appearance.
    let channel = FlutterMethodChannel(
      name: "nox/app_icon",
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setTheme" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let isDark = call.arguments as? Bool ?? true
      let imageName = isDark ? "AppIconDark" : "AppIconLight"
      if let image = NSImage(named: imageName) {
        NSApp.applicationIconImage = image
      }
      result(nil)
    }

    // ── Sound channel ─────────────────────────────────────────────────────────
    // In-app notification chime. Played from Dart whenever a wallet event
    // hits the notification panel and the user has the "Sound" toggle on.
    // We deliberately don't ride on macOS's toast sound (presentSound on the
    // UNNotificationContent) because that double-plays when both the toast
    // and our chime are on — making the chime our single source of audio
    // means it works even if the user has macOS toasts disabled or the app
    // is foregrounded (where macOS often suppresses toast sound).
    //
    // Default sound is "Glass" — a short, distinct macOS system sound that
    // doesn't blend with browser / Slack notification chimes. Callers can
    // override by passing a name string (any NSSound system name works:
    // Glass, Ping, Pop, Tink, Hero, Funk, Frog, Basso, Blow, Bottle,
    // Morse, Purr, Sosumi, Submarine).
    let soundChannel = FlutterMethodChannel(
      name: "nox/sound",
      binaryMessenger: controller.engine.binaryMessenger
    )
    soundChannel.setMethodCallHandler { call, result in
      guard call.method == "playChime" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let args = call.arguments as? [String: Any]
      let name = (args?["name"] as? String) ?? "Glass"
      if let sound = NSSound(named: NSSound.Name(name)) {
        sound.play()
      }
      result(nil)
    }
  }

  // Keep the process alive when the user dismisses every window — Nox is
  // designed as a tray-resident app: red-cross / Cmd-W just hide the
  // window, and the menu-bar icon stays clickable to bring it back. Only
  // an explicit Cmd-Q (which goes through `terminate:` on
  // `NSApplication`) is a real quit.
  override func applicationShouldTerminateAfterLastWindowClosed(
    _ sender: NSApplication
  ) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(
    _ app: NSApplication
  ) -> Bool {
    return true
  }
}
