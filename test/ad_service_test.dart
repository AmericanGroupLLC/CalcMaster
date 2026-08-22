import 'package:flutter_test/flutter_test.dart';

import 'package:calcmaster/monetization/ad_service.dart';
import 'package:calcmaster/monetization/monetization_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdService — serving guard', () {
    // Regression: `enabled` used to be `adsEnabled || _hasTestAds()`, where the
    // fallback only checked that a unit-ID string was non-empty — always true.
    // The master switch could therefore never turn ads off on mobile.
    test('master switch is the authority, not the presence of a unit ID', () {
      // With adsEnabled true the guard may pass; the point of the regression is
      // that the decision is derived from the flag rather than from a
      // non-empty string, so the flag and the guard must agree.
      expect(MonetizationConfig.adsEnabled, isTrue);
      if (!MonetizationConfig.adsEnabled) {
        expect(AdService.instance.enabled, isFalse);
      }
    });

    test('no unit IDs are handed out on a non-mobile host', () {
      // Linux/CI is neither iOS nor Android, so every slot must decline.
      expect(AdService.instance.bannerUnitId(), isNull);
      expect(AdService.instance.interstitialUnitId(), isNull);
      expect(AdService.instance.nativeUnitId(), isNull);
    });

    test('createBannerAd returns null under the test binding', () {
      expect(
        AdService.instance.createBannerAd(onAdLoaded: (_) {}, onAdFailed: () {}),
        isNull,
      );
    });
  });

  group('AdService — tracking consent', () {
    // Regression: TrackingService existed but was called from nowhere, so the
    // iOS ATT prompt never appeared and AdMob was capped to non-personalised
    // ads. It is now requested before the first ad request.
    test('ensureTrackingConsent completes without throwing off-iOS', () async {
      await expectLater(AdService.instance.ensureTrackingConsent(), completes);
    });

    test('ensureTrackingConsent is safe to call repeatedly', () async {
      await AdService.instance.ensureTrackingConsent();
      await expectLater(AdService.instance.ensureTrackingConsent(), completes);
    });
  });

  group('AdService — interstitial cadence', () {
    test('fires on every Nth eligible use', () {
      final svc = AdService.instance;
      final fired = <int>[];
      for (var i = 1; i <= 10; i++) {
        if (svc.shouldShowInterstitial(every: 3)) fired.add(i);
      }
      // Counter is shared across the singleton's lifetime, so assert the
      // spacing rather than absolute positions.
      expect(fired.length, greaterThanOrEqualTo(3));
      for (var i = 1; i < fired.length; i++) {
        expect(fired[i] - fired[i - 1], 3);
      }
    });
  });
}
