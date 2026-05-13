import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_primary_action_button.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasProfessorMobileIntro extends StatelessWidget {
  const MinhasDisciplinasProfessorMobileIntro({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onCreate,
    required this.activeColor,
  });

  final String title;
  final String subtitle;
  final VoidCallback onCreate;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: MinhasDisciplinasProfessorColors.title,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 38 / 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: MinhasDisciplinasProfessorColors.mobileMutedText,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 18 / 13,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: MinhasDisciplinasPrimaryActionButton(
            label: 'Adicionar nova', 
            icon: Icons.add_rounded,
            onTap: onCreate,
            activeColor: activeColor, 
          ),
        ),
      ],
    );
  }
}