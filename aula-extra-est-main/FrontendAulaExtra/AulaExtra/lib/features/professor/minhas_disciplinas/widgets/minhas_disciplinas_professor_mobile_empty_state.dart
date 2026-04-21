import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_primary_action_button.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasProfessorMobileEmptyState extends StatelessWidget {
  const MinhasDisciplinasProfessorMobileEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onTap,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        MinhasDisciplinasProfessorLayout.mobileCardPadding,
      ),
      decoration: BoxDecoration(
        color: MinhasDisciplinasProfessorColors.mobileSurface,
        borderRadius: BorderRadius.circular(
          MinhasDisciplinasProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(color: MinhasDisciplinasProfessorColors.cardBorder),
        boxShadow: MinhasDisciplinasProfessorColors.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: MinhasDisciplinasProfessorColors.title,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 28 / 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: MinhasDisciplinasProfessorColors.mobileMutedText,
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: MinhasDisciplinasPrimaryActionButton(
              label: buttonLabel,
              icon: Icons.add_rounded,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
