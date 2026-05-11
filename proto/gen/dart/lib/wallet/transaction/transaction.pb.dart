// This is a generated file - do not edit.
//
// Generated from wallet/transaction/transaction.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class TxReceipt extends $pb.GeneratedMessage {
  factory TxReceipt({
    $core.String? txHash,
    $fixnum.Int64? blockNumber,
    $fixnum.Int64? gasUsed,
    $core.String? effectiveGasPriceGwei,
    $core.bool? success,
  }) {
    final result = create();
    if (txHash != null) result.txHash = txHash;
    if (blockNumber != null) result.blockNumber = blockNumber;
    if (gasUsed != null) result.gasUsed = gasUsed;
    if (effectiveGasPriceGwei != null)
      result.effectiveGasPriceGwei = effectiveGasPriceGwei;
    if (success != null) result.success = success;
    return result;
  }

  TxReceipt._();

  factory TxReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TxReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TxReceipt',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'wallet.transaction'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txHash')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'blockNumber', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'gasUsed', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'effectiveGasPriceGwei')
    ..aOB(5, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TxReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TxReceipt copyWith(void Function(TxReceipt) updates) =>
      super.copyWith((message) => updates(message as TxReceipt)) as TxReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TxReceipt create() => TxReceipt._();
  @$core.override
  TxReceipt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TxReceipt getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TxReceipt>(create);
  static TxReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set txHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get blockNumber => $_getI64(1);
  @$pb.TagNumber(2)
  set blockNumber($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockNumber() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get gasUsed => $_getI64(2);
  @$pb.TagNumber(3)
  set gasUsed($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGasUsed() => $_has(2);
  @$pb.TagNumber(3)
  void clearGasUsed() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get effectiveGasPriceGwei => $_getSZ(3);
  @$pb.TagNumber(4)
  set effectiveGasPriceGwei($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEffectiveGasPriceGwei() => $_has(3);
  @$pb.TagNumber(4)
  void clearEffectiveGasPriceGwei() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get success => $_getBF(4);
  @$pb.TagNumber(5)
  set success($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSuccess() => $_has(4);
  @$pb.TagNumber(5)
  void clearSuccess() => $_clearField(5);
}

class HistoryItem extends $pb.GeneratedMessage {
  factory HistoryItem({
    $core.String? txHash,
    $core.String? from,
    $core.String? to,
    $core.String? asset,
    $core.String? value,
    $core.String? rawValue,
    $0.Timestamp? blockTime,
    $fixnum.Int64? blockNum,
    $core.String? category,
    $core.String? gasFeeEth,
    $core.String? gasFeeUsd,
    $core.String? valueUsd,
    $core.bool? isSwap,
    $core.String? tokenInSym,
    $core.String? tokenInValue,
    $core.String? tokenOutSym,
    $core.String? tokenOutValue,
  }) {
    final result = create();
    if (txHash != null) result.txHash = txHash;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (asset != null) result.asset = asset;
    if (value != null) result.value = value;
    if (rawValue != null) result.rawValue = rawValue;
    if (blockTime != null) result.blockTime = blockTime;
    if (blockNum != null) result.blockNum = blockNum;
    if (category != null) result.category = category;
    if (gasFeeEth != null) result.gasFeeEth = gasFeeEth;
    if (gasFeeUsd != null) result.gasFeeUsd = gasFeeUsd;
    if (valueUsd != null) result.valueUsd = valueUsd;
    if (isSwap != null) result.isSwap = isSwap;
    if (tokenInSym != null) result.tokenInSym = tokenInSym;
    if (tokenInValue != null) result.tokenInValue = tokenInValue;
    if (tokenOutSym != null) result.tokenOutSym = tokenOutSym;
    if (tokenOutValue != null) result.tokenOutValue = tokenOutValue;
    return result;
  }

  HistoryItem._();

  factory HistoryItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HistoryItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HistoryItem',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'wallet.transaction'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txHash')
    ..aOS(2, _omitFieldNames ? '' : 'from')
    ..aOS(3, _omitFieldNames ? '' : 'to')
    ..aOS(4, _omitFieldNames ? '' : 'asset')
    ..aOS(5, _omitFieldNames ? '' : 'value')
    ..aOS(6, _omitFieldNames ? '' : 'rawValue')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'blockTime',
        subBuilder: $0.Timestamp.create)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'blockNum', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(9, _omitFieldNames ? '' : 'category')
    ..aOS(10, _omitFieldNames ? '' : 'gasFeeEth')
    ..aOS(11, _omitFieldNames ? '' : 'gasFeeUsd')
    ..aOS(12, _omitFieldNames ? '' : 'valueUsd')
    ..aOB(13, _omitFieldNames ? '' : 'isSwap')
    ..aOS(14, _omitFieldNames ? '' : 'tokenInSym')
    ..aOS(15, _omitFieldNames ? '' : 'tokenInValue')
    ..aOS(16, _omitFieldNames ? '' : 'tokenOutSym')
    ..aOS(17, _omitFieldNames ? '' : 'tokenOutValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoryItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoryItem copyWith(void Function(HistoryItem) updates) =>
      super.copyWith((message) => updates(message as HistoryItem))
          as HistoryItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HistoryItem create() => HistoryItem._();
  @$core.override
  HistoryItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HistoryItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HistoryItem>(create);
  static HistoryItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set txHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get to => $_getSZ(2);
  @$pb.TagNumber(3)
  set to($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearTo() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get asset => $_getSZ(3);
  @$pb.TagNumber(4)
  set asset($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAsset() => $_has(3);
  @$pb.TagNumber(4)
  void clearAsset() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get value => $_getSZ(4);
  @$pb.TagNumber(5)
  set value($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get rawValue => $_getSZ(5);
  @$pb.TagNumber(6)
  set rawValue($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRawValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearRawValue() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get blockTime => $_getN(6);
  @$pb.TagNumber(7)
  set blockTime($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockTime() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureBlockTime() => $_ensure(6);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockNum => $_getI64(7);
  @$pb.TagNumber(8)
  set blockNum($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBlockNum() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockNum() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get category => $_getSZ(8);
  @$pb.TagNumber(9)
  set category($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCategory() => $_has(8);
  @$pb.TagNumber(9)
  void clearCategory() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get gasFeeEth => $_getSZ(9);
  @$pb.TagNumber(10)
  set gasFeeEth($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasGasFeeEth() => $_has(9);
  @$pb.TagNumber(10)
  void clearGasFeeEth() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get gasFeeUsd => $_getSZ(10);
  @$pb.TagNumber(11)
  set gasFeeUsd($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGasFeeUsd() => $_has(10);
  @$pb.TagNumber(11)
  void clearGasFeeUsd() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get valueUsd => $_getSZ(11);
  @$pb.TagNumber(12)
  set valueUsd($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasValueUsd() => $_has(11);
  @$pb.TagNumber(12)
  void clearValueUsd() => $_clearField(12);

  /// Swap fields — populated only when is_swap = true. The two same-hash legs
  /// of a DEX swap are merged server-side into one virtual entry so the UI
  /// shows "Swap USDC → USDT" instead of two separate "Sent / Received" rows.
  @$pb.TagNumber(13)
  $core.bool get isSwap => $_getBF(12);
  @$pb.TagNumber(13)
  set isSwap($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsSwap() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsSwap() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get tokenInSym => $_getSZ(13);
  @$pb.TagNumber(14)
  set tokenInSym($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasTokenInSym() => $_has(13);
  @$pb.TagNumber(14)
  void clearTokenInSym() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get tokenInValue => $_getSZ(14);
  @$pb.TagNumber(15)
  set tokenInValue($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasTokenInValue() => $_has(14);
  @$pb.TagNumber(15)
  void clearTokenInValue() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get tokenOutSym => $_getSZ(15);
  @$pb.TagNumber(16)
  set tokenOutSym($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasTokenOutSym() => $_has(15);
  @$pb.TagNumber(16)
  void clearTokenOutSym() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get tokenOutValue => $_getSZ(16);
  @$pb.TagNumber(17)
  set tokenOutValue($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasTokenOutValue() => $_has(16);
  @$pb.TagNumber(17)
  void clearTokenOutValue() => $_clearField(17);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
