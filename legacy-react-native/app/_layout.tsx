import React from "react";
import { Stack } from "expo-router";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";

import { RegionProvider } from "@/app/state/RegionProvider";
import { NotesProvider } from "@/app/state/NotesProvider";
import { colors } from "@/app/theme/tokens";

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1, backgroundColor: colors.bg }}>
      <SafeAreaProvider>
        <RegionProvider>
          <NotesProvider>
            <StatusBar style="light" />
            <Stack
              screenOptions={{
                headerShown: false,
                contentStyle: { backgroundColor: colors.bg },
                animation: "slide_from_right",
              }}
            >
              <Stack.Screen name="(tabs)" />
              <Stack.Screen
                name="notes"
                options={{ presentation: "modal", animation: "slide_from_bottom" }}
              />
            </Stack>
          </NotesProvider>
        </RegionProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
