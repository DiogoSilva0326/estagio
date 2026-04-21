import 'package:aula_extra/features/aluno/perfil/constants/perfil_constants.dart';
import 'package:flutter/material.dart';

class PerfilLabeledField extends StatelessWidget {
  const PerfilLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    this.readOnly = false,
    this.isMobile = false,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final bool readOnly;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: isMobile
              ? PerfilConstants.mobileLabelStyle
              : PerfilConstants.labelStyle,
        ),
        SizedBox(
          height: isMobile
              ? PerfilConstants.mobileSmallGap
              : PerfilConstants.smallGap,
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 22.247,
            vertical: isMobile ? 12 : 16.685,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              isMobile
                  ? PerfilConstants.mobileFieldRadius
                  : PerfilConstants.fieldRadius,
            ),
            border: Border.all(
              color: isMobile
                  ? PerfilConstants.mobileBorderColor
                  : PerfilConstants.fieldBorderColor,
              width: 1.39,
            ),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: isMobile
                  ? PerfilConstants.mobileHintStyle
                  : PerfilConstants.mutedHintStyle,
              contentPadding: EdgeInsets.zero,
            ),
            style: isMobile
                ? PerfilConstants.mobileFieldTextStyle
                : PerfilConstants.fieldTextStyle,
          ),
        ),
      ],
    );
  }
}
