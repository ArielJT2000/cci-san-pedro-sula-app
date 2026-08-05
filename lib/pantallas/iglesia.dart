import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';
import 'red_cci.dart';

class Iglesia extends StatelessWidget {
  const Iglesia({super.key});

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
                _buildIntroText(screenWidth),
                _buildVisionMisionSection(screenWidth),
                _buildPastoresSection(screenWidth, screenHeight),
                _buildRedCCISection(context, screenWidth, screenHeight),
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
      "Seamos Iglesia",
      style: getTitulo(screenWidth),
    );
  }

  Widget _buildIntroText(double screenWidth) {
    return Text(
      "Ser comunidad es fundamental para crecer juntos y fortalecernos. "
      "Cuando nos unimos como comunidad, podemos compartir nuestras experiencias, "
      "conocimientos y habilidades, lo que nos permite aprender unos de otros y crecer juntos.",
      style: TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: screenWidth < 360 ? 15 : 17,
        height: 1.6,
        color: grisMedio,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
      ),
    );
  }

  Widget _buildVisionMisionSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MisionSection(),
        SizedBox(height: screenWidth * 0.06),
        const _VisionSection(),
      ],
    );
  }

  Widget _buildPastoresSection(double screenWidth, double screenHeight) {
    const generales = ['mario', 'karla'];
    const cuerpoPastoral = [
      'enrique',
      'juanramon',
      'rosa',
      'juanca',
      'kensy',
      'nelson',
      'cinthia',
      'karlita',
    ];

    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.04),
          _buildPastoresListSegment(
            context: context,
            title: 'Pastores Generales',
            pastorKeys: generales,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
          SizedBox(height: screenHeight * 0.04),
          _buildPastoresListSegment(
            context: context,
            title: 'Cuerpo Pastoral',
            pastorKeys: cuerpoPastoral,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildPastoresListSegment({
    required BuildContext context,
    required String title,
    required List<String> pastorKeys,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenHeight * 0.025),
        SizedBox(
          height: screenHeight * 0.15,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: pastorKeys.length,
            itemBuilder: (context, index) {
              return _PastorImage(
                pastorKeys[index],
                screenWidth,
                screenHeight,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRedCCISection(
      BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.04),
        Text(
          "Red CCI",
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToRedCCI(context),
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: grisCard,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: colorWithOpacity(blanco, 0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorWithOpacity(blanco, 0.1),
                      borderRadius: BorderRadius.circular(borderRadiusSmall),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.language_outlined,
                          color: blanco,
                          size: 28,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Conoce más sobre la Red CCI",
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            color: blanco,
                            fontSize: screenWidth < 360 ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.41,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.006),
                        Text(
                          "Somos parte de una red internacional",
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            color: grisMedio,
                            fontSize: screenWidth < 360 ? 13 : 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.24,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: grisMedio,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToRedCCI(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RedCCI(),
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
}

class _MisionSection extends StatelessWidget {
  const _MisionSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenWidth * 0.04),
        Text(
          "Misión",
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          "Formar discípulos de Cristo comprometidos con la restauración integral de las familias en el mundo.",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: grisMedio,
            fontSize: screenWidth < 360 ? 15 : 17,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.0,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _VisionSection extends StatelessWidget {
  const _VisionSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Visión",
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          "Ser una iglesia comprometida con la transformación de vidas, que refleja el evangelio de Jesús en nuestra comunidad, la nación y el mundo. ",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: grisMedio,
            fontSize: screenWidth < 360 ? 15 : 17,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.0,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _PastorImage extends StatelessWidget {
  final String name;
  final double screenWidth;
  final double screenHeight;

  const _PastorImage(this.name, this.screenWidth, this.screenHeight);

  static final Map<String, Map<String, String>> _pastorInfo = {
    "mario": {
      "nombre": "Mario Valencia",
      "titulo": "Pastor General",
      "info": "Lidera la visión y misión general de CCI San Pedro Sula, enfocado en la restauración "
          "de las familias y la formación de discípulos misionales, guiando a la iglesia conforme "
          "al propósito de Dios.",
    },
    "karla": {
      "nombre": "Karla de Valencia",
      "titulo": "Pastora General",
      "info": "Lidera junto a su esposo Mario Valencia la visión y misión general de CCI San Pedro Sula, "
          "con un enfoque en el discipulado, la familia y el desarrollo del liderazgo ministerial, "
          "aportando dirección y acompañamiento pastoral.",
    },
    "juanramon": {
      "nombre": "Juan Ramón Tábora",
      "titulo": "Pastor Titular",
      "info":
          "Pastor titular del servicio de las 9:00 A.M. junto a su esposa Rosa de Tábora. "
              "Dedicado a la enseñanza de la Palabra y la pastoral de familias.",
    },
    "rosa": {
      "nombre": "Rosa de Tábora",
      "titulo": "Pastora Adjunta",
      "info": "Pastora adjunta del servicio de las 9:00 A.M. "
          "Con un corazón por la adoración y el acompañamiento pastoral.",
    },
    "juanca": {
      "nombre": "Juan Carlos Vallecillo",
      "titulo": "Pastor Titular",
      "info":
          "Pastor titular del servicio de las 11:30 A.M. junto a su esposa Kensy de Vallecillo. "
              "Enfocado en la predicación y el crecimiento de la congregación.",
    },
    "kensy": {
      "nombre": "Kensy de Vallecillo",
      "titulo": "Pastora Adjunta",
      "info": "Pastora adjunta del servicio de las 11:30 A.M. "
          "Comprometida con la formación espiritual y el cuidado de las familias.",
    },
    "enrique": {
      "nombre": "Enrique Zaldivar",
      "titulo": "Pastor Titular",
      "info": "Lidera los ministerios de alabanza y comunicaciones. "
          "A cargo de la alabanza, los medios y la transmisión de los servicios.",
    },
    "nelson": {
      "nombre": "Nelson López",
      "titulo": "Pastor Adjunto",
      "info": "Pastor de la Celebración de Oración de los miércoles junto a su esposa Cynthia de López. "
          "Acompaña la vida pastoral de la iglesia y el cuidado de las familias.",
    },
    "cinthia": {
      "nombre": "Cynthia de López",
      "titulo": "Pastora Adjunta",
      "info": "Pastora de la Celebración de Oración de los miércoles junto a su esposo Nelson López. "
          "Sirve en el acompañamiento pastoral y el cuidado de las familias de CCI San Pedro Sula.",
    },
    "karlita": {
      "nombre": "Karla Valencia",
      "titulo": "Pastora Adjunta",
      "info": "Pastora de jóvenes de los ministerios Next, Alive y Shift. "
          "Se dedica al cuidado y la formación de los jóvenes de nuestra iglesia.",
    },
  };

  @override
  Widget build(BuildContext context) {
    final double size = screenHeight * 0.13;
    return GestureDetector(
      onTap: () => _showPastorInfo(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 7.6),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorWithOpacity(blanco, 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          clipBehavior: Clip.hardEdge,
          child: ColoredBox(
            color: negro,
            child: Transform.scale(
              scale: 1.06,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/$name.png",
                fit: BoxFit.cover,
                width: size,
                height: size,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: screenHeight * 0.08,
                    color: colorWithOpacity(blanco, 0.5),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPastorInfo(BuildContext context) {
    final info = _pastorInfo[name];
    if (info == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => _PastorInfoDialog(
        nombre: info["nombre"]!,
        titulo: info["titulo"]!,
        info: info["info"],
        imagePath: "assets/images/$name.png",
      ),
    );
  }
}

class _PastorInfoDialog extends StatelessWidget {
  final String nombre;
  final String titulo;
  final String? info;
  final String imagePath;

  const _PastorInfoDialog({
    required this.nombre,
    required this.titulo,
    this.info,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Glass más transparente (~30% menos opacidad) + más blur.
    const glassBlur = 28.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      alignment: Alignment.center,
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadiusLarge),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 0.8,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.025),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: blanco),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Container(
                      width: screenWidth * 0.55,
                      height: screenHeight * 0.22,
                      decoration: BoxDecoration(
                        color: colorWithOpacity(negro, 0.18),
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: colorWithOpacity(blanco, 0.06),
                          width: 0.5,
                        ),
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: screenHeight * 0.1,
                            color: colorWithOpacity(blanco, 0.5),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    color: blanco,
                    fontSize: screenWidth < 360 ? 20 : 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    color: grisMedio,
                    fontSize: screenWidth < 360 ? 16 : 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.0,
                    height: 1.4,
                  ),
                ),
                if (info != null && info!.isNotEmpty) ...[
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    info!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: grisMedio,
                      fontSize: screenWidth < 360 ? 14 : 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.0,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
