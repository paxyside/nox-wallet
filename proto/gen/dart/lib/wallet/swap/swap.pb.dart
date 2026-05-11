// This is a generated file - do not edit.
//
// Generated from wallet/swap/swap.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'swap.pbenum.dart';

class SwapQuote extends $pb.GeneratedMessage {
  factory SwapQuote({
    $core.String? amountOut,
    $core.String? amountOutRaw,
    $core.String? priceImpactBps,
    $core.String? gasEstimate,
    $core.String? gasCostUsd,
    $core.String? maxFeeGwei,
  }) {
    final result = create();
    if (amountOut != null) result.amountOut = amountOut;
    if (amountOutRaw != null) result.amountOutRaw = amountOutRaw;
    if (priceImpactBps != null) result.priceImpactBps = priceImpactBps;
    if (gasEstimate != null) result.gasEstimate = gasEstimate;
    if (gasCostUsd != null) result.gasCostUsd = gasCostUsd;
    if (maxFeeGwei != null) result.maxFeeGwei = maxFeeGwei;
    return result;
  }

  SwapQuote._();

  factory SwapQuote.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SwapQuote.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SwapQuote',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.swap'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'amountOut')
    ..aOS(2, _omitFieldNames ? '' : 'amountOutRaw')
    ..aOS(3, _omitFieldNames ? '' : 'priceImpactBps')
    ..aOS(4, _omitFieldNames ? '' : 'gasEstimate')
    ..aOS(5, _omitFieldNames ? '' : 'gasCostUsd')
    ..aOS(6, _omitFieldNames ? '' : 'maxFeeGwei')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwapQuote clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwapQuote copyWith(void Function(SwapQuote) updates) =>
      super.copyWith((message) => updates(message as SwapQuote)) as SwapQuote;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SwapQuote create() => SwapQuote._();
  @$core.override
  SwapQuote createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SwapQuote getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwapQuote>(create);
  static SwapQuote? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get amountOut => $_getSZ(0);
  @$pb.TagNumber(1)
  set amountOut($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAmountOut() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmountOut() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get amountOutRaw => $_getSZ(1);
  @$pb.TagNumber(2)
  set amountOutRaw($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountOutRaw() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountOutRaw() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get priceImpactBps => $_getSZ(2);
  @$pb.TagNumber(3)
  set priceImpactBps($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriceImpactBps() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceImpactBps() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get gasEstimate => $_getSZ(3);
  @$pb.TagNumber(4)
  set gasEstimate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGasEstimate() => $_has(3);
  @$pb.TagNumber(4)
  void clearGasEstimate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get gasCostUsd => $_getSZ(4);
  @$pb.TagNumber(5)
  set gasCostUsd($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGasCostUsd() => $_has(4);
  @$pb.TagNumber(5)
  void clearGasCostUsd() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get maxFeeGwei => $_getSZ(5);
  @$pb.TagNumber(6)
  set maxFeeGwei($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxFeeGwei() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxFeeGwei() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
