import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:calcmaster/monetization/monetization_config.dart';

void main() {
  group('MonetizationConfig — single-file dummy defaults', () {
    test('ads and subscriptions are on; the rest stay switched off', () {
      // Subscriptions are live: the three products exist in App Store Connect
      // and are READY_TO_SUBMIT. Affiliates/analytics/FCM still hold dummy
      // credentials, so they must stay false.
      expect(MonetizationConfig.adsEnabled, isTrue);
      expect(MonetizationConfig.subscriptionsEnabled, isTrue);
      expect(MonetizationConfig.affiliatesEnabled, isFalse);
      expect(MonetizationConfig.analyticsEnabled, isFalse);
      expect(MonetizationConfig.fcmEnabled, isFalse);
    });

    test('AdMob app IDs are real and on the CalcMaster publisher', () {
      // App IDs are real. Unit IDs are NOT yet — see the test below. The old
      // Android values belonged to publisher 1804742004018995, which does not
      // own these app IDs and could never have served.
      const publisher = '8528784688453695';
      expect(MonetizationConfig.admobAppIdAndroid, contains(publisher));
      expect(MonetizationConfig.admobAppIdIos, contains(publisher));
      expect(MonetizationConfig.admobAppIdIos,
          isNot(equals(MonetizationConfig.admobAppIdAndroid)));
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
      // Ads must stay OFF while the banner units are Google's test units, so a
      // release build can never ship "Test Ad" placeholders. Replacing the two
      // banner IDs flips both of these to true with no other code change.
      expect(MonetizationConfig.adUnitsAreReal, isFalse);
      expect(MonetizationConfig.adsReady, isFalse);
      // subscriptionsReady still checks the RevenueCat keys, which are dummies.
      // That guard is vestigial: purchases go through in_app_purchase/StoreKit
      // (see PremiumProvider), not RevenueCat, so it does not gate anything.
      expect(MonetizationConfig.subscriptionsReady, isFalse);
      // affiliatesEnabled is false → affiliatesReady false
      expect(MonetizationConfig.affiliatesReady, isFalse);
    });

    test('banner is the only rendered ad format, and gates adUnitsAreReal', () {
      // showInterstitial()/nativeUnitId() have no call sites, so requiring
      // real interstitial/native units would keep ads off forever.
      const testPublisher = 'ca-app-pub-3940256099942544';
      expect(MonetizationConfig.admobIosBanner, startsWith(testPublisher));
      expect(MonetizationConfig.admobAndroidBanner, startsWith(testPublisher));
      expect(MonetizationConfig.adUnitsAreReal, isFalse);
    });
  });
}
