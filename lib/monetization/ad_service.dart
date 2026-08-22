import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'monetization_config.dart';
import 'tracking_service.dart';

/// AdMob wrapper using the real google_mobile_ads SDK.
///
/// Unit IDs come from [MonetizationConfig]. Android currently holds real
/// production IDs; iOS still holds Google's public TEST IDs, so iOS release
/// builds serve no ads until real ones are pasted in (see [enabled]). Debug
/// builds still show test ads so the slots can be verified during development.
///
/// On web and in widget tests, every method gracefully no-ops.
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  bool _initialized = false;
  int _interstitialCounter = 0;
  InterstitialAd? _cachedInterstitial;
  bool _loadingInterstitial = false;
  bool _consentRequested = false;

  /// Ask for iOS tracking permission once, immediately before the first ad
  /// request.
  ///
  /// Without ATT authorization AdMob may only serve non-personalised ads, which
  /// earn materially less. [TrackingService] existed but was never called from
  /// anywhere, so the prompt never appeared. Triggering it here — on the first
  /// ad, not at cold launch — matches the deferral that TrackingService
  /// documents and that App Review expects. No-ops on Android and web.
  Future<void> ensureTrackingConsent() async {
    if (kIsWeb || _consentRequested || _isInTest()) return;
    _consentRequested = true;
    try {
      await TrackingService.instance.requestIfNeeded();
    } catch (e) {
      debugPrint('[AdService] Tracking consent request failed: $e');
    }
  }

  /// Whether ads may be served on this platform right now.
  ///
  /// Previously this was `adsEnabled || _hasTestAds()`, where the fallback only
  /// checked that a unit ID string was non-empty — always true. That made the
  /// `adsEnabled` master switch inoperative on mobile: ads could not be turned
  /// off. The switch is now authoritative, and release builds additionally
  /// refuse to serve Google's test inventory (which earns nothing and breaches
  /// AdMob policy when shown to real users), so a platform still holding test
  /// IDs simply shows no ads instead of shipping sample ads to production.
  bool get enabled {
    if (kIsWeb) return false;
    if (!MonetizationConfig.adsEnabled) return false;
    if (kReleaseMode && !_platformAdIdsAreReal()) return false;
    return true;
  }

  /// Whether *this* platform's unit IDs are real (non-test) production IDs.
  bool _platformAdIdsAreReal() {
    try {
      if (Platform.isIOS) return MonetizationConfig.iosAdIdsAreReal;
      if (Platform.isAndroid) return MonetizationConfig.androidAdIdsAreReal;
    } catch (_) {}
    return false;
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
    await ensureTrackingConsent();
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
      // Matches AutomatedTestWidgetsFlutterBinding (`flutter test`) *and*
      // IntegrationTestWidgetsFlutterBinding (`integration_test`). Only the
      // former was matched before, so integration tests hit real ad platform
      // channels. Production uses plain WidgetsFlutterBinding, which does not
      // contain this substring.
      return WidgetsBinding.instance.runtimeType
          .toString()
          .contains('TestWidgetsFlutterBinding');
    } catch (_) {
      return false;
    }
  }
}
