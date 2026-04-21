import 'package:flutter/material.dart';

class AreasAlunoMobilePromoCard extends StatelessWidget {
  const AreasAlunoMobilePromoCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    required this.gradient,
    required this.buttonTextColor,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.titleStyle,
    this.descriptionStyle,
    this.buttonHeight = 44,
    this.buttonWidth,
    this.buttonPadding = const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 12,
    ),
    this.buttonBorderRadius = 14,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Gradient gradient;
  final Color buttonTextColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double buttonHeight;
  final double? buttonWidth;
  final EdgeInsetsGeometry buttonPadding;
  final double buttonBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                titleStyle ??
                const TextStyle(
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style:
                descriptionStyle ??
                const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: buttonTextColor,
                  elevation: 0,
                  minimumSize: Size(0, buttonHeight),
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: buttonTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
