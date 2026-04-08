import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_icons/simple_icons.dart';
import '../utils/constants.dart';

/// Tarjeta con título + botones Facebook / Instagram / YouTube (mismo diseño que en Eventos).
class ChurchSocialLinksCard extends StatelessWidget {
  const ChurchSocialLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
            'CCI San Pedro Sula',
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              color: blanco,
              fontSize: screenWidth < 360 ? 20 : 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          const ActividadesExternas(),
        ],
      ),
    );
  }
}

class ActividadesExternas extends StatelessWidget {
  const ActividadesExternas({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Externa('Facebook'),
        Externa('Instagram'),
        Externa('YouTube'),
      ],
    );
  }
}

class Externa extends StatelessWidget {
  final String actividad;
  const Externa(this.actividad, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.16).clamp(44.0, 64.0);

    return Tooltip(
      message: actividad,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchURL(context),
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorWithOpacity(blanco, 0.05),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: colorWithOpacity(blanco, 0.1),
                width: 0.5,
              ),
            ),
            child: Icon(
              _getPlatformIcon(actividad),
              color: blanco,
              size: (screenWidth < 360 ? 20 : 22),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return SimpleIcons.instagram;
      case 'facebook':
        return SimpleIcons.facebook;
      case 'youtube':
        return SimpleIcons.youtube;
      case 'whatsapp':
        return Icons.chat;
      default:
        return Icons.link;
    }
  }

  Future<void> _launchURL(BuildContext context) async {
    String url = '';
    switch (actividad.toLowerCase()) {
      case 'facebook':
        url = 'https://facebook.com/ccisanpedrosula';
        break;
      case 'instagram':
        url = 'https://instagram.com/ccisanpedrosula';
        break;
      case 'youtube':
        url = 'https://youtube.com/ccisanpedrosula';
        break;
      default:
        url = 'https://ccisanpedrosula.com';
    }

    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'No se puede abrir $actividad';
      }
    } catch (e) {
      debugPrint('Error al abrir $actividad: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir $actividad'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
