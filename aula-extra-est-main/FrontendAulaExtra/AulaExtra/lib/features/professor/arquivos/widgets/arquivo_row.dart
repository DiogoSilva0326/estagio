import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_colors.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_font_sizes.dart';
import 'package:flutter/material.dart';

class ArquivoRow extends StatelessWidget {
  const ArquivoRow({
    super.key,
    required this.leadingBackground,
    required this.leadingIcon,
    required this.fileName,
    required this.sizeLabel,
    required this.dateLabel,
    this.ownerLabel,
    this.onDownloadTap,
    this.onEditTap,
    this.onDeleteTap,
    this.showDivider = true,
  });

  final Color leadingBackground;
  final IconData leadingIcon;
  final String fileName;
  final String sizeLabel;
  final String dateLabel;
  final String? ownerLabel;

  final VoidCallback? onDownloadTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: 92.685,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(19.259, 19.259, 19.259, 19.259),
        child: Row(
          children: [
            Container(
              width: 48.148,
              height: 48.148,
              decoration: BoxDecoration(
                color: leadingBackground,
                borderRadius: BorderRadius.circular(19.259),
              ),
              child: Center(
                child: Icon(leadingIcon, size: 28.889, color: ArquivosProfessorColors.title),
              ),
            ),
            const SizedBox(width: 19.259),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ArquivosProfessorColors.title,
                      fontSize: ArquivosProfessorFontSizes.fileName,
                      fontWeight: FontWeight.w500,
                      height: 28.889 / ArquivosProfessorFontSizes.fileName,
                    ),
                  ),
                  const SizedBox(height: 4.815),
                  Row(
                    children: [
                      if (ownerLabel != null && ownerLabel!.trim().isNotEmpty) ...[
                        Flexible(
                          child: Text(
                            ownerLabel!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ArquivosProfessorColors.textSecondary,
                              fontSize: ArquivosProfessorFontSizes.fileMeta,
                              fontWeight: FontWeight.w400,
                              height: 19.259 / ArquivosProfessorFontSizes.fileMeta,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14.444),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: ArquivosProfessorColors.textSecondary,
                            fontSize: ArquivosProfessorFontSizes.fileMeta,
                            fontWeight: FontWeight.w400,
                            height: 19.259 / ArquivosProfessorFontSizes.fileMeta,
                          ),
                        ),
                        const SizedBox(width: 14.444),
                      ],
                      Text(
                        sizeLabel,
                        style: const TextStyle(
                          color: ArquivosProfessorColors.textSecondary,
                          fontSize: ArquivosProfessorFontSizes.fileMeta,
                          fontWeight: FontWeight.w400,
                          height: 19.259 / ArquivosProfessorFontSizes.fileMeta,
                        ),
                      ),
                      const SizedBox(width: 14.444),
                      const Text(
                        '•',
                        style: TextStyle(
                          color: ArquivosProfessorColors.textSecondary,
                          fontSize: ArquivosProfessorFontSizes.fileMeta,
                          fontWeight: FontWeight.w400,
                          height: 19.259 / ArquivosProfessorFontSizes.fileMeta,
                        ),
                      ),
                      const SizedBox(width: 14.444),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          color: ArquivosProfessorColors.textSecondary,
                          fontSize: ArquivosProfessorFontSizes.fileMeta,
                          fontWeight: FontWeight.w400,
                          height: 19.259 / ArquivosProfessorFontSizes.fileMeta,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 19.259),
            SizedBox(
              height: 43.333,
              child: Row(
                children: [
                  _ActionButton(icon: Icons.download_rounded, onTap: onDownloadTap),
                  const SizedBox(width: 9.63),
                  _ActionButton(icon: Icons.edit_rounded, onTap: onEditTap),
                  const SizedBox(width: 9.63),
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFB42318),
                    onTap: onDeleteTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (showDivider)
          const Divider(
            height: 1.204,
            thickness: 1.204,
            color: ArquivosProfessorColors.cardBorder,
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor = ArquivosProfessorColors.title,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9.63),
      child: SizedBox(
        width: 43.333,
        height: 43.333,
        child: Center(
          child: Icon(icon, size: 19.259, color: iconColor),
        ),
      ),
    );
  }
}
