import 'dart:io' show Platform;

import 'monetization_config.dart';

/// AdMob wrapper. When ads are not configured, every method returns a no-op so
/// the rest of the app doesn't have to special-case anything. Once real keys
/// land, swap in `google_mobile_ads` and replace the method bodies — the
/// surface stays the same.
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  bool _initialized = false;
  int _interstitialCounter = 0;

  bool get enabled => MonetizationConfig.adsEnabled;

  Future<void> bootstrap() async {
    if (!enabled || _initialized) return;
    _initialized = true;
    // TODO(monetization): MobileAds.instance.initialize();
  }

  String? bannerUnitId() {
    if (!enabled) return null;
    if (Platform.isIOS) return MonetizationConfig.admobIosBanner;
    if (Platform.isAndroid) return MonetizationConfig.admobAndroidBanner;
    return null;
  }

  String? interstitialUnitId() {
    if (!enabled) return null;
    if (Platform.isIOS) return MonetizationConfig.admobIosInterstitial;
    if (Platform.isAndroid) return MonetizationConfig.admobAndroidInterstitial;
    return null;
  }

  String? nativeUnitId() {
    if (!enabled) return null;
    if (Platform.isIOS) return MonetizationConfig.admobIosNative;
    if (Platform.isAndroid) return MonetizationConfig.admobAndroidNative;
    return null;
  }

  /// Increments a session counter. Returns true every Nth call (default 5),
  /// signaling the caller it's time to display an interstitial.
  bool shouldShowInterstitial({int every = 5}) {
    _interstitialCounter += 1;
    return _interstitialCounter % every == 0;
  }
}
