import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a tappable child with a quick scale-down + haptic on press, giving
/// every button across the app a tactile, responsive feel. Keeps the visual
/// styling to the child — this only owns the press animation and haptic.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  /// How far the child shrinks while held. 0.96 ≈ a gentle, premium press.
  final double pressedScale;

  /// Haptic fired on tap-down. `selectionClick` is the lightest tick — ideal
  /// for high-frequency surfaces like a calculator keypad.
  final HapticFeedbackKind haptic;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
    this.haptic = HapticFeedbackKind.selection,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

enum HapticFeedbackKind { none, selection, light, medium }

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  void _fireHaptic() {
    switch (widget.haptic) {
      case HapticFeedbackKind.none:
        break;
      case HapticFeedbackKind.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackKind.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackKind.medium:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _setDown(true);
        _fireHaptic();
      },
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
