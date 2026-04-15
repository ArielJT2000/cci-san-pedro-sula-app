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
  late AnimationController _animationController;
  late AnimationController _exitController;
  late Animation<double> _scaleAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    print('SplashScreen: initState');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );

    // Animación de escala simple: aparece desde pequeño
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    unawaited(_continueAfterBoot());
  }

  Future<void> _continueAfterBoot() async {
    // Mantener un mínimo de tiempo visible para evitar “flashes”.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted || _navigated) return;

    // Intentar leer el "intent" de apertura desde notificación lo antes posible,
    // sin esperar a que FCM termine de inicializar (iOS puede tardar por APNs).
    await FCMService().preloadInitialMessage();
    if (!mounted || _navigated) return;

    // Efecto de salida (mismo feeling que entrada) antes del push.
    // Ojo: el logo mantiene el Hero hacia Inicio; la salida afecta principalmente el texto.
    await _exitController.forward();
    if (!mounted || _navigated) return;

    // Ya no existe Welcome: siempre entramos a MainNavigation.
    // Si venimos desde notificación, MainNavigation aplicará la navegación pendiente.
    _navigated = true;
    print('SplashScreen: yendo a MainNavigation');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigation(fromSplash: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('SplashScreen: build');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final opacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    );
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
              animation: Listenable.merge([_animationController, _exitController]),
              builder: (context, child) {
                final exit = _exitController.value;
                // "Disolver" al salir: fade-out uniforme de todo el splash.
                final dissolveOut = (1.0 - exit).clamp(0.0, 1.0);
                final textOpacity = (opacity.value * dissolveOut).clamp(0.0, 1.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.06),
                    Opacity(
                      opacity: dissolveOut,
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
                              return Icon(Icons.error,
                                  size: 120, color: Colors.red);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),
                    Opacity(
                      opacity: textOpacity,
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
                            Text(
                              'San Pedro Sula',
                              style: subtitleStyle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
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
