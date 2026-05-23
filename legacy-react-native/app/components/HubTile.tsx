import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useRouter } from "expo-router";

import { colors, fontSize, fontWeight, radii, shadow, spacing } from "@/app/theme/tokens";

type Props = {
  title: string;
  description?: string;
  iconName: keyof typeof Ionicons.glyphMap;
  iconColor?: string;
  href: string;
};

/** A wide rounded list item used on the Calculate / Finance / Tools hubs. */
export function HubTile({ title, description, iconName, iconColor, href }: Props) {
  const router = useRouter();
  return (
    <Pressable
      onPress={() => router.push(href as never)}
      style={({ pressed }) => [styles.tile, pressed && { opacity: 0.92, transform: [{ scale: 0.99 }] }]}
      accessibilityRole="button"
      accessibilityLabel={title}
    >
      <View style={[styles.iconWrap, { borderColor: (iconColor ?? colors.accentPrimary) + "55" }]}>
        <Ionicons name={iconName} size={22} color={iconColor ?? colors.accentPrimary} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.title}>{title}</Text>
        {description ? <Text style={styles.description}>{description}</Text> : null}
      </View>
      <Ionicons name="chevron-forward" size={20} color={colors.textDim} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  tile: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surface,
    borderRadius: radii.card,
    padding: spacing.lg,
    marginVertical: 6,
    borderWidth: 1,
    borderColor: colors.border,
    gap: spacing.md,
    ...shadow.card,
  },
  iconWrap: {
    width: 44,
    height: 44,
    borderRadius: radii.button,
    backgroundColor: colors.surfaceAlt,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
  },
  title: { color: colors.text, fontWeight: fontWeight.semibold, fontSize: fontSize.body },
  description: { color: colors.textMuted, fontSize: fontSize.caption, marginTop: 2 },
});
