import 'package:flutter/material.dart';
import 'back_button_widget.dart';

/// Botón "Atrás" encima del contenido cuando la pantalla se abre con
/// [Navigator.push] desde Inicio (el [MainNavigation] queda debajo y no se ve).
class PushedScreenBackOverlay extends StatelessWidget {
  final Widget child;

  const PushedScreenBackOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            child: BackButtonWidget(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
