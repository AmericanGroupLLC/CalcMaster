import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
import '../monetization/monetization_config.dart';
import '../theme/tokens.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(loc.settingsPrivacyPolicy, style: const TextStyle(color: AppColors.text)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xxl),
        children: [
          const Text('Privacy at a glance',
              style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: Spacing.md),
          _para('CalcMaster runs almost entirely on your device. Your conversions, '
              'notes, and selected region are stored locally and never leave your phone unless you explicitly opt in.'),
          _para('We use anonymous analytics to understand which calculators are most useful so '
              'we can prioritize improvements. No personally identifiable information is collected.'),
          _para('When you tap an affiliate link or sponsored card, you leave the app and visit '
              'a partner website. Their privacy policy applies once you click.'),
          _para('If you subscribe to CalcMaster Pro, your purchase is processed by the App Store or Google Play; '
              'we never see your payment details.'),
          const SizedBox(height: Spacing.lg),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surfaceAlt,
              foregroundColor: AppColors.text,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => launchUrl(Uri.parse(MonetizationConfig.privacyPolicyUrl)),
            child: const Text('Open full privacy policy'),
          ),
          const SizedBox(height: Spacing.sm),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.borderStrong),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => launchUrl(Uri.parse(MonetizationConfig.termsOfServiceUrl)),
            child: const Text('Terms of service'),
          ),
        ],
      ),
    );
  }

  Widget _para(String s) => Padding(
        padding: const EdgeInsets.only(bottom: Spacing.md),
        child: Text(s,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5)),
      );
}
