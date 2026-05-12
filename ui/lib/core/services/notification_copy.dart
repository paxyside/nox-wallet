import 'package:nox/core/utils/format.dart';
import 'package:nox/core/wallet_events/domain/wallet_event.dart';

/// Single source of truth for notification copy — both OS toasts and
/// in-app panel tiles read from here. Pattern: short noun-phrase
/// **header** + one-sentence **description**, no emoji.
///
/// `id` is fed to `local_notifier` to coalesce repeats within the OS.
class NotificationCopy {
  const NotificationCopy({required this.id, required this.title, required this.body});

  final String id;
  final String title;
  final String body;

  /// Resolves the copy for a [WalletEvent].
  ///
  /// We previously suppressed the toast for `tx.isOurs` (self-
  /// initiated swap / send) on the rationale that the in-app result
  /// modal already covered the outcome. In practice users *expect* a
  /// system toast confirming on-chain inclusion — the modal closes
  /// after a few seconds, and the toast is the durable receipt that
  /// shows up in Notification Center too. Suppressing it gave the
  /// wrong impression that "the swap didn't go through". Show it
  /// always; users who don't want any toasts can flip the global
  /// `macOS toasts` switch in the notification center settings.
  static NotificationCopy? forEvent(WalletEvent event) {
    switch (event.kind) {
      case WalletEventKind.transaction:
        final tx = event.transaction;
        if (tx == null) return null;
        return _forTransaction(tx);

      case WalletEventKind.gasAlert:
        final e = event.gasAlert!;
        return NotificationCopy(
          id: e.isSpike ? 'gas_spike' : 'gas_drop',
          title: e.isSpike ? 'Gas spike' : 'Gas drop',
          body: e.description,
        );

      case WalletEventKind.lowBalance:
        final e = event.lowBalance!;
        return NotificationCopy(
          id: 'low_balance',
          title: 'Low ETH balance',
          body: '${e.ethBalance} ETH remaining — top up to cover gas fees',
        );
    }
  }

  /// Same as [forEvent] but never returns null for a `transaction` event
  /// (panel always renders something, even for `isOurs`).
  static NotificationCopy? forEventPanel(WalletEvent event) {
    if (event.kind == WalletEventKind.transaction) {
      final tx = event.transaction;
      if (tx == null) return null;
      return _forTransaction(tx);
    }
    return forEvent(event);
  }

  // Constructor-style helper would lock the public API; static keeps the
  // class free to grow other named factories without a breaking rename.
  // ignore: prefer_constructors_over_static_methods
  static NotificationCopy _forTransaction(TransactionEvent tx) {
    switch (tx.role) {
      case TxRole.sendEth:
      case TxRole.sendToken:
        final out = tx.outgoing.firstOrNull;
        return NotificationCopy(
          id: 'tx_send',
          title: 'Transfer sent',
          body: out == null
              ? tx.shortTxHash
              : 'Sent ${formatAmount(out.amount)} ${out.displaySymbol} to ${_short(out.counterparty)}',
        );

      case TxRole.receiveEth:
      case TxRole.receiveToken:
        final inc = tx.incoming.firstOrNull;
        return NotificationCopy(
          id: 'tx_receive',
          title: 'Transfer received',
          body: inc == null
              ? tx.shortTxHash
              : 'Received ${formatAmount(inc.amount)} ${inc.displaySymbol} from ${_short(inc.counterparty)}',
        );

      case TxRole.swap:
        final out = tx.outgoing.firstOrNull;
        final inc = tx.incoming.firstOrNull;
        if (out == null || inc == null) {
          return NotificationCopy(id: 'tx_swap', title: 'Swap completed', body: tx.shortTxHash);
        }
        return NotificationCopy(
          id: 'tx_swap',
          title: 'Swap completed',
          body:
              'Exchanged ${formatAmount(out.amount)} ${out.displaySymbol} for '
              '${formatAmount(inc.amount)} ${inc.displaySymbol}',
        );

      case TxRole.selfTransfer:
        final out = tx.outgoing.firstOrNull;
        return NotificationCopy(
          id: 'tx_self',
          title: 'Self transfer',
          body: out == null
              ? tx.shortTxHash
              : 'Sent ${formatAmount(out.amount)} ${out.displaySymbol} to your own wallet',
        );

      case TxRole.approve:
        return const NotificationCopy(
          id: 'tx_approve',
          title: 'Allowance updated',
          body: 'Token spending approval changed',
        );

      case TxRole.unknown:
        return NotificationCopy(id: 'tx_unknown', title: 'New transaction', body: tx.shortTxHash);
    }
  }

  static String _short(String hex) {
    if (hex.length <= 12) return hex;
    return '${hex.substring(0, 6)}…${hex.substring(hex.length - 4)}';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
