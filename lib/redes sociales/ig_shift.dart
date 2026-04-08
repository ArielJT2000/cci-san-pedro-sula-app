import 'package:flutter/material.dart';
import '../utils/social_link.dart';
// import '../widgets/social_link.dart';

class IgShift extends StatelessWidget {
  final String socialId;
  final double visualScale;
  const IgShift(this.socialId, {super.key, this.visualScale = 1.0});

  @override
  Widget build(BuildContext context) {
    return SocialLink(
      socialId: socialId,
      url: 'https://www.instagram.com/shiftcci_/',
      platform: 'Instagram',
      visualScale: visualScale,
    );
  }
}
