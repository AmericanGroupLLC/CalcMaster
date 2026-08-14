import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'monetization_config.dart';

/// AdMob wrapper using the real google_mobile_ads SDK.
///
/// The default credentials in MonetizationConfig are Google's official TEST
/// ad unit IDs — these serve safe test ads without requiring a real AdMob
/// account. Replace with production unit IDs before public release.
///
/// On web and in widget tests, every method gracefully no-ops.
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  bool _initialized = false;
  int _interstitialCounter = 0;
  InterstitialAd? _cachedInterstitial;
  bool _loadingInterstitial = false;

  /// Single gate for ad loading. Previously this was
  /// `adsEnabled || _hasTestAds()`, and `_hasTestAds()` only checked that a
  /// unit ID string was non-empty — which is always true — so ads rendered
  /// even with `adsEnabled = false`. It now defers entirely to
  /// [MonetizationConfig.adsReady], which additionally requires real
  /// (non-test) unit IDs, so a release build cannot ship test ads.
  bool get enabled {
    if (kIsWeb) return false;
    return MonetizationConfig.adsReady;
  }

  Future<void> bootstrap() async {
    if (kIsWeb || _initialized) return;
    if (_isInTest()) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      // Initialization can fail on emulators without Google Play Services etc.
      debugPrint('[AdService] Mobile Ads init failed: $e');
    }
  }

  String? bannerUnitId() {
    if (!enabled) return null;
    try {
      if (Platform.isIOS) return MonetizationConfig.admobIosBanner;
      if (Platform.isAndroid) return MonetizationConfig.admobAndroidBanner;
    } catch (_) {}
    return null;
  }

  String? interstitialUnitId() {
    if (!enabled) return null;
    try {
      if (Platform.isIOS) return MonetizationConfig.admobIosInterstitial;
      if (Platform.isAndroid) return MonetizationConfig.admobAndroidInterstitial;
    } catch (_) {}
    return null;
  }

  String? nativeUnitId() {
    if (!enabled) return null;
    try {
      if (Platform.isIOS) return MonetizationConfig.admobIosNative;
      if (Platform.isAndroid) return MonetizationConfig.admobAndroidNative;
    } catch (_) {}
    return null;
  }

  /// Builds a fresh BannerAd. Caller is responsible for calling `ad.load()`
  /// and disposing on widget dispose.
  BannerAd? createBannerAd({required void Function(Ad) onAdLoaded, required void Function() onAdFailed}) {
    final unitId = bannerUnitId();
    if (unitId == null || _isInTest()) return null;
    return BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('[AdService] Banner failed to load: $error');
          onAdFailed();
        },
      ),
    );
  }

  /// Preload the next interstitial in the background so `showInterstitial`
  /// can fire immediately on its next eligible trigger.
  Future<void> preloadInterstitial() async {
    if (kIsWeb || _isInTest()) return;
    if (_cachedInterstitial != null || _loadingInterstitial) return;
    final unitId = interstitialUnitId();
    if (unitId == null) return;
    _loadingInterstitial = true;
    await InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedInterstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial failed to load: $error');
          _loadingInterstitial = false;
        },
      ),
    );
  }

  /// Increments a session counter. Returns true every Nth call (default 5),
  /// signaling the caller it's time to display an interstitial.
  bool shouldShowInterstitial({int? every}) {
    _interstitialCounter += 1;
    final n = every ?? MonetizationConfig.interstitialEveryNUses;
    return _interstitialCounter % n == 0;
  }

  /// Show the cached interstitial (loads one if not yet cached). Triggers
  /// the next preload so subsequent shows are instant.
  Future<void> showInterstitial() async {
    if (kIsWeb || _isInTest()) return;
    if (_cachedInterstitial == null) {
      await preloadInterstitial();
      return; // skip this show — preload kicked off for next time
    }
    final ad = _cachedInterstitial!;
    _cachedInterstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        debugPrint('[AdService] Interstitial show failed: $error');
        preloadInterstitial();
      },
    );
    await ad.show();
  }

  static bool _isInTest() {
    try {
      return WidgetsBinding.instance.runtimeType
          .toString()
          .contains('AutomatedTestWidgetsFlutterBinding');
    } catch (_) {
      return false;
    }
  }
}
