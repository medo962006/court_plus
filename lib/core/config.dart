import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment-aware configuration.
/// Loads from .env in development, compile-time constants in release.
final class AppConfig {
  AppConfig._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    if (kDebugMode || kProfileMode) {
      await dotenv.load(fileName: '.env');
    }
    _initialized = true;
  }

  // ─── Supabase ───
  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');

  // ─── Google Maps ───
  static String get googleMapsApiKey => _get('GOOGLE_MAPS_API_KEY');

  // ─── Feature Flags ───
  static bool get enableAnalytics => _bool('ENABLE_ANALYTICS', false);
  static bool get enableCrashReporting => _bool('ENABLE_CRASH_REPORTING', false);

  // ─── Build Info ───
  static String get appVersion => _get('APP_VERSION', '1.0.0');
  static String get buildNumber => _get('BUILD_NUMBER', '1');
  static String get environment =>
      kDebugMode ? 'development' : kProfileMode ? 'staging' : 'production';

  // ─── Helpers ───
  static String _get(String key, [String fallback = '']) {
    if (kDebugMode || kProfileMode) {
      return dotenv.env[key] ?? fallback;
    }
    // Release: read from compile-time constants
    return _releaseValue(key, fallback);
  }

  static bool _bool(String key, bool fallback) {
    final v = _get(key);
    if (v.isEmpty) return fallback;
    return v.toLowerCase() == 'true' || v == '1';
  }

  /// Placeholder: in release, these come from --dart-define or Gradle.
  static String _releaseValue(String key, String fallback) {
    // Production setup: pass via --dart-define=SUPABASE_URL=...
    // then read via String.fromEnvironment
    switch (key) {
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY',
            defaultValue: '');
      default:
        return fallback;
    }
  }
}