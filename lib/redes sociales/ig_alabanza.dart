import 'package:flutter/material.dart';
import '../utils/social_link.dart';

class IgAlabanza extends StatelessWidget {
  final String socialId;
  const IgAlabanza(this.socialId, {super.key});

  @override
  Widget build(BuildContext context) {
    return SocialLink(
      socialId: socialId,
      url: 'https://www.instagram.com/ccipraise/',
      platform: 'Instagram',
    );
  }
}
