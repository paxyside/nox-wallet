// This is a generated file - do not edit.
//
// Generated from wallet/token/token.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class WatchedToken extends $pb.GeneratedMessage {
  factory WatchedToken({
    $core.String? id,
    $core.String? address,
    $core.String? symbol,
    $core.String? name,
    $core.int? decimals,
    $0.Timestamp? addedAt,
    $core.bool? isPinned,
    $core.bool? isHidden,
    $core.String? logoUrl,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (address != null) result.address = address;
    if (symbol != null) result.symbol = symbol;
    if (name != null) result.name = name;
    if (decimals != null) result.decimals = decimals;
    if (addedAt != null) result.addedAt = addedAt;
    if (isPinned != null) result.isPinned = isPinned;
    if (isHidden != null) result.isHidden = isHidden;
    if (logoUrl != null) result.logoUrl = logoUrl;
    return result;
  }

  WatchedToken._();

  factory WatchedToken.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchedToken.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchedToken',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.token'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'symbol')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aI(5, _omitFieldNames ? '' : 'decimals', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'addedAt',
        subBuilder: $0.Timestamp.create)
    ..aOB(7, _omitFieldNames ? '' : 'isPinned')
    ..aOB(8, _omitFieldNames ? '' : 'isHidden')
    ..aOS(9, _omitFieldNames ? '' : 'logoUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchedToken clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchedToken copyWith(void Function(WatchedToken) updates) =>
      super.copyWith((message) => updates(message as WatchedToken))
          as WatchedToken;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchedToken create() => WatchedToken._();
  @$core.override
  WatchedToken createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchedToken getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchedToken>(create);
  static WatchedToken? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get symbol => $_getSZ(2);
  @$pb.TagNumber(3)
  set symbol($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSymbol() => $_has(2);
  @$pb.TagNumber(3)
  void clearSymbol() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get decimals => $_getIZ(4);
  @$pb.TagNumber(5)
  set decimals($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDecimals() => $_has(4);
  @$pb.TagNumber(5)
  void clearDecimals() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get addedAt => $_getN(5);
  @$pb.TagNumber(6)
  set addedAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAddedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureAddedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.bool get isPinned => $_getBF(6);
  @$pb.TagNumber(7)
  set isPinned($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsPinned() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsPinned() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isHidden => $_getBF(7);
  @$pb.TagNumber(8)
  set isHidden($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsHidden() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsHidden() => $_clearField(8);

  /// Logo URL — populated from the embedded Uniswap Default Token
  /// List when the contract is verified there. Empty for unverified
  /// tokens; UI falls back to a letter avatar.
  @$pb.TagNumber(9)
  $core.String get logoUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set logoUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLogoUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearLogoUrl() => $_clearField(9);
}

/// Market snapshot for one token (may be empty if CoinGecko unavailable)
class TokenMarketData extends $pb.GeneratedMessage {
  factory TokenMarketData({
    $core.String? priceUsd,
    $core.String? change24hPct,
    $core.bool? changePositive,
    $core.Iterable<$core.double>? sparkline7d,
    $core.Iterable<$core.double>? sparkline30d,
  }) {
    final result = create();
    if (priceUsd != null) result.priceUsd = priceUsd;
    if (change24hPct != null) result.change24hPct = change24hPct;
    if (changePositive != null) result.changePositive = changePositive;
    if (sparkline7d != null) result.sparkline7d.addAll(sparkline7d);
    if (sparkline30d != null) result.sparkline30d.addAll(sparkline30d);
    return result;
  }

  TokenMarketData._();

  factory TokenMarketData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TokenMarketData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TokenMarketData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.token'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'priceUsd')
    ..aOS(2, _omitFieldNames ? '' : 'change24hPct', protoName: 'change_24h_pct')
    ..aOB(3, _omitFieldNames ? '' : 'changePositive')
    ..p<$core.double>(
        4, _omitFieldNames ? '' : 'sparkline7d', $pb.PbFieldType.KD,
        protoName: 'sparkline_7d')
    ..p<$core.double>(
        5, _omitFieldNames ? '' : 'sparkline30d', $pb.PbFieldType.KD,
        protoName: 'sparkline_30d')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenMarketData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenMarketData copyWith(void Function(TokenMarketData) updates) =>
      super.copyWith((message) => updates(message as TokenMarketData))
          as TokenMarketData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenMarketData create() => TokenMarketData._();
  @$core.override
  TokenMarketData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TokenMarketData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TokenMarketData>(create);
  static TokenMarketData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get priceUsd => $_getSZ(0);
  @$pb.TagNumber(1)
  set priceUsd($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPriceUsd() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriceUsd() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get change24hPct => $_getSZ(1);
  @$pb.TagNumber(2)
  set change24hPct($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChange24hPct() => $_has(1);
  @$pb.TagNumber(2)
  void clearChange24hPct() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get changePositive => $_getBF(2);
  @$pb.TagNumber(3)
  set changePositive($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChangePositive() => $_has(2);
  @$pb.TagNumber(3)
  void clearChangePositive() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get sparkline7d => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.double> get sparkline30d => $_getList(4);
}

class WatchedTokenWithBalance extends $pb.GeneratedMessage {
  factory WatchedTokenWithBalance({
    WatchedToken? token,
    $core.String? balance,
    $core.String? balanceUsd,
    TokenMarketData? market,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (balance != null) result.balance = balance;
    if (balanceUsd != null) result.balanceUsd = balanceUsd;
    if (market != null) result.market = market;
    return result;
  }

  WatchedTokenWithBalance._();

  factory WatchedTokenWithBalance.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchedTokenWithBalance.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchedTokenWithBalance',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.token'),
      createEmptyInstance: create)
    ..aOM<WatchedToken>(1, _omitFieldNames ? '' : 'token',
        subBuilder: WatchedToken.create)
    ..aOS(2, _omitFieldNames ? '' : 'balance')
    ..aOS(3, _omitFieldNames ? '' : 'balanceUsd')
    ..aOM<TokenMarketData>(4, _omitFieldNames ? '' : 'market',
        subBuilder: TokenMarketData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchedTokenWithBalance clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchedTokenWithBalance copyWith(
          void Function(WatchedTokenWithBalance) updates) =>
      super.copyWith((message) => updates(message as WatchedTokenWithBalance))
          as WatchedTokenWithBalance;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchedTokenWithBalance create() => WatchedTokenWithBalance._();
  @$core.override
  WatchedTokenWithBalance createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchedTokenWithBalance getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchedTokenWithBalance>(create);
  static WatchedTokenWithBalance? _defaultInstance;

  @$pb.TagNumber(1)
  WatchedToken get token => $_getN(0);
  @$pb.TagNumber(1)
  set token(WatchedToken value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
  @$pb.TagNumber(1)
  WatchedToken ensureToken() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get balance => $_getSZ(1);
  @$pb.TagNumber(2)
  set balance($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalance() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get balanceUsd => $_getSZ(2);
  @$pb.TagNumber(3)
  set balanceUsd($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBalanceUsd() => $_has(2);
  @$pb.TagNumber(3)
  void clearBalanceUsd() => $_clearField(3);

  @$pb.TagNumber(4)
  TokenMarketData get market => $_getN(3);
  @$pb.TagNumber(4)
  set market(TokenMarketData value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMarket() => $_has(3);
  @$pb.TagNumber(4)
  void clearMarket() => $_clearField(4);
  @$pb.TagNumber(4)
  TokenMarketData ensureMarket() => $_ensure(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
