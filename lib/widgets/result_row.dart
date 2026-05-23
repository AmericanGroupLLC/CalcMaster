import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final bool highlight;

  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: highlight ? AppColors.surfaceAlt : AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.button),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied: $value'), duration: const Duration(seconds: 1)),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: highlight ? AppColors.borderStrong : AppColors.border),
              borderRadius: BorderRadius.circular(Radii.button),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      if (caption != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(caption!,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                        ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: highlight ? AppColors.success : AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                const Icon(Icons.copy_outlined, size: 16, color: AppColors.textDim),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
