import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_constants.dart';
import 'package:flutter/material.dart';

class ArquivosMobileIntro extends StatelessWidget {
  const ArquivosMobileIntro({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ArquivosConstants.mobileTitleStyle),
        const SizedBox(height: 8),
        Text(subtitle, style: ArquivosConstants.mobileSubtitleStyle),
      ],
    );
  }
}
