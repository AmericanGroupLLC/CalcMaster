import 'package:flutter/material.dart';

/// Renders text with a soft accent-colored halo behind it. Use on hero numbers,
/// headlines, or any element that should feel "lit up" in the futuristic theme.
class GlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double glowRadius;
  final TextAlign? textAlign;

  const GlowText(
    this.text, {
    super.key,
    this.style,
    required this.glowColor,
    this.glowRadius = 18,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? const TextStyle();
    return Text(
      text,
      textAlign: textAlign,
      style: base.copyWith(
        shadows: [
          Shadow(color: glowColor.withValues(alpha: 0.55), blurRadius: glowRadius),
          Shadow(color: glowColor.withValues(alpha: 0.3), blurRadius: glowRadius * 2),
        ],
      ),
    );
  }
}
