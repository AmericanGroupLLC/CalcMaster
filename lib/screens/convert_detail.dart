import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n_helpers.dart';
import '../l10n/generated/app_localizations.dart';
import '../lib_units.dart';
import '../theme/tokens.dart';

/// Rich Convert detail screen — header badge, FROM/TO card with circular swap
/// button, big accent-colored result number, and "ALL CONVERSIONS" list.
class ConvertDetail extends StatefulWidget {
  final String categoryId;
  const ConvertDetail({super.key, required this.categoryId});

  @override
  State<ConvertDetail> createState() => _ConvertDetailState();
}

class _ConvertDetailState extends State<ConvertDetail> {
  late TextEditingController _controller;
  late String _fromUnit;
  late String _toUnit;
  late Category _cat;

  @override
  void initState() {
    super.initState();
    _cat = categoryById(widget.categoryId) ?? categories.first;
    _fromUnit = _cat.units.first.id;
    _toUnit = _cat.units.length > 1 ? _cat.units[1].id : _cat.units.first.id;
    _controller = TextEditingController(text: '1');
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double v) {
    if (!v.isFinite) return '—';
    final abs = v.abs();
    if (abs == 0) return '0';
    if (abs < 0.001 || abs >= 1e7) {
      return v.toStringAsExponential(6).replaceAll('e+', 'e+').replaceAll('e-', 'e-');
    }
    if (abs >= 100) return v.toStringAsFixed(math.max(0, 6 - v.toInt().toString().length));
    return v.toStringAsPrecision(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _swap() {
    setState(() {
      final tmp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final accent = _cat.accent;
    final value = double.tryParse(_controller.text) ?? 0;
    final fromObj = _cat.unitById(_fromUnit) ?? _cat.units.first;
    final toObj = _cat.unitById(_toUnit) ?? _cat.units.first;
    final result = convert(value, _fromUnit, _toUnit, _cat);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: back + icon badge + title + units count
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 26, color: AppColors.text),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withValues(alpha: 0.4)),
                    ),
                    child: Icon(_cat.icon, size: 22, color: accent),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedCategoryLabel(context, _cat.id),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          loc.labelUnitsAvailable(_cat.units.length),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // FROM / TO card
              Container(
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.labelFrom,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        )),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            cursorColor: accent,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              hintText: '0',
                              hintStyle: const TextStyle(color: AppColors.textDim, fontSize: 32),
                              border: UnderlineInputBorder(borderSide: BorderSide(color: accent, width: 2)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent, width: 2)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent, width: 2)),
                              contentPadding: const EdgeInsets.only(bottom: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        _UnitDropdown(
                          units: _cat.units,
                          value: _fromUnit,
                          onChanged: (v) => setState(() => _fromUnit = v!),
                        ),
                      ],
                    ),

                    // Center swap button
                    const SizedBox(height: Spacing.lg),
                    Center(
                      child: GestureDetector(
                        onTap: _swap,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.swap_horiz, size: 18, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    Text(loc.labelTo,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        )),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatValue(result),
                              style: TextStyle(
                                color: accent,
                                fontSize: 44,
                                fontWeight: FontWeight.w400,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        _UnitDropdown(
                          units: _cat.units,
                          value: _toUnit,
                          onChanged: (v) => setState(() => _toUnit = v!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.xl),
              Text(
                loc.labelAllConversions,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: Spacing.sm),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _cat.units.length; i++) ...[
                      _AllRow(
                        label: _cat.units[i].label,
                        value: _formatValue(convert(value, _fromUnit, _cat.units[i].id, _cat)),
                        accent: accent,
                        active: _cat.units[i].id == _toUnit,
                      ),
                      if (i < _cat.units.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final List<Unit> units;
  final String value;
  final ValueChanged<String?> onChanged;
  const _UnitDropdown({required this.units, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.button),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surfaceAlt,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textMuted),
          style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500),
          items: [
            for (final u in units) DropdownMenuItem(value: u.id, child: Text(u.label)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AllRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool active;
  const _AllRow({required this.label, required this.value, required this.accent, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 14),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceAlt : Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppColors.text : AppColors.textMuted,
                fontSize: 15,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: active ? accent : AppColors.text,
              fontSize: 15,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
