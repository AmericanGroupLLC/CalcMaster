import React, { useMemo, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { safeNumber } from "@/app/lib/format";
import { simplifyFraction } from "@/app/lib/calc";
import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

type Op = "+" | "-" | "×" | "÷";
const OPS: Op[] = ["+", "-", "×", "÷"];

function compute(n1: number, d1: number, n2: number, d2: number, op: Op): { n: number; d: number } {
  if (d1 === 0 || d2 === 0) return { n: NaN, d: 0 };
  switch (op) {
    case "+":
      return simplifyFraction(n1 * d2 + n2 * d1, d1 * d2);
    case "-":
      return simplifyFraction(n1 * d2 - n2 * d1, d1 * d2);
    case "×":
      return simplifyFraction(n1 * n2, d1 * d2);
    case "÷":
      if (n2 === 0) return { n: NaN, d: 0 };
      return simplifyFraction(n1 * d2, d1 * n2);
  }
}

function toMixed(n: number, d: number): string {
  if (d === 0 || !Number.isFinite(n)) return "—";
  const whole = Math.trunc(n / d);
  const remainder = Math.abs(n - whole * d);
  if (remainder === 0) return `${whole}`;
  if (whole === 0) return `${n}/${d}`;
  return `${whole} ${remainder}/${d}`;
}

export default function FractionCalc() {
  const [n1, setN1] = useState("1");
  const [d1, setD1] = useState("2");
  const [n2, setN2] = useState("1");
  const [d2, setD2] = useState("3");
  const [op, setOp] = useState<Op>("+");

  const result = useMemo(
    () => compute(safeNumber(n1), safeNumber(d1), safeNumber(n2), safeNumber(d2), op),
    [n1, d1, n2, d2, op],
  );

  const decimal = Number.isFinite(result.n) && result.d !== 0 ? result.n / result.d : NaN;

  return (
    <Screen>
      <PageHeader title="Fraction" subtitle="Add, subtract, multiply, divide" />

      <View style={{ flexDirection: "row", gap: spacing.md, marginTop: spacing.lg }}>
        <View style={{ flex: 1 }}>
          <NumberInput label="Numerator A" value={n1} onChangeText={setN1} keyboardType="numeric" />
          <NumberInput label="Denominator A" value={d1} onChangeText={setD1} keyboardType="numeric" />
        </View>
        <View style={{ flex: 1 }}>
          <NumberInput label="Numerator B" value={n2} onChangeText={setN2} keyboardType="numeric" />
          <NumberInput label="Denominator B" value={d2} onChangeText={setD2} keyboardType="numeric" />
        </View>
      </View>

      <Text style={styles.label}>Operator</Text>
      <ChipPicker options={OPS.map((o) => ({ id: o, label: o }))} value={op} onChange={setOp} />

      <View style={{ marginTop: spacing.lg }}>
        <ResultRow
          label="Simplified"
          value={Number.isFinite(result.n) && result.d !== 0 ? `${result.n}/${result.d}` : "—"}
          highlight
        />
        <ResultRow label="Mixed number" value={toMixed(result.n, result.d)} />
        <ResultRow label="Decimal" value={Number.isFinite(decimal) ? decimal.toString() : "—"} />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  label: {
    color: colors.textMuted,
    fontSize: fontSize.caption,
    fontWeight: fontWeight.medium,
    marginTop: spacing.md,
    marginBottom: spacing.sm,
    marginLeft: 2,
  },
});
