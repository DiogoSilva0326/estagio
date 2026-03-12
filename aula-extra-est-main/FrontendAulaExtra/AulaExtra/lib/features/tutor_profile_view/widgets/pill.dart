import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    this.dense = false,
  });

  final String text;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final double height = dense ? 40.851 : 51.064;
    final EdgeInsets padding = dense
        ? const EdgeInsets.symmetric(horizontal: 15.319)
        : const EdgeInsets.symmetric(horizontal: 20.426);
    final double fontSize = dense ? 17.872 : 20.426;
    final double lineHeight = dense ? (25.532 / 17.872) : (30.638 / 20.426);

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.766),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              height: lineHeight,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF364153),
            ),
          ),
        ),
      ),
    );
  }
}
