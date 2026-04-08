import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';
import '../widgets/back_button_widget.dart';

/// Widget base para pantallas de ministerios (Alive, Next, Shift)
/// Reduce código duplicado y mantiene consistencia.
/// Opcionalmente muestra una sección "Información" con eventos (AWS) vía [informationSection].
/// Si [headerWidget] se proporciona, se usa en lugar de [imagePath] (título como texto SF Pro Display).
class MinistryScreenBase extends StatelessWidget {
  final String title;
  final String description;
  /// Ruta de imagen del ministerio; se ignora si [headerWidget] no es null.
  final String? imagePath;
  /// Título del ministerio como widget (texto SF Pro Display). Si no es null, reemplaza la imagen.
  final Widget? headerWidget;
  final String additionalInfo;
  final Widget socialWidget;
  /// Sección opcional (ej. MinistryEventsSection) que se muestra bajo el bloque del ministerio.
  final Widget? informationSection;

  const MinistryScreenBase({
    super.key,
    required this.title,
    required this.description,
    this.imagePath,
    this.headerWidget,
    required this.additionalInfo,
    required this.socialWidget,
    this.informationSection,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SwipeBackWrapper(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getGradientBackground(),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: scrollScreenPadding(
                  context,
                  screenWidth,
                  topExtra: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(screenWidth),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(height: screenHeight * 0.04),
                      _buildDescription(screenWidth),
                      _buildMinistryInfo(screenWidth, screenHeight),
                      if (informationSection != null) ...[
                        SizedBox(height: screenHeight * 0.03),
                        informationSection!,
                      ],
                    SizedBox(height: screenHeight * 0.08),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                bottom: false,
                child: BackButtonWidget(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Text(
      title,
      overflow: TextOverflow.visible,
      style: getTitulo(screenWidth),
    );
  }

  Widget _buildDescription(double screenWidth) {
    return Text(
      description,
      overflow: TextOverflow.visible,
      style: getBodyLargeTextStyle(screenWidth).copyWith(
        height: 1.5,
      ),
    );
  }

  /// Misma proporción y presentación que el logo en Ministerios CCI (545×249).
  static const double _logoDesignWidth = 545.0;
  static const double _logoDesignHeight = 249.0;
  /// Next / Alive / Shift: logos un 30 % más pequeños que la referencia de Ministerios.
  static const double _ministryLogoScale = 0.7;

  Widget _buildLogoLikeMinisterios(double screenWidth) {
    if (imagePath == null) return const SizedBox.shrink();
    final maxWidth = screenWidth * 0.88 * _ministryLogoScale;
    final width = maxWidth.clamp(0.0, _logoDesignWidth);
    final height = width * (_logoDesignHeight / _logoDesignWidth);
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          imagePath!,
          fit: BoxFit.contain,
          cacheWidth: 545,
          cacheHeight: 249,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              color: colorWithOpacity(gris, 0.3),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Icon(
              Icons.people,
              size: screenWidth * 0.2,
              color: colorWithOpacity(blanco, 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinistryInfo(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.055),
      child: Column(
        children: [
          if (headerWidget != null)
            SizedBox(
              width: screenWidth * 0.6,
              height: screenHeight * 0.15,
              child: headerWidget,
            ),
          if (headerWidget == null && imagePath != null)
            _buildLogoLikeMinisterios(screenWidth),
          if (headerWidget == null && imagePath == null)
            Container(
              width: screenWidth * 0.6,
              height: screenHeight * 0.15,
              decoration: BoxDecoration(
                color: colorWithOpacity(gris, 0.3),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                Icons.people,
                size: screenWidth * 0.2,
                color: colorWithOpacity(blanco, 0.5),
              ),
            ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            additionalInfo,
            overflow: TextOverflow.visible,
            style: getBodyTextStyle(screenWidth).copyWith(
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [socialWidget],
          ),
        ],
      ),
    );
  }
}

