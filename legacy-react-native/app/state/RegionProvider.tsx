import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import * as Localization from "expo-localization";

import { regions, type Region, type RegionId, fetchLatestRates, STATIC_RATES } from "@/app/lib/currency";
import { readJSON, writeJSON } from "@/app/lib/storage";

type RegionContextValue = {
  region: Region;
  setRegion: (id: RegionId) => void;
  cycleRegion: () => void;
  rates: Record<string, number>;
  ratesLive: boolean;
  ratesUpdatedAt: number | null;
  refreshRates: () => Promise<void>;
};

const STORAGE_KEY_REGION = "region";
const STORAGE_KEY_RATES = "rates-cache";
const RATE_TTL_MS = 24 * 60 * 60 * 1000;

const RegionContext = createContext<RegionContextValue | null>(null);

function detectDefaultRegion(): RegionId {
  try {
    const locales = Localization.getLocales?.();
    const code = locales?.[0]?.regionCode?.toUpperCase();
    if (code === "US") return "US";
    if (code === "GB") return "UK";
    if (code === "CA") return "CA";
    if (code === "AU") return "AU";
    if (code === "IN") return "IN";
    if (code === "JP") return "JP";
    if (code && ["DE", "FR", "ES", "IT", "NL", "BE", "AT", "PT", "IE", "FI", "GR"].includes(code)) return "EU";
  } catch {
    /* ignore */
  }
  return "US";
}

export function RegionProvider({ children }: { children: React.ReactNode }) {
  const [regionId, setRegionId] = useState<RegionId>(() => detectDefaultRegion());
  const [rates, setRates] = useState<Record<string, number>>(STATIC_RATES);
  const [ratesLive, setRatesLive] = useState(false);
  const [ratesUpdatedAt, setRatesUpdatedAt] = useState<number | null>(null);

  // Hydrate persisted region
  useEffect(() => {
    let cancel = false;
    (async () => {
      const stored = await readJSON<{ regionId: RegionId }>(STORAGE_KEY_REGION);
      if (!cancel && stored?.regionId) setRegionId(stored.regionId);
    })();
    return () => {
      cancel = true;
    };
  }, []);

  // Hydrate cached rates and refresh if stale
  useEffect(() => {
    let cancel = false;
    (async () => {
      const cached = await readJSON<{ rates: Record<string, number>; fetchedAt: number; live: boolean }>(STORAGE_KEY_RATES);
      const fresh = cached && Date.now() - cached.fetchedAt < RATE_TTL_MS;
      if (cached && !cancel) {
        setRates(cached.rates);
        setRatesLive(cached.live);
        setRatesUpdatedAt(cached.fetchedAt);
      }
      if (!fresh) {
        const result = await fetchLatestRates();
        if (cancel) return;
        setRates(result.rates);
        setRatesLive(result.live);
        setRatesUpdatedAt(result.fetchedAt);
        writeJSON(STORAGE_KEY_RATES, result);
      }
    })();
    return () => {
      cancel = true;
    };
  }, []);

  const setRegion = useCallback((id: RegionId) => {
    setRegionId(id);
    writeJSON(STORAGE_KEY_REGION, { regionId: id });
  }, []);

  const cycleRegion = useCallback(() => {
    setRegionId((prev) => {
      const idx = regions.findIndex((r) => r.id === prev);
      const next = regions[(idx + 1) % regions.length].id;
      writeJSON(STORAGE_KEY_REGION, { regionId: next });
      return next;
    });
  }, []);

  const refreshRates = useCallback(async () => {
    const result = await fetchLatestRates();
    setRates(result.rates);
    setRatesLive(result.live);
    setRatesUpdatedAt(result.fetchedAt);
    writeJSON(STORAGE_KEY_RATES, result);
  }, []);

  const region = useMemo(() => regions.find((r) => r.id === regionId) ?? regions[0], [regionId]);

  const value = useMemo<RegionContextValue>(
    () => ({ region, setRegion, cycleRegion, rates, ratesLive, ratesUpdatedAt, refreshRates }),
    [region, setRegion, cycleRegion, rates, ratesLive, ratesUpdatedAt, refreshRates],
  );

  return <RegionContext.Provider value={value}>{children}</RegionContext.Provider>;
}

export function useRegion(): RegionContextValue {
  const ctx = useContext(RegionContext);
  if (!ctx) throw new Error("useRegion must be used inside <RegionProvider>");
  return ctx;
}
