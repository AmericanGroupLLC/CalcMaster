import React, { useMemo, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

import { KeyPad, type KeyDef } from "@/app/components/KeyPad";
import { PageHeader } from "@/app/components/PageHeader";
import { Screen } from "@/app/components/Screen";
import { evaluate } from "@/app/lib/calc";
import { formatNumber } from "@/app/lib/format";
import { colors, fontSize, fontWeight, spacing } from "@/app/theme/tokens";

const ROWS: KeyDef[][] = [
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

export default function StandardCalc() {
  const [expr, setExpr] = useState("");
  const [parenOpen, setParenOpen] = useState(0);

  const liveResult = useMemo(() => {
    if (!expr.trim()) return "";
    try {
      const v = evaluate(expr);
      if (!Number.isFinite(v)) return "";
      return formatNumber(v);
    } catch {
      return "";
    }
  }, [expr]);

  const onKey = (k: KeyDef) => {
    if (k.action === "clear") {
      setExpr("");
      setParenOpen(0);
      return;
    }
    if (k.action === "back") {
      setExpr((e) => {
        const last = e.slice(-1);
        if (last === "(") setParenOpen((p) => Math.max(0, p - 1));
        if (last === ")") setParenOpen((p) => p + 1);
        return e.slice(0, -1);
      });
      return;
    }
    if (k.action === "equals") {
      if (liveResult) setExpr(liveResult);
      return;
    }
    let toInsert = k.insert ?? k.label;
    if (k.label === "( )") {
      if (parenOpen > 0 && (/[\d)\.]$/.test(expr))) {
        toInsert = ")";
        setParenOpen((p) => p - 1);
      } else {
        toInsert = "(";
        setParenOpen((p) => p + 1);
      }
    }
    setExpr((e) => e + toInsert);
  };

  return (
    <Screen scroll={false}>
      <PageHeader title="Standard" subtitle="Live result updates as you type" />
      <View style={styles.display}>
        <Text style={styles.expr} numberOfLines={2} adjustsFontSizeToFit minimumFontScale={0.5}>
          {expr || "0"}
        </Text>
        {liveResult ? <Text style={styles.live}>= {liveResult}</Text> : null}
      </View>
      <KeyPad rows={ROWS} onPress={onKey} />
    </Screen>
  );
}

const styles = StyleSheet.create({
  display: {
    minHeight: 180,
    justifyContent: "flex-end",
    alignItems: "flex-end",
    marginTop: spacing.lg,
    paddingBottom: spacing.md,
  },
  expr: { color: colors.text, fontSize: 38, fontWeight: fontWeight.semibold, textAlign: "right" },
  live: { color: colors.textMuted, fontSize: fontSize.h3, marginTop: spacing.sm },
});
