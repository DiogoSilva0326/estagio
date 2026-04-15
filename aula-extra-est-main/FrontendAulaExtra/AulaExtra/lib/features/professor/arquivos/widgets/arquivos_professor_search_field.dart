import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_colors.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_font_sizes.dart';
import 'package:flutter/material.dart';

class ArquivosProfessorSearchField extends StatelessWidget {
  const ArquivosProfessorSearchField({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43.333,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: ArquivosProfessorFontSizes.input,
          height: 1.2,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: ArquivosProfessorColors.searchFill,
          hintText: 'Procurar arquivos...',
          hintStyle: const TextStyle(
            color: ArquivosProfessorColors.hintText,
            fontSize: ArquivosProfessorFontSizes.input,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 24.074,
            color: ArquivosProfessorColors.hintText,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48.148,
            minHeight: 43.333,
          ),
          contentPadding: const EdgeInsets.only(right: 14.444),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.037),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
