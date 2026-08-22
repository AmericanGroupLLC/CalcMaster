import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A destination for captured errors — Crashlytics, Sentry, or a backend.
///
/// Kept as an interface so the app captures crashes correctly with **no**
/// third-party SDK and no credentials, and a vendor can be attached later
/// without touching any call site. See `docs/CRASH_REPORTING.md`.
abstract class CrashSink {
  Future<void> report(CrashRecord record);
}

/// One captured error, with the breadcrumbs leading up to it.
class CrashRecord {
  final String error;
  final String stack;
  final String library;
  final bool fatal;
  final int timestamp;
  final List<String> breadcrumbs;

  const CrashRecord({
    required this.error,
    required this.stack,
    required this.library,
    required this.fatal,
    required this.timestamp,
    required this.breadcrumbs,
  });

  Map<String, dynamic> toJson() => {
        'error': error,
        'stack': stack,
        'library': library,
        'fatal': fatal,
        'timestamp': timestamp,
        'breadcrumbs': breadcrumbs,
      };

  factory CrashRecord.fromJson(Map<String, dynamic> json) => CrashRecord(
        error: json['error'] as String? ?? '',
        stack: json['stack'] as String? ?? '',
        library: json['library'] as String? ?? '',
        fatal: json['fatal'] as bool? ?? false,
        timestamp: json['timestamp'] as int? ?? 0,
        breadcrumbs:
            (json['breadcrumbs'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(timestamp);

  /// Human-readable form used by the in-app diagnostics export.
  String toReport() => StringBuffer()
      .let((b) {
        b.writeln('── ${fatal ? 'FATAL' : 'non-fatal'} · ${time.toIso8601String()}');
        if (library.isNotEmpty) b.writeln('library: $library');
        b.writeln(error);
        if (breadcrumbs.isNotEmpty) {
          b.writeln('breadcrumbs:');
          for (final crumb in breadcrumbs) {
            b.writeln('  · $crumb');
          }
        }
        if (stack.isNotEmpty) b.writeln(stack);
        return b;
      })
      .toString();
}

extension _Let<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}

/// Captures unhandled errors so they are not lost.
///
/// Flutter routes errors through three separate channels, and an app that
/// installs none of them — as this one previously did — silently swallows every
/// unhandled error in a release build:
///
///  1. [FlutterError.onError] — errors inside the widgets/rendering layer.
///  2. [PlatformDispatcher.instance.onError] — uncaught async errors.
///  3. The zone error handler — anything escaping `runApp`'s zone.
///
/// Records are persisted immediately so they survive the process death that
/// often follows, and are read back on the next launch.
///
/// **Dart errors are not native crashes.** A caught Dart exception never
/// reaches Play Console's Android Vitals or App Store Connect on its own — only
/// native crashes and ANRs do. Attaching a [sink] is what bridges that gap.
class CrashReporter {
  CrashReporter._();
  static final CrashReporter instance = CrashReporter._();

  static const _kStoredCrashes = '@calcmaster/crash_records';

  /// How many breadcrumbs to retain. Bounded so a long session cannot grow
  /// memory without limit.
  static const int maxBreadcrumbs = 50;

  /// How many crash records to persist. Oldest are dropped first.
  static const int maxStoredCrashes = 20;

  final List<String> _breadcrumbs = <String>[];
  bool _installed = false;

  /// Optional forwarder to Crashlytics/Sentry/a backend. Null means
  /// capture-and-store only, which needs no credentials.
  CrashSink? sink;

  /// Breadcrumbs recorded so far this session, oldest first.
  List<String> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  bool get isInstalled => _installed;

  /// Install the three error handlers. Safe to call more than once.
  ///
  /// The zone handler cannot be installed here — it must wrap `runApp`. See
  /// [guard].
  void install() {
    if (_installed) return;
    _installed = true;

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Keep Flutter's own console dump: losing it would make debugging worse,
      // not better.
      previousOnError?.call(details);
      unawaited(recordError(
        details.exception,
        details.stack,
        library: details.library ?? 'flutter',
        fatal: false,
      ));
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      unawaited(recordError(error, stack, library: 'platform', fatal: true));
      // true = handled; returning false would re-throw and kill the isolate.
      return true;
    };
  }

  /// Run [body] inside a guarded zone so errors escaping `runApp` are captured.
  ///
  /// ```dart
  /// CrashReporter.instance.guard(() => runApp(const CalcMasterApp()));
  /// ```
  void guard(void Function() body) {
    install();
    runZonedGuarded(body, (Object error, StackTrace stack) {
      unawaited(recordError(error, stack, library: 'zone', fatal: true));
    });
  }

  /// Record a trail marker. Cheap, in-memory, and attached to the next crash —
  /// which is usually what makes a stack trace interpretable.
  void leaveBreadcrumb(String message) {
    _breadcrumbs.add('${DateTime.now().toIso8601String()} $message');
    if (_breadcrumbs.length > maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }
  }

  /// Capture an error, persist it, and forward it to [sink] when one is set.
  ///
  /// Never throws: a failure inside error reporting must not itself become an
  /// unhandled error.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String library = 'app',
    bool fatal = false,
  }) async {
    final record = CrashRecord(
      error: error.toString(),
      stack: stack?.toString() ?? '',
      library: library,
      fatal: fatal,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      breadcrumbs: List<String>.from(_breadcrumbs),
    );

    if (kDebugMode) {
      debugPrint('[CrashReporter] ${fatal ? 'FATAL' : 'error'}: $error');
    }

    try {
      await _persist(record);
    } catch (_) {
      // Storage unavailable — the sink may still succeed.
    }

    try {
      await sink?.report(record);
    } catch (_) {
      // A failing sink must never mask the original error.
    }
  }

  Future<void> _persist(CrashRecord record) async {
    final sp = await SharedPreferences.getInstance();
    final existing = sp.getStringList(_kStoredCrashes) ?? <String>[];
    existing.add(jsonEncode(record.toJson()));
    while (existing.length > maxStoredCrashes) {
      existing.removeAt(0);
    }
    await sp.setStringList(_kStoredCrashes, existing);
  }

  /// Crashes persisted by this and previous sessions, oldest first.
  Future<List<CrashRecord>> storedCrashes() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getStringList(_kStoredCrashes) ?? <String>[];
      return raw
          .map((s) {
            try {
              return CrashRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<CrashRecord>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> clearStoredCrashes() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kStoredCrashes);
    } catch (_) {
      // Nothing to clear.
    }
  }

  /// Everything captured, as shareable text — this is what a tester sends back
  /// when a build misbehaves on a device you cannot attach a debugger to.
  Future<String> exportDiagnostics() async {
    final crashes = await storedCrashes();
    final buffer = StringBuffer()
      ..writeln('CalcMaster diagnostics')
      ..writeln('generated: ${DateTime.now().toIso8601String()}')
      ..writeln('stored errors: ${crashes.length}')
      ..writeln();
    if (crashes.isEmpty) {
      buffer.writeln('No errors recorded.');
    } else {
      for (final c in crashes.reversed) {
        buffer
          ..writeln(c.toReport())
          ..writeln();
      }
    }
    return buffer.toString();
  }

  @visibleForTesting
  void resetForTest() {
    _breadcrumbs.clear();
    _installed = false;
    sink = null;
  }
}
