import 'package:flutter/material.dart';

import '../theme/contrast.dart';
import '../theme/tokens.dart';

/// Small uppercase category badge, e.g. "UNIT CONVERSION".
///
/// [color] is decorative (dot, border, tint). The label is drawn in a
/// contrast-corrected variant of it: at 11px the raw accent could fall below
/// WCAG AA — the brand purple measured 3.76:1 — and callers pass whichever
/// accent their section uses, so the correction belongs here.
class PillBadge extends StatelessWidget {
  final String label;
  final Color color;
  const PillBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final background = Color.alphaBlend(color.withValues(alpha: 0.12), AppColors.bg);
    final labelColor = legibleOn(color, background);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
