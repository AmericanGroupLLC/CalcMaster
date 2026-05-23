import React, { useMemo, useState } from "react";
import { Alert, Pressable, StyleSheet, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import * as Location from "expo-location";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { safeNumber } from "@/app/lib/format";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

function decimalToDMS(decimal: number, isLat: boolean): string {
  if (!Number.isFinite(decimal)) return "—";
  const sign = decimal >= 0 ? (isLat ? "N" : "E") : isLat ? "S" : "W";
  const abs = Math.abs(decimal);
  const deg = Math.floor(abs);
  const minF = (abs - deg) * 60;
  const min = Math.floor(minF);
  const sec = (minF - min) * 60;
  return `${deg}° ${min}' ${sec.toFixed(2)}" ${sign}`;
}

export default function GpsCalc() {
  const [lat, setLat] = useState("");
  const [lng, setLng] = useState("");
  const [loading, setLoading] = useState(false);

  const dmsLat = useMemo(() => decimalToDMS(safeNumber(lat), true), [lat]);
  const dmsLng = useMemo(() => decimalToDMS(safeNumber(lng), false), [lng]);

  async function useMyLocation() {
    try {
      setLoading(true);
      const perm = await Location.requestForegroundPermissionsAsync();
      if (!perm.granted) {
        Alert.alert("Location permission denied", "Enable location access in Settings to use this feature.");
        return;
      }
      const pos = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.Balanced });
      setLat(pos.coords.latitude.toFixed(6));
      setLng(pos.coords.longitude.toFixed(6));
    } catch (e) {
      Alert.alert("Could not fetch location", String(e));
    } finally {
      setLoading(false);
    }
  }

  return (
    <Screen>
      <PageHeader title="GPS Coordinates" subtitle="Decimal ↔ DMS" />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label="Latitude (decimal)" value={lat} onChangeText={setLat} placeholder="37.4220" />
        <NumberInput label="Longitude (decimal)" value={lng} onChangeText={setLng} placeholder="-122.0840" />
      </View>
      <Pressable
        onPress={useMyLocation}
        style={({ pressed }) => [styles.cta, pressed && { opacity: 0.85 }]}
        accessibilityRole="button"
      >
        <Ionicons name="navigate" size={18} color={colors.bg} />
        <Text style={styles.ctaText}>{loading ? "Locating..." : "Use my location"}</Text>
      </Pressable>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow label="Latitude (DMS)" value={dmsLat} highlight />
        <ResultRow label="Longitude (DMS)" value={dmsLng} highlight />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  cta: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: colors.text,
    borderRadius: radii.button,
    paddingVertical: 14,
    marginTop: spacing.md,
    gap: 8,
  },
  ctaText: { color: colors.bg, fontSize: fontSize.body, fontWeight: fontWeight.bold },
});
