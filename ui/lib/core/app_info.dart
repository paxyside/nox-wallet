/// Static metadata about the running app.
///
/// [kAppVersion] mirrors the marketing version from the repo's
/// `/VERSION` file. **Do not edit by hand** — `task version:set`
/// updates this constant alongside VERSION, `ui/pubspec.yaml`, and
/// `config.example.yaml` so the four sources never drift.
///
/// Why a hand-rolled constant instead of `package_info_plus`:
///   - No new dependency in the bundle.
///   - Synchronous read (no FutureBuilder gymnastics in Settings).
///   - One source of truth driven by the existing version pipeline.
library;

const String kAppVersion = '0.8.0';
