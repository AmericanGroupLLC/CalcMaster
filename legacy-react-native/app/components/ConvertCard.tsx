import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";

import { accents, colors, fontSize, fontWeight, radii, shadow, spacing, type AccentName } from "@/app/theme/tokens";

type Hint = { primary: string; secondary: string; tertiary?: string };

type Props = {
  title: string;
  subtitle: string;
  accent: AccentName;
  hint: Hint;
  iconNode: React.ReactNode;
  onPress: () => void;
};

/** A 2-col grid card for the Convert home, mirroring the reference image. */
export function ConvertCard({ title, subtitle, accent, hint, iconNode, onPress }: Props) {
  const accentColor = accents[accent];
  return (
    <Pressable
      style={({ pressed }) => [styles.card, pressed && { transform: [{ scale: 0.98 }], opacity: 0.95 }]}
      onPress={onPress}
      android_ripple={{ color: "rgba(255,255,255,0.04)" }}
      accessibilityRole="button"
      accessibilityLabel={`Open ${title} converter`}
    >
      <View style={styles.thumb}>
        <View style={styles.iconWrap}>{iconNode}</View>
        <Text style={[styles.hintPrimary, { color: accentColor }]}>{hint.primary}</Text>
        <Text style={[styles.hintSecondary, { color: accentColor, opacity: 0.85 }]}>{hint.secondary}</Text>
        {hint.tertiary ? (
          <Text style={[styles.hintTertiary, { color: accentColor, opacity: 0.7 }]}>{hint.tertiary}</Text>
        ) : null}
      </View>
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.subtitle}>{subtitle}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: radii.card,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.card,
  },
  thumb: {
    width: 100,
    height: 88,
    borderRadius: radii.cardThumb,
    backgroundColor: colors.surfaceAlt,
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: spacing.md,
    position: "relative",
    overflow: "hidden",
  },
  iconWrap: {
    position: "absolute",
    top: 14,
    left: 14,
  },
  hintPrimary: {
    position: "absolute",
    bottom: 8,
    left: 10,
    fontSize: fontSize.micro + 1,
    fontWeight: fontWeight.semibold,
  },
  hintSecondary: {
    position: "absolute",
    bottom: 8,
    right: 10,
    fontSize: fontSize.micro + 1,
    fontWeight: fontWeight.semibold,
  },
  hintTertiary: {
    position: "absolute",
    top: 8,
    right: 10,
    fontSize: fontSize.micro,
    fontWeight: fontWeight.medium,
  },
  title: {
    color: colors.text,
    fontWeight: fontWeight.bold,
    fontSize: fontSize.h3,
    marginTop: 2,
  },
  subtitle: {
    color: colors.textMuted,
    fontSize: fontSize.caption,
    marginTop: 4,
  },
});
