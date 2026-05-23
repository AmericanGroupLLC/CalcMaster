import React, { useMemo, useState } from "react";
import { Text, View } from "react-native";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatNumber, safeNumber } from "@/app/lib/format";
import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

type Mode = "adc" | "dac";

export default function AdcDac() {
  const [mode, setMode] = useState<Mode>("adc");
  const [bits, setBits] = useState("12");
  const [vref, setVref] = useState("3.3");
  const [analog, setAnalog] = useState("");
  const [digital, setDigital] = useState("");

  const out = useMemo(() => {
    const n = Math.max(1, Math.round(safeNumber(bits)));
    const ref = safeNumber(vref);
    const max = Math.pow(2, n) - 1;
    if (mode === "adc") {
      const v = safeNumber(analog);
      if (ref <= 0) return { code: NaN, max, lsb: 0 };
      const code = Math.max(0, Math.min(max, Math.round((v / ref) * max)));
      return { code, max, lsb: ref / Math.pow(2, n) };
    } else {
      const code = Math.max(0, Math.min(max, Math.round(safeNumber(digital))));
      const v = (code / max) * ref;
      return { voltage: v, max, lsb: ref / Math.pow(2, n) };
    }
  }, [mode, bits, vref, analog, digital]);

  return (
    <Screen>
      <PageHeader title="ADC / DAC" subtitle={mode === "adc" ? "Analog → Digital" : "Digital → Analog"} />
      <View style={{ marginTop: spacing.lg }}>
        <ChipPicker
          options={[
            { id: "adc", label: "ADC" },
            { id: "dac", label: "DAC" },
          ]}
          value={mode}
          onChange={setMode}
        />
        <NumberInput label="Resolution (bits)" value={bits} onChangeText={setBits} keyboardType="numeric" />
        <NumberInput label="Reference voltage (V)" value={vref} onChangeText={setVref} />
        {mode === "adc" ? (
          <NumberInput label="Analog input (V)" value={analog} onChangeText={setAnalog} />
        ) : (
          <NumberInput label="Digital code" value={digital} onChangeText={setDigital} keyboardType="numeric" />
        )}
      </View>
      <Text style={{ color: colors.textMuted, fontSize: fontSize.caption, fontWeight: fontWeight.medium, marginTop: spacing.lg, marginBottom: spacing.sm, marginLeft: 2 }}>
        Result
      </Text>
      {mode === "adc" ? (
        <>
          <ResultRow label="Digital code (decimal)" value={Number.isFinite(out.code) ? `${out.code}` : "—"} highlight />
          <ResultRow
            label="Digital code (hex)"
            value={Number.isFinite(out.code) ? `0x${(out.code as number).toString(16).toUpperCase()}` : "—"}
          />
        </>
      ) : (
        <ResultRow label="Analog output (V)" value={Number.isFinite((out as any).voltage) ? `${formatNumber((out as any).voltage)} V` : "—"} highlight />
      )}
      <ResultRow label="Full-scale code" value={`${out.max}`} />
      <ResultRow label="LSB step" value={`${formatNumber(out.lsb)} V`} />
    </Screen>
  );
}
