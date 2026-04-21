import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/complaints/complaints_service.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/features/shared/complaints/widgets/related_user_complaint_dialog.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/meus_alunos_professor_mobile_intro.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/meus_alunos_professor_mobile_stat_card.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/meus_alunos_professor_mobile_student_card.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/alunos_grid.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class MeusAlunosProfessorContentSection extends StatefulWidget {
  const MeusAlunosProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<MeusAlunosProfessorContentSection> createState() =>
      _MeusAlunosProfessorContentSectionState();
}

class _MeusAlunosProfessorContentSectionState
    extends State<MeusAlunosProfessorContentSection> {
  final ProfessorsService _professorsService = ProfessorsService();
  final ComplaintsService _complaintsService = ComplaintsService();
  late Future<List<ProfessorAlunoDto>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _professorsService.fetchMeusAlunos();
  }

  Future<void> _showComplaintDialog(ProfessorAlunoDto aluno) async {
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => RelatedUserComplaintDialog(
        targetUserId: aluno.id,
        targetName: aluno.fullName,
        targetRoleLabel: 'do aluno',
        relationshipType: 'student',
        onSubmit: _complaintsService.createRelatedUserComplaint,
      ),
    );

    if (!mounted || submitted != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reclamação submetida sobre ${aluno.fullName}.')),
    );
  }

  void _openChat(ProfessorAlunoDto aluno) {
    Navigator.pushNamed(
      context,
      Routes.professorChats,
      arguments: <String, dynamic>{
        'studentUsername': aluno.username,
        'studentName': aluno.fullName,
      },
    );
  }

  void _openArquivos() {
    Navigator.pushNamed(context, Routes.professorArquivos);
  }

  int _averageProgress(List<ProfessorAlunoDto> alunos) {
    if (alunos.isEmpty) return 0;
    final total = alunos.fold<double>(0, (sum, aluno) => sum + aluno.progress);
    return ((total / alunos.length) * 100).round().clamp(0, 100);
  }

  int _uniqueSubjectsCount(List<ProfessorAlunoDto> alunos) {
    final subjects = <String>{};
    for (final aluno in alunos) {
      for (final subject in aluno.subjects) {
        final normalized = subject.trim().toLowerCase();
        if (normalized.isNotEmpty) {
          subjects.add(normalized);
        }
      }
    }
    return subjects.length;
  }

  Widget _buildMobileContent() {
    return Container(
      width: double.infinity,
      color: MeusAlunosProfessorColors.pageBackground,
      padding: const EdgeInsets.fromLTRB(
        MeusAlunosProfessorLayout.mobileHorizontalPadding,
        MeusAlunosProfessorLayout.mobileTopPadding,
        MeusAlunosProfessorLayout.mobileHorizontalPadding,
        MeusAlunosProfessorLayout.mobileBottomPadding,
      ),
      child: FutureBuilder<List<ProfessorAlunoDto>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return _MobileStateCard(
              title: 'Não foi possível carregar os alunos.',
              message: 'Erro: ${snapshot.error}',
            );
          }

          final alunos = snapshot.data ?? const <ProfessorAlunoDto>[];

          if (alunos.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                MeusAlunosProfessorMobileIntro(
                  title: 'Meus Alunos',
                  subtitle:
                      'Acompanhe os alunos associados, o progresso e as ações mais rápidas no telemóvel.',
                ),
                SizedBox(height: MeusAlunosProfessorLayout.mobileSectionGap),
                _MobileStateCard(
                  title: 'Ainda não tens alunos associados.',
                  message:
                      'Quando um aluno reservar aulas contigo, ele vai aparecer aqui automaticamente.',
                ),
              ],
            );
          }

          final averageProgress = _averageProgress(alunos);
          final subjectsCount = _uniqueSubjectsCount(alunos);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MeusAlunosProfessorMobileIntro(
                title: 'Meus Alunos',
                subtitle:
                    'Acompanhe os alunos associados, o progresso e as ações mais rápidas no telemóvel.',
              ),
              const SizedBox(
                height: MeusAlunosProfessorLayout.mobileSectionGap,
              ),
              Row(
                children: [
                  Expanded(
                    child: MeusAlunosProfessorMobileStatCard(
                      label: 'Alunos',
                      value: '${alunos.length}',
                      helper: 'ativos',
                    ),
                  ),
                  const SizedBox(
                    width: MeusAlunosProfessorLayout.mobileStatGap,
                  ),
                  Expanded(
                    child: MeusAlunosProfessorMobileStatCard(
                      label: 'Progresso médio',
                      value: '$averageProgress%',
                      helper: 'turma',
                    ),
                  ),
                  const SizedBox(
                    width: MeusAlunosProfessorLayout.mobileStatGap,
                  ),
                  Expanded(
                    child: MeusAlunosProfessorMobileStatCard(
                      label: 'Disciplinas',
                      value: '$subjectsCount',
                      helper: 'únicas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < alunos.length; index++) ...[
                MeusAlunosProfessorMobileStudentCard(
                  aluno: alunos[index],
                  onChatTap: () => _openChat(alunos[index]),
                  onFilesTap: _openArquivos,
                  onComplaintTap: () => _showComplaintDialog(alunos[index]),
                ),
                if (index != alunos.length - 1)
                  const SizedBox(
                    height: MeusAlunosProfessorLayout.mobileSectionGap,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        widget.isMobile ||
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    final titleStyle = TextStyle(
      color: MeusAlunosProfessorColors.title,
      fontWeight: FontWeight.w800,
      fontSize: MeusAlunosProfessorLayout.titleFontSize,
      height:
          MeusAlunosProfessorLayout.titleLineHeight /
          MeusAlunosProfessorLayout.titleFontSize,
    );

    if (isMobile) {
      return _buildMobileContent();
    }

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
              const SizedBox(
                width: MeusAlunosProfessorLayout.sidebarContentGap,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meus Alunos', style: titleStyle),
                    const SizedBox(
                      height: MeusAlunosProfessorLayout.titleBottomGap,
                    ),
                    FutureBuilder<List<ProfessorAlunoDto>>(
                      future: _studentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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

                        final alunos =
                            snapshot.data ?? const <ProfessorAlunoDto>[];
                        if (alunos.isEmpty) {
                          return const Center(
                            child: Text('Ainda não tens alunos associados.'),
                          );
                        }

                        return AlunosGrid(
                          alunos: alunos,
                          onComplaintTap: _showComplaintDialog,
                        );
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

class _MobileStateCard extends StatelessWidget {
  const _MobileStateCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        MeusAlunosProfessorLayout.mobileCardPadding,
      ),
      decoration: BoxDecoration(
        color: MeusAlunosProfessorColors.mobileSurface,
        borderRadius: BorderRadius.circular(
          MeusAlunosProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(color: MeusAlunosProfessorColors.mobileBorder),
        boxShadow: MeusAlunosProfessorColors.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: MeusAlunosProfessorColors.title,
              height: 28 / 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: MeusAlunosProfessorColors.mobileMutedText,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}
