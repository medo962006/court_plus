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

  // ─── Stripe ───
  static String get stripePublishableKey => _get('STRIPE_PUBLISHABLE_KEY');

  // ─── Sentry ───
  static String get sentryDsn => _get('SENTRY_DSN');

  // ─── Feature Flags ───
  static bool get enableAnalytics => _bool('ENABLE_ANALYTICS', false);
  static bool get enableCrashReporting => _bool('ENABLE_CRASH_REPORTING', false);

  // ─── Build Info ───
  static String get appVersion => _get('APP_VERSION', '1.0.0');
  static String get buildNumber => _get('BUILD_NUMBER', '1');
  static String get environment => _get('APP_ENV',
      kDebugMode ? 'development' : kProfileMode ? 'staging' : 'production');

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

  /// Production: values come from --dart-define compile-time constants.
  static String _releaseValue(String key, String fallback) {
    switch (key) {
      case 'APP_ENV':
        return const String.fromEnvironment('APP_ENV', defaultValue: 'production');
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY',
            defaultValue: '');
      case 'GOOGLE_MAPS_API_KEY':
        return const String.fromEnvironment('GOOGLE_MAPS_API_KEY',
            defaultValue: '');
      case 'STRIPE_PUBLISHABLE_KEY':
        return const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
            defaultValue: '');
      case 'SENTRY_DSN':
        return const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      default:
        return fallback;
    }
  }
}
