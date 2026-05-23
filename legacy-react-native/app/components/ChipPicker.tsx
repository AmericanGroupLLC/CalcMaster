import React from "react";
import { Pressable, ScrollView, StyleSheet, Text, View } from "react-native";

import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

export type ChipOption<T extends string = string> = { id: T; label: string };

type Props<T extends string> = {
  options: ChipOption<T>[];
  value: T;
  onChange: (id: T) => void;
};

export function ChipPicker<T extends string>({ options, value, onChange }: Props<T>) {
  return (
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      contentContainerStyle={styles.row}
    >
      {options.map((opt) => {
        const active = opt.id === value;
        return (
          <Pressable
            key={opt.id}
            style={[styles.chip, active && styles.chipActive]}
            onPress={() => onChange(opt.id)}
            accessibilityRole="button"
            accessibilityState={{ selected: active }}
            accessibilityLabel={opt.label}
          >
            <Text style={[styles.label, active && styles.labelActive]}>{opt.label}</Text>
          </Pressable>
        );
      })}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  row: { gap: spacing.sm, paddingVertical: spacing.xs, paddingRight: spacing.lg },
  chip: {
    backgroundColor: colors.surface,
    borderRadius: radii.pill,
    paddingHorizontal: spacing.lg,
    paddingVertical: 9,
    borderWidth: 1,
    borderColor: colors.border,
  },
  chipActive: {
    backgroundColor: colors.text,
    borderColor: colors.text,
  },
  label: { color: colors.text, fontWeight: fontWeight.medium, fontSize: fontSize.caption + 1 },
  labelActive: { color: colors.bg, fontWeight: fontWeight.semibold },
});
