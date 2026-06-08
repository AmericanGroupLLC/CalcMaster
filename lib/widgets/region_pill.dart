import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../lib_currency.dart';
import '../state/region_provider.dart';
import '../theme/tokens.dart';

class RegionPill extends StatelessWidget {
  /// Opens the region/currency picker. Wired to a plain tap so it's
  /// discoverable (tap used to silently cycle regions, which was confusing).
  final VoidCallback? onTap;
  const RegionPill({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    return GestureDetector(
      onTap: onTap,
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
    final loc = AppLocalizations.of(context)!;
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
          Text(loc.regionPickerTitle,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: Spacing.md),
          const _DetectLocationButton(),
          const SizedBox(height: Spacing.sm),
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

/// "Detect my location" action inside the picker — uses GPS to set the
/// region/currency, with an inline spinner and result feedback.
class _DetectLocationButton extends StatelessWidget {
  const _DetectLocationButton();

  @override
  Widget build(BuildContext context) {
    final detecting = context.watch<RegionProvider>().detecting;
    return Material(
      color: AppColors.accentPrimary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(Radii.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.button),
        onTap: detecting
            ? null
            : () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final result = await context
                    .read<RegionProvider>()
                    .detectRegionFromLocation();
                if (result == DetectResult.success) {
                  navigator.pop();
                }
                messenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1600),
                  content: Text(switch (result) {
                    DetectResult.success => 'Region set from your location',
                    DetectResult.permissionDenied =>
                      'Location permission denied — pick a region below',
                    DetectResult.noMatch =>
                      'No matching region for your location — pick one below',
                    DetectResult.unavailable =>
                      "Couldn't detect location — pick a region below",
                  }),
                ));
              },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md, vertical: Spacing.md),
          decoration: BoxDecoration(
            border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(Radii.button),
          ),
          child: Row(
            children: [
              if (detecting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accentPrimary),
                )
              else
                const Icon(Icons.my_location,
                    size: 18, color: AppColors.accentPrimary),
              const SizedBox(width: Spacing.md),
              Text(
                detecting ? 'Detecting…' : 'Detect my location',
                style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
