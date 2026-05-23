import 'package:intl/intl.dart';

String formatNumber(double value, {int? maxDigits, int minDigits = 0}) {
  if (!value.isFinite) return '—';
  final abs = value.abs();
  int max = maxDigits ?? 6;
  if (abs != 0 && abs < 0.0001) max = 8;
  if (abs >= 10000) max = 2;
  if (abs >= 1000000) max = 0;

  final pattern = StringBuffer('#,##0');
  if (max > 0) {
    pattern.write('.');
    pattern.write('0' * minDigits);
    pattern.write('#' * (max - minDigits));
  }
  final f = NumberFormat(pattern.toString(), 'en_US');
  return f.format(value);
}

String formatCurrency(double value, String locale, String currency) {
  if (!value.isFinite) return '—';
  try {
    return NumberFormat.currency(locale: locale, name: currency, symbol: _symbolFor(currency)).format(value);
  } catch (_) {
    return '${value.toStringAsFixed(2)} $currency';
  }
}

String _symbolFor(String currency) {
  switch (currency) {
    case 'USD':
      return '\$';
    case 'GBP':
      return '£';
    case 'EUR':
      return '€';
    case 'CAD':
      return 'C\$';
    case 'AUD':
      return 'A\$';
    case 'INR':
      return '₹';
    case 'JPY':
      return '¥';
    default:
      return '$currency ';
  }
}

String formatPercent(double value, {int digits = 2}) {
  if (!value.isFinite) return '—';
  return '${(value * 100).toStringAsFixed(digits)}%';
}

double safeNumber(String input) {
  if (input.isEmpty) return 0;
  final cleaned = input.replaceAll(',', '').trim();
  return double.tryParse(cleaned) ?? 0;
}
