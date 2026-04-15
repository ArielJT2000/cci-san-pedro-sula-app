import 'package:flutter/material.dart';
import 'dart:async';
import '../navigation/main_navigation.dart';
import '../utils/fcm_service.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _kTotalSplashTime = Duration(milliseconds: 2500);
  // Momento aproximado (desde start) en que ya mostramos "San Pedro Sula".
  // Desde aquí corre el "foco" hasta que arranca la salida.
  static const Duration _kSpotlightStartDelay = Duration(milliseconds: 740);
  late AnimationController _animationController;
  late AnimationController _spotlightController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  bool _navigated = false;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final spotlightDuration = _kTotalSplashTime - _kSpotlightStartDelay;
    _spotlightController = AnimationController(
      duration: spotlightDuration > Duration.zero
          ? spotlightDuration
          : const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animación de escala simple: aparece desde pequeño
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutExpo,
      ),
    );

    // Secuencia:
    // 1) Logo entra primero.
    // 2) Título entra después del logo.
    // 3) "San Pedro Sula" entra al final con efecto "foco" (recorrido izq→der).
    _logoOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _titleOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.32, 0.78, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    // Arranca el foco cuando "San Pedro Sula" ya está en pantalla.
    Future.delayed(_kSpotlightStartDelay, () {
      if (!mounted) return;
      _spotlightController.forward();
    });

    unawaited(_continueAfterBoot());
  }

  Future<void> _continueAfterBoot() async {
    // Intentar leer el "intent" de apertura desde notificación lo antes posible,
    // sin esperar a que FCM termine de inicializar (iOS puede tardar por APNs).
    try {
      await Future.wait<void>([
        FCMService().preloadInitialMessage(),
        FCMService().ensureInitialMessage(),
      ]).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      debugPrint(
          'Splash: tiempo de espera leyendo mensaje FCM inicial; continuando.');
    }
    if (!mounted || _navigated) return;

    // Mantener el splash hasta completar ~2.5s total (incluye animación de entrada).
    final elapsed = DateTime.now().difference(_startedAt);
    final remaining = _kTotalSplashTime - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
      if (!mounted || _navigated) return;
    }

    // Ya no existe Welcome: siempre entramos a MainNavigation.
    // Si venimos desde notificación, MainNavigation aplicará la navegación pendiente.
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigation(fromSplash: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _spotlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final titleStyle = getTitulo(screenWidth).copyWith(
      fontSize: (getTitulo(screenWidth).fontSize ?? 56) * 0.62,
      height: 1.05,
    );
    final subtitleStyle = getSubtitulo(screenWidth).copyWith(
      fontSize: (getSubtitulo(screenWidth).fontSize ?? 24) * 0.78,
      fontWeight: FontWeight.w400,
      color: grisMedio,
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getGradientBackground(),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [_animationController, _spotlightController]),
              builder: (context, child) {
                final logoOpacity = _logoOpacity.value.clamp(0.0, 1.0);
                final titleOpacity = _titleOpacity.value.clamp(0.0, 1.0);
                final spsReveal = Curves.easeInOutCubic
                    .transform(_spotlightController.value.clamp(0.0, 1.0));
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.06),
                    Opacity(
                      opacity: logoOpacity,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Material(
                          color: Colors.transparent,
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: screenWidth * 0.55,
                            height: screenWidth * 0.55,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error,
                                  size: 120, color: Colors.red);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),
                    Opacity(
                      opacity: titleOpacity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getHorizontalPadding(screenWidth),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Centro Cristiano',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                            Text(
                              'Internacional',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                            SizedBox(height: screenHeight * 0.018),
                            _SpotlightText(
                              text: 'San Pedro Sula',
                              baseStyle: subtitleStyle,
                              highlightStyle: subtitleStyle.copyWith(
                                color: blanco,
                                fontWeight: FontWeight.w500,
                              ),
                              reveal: spsReveal,
                              dissolveOut: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  /// 0..1 recorrido izq→der del "foco"
  final double reveal;

  /// 0..1 disolver al salir (1 = visible)
  final double dissolveOut;

  const _SpotlightText({
    required this.text,
    required this.baseStyle,
    required this.highlightStyle,
    required this.reveal,
    required this.dissolveOut,
  });

  @override
  Widget build(BuildContext context) {
    // Tamaño aproximado del "foco" (porcentaje del ancho del texto).
    const beamWidth = 0.22;
    final left = (reveal - beamWidth).clamp(0.0, 1.0);
    final mid = reveal.clamp(0.0, 1.0);
    final right = (reveal + beamWidth).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Base: texto tenue fijo.
        Opacity(
          opacity: (0.92 * dissolveOut).clamp(0.0, 1.0),
          child: Text(
            text,
            style: baseStyle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
        // Highlight: un "foco" que recorre de izquierda a derecha.
        Opacity(
          opacity: (dissolveOut * (reveal > 0 ? 1.0 : 0.0)).clamp(0.0, 1.0),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Colors.transparent,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [
                  left,
                  mid,
                  right,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Text(
              text,
              style: highlightStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ),
        ),
      ],
    );
  }
}
