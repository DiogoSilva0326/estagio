import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_colors.dart';
import 'package:flutter/material.dart';

class AvaliacoesProfessorMobileIntro extends StatelessWidget {
  const AvaliacoesProfessorMobileIntro({
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
        const Text(
          'Avaliações',
          style: TextStyle(
            color: AvaliacoesProfessorColors.title,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 38 / 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: AvaliacoesProfessorColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 18 / 13,
          ),
        ),
      ],
    );
  }
}
