import 'package:flutter/material.dart';
import '../widgets/ministry_screen_base.dart';
import '../widgets/ministry_events_section.dart';
import '../redes sociales/ig_shift.dart';

class Shift extends StatelessWidget {
  const Shift({super.key});

  @override
  Widget build(BuildContext context) {
    return MinistryScreenBase(
      title: "Shift",
      description:
          "Somos un ministerio que crea espacios de comunidad para jóvenes adultos, "
          "donde crecen espiritualmente y aplican principios bíblicos en la vida diaria, influyendo en familia, trabajo y sociedad.",
      imagePath: 'assets/images/shift.png',
      additionalInfo:
          "Únete a Shift y sé parte de un ministerio para jóvenes adultos.",
      socialWidget: const IgShift('Instagram', visualScale: 0.7),
      informationSection: const MinistryEventsSection(category: 'shift'),
    );
  }
}

