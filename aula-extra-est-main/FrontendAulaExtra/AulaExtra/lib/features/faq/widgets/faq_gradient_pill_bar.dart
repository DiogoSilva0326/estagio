import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:flutter/material.dart';

class FaqGradientPillBar extends StatelessWidget {
  const FaqGradientPillBar({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: FaqGradients.orangeVertical,
        borderRadius: BorderRadius.circular(FaqDimens.radiusPill),
      ),
    );
  }
}
