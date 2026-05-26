import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../lib_currency.dart';
import '../../lib_format.dart';
import '../../lib_tax.dart';
import '../../state/region_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/chip_picker.dart';
import '../../widgets/inner_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_row.dart';

// =================== TAX ===================

class TaxCalc extends StatefulWidget {
  const TaxCalc({super.key});
  @override
  State<TaxCalc> createState() => _TaxCalcState();
}

class _TaxCalcState extends State<TaxCalc> {
  String mode = 'income';
  final income = TextEditingController();
  final stateRate = TextEditingController(text: '0');
  final salePrice = TextEditingController();
  late TextEditingController salesRate;
  FilingStatus filing = FilingStatus.single;

  @override
  void initState() {
    super.initState();
    final region = context.read<RegionProvider>().region.id;
    salesRate = TextEditingController(text: ((salesTaxRate[region] ?? 0) * 100).toStringAsFixed(1));
    for (final c in [income, stateRate, salePrice, salesRate]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [income, stateRate, salePrice, salesRate]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    String cur(double n) => formatCurrency(n, region.locale, region.currency);

    final result = computeIncomeTax(
      safeNumber(income.text),
      region.id,
      filing,
      stateLocalRate: (safeNumber(stateRate.text) / 100).clamp(0, 0.15),
    );
    final p = safeNumber(salePrice.text);
    final r = safeNumber(salesRate.text) / 100;
    final salesTax = p * r;
    final salesTotal = p + salesTax;

    return InnerScaffold(
      title: AppLocalizations.of(context)!.financeTax,
      subtitle: '${region.flag} ${region.label} · ${region.currency}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _ModePill(label: 'Income', active: mode == 'income', onTap: () => setState(() => mode = 'income'))),
          const SizedBox(width: Spacing.sm),
          Expanded(child: _ModePill(label: 'Sales / VAT', active: mode == 'sales', onTap: () => setState(() => mode = 'sales'))),
        ]),
        if (mode == 'income') ...[
          NumberInput(label: 'Annual gross (${region.currency})', controller: income),
          const SizedBox(height: Spacing.md),
          const Text('Filing status', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: Spacing.sm),
          ChipPicker<FilingStatus>(
            options: const [
              (id: FilingStatus.single, label: 'Single'),
              (id: FilingStatus.joint, label: 'Joint'),
              (id: FilingStatus.head, label: 'Head'),
            ],
            value: filing,
            onChange: (v) => setState(() => filing = v),
          ),
          NumberInput(label: 'State / local rate (%)', controller: stateRate),
          const SizedBox(height: Spacing.lg),
          ResultRow(label: 'Taxable income', value: cur(result.taxableIncome)),
          ResultRow(label: 'Tax owed', value: cur(result.taxOwed), highlight: true),
          ResultRow(label: 'Effective rate', value: formatPercent(result.effectiveRate)),
          ResultRow(label: 'Marginal rate', value: formatPercent(result.marginalRate)),
          ResultRow(label: 'Take-home (year)', value: cur(result.takeHome), highlight: true),
          ResultRow(label: 'Take-home (month)', value: cur(result.takeHomeMonthly)),
        ] else ...[
          NumberInput(label: 'Sale price (${region.currency})', controller: salePrice),
          NumberInput(label: 'Tax rate (%)', controller: salesRate),
          const SizedBox(height: Spacing.lg),
          ResultRow(label: 'Tax amount', value: cur(salesTax)),
          ResultRow(label: 'Total with tax', value: cur(salesTotal), highlight: true),
        ],
      ]),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModePill({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.text : AppColors.surface,
      borderRadius: BorderRadius.circular(Radii.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.button),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: active ? AppColors.text : AppColors.border), borderRadius: BorderRadius.circular(Radii.button)),
          child: Text(label, style: TextStyle(color: active ? AppColors.bg : AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// =================== TIP ===================

class TipCalc extends StatefulWidget {
  const TipCalc({super.key});
  @override
  State<TipCalc> createState() => _TipCalcState();
}

class _TipCalcState extends State<TipCalc> {
  final bill = TextEditingController();
  final tipPct = TextEditingController(text: '18');
  final people = TextEditingController(text: '2');
  @override
  void initState() {
    super.initState();
    for (final c in [bill, tipPct, people]) {
      c.addListener(() => setState(() {}));
    }
  }
  @override
  void dispose() { for (final c in [bill, tipPct, people]) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    String cur(double n) => formatCurrency(n, region.locale, region.currency);
    final b = safeNumber(bill.text);
    final t = safeNumber(tipPct.text) / 100;
    final p = safeNumber(people.text).toInt().clamp(1, 1000000);
    final tip = b * t;
    final total = b + tip;
    return InnerScaffold(
      title: AppLocalizations.of(context)!.financeTip,
      subtitle: '${region.flag} ${region.currency}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Bill (${region.currency})', controller: bill),
        NumberInput(label: 'Tip %', controller: tipPct),
        NumberInput(label: 'People', controller: people, keyboardType: TextInputType.number),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Tip', value: cur(tip)),
        ResultRow(label: 'Total', value: cur(total), highlight: true),
        ResultRow(label: 'Per person', value: cur(total / p), highlight: true),
        ResultRow(label: 'Tip per person', value: cur(tip / p)),
      ]),
    );
  }
}

// =================== DISCOUNT ===================

class DiscountCalc extends StatefulWidget {
  const DiscountCalc({super.key});
  @override
  State<DiscountCalc> createState() => _DiscountCalcState();
}
class _DiscountCalcState extends State<DiscountCalc> {
  final original = TextEditingController();
  final pct = TextEditingController();
  @override void initState() { super.initState(); for (final c in [original, pct]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [original, pct]) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    String cur(double n) => formatCurrency(n, region.locale, region.currency);
    final o = safeNumber(original.text);
    final p = safeNumber(pct.text) / 100;
    final savings = o * p;
    final fin = o - savings;
    return InnerScaffold(
      title: AppLocalizations.of(context)!.financeDiscount,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Original (${region.currency})', controller: original),
        NumberInput(label: 'Discount %', controller: pct),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'You save', value: cur(savings)),
        ResultRow(label: 'Final price', value: cur(fin), highlight: true),
      ]),
    );
  }
}

// =================== COMPOUND ===================

class CompoundCalc extends StatefulWidget {
  const CompoundCalc({super.key});
  @override
  State<CompoundCalc> createState() => _CompoundCalcState();
}
class _CompoundCalcState extends State<CompoundCalc> {
  final principal = TextEditingController();
  final ratePct = TextEditingController(text: '7');
  final years = TextEditingController(text: '10');
  final pmt = TextEditingController();
  String freq = '12';
  @override void initState() { super.initState(); for (final c in [principal, ratePct, years, pmt]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [principal, ratePct, years, pmt]) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    String cur(double n) => formatCurrency(n, region.locale, region.currency);
    final P = safeNumber(principal.text);
    final r = safeNumber(ratePct.text) / 100;
    final t = safeNumber(years.text);
    final n = double.parse(freq);
    final PMT = safeNumber(pmt.text);
    double future = P;
    if (n > 0 && t > 0 && r >= 0) {
      final factor = math.pow(1 + r / n, n * t).toDouble();
      future = P * factor + (PMT > 0 && r > 0 ? PMT * ((factor - 1) / (r / n)) : PMT * n * t);
    }
    final contributed = P + PMT * n * t;
    final interest = future - contributed;
    return InnerScaffold(
      title: AppLocalizations.of(context)!.financeCompound,
      subtitle: 'Future value of an investment',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Principal (${region.currency})', controller: principal),
        NumberInput(label: 'Annual rate (%)', controller: ratePct),
        NumberInput(label: 'Years', controller: years),
        NumberInput(label: 'Monthly contribution (optional, ${region.currency})', controller: pmt),
        const SizedBox(height: Spacing.md),
        const Text('Compounding frequency', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: Spacing.sm),
        ChipPicker<String>(
          options: const [(id: '1', label: 'Annually'), (id: '4', label: 'Quarterly'), (id: '12', label: 'Monthly'), (id: '365', label: 'Daily')],
          value: freq,
          onChange: (v) => setState(() => freq = v),
        ),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Future value', value: cur(future), highlight: true),
        ResultRow(label: 'Total contributed', value: cur(contributed)),
        ResultRow(label: 'Interest earned', value: cur(interest)),
      ]),
    );
  }
}

// =================== EMI ===================

class EmiCalc extends StatefulWidget {
  const EmiCalc({super.key});
  @override
  State<EmiCalc> createState() => _EmiCalcState();
}
class _EmiCalcState extends State<EmiCalc> {
  final principal = TextEditingController();
  final ratePct = TextEditingController();
  final years = TextEditingController();
  @override void initState() { super.initState(); for (final c in [principal, ratePct, years]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [principal, ratePct, years]) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    String cur(double n) => formatCurrency(n, region.locale, region.currency);
    final P = safeNumber(principal.text);
    final r = safeNumber(ratePct.text) / 100 / 12;
    final n = safeNumber(years.text) * 12;
    double emi = 0, totalInterest = 0, totalPayable = 0;
    if (P > 0 && n > 0 && r >= 0) {
      if (r == 0) {
        emi = P / n;
        totalPayable = P;
      } else {
        final factor = math.pow(1 + r, n).toDouble();
        emi = (P * r * factor) / (factor - 1);
        totalPayable = emi * n;
        totalInterest = totalPayable - P;
      }
    }
    return InnerScaffold(
      title: AppLocalizations.of(context)!.financeEMI,
      subtitle: 'Equated monthly installment',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Loan amount (${region.currency})', controller: principal),
        NumberInput(label: 'Annual rate (%)', controller: ratePct),
        NumberInput(label: 'Term (years)', controller: years),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Monthly EMI', value: cur(emi), highlight: true),
        ResultRow(label: 'Total interest', value: cur(totalInterest)),
        ResultRow(label: 'Total payable', value: cur(totalPayable)),
      ]),
    );
  }
}

// =================== CURRENCY ===================

class CurrencyCalc extends StatefulWidget {
  const CurrencyCalc({super.key});
  @override
  State<CurrencyCalc> createState() => _CurrencyCalcState();
}
class _CurrencyCalcState extends State<CurrencyCalc> {
  final amount = TextEditingController(text: '1');
  String? from;
  @override void initState() { super.initState(); amount.addListener(() => setState(() {})); }
  @override void dispose() { amount.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final regionState = context.watch<RegionProvider>();
    from ??= regionState.region.currency;
    final rates = regionState.rates;
    final allCodes = <String>{
      ...regions.map((r) => r.currency),
      'USD','EUR','GBP','JPY','CAD','AUD','INR','CHF','CNY','MXN','BRL','KRW','SGD','HKD','NZD','ZAR','SEK','NOK','DKK',
      ...rates.keys,
    }.toList();
    final num = safeNumber(amount.text);
    return InnerScaffold(
      title: AppLocalizations.of(context)!.financeCurrency,
      subtitle: regionState.ratesLive ? 'Live rates' : 'Offline rates',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textMuted),
          onPressed: () => context.read<RegionProvider>().refreshRates(),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Amount', controller: amount),
        const SizedBox(height: Spacing.md),
        const Text('From', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: Spacing.sm),
        ChipPicker<String>(
          options: [for (final c in allCodes) (id: c, label: c)],
          value: from!,
          onChange: (v) => setState(() => from = v),
        ),
        const SizedBox(height: Spacing.lg),
        for (final code in allCodes.where((c) => c != from).take(18))
          ResultRow(
            label: code,
            value: () {
              final v = convertCurrency(num, from!, code, rates);
              return v.isFinite ? formatNumber(v) : '—';
            }(),
            highlight: code == regionState.region.currency,
          ),
      ]),
    );
  }
}

// =================== UNIT PRICE ===================

class UnitPriceCalc extends StatefulWidget {
  const UnitPriceCalc({super.key});
  @override
  State<UnitPriceCalc> createState() => _UnitPriceCalcState();
}
class _UnitPriceCalcState extends State<UnitPriceCalc> {
  final pa = TextEditingController();
  final qa = TextEditingController();
  final pb = TextEditingController();
  final qb = TextEditingController();
  @override void initState() { super.initState(); for (final c in [pa, qa, pb, qb]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [pa, qa, pb, qb]) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final region = context.watch<RegionProvider>().region;
    String cur(double n) => formatCurrency(n, region.locale, region.currency);
    final upA = safeNumber(qa.text) > 0 ? safeNumber(pa.text) / safeNumber(qa.text) : double.nan;
    final upB = safeNumber(qb.text) > 0 ? safeNumber(pb.text) / safeNumber(qb.text) : double.nan;
    String? cheaper;
    if (upA.isFinite && upB.isFinite) cheaper = upA < upB ? 'A' : (upB < upA ? 'B' : null);
    Widget card(String name, TextEditingController p, TextEditingController q, double up, bool win) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: win ? AppColors.success.withValues(alpha: 0.5) : AppColors.border),
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Option $name', style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
            NumberInput(label: 'Price (${region.currency})', controller: p),
            NumberInput(label: 'Quantity', controller: q),
            const SizedBox(height: Spacing.sm),
            const Text('Per unit', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            Text(up.isFinite ? cur(up) : '—', style: TextStyle(color: win ? AppColors.success : AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
    }
    return InnerScaffold(
      title: AppLocalizations.of(context)!.financeUnitPrice,
      subtitle: 'Which pack is cheaper?',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          card('A', pa, qa, upA, cheaper == 'A'),
          const SizedBox(width: Spacing.md),
          card('B', pb, qb, upB, cheaper == 'B'),
        ]),
        if (cheaper != null)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.lg),
            child: Center(
              child: Text('Option $cheaper is cheaper per unit.', style: const TextStyle(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
      ]),
    );
  }
}
