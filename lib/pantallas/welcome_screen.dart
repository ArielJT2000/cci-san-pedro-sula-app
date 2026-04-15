import 'package:flutter/material.dart';
import 'dart:ui';
import '../navigation/main_navigation.dart';
import '../utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  /// Cuando viene desde el Splash (via Hero), evitamos la animación de entrada
  /// para que el logo aterrice exactamente en su tamaño/posición final.
  final bool fromSplash;

  const WelcomeScreen({super.key, this.fromSplash = false});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _logoExitController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _navigatingToHome = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: duracionLarga,
      vsync: this,
    );

    _logoExitController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: curvaSuave),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: curvaSuave),
      ),
    );

    if (widget.fromSplash) {
      // Salta la animación de entrada: el Hero define el movimiento inicial.
      _animationController.value = 1.0;
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoExitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveScale = widget.fromSplash
        ? const AlwaysStoppedAnimation<double>(1.0)
        : _scaleAnimation;
    final effectiveSlide = widget.fromSplash
        ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
        : _slideAnimation;
    final effectiveFade = widget.fromSplash
        ? const AlwaysStoppedAnimation<double>(1.0)
        : _fadeAnimation;

    final tituloBase = getTitulo(screenWidth);
    // ~30 % más grande que el título welcome anterior (1.18 × 1.30 sobre getTitulo).
    final welcomeTituloStyle = tituloBase.copyWith(
      fontSize: (tituloBase.fontSize ?? 48) * 1.18 * 1.30,
      height: 1.05,
    );
    final subtituloBase = getSubtitulo(screenWidth);
    final welcomeSubtituloStyle = subtituloBase.copyWith(
      color: grisMedio,
      fontSize: (subtituloBase.fontSize ?? 22) * 0.72,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getGradientBackground(),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: effectiveFade,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: getHorizontalPadding(screenWidth),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // Logo: Hero solo Splash → Welcome; al pulsar Empezar se oculta antes del push.
                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [_animationController, _logoExitController]),
                        builder: (context, child) {
                          final exit = _logoExitController.value;
                          final welcomeOpacity =
                              effectiveFade.value * (1.0 - exit);
                          final welcomeScale =
                              effectiveScale.value * (1.0 - 0.12 * exit);
                          return Opacity(
                            opacity: welcomeOpacity.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: welcomeScale.clamp(0.01, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: SlideTransition(
                          position: effectiveSlide,
                          child: Material(
                            color: Colors.transparent,
                            child: Hero(
                              tag: 'app_logo',
                              flightShuttleBuilder: (
                                BuildContext flightContext,
                                Animation<double> animation,
                                HeroFlightDirection flightDirection,
                                BuildContext fromHeroContext,
                                BuildContext toHeroContext,
                              ) {
                                final fromHero = fromHeroContext.widget as Hero;
                                if (fromHero.key ==
                                    const ValueKey('splash_app_logo_hero')) {
                                  if (toHeroContext.widget is Hero) {
                                    return (toHeroContext.widget as Hero).child;
                                  }
                                  return fromHero.child;
                                }

                                final Hero toHero =
                                    toHeroContext.widget as Hero;
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    final progress = animation.value;
                                    final scale = 1.0 - (progress * 0.15);
                                    final opacity = 1.0 - (progress * 0.2);

                                    return Opacity(
                                      opacity: opacity.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: scale.clamp(0.85, 1.0),
                                        child: toHero.child,
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: screenWidth * 0.5,
                                height: screenWidth * 0.5,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.church,
                                    size: screenWidth * 0.4,
                                    color: blanco,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      // Título con animación (más grande que getTitulo estándar)
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getHorizontalPadding(screenWidth),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Centro Cristiano',
                                    style: welcomeTituloStyle,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                    softWrap: false,
                                  ),
                                  SizedBox(height: screenHeight * 0.006),
                                  Text(
                                    'Internacional',
                                    style: welcomeTituloStyle,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      // Subtítulo (más pequeño que getSubtitulo estándar)
                      SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          "San Pedro Sula",
                          style: welcomeSubtituloStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(flex: 2),
                      // Botón minimalista
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildStartButton(
                            context, screenWidth, screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.08),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(
      BuildContext context, double screenWidth, double screenHeight) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duracionLarga,
      curve: const Interval(0.5, 1.0, curve: curvaSuave),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: GestureDetector(
              onTap: () async {
                if (_navigatingToHome) return;
                setState(() => _navigatingToHome = true);
                await _logoExitController.forward();
                if (!context.mounted) return;

                // Transición con efecto blur (sin Hero a Inicio: el logo reaparece allí con la animación del encabezado).
                Navigator.of(context)
                    .push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const MainNavigation(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final blurValue = (1 - animation.value) * 15.0;

                      return Stack(
                        children: [
                          if (animation.value < 1.0)
                            ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: blurValue,
                                  sigmaY: blurValue,
                                ),
                                child: Container(
                                  color: Colors.black.withValues(
                                      alpha: (0.3 * (1 - animation.value))
                                          .clamp(0.0, 1.0)),
                                ),
                              ),
                            ),
                          FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.03),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        ],
                      );
                    },
                    transitionDuration: duracionLarga,
                  ),
                )
                    .then((_) {
                  if (!mounted) return;
                  _logoExitController.reset();
                  setState(() => _navigatingToHome = false);
                });
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: blanco,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Center(
                  child: Text(
                    "Empezar",
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: screenWidth < 360 ? 16 : 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.41,
                      color: negro,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
