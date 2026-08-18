import 'dart:convert';
import 'package:http/http.dart' as http;

enum RegionId { US, UK, EU, CA, AU, IN, JP, BR, MX, KR, AE }

class Region {
  final RegionId id;
  final String label;
  final String flag;
  final String currency;
  final String symbol;
  final String locale;

  const Region({
    required this.id,
    required this.label,
    required this.flag,
    required this.currency,
    required this.symbol,
    required this.locale,
  });
}

const List<Region> regions = [
  Region(id: RegionId.US, label: 'US', flag: '🇺🇸', currency: 'USD', symbol: '\$', locale: 'en_US'),
  Region(id: RegionId.UK, label: 'UK', flag: '🇬🇧', currency: 'GBP', symbol: '£', locale: 'en_GB'),
  Region(id: RegionId.EU, label: 'EU', flag: '🇪🇺', currency: 'EUR', symbol: '€', locale: 'de_DE'),
  Region(id: RegionId.CA, label: 'CA', flag: '🇨🇦', currency: 'CAD', symbol: 'C\$', locale: 'en_CA'),
  Region(id: RegionId.AU, label: 'AU', flag: '🇦🇺', currency: 'AUD', symbol: 'A\$', locale: 'en_AU'),
  Region(id: RegionId.IN, label: 'IN', flag: '🇮🇳', currency: 'INR', symbol: '₹', locale: 'en_IN'),
  Region(id: RegionId.JP, label: 'JP', flag: '🇯🇵', currency: 'JPY', symbol: '¥', locale: 'ja_JP'),
  Region(id: RegionId.BR, label: 'BR', flag: '🇧🇷', currency: 'BRL', symbol: 'R\$', locale: 'pt_BR'),
  Region(id: RegionId.MX, label: 'MX', flag: '🇲🇽', currency: 'MXN', symbol: 'Mex\$', locale: 'es_MX'),
  Region(id: RegionId.KR, label: 'KR', flag: '🇰🇷', currency: 'KRW', symbol: '₩', locale: 'ko_KR'),
  Region(id: RegionId.AE, label: 'AE', flag: '🇦🇪', currency: 'AED', symbol: 'د.إ', locale: 'en_AE'),
];

Region regionById(RegionId id) =>
    regions.firstWhere((r) => r.id == id, orElse: () => regions[0]);

const Map<String, double> staticRates = {
  'USD': 1,
  'EUR': 0.92,
  'GBP': 0.78,
  'CAD': 1.36,
  'AUD': 1.5,
  'INR': 83.4,
  'JPY': 149.2,
  'CHF': 0.88,
  'CNY': 7.18,
  'MXN': 17.1,
  'BRL': 5.05,
  'KRW': 1310,
  'SGD': 1.34,
  'HKD': 7.81,
  'NZD': 1.62,
  'ZAR': 18.4,
  'SEK': 10.4,
  'NOK': 10.5,
  'DKK': 6.85,
};

class RatesResult {
  final Map<String, double> rates;
  final int fetchedAt;
  final bool live;
  const RatesResult({required this.rates, required this.fetchedAt, required this.live});
}

// Frankfurter moved to api.frankfurter.dev/v1; the old api.frankfurter.app host
// only 301s here now, so call the current one directly rather than relying on
// the redirect surviving.
const String kRatesEndpoint = 'https://api.frankfurter.dev/v1/latest?from=USD';

Future<RatesResult> fetchLatestRates() async {
  try {
    final res = await http
        .get(Uri.parse(kRatesEndpoint))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) throw Exception('Status ${res.statusCode}');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = (json['rates'] as Map<String, dynamic>?) ?? {};
    final rates = <String, double>{'USD': 1};
    raw.forEach((k, v) {
      if (v is num) rates[k] = v.toDouble();
    });
    return RatesResult(rates: rates, fetchedAt: DateTime.now().millisecondsSinceEpoch, live: true);
  } catch (_) {
    return RatesResult(
      rates: Map<String, double>.from(staticRates),
      fetchedAt: DateTime.now().millisecondsSinceEpoch,
      live: false,
    );
  }
}

double convertCurrency(double amount, String from, String to, Map<String, double> rates) {
  if (!amount.isFinite) return double.nan;
  final fromR = rates[from] ?? staticRates[from];
  final toR = rates[to] ?? staticRates[to];
  if (fromR == null || toR == null) return double.nan;
  return (amount / fromR) * toR;
}
