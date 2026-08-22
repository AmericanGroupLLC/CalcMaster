import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calcmaster/services/crash_reporter.dart';

class _RecordingSink implements CrashSink {
  final List<CrashRecord> received = [];
  @override
  Future<void> report(CrashRecord record) async => received.add(record);
}

class _ThrowingSink implements CrashSink {
  @override
  Future<void> report(CrashRecord record) async => throw StateError('sink down');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CrashReporter.instance.resetForTest();
    await CrashReporter.instance.clearStoredCrashes();
  });

  group('capture and persistence', () {
    test('an error is stored and readable back', () async {
      await CrashReporter.instance
          .recordError(StateError('boom'), StackTrace.current, fatal: true);

      final stored = await CrashReporter.instance.storedCrashes();
      expect(stored, hasLength(1));
      expect(stored.single.error, contains('boom'));
      expect(stored.single.fatal, isTrue);
      expect(stored.single.stack, isNotEmpty);
    });

    test('breadcrumbs are attached to the crash that follows', () async {
      CrashReporter.instance.leaveBreadcrumb('opened scientific');
      CrashReporter.instance.leaveBreadcrumb('tapped =');
      await CrashReporter.instance.recordError(Exception('later'), null);

      final stored = await CrashReporter.instance.storedCrashes();
      expect(stored.single.breadcrumbs, hasLength(2));
      expect(stored.single.breadcrumbs.last, contains('tapped ='));
    });

    test('breadcrumbs are bounded so a long session cannot grow unbounded', () {
      for (var i = 0; i < CrashReporter.maxBreadcrumbs + 25; i++) {
        CrashReporter.instance.leaveBreadcrumb('step $i');
      }
      expect(CrashReporter.instance.breadcrumbs,
          hasLength(CrashReporter.maxBreadcrumbs));
      // The newest are kept, the oldest dropped.
      expect(CrashReporter.instance.breadcrumbs.last, contains('step 74'));
    });

    test('stored crashes are capped, dropping the oldest', () async {
      for (var i = 0; i < CrashReporter.maxStoredCrashes + 5; i++) {
        await CrashReporter.instance.recordError(Exception('e$i'), null);
      }
      final stored = await CrashReporter.instance.storedCrashes();
      expect(stored, hasLength(CrashReporter.maxStoredCrashes));
      expect(stored.first.error, contains('e5'), reason: 'oldest dropped first');
      expect(stored.last.error, contains('e24'));
    });
  });

  group('sink forwarding', () {
    test('records are forwarded when a sink is attached', () async {
      final sink = _RecordingSink();
      CrashReporter.instance.sink = sink;

      await CrashReporter.instance.recordError(Exception('to vendor'), null);

      expect(sink.received, hasLength(1));
      expect(sink.received.single.error, contains('to vendor'));
    });

    // Error reporting must never be the thing that crashes the app.
    test('a failing sink does not mask or rethrow the original error', () async {
      CrashReporter.instance.sink = _ThrowingSink();

      await expectLater(
        CrashReporter.instance.recordError(Exception('original'), null),
        completes,
      );
      final stored = await CrashReporter.instance.storedCrashes();
      expect(stored.single.error, contains('original'),
          reason: 'the error is still persisted even though the sink threw');
    });
  });

  group('handler installation', () {
    test('install() is idempotent and captures FlutterError', () async {
      CrashReporter.instance.install();
      CrashReporter.instance.install();
      expect(CrashReporter.instance.isInstalled, isTrue);

      // Route a framework error through the installed handler.
      FlutterError.onError!(FlutterErrorDetails(
        exception: StateError('render failure'),
        stack: StackTrace.current,
        library: 'rendering library',
      ));
      await Future<void>.delayed(Duration.zero);

      final stored = await CrashReporter.instance.storedCrashes();
      expect(stored, isNotEmpty);
      expect(stored.last.error, contains('render failure'));
      expect(stored.last.library, contains('rendering'));
    });
  });

  group('diagnostics export', () {
    test('export is empty-but-valid with no crashes', () async {
      final text = await CrashReporter.instance.exportDiagnostics();
      expect(text, contains('CalcMaster diagnostics'));
      expect(text, contains('No errors recorded'));
    });

    test('export includes the error, breadcrumbs and severity', () async {
      CrashReporter.instance.leaveBreadcrumb('navigated to /tools/bmi');
      await CrashReporter.instance
          .recordError(StateError('kaboom'), StackTrace.current, fatal: true);

      final text = await CrashReporter.instance.exportDiagnostics();
      expect(text, contains('kaboom'));
      expect(text, contains('navigated to /tools/bmi'));
      expect(text, contains('FATAL'));
      expect(text, contains('stored errors: 1'));
    });
  });
}
