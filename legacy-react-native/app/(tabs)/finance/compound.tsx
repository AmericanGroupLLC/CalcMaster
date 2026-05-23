import React, { useMemo, useState } from "react";
import { View, Text } from "react-native";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatCurrency, safeNumber } from "@/app/lib/format";
import { useRegion } from "@/app/state/RegionProvider";
import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

type Freq = "1" | "4" | "12" | "365";

export default function CompoundCalc() {
  const { region } = useRegion();
  const [principal, setPrincipal] = useState("");
  const [ratePct, setRatePct] = useState("7");
  const [years, setYears] = useState("10");
  const [freq, setFreq] = useState<Freq>("12");
  const [contribution, setContribution] = useState("");

  const calc = useMemo(() => {
    const P = safeNumber(principal);
    const r = safeNumber(ratePct) / 100;
    const t = safeNumber(years);
    const n = Number(freq);
    const PMT = safeNumber(contribution);
    if (n <= 0 || t <= 0 || r < 0) return { future: P, contributed: P, interest: 0 };
    const future = P * Math.pow(1 + r / n, n * t) + (PMT > 0 ? PMT * ((Math.pow(1 + r / n, n * t) - 1) / (r / n)) : 0);
    const contributed = P + PMT * n * t;
    const interest = future - contributed;
    return { future, contributed, interest };
  }, [principal, ratePct, years, freq, contribution]);

  const cur = (n: number) => formatCurrency(n, region.locale, region.currency);

  return (
    <Screen>
      <PageHeader title="Compound Interest" subtitle="Future value of an investment" />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label={`Principal (${region.currency})`} value={principal} onChangeText={setPrincipal} />
        <NumberInput label="Annual rate (%)" value={ratePct} onChangeText={setRatePct} />
        <NumberInput label="Years" value={years} onChangeText={setYears} />
        <NumberInput label={`Monthly contribution (${region.currency}, optional)`} value={contribution} onChangeText={setContribution} />
        <Text style={{ color: colors.textMuted, fontSize: fontSize.caption, fontWeight: fontWeight.medium, marginTop: spacing.md, marginBottom: spacing.sm, marginLeft: 2 }}>
          Compounding frequency
        </Text>
        <ChipPicker
          options={[
            { id: "1", label: "Annually" },
            { id: "4", label: "Quarterly" },
            { id: "12", label: "Monthly" },
            { id: "365", label: "Daily" },
          ]}
          value={freq}
          onChange={setFreq}
        />
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow label="Future value" value={cur(calc.future)} highlight />
        <ResultRow label="Total contributed" value={cur(calc.contributed)} />
        <ResultRow label="Interest earned" value={cur(calc.interest)} />
      </View>
    </Screen>
  );
}
