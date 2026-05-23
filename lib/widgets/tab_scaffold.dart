import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../monetization/analytics_service.dart';
import '../theme/tokens.dart';
import 'banner_ad_slot.dart';

class TabScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const TabScaffold({super.key, required this.shell});

  static const _tabNames = ['convert', 'calculate', 'finance', 'tools', 'notes'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(child: shell),
          // Banner ad anchored above the bottom nav. Renders nothing for Pro users
          // or when ads are not configured — see widgets/banner_ad_slot.dart.
          const BannerAdSlot(),
        ],
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
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.text,
        unselectedItemColor: AppColors.textDim,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Convert'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculate'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Notes'),
        ],
      ),
    );
  }
}
