// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isUnlockedHash() => r'8048bd85e4193e27a59c729030444e0fe5ac5757';

/// True after the user successfully authenticates on startup.
///
/// Copied from [IsUnlocked].
@ProviderFor(IsUnlocked)
final isUnlockedProvider = NotifierProvider<IsUnlocked, bool>.internal(
  IsUnlocked.new,
  name: r'isUnlockedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$isUnlockedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsUnlocked = Notifier<bool>;
String _$lockPromptPendingHash() => r'e1704984413844006010058536d3ca9cf05b7c51';

/// One-shot gate that controls whether the next LockScreen mount may
/// auto-prompt Touch ID.
///
/// - `build()` defaults to `true` so the **very first** launch greets the
///   user with a Touch ID prompt automatically.
/// - `IsUnlocked.lock()` flips it back to `true` whenever the wallet
///   re-locks (idle timeout, sidebar "Lock" button) — so a fresh lock
///   re-prompts once.
/// - LockScreen consumes (sets `false`) when it triggers the prompt.
///
/// This decouples the prompt from widget-mount events: macOS window
/// re-shows / mini ↔ full transitions remount LockScreen but don't
/// re-prompt because the flag is already consumed.
///
/// Copied from [LockPromptPending].
@ProviderFor(LockPromptPending)
final lockPromptPendingProvider = NotifierProvider<LockPromptPending, bool>.internal(
  LockPromptPending.new,
  name: r'lockPromptPendingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lockPromptPendingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LockPromptPending = Notifier<bool>;
String _$isMiniModeHash() => r'd99642f90485d1d4cf3ba7d9a164fff42f21305a';

/// True while the app is displaying the compact menu-bar mini widget.
///
/// Copied from [IsMiniMode].
@ProviderFor(IsMiniMode)
final isMiniModeProvider = AutoDisposeNotifierProvider<IsMiniMode, bool>.internal(
  IsMiniMode.new,
  name: r'isMiniModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$isMiniModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsMiniMode = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
