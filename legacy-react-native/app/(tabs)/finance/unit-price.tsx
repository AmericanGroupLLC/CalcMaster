import React, { useMemo, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { Screen } from "@/app/components/Screen";
import { formatCurrency, safeNumber } from "@/app/lib/format";
import { useRegion } from "@/app/state/RegionProvider";
import { colors, fontSize, fontWeight, radii, shadow, spacing } from "@/app/theme/tokens";

export default function UnitPriceCalc() {
  const { region } = useRegion();
  const [priceA, setPriceA] = useState("");
  const [qtyA, setQtyA] = useState("");
  const [priceB, setPriceB] = useState("");
  const [qtyB, setQtyB] = useState("");

  const result = useMemo(() => {
    const pa = safeNumber(priceA);
    const qa = safeNumber(qtyA);
    const pb = safeNumber(priceB);
    const qb = safeNumber(qtyB);
    const upA = qa > 0 ? pa / qa : NaN;
    const upB = qb > 0 ? pb / qb : NaN;
    let cheaper: "A" | "B" | null = null;
    if (Number.isFinite(upA) && Number.isFinite(upB)) {
      cheaper = upA < upB ? "A" : upB < upA ? "B" : null;
    }
    return { upA, upB, cheaper };
  }, [priceA, qtyA, priceB, qtyB]);

  const cur = (n: number) => formatCurrency(n, region.locale, region.currency);

  return (
    <Screen>
      <PageHeader title="Unit Price" subtitle="Which pack is cheaper?" />
      <View style={{ flexDirection: "row", gap: spacing.md, marginTop: spacing.lg }}>
        <View style={[styles.card, result.cheaper === "A" && styles.cardWin]}>
          <Text style={styles.cardTitle}>Option A</Text>
          <NumberInput label={`Price (${region.currency})`} value={priceA} onChangeText={setPriceA} />
          <NumberInput label="Quantity" value={qtyA} onChangeText={setQtyA} />
          <Text style={styles.unitPriceLabel}>Per unit</Text>
          <Text style={[styles.unitPriceValue, result.cheaper === "A" && { color: colors.success }]}>
            {Number.isFinite(result.upA) ? cur(result.upA) : "—"}
          </Text>
        </View>
        <View style={[styles.card, result.cheaper === "B" && styles.cardWin]}>
          <Text style={styles.cardTitle}>Option B</Text>
          <NumberInput label={`Price (${region.currency})`} value={priceB} onChangeText={setPriceB} />
          <NumberInput label="Quantity" value={qtyB} onChangeText={setQtyB} />
          <Text style={styles.unitPriceLabel}>Per unit</Text>
          <Text style={[styles.unitPriceValue, result.cheaper === "B" && { color: colors.success }]}>
            {Number.isFinite(result.upB) ? cur(result.upB) : "—"}
          </Text>
        </View>
      </View>
      {result.cheaper ? (
        <Text style={styles.banner}>
          Option {result.cheaper} is cheaper per unit.
        </Text>
      ) : null}
    </Screen>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: radii.card,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.card,
  },
  cardWin: { borderColor: colors.success + "88" },
  cardTitle: { color: colors.text, fontWeight: fontWeight.bold, fontSize: fontSize.h3, marginBottom: spacing.xs },
  unitPriceLabel: { color: colors.textMuted, fontSize: fontSize.caption, marginTop: spacing.sm },
  unitPriceValue: { color: colors.text, fontSize: fontSize.h2, fontWeight: fontWeight.bold, marginTop: 4 },
  banner: { color: colors.success, fontSize: fontSize.body, fontWeight: fontWeight.semibold, marginTop: spacing.lg, textAlign: "center" },
});
