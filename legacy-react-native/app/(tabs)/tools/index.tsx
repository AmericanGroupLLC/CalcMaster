import React from "react";
import { Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useRouter } from "expo-router";

import { HubTile } from "@/app/components/HubTile";
import { Screen } from "@/app/components/Screen";
import { accents, colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

export default function ToolsHome() {
  const router = useRouter();
  return (
    <Screen>
      <View style={{ flexDirection: "row", alignItems: "flex-start", paddingTop: spacing.sm }}>
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: fontSize.h1, fontWeight: fontWeight.bold }}>Tools</Text>
          <Text style={{ color: colors.textMuted, fontSize: fontSize.body, marginTop: 2 }}>
            Practical utilities and engineering helpers
          </Text>
        </View>
        <Pressable
          onPress={() => router.push("/notes" as never)}
          accessibilityRole="button"
          accessibilityLabel="Open notes"
          hitSlop={10}
          style={({ pressed }) => [{ padding: 8, opacity: pressed ? 0.7 : 1 }]}
        >
          <Ionicons name="bookmark-outline" size={22} color={colors.text} />
        </Pressable>
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <HubTile title="GPS Coordinates" description="Decimal ↔ DMS, use my location" iconName="navigate-outline" iconColor={accents.distance} href="/tools/gps" />
        <HubTile title="Ohm's Law" description="V · I · R · P" iconName="flash-outline" iconColor={accents.energy} href="/tools/ohm" />
        <HubTile title="BMI" description="Body mass index + category" iconName="body-outline" iconColor={accents.weight} href="/tools/bmi" />
        <HubTile title="Date Difference" description="Years, months, days between" iconName="calendar-outline" iconColor={accents.area} href="/tools/date-diff" />
        <HubTile title="Time Zones" description="Live world clocks" iconName="time-outline" iconColor={accents.volume} href="/tools/time-zones" />
        <HubTile title="ADC / DAC" description="Bits + Vref → analog/digital" iconName="pulse-outline" iconColor={accents.dataSize} href="/tools/adc-dac" />
        <HubTile title="Age Calculator" description="Years/months/days from DOB" iconName="hourglass-outline" iconColor={accents.fuelEconomy} href="/tools/age" />
        <HubTile title="Aspect Ratio" description="Solve missing W or H" iconName="resize-outline" iconColor={accents.pressure} href="/tools/aspect-ratio" />
      </View>
    </Screen>
  );
}
