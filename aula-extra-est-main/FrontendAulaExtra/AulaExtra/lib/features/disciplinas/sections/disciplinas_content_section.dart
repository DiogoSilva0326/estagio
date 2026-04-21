import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/disciplinas/constants/disciplinas_mobile_layout.dart';
import 'package:aula_extra/features/disciplinas/sections/disciplinas_mobile_content_section.dart';
import 'package:aula_extra/features/disciplinas/sections/main_content_section.dart';
import 'package:aula_extra/features/disciplinas/sections/sidebar_section.dart';
import 'package:flutter/material.dart';

class DisciplinasContentSection extends StatefulWidget {
  const DisciplinasContentSection({super.key});

  @override
  State<DisciplinasContentSection> createState() =>
      _DisciplinasContentSectionState();
}

class _DisciplinasContentSectionState extends State<DisciplinasContentSection> {
  final EducationService _educationService = EducationService();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  String? _selectedAreaId;
  List<AreaDto> _areas = const [];
  List<DisciplinaDto> _disciplinas = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _educationService.getPublicAreas(),
        _educationService.getPublicDisciplinasWithProfessors(),
      ]);

      final areas = (results[0] as List<AreaDto>)
          .where((area) => area.idArea.trim().isNotEmpty)
          .toList(growable: false);
      final disciplinas = (results[1] as List<DisciplinaDto>)
          .where(
            (disciplina) =>
                disciplina.idDisciplina.trim().isNotEmpty &&
                (disciplina.idArea?.trim().isNotEmpty ?? false),
          )
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _areas = areas;
        _disciplinas = disciplinas;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar as áreas e disciplinas.';
      });
    }
  }

  String _normalize(String value) {
    const source = 'áàâãäåéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÅÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const target = 'aaaaaaeeeeiiiiooooouuuucnAAAAAAEEEEIIIIOOOOOUUUUCN';

    final buffer = StringBuffer();
    for (final rune in value.trim().toLowerCase().runes) {
      final character = String.fromCharCode(rune);
      final index = source.indexOf(character);
      buffer.write(index >= 0 ? target[index].toLowerCase() : character);
    }

    return buffer.toString();
  }

  bool _matchesSearch(String text, String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return true;
    return _normalize(text).contains(normalizedQuery);
  }

  List<AreaDto> get _visibleAreas {
    final filtered = _areas
        .where((area) {
          return _matchesSearch(area.nome, _searchController.text);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final byCount = b.professorCount.compareTo(a.professorCount);
      if (byCount != 0) return byCount;
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });

    return filtered;
  }

  List<DisciplinaDto> get _visibleDisciplinas {
    final filtered = _disciplinas
        .where((disciplina) {
          if (_selectedAreaId == null) return false;
          if (disciplina.idArea != _selectedAreaId) return false;
          return _matchesSearch(disciplina.nome, _searchController.text);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final byCount = b.activeStudentsCount.compareTo(a.activeStudentsCount);
      if (byCount != 0) return byCount;
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });

    return filtered;
  }

  AreaDto? get _selectedArea {
    for (final area in _areas) {
      if (area.idArea == _selectedAreaId) return area;
    }
    return null;
  }

  void _handleAreaSelected(String? areaId) {
    setState(() {
      _selectedAreaId = areaId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return ColoredBox(
        color: DisciplinasMobileLayout.pageBackground,
        child: SizedBox(
          width: double.infinity,
          child: DisciplinasMobileContentSection(
            searchController: _searchController,
            onSearchChanged: (_) => setState(() {}),
            areas: _visibleAreas,
            disciplinas: _visibleDisciplinas,
            selectedArea: _selectedArea,
            onAreaSelected: _handleAreaSelected,
            onClearArea: () => _handleAreaSelected(null),
            loading: _loading,
            error: _error,
          ),
        ),
      );
    }

    return ColoredBox(
      color: const Color(0xFFF9FAFB),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 69),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 53),
              SidebarSection(
                areas: _visibleAreas,
                selectedAreaId: _selectedAreaId,
                onAreaSelected: _handleAreaSelected,
              ),
              Expanded(
                child: MainContentSection(
                  searchController: _searchController,
                  onSearchChanged: (_) => setState(() {}),
                  areas: _visibleAreas,
                  disciplinas: _visibleDisciplinas,
                  selectedArea: _selectedArea,
                  onAreaSelected: _handleAreaSelected,
                  onClearArea: () => _handleAreaSelected(null),
                  loading: _loading,
                  error: _error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
