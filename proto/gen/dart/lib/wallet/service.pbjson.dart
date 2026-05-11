// This is a generated file - do not edit.
//
// Generated from wallet/service.proto.

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

@$core.Deprecated('Use generateWalletRequestDescriptor instead')
const GenerateWalletRequest$json = {
  '1': 'GenerateWalletRequest',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'word_count_24', '3': 2, '4': 1, '5': 8, '10': 'wordCount24'},
  ],
};

/// Descriptor for `GenerateWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateWalletRequestDescriptor = $convert.base64Decode(
    'ChVHZW5lcmF0ZVdhbGxldFJlcXVlc3QSFAoFbGFiZWwYASABKAlSBWxhYmVsEiIKDXdvcmRfY2'
    '91bnRfMjQYAiABKAhSC3dvcmRDb3VudDI0');

@$core.Deprecated('Use generateWalletResponseDescriptor instead')
const GenerateWalletResponse$json = {
  '1': 'GenerateWalletResponse',
  '2': [
    {
      '1': 'wallet',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.wallet.Wallet',
      '10': 'wallet'
    },
    {'1': 'mnemonic', '3': 2, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `GenerateWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateWalletResponseDescriptor =
    $convert.base64Decode(
        'ChZHZW5lcmF0ZVdhbGxldFJlc3BvbnNlEi0KBndhbGxldBgBIAEoCzIVLndhbGxldC53YWxsZX'
        'QuV2FsbGV0UgZ3YWxsZXQSGgoIbW5lbW9uaWMYAiABKAlSCG1uZW1vbmlj');

@$core.Deprecated('Use importMnemonicRequestDescriptor instead')
const ImportMnemonicRequest$json = {
  '1': 'ImportMnemonicRequest',
  '2': [
    {'1': 'mnemonic', '3': 1, '4': 1, '5': 9, '10': 'mnemonic'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'derivation_path', '3': 3, '4': 1, '5': 9, '10': 'derivationPath'},
  ],
};

/// Descriptor for `ImportMnemonicRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importMnemonicRequestDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRNbmVtb25pY1JlcXVlc3QSGgoIbW5lbW9uaWMYASABKAlSCG1uZW1vbmljEhQKBW'
    'xhYmVsGAIgASgJUgVsYWJlbBInCg9kZXJpdmF0aW9uX3BhdGgYAyABKAlSDmRlcml2YXRpb25Q'
    'YXRo');

@$core.Deprecated('Use importMnemonicResponseDescriptor instead')
const ImportMnemonicResponse$json = {
  '1': 'ImportMnemonicResponse',
  '2': [
    {
      '1': 'wallet',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.wallet.Wallet',
      '10': 'wallet'
    },
  ],
};

/// Descriptor for `ImportMnemonicResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importMnemonicResponseDescriptor =
    $convert.base64Decode(
        'ChZJbXBvcnRNbmVtb25pY1Jlc3BvbnNlEi0KBndhbGxldBgBIAEoCzIVLndhbGxldC53YWxsZX'
        'QuV2FsbGV0UgZ3YWxsZXQ=');

@$core.Deprecated('Use importPrivateKeyRequestDescriptor instead')
const ImportPrivateKeyRequest$json = {
  '1': 'ImportPrivateKeyRequest',
  '2': [
    {'1': 'private_key_hex', '3': 1, '4': 1, '5': 9, '10': 'privateKeyHex'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `ImportPrivateKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPrivateKeyRequestDescriptor =
    $convert.base64Decode(
        'ChdJbXBvcnRQcml2YXRlS2V5UmVxdWVzdBImCg9wcml2YXRlX2tleV9oZXgYASABKAlSDXByaX'
        'ZhdGVLZXlIZXgSFAoFbGFiZWwYAiABKAlSBWxhYmVs');

@$core.Deprecated('Use importPrivateKeyResponseDescriptor instead')
const ImportPrivateKeyResponse$json = {
  '1': 'ImportPrivateKeyResponse',
  '2': [
    {
      '1': 'wallet',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.wallet.Wallet',
      '10': 'wallet'
    },
  ],
};

/// Descriptor for `ImportPrivateKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPrivateKeyResponseDescriptor =
    $convert.base64Decode(
        'ChhJbXBvcnRQcml2YXRlS2V5UmVzcG9uc2USLQoGd2FsbGV0GAEgASgLMhUud2FsbGV0LndhbG'
        'xldC5XYWxsZXRSBndhbGxldA==');

@$core.Deprecated('Use importKeystoreRequestDescriptor instead')
const ImportKeystoreRequest$json = {
  '1': 'ImportKeystoreRequest',
  '2': [
    {'1': 'keystore_json', '3': 1, '4': 1, '5': 12, '10': 'keystoreJson'},
    {'1': 'passphrase', '3': 2, '4': 1, '5': 9, '10': 'passphrase'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `ImportKeystoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importKeystoreRequestDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRLZXlzdG9yZVJlcXVlc3QSIwoNa2V5c3RvcmVfanNvbhgBIAEoDFIMa2V5c3Rvcm'
    'VKc29uEh4KCnBhc3NwaHJhc2UYAiABKAlSCnBhc3NwaHJhc2USFAoFbGFiZWwYAyABKAlSBWxh'
    'YmVs');

@$core.Deprecated('Use importKeystoreResponseDescriptor instead')
const ImportKeystoreResponse$json = {
  '1': 'ImportKeystoreResponse',
  '2': [
    {
      '1': 'wallet',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.wallet.Wallet',
      '10': 'wallet'
    },
  ],
};

/// Descriptor for `ImportKeystoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importKeystoreResponseDescriptor =
    $convert.base64Decode(
        'ChZJbXBvcnRLZXlzdG9yZVJlc3BvbnNlEi0KBndhbGxldBgBIAEoCzIVLndhbGxldC53YWxsZX'
        'QuV2FsbGV0UgZ3YWxsZXQ=');

@$core.Deprecated('Use exportKeystoreRequestDescriptor instead')
const ExportKeystoreRequest$json = {
  '1': 'ExportKeystoreRequest',
  '2': [
    {'1': 'passphrase', '3': 1, '4': 1, '5': 9, '10': 'passphrase'},
  ],
};

/// Descriptor for `ExportKeystoreRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportKeystoreRequestDescriptor = $convert.base64Decode(
    'ChVFeHBvcnRLZXlzdG9yZVJlcXVlc3QSHgoKcGFzc3BocmFzZRgBIAEoCVIKcGFzc3BocmFzZQ'
    '==');

@$core.Deprecated('Use exportKeystoreResponseDescriptor instead')
const ExportKeystoreResponse$json = {
  '1': 'ExportKeystoreResponse',
  '2': [
    {'1': 'keystore_json', '3': 1, '4': 1, '5': 12, '10': 'keystoreJson'},
  ],
};

/// Descriptor for `ExportKeystoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportKeystoreResponseDescriptor =
    $convert.base64Decode(
        'ChZFeHBvcnRLZXlzdG9yZVJlc3BvbnNlEiMKDWtleXN0b3JlX2pzb24YASABKAxSDGtleXN0b3'
        'JlSnNvbg==');

@$core.Deprecated('Use revealSecretRequestDescriptor instead')
const RevealSecretRequest$json = {
  '1': 'RevealSecretRequest',
};

/// Descriptor for `RevealSecretRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revealSecretRequestDescriptor =
    $convert.base64Decode('ChNSZXZlYWxTZWNyZXRSZXF1ZXN0');

@$core.Deprecated('Use revealSecretResponseDescriptor instead')
const RevealSecretResponse$json = {
  '1': 'RevealSecretResponse',
  '2': [
    {'1': 'secret', '3': 1, '4': 1, '5': 9, '10': 'secret'},
    {
      '1': 'secret_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.wallet.wallet.SecretType',
      '10': 'secretType'
    },
  ],
};

/// Descriptor for `RevealSecretResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revealSecretResponseDescriptor = $convert.base64Decode(
    'ChRSZXZlYWxTZWNyZXRSZXNwb25zZRIWCgZzZWNyZXQYASABKAlSBnNlY3JldBI6CgtzZWNyZX'
    'RfdHlwZRgCIAEoDjIZLndhbGxldC53YWxsZXQuU2VjcmV0VHlwZVIKc2VjcmV0VHlwZQ==');

@$core.Deprecated('Use getWalletRequestDescriptor instead')
const GetWalletRequest$json = {
  '1': 'GetWalletRequest',
};

/// Descriptor for `GetWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletRequestDescriptor =
    $convert.base64Decode('ChBHZXRXYWxsZXRSZXF1ZXN0');

@$core.Deprecated('Use getWalletResponseDescriptor instead')
const GetWalletResponse$json = {
  '1': 'GetWalletResponse',
  '2': [
    {
      '1': 'wallet',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.wallet.Wallet',
      '10': 'wallet'
    },
  ],
};

/// Descriptor for `GetWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletResponseDescriptor = $convert.base64Decode(
    'ChFHZXRXYWxsZXRSZXNwb25zZRItCgZ3YWxsZXQYASABKAsyFS53YWxsZXQud2FsbGV0LldhbG'
    'xldFIGd2FsbGV0');

@$core.Deprecated('Use getBalancesRequestDescriptor instead')
const GetBalancesRequest$json = {
  '1': 'GetBalancesRequest',
  '2': [
    {'1': 'with_tokens', '3': 1, '4': 1, '5': 8, '10': 'withTokens'},
  ],
};

/// Descriptor for `GetBalancesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalancesRequestDescriptor = $convert.base64Decode(
    'ChJHZXRCYWxhbmNlc1JlcXVlc3QSHwoLd2l0aF90b2tlbnMYASABKAhSCndpdGhUb2tlbnM=');

@$core.Deprecated('Use getBalancesResponseDescriptor instead')
const GetBalancesResponse$json = {
  '1': 'GetBalancesResponse',
  '2': [
    {'1': 'eth_balance', '3': 1, '4': 1, '5': 9, '10': 'ethBalance'},
    {'1': 'eth_balance_wei', '3': 2, '4': 1, '5': 9, '10': 'ethBalanceWei'},
    {
      '1': 'tokens',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.wallet.balance.TokenBalance',
      '10': 'tokens'
    },
    {'1': 'eth_usd_value', '3': 4, '4': 1, '5': 9, '10': 'ethUsdValue'},
  ],
};

/// Descriptor for `GetBalancesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalancesResponseDescriptor = $convert.base64Decode(
    'ChNHZXRCYWxhbmNlc1Jlc3BvbnNlEh8KC2V0aF9iYWxhbmNlGAEgASgJUgpldGhCYWxhbmNlEi'
    'YKD2V0aF9iYWxhbmNlX3dlaRgCIAEoCVINZXRoQmFsYW5jZVdlaRI0CgZ0b2tlbnMYAyADKAsy'
    'HC53YWxsZXQuYmFsYW5jZS5Ub2tlbkJhbGFuY2VSBnRva2VucxIiCg1ldGhfdXNkX3ZhbHVlGA'
    'QgASgJUgtldGhVc2RWYWx1ZQ==');

@$core.Deprecated('Use getGasFeesRequestDescriptor instead')
const GetGasFeesRequest$json = {
  '1': 'GetGasFeesRequest',
};

/// Descriptor for `GetGasFeesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGasFeesRequestDescriptor =
    $convert.base64Decode('ChFHZXRHYXNGZWVzUmVxdWVzdA==');

@$core.Deprecated('Use getGasFeesResponseDescriptor instead')
const GetGasFeesResponse$json = {
  '1': 'GetGasFeesResponse',
  '2': [
    {
      '1': 'fees',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.balance.GasFees',
      '10': 'fees'
    },
    {'1': 'block_number', '3': 2, '4': 1, '5': 4, '10': 'blockNumber'},
    {'1': 'eth_price_usd', '3': 3, '4': 1, '5': 9, '10': 'ethPriceUsd'},
  ],
};

/// Descriptor for `GetGasFeesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGasFeesResponseDescriptor = $convert.base64Decode(
    'ChJHZXRHYXNGZWVzUmVzcG9uc2USKwoEZmVlcxgBIAEoCzIXLndhbGxldC5iYWxhbmNlLkdhc0'
    'ZlZXNSBGZlZXMSIQoMYmxvY2tfbnVtYmVyGAIgASgEUgtibG9ja051bWJlchIiCg1ldGhfcHJp'
    'Y2VfdXNkGAMgASgJUgtldGhQcmljZVVzZA==');

@$core.Deprecated('Use gasOptionsDescriptor instead')
const GasOptions$json = {
  '1': 'GasOptions',
  '2': [
    {'1': 'priority_gwei', '3': 1, '4': 1, '5': 9, '10': 'priorityGwei'},
    {'1': 'max_gwei', '3': 2, '4': 1, '5': 9, '10': 'maxGwei'},
  ],
};

/// Descriptor for `GasOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gasOptionsDescriptor = $convert.base64Decode(
    'CgpHYXNPcHRpb25zEiMKDXByaW9yaXR5X2d3ZWkYASABKAlSDHByaW9yaXR5R3dlaRIZCghtYX'
    'hfZ3dlaRgCIAEoCVIHbWF4R3dlaQ==');

@$core.Deprecated('Use sendETHRequestDescriptor instead')
const SendETHRequest$json = {
  '1': 'SendETHRequest',
  '2': [
    {'1': 'to', '3': 1, '4': 1, '5': 9, '10': 'to'},
    {'1': 'amount', '3': 2, '4': 1, '5': 9, '10': 'amount'},
    {
      '1': 'gas',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.wallet.GasOptions',
      '10': 'gas'
    },
  ],
};

/// Descriptor for `SendETHRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendETHRequestDescriptor = $convert.base64Decode(
    'Cg5TZW5kRVRIUmVxdWVzdBIOCgJ0bxgBIAEoCVICdG8SFgoGYW1vdW50GAIgASgJUgZhbW91bn'
    'QSJAoDZ2FzGAMgASgLMhIud2FsbGV0Lkdhc09wdGlvbnNSA2dhcw==');

@$core.Deprecated('Use sendETHResponseDescriptor instead')
const SendETHResponse$json = {
  '1': 'SendETHResponse',
  '2': [
    {
      '1': 'receipt',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.transaction.TxReceipt',
      '10': 'receipt'
    },
  ],
};

/// Descriptor for `SendETHResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendETHResponseDescriptor = $convert.base64Decode(
    'Cg9TZW5kRVRIUmVzcG9uc2USNwoHcmVjZWlwdBgBIAEoCzIdLndhbGxldC50cmFuc2FjdGlvbi'
    '5UeFJlY2VpcHRSB3JlY2VpcHQ=');

@$core.Deprecated('Use sendTokenRequestDescriptor instead')
const SendTokenRequest$json = {
  '1': 'SendTokenRequest',
  '2': [
    {'1': 'to', '3': 1, '4': 1, '5': 9, '10': 'to'},
    {'1': 'token_address', '3': 2, '4': 1, '5': 9, '10': 'tokenAddress'},
    {'1': 'amount', '3': 3, '4': 1, '5': 9, '10': 'amount'},
    {
      '1': 'gas',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.wallet.GasOptions',
      '10': 'gas'
    },
  ],
};

/// Descriptor for `SendTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTokenRequestDescriptor = $convert.base64Decode(
    'ChBTZW5kVG9rZW5SZXF1ZXN0Eg4KAnRvGAEgASgJUgJ0bxIjCg10b2tlbl9hZGRyZXNzGAIgAS'
    'gJUgx0b2tlbkFkZHJlc3MSFgoGYW1vdW50GAMgASgJUgZhbW91bnQSJAoDZ2FzGAQgASgLMhIu'
    'd2FsbGV0Lkdhc09wdGlvbnNSA2dhcw==');

@$core.Deprecated('Use sendTokenResponseDescriptor instead')
const SendTokenResponse$json = {
  '1': 'SendTokenResponse',
  '2': [
    {
      '1': 'receipt',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.transaction.TxReceipt',
      '10': 'receipt'
    },
  ],
};

/// Descriptor for `SendTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTokenResponseDescriptor = $convert.base64Decode(
    'ChFTZW5kVG9rZW5SZXNwb25zZRI3CgdyZWNlaXB0GAEgASgLMh0ud2FsbGV0LnRyYW5zYWN0aW'
    '9uLlR4UmVjZWlwdFIHcmVjZWlwdA==');

@$core.Deprecated('Use getHistoryRequestDescriptor instead')
const GetHistoryRequest$json = {
  '1': 'GetHistoryRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'asset', '3': 2, '4': 1, '5': 9, '10': 'asset'},
    {
      '1': 'page',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.wallet.common.PageParams',
      '10': 'page'
    },
  ],
};

/// Descriptor for `GetHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoryRequestDescriptor = $convert.base64Decode(
    'ChFHZXRIaXN0b3J5UmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhQKBWFzc2V0GA'
    'IgASgJUgVhc3NldBItCgRwYWdlGAMgASgLMhkud2FsbGV0LmNvbW1vbi5QYWdlUGFyYW1zUgRw'
    'YWdl');

@$core.Deprecated('Use getHistoryResponseDescriptor instead')
const GetHistoryResponse$json = {
  '1': 'GetHistoryResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wallet.transaction.HistoryItem',
      '10': 'items'
    },
    {
      '1': 'page_info',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.wallet.common.PageInfo',
      '10': 'pageInfo'
    },
  ],
};

/// Descriptor for `GetHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoryResponseDescriptor = $convert.base64Decode(
    'ChJHZXRIaXN0b3J5UmVzcG9uc2USNQoFaXRlbXMYASADKAsyHy53YWxsZXQudHJhbnNhY3Rpb2'
    '4uSGlzdG9yeUl0ZW1SBWl0ZW1zEjQKCXBhZ2VfaW5mbxgCIAEoCzIXLndhbGxldC5jb21tb24u'
    'UGFnZUluZm9SCHBhZ2VJbmZv');

@$core.Deprecated('Use quoteSwapRequestDescriptor instead')
const QuoteSwapRequest$json = {
  '1': 'QuoteSwapRequest',
  '2': [
    {'1': 'token_in', '3': 1, '4': 1, '5': 9, '10': 'tokenIn'},
    {'1': 'token_out', '3': 2, '4': 1, '5': 9, '10': 'tokenOut'},
    {'1': 'amount_in', '3': 3, '4': 1, '5': 9, '10': 'amountIn'},
    {
      '1': 'fee',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.wallet.swap.PoolFee',
      '10': 'fee'
    },
  ],
};

/// Descriptor for `QuoteSwapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteSwapRequestDescriptor = $convert.base64Decode(
    'ChBRdW90ZVN3YXBSZXF1ZXN0EhkKCHRva2VuX2luGAEgASgJUgd0b2tlbkluEhsKCXRva2VuX2'
    '91dBgCIAEoCVIIdG9rZW5PdXQSGwoJYW1vdW50X2luGAMgASgJUghhbW91bnRJbhImCgNmZWUY'
    'BCABKA4yFC53YWxsZXQuc3dhcC5Qb29sRmVlUgNmZWU=');

@$core.Deprecated('Use quoteSwapResponseDescriptor instead')
const QuoteSwapResponse$json = {
  '1': 'QuoteSwapResponse',
  '2': [
    {
      '1': 'quote',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.swap.SwapQuote',
      '10': 'quote'
    },
  ],
};

/// Descriptor for `QuoteSwapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteSwapResponseDescriptor = $convert.base64Decode(
    'ChFRdW90ZVN3YXBSZXNwb25zZRIsCgVxdW90ZRgBIAEoCzIWLndhbGxldC5zd2FwLlN3YXBRdW'
    '90ZVIFcXVvdGU=');

@$core.Deprecated('Use executeSwapRequestDescriptor instead')
const ExecuteSwapRequest$json = {
  '1': 'ExecuteSwapRequest',
  '2': [
    {'1': 'token_in', '3': 1, '4': 1, '5': 9, '10': 'tokenIn'},
    {'1': 'token_out', '3': 2, '4': 1, '5': 9, '10': 'tokenOut'},
    {'1': 'amount_in', '3': 3, '4': 1, '5': 9, '10': 'amountIn'},
    {'1': 'amount_out_min', '3': 4, '4': 1, '5': 9, '10': 'amountOutMin'},
    {
      '1': 'fee',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.wallet.swap.PoolFee',
      '10': 'fee'
    },
    {'1': 'deadline_seconds', '3': 6, '4': 1, '5': 13, '10': 'deadlineSeconds'},
    {
      '1': 'gas',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.wallet.GasOptions',
      '10': 'gas'
    },
  ],
};

/// Descriptor for `ExecuteSwapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeSwapRequestDescriptor = $convert.base64Decode(
    'ChJFeGVjdXRlU3dhcFJlcXVlc3QSGQoIdG9rZW5faW4YASABKAlSB3Rva2VuSW4SGwoJdG9rZW'
    '5fb3V0GAIgASgJUgh0b2tlbk91dBIbCglhbW91bnRfaW4YAyABKAlSCGFtb3VudEluEiQKDmFt'
    'b3VudF9vdXRfbWluGAQgASgJUgxhbW91bnRPdXRNaW4SJgoDZmVlGAUgASgOMhQud2FsbGV0Ln'
    'N3YXAuUG9vbEZlZVIDZmVlEikKEGRlYWRsaW5lX3NlY29uZHMYBiABKA1SD2RlYWRsaW5lU2Vj'
    'b25kcxIkCgNnYXMYByABKAsyEi53YWxsZXQuR2FzT3B0aW9uc1IDZ2Fz');

@$core.Deprecated('Use executeSwapResponseDescriptor instead')
const ExecuteSwapResponse$json = {
  '1': 'ExecuteSwapResponse',
  '2': [
    {
      '1': 'receipt',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.transaction.TxReceipt',
      '10': 'receipt'
    },
  ],
};

/// Descriptor for `ExecuteSwapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeSwapResponseDescriptor = $convert.base64Decode(
    'ChNFeGVjdXRlU3dhcFJlc3BvbnNlEjcKB3JlY2VpcHQYASABKAsyHS53YWxsZXQudHJhbnNhY3'
    'Rpb24uVHhSZWNlaXB0UgdyZWNlaXB0');

@$core.Deprecated('Use createContactRequestDescriptor instead')
const CreateContactRequest$json = {
  '1': 'CreateContactRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'note', '3': 3, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `CreateContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createContactRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVDb250YWN0UmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhgKB2FkZHJlc3MYAi'
    'ABKAlSB2FkZHJlc3MSEgoEbm90ZRgDIAEoCVIEbm90ZQ==');

@$core.Deprecated('Use createContactResponseDescriptor instead')
const CreateContactResponse$json = {
  '1': 'CreateContactResponse',
  '2': [
    {
      '1': 'contact',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.contact.Contact',
      '10': 'contact'
    },
  ],
};

/// Descriptor for `CreateContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createContactResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVDb250YWN0UmVzcG9uc2USMQoHY29udGFjdBgBIAEoCzIXLndhbGxldC5jb250YW'
    'N0LkNvbnRhY3RSB2NvbnRhY3Q=');

@$core.Deprecated('Use getContactRequestDescriptor instead')
const GetContactRequest$json = {
  '1': 'GetContactRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getContactRequestDescriptor =
    $convert.base64Decode('ChFHZXRDb250YWN0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getContactResponseDescriptor instead')
const GetContactResponse$json = {
  '1': 'GetContactResponse',
  '2': [
    {
      '1': 'contact',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.contact.Contact',
      '10': 'contact'
    },
  ],
};

/// Descriptor for `GetContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getContactResponseDescriptor = $convert.base64Decode(
    'ChJHZXRDb250YWN0UmVzcG9uc2USMQoHY29udGFjdBgBIAEoCzIXLndhbGxldC5jb250YWN0Lk'
    'NvbnRhY3RSB2NvbnRhY3Q=');

@$core.Deprecated('Use updateContactRequestDescriptor instead')
const UpdateContactRequest$json = {
  '1': 'UpdateContactRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'note', '3': 4, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `UpdateContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateContactRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVDb250YWN0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIYCgdhZGRyZXNzGAMgASgJUgdhZGRyZXNzEhIKBG5vdGUYBCABKAlSBG5vdGU=');

@$core.Deprecated('Use updateContactResponseDescriptor instead')
const UpdateContactResponse$json = {
  '1': 'UpdateContactResponse',
  '2': [
    {
      '1': 'contact',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.contact.Contact',
      '10': 'contact'
    },
  ],
};

/// Descriptor for `UpdateContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateContactResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVDb250YWN0UmVzcG9uc2USMQoHY29udGFjdBgBIAEoCzIXLndhbGxldC5jb250YW'
    'N0LkNvbnRhY3RSB2NvbnRhY3Q=');

@$core.Deprecated('Use deleteContactRequestDescriptor instead')
const DeleteContactRequest$json = {
  '1': 'DeleteContactRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteContactRequestDescriptor = $convert
    .base64Decode('ChREZWxldGVDb250YWN0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteContactResponseDescriptor instead')
const DeleteContactResponse$json = {
  '1': 'DeleteContactResponse',
};

/// Descriptor for `DeleteContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteContactResponseDescriptor =
    $convert.base64Decode('ChVEZWxldGVDb250YWN0UmVzcG9uc2U=');

@$core.Deprecated('Use listContactsRequestDescriptor instead')
const ListContactsRequest$json = {
  '1': 'ListContactsRequest',
};

/// Descriptor for `ListContactsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listContactsRequestDescriptor =
    $convert.base64Decode('ChNMaXN0Q29udGFjdHNSZXF1ZXN0');

@$core.Deprecated('Use listContactsResponseDescriptor instead')
const ListContactsResponse$json = {
  '1': 'ListContactsResponse',
  '2': [
    {
      '1': 'contacts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wallet.contact.Contact',
      '10': 'contacts'
    },
  ],
};

/// Descriptor for `ListContactsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listContactsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0Q29udGFjdHNSZXNwb25zZRIzCghjb250YWN0cxgBIAMoCzIXLndhbGxldC5jb250YW'
    'N0LkNvbnRhY3RSCGNvbnRhY3Rz');

@$core.Deprecated('Use favoriteContactRequestDescriptor instead')
const FavoriteContactRequest$json = {
  '1': 'FavoriteContactRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'favorite', '3': 2, '4': 1, '5': 8, '10': 'favorite'},
  ],
};

/// Descriptor for `FavoriteContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteContactRequestDescriptor =
    $convert.base64Decode(
        'ChZGYXZvcml0ZUNvbnRhY3RSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIaCghmYXZvcml0ZRgCIA'
        'EoCFIIZmF2b3JpdGU=');

@$core.Deprecated('Use favoriteContactResponseDescriptor instead')
const FavoriteContactResponse$json = {
  '1': 'FavoriteContactResponse',
};

/// Descriptor for `FavoriteContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteContactResponseDescriptor =
    $convert.base64Decode('ChdGYXZvcml0ZUNvbnRhY3RSZXNwb25zZQ==');

@$core.Deprecated('Use addTokenRequestDescriptor instead')
const AddTokenRequest$json = {
  '1': 'AddTokenRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `AddTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTokenRequestDescriptor = $convert.base64Decode(
    'Cg9BZGRUb2tlblJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use addTokenResponseDescriptor instead')
const AddTokenResponse$json = {
  '1': 'AddTokenResponse',
  '2': [
    {
      '1': 'token',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.token.WatchedToken',
      '10': 'token'
    },
  ],
};

/// Descriptor for `AddTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTokenResponseDescriptor = $convert.base64Decode(
    'ChBBZGRUb2tlblJlc3BvbnNlEjAKBXRva2VuGAEgASgLMhoud2FsbGV0LnRva2VuLldhdGNoZW'
    'RUb2tlblIFdG9rZW4=');

@$core.Deprecated('Use removeTokenRequestDescriptor instead')
const RemoveTokenRequest$json = {
  '1': 'RemoveTokenRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `RemoveTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeTokenRequestDescriptor =
    $convert.base64Decode('ChJSZW1vdmVUb2tlblJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use removeTokenResponseDescriptor instead')
const RemoveTokenResponse$json = {
  '1': 'RemoveTokenResponse',
};

/// Descriptor for `RemoveTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeTokenResponseDescriptor =
    $convert.base64Decode('ChNSZW1vdmVUb2tlblJlc3BvbnNl');

@$core.Deprecated('Use listTokensRequestDescriptor instead')
const ListTokensRequest$json = {
  '1': 'ListTokensRequest',
};

/// Descriptor for `ListTokensRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTokensRequestDescriptor =
    $convert.base64Decode('ChFMaXN0VG9rZW5zUmVxdWVzdA==');

@$core.Deprecated('Use listTokensResponseDescriptor instead')
const ListTokensResponse$json = {
  '1': 'ListTokensResponse',
  '2': [
    {
      '1': 'tokens',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wallet.token.WatchedToken',
      '10': 'tokens'
    },
  ],
};

/// Descriptor for `ListTokensResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTokensResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0VG9rZW5zUmVzcG9uc2USMgoGdG9rZW5zGAEgAygLMhoud2FsbGV0LnRva2VuLldhdG'
    'NoZWRUb2tlblIGdG9rZW5z');

@$core.Deprecated('Use listTokensWithBalancesRequestDescriptor instead')
const ListTokensWithBalancesRequest$json = {
  '1': 'ListTokensWithBalancesRequest',
};

/// Descriptor for `ListTokensWithBalancesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTokensWithBalancesRequestDescriptor =
    $convert.base64Decode('Ch1MaXN0VG9rZW5zV2l0aEJhbGFuY2VzUmVxdWVzdA==');

@$core.Deprecated('Use listTokensWithBalancesResponseDescriptor instead')
const ListTokensWithBalancesResponse$json = {
  '1': 'ListTokensWithBalancesResponse',
  '2': [
    {
      '1': 'tokens',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wallet.token.WatchedTokenWithBalance',
      '10': 'tokens'
    },
  ],
};

/// Descriptor for `ListTokensWithBalancesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTokensWithBalancesResponseDescriptor =
    $convert.base64Decode(
        'Ch5MaXN0VG9rZW5zV2l0aEJhbGFuY2VzUmVzcG9uc2USPQoGdG9rZW5zGAEgAygLMiUud2FsbG'
        'V0LnRva2VuLldhdGNoZWRUb2tlbldpdGhCYWxhbmNlUgZ0b2tlbnM=');

@$core.Deprecated('Use pinTokenRequestDescriptor instead')
const PinTokenRequest$json = {
  '1': 'PinTokenRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'pinned', '3': 2, '4': 1, '5': 8, '10': 'pinned'},
  ],
};

/// Descriptor for `PinTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pinTokenRequestDescriptor = $convert.base64Decode(
    'Cg9QaW5Ub2tlblJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhYKBnBpbm5lZBgCIAEoCFIGcGlubm'
    'Vk');

@$core.Deprecated('Use pinTokenResponseDescriptor instead')
const PinTokenResponse$json = {
  '1': 'PinTokenResponse',
};

/// Descriptor for `PinTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pinTokenResponseDescriptor =
    $convert.base64Decode('ChBQaW5Ub2tlblJlc3BvbnNl');

@$core.Deprecated('Use hideTokenRequestDescriptor instead')
const HideTokenRequest$json = {
  '1': 'HideTokenRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'hidden', '3': 2, '4': 1, '5': 8, '10': 'hidden'},
  ],
};

/// Descriptor for `HideTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hideTokenRequestDescriptor = $convert.base64Decode(
    'ChBIaWRlVG9rZW5SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIWCgZoaWRkZW4YAiABKAhSBmhpZG'
    'Rlbg==');

@$core.Deprecated('Use hideTokenResponseDescriptor instead')
const HideTokenResponse$json = {
  '1': 'HideTokenResponse',
};

/// Descriptor for `HideTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hideTokenResponseDescriptor =
    $convert.base64Decode('ChFIaWRlVG9rZW5SZXNwb25zZQ==');

@$core.Deprecated('Use tokenApprovalDescriptor instead')
const TokenApproval$json = {
  '1': 'TokenApproval',
  '2': [
    {'1': 'token_address', '3': 1, '4': 1, '5': 9, '10': 'tokenAddress'},
    {'1': 'token_symbol', '3': 2, '4': 1, '5': 9, '10': 'tokenSymbol'},
    {'1': 'token_name', '3': 3, '4': 1, '5': 9, '10': 'tokenName'},
    {'1': 'token_decimals', '3': 4, '4': 1, '5': 13, '10': 'tokenDecimals'},
    {'1': 'spender', '3': 5, '4': 1, '5': 9, '10': 'spender'},
    {'1': 'spender_label', '3': 6, '4': 1, '5': 9, '10': 'spenderLabel'},
    {'1': 'amount_raw', '3': 7, '4': 1, '5': 9, '10': 'amountRaw'},
    {'1': 'amount_human', '3': 8, '4': 1, '5': 9, '10': 'amountHuman'},
    {'1': 'token_logo_url', '3': 9, '4': 1, '5': 9, '10': 'tokenLogoUrl'},
  ],
};

/// Descriptor for `TokenApproval`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenApprovalDescriptor = $convert.base64Decode(
    'Cg1Ub2tlbkFwcHJvdmFsEiMKDXRva2VuX2FkZHJlc3MYASABKAlSDHRva2VuQWRkcmVzcxIhCg'
    'x0b2tlbl9zeW1ib2wYAiABKAlSC3Rva2VuU3ltYm9sEh0KCnRva2VuX25hbWUYAyABKAlSCXRv'
    'a2VuTmFtZRIlCg50b2tlbl9kZWNpbWFscxgEIAEoDVINdG9rZW5EZWNpbWFscxIYCgdzcGVuZG'
    'VyGAUgASgJUgdzcGVuZGVyEiMKDXNwZW5kZXJfbGFiZWwYBiABKAlSDHNwZW5kZXJMYWJlbBId'
    'CgphbW91bnRfcmF3GAcgASgJUglhbW91bnRSYXcSIQoMYW1vdW50X2h1bWFuGAggASgJUgthbW'
    '91bnRIdW1hbhIkCg50b2tlbl9sb2dvX3VybBgJIAEoCVIMdG9rZW5Mb2dvVXJs');

@$core.Deprecated('Use listApprovalsRequestDescriptor instead')
const ListApprovalsRequest$json = {
  '1': 'ListApprovalsRequest',
};

/// Descriptor for `ListApprovalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listApprovalsRequestDescriptor =
    $convert.base64Decode('ChRMaXN0QXBwcm92YWxzUmVxdWVzdA==');

@$core.Deprecated('Use listApprovalsResponseDescriptor instead')
const ListApprovalsResponse$json = {
  '1': 'ListApprovalsResponse',
  '2': [
    {
      '1': 'approvals',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wallet.TokenApproval',
      '10': 'approvals'
    },
  ],
};

/// Descriptor for `ListApprovalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listApprovalsResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0QXBwcm92YWxzUmVzcG9uc2USMwoJYXBwcm92YWxzGAEgAygLMhUud2FsbGV0LlRva2'
    'VuQXBwcm92YWxSCWFwcHJvdmFscw==');

@$core.Deprecated('Use revokeApprovalRequestDescriptor instead')
const RevokeApprovalRequest$json = {
  '1': 'RevokeApprovalRequest',
  '2': [
    {'1': 'token_address', '3': 1, '4': 1, '5': 9, '10': 'tokenAddress'},
    {'1': 'spender', '3': 2, '4': 1, '5': 9, '10': 'spender'},
  ],
};

/// Descriptor for `RevokeApprovalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeApprovalRequestDescriptor = $convert.base64Decode(
    'ChVSZXZva2VBcHByb3ZhbFJlcXVlc3QSIwoNdG9rZW5fYWRkcmVzcxgBIAEoCVIMdG9rZW5BZG'
    'RyZXNzEhgKB3NwZW5kZXIYAiABKAlSB3NwZW5kZXI=');

@$core.Deprecated('Use revokeApprovalResponseDescriptor instead')
const RevokeApprovalResponse$json = {
  '1': 'RevokeApprovalResponse',
  '2': [
    {
      '1': 'receipt',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.transaction.TxReceipt',
      '10': 'receipt'
    },
  ],
};

/// Descriptor for `RevokeApprovalResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeApprovalResponseDescriptor =
    $convert.base64Decode(
        'ChZSZXZva2VBcHByb3ZhbFJlc3BvbnNlEjcKB3JlY2VpcHQYASABKAsyHS53YWxsZXQudHJhbn'
        'NhY3Rpb24uVHhSZWNlaXB0UgdyZWNlaXB0');

@$core.Deprecated('Use resolveENSRequestDescriptor instead')
const ResolveENSRequest$json = {
  '1': 'ResolveENSRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ResolveENSRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveENSRequestDescriptor = $convert
    .base64Decode('ChFSZXNvbHZlRU5TUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1l');

@$core.Deprecated('Use resolveENSResponseDescriptor instead')
const ResolveENSResponse$json = {
  '1': 'ResolveENSResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `ResolveENSResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveENSResponseDescriptor =
    $convert.base64Decode(
        'ChJSZXNvbHZlRU5TUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use reverseENSRequestDescriptor instead')
const ReverseENSRequest$json = {
  '1': 'ReverseENSRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `ReverseENSRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reverseENSRequestDescriptor = $convert.base64Decode(
    'ChFSZXZlcnNlRU5TUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNz');

@$core.Deprecated('Use reverseENSResponseDescriptor instead')
const ReverseENSResponse$json = {
  '1': 'ReverseENSResponse',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ReverseENSResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reverseENSResponseDescriptor = $convert
    .base64Decode('ChJSZXZlcnNlRU5TUmVzcG9uc2USEgoEbmFtZRgBIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use speedUpTxRequestDescriptor instead')
const SpeedUpTxRequest$json = {
  '1': 'SpeedUpTxRequest',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 9, '10': 'txHash'},
  ],
};

/// Descriptor for `SpeedUpTxRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speedUpTxRequestDescriptor = $convert.base64Decode(
    'ChBTcGVlZFVwVHhSZXF1ZXN0EhcKB3R4X2hhc2gYASABKAlSBnR4SGFzaA==');

@$core.Deprecated('Use speedUpTxResponseDescriptor instead')
const SpeedUpTxResponse$json = {
  '1': 'SpeedUpTxResponse',
  '2': [
    {'1': 'new_tx_hash', '3': 1, '4': 1, '5': 9, '10': 'newTxHash'},
  ],
};

/// Descriptor for `SpeedUpTxResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speedUpTxResponseDescriptor = $convert.base64Decode(
    'ChFTcGVlZFVwVHhSZXNwb25zZRIeCgtuZXdfdHhfaGFzaBgBIAEoCVIJbmV3VHhIYXNo');

@$core.Deprecated('Use cancelTxRequestDescriptor instead')
const CancelTxRequest$json = {
  '1': 'CancelTxRequest',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 9, '10': 'txHash'},
  ],
};

/// Descriptor for `CancelTxRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelTxRequestDescriptor = $convert
    .base64Decode('Cg9DYW5jZWxUeFJlcXVlc3QSFwoHdHhfaGFzaBgBIAEoCVIGdHhIYXNo');

@$core.Deprecated('Use cancelTxResponseDescriptor instead')
const CancelTxResponse$json = {
  '1': 'CancelTxResponse',
  '2': [
    {'1': 'new_tx_hash', '3': 1, '4': 1, '5': 9, '10': 'newTxHash'},
  ],
};

/// Descriptor for `CancelTxResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelTxResponseDescriptor = $convert.base64Decode(
    'ChBDYW5jZWxUeFJlc3BvbnNlEh4KC25ld190eF9oYXNoGAEgASgJUgluZXdUeEhhc2g=');

@$core.Deprecated('Use pendingTxDescriptor instead')
const PendingTx$json = {
  '1': 'PendingTx',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 9, '10': 'txHash'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
    {'1': 'value', '3': 4, '4': 1, '5': 9, '10': 'value'},
    {'1': 'nonce', '3': 5, '4': 1, '5': 4, '10': 'nonce'},
    {'1': 'gas_tip_gwei', '3': 6, '4': 1, '5': 9, '10': 'gasTipGwei'},
    {'1': 'gas_cap_gwei', '3': 7, '4': 1, '5': 9, '10': 'gasCapGwei'},
    {'1': 'kind', '3': 8, '4': 1, '5': 9, '10': 'kind'},
    {
      '1': 'submitted_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'submittedAt'
    },
  ],
};

/// Descriptor for `PendingTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pendingTxDescriptor = $convert.base64Decode(
    'CglQZW5kaW5nVHgSFwoHdHhfaGFzaBgBIAEoCVIGdHhIYXNoEhIKBGZyb20YAiABKAlSBGZyb2'
    '0SDgoCdG8YAyABKAlSAnRvEhQKBXZhbHVlGAQgASgJUgV2YWx1ZRIUCgVub25jZRgFIAEoBFIF'
    'bm9uY2USIAoMZ2FzX3RpcF9nd2VpGAYgASgJUgpnYXNUaXBHd2VpEiAKDGdhc19jYXBfZ3dlaR'
    'gHIAEoCVIKZ2FzQ2FwR3dlaRISCgRraW5kGAggASgJUgRraW5kEj0KDHN1Ym1pdHRlZF9hdBgJ'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC3N1Ym1pdHRlZEF0');

@$core.Deprecated('Use listPendingTxsRequestDescriptor instead')
const ListPendingTxsRequest$json = {
  '1': 'ListPendingTxsRequest',
};

/// Descriptor for `ListPendingTxsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPendingTxsRequestDescriptor =
    $convert.base64Decode('ChVMaXN0UGVuZGluZ1R4c1JlcXVlc3Q=');

@$core.Deprecated('Use listPendingTxsResponseDescriptor instead')
const ListPendingTxsResponse$json = {
  '1': 'ListPendingTxsResponse',
  '2': [
    {
      '1': 'pending',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wallet.PendingTx',
      '10': 'pending'
    },
  ],
};

/// Descriptor for `ListPendingTxsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPendingTxsResponseDescriptor =
    $convert.base64Decode(
        'ChZMaXN0UGVuZGluZ1R4c1Jlc3BvbnNlEisKB3BlbmRpbmcYASADKAsyES53YWxsZXQuUGVuZG'
        'luZ1R4UgdwZW5kaW5n');

@$core.Deprecated('Use simulateSendRequestDescriptor instead')
const SimulateSendRequest$json = {
  '1': 'SimulateSendRequest',
  '2': [
    {'1': 'to', '3': 1, '4': 1, '5': 9, '10': 'to'},
    {'1': 'amount', '3': 2, '4': 1, '5': 9, '10': 'amount'},
    {'1': 'token_address', '3': 3, '4': 1, '5': 9, '10': 'tokenAddress'},
  ],
};

/// Descriptor for `SimulateSendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateSendRequestDescriptor = $convert.base64Decode(
    'ChNTaW11bGF0ZVNlbmRSZXF1ZXN0Eg4KAnRvGAEgASgJUgJ0bxIWCgZhbW91bnQYAiABKAlSBm'
    'Ftb3VudBIjCg10b2tlbl9hZGRyZXNzGAMgASgJUgx0b2tlbkFkZHJlc3M=');

@$core.Deprecated('Use simulateSendResponseDescriptor instead')
const SimulateSendResponse$json = {
  '1': 'SimulateSendResponse',
  '2': [
    {'1': 'will_revert', '3': 1, '4': 1, '5': 8, '10': 'willRevert'},
    {'1': 'revert_reason', '3': 2, '4': 1, '5': 9, '10': 'revertReason'},
    {'1': 'gas_units', '3': 3, '4': 1, '5': 4, '10': 'gasUnits'},
    {'1': 'gas_cost_eth', '3': 4, '4': 1, '5': 9, '10': 'gasCostEth'},
    {'1': 'gas_cost_usd', '3': 5, '4': 1, '5': 9, '10': 'gasCostUsd'},
    {
      '1': 'asset_changes',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.wallet.SimulatedAssetChange',
      '10': 'assetChanges'
    },
  ],
};

/// Descriptor for `SimulateSendResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateSendResponseDescriptor = $convert.base64Decode(
    'ChRTaW11bGF0ZVNlbmRSZXNwb25zZRIfCgt3aWxsX3JldmVydBgBIAEoCFIKd2lsbFJldmVydB'
    'IjCg1yZXZlcnRfcmVhc29uGAIgASgJUgxyZXZlcnRSZWFzb24SGwoJZ2FzX3VuaXRzGAMgASgE'
    'UghnYXNVbml0cxIgCgxnYXNfY29zdF9ldGgYBCABKAlSCmdhc0Nvc3RFdGgSIAoMZ2FzX2Nvc3'
    'RfdXNkGAUgASgJUgpnYXNDb3N0VXNkEkEKDWFzc2V0X2NoYW5nZXMYBiADKAsyHC53YWxsZXQu'
    'U2ltdWxhdGVkQXNzZXRDaGFuZ2VSDGFzc2V0Q2hhbmdlcw==');

@$core.Deprecated('Use simulatedAssetChangeDescriptor instead')
const SimulatedAssetChange$json = {
  '1': 'SimulatedAssetChange',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'change_type', '3': 2, '4': 1, '5': 9, '10': 'changeType'},
    {'1': 'from', '3': 3, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 4, '4': 1, '5': 9, '10': 'to'},
    {'1': 'amount', '3': 5, '4': 1, '5': 9, '10': 'amount'},
    {'1': 'symbol', '3': 6, '4': 1, '5': 9, '10': 'symbol'},
    {'1': 'name', '3': 7, '4': 1, '5': 9, '10': 'name'},
    {'1': 'decimals', '3': 8, '4': 1, '5': 13, '10': 'decimals'},
    {'1': 'contract_address', '3': 9, '4': 1, '5': 9, '10': 'contractAddress'},
    {'1': 'token_id', '3': 10, '4': 1, '5': 9, '10': 'tokenId'},
  ],
};

/// Descriptor for `SimulatedAssetChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulatedAssetChangeDescriptor = $convert.base64Decode(
    'ChRTaW11bGF0ZWRBc3NldENoYW5nZRISCgRraW5kGAEgASgJUgRraW5kEh8KC2NoYW5nZV90eX'
    'BlGAIgASgJUgpjaGFuZ2VUeXBlEhIKBGZyb20YAyABKAlSBGZyb20SDgoCdG8YBCABKAlSAnRv'
    'EhYKBmFtb3VudBgFIAEoCVIGYW1vdW50EhYKBnN5bWJvbBgGIAEoCVIGc3ltYm9sEhIKBG5hbW'
    'UYByABKAlSBG5hbWUSGgoIZGVjaW1hbHMYCCABKA1SCGRlY2ltYWxzEikKEGNvbnRyYWN0X2Fk'
    'ZHJlc3MYCSABKAlSD2NvbnRyYWN0QWRkcmVzcxIZCgh0b2tlbl9pZBgKIAEoCVIHdG9rZW5JZA'
    '==');

@$core.Deprecated('Use watchEventsRequestDescriptor instead')
const WatchEventsRequest$json = {
  '1': 'WatchEventsRequest',
};

/// Descriptor for `WatchEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchEventsRequestDescriptor =
    $convert.base64Decode('ChJXYXRjaEV2ZW50c1JlcXVlc3Q=');

@$core.Deprecated('Use notificationEnvelopeDescriptor instead')
const NotificationEnvelope$json = {
  '1': 'NotificationEnvelope',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'is_read', '3': 2, '4': 1, '5': 8, '10': 'isRead'},
    {
      '1': 'event',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.wallet.event.WalletEvent',
      '10': 'event'
    },
  ],
};

/// Descriptor for `NotificationEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationEnvelopeDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25FbnZlbG9wZRIOCgJpZBgBIAEoCVICaWQSFwoHaXNfcmVhZBgCIAEoCF'
    'IGaXNSZWFkEi8KBWV2ZW50GAMgASgLMhkud2FsbGV0LmV2ZW50LldhbGxldEV2ZW50UgVldmVu'
    'dA==');

@$core.Deprecated('Use listNotificationsRequestDescriptor instead')
const ListNotificationsRequest$json = {
  '1': 'ListNotificationsRequest',
  '2': [
    {'1': 'limit', '3': 1, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `ListNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNotificationsRequestDescriptor =
    $convert.base64Decode(
        'ChhMaXN0Tm90aWZpY2F0aW9uc1JlcXVlc3QSFAoFbGltaXQYASABKAVSBWxpbWl0');

@$core.Deprecated('Use listNotificationsResponseDescriptor instead')
const ListNotificationsResponse$json = {
  '1': 'ListNotificationsResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wallet.NotificationEnvelope',
      '10': 'items'
    },
  ],
};

/// Descriptor for `ListNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNotificationsResponseDescriptor =
    $convert.base64Decode(
        'ChlMaXN0Tm90aWZpY2F0aW9uc1Jlc3BvbnNlEjIKBWl0ZW1zGAEgAygLMhwud2FsbGV0Lk5vdG'
        'lmaWNhdGlvbkVudmVsb3BlUgVpdGVtcw==');

@$core.Deprecated('Use markNotificationReadRequestDescriptor instead')
const MarkNotificationReadRequest$json = {
  '1': 'MarkNotificationReadRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `MarkNotificationReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markNotificationReadRequestDescriptor =
    $convert.base64Decode(
        'ChtNYXJrTm90aWZpY2F0aW9uUmVhZFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use markNotificationReadResponseDescriptor instead')
const MarkNotificationReadResponse$json = {
  '1': 'MarkNotificationReadResponse',
};

/// Descriptor for `MarkNotificationReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markNotificationReadResponseDescriptor =
    $convert.base64Decode('ChxNYXJrTm90aWZpY2F0aW9uUmVhZFJlc3BvbnNl');

@$core.Deprecated('Use markAllNotificationsReadRequestDescriptor instead')
const MarkAllNotificationsReadRequest$json = {
  '1': 'MarkAllNotificationsReadRequest',
};

/// Descriptor for `MarkAllNotificationsReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAllNotificationsReadRequestDescriptor =
    $convert.base64Decode('Ch9NYXJrQWxsTm90aWZpY2F0aW9uc1JlYWRSZXF1ZXN0');

@$core.Deprecated('Use markAllNotificationsReadResponseDescriptor instead')
const MarkAllNotificationsReadResponse$json = {
  '1': 'MarkAllNotificationsReadResponse',
};

/// Descriptor for `MarkAllNotificationsReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAllNotificationsReadResponseDescriptor =
    $convert.base64Decode('CiBNYXJrQWxsTm90aWZpY2F0aW9uc1JlYWRSZXNwb25zZQ==');

@$core.Deprecated('Use clearNotificationsRequestDescriptor instead')
const ClearNotificationsRequest$json = {
  '1': 'ClearNotificationsRequest',
};

/// Descriptor for `ClearNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearNotificationsRequestDescriptor =
    $convert.base64Decode('ChlDbGVhck5vdGlmaWNhdGlvbnNSZXF1ZXN0');

@$core.Deprecated('Use clearNotificationsResponseDescriptor instead')
const ClearNotificationsResponse$json = {
  '1': 'ClearNotificationsResponse',
};

/// Descriptor for `ClearNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearNotificationsResponseDescriptor =
    $convert.base64Decode('ChpDbGVhck5vdGlmaWNhdGlvbnNSZXNwb25zZQ==');

@$core.Deprecated('Use notificationSettingsDescriptor instead')
const NotificationSettings$json = {
  '1': 'NotificationSettings',
  '2': [
    {'1': 'play_sound', '3': 1, '4': 1, '5': 8, '10': 'playSound'},
    {'1': 'macos_toasts', '3': 2, '4': 1, '5': 8, '10': 'macosToasts'},
    {'1': 'auto_mark_read', '3': 3, '4': 1, '5': 8, '10': 'autoMarkRead'},
    {'1': 'auto_delete_days', '3': 4, '4': 1, '5': 5, '10': 'autoDeleteDays'},
    {
      '1': 'mute_system_alerts',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'muteSystemAlerts'
    },
  ],
};

/// Descriptor for `NotificationSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationSettingsDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25TZXR0aW5ncxIdCgpwbGF5X3NvdW5kGAEgASgIUglwbGF5U291bmQSIQ'
    'oMbWFjb3NfdG9hc3RzGAIgASgIUgttYWNvc1RvYXN0cxIkCg5hdXRvX21hcmtfcmVhZBgDIAEo'
    'CFIMYXV0b01hcmtSZWFkEigKEGF1dG9fZGVsZXRlX2RheXMYBCABKAVSDmF1dG9EZWxldGVEYX'
    'lzEiwKEm11dGVfc3lzdGVtX2FsZXJ0cxgFIAEoCFIQbXV0ZVN5c3RlbUFsZXJ0cw==');

@$core.Deprecated('Use getNotificationSettingsRequestDescriptor instead')
const GetNotificationSettingsRequest$json = {
  '1': 'GetNotificationSettingsRequest',
};

/// Descriptor for `GetNotificationSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationSettingsRequestDescriptor =
    $convert.base64Decode('Ch5HZXROb3RpZmljYXRpb25TZXR0aW5nc1JlcXVlc3Q=');

@$core.Deprecated('Use getNotificationSettingsResponseDescriptor instead')
const GetNotificationSettingsResponse$json = {
  '1': 'GetNotificationSettingsResponse',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.NotificationSettings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `GetNotificationSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationSettingsResponseDescriptor =
    $convert.base64Decode(
        'Ch9HZXROb3RpZmljYXRpb25TZXR0aW5nc1Jlc3BvbnNlEjgKCHNldHRpbmdzGAEgASgLMhwud2'
        'FsbGV0Lk5vdGlmaWNhdGlvblNldHRpbmdzUghzZXR0aW5ncw==');

@$core.Deprecated('Use updateNotificationSettingsRequestDescriptor instead')
const UpdateNotificationSettingsRequest$json = {
  '1': 'UpdateNotificationSettingsRequest',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.NotificationSettings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `UpdateNotificationSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNotificationSettingsRequestDescriptor =
    $convert.base64Decode(
        'CiFVcGRhdGVOb3RpZmljYXRpb25TZXR0aW5nc1JlcXVlc3QSOAoIc2V0dGluZ3MYASABKAsyHC'
        '53YWxsZXQuTm90aWZpY2F0aW9uU2V0dGluZ3NSCHNldHRpbmdz');

@$core.Deprecated('Use updateNotificationSettingsResponseDescriptor instead')
const UpdateNotificationSettingsResponse$json = {
  '1': 'UpdateNotificationSettingsResponse',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.NotificationSettings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `UpdateNotificationSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNotificationSettingsResponseDescriptor =
    $convert.base64Decode(
        'CiJVcGRhdGVOb3RpZmljYXRpb25TZXR0aW5nc1Jlc3BvbnNlEjgKCHNldHRpbmdzGAEgASgLMh'
        'wud2FsbGV0Lk5vdGlmaWNhdGlvblNldHRpbmdzUghzZXR0aW5ncw==');
