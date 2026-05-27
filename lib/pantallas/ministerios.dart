import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';
import '../redes sociales/ig_alabanza.dart';
import '../redes sociales/ig_alive.dart';
import '../redes sociales/ig_next.dart';
import '../redes sociales/ig_matrimonios.dart';
import '../redes sociales/ig_mujeres.dart';
import '../redes sociales/ig_shift.dart';
import '../redes sociales/fb_hombres.dart';
import '../redes sociales/tiktok_comunicaciones.dart';

class Ministerios extends StatelessWidget {
  const Ministerios({super.key});

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
          physics: const ClampingScrollPhysics(),
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
                _buildMinisteriosList(context, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Text(
      "Ministerios CCI",
      style: getTitulo(screenWidth),
    );
  }

  Widget _buildDescription(double screenWidth) {
    return Text(
      "La comunidad CCI en San Pedro Sula cuenta con diferentes ministerios que "
      "responden a las necesidades y desafíos del creyente en sus diferentes etapas "
      "de vida. Te invitamos a conocerlos para que puedas ser parte!",
      style: TextStyle(
        height: 1.5,
        fontSize: screenWidth < 360 ? 16 : 18,
        color: blanco,
      ),
    );
  }

  static const String _formEbdUrl =
      'https://ccisanpedrosula.org/discipulado-app-cci/';
  static const String _formCciKidsUrl =
      'https://ccisanpedrosula.org/cci-kids-app-cci/';
  static const String _formMovilizacionUrl =
      'https://ccisanpedrosula.org/movilizacion/';
  static const String _formGruposHogarUrl =
      'https://ccisanpedrosula.org/grupos-en-hogar-cci/';
  static const String _formServidoresUrl =
      'https://ccisanpedrosula.org/servidores-cci/';

  static String? _getMinisterioLogoAsset(String ministryKey) {
    switch (ministryKey.toLowerCase()) {
      case 'alabanza':
        return 'assets/images/alabanza.png';
      case 'produccion':
        return 'assets/images/comunicaciones.png';
      case 'alive':
        return 'assets/images/alive.png';
      case 'next':
        return 'assets/images/next.png';
      case 'matrimonios':
        return 'assets/images/matrimonios.png';
      case 'hombres':
        return 'assets/images/hombres.png';
      case 'mujeres':
        return 'assets/images/mujeres.png';
      case 'shift':
        return 'assets/images/shift.png';
      case 'ebd':
        return 'assets/images/ebd.png';
      case 'kids':
        return 'assets/images/kids.png';
      case 'movilizacion':
        return 'assets/images/movilizacion.png';
      case 'hg':
        return 'assets/images/hg.png';
      case 'servidores':
        return 'assets/images/servidores.png';
      default:
        return null;
    }
  }

  /// Proporción del logo: 545 ancho × 249 alto
  static const double _logoDesignWidth = 545.0;
  static const double _logoDesignHeight = 249.0;

  Widget _buildMinisterioLogo(
      String ministryKey, double screenWidth, double screenHeight) {
    final asset = _getMinisterioLogoAsset(ministryKey);
    if (asset == null) return const SizedBox.shrink();
    final maxWidth = screenWidth * 0.88;
    final width = maxWidth.clamp(0.0, _logoDesignWidth);
    final height = width * (_logoDesignHeight / _logoDesignWidth);
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          cacheWidth: 545,
          cacheHeight: 249,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Future<void> _launchEbdUrl(BuildContext context) async {
    final uri = Uri.parse(_formEbdUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se puede abrir el enlace';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo abrir el enlace'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchCciKidsUrl(BuildContext context) async {
    final uri = Uri.parse(_formCciKidsUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se puede abrir el enlace';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo abrir el enlace'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchMovilizacionUrl(BuildContext context) async {
    final uri = Uri.parse(_formMovilizacionUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se puede abrir el enlace';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo abrir el enlace'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchGruposHogarUrl(BuildContext context) async {
    final uri = Uri.parse(_formGruposHogarUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se puede abrir el enlace';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo abrir el enlace'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchServidoresUrl(BuildContext context) async {
    final uri = Uri.parse(_formServidoresUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se puede abrir el enlace';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo abrir el enlace'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildMinisteriosList(
      BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      children: [
        RepaintBoundary(
            child: _buildMinisterioItem(
          "kids",
          "El discipulado de los más pequeños está a cargo de un dinámico y comprometido "
              "equipo de voluntarios sirviendo en las celebraciones dominicales. Nuestros niños "
              "pueden vivir un encuentro con Dios y Su Palabra cada domingo en un ambiente "
              "seguro y divertido.",
          () => _launchCciKidsUrl(context),
          "Conoce más",
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioItem(
          "movilizacion",
          "Llevamos el amor de Dios y predicamos el evangelio de Jesús más allá de las "
              "paredes de la iglesia. En hospitales de la ciudad impactando vidas como un solo cuerpo.",
          () => _launchMovilizacionUrl(context),
          "Conoce más",
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioItem(
          "hg",
          "Somos la iglesia reunida en hogares con el fin de crecer en comunidad, estudiar la "
              "Biblia y apoyarnos mutuamente, mientras construimos amistades significativas, "
              "porque la vida cristiana no está diseñada para vivirse en solitud.",
          () => _launchGruposHogarUrl(context),
          "Conoce más",
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioItem(
          "ebd",
          "Somos un ministerio que orienta las actividades y enseñanzas hacia el evangelismo, "
              "misiones y servicio, discipulando al estilo de Jesús mediante grupos pequeños "
              "de estudio bíblico y relación entre mentor y discípulos.",
          () => _launchEbdUrl(context),
          "Inscríbete al Estudio Bíblico",
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "matrimonios",
          "Ser un ministerio que edifica matrimonios y prepara futuras familias sobre fundamentos bíblicos, "
              "fortaleciendo relaciones saludables, restauradas y centradas en Cristo, desde la etapa prematrimonial "
              "hasta la vida matrimonial.",
          const IgMatrimonios('Instagram'),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "produccion",
          "Ser un ministerio que comunica el mensaje del Evangelio con excelencia y creatividad, "
              "utilizando los medios y la producción audiovisual para apoyar la visión de la iglesia "
              "y facilitar encuentros claros y efectivos con Dios.",
          const TiktokComunicaciones(),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "alabanza",
          "Ser un ministerio entendido de nuestra función como siervos que disciernen "
              "la voluntad de Dios, el mover del Espíritu Santo y que ejercen su sacerdocio "
              "guiando al pueblo a una alabanza y adoración genuina, recordándoles Quién es "
              "Él y lo que ha hecho por nosotros.",
          const IgAlabanza('Instagram'),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "alive",
          "Ser un ministerio que acompaña a adolescentes en el descubrimiento de su identidad en Cristo, "
              "formando fundamentos bíblicos sólidos y guiándolos a vivir una fe auténtica, relevante y firme "
              "en medio de su etapa de crecimiento.",
          const IgAlive('Instagram'),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "next",
          "Ser un ministerio que impulsa a los jóvenes a desarrollar una relación personal con Dios, afirmando "
              "su identidad, propósito y llamado, para que vivan una fe práctica que impacte sus decisiones, "
              "su entorno y su generación.",
          const IgNext('Instagram'),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "hombres",
          "Ser un ministerio que forma hombres conforme al corazón de Dios, afirmando su identidad, responsabilidad "
              "y liderazgo espiritual, para impactar positivamente su hogar, la iglesia y la sociedad.",
          const FbHombres('Facebook'),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "mujeres",
          "Ser un ministerio que impulsa a las mujeres a vivir su identidad en Cristo, desarrollando su "
              "llamado y propósito, para servir, influir y transformar su entorno con fe, amor y acción.",
          const IgMujeres('Instagram'),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioSocialItem(
          "shift",
          "Ser un ministerio que crea espacios de comunidad para jóvenes adultos, donde puedan "
              "crecer espiritualmente, fortalecer su carácter y aplicar los principios bíblicos a la "
              "vida diaria, influyendo de manera intencional en su familia, trabajo y sociedad.",
          const IgShift('Instagram'),
          screenWidth,
          screenHeight,
        )),
        RepaintBoundary(
            child: _buildMinisterioItem(
          "servidores",
          "Creemos que cada persona tiene dones y un propósito. Te invitamos a unirte a uno de "
              "nuestros equipos de servicio y ser parte de lo que Dios está haciendo en CCI.",
          () => _launchServidoresUrl(context),
          "¡Sé parte!",
          screenWidth,
          screenHeight,
        )),
      ],
    );
  }

  Widget _buildMinisterioItem(
    String image,
    String description,
    VoidCallback onTap,
    String buttonText,
    double screenWidth,
    double screenHeight, {
    Widget? socialWidget,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.055),
      child: Column(
        children: [
          _buildMinisterioLogo(image, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.012),
          Text(
            description,
            style: TextStyle(
              color: blanco,
              fontSize: screenWidth < 360 ? 14 : 15,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.015),
          Center(
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: blanco,
                foregroundColor: negro,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.015,
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: negro,
                  fontSize: screenWidth < 360 ? 14 : 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (socialWidget != null) ...[
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [socialWidget],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinisterioSocialItem(
    String image,
    String description,
    Widget socialButton,
    double screenWidth,
    double screenHeight,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.055),
      child: Column(
        children: [
          _buildMinisterioLogo(image, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.012),
          Text(
            description,
            style: TextStyle(
              color: blanco,
              fontSize: screenWidth < 360 ? 14 : 15,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [socialButton],
          ),
        ],
      ),
    );
  }
}
