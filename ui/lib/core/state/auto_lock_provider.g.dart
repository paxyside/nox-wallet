// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_lock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autoLockSettingHash() => r'd1f99a7097214a7611f199f0b2c72b43fe498081';

/// User's preferred auto-lock idle timeout. Stored in-memory only — persists
/// for the app's lifetime, defaults to 5 minutes.
///
/// Copied from [AutoLockSetting].
@ProviderFor(AutoLockSetting)
final autoLockSettingProvider = NotifierProvider<AutoLockSetting, AutoLockTimeout>.internal(
  AutoLockSetting.new,
  name: r'autoLockSettingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoLockSettingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AutoLockSetting = Notifier<AutoLockTimeout>;
String _$lastActivityHash() => r'340dfce75b88963d13ad3c41c537485bd75b38f3';

/// Tracks the wall-clock time of the last user activity (pointer/key event).
///
/// Updated by a single global gesture detector wrapping the app shell.
/// The idle-tracker widget evaluates whether to lock based on this value.
///
/// Copied from [LastActivity].
@ProviderFor(LastActivity)
final lastActivityProvider = NotifierProvider<LastActivity, DateTime>.internal(
  LastActivity.new,
  name: r'lastActivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastActivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LastActivity = Notifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
