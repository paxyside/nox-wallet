// This is a generated file - do not edit.
//
// Generated from wallet/transaction/transaction.proto.

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

@$core.Deprecated('Use txReceiptDescriptor instead')
const TxReceipt$json = {
  '1': 'TxReceipt',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 9, '10': 'txHash'},
    {'1': 'block_number', '3': 2, '4': 1, '5': 4, '10': 'blockNumber'},
    {'1': 'gas_used', '3': 3, '4': 1, '5': 4, '10': 'gasUsed'},
    {
      '1': 'effective_gas_price_gwei',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'effectiveGasPriceGwei'
    },
    {'1': 'success', '3': 5, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `TxReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txReceiptDescriptor = $convert.base64Decode(
    'CglUeFJlY2VpcHQSFwoHdHhfaGFzaBgBIAEoCVIGdHhIYXNoEiEKDGJsb2NrX251bWJlchgCIA'
    'EoBFILYmxvY2tOdW1iZXISGQoIZ2FzX3VzZWQYAyABKARSB2dhc1VzZWQSNwoYZWZmZWN0aXZl'
    'X2dhc19wcmljZV9nd2VpGAQgASgJUhVlZmZlY3RpdmVHYXNQcmljZUd3ZWkSGAoHc3VjY2Vzcx'
    'gFIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use historyItemDescriptor instead')
const HistoryItem$json = {
  '1': 'HistoryItem',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 9, '10': 'txHash'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
    {'1': 'asset', '3': 4, '4': 1, '5': 9, '10': 'asset'},
    {'1': 'value', '3': 5, '4': 1, '5': 9, '10': 'value'},
    {'1': 'raw_value', '3': 6, '4': 1, '5': 9, '10': 'rawValue'},
    {
      '1': 'block_time',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'blockTime'
    },
    {'1': 'block_num', '3': 8, '4': 1, '5': 4, '10': 'blockNum'},
    {'1': 'category', '3': 9, '4': 1, '5': 9, '10': 'category'},
    {'1': 'gas_fee_eth', '3': 10, '4': 1, '5': 9, '10': 'gasFeeEth'},
    {'1': 'gas_fee_usd', '3': 11, '4': 1, '5': 9, '10': 'gasFeeUsd'},
    {'1': 'value_usd', '3': 12, '4': 1, '5': 9, '10': 'valueUsd'},
    {'1': 'is_swap', '3': 13, '4': 1, '5': 8, '10': 'isSwap'},
    {'1': 'token_in_sym', '3': 14, '4': 1, '5': 9, '10': 'tokenInSym'},
    {'1': 'token_in_value', '3': 15, '4': 1, '5': 9, '10': 'tokenInValue'},
    {'1': 'token_out_sym', '3': 16, '4': 1, '5': 9, '10': 'tokenOutSym'},
    {'1': 'token_out_value', '3': 17, '4': 1, '5': 9, '10': 'tokenOutValue'},
  ],
};

/// Descriptor for `HistoryItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyItemDescriptor = $convert.base64Decode(
    'CgtIaXN0b3J5SXRlbRIXCgd0eF9oYXNoGAEgASgJUgZ0eEhhc2gSEgoEZnJvbRgCIAEoCVIEZn'
    'JvbRIOCgJ0bxgDIAEoCVICdG8SFAoFYXNzZXQYBCABKAlSBWFzc2V0EhQKBXZhbHVlGAUgASgJ'
    'UgV2YWx1ZRIbCglyYXdfdmFsdWUYBiABKAlSCHJhd1ZhbHVlEjkKCmJsb2NrX3RpbWUYByABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglibG9ja1RpbWUSGwoJYmxvY2tfbnVtGAgg'
    'ASgEUghibG9ja051bRIaCghjYXRlZ29yeRgJIAEoCVIIY2F0ZWdvcnkSHgoLZ2FzX2ZlZV9ldG'
    'gYCiABKAlSCWdhc0ZlZUV0aBIeCgtnYXNfZmVlX3VzZBgLIAEoCVIJZ2FzRmVlVXNkEhsKCXZh'
    'bHVlX3VzZBgMIAEoCVIIdmFsdWVVc2QSFwoHaXNfc3dhcBgNIAEoCFIGaXNTd2FwEiAKDHRva2'
    'VuX2luX3N5bRgOIAEoCVIKdG9rZW5JblN5bRIkCg50b2tlbl9pbl92YWx1ZRgPIAEoCVIMdG9r'
    'ZW5JblZhbHVlEiIKDXRva2VuX291dF9zeW0YECABKAlSC3Rva2VuT3V0U3ltEiYKD3Rva2VuX2'
    '91dF92YWx1ZRgRIAEoCVINdG9rZW5PdXRWYWx1ZQ==');
