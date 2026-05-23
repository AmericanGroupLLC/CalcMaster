import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Slowly shifting linear gradient backdrop (purple → cyan → mint, ~18 s loop).
/// Wrap the body of any Scaffold in a Stack with this at index 0.
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 18));
    // Don't start the infinite repeat in widget tests (would prevent pumpAndSettle).
    if (!_isInTest()) _ctl.repeat();
  }

  static bool _isInTest() {
    return const bool.fromEnvironment('FLUTTER_TEST') ||
        WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTestWidgetsFlutterBinding');
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  // Three palette anchors that the gradient cycles through.
  static const _palette = [
    Color(0xFF0B1020), // bg
    Color(0xFF1A1442), // deep purple
    Color(0xFF0F2540), // teal-navy
  ];

  Color _lerp3(double t) {
    // t in [0, 1] cycles through 3 colors smoothly
    final scaled = t * _palette.length;
    final idx = scaled.floor() % _palette.length;
    final next = (idx + 1) % _palette.length;
    final local = scaled - scaled.floor();
    return Color.lerp(_palette[idx], _palette[next], local) ?? _palette[idx];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      child: widget.child,
      builder: (context, child) {
        final t = _ctl.value;
        final top = _lerp3(t);
        final bottom = _lerp3((t + 0.5) % 1.0);
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [top, bottom],
                  ),
                ),
              ),
            ),
            // Soft accent radial in the upper-right that drifts.
            Positioned(
              right: -120 + 80 * t,
              top: -80 + 40 * t,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentPrimary.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(child: child!),
          ],
        );
      },
    );
  }
}
