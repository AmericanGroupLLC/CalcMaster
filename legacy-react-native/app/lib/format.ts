// Number formatting helpers used across all calculator/converter screens.
// Goal: never show meaningless trailing zeros, but always show enough precision for tiny / huge values.

export function formatNumber(value: number, opts: { maxDigits?: number; minDigits?: number } = {}): string {
  if (!Number.isFinite(value)) return "—";
  const abs = Math.abs(value);
  let max = opts.maxDigits ?? 6;
  if (abs !== 0 && abs < 0.0001) max = 8;
  if (abs >= 10000) max = 2;
  if (abs >= 1_000_000) max = 0;
  const formatter = new Intl.NumberFormat("en-US", {
    minimumFractionDigits: opts.minDigits ?? 0,
    maximumFractionDigits: max,
  });
  return formatter.format(value);
}

export function formatCurrency(value: number, locale: string, currency: string): string {
  if (!Number.isFinite(value)) return "—";
  try {
    return new Intl.NumberFormat(locale, {
      style: "currency",
      currency,
      maximumFractionDigits: 2,
    }).format(value);
  } catch {
    return `${value.toFixed(2)} ${currency}`;
  }
}

export function formatPercent(value: number, digits = 2): string {
  if (!Number.isFinite(value)) return "—";
  return `${(value * 100).toFixed(digits)}%`;
}

export function safeNumber(input: string): number {
  if (!input) return 0;
  const cleaned = input.replace(/,/g, "").trim();
  const n = Number(cleaned);
  return Number.isFinite(n) ? n : 0;
}
