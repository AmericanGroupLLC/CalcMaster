import React, { useMemo, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

function pad(n: number): string {
  return String(n).padStart(2, "0");
}

function isoDate(d: Date): string {
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

function parseDate(input: string): Date | null {
  // Accept yyyy-mm-dd
  const m = input.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (!m) return null;
  const d = new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
  return isNaN(d.getTime()) ? null : d;
}

function diff(a: Date, b: Date) {
  const ms = b.getTime() - a.getTime();
  const days = Math.floor(ms / 86400000);
  const weeks = Math.floor(days / 7);
  const hours = Math.floor(ms / 3600000);
  // Years/months — calendar arithmetic
  let years = b.getFullYear() - a.getFullYear();
  let months = b.getMonth() - a.getMonth();
  let dDays = b.getDate() - a.getDate();
  if (dDays < 0) {
    months -= 1;
    const prevMonthLastDay = new Date(b.getFullYear(), b.getMonth(), 0).getDate();
    dDays += prevMonthLastDay;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }
  return { years, months, days: dDays, totalDays: days, weeks, hours };
}

export default function DateDiff() {
  const today = useMemo(() => isoDate(new Date()), []);
  const [from, setFrom] = useState(today);
  const [to, setTo] = useState(today);

  const result = useMemo(() => {
    const a = parseDate(from);
    const b = parseDate(to);
    if (!a || !b) return null;
    if (a > b) return diff(b, a);
    return diff(a, b);
  }, [from, to]);

  return (
    <Screen>
      <PageHeader title="Date Difference" subtitle="YYYY-MM-DD format" />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label="From" value={from} onChangeText={setFrom} keyboardType="default" placeholder="2025-01-01" />
        <NumberInput label="To" value={to} onChangeText={setTo} keyboardType="default" placeholder="2026-01-01" />
        <Pressable onPress={() => setTo(today)} style={styles.todayBtn}>
          <Text style={styles.todayLabel}>Set To = Today</Text>
        </Pressable>
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow
          label="Calendar"
          value={
            result
              ? `${result.years}y ${result.months}m ${result.days}d`
              : "—"
          }
          highlight
        />
        <ResultRow label="Total days" value={result ? `${result.totalDays}` : "—"} />
        <ResultRow label="Weeks" value={result ? `${result.weeks}` : "—"} />
        <ResultRow label="Hours" value={result ? `${result.hours}` : "—"} />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  todayBtn: {
    alignSelf: "flex-start",
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    paddingHorizontal: spacing.md,
    paddingVertical: 8,
    marginTop: spacing.sm,
    borderWidth: 1,
    borderColor: colors.border,
  },
  todayLabel: { color: colors.text, fontWeight: fontWeight.semibold, fontSize: fontSize.caption + 1 },
});
