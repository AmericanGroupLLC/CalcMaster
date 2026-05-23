import React, { useMemo, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

type Base = "bin" | "oct" | "dec" | "hex";

const BASES: Base[] = ["bin", "oct", "dec", "hex"];

const RADIX: Record<Base, number> = { bin: 2, oct: 8, dec: 10, hex: 16 };

function parseInBase(input: string, base: Base): number {
  if (!input.trim()) return NaN;
  const n = parseInt(input, RADIX[base]);
  return Number.isFinite(n) ? n : NaN;
}

export default function BaseCalc() {
  const [base, setBase] = useState<Base>("dec");
  const [text, setText] = useState("255");

  const value = useMemo(() => parseInBase(text, base), [text, base]);

  const rep = (b: Base) => (Number.isFinite(value) ? value.toString(RADIX[b]).toUpperCase() : "—");

  return (
    <Screen>
      <PageHeader title="Base Converter" subtitle="Bin · Oct · Dec · Hex" />
      <View style={{ marginTop: spacing.lg }}>
        <Text style={styles.label}>Input base</Text>
        <ChipPicker
          options={BASES.map((b) => ({ id: b, label: b.toUpperCase() }))}
          value={base}
          onChange={setBase}
        />
      </View>
      <NumberInput
        value={text}
        onChangeText={setText}
        keyboardType={base === "dec" ? "decimal-pad" : "default"}
        placeholder={base === "hex" ? "FF" : "255"}
      />

      <View style={{ marginTop: spacing.md }}>
        <ResultRow label="Binary" caption="base 2" value={rep("bin")} />
        <ResultRow label="Octal" caption="base 8" value={rep("oct")} />
        <ResultRow label="Decimal" caption="base 10" value={rep("dec")} highlight />
        <ResultRow label="Hex" caption="base 16" value={rep("hex")} />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  label: { color: colors.textMuted, fontSize: fontSize.caption, fontWeight: fontWeight.medium, marginBottom: 4, marginLeft: 2 },
});
