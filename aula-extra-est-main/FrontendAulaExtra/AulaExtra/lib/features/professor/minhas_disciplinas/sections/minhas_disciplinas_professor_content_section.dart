import 'dart:math' as math;

import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/widgets/app_confirmation_dialog.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/disciplina_card.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_professor_mobile_card.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_professor_mobile_empty_state.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_professor_mobile_intro.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_professor_mobile_stat_card.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_empty_state_card.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_section_header.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/minhas_disciplinas_summary_box.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/widgets/professor_disciplina_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';

class MinhasDisciplinasProfessorContentSection extends StatefulWidget {
  const MinhasDisciplinasProfessorContentSection({
    super.key,
    this.isMobile = false,
  });

  final bool isMobile;

  @override
  State<MinhasDisciplinasProfessorContentSection> createState() =>
      _MinhasDisciplinasProfessorContentSectionState();
}

class _MinhasDisciplinasProfessorContentSectionState
    extends State<MinhasDisciplinasProfessorContentSection> {
  static const _pageTitleStyle = TextStyle(
    color: MinhasDisciplinasProfessorColors.title,
    fontSize: 41.09,
    height: 45.656 / 41.09,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.42,
  );

  final ProfessorsService _professorsService = ProfessorsService();
  final EducationService _educationService = EducationService();

  late Future<List<DisciplinaDto>> _disciplinasFuture;
  List<DisciplinaDto> _disciplinas = const [];

  @override
  void initState() {
    super.initState();
    _disciplinasFuture = _loadDisciplinas();
  }

  Future<List<DisciplinaDto>> _loadDisciplinas() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentTargetRole = userProvider.role == Role.psychologist ? 'psicologia' 
                            : userProvider.role == Role.tutor ? 'tutoria' 
                            : 'ensino';

    final results = await Future.wait([
      _professorsService.getMyDisciplinas(),
      _educationService.getAreas(targetRole: currentTargetRole),
    ]);

    final allDisciplinas = results[0] as List<DisciplinaDto>;
    final allowedAreas = results[1] as List<AreaDto>;
    final allowedAreaIds = allowedAreas.map((a) => a.idArea).toSet();

    _disciplinas = allDisciplinas.where((item) {
      if (!item.isActive) return false;
      return allowedAreaIds.contains(item.idArea);
    }).toList(growable: false);

    return _disciplinas;
  }

  Future<void> _refresh() async {
    final future = _loadDisciplinas();
    setState(() {
      _disciplinasFuture = future;
    });
    await future;
  }

  Future<void> _openDisciplinaDialog({DisciplinaDto? disciplina}) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentTargetRole = userProvider.role == Role.psychologist ? 'psicologia' 
                              : userProvider.role == Role.tutor ? 'tutoria' 
                              : 'ensino';

      final results = await Future.wait([
        _educationService.getAreas(targetRole: currentTargetRole),
        _educationService.getCiclosEstudo(),
        _educationService.getCatalog(),
      ]);
      if (!mounted) return;

      final formResult = await showDialog<ProfessorDisciplinaDialogResult>(
        context: context,
        barrierDismissible: true,
        builder: (context) => ProfessorDisciplinaDialog(
          areas: results[0] as List<AreaDto>,
          ciclos: results[1] as List<CicloEstudoDto>,
          catalog: results[2] as List<DisciplinaDto>,
          initialDisciplina: disciplina,
        ),
      );

      if (formResult == null) return;

      await (disciplina == null
          ? _professorsService.createMyDisciplina(
              idDisciplina: formResult.idDisciplina,
              idArea: formResult.idArea,
              idCicloEstudo: formResult.idCicloEstudo,
              nome: formResult.nome,
              descricao: formResult.descricao,
            )
          : _professorsService.updateMyDisciplina(
              currentIdDisciplina: disciplina.idDisciplina,
              idDisciplina: formResult.idDisciplina,
              idArea: formResult.idArea,
              idCicloEstudo: formResult.idCicloEstudo,
              nome: formResult.nome,
              descricao: formResult.descricao,
            ));

      if (!mounted) return;
      
      await _refresh();
      
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            disciplina == null
                ? 'Não foi possível criar a área: $error'
                : 'Não foi possível atualizar a área: $error',
          ),
        ),
      );
    }
  }

  Future<void> _removeDisciplina(DisciplinaDto disciplina, TeachingRoleConfig config) async {
    final areaLabel = config.perfil.subjectsSectionTitle.toLowerCase();
    
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Eliminar',
      confirmLabel: 'Sim, eliminar',
      icon: Icons.warning_amber_rounded,
      inlineHeader: true,
      confirmGradient: null,
      confirmColor: MinhasDisciplinasProfessorColors.deleteConfirmButton,
      iconColor: MinhasDisciplinasProfessorColors.dangerIcon,
      iconBackgroundColor:
          MinhasDisciplinasProfessorColors.deleteIconBackground,
      iconBorderColor: MinhasDisciplinasProfessorColors.deleteIconBorder,
      showIconBorder: false,
      width: MinhasDisciplinasProfessorLayout.confirmationDialogWidth,
      height: MinhasDisciplinasProfessorLayout.confirmationDialogHeight,
      iconContainerRadius:
          MinhasDisciplinasProfessorLayout.confirmationDialogIconRadius,
      iconContainerSize:
          MinhasDisciplinasProfessorLayout.confirmationDialogIconContainerSize,
      iconSize: MinhasDisciplinasProfessorLayout.confirmationDialogIconSize,
      cancelBorderColor: MinhasDisciplinasProfessorColors.dialogCancelBorder,
      cancelTextColor: MinhasDisciplinasProfessorColors.dialogText,
      closeIconColor: MinhasDisciplinasProfessorColors.deleteCloseIcon,
      maxWidth: MinhasDisciplinasProfessorLayout.confirmationDialogMaxWidth,
      borderRadius: MinhasDisciplinasProfessorLayout.confirmationDialogRadius,
      padding: const EdgeInsets.all(24),
      contentPadding: const EdgeInsets.only(left: 60),
      headerBottomSpacing: 16,
      actionsTopSpacing: 24,
      actionButtonHeight: 46,
      actionSpacing: 12,
      forceHorizontalActions: true,
      titleStyle: const TextStyle(
        color: MinhasDisciplinasProfessorColors.title,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.45,
      ),
      cancelTextStyle: const TextStyle(
        color: Color(0xFF364153),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: -0.31,
      ),
      confirmTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: -0.31,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 340,
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: MinhasDisciplinasProfessorColors.dialogText,
                  letterSpacing: -0.31,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: 'Tem certeza que deseja eliminar a $areaLabel ',
                  ),
                  TextSpan(
                    text: disciplina.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: MinhasDisciplinasProfessorColors.title,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta ação não pode ser desfeita.',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: MinhasDisciplinasProfessorColors.deleteDangerText,
              fontSize: 14,
              height: 1.43,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _professorsService.removeMyDisciplina(
        idDisciplina: disciplina.idDisciplina,
      );
      if (!mounted) return;
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível eliminar a $areaLabel: $error'),
        ),
      );
    }
  }

  int _totalStudents(List<DisciplinaDto> disciplinas) =>
      disciplinas.fold(0, (sum, item) => sum + item.activeStudentsCount);

  int _averageStudents(List<DisciplinaDto> disciplinas) {
    if (disciplinas.isEmpty) return 0;
    return (_totalStudents(disciplinas) / disciplinas.length).round();
  }

  Color _disciplineColor(String key) {
    const palette = <Color>[
      Color(0xFF2B7FFF),
      Color(0xFF00C950),
      Color(0xFFAD46FF),
      Color(0xFFF59E0B),
      Color(0xFFF15C64),
      Color(0xFF06B6D4),
    ];

    final hash = key.runes.fold<int>(0, (value, rune) => value + rune);
    return palette[hash % palette.length];
  }

  Widget _buildMobileContent(TeachingRoleConfig config) {
    return Container(
      width: double.infinity,
      color: MinhasDisciplinasProfessorColors.background,
      padding: const EdgeInsets.fromLTRB(
        MinhasDisciplinasProfessorLayout.mobileHorizontalPadding,
        MinhasDisciplinasProfessorLayout.mobileTopPadding,
        MinhasDisciplinasProfessorLayout.mobileHorizontalPadding,
        MinhasDisciplinasProfessorLayout.mobileBottomPadding,
      ),
      child: FutureBuilder<List<DisciplinaDto>>(
        future: _disciplinasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return MinhasDisciplinasProfessorMobileEmptyState(
              title: 'Não foi possível carregar as ${config.perfil.subjectsSectionTitle.toLowerCase()}.',
              message: 'Erro: ${snapshot.error}',
              buttonLabel: 'Tentar novamente',
              onTap: _refresh,
            );
          }

          final disciplinas = snapshot.data ?? const <DisciplinaDto>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MinhasDisciplinasProfessorMobileIntro(
                title: config.perfil.subjectsSectionTitle,
                subtitle:
                    'Crie, edite e organize as suas ${config.perfil.subjectsSectionTitle.toLowerCase()} no formato mobile.',
                onCreate: _openDisciplinaDialog,
                activeColor: config.primaryColor, 
              ),
              const SizedBox(
                height: MinhasDisciplinasProfessorLayout.mobileSectionGap,
              ),
              Row(
                children: [
                  Expanded(
                    child: MinhasDisciplinasProfessorMobileStatCard(
                      label: config.perfil.subjectsSectionTitle,
                      value: '${disciplinas.length}',
                      helper: 'ativas',
                      activeColor: config.primaryColor,
                    ),
                  ),
                  const SizedBox(
                    width: MinhasDisciplinasProfessorLayout.mobileStatsGap,
                  ),
                  Expanded(
                    child: MinhasDisciplinasProfessorMobileStatCard(
                      label: config.studentsLabel.replaceAll('Meus ', ''), 
                      value: '${_totalStudents(disciplinas)}',
                      helper: 'ativos',
                      activeColor: config.primaryColor,
                    ),
                  ),
                  const SizedBox(
                    width: MinhasDisciplinasProfessorLayout.mobileStatsGap,
                  ),
                  Expanded(
                    child: MinhasDisciplinasProfessorMobileStatCard(
                      label: 'Média',
                      value: '${_averageStudents(disciplinas)}',
                      helper: 'por ${config.perfil.subjectsSectionTitle.toLowerCase()}',
                      activeColor: config.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (disciplinas.isEmpty)
                MinhasDisciplinasProfessorMobileEmptyState(
                  title: 'Ainda não tem ${config.perfil.subjectsSectionTitle.toLowerCase()} configuradas.',
                  message:
                      'Adicione ${config.perfil.subjectsSectionTitle.toLowerCase()} ao seu perfil para geri-las aqui.',
                  buttonLabel: 'Adicionar nova',
                  onTap: _openDisciplinaDialog,
                )
              else
                for (var index = 0; index < disciplinas.length; index++) ...[
                  MinhasDisciplinasProfessorMobileCard(
                    disciplina: disciplinas[index],
                    color: _disciplineColor(disciplinas[index].nome),
                    onEdit: () =>
                        _openDisciplinaDialog(disciplina: disciplinas[index]),
                    onDelete: () => _removeDisciplina(disciplinas[index], config),
                    studentLabel: config.studentsLabel.toLowerCase(), 
                    activeColor: config.primaryColor, 
                  ),
                  if (index != disciplinas.length - 1)
                    const SizedBox(
                      height: MinhasDisciplinasProfessorLayout.mobileSectionGap,
                    ),
                ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(double width, TeachingRoleConfig config) {
    return SizedBox(
      width: width,
      child: FutureBuilder<List<DisciplinaDto>>(
        future: _disciplinasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 120),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.perfil.subjectsSectionTitle, style: _pageTitleStyle),
                const SizedBox(height: 12),
                Text(
                  'Não foi possível carregar as ${config.perfil.subjectsSectionTitle.toLowerCase()}: ${snapshot.error}',
                  style: const TextStyle(color: Color(0xFFB42318)),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _refresh,
                  child: const Text('Tentar novamente'),
                ),
              ],
            );
          }

          final disciplinas = snapshot.data ?? const <DisciplinaDto>[];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MinhasDisciplinasSectionHeader(
                onCreate: _openDisciplinaDialog,
                title: config.perfil.subjectsSectionTitle,
                activeColor: config.primaryColor,
              ),
              const SizedBox(
                height: MinhasDisciplinasProfessorLayout.titleBottomGap,
              ),
              LayoutBuilder(
                builder: (context, summaryConstraints) {
                  final availableWidth = summaryConstraints.maxWidth;
                  final summaryCardsPerRow = math.max(
                    1,
                    ((availableWidth +
                                MinhasDisciplinasProfessorLayout
                                    .summarySpacing) /
                            (MinhasDisciplinasProfessorLayout.summaryWidth +
                                MinhasDisciplinasProfessorLayout
                                    .summarySpacing))
                        .floor(),
                  );
                  final summaryWidth = summaryCardsPerRow >= 3
                      ? MinhasDisciplinasProfessorLayout.summaryWidth
                      : summaryCardsPerRow == 1
                      ? availableWidth
                      : ((availableWidth -
                                    ((summaryCardsPerRow - 1) *
                                        MinhasDisciplinasProfessorLayout
                                            .summarySpacing)) /
                                summaryCardsPerRow)
                            .clamp(
                              260.0,
                              MinhasDisciplinasProfessorLayout.summaryWidth,
                            );

                  return Wrap(
                    spacing: MinhasDisciplinasProfessorLayout.summarySpacing,
                    runSpacing:
                        MinhasDisciplinasProfessorLayout.summaryRunSpacing,
                    children: [
                      MinhasDisciplinasSummaryBox(
                        width: summaryWidth,
                        label: 'Total de ${config.perfil.subjectsSectionTitle}',
                        value: '${disciplinas.length}',
                      ),
                      MinhasDisciplinasSummaryBox(
                        width: summaryWidth,
                        label: 'Total de ${config.studentsLabel.replaceAll('Meus ', '')}',
                        value: '${_totalStudents(disciplinas)}',
                      ),
                      MinhasDisciplinasSummaryBox(
                        width: summaryWidth,
                        label: 'Média por ${config.perfil.subjectsSectionTitle.toLowerCase().replaceAll('s', '')}', 
                        value: '${_averageStudents(disciplinas)}',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 27.394),
              if (disciplinas.isEmpty)
                MinhasDisciplinasEmptyStateCard(
                  onTap: _openDisciplinaDialog,
                  message: 'Ainda não tem ${config.perfil.subjectsSectionTitle.toLowerCase()} configuradas.',
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final cardsPerRow = math.max(
                      1,
                      ((availableWidth +
                                  MinhasDisciplinasProfessorLayout
                                      .cardSpacing) /
                              (MinhasDisciplinasProfessorLayout.cardWidth +
                                  MinhasDisciplinasProfessorLayout.cardSpacing))
                          .floor(),
                    );
                    final cardWidth = cardsPerRow >= 3
                        ? MinhasDisciplinasProfessorLayout.cardWidth
                        : cardsPerRow == 1
                        ? availableWidth
                        : ((availableWidth -
                                      ((cardsPerRow - 1) *
                                          MinhasDisciplinasProfessorLayout
                                              .cardSpacing)) /
                                  cardsPerRow)
                              .clamp(
                                280.0,
                                MinhasDisciplinasProfessorLayout.cardWidth,
                              );

                    return Wrap(
                      spacing: MinhasDisciplinasProfessorLayout.cardSpacing,
                      runSpacing: MinhasDisciplinasProfessorLayout.cardSpacing,
                      children: disciplinas
                          .map((disciplina) {
                            final color = _disciplineColor(disciplina.nome);
                            return DisciplinaCard(
                              disciplina: disciplina,
                              color: color,
                              width: cardWidth,
                              studentLabel: config.studentsLabel.toLowerCase(),
                              activeColor: config.primaryColor, 
                              onEdit: () =>
                                  _openDisciplinaDialog(disciplina: disciplina),
                              onDelete: () => _removeDisciplina(disciplina, config),
                            );
                          })
                          .toList(growable: false),
                    );
                  },
                ),
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

    if (isMobile) {
      return _buildMobileContent(config);
    }

    return Container(
      color: MinhasDisciplinasProfessorColors.background,
      child: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final shellWidth = math.min(
            viewportConstraints.maxWidth,
            MinhasDisciplinasProfessorLayout.maxContentWidth,
          );
          final innerWidth = math.max(
            0.0,
            shellWidth -
                MinhasDisciplinasProfessorLayout.pageLeftPadding -
                MinhasDisciplinasProfessorLayout.pageRightPadding,
          );
          final useDesktopLayout =
              viewportConstraints.maxWidth >=
                  MinhasDisciplinasProfessorLayout.desktopBreakpoint &&
              innerWidth >= 860;
          final mainContentWidth = useDesktopLayout
              ? math.min(
                  MinhasDisciplinasProfessorLayout.desktopMainWidth,
                  math.max(
                    0.0,
                    innerWidth -
                        MinhasDisciplinasProfessorLayout.desktopMenuWidth -
                        MinhasDisciplinasProfessorLayout.sidebarContentGap,
                  ),
                )
              : innerWidth;
          final layout = useDesktopLayout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfessorMenuNav(selectedIndex: 1), 
                    const SizedBox(
                      width: MinhasDisciplinasProfessorLayout.sidebarContentGap,
                    ),
                    _buildMainContent(mainContentWidth, config),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfessorMenuNav(selectedIndex: 1), 
                    const SizedBox(height: 28),
                    _buildMainContent(mainContentWidth, config),
                  ],
                );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: shellWidth),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: MinhasDisciplinasProfessorLayout.pageLeftPadding,
                  right: MinhasDisciplinasProfessorLayout.pageRightPadding,
                  top: MinhasDisciplinasProfessorLayout.pageTopPadding,
                  bottom: MinhasDisciplinasProfessorLayout.pageBottomPadding,
                ),
                child: layout,
              ),
            ),
          );
        },
      ),
    );
  }
}