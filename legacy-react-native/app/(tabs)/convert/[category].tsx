import React, { useMemo, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Stack, useLocalSearchParams, useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";

import { ChipPicker } from "@/app/components/ChipPicker";
import { NumberInput } from "@/app/components/NumberInput";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { categories, convert, type CategoryId } from "@/app/lib/units";
import { formatNumber, safeNumber } from "@/app/lib/format";
import { useNotes } from "@/app/state/NotesProvider";
import { accents, colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

export default function ConvertDetail() {
  const router = useRouter();
  const { category } = useLocalSearchParams<{ category: string }>();
  const id = category as CategoryId;
  const cat = categories[id];
  const { add } = useNotes();

  const [fromUnit, setFromUnit] = useState<string>(cat?.units[0]?.id ?? "");
  const [valueText, setValueText] = useState<string>("1");

  if (!cat) {
    return (
      <Screen>
        <Text style={{ color: colors.text }}>Unknown category.</Text>
      </Screen>
    );
  }

  const numericValue = safeNumber(valueText);
  const accentColor = accents[cat.accent];

  const otherUnits = useMemo(() => cat.units.filter((u) => u.id !== fromUnit), [cat, fromUnit]);

  const fromUnitObj = cat.units.find((u) => u.id === fromUnit) ?? cat.units[0];

  return (
    <Screen>
      <View style={styles.headerRow}>
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel="Back"
        >
          <Ionicons name="chevron-back" size={28} color={colors.text} />
        </Pressable>
        <Text style={styles.title}>{cat.label}</Text>
        <View style={{ width: 28 }} />
      </View>
      <Text style={[styles.subtitle, { color: accentColor }]}>{cat.subtitle}</Text>

      <View style={{ marginTop: spacing.lg }}>
        <Text style={styles.sectionLabel}>From</Text>
        <ChipPicker
          options={cat.units.map((u) => ({ id: u.id, label: u.symbol }))}
          value={fromUnit}
          onChange={setFromUnit}
        />
      </View>

      <NumberInput
        value={valueText}
        onChangeText={setValueText}
        unitSymbol={fromUnitObj.symbol}
        autoFocus
      />

      <View style={{ marginTop: spacing.lg }}>
        <Text style={styles.sectionLabel}>Equivalents</Text>
        {otherUnits.map((u) => {
          const result = convert(numericValue, fromUnit, u.id, id);
          const formatted = `${formatNumber(result)} ${u.symbol}`;
          return (
            <ResultRow
              key={u.id}
              label={u.label}
              caption={u.symbol}
              value={formatted}
              onLongPress={() => {
                add(
                  `${cat.label}: ${valueText} ${fromUnitObj.symbol} → ${u.symbol}`,
                  formatted,
                );
              }}
            />
          );
        })}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  headerRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingTop: spacing.xs,
  },
  title: { color: colors.text, fontSize: fontSize.h2, fontWeight: fontWeight.bold },
  subtitle: { fontSize: fontSize.caption, marginTop: 2, marginLeft: 36, fontWeight: fontWeight.medium },
  sectionLabel: { color: colors.textMuted, fontSize: fontSize.caption, marginBottom: spacing.sm, marginLeft: 2 },
});
