import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: const Text('About', style: TextStyle(color: AppColors.text)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xxl),
        children: [
          const SizedBox(height: Spacing.lg),
          const Center(
            child: Text('CalcMaster',
                style: TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.w800)),
          ),
          const Center(
            child: Text('World calculator & converter',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ),
          const SizedBox(height: Spacing.lg),
          const _Row(label: 'Version', value: '4.0.0'),
          const _Row(label: 'Build', value: 'flutter'),
          const _Row(label: 'Made with', value: 'Flutter + ❤'),
          const SizedBox(height: Spacing.xxl),
          const Text(
            'CalcMaster bundles the calculators most people actually use — unit conversions, '
            'percentages, scientific math, tax + finance, electronics, and a notes pad — '
            'in one polished app that respects your privacy and your battery.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
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
