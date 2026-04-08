import 'package:flutter/material.dart';
import '../utils/social_link.dart';

/// TikTok del ministerio de Comunicaciones (CCI Media).
class TiktokComunicaciones extends StatelessWidget {
  const TiktokComunicaciones({super.key});

  static const String _url =
      'https://www.tiktok.com/@ccimedia?_r=1&_t=ZS-95LgpbllbWf';

  @override
  Widget build(BuildContext context) {
    return const SocialLink(
      socialId: '@ccimedia',
      url: _url,
      platform: 'TikTok',
      label: 'Síguenos en TikTok',
    );
  }
}
