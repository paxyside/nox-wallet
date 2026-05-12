// This is a generated file - do not edit.
//
// Generated from wallet/balance/balance.proto.

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

@$core.Deprecated('Use tokenBalanceDescriptor instead')
const TokenBalance$json = {
  '1': 'TokenBalance',
  '2': [
    {'1': 'symbol', '3': 1, '4': 1, '5': 9, '10': 'symbol'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'balance', '3': 4, '4': 1, '5': 9, '10': 'balance'},
    {'1': 'decimals', '3': 5, '4': 1, '5': 13, '10': 'decimals'},
    {'1': 'usd_value', '3': 6, '4': 1, '5': 9, '10': 'usdValue'},
    {'1': 'logo_url', '3': 7, '4': 1, '5': 9, '10': 'logoUrl'},
  ],
};

/// Descriptor for `TokenBalance`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenBalanceDescriptor = $convert.base64Decode(
    'CgxUb2tlbkJhbGFuY2USFgoGc3ltYm9sGAEgASgJUgZzeW1ib2wSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIYCgdhZGRyZXNzGAMgASgJUgdhZGRyZXNzEhgKB2JhbGFuY2UYBCABKAlSB2JhbGFuY2US'
    'GgoIZGVjaW1hbHMYBSABKA1SCGRlY2ltYWxzEhsKCXVzZF92YWx1ZRgGIAEoCVIIdXNkVmFsdW'
    'USGQoIbG9nb191cmwYByABKAlSB2xvZ29Vcmw=');

@$core.Deprecated('Use gasFeesDescriptor instead')
const GasFees$json = {
  '1': 'GasFees',
  '2': [
    {'1': 'base_fee_gwei', '3': 1, '4': 1, '5': 9, '10': 'baseFeeGwei'},
    {
      '1': 'max_priority_fee_gwei',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'maxPriorityFeeGwei'
    },
    {'1': 'max_fee_gwei', '3': 3, '4': 1, '5': 9, '10': 'maxFeeGwei'},
    {'1': 'estimated_gas', '3': 4, '4': 1, '5': 4, '10': 'estimatedGas'},
    {'1': 'chain_id', '3': 5, '4': 1, '5': 3, '10': 'chainId'},
    {'1': 'block_number', '3': 6, '4': 1, '5': 4, '10': 'blockNumber'},
  ],
};

/// Descriptor for `GasFees`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gasFeesDescriptor = $convert.base64Decode(
    'CgdHYXNGZWVzEiIKDWJhc2VfZmVlX2d3ZWkYASABKAlSC2Jhc2VGZWVHd2VpEjEKFW1heF9wcm'
    'lvcml0eV9mZWVfZ3dlaRgCIAEoCVISbWF4UHJpb3JpdHlGZWVHd2VpEiAKDG1heF9mZWVfZ3dl'
    'aRgDIAEoCVIKbWF4RmVlR3dlaRIjCg1lc3RpbWF0ZWRfZ2FzGAQgASgEUgxlc3RpbWF0ZWRHYX'
    'MSGQoIY2hhaW5faWQYBSABKANSB2NoYWluSWQSIQoMYmxvY2tfbnVtYmVyGAYgASgEUgtibG9j'
    'a051bWJlcg==');
