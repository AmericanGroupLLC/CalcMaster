import React from "react";
import { Text, View } from "react-native";

import { HubTile } from "@/app/components/HubTile";
import { RegionPill } from "@/app/components/RegionPill";
import { Screen } from "@/app/components/Screen";
import { accents, colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

export default function CalculateHome() {
  return (
    <Screen>
      <View style={{ flexDirection: "row", alignItems: "flex-start", paddingTop: spacing.sm }}>
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: fontSize.h1, fontWeight: fontWeight.bold }}>
            Calculate
          </Text>
          <Text style={{ color: colors.textMuted, fontSize: fontSize.body, marginTop: 2 }}>
            Numbers, formulas, and base conversions
          </Text>
        </View>
        <RegionPill />
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <HubTile title="Standard" description="The everyday calculator" iconName="calculator-outline" iconColor={accents.distance} href="/calculate/standard" />
        <HubTile title="Scientific" description="Trig, logs, powers, factorial" iconName="rocket-outline" iconColor={accents.weight} href="/calculate/scientific" />
        <HubTile title="Percentage" description="X% of Y, % change, etc." iconName="pricetag-outline" iconColor={accents.area} href="/calculate/percentage" />
        <HubTile title="Base Converter" description="Hex / Decimal / Binary / Octal" iconName="code-slash-outline" iconColor={accents.dataSize} href="/calculate/base" />
        <HubTile title="Fraction" description="Add, subtract, simplify" iconName="grid-outline" iconColor={accents.fuelEconomy} href="/calculate/fraction" />
      </View>
    </Screen>
  );
}
