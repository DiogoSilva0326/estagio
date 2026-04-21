import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:flutter/material.dart';

class MeusAlunosProfessorMobileStatCard extends StatelessWidget {
  const MeusAlunosProfessorMobileStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        MeusAlunosProfessorLayout.mobileCardPadding,
      ),
      decoration: BoxDecoration(
        color: MeusAlunosProfessorColors.mobileSoftSurface,
        borderRadius: BorderRadius.circular(
          MeusAlunosProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(color: const Color(0xFFFFD7BA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MeusAlunosProfessorColors.mobileMutedText,
              height: 16 / 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: MeusAlunosProfessorColors.orange,
              height: 28 / 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MeusAlunosProfessorColors.mobileMutedText,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
