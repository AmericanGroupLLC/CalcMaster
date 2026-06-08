import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../lib_units.dart';
import '../theme/tokens.dart';
import '../widgets/convert_card.dart';
import '../widgets/pill_badge.dart';
import '../widgets/region_pill.dart';

class ConvertHome extends StatelessWidget {
  const ConvertHome({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.appTitle, style: Theme.of(context).textTheme.displayLarge),
                        const SizedBox(height: 2),
                        Text(
                          loc.appTagline,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  RegionPill(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const RegionPickerSheet(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.text),
                    tooltip: loc.settingsTitle,
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),
              PillBadge(label: loc.pillUnitConversion, color: AppColors.accentPrimary),
              const SizedBox(height: Spacing.md),
              Text(loc.convertHubHeading,
                  style: const TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(loc.convertHubSubheading,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
              const SizedBox(height: Spacing.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: Spacing.md,
                  mainAxisSpacing: Spacing.md,
                ),
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  return ConvertCard(
                    category: cat,
                    onTap: () => context.push('/convert/${cat.id}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
