import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../lib_currency.dart';
import '../state/region_provider.dart';
import '../theme/tokens.dart';

class RegionPill extends StatelessWidget {
  final VoidCallback? onLongPress;
  const RegionPill({super.key, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    return GestureDetector(
      onTap: () {
        context.read<RegionProvider>().cycleRegion();
      },
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.text),
            const SizedBox(width: 6),
            Text(region.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(region.label,
                style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(width: 4),
            const Text('·', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(width: 4),
            Text(region.symbol,
                style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class RegionPickerSheet extends StatelessWidget {
  const RegionPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<RegionProvider>().regionId;
    return Container(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xxxl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: Spacing.md),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Select region',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: Spacing.md),
          for (final r in regions)
            InkWell(
              borderRadius: BorderRadius.circular(Radii.button),
              onTap: () {
                context.read<RegionProvider>().setRegion(r.id);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: r.id == current ? AppColors.surfaceAlt : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.button),
                ),
                child: Row(
                  children: [
                    Text(r.flag, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.label,
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          Text('${r.currency} · ${r.symbol}',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (r.id == current)
                      const Icon(Icons.check, color: AppColors.success),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
