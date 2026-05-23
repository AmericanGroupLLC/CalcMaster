import React, { useMemo, useState } from "react";
import { View } from "react-native";

import { NumberInput } from "@/app/components/NumberInput";
import { PageHeader } from "@/app/components/PageHeader";
import { ResultRow } from "@/app/components/ResultRow";
import { Screen } from "@/app/components/Screen";
import { spacing } from "@/app/theme/tokens";

function pad(n: number): string {
  return String(n).padStart(2, "0");
}
function isoDate(d: Date): string {
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}
function parseDate(input: string): Date | null {
  const m = input.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (!m) return null;
  const d = new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
  return isNaN(d.getTime()) ? null : d;
}
function calendarDiff(a: Date, b: Date) {
  let years = b.getFullYear() - a.getFullYear();
  let months = b.getMonth() - a.getMonth();
  let days = b.getDate() - a.getDate();
  if (days < 0) {
    months -= 1;
    const prevLast = new Date(b.getFullYear(), b.getMonth(), 0).getDate();
    days += prevLast;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }
  const totalDays = Math.floor((b.getTime() - a.getTime()) / 86400000);
  return { years, months, days, totalDays };
}
function nextBirthday(dob: Date, today: Date) {
  const next = new Date(today.getFullYear(), dob.getMonth(), dob.getDate());
  if (next < today) next.setFullYear(today.getFullYear() + 1);
  const days = Math.ceil((next.getTime() - today.getTime()) / 86400000);
  return { date: next, days };
}

export default function AgeCalc() {
  const today = useMemo(() => isoDate(new Date()), []);
  const [dob, setDob] = useState("2000-01-01");
  const [ref, setRef] = useState(today);

  const result = useMemo(() => {
    const a = parseDate(dob);
    const b = parseDate(ref);
    if (!a || !b || a > b) return null;
    const c = calendarDiff(a, b);
    const nb = nextBirthday(a, b);
    return { ...c, nextBirthday: nb };
  }, [dob, ref]);

  return (
    <Screen>
      <PageHeader title="Age Calculator" subtitle="YYYY-MM-DD" />
      <View style={{ marginTop: spacing.lg }}>
        <NumberInput label="Date of birth" value={dob} onChangeText={setDob} keyboardType="default" />
        <NumberInput label="Reference date" value={ref} onChangeText={setRef} keyboardType="default" />
      </View>
      <View style={{ marginTop: spacing.lg }}>
        <ResultRow
          label="Age"
          value={result ? `${result.years}y ${result.months}m ${result.days}d` : "—"}
          highlight
        />
        <ResultRow label="Total days lived" value={result ? `${result.totalDays}` : "—"} />
        <ResultRow
          label="Next birthday"
          value={result ? `${isoDate(result.nextBirthday.date)} · in ${result.nextBirthday.days} days` : "—"}
        />
      </View>
    </Screen>
  );
}
