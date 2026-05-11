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

class PoolFee extends $pb.ProtobufEnum {
  static const PoolFee POOL_FEE_UNSPECIFIED =
      PoolFee._(0, _omitEnumNames ? '' : 'POOL_FEE_UNSPECIFIED');
  static const PoolFee POOL_FEE_100 =
      PoolFee._(1, _omitEnumNames ? '' : 'POOL_FEE_100');
  static const PoolFee POOL_FEE_500 =
      PoolFee._(2, _omitEnumNames ? '' : 'POOL_FEE_500');
  static const PoolFee POOL_FEE_3000 =
      PoolFee._(3, _omitEnumNames ? '' : 'POOL_FEE_3000');
  static const PoolFee POOL_FEE_10000 =
      PoolFee._(4, _omitEnumNames ? '' : 'POOL_FEE_10000');

  static const $core.List<PoolFee> values = <PoolFee>[
    POOL_FEE_UNSPECIFIED,
    POOL_FEE_100,
    POOL_FEE_500,
    POOL_FEE_3000,
    POOL_FEE_10000,
  ];

  static final $core.List<PoolFee?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static PoolFee? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PoolFee._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
