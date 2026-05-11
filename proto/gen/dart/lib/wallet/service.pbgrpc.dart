// This is a generated file - do not edit.
//
// Generated from wallet/service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'service.pb.dart' as $0;

export 'service.pb.dart';

@$pb.GrpcServiceName('wallet.WalletService')
class WalletServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WalletServiceClient(super.channel, {super.options, super.interceptors});

  /// Wallet management
  $grpc.ResponseFuture<$0.GenerateWalletResponse> generateWallet(
    $0.GenerateWalletRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$generateWallet, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportMnemonicResponse> importMnemonic(
    $0.ImportMnemonicRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importMnemonic, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportPrivateKeyResponse> importPrivateKey(
    $0.ImportPrivateKeyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importPrivateKey, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportKeystoreResponse> importKeystore(
    $0.ImportKeystoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importKeystore, request, options: options);
  }

  $grpc.ResponseFuture<$0.RevealSecretResponse> revealSecret(
    $0.RevealSecretRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revealSecret, request, options: options);
  }

  $grpc.ResponseFuture<$0.ExportKeystoreResponse> exportKeystore(
    $0.ExportKeystoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exportKeystore, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetWalletResponse> getWallet(
    $0.GetWalletRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getWallet, request, options: options);
  }

  /// Balances & fees
  $grpc.ResponseFuture<$0.GetBalancesResponse> getBalances(
    $0.GetBalancesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBalances, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetGasFeesResponse> getGasFees(
    $0.GetGasFeesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGasFees, request, options: options);
  }

  /// Transactions
  $grpc.ResponseFuture<$0.SendETHResponse> sendETH(
    $0.SendETHRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendETH, request, options: options);
  }

  $grpc.ResponseFuture<$0.SendTokenResponse> sendToken(
    $0.SendTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendToken, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetHistoryResponse> getHistory(
    $0.GetHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHistory, request, options: options);
  }

  /// Swap
  $grpc.ResponseFuture<$0.QuoteSwapResponse> quoteSwap(
    $0.QuoteSwapRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$quoteSwap, request, options: options);
  }

  $grpc.ResponseFuture<$0.ExecuteSwapResponse> executeSwap(
    $0.ExecuteSwapRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeSwap, request, options: options);
  }

  /// Contacts
  $grpc.ResponseFuture<$0.CreateContactResponse> createContact(
    $0.CreateContactRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createContact, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetContactResponse> getContact(
    $0.GetContactRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getContact, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateContactResponse> updateContact(
    $0.UpdateContactRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateContact, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteContactResponse> deleteContact(
    $0.DeleteContactRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteContact, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListContactsResponse> listContacts(
    $0.ListContactsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listContacts, request, options: options);
  }

  $grpc.ResponseFuture<$0.FavoriteContactResponse> favoriteContact(
    $0.FavoriteContactRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$favoriteContact, request, options: options);
  }

  /// Tokens
  $grpc.ResponseFuture<$0.AddTokenResponse> addToken(
    $0.AddTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addToken, request, options: options);
  }

  $grpc.ResponseFuture<$0.RemoveTokenResponse> removeToken(
    $0.RemoveTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeToken, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListTokensResponse> listTokens(
    $0.ListTokensRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTokens, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListTokensWithBalancesResponse>
      listTokensWithBalances(
    $0.ListTokensWithBalancesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTokensWithBalances, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.PinTokenResponse> pinToken(
    $0.PinTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pinToken, request, options: options);
  }

  $grpc.ResponseFuture<$0.HideTokenResponse> hideToken(
    $0.HideTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$hideToken, request, options: options);
  }

  /// Approvals
  $grpc.ResponseFuture<$0.ListApprovalsResponse> listApprovals(
    $0.ListApprovalsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listApprovals, request, options: options);
  }

  $grpc.ResponseFuture<$0.RevokeApprovalResponse> revokeApproval(
    $0.RevokeApprovalRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeApproval, request, options: options);
  }

  /// ENS
  $grpc.ResponseFuture<$0.ResolveENSResponse> resolveENS(
    $0.ResolveENSRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resolveENS, request, options: options);
  }

  $grpc.ResponseFuture<$0.ReverseENSResponse> reverseENS(
    $0.ReverseENSRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reverseENS, request, options: options);
  }

  /// Replacement transactions
  $grpc.ResponseFuture<$0.SpeedUpTxResponse> speedUpTx(
    $0.SpeedUpTxRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$speedUpTx, request, options: options);
  }

  $grpc.ResponseFuture<$0.CancelTxResponse> cancelTx(
    $0.CancelTxRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cancelTx, request, options: options);
  }

  /// Pending transactions
  $grpc.ResponseFuture<$0.ListPendingTxsResponse> listPendingTxs(
    $0.ListPendingTxsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPendingTxs, request, options: options);
  }

  /// Simulation
  $grpc.ResponseFuture<$0.SimulateSendResponse> simulateSend(
    $0.SimulateSendRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$simulateSend, request, options: options);
  }

  /// Streaming
  $grpc.ResponseStream<$0.NotificationEnvelope> watchEvents(
    $0.WatchEventsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchEvents, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Notifications
  $grpc.ResponseFuture<$0.ListNotificationsResponse> listNotifications(
    $0.ListNotificationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.MarkNotificationReadResponse> markNotificationRead(
    $0.MarkNotificationReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markNotificationRead, request, options: options);
  }

  $grpc.ResponseFuture<$0.MarkAllNotificationsReadResponse>
      markAllNotificationsRead(
    $0.MarkAllNotificationsReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markAllNotificationsRead, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.ClearNotificationsResponse> clearNotifications(
    $0.ClearNotificationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clearNotifications, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetNotificationSettingsResponse>
      getNotificationSettings(
    $0.GetNotificationSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNotificationSettings, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.UpdateNotificationSettingsResponse>
      updateNotificationSettings(
    $0.UpdateNotificationSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateNotificationSettings, request,
        options: options);
  }

  // method descriptors

  static final _$generateWallet =
      $grpc.ClientMethod<$0.GenerateWalletRequest, $0.GenerateWalletResponse>(
          '/wallet.WalletService/GenerateWallet',
          ($0.GenerateWalletRequest value) => value.writeToBuffer(),
          $0.GenerateWalletResponse.fromBuffer);
  static final _$importMnemonic =
      $grpc.ClientMethod<$0.ImportMnemonicRequest, $0.ImportMnemonicResponse>(
          '/wallet.WalletService/ImportMnemonic',
          ($0.ImportMnemonicRequest value) => value.writeToBuffer(),
          $0.ImportMnemonicResponse.fromBuffer);
  static final _$importPrivateKey = $grpc.ClientMethod<
          $0.ImportPrivateKeyRequest, $0.ImportPrivateKeyResponse>(
      '/wallet.WalletService/ImportPrivateKey',
      ($0.ImportPrivateKeyRequest value) => value.writeToBuffer(),
      $0.ImportPrivateKeyResponse.fromBuffer);
  static final _$importKeystore =
      $grpc.ClientMethod<$0.ImportKeystoreRequest, $0.ImportKeystoreResponse>(
          '/wallet.WalletService/ImportKeystore',
          ($0.ImportKeystoreRequest value) => value.writeToBuffer(),
          $0.ImportKeystoreResponse.fromBuffer);
  static final _$revealSecret =
      $grpc.ClientMethod<$0.RevealSecretRequest, $0.RevealSecretResponse>(
          '/wallet.WalletService/RevealSecret',
          ($0.RevealSecretRequest value) => value.writeToBuffer(),
          $0.RevealSecretResponse.fromBuffer);
  static final _$exportKeystore =
      $grpc.ClientMethod<$0.ExportKeystoreRequest, $0.ExportKeystoreResponse>(
          '/wallet.WalletService/ExportKeystore',
          ($0.ExportKeystoreRequest value) => value.writeToBuffer(),
          $0.ExportKeystoreResponse.fromBuffer);
  static final _$getWallet =
      $grpc.ClientMethod<$0.GetWalletRequest, $0.GetWalletResponse>(
          '/wallet.WalletService/GetWallet',
          ($0.GetWalletRequest value) => value.writeToBuffer(),
          $0.GetWalletResponse.fromBuffer);
  static final _$getBalances =
      $grpc.ClientMethod<$0.GetBalancesRequest, $0.GetBalancesResponse>(
          '/wallet.WalletService/GetBalances',
          ($0.GetBalancesRequest value) => value.writeToBuffer(),
          $0.GetBalancesResponse.fromBuffer);
  static final _$getGasFees =
      $grpc.ClientMethod<$0.GetGasFeesRequest, $0.GetGasFeesResponse>(
          '/wallet.WalletService/GetGasFees',
          ($0.GetGasFeesRequest value) => value.writeToBuffer(),
          $0.GetGasFeesResponse.fromBuffer);
  static final _$sendETH =
      $grpc.ClientMethod<$0.SendETHRequest, $0.SendETHResponse>(
          '/wallet.WalletService/SendETH',
          ($0.SendETHRequest value) => value.writeToBuffer(),
          $0.SendETHResponse.fromBuffer);
  static final _$sendToken =
      $grpc.ClientMethod<$0.SendTokenRequest, $0.SendTokenResponse>(
          '/wallet.WalletService/SendToken',
          ($0.SendTokenRequest value) => value.writeToBuffer(),
          $0.SendTokenResponse.fromBuffer);
  static final _$getHistory =
      $grpc.ClientMethod<$0.GetHistoryRequest, $0.GetHistoryResponse>(
          '/wallet.WalletService/GetHistory',
          ($0.GetHistoryRequest value) => value.writeToBuffer(),
          $0.GetHistoryResponse.fromBuffer);
  static final _$quoteSwap =
      $grpc.ClientMethod<$0.QuoteSwapRequest, $0.QuoteSwapResponse>(
          '/wallet.WalletService/QuoteSwap',
          ($0.QuoteSwapRequest value) => value.writeToBuffer(),
          $0.QuoteSwapResponse.fromBuffer);
  static final _$executeSwap =
      $grpc.ClientMethod<$0.ExecuteSwapRequest, $0.ExecuteSwapResponse>(
          '/wallet.WalletService/ExecuteSwap',
          ($0.ExecuteSwapRequest value) => value.writeToBuffer(),
          $0.ExecuteSwapResponse.fromBuffer);
  static final _$createContact =
      $grpc.ClientMethod<$0.CreateContactRequest, $0.CreateContactResponse>(
          '/wallet.WalletService/CreateContact',
          ($0.CreateContactRequest value) => value.writeToBuffer(),
          $0.CreateContactResponse.fromBuffer);
  static final _$getContact =
      $grpc.ClientMethod<$0.GetContactRequest, $0.GetContactResponse>(
          '/wallet.WalletService/GetContact',
          ($0.GetContactRequest value) => value.writeToBuffer(),
          $0.GetContactResponse.fromBuffer);
  static final _$updateContact =
      $grpc.ClientMethod<$0.UpdateContactRequest, $0.UpdateContactResponse>(
          '/wallet.WalletService/UpdateContact',
          ($0.UpdateContactRequest value) => value.writeToBuffer(),
          $0.UpdateContactResponse.fromBuffer);
  static final _$deleteContact =
      $grpc.ClientMethod<$0.DeleteContactRequest, $0.DeleteContactResponse>(
          '/wallet.WalletService/DeleteContact',
          ($0.DeleteContactRequest value) => value.writeToBuffer(),
          $0.DeleteContactResponse.fromBuffer);
  static final _$listContacts =
      $grpc.ClientMethod<$0.ListContactsRequest, $0.ListContactsResponse>(
          '/wallet.WalletService/ListContacts',
          ($0.ListContactsRequest value) => value.writeToBuffer(),
          $0.ListContactsResponse.fromBuffer);
  static final _$favoriteContact =
      $grpc.ClientMethod<$0.FavoriteContactRequest, $0.FavoriteContactResponse>(
          '/wallet.WalletService/FavoriteContact',
          ($0.FavoriteContactRequest value) => value.writeToBuffer(),
          $0.FavoriteContactResponse.fromBuffer);
  static final _$addToken =
      $grpc.ClientMethod<$0.AddTokenRequest, $0.AddTokenResponse>(
          '/wallet.WalletService/AddToken',
          ($0.AddTokenRequest value) => value.writeToBuffer(),
          $0.AddTokenResponse.fromBuffer);
  static final _$removeToken =
      $grpc.ClientMethod<$0.RemoveTokenRequest, $0.RemoveTokenResponse>(
          '/wallet.WalletService/RemoveToken',
          ($0.RemoveTokenRequest value) => value.writeToBuffer(),
          $0.RemoveTokenResponse.fromBuffer);
  static final _$listTokens =
      $grpc.ClientMethod<$0.ListTokensRequest, $0.ListTokensResponse>(
          '/wallet.WalletService/ListTokens',
          ($0.ListTokensRequest value) => value.writeToBuffer(),
          $0.ListTokensResponse.fromBuffer);
  static final _$listTokensWithBalances = $grpc.ClientMethod<
          $0.ListTokensWithBalancesRequest, $0.ListTokensWithBalancesResponse>(
      '/wallet.WalletService/ListTokensWithBalances',
      ($0.ListTokensWithBalancesRequest value) => value.writeToBuffer(),
      $0.ListTokensWithBalancesResponse.fromBuffer);
  static final _$pinToken =
      $grpc.ClientMethod<$0.PinTokenRequest, $0.PinTokenResponse>(
          '/wallet.WalletService/PinToken',
          ($0.PinTokenRequest value) => value.writeToBuffer(),
          $0.PinTokenResponse.fromBuffer);
  static final _$hideToken =
      $grpc.ClientMethod<$0.HideTokenRequest, $0.HideTokenResponse>(
          '/wallet.WalletService/HideToken',
          ($0.HideTokenRequest value) => value.writeToBuffer(),
          $0.HideTokenResponse.fromBuffer);
  static final _$listApprovals =
      $grpc.ClientMethod<$0.ListApprovalsRequest, $0.ListApprovalsResponse>(
          '/wallet.WalletService/ListApprovals',
          ($0.ListApprovalsRequest value) => value.writeToBuffer(),
          $0.ListApprovalsResponse.fromBuffer);
  static final _$revokeApproval =
      $grpc.ClientMethod<$0.RevokeApprovalRequest, $0.RevokeApprovalResponse>(
          '/wallet.WalletService/RevokeApproval',
          ($0.RevokeApprovalRequest value) => value.writeToBuffer(),
          $0.RevokeApprovalResponse.fromBuffer);
  static final _$resolveENS =
      $grpc.ClientMethod<$0.ResolveENSRequest, $0.ResolveENSResponse>(
          '/wallet.WalletService/ResolveENS',
          ($0.ResolveENSRequest value) => value.writeToBuffer(),
          $0.ResolveENSResponse.fromBuffer);
  static final _$reverseENS =
      $grpc.ClientMethod<$0.ReverseENSRequest, $0.ReverseENSResponse>(
          '/wallet.WalletService/ReverseENS',
          ($0.ReverseENSRequest value) => value.writeToBuffer(),
          $0.ReverseENSResponse.fromBuffer);
  static final _$speedUpTx =
      $grpc.ClientMethod<$0.SpeedUpTxRequest, $0.SpeedUpTxResponse>(
          '/wallet.WalletService/SpeedUpTx',
          ($0.SpeedUpTxRequest value) => value.writeToBuffer(),
          $0.SpeedUpTxResponse.fromBuffer);
  static final _$cancelTx =
      $grpc.ClientMethod<$0.CancelTxRequest, $0.CancelTxResponse>(
          '/wallet.WalletService/CancelTx',
          ($0.CancelTxRequest value) => value.writeToBuffer(),
          $0.CancelTxResponse.fromBuffer);
  static final _$listPendingTxs =
      $grpc.ClientMethod<$0.ListPendingTxsRequest, $0.ListPendingTxsResponse>(
          '/wallet.WalletService/ListPendingTxs',
          ($0.ListPendingTxsRequest value) => value.writeToBuffer(),
          $0.ListPendingTxsResponse.fromBuffer);
  static final _$simulateSend =
      $grpc.ClientMethod<$0.SimulateSendRequest, $0.SimulateSendResponse>(
          '/wallet.WalletService/SimulateSend',
          ($0.SimulateSendRequest value) => value.writeToBuffer(),
          $0.SimulateSendResponse.fromBuffer);
  static final _$watchEvents =
      $grpc.ClientMethod<$0.WatchEventsRequest, $0.NotificationEnvelope>(
          '/wallet.WalletService/WatchEvents',
          ($0.WatchEventsRequest value) => value.writeToBuffer(),
          $0.NotificationEnvelope.fromBuffer);
  static final _$listNotifications = $grpc.ClientMethod<
          $0.ListNotificationsRequest, $0.ListNotificationsResponse>(
      '/wallet.WalletService/ListNotifications',
      ($0.ListNotificationsRequest value) => value.writeToBuffer(),
      $0.ListNotificationsResponse.fromBuffer);
  static final _$markNotificationRead = $grpc.ClientMethod<
          $0.MarkNotificationReadRequest, $0.MarkNotificationReadResponse>(
      '/wallet.WalletService/MarkNotificationRead',
      ($0.MarkNotificationReadRequest value) => value.writeToBuffer(),
      $0.MarkNotificationReadResponse.fromBuffer);
  static final _$markAllNotificationsRead = $grpc.ClientMethod<
          $0.MarkAllNotificationsReadRequest,
          $0.MarkAllNotificationsReadResponse>(
      '/wallet.WalletService/MarkAllNotificationsRead',
      ($0.MarkAllNotificationsReadRequest value) => value.writeToBuffer(),
      $0.MarkAllNotificationsReadResponse.fromBuffer);
  static final _$clearNotifications = $grpc.ClientMethod<
          $0.ClearNotificationsRequest, $0.ClearNotificationsResponse>(
      '/wallet.WalletService/ClearNotifications',
      ($0.ClearNotificationsRequest value) => value.writeToBuffer(),
      $0.ClearNotificationsResponse.fromBuffer);
  static final _$getNotificationSettings = $grpc.ClientMethod<
          $0.GetNotificationSettingsRequest,
          $0.GetNotificationSettingsResponse>(
      '/wallet.WalletService/GetNotificationSettings',
      ($0.GetNotificationSettingsRequest value) => value.writeToBuffer(),
      $0.GetNotificationSettingsResponse.fromBuffer);
  static final _$updateNotificationSettings = $grpc.ClientMethod<
          $0.UpdateNotificationSettingsRequest,
          $0.UpdateNotificationSettingsResponse>(
      '/wallet.WalletService/UpdateNotificationSettings',
      ($0.UpdateNotificationSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateNotificationSettingsResponse.fromBuffer);
}

@$pb.GrpcServiceName('wallet.WalletService')
abstract class WalletServiceBase extends $grpc.Service {
  $core.String get $name => 'wallet.WalletService';

  WalletServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GenerateWalletRequest,
            $0.GenerateWalletResponse>(
        'GenerateWallet',
        generateWallet_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GenerateWalletRequest.fromBuffer(value),
        ($0.GenerateWalletResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportMnemonicRequest,
            $0.ImportMnemonicResponse>(
        'ImportMnemonic',
        importMnemonic_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportMnemonicRequest.fromBuffer(value),
        ($0.ImportMnemonicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportPrivateKeyRequest,
            $0.ImportPrivateKeyResponse>(
        'ImportPrivateKey',
        importPrivateKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportPrivateKeyRequest.fromBuffer(value),
        ($0.ImportPrivateKeyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportKeystoreRequest,
            $0.ImportKeystoreResponse>(
        'ImportKeystore',
        importKeystore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportKeystoreRequest.fromBuffer(value),
        ($0.ImportKeystoreResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RevealSecretRequest, $0.RevealSecretResponse>(
            'RevealSecret',
            revealSecret_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RevealSecretRequest.fromBuffer(value),
            ($0.RevealSecretResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExportKeystoreRequest,
            $0.ExportKeystoreResponse>(
        'ExportKeystore',
        exportKeystore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExportKeystoreRequest.fromBuffer(value),
        ($0.ExportKeystoreResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetWalletRequest, $0.GetWalletResponse>(
        'GetWallet',
        getWallet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetWalletRequest.fromBuffer(value),
        ($0.GetWalletResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetBalancesRequest, $0.GetBalancesResponse>(
            'GetBalances',
            getBalances_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetBalancesRequest.fromBuffer(value),
            ($0.GetBalancesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGasFeesRequest, $0.GetGasFeesResponse>(
        'GetGasFees',
        getGasFees_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGasFeesRequest.fromBuffer(value),
        ($0.GetGasFeesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendETHRequest, $0.SendETHResponse>(
        'SendETH',
        sendETH_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SendETHRequest.fromBuffer(value),
        ($0.SendETHResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendTokenRequest, $0.SendTokenResponse>(
        'SendToken',
        sendToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SendTokenRequest.fromBuffer(value),
        ($0.SendTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHistoryRequest, $0.GetHistoryResponse>(
        'GetHistory',
        getHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetHistoryRequest.fromBuffer(value),
        ($0.GetHistoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QuoteSwapRequest, $0.QuoteSwapResponse>(
        'QuoteSwap',
        quoteSwap_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QuoteSwapRequest.fromBuffer(value),
        ($0.QuoteSwapResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ExecuteSwapRequest, $0.ExecuteSwapResponse>(
            'ExecuteSwap',
            executeSwap_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ExecuteSwapRequest.fromBuffer(value),
            ($0.ExecuteSwapResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateContactRequest, $0.CreateContactResponse>(
            'CreateContact',
            createContact_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateContactRequest.fromBuffer(value),
            ($0.CreateContactResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetContactRequest, $0.GetContactResponse>(
        'GetContact',
        getContact_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetContactRequest.fromBuffer(value),
        ($0.GetContactResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateContactRequest, $0.UpdateContactResponse>(
            'UpdateContact',
            updateContact_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateContactRequest.fromBuffer(value),
            ($0.UpdateContactResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteContactRequest, $0.DeleteContactResponse>(
            'DeleteContact',
            deleteContact_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteContactRequest.fromBuffer(value),
            ($0.DeleteContactResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListContactsRequest, $0.ListContactsResponse>(
            'ListContacts',
            listContacts_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListContactsRequest.fromBuffer(value),
            ($0.ListContactsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FavoriteContactRequest,
            $0.FavoriteContactResponse>(
        'FavoriteContact',
        favoriteContact_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FavoriteContactRequest.fromBuffer(value),
        ($0.FavoriteContactResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddTokenRequest, $0.AddTokenResponse>(
        'AddToken',
        addToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddTokenRequest.fromBuffer(value),
        ($0.AddTokenResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RemoveTokenRequest, $0.RemoveTokenResponse>(
            'RemoveToken',
            removeToken_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RemoveTokenRequest.fromBuffer(value),
            ($0.RemoveTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListTokensRequest, $0.ListTokensResponse>(
        'ListTokens',
        listTokens_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListTokensRequest.fromBuffer(value),
        ($0.ListTokensResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListTokensWithBalancesRequest,
            $0.ListTokensWithBalancesResponse>(
        'ListTokensWithBalances',
        listTokensWithBalances_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListTokensWithBalancesRequest.fromBuffer(value),
        ($0.ListTokensWithBalancesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PinTokenRequest, $0.PinTokenResponse>(
        'PinToken',
        pinToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PinTokenRequest.fromBuffer(value),
        ($0.PinTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HideTokenRequest, $0.HideTokenResponse>(
        'HideToken',
        hideToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HideTokenRequest.fromBuffer(value),
        ($0.HideTokenResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListApprovalsRequest, $0.ListApprovalsResponse>(
            'ListApprovals',
            listApprovals_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListApprovalsRequest.fromBuffer(value),
            ($0.ListApprovalsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeApprovalRequest,
            $0.RevokeApprovalResponse>(
        'RevokeApproval',
        revokeApproval_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RevokeApprovalRequest.fromBuffer(value),
        ($0.RevokeApprovalResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ResolveENSRequest, $0.ResolveENSResponse>(
        'ResolveENS',
        resolveENS_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ResolveENSRequest.fromBuffer(value),
        ($0.ResolveENSResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReverseENSRequest, $0.ReverseENSResponse>(
        'ReverseENS',
        reverseENS_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ReverseENSRequest.fromBuffer(value),
        ($0.ReverseENSResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpeedUpTxRequest, $0.SpeedUpTxResponse>(
        'SpeedUpTx',
        speedUpTx_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SpeedUpTxRequest.fromBuffer(value),
        ($0.SpeedUpTxResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CancelTxRequest, $0.CancelTxResponse>(
        'CancelTx',
        cancelTx_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CancelTxRequest.fromBuffer(value),
        ($0.CancelTxResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListPendingTxsRequest,
            $0.ListPendingTxsResponse>(
        'ListPendingTxs',
        listPendingTxs_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListPendingTxsRequest.fromBuffer(value),
        ($0.ListPendingTxsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SimulateSendRequest, $0.SimulateSendResponse>(
            'SimulateSend',
            simulateSend_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SimulateSendRequest.fromBuffer(value),
            ($0.SimulateSendResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.WatchEventsRequest, $0.NotificationEnvelope>(
            'WatchEvents',
            watchEvents_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.WatchEventsRequest.fromBuffer(value),
            ($0.NotificationEnvelope value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListNotificationsRequest,
            $0.ListNotificationsResponse>(
        'ListNotifications',
        listNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListNotificationsRequest.fromBuffer(value),
        ($0.ListNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MarkNotificationReadRequest,
            $0.MarkNotificationReadResponse>(
        'MarkNotificationRead',
        markNotificationRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MarkNotificationReadRequest.fromBuffer(value),
        ($0.MarkNotificationReadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MarkAllNotificationsReadRequest,
            $0.MarkAllNotificationsReadResponse>(
        'MarkAllNotificationsRead',
        markAllNotificationsRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MarkAllNotificationsReadRequest.fromBuffer(value),
        ($0.MarkAllNotificationsReadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClearNotificationsRequest,
            $0.ClearNotificationsResponse>(
        'ClearNotifications',
        clearNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ClearNotificationsRequest.fromBuffer(value),
        ($0.ClearNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNotificationSettingsRequest,
            $0.GetNotificationSettingsResponse>(
        'GetNotificationSettings',
        getNotificationSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNotificationSettingsRequest.fromBuffer(value),
        ($0.GetNotificationSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateNotificationSettingsRequest,
            $0.UpdateNotificationSettingsResponse>(
        'UpdateNotificationSettings',
        updateNotificationSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateNotificationSettingsRequest.fromBuffer(value),
        ($0.UpdateNotificationSettingsResponse value) =>
            value.writeToBuffer()));
  }

  $async.Future<$0.GenerateWalletResponse> generateWallet_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GenerateWalletRequest> $request) async {
    return generateWallet($call, await $request);
  }

  $async.Future<$0.GenerateWalletResponse> generateWallet(
      $grpc.ServiceCall call, $0.GenerateWalletRequest request);

  $async.Future<$0.ImportMnemonicResponse> importMnemonic_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportMnemonicRequest> $request) async {
    return importMnemonic($call, await $request);
  }

  $async.Future<$0.ImportMnemonicResponse> importMnemonic(
      $grpc.ServiceCall call, $0.ImportMnemonicRequest request);

  $async.Future<$0.ImportPrivateKeyResponse> importPrivateKey_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportPrivateKeyRequest> $request) async {
    return importPrivateKey($call, await $request);
  }

  $async.Future<$0.ImportPrivateKeyResponse> importPrivateKey(
      $grpc.ServiceCall call, $0.ImportPrivateKeyRequest request);

  $async.Future<$0.ImportKeystoreResponse> importKeystore_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportKeystoreRequest> $request) async {
    return importKeystore($call, await $request);
  }

  $async.Future<$0.ImportKeystoreResponse> importKeystore(
      $grpc.ServiceCall call, $0.ImportKeystoreRequest request);

  $async.Future<$0.RevealSecretResponse> revealSecret_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RevealSecretRequest> $request) async {
    return revealSecret($call, await $request);
  }

  $async.Future<$0.RevealSecretResponse> revealSecret(
      $grpc.ServiceCall call, $0.RevealSecretRequest request);

  $async.Future<$0.ExportKeystoreResponse> exportKeystore_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ExportKeystoreRequest> $request) async {
    return exportKeystore($call, await $request);
  }

  $async.Future<$0.ExportKeystoreResponse> exportKeystore(
      $grpc.ServiceCall call, $0.ExportKeystoreRequest request);

  $async.Future<$0.GetWalletResponse> getWallet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetWalletRequest> $request) async {
    return getWallet($call, await $request);
  }

  $async.Future<$0.GetWalletResponse> getWallet(
      $grpc.ServiceCall call, $0.GetWalletRequest request);

  $async.Future<$0.GetBalancesResponse> getBalances_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetBalancesRequest> $request) async {
    return getBalances($call, await $request);
  }

  $async.Future<$0.GetBalancesResponse> getBalances(
      $grpc.ServiceCall call, $0.GetBalancesRequest request);

  $async.Future<$0.GetGasFeesResponse> getGasFees_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetGasFeesRequest> $request) async {
    return getGasFees($call, await $request);
  }

  $async.Future<$0.GetGasFeesResponse> getGasFees(
      $grpc.ServiceCall call, $0.GetGasFeesRequest request);

  $async.Future<$0.SendETHResponse> sendETH_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SendETHRequest> $request) async {
    return sendETH($call, await $request);
  }

  $async.Future<$0.SendETHResponse> sendETH(
      $grpc.ServiceCall call, $0.SendETHRequest request);

  $async.Future<$0.SendTokenResponse> sendToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SendTokenRequest> $request) async {
    return sendToken($call, await $request);
  }

  $async.Future<$0.SendTokenResponse> sendToken(
      $grpc.ServiceCall call, $0.SendTokenRequest request);

  $async.Future<$0.GetHistoryResponse> getHistory_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetHistoryRequest> $request) async {
    return getHistory($call, await $request);
  }

  $async.Future<$0.GetHistoryResponse> getHistory(
      $grpc.ServiceCall call, $0.GetHistoryRequest request);

  $async.Future<$0.QuoteSwapResponse> quoteSwap_Pre($grpc.ServiceCall $call,
      $async.Future<$0.QuoteSwapRequest> $request) async {
    return quoteSwap($call, await $request);
  }

  $async.Future<$0.QuoteSwapResponse> quoteSwap(
      $grpc.ServiceCall call, $0.QuoteSwapRequest request);

  $async.Future<$0.ExecuteSwapResponse> executeSwap_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ExecuteSwapRequest> $request) async {
    return executeSwap($call, await $request);
  }

  $async.Future<$0.ExecuteSwapResponse> executeSwap(
      $grpc.ServiceCall call, $0.ExecuteSwapRequest request);

  $async.Future<$0.CreateContactResponse> createContact_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateContactRequest> $request) async {
    return createContact($call, await $request);
  }

  $async.Future<$0.CreateContactResponse> createContact(
      $grpc.ServiceCall call, $0.CreateContactRequest request);

  $async.Future<$0.GetContactResponse> getContact_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetContactRequest> $request) async {
    return getContact($call, await $request);
  }

  $async.Future<$0.GetContactResponse> getContact(
      $grpc.ServiceCall call, $0.GetContactRequest request);

  $async.Future<$0.UpdateContactResponse> updateContact_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateContactRequest> $request) async {
    return updateContact($call, await $request);
  }

  $async.Future<$0.UpdateContactResponse> updateContact(
      $grpc.ServiceCall call, $0.UpdateContactRequest request);

  $async.Future<$0.DeleteContactResponse> deleteContact_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteContactRequest> $request) async {
    return deleteContact($call, await $request);
  }

  $async.Future<$0.DeleteContactResponse> deleteContact(
      $grpc.ServiceCall call, $0.DeleteContactRequest request);

  $async.Future<$0.ListContactsResponse> listContacts_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListContactsRequest> $request) async {
    return listContacts($call, await $request);
  }

  $async.Future<$0.ListContactsResponse> listContacts(
      $grpc.ServiceCall call, $0.ListContactsRequest request);

  $async.Future<$0.FavoriteContactResponse> favoriteContact_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.FavoriteContactRequest> $request) async {
    return favoriteContact($call, await $request);
  }

  $async.Future<$0.FavoriteContactResponse> favoriteContact(
      $grpc.ServiceCall call, $0.FavoriteContactRequest request);

  $async.Future<$0.AddTokenResponse> addToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddTokenRequest> $request) async {
    return addToken($call, await $request);
  }

  $async.Future<$0.AddTokenResponse> addToken(
      $grpc.ServiceCall call, $0.AddTokenRequest request);

  $async.Future<$0.RemoveTokenResponse> removeToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RemoveTokenRequest> $request) async {
    return removeToken($call, await $request);
  }

  $async.Future<$0.RemoveTokenResponse> removeToken(
      $grpc.ServiceCall call, $0.RemoveTokenRequest request);

  $async.Future<$0.ListTokensResponse> listTokens_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListTokensRequest> $request) async {
    return listTokens($call, await $request);
  }

  $async.Future<$0.ListTokensResponse> listTokens(
      $grpc.ServiceCall call, $0.ListTokensRequest request);

  $async.Future<$0.ListTokensWithBalancesResponse> listTokensWithBalances_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListTokensWithBalancesRequest> $request) async {
    return listTokensWithBalances($call, await $request);
  }

  $async.Future<$0.ListTokensWithBalancesResponse> listTokensWithBalances(
      $grpc.ServiceCall call, $0.ListTokensWithBalancesRequest request);

  $async.Future<$0.PinTokenResponse> pinToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PinTokenRequest> $request) async {
    return pinToken($call, await $request);
  }

  $async.Future<$0.PinTokenResponse> pinToken(
      $grpc.ServiceCall call, $0.PinTokenRequest request);

  $async.Future<$0.HideTokenResponse> hideToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HideTokenRequest> $request) async {
    return hideToken($call, await $request);
  }

  $async.Future<$0.HideTokenResponse> hideToken(
      $grpc.ServiceCall call, $0.HideTokenRequest request);

  $async.Future<$0.ListApprovalsResponse> listApprovals_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListApprovalsRequest> $request) async {
    return listApprovals($call, await $request);
  }

  $async.Future<$0.ListApprovalsResponse> listApprovals(
      $grpc.ServiceCall call, $0.ListApprovalsRequest request);

  $async.Future<$0.RevokeApprovalResponse> revokeApproval_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RevokeApprovalRequest> $request) async {
    return revokeApproval($call, await $request);
  }

  $async.Future<$0.RevokeApprovalResponse> revokeApproval(
      $grpc.ServiceCall call, $0.RevokeApprovalRequest request);

  $async.Future<$0.ResolveENSResponse> resolveENS_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ResolveENSRequest> $request) async {
    return resolveENS($call, await $request);
  }

  $async.Future<$0.ResolveENSResponse> resolveENS(
      $grpc.ServiceCall call, $0.ResolveENSRequest request);

  $async.Future<$0.ReverseENSResponse> reverseENS_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ReverseENSRequest> $request) async {
    return reverseENS($call, await $request);
  }

  $async.Future<$0.ReverseENSResponse> reverseENS(
      $grpc.ServiceCall call, $0.ReverseENSRequest request);

  $async.Future<$0.SpeedUpTxResponse> speedUpTx_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpeedUpTxRequest> $request) async {
    return speedUpTx($call, await $request);
  }

  $async.Future<$0.SpeedUpTxResponse> speedUpTx(
      $grpc.ServiceCall call, $0.SpeedUpTxRequest request);

  $async.Future<$0.CancelTxResponse> cancelTx_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CancelTxRequest> $request) async {
    return cancelTx($call, await $request);
  }

  $async.Future<$0.CancelTxResponse> cancelTx(
      $grpc.ServiceCall call, $0.CancelTxRequest request);

  $async.Future<$0.ListPendingTxsResponse> listPendingTxs_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListPendingTxsRequest> $request) async {
    return listPendingTxs($call, await $request);
  }

  $async.Future<$0.ListPendingTxsResponse> listPendingTxs(
      $grpc.ServiceCall call, $0.ListPendingTxsRequest request);

  $async.Future<$0.SimulateSendResponse> simulateSend_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SimulateSendRequest> $request) async {
    return simulateSend($call, await $request);
  }

  $async.Future<$0.SimulateSendResponse> simulateSend(
      $grpc.ServiceCall call, $0.SimulateSendRequest request);

  $async.Stream<$0.NotificationEnvelope> watchEvents_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.WatchEventsRequest> $request) async* {
    yield* watchEvents($call, await $request);
  }

  $async.Stream<$0.NotificationEnvelope> watchEvents(
      $grpc.ServiceCall call, $0.WatchEventsRequest request);

  $async.Future<$0.ListNotificationsResponse> listNotifications_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListNotificationsRequest> $request) async {
    return listNotifications($call, await $request);
  }

  $async.Future<$0.ListNotificationsResponse> listNotifications(
      $grpc.ServiceCall call, $0.ListNotificationsRequest request);

  $async.Future<$0.MarkNotificationReadResponse> markNotificationRead_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.MarkNotificationReadRequest> $request) async {
    return markNotificationRead($call, await $request);
  }

  $async.Future<$0.MarkNotificationReadResponse> markNotificationRead(
      $grpc.ServiceCall call, $0.MarkNotificationReadRequest request);

  $async.Future<$0.MarkAllNotificationsReadResponse>
      markAllNotificationsRead_Pre($grpc.ServiceCall $call,
          $async.Future<$0.MarkAllNotificationsReadRequest> $request) async {
    return markAllNotificationsRead($call, await $request);
  }

  $async.Future<$0.MarkAllNotificationsReadResponse> markAllNotificationsRead(
      $grpc.ServiceCall call, $0.MarkAllNotificationsReadRequest request);

  $async.Future<$0.ClearNotificationsResponse> clearNotifications_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ClearNotificationsRequest> $request) async {
    return clearNotifications($call, await $request);
  }

  $async.Future<$0.ClearNotificationsResponse> clearNotifications(
      $grpc.ServiceCall call, $0.ClearNotificationsRequest request);

  $async.Future<$0.GetNotificationSettingsResponse> getNotificationSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetNotificationSettingsRequest> $request) async {
    return getNotificationSettings($call, await $request);
  }

  $async.Future<$0.GetNotificationSettingsResponse> getNotificationSettings(
      $grpc.ServiceCall call, $0.GetNotificationSettingsRequest request);

  $async.Future<$0.UpdateNotificationSettingsResponse>
      updateNotificationSettings_Pre($grpc.ServiceCall $call,
          $async.Future<$0.UpdateNotificationSettingsRequest> $request) async {
    return updateNotificationSettings($call, await $request);
  }

  $async.Future<$0.UpdateNotificationSettingsResponse>
      updateNotificationSettings(
          $grpc.ServiceCall call, $0.UpdateNotificationSettingsRequest request);
}
