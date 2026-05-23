import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/tokens.dart';

/// Rich card with a left accent stripe, line-art SVG icon, title, and subtitle.
/// Used by Calculate / Finance / Tools hub screens.
class RichHubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String svgPath;
  final Color accent;
  final VoidCallback onTap;

  const RichHubCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.svgPath,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(Radii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.card),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(Radii.card),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.04),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 12,
                bottom: 12,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      svgPath,
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      title,
                      style: const TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
