import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/tokens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: Text(loc.settingsAbout, style: const TextStyle(color: AppColors.text)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xxl),
        children: [
          const SizedBox(height: Spacing.lg),
          Center(
            child: Text(loc.appTitle,
                style: const TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.w800)),
          ),
          Center(
            child: Text(loc.appTagline,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ),
          const SizedBox(height: Spacing.lg),
          _Row(label: loc.aboutVersion, value: '4.0.0'),
          _Row(label: loc.aboutBuild, value: 'flutter'),
          _Row(label: loc.aboutMadeWith, value: 'Flutter + ❤'),
          const SizedBox(height: Spacing.xxl),
          Text(
            loc.aboutBlurb,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14))),
          Text(value,
              style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
