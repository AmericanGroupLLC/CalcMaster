import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';
import 'monetization_config.dart';

enum SubscriptionTier { monthly, annual, lifetime }

extension SubscriptionTierProductId on SubscriptionTier {
  String get productId {
    switch (this) {
      case SubscriptionTier.monthly:
        return MonetizationConfig.productMonthly;
      case SubscriptionTier.annual:
        return MonetizationConfig.productAnnual;
      case SubscriptionTier.lifetime:
        return MonetizationConfig.productLifetime;
    }
  }
}

/// Tracks whether the current user has an active premium entitlement and
/// exposes the purchase / restore lifecycle.
///
/// In the scaffold today, no real IAP runs: `purchase()` and `restore()` log
/// analytics + return `false`. When RevenueCat is configured, swap the bodies
/// of those methods for `Purchases.purchaseProduct` / `Purchases.restorePurchases`.
class PremiumProvider extends ChangeNotifier {
  static const _kIsPro = '@calcmaster/is_pro';

  bool _isPro = false;
  bool get isPro => _isPro;

  PremiumProvider() {
    _hydrate();
    _bootstrap();
  }

  Future<void> _hydrate() async {
    final sp = await SharedPreferences.getInstance();
    _isPro = sp.getBool(_kIsPro) ?? false;
    notifyListeners();
  }

  Future<void> _bootstrap() async {
    if (!MonetizationConfig.subscriptionsEnabled) return;
    // TODO(monetization): Purchases.configure(...) + listen to customerInfo.
  }

  /// Attempt to start a purchase flow for the given tier. Returns whether the
  /// purchase completed successfully. In the scaffold this is always `false`.
  Future<bool> purchase(SubscriptionTier tier) async {
    AnalyticsService.instance.logPurchaseStarted(tier.productId);
    if (!MonetizationConfig.subscriptionsEnabled) return false;

    // TODO(monetization): real purchase flow via purchases_flutter.
    return false;
  }

  /// Attempt to restore previously purchased entitlements (e.g. after reinstall).
  Future<bool> restore() async {
    AnalyticsService.instance.logPurchaseRestored();
    if (!MonetizationConfig.subscriptionsEnabled) return false;

    // TODO(monetization): real restore flow via purchases_flutter.
    return false;
  }

  /// Used by tests + future real IAP callbacks to flip the entitlement.
  @visibleForTesting
  Future<void> setIsProForTest(bool value) async {
    _isPro = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kIsPro, value);
    notifyListeners();
  }
}
