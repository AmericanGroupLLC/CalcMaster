import React, { useMemo, useState } from "react";
import { Pressable, ScrollView, StyleSheet, Text, View } from "react-native";

import { KeyPad, type KeyDef } from "@/app/components/KeyPad";
import { PageHeader } from "@/app/components/PageHeader";
import { Screen } from "@/app/components/Screen";
import { evaluate } from "@/app/lib/calc";
import { formatNumber } from "@/app/lib/format";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

const SCI_ROWS: KeyDef[][] = [
  [
    { label: "sin", insert: "sin(", action: "insert", variant: "muted" },
    { label: "cos", insert: "cos(", action: "insert", variant: "muted" },
    { label: "tan", insert: "tan(", action: "insert", variant: "muted" },
    { label: "π", insert: "pi", action: "insert", variant: "muted" },
  ],
  [
    { label: "ln", insert: "ln(", action: "insert", variant: "muted" },
    { label: "log", insert: "log(", action: "insert", variant: "muted" },
    { label: "√", insert: "sqrt(", action: "insert", variant: "muted" },
    { label: "x²", insert: "^2", action: "insert", variant: "muted" },
  ],
  [
    { label: "x^y", insert: "^", action: "insert", variant: "muted" },
    { label: "n!", insert: "!", action: "insert", variant: "muted" },
    { label: "e", insert: "e", action: "insert", variant: "muted" },
    { label: "exp", insert: "exp(", action: "insert", variant: "muted" },
  ],
];

const NUM_ROWS: KeyDef[][] = [
  [
    { label: "C", action: "clear", variant: "muted" },
    { label: "( )", insert: "(", action: "insert", variant: "muted" },
    { label: "%", insert: "%", variant: "muted" },
    { label: "÷", insert: "/", action: "insert", variant: "op" },
  ],
  [
    { label: "7", insert: "7", action: "insert" },
    { label: "8", insert: "8", action: "insert" },
    { label: "9", insert: "9", action: "insert" },
    { label: "×", insert: "*", action: "insert", variant: "op" },
  ],
  [
    { label: "4", insert: "4", action: "insert" },
    { label: "5", insert: "5", action: "insert" },
    { label: "6", insert: "6", action: "insert" },
    { label: "−", insert: "-", action: "insert", variant: "op" },
  ],
  [
    { label: "1", insert: "1", action: "insert" },
    { label: "2", insert: "2", action: "insert" },
    { label: "3", insert: "3", action: "insert" },
    { label: "+", insert: "+", action: "insert", variant: "op" },
  ],
  [
    { label: "⌫", action: "back", variant: "muted" },
    { label: "0", insert: "0", action: "insert" },
    { label: ".", insert: ".", action: "insert" },
    { label: "=", action: "equals", variant: "primary" },
  ],
];

export default function ScientificCalc() {
  const [expr, setExpr] = useState("");
  const [memory, setMemory] = useState(0);

  const liveResult = useMemo(() => {
    if (!expr.trim()) return "";
    try {
      // Auto-balance unclosed parens for live preview
      const open = (expr.match(/\(/g) ?? []).length;
      const close = (expr.match(/\)/g) ?? []).length;
      const padded = expr + ")".repeat(Math.max(0, open - close));
      const v = evaluate(padded);
      if (!Number.isFinite(v)) return "";
      return formatNumber(v, { maxDigits: 10 });
    } catch {
      return "";
    }
  }, [expr]);

  const onKey = (k: KeyDef) => {
    if (k.action === "clear") {
      setExpr("");
      return;
    }
    if (k.action === "back") {
      setExpr((e) => e.slice(0, -1));
      return;
    }
    if (k.action === "equals") {
      if (liveResult) setExpr(liveResult);
      return;
    }
    setExpr((e) => e + (k.insert ?? k.label));
  };

  return (
    <Screen scroll={false}>
      <PageHeader title="Scientific" subtitle={memory ? `M = ${formatNumber(memory)}` : "Trig, logs, powers, factorial"} />
      <View style={styles.display}>
        <Text style={styles.expr} numberOfLines={3} adjustsFontSizeToFit minimumFontScale={0.4}>
          {expr || "0"}
        </Text>
        {liveResult ? <Text style={styles.live}>= {liveResult}</Text> : null}
      </View>

      <View style={styles.memBar}>
        <Pressable style={styles.memBtn} onPress={() => setMemory(0)}>
          <Text style={styles.memLabel}>MC</Text>
        </Pressable>
        <Pressable style={styles.memBtn} onPress={() => setExpr((e) => e + memory.toString())}>
          <Text style={styles.memLabel}>MR</Text>
        </Pressable>
        <Pressable
          style={styles.memBtn}
          onPress={() => {
            const v = Number(liveResult);
            if (Number.isFinite(v)) setMemory((m) => m + v);
          }}
        >
          <Text style={styles.memLabel}>M+</Text>
        </Pressable>
        <Pressable
          style={styles.memBtn}
          onPress={() => {
            const v = Number(liveResult);
            if (Number.isFinite(v)) setMemory((m) => m - v);
          }}
        >
          <Text style={styles.memLabel}>M-</Text>
        </Pressable>
      </View>

      <ScrollView contentContainerStyle={{ paddingBottom: spacing.xxl }} showsVerticalScrollIndicator={false}>
        <KeyPad rows={SCI_ROWS} onPress={onKey} />
        <KeyPad rows={NUM_ROWS} onPress={onKey} />
      </ScrollView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  display: {
    minHeight: 130,
    justifyContent: "flex-end",
    alignItems: "flex-end",
    marginTop: spacing.md,
    paddingBottom: spacing.xs,
  },
  expr: { color: colors.text, fontSize: 30, fontWeight: fontWeight.semibold, textAlign: "right" },
  live: { color: colors.textMuted, fontSize: fontSize.h3, marginTop: spacing.sm },
  memBar: {
    flexDirection: "row",
    gap: spacing.sm,
    marginTop: spacing.md,
  },
  memBtn: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    paddingVertical: 10,
    alignItems: "center",
    borderWidth: 1,
    borderColor: colors.border,
  },
  memLabel: { color: colors.textMuted, fontWeight: fontWeight.semibold, fontSize: fontSize.caption + 1 },
});
