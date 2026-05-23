import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../monetization/ad_service.dart';
import '../monetization/premium_provider.dart';

/// 50dp banner ad anchored above the bottom nav. Uses the real google_mobile_ads
/// SDK with Google's TEST ad unit IDs by default — these serve test ads safely
/// without a real AdMob account.
///
/// Renders nothing when:
///   - on web (AdMob not supported on web)
///   - the user is Pro
///   - ads are disabled in MonetizationConfig and no test ID present
///   - the ad failed to load (graceful degrade — slot collapses)
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  static const double bannerHeight = 50.0;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadAd();
    }
  }

  void _loadAd() {
    final ad = AdService.instance.createBannerAd(
      onAdLoaded: (_) {
        if (mounted) setState(() => _loaded = true);
      },
      onAdFailed: () {
        if (mounted) setState(() => _failed = true);
      },
    );
    if (ad == null) return;
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<PremiumProvider>().isPro;
    if (kIsWeb || isPro || _failed || _ad == null || !_loaded) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: Center(child: AdWidget(ad: _ad!)),
    );
  }
}
