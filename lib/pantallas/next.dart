import 'package:flutter/material.dart';
import '../widgets/ministry_screen_base.dart';
import '../widgets/ministry_events_section.dart';
import '../redes sociales/ig_next.dart';

class Next extends StatelessWidget {
  const Next({super.key});

  @override
  Widget build(BuildContext context) {
    return MinistryScreenBase(
      title: "Next",
      description:
          "Somos un ministerio que impulsa a los jóvenes a una relación personal con Dios, "
          "afirmando su identidad y propósito, para que su fe impacte sus decisiones, entorno y generación.",
      imagePath: 'assets/images/next.png',
      additionalInfo:
          "Únete a Next y sé parte de una comunidad para jóvenes como tú.",
      socialWidget: const IgNext('Instagram'),
      informationSection: const MinistryEventsSection(category: 'next'),
    );
  }
}
