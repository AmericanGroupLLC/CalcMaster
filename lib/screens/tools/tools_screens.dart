import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../lib_format.dart';
import '../../theme/tokens.dart';
import '../../widgets/chip_picker.dart';
import '../../widgets/inner_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_row.dart';

// =================== GPS ===================

class GpsCalc extends StatefulWidget {
  const GpsCalc({super.key});
  @override
  State<GpsCalc> createState() => _GpsCalcState();
}
class _GpsCalcState extends State<GpsCalc> {
  final lat = TextEditingController();
  final lng = TextEditingController();
  bool loading = false;
  @override void initState() { super.initState(); for (final c in [lat, lng]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [lat, lng]) c.dispose(); super.dispose(); }

  String _toDms(double dec, bool isLat) {
    if (!dec.isFinite) return '—';
    final sign = dec >= 0 ? (isLat ? 'N' : 'E') : (isLat ? 'S' : 'W');
    final abs = dec.abs();
    final deg = abs.floor();
    final minF = (abs - deg) * 60;
    final min = minF.floor();
    final sec = (minF - min) * 60;
    return '$deg° $min\' ${sec.toStringAsFixed(2)}" $sign';
  }

  Future<void> _useMyLoc() async {
    setState(() => loading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      lat.text = pos.latitude.toStringAsFixed(6);
      lng.text = pos.longitude.toStringAsFixed(6);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: 'GPS Coordinates',
      subtitle: 'Decimal ↔ DMS',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Latitude (decimal)', controller: lat),
        NumberInput(label: 'Longitude (decimal)', controller: lng),
        const SizedBox(height: Spacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.text, foregroundColor: AppColors.bg, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: loading ? null : _useMyLoc,
            icon: const Icon(Icons.navigation, size: 18),
            label: Text(loading ? 'Locating...' : 'Use my location'),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Latitude (DMS)', value: _toDms(safeNumber(lat.text), true), highlight: true),
        ResultRow(label: 'Longitude (DMS)', value: _toDms(safeNumber(lng.text), false), highlight: true),
      ]),
    );
  }
}

// =================== OHM ===================

class OhmCalc extends StatefulWidget {
  const OhmCalc({super.key});
  @override
  State<OhmCalc> createState() => _OhmCalcState();
}
class _OhmCalcState extends State<OhmCalc> {
  final v = TextEditingController();
  final i = TextEditingController();
  final r = TextEditingController();
  final p = TextEditingController();
  @override void initState() { super.initState(); for (final c in [v,i,r,p]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [v,i,r,p]) c.dispose(); super.dispose(); }
  ({double? V, double? I, double? R, double? P}) _solve() {
    double? V = v.text.isEmpty ? null : safeNumber(v.text);
    double? I = i.text.isEmpty ? null : safeNumber(i.text);
    double? R = r.text.isEmpty ? null : safeNumber(r.text);
    double? P = p.text.isEmpty ? null : safeNumber(p.text);
    for (int pass = 0; pass < 4; pass++) {
      V ??= (I != null && R != null) ? I * R : null;
      V ??= (P != null && I != null && I != 0) ? P / I : null;
      I ??= (V != null && R != null && R != 0) ? V / R : null;
      I ??= (P != null && V != null && V != 0) ? P / V : null;
      R ??= (V != null && I != null && I != 0) ? V / I : null;
      R ??= (V != null && P != null && P != 0) ? (V * V) / P : null;
      R ??= (P != null && I != null && I != 0) ? P / (I * I) : null;
      P ??= (V != null && I != null) ? V * I : null;
      P ??= (V != null && R != null && R != 0) ? (V * V) / R : null;
      P ??= (I != null && R != null) ? I * I * R : null;
    }
    return (V: V, I: I, R: R, P: P);
  }
  @override
  Widget build(BuildContext context) {
    final s = _solve();
    String f(double? x, String unit) => (x == null || !x.isFinite) ? '—' : '${formatNumber(x)} $unit';
    return InnerScaffold(
      title: "Ohm's Law",
      subtitle: 'Enter any two values',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Voltage (V)', controller: v),
        NumberInput(label: 'Current (A)', controller: i),
        NumberInput(label: 'Resistance (Ω)', controller: r),
        NumberInput(label: 'Power (W)', controller: p),
        const SizedBox(height: Spacing.lg),
        const Text('Solved', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: Spacing.sm),
        ResultRow(label: 'V', caption: 'Voltage', value: f(s.V, 'V'), highlight: s.V != null && v.text.isEmpty),
        ResultRow(label: 'I', caption: 'Current', value: f(s.I, 'A'), highlight: s.I != null && i.text.isEmpty),
        ResultRow(label: 'R', caption: 'Resistance', value: f(s.R, 'Ω'), highlight: s.R != null && r.text.isEmpty),
        ResultRow(label: 'P', caption: 'Power', value: f(s.P, 'W'), highlight: s.P != null && p.text.isEmpty),
      ]),
    );
  }
}

// =================== BMI ===================

class BmiCalc extends StatefulWidget {
  const BmiCalc({super.key});
  @override
  State<BmiCalc> createState() => _BmiCalcState();
}
class _BmiCalcState extends State<BmiCalc> {
  String system = 'metric';
  final h = TextEditingController();
  final w = TextEditingController();
  @override void initState() { super.initState(); for (final c in [h,w]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [h,w]) c.dispose(); super.dispose(); }
  ({String label, Color color}) _category(double bmi) {
    if (!bmi.isFinite || bmi <= 0) return (label: '—', color: AppColors.textMuted);
    if (bmi < 18.5) return (label: 'Underweight', color: const Color(0xFF7CC8FF));
    if (bmi < 25) return (label: 'Healthy weight', color: AppColors.success);
    if (bmi < 30) return (label: 'Overweight', color: AppColors.warning);
    return (label: 'Obese', color: AppColors.danger);
  }
  @override
  Widget build(BuildContext context) {
    final hv = safeNumber(h.text);
    final wv = safeNumber(w.text);
    double bmi = double.nan;
    if (hv > 0 && wv > 0) {
      if (system == 'metric') {
        final hm = hv / 100;
        bmi = wv / (hm * hm);
      } else {
        bmi = (703 * wv) / (hv * hv);
      }
    }
    final cat = _category(bmi);
    return InnerScaffold(
      title: 'BMI',
      subtitle: 'Body Mass Index',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Units', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: Spacing.sm),
        ChipPicker<String>(
          options: const [(id: 'metric', label: 'Metric (cm, kg)'), (id: 'imperial', label: 'Imperial (in, lb)')],
          value: system,
          onChange: (v) => setState(() => system = v),
        ),
        NumberInput(label: system == 'metric' ? 'Height (cm)' : 'Height (in)', controller: h),
        NumberInput(label: system == 'metric' ? 'Weight (kg)' : 'Weight (lb)', controller: w),
        const SizedBox(height: Spacing.lg),
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: cat.color.withValues(alpha: 0.33)),
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: Column(children: [
            Text(bmi.isFinite ? formatNumber(bmi, maxDigits: 1) : '—', style: const TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.w700)),
            Text(cat.label, style: TextStyle(color: cat.color, fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: Spacing.md),
        const ResultRow(label: 'Healthy range', value: '18.5 – 24.9'),
      ]),
    );
  }
}

// =================== DATE DIFF ===================

DateTime? _parseDate(String input) {
  final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(input);
  if (m == null) return null;
  try {
    return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
  } catch (_) {
    return null;
  }
}

String _isoDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

class DateDiffCalc extends StatefulWidget {
  const DateDiffCalc({super.key});
  @override
  State<DateDiffCalc> createState() => _DateDiffCalcState();
}
class _DateDiffCalcState extends State<DateDiffCalc> {
  late TextEditingController from;
  late TextEditingController to;
  @override
  void initState() {
    super.initState();
    final today = _isoDate(DateTime.now());
    from = TextEditingController(text: today);
    to = TextEditingController(text: today);
    for (final c in [from, to]) c.addListener(() => setState(() {}));
  }
  @override void dispose() { for (final c in [from, to]) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final a0 = _parseDate(from.text);
    final b0 = _parseDate(to.text);
    DateTime? a = a0, b = b0;
    if (a != null && b != null && a.isAfter(b)) { final t = a; a = b; b = t; }
    String calendar = '—';
    String totalDays = '—', weeks = '—', hours = '—';
    if (a != null && b != null) {
      var years = b.year - a.year;
      var months = b.month - a.month;
      var days = b.day - a.day;
      if (days < 0) {
        months -= 1;
        final prevLast = DateTime(b.year, b.month, 0).day;
        days += prevLast;
      }
      if (months < 0) { years -= 1; months += 12; }
      calendar = '${years}y ${months}m ${days}d';
      final diff = b.difference(a);
      totalDays = '${diff.inDays}';
      weeks = '${diff.inDays ~/ 7}';
      hours = '${diff.inHours}';
    }
    return InnerScaffold(
      title: 'Date Difference',
      subtitle: 'YYYY-MM-DD format',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'From', controller: from, keyboardType: TextInputType.text),
        NumberInput(label: 'To', controller: to, keyboardType: TextInputType.text),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Calendar', value: calendar, highlight: true),
        ResultRow(label: 'Total days', value: totalDays),
        ResultRow(label: 'Weeks', value: weeks),
        ResultRow(label: 'Hours', value: hours),
      ]),
    );
  }
}

// =================== TIME ZONES ===================

class TimeZonesScreen extends StatefulWidget {
  const TimeZonesScreen({super.key});
  @override
  State<TimeZonesScreen> createState() => _TimeZonesScreenState();
}
class _TimeZonesScreenState extends State<TimeZonesScreen> {
  Timer? _timer;
  @override void initState() { super.initState(); _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {})); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  // Approximate fixed UTC offsets (no DST handling).
  final List<({String label, String flag, double offsetHours})> zones = const [
    (label: 'Cupertino', flag: '🇺🇸', offsetHours: -7),
    (label: 'New York', flag: '🇺🇸', offsetHours: -4),
    (label: 'London', flag: '🇬🇧', offsetHours: 1),
    (label: 'Berlin', flag: '🇩🇪', offsetHours: 2),
    (label: 'Mumbai', flag: '🇮🇳', offsetHours: 5.5),
    (label: 'Singapore', flag: '🇸🇬', offsetHours: 8),
    (label: 'Tokyo', flag: '🇯🇵', offsetHours: 9),
    (label: 'Sydney', flag: '🇦🇺', offsetHours: 10),
    (label: 'São Paulo', flag: '🇧🇷', offsetHours: -3),
    (label: 'Dubai', flag: '🇦🇪', offsetHours: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    return InnerScaffold(
      title: 'Time Zones',
      subtitle: 'Live world clocks',
      child: Column(children: [
        for (final z in zones)
          Builder(builder: (_) {
            final dt = nowUtc.add(Duration(minutes: (z.offsetHours * 60).round()));
            final time = DateFormat('h:mm:ss a').format(dt);
            final day = DateFormat('EEE, MMM d').format(dt);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Radii.button),
              ),
              child: Row(children: [
                Text(z.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(z.label, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(day, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ]),
                ),
                Text(time, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
            );
          }),
      ]),
    );
  }
}

// =================== ADC / DAC ===================

class AdcDacCalc extends StatefulWidget {
  const AdcDacCalc({super.key});
  @override
  State<AdcDacCalc> createState() => _AdcDacCalcState();
}
class _AdcDacCalcState extends State<AdcDacCalc> {
  String mode = 'adc';
  final bits = TextEditingController(text: '12');
  final vref = TextEditingController(text: '3.3');
  final analog = TextEditingController();
  final digital = TextEditingController();
  @override void initState() { super.initState(); for (final c in [bits, vref, analog, digital]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [bits, vref, analog, digital]) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final n = safeNumber(bits.text).round().clamp(1, 64);
    final ref = safeNumber(vref.text);
    final maxCode = (1 << n) - 1;
    final lsb = ref / (1 << n);
    int? code;
    double? voltage;
    if (mode == 'adc') {
      final v = safeNumber(analog.text);
      if (ref > 0) code = ((v / ref) * maxCode).round().clamp(0, maxCode);
    } else {
      final c = safeNumber(digital.text).round().clamp(0, maxCode);
      voltage = (c / maxCode) * ref;
      code = c;
    }
    return InnerScaffold(
      title: 'ADC / DAC',
      subtitle: mode == 'adc' ? 'Analog → Digital' : 'Digital → Analog',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ChipPicker<String>(options: const [(id: 'adc', label: 'ADC'), (id: 'dac', label: 'DAC')], value: mode, onChange: (v) => setState(() => mode = v)),
        NumberInput(label: 'Resolution (bits)', controller: bits, keyboardType: TextInputType.number),
        NumberInput(label: 'Reference voltage (V)', controller: vref),
        if (mode == 'adc') NumberInput(label: 'Analog input (V)', controller: analog) else NumberInput(label: 'Digital code', controller: digital, keyboardType: TextInputType.number),
        const SizedBox(height: Spacing.lg),
        if (mode == 'adc') ...[
          ResultRow(label: 'Digital code (decimal)', value: code?.toString() ?? '—', highlight: true),
          ResultRow(label: 'Digital code (hex)', value: code != null ? '0x${code.toRadixString(16).toUpperCase()}' : '—'),
        ] else
          ResultRow(label: 'Analog output (V)', value: voltage != null ? '${formatNumber(voltage)} V' : '—', highlight: true),
        ResultRow(label: 'Full-scale code', value: '$maxCode'),
        ResultRow(label: 'LSB step', value: '${formatNumber(lsb)} V'),
      ]),
    );
  }
}

// =================== AGE ===================

class AgeCalc extends StatefulWidget {
  const AgeCalc({super.key});
  @override
  State<AgeCalc> createState() => _AgeCalcState();
}
class _AgeCalcState extends State<AgeCalc> {
  final dob = TextEditingController(text: '2000-01-01');
  late TextEditingController ref;
  @override
  void initState() {
    super.initState();
    ref = TextEditingController(text: _isoDate(DateTime.now()));
    for (final c in [dob, ref]) c.addListener(() => setState(() {}));
  }
  @override void dispose() { for (final c in [dob, ref]) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final a = _parseDate(dob.text);
    final b = _parseDate(ref.text);
    String age = '—', total = '—', next = '—';
    if (a != null && b != null && !a.isAfter(b)) {
      var years = b.year - a.year;
      var months = b.month - a.month;
      var days = b.day - a.day;
      if (days < 0) {
        months -= 1;
        final prevLast = DateTime(b.year, b.month, 0).day;
        days += prevLast;
      }
      if (months < 0) { years -= 1; months += 12; }
      age = '${years}y ${months}m ${days}d';
      total = '${b.difference(a).inDays}';
      var nb = DateTime(b.year, a.month, a.day);
      if (nb.isBefore(b)) nb = DateTime(b.year + 1, a.month, a.day);
      final daysToNext = nb.difference(b).inDays;
      next = '${_isoDate(nb)} · in $daysToNext days';
    }
    return InnerScaffold(
      title: 'Age Calculator',
      subtitle: 'YYYY-MM-DD',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NumberInput(label: 'Date of birth', controller: dob, keyboardType: TextInputType.text),
        NumberInput(label: 'Reference date', controller: ref, keyboardType: TextInputType.text),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Age', value: age, highlight: true),
        ResultRow(label: 'Total days lived', value: total),
        ResultRow(label: 'Next birthday', value: next),
      ]),
    );
  }
}

// =================== ASPECT RATIO ===================

class AspectRatioCalc extends StatefulWidget {
  const AspectRatioCalc({super.key});
  @override
  State<AspectRatioCalc> createState() => _AspectRatioCalcState();
}
class _AspectRatioCalcState extends State<AspectRatioCalc> {
  final w1 = TextEditingController(text: '1920');
  final h1 = TextEditingController(text: '1080');
  final w2 = TextEditingController();
  final h2 = TextEditingController();
  @override void initState() { super.initState(); for (final c in [w1,h1,w2,h2]) c.addListener(() => setState(() {})); }
  @override void dispose() { for (final c in [w1,h1,w2,h2]) c.dispose(); super.dispose(); }

  String _reduce(double w, double h) {
    if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) return '—';
    final target = w / h;
    int bestA = 0, bestB = 0;
    double bestErr = double.infinity;
    for (int b = 1; b <= 50; b++) {
      final a = (target * b).round();
      final err = (target - a / b).abs();
      if (err < bestErr) { bestErr = err; bestA = a; bestB = b; }
    }
    return '$bestA:$bestB';
  }

  @override
  Widget build(BuildContext context) {
    final W1 = safeNumber(w1.text);
    final H1 = safeNumber(h1.text);
    final W2 = w2.text.isEmpty ? double.nan : safeNumber(w2.text);
    final H2 = h2.text.isEmpty ? double.nan : safeNumber(h2.text);
    final ratio = (W1 > 0 && H1 > 0) ? W1 / H1 : double.nan;
    String? computedLabel;
    String? computedValue;
    if (ratio.isFinite) {
      if (W2.isFinite && !H2.isFinite) {
        computedLabel = 'Solved height';
        computedValue = '${formatNumber(W2 / ratio, maxDigits: 2)} px';
      } else if (H2.isFinite && !W2.isFinite) {
        computedLabel = 'Solved width';
        computedValue = '${formatNumber(H2 * ratio, maxDigits: 2)} px';
      }
    }
    return InnerScaffold(
      title: 'Aspect Ratio',
      subtitle: 'Solve missing W or H',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(children: [
            NumberInput(label: 'W₁', controller: w1),
            NumberInput(label: 'H₁', controller: h1),
          ])),
          const SizedBox(width: Spacing.md),
          Expanded(child: Column(children: [
            NumberInput(label: 'W₂ (optional)', controller: w2),
            NumberInput(label: 'H₂ (optional)', controller: h2),
          ])),
        ]),
        const SizedBox(height: Spacing.lg),
        ResultRow(label: 'Ratio (decimal)', value: ratio.isFinite ? formatNumber(ratio, maxDigits: 4) : '—'),
        ResultRow(label: 'Ratio (a:b)', value: _reduce(W1, H1), highlight: true),
        if (computedLabel != null) ResultRow(label: computedLabel, value: computedValue!, highlight: true),
      ]),
    );
  }
}
