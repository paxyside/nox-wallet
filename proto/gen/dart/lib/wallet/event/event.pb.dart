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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'event.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'event.pbenum.dart';

enum WalletEvent_Payload { gasAlert, lowBalance, transaction, notSet }

class WalletEvent extends $pb.GeneratedMessage {
  factory WalletEvent({
    GasAlertEvent? gasAlert,
    LowBalanceEvent? lowBalance,
    TransactionEvent? transaction,
  }) {
    final result = create();
    if (gasAlert != null) result.gasAlert = gasAlert;
    if (lowBalance != null) result.lowBalance = lowBalance;
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  WalletEvent._();

  factory WalletEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WalletEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WalletEvent_Payload>
      _WalletEvent_PayloadByTag = {
    1: WalletEvent_Payload.gasAlert,
    2: WalletEvent_Payload.lowBalance,
    3: WalletEvent_Payload.transaction,
    0: WalletEvent_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WalletEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.event'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<GasAlertEvent>(1, _omitFieldNames ? '' : 'gasAlert',
        subBuilder: GasAlertEvent.create)
    ..aOM<LowBalanceEvent>(2, _omitFieldNames ? '' : 'lowBalance',
        subBuilder: LowBalanceEvent.create)
    ..aOM<TransactionEvent>(3, _omitFieldNames ? '' : 'transaction',
        subBuilder: TransactionEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletEvent copyWith(void Function(WalletEvent) updates) =>
      super.copyWith((message) => updates(message as WalletEvent))
          as WalletEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WalletEvent create() => WalletEvent._();
  @$core.override
  WalletEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WalletEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WalletEvent>(create);
  static WalletEvent? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  WalletEvent_Payload whichPayload() =>
      _WalletEvent_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GasAlertEvent get gasAlert => $_getN(0);
  @$pb.TagNumber(1)
  set gasAlert(GasAlertEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearGasAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  GasAlertEvent ensureGasAlert() => $_ensure(0);

  @$pb.TagNumber(2)
  LowBalanceEvent get lowBalance => $_getN(1);
  @$pb.TagNumber(2)
  set lowBalance(LowBalanceEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLowBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearLowBalance() => $_clearField(2);
  @$pb.TagNumber(2)
  LowBalanceEvent ensureLowBalance() => $_ensure(1);

  @$pb.TagNumber(3)
  TransactionEvent get transaction => $_getN(2);
  @$pb.TagNumber(3)
  set transaction(TransactionEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTransaction() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransaction() => $_clearField(3);
  @$pb.TagNumber(3)
  TransactionEvent ensureTransaction() => $_ensure(2);
}

/// AssetMovement is a single in/out leg of a TransactionEvent. A simple
/// Send produces one outgoing movement; a Swap produces two (outgoing
/// input asset + incoming output asset).
class AssetMovement extends $pb.GeneratedMessage {
  factory AssetMovement({
    $core.String? symbol,
    $core.String? name,
    $core.String? contractAddress,
    $core.String? amount,
    $core.bool? isOutgoing,
    $core.String? counterparty,
  }) {
    final result = create();
    if (symbol != null) result.symbol = symbol;
    if (name != null) result.name = name;
    if (contractAddress != null) result.contractAddress = contractAddress;
    if (amount != null) result.amount = amount;
    if (isOutgoing != null) result.isOutgoing = isOutgoing;
    if (counterparty != null) result.counterparty = counterparty;
    return result;
  }

  AssetMovement._();

  factory AssetMovement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AssetMovement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssetMovement',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.event'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'symbol')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'contractAddress')
    ..aOS(4, _omitFieldNames ? '' : 'amount')
    ..aOB(5, _omitFieldNames ? '' : 'isOutgoing')
    ..aOS(6, _omitFieldNames ? '' : 'counterparty')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssetMovement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssetMovement copyWith(void Function(AssetMovement) updates) =>
      super.copyWith((message) => updates(message as AssetMovement))
          as AssetMovement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssetMovement create() => AssetMovement._();
  @$core.override
  AssetMovement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AssetMovement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssetMovement>(create);
  static AssetMovement? _defaultInstance;

  /// Token symbol — "ETH" for native, ERC-20 ticker otherwise. Falls back
  /// to "Unknown" when the contract didn't expose `symbol()`.
  @$pb.TagNumber(1)
  $core.String get symbol => $_getSZ(0);
  @$pb.TagNumber(1)
  set symbol($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSymbol() => $_has(0);
  @$pb.TagNumber(1)
  void clearSymbol() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// Empty for native ETH; lowercase 0x-prefixed contract for ERC-20.
  @$pb.TagNumber(3)
  $core.String get contractAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set contractAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContractAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearContractAddress() => $_clearField(3);

  /// Human-readable amount, decimals already applied. "0.001234" for
  /// small numbers, "1,234.5" doesn't apply (no separators).
  @$pb.TagNumber(4)
  $core.String get amount => $_getSZ(3);
  @$pb.TagNumber(4)
  set amount($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);

  /// Negative side from wallet's POV. For a Swap, both `is_outgoing` legs
  /// sum to "what you spent", incoming legs to "what you received".
  @$pb.TagNumber(5)
  $core.bool get isOutgoing => $_getBF(4);
  @$pb.TagNumber(5)
  set isOutgoing($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsOutgoing() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsOutgoing() => $_clearField(5);

  /// The other side of the leg — for a Send, the recipient address;
  /// for a Receive, the sender; for a Swap, the pool/router. Lowercase
  /// hex.
  @$pb.TagNumber(6)
  $core.String get counterparty => $_getSZ(5);
  @$pb.TagNumber(6)
  set counterparty($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCounterparty() => $_has(5);
  @$pb.TagNumber(6)
  void clearCounterparty() => $_clearField(6);
}

/// TransactionEvent is the canonical event the UI listens to. One event
/// per on-chain tx hash that involves the loaded wallet, regardless of how
/// many internal transfers / Transfer logs / native deltas it produced.
class TransactionEvent extends $pb.GeneratedMessage {
  factory TransactionEvent({
    $core.String? txHash,
    TransactionEvent_Role? role,
    $core.Iterable<AssetMovement>? movements,
    $core.bool? isOurs,
    $fixnum.Int64? blockNumber,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (txHash != null) result.txHash = txHash;
    if (role != null) result.role = role;
    if (movements != null) result.movements.addAll(movements);
    if (isOurs != null) result.isOurs = isOurs;
    if (blockNumber != null) result.blockNumber = blockNumber;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  TransactionEvent._();

  factory TransactionEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransactionEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransactionEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.event'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txHash')
    ..aE<TransactionEvent_Role>(2, _omitFieldNames ? '' : 'role',
        enumValues: TransactionEvent_Role.values)
    ..pPM<AssetMovement>(3, _omitFieldNames ? '' : 'movements',
        subBuilder: AssetMovement.create)
    ..aOB(4, _omitFieldNames ? '' : 'isOurs')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'blockNumber', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionEvent copyWith(void Function(TransactionEvent) updates) =>
      super.copyWith((message) => updates(message as TransactionEvent))
          as TransactionEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionEvent create() => TransactionEvent._();
  @$core.override
  TransactionEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransactionEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransactionEvent>(create);
  static TransactionEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set txHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => $_clearField(1);

  @$pb.TagNumber(2)
  TransactionEvent_Role get role => $_getN(1);
  @$pb.TagNumber(2)
  set role(TransactionEvent_Role value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<AssetMovement> get movements => $_getList(2);

  /// True when this hash was in the local pending-tx tracker — i.e. the
  /// user clicked Send / Swap from this very app. Frontend suppresses the
  /// OS notification in that case (the result modal already showed the
  /// outcome) but keeps the event in the in-app history.
  @$pb.TagNumber(4)
  $core.bool get isOurs => $_getBF(3);
  @$pb.TagNumber(4)
  set isOurs($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsOurs() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsOurs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockNumber => $_getI64(4);
  @$pb.TagNumber(5)
  set blockNumber($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockNumber() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get timestamp => $_getN(5);
  @$pb.TagNumber(6)
  set timestamp($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureTimestamp() => $_ensure(5);
}

/// Gas price changed significantly (spike or drop).
class GasAlertEvent extends $pb.GeneratedMessage {
  factory GasAlertEvent({
    GasAlertEvent_AlertType? type,
    $core.String? currentGwei,
    $core.String? previousGwei,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (currentGwei != null) result.currentGwei = currentGwei;
    if (previousGwei != null) result.previousGwei = previousGwei;
    return result;
  }

  GasAlertEvent._();

  factory GasAlertEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GasAlertEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GasAlertEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.event'),
      createEmptyInstance: create)
    ..aE<GasAlertEvent_AlertType>(1, _omitFieldNames ? '' : 'type',
        enumValues: GasAlertEvent_AlertType.values)
    ..aOS(2, _omitFieldNames ? '' : 'currentGwei')
    ..aOS(3, _omitFieldNames ? '' : 'previousGwei')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasAlertEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasAlertEvent copyWith(void Function(GasAlertEvent) updates) =>
      super.copyWith((message) => updates(message as GasAlertEvent))
          as GasAlertEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GasAlertEvent create() => GasAlertEvent._();
  @$core.override
  GasAlertEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GasAlertEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GasAlertEvent>(create);
  static GasAlertEvent? _defaultInstance;

  @$pb.TagNumber(1)
  GasAlertEvent_AlertType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(GasAlertEvent_AlertType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get currentGwei => $_getSZ(1);
  @$pb.TagNumber(2)
  set currentGwei($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrentGwei() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentGwei() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get previousGwei => $_getSZ(2);
  @$pb.TagNumber(3)
  set previousGwei($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPreviousGwei() => $_has(2);
  @$pb.TagNumber(3)
  void clearPreviousGwei() => $_clearField(3);
}

/// ETH balance fell below the critical threshold.
class LowBalanceEvent extends $pb.GeneratedMessage {
  factory LowBalanceEvent({
    $core.String? ethBalance,
    $core.String? ethBalanceWei,
  }) {
    final result = create();
    if (ethBalance != null) result.ethBalance = ethBalance;
    if (ethBalanceWei != null) result.ethBalanceWei = ethBalanceWei;
    return result;
  }

  LowBalanceEvent._();

  factory LowBalanceEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LowBalanceEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LowBalanceEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet.event'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ethBalance')
    ..aOS(2, _omitFieldNames ? '' : 'ethBalanceWei')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LowBalanceEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LowBalanceEvent copyWith(void Function(LowBalanceEvent) updates) =>
      super.copyWith((message) => updates(message as LowBalanceEvent))
          as LowBalanceEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LowBalanceEvent create() => LowBalanceEvent._();
  @$core.override
  LowBalanceEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LowBalanceEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LowBalanceEvent>(create);
  static LowBalanceEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ethBalance => $_getSZ(0);
  @$pb.TagNumber(1)
  set ethBalance($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEthBalance() => $_has(0);
  @$pb.TagNumber(1)
  void clearEthBalance() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ethBalanceWei => $_getSZ(1);
  @$pb.TagNumber(2)
  set ethBalanceWei($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEthBalanceWei() => $_has(1);
  @$pb.TagNumber(2)
  void clearEthBalanceWei() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
