import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";

import { readJSON, writeJSON } from "@/app/lib/storage";

export type Note = {
  id: string;
  title: string;
  body: string;
  createdAt: number;
  updatedAt: number;
};

type NotesContextValue = {
  notes: Note[];
  add: (title: string, body: string) => Note;
  update: (id: string, partial: Partial<Pick<Note, "title" | "body">>) => void;
  remove: (id: string) => void;
};

const STORAGE_KEY = "notes";
const NotesContext = createContext<NotesContextValue | null>(null);

function makeId(): string {
  return Math.random().toString(36).slice(2, 11) + Date.now().toString(36);
}

export function NotesProvider({ children }: { children: React.ReactNode }) {
  const [notes, setNotes] = useState<Note[]>([]);

  useEffect(() => {
    let cancel = false;
    (async () => {
      const stored = await readJSON<Note[]>(STORAGE_KEY);
      if (!cancel && Array.isArray(stored)) setNotes(stored);
    })();
    return () => {
      cancel = true;
    };
  }, []);

  const persist = useCallback((next: Note[]) => {
    setNotes(next);
    writeJSON(STORAGE_KEY, next);
  }, []);

  const add = useCallback(
    (title: string, body: string): Note => {
      const note: Note = {
        id: makeId(),
        title,
        body,
        createdAt: Date.now(),
        updatedAt: Date.now(),
      };
      const next = [note, ...notes];
      persist(next);
      return note;
    },
    [notes, persist],
  );

  const update = useCallback(
    (id: string, partial: Partial<Pick<Note, "title" | "body">>) => {
      const next = notes.map((n) =>
        n.id === id ? { ...n, ...partial, updatedAt: Date.now() } : n,
      );
      persist(next);
    },
    [notes, persist],
  );

  const remove = useCallback(
    (id: string) => {
      persist(notes.filter((n) => n.id !== id));
    },
    [notes, persist],
  );

  const value = useMemo<NotesContextValue>(() => ({ notes, add, update, remove }), [notes, add, update, remove]);

  return <NotesContext.Provider value={value}>{children}</NotesContext.Provider>;
}

export function useNotes(): NotesContextValue {
  const ctx = useContext(NotesContext);
  if (!ctx) throw new Error("useNotes must be used inside <NotesProvider>");
  return ctx;
}
