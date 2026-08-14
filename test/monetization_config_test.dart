import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:calcmaster/monetization/monetization_config.dart';

void main() {
  group('MonetizationConfig — single-file dummy defaults', () {
    test('ads are live; every other pillar is still switched off', () {
      // Ads ship enabled with real Android unit IDs. The remaining pillars
      // still hold dummy credentials, so they must stay false.
      expect(MonetizationConfig.adsEnabled, isTrue);
      expect(MonetizationConfig.subscriptionsEnabled, isFalse);
      expect(MonetizationConfig.affiliatesEnabled, isFalse);
      expect(MonetizationConfig.analyticsEnabled, isFalse);
      expect(MonetizationConfig.fcmEnabled, isFalse);
    });

    test('Android AdMob units are real production IDs', () {
      // Real publisher ID for the CalcMaster AdMob account. Google's public
      // test publisher (3940256099942544) must NOT appear on Android now
      // that ads are enabled — test units earn nothing.
      const publisher = '8528784688453695';
      expect(MonetizationConfig.admobAppIdAndroid, contains(publisher));
      expect(MonetizationConfig.admobAndroidBanner, contains(publisher));
      expect(MonetizationConfig.admobAndroidInterstitial, contains(publisher));
    });

    test('Android app ID matches the AndroidManifest meta-data', () {
      // The SDK throws at startup if these drift apart.
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains(MonetizationConfig.admobAppIdAndroid));
    });

    test('iOS AdMob units are still Google test IDs (replace before App Store)', () {
      expect(MonetizationConfig.admobIosBanner, contains('3940256099942544'));
      expect(MonetizationConfig.admobIosInterstitial, contains('3940256099942544'));
    });

    test('RevenueCat keys still hold dummy markers (replace before launch)', () {
      expect(MonetizationConfig.revenueCatIosKey, contains('DUMMY'));
      expect(MonetizationConfig.revenueCatAndroidKey, contains('DUMMY'));
    });

    test('Product IDs default to canonical names', () {
      expect(MonetizationConfig.productMonthly, equals('calcmaster_pro_monthly'));
      expect(MonetizationConfig.productAnnual, equals('calcmaster_pro_annual'));
      expect(MonetizationConfig.productLifetime, equals('calcmaster_pro_lifetime'));
    });

    test('Display prices have ready-to-show strings', () {
      expect(MonetizationConfig.priceMonthly, contains('\$'));
      expect(MonetizationConfig.priceAnnual, contains('\$'));
      expect(MonetizationConfig.priceLifetime, contains('\$'));
    });

    test('Affiliate slot map covers known slots', () {
      expect(MonetizationConfig.affiliateSlots.containsKey('volume_buy_measuring_set'), isTrue);
      expect(MonetizationConfig.affiliateSlots.containsKey('bmi_smart_scale'), isTrue);
      expect(MonetizationConfig.affiliateSlots.containsKey('compound_savings_account'), isTrue);
      expect(MonetizationConfig.affiliateSlots['_fallback'], contains('amazon'));
    });

    test('Legal URLs and support email are present', () {
      expect(MonetizationConfig.privacyPolicyUrl, contains('http'));
      expect(MonetizationConfig.termsOfServiceUrl, contains('http'));
      expect(MonetizationConfig.supportEmail, contains('@'));
    });

    test('"ready" guards correctly reject dummy values', () {
      // adsEnabled is true and both app IDs are populated → adsReady true
      expect(MonetizationConfig.adsReady, isTrue);
      // subscriptionsEnabled is false → subscriptionsReady false
      expect(MonetizationConfig.subscriptionsReady, isFalse);
      // affiliatesEnabled is false → affiliatesReady false
      expect(MonetizationConfig.affiliatesReady, isFalse);
    });
  });
}
