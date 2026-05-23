import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";

import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

type Variant = "default" | "op" | "primary" | "muted";

export type KeyDef = {
  label: string;
  /** What to append/insert into the expression buffer; defaults to label. */
  insert?: string;
  variant?: Variant;
  flex?: number;
  /** Special action handled by parent; e.g. "clear", "back", "equals". */
  action?: "clear" | "back" | "equals" | "insert";
};

type Props = {
  rows: KeyDef[][];
  onPress: (key: KeyDef) => void;
};

export function KeyPad({ rows, onPress }: Props) {
  return (
    <View style={styles.pad}>
      {rows.map((row, rIdx) => (
        <View key={rIdx} style={styles.row}>
          {row.map((key, kIdx) => (
            <Pressable
              key={`${rIdx}-${kIdx}`}
              onPress={() => onPress(key)}
              style={({ pressed }) => [
                styles.btn,
                key.flex ? { flex: key.flex } : null,
                key.variant === "op" && styles.btnOp,
                key.variant === "primary" && styles.btnPrimary,
                key.variant === "muted" && styles.btnMuted,
                pressed && { opacity: 0.85 },
              ]}
              accessibilityRole="button"
              accessibilityLabel={key.label}
            >
              <Text
                style={[
                  styles.label,
                  key.variant === "op" && styles.labelOp,
                  key.variant === "primary" && styles.labelPrimary,
                  key.variant === "muted" && styles.labelMuted,
                ]}
              >
                {key.label}
              </Text>
            </Pressable>
          ))}
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  pad: { gap: spacing.sm, marginTop: spacing.lg },
  row: { flexDirection: "row", gap: spacing.sm },
  btn: {
    flex: 1,
    paddingVertical: 18,
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: colors.border,
  },
  btnOp: { backgroundColor: colors.surfaceAlt, borderColor: colors.borderStrong },
  btnPrimary: { backgroundColor: colors.accentPrimary, borderColor: colors.accentPrimary },
  btnMuted: { backgroundColor: "transparent" },
  label: { color: colors.text, fontSize: fontSize.h3, fontWeight: fontWeight.semibold },
  labelOp: { color: colors.text },
  labelPrimary: { color: "#fff", fontWeight: fontWeight.bold },
  labelMuted: { color: colors.textMuted, fontWeight: fontWeight.medium, fontSize: fontSize.body },
});
