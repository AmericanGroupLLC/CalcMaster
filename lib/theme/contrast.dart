import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart' show HSLColor;

/// WCAG 2.1 contrast utilities.
///
/// Widgets like `PillBadge` and `ChipPicker` take an arbitrary accent colour
/// from their caller and paint small text with it. Callers cannot be expected
/// to check contrast per colour — and when they didn't, the result was real
/// AA failures (the "UNIT CONVERSION" badge measured 3.76:1). [legibleOn]
/// guarantees legibility at the point of use instead.

/// Relative luminance per WCAG 2.1.
double relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Contrast ratio between [foreground] and an opaque [ground], 1.0–21.0.
///
/// A translucent [foreground] is composited over [ground] first, so passing a
/// colour with alpha gives the ratio the user actually perceives.
///
/// ```dart
/// contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)); // 21.0
/// ```
double contrastRatio(Color foreground, Color ground) {
  final fg = Color.alphaBlend(foreground, ground);
  final a = relativeLuminance(fg);
  final b = relativeLuminance(ground);
  final hi = math.max(a, b);
  final lo = math.min(a, b);
  return (hi + 0.05) / (lo + 0.05);
}

/// [color] lightened just enough to reach [minRatio] against [ground],
/// preserving hue and saturation. Returns [color] unchanged when it already
/// passes, and white if even full lightness cannot reach the target.
///
/// ```dart
/// // Brand purple is only 3.8:1 on its own tinted badge — this lifts it to AA.
/// final safe = legibleOn(AppColors.accentPrimary, badgeBackground);
/// ```
Color legibleOn(Color color, Color ground, {double minRatio = 4.5}) {
  if (contrastRatio(color, ground) >= minRatio) return color;

  final hsl = HSLColor.fromColor(Color.alphaBlend(color, ground));
  // 2% steps: fine enough that the hue shift is imperceptible, bounded so this
  // is a handful of iterations rather than a search.
  for (var l = hsl.lightness; l <= 1.0; l += 0.02) {
    final candidate = hsl.withLightness(math.min(l, 1.0)).toColor();
    if (contrastRatio(candidate, ground) >= minRatio) return candidate;
  }
  return const Color(0xFFFFFFFF);
}
