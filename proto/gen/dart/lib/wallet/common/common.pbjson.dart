// This is a generated file - do not edit.
//
// Generated from wallet/common/common.proto.

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

@$core.Deprecated('Use pageParamsDescriptor instead')
const PageParams$json = {
  '1': 'PageParams',
  '2': [
    {'1': 'limit', '3': 1, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `PageParams`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pageParamsDescriptor = $convert.base64Decode(
    'CgpQYWdlUGFyYW1zEhQKBWxpbWl0GAEgASgFUgVsaW1pdBIWCgZjdXJzb3IYAiABKAlSBmN1cn'
    'Nvcg==');

@$core.Deprecated('Use pageInfoDescriptor instead')
const PageInfo$json = {
  '1': 'PageInfo',
  '2': [
    {'1': 'next_cursor', '3': 1, '4': 1, '5': 9, '10': 'nextCursor'},
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `PageInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pageInfoDescriptor = $convert.base64Decode(
    'CghQYWdlSW5mbxIfCgtuZXh0X2N1cnNvchgBIAEoCVIKbmV4dEN1cnNvchIZCghoYXNfbW9yZR'
    'gCIAEoCFIHaGFzTW9yZRIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');
