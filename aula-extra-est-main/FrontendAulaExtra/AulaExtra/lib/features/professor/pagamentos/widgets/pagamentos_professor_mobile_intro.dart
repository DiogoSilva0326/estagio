import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:flutter/material.dart';

class PagamentosProfessorMobileIntro extends StatelessWidget {
  const PagamentosProfessorMobileIntro({
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
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: PagamentosProfessorColors.title,
            height: 36 / 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: PagamentosProfessorColors.muted,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
