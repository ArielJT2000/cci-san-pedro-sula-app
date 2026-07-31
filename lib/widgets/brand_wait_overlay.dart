import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Pantalla de marca (logo + degradado):
/// - Tras [idleTimeout] sin tocar la app (aunque se bloquee o vaya a 2.º plano).
/// - También al pasar a 2.º plano, para el App Switcher.
class BrandWaitOverlay extends StatefulWidget {
  final Widget child;

  /// Tiempo sin interacción para activar la pantalla de marca.
  static const Duration idleTimeout = Duration(minutes: 5);

  const BrandWaitOverlay({super.key, required this.child});

  @override
  State<BrandWaitOverlay> createState() => _BrandWaitOverlayState();
}

class _BrandWaitOverlayState extends State<BrandWaitOverlay>
    with WidgetsBindingObserver {
  bool _backgroundBrand = false;
  bool _idleBrand = false;
  Timer? _idleTimer;
  DateTime _lastActivityAt = DateTime.now();
  bool _appInForeground = true;

  bool get _showBrand => _backgroundBrand || _idleBrand;

  bool get _isPastIdleTimeout =>
      DateTime.now().difference(_lastActivityAt) >=
      BrandWaitOverlay.idleTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastActivityAt = DateTime.now();
    _scheduleIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _markActivity() {
    _lastActivityAt = DateTime.now();
    if (_idleBrand) {
      setState(() => _idleBrand = false);
    }
    _scheduleIdleTimer();
  }

  void _scheduleIdleTimer() {
    _idleTimer?.cancel();
    if (!_appInForeground || _idleBrand) return;

    final elapsed = DateTime.now().difference(_lastActivityAt);
    final remaining = BrandWaitOverlay.idleTimeout - elapsed;
    if (remaining <= Duration.zero) {
      setState(() => _idleBrand = true);
      return;
    }

    _idleTimer = Timer(remaining, () {
      if (!mounted || !_appInForeground) return;
      if (_isPastIdleTimeout) {
        setState(() => _idleBrand = true);
      }
    });
  }

  void _dismissIdleBrand() {
    _lastActivityAt = DateTime.now();
    if (!_idleBrand && !_backgroundBrand) return;
    setState(() {
      _idleBrand = false;
      _backgroundBrand = false;
    });
    _scheduleIdleTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final inBackground = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;

    if (inBackground) {
      _appInForeground = false;
      _idleTimer?.cancel();
      // App Switcher: captura el logo. Si ya hubo 5 min de inactividad,
      // al volver también se mantiene la pantalla de marca.
      setState(() {
        _backgroundBrand = true;
        if (_isPastIdleTimeout) {
          _idleBrand = true;
        }
      });
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _appInForeground = true;
      final showIdle = _isPastIdleTimeout;
      setState(() {
        _backgroundBrand = false;
        _idleBrand = showIdle;
      });
      if (!showIdle) {
        _scheduleIdleTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (_idleBrand) return;
        _markActivity();
      },
      onPointerSignal: (_) {
        if (_idleBrand) return;
        _markActivity();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_showBrand)
            Positioned.fill(
              child: _BrandScreen(
                onTap: _idleBrand ? _dismissIdleBrand : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandScreen extends StatelessWidget {
  final VoidCallback? onTap;

  const _BrandScreen({this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final content = DecoratedBox(
      decoration: getGradientBackground(),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: width * 0.42,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
