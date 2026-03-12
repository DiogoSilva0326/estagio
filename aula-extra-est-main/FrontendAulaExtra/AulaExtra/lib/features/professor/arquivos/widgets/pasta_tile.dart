import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_colors.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_font_sizes.dart';
import 'package:flutter/material.dart';

class PastaTile extends StatelessWidget {
  const PastaTile({
    super.key,
    required this.icon,
    required this.name,
    required this.countLabel,
    this.onTap,
  });

  final IconData icon;
  final String name;
  final String countLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.037),
      child: SizedBox(
        height: 72.222,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.444),
          child: Row(
            children: [
              Icon(icon, size: 24.074, color: ArquivosProfessorColors.title),
              const SizedBox(width: 14.444),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ArquivosProfessorColors.title,
                        fontSize: ArquivosProfessorFontSizes.folderName,
                        fontWeight: FontWeight.w500,
                        height: 24.074 / ArquivosProfessorFontSizes.folderName,
                      ),
                    ),
                    Text(
                      countLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ArquivosProfessorColors.textSecondary,
                        fontSize: ArquivosProfessorFontSizes.folderCount,
                        fontWeight: FontWeight.w500,
                        height: 19.259 / ArquivosProfessorFontSizes.folderCount,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
