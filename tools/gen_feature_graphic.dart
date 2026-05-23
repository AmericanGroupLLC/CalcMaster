// =====================================================================
//  CalcMaster · Play Store Feature Graphic Generator
// =====================================================================
//
//  Run from project root:
//      dart run tools/gen_feature_graphic.dart
//
//  Output:
//      marketing/play-store/feature-graphic-1024x500.png
//
//  Requirements satisfied:
//    • 1024×500 px, PNG, no transparency  (Google Play spec)
//    • Critical content kept inside left safe zone
//    • Brand colors mirror lib/theme/tokens.dart
// =====================================================================

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const int kWidth = 1024;
const int kHeight = 500;

// CalcMaster brand palette (must mirror lib/theme/tokens.dart)
const _bgTop = (red: 0x0B, green: 0x10, blue: 0x20);
const _bgBottom = (red: 0x14, green: 0x1A, blue: 0x2E);
const _accent = (red: 0x7C, green: 0x5C, blue: 0xFF); // primary purple
const _accentSoft = (red: 0xB8, green: 0x9C, blue: 0xFF); // lavender
const _mint = (red: 0x5C, green: 0xE0, blue: 0xA8);
const _white = (red: 0xFF, green: 0xFF, blue: 0xFF);
const _textMuted = (red: 0x9E, green: 0x9E, blue: 0xB0);

img.Color rgb(({int red, int green, int blue}) c, [int a = 255]) =>
    img.ColorRgba8(c.red, c.green, c.blue, a);

void main() {
  final canvas = img.Image(width: kWidth, height: kHeight, numChannels: 3);

  _fillVerticalGradient(canvas, _bgTop, _bgBottom);
  _drawSubtleDotGrid(canvas);
  _drawAccentRays(canvas);

  // Left panel — wordmark + tagline + feature ribbons
  _drawWordmark(canvas, leftX: 64, baselineY: 200);
  _drawTagline(canvas, leftX: 64, baselineY: 260);
  _drawFeatureChips(canvas, leftX: 64, topY: 320);

  // Right panel — CM monogram badge with accent ring
  _drawMonogramBadge(canvas, centerX: kWidth - 200, centerY: kHeight ~/ 2);

  Directory('marketing/play-store').createSync(recursive: true);
  final out = File('marketing/play-store/feature-graphic-1024x500.png');
  out.writeAsBytesSync(img.encodePng(canvas));

  stdout.writeln('✓ ${out.path}  (${canvas.width}×${canvas.height})');
}

// ---------------------------------------------------------------------
// Background
// ---------------------------------------------------------------------
void _fillVerticalGradient(
  img.Image image,
  ({int red, int green, int blue}) top,
  ({int red, int green, int blue}) bottom,
) {
  for (var y = 0; y < image.height; y++) {
    final t = y / (image.height - 1);
    final r = (top.red + (bottom.red - top.red) * t).round();
    final g = (top.green + (bottom.green - top.green) * t).round();
    final b = (top.blue + (bottom.blue - top.blue) * t).round();
    final color = img.ColorRgba8(r, g, b, 255);
    for (var x = 0; x < image.width; x++) {
      image.setPixel(x, y, color);
    }
  }
}

void _drawSubtleDotGrid(img.Image image) {
  final dotR = 1;
  final spacing = 24;
  final color = img.ColorRgba8(_accentSoft.red, _accentSoft.green, _accentSoft.blue, 12);
  for (var y = 12; y < image.height; y += spacing) {
    for (var x = 12; x < image.width; x += spacing) {
      img.fillCircle(image, x: x, y: y, radius: dotR, color: color);
    }
  }
}

void _drawAccentRays(img.Image image) {
  // Soft purple radial-style glow on the right side, behind the monogram.
  final cx = image.width - 200;
  final cy = image.height ~/ 2;
  for (var r = 240; r > 60; r -= 8) {
    final alpha = (8 + (240 - r) ~/ 18).clamp(0, 28);
    final color = img.ColorRgba8(
      _accent.red,
      _accent.green,
      _accent.blue,
      alpha,
    );
    img.drawCircle(image, x: cx, y: cy, radius: r, color: color);
  }
}

// ---------------------------------------------------------------------
// "CalcMaster" wordmark — stylised C+M block letters with a mint dot accent.
// Same construction as the app icon, scaled for banner.
// ---------------------------------------------------------------------
void _drawWordmark(img.Image image, {required int leftX, required int baselineY}) {
  // The wordmark we render is the brand bug "CM·" + the word painted below.
  // For the banner we keep it simple: two stylised glyphs side by side, big.
  final stroke = 18;
  final letterW = 70;
  final letterH = 110;
  final gap = 14;
  final accent = rgb(_accent);
  final mint = rgb(_mint);

  // C
  final cLeft = leftX;
  final cTop = baselineY - letterH;
  img.fillRect(image, x1: cLeft, y1: cTop, x2: cLeft + letterW, y2: cTop + stroke, color: accent);
  img.fillRect(image, x1: cLeft, y1: baselineY - stroke, x2: cLeft + letterW, y2: baselineY, color: accent);
  img.fillRect(image, x1: cLeft, y1: cTop, x2: cLeft + stroke, y2: baselineY, color: accent);

  // M
  final mLeft = cLeft + letterW + gap;
  final mTop = cTop;
  img.fillRect(image, x1: mLeft, y1: mTop, x2: mLeft + stroke, y2: baselineY, color: accent);
  img.fillRect(image, x1: mLeft + letterW - stroke, y1: mTop, x2: mLeft + letterW, y2: baselineY, color: accent);
  // V valley
  final innerLeft = (x: mLeft + stroke, y: mTop);
  final innerRight = (x: mLeft + letterW - stroke, y: mTop);
  final valley = (x: mLeft + letterW ~/ 2, y: mTop + (letterH * 0.55).round());
  _drawAngledStroke(image,
      x1: innerLeft.x, y1: innerLeft.y,
      x2: valley.x, y2: valley.y,
      thickness: stroke, color: accent);
  _drawAngledStroke(image,
      x1: valley.x, y1: valley.y,
      x2: innerRight.x, y2: innerRight.y,
      thickness: stroke, color: accent);

  // Mint accent dot
  img.fillCircle(image,
      x: cLeft + letterW - stroke ~/ 2,
      y: baselineY - stroke ~/ 2 - (stroke * 0.6).round(),
      radius: (stroke * 0.55).round(),
      color: mint);

  // Wordmark text label
  img.drawString(image, 'CALCMASTER',
      font: img.arial48,
      x: cLeft + letterW * 2 + gap + 20,
      y: cTop + 30,
      color: rgb(_white));
}

// ---------------------------------------------------------------------
// Tagline & feature chips
// ---------------------------------------------------------------------
void _drawTagline(img.Image image, {required int leftX, required int baselineY}) {
  img.drawString(image, 'World calculator & converter',
      font: img.arial24, x: leftX, y: baselineY - 20, color: rgb(_textMuted));
}

void _drawFeatureChips(img.Image image, {required int leftX, required int topY}) {
  final chips = [
    'CONVERT',
    'CALCULATE',
    'FINANCE',
    'TOOLS',
    'NOTES',
  ];
  var cursorX = leftX;
  for (final label in chips) {
    final chipW = label.length * 13 + 28;
    final chipH = 32;
    // Pill outline
    final color = img.ColorRgba8(_accent.red, _accent.green, _accent.blue, 36);
    img.fillRect(image, x1: cursorX, y1: topY, x2: cursorX + chipW, y2: topY + chipH, color: color);
    img.drawRect(image,
        x1: cursorX, y1: topY, x2: cursorX + chipW, y2: topY + chipH,
        color: img.ColorRgba8(_accent.red, _accent.green, _accent.blue, 120),
        thickness: 2);
    // Text
    img.drawString(image, label,
        font: img.arial14, x: cursorX + 14, y: topY + 8, color: rgb(_accentSoft));
    cursorX += chipW + 10;
  }
}

// ---------------------------------------------------------------------
// Right-side monogram badge — large CM in a circular plate with accent ring
// ---------------------------------------------------------------------
void _drawMonogramBadge(img.Image image, {required int centerX, required int centerY}) {
  // Outer ring — drawn as filled annulus (ring) for guaranteed thickness
  final ringColor = img.ColorRgba8(_accent.red, _accent.green, _accent.blue, 200);
  for (var rr = 167; rr <= 173; rr++) {
    img.drawCircle(image, x: centerX, y: centerY, radius: rr, color: ringColor);
  }
  // Soft inner plate
  img.fillCircle(image, x: centerX, y: centerY, radius: 156,
      color: img.ColorRgba8(_bgTop.red, _bgTop.green, _bgTop.blue, 230));
  // CM monogram inside
  final stroke = 24;
  final letterW = 88;
  final letterH = 132;
  final gap = 8;
  final accent = rgb(_accent);
  final mint = rgb(_mint);

  final cLeft = centerX - letterW - gap ~/ 2;
  final cTop = centerY - letterH ~/ 2;
  img.fillRect(image, x1: cLeft, y1: cTop, x2: cLeft + letterW, y2: cTop + stroke, color: accent);
  img.fillRect(image, x1: cLeft, y1: cTop + letterH - stroke, x2: cLeft + letterW, y2: cTop + letterH, color: accent);
  img.fillRect(image, x1: cLeft, y1: cTop, x2: cLeft + stroke, y2: cTop + letterH, color: accent);

  final mLeft = centerX + gap ~/ 2;
  final mTop = cTop;
  img.fillRect(image, x1: mLeft, y1: mTop, x2: mLeft + stroke, y2: mTop + letterH, color: accent);
  img.fillRect(image, x1: mLeft + letterW - stroke, y1: mTop, x2: mLeft + letterW, y2: mTop + letterH, color: accent);
  final iLeft = (x: mLeft + stroke, y: mTop);
  final iRight = (x: mLeft + letterW - stroke, y: mTop);
  final valley = (x: mLeft + letterW ~/ 2, y: mTop + (letterH * 0.55).round());
  _drawAngledStroke(image,
      x1: iLeft.x, y1: iLeft.y,
      x2: valley.x, y2: valley.y,
      thickness: stroke, color: accent);
  _drawAngledStroke(image,
      x1: valley.x, y1: valley.y,
      x2: iRight.x, y2: iRight.y,
      thickness: stroke, color: accent);

  img.fillCircle(image,
      x: cLeft + letterW - stroke ~/ 2,
      y: cTop + letterH - stroke ~/ 2 - (stroke * 0.6).round(),
      radius: (stroke * 0.55).round(),
      color: mint);
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------
void _drawAngledStroke(
  img.Image image, {
  required int x1,
  required int y1,
  required int x2,
  required int y2,
  required int thickness,
  required img.Color color,
}) {
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
