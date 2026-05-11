part of 'address_field.dart';

// ---------------------------------------------------------------------------
// Contact-picker overlay panel
//
// Drops below the address card (anchored via CompositedTransformFollower) so
// the form layout doesn't shift when it opens. The earlier inline-expand
// version stuffed a duplicate input + search bar + list inside the same
// card, which read as two competing fields stacked on top of each other.
// ---------------------------------------------------------------------------

class _ContactPickerPanel extends StatefulWidget {
  const _ContactPickerPanel({
    required this.width,
    required this.searchCtrl,
    required this.searchFocus,
    required this.query,
    required this.onQueryChanged,
    required this.contacts,
    required this.onContactPicked,
    required this.onClose,
  });

  final double width;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final List<Contact> contacts;
  final ValueChanged<Contact> onContactPicked;
  final VoidCallback onClose;

  @override
  State<_ContactPickerPanel> createState() => _ContactPickerPanelState();
}

class _ContactPickerPanelState extends State<_ContactPickerPanel> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.query.isEmpty
        ? widget.contacts
        : widget.contacts.where((c) {
            final q = widget.query.toLowerCase();
            return c.name.toLowerCase().contains(q) || c.address.toLowerCase().contains(q);
          }).toList();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      opacity: _shown ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        scale: _shown ? 1 : 0.96,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Search row ───────────────────────────────────────────
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: context.colors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.searchCtrl,
                        focusNode: widget.searchFocus,
                        style: AppTextStyles.mono.copyWith(
                          color: context.colors.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or address…',
                          hintStyle: AppTextStyles.mono.copyWith(
                            color: context.colors.textDisabled,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                        onChanged: widget.onQueryChanged,
                      ),
                    ),
                    if (widget.query.isNotEmpty)
                      IconBtn(
                        icon: Icons.close_rounded,
                        tooltip: 'Clear',
                        onTap: () {
                          widget.searchCtrl.clear();
                          widget.onQueryChanged('');
                        },
                      ),
                    const SizedBox(width: 6),
                  ],
                ),

                Divider(height: 1, color: context.colors.border),

                // ── Contact list ─────────────────────────────────────────
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          child: Center(
                            child: Text(
                              widget.query.isEmpty
                                  ? 'No contacts yet.'
                                  : 'No results for "${widget.query}".',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: filtered.length,
                          separatorBuilder: (_, i) => Divider(
                            height: 1,
                            color: context.colors.border,
                            indent: 56,
                            endIndent: 14,
                          ),
                          itemBuilder: (_, i) => ContactPickerTile(
                            contact: filtered[i],
                            onTap: () => widget.onContactPicked(filtered[i]),
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
}
