import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';

/// Fires granular interaction events to the ops dashboard's `ingest-events`
/// Edge Function, so every user action across the court+ userbase surfaces in
/// near-real-time on the ops dashboard's live activity feed.
///
/// Fire-and-forget, mirroring [RemoteLogger]: events are buffered and flushed
/// on a timer or when the batch fills. Failures never affect the app.
final class EventTracker {
  EventTracker._();

  static final EventTracker instance = EventTracker._();

  final List<Map<String, Object?>> _buffer = [];
  bool _draining = false;
  bool _online = true;
  bool _attached = false;
  int _fails = 0;

  static const int _batchCap = 50;
  static const Duration _flushInterval = Duration(seconds: 10);
  static const int _maxFails = 3;
  static const Duration _cooldown = Duration(minutes: 2);

  /// Starts the periodic flush. Safe to call once from app init.
  void attach() {
    if (_attached) return;
    _attached = true;
    Timer.periodic(_flushInterval, (_) => flush());
    // Let a down backend recover for the next session.
    Timer(_cooldown, () => _online = true);
  }

  /// Records an interaction event. [props] may carry lightweight context
  /// (screen name, court id, amount, etc.) that the dashboard can render.
  void track(String event, {Map<String, Object?>? props, String? userId}) {
    if (!_attached) return;
    _buffer.add({
      'event': event,
      'props': props ?? const <String, Object?>{},
      'userId': userId,
      'appVersion': AppConfig.appVersion,
      'appEnv': AppConfig.environment,
      'platform': _platformName,
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
            Uri.parse('$base/functions/v1/ingest-events'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': key,
              'Authorization': 'Bearer $key',
            },
            body: jsonEncode({'events': batch}),
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

  static String get _platformName =>
      kIsWeb ? 'web' : defaultTargetPlatform.name;
}
