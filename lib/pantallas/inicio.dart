import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';
import 'eventos.dart';
import 'iglesia.dart';
import 'ministerios.dart';
import 'transmisiones.dart';
import 'ofrendas.dart';
import 'youth.dart';
import 'ubicacion.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _logoPositionController;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _logoPositionAnimation;
  late Animation<Offset> _textPositionAnimation;
  late Animation<double> _logoPositionScaleAnimation;

  @override
  void initState() {
    super.initState();
    _heroAnimationController = AnimationController(
      duration: duracionLarga,
      vsync: this,
    );

    // Animación para el texto con efecto desde la izquierda
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Opacidad del texto (efecto wipe de izquierda a derecha)
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Animación para mover el logo y texto a su posición final
    _logoPositionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animación de posición del logo: desde el centro hacia la derecha
    _logoPositionAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0), // Posición inicial centrada
      end: const Offset(1.25, 0.0), // Posición final: a la derecha
    ).animate(
      CurvedAnimation(
        parent: _logoPositionController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animación de posición del texto: desde el centro hacia la izquierda
    _textPositionAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0), // Posición inicial centrada
      end:
          const Offset(-0.65, 0.0), // Posición final: a la izquierda (ajustado)
    ).animate(
      CurvedAnimation(
        parent: _logoPositionController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Escala del logo: mismo tamaño que al finalizar el Hero (0.85)
    _logoPositionScaleAnimation = Tween<double>(
      begin: 0.85, // Igual al tamaño final del Hero para transición continua
      end: 0.85, // Tamaño final en header
    ).animate(
      CurvedAnimation(
        parent: _logoPositionController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Delay para que la transición Hero se complete primero
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        // El logo ya está en posición centrada después del Hero
        _heroAnimationController.forward();
        // Iniciar animación del texto inmediatamente (aparece centrado)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _textAnimationController.forward();
            // Después de 0.5s, mover todo desde el centro hacia la izquierda
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _logoPositionController.forward();
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _textAnimationController.dispose();
    _logoPositionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SwipeBackWrapper(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getGradientBackground(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getHorizontalPadding(screenWidth),
            ).copyWith(
              top: MediaQuery.of(context).padding.top + 0.05,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo y texto - Inicialmente centrados, luego se separan
                ScaleTransition(
                  scale: _logoPositionScaleAnimation,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Texto que se mueve a la izquierda con efecto wipe
                        SlideTransition(
                          position: _textPositionAnimation,
                          child: Padding(
                            padding: EdgeInsets.only(top: screenWidth * 0.02),
                            child: AnimatedBuilder(
                              animation: _textOpacityAnimation,
                              builder: (context, child) {
                                return ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _textOpacityAnimation.value,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          kChurchName,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: blanco,
                                            fontSize: getFontSizeBodySmall(
                                                screenWidth),
                                            fontWeight: fontWeightBold,
                                            letterSpacing: letterSpacingWider,
                                            height: lineHeightLoose,
                                          ),
                                        ),
                                        Text(
                                          kChurchSubtitle,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: blanco,
                                            fontSize: getFontSizeBodySmall(
                                                screenWidth),
                                            fontWeight: fontWeightBold,
                                            letterSpacing: letterSpacingWider,
                                            height: lineHeightNormal,
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                screenWidth * widthSpacingXS),
                                        Text(
                                          kChurchCity,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontFamily: kFontFamily,
                                            color: grisMedio,
                                            fontSize:
                                                getFontSizeSmall(screenWidth),
                                            fontWeight: fontWeightRegular,
                                            letterSpacing: letterSpacingWide,
                                            height: lineHeightLoose,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        // Logo que se mueve a la derecha
                        SlideTransition(
                          position: _logoPositionAnimation,
                          child: Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/images/Logo CCI SPS_Globo Gris Oscuro.png',
                              width: screenWidth * 0.20,
                              height: screenWidth * 0.20,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.church,
                                  size: screenWidth * 0.3,
                                  color: blanco,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                _buildHeroSection(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.08),
                _buildMenuGrid(context, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _heroAnimationController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main headline con diferentes tamaños
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MOSTREMOS - fuente más pequeña
              Text(
                kMainMessageLine1,
                style: getHeroSmallTextStyle(screenWidth),
              ),
              SizedBox(height: screenHeight * spacingS),
              // EL AMOR - fuente mucho más grande y negrita
              Text(
                kMainMessageLine2,
                style: getHeroTextStyle(screenWidth),
              ),
              SizedBox(height: screenHeight * spacingXXS),
              // DE DIOS - fuente mucho más grande y negrita
              Text(
                kMainMessageLine3,
                style: getHeroTextStyle(screenWidth),
              ),
              SizedBox(height: screenHeight * spacingS),
              // PARA QUE EL MUNDO CREA - fuente más pequeña
              Text(
                kMainMessageLine4,
                style: getHeroSmallTextStyle(screenWidth),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          // Imagen del mundo
          Center(
            child: Image.asset(
              'assets/images/mundo.png',
              width: screenWidth - (getHorizontalPadding(screenWidth) * 2),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.public,
                  size: screenWidth * 0.3,
                  color: blanco,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const double _bentoRadius = borderRadiusXL;
  static const double _bentoGap = 12.0;

  Widget _buildMenuGrid(
      BuildContext context, double screenWidth, double screenHeight) {
    final titleStyle = getCardTitleStyle(screenWidth);
    final subtitleStyle = getCardSubtitleStyle(screenWidth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          kSectionExplore,
          style: getSectionTitleStyle(screenWidth),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: screenHeight * 0.025),
        _buildBentoNavTile(
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          icon: Icons.calendar_today_outlined,
          title: 'Eventos',
          subtitle: 'Próximas actividades',
          screen: const Eventos(),
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          minHeight: 108,
          featuredAccent: true,
        ),
        SizedBox(height: _bentoGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 58,
              child: _buildBentoNavTile(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                icon: Icons.church_outlined,
                title: 'Seamos Iglesia',
                subtitle: 'Conoce más sobre nosotros',
                screen: const Iglesia(),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                minHeight: 148,
                compactText: false,
              ),
            ),
            SizedBox(width: _bentoGap),
            Expanded(
              flex: 42,
              child: _buildBentoNavTile(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                icon: Icons.people_outline,
                title: 'Ministerios CCI',
                subtitle: 'Nuestros ministerios',
                screen: const Ministerios(),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                minHeight: 112,
                compactText: true,
              ),
            ),
          ],
        ),
        SizedBox(height: _bentoGap),
        _buildBentoNavTile(
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          icon: Icons.live_tv_outlined,
          title: 'En vivo',
          subtitle: 'Transmisiones en vivo',
          screen: const Transmisiones(),
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          minHeight: 108,
          featuredAccent: true,
        ),
        SizedBox(height: _bentoGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 58,
              child: _buildBentoNavTile(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                icon: Icons.favorite_outline,
                title: 'Dar',
                subtitle: 'Ofrendas y donaciones',
                screen: const Ofrendas(),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                minHeight: 148,
                compactText: false,
              ),
            ),
            SizedBox(width: _bentoGap),
            Expanded(
              flex: 42,
              child: _buildBentoNavTile(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                icon: Icons.arrow_forward_outlined,
                title: 'Youth CCI',
                subtitle: 'Próximas generaciones',
                screen: const Youth(),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                minHeight: 112,
                compactText: true,
              ),
            ),
          ],
        ),
        SizedBox(height: _bentoGap),
        _buildBentoNavTile(
          context: context,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          icon: Icons.location_on_outlined,
          title: 'Ubicación',
          subtitle: 'Encuéntranos y visita',
          screen: const Ubicacion(),
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          minHeight: 104,
          featuredAccent: true,
        ),
      ],
    );
  }

  Widget _buildBentoNavTile({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
    required TextStyle titleStyle,
    required TextStyle subtitleStyle,
    double minHeight = 100,
    bool compactText = false,
    bool featuredAccent = false,
  }) {
    final pad = screenWidth * 0.045;
    final titleEffective = compactText
        ? titleStyle.copyWith(fontSize: (titleStyle.fontSize ?? 17) * 0.92)
        : titleStyle;
    final subtitleEffective = compactText
        ? subtitleStyle.copyWith(
            fontSize: (subtitleStyle.fontSize ?? 14) * 0.9,
            height: 1.25,
          )
        : subtitleStyle;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_bentoRadius),
        border: Border.all(
          color: colorWithOpacity(blanco, 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_bentoRadius - 0.5),
        child: Material(
          color: grisCard,
          child: InkWell(
            onTap: () => _navigateToScreen(context, screen),
            splashColor: colorWithOpacity(accent, 0.18),
            highlightColor: colorWithOpacity(blanco, 0.06),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (featuredAccent)
                    Positioned(
                      right: -screenWidth * 0.02,
                      bottom: -screenWidth * 0.06,
                      child: Icon(
                        icon,
                        size: screenWidth * 0.26,
                        color: colorWithOpacity(accent, 0.14),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, pad * 0.95, pad, pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorWithOpacity(accent, 0.28),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: colorWithOpacity(blanco, 0.95),
                            size: 18,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        Text(
                          title,
                          style: titleEffective,
                          maxLines: compactText ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.004),
                        Text(
                          subtitle,
                          style: subtitleEffective,
                          maxLines: compactText ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Efecto blur progresivo: la pantalla anterior se vuelve borrosa
          final blurValue =
              (1 - animation.value) * 15.0; // De 15 (muy borroso) a 0 (claro)

          return Stack(
            children: [
              // Fondo con blur que simula la pantalla anterior borrosa
              if (animation.value < 1.0)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurValue,
                      sigmaY: blurValue,
                    ),
                    child: Container(
                      color: Colors.black.withValues(
                          alpha: (0.3 * (1 - animation.value)).clamp(0.0, 1.0)),
                    ),
                  ),
                ),
              // Nueva pantalla con fade in
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
    );
  }
}
