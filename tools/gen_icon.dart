// =====================================================================
//  CalcMaster · Icon + Splash Asset Generator
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
const _white = (red: 0xFF, green: 0xFF, blue: 0xFF);
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
// Icon — square 1024×1024 with rounded gradient background, big "CM"
// monogram in accent purple, with a calculator dot grid behind it.
// ---------------------------------------------------------------------
img.Image _renderIcon({required bool withBackground}) {
  final image = img.Image(width: kIconSize, height: kIconSize, numChannels: 4);
  // Transparent base for the foreground variant.
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  if (withBackground) {
    _fillRoundedGradient(image, _bg, _bgGradient);
  }

  // Subtle calculator grid backdrop (3×3 dots) — only when bg is opaque
  if (withBackground) {
    _drawDotGrid(image);
  }

  // The "CM" wordmark, centered.
  _drawMonogram(image);
  return image;
}

img.Image _renderSplash() {
  // Splash logo is the foreground monogram on transparent — flutter_native_splash
  // composites it onto a solid color bg from pubspec.
  final image = img.Image(width: kSplashSize, height: kSplashSize, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
  _drawMonogram(image, scale: 0.62);
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

// Draw a 3×3 rounded-square dot grid as a subtle backdrop. Echoes the
// app's calculator/keypad theme without being literal.
void _drawDotGrid(img.Image image) {
  final w = image.width;
  final h = image.height;
  final dotR = (w * 0.022).round();
  final spacing = (w * 0.16).round();
  final originX = w ~/ 2 - spacing;
  final originY = h ~/ 2 - spacing;
  final color = img.ColorRgba8(_accentSoft.red, _accentSoft.green, _accentSoft.blue, 22);
  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
      final cx = originX + i * spacing;
      final cy = originY + j * spacing;
      img.fillCircle(image, x: cx, y: cy, radius: dotR, color: color);
    }
  }
}

// "CM" stylized monogram. Built from rectangles + accent dot rather than
// trying to render text (avoids font-loading complexity in a CLI script).
void _drawMonogram(img.Image image, {double scale = 1.0}) {
  final w = image.width;
  final h = image.height;
  final cx = w ~/ 2;
  final cy = h ~/ 2;

  // Geometry: two stacked equal-thickness "C" and "M" forms, side-by-side.
  // We'll instead render a single bold "C" with a calculator dot — this
  // reads well at all sizes (down to 16×16 favicon).
  final stroke = (w * 0.10 * scale).round();
  final letterW = (w * 0.30 * scale).round();
  final letterH = (w * 0.46 * scale).round();
  final gap = (w * 0.04 * scale).round();

  final accent = rgb(_accent);
  final mint = rgb(_mint);

  // ---- "C" ----
  final cLeft = cx - letterW - gap ~/ 2;
  final cTop = cy - letterH ~/ 2;
  // Outer rounded rect (C shape) — a thick C drawn as 3 strokes
  // top stroke
  img.fillRect(
    image,
    x1: cLeft,
    y1: cTop,
    x2: cLeft + letterW,
    y2: cTop + stroke,
    color: accent,
  );
  // bottom stroke
  img.fillRect(
    image,
    x1: cLeft,
    y1: cTop + letterH - stroke,
    x2: cLeft + letterW,
    y2: cTop + letterH,
    color: accent,
  );
  // left stroke
  img.fillRect(
    image,
    x1: cLeft,
    y1: cTop,
    x2: cLeft + stroke,
    y2: cTop + letterH,
    color: accent,
  );

  // ---- "M" ----
  final mLeft = cx + gap ~/ 2;
  final mTop = cy - letterH ~/ 2;
  // Left vertical
  img.fillRect(
    image,
    x1: mLeft,
    y1: mTop,
    x2: mLeft + stroke,
    y2: mTop + letterH,
    color: accent,
  );
  // Right vertical
  img.fillRect(
    image,
    x1: mLeft + letterW - stroke,
    y1: mTop,
    x2: mLeft + letterW,
    y2: mTop + letterH,
    color: accent,
  );
  // Diagonal-V at the top center, drawn as two thick angled strokes that
  // stop *inside* the M's vertical strokes so the round caps don't bleed past.
  final innerLeftTop = (x: mLeft + stroke, y: mTop);
  final innerRightTop = (x: mLeft + letterW - stroke, y: mTop);
  final valleyCenter = (x: mLeft + letterW ~/ 2, y: mTop + (letterH * 0.55).round());
  _drawAngledStroke(image,
      x1: innerLeftTop.x, y1: innerLeftTop.y,
      x2: valleyCenter.x, y2: valleyCenter.y,
      thickness: stroke, color: accent);
  _drawAngledStroke(image,
      x1: valleyCenter.x, y1: valleyCenter.y,
      x2: innerRightTop.x, y2: innerRightTop.y,
      thickness: stroke, color: accent);

  // Mint accent dot in the bottom-right of the "C" — implies "calculate"
  final dotR = (stroke * 0.55).round();
  img.fillCircle(image,
      x: cLeft + letterW - stroke ~/ 2,
      y: cTop + letterH - stroke ~/ 2 - (stroke * 0.6).round(),
      radius: dotR,
      color: mint);
}

void _drawAngledStroke(
  img.Image image, {
  required int x1,
  required int y1,
  required int x2,
  required int y2,
  required int thickness,
  required img.Color color,
}) {
  // Rasterise a thick line by drawing a chain of filled circles.
  final dx = x2 - x1;
  final dy = y2 - y1;
  final length = math.sqrt(dx * dx + dy * dy).round();
  for (var i = 0; i <= length; i++) {
    final t = length == 0 ? 0.0 : i / length;
    final cx = (x1 + dx * t).round();
    final cy = (y1 + dy * t).round();
    img.fillCircle(image, x: cx, y: cy, radius: thickness ~/ 2, color: color);
  }
}
