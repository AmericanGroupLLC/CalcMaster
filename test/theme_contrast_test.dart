import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';

import 'package:calcmaster/theme/contrast.dart';
import 'package:calcmaster/theme/tokens.dart';

/// WCAG 2.1 contrast checks for the colour tokens.
///
/// The bottom-nav labels used to fail AA in *both* states — the active label
/// was `accentPrimary` (3.97:1 on surface) and the inactive one `textDim`
/// (4.06:1) — so the failure was visible on every screen. These tests pin the
/// fix so a token edit cannot quietly reintroduce it.

void main() {
  const grounds = <String, Color>{
    'bg': AppColors.bg,
    'surface': AppColors.surface,
    'surfaceAlt': AppColors.surfaceAlt,
    'surfaceElevated': AppColors.surfaceElevated,
    'surfaceCard': AppColors.surfaceCard,
  };

  // Every token used to paint text or icons on a dark ground.
  const foregrounds = <String, Color>{
    'text': AppColors.text,
    'textMuted': AppColors.textMuted,
    'textDim': AppColors.textDim,
    'accentText': AppColors.accentText,
    'danger': AppColors.danger,
    'success': AppColors.success,
    'warning': AppColors.warning,
  };

  group('WCAG AA — text tokens reach 4.5:1 on every ground', () {
    foregrounds.forEach((fgName, fg) {
      grounds.forEach((groundName, ground) {
        test('$fgName on $groundName', () {
          final r = contrastRatio(fg, ground);
          expect(
            r,
            greaterThanOrEqualTo(4.5),
            reason: '$fgName on $groundName is ${r.toStringAsFixed(2)}:1, '
                'below the WCAG AA minimum of 4.5:1 for normal text.',
          );
        });
      });
    });
  });

  group('WCAG AA — category accents are legible as text', () {
    const accents = <String, Color>{
      'distance': CategoryAccent.distance,
      'volume': CategoryAccent.volume,
      'weight': CategoryAccent.weight,
      'temperature': CategoryAccent.temperature,
      'speed': CategoryAccent.speed,
      'area': CategoryAccent.area,
      'dataSize': CategoryAccent.dataSize,
      'fuelEconomy': CategoryAccent.fuelEconomy,
      'pressure': CategoryAccent.pressure,
      'energy': CategoryAccent.energy,
    };
    accents.forEach((name, c) {
      test('$name on surface', () {
        expect(contrastRatio(c, AppColors.surface), greaterThanOrEqualTo(4.5));
      });
    });
  });

  test('accentPrimary is documented as fill-only (it fails AA as text)', () {
    // Guards the reason accentText exists: if the brand purple ever becomes
    // AA-compliant on its own, accentText can be retired.
    expect(
      contrastRatio(AppColors.accentPrimary, AppColors.surface),
      lessThan(4.5),
      reason: 'accentPrimary now passes AA — reconsider whether accentText '
          'is still needed.',
    );
  });

  test('the contrast helper matches known WCAG values', () {
    // A test that cannot fail proves nothing: anchor the maths on pairs whose
    // ratios are fixed by the spec.
    expect(contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
        closeTo(21.0, 0.01));
    expect(contrastRatio(const Color(0xFF000000), const Color(0xFF000000)),
        closeTo(1.0, 0.01));
  });
}
