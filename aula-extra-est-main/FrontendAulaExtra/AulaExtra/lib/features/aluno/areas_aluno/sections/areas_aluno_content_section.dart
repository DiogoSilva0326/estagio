import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_area_summary_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_assets.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/features/aluno/areas_aluno/sections/areas_aluno_mobile_content_section.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/student_area_card.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_filter_chip.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/add_area_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_details_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_mark_lesson_dialog.dart';
import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class AreasAlunoContentSection extends StatefulWidget {
  const AreasAlunoContentSection({super.key});

  @override
  State<AreasAlunoContentSection> createState() =>
      _AreasAlunoContentSectionState();
}

class _AreasAlunoContentSectionState extends State<AreasAlunoContentSection> {
  final EducationService _education = EducationService();
  final ReservationsCalendarService _calendar = ReservationsCalendarService();

  static const _gridPageSize = 4;
  var _gridPagesShown = 1;

  final ScrollController _filterScrollController = ScrollController();
  final TextEditingController _popularSearchController = TextEditingController();

  bool _loading = true;
  String? _error;
  String? _removingDisciplinaId;
  String _popularFilter = 'Todos';
  String _popularSearch = '';

  List<DisciplinaDto> _myDisciplinas = const [];
  List<AreaDto> _areasCatalog = const [];
  Map<String, StudentAreaSummaryDto> _areaSummaries = const {};
  List<StudentCalendarItemDto> _upcomingLessons = const []; 
  String _filterName = 'Todas';

  String _categoryForAreaName(String name) {
    final n = name.trim().toLowerCase();
    if (n.contains('psicolog') || n.contains('terapia') || n.contains('ansiedade') || n.contains('orientação')) return 'Psicologia & Bem-estar';
    if (n.contains('inglês') || n.contains('espanhol') || n.contains('francês') || n.contains('alemão') || n.contains('idioma') || n.contains('língua')) return 'Idiomas';
    if (n.contains('música') || n.contains('piano') || n.contains('guitarra') || n.contains('arte') || n.contains('desenho')) return 'Artes & Música';
    if (n.contains('programação') || n.contains('informática') || n.contains('computador') || n.contains('software')) return 'Tecnologia';
    if (n.contains('universidade') || n.contains('superior') || n.contains('tese') || n.contains('dissertação')) return 'Ensino Superior';
    return 'Disciplinas Escolares';
  }

  List<String> get _popularAreaFilters => [
    'Todos', 
    'Disciplinas Escolares', 
    'Idiomas', 
    'Psicologia & Bem-estar', 
    'Ensino Superior',
    'Tecnologia', 
    'Artes & Música'
  ];

  Map<String, String> get _areaNameById {
    final map = <String, String>{};
    for (final a in _areasCatalog) {
      final id = a.idArea.trim();
      if (id.isEmpty) continue;
      map[id] = a.nome.trim();
    }
    return map;
  }

  Map<String, String> get _areaTargetRoleById {
    final map = <String, String>{};
    for (final a in _areasCatalog) {
      final id = a.idArea.trim();
      if (id.isEmpty) continue;
      
      String role = a.targetRole.trim().toLowerCase();
      final cat = _categoryForAreaName(a.nome);
      if (cat == 'Psicologia & Bem-estar') {
          role = 'psicologia';
      } else if (cat == 'Idiomas' || cat == 'Artes & Música' || cat == 'Tecnologia') {
          role = 'tutoria';
      }
      map[id] = role.isNotEmpty ? role : 'ensino';
    }
    return map;
  }

  List<String> get _filterOptions {
    final byId = _areaNameById;
    final names = _myDisciplinas
        .map((d) => byId[(d.idArea ?? '').trim()] ?? 'Sem área')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList(growable: false);
    final unique = <String>{};
    final ordered = <String>['Todas'];
    for (final n in names) {
      if (unique.add(n)) ordered.add(n);
    }
    return ordered;
  }

  String _assetForAreaName(String name) {
    final n = name.trim().toLowerCase();
    final category = _categoryForAreaName(name);

    if (category == 'Psicologia & Bem-estar') return AreasAlunoAssets.ciencias;
    if (category == 'Idiomas') return AreasAlunoAssets.linguas;
    
    if (n.contains('matem') || n.contains('álgebra') || n.contains('geometr') || n.contains('estat')) {
      return AreasAlunoAssets.matematica;
    }
    return AreasAlunoAssets.ciencias;
  }

  String _areaNameForDisciplina(DisciplinaDto d) {
    final byId = _areaNameById;
    final idArea = (d.idArea ?? '').trim();
    if (idArea.isEmpty) return 'Sem área';
    return byId[idArea]?.trim().isNotEmpty == true
        ? byId[idArea]!.trim()
        : 'Sem área';
  }

  List<DisciplinaDto> get _filteredDisciplinas {
    if (_filterName == 'Todas') return _myDisciplinas;
    return _myDisciplinas
        .where((d) => _areaNameForDisciplina(d) == _filterName)
        .toList(growable: false);
  }

  List<AreaOverview> get _areaOverviews {
    final byArea = <String, List<DisciplinaDto>>{};
    for (final disciplina in _myDisciplinas) {
      final idArea = (disciplina.idArea ?? '').trim();
      if (idArea.isEmpty) continue;
      (byArea[idArea] ??= <DisciplinaDto>[]).add(disciplina);
    }

    final result = <AreaOverview>[];
    byArea.forEach((idArea, disciplinas) {
      final areaName = _areaNameById[idArea] ?? 'Sem área';
      final targetRole = _areaTargetRoleById[idArea] ?? 'ensino'; 
      final summary = _areaSummaries[idArea];

      final areaTokens = <String>{
        areaName.trim().toLowerCase(),
        ...disciplinas.map((d) => d.nome.trim().toLowerCase()),
      }..removeWhere((t) => t.isEmpty);

      final areaUpcoming = _upcomingLessons.where((lesson) {
        final status = lesson.status.trim().toLowerCase();
        if (status.contains('cancel')) return false;

        final subj = lesson.disciplinaName.trim().toLowerCase();
        final title = lesson.lessonTitle.trim().toLowerCase();
        
        if (areaTokens.isEmpty) return true;
        return areaTokens.any((token) => subj.contains(token) || title.contains(token));
      }).toList();

      areaUpcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
      final nextStart = areaUpcoming.isNotEmpty ? areaUpcoming.first.startTime : summary?.nextLessonStart;

      result.add(
        AreaOverview(
          idArea: idArea,
          name: areaName,
          imageAsset: _assetForAreaName(areaName),
          targetRole: targetRole,
          selectedDisciplinaIds: disciplinas
              .map((item) => item.idDisciplina.trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false),
          selectedDisciplinaNames: disciplinas
              .map((item) => item.nome.trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false),
          scheduledLessons: areaUpcoming.length, 
          pendingTasks: 0,
          nextLessonText: _formatNextLesson(nextStart) ?? 'nenhuma',
          nextLessonColor: nextStart != null
              ? const Color(0xFF00A63E)
              : const Color(0xFF4A5565),
        ),
      );
    });

    result.sort((left, right) => left.name.compareTo(right.name));
    return result;
  }

  List<AreasAlunoMobileCatalogItem> get _popularAreas {
    final query = _popularSearch.trim().toLowerCase();
    return _areasCatalog
        .where((area) {
          final name = area.nome.trim();
          if (name.isEmpty) return false;
          
          final category = _categoryForAreaName(name);
          final matchesFilter = _popularFilter == 'Todos' || category == _popularFilter;
          final matchesSearch = query.isEmpty || name.toLowerCase().contains(query);
          
          return matchesFilter && matchesSearch;
        })
        .map((area) {
          return AreasAlunoMobileCatalogItem(
            id: area.idArea,
            name: area.nome.trim(),
            category: _categoryForAreaName(area.nome), 
            imageAsset: _assetForAreaName(area.nome),
          );
        })
        .toList(growable: false);
  }

  Map<String, List<String>> get _selectedDisciplinaNamesByAreaId {
    final map = <String, List<String>>{};
    for (final d in _myDisciplinas) {
      final idArea = (d.idArea ?? '').trim();
      if (idArea.isEmpty) continue;
      final name = d.nome.trim();
      if (name.isEmpty) continue;
      (map[idArea] ??= <String>[]).add(name);
    }
    return map;
  }

  Map<String, List<String>> get _selectedDisciplinaIdsByAreaId {
    final map = <String, List<String>>{};
    for (final d in _myDisciplinas) {
      final idArea = (d.idArea ?? '').trim();
      final idDisciplina = d.idDisciplina.trim();
      if (idArea.isEmpty || idDisciplina.isEmpty) continue;
      (map[idArea] ??= <String>[]).add(idDisciplina);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final mine = await _education.getMyDisciplinas();
      final areas = await _education.getAreas();
      
      List<StudentCalendarItemDto> upcoming = [];
      try {
        upcoming = await _calendar.getMyUpcoming(limit: 50);
      } catch (_) {}

      final areaIds = mine
          .map((item) => (item.idArea ?? '').trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(growable: false);
      
      final summaryEntries = await Future.wait(
        areaIds.map((idArea) async {
          try {
            final summary = await _calendar.getMyAreaSummary(areaId: idArea);
            return MapEntry(idArea, summary);
          } catch (_) {
            return null;
          }
        }),
      );

      if (!mounted) return;
      setState(() {
        _myDisciplinas = mine;
        _areasCatalog = areas;
        _upcomingLessons = upcoming; 
        _areaSummaries = {
          for (final entry in summaryEntries)
            if (entry != null) entry.key: entry.value,
        };
        _loading = false;

        final byId = _areaNameById;
        final currentAreaNames = _myDisciplinas
            .map((d) => byId[(d.idArea ?? '').trim()] ?? 'Sem área')
            .toSet();
        if (_filterName != 'Todas' && !currentAreaNames.contains(_filterName)) {
          _filterName = 'Todas';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Ocorreu um erro ao carregar os seus dados. Por favor, tente novamente.';
      });
    }
  }

  Future<void> _setDisciplinesForArea({
    required String idArea,
    required List<String> allDisciplinaIdsInArea,
    required List<String> selectedIdsInArea,
  }) async {
    final current = <String>{
      for (final d in _myDisciplinas) d.idDisciplina.trim(),
    };

    final areaIds = allDisciplinaIdsInArea
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    current.removeWhere(areaIds.contains);
    current.addAll(
      selectedIdsInArea.map((id) => id.trim()).where((id) => id.isNotEmpty),
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final updated = await _education.setMyDisciplinas(
        ids: current.toList(growable: false),
      );
      if (!mounted) return;
      setState(() {
        _myDisciplinas = updated;
        _loading = false;

        final byId = _areaNameById;
        final currentAreaNames = _myDisciplinas
            .map((d) => byId[(d.idArea ?? '').trim()] ?? 'Sem área')
            .toSet();
        if (_filterName != 'Todas' && !currentAreaNames.contains(_filterName)) {
          _filterName = 'Todas';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Erro ao atualizar as disciplinas.';
      });
    }
  }

  Future<void> _removeDisciplina(DisciplinaDto disciplina) async {
    final idDisciplina = disciplina.idDisciplina.trim();
    if (idDisciplina.isEmpty) return;
    if (_removingDisciplinaId != null) return;

    setState(() => _removingDisciplinaId = idDisciplina);

    try {
      final updated = await _education.removeMyDisciplina(
        idDisciplina: idDisciplina,
      );
      if (!mounted) return;
      setState(() {
        _myDisciplinas = updated;
        _removingDisciplinaId = null;

        final byId = _areaNameById;
        final currentAreaNames = _myDisciplinas
            .map((d) => byId[(d.idArea ?? '').trim()] ?? 'Sem área')
            .toSet();
        if (_filterName != 'Todas' && !currentAreaNames.contains(_filterName)) {
          _filterName = 'Todas';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _removingDisciplinaId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível remover a disciplina.')),
      );
    }
  }

  @override
  void dispose() {
    _filterScrollController.dispose();
    _popularSearchController.dispose();
    super.dispose();
  }

  void _scrollFiltersBy(double delta) {
    if (!_filterScrollController.hasClients) return;
    final max = _filterScrollController.position.maxScrollExtent;
    final next = (_filterScrollController.offset + delta).clamp(0.0, max);
    _filterScrollController.animateTo(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  String? _formatNextLesson(DateTime? start) {
    if (start == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(start.year, start.month, start.day);
    final diff = targetDay.difference(today).inDays;

    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');

    if (diff == 0) return 'hoje $hour:$minute';
    if (diff == 1) return 'amanhã $hour:$minute';
    
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final weekday = weekdays[start.weekday - 1];
    final day = start.day.toString().padLeft(2, '0');
    final month = start.month.toString().padLeft(2, '0');
    return '$weekday, $day/$month • $hour:$minute';
  }

  void _openAddAreaDialog() {
    showAddAreaDialog(
      context,
      areas: _areasCatalog,
      selectedAreaIds: _myDisciplinas
          .map((d) => (d.idArea ?? '').trim())
          .where((id) => id.isNotEmpty)
          .toSet(),
      selectedDisciplinaIds: _myDisciplinas
          .map((d) => d.idDisciplina.trim())
          .where((id) => id.isNotEmpty)
          .toSet(),
      selectedDisciplinaNamesByAreaId: _selectedDisciplinaNamesByAreaId,
      loadDisciplinasByAreaId: (idArea) =>
          _education.getDisciplinasByArea(idArea: idArea),
      onAreaSelectionConfirmed: (idArea, allIdsInArea, selectedIds) =>
          _setDisciplinesForArea(
            idArea: idArea,
            allDisciplinaIdsInArea: allIdsInArea,
            selectedIdsInArea: selectedIds,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;
    final disciplinas = _filteredDisciplinas;
    final filterOptions = _filterOptions;

    final visibleCount = (_gridPagesShown * _gridPageSize).clamp(0, disciplinas.length);
    final visibleDisciplinas = disciplinas.take(visibleCount).toList(growable: false);
    final hasMoreCards = visibleCount < disciplinas.length;

    if (isMobile) {
      return AreasAlunoMobileContentSection(
        loading: _loading,
        error: _error,
        overviews: _areaOverviews,
        popularAreas: _popularAreas,
        popularFilterOptions: _popularAreaFilters, 
        selectedPopularFilter: _popularFilter,
        searchController: _popularSearchController,
        onRetry: _bootstrap,
        onViewDetails: (area) => showAreaDetailsDialog(context, area: area),
        onMarkLesson: (area) => showAreaMarkLessonDialog(context, area: area),
        onAddArea: _loading ? () {} : _openAddAreaDialog,
        onPopularFilterChanged: (value) => setState(() => _popularFilter = value),
        onPopularSearchChanged: (value) => setState(() => _popularSearch = value),
        onPopularAreaTap: (_) {
          if (!_loading) _openAddAreaDialog();
        },
        onExploreTutors: () => Navigator.of(context).pushNamed(Routes.explicadores),
        onBecomeTeacher: () => Navigator.of(context).pushNamed(Routes.becomeTeacher),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AreasAlunoConstants.horizontalPadding,
        vertical: AreasAlunoConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Minhas Áreas e Apoios', style: AreasAlunoConstants.titleStyle),
                        SizedBox(height: 8),
                        Text(
                          'Gerencie as suas áreas de estudo, tutoria e apoio psicológico.',
                          style: AreasAlunoConstants.subtitleStyle,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _openAddAreaDialog,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        label: const Text('Adicionar Nova Área', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AreasAlunoConstants.orangeStart, width: 1.5),
                          foregroundColor: AreasAlunoConstants.orangeStart,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 33),
                SizedBox(
                  width: 984.68,
                  height: 58,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _scrollFiltersBy(-260),
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: AreasAlunoConstants.labelColor,
                        tooltip: 'Anterior',
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _filterScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < filterOptions.length; i++) ...[
                                if (i > 0) const SizedBox(width: AreasAlunoConstants.filterChipGap),
                                AreasFilterChip(
                                  label: filterOptions[i],
                                  selected: _filterName == filterOptions[i],
                                  onTap: () => setState(() {
                                    _filterName = filterOptions[i];
                                    _gridPagesShown = 1;
                                  }),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _scrollFiltersBy(260),
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: AreasAlunoConstants.labelColor,
                        tooltip: 'Seguinte',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 33),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: _bootstrap,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                else if (visibleDisciplinas.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.school_outlined, size: 48, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 16),
                        const Text(
                          'Ainda não tens áreas selecionadas.',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Adiciona disciplinas, tutoria ou apoio psicológico para começares.',
                          style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _openAddAreaDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Explorar Catálogo'),
                        )
                      ],
                    ),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AreasAlunoConstants.gridCrossAxisSpacing,
                          mainAxisSpacing: AreasAlunoConstants.gridMainAxisSpacing,
                          mainAxisExtent: AreasAlunoConstants.gridMainAxisExtent,
                        ),
                        itemCount: visibleDisciplinas.length,
                        itemBuilder: (context, index) {
                          final d = visibleDisciplinas[index];
                          final areaName = _areaNameForDisciplina(d);
                          final asset = _assetForAreaName(areaName);
                          final idArea = (d.idArea ?? '').trim();
                          final targetRole = _areaTargetRoleById[idArea] ?? 'ensino'; 
                          
                          final overview = _areaOverviews.firstWhere(
                            (o) => o.idArea == idArea, 
                            orElse: () => AreaOverview(
                              idArea: idArea,
                              name: areaName,
                              imageAsset: asset,
                              targetRole: targetRole,
                              selectedDisciplinaIds: [],
                              selectedDisciplinaNames: [],
                              scheduledLessons: 0,
                              pendingTasks: 0,
                              nextLessonText: 'nenhuma',
                              nextLessonColor: const Color(0xFF00A63E),
                            )
                          );

                          return StudentAreaCard(
                            disciplina: d,
                            areaName: areaName,
                            imageAsset: asset,
                            targetRole: targetRole,
                            onViewDetails: () => showAreaDetailsDialog(context, area: overview),
                            onMarkLesson: () => showAreaMarkLessonDialog(context, area: overview),
                            onRemove: () => _removeDisciplina(d),
                            scheduledLessons: overview.scheduledLessons,
                            pendingTasks: overview.pendingTasks,
                            nextLessonText: overview.nextLessonText,
                            nextLessonColor: overview.nextLessonColor,
                          );
                        },
                      ),
                      if (hasMoreCards) const SizedBox(height: 24),
                      if (hasMoreCards)
                        Align(
                          alignment: Alignment.center,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _gridPagesShown += 1),
                            icon: const Icon(Icons.expand_more_rounded),
                            label: const Text('Carregar mais'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4A5565),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}