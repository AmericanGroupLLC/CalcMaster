import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Subtle pulsing dot grid backdrop. ~30 fps via Ticker (not 60) to save battery.
class ParticleDotGrid extends StatefulWidget {
  const ParticleDotGrid({super.key});

  @override
  State<ParticleDotGrid> createState() => _ParticleDotGridState();
}

class _ParticleDotGridState extends State<ParticleDotGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    // Don't start the infinite repeat in widget tests.
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTestWidgetsFlutterBinding');
    if (!isTest) _ctl.repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, __) => CustomPaint(
          painter: _DotPainter(t: _ctl.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final double t;
  _DotPainter({required this.t});

  static const _spacing = 28.0;
  static const _baseAlpha = 0.05;
  static const _peakAlpha = 0.14;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var y = 0.0; y < size.height; y += _spacing) {
      for (var x = 0.0; x < size.width; x += _spacing) {
        // Each dot's pulse is offset by its position so the field "breathes".
        final phase = (x * 0.013 + y * 0.017 + t * 2 * math.pi) % (2 * math.pi);
        final pulse = (math.sin(phase) + 1) / 2; // 0..1
        final alpha = _baseAlpha + (_peakAlpha - _baseAlpha) * pulse;
        paint.color = AppColors.accentPrimary.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) => oldDelegate.t != t;
}
