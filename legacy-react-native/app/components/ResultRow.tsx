import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import * as Clipboard from "expo-clipboard";
import * as Haptics from "expo-haptics";

import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

type Props = {
  label: string;
  value: string;
  caption?: string;
  highlight?: boolean;
  onLongPress?: () => void;
};

/** A single row in a list of computed results — copy-to-clipboard on tap. */
export function ResultRow({ label, value, caption, highlight, onLongPress }: Props) {
  return (
    <Pressable
      onPress={async () => {
        await Clipboard.setStringAsync(value);
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      }}
      onLongPress={onLongPress}
      style={({ pressed }) => [
        styles.row,
        highlight && styles.highlight,
        pressed && { opacity: 0.85 },
      ]}
      accessibilityRole="button"
      accessibilityLabel={`${label}, ${value}. Tap to copy.`}
    >
      <View style={{ flex: 1 }}>
        <Text style={styles.label}>{label}</Text>
        {caption ? <Text style={styles.caption}>{caption}</Text> : null}
      </View>
      <Text style={[styles.value, highlight && styles.valueHighlight]} numberOfLines={1}>
        {value}
      </Text>
      <Ionicons name="copy-outline" size={16} color={colors.textDim} style={{ marginLeft: spacing.md }} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    marginVertical: 4,
    borderWidth: 1,
    borderColor: colors.border,
  },
  highlight: { backgroundColor: colors.surfaceAlt, borderColor: colors.borderStrong },
  label: { color: colors.text, fontSize: fontSize.body, fontWeight: fontWeight.semibold },
  caption: { color: colors.textMuted, fontSize: fontSize.caption, marginTop: 2 },
  value: { color: colors.text, fontSize: fontSize.body, fontWeight: fontWeight.semibold, maxWidth: "55%" },
  valueHighlight: { color: colors.success },
});
