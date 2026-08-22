import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/crash_reporter.dart';
import '../theme/tokens.dart';
import '../widgets/inner_scaffold.dart';

/// In-app diagnostics: the captured error log, copyable as text.
///
/// This is how a tester gets a crash out of a device you cannot attach a
/// debugger to — a TestFlight or internal-testing build on someone else's
/// phone. `adb logcat` only works while the device is plugged into your
/// machine, and Play Console / App Store Connect never see caught Dart errors
/// at all. See `docs/CRASH_REPORTING.md`.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  List<CrashRecord> _records = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await CrashReporter.instance.storedCrashes();
    if (!mounted) return;
    setState(() {
      _records = records.reversed.toList(); // newest first
      _loading = false;
    });
  }

  Future<void> _copyAll() async {
    final text = await CrashReporter.instance.exportDiagnostics();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Diagnostics copied to clipboard'),
    ));
  }

  Future<void> _clear() async {
    await CrashReporter.instance.clearStoredCrashes();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: 'Diagnostics',
      subtitle: 'Captured errors on this device',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _records.isEmpty ? null : _copyAll,
                  icon: const Icon(Icons.copy_all_outlined, size: 18),
                  label: const Text('Copy all'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _records.isEmpty ? null : _clear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: Spacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_records.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: Spacing.xxxl),
              child: Center(
                child: Text(
                  'No errors recorded.\nThat is the expected state.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
              ),
            )
          else
            for (final record in _records) _CrashCard(record: record),
        ],
      ),
    );
  }
}

class _CrashCard extends StatelessWidget {
  final CrashRecord record;
  const _CrashCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final severity = record.fatal ? AppColors.danger : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.button),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severity.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Text(
                  record.fatal ? 'FATAL' : 'ERROR',
                  style: TextStyle(
                      color: severity, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  record.time.toLocal().toString().split('.').first,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          SelectableText(
            record.error,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
          ),
          if (record.breadcrumbs.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              'Last steps: ${record.breadcrumbs.length}',
              style: const TextStyle(color: AppColors.textDim, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
