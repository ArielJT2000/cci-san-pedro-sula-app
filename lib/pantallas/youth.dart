import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';
import 'next.dart';
import 'alive.dart';
import 'shift.dart';

/// Datos de cada ministerio Youth para la pila de cartas.
class _YouthCardData {
  final String title;
  final String subtitle;
  final Color color;
  final Widget screen;

  const _YouthCardData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screen,
  });
}

class Youth extends StatefulWidget {
  const Youth({super.key});

  @override
  State<Youth> createState() => _YouthState();
}

class _YouthState extends State<Youth> with TickerProviderStateMixin {
  /// Altura de carta y solapado; valores algo menores para evitar overflow en pantallas pequeñas.
  static const double _cardHeight = 200;
  static const double _overlap = 52;
  static const double _borderRadius = 24;

  /// Orden de la pila: índice 0 = carta superior (frente), 1 = medio, 2 = atrás.
  late List<_YouthCardData> _stackOrder;

  /// Desplazamiento al arrastrar la carta superior (cualquier dirección).
  Offset _dragOffset = Offset.zero;

  /// Progreso del arrastre (0..1) al soltar; las cartas de atrás completan el movimiento durante el dismiss.
  double _dragProgressAtRelease = 0.0;

  /// Animación de descarte: vuela en la dirección del gesto con escala y fade.
  bool _isAnimatingDismiss = false;
  late AnimationController _dismissController;
  late Animation<Offset> _dismissOffsetAnim;
  late Animation<double> _dismissScaleAnim;


  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _dismissOffsetAnim =
        Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
    );
    _dismissScaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
    );
    _dismissController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        HapticFeedback.mediumImpact();
        _onDismissTop();
        setState(() {
          _dragOffset = Offset.zero;
          _isAnimatingDismiss = false;
          _dragProgressAtRelease = 0.0;
        });
        _dismissController.reset();
      }
    });

    _stackOrder = [
      const _YouthCardData(
        title: 'Shift',
        subtitle: '26+ años',
        color: Color(0xFFD9B8F3), // Purple
        screen: Shift(),
      ),
      const _YouthCardData(
        title: 'Next',
        subtitle: '18 - 25 años',
        color: Color(0xFFDFF37D), // Old flax
        screen: Next(),
      ),
      const _YouthCardData(
        title: 'Alive',
        subtitle: '12 - 17 años',
        color: Color(0xFFB8D4E8), // Azul claro
        screen: Alive(),
      ),
    ];
  }

  double get _stackHeight => _cardHeight + 2 * _overlap;

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  void _onDismissTop() {
    setState(() {
      final first = _stackOrder.removeAt(0);
      _stackOrder.add(first);
      _dragOffset = Offset.zero;
    });
  }

  void _startDismissAnimation() {
    final d = _dragOffset.distance;
    if (d < 20) return;
    _dragProgressAtRelease = (d / 100.0).clamp(0.0, 1.0);
    final dir = Offset(_dragOffset.dx / d, _dragOffset.dy / d);
    const extent = 260.0;
    final end = Offset(dir.dx * extent, dir.dy * extent);
    _dismissOffsetAnim = Tween<Offset>(begin: _dragOffset, end: end).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
    );
    setState(() => _isAnimatingDismiss = true);
    _dismissController.forward(from: 0);
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                          alpha: (0.3 * (1 - animation.value)).clamp(0.0, 1.0)),
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
    );
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getHorizontalPadding(screenWidth),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.012),
                _buildHeader(screenWidth),
                SizedBox(height: screenHeight * 0.008),
                SizedBox(height: screenHeight * 0.016),
                _buildDescription(screenWidth),
                SizedBox(height: screenHeight * 0.012),
                _buildLogosRow(screenWidth),
                SizedBox(height: screenHeight * 0.01),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const bottomPad = 20.0;
                      final maxStackH = (constraints.maxHeight - bottomPad).clamp(180.0, _stackHeight);
                      final scale = maxStackH / _stackHeight;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildStackedCards(context, screenWidth, scale),
                          SizedBox(height: bottomPad),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Text(
      "Youth CCI",
      overflow: TextOverflow.visible,
      style: getTitulo(screenWidth),
    );
  }

  Widget _buildDescription(double screenWidth) {
    return Text(
      "Conoce nuestros ministerios para jóvenes y elige el que mejor se adapte a ti.",
      overflow: TextOverflow.visible,
      style: TextStyle(
        height: 1.5,
        fontSize: screenWidth < 360 ? 16 : 18,
        color: blanco,
      ),
    );
  }

  Widget _buildLogosRow(double screenWidth) {
    const double logoHeight = 88;
    final maxLogoWidth = (screenWidth - getHorizontalPadding(screenWidth) * 2) * 0.45;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: SizedBox(
                height: logoHeight,
                child: Image.asset(
                  'assets/images/alive.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: SizedBox(
                height: logoHeight,
                child: Image.asset(
                  'assets/images/next.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: logoHeight * 0.12),
        Center(
          child: SizedBox(
            width: maxLogoWidth.clamp(80.0, 200.0),
            height: logoHeight,
            child: Image.asset(
              'assets/images/shift.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedCards(BuildContext context, double screenWidth, [double scale = 1.0]) {
    final h = _stackHeight * scale;
    final cardH = _cardHeight * scale;
    final ov = _overlap * scale;
    return SizedBox(
      height: h,
      child: AnimatedBuilder(
        animation: _dismissController,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = _stackOrder.length - 1; i >= 0; i--)
                _buildStackCard(context, screenWidth, i, cardHeight: cardH, overlap: ov),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStackCard(BuildContext context, double screenWidth, int index, {double? cardHeight, double? overlap}) {
    final ch = cardHeight ?? _cardHeight;
    final ov = overlap ?? _overlap;
    final data = _stackOrder[index];
    final isTop = index == 0;
    final baseTop = (_stackOrder.length - 1 - index) * ov;
    final double topPosition;
    double cardOpacity = 1.0;
    if (index == 0) {
      topPosition = baseTop;
    } else {
      double progress;
      if (_isAnimatingDismiss) {
        progress = _dragProgressAtRelease + (1.0 - _dragProgressAtRelease) * _dismissController.value;
      } else {
        progress = (_dragOffset.distance / 100.0).clamp(0.0, 1.0);
      }
      if (index == 1) {
        topPosition = ov * (1 + progress);
      } else {
        topPosition = ov * progress;
      }
    }

    Widget cardContent = _buildCardContent(data, screenWidth);

    cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToScreen(context, data.screen),
        borderRadius: BorderRadius.circular(_borderRadius),
        child: cardContent,
      ),
    );

    if (isTop) {
      cardContent = GestureDetector(
        onPanUpdate: (details) {
          if (_isAnimatingDismiss) return;
          setState(() {
            _dragOffset += details.delta;
            const limit = 280.0;
            final d = _dragOffset.distance;
            if (d > limit)
              _dragOffset = Offset(
                  _dragOffset.dx * limit / d, _dragOffset.dy * limit / d);
          });
        },
        onPanEnd: (details) {
          if (_isAnimatingDismiss) return;
          const threshold = 55.0;
          final velocity = details.velocity.pixelsPerSecond;
          final speed = velocity.distance;
          final distance = _dragOffset.distance;
          if (distance > threshold || speed > 180) {
            _startDismissAnimation();
          } else {
            setState(() => _dragOffset = Offset.zero);
          }
        },
        child: AnimatedBuilder(
          animation: _dismissController,
          builder: (context, child) {
            final offset =
                _isAnimatingDismiss ? _dismissOffsetAnim.value : _dragOffset;
            final scale = _isAnimatingDismiss ? _dismissScaleAnim.value : 1.0;
            final opacity = _isAnimatingDismiss
                ? (1.0 - _dismissController.value).clamp(0.0, 1.0)
                : 1.0;
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translateByDouble(offset.dx, offset.dy, 0.0, 1.0)
                  ..scaleByDouble(scale, scale, scale, 1.0),
                child: child,
              ),
            );
          },
          child: cardContent,
        ),
      );
    }

    if (cardOpacity < 1.0) {
      cardContent = Opacity(opacity: cardOpacity.clamp(0.0, 1.0), child: cardContent);
    }
    if (ch < _cardHeight) {
      cardContent = Transform.scale(
        alignment: Alignment.topCenter,
        scale: ch / _cardHeight,
        child: cardContent,
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      top: topPosition,
      height: ch,
      child: cardContent,
    );
  }

  static String? _youthLogoAsset(String title) {
    switch (title) {
      case 'Alive':
        return 'assets/images/alive.png';
      case 'Next':
        return 'assets/images/next.png';
      case 'Shift':
        return 'assets/images/shift.png';
      default:
        return null;
    }
  }

  Widget _buildCardContent(_YouthCardData data, double screenWidth) {
    final isLight = _isLightColor(data.color);
    final titleColor = isLight ? const Color(0xFF1C1C1E) : blanco;
    final chipBorder = isLight ? const Color(0xFF3A3A3C) : blanco;
    final chipTextColor = isLight ? const Color(0xFF3A3A3C) : blanco;
    final chipBg = isLight
        ? Colors.white.withValues(alpha: 0.7)
        : blanco.withValues(alpha: 0.25);
    final logoAsset = _youthLogoAsset(data.title);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: screenWidth * 0.055,
        right: screenWidth * 0.055,
        top: screenWidth * 0.028,
        bottom: screenWidth * 0.055,
      ),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (logoAsset != null)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              if (logoAsset != null) SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: screenWidth < 360 ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFF2C2C2E)
                      : blanco.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: blanco,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.035),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.038,
              vertical: screenWidth * 0.022,
            ),
            decoration: BoxDecoration(
              color: chipBg,
              border: Border.all(color: chipBorder, width: 1.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              data.subtitle,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: screenWidth < 360 ? 12 : 13,
                fontWeight: FontWeight.w500,
                color: chipTextColor,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }
}
