import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';

class PuertasAbiertas extends StatelessWidget {
  const PuertasAbiertas({super.key});

  static const String _websiteUrl = 'https://puertasabiertashn.org/';

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getHorizontalPadding(screenWidth),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  _buildHeaderWithLogo(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  _buildLocation(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildDescriptionSection(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildProjectsSection(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildImpactSection(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildContactSection(context, screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildWebsiteButton(context, screenWidth),
                  SizedBox(height: screenHeight * 0.08),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const String _logoAsset =
      'assets/images/Fundacion_Puertas_Abiertas.png';

  Widget _buildHeaderWithLogo(double screenWidth) {
    final logoSize = screenWidth * 0.28;
    final titleStyle = getTitulo(screenWidth);
    const titleText = 'Fundación Puertas Abiertas';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: titleStyle,
              ),
              SizedBox(height: screenWidth * 0.04),
              Center(
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    _logoAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.volunteer_activism_outlined,
                      size: logoSize * 0.7,
                      color: colorWithOpacity(blanco, 0.6),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  titleText,
                  style: titleStyle,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            SizedBox(
              width: logoSize,
              height: logoSize,
              child: Image.asset(
                _logoAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.volunteer_activism_outlined,
                  size: logoSize * 0.7,
                  color: colorWithOpacity(blanco, 0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocation(double screenWidth) {
    return Text(
      "San Pedro Sula",
      overflow: TextOverflow.visible,
      style: TextStyle(
        fontFamily: 'SF Pro Display',
        color: grisMedio,
        fontSize: screenWidth < 360 ? 15 : 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
      ),
    );
  }

  Widget _buildDescriptionSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Acerca de la Fundación",
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        Container(
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
          child: Text(
            "Desde 2010, Puertas Abiertas ha servido con amor a familias de "
            "comunidades vulnerables en los alrededores de San Pedro Sula, Honduras. "
            "A través de un acompañamiento integral, trabajamos para transformar vidas, "
            "familia por familia y niño por niño, apoyando el acceso a la educación formal "
            "y sembrando esperanza para su futuro. Creemos que es tiempo de seguir "
            "edificando una infancia y juventud con mayores oportunidades, valores firmes "
            "y un propósito en Dios.",
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: screenWidth < 360 ? 15 : 17,
              height: 1.6,
              color: blanco,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsSection(double screenWidth) {
    final projects = [
      {
        'title': 'Edúcame',
        'desc':
            'Para disminuir la deserción escolar, veintiséis niños son apadrinados cada año, con seguimiento personal hasta que terminan la escuela primaria.',
      },
      {
        'title': 'Cuida mis Pasos',
        'desc':
            'Se enfoca en capacitar a las madres durante el embarazo y hasta los 5 años del niño, guiándolas en cada etapa para desarrollar un bebé saludable.',
      },
      {
        'title': 'Juventud en Desarrollo',
        'desc':
            'Permite a jóvenes de 11 a 18 años insertarse en la sociedad como ciudadanos productivos, con una educación que les permite formar parte del mundo laboral y ser autónomos.',
      },
      {
        'title': 'PIE',
        'desc':
            'Implementa medidas de mejora académica para estudiantes con necesidades, con atención directa mediante metodologías e innovación para maximizar el rendimiento según perfiles y necesidades.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Proyectos",
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        ...projects.map(
            (p) => _buildProjectCard(screenWidth, p['title']!, p['desc']!)),
      ],
    );
  }

  Widget _buildProjectCard(
      double screenWidth, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                color: primario,
                fontSize: screenWidth < 360 ? 17 : 19,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              description,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: screenWidth < 360 ? 14 : 16,
                height: 1.5,
                color: grisMedio,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mira lo que logramos juntos",
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
          "El impacto de cada proyecto durante los últimos 10 años, en la vida de quienes se han beneficiado de un proyecto que apoyamos, va más allá de los números…",
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: grisMedio,
            fontSize: screenWidth < 360 ? 14 : 16,
            height: 1.5,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.0,
          ),
        ),
        SizedBox(height: screenWidth * 0.04),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.06,
            horizontal: screenWidth * 0.04,
          ),
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
              Expanded(
                child: _buildImpactStat(screenWidth, "350+", "Niños atendidos"),
              ),
              Expanded(
                child: _buildImpactStat(
                    screenWidth, "100+", "Familias beneficiadas"),
              ),
              Expanded(
                child: _buildImpactStat(
                    screenWidth, "150+", "Voluntarios involucrados"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactStat(double screenWidth, String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 26 : 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: grisMedio,
            fontSize: screenWidth < 360 ? 12 : 14,
            height: 1.3,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Contacto",
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: blanco,
            fontSize: screenWidth < 360 ? 20 : 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactItem(
                context,
                screenWidth,
                icon: Icons.location_on_outlined,
                label: "Dirección",
                value: "Col. Trejo, 9 calle 21 y 22 Avenida, San Pedro Sula",
                onTap: () => _launchURL(
                    "https://www.google.com/maps/search/?api=1&query=Colonia+Trejo+9+calle+21+22+Avenida+San+Pedro+Sula"),
              ),
              SizedBox(height: screenWidth * 0.04),
              _buildContactItem(
                context,
                screenWidth,
                icon: Icons.phone_outlined,
                label: "Teléfono",
                value: "+504 3298-6426",
                onTap: () => _launchURL("tel:+50432986426"),
              ),
              SizedBox(height: screenWidth * 0.04),
              _buildContactItem(
                context,
                screenWidth,
                icon: Icons.email_outlined,
                label: "Correo electrónico",
                value: "info@puertasabiertashn.org",
                onTap: () => _launchURL("mailto:info@puertasabiertashn.org"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    double screenWidth, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadiusSmall),
        child: Row(
          children: [
            Icon(
              icon,
              color: primario,
              size: 24,
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: grisMedio,
                      fontSize: screenWidth < 360 ? 13 : 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.0,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: blanco,
                      fontSize: screenWidth < 360 ? 15 : 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
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
    );
  }

  Widget _buildWebsiteButton(BuildContext context, double screenWidth) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(_websiteUrl),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.045,
            horizontal: screenWidth * 0.05,
          ),
          decoration: BoxDecoration(
            color: grisCard,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: colorWithOpacity(blanco, 0.1),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language_outlined, color: primario, size: 24),
              SizedBox(width: screenWidth * 0.03),
              Text(
                "Visitar sitio web",
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  color: blanco,
                  fontSize: screenWidth < 360 ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
