import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/alunos_grid.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class MeusAlunosProfessorContentSection extends StatefulWidget {
  const MeusAlunosProfessorContentSection({
    super.key,
  });

  @override
  State<MeusAlunosProfessorContentSection> createState() => _MeusAlunosProfessorContentSectionState();
}

class _MeusAlunosProfessorContentSectionState extends State<MeusAlunosProfessorContentSection> {
  final ProfessorsService _professorsService = ProfessorsService();
  late Future<List<ProfessorAlunoDto>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _professorsService.fetchMeusAlunos();
  }

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
                    FutureBuilder<List<ProfessorAlunoDto>>(
                      future: _studentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final alunos = snapshot.data ?? const <ProfessorAlunoDto>[];
                        if (alunos.isEmpty) {
                          return const Center(
                            child: Text('Ainda não tens alunos associados.'),
                          );
                        }

                        return AlunosGrid(alunos: alunos);
                      },
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
