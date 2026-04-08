import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_assets.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/disciplina_card.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_filter_chip.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/add_area_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_details_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_mark_lesson_dialog.dart';
import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:flutter/material.dart';

class AreasAlunoContentSection extends StatefulWidget {
  const AreasAlunoContentSection({super.key});

  @override
  State<AreasAlunoContentSection> createState() => _AreasAlunoContentSectionState();
}

class _AreasAlunoContentSectionState extends State<AreasAlunoContentSection> {
  final EducationService _education = EducationService();

  static const _gridPageSize = 4;
  var _gridPagesShown = 1;

  final ScrollController _filterScrollController = ScrollController();

  bool _loading = true;
  String? _error;
  String? _removingDisciplinaId;

  List<DisciplinaDto> _myDisciplinas = const [];
  List<AreaDto> _areasCatalog = const [];
  String _filterName = 'Todas';

  Map<String, String> get _areaNameById {
    final map = <String, String>{};
    for (final a in _areasCatalog) {
      final id = a.idArea.trim();
      if (id.isEmpty) continue;
      map[id] = a.nome.trim();
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
    if (n.contains('matem') || n.contains('álgebra') || n.contains('algebra') || n.contains('geometr') || n.contains('trigonom') || n.contains('cálculo') || n.contains('calculo') || n.contains('estat')) {
      return AreasAlunoAssets.matematica;
    }

    if (n.contains('ingl') || n.contains('portugu') || n.contains('espan') || n.contains('franc') || n.contains('alem')) {
      return AreasAlunoAssets.linguas;
    }

    return AreasAlunoAssets.ciencias;
  }

  String _areaNameForDisciplina(DisciplinaDto d) {
    final byId = _areaNameById;
    final idArea = (d.idArea ?? '').trim();
    if (idArea.isEmpty) return 'Sem área';
    return byId[idArea]?.trim().isNotEmpty == true ? byId[idArea]!.trim() : 'Sem área';
  }

  List<DisciplinaDto> get _filteredDisciplinas {
    if (_filterName == 'Todas') return _myDisciplinas;
    return _myDisciplinas
        .where((d) => _areaNameForDisciplina(d) == _filterName)
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

      if (!mounted) return;
      setState(() {
        _myDisciplinas = mine;
        _areasCatalog = areas;
        _loading = false;

        // Keep filter valid.
        final byId = _areaNameById;
        final currentAreaNames = _myDisciplinas
            .map((d) => byId[(d.idArea ?? '').trim()] ?? 'Sem área')
            .toSet();
        if (_filterName != 'Todas' && !currentAreaNames.contains(_filterName)) _filterName = 'Todas';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
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
      selectedIdsInArea
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty),
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final updated = await _education.setMyDisciplinas(ids: current.toList(growable: false));
      if (!mounted) return;
      setState(() {
        _myDisciplinas = updated;
        _loading = false;

        final byId = _areaNameById;
        final currentAreaNames = _myDisciplinas
            .map((d) => byId[(d.idArea ?? '').trim()] ?? 'Sem área')
            .toSet();
        if (_filterName != 'Todas' && !currentAreaNames.contains(_filterName)) _filterName = 'Todas';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _removeDisciplina(DisciplinaDto disciplina) async {
    final idDisciplina = disciplina.idDisciplina.trim();
    if (idDisciplina.isEmpty) return;
    if (_removingDisciplinaId != null) return;

    setState(() => _removingDisciplinaId = idDisciplina);

    try {
      final updated = await _education.removeMyDisciplina(idDisciplina: idDisciplina);
      if (!mounted) return;
      setState(() {
        _myDisciplinas = updated;
        _removingDisciplinaId = null;

        final byId = _areaNameById;
        final currentAreaNames = _myDisciplinas
            .map((d) => byId[(d.idArea ?? '').trim()] ?? 'Sem área')
            .toSet();
        if (_filterName != 'Todas' && !currentAreaNames.contains(_filterName)) _filterName = 'Todas';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _removingDisciplinaId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível remover a disciplina: $e')),
      );
    }
  }

  @override
  void dispose() {
    _filterScrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final disciplinas = _filteredDisciplinas;
    final filterOptions = _filterOptions;

    final visibleCount = (_gridPagesShown * _gridPageSize).clamp(0, disciplinas.length);
    final visibleDisciplinas = disciplinas.take(visibleCount).toList(growable: false);
    final hasMoreCards = visibleCount < disciplinas.length;

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
                const Text(
                  'Minhas Áreas',
                  style: AreasAlunoConstants.titleStyle,
                ),
                const SizedBox(height: 11.064),
                const Text(
                  'Gerencie suas disciplinas e acompanhe seu progresso',
                  style: AreasAlunoConstants.subtitleStyle,
                ),
                const SizedBox(height: 33),
                SizedBox(
                  width: 984.68,
                  height: 58.085,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _scrollFiltersBy(-260),
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: AreasAlunoConstants.labelColor,
                        tooltip: 'Anterior',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 40, height: 58.085),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _filterScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < filterOptions.length; i++) ...[
                                if (i > 0)
                                  const SizedBox(width: AreasAlunoConstants.filterChipGap),
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
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 40, height: 58.085),
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
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: _bootstrap,
                          child: const Text('Tentar novamente'),
                        ),
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
                          final selectedIds = _selectedDisciplinaIdsByAreaId[idArea] ?? const <String>[];
                          final selectedNames = _selectedDisciplinaNamesByAreaId[idArea] ?? const <String>[];
                          final overview = AreaOverview(
                            idArea: idArea,
                            name: areaName,
                            imageAsset: asset,
                            selectedDisciplinaIds: selectedIds,
                            selectedDisciplinaNames: selectedNames,
                            scheduledLessons: 0,
                            pendingTasks: 0,
                            nextLessonText: 'nenhuma',
                            nextLessonColor: const Color(0xFF00A63E),
                          );

                          return DisciplinaCard(
                            disciplina: d,
                            areaName: areaName,
                            imageAsset: asset,
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
                      if (hasMoreCards)
                        const SizedBox(height: 18),
                      if (hasMoreCards)
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _gridPagesShown += 1),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AreasAlunoConstants.orangeStart,
                                width: AreasAlunoConstants.addAreaButtonBorderWidth,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AreasAlunoConstants.addAreaButtonRadius),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                              minimumSize: const Size(0, 56),
                              foregroundColor: AreasAlunoConstants.orangeStart,
                              textStyle: AreasAlunoConstants.addAreaTextStyle.copyWith(
                                color: AreasAlunoConstants.orangeStart,
                                fontSize: 20,
                                height: 28 / 20,
                              ),
                            ),
                            child: const Text('Ver mais'),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 33),
                SizedBox(
                  width: 311.581,
                  height: 71.915,
                  child: OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => showAddAreaDialog(
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
                              loadDisciplinasByAreaId: (idArea) => _education.getDisciplinasByArea(idArea: idArea),
                              onAreaSelectionConfirmed: (idArea, allIdsInArea, selectedIds) => _setDisciplinesForArea(
                                idArea: idArea,
                                allDisciplinaIdsInArea: allIdsInArea,
                                selectedIdsInArea: selectedIds,
                              ),
                            ),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: AreasAlunoConstants.addAreaIconSize,
                      color: AreasAlunoConstants.labelColor,
                    ),
                    label: const Text(
                      'Adicionar Nova Área',
                      style: AreasAlunoConstants.addAreaTextStyle,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AreasAlunoConstants.addAreaButtonBorderColor,
                        width: AreasAlunoConstants.addAreaButtonBorderWidth,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AreasAlunoConstants.addAreaButtonRadius),
                      ),
                      padding: const EdgeInsets.all(AreasAlunoConstants.addAreaButtonBorderWidth),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

