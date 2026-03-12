import 'package:flutter/material.dart';

class AreasFilterChip extends StatelessWidget {
  const AreasFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.width,
    this.height = 58.085,
    this.horizontalPadding = 28,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final double horizontalPadding;

  static const _orangeStart = Color(0xFFFF6B00);
  static const _orangeEnd = Color(0xFFFF9966);

  @override
  Widget build(BuildContext context) {
    final decoration = selected
        ? const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_orangeStart, _orangeEnd],
            ),
            borderRadius: BorderRadius.all(Radius.circular(9999)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                offset: Offset(0, 5.532),
                blurRadius: 8.298,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                offset: Offset(0, 2.766),
                blurRadius: 5.532,
              ),
            ],
          )
        : BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.383),
            borderRadius: const BorderRadius.all(Radius.circular(9999)),
          );

    final textStyle = TextStyle(
      fontSize: 22.128,
      fontWeight: FontWeight.w400,
      color: selected ? Colors.white : const Color(0xFF364153),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(label, style: textStyle, textAlign: TextAlign.center),
      ),
    );
  }
}
