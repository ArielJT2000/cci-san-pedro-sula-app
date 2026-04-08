import 'package:flutter/material.dart';
import '../widgets/ministry_screen_base.dart';
import '../widgets/ministry_events_section.dart';
import '../redes sociales/ig_alive.dart';

class Alive extends StatelessWidget {
  const Alive({super.key});

  @override
  Widget build(BuildContext context) {
    return MinistryScreenBase(
      title: "Alive",
      description:
          "Somos un ministerio que acompaña a adolescentes a descubrir su identidad en Cristo, "
          "con fundamentos bíblicos sólidos y una fe auténtica y firme en su etapa de crecimiento.",
      imagePath: 'assets/images/alive.png',
      additionalInfo:
          "Únete a Alive y sé parte de una comunidad vibrante para jóvenes.",
      socialWidget: const IgAlive('Instagram', visualScale: 0.7),
      informationSection: const MinistryEventsSection(category: 'alive'),
    );
  }
}


