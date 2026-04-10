import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';
import '../widgets/pushed_screen_back_overlay.dart';
import 'eventos.dart';
import 'iglesia.dart';
import 'ministerios.dart';
import 'puertas_abiertas.dart';
import 'transmisiones.dart';
import 'ofrendas.dart';
import 'youth.dart';
import 'ubicacion.dart';
import '../Informacion/actividades_externas.dart';

/// Solo el logo del encabezado (~−30 % respecto a 0.20 del ancho); el rótulo CCI conserva el tamaño de cuerpo estándar.
const double _kInicioLogoScale = 0.7;

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _headerLogoController;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _cciEnterSlide;
  late Animation<Offset> _logoEnterSlide;
  late Animation<double> _logoEnterFade;
  late Animation<double> _logoEnterScale;
  bool _headerLogoRevealStarted = false;

  void _onTextProgressForLogo() {
    if (_headerLogoRevealStarted || !mounted) return;
    if (_textAnimationController.value >= 0.5) {
      _headerLogoRevealStarted = true;
      _headerLogoController.forward();
    }
  }

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

    _cciEnterSlide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _headerLogoController = AnimationController(
      duration: const Duration(milliseconds: 720),
      vsync: this,
    );

    _logoEnterSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerLogoController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _logoEnterFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerLogoController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    _logoEnterScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerLogoController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textAnimationController.addListener(_onTextProgressForLogo);

    // Pausa breve tras montar (la bienvenida oculta el logo antes del push; sin Hero a Inicio).
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _heroAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _textAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _textAnimationController.removeListener(_onTextProgressForLogo);
    _heroAnimationController.dispose();
    _textAnimationController.dispose();
    _headerLogoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final logoL = screenWidth * 0.20 * _kInicioLogoScale;

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.008),
                          child: SlideTransition(
                            position: _cciEnterSlide,
                            child: AnimatedBuilder(
                              animation: _textOpacityAnimation,
                              builder: (context, child) {
                                return ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor:
                                        _textOpacityAnimation.value,
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
                                          color: grisMedio,
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
                                          color: grisMedio,
                                          fontSize: getFontSizeBodySmall(
                                              screenWidth),
                                          fontWeight: fontWeightBold,
                                          letterSpacing: letterSpacingWider,
                                          height: lineHeightNormal,
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
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    FadeTransition(
                      opacity: _logoEnterFade,
                      child: SlideTransition(
                        position: _logoEnterSlide,
                        child: ScaleTransition(
                          scale: _logoEnterScale,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/Logo CCI SPS_Globo Gris Oscuro.png',
                            width: logoL,
                            height: logoL,
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
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.018),
                _buildHeroSection(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.03),
                _buildMenuGrid(context, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.06),
                const ChurchSocialLinksCard(),
                SizedBox(height: screenHeight * 0.06),
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
          icon: Icons.church_outlined,
          title: 'Seamos Iglesia',
          subtitle: 'Conoce más sobre nosotros',
          screen: const Iglesia(),
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          minHeight: 108,
          featuredAccent: true,
        ),
        SizedBox(height: _bentoGap),
        // Segunda fila: En vivo y Contribuir como botones pequeños
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBentoNavTile(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                icon: Icons.live_tv_outlined,
                title: 'En vivo',
                subtitle: 'Transmisiones en vivo',
                screen: const Transmisiones(),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                minHeight: 112,
                compactText: true,
              ),
            ),
            SizedBox(width: _bentoGap),
            Expanded(
              child: _buildBentoNavTile(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                icon: Icons.favorite_outline,
                title: 'Contribuir',
                subtitle: 'Apoya la obra y expande el mensaje',
                screen: const Ofrendas(),
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
          icon: Icons.people_outline,
          title: 'Ministerios CCI',
          subtitle: 'Nuestros ministerios',
          screen: const Ministerios(),
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          minHeight: 108,
          featuredAccent: true,
        ),
        SizedBox(height: _bentoGap),
        // Eventos como botón pequeño
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBentoNavTile(
                context: context,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                icon: Icons.calendar_today_outlined,
                title: 'Eventos',
                subtitle: 'Próximas actividades',
                screen: const Eventos(),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                minHeight: 112,
                compactText: true,
              ),
            ),
            SizedBox(width: _bentoGap),
            Expanded(
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
          icon: Icons.volunteer_activism_outlined,
          title: 'Fundación Puertas Abiertas',
          subtitle: 'Conoce más sobre nuestra fundación',
          screen: const PuertasAbiertas(),
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          minHeight: 108,
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
        pageBuilder: (context, animation, secondaryAnimation) =>
            PushedScreenBackOverlay(child: screen),
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
