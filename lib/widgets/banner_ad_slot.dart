import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../monetization/ad_service.dart';
import '../monetization/premium_provider.dart';

/// Reserves space for a banner ad at the bottom of any screen. Renders nothing
/// when ads are disabled or the user is Pro. When AdMob is wired and a unit ID
/// is available, the inner placeholder will be replaced by `AdWidget` driven
/// by `google_mobile_ads`.
class BannerAdSlot extends StatelessWidget {
  const BannerAdSlot({super.key});

  static const _bannerHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<PremiumProvider>().isPro;
    final unitId = AdService.instance.bannerUnitId();
    final shouldRender = !isPro && AdService.instance.enabled && unitId != null;
    if (!shouldRender) return const SizedBox.shrink();
    // Placeholder until google_mobile_ads is wired. Reserves space and visually
    // indicates that an ad would render here in production.
    return Container(
      height: _bannerHeight,
      color: Colors.black.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: const Text(
        'AD',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
