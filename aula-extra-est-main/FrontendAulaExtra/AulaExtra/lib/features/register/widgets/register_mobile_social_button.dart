import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/register/constants/register_mobile_layout.dart';
import 'package:flutter/material.dart';

class RegisterMobileSocialButton extends StatelessWidget {
  const RegisterMobileSocialButton({
    super.key,
    required this.text,
    required this.iconAsset,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.onTap,
  });

  final String text;
  final String iconAsset;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RegisterMobileLayout.socialButtonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1.38),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AssetPicture(iconAsset, width: 20, height: 20, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
                letterSpacing: -0.3125,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
