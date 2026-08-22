import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:calcmaster/monetization/monetization_config.dart';

void main() {
  group('MonetizationConfig — shipping state', () {
    // Ads are live on Android (real AdMob unit IDs); every other pillar stays
    // off. Flipping one of these is a release decision, so the test states the
    // intended shipping posture rather than a blanket "all false".
    test('only ads are switched on', () {
      expect(MonetizationConfig.adsEnabled, isTrue);
      expect(MonetizationConfig.subscriptionsEnabled, isFalse);
      expect(MonetizationConfig.affiliatesEnabled, isFalse);
      expect(MonetizationConfig.analyticsEnabled, isFalse);
      expect(MonetizationConfig.fcmEnabled, isFalse);
    });

    test('the owning publisher account is AMERICAN GROUP LLC', () {
      expect(MonetizationConfig.admobPublisherId, '8528784688453695');
      expect(MonetizationConfig.googleTestPublisherId, '3940256099942544');
    });

    // app-ads.txt is hosted separately from the binary, so the two drift
    // silently — and a mismatch makes AdMob treat the inventory as
    // unauthorized, which costs demand rather than failing loudly.
    test('app-ads.txt declares the same publisher as the config', () {
      final file = File('marketing/site/app-ads.txt');
      expect(file.existsSync(), isTrue,
          reason: 'marketing/site/app-ads.txt must ship with the marketing site');

      final entries = file
          .readAsLinesSync()
          .map((l) => l.split('#').first.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      expect(entries, isNotEmpty, reason: 'app-ads.txt has no seller entries');

      expect(
        entries.any((l) =>
            l.startsWith('google.com,') &&
            l.contains('pub-${MonetizationConfig.admobPublisherId}') &&
            l.toUpperCase().contains('DIRECT')),
        isTrue,
        reason: 'app-ads.txt must contain a DIRECT google.com entry for '
            'pub-${MonetizationConfig.admobPublisherId}; found: $entries',
      );
    });

    // Neither platform carries IDs belonging to pub-8528784688453695 yet, so
    // release builds serve no ads. Each expectation flips to isTrue as that
    // platform's real IDs are pasted in.
    test('iOS is not ad-ready: still Google sample IDs', () {
      expect(MonetizationConfig.admobIosBanner,
          contains(MonetizationConfig.googleTestPublisherId));
      expect(MonetizationConfig.iosAdIdsAreReal, isFalse);
    });

    test('Android is not ad-ready: IDs belong to a different publisher', () {
      // Real inventory, but owned by a superseded account — serving it would
      // earn into that account rather than AMERICAN GROUP LLC's.
      expect(MonetizationConfig.admobAndroidBanner,
          isNot(contains(MonetizationConfig.googleTestPublisherId)));
      expect(MonetizationConfig.admobAndroidBanner,
          isNot(contains(MonetizationConfig.admobPublisherId)));
      expect(MonetizationConfig.androidAdIdsAreReal, isFalse);
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

    test('"ready" guards reflect real configuration', () {
      // Ads are switched on, but no platform yet holds IDs owned by
      // pub-8528784688453695 → not ready, so nothing serves.
      expect(MonetizationConfig.adsReady, isFalse);
      // affiliatesEnabled is false → affiliatesReady false
      expect(MonetizationConfig.affiliatesReady, isFalse);
    });

    // Selling an entitlement the app cannot verify server-side is not
    // shippable: PremiumProvider fails closed on this flag.
    test('subscriptions are not ready without receipt verification', () {
      expect(MonetizationConfig.receiptVerificationConfigured, isFalse);
      expect(MonetizationConfig.subscriptionsReady, isFalse);
    });
  });
}
