// Design tokens — single source of truth for colors, spacing, radii, and typography.
// Matches the CalcMaster reference design (dark navy background, neon-accented cards).

export const colors = {
  bg: "#0B1020",
  surface: "#141A2E",
  surfaceAlt: "#1B2238",
  surfaceElevated: "#222A45",
  text: "#FFFFFF",
  textMuted: "rgba(255, 255, 255, 0.62)",
  textDim: "rgba(255, 255, 255, 0.42)",
  border: "rgba(255, 255, 255, 0.06)",
  borderStrong: "rgba(255, 255, 255, 0.12)",
  accentPrimary: "#7C5CFF",
  danger: "#FF5C7A",
  success: "#5CE0A8",
  warning: "#FFC85C",
} as const;

// Per-category neon accents used on the Convert card thumbnails.
export const accents = {
  distance: "#5CE0A8", // mint
  volume: "#7CC8FF", // sky blue
  weight: "#B89CFF", // lavender
  temperature: "#FF8A65", // peach/coral
  speed: "#FFC85C", // amber
  area: "#9DFFB0", // lime
  dataSize: "#A5B8FF", // periwinkle
  fuelEconomy: "#FF7AC6", // magenta
  pressure: "#FF9BB3", // rose
  energy: "#FFD86B", // gold
} as const;

export const radii = {
  card: 22,
  cardThumb: 18,
  pill: 999,
  button: 14,
  input: 16,
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
} as const;

export const fontSize = {
  display: 32,
  h1: 28,
  h2: 22,
  h3: 18,
  body: 16,
  caption: 13,
  micro: 11,
} as const;

export const fontWeight = {
  regular: "400" as const,
  medium: "500" as const,
  semibold: "600" as const,
  bold: "700" as const,
};

export const shadow = {
  card: {
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.18,
    shadowRadius: 12,
    elevation: 4,
  },
};

export type AccentName = keyof typeof accents;
