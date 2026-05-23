import React from "react";
import { Text, View } from "react-native";

import { HubTile } from "@/app/components/HubTile";
import { RegionPill } from "@/app/components/RegionPill";
import { Screen } from "@/app/components/Screen";
import { useRegion } from "@/app/state/RegionProvider";
import { accents, colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

export default function FinanceHome() {
  const { region } = useRegion();
  return (
    <Screen>
      <View style={{ flexDirection: "row", alignItems: "flex-start", paddingTop: spacing.sm }}>
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: fontSize.h1, fontWeight: fontWeight.bold }}>Finance</Text>
          <Text style={{ color: colors.textMuted, fontSize: fontSize.body, marginTop: 2 }}>
            Tax, tips, loans, and currency for {region.label}
          </Text>
        </View>
        <RegionPill />
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <HubTile title="Tax Calculator" description="Income tax + take-home pay" iconName="document-text-outline" iconColor={accents.distance} href="/finance/tax" />
        <HubTile title="Tip & Split" description="Bill, tip %, and party size" iconName="restaurant-outline" iconColor={accents.area} href="/finance/tip" />
        <HubTile title="Discount" description="Final price + savings" iconName="pricetag-outline" iconColor={accents.fuelEconomy} href="/finance/discount" />
        <HubTile title="Compound Interest" description="Future value of an investment" iconName="trending-up-outline" iconColor={accents.weight} href="/finance/compound" />
        <HubTile title="EMI / Loan" description="Monthly payment calculator" iconName="card-outline" iconColor={accents.dataSize} href="/finance/emi" />
        <HubTile title="Currency" description="Live exchange rates" iconName="cash-outline" iconColor={accents.energy} href="/finance/currency" />
        <HubTile title="Unit Price" description="Compare two pack sizes" iconName="bag-handle-outline" iconColor={accents.pressure} href="/finance/unit-price" />
      </View>
    </Screen>
  );
}
