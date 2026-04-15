import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasSummaryBox extends StatelessWidget {
  const MinhasDisciplinasSummaryBox({
    super.key,
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(
        minHeight: MinhasDisciplinasProfessorLayout.summaryHeight,
      ),
      padding: const EdgeInsets.fromLTRB(27.394, 27.394, 27.394, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          MinhasDisciplinasProfessorLayout.cardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: MinhasDisciplinasProfessorColors.cardShadow,
            blurRadius: 3.424,
            offset: Offset(0, 1.141),
          ),
          BoxShadow(
            color: MinhasDisciplinasProfessorColors.cardShadow,
            blurRadius: 2.283,
            offset: Offset(0, 1.141),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: MinhasDisciplinasProfessorColors.subtitle,
              fontSize: 15.98,
              height: 22.828 / 15.98,
            ),
          ),
          const SizedBox(height: 4.566),
          Text(
            value,
            style: const TextStyle(
              color: MinhasDisciplinasProfessorColors.title,
              fontSize: 34.242,
              height: 41.09 / 34.242,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
