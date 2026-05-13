import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_primary_action_button.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasEmptyStateCard extends StatelessWidget {
  const MinhasDisciplinasEmptyStateCard({
    super.key,
    required this.onTap,
    required this.message, 
  });

  final VoidCallback onTap;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          MinhasDisciplinasProfessorLayout.cardRadius,
        ),
        border: Border.all(color: MinhasDisciplinasProfessorColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message, 
            style: const TextStyle(
              color: MinhasDisciplinasProfessorColors.title,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione novas configurações ao seu perfil com área e ciclo de estudos para geri-las aqui.',
            style: TextStyle(
              color: MinhasDisciplinasProfessorColors.subtitle,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          MinhasDisciplinasPrimaryActionButton(
            label: 'Adicionar nova',
            icon: Icons.add_rounded,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}