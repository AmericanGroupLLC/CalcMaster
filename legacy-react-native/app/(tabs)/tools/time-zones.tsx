import React, { useEffect, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

import { PageHeader } from "@/app/components/PageHeader";
import { Screen } from "@/app/components/Screen";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

const ZONES: { label: string; tz: string; flag: string }[] = [
  { label: "Cupertino", tz: "America/Los_Angeles", flag: "🇺🇸" },
  { label: "New York", tz: "America/New_York", flag: "🇺🇸" },
  { label: "London", tz: "Europe/London", flag: "🇬🇧" },
  { label: "Berlin", tz: "Europe/Berlin", flag: "🇩🇪" },
  { label: "Mumbai", tz: "Asia/Kolkata", flag: "🇮🇳" },
  { label: "Singapore", tz: "Asia/Singapore", flag: "🇸🇬" },
  { label: "Tokyo", tz: "Asia/Tokyo", flag: "🇯🇵" },
  { label: "Sydney", tz: "Australia/Sydney", flag: "🇦🇺" },
  { label: "São Paulo", tz: "America/Sao_Paulo", flag: "🇧🇷" },
  { label: "Dubai", tz: "Asia/Dubai", flag: "🇦🇪" },
];

export default function TimeZones() {
  const [now, setNow] = useState(Date.now());

  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, []);

  const date = new Date(now);

  return (
    <Screen>
      <PageHeader title="Time Zones" subtitle="Live world clocks" />
      <View style={{ marginTop: spacing.lg }}>
        {ZONES.map((z) => {
          const time = new Intl.DateTimeFormat("en-US", {
            hour: "numeric",
            minute: "2-digit",
            second: "2-digit",
            timeZone: z.tz,
            hour12: true,
          }).format(date);
          const day = new Intl.DateTimeFormat("en-US", {
            weekday: "short",
            month: "short",
            day: "numeric",
            timeZone: z.tz,
          }).format(date);
          return (
            <View key={z.tz} style={styles.row}>
              <Text style={styles.flag}>{z.flag}</Text>
              <View style={{ flex: 1 }}>
                <Text style={styles.city}>{z.label}</Text>
                <Text style={styles.day}>{day}</Text>
              </View>
              <Text style={styles.time}>{time}</Text>
            </View>
          );
        })}
      </View>
    </Screen>
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
    gap: spacing.md,
  },
  flag: { fontSize: 22 },
  city: { color: colors.text, fontSize: fontSize.body, fontWeight: fontWeight.semibold },
  day: { color: colors.textMuted, fontSize: fontSize.caption, marginTop: 2 },
  time: { color: colors.text, fontSize: fontSize.body, fontWeight: fontWeight.bold },
});
