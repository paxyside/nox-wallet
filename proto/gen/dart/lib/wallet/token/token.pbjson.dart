// This is a generated file - do not edit.
//
// Generated from wallet/token/token.proto.

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

@$core.Deprecated('Use watchedTokenDescriptor instead')
const WatchedToken$json = {
  '1': 'WatchedToken',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'symbol', '3': 3, '4': 1, '5': 9, '10': 'symbol'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'decimals', '3': 5, '4': 1, '5': 13, '10': 'decimals'},
    {
      '1': 'added_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'addedAt'
    },
    {'1': 'is_pinned', '3': 7, '4': 1, '5': 8, '10': 'isPinned'},
    {'1': 'is_hidden', '3': 8, '4': 1, '5': 8, '10': 'isHidden'},
  ],
};

/// Descriptor for `WatchedToken`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchedTokenDescriptor = $convert.base64Decode(
    'CgxXYXRjaGVkVG9rZW4SDgoCaWQYASABKAlSAmlkEhgKB2FkZHJlc3MYAiABKAlSB2FkZHJlc3'
    'MSFgoGc3ltYm9sGAMgASgJUgZzeW1ib2wSEgoEbmFtZRgEIAEoCVIEbmFtZRIaCghkZWNpbWFs'
    'cxgFIAEoDVIIZGVjaW1hbHMSNQoIYWRkZWRfYXQYBiABKAsyGi5nb29nbGUucHJvdG9idWYuVG'
    'ltZXN0YW1wUgdhZGRlZEF0EhsKCWlzX3Bpbm5lZBgHIAEoCFIIaXNQaW5uZWQSGwoJaXNfaGlk'
    'ZGVuGAggASgIUghpc0hpZGRlbg==');

@$core.Deprecated('Use tokenMarketDataDescriptor instead')
const TokenMarketData$json = {
  '1': 'TokenMarketData',
  '2': [
    {'1': 'price_usd', '3': 1, '4': 1, '5': 9, '10': 'priceUsd'},
    {'1': 'change_24h_pct', '3': 2, '4': 1, '5': 9, '10': 'change24hPct'},
    {'1': 'change_positive', '3': 3, '4': 1, '5': 8, '10': 'changePositive'},
    {'1': 'sparkline_7d', '3': 4, '4': 3, '5': 1, '10': 'sparkline7d'},
    {'1': 'sparkline_30d', '3': 5, '4': 3, '5': 1, '10': 'sparkline30d'},
  ],
};

/// Descriptor for `TokenMarketData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenMarketDataDescriptor = $convert.base64Decode(
    'Cg9Ub2tlbk1hcmtldERhdGESGwoJcHJpY2VfdXNkGAEgASgJUghwcmljZVVzZBIkCg5jaGFuZ2'
    'VfMjRoX3BjdBgCIAEoCVIMY2hhbmdlMjRoUGN0EicKD2NoYW5nZV9wb3NpdGl2ZRgDIAEoCFIO'
    'Y2hhbmdlUG9zaXRpdmUSIQoMc3BhcmtsaW5lXzdkGAQgAygBUgtzcGFya2xpbmU3ZBIjCg1zcG'
    'Fya2xpbmVfMzBkGAUgAygBUgxzcGFya2xpbmUzMGQ=');

@$core.Deprecated('Use watchedTokenWithBalanceDescriptor instead')
const WatchedTokenWithBalance$json = {
  '1': 'WatchedTokenWithBalance',
  '2': [
    {
      '1': 'token',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.token.WatchedToken',
      '10': 'token'
    },
    {'1': 'balance', '3': 2, '4': 1, '5': 9, '10': 'balance'},
    {'1': 'balance_usd', '3': 3, '4': 1, '5': 9, '10': 'balanceUsd'},
    {
      '1': 'market',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.wallet.token.TokenMarketData',
      '10': 'market'
    },
  ],
};

/// Descriptor for `WatchedTokenWithBalance`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchedTokenWithBalanceDescriptor = $convert.base64Decode(
    'ChdXYXRjaGVkVG9rZW5XaXRoQmFsYW5jZRIwCgV0b2tlbhgBIAEoCzIaLndhbGxldC50b2tlbi'
    '5XYXRjaGVkVG9rZW5SBXRva2VuEhgKB2JhbGFuY2UYAiABKAlSB2JhbGFuY2USHwoLYmFsYW5j'
    'ZV91c2QYAyABKAlSCmJhbGFuY2VVc2QSNQoGbWFya2V0GAQgASgLMh0ud2FsbGV0LnRva2VuLl'
    'Rva2VuTWFya2V0RGF0YVIGbWFya2V0');
