import React from "react";
import { StyleSheet, Text, View } from "react-native";

import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

type Props = {
  title: string;
  subtitle?: string;
  right?: React.ReactNode;
};

export function SectionHeader({ title, subtitle, right }: Props) {
  return (
    <View style={styles.row}>
      <View style={{ flex: 1 }}>
        <Text style={styles.title}>{title}</Text>
        {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
      </View>
      {right}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "flex-end",
    marginTop: spacing.xl,
    marginBottom: spacing.md,
  },
  title: {
    color: colors.text,
    fontSize: fontSize.h1,
    fontWeight: fontWeight.bold,
  },
  subtitle: {
    color: colors.textMuted,
    fontSize: fontSize.body,
    marginTop: 4,
  },
});
