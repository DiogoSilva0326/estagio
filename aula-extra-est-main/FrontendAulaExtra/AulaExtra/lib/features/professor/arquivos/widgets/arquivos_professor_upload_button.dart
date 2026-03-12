import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_colors.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_font_sizes.dart';
import 'package:flutter/material.dart';

class ArquivosProfessorUploadButton extends StatelessWidget {
  const ArquivosProfessorUploadButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43.333,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.444),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ArquivosProfessorColors.uploadGradientTop,
              ArquivosProfessorColors.uploadGradientBottom,
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.444),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.44),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_upload_rounded,
                  size: 19.259,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  'Fazer Upload',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ArquivosProfessorFontSizes.button,
                    fontWeight: FontWeight.w500,
                    height: 24.074 / ArquivosProfessorFontSizes.button,
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
