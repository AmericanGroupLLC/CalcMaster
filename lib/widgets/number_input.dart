import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

class NumberInput extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final String? unitSymbol;
  final TextInputType keyboardType;
  final bool autofocus;

  const NumberInput({
    super.key,
    this.label,
    required this.controller,
    this.unitSymbol,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 6),
              child: Text(
                label!,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Radii.input),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    autofocus: autofocus,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: AppColors.accentPrimary,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: AppColors.textDim),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                    ],
                  ),
                ),
                if (unitSymbol != null) ...[
                  const SizedBox(width: Spacing.sm),
                  Text(
                    unitSymbol!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
