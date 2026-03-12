import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
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
      height: 43.458,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11.7),
        border: Border.all(color: borderColor, width: 1.671),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 80,
            top: 11.7,
            width: 16.715,
            height: 16.715,
            child: AssetPicture(iconAsset, fit: BoxFit.contain),
          ),
          Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.372,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 20.057 / 13.372,
                letterSpacing: -0.2612,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
