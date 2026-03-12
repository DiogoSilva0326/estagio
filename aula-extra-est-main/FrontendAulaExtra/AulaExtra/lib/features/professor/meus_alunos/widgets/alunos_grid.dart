import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:flutter/material.dart';

class AlunosGrid extends StatelessWidget {
  const AlunosGrid({
    super.key,
    required this.cards,
  });

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = MeusAlunosProfessorLayout.cardWidth;
        final spacing = MeusAlunosProfessorLayout.gridSpacing;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(
                width: cardWidth,
                child: card,
              ),
          ],
        );
      },
    );
  }
}
