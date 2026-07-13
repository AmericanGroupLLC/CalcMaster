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
      child: Stack(
        children: [
          // Left accent stripe with rim glow
          Positioned(
            left: -Spacing.md + 2,
            top: 4,
            bottom: 4,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: -1,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgPath,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
