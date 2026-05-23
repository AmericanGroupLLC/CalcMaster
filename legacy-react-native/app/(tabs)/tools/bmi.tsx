import React, { useMemo, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatNumber, safeNumber } from "@/app/lib/format";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

type System = "metric" | "imperial";

function bmiCategory(bmi: number): { label: string; color: string } {
  if (!Number.isFinite(bmi) || bmi <= 0) return { label: "—", color: colors.textMuted };
  if (bmi < 18.5) return { label: "Underweight", color: "#7CC8FF" };
  if (bmi < 25) return { label: "Healthy weight", color: colors.success };
  if (bmi < 30) return { label: "Overweight", color: colors.warning };
  return { label: "Obese", color: colors.danger };
}

export default function BmiCalc() {
  const [system, setSystem] = useState<System>("metric");
  const [height, setHeight] = useState("");
  const [weight, setWeight] = useState("");

  const bmi = useMemo(() => {
    const h = safeNumber(height);
    const w = safeNumber(weight);
    if (h <= 0 || w <= 0) return NaN;
    if (system === "metric") {
      // height cm, weight kg
      const hm = h / 100;
      return w / (hm * hm);
    }
    // imperial: height in, weight lb
    return (703 * w) / (h * h);
  }, [height, weight, system]);

  const cat = bmiCategory(bmi);

  return (
    <Screen>
      <PageHeader title="BMI" subtitle="Body Mass Index" />
      <View style={{ marginTop: spacing.lg }}>
        <Text style={styles.label}>Units</Text>
        <ChipPicker
          options={[
            { id: "metric", label: "Metric (cm, kg)" },
            { id: "imperial", label: "Imperial (in, lb)" },
          ]}
          value={system}
          onChange={setSystem}
        />
      </View>
      <NumberInput label={system === "metric" ? "Height (cm)" : "Height (in)"} value={height} onChangeText={setHeight} />
      <NumberInput label={system === "metric" ? "Weight (kg)" : "Weight (lb)"} value={weight} onChangeText={setWeight} />

      <View style={[styles.banner, { borderColor: cat.color + "55" }]}>
        <Text style={styles.bmiValue}>{Number.isFinite(bmi) ? formatNumber(bmi, { maxDigits: 1 }) : "—"}</Text>
        <Text style={[styles.bmiCategory, { color: cat.color }]}>{cat.label}</Text>
      </View>

      <ResultRow label="Healthy range" value="18.5 – 24.9" />
    </Screen>
  );
}

const styles = StyleSheet.create({
  label: { color: colors.textMuted, fontSize: fontSize.caption, fontWeight: fontWeight.medium, marginBottom: spacing.sm, marginLeft: 2 },
  banner: {
    backgroundColor: colors.surface,
    borderRadius: radii.card,
    padding: spacing.lg,
    marginTop: spacing.lg,
    borderWidth: 1,
    alignItems: "center",
  },
  bmiValue: { color: colors.text, fontSize: fontSize.display, fontWeight: fontWeight.bold },
  bmiCategory: { fontSize: fontSize.body, fontWeight: fontWeight.semibold, marginTop: 4 },
});
