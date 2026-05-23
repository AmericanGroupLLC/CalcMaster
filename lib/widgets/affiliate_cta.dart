import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../monetization/affiliate_service.dart';
import '../state/region_provider.dart';
import '../theme/tokens.dart';

/// Compact CTA button used inside detail screens to drive affiliate revenue.
/// Tapping logs analytics + opens the partner URL externally.
class AffiliateCta extends StatelessWidget {
  final String slot;
  final String label;
  final IconData icon;
  final Color accent;

  const AffiliateCta({
    super.key,
    required this.slot,
    required this.label,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md),
      child: Material(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.button),
          onTap: () {
            final region = context.read<RegionProvider>().regionId;
            AffiliateService.instance.open(context, slot, region);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.button),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text('Sponsored',
                    style: TextStyle(color: AppColors.textDim, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                Icon(Icons.open_in_new, size: 14, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
