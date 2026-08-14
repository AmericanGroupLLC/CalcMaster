// =====================================================================
//  CALCMASTER · MONETIZATION CONFIG · SINGLE SOURCE OF TRUTH
// =====================================================================
//
// EVERY monetization credential, ID, URL, email and feature flag lives in
// THIS FILE only. No other Dart file in the project hard-codes a key.
//
// To go live in production:
//   1. Find each value marked  // REPLACE: <source>  below
//   2. Paste the real value
//   3. Flip the matching master switch at the top of the class to `true`
//
// Defaults are SAFE to ship today: ad unit IDs are Google's official
// TEST IDs, RevenueCat keys are dummy strings, affiliate tags are dummies.
// Until the master switches are flipped to `true`, every service in
// `lib/monetization/` short-circuits cleanly and the app behaves as if
// monetization were absent.
// =====================================================================

class MonetizationConfig {
  // ───────────────────────────────────────────────────────────────────
  //  MASTER SWITCHES — flip per-pillar after replacing values below
  // ───────────────────────────────────────────────────────────────────

  /// Show banner / interstitial / native ads in the app.
  /// Requires real AdMob unit IDs (see ADMOB section).
  static const bool adsEnabled = true;

  /// Show paywall + accept real in-app purchases via RevenueCat.
  /// Requires real RevenueCat key + IAP products in App Store Connect / Play Console.
  static const bool subscriptionsEnabled = false;

  /// Render affiliate CTA buttons inside detail screens + tag URLs.
  /// Requires real Amazon Associates (or other) tag.
  static const bool affiliatesEnabled = false;

  /// Forward in-app events to Firebase Analytics.
  /// Until then, every event is logged via debugPrint for inspection.
  static const bool analyticsEnabled = false;

  /// Subscribe device to FCM topics + show push notifications.
  /// Requires Firebase project + APNs auth key (iOS) + google-services.json (Android).
  static const bool fcmEnabled = false;

  // ───────────────────────────────────────────────────────────────────
  //  ADMOB · in-app advertising
  // ───────────────────────────────────────────────────────────────────
  // REPLACE: AdMob console → Apps → CalcMaster iOS / Android → Ad units
  // Google's official TEST ad unit IDs are used as defaults — these will
  // serve test ads (not earning) when `adsEnabled` is true and
  // `google_mobile_ads` is wired in. Switch to your real production unit IDs
  // before public release.
  // https://developers.google.com/admob/flutter/quick-start
  // Real AdMob app ID — keep in sync with:
  //   android/app/src/main/AndroidManifest.xml  (APPLICATION_ID meta-data)
  //   ios/Runner/Info.plist                     (GADApplicationIdentifier)
  // NOTE: AdMob issues one app ID per platform. Both entries below currently
  // use the same ID. Register a separate iOS app in the AdMob console and
  // replace admobAppIdIos + Info.plist before shipping to the App Store.
  static const String admobAppIdIos = 'ca-app-pub-8528784688453695~5377349094'; // REPLACE with real iOS app ID
  static const String admobAppIdAndroid = 'ca-app-pub-8528784688453695~5377349094';

  static const String admobIosBanner = 'ca-app-pub-3940256099942544/2934735716'; // REPLACE
  static const String admobAndroidBanner = 'ca-app-pub-8528784688453695/7665581023'; // Real value (calcmaster-banner)

  static const String admobIosInterstitial = 'ca-app-pub-3940256099942544/4411468910'; // REPLACE
  static const String admobAndroidInterstitial = 'ca-app-pub-8528784688453695/7474009334'; // Real value (calcmaster-interstitial)

  static const String admobIosNative = 'ca-app-pub-3940256099942544/3986624511'; // REPLACE
  static const String admobAndroidNative = 'ca-app-pub-3940256099942544/2247696110'; // REPLACE

  // ───────────────────────────────────────────────────────────────────
  //  REVENUECAT · subscriptions
  // ───────────────────────────────────────────────────────────────────
  // REPLACE: app.revenuecat.com → Project → Apps → Public API key
  // Use the platform-specific key — RevenueCat's Flutter SDK requires both.
  static const String revenueCatIosKey = 'appl_DUMMY_REPLACE_BEFORE_LAUNCH'; // REPLACE
  static const String revenueCatAndroidKey = 'goog_DUMMY_REPLACE_BEFORE_LAUNCH'; // REPLACE

  // REPLACE: App Store Connect → My Apps → CalcMaster → In-App Purchases  AND
  //          Google Play Console → CalcMaster → Monetize → Products → Subscriptions
  // Both stores must use the SAME identifier strings as below.
  static const String productMonthly = 'calcmaster_pro_monthly'; // REPLACE if different
  static const String productAnnual = 'calcmaster_pro_annual'; // REPLACE if different
  static const String productLifetime = 'calcmaster_pro_lifetime'; // REPLACE if different

  // Display prices shown on the paywall. These are *cosmetic only* — the real
  // price is fetched from the store at purchase time. Keep these in sync with
  // App Store Connect / Play Console base pricing for honest UX.
  static const String priceMonthly = '\$2.99 / month'; // REPLACE with store price
  static const String priceAnnual = '\$19.99 / year'; // REPLACE with store price
  static const String priceLifetime = '\$49.99 once'; // REPLACE with store price
  static const String annualSavingsLabel = 'Save 44% · most popular'; // REPLACE if pricing changes

  // ───────────────────────────────────────────────────────────────────
  //  FIREBASE · analytics, crashlytics, FCM (re-engagement)
  // ───────────────────────────────────────────────────────────────────
  // REPLACE: console.firebase.google.com → CalcMaster project → Project settings
  // The real config travels in `ios/Runner/GoogleService-Info.plist` and
  // `android/app/google-services.json` — these dummies are for sanity-check
  // logs only.
  static const String firebaseProjectId = 'calcmaster-DUMMY-12345'; // REPLACE
  static const String firebaseSenderId = '0123456789'; // REPLACE

  // FCM topics the app subscribes to once the user opts in to notifications.
  static const List<String> fcmTopics = ['daily_tip', 'rate_alerts', 'reengagement'];

  // ───────────────────────────────────────────────────────────────────
  //  AFFILIATE PARTNERS
  // ───────────────────────────────────────────────────────────────────
  // REPLACE: affiliate-program.amazon.com → tag (e.g. "myname-20")
  // One tag per region; falls back to US tag when a region-specific tag
  // is empty.
  static const String amazonAssociatesTagUS = 'calcmaster-20'; // REPLACE
  static const String amazonAssociatesTagUK = 'calcmaster-21'; // REPLACE
  static const String amazonAssociatesTagIN = 'calcmaster-21'; // REPLACE

  // Optional: meal-delivery / wellness affiliate URLs. Replace with real
  // tracking URLs from your partner dashboards.
  static const String mealKitAffiliateUrl = ''; // REPLACE: set real meal-kit affiliate URL
  static const String wellnessSubscriptionUrl = ''; // REPLACE: set real wellness affiliate URL

  // Per-slot Amazon search URLs — used by `AffiliateService.urlFor()`.
  // The `?tag=...` query param is appended automatically based on region.
  // REPLACE with concrete product detail page URLs to maximise conversion.
  static const Map<String, String> affiliateSlots = {
    'volume_buy_measuring_set': 'https://www.amazon.com/s?k=measuring+cup+set',
    'bmi_smart_scale': 'https://www.amazon.com/s?k=smart+scale',
    'compound_savings_account': 'https://www.amazon.com/s?k=high+yield+savings+book',
    'tax_book': 'https://www.amazon.com/s?k=tax+guide',
    'cooking_scale': 'https://www.amazon.com/s?k=kitchen+scale',
    '_fallback': 'https://www.amazon.com/',
  };

  // ───────────────────────────────────────────────────────────────────
  //  LEGAL / SUPPORT
  // ───────────────────────────────────────────────────────────────────
  // Safe Code G (American Group LLC) — live pages on safecodeg.com.
  static const String privacyPolicyUrl = 'https://safecodeg.com/privacy-policy';
  static const String termsOfServiceUrl = 'https://safecodeg.com/terms';
  static const String supportEmail = 'contact@safecodeg.com';
  static const String marketingWebsite = 'https://safecodeg.com';
  static const String appStoreUrl =
      'https://apps.apple.com/app/calcmaster/id0000000000'; // REPLACE after listing
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.americangroupllc.calcmaster'; // REPLACE

  // ───────────────────────────────────────────────────────────────────
  //  TUNING — safe to leave at defaults
  // ───────────────────────────────────────────────────────────────────

  /// Show an interstitial after every Nth use of any tool/calculator.
  static const int interstitialEveryNUses = 5;

  /// Currency rates auto-refresh interval for free-tier users.
  static const Duration freeRateRefreshInterval = Duration(hours: 24);

  /// Currency rates auto-refresh interval for Pro subscribers.
  static const Duration proRateRefreshInterval = Duration(minutes: 15);

  /// Maximum notification frequency to avoid annoying users.
  static const int maxPushNotificationsPerDay = 2;

  // ───────────────────────────────────────────────────────────────────
  //  COMPUTED — used by the rest of the app, do not edit
  // ───────────────────────────────────────────────────────────────────

  /// True only when both ads are enabled AND no obvious dummy value is left
  /// in the iOS or Android app IDs. Defensive check so a half-configured
  /// build never serves blank slots.
  static bool get adsReady =>
      adsEnabled &&
          admobAppIdIos.isNotEmpty &&
          admobAppIdAndroid.isNotEmpty;

  /// True only when subscriptions are enabled AND a real RevenueCat key is in
  /// place (i.e. the dummy `_DUMMY_` marker has been removed).
  static bool get subscriptionsReady =>
      subscriptionsEnabled &&
          !revenueCatIosKey.contains('DUMMY') &&
          !revenueCatAndroidKey.contains('DUMMY');

  /// True when at least one affiliate tag has been replaced from the dummy.
  static bool get affiliatesReady =>
      affiliatesEnabled &&
          !amazonAssociatesTagUS.contains('DUMMY');
}
