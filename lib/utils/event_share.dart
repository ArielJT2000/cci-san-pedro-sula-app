import 'dart:ui';

import 'package:share_plus/share_plus.dart';
import '../models/event_model.dart';
import 'app_config.dart';

/// Construye y comparte el enlace de un evento.
///
/// Usa HTTPS (clicable en WhatsApp). La página web intenta abrir la app
/// o redirige a las tiendas. Ver `hosting/app/index.html`.
class EventShare {
  EventShare._();

  /// Link nativo: `ccisps://event/{eventId}?category=general`
  static Uri nativeDeepLinkFor({
    required String eventId,
    String category = 'general',
  }) {
    return Uri(
      scheme: AppConfig.deepLinkScheme,
      host: 'event',
      pathSegments: [eventId],
      queryParameters: {
        'category': category.isEmpty ? 'general' : category,
      },
    );
  }

  /// Link HTTPS compartible: `https://ccisanpedrosula.org/app/?e=ID&c=general`
  static Uri httpsShareLinkFor({
    required String eventId,
    String category = 'general',
  }) {
    return Uri.parse(AppConfig.shareLinkBase).replace(
      queryParameters: {
        'e': eventId,
        'c': category.isEmpty ? 'general' : category,
      },
    );
  }

  static String shareText({
    required EventModel event,
    String category = 'general',
  }) {
    final link = httpsShareLinkFor(eventId: event.eventId, category: category);
    return '''
Te invito a "${event.name}" en la app CCI SPS.

📅 ${event.displayDate}

👉 Ábrelo aquí:
$link
'''
        .trim();
  }

  static Future<ShareResult> shareEvent({
    required EventModel event,
    String category = 'general',
    Rect? sharePositionOrigin,
  }) {
    return SharePlus.instance.share(
      ShareParams(
        text: shareText(event: event, category: category),
        subject: 'CCI SPS · ${event.name}',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
