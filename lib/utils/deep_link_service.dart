import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'fcm_service.dart';

/// Escucha deep links de eventos:
/// - `ccisps://event/{id}?category=...`
/// - `https://ccisanpedrosula.org/app/?e={id}&c=...`
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        debugPrint('DeepLink inicial: $initial');
        _handleUri(initial);
      }
    } catch (e) {
      debugPrint('DeepLink getInitialLink error: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('DeepLink recibido: $uri');
        _handleUri(uri);
      },
      onError: (e) => debugPrint('DeepLink stream error: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _started = false;
  }

  void _handleUri(Uri uri) {
    final eventId = _extractEventId(uri);
    if (eventId == null || eventId.isEmpty) return;

    final category = _extractCategory(uri);
    FCMService().openEventFromDeepLink(
      eventId: eventId,
      category: category,
    );
  }

  String? _extractEventId(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    // ccisps://event/{eventId}
    if (scheme == AppConfig.deepLinkScheme) {
      if (host == 'event' && segments.isNotEmpty) return segments.first;
      if (host.isNotEmpty && segments.isEmpty) return host;
      return uri.queryParameters['e'] ?? uri.queryParameters['eventId'];
    }

    // https://ccisanpedrosula.org/app/?e=ID  or  /app/event/ID
    if (scheme == 'https' || scheme == 'http') {
      if (host != AppConfig.shareLinkHost &&
          host != 'www.${AppConfig.shareLinkHost}') {
        return null;
      }
      final fromQuery =
          uri.queryParameters['e'] ?? uri.queryParameters['eventId'];
      if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;

      // /app/event/{id}
      final appIdx = segments.indexOf('app');
      if (appIdx >= 0 &&
          appIdx + 2 < segments.length &&
          segments[appIdx + 1] == 'event') {
        return segments[appIdx + 2];
      }
    }

    return null;
  }

  String _extractCategory(Uri uri) {
    final raw = uri.queryParameters['c'] ??
        uri.queryParameters['category'] ??
        'general';
    return raw.toLowerCase();
  }
}
