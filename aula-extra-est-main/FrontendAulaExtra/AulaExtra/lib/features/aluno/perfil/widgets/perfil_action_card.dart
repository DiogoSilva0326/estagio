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
  });

  final String title;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final Color? buttonBorderColor;
  final Color? buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(34.761, 34.761, 34.761, 1.39),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PerfilConstants.cardRadius),
        border: Border.all(color: PerfilConstants.cardBorderColor, width: 1.39),
        boxShadow: PerfilConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PerfilConstants.sectionHeadingStyle),
          const SizedBox(height: 22.247),
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(PerfilConstants.fieldRadius),
            child: Container(
              height: 72.303,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PerfilConstants.fieldRadius),
                border: Border.all(color: buttonBorderColor ?? PerfilConstants.fieldBorderColor, width: 2.781),
                color: Colors.white,
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  fontSize: 22.247,
                  fontWeight: FontWeight.w400,
                  color: buttonTextColor ?? const Color(0xFF364153),
                  height: 33.371 / 22.247,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
