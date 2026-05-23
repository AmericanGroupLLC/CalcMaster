import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Frosted-glass surface with translucent fill, 1 dp inner border, and an
/// optional accent rim glow. Replaces solid `AppColors.surface` cards across
/// the app for the futuristic AI look.
///
/// On web we skip the BackdropFilter (CanvasKit blur is expensive) and fall
/// back to a slightly more opaque translucent fill that approximates the look.
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
    final fillAlpha = kIsWeb ? 0.12 : 0.06;
    final inner = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: fillAlpha),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowRim
              ? accentColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: glowRim ? 1.5 : 1,
        ),
        boxShadow: glowRim
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: child,
    );

    final blurred = kIsWeb
        ? inner
        : ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: inner,
            ),
          );

    if (onTap == null) return blurred;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: blurred,
      ),
    );
  }
}
