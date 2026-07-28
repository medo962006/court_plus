import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' as pkg;

/// Structured logger for court+ app.
/// Logs to console in debug, silent in release (or sends to Crashlytics).
final class AppLogger {
  AppLogger._();

  static final pkg.Logger _log = pkg.Logger('court+');

  static void init({bool verbose = false}) {
    if (verbose || kDebugMode) {
      pkg.hierarchicalLoggingEnabled = true;
      _log.level = pkg.Level.ALL;
      pkg.Logger.root.onRecord.listen((r) {
        // ignore: avoid_print
        print('[${r.level.name}] ${r.loggerName}: ${r.message}');
        if (r.error != null) {
          // ignore: avoid_print
          print('  └─ ${r.error}');
        }
      });
    } else {
      _log.level = pkg.Level.WARNING;
    }
  }

  static void debug(String message, {Object? error}) =>
      _log.fine(message, error);

  static void info(String message, {Object? error}) =>
      _log.info(message, error);

  static void warn(String message, {Object? error}) =>
      _log.warning(message, error);

  static void error(String message, {Object? error, StackTrace? stack}) =>
      _log.severe(message, error, stack);
}