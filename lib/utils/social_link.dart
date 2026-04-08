import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_icons/simple_icons.dart';
import 'constants.dart';

class SocialLink extends StatelessWidget {
  final String socialId;
  final String url;
  final String platform;
  /// 1.0 por defecto; p. ej. 0.7 para icono y texto un 30 % más pequeños.
  final double visualScale;
  /// Si es null, se usa el texto por defecto ("Conoce más de nosotros!").
  final String? label;

  const SocialLink({
    required this.socialId,
    required this.url,
    required this.platform,
    this.visualScale = 1.0,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final s = visualScale;

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02 * s),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchURL(context),
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04 * s,
              vertical: screenWidth * 0.02 * s,
            ),
            decoration: BoxDecoration(
              color: colorWithOpacity(blanco, 0.1),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: colorWithOpacity(blanco, 0.3)),
              boxShadow: defaultShadow,
            ),
            child: Tooltip(
              message: '$platform: $socialId',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getPlatformIcon(platform),
                    color: blanco,
                    size: (screenWidth < 360 ? 18 : 20) * s,
                  ),
                  SizedBox(width: screenWidth * 0.02 * s),
                  Text(
                    label ?? 'Conoce más de nosotros!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blanco,
                      fontSize: (screenWidth < 360 ? 14 : 16) * s,
                      fontWeight: FontWeight.w500,
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
      case 'tiktok':
        return SimpleIcons.tiktok;
      default:
        return Icons.link;
    }
  }

  Future<void> _launchURL(BuildContext context) async {
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'No se puede abrir $platform';
      }
    } catch (e) {
      debugPrint('Error al abrir $platform: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir $platform'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
