import React, { useState } from "react";
import { Modal, Pressable, StyleSheet, Text, View } from "react-native";

import { regions } from "@/app/lib/currency";
import { useRegion } from "@/app/state/RegionProvider";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

type Props = { visible: boolean; onClose: () => void };

export function RegionPickerSheet({ visible, onClose }: Props) {
  const { region, setRegion } = useRegion();
  return (
    <Modal animationType="slide" transparent visible={visible} onRequestClose={onClose}>
      <Pressable style={styles.scrim} onPress={onClose}>
        <Pressable style={styles.sheet} onPress={(e) => e.stopPropagation()}>
          <View style={styles.handle} />
          <Text style={styles.heading}>Select region</Text>
          {regions.map((r) => {
            const selected = r.id === region.id;
            return (
              <Pressable
                key={r.id}
                style={[styles.row, selected && styles.rowSelected]}
                onPress={() => {
                  setRegion(r.id);
                  onClose();
                }}
                accessibilityRole="button"
              >
                <Text style={styles.flag}>{r.flag}</Text>
                <View style={{ flex: 1 }}>
                  <Text style={styles.label}>{r.label}</Text>
                  <Text style={styles.sub}>
                    {r.currency} · {r.symbol}
                  </Text>
                </View>
                {selected ? <Text style={styles.check}>✓</Text> : null}
              </Pressable>
            );
          })}
        </Pressable>
      </Pressable>
    </Modal>
  );
}

const styles = StyleSheet.create({
  scrim: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
  sheet: {
    backgroundColor: colors.surface,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    padding: spacing.lg,
    paddingBottom: spacing.xxxl,
  },
  handle: {
    alignSelf: "center",
    width: 40,
    height: 4,
    borderRadius: 2,
    backgroundColor: colors.borderStrong,
    marginBottom: spacing.md,
  },
  heading: { color: colors.text, fontSize: fontSize.h3, fontWeight: fontWeight.bold, marginBottom: spacing.md },
  row: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.md,
    borderRadius: radii.button,
    gap: spacing.md,
  },
  rowSelected: { backgroundColor: colors.surfaceAlt },
  flag: { fontSize: 24 },
  label: { color: colors.text, fontSize: fontSize.body, fontWeight: fontWeight.semibold },
  sub: { color: colors.textMuted, fontSize: fontSize.caption, marginTop: 2 },
  check: { color: colors.success, fontSize: fontSize.h3, fontWeight: fontWeight.bold },
});
