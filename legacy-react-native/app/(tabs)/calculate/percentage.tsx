import React, { useMemo, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatNumber, formatPercent, safeNumber } from "@/app/lib/format";
import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

export default function PercentageCalc() {
  const [a, setA] = useState("");
  const [b, setB] = useState("");

  const A = safeNumber(a);
  const B = safeNumber(b);

  const xPercentOfY = (A / 100) * B;
  const xIsWhatPercentOfY = B === 0 ? NaN : A / B;
  const percentChange = A === 0 ? NaN : (B - A) / A;

  return (
    <Screen>
      <PageHeader title="Percentage" subtitle="Three live percentage scenarios" />
      <View style={{ flexDirection: "row", gap: spacing.md, marginTop: spacing.lg }}>
        <View style={{ flex: 1 }}>
          <NumberInput label="X" value={a} onChangeText={setA} placeholder="X" />
        </View>
        <View style={{ flex: 1 }}>
          <NumberInput label="Y" value={b} onChangeText={setB} placeholder="Y" />
        </View>
      </View>

      <View style={{ marginTop: spacing.lg }}>
        <Text style={styles.label}>X% of Y</Text>
        <ResultRow label={`${a || "0"}% of ${b || "0"}`} value={formatNumber(xPercentOfY)} />

        <Text style={[styles.label, { marginTop: spacing.lg }]}>X is what % of Y</Text>
        <ResultRow
          label={`${a || "0"} of ${b || "0"}`}
          value={Number.isFinite(xIsWhatPercentOfY) ? formatPercent(xIsWhatPercentOfY) : "—"}
        />

        <Text style={[styles.label, { marginTop: spacing.lg }]}>% change from X to Y</Text>
        <ResultRow
          label={`Change`}
          value={Number.isFinite(percentChange) ? formatPercent(percentChange) : "—"}
          highlight={Number.isFinite(percentChange)}
        />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  label: { color: colors.textMuted, fontSize: fontSize.caption, fontWeight: fontWeight.medium, marginBottom: 4, marginLeft: 2 },
});
