import React from "react";
import { StyleSheet, Text, TextInput, View } from "react-native";

import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

type Props = {
  label?: string;
  value: string;
  onChangeText: (v: string) => void;
  placeholder?: string;
  unitSymbol?: string;
  keyboardType?: "decimal-pad" | "numeric" | "default" | "phone-pad";
  autoFocus?: boolean;
};

export function NumberInput({
  label,
  value,
  onChangeText,
  placeholder = "0",
  unitSymbol,
  keyboardType = "decimal-pad",
  autoFocus,
}: Props) {
  return (
    <View style={styles.wrap}>
      {label ? <Text style={styles.label}>{label}</Text> : null}
      <View style={styles.inputRow}>
        <TextInput
          style={styles.input}
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={colors.textDim}
          keyboardType={keyboardType}
          autoFocus={autoFocus}
          selectionColor={colors.accentPrimary}
        />
        {unitSymbol ? <Text style={styles.unit}>{unitSymbol}</Text> : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { marginVertical: spacing.sm },
  label: { color: colors.textMuted, fontSize: fontSize.caption, marginBottom: 6, marginLeft: 2 },
  inputRow: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surface,
    borderRadius: radii.input,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  input: {
    flex: 1,
    color: colors.text,
    fontSize: fontSize.h2,
    fontWeight: fontWeight.semibold,
    paddingVertical: 0,
  },
  unit: { color: colors.textMuted, fontSize: fontSize.body, marginLeft: spacing.sm, fontWeight: fontWeight.medium },
});
