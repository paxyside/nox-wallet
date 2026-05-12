import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';
import 'package:nox/features/send/presentation/widgets/gas_estimate_card.dart';
import 'package:nox/features/send/presentation/widgets/send_confirm_dialog.dart';
import 'package:nox/features/send/presentation/widgets/send_form.dart';

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({this.initialTokenAddress, super.key});

  /// When non-null, after the on-mount reset the screen looks up a
  /// matching `SendAsset` by contract address and selects it. Drives the
  /// Send quick-action from the Tokens screen so the user lands on a
  /// pre-filled form instead of the default ETH selection.
  final String? initialTokenAddress;

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  /// Captured notifier reference for `dispose()`. Riverpod invalidates
  /// `ref` during the element's `unmount` phase (before our `dispose`
  /// runs in newer riverpod builds), so reading `ref.read(...)` from
  /// dispose throws "Cannot use ref after the widget was disposed". We
  /// cache the notifier the first time `build` runs — by then it's
  /// fully constructed — and use the captured reference for the
  /// post-unmount reset. Same pattern as `didChangeDependencies` would
  /// give us, but works for the very first build too.
  SendNotifier? _notifier;
  bool _wasSending = false;

  @override
  void initState() {
    super.initState();
    // Reset form state on mount so a stale chip / amount from a previous
    // visit doesn't leak. Skip when status==sending — gRPC is mid-flight
    // from a prior mount and AppShell's result dialog still needs the
    // captured amount / selectedAsset to render the success modal.
    //
    // `Future.microtask` is required because Riverpod forbids modifying a
    // provider synchronously from initState/dispose/build (the framework
    // throws "Tried to modify a provider while the widget tree was
    // building"). The microtask runs right after initState completes but
    // before the first paint, so there's no visible flicker.
    unawaited(
      Future.microtask(() async {
        if (!mounted) return;
        final notifier = ref.read(sendNotifierProvider.notifier);
        final status = ref.read(sendNotifierProvider).status;
        if (status != SendStatus.sending) {
          notifier.reset();
        }

        // Apply the deep-link selection AFTER reset so we don't get
        // overwritten back to default. Wait one more microtask so the
        // sendableAssetsProvider has a chance to produce its first value
        // when the screen is mounted from a cold start.
        final wanted = widget.initialTokenAddress;
        if (wanted == null || wanted.isEmpty) return;
        final assets = await ref
            .read(sendableAssetsProvider.future)
            .catchError((_) => <SendAsset>[]);
        if (!mounted) return;
        final match = assets.firstWhere(
          (a) => (a.tokenAddress ?? '').toLowerCase() == wanted.toLowerCase(),
          orElse: () => assets.firstWhere((a) => a.isEth, orElse: () => assets.first),
        );
        notifier.setSelectedAsset(match);
      }),
    );
  }

  @override
  void dispose() {
    // Use the build-cached notifier — ref is already invalidated by
    // ConsumerStatefulElement.unmount at this point. _wasSending is
    // updated on every build so it reflects the most recent status
    // before unmount started.
    final notifier = _notifier;
    super.dispose();
    if (notifier != null && !_wasSending) {
      unawaited(Future.microtask(notifier.reset));
    }
  }

  @override
  Widget build(BuildContext context) {
    final send = ref.watch(sendNotifierProvider);
    _notifier ??= ref.read(sendNotifierProvider.notifier);
    _wasSending = send.status == SendStatus.sending;
    // Result dialog is shown app-shell-wide (see AppShell) so it survives
    // the user navigating off Send mid-broadcast. SendScreen only owns
    // the in-flight form state.

    final canSend = send.isFormValid && !send.isBusy;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Card fills all height — no scroll ─────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Form content — scrollable, scrollbar hidden
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── Header inside card ─────────────────────
                                  Text(
                                    'Send',
                                    style: AppTextStyles.h2.copyWith(
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Transfer ETH or ERC-20 tokens to any address.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Divider(height: 1, color: context.colors.border),
                                  const SizedBox(height: 16),

                                  const SendForm(),

                                  // Gas / time card sits right under the form
                                  // (was pinned at the bottom of the page —
                                  // looked detached on a tall window with
                                  // empty space between).
                                  const SizedBox(height: 12),
                                  const GasEstimateCard(),

                                  // Errors before send (validation /
                                  // estimate failures). Post-send success or
                                  // failure is shown via SendResultDialog.
                                  if (send.errorMessage != null &&
                                      send.status != SendStatus.success &&
                                      send.status != SendStatus.failure) ...[
                                    const SizedBox(height: 10),
                                    _ErrorBanner(send.errorMessage!),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ── Send button pinned at card bottom ───────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(height: 1, color: context.colors.border),
                              const SizedBox(height: 16),

                              SizedBox(
                                height: 50,
                                child: FilledButton(
                                  onPressed: canSend ? () => _confirmAndSend(context, ref) : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: context.colors.primary,
                                    disabledBackgroundColor: context.colors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: send.status == SendStatus.sending
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: context.colors.textPrimary,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.send_rounded,
                                              size: 16,
                                              color: context.colors.textPrimary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Send',
                                              style: AppTextStyles.labelLarge.copyWith(
                                                color: context.colors.textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndSend(BuildContext context, WidgetRef ref) async {
    final send = ref.read(sendNotifierProvider);
    final notifier = ref.read(sendNotifierProvider.notifier);

    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (_) => SendConfirmDialog(
        recipient: send.toAddress,
        amount: send.amount,
        symbol: send.selectedAsset?.symbol ?? 'ETH',
        // tokenAddress empty for native ETH so the simulator hits eth_call
        // on a plain transfer, not an ERC-20 transfer() encoding.
        tokenAddress: (send.selectedAsset?.isEth ?? true)
            ? ''
            : (send.selectedAsset!.tokenAddress ?? ''),
        gasEstimate: send.gasEstimate,
        effectiveMaxFeeGwei: send.effectiveMaxFeeGwei,
      ),
    );

    if (confirmed == true) await notifier.send();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: context.colors.error.withValues(alpha: 0.4)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: context.colors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ),
    ),
  );
}
