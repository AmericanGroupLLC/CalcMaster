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

  /// Below this width we use the mobile bottom-nav layout; at or above it we
  /// switch to a desktop web layout with a side navigation rail and a bounded,
  /// centered content column.
  static const double _desktopBreakpoint = 840;

  /// Content never grows wider than this on desktop — keeps line lengths and
  /// tap targets comfortable instead of stretching edge-to-edge.
  static const double _contentMaxWidth = 1120;

  void _onSelect(int i) {
    if (i < _tabNames.length) {
      AnalyticsService.instance.logTabOpen(_tabNames[i]);
    }
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }

  List<({IconData icon, String label})> _destinations(AppLocalizations loc) => [
        (icon: Icons.swap_horiz, label: loc.tabConvert),
        (icon: Icons.calculate, label: loc.tabCalculate),
        (icon: Icons.attach_money, label: loc.tabFinance),
        (icon: Icons.build, label: loc.tabTools),
        (icon: Icons.bookmark_outline, label: loc.tabNotes),
      ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.sizeOf(context).width >= _desktopBreakpoint;

    final content = Column(
      children: [
        Expanded(child: shell),
        // Banner ad anchored above the bottom nav. Renders nothing for
        // Pro users or when ads are not configured.
        const BannerAdSlot(),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      // Body wrapped in animated gradient + particle grid for the futuristic look.
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            const Positioned.fill(child: ParticleDotGrid()),
            if (isDesktop)
              SafeArea(
                child: Row(
                  children: [
                    _SideRail(
                      destinations: _destinations(loc),
                      currentIndex: shell.currentIndex,
                      onSelect: _onSelect,
                      extended: MediaQuery.sizeOf(context).width >= 1180,
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                          child: content,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              content,
          ],
        ),
      ),
      bottomNavigationBar: isDesktop ? null : _BottomNav(
        destinations: _destinations(loc),
        currentIndex: shell.currentIndex,
        onSelect: _onSelect,
      ),
    );
  }
}

/// Mobile bottom navigation bar with an accented active tab and a top hairline.
class _BottomNav extends StatelessWidget {
  final List<({IconData icon, String label})> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _BottomNav({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Hairline that separates the nav from the content above it.
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderStrong)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onSelect,
        type: BottomNavigationBarType.fixed,
        // Translucent so the gradient bleeds through.
        backgroundColor: AppColors.surface.withValues(alpha: 0.92),
        // Accent the active tab so the current section reads at a glance.
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.textDim,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        items: [
          for (final d in destinations)
            BottomNavigationBarItem(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}

/// Desktop side navigation rail — the core of the "webapp" layout.
class _SideRail extends StatelessWidget {
  final List<({IconData icon, String label})> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final bool extended;

  const _SideRail({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Translucent sidebar with a right hairline separating it from content.
        border: Border(right: BorderSide(color: AppColors.borderStrong)),
      ),
      child: NavigationRail(
        backgroundColor: AppColors.surface.withValues(alpha: 0.45),
        extended: extended,
        minWidth: 76,
        minExtendedWidth: 200,
        selectedIndex: currentIndex,
        onDestinationSelected: onSelect,
        groupAlignment: -0.85,
        indicatorColor: AppColors.accentPrimary.withValues(alpha: 0.18),
        selectedIconTheme: const IconThemeData(color: AppColors.accentPrimary),
        unselectedIconTheme: const IconThemeData(color: AppColors.textDim),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.accentPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9B7DFF), AppColors.accentPrimary],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 22),
          ),
        ),
        destinations: [
          for (final d in destinations)
            NavigationRailDestination(
              icon: Icon(d.icon),
              label: Text(d.label),
            ),
        ],
      ),
    );
  }
}
