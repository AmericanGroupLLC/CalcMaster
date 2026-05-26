import 'package:flutter_test/flutter_test.dart';
import 'package:calcmaster/lib_units.dart';

/// Helper: look up a category by id, assert it exists, then convert.
double c(String catId, double value, String fromId, String toId) {
  final cat = categoryById(catId);
  expect(cat, isNotNull, reason: 'Category "$catId" must exist');
  return convert(value, fromId, toId, cat!);
}

void main() {
  group('categories list', () {
    test('contains 10 categories', () => expect(categories.length, equals(10)));
    test('all expected category IDs present', () {
      final ids = categories.map((c) => c.id).toSet();
      expect(ids, containsAll(['distance', 'volume', 'weight', 'temperature',
          'speed', 'area', 'dataSize', 'fuelEconomy', 'pressure', 'energy']));
    });
    test('categoryById returns null for unknown id', () => expect(categoryById('unknown_xyz'), isNull));
    test('categoryById returns correct category', () {
      final cat = categoryById('distance');
      expect(cat, isNotNull);
      expect(cat!.label, equals('Distance'));
    });
  });

  group('convert — distance', () {
    test('1 km = 1000 m', () => expect(c('distance', 1, 'km', 'm'), closeTo(1000, 1e-6)));
    test('1 m = 100 cm', () => expect(c('distance', 1, 'm', 'cm'), closeTo(100, 1e-6)));
    test('1 mile = 1609.344 m', () => expect(c('distance', 1, 'mi', 'm'), closeTo(1609.344, 1e-3)));
    test('1 inch = 2.54 cm', () => expect(c('distance', 1, 'in', 'cm'), closeTo(2.54, 1e-6)));
    test('1 ft = 12 in', () => expect(c('distance', 1, 'ft', 'in'), closeTo(12, 1e-4)));
    test('same unit returns same value', () => expect(c('distance', 42, 'm', 'm'), closeTo(42.0, 1e-9)));
    test('zero converts to zero', () => expect(c('distance', 0, 'km', 'm'), 0.0));
    test('unknown unit returns NaN', () {
      final cat = categoryById('distance')!;
      expect(convert(1, 'km', 'INVALID', cat).isNaN, isTrue);
    });
  });

  group('convert — weight', () {
    test('1 kg = 1000 g', () => expect(c('weight', 1, 'kg', 'g'), closeTo(1000, 1e-6)));
    test('1 t = 1000 kg', () => expect(c('weight', 1, 't', 'kg'), closeTo(1000, 1e-6)));
  });

  group('convert — temperature', () {
    test('0 C = 32 F', () => expect(c('temperature', 0, 'c', 'f'), closeTo(32, 1e-6)));
    test('100 C = 212 F', () => expect(c('temperature', 100, 'c', 'f'), closeTo(212, 1e-6)));
    test('0 C = 273.15 K', () => expect(c('temperature', 0, 'c', 'k'), closeTo(273.15, 1e-6)));
    test('32 F = 0 C', () => expect(c('temperature', 32, 'f', 'c'), closeTo(0, 1e-6)));
    test('212 F = 100 C', () => expect(c('temperature', 212, 'f', 'c'), closeTo(100, 1e-6)));
    test('-40 C = -40 F', () => expect(c('temperature', -40, 'c', 'f'), closeTo(-40, 1e-6)));
  });

  group('convert — volume', () {
    test('1 L = 1000 mL', () => expect(c('volume', 1, 'l', 'ml'), closeTo(1000, 1e-6)));
    test('1 gal = 3.78541 L', () => expect(c('volume', 1, 'gal', 'l'), closeTo(3.78541, 1e-3)));
    test('1 cup = 236.588 mL', () => expect(c('volume', 1, 'cup', 'ml'), closeTo(236.588, 1e-2)));
  });

  group('convert — speed', () {
    test('1 kmh = 0.27778 m/s', () => expect(c('speed', 1, 'kmh', 'mps'), closeTo(0.27778, 1e-4)));
    test('1 mph = 0.44704 m/s', () => expect(c('speed', 1, 'mph', 'mps'), closeTo(0.44704, 1e-4)));
    test('1 kn = 0.514444 m/s', () => expect(c('speed', 1, 'kn', 'mps'), closeTo(0.514444, 1e-4)));
  });

  group('convert — data size (SI, 1000-based)', () {
    test('1 kb = 1000 b', () => expect(c('dataSize', 1, 'kb', 'b'), closeTo(1000, 1e-6)));
    test('1 mb = 1000 kb', () => expect(c('dataSize', 1, 'mb', 'kb'), closeTo(1000, 1e-6)));
    test('1 gb = 1000 mb', () => expect(c('dataSize', 1, 'gb', 'mb'), closeTo(1000, 1e-6)));
    test('1 kib = 1024 b', () => expect(c('dataSize', 1, 'kib', 'b'), closeTo(1024, 1e-6)));
    test('1 mib = 1024 kib', () => expect(c('dataSize', 1, 'mib', 'kib'), closeTo(1024, 1e-6)));
  });

  group('convert — area', () {
    test('1 m2 = 10000 cm2', () => expect(c('area', 1, 'm2', 'cm2'), closeTo(10000, 1e-6)));
    test('1 km2 = 1000000 m2', () => expect(c('area', 1, 'km2', 'm2'), closeTo(1000000, 1e-6)));
    test('1 ac = 4046.86 m2', () => expect(c('area', 1, 'ac', 'm2'), closeTo(4046.86, 1e-1)));
  });

  group('convert — pressure', () {
    test('1 atm = 101325 Pa', () => expect(c('pressure', 1, 'atm', 'pa'), closeTo(101325, 1e-3)));
    test('1 bar = 100000 Pa', () => expect(c('pressure', 1, 'bar', 'pa'), closeTo(100000, 1e-3)));
    test('1 kpa = 1000 Pa', () => expect(c('pressure', 1, 'kpa', 'pa'), closeTo(1000, 1e-6)));
  });

  group('convert — energy', () {
    test('1 kj = 1000 J', () => expect(c('energy', 1, 'kj', 'j'), closeTo(1000, 1e-6)));
    test('1 kcal = 4184 J', () => expect(c('energy', 1, 'kcal', 'j'), closeTo(4184, 1e-2)));
    test('1 kwh = 3600000 J', () => expect(c('energy', 1, 'kwh', 'j'), closeTo(3600000, 1e-3)));
  });

  group('convert — fuel economy (inverse scale)', () {
    test('1 L/100km → same in base', () => expect(c('fuelEconomy', 1, 'l100km', 'l100km'), closeTo(1, 1e-6)));
    test('100 km/L = 1 L/100km', () => expect(c('fuelEconomy', 100, 'kmpl', 'l100km'), closeTo(1, 1e-6)));
    test('235.215 MPG(US) = 1 L/100km', () => expect(c('fuelEconomy', 235.215, 'mpgus', 'l100km'), closeTo(1, 1e-2)));
  });

  group('Category.unitById', () {
    test('returns unit for valid id', () {
      final cat = categoryById('distance')!;
      final unit = cat.unitById('km');
      expect(unit, isNotNull);
      expect(unit!.label, equals('Kilometer'));
    });
    test('returns null for invalid id', () {
      final cat = categoryById('distance')!;
      expect(cat.unitById('INVALID'), isNull);
    });
  });
}
