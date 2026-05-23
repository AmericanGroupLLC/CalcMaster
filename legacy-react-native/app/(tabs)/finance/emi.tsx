import React, { useMemo, useState } from "react";
import { View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { formatCurrency, safeNumber } from "@/app/lib/format";
import { useRegion } from "@/app/state/RegionProvider";
import { spacing } from "@/app/theme/tokens";

export default function EmiCalc() {
  const { region } = useRegion();
  const [principal, setPrincipal] = useState("");
  const [ratePct, setRatePct] = useState("");
  const [years, setYears] = useState("");

  const calc = useMemo(() => {
    const P = safeNumber(principal);
    const r = safeNumber(ratePct) / 100 / 12;
    const n = safeNumber(years) * 12;
    if (P <= 0 || n <= 0 || r < 0) return { emi: 0, totalInterest: 0, totalPayable: 0 };
    if (r === 0) {
      const emi = P / n;
      return { emi, totalInterest: 0, totalPayable: P };
    }
    const factor = Math.pow(1 + r, n);
    const emi = (P * r * factor) / (factor - 1);
    const totalPayable = emi * n;
    return { emi, totalInterest: totalPayable - P, totalPayable };
  }, [principal, ratePct, years]);

  const cur = (n: number) => formatCurrency(n, region.locale, region.currency);

  return (
    <Screen>
      <PageHeader title="EMI / Loan" subtitle="Equated monthly installment" />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label={`Loan amount (${region.currency})`} value={principal} onChangeText={setPrincipal} />
        <NumberInput label="Annual rate (%)" value={ratePct} onChangeText={setRatePct} />
        <NumberInput label="Term (years)" value={years} onChangeText={setYears} />
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow label="Monthly EMI" value={cur(calc.emi)} highlight />
        <ResultRow label="Total interest" value={cur(calc.totalInterest)} />
        <ResultRow label="Total payable" value={cur(calc.totalPayable)} />
      </View>
    </Screen>
  );
}
