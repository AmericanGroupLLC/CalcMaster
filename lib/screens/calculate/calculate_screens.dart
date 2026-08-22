import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../lib_calc.dart';
import '../../lib_format.dart';
import '../../theme/tokens.dart';
import '../../widgets/chip_picker.dart';
import '../../widgets/inner_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/result_row.dart';

// =================== STANDARD ===================

class StandardCalc extends StatefulWidget {
  const StandardCalc({super.key});
  @override
  State<StandardCalc> createState() => _StandardCalcState();
}

// Apple Calculator key palette (rendered over the app's dark gradient).
class _AppleKeys {
  static const function = Color(0xFFA5A5A5); // AC, +/-, %
  static const functionText = Color(0xFF1A1A1A);
  static const digit = Color(0xFF2E2E33); // numbers & decimal
  static const operator = Color(0xFFFF9F0A); // ÷ × − + =
  static const operatorActive = Colors.white; // pressed operator
}

enum _KeyKind { function, digit, operator }

class _StandardCalcState extends State<StandardCalc> {
  String expr = '';

  String get liveResult {
    if (expr.trim().isEmpty) return '';
    try {
      final open = '('.allMatches(expr).length;
      final close = ')'.allMatches(expr).length;
      final padded = expr + (')' * (open - close).clamp(0, 100));
      final v = evaluate(padded);
      if (!v.isFinite) return '';
      return formatNumber(v);
    } catch (_) {
      return '';
    }
  }

  // Internal operator chars the active-highlight should track.
  static const _opChar = {'÷': '/', '×': '*', '−': '-', '+': '+'};

  bool _isActiveOperator(String label) {
    final ch = _opChar[label];
    return ch != null && expr.isNotEmpty && expr.endsWith(ch);
  }

  void _backspace() {
    if (expr.isNotEmpty) setState(() => expr = expr.substring(0, expr.length - 1));
  }

  // Toggle the sign of the trailing number (Apple's +/- key).
  void _toggleSign() {
    final m = RegExp(r'(\d*\.?\d+)$').firstMatch(expr);
    if (m == null) return;
    final idx = m.start;
    final hasUnaryMinus = idx > 0 &&
        expr[idx - 1] == '-' &&
        (idx - 1 == 0 || '(+-*/%'.contains(expr[idx - 2]));
    setState(() {
      expr = hasUnaryMinus
          ? expr.substring(0, idx - 1) + expr.substring(idx)
          : '${expr.substring(0, idx)}-${expr.substring(idx)}';
    });
  }

  void _press(String label) {
    switch (label) {
      case 'AC':
      case 'C':
        setState(() => expr = '');
        break;
      case '+/−':
        _toggleSign();
        break;
      case '=':
        if (liveResult.isNotEmpty) setState(() => expr = liveResult);
        break;
      case '×':
        setState(() => expr += '*');
        break;
      case '÷':
        setState(() => expr += '/');
        break;
      case '−':
        setState(() => expr += '-');
        break;
      default:
        setState(() => expr += label);
    }
  }

  Widget _key(String label, _KeyKind kind, double size, double gap, {double widthFactor = 1}) {
    final active = kind == _KeyKind.operator && _isActiveOperator(label);
    final isEquals = label == '=';

    Color bg;
    Color fg;
    switch (kind) {
      case _KeyKind.function:
        bg = _AppleKeys.function;
        fg = _AppleKeys.functionText;
        break;
      case _KeyKind.digit:
        bg = _AppleKeys.digit;
        fg = Colors.white;
        break;
      case _KeyKind.operator:
        bg = active ? _AppleKeys.operatorActive : _AppleKeys.operator;
        fg = active ? _AppleKeys.operator : Colors.white;
        break;
    }

    // A wide key spans N columns plus the gaps it bridges.
    final width = size * widthFactor + gap * (widthFactor - 1);
    return PressableScale(
      onTap: () => _press(label),
      haptic: isEquals ? HapticFeedbackKind.medium : HapticFeedbackKind.selection,
      child: Container(
        width: width,
        height: size,
        alignment: widthFactor > 1 ? Alignment.centerLeft : Alignment.center,
        padding: widthFactor > 1 ? EdgeInsets.only(left: size * 0.36) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: kind == _KeyKind.operator && !active
              ? [
                  BoxShadow(
                    color: _AppleKeys.operator.withValues(alpha: 0.4),
                    blurRadius: 14,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apple keypad: 4 columns × 5 rows. Each entry is (label, kind, widthFactor).
    final rows = <List<(String, _KeyKind, double)>>[
      [
        (expr.isEmpty ? 'AC' : 'C', _KeyKind.function, 1),
        ('+/−', _KeyKind.function, 1),
        ('%', _KeyKind.function, 1),
        ('÷', _KeyKind.operator, 1),
      ],
      [
        ('7', _KeyKind.digit, 1),
        ('8', _KeyKind.digit, 1),
        ('9', _KeyKind.digit, 1),
        ('×', _KeyKind.operator, 1),
      ],
      [
        ('4', _KeyKind.digit, 1),
        ('5', _KeyKind.digit, 1),
        ('6', _KeyKind.digit, 1),
        ('−', _KeyKind.operator, 1),
      ],
      [
        ('1', _KeyKind.digit, 1),
        ('2', _KeyKind.digit, 1),
        ('3', _KeyKind.digit, 1),
        ('+', _KeyKind.operator, 1),
      ],
      [
        ('0', _KeyKind.digit, 2),
        ('.', _KeyKind.digit, 1),
        ('=', _KeyKind.operator, 1),
      ],
    ];

    return InnerScaffold(
      title: AppLocalizations.of(context)!.calcStandard,
      subtitle: 'Swipe the display to delete · live result',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 12.0;
          final available = constraints.maxWidth;
          final size = ((available - gap * 3) / 4).clamp(56.0, 88.0);
          final keypadWidth = size * 4 + gap * 3;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---- Display (swipe horizontally to backspace) ----
              GestureDetector(
                onHorizontalDragEnd: (_) => _backspace(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: keypadWidth,
                  constraints: const BoxConstraints(minHeight: 130),
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Always rendered — blank when there is no result — so
                      // the keypad below keeps a fixed position. Showing it
                      // conditionally made the whole keypad jump as the
                      // expression became valid/invalid mid-entry, which
                      // causes mis-taps (and on a calculator a mis-tap is a
                      // wrong answer).
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(liveResult.isEmpty ? '' : '= $liveResult',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 20)),
                      ),
                      FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          expr.isEmpty ? '0' : expr,
                          maxLines: 1,
                          style: const TextStyle(
                              color: AppColors.text, fontSize: 64, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // ---- Keypad ----
              SizedBox(
                width: keypadWidth,
                child: Column(
                  children: [
                    for (final row in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: gap),
                        child: Row(
                          children: [
                            for (var i = 0; i < row.length; i++) ...[
                              if (i > 0) const SizedBox(width: gap),
                              _key(row[i].$1, row[i].$2, size, gap, widthFactor: row[i].$3),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =================== SCIENTIFIC ===================

class ScientificCalc extends StatefulWidget {
  const ScientificCalc({super.key});
  @override
  State<ScientificCalc> createState() => _ScientificCalcState();
}

class _ScientificCalcState extends State<ScientificCalc> {
  String expr = '';

  String get liveResult {
    if (expr.trim().isEmpty) return '';
    try {
      final open = '('.allMatches(expr).length;
      final close = ')'.allMatches(expr).length;
      final padded = expr + (')' * (open - close).clamp(0, 100));
      final v = evaluate(padded);
      if (!v.isFinite) return '';
      return formatNumber(v, maxDigits: 10);
    } catch (_) {
      return '';
    }
  }

  Widget _key(String label, String insert, {Color? bg, Color? fg, bool small = false}) {
    final isEquals = label == '=';
    final isOperator = RegExp(r'[÷×−+]').hasMatch(label);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: PressableScale(
          onTap: () {
            setState(() {
              if (label == 'C') {
                expr = '';
              } else if (label == '⌫') {
                if (expr.isNotEmpty) expr = expr.substring(0, expr.length - 1);
              } else if (label == '=') {
                if (liveResult.isNotEmpty) expr = liveResult;
              } else {
                expr += insert;
              }
            });
          },
          haptic: isEquals
              ? HapticFeedbackKind.medium
              : HapticFeedbackKind.selection,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: small ? 12 : 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isEquals ? null : (bg ?? AppColors.surface),
              gradient: isEquals
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF9B7DFF), AppColors.accentPrimary],
                    )
                  : null,
              border: Border.all(
                color: isEquals
                    ? Colors.transparent
                    : (isOperator
                        ? AppColors.accentPrimary.withValues(alpha: 0.35)
                        : AppColors.border),
              ),
              borderRadius: BorderRadius.circular(Radii.button),
              boxShadow: isEquals
                  ? [
                      BoxShadow(
                        color: AppColors.accentPrimary.withValues(alpha: 0.45),
                        blurRadius: 16,
                        spreadRadius: -2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isEquals
                    ? Colors.white
                    : (isOperator ? AppColors.accentPrimary : (fg ?? AppColors.text)),
                fontSize: small ? 14 : 18,
                fontWeight: isOperator || isEquals ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: AppLocalizations.of(context)!.calcScientific,
      subtitle: 'Trig, logs, powers, factorial',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Text(expr.isEmpty ? '0' : expr, style: const TextStyle(color: AppColors.text, fontSize: 30, fontWeight: FontWeight.w600)),
                ),
                // Reserved unconditionally so the keypad never shifts — see
                // the note on the standard calculator's display.
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: Text(liveResult.isEmpty ? '' : '= $liveResult',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 18)),
                ),
              ],
            ),
          ),
          // Sci row
          Row(children: [_key('sin', 'sin(', small: true), _key('cos', 'cos(', small: true), _key('tan', 'tan(', small: true), _key('π', 'pi', small: true)]),
          Row(children: [_key('ln', 'ln(', small: true), _key('log', 'log(', small: true), _key('√', 'sqrt(', small: true), _key('x²', '^2', small: true)]),
          Row(children: [_key('x^y', '^', small: true), _key('n!', '!', small: true), _key('e', 'e', small: true), _key('exp', 'exp(', small: true)]),
          // Standard rows
          Row(children: [_key('C', '', bg: AppColors.surface), _key('( )', '(', bg: AppColors.surface), _key('%', '%', bg: AppColors.surface), _key('÷', '/', bg: AppColors.surfaceAlt)]),
          Row(children: [_key('7', '7'), _key('8', '8'), _key('9', '9'), _key('×', '*', bg: AppColors.surfaceAlt)]),
          Row(children: [_key('4', '4'), _key('5', '5'), _key('6', '6'), _key('−', '-', bg: AppColors.surfaceAlt)]),
          Row(children: [_key('1', '1'), _key('2', '2'), _key('3', '3'), _key('+', '+', bg: AppColors.surfaceAlt)]),
          Row(children: [_key('⌫', '', bg: AppColors.surface), _key('0', '0'), _key('.', '.'), _key('=', '', bg: AppColors.accentPrimary, fg: Colors.white)]),
        ],
      ),
    );
  }
}

// =================== PERCENTAGE ===================

class PercentageCalc extends StatefulWidget {
  const PercentageCalc({super.key});
  @override
  State<PercentageCalc> createState() => _PercentageCalcState();
}

class _PercentageCalcState extends State<PercentageCalc> {
  final aC = TextEditingController();
  final bC = TextEditingController();

  @override
  void initState() {
    super.initState();
    aC.addListener(() => setState(() {}));
    bC.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    aC.dispose();
    bC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final A = safeNumber(aC.text);
    final B = safeNumber(bC.text);
    final pctOf = (A / 100) * B;
    final isPct = B == 0 ? double.nan : A / B;
    final change = A == 0 ? double.nan : (B - A) / A;
    return InnerScaffold(
      title: AppLocalizations.of(context)!.calcPercentage,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: NumberInput(label: 'X', controller: aC)),
          const SizedBox(width: Spacing.md),
          Expanded(child: NumberInput(label: 'Y', controller: bC)),
        ]),
        const SizedBox(height: Spacing.lg),
        Text(AppLocalizations.of(context)!.labelXofY, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ResultRow(label: '${aC.text.isEmpty ? '0' : aC.text}% of ${bC.text.isEmpty ? '0' : bC.text}', value: formatNumber(pctOf)),
        const SizedBox(height: Spacing.lg),
        Text(AppLocalizations.of(context)!.labelXisWhatPctOfY, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ResultRow(label: '${aC.text.isEmpty ? '0' : aC.text} of ${bC.text.isEmpty ? '0' : bC.text}', value: isPct.isFinite ? formatPercent(isPct) : '—'),
        const SizedBox(height: Spacing.lg),
        Text(AppLocalizations.of(context)!.labelPctChangeXtoY, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ResultRow(label: 'Change', value: change.isFinite ? formatPercent(change) : '—', highlight: change.isFinite),
      ]),
    );
  }
}

// =================== BASE ===================

class BaseCalc extends StatefulWidget {
  const BaseCalc({super.key});
  @override
  State<BaseCalc> createState() => _BaseCalcState();
}

class _BaseCalcState extends State<BaseCalc> {
  String base = 'dec';
  final controller = TextEditingController(text: '255');

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int? _parsed() {
    final radix = {'bin': 2, 'oct': 8, 'dec': 10, 'hex': 16}[base]!;
    return int.tryParse(controller.text.trim(), radix: radix);
  }

  String _rep(String b) {
    final v = _parsed();
    if (v == null) return '—';
    final radix = {'bin': 2, 'oct': 8, 'dec': 10, 'hex': 16}[b]!;
    return v.toRadixString(radix).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: AppLocalizations.of(context)!.calcBase,
      subtitle: 'Bin · Oct · Dec · Hex',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context)!.labelInputBase, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: Spacing.sm),
        ChipPicker<String>(
          options: const [(id: 'bin', label: 'BIN'), (id: 'oct', label: 'OCT'), (id: 'dec', label: 'DEC'), (id: 'hex', label: 'HEX')],
          value: base,
          onChange: (v) => setState(() => base = v),
        ),
        NumberInput(controller: controller, keyboardType: const TextInputType.numberWithOptions()),
        const SizedBox(height: Spacing.md),
        ResultRow(label: 'Binary', caption: 'base 2', value: _rep('bin')),
        ResultRow(label: 'Octal', caption: 'base 8', value: _rep('oct')),
        ResultRow(label: 'Decimal', caption: 'base 10', value: _rep('dec'), highlight: true),
        ResultRow(label: 'Hex', caption: 'base 16', value: _rep('hex')),
      ]),
    );
  }
}

// =================== FRACTION ===================

class FractionCalc extends StatefulWidget {
  const FractionCalc({super.key});
  @override
  State<FractionCalc> createState() => _FractionCalcState();
}

class _FractionCalcState extends State<FractionCalc> {
  final n1 = TextEditingController(text: '1');
  final d1 = TextEditingController(text: '2');
  final n2 = TextEditingController(text: '1');
  final d2 = TextEditingController(text: '3');
  String op = '+';

  @override
  void initState() {
    super.initState();
    for (final c in [n1, d1, n2, d2]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [n1, d1, n2, d2]) {
      c.dispose();
    }
    super.dispose();
  }

  ({int n, int d}) _compute() {
    final a = safeNumber(n1.text).toInt();
    final b = safeNumber(d1.text).toInt();
    final c = safeNumber(n2.text).toInt();
    final d = safeNumber(d2.text).toInt();
    if (b == 0 || d == 0) return (n: 0, d: 0);
    switch (op) {
      case '+':
        return simplifyFraction(a * d + c * b, b * d);
      case '-':
        return simplifyFraction(a * d - c * b, b * d);
      case '×':
        return simplifyFraction(a * c, b * d);
      case '÷':
        if (c == 0) return (n: 0, d: 0);
        return simplifyFraction(a * d, b * c);
    }
    return (n: 0, d: 0);
  }

  String _toMixed(int n, int d) {
    if (d == 0) return '—';
    final whole = n ~/ d;
    final remainder = (n - whole * d).abs();
    if (remainder == 0) return '$whole';
    if (whole == 0) return '$n/$d';
    return '$whole $remainder/$d';
  }

  @override
  Widget build(BuildContext context) {
    final r = _compute();
    final dec = r.d == 0 ? double.nan : r.n / r.d;
    return InnerScaffold(
      title: AppLocalizations.of(context)!.calcFraction,
      subtitle: 'Add, subtract, multiply, divide',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(children: [
              NumberInput(label: 'Numerator A', controller: n1),
              NumberInput(label: 'Denominator A', controller: d1),
            ]),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(children: [
              NumberInput(label: 'Numerator B', controller: n2),
              NumberInput(label: 'Denominator B', controller: d2),
            ]),
          ),
        ]),
        const SizedBox(height: Spacing.md),
        Text(AppLocalizations.of(context)!.labelOperator, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: Spacing.sm),
        ChipPicker<String>(
          options: const [(id: '+', label: '+'), (id: '-', label: '−'), (id: '×', label: '×'), (id: '÷', label: '÷')],
          value: op,
          onChange: (v) => setState(() => op = v),
        ),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Simplified', value: r.d == 0 ? '—' : '${r.n}/${r.d}', highlight: true),
        ResultRow(label: 'Mixed number', value: _toMixed(r.n, r.d)),
        ResultRow(label: 'Decimal', value: dec.isFinite ? dec.toString() : '—'),
      ]),
    );
  }
}
