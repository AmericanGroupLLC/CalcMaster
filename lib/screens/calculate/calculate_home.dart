import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/pill_badge.dart';
import '../../widgets/rich_hub_card.dart';

class CalculateHome extends StatelessWidget {
  const CalculateHome({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const accent = CategoryAccent.distance;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillBadge(label: loc.pillCalculators, color: accent),
              const SizedBox(height: Spacing.md),
              Text(loc.calculateHubHeading, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              Text(loc.calculateHubSubheading,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: Spacing.xl),
              GridView.extent(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 240,
                childAspectRatio: 1.6,
                crossAxisSpacing: Spacing.md,
                mainAxisSpacing: Spacing.md,
                children: [
                  RichHubCard(title: loc.calcStandard, subtitle: 'Basic arithmetic', svgPath: 'assets/icons/standard.svg', accent: accent, onTap: () => context.push('/calculate/standard')),
                  RichHubCard(title: loc.calcScientific, subtitle: 'Trig, log, powers', svgPath: 'assets/icons/scientific.svg', accent: accent, onTap: () => context.push('/calculate/scientific')),
                  RichHubCard(title: loc.calcPercentage, subtitle: '% of, increase, decrease', svgPath: 'assets/icons/percentage.svg', accent: accent, onTap: () => context.push('/calculate/percentage')),
                  RichHubCard(title: loc.calcBase, subtitle: 'Bin / Oct / Dec / Hex', svgPath: 'assets/icons/base.svg', accent: accent, onTap: () => context.push('/calculate/base')),
                  RichHubCard(title: loc.calcFraction, subtitle: 'Simplify & convert', svgPath: 'assets/icons/fraction.svg', accent: accent, onTap: () => context.push('/calculate/fraction')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
