import 'dart:async';
import 'package:flutter/material.dart';
import 'aws_video_service.dart';
import 'notification_service.dart';

class LiveStreamMonitor {
  static final LiveStreamMonitor _instance = LiveStreamMonitor._internal();
  factory LiveStreamMonitor() => _instance;
  LiveStreamMonitor._internal();

  Timer? _pollingTimer;
  String? _lastLiveVideoId;
  bool _isMonitoring = false;

  /// Inicia el monitoreo de transmisiones en vivo
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    // Sin polling: dependemos de tu "test manual" (Lambda) + push notification.
    // `checkNow()` sigue disponible si en algún punto quieres verificar manualmente.
  }

  /// Detiene el monitoreo
  void stopMonitoring() {
    _isMonitoring = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Verifica si hay una transmisión en vivo nueva
  Future<void> _checkForLiveStream() async {
    try {
      final videoIds = await AWSVideoService.getVideoIds();
      final currentLiveVideoId = videoIds['liveVideoId'];

      // Si hay una transmisión nueva (diferente a la anterior)
      if (currentLiveVideoId != null &&
          currentLiveVideoId.isNotEmpty &&
          currentLiveVideoId != _lastLiveVideoId) {
        // Mostrar notificación
        await NotificationService().showNotification(
          id: 100,
          title: '🔴 Transmisión en Vivo',
          body: '¡Hay una transmisión en vivo disponible ahora!',
        );

        _lastLiveVideoId = currentLiveVideoId;
      }

      // Si la transmisión terminó, limpiar el estado
      if (currentLiveVideoId == null || currentLiveVideoId.isEmpty) {
        _lastLiveVideoId = null;
      }
    } catch (e) {
      debugPrint('Error verificando transmisión en vivo: $e');
    }
  }

  /// Verifica inmediatamente si hay transmisión en vivo
  Future<void> checkNow() async {
    await _checkForLiveStream();
  }
}
