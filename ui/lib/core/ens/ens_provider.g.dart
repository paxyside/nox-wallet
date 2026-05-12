// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ens_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ensRepositoryHash() => r'd75bc0a435e2eb5ea4a469a7495bff8a7e8b7639';

/// See also [ensRepository].
@ProviderFor(ensRepository)
final ensRepositoryProvider = AutoDisposeProvider<EnsRepository>.internal(
  ensRepository,
  name: r'ensRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ensRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnsRepositoryRef = AutoDisposeProviderRef<EnsRepository>;
String _$ensReverseHash() => r'90a5e4d996ea62bce4ab120a1740e3e7201b7a5d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Returns the primary ENS name for [address], or empty string when none is
/// registered. The result is cached for the app's lifetime — names are
/// effectively static and we'd rather avoid hammering the resolver every
/// time the History scrolls.
///
/// On error, returns an empty string (treated as "no record") so the UI
/// silently falls back to a truncated 0x… address.
///
/// Copied from [ensReverse].
@ProviderFor(ensReverse)
const ensReverseProvider = EnsReverseFamily();

/// Returns the primary ENS name for [address], or empty string when none is
/// registered. The result is cached for the app's lifetime — names are
/// effectively static and we'd rather avoid hammering the resolver every
/// time the History scrolls.
///
/// On error, returns an empty string (treated as "no record") so the UI
/// silently falls back to a truncated 0x… address.
///
/// Copied from [ensReverse].
class EnsReverseFamily extends Family<AsyncValue<String>> {
  /// Returns the primary ENS name for [address], or empty string when none is
  /// registered. The result is cached for the app's lifetime — names are
  /// effectively static and we'd rather avoid hammering the resolver every
  /// time the History scrolls.
  ///
  /// On error, returns an empty string (treated as "no record") so the UI
  /// silently falls back to a truncated 0x… address.
  ///
  /// Copied from [ensReverse].
  const EnsReverseFamily();

  /// Returns the primary ENS name for [address], or empty string when none is
  /// registered. The result is cached for the app's lifetime — names are
  /// effectively static and we'd rather avoid hammering the resolver every
  /// time the History scrolls.
  ///
  /// On error, returns an empty string (treated as "no record") so the UI
  /// silently falls back to a truncated 0x… address.
  ///
  /// Copied from [ensReverse].
  EnsReverseProvider call(String address) {
    return EnsReverseProvider(address);
  }

  @override
  EnsReverseProvider getProviderOverride(covariant EnsReverseProvider provider) {
    return call(provider.address);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies => _allTransitiveDependencies;

  @override
  String? get name => r'ensReverseProvider';
}

/// Returns the primary ENS name for [address], or empty string when none is
/// registered. The result is cached for the app's lifetime — names are
/// effectively static and we'd rather avoid hammering the resolver every
/// time the History scrolls.
///
/// On error, returns an empty string (treated as "no record") so the UI
/// silently falls back to a truncated 0x… address.
///
/// Copied from [ensReverse].
class EnsReverseProvider extends FutureProvider<String> {
  /// Returns the primary ENS name for [address], or empty string when none is
  /// registered. The result is cached for the app's lifetime — names are
  /// effectively static and we'd rather avoid hammering the resolver every
  /// time the History scrolls.
  ///
  /// On error, returns an empty string (treated as "no record") so the UI
  /// silently falls back to a truncated 0x… address.
  ///
  /// Copied from [ensReverse].
  EnsReverseProvider(String address)
    : this._internal(
        (ref) => ensReverse(ref as EnsReverseRef, address),
        from: ensReverseProvider,
        name: r'ensReverseProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ensReverseHash,
        dependencies: EnsReverseFamily._dependencies,
        allTransitiveDependencies: EnsReverseFamily._allTransitiveDependencies,
        address: address,
      );

  EnsReverseProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.address,
  }) : super.internal();

  final String address;

  @override
  Override overrideWith(FutureOr<String> Function(EnsReverseRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: EnsReverseProvider._internal(
        (ref) => create(ref as EnsReverseRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        address: address,
      ),
    );
  }

  @override
  FutureProviderElement<String> createElement() {
    return _EnsReverseProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnsReverseProvider && other.address == address;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, address.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EnsReverseRef on FutureProviderRef<String> {
  /// The parameter `address` of this provider.
  String get address;
}

class _EnsReverseProviderElement extends FutureProviderElement<String> with EnsReverseRef {
  _EnsReverseProviderElement(super.provider);

  @override
  String get address => (origin as EnsReverseProvider).address;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
