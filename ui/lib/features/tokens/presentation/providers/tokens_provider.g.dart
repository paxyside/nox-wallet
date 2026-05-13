// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenRepositoryHash() => r'63ea81b0ea36071b88f85bdb03b3ba6697ea05f0';

/// See also [tokenRepository].
@ProviderFor(tokenRepository)
final tokenRepositoryProvider = AutoDisposeProvider<TokenRepository>.internal(
  tokenRepository,
  name: r'tokenRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TokenRepositoryRef = AutoDisposeProviderRef<TokenRepository>;
String _$filteredTokensHash() => r'0654eea82be158924348e6823adfcd04e647389f';

/// See also [filteredTokens].
@ProviderFor(filteredTokens)
final filteredTokensProvider = AutoDisposeProvider<List<WatchedToken>>.internal(
  filteredTokens,
  name: r'filteredTokensProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredTokensHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTokensRef = AutoDisposeProviderRef<List<WatchedToken>>;
String _$totalPortfolioValueHash() => r'3d0521bfd292bf76ed5976f34c159931d2e97cea';

/// See also [totalPortfolioValue].
@ProviderFor(totalPortfolioValue)
final totalPortfolioValueProvider = AutoDisposeProvider<String>.internal(
  totalPortfolioValue,
  name: r'totalPortfolioValueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalPortfolioValueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalPortfolioValueRef = AutoDisposeProviderRef<String>;
String _$tokensSortHash() => r'7c338b251e613672a5db1f2c972ad6e0008e1b76';

/// See also [TokensSort].
@ProviderFor(TokensSort)
final tokensSortProvider = AutoDisposeNotifierProvider<TokensSort, TokenSortField>.internal(
  TokensSort.new,
  name: r'tokensSortProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$tokensSortHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokensSort = AutoDisposeNotifier<TokenSortField>;
String _$tokensSearchHash() => r'5f7e467ea01792728934cb31d9ab89626446793e';

/// See also [TokensSearch].
@ProviderFor(TokensSearch)
final tokensSearchProvider = AutoDisposeNotifierProvider<TokensSearch, String>.internal(
  TokensSearch.new,
  name: r'tokensSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokensSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokensSearch = AutoDisposeNotifier<String>;
String _$tokensVisibilityFilterHash() => r'74c5508119d6f4d75db24de1debb4c1c10c16ea6';

/// See also [TokensVisibilityFilter].
@ProviderFor(TokensVisibilityFilter)
final tokensVisibilityFilterProvider =
    AutoDisposeNotifierProvider<TokensVisibilityFilter, TokenVisibility>.internal(
      TokensVisibilityFilter.new,
      name: r'tokensVisibilityFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tokensVisibilityFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TokensVisibilityFilter = AutoDisposeNotifier<TokenVisibility>;
String _$tokensNotifierHash() => r'4de11fe7638a068e0ef8c74c0950b4ca4940c1ac';

/// See also [TokensNotifier].
@ProviderFor(TokensNotifier)
final tokensNotifierProvider = AsyncNotifierProvider<TokensNotifier, List<WatchedToken>>.internal(
  TokensNotifier.new,
  name: r'tokensNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokensNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokensNotifier = AsyncNotifier<List<WatchedToken>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
