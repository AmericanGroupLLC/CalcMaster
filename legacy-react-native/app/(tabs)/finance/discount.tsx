import React, { useMemo, useState } from "react";
import { View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatCurrency, formatPercent, safeNumber } from "@/app/lib/format";
import { useRegion } from "@/app/state/RegionProvider";
import { spacing } from "@/app/theme/tokens";

export default function DiscountCalc() {
  const { region } = useRegion();
  const [original, setOriginal] = useState("");
  const [pct, setPct] = useState("");

  const calc = useMemo(() => {
    const o = safeNumber(original);
    const p = safeNumber(pct) / 100;
    const savings = o * p;
    const final = o - savings;
    return { savings, final, effectiveRate: o ? savings / o : NaN };
  }, [original, pct]);

  const cur = (n: number) => formatCurrency(n, region.locale, region.currency);

  return (
    <Screen>
      <PageHeader title="Discount" subtitle="Final price + savings" />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label={`Original (${region.currency})`} value={original} onChangeText={setOriginal} />
        <NumberInput label="Discount %" value={pct} onChangeText={setPct} />
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow label="You save" value={cur(calc.savings)} />
        <ResultRow label="Final price" value={cur(calc.final)} highlight />
        <ResultRow label="Effective discount" value={Number.isFinite(calc.effectiveRate) ? formatPercent(calc.effectiveRate) : "—"} />
      </View>
    </Screen>
  );
}
