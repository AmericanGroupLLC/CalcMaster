// Income tax brackets and sales tax / VAT defaults per region.
// Bracket rates reflect commonly cited 2025-2026 figures and are intended for rough
// estimates only — these are NOT a substitute for professional tax advice.

import type { RegionId } from "@/app/lib/currency";

export type FilingStatus = "single" | "joint" | "head";

export type Bracket = {
  /** Inclusive upper bound of this bracket in local currency. Use Infinity for the top bracket. */
  upTo: number;
  rate: number; // 0..1
};

type CountryBrackets = Record<FilingStatus, Bracket[]>;

// Sales tax / VAT default rates (used as the default for the Tax Calculator's sales tax mode).
export const salesTaxRate: Record<RegionId, number> = {
  US: 0.085,
  UK: 0.2,
  EU: 0.19,
  CA: 0.13,
  AU: 0.1,
  IN: 0.18,
  JP: 0.1,
};

export const standardDeduction: Record<RegionId, Record<FilingStatus, number>> = {
  US: { single: 15000, joint: 30000, head: 22500 },
  UK: { single: 12570, joint: 12570, head: 12570 }, // personal allowance, ignores joint marriage allowance for simplicity
  EU: { single: 10908, joint: 21816, head: 10908 }, // approximate EU-wide; uses Germany's Grundfreibetrag
  CA: { single: 15705, joint: 15705, head: 15705 },
  AU: { single: 18200, joint: 18200, head: 18200 },
  IN: { single: 75000, joint: 75000, head: 75000 }, // standard deduction in new tax regime FY 2025-26
  JP: { single: 480000, joint: 480000, head: 480000 }, // basic deduction in JPY
};

const usSingle: Bracket[] = [
  { upTo: 11925, rate: 0.10 },
  { upTo: 48475, rate: 0.12 },
  { upTo: 103350, rate: 0.22 },
  { upTo: 197300, rate: 0.24 },
  { upTo: 250525, rate: 0.32 },
  { upTo: 626350, rate: 0.35 },
  { upTo: Infinity, rate: 0.37 },
];

const usJoint: Bracket[] = [
  { upTo: 23850, rate: 0.10 },
  { upTo: 96950, rate: 0.12 },
  { upTo: 206700, rate: 0.22 },
  { upTo: 394600, rate: 0.24 },
  { upTo: 501050, rate: 0.32 },
  { upTo: 751600, rate: 0.35 },
  { upTo: Infinity, rate: 0.37 },
];

const usHead: Bracket[] = [
  { upTo: 17000, rate: 0.10 },
  { upTo: 64850, rate: 0.12 },
  { upTo: 103350, rate: 0.22 },
  { upTo: 197300, rate: 0.24 },
  { upTo: 250500, rate: 0.32 },
  { upTo: 626350, rate: 0.35 },
  { upTo: Infinity, rate: 0.37 },
];

const ukAll: Bracket[] = [
  { upTo: 12570, rate: 0 }, // personal allowance band - taxed at 0
  { upTo: 50270, rate: 0.20 },
  { upTo: 125140, rate: 0.40 },
  { upTo: Infinity, rate: 0.45 },
];

const euAll: Bracket[] = [
  // Approximation of Germany's progressive scale (a reasonable EU average)
  { upTo: 11604, rate: 0 },
  { upTo: 17005, rate: 0.14 },
  { upTo: 66760, rate: 0.24 },
  { upTo: 277825, rate: 0.42 },
  { upTo: Infinity, rate: 0.45 },
];

const caAll: Bracket[] = [
  { upTo: 55867, rate: 0.15 },
  { upTo: 111733, rate: 0.205 },
  { upTo: 173205, rate: 0.26 },
  { upTo: 246752, rate: 0.29 },
  { upTo: Infinity, rate: 0.33 },
];

const auAll: Bracket[] = [
  { upTo: 18200, rate: 0 },
  { upTo: 45000, rate: 0.16 },
  { upTo: 135000, rate: 0.30 },
  { upTo: 190000, rate: 0.37 },
  { upTo: Infinity, rate: 0.45 },
];

const inAll: Bracket[] = [
  { upTo: 400000, rate: 0 },
  { upTo: 800000, rate: 0.05 },
  { upTo: 1200000, rate: 0.10 },
  { upTo: 1600000, rate: 0.15 },
  { upTo: 2000000, rate: 0.20 },
  { upTo: 2400000, rate: 0.25 },
  { upTo: Infinity, rate: 0.30 },
];

const jpAll: Bracket[] = [
  { upTo: 1950000, rate: 0.05 },
  { upTo: 3300000, rate: 0.10 },
  { upTo: 6950000, rate: 0.20 },
  { upTo: 9000000, rate: 0.23 },
  { upTo: 18000000, rate: 0.33 },
  { upTo: 40000000, rate: 0.40 },
  { upTo: Infinity, rate: 0.45 },
];

export const incomeTaxBrackets: Record<RegionId, CountryBrackets> = {
  US: { single: usSingle, joint: usJoint, head: usHead },
  UK: { single: ukAll, joint: ukAll, head: ukAll },
  EU: { single: euAll, joint: euAll, head: euAll },
  CA: { single: caAll, joint: caAll, head: caAll },
  AU: { single: auAll, joint: auAll, head: auAll },
  IN: { single: inAll, joint: inAll, head: inAll },
  JP: { single: jpAll, joint: jpAll, head: jpAll },
};

export type TaxResult = {
  taxableIncome: number;
  taxOwed: number;
  effectiveRate: number;
  marginalRate: number;
  takeHome: number;
  takeHomeMonthly: number;
};

export function computeIncomeTax(
  grossIncome: number,
  region: RegionId,
  status: FilingStatus,
  options: { applyStandardDeduction?: boolean; stateLocalRate?: number } = {},
): TaxResult {
  const applyStdDeduction = options.applyStandardDeduction ?? true;
  const stateRate = options.stateLocalRate ?? 0;
  const deduction = applyStdDeduction ? standardDeduction[region][status] : 0;
  const taxable = Math.max(0, grossIncome - deduction);

  const brackets = incomeTaxBrackets[region][status];
  let owed = 0;
  let prevCap = 0;
  let marginal = 0;
  for (const bracket of brackets) {
    if (taxable <= prevCap) break;
    const slice = Math.min(taxable, bracket.upTo) - prevCap;
    owed += slice * bracket.rate;
    marginal = bracket.rate;
    prevCap = bracket.upTo;
  }

  // Approximate state / local tax as a flat percent of taxable income.
  owed += taxable * stateRate;
  // Combined marginal rate is federal marginal + flat state rate.
  marginal = marginal + stateRate;

  const takeHome = Math.max(0, grossIncome - owed);
  return {
    taxableIncome: taxable,
    taxOwed: owed,
    effectiveRate: grossIncome > 0 ? owed / grossIncome : 0,
    marginalRate: marginal,
    takeHome,
    takeHomeMonthly: takeHome / 12,
  };
}
