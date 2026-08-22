import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/tokens.dart';
import 'glass_card.dart';

/// Rich card with a left accent stripe + tinted icon square + title + subtitle.
/// Wrapped in GlassCard for the futuristic frosted look.
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
    return GlassCard(
      accent: accent,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.md),
      glowRim: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The accent stripe used to be Positioned at left:-10 — outside the
          // card's clip, so it never rendered. It is now a real element in the
          // layout, which is also what makes each category readable at a glance.
          Container(
            width: 3,
            height: 40,
            margin: const EdgeInsets.only(right: Spacing.md, top: 2),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.55),
                  blurRadius: 8,
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(Radii.cardThumb - 6),
                    border: Border.all(color: accent.withValues(alpha: 0.55)),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      svgPath,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
