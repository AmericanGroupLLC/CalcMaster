import 'package:flutter_test/flutter_test.dart';

import 'package:calcmaster/monetization/monetization_config.dart';

void main() {
  group('MonetizationConfig — single-file dummy defaults', () {
    test('master switches default to false (safe to ship)', () {
      expect(MonetizationConfig.adsEnabled, isFalse);
      expect(MonetizationConfig.subscriptionsEnabled, isFalse);
      expect(MonetizationConfig.affiliatesEnabled, isFalse);
      expect(MonetizationConfig.analyticsEnabled, isFalse);
      expect(MonetizationConfig.fcmEnabled, isFalse);
    });

    test('AdMob defaults are Google\'s test IDs (safe to use today)', () {
      // Google publishes these test IDs publicly — they show test ads when
      // the SDK is wired in. Production keys must replace these before
      // public release.
      expect(MonetizationConfig.admobIosBanner, contains('3940256099942544'));
      expect(MonetizationConfig.admobAndroidBanner, contains('3940256099942544'));
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
      // adsEnabled is false → adsReady false
      expect(MonetizationConfig.adsReady, isFalse);
      // subscriptionsEnabled is false → subscriptionsReady false
      expect(MonetizationConfig.subscriptionsReady, isFalse);
      // affiliatesEnabled is false → affiliatesReady false
      expect(MonetizationConfig.affiliatesReady, isFalse);
    });
  });
}
