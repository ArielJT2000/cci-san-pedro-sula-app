import 'package:flutter/material.dart';
// import '../widgets/social_link.dart';
import '../utils/social_link.dart';

class IgAlive extends StatelessWidget {
  final String socialId;
  final double visualScale;
  const IgAlive(this.socialId, {super.key, this.visualScale = 1.0});

  @override
  Widget build(BuildContext context) {
    return SocialLink(
      socialId: socialId,
      url: 'https://www.instagram.com/alive.cci',
      platform: 'Instagram',
      visualScale: visualScale,
    );
  }
}
