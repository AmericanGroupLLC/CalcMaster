import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Raised card surface: a solid fill carrying a faint accent wash, a hairline
/// border, and a real drop shadow.
///
/// Previously this painted white at 6% alpha behind a `BackdropFilter`. Over a
/// near-black background that produced almost no separation — cards read as
/// barely-there rectangles — while a full-screen blur per card is one of the
/// most expensive things Flutter can draw. Solid fill + shadow reads as depth
/// and costs a fraction as much, which matters on low-end devices.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool glowRim;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.accent,
    this.borderRadius = Radii.card,
    this.onTap,
    this.glowRim = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? AppColors.accentPrimary;
    final radius = BorderRadius.circular(borderRadius);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        // A faint accent wash from the top-left, where the icon sits, so each
        // category is recognisable at a glance instead of every card being an
        // identical grey slab.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accentColor.withValues(alpha: 0.10), AppColors.surfaceCard),
            AppColors.surfaceCard,
          ],
          stops: const [0.0, 0.65],
        ),
        borderRadius: radius,
        border: Border.all(
          color: glowRim
              ? accentColor.withValues(alpha: 0.55)
              : AppColors.border,
          width: glowRim ? 1.5 : 1,
        ),
        boxShadow: glowRim
            ? [
                ...AppColors.shadowElevated,
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : AppColors.shadowElevated,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return surface;
    // Material sits *inside* the decoration so the ink ripple is clipped to the
    // rounded corners without a ClipRRect around the shadow (which would clip
    // the shadow itself away).
    return Stack(
      children: [
        surface,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: radius,
              onTap: () {
                HapticFeedback.selectionClick();
                onTap!();
              },
            ),
          ),
        ),
      ],
    );
  }
}
