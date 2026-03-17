import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Título de ministerio como texto (SF Pro Display), reemplazo de imágenes.
/// Todos mismo tamaño y bold. Clave 'produccion' se muestra como "Comunicaciones".
class MinistryTitleText extends StatelessWidget {
  final String ministryKey;
  final double? width;
  final double? height;
  final double fontSize;

  const MinistryTitleText({
    super.key,
    required this.ministryKey,
    this.width,
    this.height,
    this.fontSize = 32,
  });

  static const String _fontFamily = 'SF Pro Display';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: _buildContent(context),
      ),
    );
  }

  TextStyle _style(
    double size, {
    FontWeight weight = FontWeight.w400,
    double letterSpacing = -0.5,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      color: blanco,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  Widget _centeredText(String text, TextStyle style) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth < 360 ? fontSize * 0.85 : fontSize;
    final titleStyle = _style(size, weight: FontWeight.w700);

    switch (ministryKey.toLowerCase()) {
      case 'alabanza':
        return _centeredText('ALABANZA', titleStyle);

      case 'produccion':
        return _centeredText('COMUNICACIONES', titleStyle);

      case 'alive':
        return _centeredText('ALIVE', titleStyle);
      case 'next':
        return _centeredText('NEXT', titleStyle);
      case 'shift':
        return _centeredText('SHIFT', titleStyle);
      case 'matrimonios':
        return _centeredText('MATRIMONIOS', titleStyle);
      case 'hombres':
        return _centeredText('HOMBRES DE VERDAD', titleStyle);
      case 'mujeres':
        return _centeredText('MUJERES EN ACCIÓN', titleStyle);
      default:
        return _centeredText(ministryKey.toUpperCase(), titleStyle);
    }
  }
}
