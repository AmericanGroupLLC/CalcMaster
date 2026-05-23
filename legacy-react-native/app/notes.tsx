import React, { useMemo, useState } from "react";
import { FlatList, Pressable, StyleSheet, Text, TextInput, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useRouter } from "expo-router";

import { Screen } from "@/app/components/Screen";
import { useNotes, type Note } from "@/app/state/NotesProvider";
import { colors, fontSize, fontWeight, radii, spacing } from "@/app/theme/tokens";

export default function NotesModal() {
  const router = useRouter();
  const { notes, add, update, remove } = useNotes();
  const [search, setSearch] = useState("");
  const [editing, setEditing] = useState<Note | null>(null);
  const [draft, setDraft] = useState({ title: "", body: "" });

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return notes;
    return notes.filter(
      (n) => n.title.toLowerCase().includes(q) || n.body.toLowerCase().includes(q),
    );
  }, [notes, search]);

  function startNew() {
    setEditing(null);
    setDraft({ title: "", body: "" });
  }

  function save() {
    if (!draft.title.trim() && !draft.body.trim()) return;
    if (editing) {
      update(editing.id, draft);
    } else {
      add(draft.title || "Untitled", draft.body);
    }
    setDraft({ title: "", body: "" });
    setEditing(null);
  }

  return (
    <Screen scroll={false}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={12} accessibilityLabel="Close">
          <Ionicons name="close" size={26} color={colors.text} />
        </Pressable>
        <Text style={styles.title}>Notes</Text>
        <Pressable onPress={startNew} hitSlop={12} accessibilityLabel="New note">
          <Ionicons name="add" size={26} color={colors.text} />
        </Pressable>
      </View>

      <View style={styles.searchWrap}>
        <Ionicons name="search" size={16} color={colors.textMuted} />
        <TextInput
          placeholder="Search notes"
          placeholderTextColor={colors.textDim}
          value={search}
          onChangeText={setSearch}
          style={styles.searchInput}
        />
      </View>

      <View style={styles.editor}>
        <TextInput
          style={styles.editorTitle}
          placeholder={editing ? "Title" : "New note title"}
          placeholderTextColor={colors.textDim}
          value={draft.title}
          onChangeText={(v) => setDraft((d) => ({ ...d, title: v }))}
        />
        <TextInput
          style={styles.editorBody}
          placeholder="Body"
          placeholderTextColor={colors.textDim}
          value={draft.body}
          onChangeText={(v) => setDraft((d) => ({ ...d, body: v }))}
          multiline
        />
        <Pressable style={styles.saveBtn} onPress={save} accessibilityRole="button">
          <Text style={styles.saveLabel}>{editing ? "Save changes" : "Add note"}</Text>
        </Pressable>
      </View>

      <FlatList
        style={{ marginTop: spacing.md }}
        data={filtered}
        keyExtractor={(n) => n.id}
        ItemSeparatorComponent={() => <View style={{ height: 6 }} />}
        renderItem={({ item }) => (
          <Pressable
            style={styles.note}
            onPress={() => {
              setEditing(item);
              setDraft({ title: item.title, body: item.body });
            }}
            onLongPress={() => remove(item.id)}
          >
            <View style={{ flex: 1 }}>
              <Text style={styles.noteTitle} numberOfLines={1}>
                {item.title}
              </Text>
              <Text style={styles.noteBody} numberOfLines={2}>
                {item.body}
              </Text>
            </View>
            <Ionicons name="chevron-forward" size={18} color={colors.textDim} />
          </Pressable>
        )}
        ListEmptyComponent={
          <Text style={styles.empty}>
            No notes yet. Long-press any conversion result to save it here.
          </Text>
        }
      />
    </Screen>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingTop: spacing.xs,
    paddingBottom: spacing.md,
  },
  title: { color: colors.text, fontSize: fontSize.h2, fontWeight: fontWeight.bold },
  searchWrap: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    paddingHorizontal: spacing.md,
    paddingVertical: 10,
    gap: 8,
    borderWidth: 1,
    borderColor: colors.border,
  },
  searchInput: { flex: 1, color: colors.text, fontSize: fontSize.body, paddingVertical: 0 },
  editor: {
    backgroundColor: colors.surface,
    borderRadius: radii.card,
    padding: spacing.md,
    marginTop: spacing.md,
    borderWidth: 1,
    borderColor: colors.border,
  },
  editorTitle: { color: colors.text, fontSize: fontSize.h3, fontWeight: fontWeight.semibold, paddingVertical: 4 },
  editorBody: { color: colors.text, fontSize: fontSize.body, minHeight: 64, marginTop: 4, textAlignVertical: "top" },
  saveBtn: {
    backgroundColor: colors.text,
    borderRadius: radii.button,
    paddingVertical: 10,
    alignItems: "center",
    marginTop: spacing.sm,
  },
  saveLabel: { color: colors.bg, fontWeight: fontWeight.bold, fontSize: fontSize.caption + 1 },
  note: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surface,
    borderRadius: radii.button,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.border,
  },
  noteTitle: { color: colors.text, fontWeight: fontWeight.semibold, fontSize: fontSize.body },
  noteBody: { color: colors.textMuted, fontSize: fontSize.caption, marginTop: 2 },
  empty: {
    color: colors.textMuted,
    fontSize: fontSize.caption,
    textAlign: "center",
    marginTop: spacing.lg,
  },
});
