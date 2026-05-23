import 'package:flutter/material.dart';
import 'theme/tokens.dart';

class Unit {
  final String id;
  final String label;
  final String symbol;
  final double Function(double) toBase;
  final double Function(double) fromBase;

  const Unit({
    required this.id,
    required this.label,
    required this.symbol,
    required this.toBase,
    required this.fromBase,
  });
}

Unit _linear(String id, String label, String symbol, double factor) {
  return Unit(
    id: id,
    label: label,
    symbol: symbol,
    toBase: (v) => v * factor,
    fromBase: (v) => v / factor,
  );
}

class ThumbHint {
  final String primary;
  final String secondary;
  final String? tertiary;
  const ThumbHint(this.primary, this.secondary, [this.tertiary]);
}

class Category {
  final String id;
  final String label;
  final String subtitle;
  final ThumbHint hint;
  final Color accent;
  final IconData icon;
  final String svg;
  final List<Unit> units;

  const Category({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.hint,
    required this.accent,
    required this.icon,
    required this.svg,
    required this.units,
  });

  Unit? unitById(String id) {
    for (final u in units) {
      if (u.id == id) return u;
    }
    return null;
  }
}

double convert(double value, String fromId, String toId, Category cat) {
  final from = cat.unitById(fromId);
  final to = cat.unitById(toId);
  if (from == null || to == null) return double.nan;
  final inBase = from.toBase(value);
  return to.fromBase(inBase);
}

final List<Category> categories = [
  Category(
    id: 'distance',
    label: 'Distance',
    subtitle: 'km · mi · ft · m · in',
    hint: const ThumbHint('mi', 'ft'),
    accent: CategoryAccent.distance,
    icon: Icons.straighten,
    svg: 'assets/icons/distance.svg',
    units: [
      _linear('mm', 'Millimeter', 'mm', 0.001),
      _linear('cm', 'Centimeter', 'cm', 0.01),
      _linear('m', 'Meter', 'm', 1),
      _linear('km', 'Kilometer', 'km', 1000),
      _linear('in', 'Inch', 'in', 0.0254),
      _linear('ft', 'Foot', 'ft', 0.3048),
      _linear('yd', 'Yard', 'yd', 0.9144),
      _linear('mi', 'Mile', 'mi', 1609.344),
      _linear('nmi', 'Nautical mile', 'nmi', 1852),
    ],
  ),
  Category(
    id: 'volume',
    label: 'Volume',
    subtitle: 'mL · L · gal · fl oz',
    hint: const ThumbHint('mL', 'gal', 'cup'),
    accent: CategoryAccent.volume,
    icon: Icons.science_outlined,
    svg: 'assets/icons/volume.svg',
    units: [
      _linear('ml', 'Milliliter', 'mL', 0.001),
      _linear('l', 'Liter', 'L', 1),
      _linear('tsp', 'Teaspoon (US)', 'tsp', 0.00492892),
      _linear('tbsp', 'Tablespoon (US)', 'tbsp', 0.0147868),
      _linear('floz', 'Fluid ounce (US)', 'fl oz', 0.0295735),
      _linear('cup', 'Cup (US)', 'cup', 0.236588),
      _linear('pt', 'Pint (US)', 'pt', 0.473176),
      _linear('qt', 'Quart (US)', 'qt', 0.946353),
      _linear('gal', 'Gallon (US)', 'gal', 3.78541),
      _linear('galuk', 'Gallon (UK)', 'gal UK', 4.54609),
    ],
  ),
  Category(
    id: 'weight',
    label: 'Weight',
    subtitle: 'kg · lb · g · oz · st',
    hint: const ThumbHint('lb', 'oz'),
    accent: CategoryAccent.weight,
    icon: Icons.fitness_center_outlined,
    svg: 'assets/icons/weight.svg',
    units: [
      _linear('mg', 'Milligram', 'mg', 0.000001),
      _linear('g', 'Gram', 'g', 0.001),
      _linear('kg', 'Kilogram', 'kg', 1),
      _linear('t', 'Metric ton', 't', 1000),
      _linear('oz', 'Ounce', 'oz', 0.0283495),
      _linear('lb', 'Pound', 'lb', 0.453592),
      _linear('st', 'Stone', 'st', 6.35029),
    ],
  ),
  Category(
    id: 'temperature',
    label: 'Temperature',
    subtitle: '°F · °C · K',
    hint: const ThumbHint('°F', '°C', 'K'),
    accent: CategoryAccent.temperature,
    icon: Icons.thermostat_outlined,
    svg: 'assets/icons/temperature.svg',
    units: [
      Unit(
        id: 'c',
        label: 'Celsius',
        symbol: '°C',
        toBase: (v) => v + 273.15,
        fromBase: (v) => v - 273.15,
      ),
      Unit(
        id: 'f',
        label: 'Fahrenheit',
        symbol: '°F',
        toBase: (v) => (v - 32) * (5 / 9) + 273.15,
        fromBase: (v) => (v - 273.15) * (9 / 5) + 32,
      ),
      Unit(
        id: 'k',
        label: 'Kelvin',
        symbol: 'K',
        toBase: (v) => v,
        fromBase: (v) => v,
      ),
      Unit(
        id: 'r',
        label: 'Rankine',
        symbol: '°R',
        toBase: (v) => v * (5 / 9),
        fromBase: (v) => v * (9 / 5),
      ),
    ],
  ),
  Category(
    id: 'speed',
    label: 'Speed',
    subtitle: 'mph · km/h · m/s · kn',
    hint: const ThumbHint('mph', 'km/h'),
    accent: CategoryAccent.speed,
    icon: Icons.speed_outlined,
    svg: 'assets/icons/speed.svg',
    units: [
      _linear('mps', 'Meters / second', 'm/s', 1),
      _linear('kmh', 'Kilometers / hour', 'km/h', 1 / 3.6),
      _linear('mph', 'Miles / hour', 'mph', 0.44704),
      _linear('fps', 'Feet / second', 'ft/s', 0.3048),
      _linear('kn', 'Knot', 'kn', 0.514444),
    ],
  ),
  Category(
    id: 'area',
    label: 'Area',
    subtitle: 'm² · ft² · acres · km²',
    hint: const ThumbHint('m²', 'ac'),
    accent: CategoryAccent.area,
    icon: Icons.crop_square_outlined,
    svg: 'assets/icons/area.svg',
    units: [
      _linear('mm2', 'Square millimeter', 'mm²', 0.000001),
      _linear('cm2', 'Square centimeter', 'cm²', 0.0001),
      _linear('m2', 'Square meter', 'm²', 1),
      _linear('ha', 'Hectare', 'ha', 10000),
      _linear('km2', 'Square kilometer', 'km²', 1000000),
      _linear('in2', 'Square inch', 'in²', 0.00064516),
      _linear('ft2', 'Square foot', 'ft²', 0.092903),
      _linear('yd2', 'Square yard', 'yd²', 0.836127),
      _linear('ac', 'Acre', 'ac', 4046.86),
      _linear('mi2', 'Square mile', 'mi²', 2589988.11),
    ],
  ),
  Category(
    id: 'dataSize',
    label: 'Data Size',
    subtitle: 'B · KB · MB · GB · TB',
    hint: const ThumbHint('B', 'MB', 'KB'),
    accent: CategoryAccent.dataSize,
    icon: Icons.storage_outlined,
    svg: 'assets/icons/data_size.svg',
    units: [
      _linear('b', 'Byte', 'B', 1),
      _linear('kb', 'Kilobyte', 'KB', 1000),
      _linear('mb', 'Megabyte', 'MB', 1000000),
      _linear('gb', 'Gigabyte', 'GB', 1e9),
      _linear('tb', 'Terabyte', 'TB', 1e12),
      _linear('pb', 'Petabyte', 'PB', 1e15),
      _linear('kib', 'Kibibyte', 'KiB', 1024),
      _linear('mib', 'Mebibyte', 'MiB', 1024 * 1024),
      _linear('gib', 'Gibibyte', 'GiB', 1024 * 1024 * 1024),
      _linear('tib', 'Tebibyte', 'TiB', 1024.0 * 1024 * 1024 * 1024),
      _linear('bit', 'Bit', 'bit', 1 / 8),
    ],
  ),
  Category(
    id: 'fuelEconomy',
    label: 'Fuel Economy',
    subtitle: 'MPG · L/100km · km/L',
    hint: const ThumbHint('MPG', 'L/100km'),
    accent: CategoryAccent.fuelEconomy,
    icon: Icons.local_gas_station_outlined,
    svg: 'assets/icons/fuel_economy.svg',
    units: [
      Unit(
        id: 'l100km',
        label: 'Liters / 100 km',
        symbol: 'L/100km',
        toBase: (v) => v,
        fromBase: (v) => v,
      ),
      Unit(
        id: 'kmpl',
        label: 'Kilometers / liter',
        symbol: 'km/L',
        toBase: (v) => v == 0 ? 0 : 100 / v,
        fromBase: (v) => v == 0 ? 0 : 100 / v,
      ),
      Unit(
        id: 'mpgus',
        label: 'Miles / gallon (US)',
        symbol: 'MPG (US)',
        toBase: (v) => v == 0 ? 0 : 235.215 / v,
        fromBase: (v) => v == 0 ? 0 : 235.215 / v,
      ),
      Unit(
        id: 'mpguk',
        label: 'Miles / gallon (UK)',
        symbol: 'MPG (UK)',
        toBase: (v) => v == 0 ? 0 : 282.481 / v,
        fromBase: (v) => v == 0 ? 0 : 282.481 / v,
      ),
    ],
  ),
  Category(
    id: 'pressure',
    label: 'Pressure',
    subtitle: 'psi · bar · kPa · atm',
    hint: const ThumbHint('psi', 'bar'),
    accent: CategoryAccent.pressure,
    icon: Icons.compress_outlined,
    svg: 'assets/icons/pressure.svg',
    units: [
      _linear('pa', 'Pascal', 'Pa', 1),
      _linear('kpa', 'Kilopascal', 'kPa', 1000),
      _linear('mpa', 'Megapascal', 'MPa', 1000000),
      _linear('bar', 'Bar', 'bar', 100000),
      _linear('psi', 'PSI', 'psi', 6894.757),
      _linear('atm', 'Atmosphere', 'atm', 101325),
      _linear('torr', 'Torr / mmHg', 'Torr', 133.322),
    ],
  ),
  Category(
    id: 'energy',
    label: 'Energy',
    subtitle: 'J · kWh · cal · BTU',
    hint: const ThumbHint('J', 'kWh'),
    accent: CategoryAccent.energy,
    icon: Icons.bolt_outlined,
    svg: 'assets/icons/energy.svg',
    units: [
      _linear('j', 'Joule', 'J', 1),
      _linear('kj', 'Kilojoule', 'kJ', 1000),
      _linear('cal', 'Calorie', 'cal', 4.184),
      _linear('kcal', 'Kilocalorie', 'kcal', 4184),
      _linear('wh', 'Watt-hour', 'Wh', 3600),
      _linear('kwh', 'Kilowatt-hour', 'kWh', 3600000),
      _linear('btu', 'BTU', 'BTU', 1055.06),
      _linear('ftlb', 'Foot-pound', 'ft·lb', 1.35582),
    ],
  ),
];

Category? categoryById(String id) {
  for (final c in categories) {
    if (c.id == id) return c;
  }
  return null;
}
