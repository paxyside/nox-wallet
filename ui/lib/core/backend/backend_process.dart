import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Manages the lifecycle of the embedded Go gRPC backend process.
///
/// Call [start] once at app startup and [stop] when the app exits.
/// In production the binary lives at `Contents/MacOS/backend` next to the
/// Flutter executable. In debug mode the class walks up the directory tree to
/// find `build/backend` at the project root.
class BackendProcess {
  BackendProcess._();

  static Process? _process;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  static Future<void> start() async {
    final binary = _findBinary();
    final config = _findConfig();
    final dataDir = await _ensureDataDir();

    debugPrint('[BackendProcess] starting $binary');

    _process = await Process.start(
      binary,
      ['--config', config, '--data-dir', dataDir],
      mode: ProcessStartMode.normal,
    );

    if (kDebugMode) {
      _process!.stdout
          .transform(const SystemEncoding().decoder)
          .listen((s) => debugPrint('[backend] $s'));
      _process!.stderr
          .transform(const SystemEncoding().decoder)
          .listen((s) => debugPrint('[backend:err] $s'));
    } else {
      // In release we still consume the streams so the OS pipe doesn't
      // fill up and stall the backend, but we drop the bytes. Listen-
      // and-ignore is the safe form: `Stream.drain<T>()` resolves with
      // the type-default which is null for non-nullable T like List<int>
      // — that would crash with a type-cast error in release-only.
      _process!.stdout.listen((_) {});
      _process!.stderr.listen((_) {});
    }

    await _waitForReady();
    debugPrint('[BackendProcess] ready on 127.0.0.1:50055');
  }

  static void stop() {
    _process?.kill(ProcessSignal.sigterm);
    _process = null;
  }

  // ---------------------------------------------------------------------------
  // Path resolution
  // ---------------------------------------------------------------------------

  static String _findBinary() {
    // Production / injected debug bundle: next to the Flutter executable.
    final execDir = File(Platform.resolvedExecutable).parent.path;
    final bundled = p.join(execDir, 'backend');
    if (File(bundled).existsSync()) return bundled;

    // Dev fallback: walk up to find <project-root>/build/backend.
    if (kDebugMode) {
      var dir = Directory(execDir);
      for (var i = 0; i < 14; i++) {
        final candidate = p.join(dir.path, 'build', 'backend');
        if (File(candidate).existsSync()) return candidate;
        final parent = dir.parent;
        if (parent.path == dir.path) break;
        dir = parent;
      }
    }

    throw StateError(
      'Backend binary not found at $bundled. '
      "Run 'task build:backend' first.",
    );
  }

  static String _findConfig() {
    // Production: config.yaml bundled in Contents/Resources/.
    final execDir = File(Platform.resolvedExecutable).parent.path;
    final resourcesConfig = p.normalize(
      p.join(execDir, '..', 'Resources', 'config.yaml'),
    );
    if (File(resourcesConfig).existsSync()) return resourcesConfig;

    // Dev fallback: walk up to find <project-root>/config.yaml.
    if (kDebugMode) {
      var dir = Directory(execDir);
      for (var i = 0; i < 14; i++) {
        final candidate = p.join(dir.path, 'config.yaml');
        if (File(candidate).existsSync()) return candidate;
        final parent = dir.parent;
        if (parent.path == dir.path) break;
        dir = parent;
      }
    }

    throw StateError('config.yaml not found near $resourcesConfig');
  }

  static Future<String> _ensureDataDir() async {
    final home = Platform.environment['HOME'] ?? '/tmp';
    final dir = Directory(
      p.join(home, 'Library', 'Application Support', 'WalletApp'),
    );
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir.path;
  }

  // ---------------------------------------------------------------------------
  // Readiness probe
  // ---------------------------------------------------------------------------

  static Future<void> _waitForReady({int maxAttempts = 40}) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final sock = await Socket.connect(
          '127.0.0.1',
          50055,
          timeout: const Duration(milliseconds: 300),
        );
        await sock.close();
        return;
      } on Object catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }
    throw StateError('Backend did not become ready within timeout');
  }
}
