part of '../mini_widget.dart';

class _Footer extends StatelessWidget {
  const _Footer({
    required this.onSettings,
    required this.onQuit,
    this.settingsLabel = 'Settings',
    this.settingsIcon = Icons.settings_outlined,
  });

  final VoidCallback onSettings;
  final VoidCallback onQuit;
  final String settingsLabel;
  final IconData settingsIcon;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: col.border)),
      ),
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: _FooterAction(icon: settingsIcon, label: settingsLabel, onTap: onSettings),
          ),
          _FooterDivider(),
          Expanded(
            child: _FooterAction(
              icon: Icons.power_settings_new_rounded,
              label: 'Quit Nox',
              onTap: onQuit,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 12, color: context.colors.border);
  }
}

class _FooterAction extends StatefulWidget {
  const _FooterAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterAction> createState() => _FooterActionState();
}

class _FooterActionState extends State<_FooterAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final color = _hovered ? col.textPrimary : col.textSecondary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 13, color: color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
