import React, { useMemo, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { convertCurrency, regions, STATIC_RATES } from "@/app/lib/currency";
import { formatNumber, safeNumber } from "@/app/lib/format";
import { useRegion } from "@/app/state/RegionProvider";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

const POPULAR = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "INR", "CHF", "CNY", "MXN", "BRL", "KRW", "SGD"];

export default function CurrencyCalc() {
  const { region, rates, ratesLive, ratesUpdatedAt, refreshRates } = useRegion();
  const [from, setFrom] = useState<string>(region.currency);
  const [amount, setAmount] = useState("1");

  const allCodes = useMemo(() => {
    const set = new Set<string>([...regions.map((r) => r.currency), ...POPULAR, ...Object.keys(rates ?? {})]);
    return Array.from(set);
  }, [rates]);

  const num = safeNumber(amount);
  const lastUpdated = ratesUpdatedAt ? new Date(ratesUpdatedAt).toLocaleString(region.locale) : "—";

  return (
    <Screen>
      <PageHeader
        title="Currency"
        subtitle={ratesLive ? `Live · updated ${lastUpdated}` : `Offline rates · ${lastUpdated}`}
        right={
          <Pressable onPress={() => refreshRates()} hitSlop={10} accessibilityLabel="Refresh rates">
            <Ionicons name="refresh-outline" size={22} color={colors.textMuted} />
          </Pressable>
        }
      />

      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label="Amount" value={amount} onChangeText={setAmount} />
        <Text style={styles.section}>From</Text>
        <ChipPicker
          options={allCodes.map((c) => ({ id: c, label: c }))}
          value={from}
          onChange={setFrom}
        />
      </View>

      <View style={{ marginTop: spacing.lg }}>
        {allCodes
          .filter((c) => c !== from)
          .slice(0, 18)
          .map((code) => {
            const v = convertCurrency(num, from, code, rates ?? STATIC_RATES);
            return (
              <ResultRow
                key={code}
                label={code}
                value={Number.isFinite(v) ? formatNumber(v) : "—"}
                highlight={code === region.currency}
              />
            );
          })}
      </View>

      {!ratesLive && (
        <View style={styles.warn}>
          <Ionicons name="information-circle-outline" size={16} color={colors.warning} />
          <Text style={styles.warnText}>Live rates are unavailable. Showing approximate offline rates.</Text>
        </View>
      )}
    </Screen>
  );
}

const styles = StyleSheet.create({
  section: {
    color: colors.textMuted,
    fontSize: fontSize.caption,
    fontWeight: fontWeight.medium,
    marginTop: spacing.md,
    marginBottom: spacing.sm,
    marginLeft: 2,
  },
  warn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    marginTop: spacing.md,
    borderWidth: 1,
    borderColor: colors.warning + "55",
  },
  warnText: { color: colors.textMuted, fontSize: fontSize.caption },
});
