// This is a generated file - do not edit.
//
// Generated from wallet/event/event.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TransactionEvent_Role extends $pb.ProtobufEnum {
  static const TransactionEvent_Role ROLE_UNSPECIFIED =
      TransactionEvent_Role._(0, _omitEnumNames ? '' : 'ROLE_UNSPECIFIED');
  static const TransactionEvent_Role ROLE_SEND_ETH =
      TransactionEvent_Role._(1, _omitEnumNames ? '' : 'ROLE_SEND_ETH');
  static const TransactionEvent_Role ROLE_RECEIVE_ETH =
      TransactionEvent_Role._(2, _omitEnumNames ? '' : 'ROLE_RECEIVE_ETH');
  static const TransactionEvent_Role ROLE_SEND_TOKEN =
      TransactionEvent_Role._(3, _omitEnumNames ? '' : 'ROLE_SEND_TOKEN');
  static const TransactionEvent_Role ROLE_RECEIVE_TOKEN =
      TransactionEvent_Role._(4, _omitEnumNames ? '' : 'ROLE_RECEIVE_TOKEN');
  static const TransactionEvent_Role ROLE_SWAP =
      TransactionEvent_Role._(5, _omitEnumNames ? '' : 'ROLE_SWAP');
  static const TransactionEvent_Role ROLE_SELF_TRANSFER =
      TransactionEvent_Role._(6, _omitEnumNames ? '' : 'ROLE_SELF_TRANSFER');
  static const TransactionEvent_Role ROLE_APPROVE =
      TransactionEvent_Role._(7, _omitEnumNames ? '' : 'ROLE_APPROVE');

  static const $core.List<TransactionEvent_Role> values =
      <TransactionEvent_Role>[
    ROLE_UNSPECIFIED,
    ROLE_SEND_ETH,
    ROLE_RECEIVE_ETH,
    ROLE_SEND_TOKEN,
    ROLE_RECEIVE_TOKEN,
    ROLE_SWAP,
    ROLE_SELF_TRANSFER,
    ROLE_APPROVE,
  ];

  static final $core.List<TransactionEvent_Role?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static TransactionEvent_Role? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TransactionEvent_Role._(super.value, super.name);
}

class GasAlertEvent_AlertType extends $pb.ProtobufEnum {
  static const GasAlertEvent_AlertType ALERT_TYPE_UNSPECIFIED =
      GasAlertEvent_AlertType._(
          0, _omitEnumNames ? '' : 'ALERT_TYPE_UNSPECIFIED');
  static const GasAlertEvent_AlertType ALERT_TYPE_SPIKE =
      GasAlertEvent_AlertType._(1, _omitEnumNames ? '' : 'ALERT_TYPE_SPIKE');
  static const GasAlertEvent_AlertType ALERT_TYPE_DROP =
      GasAlertEvent_AlertType._(2, _omitEnumNames ? '' : 'ALERT_TYPE_DROP');

  static const $core.List<GasAlertEvent_AlertType> values =
      <GasAlertEvent_AlertType>[
    ALERT_TYPE_UNSPECIFIED,
    ALERT_TYPE_SPIKE,
    ALERT_TYPE_DROP,
  ];

  static final $core.List<GasAlertEvent_AlertType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static GasAlertEvent_AlertType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GasAlertEvent_AlertType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
