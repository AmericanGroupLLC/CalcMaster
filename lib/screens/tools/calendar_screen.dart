import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/tokens.dart';
import '../../widgets/inner_scaffold.dart';
import '../../widgets/result_row.dart';

/// Month-view calendar tool. Browse months, tap a day to inspect it. Month and
/// weekday names follow the device locale via `intl`, so this screen is already
/// localized for all 12 supported languages without extra string keys.
class CalendarToolScreen extends StatefulWidget {
  const CalendarToolScreen({super.key});

  @override
  State<CalendarToolScreen> createState() => _CalendarToolScreenState();
}

class _CalendarToolScreenState extends State<CalendarToolScreen> {
  late DateTime _visibleMonth; // any day in the month being shown
  late DateTime _selected;

  static const _accent = CategoryAccent.pressure;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) => setState(() {
        _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      });

  void _goToday() => setState(() {
        final now = DateTime.now();
        _selected = DateTime(now.year, now.month, now.day);
        _visibleMonth = DateTime(now.year, now.month);
      });

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final today = DateTime.now();

    return InnerScaffold(
      title: 'Calendar',
      subtitle: 'Browse months · tap a day',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _monthBar(locale),
        const SizedBox(height: Spacing.md),
        _weekdayHeader(locale),
        const SizedBox(height: Spacing.xs),
        ..._buildWeeks(today),
        const SizedBox(height: Spacing.xl),
        Text('Selected day',
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: Spacing.sm),
        ResultRow(
          label: 'Date',
          value: DateFormat.yMMMMEEEEd(locale).format(_selected),
          highlight: true,
        ),
        ResultRow(label: 'Day of year', value: '${_dayOfYear(_selected)} / ${_daysInYear(_selected.year)}'),
        ResultRow(label: 'ISO week', value: '${_isoWeek(_selected)}'),
        ResultRow(label: 'Quarter', value: 'Q${((_selected.month - 1) ~/ 3) + 1}'),
        ResultRow(label: 'Days in month', value: '${_daysInMonth(_selected.year, _selected.month)}'),
      ]),
    );
  }

  // --- header widgets ------------------------------------------------------

  Widget _monthBar(String locale) {
    return Row(children: [
      _navButton(Icons.chevron_left, () => _shiftMonth(-1), 'Previous month'),
      Expanded(
        child: Center(
          child: Text(
            DateFormat.yMMMM(locale).format(_visibleMonth),
            style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      _navButton(Icons.chevron_right, () => _shiftMonth(1), 'Next month'),
      const SizedBox(width: Spacing.xs),
      TextButton(
        onPressed: _goToday,
        style: TextButton.styleFrom(foregroundColor: _accent),
        child: const Text('Today'),
      ),
    ]);
  }

  Widget _navButton(IconData icon, VoidCallback onTap, String tooltip) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: AppColors.text, size: 26),
      onPressed: onTap,
    );
  }

  Widget _weekdayHeader(String locale) {
    // Jan 7 2024 is a Sunday — use it as the Sunday-first reference.
    final sunday = DateTime(2024, 1, 7);
    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                DateFormat.E(locale).format(sunday.add(Duration(days: i))),
                style: const TextStyle(color: AppColors.textDim, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  // --- day grid ------------------------------------------------------------

  List<Widget> _buildWeeks(DateTime today) {
    final daysInMonth = _daysInMonth(_visibleMonth.year, _visibleMonth.month);
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leading = first.weekday % 7; // Sunday-first offset (Sun=0)

    final cells = <DateTime?>[];
    for (int i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_visibleMonth.year, _visibleMonth.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            for (final day in cells.sublist(i, i + 7))
              Expanded(child: _dayCell(day, today)),
          ],
        ),
      ));
    }
    return rows;
  }

  Widget _dayCell(DateTime? day, DateTime today) {
    if (day == null) return const AspectRatio(aspectRatio: 1, child: SizedBox());

    final isSelected = _sameDay(day, _selected);
    final isToday = _sameDay(day, today);

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: isSelected ? _accent : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.button),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.button),
            onTap: () => setState(() => _selected = day),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.button),
                border: isToday && !isSelected
                    ? Border.all(color: _accent.withValues(alpha: 0.8), width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isSelected ? AppColors.bg : AppColors.text,
                  fontSize: 15,
                  fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- date math -----------------------------------------------------------

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  int _dayOfYear(DateTime d) => d.difference(DateTime(d.year, 1, 1)).inDays + 1;

  bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

  int _daysInYear(int y) => _isLeap(y) ? 366 : 365;

  int _isoWeeksInYear(int y) {
    int p(int yy) => (yy + yy ~/ 4 - yy ~/ 100 + yy ~/ 400) % 7;
    return (p(y) == 4 || p(y - 1) == 3) ? 53 : 52;
  }

  int _isoWeek(DateTime d) {
    final week = (_dayOfYear(d) - d.weekday + 10) ~/ 7;
    if (week < 1) return _isoWeeksInYear(d.year - 1);
    if (week > _isoWeeksInYear(d.year)) return 1;
    return week;
  }
}
