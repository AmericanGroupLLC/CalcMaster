import 'package:flutter_test/flutter_test.dart';
import 'package:calcmaster/lib_format.dart';

void main() {
  group('formatNumber', () {
    test('integer 42', () => expect(formatNumber(42), '42'));
    test('zero', () => expect(formatNumber(0), '0'));
    test('negative integer', () => expect(formatNumber(-7), '-7'));
    test('decimal 1.5', () => expect(formatNumber(1.5), '1.5'));
    test('large number 1000000 uses no decimals', () => expect(formatNumber(1000000), '1,000,000'));
    test('10000 uses 2 decimals max', () => expect(formatNumber(10000.0), '10,000'));
    test('small decimal 0.001', () => expect(formatNumber(0.001), '0.001'));
    test('very small decimal uses 8 digits', () => expect(formatNumber(0.00001234), contains('0.000012')));
    test('NaN returns em dash', () => expect(formatNumber(double.nan), '—'));
    test('infinity returns em dash', () => expect(formatNumber(double.infinity), '—'));
    test('negative infinity returns em dash', () => expect(formatNumber(double.negativeInfinity), '—'));
    test('maxDigits parameter respected', () => expect(formatNumber(3.14159, maxDigits: 2), '3.14'));
    test('minDigits parameter respected', () => expect(formatNumber(3.0, minDigits: 2), '3.00'));
  });

  group('safeNumber', () {
    test('valid integer string', () => expect(safeNumber('42'), 42.0));
    test('valid decimal string', () => expect(safeNumber('3.14'), closeTo(3.14, 1e-10)));
    test('empty string returns 0', () => expect(safeNumber(''), 0.0));
    test('non-numeric string returns 0', () => expect(safeNumber('abc'), 0.0));
    test('negative number string', () => expect(safeNumber('-5'), -5.0));
    test('whitespace string returns 0', () => expect(safeNumber('   '), 0.0));
    test('comma-formatted number', () => expect(safeNumber('1,234'), closeTo(1234, 1e-6)));
  });

  group('formatPercent', () {
    test('50% → 50.00%', () => expect(formatPercent(0.5), '50.00%'));
    test('0% → 0.00%', () => expect(formatPercent(0), '0.00%'));
    test('100% → 100.00%', () => expect(formatPercent(1.0), '100.00%'));
    test('custom digits', () => expect(formatPercent(0.1234, digits: 1), '12.3%'));
    test('NaN returns em dash', () => expect(formatPercent(double.nan), '—'));
  });

  group('formatCurrency', () {
    test('USD formats with dollar sign', () {
      final result = formatCurrency(1234.56, 'en_US', 'USD');
      expect(result, contains('\$'));
      expect(result, contains('1,234'));
    });
    test('GBP formats with pound sign', () {
      final result = formatCurrency(100.0, 'en_GB', 'GBP');
      expect(result, contains('£'));
    });
    test('NaN returns em dash', () => expect(formatCurrency(double.nan, 'en_US', 'USD'), '—'));
  });
}
