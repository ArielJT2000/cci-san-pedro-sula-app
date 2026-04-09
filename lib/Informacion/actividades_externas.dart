import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_icons/simple_icons.dart';
import '../utils/constants.dart';

/// Fila de enlaces Facebook / Instagram / YouTube sobre el fondo de la pantalla (sin tarjeta).
class ChurchSocialLinksCard extends StatelessWidget {
  const ChurchSocialLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActividadesExternas();
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
    final iconSize = (screenWidth * 0.07).clamp(24.0, 32.0);

    return Tooltip(
      message: actividad,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchURL(context),
          customBorder: const CircleBorder(),
          splashColor: colorWithOpacity(accent, 0.2),
          highlightColor: colorWithOpacity(blanco, 0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              _getPlatformIcon(actividad),
              color: blanco,
              size: iconSize,
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
