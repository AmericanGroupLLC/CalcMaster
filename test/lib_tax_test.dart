import 'package:flutter_test/flutter_test.dart';
import 'package:calcmaster/lib_tax.dart';
import 'package:calcmaster/lib_currency.dart';

void main() {
  group('computeIncomeTax — US Single', () {
    test('zero income has zero tax', () {
      final r = computeIncomeTax(0, RegionId.US, FilingStatus.single);
      expect(r.taxOwed, 0.0);
      expect(r.effectiveRate, 0.0);
    });

    test('income below standard deduction has zero tax', () {
      // US single standard deduction is 15000
      final r = computeIncomeTax(10000, RegionId.US, FilingStatus.single);
      expect(r.taxOwed, 0.0);
      expect(r.taxableIncome, 0.0);
    });

    test('income of 50000 — single', () {
      final r = computeIncomeTax(50000, RegionId.US, FilingStatus.single);
      // Taxable = 50000 - 15000 = 35000
      // 10% on first 11925 = 1192.50
      // 12% on (35000 - 11925) = 23075 → 2769.00
      // Total = 3961.50
      expect(r.taxableIncome, closeTo(35000, 1e-2));
      expect(r.taxOwed, closeTo(3961.50, 1.0)); // allow $1 rounding
      expect(r.effectiveRate, closeTo(3961.50 / 50000, 1e-3));
      expect(r.marginalRate, closeTo(0.12, 1e-6));
      expect(r.takeHome, closeTo(50000 - 3961.50, 1.0));
    });

    test('high income hits 37% bracket', () {
      final r = computeIncomeTax(700000, RegionId.US, FilingStatus.single);
      expect(r.marginalRate, closeTo(0.37, 1e-6));
      expect(r.taxOwed, greaterThan(0));
    });

    test('take home = gross - tax', () {
      final r = computeIncomeTax(80000, RegionId.US, FilingStatus.single);
      expect(r.takeHome, closeTo(80000 - r.taxOwed, 1e-6));
    });

    test('monthly take home = annual / 12', () {
      final r = computeIncomeTax(80000, RegionId.US, FilingStatus.single);
      expect(r.takeHomeMonthly, closeTo(r.takeHome / 12, 1e-6));
    });
  });

  group('computeIncomeTax — UK', () {
    test('income below personal allowance has zero tax', () {
      final r = computeIncomeTax(12000, RegionId.UK, FilingStatus.single);
      expect(r.taxOwed, 0.0);
    });

    test('income of 30000 — UK basic rate', () {
      final r = computeIncomeTax(30000, RegionId.UK, FilingStatus.single);
      // Taxable = 30000 - 12570 = 17430
      // 20% on 17430 = 3486
      expect(r.taxOwed, closeTo(3486, 1.0));
      expect(r.marginalRate, closeTo(0.20, 1e-6));
    });
  });

  group('computeIncomeTax — no standard deduction', () {
    test('applyStandardDeduction=false uses full gross', () {
      final rWith = computeIncomeTax(50000, RegionId.US, FilingStatus.single);
      final rWithout = computeIncomeTax(50000, RegionId.US, FilingStatus.single, applyStandardDeduction: false);
      expect(rWithout.taxableIncome, 50000.0);
      expect(rWithout.taxOwed, greaterThan(rWith.taxOwed));
    });
  });

  group('salesTaxRate', () {
    test('US sales tax is 8.5%', () => expect(salesTaxRate[RegionId.US], closeTo(0.085, 1e-6)));
    test('UK VAT is 20%', () => expect(salesTaxRate[RegionId.UK], closeTo(0.20, 1e-6)));
    test('AU GST is 10%', () => expect(salesTaxRate[RegionId.AU], closeTo(0.10, 1e-6)));
    test('AE VAT is 5%', () => expect(salesTaxRate[RegionId.AE], closeTo(0.05, 1e-6)));
  });
}
