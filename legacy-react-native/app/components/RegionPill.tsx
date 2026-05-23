import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";

import { useRegion } from "@/app/state/RegionProvider";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

/** Top-right pill in the Convert header showing pin · flag · region · currency symbol. */
export function RegionPill({ onLongPress }: { onLongPress?: () => void }) {
  const { region, cycleRegion } = useRegion();
  return (
    <Pressable
      onPress={() => {
        Haptics.selectionAsync();
        cycleRegion();
      }}
      onLongPress={onLongPress}
      android_ripple={{ color: "rgba(255,255,255,0.06)", borderless: false }}
      style={({ pressed }) => [styles.pill, pressed && { opacity: 0.85 }]}
      accessibilityRole="button"
      accessibilityLabel={`Region ${region.label}, currency ${region.currency}. Tap to cycle, long press to pick.`}
    >
      <Ionicons name="location-outline" size={14} color={colors.text} />
      <Text style={styles.flag}>{region.flag}</Text>
      <Text style={styles.label}>{region.label}</Text>
      <Text style={styles.dot}>·</Text>
      <Text style={styles.symbol}>{region.symbol}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  pill: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surface,
    borderRadius: radii.pill,
    paddingHorizontal: spacing.md,
    paddingVertical: 8,
    gap: 6,
    borderWidth: 1,
    borderColor: colors.border,
  },
  flag: { fontSize: 16 },
  label: { color: colors.text, fontWeight: fontWeight.semibold, fontSize: fontSize.caption + 1 },
  dot: { color: colors.textMuted, marginHorizontal: 1 },
  symbol: { color: colors.text, fontWeight: fontWeight.semibold, fontSize: fontSize.caption + 1 },
});
