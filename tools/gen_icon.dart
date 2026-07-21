// =====================================================================
//  Calculator · Icon + Splash Asset Generator
// =====================================================================
//
//  Run from the project root:
//      dart run tools/gen_icon.dart
//
//  Outputs:
//      assets/icon/app_icon.png             # 1024×1024 main app icon
//      assets/icon/app_icon_foreground.png  # 1024×1024 with transparent BG (for Android adaptive)
//      assets/splash/splash_logo.png        # 720×720 splash logo on transparent BG
//
//  After running this, run:
//      dart run flutter_launcher_icons
//      dart run flutter_native_splash:create
//
// =====================================================================

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const int kIconSize = 1024;
const int kSplashSize = 720;

// CalcMaster brand colors (must mirror lib/theme/tokens.dart)
const _bg = (red: 0x0B, green: 0x10, blue: 0x20);
const _bgGradient = (red: 0x14, green: 0x1A, blue: 0x2E);
const _accent = (red: 0x7C, green: 0x5C, blue: 0xFF); // primary purple
const _accentSoft = (red: 0xB8, green: 0x9C, blue: 0xFF); // lavender
const _mint = (red: 0x5C, green: 0xE0, blue: 0xA8);

img.Color rgb(({int red, int green, int blue}) c, [int a = 255]) =>
    img.ColorRgba8(c.red, c.green, c.blue, a);

void main() {
  final iconWithBg = _renderIcon(withBackground: true);
  final iconForeground = _renderIcon(withBackground: false);
  final splash = _renderSplash();

  Directory('assets/icon').createSync(recursive: true);
  Directory('assets/splash').createSync(recursive: true);

  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(iconWithBg));
  File('assets/icon/app_icon_foreground.png').writeAsBytesSync(img.encodePng(iconForeground));
  File('assets/splash/splash_logo.png').writeAsBytesSync(img.encodePng(splash));

  stdout.writeln('✓ assets/icon/app_icon.png            (${iconWithBg.width}×${iconWithBg.height})');
  stdout.writeln('✓ assets/icon/app_icon_foreground.png (${iconForeground.width}×${iconForeground.height})');
  stdout.writeln('✓ assets/splash/splash_logo.png       (${splash.width}×${splash.height})');
  stdout.writeln('');
  stdout.writeln('Now run:');
  stdout.writeln('  dart run flutter_launcher_icons');
  stdout.writeln('  dart run flutter_native_splash:create');
}

// ---------------------------------------------------------------------
// Icon — square 1024×1024 with rounded gradient background and a centered
// calculator glyph (body + screen + keypad) in the brand colors.
// ---------------------------------------------------------------------
img.Image _renderIcon({required bool withBackground}) {
  final image = img.Image(width: kIconSize, height: kIconSize, numChannels: 4);
  // Transparent base for the foreground variant.
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  if (withBackground) {
    _fillRoundedGradient(image, _bg, _bgGradient);
  }

  // The calculator glyph, centered.
  _drawCalculator(image);
  return image;
}

img.Image _renderSplash() {
  // Splash logo is the foreground glyph on transparent — flutter_native_splash
  // composites it onto a solid color bg from pubspec.
  final image = img.Image(width: kSplashSize, height: kSplashSize, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
  _drawCalculator(image, scale: 0.78);
  return image;
}

// Fill with a vertical linear gradient inside a rounded-square mask.
void _fillRoundedGradient(
  img.Image image,
  ({int red, int green, int blue}) top,
  ({int red, int green, int blue}) bottom,
) {
  final w = image.width;
  final h = image.height;
  final radius = (w * 0.22).round(); // ~22% radius like iOS app icons (cosmetic — iOS auto-rounds)
  for (var y = 0; y < h; y++) {
    final t = y / (h - 1);
    final r = (top.red + (bottom.red - top.red) * t).round();
    final g = (top.green + (bottom.green - top.green) * t).round();
    final b = (top.blue + (bottom.blue - top.blue) * t).round();
    for (var x = 0; x < w; x++) {
      if (_inRoundedRect(x, y, w, h, radius)) {
        image.setPixel(x, y, img.ColorRgba8(r, g, b, 255));
      }
    }
  }
}

bool _inRoundedRect(int x, int y, int w, int h, int radius) {
  // Treat each corner as a quarter-circle test.
  final rx = math.min(x, w - 1 - x);
  final ry = math.min(y, h - 1 - y);
  if (rx >= radius || ry >= radius) return true;
  final dx = radius - rx;
  final dy = radius - ry;
  return dx * dx + dy * dy <= radius * radius;
}

// Fill an axis-aligned rounded rectangle [x1,y1)-(x2,y2) with a solid color.
void _fillRoundRect(
  img.Image image,
  int x1,
  int y1,
  int x2,
  int y2,
  int radius,
  img.Color color,
) {
  final w = x2 - x1;
  final h = y2 - y1;
  if (w <= 0 || h <= 0) return;
  final r = math.min(radius, math.min(w, h) ~/ 2);
  for (var y = y1; y < y2; y++) {
    for (var x = x1; x < x2; x++) {
      if (_inRoundedRect(x - x1, y - y1, w, h, r)) {
        image.setPixel(x, y, color);
      }
    }
  }
}

// Calculator glyph: a rounded body holding a screen and a 3×3 keypad.
// The right key column is accent purple (operators) with a mint bottom-right
// "equals" key — original artwork that reads as a calculator at any size.
void _drawCalculator(img.Image image, {double scale = 1.0}) {
  final w = image.width;
  final cx = w ~/ 2;
  final cy = image.height ~/ 2;

  final body = img.ColorRgba8(247, 248, 252, 255); // soft white card
  final screen = rgb(_bg); // dark navy display
  final keyGray = img.ColorRgba8(0xCE, 0xD4, 0xE2, 255);
  final accent = rgb(_accent);
  final accentSoft = rgb(_accentSoft);
  final mint = rgb(_mint);

  // ---- Body ----
  final bodyW = (w * 0.52 * scale).round();
  final bodyH = (w * 0.66 * scale).round();
  final bl = cx - bodyW ~/ 2;
  final bt = cy - bodyH ~/ 2;
  _fillRoundRect(image, bl, bt, bl + bodyW, bt + bodyH, (bodyW * 0.15).round(), body);

  final pad = (bodyW * 0.11).round();
  final ix = bl + pad;
  final iw = bodyW - 2 * pad;

  // ---- Screen ----
  final st = bt + pad;
  final sh = (bodyH * 0.17).round();
  _fillRoundRect(image, ix, st, ix + iw, st + sh, (sh * 0.22).round(), screen);
  // A right-aligned accent block on the screen, suggesting a digit.
  final numW = (iw * 0.30).round();
  final numH = (sh * 0.34).round();
  final numY = st + (sh - numH) ~/ 2;
  _fillRoundRect(image, ix + iw - numW, numY, ix + iw, numY + numH, (numH * 0.3).round(), accentSoft);

  // ---- Keypad: 3 × 3 ----
  const cols = 3;
  const rows = 3;
  final gtop = st + sh + pad;
  final gbottom = bt + bodyH - pad;
  final gap = (iw * 0.12).round();
  final keyW = ((iw - (cols - 1) * gap) / cols).floor();
  final keyH = ((gbottom - gtop - (rows - 1) * gap) / rows).floor();
  final keyR = (keyW * 0.30).round();
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      final kx = ix + c * (keyW + gap);
      final ky = gtop + r * (keyH + gap);
      img.Color kc = keyGray;
      if (c == cols - 1) kc = accent; // right column = operators
      if (r == rows - 1 && c == cols - 1) kc = mint; // bottom-right = equals
      _fillRoundRect(image, kx, ky, kx + keyW, ky + keyH, keyR, kc);
    }
  }
}
