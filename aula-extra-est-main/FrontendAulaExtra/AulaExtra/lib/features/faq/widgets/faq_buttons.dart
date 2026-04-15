import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:flutter/material.dart';

class FaqGradientButton extends StatelessWidget {
  const FaqGradientButton({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    this.onTap,
  });

  final double width;
  final double height;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: FaqGradients.orangeVertical,
              borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20.417,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FaqGradientIconButton extends StatelessWidget {
  const FaqGradientIconButton({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final double width;
  final double height;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FaqDimens.radiusButton),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: FaqGradients.orangeVertical,
              borderRadius: BorderRadius.circular(FaqDimens.radiusButton),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 25.522, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20.417,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FaqOutlinedButton extends StatelessWidget {
  const FaqOutlinedButton({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    this.onTap,
  });

  final double width;
  final double height;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FaqDimens.radiusButton),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(FaqDimens.radiusButton),
              border: Border.all(
                color: FaqColors.borderDefault,
                width: FaqDimens.borderThick,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20.417,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: FaqColors.textButtonSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
