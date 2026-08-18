import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
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
    final premium = context.read<PremiumProvider>();
    setState(() => _busy = true);
    final ok = await premium.purchase(_selected);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final loc = AppLocalizations.of(context)!;
      // Prefer the provider's honest reason (e.g. "unavailable on this device"
      // on the simulator); fall back to generic copy.
      final message = premium.lastError ??
          (MonetizationConfig.subscriptionsEnabled
              ? 'Could not complete purchase.'
              : loc.paywallSubscriptionsDisabled);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Close',
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
                loc.paywallTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                loc.paywallSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: Spacing.lg),
              _Benefit(label: loc.paywallBenefitAdFree),
              _Benefit(label: loc.paywallBenefitAdvanced),
              _Benefit(label: loc.paywallBenefitRealtime),
              _Benefit(label: loc.paywallBenefitSupport),
              const SizedBox(height: Spacing.lg),
              _TierCard(
                tier: SubscriptionTier.monthly,
                title: loc.paywallTierMonthly,
                priceLine: MonetizationConfig.priceMonthly,
                detail: loc.paywallCancelAnytime,
                selected: _selected == SubscriptionTier.monthly,
                onTap: () => setState(() => _selected = SubscriptionTier.monthly),
              ),
              _TierCard(
                tier: SubscriptionTier.annual,
                title: loc.paywallTierAnnual,
                priceLine: MonetizationConfig.priceAnnual,
                detail: loc.paywallAnnualSavings,
                badge: loc.paywallBadgeBestValue,
                selected: _selected == SubscriptionTier.annual,
                onTap: () => setState(() => _selected = SubscriptionTier.annual),
              ),
              _TierCard(
                tier: SubscriptionTier.lifetime,
                title: loc.paywallTierLifetime,
                priceLine: MonetizationConfig.priceLifetime,
                detail: loc.paywallLifetimeForever,
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
                    _busy ? loc.paywallProcessing : loc.paywallContinue,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final premium = context.read<PremiumProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final restored = await premium.restore();
                    if (!context.mounted) return;
                    if (restored) {
                      Navigator.of(context).pop();
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(premium.lastError ??
                              'No active purchases found.'),
                        ),
                      );
                    }
                  },
                  child: Text(loc.paywallRestore,
                      style: const TextStyle(color: AppColors.textMuted)),
                ),
              ),
              Center(
                child: Text(
                  loc.paywallTermsFooter,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDim, fontSize: 11),
                ),
              ),
              // Guideline 3.1.2 requires the Terms of Use and privacy policy to
              // be reachable from the paywall itself, not just from Settings.
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _LegalLink(
                      label: loc.paywallTermsOfUse,
                      url: MonetizationConfig.termsOfServiceUrl,
                    ),
                    const Text('·',
                        style: TextStyle(color: AppColors.textDim, fontSize: 11)),
                    _LegalLink(
                      label: loc.settingsPrivacyPolicy,
                      url: MonetizationConfig.privacyPolicyUrl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final String url;
  const _LegalLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textMuted,
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
