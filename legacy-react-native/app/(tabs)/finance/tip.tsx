import React, { useMemo, useState } from "react";
import { View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatCurrency, safeNumber } from "@/app/lib/format";
import { useRegion } from "@/app/state/RegionProvider";
import { spacing } from "@/app/theme/tokens";

export default function TipCalc() {
  const { region } = useRegion();
  const [bill, setBill] = useState("");
  const [tipPct, setTipPct] = useState("18");
  const [people, setPeople] = useState("2");

  const calc = useMemo(() => {
    const b = safeNumber(bill);
    const t = safeNumber(tipPct) / 100;
    const p = Math.max(1, Math.round(safeNumber(people)) || 1);
    const tip = b * t;
    const total = b + tip;
    return { tip, total, perPerson: total / p, tipPerPerson: tip / p };
  }, [bill, tipPct, people]);

  const cur = (n: number) => formatCurrency(n, region.locale, region.currency);

  return (
    <Screen>
      <PageHeader title="Tip & Split" subtitle={`${region.flag} ${region.currency}`} />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label={`Bill (${region.currency})`} value={bill} onChangeText={setBill} />
        <NumberInput label="Tip %" value={tipPct} onChangeText={setTipPct} />
        <NumberInput label="People" value={people} onChangeText={setPeople} keyboardType="numeric" />
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow label="Tip" value={cur(calc.tip)} />
        <ResultRow label="Total" value={cur(calc.total)} highlight />
        <ResultRow label="Per person" value={cur(calc.perPerson)} highlight />
        <ResultRow label="Tip per person" value={cur(calc.tipPerPerson)} />
      </View>
    </Screen>
  );
}
