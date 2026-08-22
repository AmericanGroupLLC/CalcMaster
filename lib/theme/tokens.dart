import 'package:flutter/material.dart';

/// Colour tokens.
///
/// Contrast ratios quoted below are measured against the three dark grounds
/// ([bg], [surface], [surfaceAlt]) and are held to WCAG 2.1 AA for normal text
/// (4.5:1). `test/theme_contrast_test.dart` recomputes them, so a token edit
/// that drops a foreground below AA fails the suite.
class AppColors {
  static const bg = Color(0xFF0B1020);
  static const surface = Color(0xFF141A2E);
  static const surfaceAlt = Color(0xFF1B2238);
  static const surfaceElevated = Color(0xFF222A45);
  static const text = Color(0xFFFFFFFF); // 15.8–18.9:1
  static const textMuted = Color(0x9EFFFFFF); // 62% → 6.9–7.6:1
  /// 49% white. Was 42% (0x6B), which measured 3.9–4.1:1 and failed AA — it is
  /// used for inactive bottom-nav labels, so the failure was on every screen.
  /// 49% is the lowest value clearing 4.5:1 on all four grounds, the tightest
  /// being the lightest one, [surfaceElevated].
  static const textDim = Color(0x7DFFFFFF); // 49% → 4.56–4.86:1

  /// Card fill. Cards used to be painted as white at 6% alpha behind a
  /// `BackdropFilter`, which over a near-black gradient produced almost no
  /// separation — they read as barely-there rectangles. A solid, deliberately
  /// lighter surface plus [shadowElevated] gives them a physical edge, and
  /// costs far less to render than a blur.
  ///
  /// Kept no lighter than [surfaceElevated] so existing text-contrast
  /// guarantees continue to hold.
  static const surfaceCard = Color(0xFF1A2138);

  static const border = Color(0x14FFFFFF); // 8% — decorative, not text
  static const borderStrong = Color(0x24FFFFFF); // 14% — decorative, not text

  /// Drop shadow for raised surfaces. Dark rather than tinted, so it reads as
  /// depth instead of glow.
  static const List<BoxShadow> shadowElevated = [
    BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// Brand purple. Use for **fills, gradients and glows** — as a foreground it
  /// measures only 3.97:1 on [surface] and fails AA. For accent-coloured text
  /// or icons use [accentText].
  static const accentPrimary = Color(0xFF7C5CFF);

  /// Lightened brand purple for accent-coloured **text and icons** on dark
  /// grounds: 4.51–6.03:1, so it clears AA where [accentPrimary] did not.
  /// Same hue and saturation, lightness raised 0.68 → 0.75 (the tightest
  /// ground is [surfaceElevated] at 4.51:1).
  static const accentText = Color(0xFF977DFF);

  static const danger = Color(0xFFFF5C7A); // 5.8–6.4:1
  static const success = Color(0xFF5CE0A8); // 10.4–11.4:1
  static const warning = Color(0xFFFFC85C); // 11.2–12.3:1
}

class CategoryAccent {
  static const distance = Color(0xFF5CE0A8); // mint
  static const volume = Color(0xFF7CC8FF); // sky
  static const weight = Color(0xFFB89CFF); // lavender
  static const temperature = Color(0xFFFF8A65); // peach
  static const speed = Color(0xFFFFC85C); // amber
  static const area = Color(0xFF9DFFB0); // lime
  static const dataSize = Color(0xFFA5B8FF); // periwinkle
  static const fuelEconomy = Color(0xFFFF7AC6); // magenta
  static const pressure = Color(0xFFFF9BB3); // rose
  static const energy = Color(0xFFFFD86B); // gold
}

/// Aspect ratio for a hub-grid cell, adjusted for the user's font size.
///
/// The hub grids pin `childAspectRatio`, which fixes cell *height* while the
/// card's title and subtitle grow with the text scale — so at 1.3x and above
/// the card overflowed its cell (a RenderFlex overflow, and clipped text on a
/// real device). Dividing the ratio by the text scale grows the cell instead.
/// At 1.0x this returns [base] unchanged, so the default layout is untouched.
///
/// ```dart
/// GridView.extent(childAspectRatio: hubCardAspectRatio(context, 1.6), ...)
/// ```
double hubCardAspectRatio(BuildContext context, double base) {
  final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 2.0);
  return base / scale;
}

class Radii {
  static const card = 22.0;
  static const cardThumb = 18.0;
  static const pill = 999.0;
  static const button = 14.0;
  static const input = 16.0;
}

class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
