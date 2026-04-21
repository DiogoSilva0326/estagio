import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class AvaliacoesSearchField extends StatelessWidget {
  const AvaliacoesSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 298.187,
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Pesquisar...',
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 15.143,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.15,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18.637,
            color: AppColors.textMuted,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.307),
            borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.307),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15.143,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
