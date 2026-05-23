import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';
import '../../widgets/pill_badge.dart';
import '../../widgets/rich_hub_card.dart';

class ToolsHome extends StatelessWidget {
  const ToolsHome({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = CategoryAccent.pressure;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PillBadge(label: 'Utility Tools', color: accent),
              const SizedBox(height: Spacing.md),
              Text('Tools', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              const Text('GPS · Ohm\'s Law · BMI · Date Diff · Time Zones · ADC/DAC · Age · Aspect Ratio',
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
                  RichHubCard(title: 'GPS Coordinates', subtitle: 'Decimal ↔ DMS conversion', svgPath: 'assets/icons/gps.svg', accent: accent, onTap: () => context.push('/tools/gps')),
                  RichHubCard(title: 'Ohm\'s Law', subtitle: 'V, I, R, P calculator', svgPath: 'assets/icons/ohm.svg', accent: accent, onTap: () => context.push('/tools/ohm')),
                  RichHubCard(title: 'BMI', subtitle: 'Body Mass Index', svgPath: 'assets/icons/bmi.svg', accent: accent, onTap: () => context.push('/tools/bmi')),
                  RichHubCard(title: 'Date Difference', subtitle: 'Days between dates', svgPath: 'assets/icons/date_diff.svg', accent: accent, onTap: () => context.push('/tools/date-diff')),
                  RichHubCard(title: 'Time Zones', subtitle: 'World time converter', svgPath: 'assets/icons/time_zones.svg', accent: accent, onTap: () => context.push('/tools/time-zones')),
                  RichHubCard(title: 'ADC / DAC', subtitle: 'Analog ↔ Digital conversion', svgPath: 'assets/icons/adc_dac.svg', accent: accent, onTap: () => context.push('/tools/adc-dac')),
                  RichHubCard(title: 'Age', subtitle: 'Exact age calculator', svgPath: 'assets/icons/age.svg', accent: accent, onTap: () => context.push('/tools/age')),
                  RichHubCard(title: 'Aspect Ratio', subtitle: 'Screen & image ratios', svgPath: 'assets/icons/aspect_ratio.svg', accent: accent, onTap: () => context.push('/tools/aspect-ratio')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
