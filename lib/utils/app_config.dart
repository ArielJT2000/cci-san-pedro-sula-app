/// Configuración de la aplicación
/// Solo contiene las constantes que se utilizan en el código
class AppConfig {
  // Configuraciones de notificaciones (usadas en NotificationService)
  static const String notificationChannelId = 'cci_notifications';
  static const String notificationChannelName = 'CCI Notifications';
  static const String notificationChannelDescription =
      'Notificaciones de CCI San Pedro Sula';

  // Canal de YouTube
  static const String youtubeChannelUrl = 'https://youtube.com/ccisanpedrosula';

  /// Scheme nativo (fallback): `ccisps://event/{eventId}?category=general`
  static const String deepLinkScheme = 'ccisps';

  /// Host HTTPS para links compartibles (WhatsApp sí los hace clicables).
  /// Debe servir la página en `hosting/app/` del repo.
  static const String shareLinkHost = 'ccisanpedrosula.org';

  /// Base del link público: `https://ccisanpedrosula.org/app/?e=ID&c=general`
  static const String shareLinkBase = 'https://$shareLinkHost/app/';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.cci.sanpedrosula';

  static const String appStoreUrl = 'https://apps.apple.com/app/id6760858460';
}
