import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../lib_units.dart';
import '../theme/tokens.dart';
import '../widgets/convert_card.dart';
import '../widgets/pill_badge.dart';
import '../widgets/region_pill.dart';

class ConvertHome extends StatelessWidget {
  const ConvertHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CalcMaster', style: Theme.of(context).textTheme.displayLarge),
                        const SizedBox(height: 2),
                        const Text(
                          'World calculator & converter',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  RegionPill(
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const RegionPickerSheet(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.text),
                    tooltip: 'Settings',
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),
              const PillBadge(label: 'Unit Conversion', color: AppColors.accentPrimary),
              const SizedBox(height: Spacing.md),
              const Text('Convert', style: TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Tap any unit to convert instantly',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
              const SizedBox(height: Spacing.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                  crossAxisSpacing: Spacing.md,
                  mainAxisSpacing: Spacing.md,
                ),
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  return ConvertCard(
                    category: cat,
                    onTap: () => context.push('/convert/${cat.id}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
