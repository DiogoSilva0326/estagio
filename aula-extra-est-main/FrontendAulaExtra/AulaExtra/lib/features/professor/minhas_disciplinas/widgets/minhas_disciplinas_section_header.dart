import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_primary_action_button.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasSectionHeader extends StatelessWidget {
  const MinhasDisciplinasSectionHeader({super.key, required this.onCreate});

  final VoidCallback onCreate;

  static const TextStyle _titleStyle = TextStyle(
    color: MinhasDisciplinasProfessorColors.title,
    fontSize: 41.09,
    height: 45.656 / 41.09,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.42,
  );

  static const TextStyle _subtitleStyle = TextStyle(
    color: MinhasDisciplinasProfessorColors.subtitle,
    fontSize: 18.262,
    height: 27.394 / 18.262,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackButton = constraints.maxWidth < 760;

        if (stackButton) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Minhas Disciplinas', style: _titleStyle),
              const SizedBox(height: 9.131),
              const Text(
                'Crie, edite e organize as disciplinas que leciona.',
                style: _subtitleStyle,
              ),
              const SizedBox(height: 18),
              MinhasDisciplinasPrimaryActionButton(
                label: 'Nova Disciplina',
                icon: Icons.add_rounded,
                onTap: onCreate,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Minhas Disciplinas', style: _titleStyle),
                  SizedBox(height: 9.131),
                  Text(
                    'Crie, edite e organize as disciplinas que leciona.',
                    style: _subtitleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            MinhasDisciplinasPrimaryActionButton(
              label: 'Nova Disciplina',
              icon: Icons.add_rounded,
              onTap: onCreate,
            ),
          ],
        );
      },
    );
  }
}
