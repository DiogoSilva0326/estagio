import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_category_option.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_discipline_selection_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_filter_chip.dart';
import 'package:flutter/material.dart';

Future<void> showAddAreaDialog(
  BuildContext context, {
  required List<AreaDto> areas,
  required Set<String> selectedAreaIds,
  required Set<String> selectedDisciplinaIds,
  required Map<String, List<String>> selectedDisciplinaNamesByAreaId,
  required Future<List<DisciplinaDto>> Function(String idArea) loadDisciplinasByAreaId,
  required Future<void> Function(
    String idArea,
    List<String> allDisciplinaIdsInArea,
    List<String> selectedIdsInArea,
  ) onAreaSelectionConfirmed,
}) {
  final isMobile = MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;
  if (isMobile) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Escolha um Apoio',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, _) => _AddAreaMobileDialog(
        parentContext: context,
        areas: areas,
        selectedAreaIds: selectedAreaIds,
        selectedDisciplinaIds: selectedDisciplinaIds,
        selectedDisciplinaNamesByAreaId: selectedDisciplinaNamesByAreaId,
        loadDisciplinasByAreaId: loadDisciplinasByAreaId,
        onAreaSelectionConfirmed: onAreaSelectionConfirmed,
      ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AddAreaDialog(
      parentContext: context,
      areas: areas,
      selectedAreaIds: selectedAreaIds,
      selectedDisciplinaIds: selectedDisciplinaIds,
      selectedDisciplinaNamesByAreaId: selectedDisciplinaNamesByAreaId,
      loadDisciplinasByAreaId: loadDisciplinasByAreaId,
      onAreaSelectionConfirmed: onAreaSelectionConfirmed,
    ),
  );
}

String _categoryForAreaName(String name) {
  final n = name.trim().toLowerCase();
  if (n.contains('psicolog') || n.contains('terapia') || n.contains('ansiedade') || n.contains('orientação')) return 'Psicologia & Bem-estar';
  if (n.contains('inglês') || n.contains('espanhol') || n.contains('francês') || n.contains('alemão') || n.contains('idioma') || n.contains('língua')) return 'Idiomas';
  if (n.contains('música') || n.contains('piano') || n.contains('guitarra') || n.contains('arte') || n.contains('desenho')) return 'Artes & Música';
  if (n.contains('programação') || n.contains('informática') || n.contains('computador') || n.contains('software')) return 'Tecnologia';
  if (n.contains('universidade') || n.contains('superior') || n.contains('tese') || n.contains('dissertação')) return 'Ensino Superior';
  return 'Disciplinas Escolares'; 
}

const _filterOptions = [
  'Todas', 
  'Disciplinas Escolares', 
  'Idiomas', 
  'Psicologia & Bem-estar', 
  'Ensino Superior',
  'Tecnologia', 
  'Artes & Música'
];

class AddAreaDialog extends StatefulWidget {
  const AddAreaDialog({
    super.key,
    required this.parentContext,
    required this.areas,
    required this.selectedAreaIds,
    required this.selectedDisciplinaIds,
    required this.selectedDisciplinaNamesByAreaId,
    required this.loadDisciplinasByAreaId,
    required this.onAreaSelectionConfirmed,
  });

  final BuildContext parentContext;
  final List<AreaDto> areas;
  final Set<String> selectedAreaIds;
  final Set<String> selectedDisciplinaIds;
  final Map<String, List<String>> selectedDisciplinaNamesByAreaId;
  final Future<List<DisciplinaDto>> Function(String idArea) loadDisciplinasByAreaId;
  final Future<void> Function(
    String idArea,
    List<String> allDisciplinaIdsInArea,
    List<String> selectedIdsInArea,
  ) onAreaSelectionConfirmed;

  @override
  State<AddAreaDialog> createState() => _AddAreaDialogState();
}

class _AddAreaDialogState extends State<AddAreaDialog> {
  static const _dialogRadius = 24.0;
  String _selectedCategory = 'Todas';

  @override
  Widget build(BuildContext context) {
    final filteredAreas = widget.areas.where((area) {
      if (_selectedCategory == 'Todas') return true;
      return _categoryForAreaName(area.nome) == _selectedCategory;
    }).toList();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_dialogRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1024),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(onClose: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterOptions.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AreasFilterChip(
                        label: filter,
                        selected: _selectedCategory == filter,
                        onTap: () {
                          setState(() {
                            _selectedCategory = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: filteredAreas.isEmpty 
                ? const Center(child: Text('Nenhuma área encontrada nesta categoria.', style: TextStyle(color: Colors.grey)))
                : Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 39, 0),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 255,
                    ),
                    itemCount: filteredAreas.length,
                    itemBuilder: (context, index) {
                      final area = filteredAreas[index];
                      final visual = _visualForAreaName(area.nome);

                      final selectedNames = widget.selectedDisciplinaNamesByAreaId[area.idArea] ?? const <String>[];
                      final isSelected = selectedNames.isNotEmpty || widget.selectedAreaIds.contains(area.idArea);

                      return _AreaOptionCard(
                        option: visual,
                        selected: isSelected,
                        selectedDisciplinaNames: selectedNames,
                        onTap: () async {
                          final navigator = Navigator.of(widget.parentContext);
                          Navigator.of(context).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            showDialog<void>(
                              context: navigator.context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            List<DisciplinaDto> disciplinas;
                            try {
                              disciplinas = await widget.loadDisciplinasByAreaId(area.idArea);
                            } catch (e) {
                              if (!navigator.mounted) return;
                              if (navigator.canPop()) navigator.pop();
                              ScaffoldMessenger.of(navigator.context).showSnackBar(
                                SnackBar(content: Text('Erro ao carregar opções: $e')),
                              );
                              return;
                            }

                            if (!navigator.mounted) return;
                            if (navigator.canPop()) navigator.pop();

                            final selectedIds = await showAreaDisciplineSelectionDialog(
                              navigator.context,
                              areaName: area.nome,
                              imageAsset: visual.imageAsset,
                              gradientStart: visual.gradientStart,
                              gradientEnd: visual.gradientEnd,
                              disciplinas: disciplinas,
                              initialSelectedIds: disciplinas
                                  .map((d) => d.idDisciplina.trim())
                                  .where((id) => id.isNotEmpty && widget.selectedDisciplinaIds.contains(id))
                                  .toList(growable: false),
                            );

                            if (!navigator.mounted) return;
                            if (selectedIds == null) return;

                            final allIdsInArea = disciplinas
                                .map((d) => d.idDisciplina.trim())
                                .where((id) => id.isNotEmpty)
                                .toList(growable: false);

                            await widget.onAreaSelectionConfirmed(
                              area.idArea,
                              allIdsInArea,
                              selectedIds,
                            );
                          });
                        },
                      );
                    },
                  ),
                ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: const Text(
                'Após escolher a área, você poderá gerir os serviços e apoios específicos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4A5565),
                  height: 20 / 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAreaMobileDialog extends StatefulWidget {
  const _AddAreaMobileDialog({
    required this.parentContext,
    required this.areas,
    required this.selectedAreaIds,
    required this.selectedDisciplinaIds,
    required this.selectedDisciplinaNamesByAreaId,
    required this.loadDisciplinasByAreaId,
    required this.onAreaSelectionConfirmed,
  });

  final BuildContext parentContext;
  final List<AreaDto> areas;
  final Set<String> selectedAreaIds;
  final Set<String> selectedDisciplinaIds;
  final Map<String, List<String>> selectedDisciplinaNamesByAreaId;
  final Future<List<DisciplinaDto>> Function(String idArea) loadDisciplinasByAreaId;
  final Future<void> Function(
    String idArea,
    List<String> allDisciplinaIdsInArea,
    List<String> selectedIdsInArea,
  ) onAreaSelectionConfirmed;

  @override
  State<_AddAreaMobileDialog> createState() => _AddAreaMobileDialogState();
}

class _AddAreaMobileDialogState extends State<_AddAreaMobileDialog> {
  String _selectedCategory = 'Todas';

  Future<void> _handleTap(BuildContext context, AreaDto area) async {
    final visual = _visualForAreaName(area.nome);
    final navigator = Navigator.of(widget.parentContext);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog<void>(
        context: navigator.context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      List<DisciplinaDto> disciplinas;
      try {
        disciplinas = await widget.loadDisciplinasByAreaId(area.idArea);
      } catch (e) {
        if (!navigator.mounted) return;
        if (navigator.canPop()) navigator.pop();
        ScaffoldMessenger.of(navigator.context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar serviços: $e')),
        );
        return;
      }

      if (!navigator.mounted) return;
      if (navigator.canPop()) navigator.pop();

      final selectedIds = await showAreaDisciplineSelectionDialog(
        navigator.context,
        areaName: area.nome,
        imageAsset: visual.imageAsset,
        gradientStart: visual.gradientStart,
        gradientEnd: visual.gradientEnd,
        disciplinas: disciplinas,
        initialSelectedIds: disciplinas
            .map((d) => d.idDisciplina.trim())
            .where((id) => id.isNotEmpty && widget.selectedDisciplinaIds.contains(id))
            .toList(growable: false),
      );

      if (!navigator.mounted || selectedIds == null) return;

      final allIdsInArea = disciplinas
          .map((d) => d.idDisciplina.trim())
          .where((id) => id.isNotEmpty)
          .toList(growable: false);

      await widget.onAreaSelectionConfirmed(area.idArea, allIdsInArea, selectedIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredAreas = widget.areas.where((area) {
      if (_selectedCategory == 'Todas') return true;
      return _categoryForAreaName(area.nome) == _selectedCategory;
    }).toList();

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionar Apoio',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selecione a área geral que deseja adicionar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A5565),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF364153),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filterOptions.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AreasFilterChip(
                        label: filter,
                        selected: _selectedCategory == filter,
                        onTap: () {
                          setState(() {
                            _selectedCategory = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: filteredAreas.isEmpty 
                ? const Center(child: Text('Nenhuma área encontrada.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filteredAreas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final area = filteredAreas[index];
                    final visual = _visualForAreaName(area.nome);
                    final selectedNames = widget.selectedDisciplinaNamesByAreaId[area.idArea] ?? const <String>[];
                    final isSelected = selectedNames.isNotEmpty || widget.selectedAreaIds.contains(area.idArea);

                    return _MobileAreaOptionCard(
                      option: visual,
                      selected: isSelected,
                      selectedDisciplinaNames: selectedNames,
                      onTap: () => _handleTap(context, area),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 117,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar Área de Apoio',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                  height: 36 / 30,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Selecione a área geral de estudo, tutoria ou psicologia.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4A5565),
                  height: 28 / 18,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onClose,
                child: const Center(
                  child: Icon(Icons.close, size: 24, color: Color(0xFF364153)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

AreaCategoryOption _visualForAreaName(String name) {
  final n = name.trim().toLowerCase();
  for (final opt in areaCategoryOptions) {
    if (opt.name.trim().toLowerCase() == n) return opt;
  }

  final fallback = areaCategoryOptions.first;
  return AreaCategoryOption(
    id: fallback.id,
    name: name.trim().isEmpty ? fallback.name : name,
    subtitle: fallback.subtitle,
    imageAsset: fallback.imageAsset,
    gradientStart: fallback.gradientStart,
    gradientEnd: fallback.gradientEnd,
    disciplines: const [],
  );
}

class _AreaOptionCard extends StatelessWidget {
  const _AreaOptionCard({
    required this.option,
    required this.selected,
    required this.selectedDisciplinaNames,
    required this.onTap,
  });

  final AreaCategoryOption option;
  final bool selected;
  final List<String> selectedDisciplinaNames;
  final VoidCallback onTap;

  static const _border = Color(0xFFE5E7EB);
  static const _chipBg = Color(0xFFF3F4F6);
  static const _chipText = Color(0xFF364153);
  static const _chipSpacing = 8.0;
  static const _chipRunSpacing = 8.0;
  static const _chipHPadding = 12.0;
  static const _chipVPadding = 4.0;

  static const _chipTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _chipText,
    height: 20 / 14,
  );

  @override
  Widget build(BuildContext context) {
    return _AreaOptionCardPaged(
      option: option,
      selected: selected,
      selectedDisciplinaNames: selectedDisciplinaNames,
      onTap: onTap,
      chipBg: _chipBg,
      chipTextStyle: _chipTextStyle,
      chipSpacing: _chipSpacing,
      chipRunSpacing: _chipRunSpacing,
      chipHPadding: _chipHPadding,
      chipVPadding: _chipVPadding,
    );
  }
}

class _AreaOptionCardPaged extends StatefulWidget {
  const _AreaOptionCardPaged({
    required this.option,
    required this.selected,
    required this.selectedDisciplinaNames,
    required this.onTap,
    required this.chipBg,
    required this.chipTextStyle,
    required this.chipSpacing,
    required this.chipRunSpacing,
    required this.chipHPadding,
    required this.chipVPadding,
  });

  final AreaCategoryOption option;
  final bool selected;
  final List<String> selectedDisciplinaNames;
  final VoidCallback onTap;

  final Color chipBg;
  final TextStyle chipTextStyle;
  final double chipSpacing;
  final double chipRunSpacing;
  final double chipHPadding;
  final double chipVPadding;

  @override
  State<_AreaOptionCardPaged> createState() => _AreaOptionCardPagedState();
}

class _AreaOptionCardPagedState extends State<_AreaOptionCardPaged> {
  static const _pageSize = 8;
  var _pagesShown = 1;

  @override
  Widget build(BuildContext context) {
    final option = widget.option;
    final selectedSet = widget.selectedDisciplinaNames
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet();

    final all = option.disciplines
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    final visibleCount = (_pagesShown * _pageSize).clamp(0, all.length);
    final visible = all.take(visibleCount).toList(growable: false);
    final hasMore = visibleCount < all.length;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _AreaOptionCard._border, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [option.gradientStart, option.gradientEnd],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.10),
                          offset: Offset(0, 4),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.10),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        option.imageAsset,
                        width: 81.702,
                        height: 81.702,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF101828),
                            height: 32 / 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A5565),
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF3F4F6), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Opções incluídas:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A5565),
                      height: 20 / 14,
                    ),
                  ),
                  Text(
                    'Selecionadas: ${selectedSet.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A5565),
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LimitedChipWrap(
                      labels: visible,
                      selected: selectedSet,
                      maxLines: 2,
                      spacing: widget.chipSpacing,
                      runSpacing: widget.chipRunSpacing,
                      chipHPadding: widget.chipHPadding,
                      chipVPadding: widget.chipVPadding,
                      baseTextStyle: widget.chipTextStyle,
                      chipBg: widget.chipBg,
                      selectedBg: AreasAlunoConstants.orangeStart.withValues(alpha: 0.12),
                      forceEllipsis: hasMore,
                    ),
                    if (hasMore)
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _pagesShown += 1),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AreasAlunoConstants.orangeStart,
                              width: AreasAlunoConstants.addAreaButtonBorderWidth,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AreasAlunoConstants.addAreaButtonRadius,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            foregroundColor: AreasAlunoConstants.orangeStart,
                            textStyle: AreasAlunoConstants.addAreaTextStyle.copyWith(
                              color: AreasAlunoConstants.orangeStart,
                              fontSize: 18,
                              height: 24 / 18,
                            ),
                          ),
                          child: const Text('Ver mais'),
                        ),
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

class _LimitedChipWrap extends StatelessWidget {
  const _LimitedChipWrap({
    required this.labels,
    required this.selected,
    required this.maxLines,
    required this.spacing,
    required this.runSpacing,
    required this.chipHPadding,
    required this.chipVPadding,
    required this.baseTextStyle,
    required this.chipBg,
    required this.selectedBg,
    this.forceEllipsis = false,
  });

  final List<String> labels;
  final Set<String> selected;
  final int maxLines;
  final double spacing;
  final double runSpacing;
  final double chipHPadding;
  final double chipVPadding;
  final TextStyle baseTextStyle;
  final Color chipBg;
  final Color selectedBg;
  final bool forceEllipsis;

  double _chipWidth(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: baseTextStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return painter.width + (chipHPadding * 2);
  }

  @override
  Widget build(BuildContext context) {
    final cleaned = labels
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    if (cleaned.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth <= 0) return const SizedBox.shrink();

        final ellipsisLabel = '...';
        final ellipsisWidth = _chipWidth(ellipsisLabel);

        final shown = <String>[];
        var line = 1;
        var x = 0.0;
        var overflowed = false;

        for (final label in cleaned) {
          final w = _chipWidth(label);
          final needed = (shown.isEmpty || x == 0.0) ? w : (spacing + w);

          if (x + needed <= maxWidth) {
            shown.add(label);
            x += needed;
            continue;
          }

          if (line >= maxLines) {
            overflowed = true;
            break;
          }

          line += 1;
          x = 0.0;

          if (w <= maxWidth) {
            shown.add(label);
            x = w;
          } else {
            overflowed = true;
            break;
          }
        }

        if (overflowed || forceEllipsis) {
          while (shown.isNotEmpty) {
            var l = 1;
            var cx = 0.0;
            var fits = true;

            for (var i = 0; i < shown.length; i++) {
              final w = _chipWidth(shown[i]);
              final needed = (cx == 0.0) ? w : (spacing + w);
              if (cx + needed <= maxWidth) {
                cx += needed;
              } else {
                if (l >= maxLines) {
                  fits = false;
                  break;
                }
                l += 1;
                cx = w;
              }
            }

            if (fits) {
              final ellipsisNeeded = (cx == 0.0)
                  ? ellipsisWidth
                  : (spacing + ellipsisWidth);
              if (cx + ellipsisNeeded <= maxWidth) break;
            }

            shown.removeLast();
          }
        }

        final showEllipsis = overflowed || forceEllipsis;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final label in shown)
              _Chip(
                label: label,
                selected: selected.contains(label),
                chipBg: chipBg,
                selectedBg: selectedBg,
                chipHPadding: chipHPadding,
                chipVPadding: chipVPadding,
                baseTextStyle: baseTextStyle,
              ),
            if (showEllipsis)
              _Chip(
                label: ellipsisLabel,
                selected: false,
                chipBg: chipBg,
                selectedBg: selectedBg,
                chipHPadding: chipHPadding,
                chipVPadding: chipVPadding,
                baseTextStyle: baseTextStyle,
              ),
          ],
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.chipBg,
    required this.selectedBg,
    required this.chipHPadding,
    required this.chipVPadding,
    required this.baseTextStyle,
  });

  final String label;
  final bool selected;
  final Color chipBg;
  final Color selectedBg;
  final double chipHPadding;
  final double chipVPadding;
  final TextStyle baseTextStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: chipHPadding,
        vertical: chipVPadding,
      ),
      decoration: BoxDecoration(
        color: selected ? selectedBg : chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.clip,
        softWrap: false,
        style: selected
            ? baseTextStyle.copyWith(fontWeight: FontWeight.w500)
            : baseTextStyle,
      ),
    );
  }
}

class _MobileAreaOptionCard extends StatelessWidget {
  const _MobileAreaOptionCard({
    required this.option,
    required this.selected,
    required this.selectedDisciplinaNames,
    required this.onTap,
  });

  final AreaCategoryOption option;
  final bool selected;
  final List<String> selectedDisciplinaNames;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AreasAlunoConstants.orangeStart
                  : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [option.gradientStart, option.gradientEnd],
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        option.imageAsset,
                        width: 54,
                        height: 54,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A5565),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF4A5565),
                  ),
                ],
              ),
              if (selectedDisciplinaNames.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final disciplina in selectedDisciplinaNames.take(4))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AreasAlunoConstants.orangeStart.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          disciplina,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF364153),
                          ),
                        ),
                      ),
                    if (selectedDisciplinaNames.length > 4)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${selectedDisciplinaNames.length - 4}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF364153),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}