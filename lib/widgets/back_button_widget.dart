import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconOnly = text == null || text!.isEmpty;
    final padding = iconOnly
        ? const EdgeInsets.fromLTRB(4, 4, 10, 10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(borderRadiusSmall),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chevron_left_rounded,
                color: primario,
                size: iconOnly ? 32 : 28,
              ),
              if (!iconOnly) ...[
                SizedBox(width: screenWidth * 0.01),
                Text(
                  text!,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    color: primario,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.41,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

