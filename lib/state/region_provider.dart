import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib_currency.dart';

class RegionProvider extends ChangeNotifier {
  static const _kRegion = 'region';

  RegionId _regionId = RegionId.US;
  Map<String, double> _rates = Map<String, double>.from(staticRates);
  bool _ratesLive = false;
  int? _ratesUpdatedAt;

  RegionId get regionId => _regionId;
  Region get region => regionById(_regionId);
  Map<String, double> get rates => _rates;
  bool get ratesLive => _ratesLive;
  int? get ratesUpdatedAt => _ratesUpdatedAt;

  RegionProvider() {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString(_kRegion);
    if (saved != null) {
      try {
        _regionId = RegionId.values.firstWhere((r) => r.name == saved);
        notifyListeners();
      } catch (_) {}
    }
    refreshRates();
  }

  Future<void> setRegion(RegionId id) async {
    _regionId = id;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kRegion, id.name);
  }

  Future<void> cycleRegion() async {
    final idx = regions.indexWhere((r) => r.id == _regionId);
    final next = regions[(idx + 1) % regions.length].id;
    await setRegion(next);
  }

  Future<void> refreshRates() async {
    final result = await fetchLatestRates();
    _rates = result.rates;
    _ratesLive = result.live;
    _ratesUpdatedAt = result.fetchedAt;
    notifyListeners();
  }
}
