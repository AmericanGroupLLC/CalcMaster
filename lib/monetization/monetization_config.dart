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
  //
  // ⚠ NONE of the IDs below belong to [admobPublisherId] (pub-8528784688453695,
  // AMERICAN GROUP LLC) yet, so no ads serve in release builds on either
  // platform. That is deliberate — see [_isOwnedAdId].
  //
  //   • `3940256099942544` is Google's public SAMPLE account: serves test ads,
  //     earns nothing, and breaches policy if shown to real users.
  //   • `1804742004018995` is a DIFFERENT, superseded publisher account. Its
  //     units would earn into that account, not AMERICAN GROUP LLC's.
  //
  // TO GO LIVE: create the app in AdMob under pub-8528784688453695, then paste
  // its app ID (`~` form) and unit IDs (`/` form) below, plus the app IDs into
  // android/app/src/main/AndroidManifest.xml and ios/Runner/Info.plist.
  // https://developers.google.com/admob/flutter/quick-start
  static const String admobAppIdIos = 'ca-app-pub-3940256099942544~1458002511'; // REPLACE: sample
  static const String admobAppIdAndroid =
      'ca-app-pub-1804742004018995~3291928616'; // REPLACE: other publisher

  static const String admobIosBanner = 'ca-app-pub-3940256099942544/2934735716'; // REPLACE: sample
  static const String admobAndroidBanner =
      'ca-app-pub-1804742004018995/7853301794'; // REPLACE: other publisher

  static const String admobIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910'; // REPLACE: sample
  static const String admobAndroidInterstitial =
      'ca-app-pub-1804742004018995/1563793836'; // REPLACE: other publisher

  static const String admobIosNative = 'ca-app-pub-3940256099942544/3986624511'; // REPLACE
  static const String admobAndroidNative = 'ca-app-pub-3940256099942544/2247696110'; // REPLACE

  // ───────────────────────────────────────────────────────────────────
  //  REVENUECAT · subscriptions
  // ───────────────────────────────────────────────────────────────────
  // NOT IN USE. Purchases run through the `in_app_purchase` plugin (StoreKit /
  // Play Billing) in `premium_provider.dart`; the RevenueCat SDK is not a
  // dependency of this app. These keys are retained only so an existing
  // RevenueCat project can be adopted later — configuring them today changes
  // nothing. The live subscription gate is [subscriptionsReady].
  static const String revenueCatIosKey = 'appl_DUMMY_REPLACE_BEFORE_LAUNCH'; // unused
  static const String revenueCatAndroidKey = 'goog_DUMMY_REPLACE_BEFORE_LAUNCH'; // unused

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

  /// Publisher prefix of Google's public sample AdMob account. Any unit ID
  /// containing this is test inventory: it serves sample ads and earns nothing,
  /// and showing it to real users breaches AdMob policy.
  static const String googleTestPublisherId = '3940256099942544';

  /// The AdMob/AdSense publisher account that owns CalcMaster's inventory —
  /// AMERICAN GROUP LLC, `pub-8528784688453695`. Declared to AdMob by
  /// `marketing/site/app-ads.txt`, which must stay in sync with this value.
  ///
  /// Every real ad unit must belong to this account. Ad IDs from any other
  /// publisher earn into someone else's account, so [_isOwnedAdId] rejects
  /// them and the affected platform simply serves no ads.
  static const String admobPublisherId = '8528784688453695';

  static bool _isTestAdId(String id) => id.contains(googleTestPublisherId);

  /// Whether an ad ID is real inventory belonging to [admobPublisherId].
  static bool _isOwnedAdId(String id) =>
      id.contains(admobPublisherId) && !_isTestAdId(id);

  /// Whether the iOS ad slots hold real unit IDs owned by [admobPublisherId].
  static bool get iosAdIdsAreReal =>
      _isOwnedAdId(admobAppIdIos) &&
          _isOwnedAdId(admobIosBanner) &&
          _isOwnedAdId(admobIosInterstitial);

  /// Whether the Android ad slots hold real unit IDs owned by
  /// [admobPublisherId].
  static bool get androidAdIdsAreReal =>
      _isOwnedAdId(admobAppIdAndroid) &&
          _isOwnedAdId(admobAndroidBanner) &&
          _isOwnedAdId(admobAndroidInterstitial);

  /// True when ads are switched on AND at least one platform holds real unit
  /// IDs. Per-platform enforcement lives in `AdService.enabled`, which refuses
  /// to serve test inventory from a release build.
  static bool get adsReady => adsEnabled && (iosAdIdsAreReal || androidAdIdsAreReal);

  /// Whether a trusted backend is configured to validate store receipts.
  ///
  /// Store callbacks are spoofable on a compromised device, so an entitlement
  /// must be granted on a server's verdict, not the client's. Until a
  /// verification endpoint exists, [PremiumProvider] fails closed and never
  /// grants Pro. Set the gateway route via
  /// `--dart-define=RECEIPT_VERIFICATION_PATH=/subscriptions/verify` (the
  /// route must match the backend actually deployed).
  static const String receiptVerificationPath = String.fromEnvironment(
    'RECEIPT_VERIFICATION_PATH',
    defaultValue: '',
  );

  static bool get receiptVerificationConfigured => receiptVerificationPath.isNotEmpty;

  /// True only when subscriptions are switched on AND receipts can be verified
  /// server-side. Selling an entitlement the app cannot verify is not shippable,
  /// so this stays false until a verification endpoint is configured.
  static bool get subscriptionsReady =>
      subscriptionsEnabled && receiptVerificationConfigured;

  /// True when at least one affiliate tag has been replaced from the dummy.
  static bool get affiliatesReady =>
      affiliatesEnabled &&
          !amazonAssociatesTagUS.contains('DUMMY');
}
