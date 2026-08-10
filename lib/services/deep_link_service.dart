import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../core/logger.dart';

/// Handles deep links (`courtplus://invite?match_id=xxx` or `courtplus://invite?token=xxx`).
final class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._();
  factory DeepLinkService() => _instance;
  DeepLinkService._();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  /// Global navigator key for routing from deep links.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> init() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        AppLogger.info('DeepLink (cold start): $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      AppLogger.error('DeepLink cold-start failed', error: e);
    }

    _sub = _appLinks.uriLinkStream.listen((uri) {
      AppLogger.info('DeepLink (warm): $uri');
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'courtplus') return;

    if (uri.host == 'invite') {
      final matchId = uri.queryParameters['match_id'];
      final token = uri.queryParameters['token'];

      if (matchId != null) {
        navigatorKey.currentState?.pushNamed(
          '/invitation-details',
          arguments: {'match_id': matchId, 'from_deep_link': true},
        );
      } else if (token != null) {
        navigatorKey.currentState?.pushNamed(
          '/invitation-details',
          arguments: {'token': token, 'from_deep_link': true},
        );
      }
    }
  }

  static String generateInviteLink(String matchId) {
    return 'courtplus://invite?match_id=$matchId';
  }

  static String generateTokenLink(String token) {
    return 'courtplus://invite?token=$token';
  }

  void dispose() {
    _sub?.cancel();
  }
}