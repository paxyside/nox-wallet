// This is a generated file - do not edit.
//
// Generated from wallet/swap/swap.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use poolFeeDescriptor instead')
const PoolFee$json = {
  '1': 'PoolFee',
  '2': [
    {'1': 'POOL_FEE_UNSPECIFIED', '2': 0},
    {'1': 'POOL_FEE_100', '2': 1},
    {'1': 'POOL_FEE_500', '2': 2},
    {'1': 'POOL_FEE_3000', '2': 3},
    {'1': 'POOL_FEE_10000', '2': 4},
  ],
};

/// Descriptor for `PoolFee`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List poolFeeDescriptor = $convert.base64Decode(
    'CgdQb29sRmVlEhgKFFBPT0xfRkVFX1VOU1BFQ0lGSUVEEAASEAoMUE9PTF9GRUVfMTAwEAESEA'
    'oMUE9PTF9GRUVfNTAwEAISEQoNUE9PTF9GRUVfMzAwMBADEhIKDlBPT0xfRkVFXzEwMDAwEAQ=');

@$core.Deprecated('Use swapQuoteDescriptor instead')
const SwapQuote$json = {
  '1': 'SwapQuote',
  '2': [
    {'1': 'amount_out', '3': 1, '4': 1, '5': 9, '10': 'amountOut'},
    {'1': 'amount_out_raw', '3': 2, '4': 1, '5': 9, '10': 'amountOutRaw'},
    {'1': 'price_impact_bps', '3': 3, '4': 1, '5': 9, '10': 'priceImpactBps'},
    {'1': 'gas_estimate', '3': 4, '4': 1, '5': 9, '10': 'gasEstimate'},
    {'1': 'gas_cost_usd', '3': 5, '4': 1, '5': 9, '10': 'gasCostUsd'},
    {'1': 'max_fee_gwei', '3': 6, '4': 1, '5': 9, '10': 'maxFeeGwei'},
  ],
};

/// Descriptor for `SwapQuote`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List swapQuoteDescriptor = $convert.base64Decode(
    'CglTd2FwUXVvdGUSHQoKYW1vdW50X291dBgBIAEoCVIJYW1vdW50T3V0EiQKDmFtb3VudF9vdX'
    'RfcmF3GAIgASgJUgxhbW91bnRPdXRSYXcSKAoQcHJpY2VfaW1wYWN0X2JwcxgDIAEoCVIOcHJp'
    'Y2VJbXBhY3RCcHMSIQoMZ2FzX2VzdGltYXRlGAQgASgJUgtnYXNFc3RpbWF0ZRIgCgxnYXNfY2'
    '9zdF91c2QYBSABKAlSCmdhc0Nvc3RVc2QSIAoMbWF4X2ZlZV9nd2VpGAYgASgJUgptYXhGZWVH'
    'd2Vp');
