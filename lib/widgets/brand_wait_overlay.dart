import 'dart:async';

import 'package:flutter/material.dart';

/// Pantalla de marca solo tras inactividad prolongada (p. ej. 5 min).
///
/// No se muestra al abrir la app ni al pasar al App Switcher de inmediato:
/// eso dejaba el logo encima del splash y cancelaba su animación.
class BrandWaitOverlay extends StatefulWidget {
  const BrandWaitOverlay({
    super.key,
    required this.child,
    this.idleTimeout = const Duration(minutes: 5),
  });

  final Widget child;
  final Duration idleTimeout;

  @override
  State<BrandWaitOverlay> createState() => _BrandWaitOverlayState();
}

class _BrandWaitOverlayState extends State<BrandWaitOverlay>
    with WidgetsBindingObserver {
  Timer? _idleTimer;
  bool _showBrand = false;
  DateTime _lastActivityAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleIdle();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Duration get _idleRemaining {
    final elapsed = DateTime.now().difference(_lastActivityAt);
    final left = widget.idleTimeout - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  bool get _isPastIdle =>
      DateTime.now().difference(_lastActivityAt) >= widget.idleTimeout;

  void _scheduleIdle() {
    _idleTimer?.cancel();
    final remaining = _idleRemaining;
    if (remaining == Duration.zero) {
      if (!_showBrand && mounted) setState(() => _showBrand = true);
      return;
    }
    _idleTimer = Timer(remaining, () {
      if (!mounted || _showBrand) return;
      setState(() => _showBrand = true);
    });
  }

  void _onUserActivity() {
    _lastActivityAt = DateTime.now();
    if (_showBrand) {
      setState(() => _showBrand = false);
    }
    _scheduleIdle();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Si ya hubo ≥5 min sin tocar, mostrar marca al volver.
        // Si no, no tapar la UI (ni el splash) y seguir el idle restante.
        if (_isPastIdle) {
          _idleTimer?.cancel();
          if (!_showBrand) setState(() => _showBrand = true);
        } else {
          _scheduleIdle();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // No mostrar marca al ir al switcher; solo pausar el timer.
        _idleTimer?.cancel();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserActivity(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_showBrand)
            const Positioned.fill(
              child: AbsorbPointer(
                child: _BrandScreen(),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandScreen extends StatelessWidget {
  const _BrandScreen();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 160,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
