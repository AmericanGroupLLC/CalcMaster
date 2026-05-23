import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/tokens.dart';
import '../../widgets/pill_badge.dart';
import '../../widgets/rich_hub_card.dart';

class FinanceHome extends StatelessWidget {
  const FinanceHome({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = CategoryAccent.energy;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PillBadge(label: 'Finance Tools', color: accent),
              const SizedBox(height: Spacing.md),
              Text('Finance', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              const Text('Tax · Tip & Split · Discount · Compound Interest · EMI · Currency · Unit Price',
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
                  RichHubCard(title: 'Tax', subtitle: 'Sales tax & VAT calculator', svgPath: 'assets/icons/tax.svg', accent: accent, onTap: () => context.push('/finance/tax')),
                  RichHubCard(title: 'Tip & Split', subtitle: 'Restaurant bill splitter', svgPath: 'assets/icons/tip.svg', accent: accent, onTap: () => context.push('/finance/tip')),
                  RichHubCard(title: 'Discount', subtitle: 'Sale price & savings', svgPath: 'assets/icons/discount.svg', accent: accent, onTap: () => context.push('/finance/discount')),
                  RichHubCard(title: 'Compound Interest', subtitle: 'Investment growth', svgPath: 'assets/icons/compound.svg', accent: accent, onTap: () => context.push('/finance/compound')),
                  RichHubCard(title: 'EMI / Loan', subtitle: 'Monthly payment calculator', svgPath: 'assets/icons/emi.svg', accent: accent, onTap: () => context.push('/finance/emi')),
                  RichHubCard(title: 'Currency', subtitle: 'Exchange rate converter', svgPath: 'assets/icons/currency.svg', accent: accent, onTap: () => context.push('/finance/currency')),
                  RichHubCard(title: 'Unit Price', subtitle: 'Best value comparison', svgPath: 'assets/icons/unit_price.svg', accent: accent, onTap: () => context.push('/finance/unit-price')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
