import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useRouter } from "expo-router";

import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

type Props = {
  title: string;
  subtitle?: string;
  right?: React.ReactNode;
};

/** Shared header used by inner screens — back chevron + title + optional right slot. */
export function PageHeader({ title, subtitle, right }: Props) {
  const router = useRouter();
  return (
    <View>
      <View style={styles.row}>
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel="Back"
        >
          <Ionicons name="chevron-back" size={28} color={colors.text} />
        </Pressable>
        <Text style={styles.title} numberOfLines={1}>
          {title}
        </Text>
        <View style={styles.right}>{right}</View>
      </View>
      {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
    paddingTop: spacing.xs,
  },
  title: {
    flex: 1,
    color: colors.text,
    fontSize: fontSize.h2,
    fontWeight: fontWeight.bold,
    marginLeft: spacing.sm,
  },
  right: { minWidth: 28, alignItems: "flex-end" },
  subtitle: { color: colors.textMuted, fontSize: fontSize.caption, marginLeft: 36, marginTop: 2 },
});
