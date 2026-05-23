import React, { useMemo, useState } from "react";
import { View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatNumber, safeNumber } from "@/app/lib/format";
import { spacing } from "@/app/theme/tokens";

export default function AspectRatio() {
  const [w1, setW1] = useState("1920");
  const [h1, setH1] = useState("1080");
  const [w2, setW2] = useState("");
  const [h2, setH2] = useState("");

  const result = useMemo(() => {
    const W1 = safeNumber(w1);
    const H1 = safeNumber(h1);
    const W2 = w2.trim() ? safeNumber(w2) : NaN;
    const H2 = h2.trim() ? safeNumber(h2) : NaN;
    if (W1 <= 0 || H1 <= 0) return { ratio: NaN, missing: "" };
    const ratio = W1 / H1;
    if (Number.isFinite(W2) && !Number.isFinite(H2)) {
      return { ratio, computed: { label: "Solved height", value: W2 / ratio, suffix: "px" } };
    }
    if (Number.isFinite(H2) && !Number.isFinite(W2)) {
      return { ratio, computed: { label: "Solved width", value: H2 * ratio, suffix: "px" } };
    }
    return { ratio };
  }, [w1, h1, w2, h2]);

  // Reduce to integer ratio (best-effort up to 1000)
  function reduce(W: number, H: number): string {
    if (!Number.isFinite(W) || !Number.isFinite(H) || W <= 0 || H <= 0) return "—";
    let best = { a: 0, b: 0, err: Infinity };
    const target = W / H;
    for (let b = 1; b <= 50; b++) {
      const a = Math.round(target * b);
      const err = Math.abs(target - a / b);
      if (err < best.err) best = { a, b, err };
    }
    return `${best.a}:${best.b}`;
  }

  return (
    <Screen>
      <PageHeader title="Aspect Ratio" subtitle="Solve missing W or H" />
      <View style={{ flexDirection: "row", gap: spacing.md, marginTop: spacing.lg }}>
        <View style={{ flex: 1 }}>
          <NumberInput label="W₁" value={w1} onChangeText={setW1} />
          <NumberInput label="H₁" value={h1} onChangeText={setH1} />
        </View>
        <View style={{ flex: 1 }}>
          <NumberInput label="W₂ (optional)" value={w2} onChangeText={setW2} />
          <NumberInput label="H₂ (optional)" value={h2} onChangeText={setH2} />
        </View>
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow label="Ratio (decimal)" value={Number.isFinite(result.ratio) ? formatNumber(result.ratio, { maxDigits: 4 }) : "—"} />
        <ResultRow label="Ratio (a:b)" value={reduce(safeNumber(w1), safeNumber(h1))} highlight />
        {result.computed ? (
          <ResultRow
            label={result.computed.label}
            value={`${formatNumber(result.computed.value, { maxDigits: 2 })} ${result.computed.suffix}`}
            highlight
          />
        ) : null}
      </View>
    </Screen>
  );
}
