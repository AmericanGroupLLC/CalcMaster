// Conversion engine. Pure TS, no React.
// Each category has a "base" unit; convert(value, from, to, category) goes from -> base -> to.
// Linear units use multiplicative factors; temperature is the special case (handled with offsets).

import type { AccentName } from "@/app/theme/tokens";

export type CategoryId =
  | "distance"
  | "volume"
  | "weight"
  | "temperature"
  | "speed"
  | "area"
  | "dataSize"
  | "fuelEconomy"
  | "pressure"
  | "energy";

export type Unit = {
  id: string;
  label: string;
  symbol: string;
  /** Convert from this unit to the category base unit. */
  toBase: (v: number) => number;
  /** Convert from the category base unit back to this unit. */
  fromBase: (v: number) => number;
};

export type Category = {
  id: CategoryId;
  label: string;
  subtitle: string;
  baseUnit: string;
  /** Three letters used for the icon thumbnail badges. */
  thumbHint: { primary: string; secondary: string; tertiary?: string };
  accent: AccentName;
  iconName: string;
  units: Unit[];
};

const linear = (factor: number): Pick<Unit, "toBase" | "fromBase"> => ({
  toBase: (v) => v * factor,
  fromBase: (v) => v / factor,
});

export const categories: Record<CategoryId, Category> = {
  distance: {
    id: "distance",
    label: "Distance",
    subtitle: "km · mi · ft · m · in",
    baseUnit: "m",
    thumbHint: { primary: "mi", secondary: "ft" },
    accent: "distance",
    iconName: "swap-horizontal-outline",
    units: [
      { id: "mm", label: "Millimeter", symbol: "mm", ...linear(0.001) },
      { id: "cm", label: "Centimeter", symbol: "cm", ...linear(0.01) },
      { id: "m", label: "Meter", symbol: "m", ...linear(1) },
      { id: "km", label: "Kilometer", symbol: "km", ...linear(1000) },
      { id: "in", label: "Inch", symbol: "in", ...linear(0.0254) },
      { id: "ft", label: "Foot", symbol: "ft", ...linear(0.3048) },
      { id: "yd", label: "Yard", symbol: "yd", ...linear(0.9144) },
      { id: "mi", label: "Mile", symbol: "mi", ...linear(1609.344) },
      { id: "nmi", label: "Nautical mile", symbol: "nmi", ...linear(1852) },
    ],
  },
  volume: {
    id: "volume",
    label: "Volume",
    subtitle: "mL · L · gal · fl oz",
    baseUnit: "L",
    thumbHint: { primary: "mL", secondary: "gal", tertiary: "cup" },
    accent: "volume",
    iconName: "flask-outline",
    units: [
      { id: "ml", label: "Milliliter", symbol: "mL", ...linear(0.001) },
      { id: "l", label: "Liter", symbol: "L", ...linear(1) },
      { id: "tsp", label: "Teaspoon (US)", symbol: "tsp", ...linear(0.00492892) },
      { id: "tbsp", label: "Tablespoon (US)", symbol: "tbsp", ...linear(0.0147868) },
      { id: "floz", label: "Fluid ounce (US)", symbol: "fl oz", ...linear(0.0295735) },
      { id: "cup", label: "Cup (US)", symbol: "cup", ...linear(0.236588) },
      { id: "pt", label: "Pint (US)", symbol: "pt", ...linear(0.473176) },
      { id: "qt", label: "Quart (US)", symbol: "qt", ...linear(0.946353) },
      { id: "gal", label: "Gallon (US)", symbol: "gal", ...linear(3.78541) },
      { id: "galuk", label: "Gallon (UK)", symbol: "gal UK", ...linear(4.54609) },
    ],
  },
  weight: {
    id: "weight",
    label: "Weight",
    subtitle: "kg · lb · g · oz · st",
    baseUnit: "kg",
    thumbHint: { primary: "lb", secondary: "oz" },
    accent: "weight",
    iconName: "barbell-outline",
    units: [
      { id: "mg", label: "Milligram", symbol: "mg", ...linear(0.000001) },
      { id: "g", label: "Gram", symbol: "g", ...linear(0.001) },
      { id: "kg", label: "Kilogram", symbol: "kg", ...linear(1) },
      { id: "t", label: "Metric ton", symbol: "t", ...linear(1000) },
      { id: "oz", label: "Ounce", symbol: "oz", ...linear(0.0283495) },
      { id: "lb", label: "Pound", symbol: "lb", ...linear(0.453592) },
      { id: "st", label: "Stone", symbol: "st", ...linear(6.35029) },
    ],
  },
  temperature: {
    id: "temperature",
    label: "Temperature",
    subtitle: "°F · °C · K",
    baseUnit: "K",
    thumbHint: { primary: "°F", secondary: "°C", tertiary: "K" },
    accent: "temperature",
    iconName: "thermometer-outline",
    units: [
      { id: "c", label: "Celsius", symbol: "°C", toBase: (v) => v + 273.15, fromBase: (v) => v - 273.15 },
      { id: "f", label: "Fahrenheit", symbol: "°F", toBase: (v) => (v - 32) * (5 / 9) + 273.15, fromBase: (v) => (v - 273.15) * (9 / 5) + 32 },
      { id: "k", label: "Kelvin", symbol: "K", toBase: (v) => v, fromBase: (v) => v },
      { id: "r", label: "Rankine", symbol: "°R", toBase: (v) => v * (5 / 9), fromBase: (v) => v * (9 / 5) },
    ],
  },
  speed: {
    id: "speed",
    label: "Speed",
    subtitle: "mph · km/h · m/s · kn",
    baseUnit: "m/s",
    thumbHint: { primary: "mph", secondary: "km/h" },
    accent: "speed",
    iconName: "speedometer-outline",
    units: [
      { id: "mps", label: "Meters / second", symbol: "m/s", ...linear(1) },
      { id: "kmh", label: "Kilometers / hour", symbol: "km/h", ...linear(1 / 3.6) },
      { id: "mph", label: "Miles / hour", symbol: "mph", ...linear(0.44704) },
      { id: "fps", label: "Feet / second", symbol: "ft/s", ...linear(0.3048) },
      { id: "kn", label: "Knot", symbol: "kn", ...linear(0.514444) },
    ],
  },
  area: {
    id: "area",
    label: "Area",
    subtitle: "m² · ft² · acres · km²",
    baseUnit: "m²",
    thumbHint: { primary: "m²", secondary: "ac" },
    accent: "area",
    iconName: "square-outline",
    units: [
      { id: "mm2", label: "Square millimeter", symbol: "mm²", ...linear(0.000001) },
      { id: "cm2", label: "Square centimeter", symbol: "cm²", ...linear(0.0001) },
      { id: "m2", label: "Square meter", symbol: "m²", ...linear(1) },
      { id: "ha", label: "Hectare", symbol: "ha", ...linear(10000) },
      { id: "km2", label: "Square kilometer", symbol: "km²", ...linear(1_000_000) },
      { id: "in2", label: "Square inch", symbol: "in²", ...linear(0.00064516) },
      { id: "ft2", label: "Square foot", symbol: "ft²", ...linear(0.092903) },
      { id: "yd2", label: "Square yard", symbol: "yd²", ...linear(0.836127) },
      { id: "ac", label: "Acre", symbol: "ac", ...linear(4046.86) },
      { id: "mi2", label: "Square mile", symbol: "mi²", ...linear(2_589_988.11) },
    ],
  },
  dataSize: {
    id: "dataSize",
    label: "Data Size",
    subtitle: "B · KB · MB · GB · TB",
    baseUnit: "B",
    thumbHint: { primary: "B", secondary: "MB", tertiary: "KB" },
    accent: "dataSize",
    iconName: "server-outline",
    units: [
      { id: "b", label: "Byte", symbol: "B", ...linear(1) },
      { id: "kb", label: "Kilobyte", symbol: "KB", ...linear(1000) },
      { id: "mb", label: "Megabyte", symbol: "MB", ...linear(1_000_000) },
      { id: "gb", label: "Gigabyte", symbol: "GB", ...linear(1_000_000_000) },
      { id: "tb", label: "Terabyte", symbol: "TB", ...linear(1_000_000_000_000) },
      { id: "pb", label: "Petabyte", symbol: "PB", ...linear(1_000_000_000_000_000) },
      { id: "kib", label: "Kibibyte", symbol: "KiB", ...linear(1024) },
      { id: "mib", label: "Mebibyte", symbol: "MiB", ...linear(1024 ** 2) },
      { id: "gib", label: "Gibibyte", symbol: "GiB", ...linear(1024 ** 3) },
      { id: "tib", label: "Tebibyte", symbol: "TiB", ...linear(1024 ** 4) },
      { id: "bit", label: "Bit", symbol: "bit", ...linear(1 / 8) },
    ],
  },
  fuelEconomy: {
    // Base unit: L/100km. Reciprocal for MPG-style units.
    id: "fuelEconomy",
    label: "Fuel Economy",
    subtitle: "MPG · L/100km · km/L",
    baseUnit: "L/100km",
    thumbHint: { primary: "MPG", secondary: "L/100km" },
    accent: "fuelEconomy",
    iconName: "car-outline",
    units: [
      { id: "l100km", label: "Liters / 100 km", symbol: "L/100km", toBase: (v) => v, fromBase: (v) => v },
      { id: "kmpl", label: "Kilometers / liter", symbol: "km/L", toBase: (v) => (v === 0 ? 0 : 100 / v), fromBase: (v) => (v === 0 ? 0 : 100 / v) },
      { id: "mpgus", label: "Miles / gallon (US)", symbol: "MPG (US)", toBase: (v) => (v === 0 ? 0 : 235.215 / v), fromBase: (v) => (v === 0 ? 0 : 235.215 / v) },
      { id: "mpguk", label: "Miles / gallon (UK)", symbol: "MPG (UK)", toBase: (v) => (v === 0 ? 0 : 282.481 / v), fromBase: (v) => (v === 0 ? 0 : 282.481 / v) },
    ],
  },
  pressure: {
    id: "pressure",
    label: "Pressure",
    subtitle: "psi · bar · kPa · atm",
    baseUnit: "Pa",
    thumbHint: { primary: "psi", secondary: "bar" },
    accent: "pressure",
    iconName: "speedometer-outline",
    units: [
      { id: "pa", label: "Pascal", symbol: "Pa", ...linear(1) },
      { id: "kpa", label: "Kilopascal", symbol: "kPa", ...linear(1000) },
      { id: "mpa", label: "Megapascal", symbol: "MPa", ...linear(1_000_000) },
      { id: "bar", label: "Bar", symbol: "bar", ...linear(100_000) },
      { id: "psi", label: "PSI", symbol: "psi", ...linear(6894.757) },
      { id: "atm", label: "Atmosphere", symbol: "atm", ...linear(101_325) },
      { id: "torr", label: "Torr / mmHg", symbol: "Torr", ...linear(133.322) },
    ],
  },
  energy: {
    id: "energy",
    label: "Energy",
    subtitle: "J · kWh · cal · BTU",
    baseUnit: "J",
    thumbHint: { primary: "J", secondary: "kWh" },
    accent: "energy",
    iconName: "flash-outline",
    units: [
      { id: "j", label: "Joule", symbol: "J", ...linear(1) },
      { id: "kj", label: "Kilojoule", symbol: "kJ", ...linear(1000) },
      { id: "cal", label: "Calorie", symbol: "cal", ...linear(4.184) },
      { id: "kcal", label: "Kilocalorie", symbol: "kcal", ...linear(4184) },
      { id: "wh", label: "Watt-hour", symbol: "Wh", ...linear(3600) },
      { id: "kwh", label: "Kilowatt-hour", symbol: "kWh", ...linear(3_600_000) },
      { id: "btu", label: "BTU", symbol: "BTU", ...linear(1055.06) },
      { id: "ftlb", label: "Foot-pound", symbol: "ft·lb", ...linear(1.35582) },
      { id: "ev", label: "Electronvolt", symbol: "eV", ...linear(1.602176634e-19) },
    ],
  },
};

export const categoryList: Category[] = Object.values(categories);

export function convert(value: number, fromUnitId: string, toUnitId: string, categoryId: CategoryId): number {
  const cat = categories[categoryId];
  const from = cat.units.find((u) => u.id === fromUnitId);
  const to = cat.units.find((u) => u.id === toUnitId);
  if (!from || !to) return NaN;
  const inBase = from.toBase(value);
  return to.fromBase(inBase);
}

export function findUnit(categoryId: CategoryId, unitId: string): Unit | undefined {
  return categories[categoryId].units.find((u) => u.id === unitId);
}
