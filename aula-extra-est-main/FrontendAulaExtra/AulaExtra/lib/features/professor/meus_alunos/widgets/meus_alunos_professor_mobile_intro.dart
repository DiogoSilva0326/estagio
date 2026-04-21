import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:flutter/material.dart';

class MeusAlunosProfessorMobileIntro extends StatelessWidget {
  const MeusAlunosProfessorMobileIntro({
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
        Text(
          title,
          style: const TextStyle(
            color: MeusAlunosProfessorColors.title,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 38 / 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: MeusAlunosProfessorColors.mobileMutedText,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 18 / 13,
          ),
        ),
      ],
    );
  }
}
