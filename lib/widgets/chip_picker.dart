import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

class ChipPicker<T> extends StatelessWidget {
  final List<({T id, String label})> options;
  final T value;
  final ValueChanged<T> onChange;

  const ChipPicker({super.key, required this.options, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          for (final opt in options)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: _Chip(
                label: opt.label,
                active: opt.id == value,
                onTap: () => onChange(opt.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.pill),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: active ? AppColors.accentPrimary : AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.pill),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(
                  color: active ? AppColors.accentPrimary : AppColors.border),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.text,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
