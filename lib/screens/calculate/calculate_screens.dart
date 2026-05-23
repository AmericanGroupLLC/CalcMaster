import 'package:flutter/material.dart';

import '../../lib_calc.dart';
import '../../lib_format.dart';
import '../../theme/tokens.dart';
import '../../widgets/chip_picker.dart';
import '../../widgets/inner_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_row.dart';

// =================== STANDARD ===================

class StandardCalc extends StatefulWidget {
  const StandardCalc({super.key});
  @override
  State<StandardCalc> createState() => _StandardCalcState();
}

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

  void _press(String label) {
    setState(() {
      switch (label) {
        case 'C':
          expr = '';
          break;
        case '⌫':
          if (expr.isNotEmpty) expr = expr.substring(0, expr.length - 1);
          break;
        case '=':
          if (liveResult.isNotEmpty) expr = liveResult;
          break;
        case '×':
          expr += '*';
          break;
        case '÷':
          expr += '/';
          break;
        case '−':
          expr += '-';
          break;
        case '( )':
          final open = '('.allMatches(expr).length;
          final close = ')'.allMatches(expr).length;
          if (open > close && (expr.isNotEmpty && RegExp(r'[\d\)\.]$').hasMatch(expr))) {
            expr += ')';
          } else {
            expr += '(';
          }
          break;
        default:
          expr += label;
      }
    });
  }

  Widget _btn(String label, {Color? bg, Color? fg, double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bg ?? AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.button),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.button),
            onTap: () => _press(label),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Radii.button),
              ),
              child: Text(label, style: TextStyle(color: fg ?? AppColors.text, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: 'Standard',
      subtitle: 'Live result updates as you type',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 100),
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Text(expr.isEmpty ? '0' : expr, style: const TextStyle(color: AppColors.text, fontSize: 38, fontWeight: FontWeight.w600)),
                ),
                if (liveResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.sm),
                    child: Text('= $liveResult', style: const TextStyle(color: AppColors.textMuted, fontSize: 18)),
                  ),
              ],
            ),
          ),
          for (final row in [
            ['C', '( )', '%', '÷'],
            ['7', '8', '9', '×'],
            ['4', '5', '6', '−'],
            ['1', '2', '3', '+'],
            ['⌫', '0', '.', '='],
          ])
            Row(children: [
              for (final k in row)
                _btn(k,
                    bg: k == '=' ? AppColors.accentPrimary : (RegExp(r'[÷×−+]').hasMatch(k) ? AppColors.surfaceAlt : null),
                    fg: k == '=' ? Colors.white : null),
            ]),
        ],
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

  void _add(String s) => setState(() => expr += s);

  Widget _key(String label, String insert, {Color? bg, Color? fg, bool small = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bg ?? AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.button),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.button),
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
            child: Container(
              padding: EdgeInsets.symmetric(vertical: small ? 12 : 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Radii.button),
              ),
              child: Text(label, style: TextStyle(color: fg ?? AppColors.text, fontSize: small ? 14 : 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: 'Scientific',
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
                if (liveResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.sm),
                    child: Text('= $liveResult', style: const TextStyle(color: AppColors.textMuted, fontSize: 18)),
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
      title: 'Percentage',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: NumberInput(label: 'X', controller: aC)),
          const SizedBox(width: Spacing.md),
          Expanded(child: NumberInput(label: 'Y', controller: bC)),
        ]),
        const SizedBox(height: Spacing.lg),
        const Text('X% of Y', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ResultRow(label: '${aC.text.isEmpty ? '0' : aC.text}% of ${bC.text.isEmpty ? '0' : bC.text}', value: formatNumber(pctOf)),
        const SizedBox(height: Spacing.lg),
        const Text('X is what % of Y', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ResultRow(label: '${aC.text.isEmpty ? '0' : aC.text} of ${bC.text.isEmpty ? '0' : bC.text}', value: isPct.isFinite ? formatPercent(isPct) : '—'),
        const SizedBox(height: Spacing.lg),
        const Text('% change from X to Y', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
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
      title: 'Base Converter',
      subtitle: 'Bin · Oct · Dec · Hex',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Input base', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
      title: 'Fraction',
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
        const Text('Operator', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
