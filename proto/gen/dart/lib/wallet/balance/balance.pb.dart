// This is a generated file - do not edit.
//
// Generated from wallet/balance/balance.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class TokenBalance extends $pb.GeneratedMessage {
  factory TokenBalance({
    $core.String? symbol,
    $core.String? name,
    $core.String? address,
    $core.String? balance,
    $core.int? decimals,
    $core.String? usdValue,
  }) {
    final result = create();
    if (symbol != null) result.symbol = symbol;
    if (name != null) result.name = name;
    if (address != null) result.address = address;
    if (balance != null) result.balance = balance;
    if (decimals != null) result.decimals = decimals;
    if (usdValue != null) result.usdValue = usdValue;
    return result;
  }

  TokenBalance._();

  factory TokenBalance.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TokenBalance.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TokenBalance',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.balance'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'symbol')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'balance')
    ..aI(5, _omitFieldNames ? '' : 'decimals', fieldType: $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'usdValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenBalance clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenBalance copyWith(void Function(TokenBalance) updates) =>
      super.copyWith((message) => updates(message as TokenBalance))
          as TokenBalance;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenBalance create() => TokenBalance._();
  @$core.override
  TokenBalance createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TokenBalance getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TokenBalance>(create);
  static TokenBalance? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get symbol => $_getSZ(0);
  @$pb.TagNumber(1)
  set symbol($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSymbol() => $_has(0);
  @$pb.TagNumber(1)
  void clearSymbol() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get balance => $_getSZ(3);
  @$pb.TagNumber(4)
  set balance($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBalance() => $_has(3);
  @$pb.TagNumber(4)
  void clearBalance() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get decimals => $_getIZ(4);
  @$pb.TagNumber(5)
  set decimals($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDecimals() => $_has(4);
  @$pb.TagNumber(5)
  void clearDecimals() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get usdValue => $_getSZ(5);
  @$pb.TagNumber(6)
  set usdValue($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUsdValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearUsdValue() => $_clearField(6);
}

class GasFees extends $pb.GeneratedMessage {
  factory GasFees({
    $core.String? baseFeeGwei,
    $core.String? maxPriorityFeeGwei,
    $core.String? maxFeeGwei,
    $fixnum.Int64? estimatedGas,
    $fixnum.Int64? chainId,
    $fixnum.Int64? blockNumber,
  }) {
    final result = create();
    if (baseFeeGwei != null) result.baseFeeGwei = baseFeeGwei;
    if (maxPriorityFeeGwei != null)
      result.maxPriorityFeeGwei = maxPriorityFeeGwei;
    if (maxFeeGwei != null) result.maxFeeGwei = maxFeeGwei;
    if (estimatedGas != null) result.estimatedGas = estimatedGas;
    if (chainId != null) result.chainId = chainId;
    if (blockNumber != null) result.blockNumber = blockNumber;
    return result;
  }

  GasFees._();

  factory GasFees.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GasFees.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GasFees',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.balance'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'baseFeeGwei')
    ..aOS(2, _omitFieldNames ? '' : 'maxPriorityFeeGwei')
    ..aOS(3, _omitFieldNames ? '' : 'maxFeeGwei')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'estimatedGas', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(5, _omitFieldNames ? '' : 'chainId')
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'blockNumber', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasFees clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasFees copyWith(void Function(GasFees) updates) =>
      super.copyWith((message) => updates(message as GasFees)) as GasFees;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GasFees create() => GasFees._();
  @$core.override
  GasFees createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GasFees getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GasFees>(create);
  static GasFees? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get baseFeeGwei => $_getSZ(0);
  @$pb.TagNumber(1)
  set baseFeeGwei($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBaseFeeGwei() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseFeeGwei() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get maxPriorityFeeGwei => $_getSZ(1);
  @$pb.TagNumber(2)
  set maxPriorityFeeGwei($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxPriorityFeeGwei() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxPriorityFeeGwei() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get maxFeeGwei => $_getSZ(2);
  @$pb.TagNumber(3)
  set maxFeeGwei($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxFeeGwei() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxFeeGwei() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get estimatedGas => $_getI64(3);
  @$pb.TagNumber(4)
  set estimatedGas($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEstimatedGas() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstimatedGas() => $_clearField(4);

  /// Network status snapshot — taken alongside gas fees so the UI can render
  /// a single "Mainnet · 18 gwei · block 19234567" indicator without a second
  /// round-trip. block_number is 0 when the chain isn't reachable.
  @$pb.TagNumber(5)
  $fixnum.Int64 get chainId => $_getI64(4);
  @$pb.TagNumber(5)
  set chainId($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasChainId() => $_has(4);
  @$pb.TagNumber(5)
  void clearChainId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get blockNumber => $_getI64(5);
  @$pb.TagNumber(6)
  set blockNumber($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockNumber() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockNumber() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
