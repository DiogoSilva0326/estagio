import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:flutter/material.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/aluno_card.dart';

class AlunosGrid extends StatelessWidget {
  final List<ProfessorAlunoDto> alunos; // <- Passar a receber o DTO

  const AlunosGrid({super.key, required this.alunos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: alunos.length,
      itemBuilder: (context, index) {
        final aluno = alunos[index];
        return AlunoCard(
          id: aluno.id,
          name: aluno.name,
          avatarUrl: aluno.avatarUrl,
          subjects: aluno.subjects,
          lastLessonDate: aluno.lastLessonDate,
          progress: aluno.progress,
        );
      },
    );
  }
}

