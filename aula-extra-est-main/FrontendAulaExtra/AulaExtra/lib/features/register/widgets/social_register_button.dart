import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:flutter/material.dart';

class SocialRegisterButton extends StatelessWidget {
  const SocialRegisterButton({
    super.key,
    required this.text,
    required this.iconAsset,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String text;
  final String iconAsset;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43.469,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11.703),
        border: Border.all(color: borderColor, width: 1.672),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 80,
            top: 11.7,
            width: 16.719,
            height: 16.719,
            child: AssetPicture(iconAsset, fit: BoxFit.contain),
          ),
          Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.375,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 20.063 / 13.375,
                letterSpacing: -0.2612,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
