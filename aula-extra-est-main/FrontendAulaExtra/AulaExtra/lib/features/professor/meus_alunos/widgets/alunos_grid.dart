import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/aluno_card.dart';
import 'package:flutter/material.dart';

class AlunosGrid extends StatelessWidget {
  const AlunosGrid({super.key, required this.alunos, this.onComplaintTap});

  final List<ProfessorAlunoDto> alunos;
  final ValueChanged<ProfessorAlunoDto>? onComplaintTap;

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
            for (final aluno in alunos)
              SizedBox(
                width: cardWidth,
                child: AlunoCard(
                  data: aluno,
                  onComplaintTap: onComplaintTap == null
                      ? null
                      : () => onComplaintTap!(aluno),
                ),
              ),
          ],
        );
      },
    );
  }
}
