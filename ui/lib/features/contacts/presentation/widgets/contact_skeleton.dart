import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nox/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton card (shown during loading)
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    unawaited(_ctrl.repeat(reverse: true));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final color = Color.lerp(context.colors.surfaceHigh, context.colors.border, _anim.value)!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(width: 12),

              // Name + address placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 13,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 220,
                      height: 11,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons placeholder
              Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
