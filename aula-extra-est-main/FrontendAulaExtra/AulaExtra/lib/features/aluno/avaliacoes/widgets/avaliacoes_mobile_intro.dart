import 'package:aula_extra/features/aluno/avaliacoes/constants/avaliacoes_constants.dart';
import 'package:flutter/material.dart';

class AvaliacoesMobileIntro extends StatelessWidget {
  const AvaliacoesMobileIntro({
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
        Text(title, style: AvaliacoesConstants.mobileTitleStyle),
        const SizedBox(height: 8),
        Text(subtitle, style: AvaliacoesConstants.mobileSubtitleStyle),
      ],
    );
  }
}
