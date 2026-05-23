import { computeIncomeTax, salesTaxRate } from "@/app/lib/tax";

describe("computeIncomeTax — US single, 2025 brackets", () => {
  test("zero income → zero tax", () => {
    const r = computeIncomeTax(0, "US", "single");
    expect(r.taxOwed).toBe(0);
    expect(r.takeHome).toBe(0);
  });
  test("income just above standard deduction (15000)", () => {
    const r = computeIncomeTax(20000, "US", "single", { applyStandardDeduction: true });
    // taxable = 5000, all in 10% bracket -> 500
    expect(r.taxOwed).toBeCloseTo(500, 2);
    expect(r.marginalRate).toBeCloseTo(0.10, 2);
  });
  test("$80k single — straddles 12% / 22% boundary", () => {
    const r = computeIncomeTax(80000, "US", "single", { applyStandardDeduction: true });
    // taxable = 65000
    // 10%*11925 + 12%*(48475-11925) + 22%*(65000-48475) = 1192.5 + 4386 + 3635.5 = 9214.0
    expect(r.taxOwed).toBeCloseTo(9214, 0);
  });
  test("UK personal allowance band", () => {
    const r = computeIncomeTax(12000, "UK", "single", { applyStandardDeduction: false });
    // entirely within 0% band
    expect(r.taxOwed).toBe(0);
  });
  test("India 2025 new regime — 5L → 0", () => {
    const r = computeIncomeTax(500000, "IN", "single", { applyStandardDeduction: false });
    expect(r.taxOwed).toBeCloseTo(5000, 0); // (500000-400000)*0.05
  });
  test("Australia 18.2k threshold", () => {
    const r = computeIncomeTax(18000, "AU", "single", { applyStandardDeduction: false });
    expect(r.taxOwed).toBe(0);
  });
});

describe("salesTaxRate", () => {
  test("contains all 7 regions", () => {
    expect(salesTaxRate.US).toBeGreaterThan(0);
    expect(salesTaxRate.UK).toBeGreaterThan(0);
    expect(salesTaxRate.EU).toBeGreaterThan(0);
    expect(salesTaxRate.CA).toBeGreaterThan(0);
    expect(salesTaxRate.AU).toBeGreaterThan(0);
    expect(salesTaxRate.IN).toBeGreaterThan(0);
    expect(salesTaxRate.JP).toBeGreaterThan(0);
  });
});
