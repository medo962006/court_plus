import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart' as pkg;

import '../core/config.dart';

/// Uploads structured app log records to the court+ `ingest-logs` Edge
/// Function so the ops dashboard can show live client logs/metrics.
///
/// Fire-and-forget: logs are buffered and flushed on a timer or when the batch
/// fills. Failures never affect the app — repeated failures trip the circuit
/// breaker (`_online=false`) so we stop hammering a down backend.
final class RemoteLogger {
  RemoteLogger._();

  static final RemoteLogger instance = RemoteLogger._();

  final List<Map<String, Object?>> _buffer = [];
  Timer? _timer;
  bool _draining = false;
  bool _online = true;
  int _fails = 0;
  pkg.Level _minLevel = pkg.Level.WARNING;

  static const int _batchCap = 50;
  static const Duration _flushInterval = Duration(seconds: 15);
  static const int _maxFails = 3;
  static const Duration _cooldown = Duration(minutes: 2);

  /// Starts forwarding records at/above [minLevel] to the backend.
  void attach(pkg.Level minLevel) {
    if (_minLevel == pkg.Level.OFF && _timer != null) return;
    _minLevel = minLevel;
    pkg.Logger.root.onRecord.listen(_onRecord);
    _timer?.cancel();
    _timer = Timer.periodic(_flushInterval, (_) => flush());
    // Let a down backend recover for the next session.
    Timer(_cooldown, () => _online = true);
  }

  void _onRecord(pkg.LogRecord r) {
    if (r.level < _minLevel) return;
    _buffer.add({
      'level': _levelName(r.level),
      'service': 'app',
      'message': r.message.toString(),
      'context': r.loggerName,
      'appVersion': AppConfig.appVersion,
      'appEnv': AppConfig.environment,
    });
    if (_buffer.length >= _batchCap) flush();
  }

  Future<void> flush() async {
    if (_buffer.isEmpty || _draining || !_online) return;
    final base = AppConfig.supabaseUrl;
    final key = AppConfig.supabaseAnonKey;
    if (base.isEmpty || key.isEmpty) return;
    _draining = true;
    final batch = List<Map<String, Object?>>.from(_buffer);
    _buffer.clear();
    try {
      final r = await http
          .post(
            Uri.parse('$base/functions/v1/ingest-logs'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': key,
              'Authorization': 'Bearer $key',
            },
            body: jsonEncode({'logs': batch}),
          )
          .timeout(const Duration(seconds: 10));
      _fails = (r.statusCode >= 200 && r.statusCode < 300) ? 0 : _fails + 1;
      if (_fails >= _maxFails) _online = false;
    } catch (_) {
      if (++_fails >= _maxFails) _online = false;
    } finally {
      _draining = false;
    }
  }

  static String _levelName(pkg.Level l) {
    if (l >= pkg.Level.SEVERE) return 'error';
    if (l >= pkg.Level.WARNING) return 'warn';
    if (l >= pkg.Level.INFO) return 'info';
    return 'debug';
  }
}