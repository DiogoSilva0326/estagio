import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:flutter/material.dart';

class FaqGradientCircleIcon extends StatelessWidget {
  const FaqGradientCircleIcon({
    super.key,
    required this.size,
    required this.iconSize,
    required this.icon,
  });

  final double size;
  final double iconSize;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: FaqGradients.orangeVertical,
        borderRadius: BorderRadius.circular(FaqDimens.radiusPill),
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: Colors.white),
      ),
    );
  }
}
