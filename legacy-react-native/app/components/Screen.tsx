import React from "react";
import { SafeAreaView, ScrollView, StatusBar, StyleSheet, View, type ViewStyle } from "react-native";

import { colors, spacing } from "@/app/theme/tokens";

type Props = {
  children: React.ReactNode;
  scroll?: boolean;
  edges?: { bottom?: boolean };
  contentStyle?: ViewStyle;
};

/** Screen wrapper — applies the dark navy background, safe area, and shared padding. */
export function Screen({ children, scroll = true, contentStyle }: Props) {
  const Body = (
    <View style={[styles.content, contentStyle]}>{children}</View>
  );
  return (
    <SafeAreaView style={styles.safe}>
      <StatusBar barStyle="light-content" backgroundColor={colors.bg} />
      {scroll ? (
        <ScrollView
          contentContainerStyle={{ flexGrow: 1, paddingBottom: spacing.xxl }}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {Body}
        </ScrollView>
      ) : (
        <View style={{ flex: 1 }}>{Body}</View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.bg },
  content: { paddingHorizontal: spacing.lg, paddingTop: spacing.sm },
});
