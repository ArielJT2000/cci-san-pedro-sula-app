import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import '../navigation/main_navigation.dart';
import '../pantallas/alive.dart';
import '../pantallas/shift.dart';

// Importar Firebase para Android e iOS
import 'package:firebase_messaging/firebase_messaging.dart'
    if (dart.library.io) 'package:firebase_messaging/firebase_messaging.dart';

/// Handler para notificaciones cuando la app está en segundo plano
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Notificación recibida en segundo plano: ${message.messageId}');
  debugPrint('Título: ${message.notification?.title}');
  debugPrint('Cuerpo: ${message.notification?.body}');
  debugPrint('Datos: ${message.data}');

  // NO mostrar notificación local si Firebase ya tiene notification en el payload
  // Firebase automáticamente muestra la notificación cuando hay 'notification' en el payload
  // Solo mostrar notificación local si SOLO hay 'data' sin 'notification'
  if (message.notification == null && message.data.isNotEmpty) {
    // Inicializar el servicio de notificaciones locales solo si es necesario
    await NotificationService().initialize();

    // Si solo hay datos sin notification, mostrar notificación con los datos
    final notificationType = message.data['type'] ?? 'general';
    final title = message.data['title'] ?? 'CCI San Pedro Sula';
    final body = message.data['body'] ?? 'Nueva notificación';

    await NotificationService().showNotification(
      id: message.hashCode,
      title: title,
      body: body,
      payload: notificationType,
    );
    debugPrint(
        'Notificación mostrada desde datos en segundo plano (sin notification en payload)');
  } else {
    debugPrint(
        'Notificación manejada automáticamente por Firebase (tiene notification en payload)');
  }
}

/// En iOS, FCM necesita el token APNs antes de [FirebaseMessaging.getToken];
/// Apple lo entrega de forma asíncrona tras permisos + registro remoto.
/// Solo avisos claramente de “en vivo” real (p. ej. Lambda). No usar “transmisión” suelto:
/// textos de prueba de *eventos* suelen decir “transmisión” y no deben ir a pantalla Live.
bool _textSuggestsLiveStream(String? title, String? body) {
  final t = '${title ?? ''}\n${body ?? ''}'.toLowerCase();
  if (t.contains('estamos en vivo')) return true;
  if (t.contains('hay una transmisión en vivo') ||
      t.contains('hay una transmision en vivo')) {
    return true;
  }
  if (t.contains('transmisión en vivo') || t.contains('transmision en vivo')) {
    return true;
  }
  if (t.contains('🔴') && t.contains('transmis')) return true;
  return false;
}

/// Combina `data` de FCM con inferencia mínima. Si ya viene `type` del backend, no se toca (iOS/Android).
Map<String, dynamic> _effectiveDataForNavigation(RemoteMessage message) {
  final data = Map<String, dynamic>.from(message.data);
  final typeVal = (data['type']?.toString() ?? '').trim();
  if (typeVal.isNotEmpty) {
    return data;
  }

  final title = message.notification?.title;
  final body = message.notification?.body;
  final eventId = (data['eventId'] ?? data['eventID'] ?? '').toString().trim();

  if (eventId.isNotEmpty) {
    data['type'] = 'new_event';
    return data;
  }

  if (message.notification != null && _textSuggestsLiveStream(title, body)) {
    data['type'] = 'live_stream';
  }

  return data;
}

Future<void> _waitForIosApnsToken(FirebaseMessaging messaging) async {
  const maxAttempts = 40;
  const delay = Duration(milliseconds: 300);
  for (var i = 0; i < maxAttempts; i++) {
    final apns = await messaging.getAPNSToken();
    if (apns != null && apns.isNotEmpty) {
      debugPrint('APNS listo para FCM (intento ${i + 1}/$maxAttempts)');
      return;
    }
    await Future.delayed(delay);
  }
  debugPrint(
      'APNS no llegó a tiempo; si estás en iOS físico, prueba hot restart (R) o reabrir la app.');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _initialized = false;
  final Completer<void> _readyCompleter = Completer<void>();
  GlobalKey<NavigatorState>? _navigatorKey;

  // Guardar mensaje inicial para navegar cuando MainNavigation esté listo
  static RemoteMessage? _pendingInitialMessage;
  static String? _pendingNotificationPayload;

  static String? _lastForegroundDedupeId;
  static DateTime? _lastForegroundDedupeAt;

  /// Datos de navegación pendiente (pantalla + evento) para que la pantalla destino los consuma
  static String? pendingEventId;
  static String? pendingCategory;

  /// True si la app se abrió desde una notificación (permite saltar Welcome)
  static bool get hasPendingNotification =>
      _pendingInitialMessage != null || _pendingNotificationPayload != null;

  /// En cold start [getInitialMessage] a veces devuelve null o [data] vacío hasta más tarde.
  Future<void> ensureInitialMessage() async {
    if (_pendingInitialMessage != null) return;
    _messaging ??= FirebaseMessaging.instance;
    try {
      const delays = [
        Duration.zero,
        Duration(milliseconds: 400),
        Duration(milliseconds: 800),
        Duration(milliseconds: 1400),
      ];
      for (final d in delays) {
        if (_pendingInitialMessage != null) break;
        if (d > Duration.zero) await Future.delayed(d);
        final message = await _messaging!.getInitialMessage();
        if (message != null) {
          debugPrint('ensureInitialMessage: mensaje obtenido (cold start)');
          debugPrint('Datos: ${message.data}');
          _pendingInitialMessage = message;
          break;
        }
      }
    } catch (e) {
      debugPrint('ensureInitialMessage error: $e');
    }
  }

  /// Intenta precargar el mensaje inicial lo antes posible, sin depender de que
  /// `initialize()` termine (en iOS puede tardar por APNs).
  ///
  /// Importante: esto NO solicita permisos ni token; solo intenta leer el intent
  /// de apertura (deep link) para decidir navegación inicial.
  Future<void> preloadInitialMessage() async {
    if (_pendingInitialMessage != null) return;
    try {
      _messaging ??= FirebaseMessaging.instance;
      final message = await _messaging!.getInitialMessage();
      if (message != null) {
        debugPrint('preloadInitialMessage: mensaje obtenido (cold start)');
        debugPrint('Datos: ${message.data}');
        _pendingInitialMessage = message;
      }
    } catch (e) {
      debugPrint('preloadInitialMessage error: $e');
    }
  }

  /// Devuelve y limpia los datos de evento pendiente para la pantalla que los consuma
  static Map<String, String>? consumePendingEventNavigation() {
    final eventId = pendingEventId;
    final category = pendingCategory;
    pendingEventId = null;
    pendingCategory = null;
    if (eventId == null || eventId.isEmpty) return null;
    return {'eventId': eventId, 'category': category ?? 'general'};
  }

  /// Establece la clave de navegación para poder navegar desde notificaciones
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Se completa cuando `initialize()` terminó (con éxito o no).
  Future<void> get ready => _readyCompleter.future;

  /// Inicializa el servicio FCM
  Future<void> initialize() async {
    if (_initialized) {
      if (!_readyCompleter.isCompleted) _readyCompleter.complete();
      return;
    }

    try {
      _messaging = FirebaseMessaging.instance;

      // Solicitar permisos
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Usuario autorizó notificaciones');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('Usuario autorizó notificaciones provisionales');
      } else {
        debugPrint('Usuario rechazó o no autorizó notificaciones');
        return;
      }

      // Configurar handler para segundo plano
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Configurar handlers para cuando la app está en primer plano
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _waitForIosApnsToken(_messaging!);
      }

      // Obtener token FCM
      _fcmToken = await _messaging!.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Escuchar cambios en el token
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('Nuevo FCM Token: $newToken');
      });

      // Verificar si la app fue abierta desde una notificación (app cerrada o en segundo plano)
      RemoteMessage? initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            'App abierta desde notificación: ${initialMessage.messageId}');
        debugPrint('Datos: ${initialMessage.data}');
        _pendingInitialMessage = initialMessage;
        // No llamar _handlePendingNavigation aquí: SplashScreen llevará a MainNavigation
        // y onMainNavigationReady() lo hará cuando el tab esté listo.
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Error inicializando FCM: $e');
      _initialized = true; // Marcar como inicializado para no intentar de nuevo
    } finally {
      if (!_readyCompleter.isCompleted) _readyCompleter.complete();
    }
  }

  /// Una sola tarjeta en Android: cancela la anterior con el mismo (id, tag) antes de mostrar.
  Future<void> _mirrorFcmForegroundOnAndroid(
      RemoteMessage message, String payload) async {
    const androidMirrorId = 9001;
    const androidMirrorTag = 'cci_fcm_mirror';
    await NotificationService()
        .cancelNotification(androidMirrorId, tag: androidMirrorTag);
    await NotificationService().showNotification(
      id: androidMirrorId,
      title: message.notification!.title ?? 'CCI San Pedro Sula',
      body: message.notification!.body ?? '',
      payload: payload,
      androidTag: androidMirrorTag,
    );
  }

  /// Maneja notificaciones cuando la app está en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Notificación recibida en primer plano: ${message.messageId}');
    debugPrint('Datos de la notificación: ${message.data}');

    final mid = message.messageId ?? '';
    final now = DateTime.now();
    if (mid.isNotEmpty) {
      if (mid == _lastForegroundDedupeId &&
          _lastForegroundDedupeAt != null &&
          now.difference(_lastForegroundDedupeAt!) <
              const Duration(seconds: 4)) {
        debugPrint('FCM foreground: omitiendo duplicado messageId=$mid');
        return;
      }
      _lastForegroundDedupeId = mid;
      _lastForegroundDedupeAt = now;
    }

    if (message.notification != null) {
      final data = _effectiveDataForNavigation(message);
      final category = (data['category'] ?? 'general').toString();
      final eventId = (data['eventId'] ?? data['eventID'] ?? '').toString();
      final type = (data['type'] ?? 'new_event').toString();
      final videoId = (data['videoId'] ?? '').toString();
      final payloadMap = <String, dynamic>{
        'type': type,
        'category': category,
        'eventId': eventId,
      };
      if (videoId.isNotEmpty) payloadMap['videoId'] = videoId;
      final payload = jsonEncode(payloadMap);

      if (defaultTargetPlatform == TargetPlatform.android) {
        unawaited(_mirrorFcmForegroundOnAndroid(message, payload));
      } else {
        unawaited(NotificationService().showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'CCI San Pedro Sula',
          body: message.notification!.body ?? '',
          payload: payload,
        ));
      }
    }
  }

  /// Maneja cuando el usuario toca una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Usuario tocó la notificación: ${message.messageId}');
    debugPrint('Datos de la notificación: ${message.data}');
    final notificationType = message.data['type'];
    debugPrint('Tipo de notificación: $notificationType');

    // Guardar el mensaje para navegar
    _pendingInitialMessage = message;
    _handlePendingNavigation();
  }

  /// Maneja la navegación pendiente cuando MainNavigation esté listo
  void _handlePendingNavigation() {
    RemoteMessage? message = _pendingInitialMessage;
    String? payload = _pendingNotificationPayload;

    if (message != null) {
      final data = _effectiveDataForNavigation(message);
      _applyNavigationFromData(data);
      _pendingInitialMessage = null;
    } else if (payload != null) {
      debugPrint('Procesando navegación desde payload: $payload');
      _pendingNotificationPayload = null;
      if (payload.trim().startsWith('{')) {
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          final type = (data['type'] ?? 'new_event').toString();
          final category =
              (data['category'] ?? 'general').toString().toLowerCase();
          final eventId = (data['eventId'] ?? '').toString();
          _applyNavigationFromData(
              {'type': type, 'category': category, 'eventId': eventId});
        } catch (e) {
          debugPrint('Error parseando payload JSON: $e');
          if (payload == 'live_stream')
            _navigateToScreen(4);
          else if (payload == 'new_event') _navigateToScreen(1);
        }
      } else {
        if (payload == 'live_stream')
          _navigateToScreen(4);
        else if (payload == 'new_event') {
          pendingCategory = 'general';
          _navigateToScreen(1);
        }
      }
    }
  }

  void _applyNavigationFromData(Map<String, dynamic> data) {
    final notificationType = data['type']?.toString();
    final category = (data['category'] ?? '').toString().toLowerCase();
    final eventId = (data['eventId'] ?? data['eventID'] ?? '').toString();
    final videoId = (data['videoId'] ?? '').toString();
    debugPrint(
        'Navegación: type=$notificationType, category=$category, eventId=$eventId, videoId=$videoId');

    final isLiveByType = notificationType == 'live_stream';
    // En algunos dispositivos al abrir desde notificación (app cerrada) el mapa
    // `data` llega incompleto pero sí trae `videoId` desde FCM.
    final isLiveByPayload = videoId.isNotEmpty &&
        notificationType != 'new_event' &&
        eventId.isEmpty;

    if (isLiveByType || isLiveByPayload) {
      _navigateToScreen(4);
      return;
    }
    if (notificationType == 'new_event') {
      pendingEventId = eventId.isNotEmpty ? eventId : null;
      pendingCategory = category.isNotEmpty ? category : 'general';
      if (category == 'alive' || category == 'shift') {
        // No ir al tab Ministerios: push directo a Alive/Shift para que al volver atrás no quede Ministerios
        Future.delayed(const Duration(milliseconds: 500), () {
          final state = _navigatorKey?.currentState;
          if (state != null && state.mounted) {
            if (category == 'alive') {
              state.push(MaterialPageRoute(builder: (_) => const Alive()));
            } else {
              state.push(MaterialPageRoute(builder: (_) => const Shift()));
            }
          }
        });
      } else {
        final index = _eventCategoryToPageIndex(category);
        _navigateToScreen(index);
      }
      return;
    }
    debugPrint('Tipo de notificación desconocido: $notificationType');
  }

  /// general -> Eventos(1), next -> Next(7). alive/shift se manejan con push directo (sin tab Ministerios).
  int _eventCategoryToPageIndex(String category) {
    switch (category) {
      case 'next':
        return 7;
      case 'alive':
      case 'shift':
        return 0;
      default:
        return 1;
    }
  }

  /// Método público para que MainNavigation notifique cuando esté listo
  void onMainNavigationReady() {
    debugPrint(
        'MainNavigation está listo, verificando navegación pendiente...');
    Future.delayed(const Duration(milliseconds: 500), () {
      _handlePendingNavigation();
    });
  }

  /// Método para navegar desde notificaciones locales
  void navigateFromLocalNotification(String? payload) {
    if (payload != null) {
      _pendingNotificationPayload = payload;
      _handlePendingNavigation();
    }
  }

  /// Navega a una pantalla específica usando el PageController de MainNavigation
  void _navigateToScreen(int screenIndex) {
    debugPrint('Intentando navegar a pantalla índice: $screenIndex');

    // navigateToPage no lanza si _instance es null: antes se hacía return aquí y nunca
    // se llegaba a pushAndRemoveUntil (p. ej. usuario en Welcome).
    if (MainNavigation.canNavigate) {
      MainNavigation.navigateToPage(screenIndex);
      debugPrint('Navegación: MainNavigation montado, tab $screenIndex');
      return;
    }

    // MainNavigation no montado: seguir con navigatorKey
    if (_navigatorKey?.currentState == null) {
      debugPrint(
          'NavigatorKey no está disponible, reintentando en 1 segundo...');
      Future.delayed(const Duration(milliseconds: 1000), () {
        _navigateToScreen(screenIndex);
      });
      return;
    }

    final context = _navigatorKey!.currentContext;
    if (context == null) {
      debugPrint('Context no está disponible, reintentando en 1 segundo...');
      Future.delayed(const Duration(milliseconds: 1000), () {
        _navigateToScreen(screenIndex);
      });
      return;
    }

    // Verificar si MainNavigation está montado
    final mainNavigation =
        context.findAncestorWidgetOfExactType<MainNavigation>();

    if (mainNavigation != null) {
      // MainNavigation está montado, navegar directamente
      debugPrint('MainNavigation encontrado, navegando directamente');
      MainNavigation.navigateToPage(screenIndex);
    } else {
      // MainNavigation no está montado, navegar primero a MainNavigation
      debugPrint(
          'MainNavigation no encontrado, navegando primero a MainNavigation');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
        (route) => false,
      );

      // Esperar a que MainNavigation esté montado y luego navegar
      Future.delayed(const Duration(milliseconds: 1000), () {
        debugPrint('Intentando navegar después de montar MainNavigation');
        MainNavigation.navigateToPage(screenIndex);

        // Si aún no funciona, intentar de nuevo
        Future.delayed(const Duration(milliseconds: 800), () {
          MainNavigation.navigateToPage(screenIndex);
        });
      });
    }
  }

  /// Obtiene el token FCM actual
  String? getToken() => _fcmToken;

  /// Suscribe a un tema (opcional)
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) return;
    try {
      await _messaging!.subscribeToTopic(topic);
      debugPrint('Suscrito al tema: $topic');
    } catch (e) {
      debugPrint('Error suscribiéndose al tema: $e');
    }
  }

  /// Cancela suscripción a un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) return;
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      debugPrint('Cancelada suscripción al tema: $topic');
    } catch (e) {
      debugPrint('Error cancelando suscripción al tema: $e');
    }
  }
}
