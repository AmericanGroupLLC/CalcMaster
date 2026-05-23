import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../lib_units.dart';
import '../theme/tokens.dart';

class ConvertCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  const ConvertCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = category.accent;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(Radii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 64,
                child: Stack(
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        category.svg,
                        width: 44,
                        height: 44,
                        colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      left: 2,
                      child: Text(
                        category.hint.primary,
                        style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Text(
                        category.hint.secondary,
                        style: TextStyle(color: accent.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (category.hint.tertiary != null)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Text(
                          category.hint.tertiary!,
                          style: TextStyle(color: accent.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                category.label,
                style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                category.subtitle,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
