import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../monetization/analytics_service.dart';
import '../monetization/monetization_config.dart';
import '../monetization/premium_provider.dart';
import '../theme/tokens.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  SubscriptionTier _selected = SubscriptionTier.annual;
  bool _busy = false;

  Future<void> _purchase() async {
    setState(() => _busy = true);
    final ok = await context.read<PremiumProvider>().purchase(_selected);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MonetizationConfig.subscriptionsEnabled
              ? 'Could not complete purchase.'
              : 'Subscriptions are not yet enabled in this build.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.workspace_premium, size: 56, color: AppColors.warning),
              const SizedBox(height: Spacing.md),
              Text(
                'Unlock CalcMaster Pro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Remove ads, get advanced insights, refresh currency rates instantly, and support indie development.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: Spacing.lg),
              _Benefit(label: 'Ad-free experience'),
              _Benefit(label: 'Advanced tax + finance insights'),
              _Benefit(label: 'Real-time currency refresh'),
              _Benefit(label: 'Priority email support'),
              const SizedBox(height: Spacing.lg),
              _TierCard(
                tier: SubscriptionTier.monthly,
                title: 'Monthly',
                priceLine: MonetizationConfig.priceMonthly,
                detail: 'Cancel anytime',
                selected: _selected == SubscriptionTier.monthly,
                onTap: () => setState(() => _selected = SubscriptionTier.monthly),
              ),
              _TierCard(
                tier: SubscriptionTier.annual,
                title: 'Annual',
                priceLine: MonetizationConfig.priceAnnual,
                detail: MonetizationConfig.annualSavingsLabel,
                badge: 'BEST VALUE',
                selected: _selected == SubscriptionTier.annual,
                onTap: () => setState(() => _selected = SubscriptionTier.annual),
              ),
              _TierCard(
                tier: SubscriptionTier.lifetime,
                title: 'Lifetime',
                priceLine: MonetizationConfig.priceLifetime,
                detail: 'Pay once, own it forever',
                selected: _selected == SubscriptionTier.lifetime,
                onTap: () => setState(() => _selected = SubscriptionTier.lifetime),
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.text,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _busy ? null : _purchase,
                  child: Text(
                    _busy ? 'Processing…' : 'Continue',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Center(
                child: TextButton(
                  onPressed: () async {
                    AnalyticsService.instance.logPurchaseRestored();
                    await context.read<PremiumProvider>().restore();
                  },
                  child: const Text('Restore purchases',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
              Center(
                child: Text(
                  'By continuing you agree to our Terms and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDim, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String label;
  const _Benefit({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.text, fontSize: 14)),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final SubscriptionTier tier;
  final String title;
  final String priceLine;
  final String detail;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _TierCard({
    required this.tier,
    required this.title,
    required this.priceLine,
    required this.detail,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColors.warning : AppColors.borderStrong;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Material(
        color: selected ? AppColors.surfaceAlt : AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.card),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: accent, width: selected ? 2 : 1),
              borderRadius: BorderRadius.circular(Radii.card),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? AppColors.warning : AppColors.textDim,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(title,
                            style: const TextStyle(
                                color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700)),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(badge!,
                                style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 2),
                      Text(detail,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                Text(priceLine,
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
