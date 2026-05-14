import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({required this.address, super.key});

  final String address;

  void _showReceiveDialog(BuildContext context) {
    unawaited(
      showAppDialog<void>(
        context: context,
        builder: (ctx) => _ReceiveDialog(address: address),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.arrow_upward_rounded,
          label: 'Send',
          subtitle: 'To any address',
          onTap: () => context.go(Routes.send),
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.arrow_downward_rounded,
          label: 'Receive',
          subtitle: 'Show QR code',
          onTap: () => _showReceiveDialog(context),
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.swap_horiz_rounded,
          label: 'Swap',
          subtitle: 'ETH ⇄ tokens',
          onTap: () => context.go(Routes.swap),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Receive dialog — QR code + copyable address
// ---------------------------------------------------------------------------

class _ReceiveDialog extends StatefulWidget {
  const _ReceiveDialog({required this.address});
  final String address;

  @override
  State<_ReceiveDialog> createState() => _ReceiveDialogState();
}

class _ReceiveDialogState extends State<_ReceiveDialog> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.address));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.colors.border),
      ),
      child: SizedBox(
        width: 360,
        // Stack so the corner close icon floats above the content instead
        // of eating a full row at the bottom — matches the AppAboutDialog
        // pattern across the app.
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Receive',
                    style: AppTextStyles.h2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan or copy your Ethereum address',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR code with Nox logo "punched through" the centre.
                  // - errorCorrectionLevel.H tolerates ~30% data loss
                  //   so the rounded white tile covering a centre chunk
                  //   doesn't break readability.
                  // - Manual Stack instead of qr_flutter's embeddedImage
                  //   so we can wrap the logo in a rounded white tile
                  //   with padding — embedded by the library renders
                  //   the image flat on top of QR modules, which read
                  //   as "logo slapped on" rather than "negative space
                  //   carved out". Stack lets us draw the tile cleanly.
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        QrImageView(
                          data: widget.address,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Image.asset(
                            'assets/images/nox_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address + copy button
                  GestureDetector(
                    onTap: _copy,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _copied
                            ? context.colors.success.withValues(alpha: 0.1)
                            : context.colors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _copied ? context.colors.success : context.colors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.address,
                              style: AppTextStyles.monoSmall.copyWith(
                                color: _copied
                                    ? context.colors.success
                                    : context.colors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _copied ? Icons.check_rounded : Icons.copy_rounded,
                              key: ValueKey(_copied),
                              size: 16,
                              color: _copied
                                  ? context.colors.success
                                  : context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _copied ? 'Copied!' : 'Tap to copy',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _copied ? context.colors.success : context.colors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),

            // Corner close button — same affordance as AppAboutDialog
            // (Settings / Add Token / etc.) so dismiss is consistent
            // across every modal in the app.
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: context.colors.textSecondary,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button tile — horizontal layout with hover state
// ---------------------------------------------------------------------------

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: active ? context.colors.surfaceHigh : context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active
                    ? context.colors.primary.withValues(alpha: 0.40)
                    : context.colors.border,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Row(
              children: [
                // Static neutral icon tile — does NOT react to hover.
                // Card-level hover is the single signal; animating the
                // tile too produced a double-layer effect on the eye.
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.colors.textSecondary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: context.colors.textSecondary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
