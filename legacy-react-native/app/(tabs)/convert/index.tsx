import React, { useState } from "react";
import { StyleSheet, Text, View } from "react-native";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";

import { ConvertCard } from "@/app/components/ConvertCard";
import { RegionPill } from "@/app/components/RegionPill";
import { RegionPickerSheet } from "@/app/components/RegionPickerSheet";
import { Screen } from "@/app/components/Screen";
import { categoryList, type Category } from "@/app/lib/units";
import { accents, colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

export default function ConvertHome() {
  const router = useRouter();
  const [pickerOpen, setPickerOpen] = useState(false);

  // Render in 2-col grid: chunk into pairs
  const rows: Category[][] = [];
  for (let i = 0; i < categoryList.length; i += 2) {
    rows.push(categoryList.slice(i, i + 2));
  }

  return (
    <Screen>
      <View style={styles.headerRow}>
        <View style={{ flex: 1 }}>
          <Text style={styles.brand}>CalcMaster</Text>
          <Text style={styles.tagline}>World calculator & converter</Text>
        </View>
        <RegionPill onLongPress={() => setPickerOpen(true)} />
      </View>

      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Convert</Text>
        <Text style={styles.sectionSubtitle}>Tap any unit to convert instantly</Text>
      </View>

      <View style={styles.grid}>
        {rows.map((row, idx) => (
          <View key={idx} style={styles.gridRow}>
            {row.map((cat) => (
              <ConvertCard
                key={cat.id}
                title={cat.label}
                subtitle={cat.subtitle}
                accent={cat.accent}
                hint={cat.thumbHint}
                iconNode={
                  <Ionicons name={cat.iconName as never} size={26} color={accents[cat.accent]} />
                }
                onPress={() => router.push(`/convert/${cat.id}` as never)}
              />
            ))}
            {row.length === 1 ? <View style={{ flex: 1 }} /> : null}
          </View>
        ))}
      </View>

      <RegionPickerSheet visible={pickerOpen} onClose={() => setPickerOpen(false)} />
    </Screen>
  );
}

const styles = StyleSheet.create({
  headerRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    paddingTop: spacing.sm,
    paddingBottom: spacing.md,
  },
  brand: { color: colors.text, fontSize: fontSize.display, fontWeight: fontWeight.bold, letterSpacing: -0.5 },
  tagline: { color: colors.textMuted, fontSize: fontSize.body, marginTop: 2 },
  sectionHeader: { marginTop: spacing.xl, marginBottom: spacing.md },
  sectionTitle: { color: colors.text, fontSize: fontSize.h1, fontWeight: fontWeight.bold },
  sectionSubtitle: { color: colors.textMuted, fontSize: fontSize.body, marginTop: 2 },
  grid: { gap: spacing.md },
  gridRow: { flexDirection: "row", gap: spacing.md },
});
