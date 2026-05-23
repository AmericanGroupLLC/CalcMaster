import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../i18n_helpers.dart';
import '../lib_units.dart';
import '../theme/tokens.dart';
import 'glass_card.dart';

class ConvertCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  const ConvertCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = category.accent;
    return GlassCard(
      accent: accent,
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    category.svg,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                [
                  category.hint.primary,
                  category.hint.secondary,
                  if (category.hint.tertiary != null) category.hint.tertiary!,
                ].join(' · '),
                style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            localizedCategoryLabel(context, category.id),
            style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            category.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
