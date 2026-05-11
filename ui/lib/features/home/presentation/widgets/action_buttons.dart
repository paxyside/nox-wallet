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
          subtitle: 'Tokens or ETH',
          onTap: () => context.go(Routes.send),
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.arrow_downward_rounded,
          label: 'Receive',
          subtitle: 'Tokens or ETH',
          onTap: () => _showReceiveDialog(context),
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.swap_horiz_rounded,
          label: 'Swap',
          subtitle: 'Tokens',
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
        child: Padding(
          padding: const EdgeInsets.all(28),
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

              // QR code
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: widget.address,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
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
                            color: _copied ? context.colors.success : context.colors.textSecondary,
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
                          color: _copied ? context.colors.success : context.colors.textSecondary,
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
              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
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
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: active
                      ? [
                          context.colors.primary.withValues(
                            alpha: _pressed ? 0.20 : 0.14,
                          ),
                          context.colors.primary.withValues(
                            alpha: _pressed ? 0.08 : 0.05,
                          ),
                        ]
                      : [
                          context.colors.surface,
                          context.colors.surfaceHigh,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                // Constant width + strokeAlignInside keeps the bounding box
                // identical between idle/hover/pressed — only the border colour
                // changes, so neighbour cards in the Row don't shift.
                border: Border.all(
                  color: active
                      ? context.colors.primary.withValues(
                          alpha: _pressed ? 0.70 : 0.50,
                        )
                      : context.colors.border,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: active && !_pressed
                    ? [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Filled purple circle icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.colors.primaryLight,
                          context.colors.primary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(
                            alpha: _pressed
                                ? 0.20
                                : active
                                ? 0.50
                                : 0.35,
                          ),
                          blurRadius: _pressed
                              ? 6
                              : active
                              ? 16
                              : 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  // Label + subtitle
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
      ),
    );
  }
}
