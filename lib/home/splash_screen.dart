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
    with SingleTickerProviderStateMixin {
  /// Tiempo mínimo en splash antes de navegar (≥ duración de la intro).
  static const Duration _kTotalSplashTime = Duration(milliseconds: 3600);

  late AnimationController _intro;

  /// Fase 1: logo + "Centro Cristiano / Internacional" aparecen juntos.
  late Animation<double> _brandOpacity;
  late Animation<double> _logoScale;

  /// Fase 2: bloque marca sube para dejar sitio a "San Pedro Sula".
  late Animation<double> _brandSlideUp;

  /// Fase 3: "San Pedro Sula" (opacidad + leve subida) y spotlight izq→der.
  late Animation<double> _spsOpacity;
  late Animation<double> _spsSlideFromBelow;
  late Animation<double> _spsSpotlightReveal;

  bool _navigated = false;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();

    const introDuration = Duration(milliseconds: 3000);
    _intro = AnimationController(vsync: this, duration: introDuration);

    // 0.00–0.30: logo grande → tamaño final + título entra con el logo.
    _logoScale = Tween<double>(begin: 1.42, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOutCubic),
      ),
    );
    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.02, 0.28, curve: Curves.easeOutCubic),
      ),
    );

    // 0.30–0.56: todo el bloque marca sube (deja hueco abajo para SPS).
    _brandSlideUp = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.30, 0.56, curve: Curves.easeInOutCubic),
      ),
    );

    // 0.54–0.68: aparece "San Pedro Sula"; 0.58–1.0: spotlight.
    _spsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.54, 0.70, curve: Curves.easeOutCubic),
      ),
    );
    _spsSlideFromBelow = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.54, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _spsSpotlightReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.58, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _intro.forward();
    unawaited(_continueAfterBoot());
  }

  Future<void> _continueAfterBoot() async {
    try {
      await Future.wait<void>([
        FCMService().preloadInitialMessage(),
        FCMService().ensureInitialMessage(),
      ]).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      debugPrint(
          'Splash: tiempo de espera leyendo mensaje FCM inicial; continuando.');
    } catch (e, st) {
      debugPrint('Splash: error leyendo mensaje FCM inicial: $e');
      debugPrint('$st');
    }
    if (!mounted || _navigated) return;

    final elapsed = DateTime.now().difference(_startedAt);
    final remaining = _kTotalSplashTime - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
      if (!mounted || _navigated) return;
    }

    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigation(fromSplash: true),
        transitionDuration: const Duration(milliseconds: 420),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _SplashRouteKeyframes(animation: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
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

    final slidePixels = screenHeight * 0.078;
    final spsLift = screenHeight * 0.028;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getGradientBackground(),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _intro,
              builder: (context, child) {
                final brandOpacity = _brandOpacity.value.clamp(0.0, 1.0);
                final slide = _brandSlideUp.value.clamp(0.0, 1.0);
                final spsOpacity = _spsOpacity.value.clamp(0.0, 1.0);
                final spsSlide = _spsSlideFromBelow.value.clamp(0.0, 1.0);
                final spotlight = _spsSpotlightReveal.value.clamp(0.0, 1.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -slide * slidePixels),
                      child: Opacity(
                        opacity: brandOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: _logoScale.value.clamp(0.85, 2.0),
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
                            SizedBox(height: screenHeight * 0.032),
                            Padding(
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.022),
                    Opacity(
                      opacity: spsOpacity,
                      child: Transform.translate(
                        offset: Offset(0, spsSlide * spsLift),
                        child: _SpotlightText(
                          text: 'San Pedro Sula',
                          baseStyle: subtitleStyle,
                          highlightStyle: subtitleStyle.copyWith(
                            color: blanco,
                            fontWeight: FontWeight.w500,
                          ),
                          reveal: spotlight,
                        ),
                      ),
                    ),
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

/// Salida splash → `MainNavigation` con curvas por tramos (keyframes), no un solo fade.
class _SplashRouteKeyframes extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _SplashRouteKeyframes({
    required this.animation,
    required this.child,
  });

  static double _kfOpacity(double t) {
    if (t <= 0.24) return Curves.easeOut.transform(t / 0.24);
    return 1.0;
  }

  static double _kfScale(double t) {
    final u = ((t - 0.05) / 0.68).clamp(0.0, 1.0);
    return 0.93 + 0.07 * Curves.easeOutCubic.transform(u);
  }

  static double _kfSlideRemain(double t) {
    final u = (t / 0.52).clamp(0.0, 1.0);
    return 1.0 - Curves.easeOut.transform(u);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value.clamp(0.0, 1.0);
        final h = MediaQuery.of(context).size.height;
        return Opacity(
          opacity: _kfOpacity(t),
          child: Transform.translate(
            offset: Offset(0, 0.022 * h * _kfSlideRemain(t)),
            child: Transform.scale(
              scale: _kfScale(t),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _SpotlightText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;
  final double reveal;

  const _SpotlightText({
    required this.text,
    required this.baseStyle,
    required this.highlightStyle,
    required this.reveal,
  });

  @override
  Widget build(BuildContext context) {
    const beamWidth = 0.22;
    final left = (reveal - beamWidth).clamp(0.0, 1.0);
    final mid = reveal.clamp(0.0, 1.0);
    final right = (reveal + beamWidth).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.92,
          child: Text(
            text,
            style: baseStyle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
        Opacity(
          opacity: reveal > 0 ? 1.0 : 0.0,
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
                stops: [left, mid, right],
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
