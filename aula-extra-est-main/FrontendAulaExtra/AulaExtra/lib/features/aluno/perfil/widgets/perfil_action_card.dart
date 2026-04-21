import 'package:aula_extra/features/aluno/perfil/constants/perfil_constants.dart';
import 'package:flutter/material.dart';

class PerfilActionCard extends StatelessWidget {
  const PerfilActionCard({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
    this.buttonBorderColor,
    this.buttonTextColor,
    this.isMobile = false,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final Color? buttonBorderColor;
  final Color? buttonTextColor;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 34.761,
        isMobile ? 18 : 34.761,
        isMobile ? 18 : 34.761,
        1.39,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          isMobile
              ? PerfilConstants.mobileCardRadius
              : PerfilConstants.cardRadius,
        ),
        border: Border.all(
          color: isMobile
              ? PerfilConstants.mobileCardBorderColor
              : PerfilConstants.cardBorderColor,
          width: 1.39,
        ),
        boxShadow: isMobile
            ? PerfilConstants.mobileShadow
            : PerfilConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isMobile
                ? PerfilConstants.mobileSectionHeadingStyle
                : PerfilConstants.sectionHeadingStyle,
          ),
          SizedBox(height: isMobile ? 14 : 22.247),
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(
              isMobile
                  ? PerfilConstants.mobileFieldRadius
                  : PerfilConstants.fieldRadius,
            ),
            child: Container(
              height: isMobile ? 50 : 72.303,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  isMobile
                      ? PerfilConstants.mobileFieldRadius
                      : PerfilConstants.fieldRadius,
                ),
                border: Border.all(
                  color:
                      buttonBorderColor ??
                      (isMobile
                          ? PerfilConstants.mobileBorderColor
                          : PerfilConstants.fieldBorderColor),
                  width: isMobile ? 1.5 : 2.781,
                ),
                color: Colors.white,
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 22.247,
                  fontWeight: isMobile ? FontWeight.w500 : FontWeight.w400,
                  color: buttonTextColor ?? const Color(0xFF364153),
                  height: isMobile ? 24 / 16 : 33.371 / 22.247,
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 18 : 28),
        ],
      ),
    );
  }
}
