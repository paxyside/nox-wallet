// This is a generated file - do not edit.
//
// Generated from wallet/wallet/wallet.proto.

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

@$core.Deprecated('Use secretTypeDescriptor instead')
const SecretType$json = {
  '1': 'SecretType',
  '2': [
    {'1': 'SECRET_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SECRET_TYPE_MNEMONIC', '2': 1},
    {'1': 'SECRET_TYPE_PRIVATE_KEY', '2': 2},
  ],
};

/// Descriptor for `SecretType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List secretTypeDescriptor = $convert.base64Decode(
    'CgpTZWNyZXRUeXBlEhsKF1NFQ1JFVF9UWVBFX1VOU1BFQ0lGSUVEEAASGAoUU0VDUkVUX1RZUE'
    'VfTU5FTU9OSUMQARIbChdTRUNSRVRfVFlQRV9QUklWQVRFX0tFWRAC');

@$core.Deprecated('Use walletDescriptor instead')
const Wallet$json = {
  '1': 'Wallet',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {
      '1': 'secret_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.wallet.wallet.SecretType',
      '10': 'secretType'
    },
    {
      '1': 'created_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Wallet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletDescriptor = $convert.base64Decode(
    'CgZXYWxsZXQSDgoCaWQYASABKAlSAmlkEhgKB2FkZHJlc3MYAiABKAlSB2FkZHJlc3MSFAoFbG'
    'FiZWwYAyABKAlSBWxhYmVsEjoKC3NlY3JldF90eXBlGAQgASgOMhkud2FsbGV0LndhbGxldC5T'
    'ZWNyZXRUeXBlUgpzZWNyZXRUeXBlEjkKCmNyZWF0ZWRfYXQYBSABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');
