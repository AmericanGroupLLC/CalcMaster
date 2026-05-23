import React, { useMemo, useState } from "react";
import { Text, View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatNumber, safeNumber } from "@/app/lib/format";
import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

// Solve V = I × R, P = V × I given any two of {V, I, R, P}.
function solve(values: { V?: number; I?: number; R?: number; P?: number }) {
  let { V, I, R, P } = values;
  for (let pass = 0; pass < 4; pass++) {
    if (V == null && I != null && R != null) V = I * R;
    if (V == null && P != null && I != null && I !== 0) V = P / I;
    if (V == null && P != null && R != null && R > 0) V = Math.sqrt(P * R);
    if (I == null && V != null && R != null && R !== 0) I = V / R;
    if (I == null && P != null && V != null && V !== 0) I = P / V;
    if (I == null && P != null && R != null && R > 0) I = Math.sqrt(P / R);
    if (R == null && V != null && I != null && I !== 0) R = V / I;
    if (R == null && V != null && P != null && P !== 0) R = (V * V) / P;
    if (R == null && P != null && I != null && I !== 0) R = P / (I * I);
    if (P == null && V != null && I != null) P = V * I;
    if (P == null && V != null && R != null && R !== 0) P = (V * V) / R;
    if (P == null && I != null && R != null) P = I * I * R;
  }
  return { V, I, R, P };
}

export default function OhmCalc() {
  const [v, setV] = useState("");
  const [i, setI] = useState("");
  const [r, setR] = useState("");
  const [p, setP] = useState("");

  const { V, I, R, P } = useMemo(() => {
    const inputs: { V?: number; I?: number; R?: number; P?: number } = {};
    if (v.trim()) inputs.V = safeNumber(v);
    if (i.trim()) inputs.I = safeNumber(i);
    if (r.trim()) inputs.R = safeNumber(r);
    if (p.trim()) inputs.P = safeNumber(p);
    return solve(inputs);
  }, [v, i, r, p]);

  return (
    <Screen>
      <PageHeader title="Ohm's Law" subtitle="Enter any two values" />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label="Voltage (V)" value={v} onChangeText={setV} />
        <NumberInput label="Current (A)" value={i} onChangeText={setI} />
        <NumberInput label="Resistance (Ω)" value={r} onChangeText={setR} />
        <NumberInput label="Power (W)" value={p} onChangeText={setP} />
      </View>
      <Text style={{ color: colors.textMuted, fontSize: fontSize.caption, fontWeight: fontWeight.medium, marginTop: spacing.lg, marginBottom: spacing.sm, marginLeft: 2 }}>
        Solved
      </Text>
      <ResultRow label="V" caption="Voltage" value={Number.isFinite(V) ? `${formatNumber(V!)} V` : "—"} highlight={Number.isFinite(V) && !v.trim()} />
      <ResultRow label="I" caption="Current" value={Number.isFinite(I) ? `${formatNumber(I!)} A` : "—"} highlight={Number.isFinite(I) && !i.trim()} />
      <ResultRow label="R" caption="Resistance" value={Number.isFinite(R) ? `${formatNumber(R!)} Ω` : "—"} highlight={Number.isFinite(R) && !r.trim()} />
      <ResultRow label="P" caption="Power" value={Number.isFinite(P) ? `${formatNumber(P!)} W` : "—"} highlight={Number.isFinite(P) && !p.trim()} />
    </Screen>
  );
}
