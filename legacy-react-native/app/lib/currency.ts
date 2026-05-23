// Region definitions + currency rate fetcher with offline-safe fallback.

export type RegionId = "US" | "UK" | "EU" | "CA" | "AU" | "IN" | "JP";

export type Region = {
  id: RegionId;
  label: string;
  flag: string;
  currency: string; // ISO 4217 code
  symbol: string;
  locale: string; // BCP 47 locale used for Intl formatting
};

export const regions: Region[] = [
  { id: "US", label: "US", flag: "🇺🇸", currency: "USD", symbol: "$", locale: "en-US" },
  { id: "UK", label: "UK", flag: "🇬🇧", currency: "GBP", symbol: "£", locale: "en-GB" },
  { id: "EU", label: "EU", flag: "🇪🇺", currency: "EUR", symbol: "€", locale: "de-DE" },
  { id: "CA", label: "CA", flag: "🇨🇦", currency: "CAD", symbol: "C$", locale: "en-CA" },
  { id: "AU", label: "AU", flag: "🇦🇺", currency: "AUD", symbol: "A$", locale: "en-AU" },
  { id: "IN", label: "IN", flag: "🇮🇳", currency: "INR", symbol: "₹", locale: "en-IN" },
  { id: "JP", label: "JP", flag: "🇯🇵", currency: "JPY", symbol: "¥", locale: "ja-JP" },
];

export function getRegion(id: RegionId): Region {
  return regions.find((r) => r.id === id) ?? regions[0];
}

// Static fallback rates (keyed on ISO code, expressed as units of currency per 1 USD).
// Roughly accurate to mid-2025 — used only when the live API is unreachable.
// Last refreshed: 2025-10-01.
export const STATIC_RATES: Record<string, number> = {
  USD: 1,
  EUR: 0.92,
  GBP: 0.78,
  CAD: 1.36,
  AUD: 1.5,
  INR: 83.4,
  JPY: 149.2,
  CHF: 0.88,
  CNY: 7.18,
  MXN: 17.1,
  BRL: 5.05,
  KRW: 1310,
  SGD: 1.34,
  HKD: 7.81,
  NZD: 1.62,
  ZAR: 18.4,
  SEK: 10.4,
  NOK: 10.5,
  DKK: 6.85,
};

const RATES_API = "https://api.frankfurter.app/latest?from=USD";

export async function fetchLatestRates(): Promise<{ rates: Record<string, number>; fetchedAt: number; live: boolean }> {
  try {
    const res = await fetch(RATES_API, { method: "GET" });
    if (!res.ok) throw new Error(`Status ${res.status}`);
    const data = (await res.json()) as { rates?: Record<string, number> };
    if (!data.rates) throw new Error("Missing rates");
    const merged = { USD: 1, ...data.rates };
    return { rates: merged, fetchedAt: Date.now(), live: true };
  } catch {
    return { rates: STATIC_RATES, fetchedAt: Date.now(), live: false };
  }
}

export function convertCurrency(amount: number, from: string, to: string, rates: Record<string, number>): number {
  if (!Number.isFinite(amount)) return NaN;
  const fromR = rates[from] ?? STATIC_RATES[from];
  const toR = rates[to] ?? STATIC_RATES[to];
  if (!fromR || !toR) return NaN;
  // amount is in `from` currency. Convert to USD first (amount / fromR), then to target.
  return (amount / fromR) * toR;
}
