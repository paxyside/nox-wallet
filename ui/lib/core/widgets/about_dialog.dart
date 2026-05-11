import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// About dialog
// ---------------------------------------------------------------------------

class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final col = context.colors;

    return Dialog(
      backgroundColor: col.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: col.border),
      ),
      child: SizedBox(
        width: 380,
        child: Stack(
          children: [
            // ── Content ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/nox_logo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    'Nox Wallet',
                    style: AppTextStyles.h2.copyWith(color: col.textPrimary),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'Self-custody Ethereum wallet for macOS.\nYour keys, your coins — stored locally, never shared.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: col.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(color: col.border),
                  const SizedBox(height: 16),

                  // Info rows
                  const _InfoRow(label: 'Version', value: '1.0.0'),
                  const SizedBox(height: 10),
                  const _InfoRow(label: 'Network', value: 'Ethereum Mainnet'),
                  const SizedBox(height: 10),
                  const _InfoRow(
                    label: 'Backend',
                    value: 'gRPC · 127.0.0.1:50055',
                  ),
                  const SizedBox(height: 10),
                  const _InfoRow(
                    label: 'Protocol',
                    value: 'Protocol Buffers v3',
                  ),
                ],
              ),
            ),

            // ── Close button ─────────────────────────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered ? context.colors.surfaceHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: _hovered ? context.colors.textSecondary : context.colors.textDisabled,
          ),
        ),
      ),
    );
  }
}
