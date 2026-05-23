import 'package:flutter/foundation.dart';

import 'monetization_config.dart';

/// Thin wrapper around analytics emission. When `analyticsEnabled` is true and a
/// real Firebase Analytics SDK is wired in, events are forwarded there. In the
/// scaffold today, every call routes to `debugPrint` so the event spec is visible
/// during development and easy to verify in CI logs.
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  Future<void> bootstrap() async {
    if (!MonetizationConfig.analyticsEnabled) return;
    // TODO(monetization): initialize FirebaseAnalytics here when configured.
  }

  void logEvent(String name, [Map<String, dynamic> params = const {}]) {
    if (kDebugMode) {
      // ignore: avoid_print
      debugPrint('[analytics] $name $params');
    }
    if (!MonetizationConfig.analyticsEnabled) return;
    // TODO(monetization): forward to FirebaseAnalytics.logEvent.
  }

  // Domain-specific helpers — keep all event names + params in one place so the
  // schema stays consistent and reviewable.
  void logTabOpen(String tabName) => logEvent('tab_open', {'name': tabName});

  void logConvertUsed(String category) => logEvent('convert_used', {'category': category});

  void logCalcUsed(String tool) => logEvent('calc_used', {'tool': tool});

  void logFinanceUsed(String tool) => logEvent('finance_used', {'tool': tool});

  void logToolUsed(String tool) => logEvent('tool_used', {'tool': tool});

  void logAffiliateClick(String partner, String slot, String region) =>
      logEvent('affiliate_click', {'partner': partner, 'slot': slot, 'region': region});

  void logAdImpression(String slot, String format) =>
      logEvent('ad_impression', {'slot': slot, 'format': format});

  void logPaywallShown(String trigger) => logEvent('paywall_shown', {'trigger': trigger});

  void logPurchaseStarted(String productId) =>
      logEvent('purchase_started', {'product_id': productId});

  void logPurchaseCompleted(String productId) =>
      logEvent('purchase_completed', {'product_id': productId});

  void logPurchaseRestored() => logEvent('purchase_restored');

  void logNotificationPermission(bool granted) =>
      logEvent('notification_permission', {'granted': granted});
}
