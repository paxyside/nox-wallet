// This is a generated file - do not edit.
//
// Generated from wallet/service.proto.

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
    as $8;

import 'balance/balance.pb.dart' as $2;
import 'common/common.pb.dart' as $4;
import 'contact/contact.pb.dart' as $6;
import 'event/event.pb.dart' as $9;
import 'swap/swap.pb.dart' as $5;
import 'token/token.pb.dart' as $7;
import 'transaction/transaction.pb.dart' as $3;
import 'wallet/wallet.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GenerateWalletRequest extends $pb.GeneratedMessage {
  factory GenerateWalletRequest({
    $core.String? label,
    $core.bool? wordCount24,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (wordCount24 != null) result.wordCount24 = wordCount24;
    return result;
  }

  GenerateWalletRequest._();

  factory GenerateWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOB(2, _omitFieldNames ? '' : 'wordCount24', protoName: 'word_count_24')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletRequest copyWith(
          void Function(GenerateWalletRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateWalletRequest))
          as GenerateWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateWalletRequest create() => GenerateWalletRequest._();
  @$core.override
  GenerateWalletRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateWalletRequest>(create);
  static GenerateWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get wordCount24 => $_getBF(1);
  @$pb.TagNumber(2)
  set wordCount24($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWordCount24() => $_has(1);
  @$pb.TagNumber(2)
  void clearWordCount24() => $_clearField(2);
}

class GenerateWalletResponse extends $pb.GeneratedMessage {
  factory GenerateWalletResponse({
    $1.Wallet? wallet,
    $core.String? mnemonic,
  }) {
    final result = create();
    if (wallet != null) result.wallet = wallet;
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  GenerateWalletResponse._();

  factory GenerateWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$1.Wallet>(1, _omitFieldNames ? '' : 'wallet',
        subBuilder: $1.Wallet.create)
    ..aOS(2, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletResponse copyWith(
          void Function(GenerateWalletResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateWalletResponse))
          as GenerateWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateWalletResponse create() => GenerateWalletResponse._();
  @$core.override
  GenerateWalletResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateWalletResponse>(create);
  static GenerateWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Wallet get wallet => $_getN(0);
  @$pb.TagNumber(1)
  set wallet($1.Wallet value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Wallet ensureWallet() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get mnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set mnemonic($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearMnemonic() => $_clearField(2);
}

class ImportMnemonicRequest extends $pb.GeneratedMessage {
  factory ImportMnemonicRequest({
    $core.String? mnemonic,
    $core.String? label,
    $core.String? derivationPath,
  }) {
    final result = create();
    if (mnemonic != null) result.mnemonic = mnemonic;
    if (label != null) result.label = label;
    if (derivationPath != null) result.derivationPath = derivationPath;
    return result;
  }

  ImportMnemonicRequest._();

  factory ImportMnemonicRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportMnemonicRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportMnemonicRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'derivationPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportMnemonicRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportMnemonicRequest copyWith(
          void Function(ImportMnemonicRequest) updates) =>
      super.copyWith((message) => updates(message as ImportMnemonicRequest))
          as ImportMnemonicRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportMnemonicRequest create() => ImportMnemonicRequest._();
  @$core.override
  ImportMnemonicRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportMnemonicRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportMnemonicRequest>(create);
  static ImportMnemonicRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get derivationPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set derivationPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDerivationPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationPath() => $_clearField(3);
}

class ImportMnemonicResponse extends $pb.GeneratedMessage {
  factory ImportMnemonicResponse({
    $1.Wallet? wallet,
  }) {
    final result = create();
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  ImportMnemonicResponse._();

  factory ImportMnemonicResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportMnemonicResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportMnemonicResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$1.Wallet>(1, _omitFieldNames ? '' : 'wallet',
        subBuilder: $1.Wallet.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportMnemonicResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportMnemonicResponse copyWith(
          void Function(ImportMnemonicResponse) updates) =>
      super.copyWith((message) => updates(message as ImportMnemonicResponse))
          as ImportMnemonicResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportMnemonicResponse create() => ImportMnemonicResponse._();
  @$core.override
  ImportMnemonicResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportMnemonicResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportMnemonicResponse>(create);
  static ImportMnemonicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Wallet get wallet => $_getN(0);
  @$pb.TagNumber(1)
  set wallet($1.Wallet value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Wallet ensureWallet() => $_ensure(0);
}

class ImportPrivateKeyRequest extends $pb.GeneratedMessage {
  factory ImportPrivateKeyRequest({
    $core.String? privateKeyHex,
    $core.String? label,
  }) {
    final result = create();
    if (privateKeyHex != null) result.privateKeyHex = privateKeyHex;
    if (label != null) result.label = label;
    return result;
  }

  ImportPrivateKeyRequest._();

  factory ImportPrivateKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportPrivateKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportPrivateKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKeyHex')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportPrivateKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportPrivateKeyRequest copyWith(
          void Function(ImportPrivateKeyRequest) updates) =>
      super.copyWith((message) => updates(message as ImportPrivateKeyRequest))
          as ImportPrivateKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPrivateKeyRequest create() => ImportPrivateKeyRequest._();
  @$core.override
  ImportPrivateKeyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportPrivateKeyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportPrivateKeyRequest>(create);
  static ImportPrivateKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKeyHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKeyHex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrivateKeyHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKeyHex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);
}

class ImportPrivateKeyResponse extends $pb.GeneratedMessage {
  factory ImportPrivateKeyResponse({
    $1.Wallet? wallet,
  }) {
    final result = create();
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  ImportPrivateKeyResponse._();

  factory ImportPrivateKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportPrivateKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportPrivateKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$1.Wallet>(1, _omitFieldNames ? '' : 'wallet',
        subBuilder: $1.Wallet.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportPrivateKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportPrivateKeyResponse copyWith(
          void Function(ImportPrivateKeyResponse) updates) =>
      super.copyWith((message) => updates(message as ImportPrivateKeyResponse))
          as ImportPrivateKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPrivateKeyResponse create() => ImportPrivateKeyResponse._();
  @$core.override
  ImportPrivateKeyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportPrivateKeyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportPrivateKeyResponse>(create);
  static ImportPrivateKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Wallet get wallet => $_getN(0);
  @$pb.TagNumber(1)
  set wallet($1.Wallet value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Wallet ensureWallet() => $_ensure(0);
}

class ImportKeystoreRequest extends $pb.GeneratedMessage {
  factory ImportKeystoreRequest({
    $core.List<$core.int>? keystoreJson,
    $core.String? passphrase,
    $core.String? label,
  }) {
    final result = create();
    if (keystoreJson != null) result.keystoreJson = keystoreJson;
    if (passphrase != null) result.passphrase = passphrase;
    if (label != null) result.label = label;
    return result;
  }

  ImportKeystoreRequest._();

  factory ImportKeystoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportKeystoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportKeystoreRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'keystoreJson', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'passphrase')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportKeystoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportKeystoreRequest copyWith(
          void Function(ImportKeystoreRequest) updates) =>
      super.copyWith((message) => updates(message as ImportKeystoreRequest))
          as ImportKeystoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportKeystoreRequest create() => ImportKeystoreRequest._();
  @$core.override
  ImportKeystoreRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportKeystoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportKeystoreRequest>(create);
  static ImportKeystoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get keystoreJson => $_getN(0);
  @$pb.TagNumber(1)
  set keystoreJson($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeystoreJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeystoreJson() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get passphrase => $_getSZ(1);
  @$pb.TagNumber(2)
  set passphrase($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassphrase() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassphrase() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);
}

class ImportKeystoreResponse extends $pb.GeneratedMessage {
  factory ImportKeystoreResponse({
    $1.Wallet? wallet,
  }) {
    final result = create();
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  ImportKeystoreResponse._();

  factory ImportKeystoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportKeystoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportKeystoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$1.Wallet>(1, _omitFieldNames ? '' : 'wallet',
        subBuilder: $1.Wallet.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportKeystoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportKeystoreResponse copyWith(
          void Function(ImportKeystoreResponse) updates) =>
      super.copyWith((message) => updates(message as ImportKeystoreResponse))
          as ImportKeystoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportKeystoreResponse create() => ImportKeystoreResponse._();
  @$core.override
  ImportKeystoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportKeystoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportKeystoreResponse>(create);
  static ImportKeystoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Wallet get wallet => $_getN(0);
  @$pb.TagNumber(1)
  set wallet($1.Wallet value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Wallet ensureWallet() => $_ensure(0);
}

class ExportKeystoreRequest extends $pb.GeneratedMessage {
  factory ExportKeystoreRequest({
    $core.String? passphrase,
  }) {
    final result = create();
    if (passphrase != null) result.passphrase = passphrase;
    return result;
  }

  ExportKeystoreRequest._();

  factory ExportKeystoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportKeystoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportKeystoreRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'passphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportKeystoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportKeystoreRequest copyWith(
          void Function(ExportKeystoreRequest) updates) =>
      super.copyWith((message) => updates(message as ExportKeystoreRequest))
          as ExportKeystoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportKeystoreRequest create() => ExportKeystoreRequest._();
  @$core.override
  ExportKeystoreRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportKeystoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportKeystoreRequest>(create);
  static ExportKeystoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get passphrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set passphrase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassphrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassphrase() => $_clearField(1);
}

class ExportKeystoreResponse extends $pb.GeneratedMessage {
  factory ExportKeystoreResponse({
    $core.List<$core.int>? keystoreJson,
  }) {
    final result = create();
    if (keystoreJson != null) result.keystoreJson = keystoreJson;
    return result;
  }

  ExportKeystoreResponse._();

  factory ExportKeystoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportKeystoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportKeystoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'keystoreJson', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportKeystoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportKeystoreResponse copyWith(
          void Function(ExportKeystoreResponse) updates) =>
      super.copyWith((message) => updates(message as ExportKeystoreResponse))
          as ExportKeystoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportKeystoreResponse create() => ExportKeystoreResponse._();
  @$core.override
  ExportKeystoreResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportKeystoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportKeystoreResponse>(create);
  static ExportKeystoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get keystoreJson => $_getN(0);
  @$pb.TagNumber(1)
  set keystoreJson($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeystoreJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeystoreJson() => $_clearField(1);
}

class RevealSecretRequest extends $pb.GeneratedMessage {
  factory RevealSecretRequest() => create();

  RevealSecretRequest._();

  factory RevealSecretRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevealSecretRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevealSecretRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevealSecretRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevealSecretRequest copyWith(void Function(RevealSecretRequest) updates) =>
      super.copyWith((message) => updates(message as RevealSecretRequest))
          as RevealSecretRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevealSecretRequest create() => RevealSecretRequest._();
  @$core.override
  RevealSecretRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevealSecretRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevealSecretRequest>(create);
  static RevealSecretRequest? _defaultInstance;
}

class RevealSecretResponse extends $pb.GeneratedMessage {
  factory RevealSecretResponse({
    $core.String? secret,
    $1.SecretType? secretType,
  }) {
    final result = create();
    if (secret != null) result.secret = secret;
    if (secretType != null) result.secretType = secretType;
    return result;
  }

  RevealSecretResponse._();

  factory RevealSecretResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevealSecretResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevealSecretResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'secret')
    ..aE<$1.SecretType>(2, _omitFieldNames ? '' : 'secretType',
        enumValues: $1.SecretType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevealSecretResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevealSecretResponse copyWith(void Function(RevealSecretResponse) updates) =>
      super.copyWith((message) => updates(message as RevealSecretResponse))
          as RevealSecretResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevealSecretResponse create() => RevealSecretResponse._();
  @$core.override
  RevealSecretResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevealSecretResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevealSecretResponse>(create);
  static RevealSecretResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get secret => $_getSZ(0);
  @$pb.TagNumber(1)
  set secret($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSecret() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecret() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.SecretType get secretType => $_getN(1);
  @$pb.TagNumber(2)
  set secretType($1.SecretType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSecretType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecretType() => $_clearField(2);
}

class GetWalletRequest extends $pb.GeneratedMessage {
  factory GetWalletRequest() => create();

  GetWalletRequest._();

  factory GetWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletRequest copyWith(void Function(GetWalletRequest) updates) =>
      super.copyWith((message) => updates(message as GetWalletRequest))
          as GetWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletRequest create() => GetWalletRequest._();
  @$core.override
  GetWalletRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletRequest>(create);
  static GetWalletRequest? _defaultInstance;
}

class GetWalletResponse extends $pb.GeneratedMessage {
  factory GetWalletResponse({
    $1.Wallet? wallet,
  }) {
    final result = create();
    if (wallet != null) result.wallet = wallet;
    return result;
  }

  GetWalletResponse._();

  factory GetWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$1.Wallet>(1, _omitFieldNames ? '' : 'wallet',
        subBuilder: $1.Wallet.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletResponse copyWith(void Function(GetWalletResponse) updates) =>
      super.copyWith((message) => updates(message as GetWalletResponse))
          as GetWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWalletResponse create() => GetWalletResponse._();
  @$core.override
  GetWalletResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletResponse>(create);
  static GetWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Wallet get wallet => $_getN(0);
  @$pb.TagNumber(1)
  set wallet($1.Wallet value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWallet() => $_has(0);
  @$pb.TagNumber(1)
  void clearWallet() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Wallet ensureWallet() => $_ensure(0);
}

class GetBalancesRequest extends $pb.GeneratedMessage {
  factory GetBalancesRequest({
    $core.bool? withTokens,
  }) {
    final result = create();
    if (withTokens != null) result.withTokens = withTokens;
    return result;
  }

  GetBalancesRequest._();

  factory GetBalancesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBalancesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBalancesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'withTokens')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesRequest copyWith(void Function(GetBalancesRequest) updates) =>
      super.copyWith((message) => updates(message as GetBalancesRequest))
          as GetBalancesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalancesRequest create() => GetBalancesRequest._();
  @$core.override
  GetBalancesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBalancesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBalancesRequest>(create);
  static GetBalancesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get withTokens => $_getBF(0);
  @$pb.TagNumber(1)
  set withTokens($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWithTokens() => $_has(0);
  @$pb.TagNumber(1)
  void clearWithTokens() => $_clearField(1);
}

class GetBalancesResponse extends $pb.GeneratedMessage {
  factory GetBalancesResponse({
    $core.String? ethBalance,
    $core.String? ethBalanceWei,
    $core.Iterable<$2.TokenBalance>? tokens,
    $core.String? ethUsdValue,
  }) {
    final result = create();
    if (ethBalance != null) result.ethBalance = ethBalance;
    if (ethBalanceWei != null) result.ethBalanceWei = ethBalanceWei;
    if (tokens != null) result.tokens.addAll(tokens);
    if (ethUsdValue != null) result.ethUsdValue = ethUsdValue;
    return result;
  }

  GetBalancesResponse._();

  factory GetBalancesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBalancesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBalancesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ethBalance')
    ..aOS(2, _omitFieldNames ? '' : 'ethBalanceWei')
    ..pPM<$2.TokenBalance>(3, _omitFieldNames ? '' : 'tokens',
        subBuilder: $2.TokenBalance.create)
    ..aOS(4, _omitFieldNames ? '' : 'ethUsdValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalancesResponse copyWith(void Function(GetBalancesResponse) updates) =>
      super.copyWith((message) => updates(message as GetBalancesResponse))
          as GetBalancesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse create() => GetBalancesResponse._();
  @$core.override
  GetBalancesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBalancesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBalancesResponse>(create);
  static GetBalancesResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $pb.PbList<$2.TokenBalance> get tokens => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get ethUsdValue => $_getSZ(3);
  @$pb.TagNumber(4)
  set ethUsdValue($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEthUsdValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearEthUsdValue() => $_clearField(4);
}

class GetGasFeesRequest extends $pb.GeneratedMessage {
  factory GetGasFeesRequest() => create();

  GetGasFeesRequest._();

  factory GetGasFeesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGasFeesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGasFeesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGasFeesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGasFeesRequest copyWith(void Function(GetGasFeesRequest) updates) =>
      super.copyWith((message) => updates(message as GetGasFeesRequest))
          as GetGasFeesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGasFeesRequest create() => GetGasFeesRequest._();
  @$core.override
  GetGasFeesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGasFeesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGasFeesRequest>(create);
  static GetGasFeesRequest? _defaultInstance;
}

class GetGasFeesResponse extends $pb.GeneratedMessage {
  factory GetGasFeesResponse({
    $2.GasFees? fees,
    $fixnum.Int64? blockNumber,
    $core.String? ethPriceUsd,
  }) {
    final result = create();
    if (fees != null) result.fees = fees;
    if (blockNumber != null) result.blockNumber = blockNumber;
    if (ethPriceUsd != null) result.ethPriceUsd = ethPriceUsd;
    return result;
  }

  GetGasFeesResponse._();

  factory GetGasFeesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGasFeesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGasFeesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$2.GasFees>(1, _omitFieldNames ? '' : 'fees',
        subBuilder: $2.GasFees.create)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'blockNumber', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'ethPriceUsd')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGasFeesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGasFeesResponse copyWith(void Function(GetGasFeesResponse) updates) =>
      super.copyWith((message) => updates(message as GetGasFeesResponse))
          as GetGasFeesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGasFeesResponse create() => GetGasFeesResponse._();
  @$core.override
  GetGasFeesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGasFeesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGasFeesResponse>(create);
  static GetGasFeesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.GasFees get fees => $_getN(0);
  @$pb.TagNumber(1)
  set fees($2.GasFees value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFees() => $_has(0);
  @$pb.TagNumber(1)
  void clearFees() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.GasFees ensureFees() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get blockNumber => $_getI64(1);
  @$pb.TagNumber(2)
  set blockNumber($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockNumber() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ethPriceUsd => $_getSZ(2);
  @$pb.TagNumber(3)
  set ethPriceUsd($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEthPriceUsd() => $_has(2);
  @$pb.TagNumber(3)
  void clearEthPriceUsd() => $_clearField(3);
}

/// GasOptions overrides the auto-estimated EIP-1559 gas parameters. Empty
/// strings ("") mean "use the network suggestion". Both fields are decimal
/// gwei strings — the conventional format throughout the API.
class GasOptions extends $pb.GeneratedMessage {
  factory GasOptions({
    $core.String? priorityGwei,
    $core.String? maxGwei,
  }) {
    final result = create();
    if (priorityGwei != null) result.priorityGwei = priorityGwei;
    if (maxGwei != null) result.maxGwei = maxGwei;
    return result;
  }

  GasOptions._();

  factory GasOptions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GasOptions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GasOptions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'priorityGwei')
    ..aOS(2, _omitFieldNames ? '' : 'maxGwei')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasOptions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasOptions copyWith(void Function(GasOptions) updates) =>
      super.copyWith((message) => updates(message as GasOptions)) as GasOptions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GasOptions create() => GasOptions._();
  @$core.override
  GasOptions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GasOptions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GasOptions>(create);
  static GasOptions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get priorityGwei => $_getSZ(0);
  @$pb.TagNumber(1)
  set priorityGwei($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPriorityGwei() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriorityGwei() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get maxGwei => $_getSZ(1);
  @$pb.TagNumber(2)
  set maxGwei($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxGwei() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxGwei() => $_clearField(2);
}

class SendETHRequest extends $pb.GeneratedMessage {
  factory SendETHRequest({
    $core.String? to,
    $core.String? amount,
    GasOptions? gas,
  }) {
    final result = create();
    if (to != null) result.to = to;
    if (amount != null) result.amount = amount;
    if (gas != null) result.gas = gas;
    return result;
  }

  SendETHRequest._();

  factory SendETHRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendETHRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendETHRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'to')
    ..aOS(2, _omitFieldNames ? '' : 'amount')
    ..aOM<GasOptions>(3, _omitFieldNames ? '' : 'gas',
        subBuilder: GasOptions.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendETHRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendETHRequest copyWith(void Function(SendETHRequest) updates) =>
      super.copyWith((message) => updates(message as SendETHRequest))
          as SendETHRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendETHRequest create() => SendETHRequest._();
  @$core.override
  SendETHRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendETHRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendETHRequest>(create);
  static SendETHRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get to => $_getSZ(0);
  @$pb.TagNumber(1)
  set to($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTo() => $_has(0);
  @$pb.TagNumber(1)
  void clearTo() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get amount => $_getSZ(1);
  @$pb.TagNumber(2)
  set amount($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  GasOptions get gas => $_getN(2);
  @$pb.TagNumber(3)
  set gas(GasOptions value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasGas() => $_has(2);
  @$pb.TagNumber(3)
  void clearGas() => $_clearField(3);
  @$pb.TagNumber(3)
  GasOptions ensureGas() => $_ensure(2);
}

class SendETHResponse extends $pb.GeneratedMessage {
  factory SendETHResponse({
    $3.TxReceipt? receipt,
  }) {
    final result = create();
    if (receipt != null) result.receipt = receipt;
    return result;
  }

  SendETHResponse._();

  factory SendETHResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendETHResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendETHResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$3.TxReceipt>(1, _omitFieldNames ? '' : 'receipt',
        subBuilder: $3.TxReceipt.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendETHResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendETHResponse copyWith(void Function(SendETHResponse) updates) =>
      super.copyWith((message) => updates(message as SendETHResponse))
          as SendETHResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendETHResponse create() => SendETHResponse._();
  @$core.override
  SendETHResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendETHResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendETHResponse>(create);
  static SendETHResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $3.TxReceipt get receipt => $_getN(0);
  @$pb.TagNumber(1)
  set receipt($3.TxReceipt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.TxReceipt ensureReceipt() => $_ensure(0);
}

class SendTokenRequest extends $pb.GeneratedMessage {
  factory SendTokenRequest({
    $core.String? to,
    $core.String? tokenAddress,
    $core.String? amount,
    GasOptions? gas,
  }) {
    final result = create();
    if (to != null) result.to = to;
    if (tokenAddress != null) result.tokenAddress = tokenAddress;
    if (amount != null) result.amount = amount;
    if (gas != null) result.gas = gas;
    return result;
  }

  SendTokenRequest._();

  factory SendTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'to')
    ..aOS(2, _omitFieldNames ? '' : 'tokenAddress')
    ..aOS(3, _omitFieldNames ? '' : 'amount')
    ..aOM<GasOptions>(4, _omitFieldNames ? '' : 'gas',
        subBuilder: GasOptions.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTokenRequest copyWith(void Function(SendTokenRequest) updates) =>
      super.copyWith((message) => updates(message as SendTokenRequest))
          as SendTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTokenRequest create() => SendTokenRequest._();
  @$core.override
  SendTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTokenRequest>(create);
  static SendTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get to => $_getSZ(0);
  @$pb.TagNumber(1)
  set to($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTo() => $_has(0);
  @$pb.TagNumber(1)
  void clearTo() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tokenAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set tokenAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTokenAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get amount => $_getSZ(2);
  @$pb.TagNumber(3)
  set amount($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  GasOptions get gas => $_getN(3);
  @$pb.TagNumber(4)
  set gas(GasOptions value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasGas() => $_has(3);
  @$pb.TagNumber(4)
  void clearGas() => $_clearField(4);
  @$pb.TagNumber(4)
  GasOptions ensureGas() => $_ensure(3);
}

class SendTokenResponse extends $pb.GeneratedMessage {
  factory SendTokenResponse({
    $3.TxReceipt? receipt,
  }) {
    final result = create();
    if (receipt != null) result.receipt = receipt;
    return result;
  }

  SendTokenResponse._();

  factory SendTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendTokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$3.TxReceipt>(1, _omitFieldNames ? '' : 'receipt',
        subBuilder: $3.TxReceipt.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTokenResponse copyWith(void Function(SendTokenResponse) updates) =>
      super.copyWith((message) => updates(message as SendTokenResponse))
          as SendTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTokenResponse create() => SendTokenResponse._();
  @$core.override
  SendTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTokenResponse>(create);
  static SendTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $3.TxReceipt get receipt => $_getN(0);
  @$pb.TagNumber(1)
  set receipt($3.TxReceipt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.TxReceipt ensureReceipt() => $_ensure(0);
}

class GetHistoryRequest extends $pb.GeneratedMessage {
  factory GetHistoryRequest({
    $core.String? address,
    $core.String? asset,
    $4.PageParams? page,
  }) {
    final result = create();
    if (address != null) result.address = address;
    if (asset != null) result.asset = asset;
    if (page != null) result.page = page;
    return result;
  }

  GetHistoryRequest._();

  factory GetHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'asset')
    ..aOM<$4.PageParams>(3, _omitFieldNames ? '' : 'page',
        subBuilder: $4.PageParams.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryRequest copyWith(void Function(GetHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetHistoryRequest))
          as GetHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoryRequest create() => GetHistoryRequest._();
  @$core.override
  GetHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoryRequest>(create);
  static GetHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get asset => $_getSZ(1);
  @$pb.TagNumber(2)
  set asset($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAsset() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsset() => $_clearField(2);

  @$pb.TagNumber(3)
  $4.PageParams get page => $_getN(2);
  @$pb.TagNumber(3)
  set page($4.PageParams value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPage() => $_clearField(3);
  @$pb.TagNumber(3)
  $4.PageParams ensurePage() => $_ensure(2);
}

class GetHistoryResponse extends $pb.GeneratedMessage {
  factory GetHistoryResponse({
    $core.Iterable<$3.HistoryItem>? items,
    $4.PageInfo? pageInfo,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    if (pageInfo != null) result.pageInfo = pageInfo;
    return result;
  }

  GetHistoryResponse._();

  factory GetHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..pPM<$3.HistoryItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: $3.HistoryItem.create)
    ..aOM<$4.PageInfo>(2, _omitFieldNames ? '' : 'pageInfo',
        subBuilder: $4.PageInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryResponse copyWith(void Function(GetHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetHistoryResponse))
          as GetHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoryResponse create() => GetHistoryResponse._();
  @$core.override
  GetHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoryResponse>(create);
  static GetHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$3.HistoryItem> get items => $_getList(0);

  @$pb.TagNumber(2)
  $4.PageInfo get pageInfo => $_getN(1);
  @$pb.TagNumber(2)
  set pageInfo($4.PageInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPageInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageInfo() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.PageInfo ensurePageInfo() => $_ensure(1);
}

class QuoteSwapRequest extends $pb.GeneratedMessage {
  factory QuoteSwapRequest({
    $core.String? tokenIn,
    $core.String? tokenOut,
    $core.String? amountIn,
    $5.PoolFee? fee,
  }) {
    final result = create();
    if (tokenIn != null) result.tokenIn = tokenIn;
    if (tokenOut != null) result.tokenOut = tokenOut;
    if (amountIn != null) result.amountIn = amountIn;
    if (fee != null) result.fee = fee;
    return result;
  }

  QuoteSwapRequest._();

  factory QuoteSwapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuoteSwapRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuoteSwapRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tokenIn')
    ..aOS(2, _omitFieldNames ? '' : 'tokenOut')
    ..aOS(3, _omitFieldNames ? '' : 'amountIn')
    ..aE<$5.PoolFee>(4, _omitFieldNames ? '' : 'fee',
        enumValues: $5.PoolFee.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteSwapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteSwapRequest copyWith(void Function(QuoteSwapRequest) updates) =>
      super.copyWith((message) => updates(message as QuoteSwapRequest))
          as QuoteSwapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuoteSwapRequest create() => QuoteSwapRequest._();
  @$core.override
  QuoteSwapRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QuoteSwapRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuoteSwapRequest>(create);
  static QuoteSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tokenIn => $_getSZ(0);
  @$pb.TagNumber(1)
  set tokenIn($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTokenIn() => $_has(0);
  @$pb.TagNumber(1)
  void clearTokenIn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tokenOut => $_getSZ(1);
  @$pb.TagNumber(2)
  set tokenOut($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTokenOut() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenOut() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get amountIn => $_getSZ(2);
  @$pb.TagNumber(3)
  set amountIn($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmountIn() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountIn() => $_clearField(3);

  @$pb.TagNumber(4)
  $5.PoolFee get fee => $_getN(3);
  @$pb.TagNumber(4)
  set fee($5.PoolFee value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => $_clearField(4);
}

class QuoteSwapResponse extends $pb.GeneratedMessage {
  factory QuoteSwapResponse({
    $5.SwapQuote? quote,
  }) {
    final result = create();
    if (quote != null) result.quote = quote;
    return result;
  }

  QuoteSwapResponse._();

  factory QuoteSwapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuoteSwapResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuoteSwapResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$5.SwapQuote>(1, _omitFieldNames ? '' : 'quote',
        subBuilder: $5.SwapQuote.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteSwapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteSwapResponse copyWith(void Function(QuoteSwapResponse) updates) =>
      super.copyWith((message) => updates(message as QuoteSwapResponse))
          as QuoteSwapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuoteSwapResponse create() => QuoteSwapResponse._();
  @$core.override
  QuoteSwapResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QuoteSwapResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuoteSwapResponse>(create);
  static QuoteSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $5.SwapQuote get quote => $_getN(0);
  @$pb.TagNumber(1)
  set quote($5.SwapQuote value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasQuote() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuote() => $_clearField(1);
  @$pb.TagNumber(1)
  $5.SwapQuote ensureQuote() => $_ensure(0);
}

class ExecuteSwapRequest extends $pb.GeneratedMessage {
  factory ExecuteSwapRequest({
    $core.String? tokenIn,
    $core.String? tokenOut,
    $core.String? amountIn,
    $core.String? amountOutMin,
    $5.PoolFee? fee,
    $core.int? deadlineSeconds,
    GasOptions? gas,
  }) {
    final result = create();
    if (tokenIn != null) result.tokenIn = tokenIn;
    if (tokenOut != null) result.tokenOut = tokenOut;
    if (amountIn != null) result.amountIn = amountIn;
    if (amountOutMin != null) result.amountOutMin = amountOutMin;
    if (fee != null) result.fee = fee;
    if (deadlineSeconds != null) result.deadlineSeconds = deadlineSeconds;
    if (gas != null) result.gas = gas;
    return result;
  }

  ExecuteSwapRequest._();

  factory ExecuteSwapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecuteSwapRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecuteSwapRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tokenIn')
    ..aOS(2, _omitFieldNames ? '' : 'tokenOut')
    ..aOS(3, _omitFieldNames ? '' : 'amountIn')
    ..aOS(4, _omitFieldNames ? '' : 'amountOutMin')
    ..aE<$5.PoolFee>(5, _omitFieldNames ? '' : 'fee',
        enumValues: $5.PoolFee.values)
    ..aI(6, _omitFieldNames ? '' : 'deadlineSeconds',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<GasOptions>(7, _omitFieldNames ? '' : 'gas',
        subBuilder: GasOptions.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteSwapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteSwapRequest copyWith(void Function(ExecuteSwapRequest) updates) =>
      super.copyWith((message) => updates(message as ExecuteSwapRequest))
          as ExecuteSwapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteSwapRequest create() => ExecuteSwapRequest._();
  @$core.override
  ExecuteSwapRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecuteSwapRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecuteSwapRequest>(create);
  static ExecuteSwapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tokenIn => $_getSZ(0);
  @$pb.TagNumber(1)
  set tokenIn($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTokenIn() => $_has(0);
  @$pb.TagNumber(1)
  void clearTokenIn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tokenOut => $_getSZ(1);
  @$pb.TagNumber(2)
  set tokenOut($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTokenOut() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenOut() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get amountIn => $_getSZ(2);
  @$pb.TagNumber(3)
  set amountIn($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmountIn() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountIn() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get amountOutMin => $_getSZ(3);
  @$pb.TagNumber(4)
  set amountOutMin($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmountOutMin() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountOutMin() => $_clearField(4);

  @$pb.TagNumber(5)
  $5.PoolFee get fee => $_getN(4);
  @$pb.TagNumber(5)
  set fee($5.PoolFee value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearFee() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get deadlineSeconds => $_getIZ(5);
  @$pb.TagNumber(6)
  set deadlineSeconds($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDeadlineSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeadlineSeconds() => $_clearField(6);

  @$pb.TagNumber(7)
  GasOptions get gas => $_getN(6);
  @$pb.TagNumber(7)
  set gas(GasOptions value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasGas() => $_has(6);
  @$pb.TagNumber(7)
  void clearGas() => $_clearField(7);
  @$pb.TagNumber(7)
  GasOptions ensureGas() => $_ensure(6);
}

class ExecuteSwapResponse extends $pb.GeneratedMessage {
  factory ExecuteSwapResponse({
    $3.TxReceipt? receipt,
  }) {
    final result = create();
    if (receipt != null) result.receipt = receipt;
    return result;
  }

  ExecuteSwapResponse._();

  factory ExecuteSwapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecuteSwapResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecuteSwapResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$3.TxReceipt>(1, _omitFieldNames ? '' : 'receipt',
        subBuilder: $3.TxReceipt.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteSwapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteSwapResponse copyWith(void Function(ExecuteSwapResponse) updates) =>
      super.copyWith((message) => updates(message as ExecuteSwapResponse))
          as ExecuteSwapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteSwapResponse create() => ExecuteSwapResponse._();
  @$core.override
  ExecuteSwapResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecuteSwapResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecuteSwapResponse>(create);
  static ExecuteSwapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $3.TxReceipt get receipt => $_getN(0);
  @$pb.TagNumber(1)
  set receipt($3.TxReceipt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.TxReceipt ensureReceipt() => $_ensure(0);
}

class CreateContactRequest extends $pb.GeneratedMessage {
  factory CreateContactRequest({
    $core.String? name,
    $core.String? address,
    $core.String? note,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (address != null) result.address = address;
    if (note != null) result.note = note;
    return result;
  }

  CreateContactRequest._();

  factory CreateContactRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateContactRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateContactRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContactRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContactRequest copyWith(void Function(CreateContactRequest) updates) =>
      super.copyWith((message) => updates(message as CreateContactRequest))
          as CreateContactRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateContactRequest create() => CreateContactRequest._();
  @$core.override
  CreateContactRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateContactRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateContactRequest>(create);
  static CreateContactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => $_clearField(3);
}

class CreateContactResponse extends $pb.GeneratedMessage {
  factory CreateContactResponse({
    $6.Contact? contact,
  }) {
    final result = create();
    if (contact != null) result.contact = contact;
    return result;
  }

  CreateContactResponse._();

  factory CreateContactResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateContactResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateContactResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$6.Contact>(1, _omitFieldNames ? '' : 'contact',
        subBuilder: $6.Contact.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContactResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContactResponse copyWith(
          void Function(CreateContactResponse) updates) =>
      super.copyWith((message) => updates(message as CreateContactResponse))
          as CreateContactResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateContactResponse create() => CreateContactResponse._();
  @$core.override
  CreateContactResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateContactResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateContactResponse>(create);
  static CreateContactResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $6.Contact get contact => $_getN(0);
  @$pb.TagNumber(1)
  set contact($6.Contact value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContact() => $_has(0);
  @$pb.TagNumber(1)
  void clearContact() => $_clearField(1);
  @$pb.TagNumber(1)
  $6.Contact ensureContact() => $_ensure(0);
}

class GetContactRequest extends $pb.GeneratedMessage {
  factory GetContactRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetContactRequest._();

  factory GetContactRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetContactRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetContactRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContactRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContactRequest copyWith(void Function(GetContactRequest) updates) =>
      super.copyWith((message) => updates(message as GetContactRequest))
          as GetContactRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetContactRequest create() => GetContactRequest._();
  @$core.override
  GetContactRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetContactRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetContactRequest>(create);
  static GetContactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetContactResponse extends $pb.GeneratedMessage {
  factory GetContactResponse({
    $6.Contact? contact,
  }) {
    final result = create();
    if (contact != null) result.contact = contact;
    return result;
  }

  GetContactResponse._();

  factory GetContactResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetContactResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetContactResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$6.Contact>(1, _omitFieldNames ? '' : 'contact',
        subBuilder: $6.Contact.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContactResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContactResponse copyWith(void Function(GetContactResponse) updates) =>
      super.copyWith((message) => updates(message as GetContactResponse))
          as GetContactResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetContactResponse create() => GetContactResponse._();
  @$core.override
  GetContactResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetContactResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetContactResponse>(create);
  static GetContactResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $6.Contact get contact => $_getN(0);
  @$pb.TagNumber(1)
  set contact($6.Contact value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContact() => $_has(0);
  @$pb.TagNumber(1)
  void clearContact() => $_clearField(1);
  @$pb.TagNumber(1)
  $6.Contact ensureContact() => $_ensure(0);
}

class UpdateContactRequest extends $pb.GeneratedMessage {
  factory UpdateContactRequest({
    $core.String? id,
    $core.String? name,
    $core.String? address,
    $core.String? note,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (address != null) result.address = address;
    if (note != null) result.note = note;
    return result;
  }

  UpdateContactRequest._();

  factory UpdateContactRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateContactRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateContactRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContactRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContactRequest copyWith(void Function(UpdateContactRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateContactRequest))
          as UpdateContactRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateContactRequest create() => UpdateContactRequest._();
  @$core.override
  UpdateContactRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateContactRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateContactRequest>(create);
  static UpdateContactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get note => $_getSZ(3);
  @$pb.TagNumber(4)
  set note($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNote() => $_has(3);
  @$pb.TagNumber(4)
  void clearNote() => $_clearField(4);
}

class UpdateContactResponse extends $pb.GeneratedMessage {
  factory UpdateContactResponse({
    $6.Contact? contact,
  }) {
    final result = create();
    if (contact != null) result.contact = contact;
    return result;
  }

  UpdateContactResponse._();

  factory UpdateContactResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateContactResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateContactResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$6.Contact>(1, _omitFieldNames ? '' : 'contact',
        subBuilder: $6.Contact.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContactResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContactResponse copyWith(
          void Function(UpdateContactResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateContactResponse))
          as UpdateContactResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateContactResponse create() => UpdateContactResponse._();
  @$core.override
  UpdateContactResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateContactResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateContactResponse>(create);
  static UpdateContactResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $6.Contact get contact => $_getN(0);
  @$pb.TagNumber(1)
  set contact($6.Contact value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContact() => $_has(0);
  @$pb.TagNumber(1)
  void clearContact() => $_clearField(1);
  @$pb.TagNumber(1)
  $6.Contact ensureContact() => $_ensure(0);
}

class DeleteContactRequest extends $pb.GeneratedMessage {
  factory DeleteContactRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteContactRequest._();

  factory DeleteContactRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteContactRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteContactRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContactRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContactRequest copyWith(void Function(DeleteContactRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteContactRequest))
          as DeleteContactRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteContactRequest create() => DeleteContactRequest._();
  @$core.override
  DeleteContactRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteContactRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteContactRequest>(create);
  static DeleteContactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteContactResponse extends $pb.GeneratedMessage {
  factory DeleteContactResponse() => create();

  DeleteContactResponse._();

  factory DeleteContactResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteContactResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteContactResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContactResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContactResponse copyWith(
          void Function(DeleteContactResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteContactResponse))
          as DeleteContactResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteContactResponse create() => DeleteContactResponse._();
  @$core.override
  DeleteContactResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteContactResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteContactResponse>(create);
  static DeleteContactResponse? _defaultInstance;
}

class ListContactsRequest extends $pb.GeneratedMessage {
  factory ListContactsRequest() => create();

  ListContactsRequest._();

  factory ListContactsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListContactsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListContactsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContactsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContactsRequest copyWith(void Function(ListContactsRequest) updates) =>
      super.copyWith((message) => updates(message as ListContactsRequest))
          as ListContactsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListContactsRequest create() => ListContactsRequest._();
  @$core.override
  ListContactsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListContactsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListContactsRequest>(create);
  static ListContactsRequest? _defaultInstance;
}

class ListContactsResponse extends $pb.GeneratedMessage {
  factory ListContactsResponse({
    $core.Iterable<$6.Contact>? contacts,
  }) {
    final result = create();
    if (contacts != null) result.contacts.addAll(contacts);
    return result;
  }

  ListContactsResponse._();

  factory ListContactsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListContactsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListContactsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..pPM<$6.Contact>(1, _omitFieldNames ? '' : 'contacts',
        subBuilder: $6.Contact.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContactsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContactsResponse copyWith(void Function(ListContactsResponse) updates) =>
      super.copyWith((message) => updates(message as ListContactsResponse))
          as ListContactsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListContactsResponse create() => ListContactsResponse._();
  @$core.override
  ListContactsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListContactsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListContactsResponse>(create);
  static ListContactsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$6.Contact> get contacts => $_getList(0);
}

class FavoriteContactRequest extends $pb.GeneratedMessage {
  factory FavoriteContactRequest({
    $core.String? id,
    $core.bool? favorite,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (favorite != null) result.favorite = favorite;
    return result;
  }

  FavoriteContactRequest._();

  factory FavoriteContactRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteContactRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteContactRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'favorite')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteContactRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteContactRequest copyWith(
          void Function(FavoriteContactRequest) updates) =>
      super.copyWith((message) => updates(message as FavoriteContactRequest))
          as FavoriteContactRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteContactRequest create() => FavoriteContactRequest._();
  @$core.override
  FavoriteContactRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FavoriteContactRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteContactRequest>(create);
  static FavoriteContactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get favorite => $_getBF(1);
  @$pb.TagNumber(2)
  set favorite($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFavorite() => $_has(1);
  @$pb.TagNumber(2)
  void clearFavorite() => $_clearField(2);
}

class FavoriteContactResponse extends $pb.GeneratedMessage {
  factory FavoriteContactResponse() => create();

  FavoriteContactResponse._();

  factory FavoriteContactResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteContactResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteContactResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteContactResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteContactResponse copyWith(
          void Function(FavoriteContactResponse) updates) =>
      super.copyWith((message) => updates(message as FavoriteContactResponse))
          as FavoriteContactResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteContactResponse create() => FavoriteContactResponse._();
  @$core.override
  FavoriteContactResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FavoriteContactResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteContactResponse>(create);
  static FavoriteContactResponse? _defaultInstance;
}

class AddTokenRequest extends $pb.GeneratedMessage {
  factory AddTokenRequest({
    $core.String? address,
  }) {
    final result = create();
    if (address != null) result.address = address;
    return result;
  }

  AddTokenRequest._();

  factory AddTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTokenRequest copyWith(void Function(AddTokenRequest) updates) =>
      super.copyWith((message) => updates(message as AddTokenRequest))
          as AddTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddTokenRequest create() => AddTokenRequest._();
  @$core.override
  AddTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddTokenRequest>(create);
  static AddTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class AddTokenResponse extends $pb.GeneratedMessage {
  factory AddTokenResponse({
    $7.WatchedToken? token,
  }) {
    final result = create();
    if (token != null) result.token = token;
    return result;
  }

  AddTokenResponse._();

  factory AddTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddTokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$7.WatchedToken>(1, _omitFieldNames ? '' : 'token',
        subBuilder: $7.WatchedToken.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTokenResponse copyWith(void Function(AddTokenResponse) updates) =>
      super.copyWith((message) => updates(message as AddTokenResponse))
          as AddTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddTokenResponse create() => AddTokenResponse._();
  @$core.override
  AddTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddTokenResponse>(create);
  static AddTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $7.WatchedToken get token => $_getN(0);
  @$pb.TagNumber(1)
  set token($7.WatchedToken value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
  @$pb.TagNumber(1)
  $7.WatchedToken ensureToken() => $_ensure(0);
}

class RemoveTokenRequest extends $pb.GeneratedMessage {
  factory RemoveTokenRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  RemoveTokenRequest._();

  factory RemoveTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveTokenRequest copyWith(void Function(RemoveTokenRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveTokenRequest))
          as RemoveTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveTokenRequest create() => RemoveTokenRequest._();
  @$core.override
  RemoveTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveTokenRequest>(create);
  static RemoveTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class RemoveTokenResponse extends $pb.GeneratedMessage {
  factory RemoveTokenResponse() => create();

  RemoveTokenResponse._();

  factory RemoveTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveTokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveTokenResponse copyWith(void Function(RemoveTokenResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveTokenResponse))
          as RemoveTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveTokenResponse create() => RemoveTokenResponse._();
  @$core.override
  RemoveTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveTokenResponse>(create);
  static RemoveTokenResponse? _defaultInstance;
}

class ListTokensRequest extends $pb.GeneratedMessage {
  factory ListTokensRequest() => create();

  ListTokensRequest._();

  factory ListTokensRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTokensRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTokensRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensRequest copyWith(void Function(ListTokensRequest) updates) =>
      super.copyWith((message) => updates(message as ListTokensRequest))
          as ListTokensRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTokensRequest create() => ListTokensRequest._();
  @$core.override
  ListTokensRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTokensRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTokensRequest>(create);
  static ListTokensRequest? _defaultInstance;
}

class ListTokensResponse extends $pb.GeneratedMessage {
  factory ListTokensResponse({
    $core.Iterable<$7.WatchedToken>? tokens,
  }) {
    final result = create();
    if (tokens != null) result.tokens.addAll(tokens);
    return result;
  }

  ListTokensResponse._();

  factory ListTokensResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTokensResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTokensResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..pPM<$7.WatchedToken>(1, _omitFieldNames ? '' : 'tokens',
        subBuilder: $7.WatchedToken.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensResponse copyWith(void Function(ListTokensResponse) updates) =>
      super.copyWith((message) => updates(message as ListTokensResponse))
          as ListTokensResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTokensResponse create() => ListTokensResponse._();
  @$core.override
  ListTokensResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTokensResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTokensResponse>(create);
  static ListTokensResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$7.WatchedToken> get tokens => $_getList(0);
}

class ListTokensWithBalancesRequest extends $pb.GeneratedMessage {
  factory ListTokensWithBalancesRequest() => create();

  ListTokensWithBalancesRequest._();

  factory ListTokensWithBalancesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTokensWithBalancesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTokensWithBalancesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensWithBalancesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensWithBalancesRequest copyWith(
          void Function(ListTokensWithBalancesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListTokensWithBalancesRequest))
          as ListTokensWithBalancesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTokensWithBalancesRequest create() =>
      ListTokensWithBalancesRequest._();
  @$core.override
  ListTokensWithBalancesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTokensWithBalancesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTokensWithBalancesRequest>(create);
  static ListTokensWithBalancesRequest? _defaultInstance;
}

class ListTokensWithBalancesResponse extends $pb.GeneratedMessage {
  factory ListTokensWithBalancesResponse({
    $core.Iterable<$7.WatchedTokenWithBalance>? tokens,
  }) {
    final result = create();
    if (tokens != null) result.tokens.addAll(tokens);
    return result;
  }

  ListTokensWithBalancesResponse._();

  factory ListTokensWithBalancesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTokensWithBalancesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTokensWithBalancesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..pPM<$7.WatchedTokenWithBalance>(1, _omitFieldNames ? '' : 'tokens',
        subBuilder: $7.WatchedTokenWithBalance.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensWithBalancesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTokensWithBalancesResponse copyWith(
          void Function(ListTokensWithBalancesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListTokensWithBalancesResponse))
          as ListTokensWithBalancesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTokensWithBalancesResponse create() =>
      ListTokensWithBalancesResponse._();
  @$core.override
  ListTokensWithBalancesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTokensWithBalancesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTokensWithBalancesResponse>(create);
  static ListTokensWithBalancesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$7.WatchedTokenWithBalance> get tokens => $_getList(0);
}

class PinTokenRequest extends $pb.GeneratedMessage {
  factory PinTokenRequest({
    $core.String? id,
    $core.bool? pinned,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (pinned != null) result.pinned = pinned;
    return result;
  }

  PinTokenRequest._();

  factory PinTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PinTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PinTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'pinned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinTokenRequest copyWith(void Function(PinTokenRequest) updates) =>
      super.copyWith((message) => updates(message as PinTokenRequest))
          as PinTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PinTokenRequest create() => PinTokenRequest._();
  @$core.override
  PinTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PinTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PinTokenRequest>(create);
  static PinTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get pinned => $_getBF(1);
  @$pb.TagNumber(2)
  set pinned($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPinned() => $_has(1);
  @$pb.TagNumber(2)
  void clearPinned() => $_clearField(2);
}

class PinTokenResponse extends $pb.GeneratedMessage {
  factory PinTokenResponse() => create();

  PinTokenResponse._();

  factory PinTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PinTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PinTokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinTokenResponse copyWith(void Function(PinTokenResponse) updates) =>
      super.copyWith((message) => updates(message as PinTokenResponse))
          as PinTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PinTokenResponse create() => PinTokenResponse._();
  @$core.override
  PinTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PinTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PinTokenResponse>(create);
  static PinTokenResponse? _defaultInstance;
}

class HideTokenRequest extends $pb.GeneratedMessage {
  factory HideTokenRequest({
    $core.String? id,
    $core.bool? hidden,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (hidden != null) result.hidden = hidden;
    return result;
  }

  HideTokenRequest._();

  factory HideTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HideTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HideTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'hidden')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HideTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HideTokenRequest copyWith(void Function(HideTokenRequest) updates) =>
      super.copyWith((message) => updates(message as HideTokenRequest))
          as HideTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HideTokenRequest create() => HideTokenRequest._();
  @$core.override
  HideTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HideTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HideTokenRequest>(create);
  static HideTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get hidden => $_getBF(1);
  @$pb.TagNumber(2)
  set hidden($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHidden() => $_has(1);
  @$pb.TagNumber(2)
  void clearHidden() => $_clearField(2);
}

class HideTokenResponse extends $pb.GeneratedMessage {
  factory HideTokenResponse() => create();

  HideTokenResponse._();

  factory HideTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HideTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HideTokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HideTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HideTokenResponse copyWith(void Function(HideTokenResponse) updates) =>
      super.copyWith((message) => updates(message as HideTokenResponse))
          as HideTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HideTokenResponse create() => HideTokenResponse._();
  @$core.override
  HideTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HideTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HideTokenResponse>(create);
  static HideTokenResponse? _defaultInstance;
}

class TokenApproval extends $pb.GeneratedMessage {
  factory TokenApproval({
    $core.String? tokenAddress,
    $core.String? tokenSymbol,
    $core.String? tokenName,
    $core.int? tokenDecimals,
    $core.String? spender,
    $core.String? spenderLabel,
    $core.String? amountRaw,
    $core.String? amountHuman,
    $core.String? tokenLogoUrl,
  }) {
    final result = create();
    if (tokenAddress != null) result.tokenAddress = tokenAddress;
    if (tokenSymbol != null) result.tokenSymbol = tokenSymbol;
    if (tokenName != null) result.tokenName = tokenName;
    if (tokenDecimals != null) result.tokenDecimals = tokenDecimals;
    if (spender != null) result.spender = spender;
    if (spenderLabel != null) result.spenderLabel = spenderLabel;
    if (amountRaw != null) result.amountRaw = amountRaw;
    if (amountHuman != null) result.amountHuman = amountHuman;
    if (tokenLogoUrl != null) result.tokenLogoUrl = tokenLogoUrl;
    return result;
  }

  TokenApproval._();

  factory TokenApproval.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TokenApproval.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TokenApproval',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tokenAddress')
    ..aOS(2, _omitFieldNames ? '' : 'tokenSymbol')
    ..aOS(3, _omitFieldNames ? '' : 'tokenName')
    ..aI(4, _omitFieldNames ? '' : 'tokenDecimals',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'spender')
    ..aOS(6, _omitFieldNames ? '' : 'spenderLabel')
    ..aOS(7, _omitFieldNames ? '' : 'amountRaw')
    ..aOS(8, _omitFieldNames ? '' : 'amountHuman')
    ..aOS(9, _omitFieldNames ? '' : 'tokenLogoUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenApproval clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenApproval copyWith(void Function(TokenApproval) updates) =>
      super.copyWith((message) => updates(message as TokenApproval))
          as TokenApproval;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenApproval create() => TokenApproval._();
  @$core.override
  TokenApproval createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TokenApproval getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TokenApproval>(create);
  static TokenApproval? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tokenAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set tokenAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTokenAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearTokenAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tokenSymbol => $_getSZ(1);
  @$pb.TagNumber(2)
  set tokenSymbol($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTokenSymbol() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenSymbol() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tokenName => $_getSZ(2);
  @$pb.TagNumber(3)
  set tokenName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTokenName() => $_has(2);
  @$pb.TagNumber(3)
  void clearTokenName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get tokenDecimals => $_getIZ(3);
  @$pb.TagNumber(4)
  set tokenDecimals($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTokenDecimals() => $_has(3);
  @$pb.TagNumber(4)
  void clearTokenDecimals() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spender => $_getSZ(4);
  @$pb.TagNumber(5)
  set spender($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpender() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpender() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get spenderLabel => $_getSZ(5);
  @$pb.TagNumber(6)
  set spenderLabel($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpenderLabel() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpenderLabel() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get amountRaw => $_getSZ(6);
  @$pb.TagNumber(7)
  set amountRaw($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAmountRaw() => $_has(6);
  @$pb.TagNumber(7)
  void clearAmountRaw() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get amountHuman => $_getSZ(7);
  @$pb.TagNumber(8)
  set amountHuman($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAmountHuman() => $_has(7);
  @$pb.TagNumber(8)
  void clearAmountHuman() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get tokenLogoUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set tokenLogoUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTokenLogoUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearTokenLogoUrl() => $_clearField(9);
}

class ListApprovalsRequest extends $pb.GeneratedMessage {
  factory ListApprovalsRequest() => create();

  ListApprovalsRequest._();

  factory ListApprovalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListApprovalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListApprovalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalsRequest copyWith(void Function(ListApprovalsRequest) updates) =>
      super.copyWith((message) => updates(message as ListApprovalsRequest))
          as ListApprovalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListApprovalsRequest create() => ListApprovalsRequest._();
  @$core.override
  ListApprovalsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListApprovalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListApprovalsRequest>(create);
  static ListApprovalsRequest? _defaultInstance;
}

class ListApprovalsResponse extends $pb.GeneratedMessage {
  factory ListApprovalsResponse({
    $core.Iterable<TokenApproval>? approvals,
  }) {
    final result = create();
    if (approvals != null) result.approvals.addAll(approvals);
    return result;
  }

  ListApprovalsResponse._();

  factory ListApprovalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListApprovalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListApprovalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..pPM<TokenApproval>(1, _omitFieldNames ? '' : 'approvals',
        subBuilder: TokenApproval.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalsResponse copyWith(
          void Function(ListApprovalsResponse) updates) =>
      super.copyWith((message) => updates(message as ListApprovalsResponse))
          as ListApprovalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListApprovalsResponse create() => ListApprovalsResponse._();
  @$core.override
  ListApprovalsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListApprovalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListApprovalsResponse>(create);
  static ListApprovalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TokenApproval> get approvals => $_getList(0);
}

class RevokeApprovalRequest extends $pb.GeneratedMessage {
  factory RevokeApprovalRequest({
    $core.String? tokenAddress,
    $core.String? spender,
  }) {
    final result = create();
    if (tokenAddress != null) result.tokenAddress = tokenAddress;
    if (spender != null) result.spender = spender;
    return result;
  }

  RevokeApprovalRequest._();

  factory RevokeApprovalRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeApprovalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeApprovalRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tokenAddress')
    ..aOS(2, _omitFieldNames ? '' : 'spender')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeApprovalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeApprovalRequest copyWith(
          void Function(RevokeApprovalRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeApprovalRequest))
          as RevokeApprovalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeApprovalRequest create() => RevokeApprovalRequest._();
  @$core.override
  RevokeApprovalRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeApprovalRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeApprovalRequest>(create);
  static RevokeApprovalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tokenAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set tokenAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTokenAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearTokenAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get spender => $_getSZ(1);
  @$pb.TagNumber(2)
  set spender($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpender() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpender() => $_clearField(2);
}

class RevokeApprovalResponse extends $pb.GeneratedMessage {
  factory RevokeApprovalResponse({
    $3.TxReceipt? receipt,
  }) {
    final result = create();
    if (receipt != null) result.receipt = receipt;
    return result;
  }

  RevokeApprovalResponse._();

  factory RevokeApprovalResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeApprovalResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeApprovalResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<$3.TxReceipt>(1, _omitFieldNames ? '' : 'receipt',
        subBuilder: $3.TxReceipt.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeApprovalResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeApprovalResponse copyWith(
          void Function(RevokeApprovalResponse) updates) =>
      super.copyWith((message) => updates(message as RevokeApprovalResponse))
          as RevokeApprovalResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeApprovalResponse create() => RevokeApprovalResponse._();
  @$core.override
  RevokeApprovalResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeApprovalResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeApprovalResponse>(create);
  static RevokeApprovalResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $3.TxReceipt get receipt => $_getN(0);
  @$pb.TagNumber(1)
  set receipt($3.TxReceipt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.TxReceipt ensureReceipt() => $_ensure(0);
}

class ResolveENSRequest extends $pb.GeneratedMessage {
  factory ResolveENSRequest({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  ResolveENSRequest._();

  factory ResolveENSRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveENSRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveENSRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveENSRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveENSRequest copyWith(void Function(ResolveENSRequest) updates) =>
      super.copyWith((message) => updates(message as ResolveENSRequest))
          as ResolveENSRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveENSRequest create() => ResolveENSRequest._();
  @$core.override
  ResolveENSRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveENSRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveENSRequest>(create);
  static ResolveENSRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class ResolveENSResponse extends $pb.GeneratedMessage {
  factory ResolveENSResponse({
    $core.String? address,
  }) {
    final result = create();
    if (address != null) result.address = address;
    return result;
  }

  ResolveENSResponse._();

  factory ResolveENSResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveENSResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveENSResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveENSResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveENSResponse copyWith(void Function(ResolveENSResponse) updates) =>
      super.copyWith((message) => updates(message as ResolveENSResponse))
          as ResolveENSResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveENSResponse create() => ResolveENSResponse._();
  @$core.override
  ResolveENSResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveENSResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveENSResponse>(create);
  static ResolveENSResponse? _defaultInstance;

  /// Empty when the name has no resolver / no address record. Clients should
  /// treat empty as "not configured" — not as a hard error.
  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class ReverseENSRequest extends $pb.GeneratedMessage {
  factory ReverseENSRequest({
    $core.String? address,
  }) {
    final result = create();
    if (address != null) result.address = address;
    return result;
  }

  ReverseENSRequest._();

  factory ReverseENSRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReverseENSRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReverseENSRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseENSRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseENSRequest copyWith(void Function(ReverseENSRequest) updates) =>
      super.copyWith((message) => updates(message as ReverseENSRequest))
          as ReverseENSRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReverseENSRequest create() => ReverseENSRequest._();
  @$core.override
  ReverseENSRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReverseENSRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReverseENSRequest>(create);
  static ReverseENSRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class ReverseENSResponse extends $pb.GeneratedMessage {
  factory ReverseENSResponse({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  ReverseENSResponse._();

  factory ReverseENSResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReverseENSResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReverseENSResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseENSResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseENSResponse copyWith(void Function(ReverseENSResponse) updates) =>
      super.copyWith((message) => updates(message as ReverseENSResponse))
          as ReverseENSResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReverseENSResponse create() => ReverseENSResponse._();
  @$core.override
  ReverseENSResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReverseENSResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReverseENSResponse>(create);
  static ReverseENSResponse? _defaultInstance;

  /// Empty when the address has no primary name registered.
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class SpeedUpTxRequest extends $pb.GeneratedMessage {
  factory SpeedUpTxRequest({
    $core.String? txHash,
  }) {
    final result = create();
    if (txHash != null) result.txHash = txHash;
    return result;
  }

  SpeedUpTxRequest._();

  factory SpeedUpTxRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpeedUpTxRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpeedUpTxRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedUpTxRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedUpTxRequest copyWith(void Function(SpeedUpTxRequest) updates) =>
      super.copyWith((message) => updates(message as SpeedUpTxRequest))
          as SpeedUpTxRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpeedUpTxRequest create() => SpeedUpTxRequest._();
  @$core.override
  SpeedUpTxRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpeedUpTxRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpeedUpTxRequest>(create);
  static SpeedUpTxRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set txHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => $_clearField(1);
}

class SpeedUpTxResponse extends $pb.GeneratedMessage {
  factory SpeedUpTxResponse({
    $core.String? newTxHash,
  }) {
    final result = create();
    if (newTxHash != null) result.newTxHash = newTxHash;
    return result;
  }

  SpeedUpTxResponse._();

  factory SpeedUpTxResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpeedUpTxResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpeedUpTxResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'newTxHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedUpTxResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedUpTxResponse copyWith(void Function(SpeedUpTxResponse) updates) =>
      super.copyWith((message) => updates(message as SpeedUpTxResponse))
          as SpeedUpTxResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpeedUpTxResponse create() => SpeedUpTxResponse._();
  @$core.override
  SpeedUpTxResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpeedUpTxResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpeedUpTxResponse>(create);
  static SpeedUpTxResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get newTxHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set newTxHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewTxHash() => $_clearField(1);
}

class CancelTxRequest extends $pb.GeneratedMessage {
  factory CancelTxRequest({
    $core.String? txHash,
  }) {
    final result = create();
    if (txHash != null) result.txHash = txHash;
    return result;
  }

  CancelTxRequest._();

  factory CancelTxRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelTxRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelTxRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTxRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTxRequest copyWith(void Function(CancelTxRequest) updates) =>
      super.copyWith((message) => updates(message as CancelTxRequest))
          as CancelTxRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelTxRequest create() => CancelTxRequest._();
  @$core.override
  CancelTxRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelTxRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelTxRequest>(create);
  static CancelTxRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set txHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => $_clearField(1);
}

class CancelTxResponse extends $pb.GeneratedMessage {
  factory CancelTxResponse({
    $core.String? newTxHash,
  }) {
    final result = create();
    if (newTxHash != null) result.newTxHash = newTxHash;
    return result;
  }

  CancelTxResponse._();

  factory CancelTxResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelTxResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelTxResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'newTxHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTxResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTxResponse copyWith(void Function(CancelTxResponse) updates) =>
      super.copyWith((message) => updates(message as CancelTxResponse))
          as CancelTxResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelTxResponse create() => CancelTxResponse._();
  @$core.override
  CancelTxResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelTxResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelTxResponse>(create);
  static CancelTxResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get newTxHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set newTxHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewTxHash() => $_clearField(1);
}

class PendingTx extends $pb.GeneratedMessage {
  factory PendingTx({
    $core.String? txHash,
    $core.String? from,
    $core.String? to,
    $core.String? value,
    $fixnum.Int64? nonce,
    $core.String? gasTipGwei,
    $core.String? gasCapGwei,
    $core.String? kind,
    $8.Timestamp? submittedAt,
  }) {
    final result = create();
    if (txHash != null) result.txHash = txHash;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (value != null) result.value = value;
    if (nonce != null) result.nonce = nonce;
    if (gasTipGwei != null) result.gasTipGwei = gasTipGwei;
    if (gasCapGwei != null) result.gasCapGwei = gasCapGwei;
    if (kind != null) result.kind = kind;
    if (submittedAt != null) result.submittedAt = submittedAt;
    return result;
  }

  PendingTx._();

  factory PendingTx.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PendingTx.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PendingTx',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txHash')
    ..aOS(2, _omitFieldNames ? '' : 'from')
    ..aOS(3, _omitFieldNames ? '' : 'to')
    ..aOS(4, _omitFieldNames ? '' : 'value')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, _omitFieldNames ? '' : 'gasTipGwei')
    ..aOS(7, _omitFieldNames ? '' : 'gasCapGwei')
    ..aOS(8, _omitFieldNames ? '' : 'kind')
    ..aOM<$8.Timestamp>(9, _omitFieldNames ? '' : 'submittedAt',
        subBuilder: $8.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingTx clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingTx copyWith(void Function(PendingTx) updates) =>
      super.copyWith((message) => updates(message as PendingTx)) as PendingTx;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PendingTx create() => PendingTx._();
  @$core.override
  PendingTx createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PendingTx getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PendingTx>(create);
  static PendingTx? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set txHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get to => $_getSZ(2);
  @$pb.TagNumber(3)
  set to($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearTo() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get value => $_getSZ(3);
  @$pb.TagNumber(4)
  set value($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get nonce => $_getI64(4);
  @$pb.TagNumber(5)
  set nonce($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNonce() => $_has(4);
  @$pb.TagNumber(5)
  void clearNonce() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get gasTipGwei => $_getSZ(5);
  @$pb.TagNumber(6)
  set gasTipGwei($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGasTipGwei() => $_has(5);
  @$pb.TagNumber(6)
  void clearGasTipGwei() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get gasCapGwei => $_getSZ(6);
  @$pb.TagNumber(7)
  set gasCapGwei($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGasCapGwei() => $_has(6);
  @$pb.TagNumber(7)
  void clearGasCapGwei() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get kind => $_getSZ(7);
  @$pb.TagNumber(8)
  set kind($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasKind() => $_has(7);
  @$pb.TagNumber(8)
  void clearKind() => $_clearField(8);

  @$pb.TagNumber(9)
  $8.Timestamp get submittedAt => $_getN(8);
  @$pb.TagNumber(9)
  set submittedAt($8.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSubmittedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearSubmittedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $8.Timestamp ensureSubmittedAt() => $_ensure(8);
}

class ListPendingTxsRequest extends $pb.GeneratedMessage {
  factory ListPendingTxsRequest() => create();

  ListPendingTxsRequest._();

  factory ListPendingTxsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPendingTxsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPendingTxsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingTxsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingTxsRequest copyWith(
          void Function(ListPendingTxsRequest) updates) =>
      super.copyWith((message) => updates(message as ListPendingTxsRequest))
          as ListPendingTxsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPendingTxsRequest create() => ListPendingTxsRequest._();
  @$core.override
  ListPendingTxsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPendingTxsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPendingTxsRequest>(create);
  static ListPendingTxsRequest? _defaultInstance;
}

class ListPendingTxsResponse extends $pb.GeneratedMessage {
  factory ListPendingTxsResponse({
    $core.Iterable<PendingTx>? pending,
  }) {
    final result = create();
    if (pending != null) result.pending.addAll(pending);
    return result;
  }

  ListPendingTxsResponse._();

  factory ListPendingTxsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPendingTxsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPendingTxsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..pPM<PendingTx>(1, _omitFieldNames ? '' : 'pending',
        subBuilder: PendingTx.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingTxsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingTxsResponse copyWith(
          void Function(ListPendingTxsResponse) updates) =>
      super.copyWith((message) => updates(message as ListPendingTxsResponse))
          as ListPendingTxsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPendingTxsResponse create() => ListPendingTxsResponse._();
  @$core.override
  ListPendingTxsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPendingTxsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPendingTxsResponse>(create);
  static ListPendingTxsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PendingTx> get pending => $_getList(0);
}

/// SimulateSendRequest dry-runs an outgoing transfer. `token_address` empty =
/// native ETH; otherwise simulates an ERC-20 `transfer(to, amount)`.
class SimulateSendRequest extends $pb.GeneratedMessage {
  factory SimulateSendRequest({
    $core.String? to,
    $core.String? amount,
    $core.String? tokenAddress,
  }) {
    final result = create();
    if (to != null) result.to = to;
    if (amount != null) result.amount = amount;
    if (tokenAddress != null) result.tokenAddress = tokenAddress;
    return result;
  }

  SimulateSendRequest._();

  factory SimulateSendRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SimulateSendRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimulateSendRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'to')
    ..aOS(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'tokenAddress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateSendRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateSendRequest copyWith(void Function(SimulateSendRequest) updates) =>
      super.copyWith((message) => updates(message as SimulateSendRequest))
          as SimulateSendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimulateSendRequest create() => SimulateSendRequest._();
  @$core.override
  SimulateSendRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SimulateSendRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SimulateSendRequest>(create);
  static SimulateSendRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get to => $_getSZ(0);
  @$pb.TagNumber(1)
  set to($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTo() => $_has(0);
  @$pb.TagNumber(1)
  void clearTo() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get amount => $_getSZ(1);
  @$pb.TagNumber(2)
  set amount($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tokenAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set tokenAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTokenAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearTokenAddress() => $_clearField(3);
}

class SimulateSendResponse extends $pb.GeneratedMessage {
  factory SimulateSendResponse({
    $core.bool? willRevert,
    $core.String? revertReason,
    $fixnum.Int64? gasUnits,
    $core.String? gasCostEth,
    $core.String? gasCostUsd,
    $core.Iterable<SimulatedAssetChange>? assetChanges,
  }) {
    final result = create();
    if (willRevert != null) result.willRevert = willRevert;
    if (revertReason != null) result.revertReason = revertReason;
    if (gasUnits != null) result.gasUnits = gasUnits;
    if (gasCostEth != null) result.gasCostEth = gasCostEth;
    if (gasCostUsd != null) result.gasCostUsd = gasCostUsd;
    if (assetChanges != null) result.assetChanges.addAll(assetChanges);
    return result;
  }

  SimulateSendResponse._();

  factory SimulateSendResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SimulateSendResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimulateSendResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'willRevert')
    ..aOS(2, _omitFieldNames ? '' : 'revertReason')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'gasUnits', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'gasCostEth')
    ..aOS(5, _omitFieldNames ? '' : 'gasCostUsd')
    ..pPM<SimulatedAssetChange>(6, _omitFieldNames ? '' : 'assetChanges',
        subBuilder: SimulatedAssetChange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateSendResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateSendResponse copyWith(void Function(SimulateSendResponse) updates) =>
      super.copyWith((message) => updates(message as SimulateSendResponse))
          as SimulateSendResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimulateSendResponse create() => SimulateSendResponse._();
  @$core.override
  SimulateSendResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SimulateSendResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SimulateSendResponse>(create);
  static SimulateSendResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get willRevert => $_getBF(0);
  @$pb.TagNumber(1)
  set willRevert($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWillRevert() => $_has(0);
  @$pb.TagNumber(1)
  void clearWillRevert() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get revertReason => $_getSZ(1);
  @$pb.TagNumber(2)
  set revertReason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevertReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevertReason() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get gasUnits => $_getI64(2);
  @$pb.TagNumber(3)
  set gasUnits($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGasUnits() => $_has(2);
  @$pb.TagNumber(3)
  void clearGasUnits() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get gasCostEth => $_getSZ(3);
  @$pb.TagNumber(4)
  set gasCostEth($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGasCostEth() => $_has(3);
  @$pb.TagNumber(4)
  void clearGasCostEth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get gasCostUsd => $_getSZ(4);
  @$pb.TagNumber(5)
  set gasCostUsd($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGasCostUsd() => $_has(4);
  @$pb.TagNumber(5)
  void clearGasCostUsd() => $_clearField(5);

  /// Asset diffs from alchemy_simulateAssetChanges. Empty when the fallback
  /// eth_call path was used (e.g. non-Alchemy node, non-mainnet).
  @$pb.TagNumber(6)
  $pb.PbList<SimulatedAssetChange> get assetChanges => $_getList(5);
}

class SimulatedAssetChange extends $pb.GeneratedMessage {
  factory SimulatedAssetChange({
    $core.String? kind,
    $core.String? changeType,
    $core.String? from,
    $core.String? to,
    $core.String? amount,
    $core.String? symbol,
    $core.String? name,
    $core.int? decimals,
    $core.String? contractAddress,
    $core.String? tokenId,
  }) {
    final result = create();
    if (kind != null) result.kind = kind;
    if (changeType != null) result.changeType = changeType;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (amount != null) result.amount = amount;
    if (symbol != null) result.symbol = symbol;
    if (name != null) result.name = name;
    if (decimals != null) result.decimals = decimals;
    if (contractAddress != null) result.contractAddress = contractAddress;
    if (tokenId != null) result.tokenId = tokenId;
    return result;
  }

  SimulatedAssetChange._();

  factory SimulatedAssetChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SimulatedAssetChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimulatedAssetChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'kind')
    ..aOS(2, _omitFieldNames ? '' : 'changeType')
    ..aOS(3, _omitFieldNames ? '' : 'from')
    ..aOS(4, _omitFieldNames ? '' : 'to')
    ..aOS(5, _omitFieldNames ? '' : 'amount')
    ..aOS(6, _omitFieldNames ? '' : 'symbol')
    ..aOS(7, _omitFieldNames ? '' : 'name')
    ..aI(8, _omitFieldNames ? '' : 'decimals', fieldType: $pb.PbFieldType.OU3)
    ..aOS(9, _omitFieldNames ? '' : 'contractAddress')
    ..aOS(10, _omitFieldNames ? '' : 'tokenId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulatedAssetChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulatedAssetChange copyWith(void Function(SimulatedAssetChange) updates) =>
      super.copyWith((message) => updates(message as SimulatedAssetChange))
          as SimulatedAssetChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimulatedAssetChange create() => SimulatedAssetChange._();
  @$core.override
  SimulatedAssetChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SimulatedAssetChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SimulatedAssetChange>(create);
  static SimulatedAssetChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get kind => $_getSZ(0);
  @$pb.TagNumber(1)
  set kind($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get changeType => $_getSZ(1);
  @$pb.TagNumber(2)
  set changeType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChangeType() => $_has(1);
  @$pb.TagNumber(2)
  void clearChangeType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get from => $_getSZ(2);
  @$pb.TagNumber(3)
  set from($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get to => $_getSZ(3);
  @$pb.TagNumber(4)
  set to($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get amount => $_getSZ(4);
  @$pb.TagNumber(5)
  set amount($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get symbol => $_getSZ(5);
  @$pb.TagNumber(6)
  set symbol($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSymbol() => $_has(5);
  @$pb.TagNumber(6)
  void clearSymbol() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get name => $_getSZ(6);
  @$pb.TagNumber(7)
  set name($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasName() => $_has(6);
  @$pb.TagNumber(7)
  void clearName() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get decimals => $_getIZ(7);
  @$pb.TagNumber(8)
  set decimals($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDecimals() => $_has(7);
  @$pb.TagNumber(8)
  void clearDecimals() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get contractAddress => $_getSZ(8);
  @$pb.TagNumber(9)
  set contractAddress($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasContractAddress() => $_has(8);
  @$pb.TagNumber(9)
  void clearContractAddress() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get tokenId => $_getSZ(9);
  @$pb.TagNumber(10)
  set tokenId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTokenId() => $_has(9);
  @$pb.TagNumber(10)
  void clearTokenId() => $_clearField(10);
}

class WatchEventsRequest extends $pb.GeneratedMessage {
  factory WatchEventsRequest() => create();

  WatchEventsRequest._();

  factory WatchEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEventsRequest copyWith(void Function(WatchEventsRequest) updates) =>
      super.copyWith((message) => updates(message as WatchEventsRequest))
          as WatchEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchEventsRequest create() => WatchEventsRequest._();
  @$core.override
  WatchEventsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchEventsRequest>(create);
  static WatchEventsRequest? _defaultInstance;
}

/// NotificationEnvelope wraps a persisted (or live-streamed) WalletEvent
/// with the storage-layer metadata the UI needs to manage read state.
/// The same shape is returned by ListNotifications and by the
/// WatchEvents stream so the client can key per-row state by `id`
/// regardless of how the event reached it.
class NotificationEnvelope extends $pb.GeneratedMessage {
  factory NotificationEnvelope({
    $core.String? id,
    $core.bool? isRead,
    $9.WalletEvent? event,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (isRead != null) result.isRead = isRead;
    if (event != null) result.event = event;
    return result;
  }

  NotificationEnvelope._();

  factory NotificationEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationEnvelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'isRead')
    ..aOM<$9.WalletEvent>(3, _omitFieldNames ? '' : 'event',
        subBuilder: $9.WalletEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationEnvelope copyWith(void Function(NotificationEnvelope) updates) =>
      super.copyWith((message) => updates(message as NotificationEnvelope))
          as NotificationEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationEnvelope create() => NotificationEnvelope._();
  @$core.override
  NotificationEnvelope createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationEnvelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationEnvelope>(create);
  static NotificationEnvelope? _defaultInstance;

  /// Server-side ULID of the persisted notification row. Empty for
  /// events that bypassed persistence (sink off, marshal failure) —
  /// those are ephemeral; UI shows them but can't mark/clear them.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// True after MarkRead / MarkAllRead has been called for this row,
  /// or after a fresh Save when `auto_mark_read` is enabled in
  /// notification settings.
  @$pb.TagNumber(2)
  $core.bool get isRead => $_getBF(1);
  @$pb.TagNumber(2)
  set isRead($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsRead() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsRead() => $_clearField(2);

  /// The event itself. For live streams this is the watcher's emit;
  /// for List this is the persisted payload re-unmarshalled.
  @$pb.TagNumber(3)
  $9.WalletEvent get event => $_getN(2);
  @$pb.TagNumber(3)
  set event($9.WalletEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEvent() => $_has(2);
  @$pb.TagNumber(3)
  void clearEvent() => $_clearField(3);
  @$pb.TagNumber(3)
  $9.WalletEvent ensureEvent() => $_ensure(2);
}

/// ListNotifications returns the persisted history so the UI can
/// re-populate its notification panel after a restart. The stream of
/// new events flows through WatchEvents (also envelope-wrapped) —
/// this RPC is purely the read-side cache.
class ListNotificationsRequest extends $pb.GeneratedMessage {
  factory ListNotificationsRequest({
    $core.int? limit,
  }) {
    final result = create();
    if (limit != null) result.limit = limit;
    return result;
  }

  ListNotificationsRequest._();

  factory ListNotificationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListNotificationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListNotificationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNotificationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNotificationsRequest copyWith(
          void Function(ListNotificationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListNotificationsRequest))
          as ListNotificationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListNotificationsRequest create() => ListNotificationsRequest._();
  @$core.override
  ListNotificationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListNotificationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListNotificationsRequest>(create);
  static ListNotificationsRequest? _defaultInstance;

  /// Max rows to return. Clamped to [1, 200]; 0 means default 100.
  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => $_clearField(1);
}

class ListNotificationsResponse extends $pb.GeneratedMessage {
  factory ListNotificationsResponse({
    $core.Iterable<NotificationEnvelope>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  ListNotificationsResponse._();

  factory ListNotificationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListNotificationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListNotificationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..pPM<NotificationEnvelope>(1, _omitFieldNames ? '' : 'items',
        subBuilder: NotificationEnvelope.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNotificationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNotificationsResponse copyWith(
          void Function(ListNotificationsResponse) updates) =>
      super.copyWith((message) => updates(message as ListNotificationsResponse))
          as ListNotificationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListNotificationsResponse create() => ListNotificationsResponse._();
  @$core.override
  ListNotificationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListNotificationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListNotificationsResponse>(create);
  static ListNotificationsResponse? _defaultInstance;

  /// Newest first.
  @$pb.TagNumber(1)
  $pb.PbList<NotificationEnvelope> get items => $_getList(0);
}

class MarkNotificationReadRequest extends $pb.GeneratedMessage {
  factory MarkNotificationReadRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  MarkNotificationReadRequest._();

  factory MarkNotificationReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkNotificationReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkNotificationReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkNotificationReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkNotificationReadRequest copyWith(
          void Function(MarkNotificationReadRequest) updates) =>
      super.copyWith(
              (message) => updates(message as MarkNotificationReadRequest))
          as MarkNotificationReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkNotificationReadRequest create() =>
      MarkNotificationReadRequest._();
  @$core.override
  MarkNotificationReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkNotificationReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkNotificationReadRequest>(create);
  static MarkNotificationReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class MarkNotificationReadResponse extends $pb.GeneratedMessage {
  factory MarkNotificationReadResponse() => create();

  MarkNotificationReadResponse._();

  factory MarkNotificationReadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkNotificationReadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkNotificationReadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkNotificationReadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkNotificationReadResponse copyWith(
          void Function(MarkNotificationReadResponse) updates) =>
      super.copyWith(
              (message) => updates(message as MarkNotificationReadResponse))
          as MarkNotificationReadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkNotificationReadResponse create() =>
      MarkNotificationReadResponse._();
  @$core.override
  MarkNotificationReadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkNotificationReadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkNotificationReadResponse>(create);
  static MarkNotificationReadResponse? _defaultInstance;
}

class MarkAllNotificationsReadRequest extends $pb.GeneratedMessage {
  factory MarkAllNotificationsReadRequest() => create();

  MarkAllNotificationsReadRequest._();

  factory MarkAllNotificationsReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAllNotificationsReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAllNotificationsReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllNotificationsReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllNotificationsReadRequest copyWith(
          void Function(MarkAllNotificationsReadRequest) updates) =>
      super.copyWith(
              (message) => updates(message as MarkAllNotificationsReadRequest))
          as MarkAllNotificationsReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAllNotificationsReadRequest create() =>
      MarkAllNotificationsReadRequest._();
  @$core.override
  MarkAllNotificationsReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAllNotificationsReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAllNotificationsReadRequest>(
          create);
  static MarkAllNotificationsReadRequest? _defaultInstance;
}

class MarkAllNotificationsReadResponse extends $pb.GeneratedMessage {
  factory MarkAllNotificationsReadResponse() => create();

  MarkAllNotificationsReadResponse._();

  factory MarkAllNotificationsReadResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAllNotificationsReadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAllNotificationsReadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllNotificationsReadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllNotificationsReadResponse copyWith(
          void Function(MarkAllNotificationsReadResponse) updates) =>
      super.copyWith(
              (message) => updates(message as MarkAllNotificationsReadResponse))
          as MarkAllNotificationsReadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAllNotificationsReadResponse create() =>
      MarkAllNotificationsReadResponse._();
  @$core.override
  MarkAllNotificationsReadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAllNotificationsReadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAllNotificationsReadResponse>(
          create);
  static MarkAllNotificationsReadResponse? _defaultInstance;
}

class ClearNotificationsRequest extends $pb.GeneratedMessage {
  factory ClearNotificationsRequest() => create();

  ClearNotificationsRequest._();

  factory ClearNotificationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearNotificationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearNotificationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearNotificationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearNotificationsRequest copyWith(
          void Function(ClearNotificationsRequest) updates) =>
      super.copyWith((message) => updates(message as ClearNotificationsRequest))
          as ClearNotificationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearNotificationsRequest create() => ClearNotificationsRequest._();
  @$core.override
  ClearNotificationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearNotificationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearNotificationsRequest>(create);
  static ClearNotificationsRequest? _defaultInstance;
}

class ClearNotificationsResponse extends $pb.GeneratedMessage {
  factory ClearNotificationsResponse() => create();

  ClearNotificationsResponse._();

  factory ClearNotificationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearNotificationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearNotificationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearNotificationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearNotificationsResponse copyWith(
          void Function(ClearNotificationsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClearNotificationsResponse))
          as ClearNotificationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearNotificationsResponse create() => ClearNotificationsResponse._();
  @$core.override
  ClearNotificationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearNotificationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearNotificationsResponse>(create);
  static ClearNotificationsResponse? _defaultInstance;
}

/// NotificationSettings mirrors the SQLite singleton row. All fields
/// are user-controlled toggles or numbers; the server persists the
/// whole struct on every Update call (no PATCH-style partial updates,
/// keeps the wire small and the storage code straight-line).
class NotificationSettings extends $pb.GeneratedMessage {
  factory NotificationSettings({
    $core.bool? playSound,
    $core.bool? macosToasts,
    $core.bool? autoMarkRead,
    $core.int? autoDeleteDays,
    $core.bool? muteSystemAlerts,
  }) {
    final result = create();
    if (playSound != null) result.playSound = playSound;
    if (macosToasts != null) result.macosToasts = macosToasts;
    if (autoMarkRead != null) result.autoMarkRead = autoMarkRead;
    if (autoDeleteDays != null) result.autoDeleteDays = autoDeleteDays;
    if (muteSystemAlerts != null) result.muteSystemAlerts = muteSystemAlerts;
    return result;
  }

  NotificationSettings._();

  factory NotificationSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'playSound')
    ..aOB(2, _omitFieldNames ? '' : 'macosToasts')
    ..aOB(3, _omitFieldNames ? '' : 'autoMarkRead')
    ..aI(4, _omitFieldNames ? '' : 'autoDeleteDays')
    ..aOB(5, _omitFieldNames ? '' : 'muteSystemAlerts')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings copyWith(void Function(NotificationSettings) updates) =>
      super.copyWith((message) => updates(message as NotificationSettings))
          as NotificationSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationSettings create() => NotificationSettings._();
  @$core.override
  NotificationSettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationSettings>(create);
  static NotificationSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get playSound => $_getBF(0);
  @$pb.TagNumber(1)
  set playSound($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlaySound() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlaySound() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get macosToasts => $_getBF(1);
  @$pb.TagNumber(2)
  set macosToasts($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMacosToasts() => $_has(1);
  @$pb.TagNumber(2)
  void clearMacosToasts() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get autoMarkRead => $_getBF(2);
  @$pb.TagNumber(3)
  set autoMarkRead($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutoMarkRead() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutoMarkRead() => $_clearField(3);

  /// 0 means "never auto-delete".
  @$pb.TagNumber(4)
  $core.int get autoDeleteDays => $_getIZ(3);
  @$pb.TagNumber(4)
  set autoDeleteDays($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAutoDeleteDays() => $_has(3);
  @$pb.TagNumber(4)
  void clearAutoDeleteDays() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get muteSystemAlerts => $_getBF(4);
  @$pb.TagNumber(5)
  set muteSystemAlerts($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMuteSystemAlerts() => $_has(4);
  @$pb.TagNumber(5)
  void clearMuteSystemAlerts() => $_clearField(5);
}

class GetNotificationSettingsRequest extends $pb.GeneratedMessage {
  factory GetNotificationSettingsRequest() => create();

  GetNotificationSettingsRequest._();

  factory GetNotificationSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNotificationSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNotificationSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsRequest copyWith(
          void Function(GetNotificationSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetNotificationSettingsRequest))
          as GetNotificationSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsRequest create() =>
      GetNotificationSettingsRequest._();
  @$core.override
  GetNotificationSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNotificationSettingsRequest>(create);
  static GetNotificationSettingsRequest? _defaultInstance;
}

class GetNotificationSettingsResponse extends $pb.GeneratedMessage {
  factory GetNotificationSettingsResponse({
    NotificationSettings? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  GetNotificationSettingsResponse._();

  factory GetNotificationSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNotificationSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNotificationSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<NotificationSettings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: NotificationSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsResponse copyWith(
          void Function(GetNotificationSettingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetNotificationSettingsResponse))
          as GetNotificationSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsResponse create() =>
      GetNotificationSettingsResponse._();
  @$core.override
  GetNotificationSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNotificationSettingsResponse>(
          create);
  static GetNotificationSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  NotificationSettings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(NotificationSettings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  NotificationSettings ensureSettings() => $_ensure(0);
}

class UpdateNotificationSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateNotificationSettingsRequest({
    NotificationSettings? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  UpdateNotificationSettingsRequest._();

  factory UpdateNotificationSettingsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNotificationSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNotificationSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<NotificationSettings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: NotificationSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsRequest copyWith(
          void Function(UpdateNotificationSettingsRequest) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateNotificationSettingsRequest))
          as UpdateNotificationSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsRequest create() =>
      UpdateNotificationSettingsRequest._();
  @$core.override
  UpdateNotificationSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNotificationSettingsRequest>(
          create);
  static UpdateNotificationSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  NotificationSettings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(NotificationSettings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  NotificationSettings ensureSettings() => $_ensure(0);
}

class UpdateNotificationSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateNotificationSettingsResponse({
    NotificationSettings? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  UpdateNotificationSettingsResponse._();

  factory UpdateNotificationSettingsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNotificationSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNotificationSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wallet'),
      createEmptyInstance: create)
    ..aOM<NotificationSettings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: NotificationSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsResponse copyWith(
          void Function(UpdateNotificationSettingsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateNotificationSettingsResponse))
          as UpdateNotificationSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsResponse create() =>
      UpdateNotificationSettingsResponse._();
  @$core.override
  UpdateNotificationSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNotificationSettingsResponse>(
          create);
  static UpdateNotificationSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  NotificationSettings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(NotificationSettings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  NotificationSettings ensureSettings() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
