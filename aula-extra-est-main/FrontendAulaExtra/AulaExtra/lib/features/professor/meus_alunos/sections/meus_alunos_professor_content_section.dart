import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_mock_data.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/aluno_card.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/alunos_grid.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class MeusAlunosProfessorContentSection extends StatelessWidget {
  const MeusAlunosProfessorContentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: MeusAlunosProfessorColors.title,
      fontWeight: FontWeight.w800,
      fontSize: MeusAlunosProfessorLayout.titleFontSize,
      height: MeusAlunosProfessorLayout.titleLineHeight / MeusAlunosProfessorLayout.titleFontSize,
    );

    return Container(
      color: MeusAlunosProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: MeusAlunosProfessorLayout.pageLeftPadding,
            right: MeusAlunosProfessorLayout.pageRightPadding,
            top: MeusAlunosProfessorLayout.pageTopPadding,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(
                selectedIndex: 0,
                notificationCount: 3,
                aulasEstaSemana: 5,
                ganhosPendentes: '120€',
                alunosAtivos: 12,
              ),
              const SizedBox(width: MeusAlunosProfessorLayout.sidebarContentGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meus Alunos', style: titleStyle),
                    const SizedBox(height: MeusAlunosProfessorLayout.titleBottomGap),
                    AlunosGrid(
                      cards: [
                        for (final aluno in MeusAlunosProfessorMockData.alunos)
                          AlunoCard(data: aluno),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
