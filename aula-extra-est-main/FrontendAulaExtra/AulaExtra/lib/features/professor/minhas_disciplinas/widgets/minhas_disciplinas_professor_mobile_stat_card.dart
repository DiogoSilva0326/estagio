import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasProfessorMobileStatCard extends StatelessWidget {
  const MinhasDisciplinasProfessorMobileStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.helper,
    required this.activeColor,
  });

  final String label;
  final String value;
  final String helper;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final isOrange = activeColor == const Color(0xFFFC9039);
    final valueColor = isOrange ? MinhasDisciplinasProfessorColors.buttonGradientBottom : activeColor;

    return Container(
      padding: const EdgeInsets.all(
        MinhasDisciplinasProfessorLayout.mobileCardPadding,
      ),
      decoration: BoxDecoration(
        color: MinhasDisciplinasProfessorColors.mobileSoftSurface,
        borderRadius: BorderRadius.circular(
          MinhasDisciplinasProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(
          color: MinhasDisciplinasProfessorColors.mobileSoftBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MinhasDisciplinasProfessorColors.mobileMutedText,
              height: 16 / 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 28 / 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MinhasDisciplinasProfessorColors.mobileMutedText,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}