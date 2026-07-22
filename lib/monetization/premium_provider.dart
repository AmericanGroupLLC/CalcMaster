import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
/// exposes the purchase / restore lifecycle backed by real store IAP via the
/// `in_app_purchase` plugin (StoreKit on iOS, Billing on Android).
///
/// Purchases + restores flow through [_iap.purchaseStream]; [purchase] and
/// [restore] await the terminal result and only flip the entitlement on a
/// `purchased` / `restored` status. There is intentionally NO free grant: on a
/// device without configured store products (e.g. the iOS Simulator, which has
/// no StoreKit products) the store either reports unavailable or returns no
/// products, and both methods honestly return `false`.
///
/// TODO(monetization): SERVER-SIDE RECEIPT VERIFICATION IS REQUIRED BEFORE
/// RELEASE. The entitlement below is granted client-side directly from the
/// store callback, which is spoofable. Before shipping, forward
/// `PurchaseDetails.verificationData.serverVerificationData` to a trusted
/// backend that validates the receipt with Apple / Google and returns the
/// authoritative entitlement; grant Pro only on that server response.
class PremiumProvider extends ChangeNotifier {
  static const _kIsPro = '@calcmaster/is_pro';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final Map<String, ProductDetails> _products = {};

  Completer<bool>? _purchaseCompleter;
  Completer<bool>? _restoreCompleter;

  bool _isPro = false;
  bool get isPro => _isPro;

  /// Whether the underlying store connection is available on this device.
  /// `false` on the simulator or when the store is unreachable.
  bool _storeAvailable = false;
  bool get storeAvailable => _storeAvailable;

  /// Human-readable reason for the most recent failed purchase / restore.
  String? _lastError;
  String? get lastError => _lastError;

  PremiumProvider() {
    _hydrate();
    _bootstrap();
  }

  Set<String> get _productIds => {
        MonetizationConfig.productMonthly,
        MonetizationConfig.productAnnual,
        MonetizationConfig.productLifetime,
      };

  /// Store-fetched details (localized price, title) for a tier, or `null` when
  /// the product could not be loaded (e.g. simulator / not yet configured).
  ProductDetails? productFor(SubscriptionTier tier) => _products[tier.productId];

  Future<void> _hydrate() async {
    final sp = await SharedPreferences.getInstance();
    _isPro = sp.getBool(_kIsPro) ?? false;
    notifyListeners();
  }

  Future<void> _bootstrap() async {
    if (!MonetizationConfig.subscriptionsEnabled) return;
    try {
      _storeAvailable = await _iap.isAvailable();
    } catch (_) {
      _storeAvailable = false;
    }
    if (!_storeAvailable) {
      notifyListeners();
      return;
    }
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) {
        _lastError = 'The store reported an error.';
        _completePurchase(false);
        _completeRestore(false);
        notifyListeners();
      },
    );
    await _loadProducts();
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    try {
      final resp = await _iap.queryProductDetails(_productIds);
      for (final p in resp.productDetails) {
        _products[p.id] = p;
      }
    } catch (_) {
      // Products stay empty; purchase() will report unavailable rather than
      // granting anything.
    }
  }

  /// Attempt to start a purchase flow for the given tier. Returns whether a
  /// verified purchase completed. Returns `false` (and sets [lastError]) when
  /// the store is unavailable or the product is not configured — never grants
  /// Pro on failure.
  Future<bool> purchase(SubscriptionTier tier) async {
    AnalyticsService.instance.logPurchaseStarted(tier.productId);
    _lastError = null;

    if (!MonetizationConfig.subscriptionsEnabled) return false;

    if (!_storeAvailable) {
      _lastError = 'In-app purchases are unavailable on this device.';
      notifyListeners();
      return false;
    }

    final product = _products[tier.productId];
    if (product == null) {
      // No StoreKit / Billing product available (e.g. the simulator). Honest
      // failure — do NOT grant Pro.
      _lastError = 'This subscription is not available right now.';
      notifyListeners();
      return false;
    }

    // Only one purchase in flight at a time.
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      return false;
    }
    _purchaseCompleter = Completer<bool>();

    final param = PurchaseParam(productDetails: product);
    try {
      // Subscriptions + one-time lifetime are both non-consumable to the plugin.
      await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      _lastError = 'Could not start the purchase.';
      _completePurchase(false);
      notifyListeners();
      return false;
    }

    // Resolves from _onPurchaseUpdates. Guard with a timeout so a stalled store
    // flow can't hang the UI forever.
    return _purchaseCompleter!.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        _purchaseCompleter = null;
        return _isPro;
      },
    );
  }

  /// Attempt to restore previously purchased entitlements (e.g. after
  /// reinstall). Returns whether an entitlement was restored.
  Future<bool> restore() async {
    AnalyticsService.instance.logPurchaseRestored();
    _lastError = null;

    if (!MonetizationConfig.subscriptionsEnabled) return false;

    if (!_storeAvailable) {
      _lastError = 'In-app purchases are unavailable on this device.';
      notifyListeners();
      return false;
    }

    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      return false;
    }
    _restoreCompleter = Completer<bool>();

    try {
      await _iap.restorePurchases();
    } catch (e) {
      _lastError = 'Could not restore purchases.';
      _completeRestore(false);
      notifyListeners();
      return false;
    }

    // restorePurchases() streams results asynchronously with no explicit "done"
    // signal; resolve on the first restored entitlement, else time out honestly.
    return _restoreCompleter!.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _restoreCompleter = null;
        return _isPro;
      },
    );
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
          // TODO(monetization): verify purchase.verificationData server-side
          // BEFORE granting (see class doc). Client grant is a pre-release stub.
          _grantPro();
          AnalyticsService.instance.logPurchaseCompleted(purchase.productID);
          _completePurchase(true);
          break;
        case PurchaseStatus.restored:
          // TODO(monetization): verify server-side before granting (see above).
          _grantPro();
          AnalyticsService.instance.logPurchaseCompleted(purchase.productID);
          _completeRestore(true);
          break;
        case PurchaseStatus.error:
          _lastError = purchase.error?.message ?? 'The purchase failed.';
          _completePurchase(false);
          _completeRestore(false);
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          _completePurchase(false);
          _completeRestore(false);
          break;
      }
      // Acknowledge the transaction so the store stops re-delivering it.
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _completePurchase(bool ok) {
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(ok);
    }
    _purchaseCompleter = null;
  }

  void _completeRestore(bool ok) {
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      _restoreCompleter!.complete(ok);
    }
    _restoreCompleter = null;
  }

  Future<void> _grantPro() async {
    _isPro = true;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kIsPro, true);
    notifyListeners();
  }

  /// Used by tests to flip the entitlement without hitting a real store.
  @visibleForTesting
  Future<void> setIsProForTest(bool value) async {
    _isPro = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kIsPro, value);
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
