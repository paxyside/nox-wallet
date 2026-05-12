import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:nox/features/home/presentation/providers/home_provider.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';
import 'package:nox/features/send/presentation/widgets/_form_atoms.dart';
import 'package:nox/features/send/presentation/widgets/add_to_contacts_chip.dart';
import 'package:nox/features/send/presentation/widgets/address_field.dart';
import 'package:nox/features/send/presentation/widgets/amount_card.dart';

class SendForm extends ConsumerStatefulWidget {
  const SendForm({super.key});

  @override
  ConsumerState<SendForm> createState() => _SendFormState();
}

class _SendFormState extends ConsumerState<SendForm> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _amountCtrl;
  @override
  void initState() {
    super.initState();
    // SendScreen.dispose resets the notifier on unmount, so the state is
    // empty whenever this form mounts — controllers can come up blank.
    _addressCtrl = TextEditingController();
    _amountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _setAmountFromFraction(double fraction, SendState send, SendNotifier notifier) {
    final balance = double.tryParse(send.selectedAsset?.balance ?? '0') ?? 0;
    if (balance == 0) return;
    final raw = balance * fraction;
    final formatted = _fmtAmount(raw);
    _amountCtrl.text = formatted;
    _amountCtrl.selection = TextSelection.collapsed(offset: formatted.length);
    notifier.setAmount(formatted);
  }

  static String _fmtAmount(double v) {
    if (v == 0) return '';
    return v.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final send = ref.watch(sendNotifierProvider);
    final notifier = ref.read(sendNotifierProvider.notifier);
    final assets = ref.watch(sendableAssetsProvider);
    final locked = send.isBusy;

    // Sync external resets and MAX presses
    ref.listen(sendNotifierProvider, (prev, next) {
      if (prev?.status != SendStatus.idle &&
          next.status == SendStatus.idle &&
          next.toAddress.isEmpty) {
        _addressCtrl.clear();
        _amountCtrl.clear();
      }
      if (next.amount != _amountCtrl.text) {
        _amountCtrl.text = next.amount;
        _amountCtrl.selection = TextSelection.collapsed(offset: _amountCtrl.text.length);
      }
    });

    final assetList = assets.valueOrNull ?? <SendAsset>[];
    final selectedAsset = send.selectedAsset ?? assetList.firstOrNull;

    // Initialise available assets list on first data
    if (send.availableAssets.isEmpty && assetList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.setAvailableAssets(assetList));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── To Address ───────────────────────────────────────────────────────
        // Inline "TO" tag now lives inside AddressField — no external label.
        Builder(
          builder: (context) {
            final contacts = ref.watch(contactsNotifierProvider).valueOrNull ?? [];
            // Own wallet address — used to warn on self-send (sending to
            // yourself is legal but almost always a mistake; the chain
            // happily accepts it and burns gas for no movement).
            final ownAddress = ref.watch(homeDataProvider).valueOrNull?.walletInfo.address ?? '';
            final isSelfSend =
                send.toAddress.isNotEmpty &&
                send.toAddress.toLowerCase() == ownAddress.toLowerCase();
            final alreadySaved =
                send.toAddress.isNotEmpty &&
                contacts.any((c) => c.address.toLowerCase() == send.toAddress.toLowerCase());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AddressField(
                  controller: _addressCtrl,
                  locked: locked,
                  errorText: send.toAddressError,
                  contacts: contacts,
                  onChanged: notifier.setToAddress,
                  onContactSelected: (c) {
                    _addressCtrl.text = c.address;
                    notifier.setToAddress(c.address);
                  },
                ),
                if (isSelfSend) ...[
                  const SizedBox(height: 8),
                  const _SelfSendWarning(),
                ] else if (send.toAddress.isNotEmpty &&
                    send.toAddressError == null &&
                    !alreadySaved) ...[
                  const SizedBox(height: 8),
                  AddToContactsChip(address: send.toAddress),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 8),

        // ── Amount — token pill embedded on the right side of the card. ──
        assets.when(
          loading: () => AmountCardShell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
                ),
              ),
            ),
          ),
          error: (e, _) => AmountCardShell(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to load assets',
                style: AppTextStyles.bodySmall.copyWith(color: context.colors.error),
              ),
            ),
          ),
          data: (_) => AmountCard(
            controller: _amountCtrl,
            locked: locked,
            assets: assetList,
            selectedAsset: selectedAsset,
            hasError: send.amountError != null,
            onAssetChanged: notifier.setSelectedAsset,
            onAmountChanged: notifier.setAmount,
            onMaxPressed: locked ? null : notifier.setMaxAmount,
            onFraction: locked ? null : (v) => _setAmountFromFraction(v, send, notifier),
          ),
        ),
        if (send.amountError != null) ...[const SizedBox(height: 4), ErrorText(send.amountError!)],
      ],
    );
  }
}

// ── Self-send warning chip ──────────────────────────────────────────────────

/// Shown when the recipient address equals the loaded wallet's own
/// address. Soft-blocking: the user can still send (sometimes legitimate
/// for sweep / consolidation flows) but the visible warning makes the
/// choice deliberate.
class _SelfSendWarning extends StatelessWidget {
  const _SelfSendWarning();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: colors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "That's your own wallet. The transfer will succeed but burn "
              'gas for no movement.',
              style: AppTextStyles.bodySmall.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
