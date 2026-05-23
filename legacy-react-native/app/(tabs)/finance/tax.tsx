import React, { useMemo, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { computeIncomeTax, salesTaxRate, type FilingStatus } from "@/app/lib/tax";
import { formatCurrency, formatPercent, safeNumber } from "@/app/lib/format";
import { useRegion } from "@/app/state/RegionProvider";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

type Mode = "income" | "sales";

export default function TaxCalc() {
  const { region } = useRegion();
  const [mode, setMode] = useState<Mode>("income");
  const [income, setIncome] = useState("");
  const [filing, setFiling] = useState<FilingStatus>("single");
  const [stateRatePct, setStateRatePct] = useState("0");
  const [salePrice, setSalePrice] = useState("");
  const [salesRatePct, setSalesRatePct] = useState((salesTaxRate[region.id] * 100).toFixed(1));

  const result = useMemo(() => {
    const gross = safeNumber(income);
    const stateRate = Math.max(0, Math.min(0.15, safeNumber(stateRatePct) / 100));
    return computeIncomeTax(gross, region.id, filing, {
      applyStandardDeduction: true,
      stateLocalRate: stateRate,
    });
  }, [income, filing, stateRatePct, region.id]);

  const sales = useMemo(() => {
    const price = safeNumber(salePrice);
    const rate = safeNumber(salesRatePct) / 100;
    const tax = price * rate;
    return { tax, total: price + tax };
  }, [salePrice, salesRatePct]);

  const cur = (n: number) => formatCurrency(n, region.locale, region.currency);

  return (
    <Screen>
      <PageHeader title="Tax" subtitle={`${region.flag} ${region.label} · ${region.currency}`} />

      <View style={styles.modeRow}>
        <ModePill label="Income" active={mode === "income"} onPress={() => setMode("income")} />
        <ModePill label="Sales / VAT" active={mode === "sales"} onPress={() => setMode("sales")} />
      </View>

      {mode === "income" ? (
        <>
          <NumberInput label={`Annual gross (${region.currency})`} value={income} onChangeText={setIncome} placeholder="0" />
          <Text style={styles.section}>Filing status</Text>
          <ChipPicker
            options={[
              { id: "single", label: "Single" },
              { id: "joint", label: "Joint" },
              { id: "head", label: "Head" },
            ]}
            value={filing}
            onChange={setFiling}
          />
          <NumberInput label="State / local rate (%)" value={stateRatePct} onChangeText={setStateRatePct} placeholder="0" />

          <View style={{ marginTop: spacing.lg }}>
            <ResultRow label="Taxable income" value={cur(result.taxableIncome)} />
            <ResultRow label="Tax owed" value={cur(result.taxOwed)} highlight />
            <ResultRow label="Effective rate" value={formatPercent(result.effectiveRate, 2)} />
            <ResultRow label="Marginal rate" value={formatPercent(result.marginalRate, 2)} />
            <ResultRow label="Take-home (year)" value={cur(result.takeHome)} highlight />
            <ResultRow label="Take-home (month)" value={cur(result.takeHomeMonthly)} />
          </View>
        </>
      ) : (
        <>
          <NumberInput label={`Sale price (${region.currency})`} value={salePrice} onChangeText={setSalePrice} />
          <NumberInput label="Tax rate (%)" value={salesRatePct} onChangeText={setSalesRatePct} />
          <View style={{ marginTop: spacing.lg }}>
            <ResultRow label="Tax amount" value={cur(sales.tax)} />
            <ResultRow label="Total with tax" value={cur(sales.total)} highlight />
          </View>
        </>
      )}
    </Screen>
  );
}

function ModePill({ label, active, onPress }: { label: string; active: boolean; onPress: () => void }) {
  return (
    <Pressable
      style={[styles.modePill, active && styles.modePillActive]}
      onPress={onPress}
      accessibilityRole="button"
    >
      <Text style={[styles.modeLabel, active && styles.modeLabelActive]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  modeRow: { flexDirection: "row", gap: spacing.sm, marginTop: spacing.lg },
  modePill: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    paddingVertical: 12,
    alignItems: "center",
    borderWidth: 1,
    borderColor: colors.border,
  },
  modePillActive: { backgroundColor: colors.text, borderColor: colors.text },
  modeLabel: { color: colors.text, fontWeight: fontWeight.semibold, fontSize: fontSize.caption + 1 },
  modeLabelActive: { color: colors.bg },
  section: {
    color: colors.textMuted,
    fontSize: fontSize.caption,
    fontWeight: fontWeight.medium,
    marginTop: spacing.md,
    marginBottom: spacing.sm,
    marginLeft: 2,
  },
});
