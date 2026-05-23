import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../monetization/analytics_service.dart';
import '../theme/tokens.dart';
import 'animated_gradient_background.dart';
import 'banner_ad_slot.dart';
import 'particle_dot_grid.dart';

class TabScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const TabScaffold({super.key, required this.shell});

  static const _tabNames = ['convert', 'calculate', 'finance', 'tools', 'notes'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      // Body wrapped in animated gradient + particle grid for the futuristic look.
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            const Positioned.fill(child: ParticleDotGrid()),
            Column(
              children: [
                Expanded(child: shell),
                // Banner ad anchored above the bottom nav. Renders nothing for
                // Pro users or when ads are not configured.
                const BannerAdSlot(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (i) {
          if (i < _tabNames.length) {
            AnalyticsService.instance.logTabOpen(_tabNames[i]);
          }
          shell.goBranch(i, initialLocation: i == shell.currentIndex);
        },
        type: BottomNavigationBarType.fixed,
        // Translucent so the gradient bleeds through.
        backgroundColor: AppColors.surface.withValues(alpha: 0.92),
        selectedItemColor: AppColors.text,
        unselectedItemColor: AppColors.textDim,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.swap_horiz), label: loc.tabConvert),
          BottomNavigationBarItem(icon: const Icon(Icons.calculate), label: loc.tabCalculate),
          BottomNavigationBarItem(icon: const Icon(Icons.attach_money), label: loc.tabFinance),
          BottomNavigationBarItem(icon: const Icon(Icons.build), label: loc.tabTools),
          BottomNavigationBarItem(icon: const Icon(Icons.bookmark_outline), label: loc.tabNotes),
        ],
      ),
    );
  }
}
