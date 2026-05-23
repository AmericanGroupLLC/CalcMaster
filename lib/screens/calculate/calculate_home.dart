import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';
import '../../widgets/pill_badge.dart';
import '../../widgets/rich_hub_card.dart';

class CalculateHome extends StatelessWidget {
  const CalculateHome({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = CategoryAccent.distance;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PillBadge(label: 'Calculators', color: accent),
              const SizedBox(height: Spacing.md),
              Text('Calculate', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              const Text('Standard · Scientific · Percentage · Base · Fraction',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: Spacing.xl),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.25,
                crossAxisSpacing: Spacing.md,
                mainAxisSpacing: Spacing.md,
                children: [
                  RichHubCard(title: 'Standard', subtitle: 'Basic arithmetic', svgPath: 'assets/icons/standard.svg', accent: accent, onTap: () => context.push('/calculate/standard')),
                  RichHubCard(title: 'Scientific', subtitle: 'Trig, log, powers', svgPath: 'assets/icons/scientific.svg', accent: accent, onTap: () => context.push('/calculate/scientific')),
                  RichHubCard(title: 'Percentage', subtitle: '% of, increase, decrease', svgPath: 'assets/icons/percentage.svg', accent: accent, onTap: () => context.push('/calculate/percentage')),
                  RichHubCard(title: 'Base', subtitle: 'Bin / Oct / Dec / Hex', svgPath: 'assets/icons/base.svg', accent: accent, onTap: () => context.push('/calculate/base')),
                  RichHubCard(title: 'Fraction', subtitle: 'Simplify & convert', svgPath: 'assets/icons/fraction.svg', accent: accent, onTap: () => context.push('/calculate/fraction')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
