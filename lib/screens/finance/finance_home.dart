import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/pill_badge.dart';
import '../../widgets/rich_hub_card.dart';

class FinanceHome extends StatelessWidget {
  const FinanceHome({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const accent = CategoryAccent.energy;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillBadge(label: loc.pillFinanceTools, color: accent),
              const SizedBox(height: Spacing.md),
              Text(loc.financeHubHeading, style: Theme.of(context).textTheme.displayLarge),
              // Subheading intentionally omitted: it enumerated the very cards
              // rendered below, so it was pure duplication that also drifted out
              // of sync (Tools listed 8 of 9 tools). The grid is the label.
              const SizedBox(height: Spacing.xl),
              GridView.extent(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 240,
                childAspectRatio: hubCardAspectRatio(context, 1.6),
                crossAxisSpacing: Spacing.md,
                mainAxisSpacing: Spacing.md,
                children: [
                  RichHubCard(title: loc.financeTax, subtitle: 'Sales tax & VAT calculator', svgPath: 'assets/icons/tax.svg', accent: accent, onTap: () => context.push('/finance/tax')),
                  RichHubCard(title: loc.financeTip, subtitle: 'Restaurant bill splitter', svgPath: 'assets/icons/tip.svg', accent: accent, onTap: () => context.push('/finance/tip')),
                  RichHubCard(title: loc.financeDiscount, subtitle: 'Sale price & savings', svgPath: 'assets/icons/discount.svg', accent: accent, onTap: () => context.push('/finance/discount')),
                  RichHubCard(title: loc.financeCompound, subtitle: 'Investment growth', svgPath: 'assets/icons/compound.svg', accent: accent, onTap: () => context.push('/finance/compound')),
                  RichHubCard(title: loc.financeEMI, subtitle: 'Monthly payment calculator', svgPath: 'assets/icons/emi.svg', accent: accent, onTap: () => context.push('/finance/emi')),
                  RichHubCard(title: loc.financeCurrency, subtitle: 'Exchange rate converter', svgPath: 'assets/icons/currency.svg', accent: accent, onTap: () => context.push('/finance/currency')),
                  RichHubCard(title: loc.financeUnitPrice, subtitle: 'Best value comparison', svgPath: 'assets/icons/unit_price.svg', accent: accent, onTap: () => context.push('/finance/unit-price')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
