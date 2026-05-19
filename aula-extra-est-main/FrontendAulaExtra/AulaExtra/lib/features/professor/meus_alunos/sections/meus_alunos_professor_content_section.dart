import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/complaints/complaints_service.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
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
import 'package:provider/provider.dart';

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
  
  Future<List<ProfessorAlunoDto>>? _studentsFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_studentsFuture == null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final config = TeachingRoleConfig.fromRole(userProvider.role);
      
      _studentsFuture = _professorsService.fetchMeusAlunos(role: config.roleName);
    }
  }

  Future<void> _showComplaintDialog(ProfessorAlunoDto aluno, TeachingRoleConfig config) async {
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => RelatedUserComplaintDialog(
        targetUserId: aluno.id,
        targetName: aluno.fullName,
        targetRoleLabel: 'do ${config.roleName.toLowerCase()}',
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

  void _openProfile(ProfessorAlunoDto aluno) {
    Navigator.pushNamed(
      context,
      Routes.professorPerfilAlunoView,
      arguments: aluno,
    );
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

  Widget _buildMobileContent(TeachingRoleConfig config) {
    return Container(
      width: double.infinity,
      color: config.roleName == 'Explicador' 
          ? MeusAlunosProfessorColors.pageBackground 
          : const Color(0xFFF9FAFB),
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
              title: 'Não foi possível carregar os dados.',
              message: 'Erro: ${snapshot.error}',
            );
          }

          final alunos = snapshot.data ?? const <ProfessorAlunoDto>[];

          if (alunos.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MeusAlunosProfessorMobileIntro(
                  title: config.studentsLabel,
                  subtitle: config.meusAlunos.pageDescription,
                ),
                const SizedBox(height: MeusAlunosProfessorLayout.mobileSectionGap),
                _MobileStateCard(
                  title: config.meusAlunos.emptyStateTitle,
                  message: config.meusAlunos.emptyStateDescription,
                ),
              ],
            );
          }

          final averageProgressValue = _averageProgress(alunos);
          final subjectsCountValue = _uniqueSubjectsCount(alunos);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MeusAlunosProfessorMobileIntro(
                title: config.studentsLabel,
                subtitle: config.meusAlunos.pageDescription,
              ),
              const SizedBox(height: MeusAlunosProfessorLayout.mobileSectionGap),
              Row(
                children: [
                  Expanded(
                    child: MeusAlunosProfessorMobileStatCard(
                      label: config.studentsLabel,
                      value: '${alunos.length}',
                      helper: 'ativos',
                      activeColor: config.primaryColor, 
                    ),
                  ),
                  const SizedBox(width: MeusAlunosProfessorLayout.mobileStatGap),
                  Expanded(
                    child: MeusAlunosProfessorMobileStatCard(
                      label: 'Progresso médio',
                      value: '$averageProgressValue%',
                      helper: config.meusAlunos.statsProgressHelper, 
                      activeColor: config.primaryColor,
                    ),
                  ),
                  const SizedBox(width: MeusAlunosProfessorLayout.mobileStatGap),
                  Expanded(
                    child: MeusAlunosProfessorMobileStatCard(
                      label: config.meusAlunos.statsSubjectsLabel, 
                      value: '$subjectsCountValue',
                      helper: 'únicas',
                      activeColor: config.primaryColor, 
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < alunos.length; index++) ...[
                MeusAlunosProfessorMobileStudentCard(
                  aluno: alunos[index],
                  onProfileTap: () => _openProfile(alunos[index]),
                  onChatTap: () => _openChat(alunos[index]),
                  onFilesTap: _openArquivos,
                  onComplaintTap: () => _showComplaintDialog(alunos[index], config),
                ),
                if (index != alunos.length - 1)
                  const SizedBox(height: MeusAlunosProfessorLayout.mobileSectionGap),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    final isMobile =
        widget.isMobile ||
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    final titleStyle = TextStyle(
      color: MeusAlunosProfessorColors.title,
      fontWeight: FontWeight.w800,
      fontSize: MeusAlunosProfessorLayout.titleFontSize,
      height: MeusAlunosProfessorLayout.titleLineHeight /
          MeusAlunosProfessorLayout.titleFontSize,
    );

    if (isMobile) {
      return _buildMobileContent(config);
    }

    return Container(
      color: config.roleName == 'Explicador' 
          ? MeusAlunosProfessorColors.background 
          : const Color(0xFFF9FAFB),
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
                    Text(config.studentsLabel, style: titleStyle),
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
                          return Center(
                            child: Text(config.meusAlunos.emptyStateTitle),
                          );
                        }

                        return AlunosGrid(
                          alunos: alunos,
                          onComplaintTap: (aluno) => _showComplaintDialog(aluno, config),
                          onViewProfileTap: _openProfile,
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