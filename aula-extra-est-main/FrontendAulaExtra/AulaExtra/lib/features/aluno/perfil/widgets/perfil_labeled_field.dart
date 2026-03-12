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
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PerfilConstants.labelStyle),
        const SizedBox(height: PerfilConstants.smallGap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22.247, vertical: 16.685),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PerfilConstants.fieldRadius),
            border: Border.all(color: PerfilConstants.fieldBorderColor, width: 1.39),
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
              hintStyle: PerfilConstants.mutedHintStyle,
              contentPadding: EdgeInsets.zero,
            ),
            style: PerfilConstants.fieldTextStyle,
          ),
        ),
      ],
    );
  }
}
