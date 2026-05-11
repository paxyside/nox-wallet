// This is a generated file - do not edit.
//
// Generated from wallet/event/event.proto.

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

@$core.Deprecated('Use walletEventDescriptor instead')
const WalletEvent$json = {
  '1': 'WalletEvent',
  '2': [
    {
      '1': 'gas_alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wallet.event.GasAlertEvent',
      '9': 0,
      '10': 'gasAlert'
    },
    {
      '1': 'low_balance',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.wallet.event.LowBalanceEvent',
      '9': 0,
      '10': 'lowBalance'
    },
    {
      '1': 'transaction',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.wallet.event.TransactionEvent',
      '9': 0,
      '10': 'transaction'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `WalletEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletEventDescriptor = $convert.base64Decode(
    'CgtXYWxsZXRFdmVudBI6CglnYXNfYWxlcnQYASABKAsyGy53YWxsZXQuZXZlbnQuR2FzQWxlcn'
    'RFdmVudEgAUghnYXNBbGVydBJACgtsb3dfYmFsYW5jZRgCIAEoCzIdLndhbGxldC5ldmVudC5M'
    'b3dCYWxhbmNlRXZlbnRIAFIKbG93QmFsYW5jZRJCCgt0cmFuc2FjdGlvbhgDIAEoCzIeLndhbG'
    'xldC5ldmVudC5UcmFuc2FjdGlvbkV2ZW50SABSC3RyYW5zYWN0aW9uQgkKB3BheWxvYWQ=');

@$core.Deprecated('Use assetMovementDescriptor instead')
const AssetMovement$json = {
  '1': 'AssetMovement',
  '2': [
    {'1': 'symbol', '3': 1, '4': 1, '5': 9, '10': 'symbol'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'contract_address', '3': 3, '4': 1, '5': 9, '10': 'contractAddress'},
    {'1': 'amount', '3': 4, '4': 1, '5': 9, '10': 'amount'},
    {'1': 'is_outgoing', '3': 5, '4': 1, '5': 8, '10': 'isOutgoing'},
    {'1': 'counterparty', '3': 6, '4': 1, '5': 9, '10': 'counterparty'},
  ],
};

/// Descriptor for `AssetMovement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assetMovementDescriptor = $convert.base64Decode(
    'Cg1Bc3NldE1vdmVtZW50EhYKBnN5bWJvbBgBIAEoCVIGc3ltYm9sEhIKBG5hbWUYAiABKAlSBG'
    '5hbWUSKQoQY29udHJhY3RfYWRkcmVzcxgDIAEoCVIPY29udHJhY3RBZGRyZXNzEhYKBmFtb3Vu'
    'dBgEIAEoCVIGYW1vdW50Eh8KC2lzX291dGdvaW5nGAUgASgIUgppc091dGdvaW5nEiIKDGNvdW'
    '50ZXJwYXJ0eRgGIAEoCVIMY291bnRlcnBhcnR5');

@$core.Deprecated('Use transactionEventDescriptor instead')
const TransactionEvent$json = {
  '1': 'TransactionEvent',
  '2': [
    {'1': 'tx_hash', '3': 1, '4': 1, '5': 9, '10': 'txHash'},
    {
      '1': 'role',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.wallet.event.TransactionEvent.Role',
      '10': 'role'
    },
    {
      '1': 'movements',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.wallet.event.AssetMovement',
      '10': 'movements'
    },
    {'1': 'is_ours', '3': 4, '4': 1, '5': 8, '10': 'isOurs'},
    {'1': 'block_number', '3': 5, '4': 1, '5': 4, '10': 'blockNumber'},
    {
      '1': 'timestamp',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
  '4': [TransactionEvent_Role$json],
};

@$core.Deprecated('Use transactionEventDescriptor instead')
const TransactionEvent_Role$json = {
  '1': 'Role',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'SEND_ETH', '2': 1},
    {'1': 'RECEIVE_ETH', '2': 2},
    {'1': 'SEND_TOKEN', '2': 3},
    {'1': 'RECEIVE_TOKEN', '2': 4},
    {'1': 'SWAP', '2': 5},
    {'1': 'SELF_TRANSFER', '2': 6},
    {'1': 'APPROVE', '2': 7},
  ],
};

/// Descriptor for `TransactionEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionEventDescriptor = $convert.base64Decode(
    'ChBUcmFuc2FjdGlvbkV2ZW50EhcKB3R4X2hhc2gYASABKAlSBnR4SGFzaBI3CgRyb2xlGAIgAS'
    'gOMiMud2FsbGV0LmV2ZW50LlRyYW5zYWN0aW9uRXZlbnQuUm9sZVIEcm9sZRI5Cgltb3ZlbWVu'
    'dHMYAyADKAsyGy53YWxsZXQuZXZlbnQuQXNzZXRNb3ZlbWVudFIJbW92ZW1lbnRzEhcKB2lzX2'
    '91cnMYBCABKAhSBmlzT3VycxIhCgxibG9ja19udW1iZXIYBSABKARSC2Jsb2NrTnVtYmVyEjgK'
    'CXRpbWVzdGFtcBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcC'
    'J/CgRSb2xlEgsKB1VOS05PV04QABIMCghTRU5EX0VUSBABEg8KC1JFQ0VJVkVfRVRIEAISDgoK'
    'U0VORF9UT0tFThADEhEKDVJFQ0VJVkVfVE9LRU4QBBIICgRTV0FQEAUSEQoNU0VMRl9UUkFOU0'
    'ZFUhAGEgsKB0FQUFJPVkUQBw==');

@$core.Deprecated('Use gasAlertEventDescriptor instead')
const GasAlertEvent$json = {
  '1': 'GasAlertEvent',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.wallet.event.GasAlertEvent.AlertType',
      '10': 'type'
    },
    {'1': 'current_gwei', '3': 2, '4': 1, '5': 9, '10': 'currentGwei'},
    {'1': 'previous_gwei', '3': 3, '4': 1, '5': 9, '10': 'previousGwei'},
  ],
  '4': [GasAlertEvent_AlertType$json],
};

@$core.Deprecated('Use gasAlertEventDescriptor instead')
const GasAlertEvent_AlertType$json = {
  '1': 'AlertType',
  '2': [
    {'1': 'SPIKE', '2': 0},
    {'1': 'DROP', '2': 1},
  ],
};

/// Descriptor for `GasAlertEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gasAlertEventDescriptor = $convert.base64Decode(
    'Cg1HYXNBbGVydEV2ZW50EjkKBHR5cGUYASABKA4yJS53YWxsZXQuZXZlbnQuR2FzQWxlcnRFdm'
    'VudC5BbGVydFR5cGVSBHR5cGUSIQoMY3VycmVudF9nd2VpGAIgASgJUgtjdXJyZW50R3dlaRIj'
    'Cg1wcmV2aW91c19nd2VpGAMgASgJUgxwcmV2aW91c0d3ZWkiIAoJQWxlcnRUeXBlEgkKBVNQSU'
    'tFEAASCAoERFJPUBAB');

@$core.Deprecated('Use lowBalanceEventDescriptor instead')
const LowBalanceEvent$json = {
  '1': 'LowBalanceEvent',
  '2': [
    {'1': 'eth_balance', '3': 1, '4': 1, '5': 9, '10': 'ethBalance'},
    {'1': 'eth_balance_wei', '3': 2, '4': 1, '5': 9, '10': 'ethBalanceWei'},
  ],
};

/// Descriptor for `LowBalanceEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lowBalanceEventDescriptor = $convert.base64Decode(
    'Cg9Mb3dCYWxhbmNlRXZlbnQSHwoLZXRoX2JhbGFuY2UYASABKAlSCmV0aEJhbGFuY2USJgoPZX'
    'RoX2JhbGFuY2Vfd2VpGAIgASgJUg1ldGhCYWxhbmNlV2Vp');
