import 'dart:math' as math;

import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasProfessorContentSection extends StatefulWidget {
  const MinhasDisciplinasProfessorContentSection({super.key});

  @override
  State<MinhasDisciplinasProfessorContentSection> createState() =>
      _MinhasDisciplinasProfessorContentSectionState();
}

class _MinhasDisciplinasProfessorContentSectionState
    extends State<MinhasDisciplinasProfessorContentSection> {
  static const _background = Color(0xFFF9F9F9);
  static const _titleColor = Color(0xFF101828);
  static const _subtitleColor = Color(0xFF4A5565);
  static const _cardBorder = Color(0xFFE5E7EB);
  static const _cardShadow = Color(0x1A000000);
  static const _buttonGradientTop = Color(0xFFF15C64);
  static const _buttonGradientBottom = Color(0xFFFC9039);
  static const _dangerBorder = Color(0xFFFFA2A2);
  static const _dangerIcon = Color(0xFFFB2C36);
  static const _summaryWidth = 318.0;
  static const _summaryHeight = 123.271;
  static const _cardWidth = 318.0;
  static const _cardMinHeight = 304.0;
  static const _desktopMenuWidth = 307.765;
  static const _desktopMainWidth = 1009.0;
  static const _pageLeftPadding = 54.0;
  static const _pageRightPadding = 41.0;
  static const _pageTopPadding = 118.0;
  static const _pageBottomPadding = 90.0;
  static const _sidebarContentGap = 28.235;
  static const _titleBottomGap = 44.0;
  static const _maxContentWidth = 1440.0;
  static const _desktopBreakpoint = 1180.0;

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
    final disciplinas = await _professorsService.getMyDisciplinas();
    _disciplinas = disciplinas
        .where((item) => item.isActive)
        .toList(growable: false);
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
      final results = await Future.wait([
        _educationService.getAreas(),
        _educationService.getCiclosEstudo(),
        _educationService.getCatalog(),
      ]);
      if (!mounted) return;

      final formResult = await showDialog<_ProfessorDisciplinaDialogResult>(
        context: context,
        barrierDismissible: true,
        builder: (context) => _ProfessorDisciplinaDialog(
          areas: results[0] as List<AreaDto>,
          ciclos: results[1] as List<CicloEstudoDto>,
          catalog: results[2] as List<DisciplinaDto>,
          initialDisciplina: disciplina,
        ),
      );

      if (formResult == null) return;

      final updated = disciplina == null
          ? await _professorsService.createMyDisciplina(
              idDisciplina: formResult.idDisciplina,
              idArea: formResult.idArea,
              idCicloEstudo: formResult.idCicloEstudo,
              nome: formResult.nome,
              descricao: formResult.descricao,
            )
          : await _professorsService.updateMyDisciplina(
              currentIdDisciplina: disciplina.idDisciplina,
              idDisciplina: formResult.idDisciplina,
              idArea: formResult.idArea,
              idCicloEstudo: formResult.idCicloEstudo,
              nome: formResult.nome,
              descricao: formResult.descricao,
            );

      if (!mounted) return;
      setState(() {
        _disciplinas = updated
            .where((item) => item.isActive)
            .toList(growable: false);
        _disciplinasFuture = Future.value(_disciplinas);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            disciplina == null
                ? 'Não foi possível criar a disciplina: $error'
                : 'Não foi possível atualizar a disciplina: $error',
          ),
        ),
      );
    }
  }

  Future<void> _removeDisciplina(DisciplinaDto disciplina) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar disciplina'),
        content: Text(
          'Deseja desativar `${disciplina.nome}`? O registo será mantido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final updated = await _professorsService.removeMyDisciplina(
        idDisciplina: disciplina.idDisciplina,
      );
      if (!mounted) return;
      setState(() {
        _disciplinas = updated
            .where((item) => item.isActive)
            .toList(growable: false);
        _disciplinasFuture = Future.value(_disciplinas);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível eliminar a disciplina: $error'),
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

  Widget _buildMainContent(double width) {
    const titleStyle = TextStyle(
      color: _titleColor,
      fontSize: 41.09,
      height: 45.656 / 41.09,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.42,
    );
    const subtitleStyle = TextStyle(
      color: _subtitleColor,
      fontSize: 18.262,
      height: 27.394 / 18.262,
    );

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
                const Text('Minhas Disciplinas', style: titleStyle),
                const SizedBox(height: 12),
                Text(
                  'Não foi possível carregar as disciplinas: ${snapshot.error}',
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
          _disciplinas = disciplinas;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, headerConstraints) {
                  final stackButton = headerConstraints.maxWidth < 760;

                  if (stackButton) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Minhas Disciplinas', style: titleStyle),
                        const SizedBox(height: 9.131),
                        const Text(
                          'Crie, edite e organize as disciplinas que leciona.',
                          style: subtitleStyle,
                        ),
                        const SizedBox(height: 18),
                        _PrimaryActionButton(
                          label: 'Nova Disciplina',
                          icon: Icons.add_rounded,
                          onTap: _openDisciplinaDialog,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Minhas Disciplinas', style: titleStyle),
                            SizedBox(height: 9.131),
                            Text(
                              'Crie, edite e organize as disciplinas que leciona.',
                              style: subtitleStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _PrimaryActionButton(
                        label: 'Nova Disciplina',
                        icon: Icons.add_rounded,
                        onTap: _openDisciplinaDialog,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: _titleBottomGap),
              LayoutBuilder(
                builder: (context, summaryConstraints) {
                  final availableWidth = summaryConstraints.maxWidth;
                  final summaryCardsPerRow = math.max(
                    1,
                    ((availableWidth + 27.394) / (_summaryWidth + 27.394))
                        .floor(),
                  );
                  final summaryWidth = summaryCardsPerRow >= 3
                      ? _summaryWidth
                      : summaryCardsPerRow == 1
                      ? availableWidth
                      : ((availableWidth -
                                    ((summaryCardsPerRow - 1) * 27.394)) /
                                summaryCardsPerRow)
                            .clamp(260.0, _summaryWidth);

                  return Wrap(
                    spacing: 27.394,
                    runSpacing: 18.262,
                    children: [
                      _SummaryBox(
                        width: summaryWidth,
                        label: 'Total de Disciplinas',
                        value: '${disciplinas.length}',
                      ),
                      _SummaryBox(
                        width: summaryWidth,
                        label: 'Total de Alunos',
                        value: '${_totalStudents(disciplinas)}',
                      ),
                      _SummaryBox(
                        width: summaryWidth,
                        label: 'Média por Disciplina',
                        value: '${_averageStudents(disciplinas)}',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 27.394),
              if (disciplinas.isEmpty)
                _EmptyStateCard(onTap: _openDisciplinaDialog)
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final cardsPerRow = math.max(
                      1,
                      ((availableWidth + 27.394) / (_cardWidth + 27.394))
                          .floor(),
                    );
                    final cardWidth = cardsPerRow >= 3
                        ? _cardWidth
                        : cardsPerRow == 1
                        ? availableWidth
                        : ((availableWidth - ((cardsPerRow - 1) * 27.394)) /
                                  cardsPerRow)
                              .clamp(280.0, _cardWidth);

                    return Wrap(
                      spacing: 27.394,
                      runSpacing: 27.394,
                      children: disciplinas
                          .map((disciplina) {
                            final color = _disciplineColor(disciplina.nome);
                            return _DisciplinaCard(
                              disciplina: disciplina,
                              color: color,
                              width: cardWidth,
                              onEdit: () =>
                                  _openDisciplinaDialog(disciplina: disciplina),
                              onDelete: () => _removeDisciplina(disciplina),
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
    return Container(
      color: _background,
      child: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final shellWidth = math.min(
            viewportConstraints.maxWidth,
            _maxContentWidth,
          );
          final innerWidth = math.max(
            0.0,
            shellWidth - _pageLeftPadding - _pageRightPadding,
          );
          final useDesktopLayout =
              viewportConstraints.maxWidth >= _desktopBreakpoint &&
              innerWidth >= 860;
          final mainContentWidth = useDesktopLayout
              ? math.min(
                  _desktopMainWidth,
                  math.max(
                    0.0,
                    innerWidth - _desktopMenuWidth - _sidebarContentGap,
                  ),
                )
              : innerWidth;
          final layout = useDesktopLayout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfessorMenuNav(selectedIndex: 1),
                    const SizedBox(width: _sidebarContentGap),
                    _buildMainContent(mainContentWidth),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfessorMenuNav(selectedIndex: 1),
                    const SizedBox(height: 28),
                    _buildMainContent(mainContentWidth),
                  ],
                );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: shellWidth),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: _pageLeftPadding,
                  right: _pageRightPadding,
                  top: _pageTopPadding,
                  bottom: _pageBottomPadding,
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

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(
        minHeight:
            _MinhasDisciplinasProfessorContentSectionState._summaryHeight,
      ),
      padding: const EdgeInsets.fromLTRB(27.394, 27.394, 27.394, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.262),
        boxShadow: const [
          BoxShadow(
            color: _MinhasDisciplinasProfessorContentSectionState._cardShadow,
            blurRadius: 3.424,
            offset: Offset(0, 1.141),
          ),
          BoxShadow(
            color: _MinhasDisciplinasProfessorContentSectionState._cardShadow,
            blurRadius: 2.283,
            offset: Offset(0, 1.141),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color:
                  _MinhasDisciplinasProfessorContentSectionState._subtitleColor,
              fontSize: 15.98,
              height: 22.828 / 15.98,
            ),
          ),
          const SizedBox(height: 4.566),
          Text(
            value,
            style: const TextStyle(
              color: _MinhasDisciplinasProfessorContentSectionState._titleColor,
              fontSize: 34.242,
              height: 41.09 / 34.242,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 213.219,
      height: 54.787,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9.131),
          gradient: const LinearGradient(
            colors: [
              _MinhasDisciplinasProfessorContentSectionState._buttonGradientTop,
              _MinhasDisciplinasProfessorContentSectionState
                  ._buttonGradientBottom,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6.848,
              offset: const Offset(0, 4.566),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.566,
              offset: const Offset(0, 2.283),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9.131),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22.828, color: Colors.white),
                const SizedBox(width: 9.131),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.262,
                    height: 27.394 / 18.262,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisciplinaCard extends StatelessWidget {
  const _DisciplinaCard({
    required this.disciplina,
    required this.color,
    required this.width,
    required this.onEdit,
    required this.onDelete,
  });

  final DisciplinaDto disciplina;
  final Color color;
  final double width;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final trimmedName = disciplina.nome.trim();
    final initial = trimmedName.isEmpty
        ? '?'
        : trimmedName.characters.first.toUpperCase();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: math.min(
          width,
          _MinhasDisciplinasProfessorContentSectionState._cardWidth,
        ),
        maxWidth: width,
        minHeight:
            _MinhasDisciplinasProfessorContentSectionState._cardMinHeight,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(27.394, 27.394, 27.394, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.262),
          boxShadow: const [
            BoxShadow(
              color: _MinhasDisciplinasProfessorContentSectionState._cardShadow,
              blurRadius: 3.424,
              offset: Offset(0, 1.141),
            ),
            BoxShadow(
              color: _MinhasDisciplinasProfessorContentSectionState._cardShadow,
              blurRadius: 2.283,
              offset: Offset(0, 1.141),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 27.394,
                  backgroundColor: color,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.545,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 13.697),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disciplina.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _MinhasDisciplinasProfessorContentSectionState
                              ._titleColor,
                          fontSize: 20.545,
                          height: 31.959 / 20.545,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13.7,
                          vertical: 5.71,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          disciplina.areaLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 13.697,
                            height: 18.262 / 13.697,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.262),
            Row(
              children: [
                const Icon(
                  Icons.groups_2_outlined,
                  size: 18.262,
                  color: _MinhasDisciplinasProfessorContentSectionState
                      ._subtitleColor,
                ),
                const SizedBox(width: 9.131),
                Text(
                  '${disciplina.activeStudentsCount} alunos',
                  style: const TextStyle(
                    color: _MinhasDisciplinasProfessorContentSectionState
                        ._subtitleColor,
                    fontSize: 15.98,
                    height: 22.828 / 15.98,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9.131),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.category_outlined,
                    size: 18.262,
                    color: _MinhasDisciplinasProfessorContentSectionState
                        ._subtitleColor,
                  ),
                ),
                const SizedBox(width: 9.131),
                Expanded(
                  child: Text(
                    disciplina.areaLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _MinhasDisciplinasProfessorContentSectionState
                          ._subtitleColor,
                      fontSize: 15.98,
                      height: 22.828 / 15.98,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9.131),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.school_outlined,
                    size: 18.262,
                    color: _MinhasDisciplinasProfessorContentSectionState
                        ._subtitleColor,
                  ),
                ),
                const SizedBox(width: 9.131),
                Expanded(
                  child: Text(
                    disciplina.cicloEstudosLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _MinhasDisciplinasProfessorContentSectionState
                          ._subtitleColor,
                      fontSize: 15.98,
                      height: 22.828 / 15.98,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.262),
            Container(
              padding: const EdgeInsets.only(top: 19.403),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF3F4F6), width: 1.141),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 41.09,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.131),
                          gradient: const LinearGradient(
                            colors: [
                              _MinhasDisciplinasProfessorContentSectionState
                                  ._buttonGradientTop,
                              _MinhasDisciplinasProfessorContentSectionState
                                  ._buttonGradientBottom,
                            ],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9.131),
                            onTap: onEdit,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18.262,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 9.131),
                                Text(
                                  'Editar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.98,
                                    height: 22.828 / 15.98,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9.131),
                  SizedBox(
                    width: 57.07,
                    height: 41.09,
                    child: OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: _MinhasDisciplinasProfessorContentSectionState
                              ._dangerBorder,
                          width: 1.141,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.131),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18.262,
                        color: _MinhasDisciplinasProfessorContentSectionState
                            ._dangerIcon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.262),
        border: Border.all(
          color: _MinhasDisciplinasProfessorContentSectionState._cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ainda não tem disciplinas configuradas.',
            style: TextStyle(
              color: _MinhasDisciplinasProfessorContentSectionState._titleColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione disciplinas ao seu perfil com área e ciclo de estudos para geri-las aqui.',
            style: TextStyle(
              color:
                  _MinhasDisciplinasProfessorContentSectionState._subtitleColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryActionButton(
            label: 'Adicionar disciplina',
            icon: Icons.add_rounded,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _ProfessorDisciplinaDialogResult {
  const _ProfessorDisciplinaDialogResult({
    this.idDisciplina,
    required this.idArea,
    required this.idCicloEstudo,
    required this.nome,
    this.descricao,
  });

  final String? idDisciplina;
  final String idArea;
  final String idCicloEstudo;
  final String nome;
  final String? descricao;
}

class _ProfessorDisciplinaDialog extends StatefulWidget {
  const _ProfessorDisciplinaDialog({
    required this.areas,
    required this.ciclos,
    required this.catalog,
    this.initialDisciplina,
  });

  final List<AreaDto> areas;
  final List<CicloEstudoDto> ciclos;
  final List<DisciplinaDto> catalog;
  final DisciplinaDto? initialDisciplina;

  @override
  State<_ProfessorDisciplinaDialog> createState() =>
      _ProfessorDisciplinaDialogState();
}

class _ProfessorDisciplinaDialogState
    extends State<_ProfessorDisciplinaDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String? _selectedAreaId;
  String? _selectedCicloId;
  String? _selectedCatalogDisciplinaId;

  bool get _isEditing => widget.initialDisciplina != null;

  List<AreaDto> get _sortedAreas {
    final items = [...widget.areas];
    items.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return items;
  }

  List<CicloEstudoDto> get _sortedCiclos {
    final items = [...widget.ciclos];
    items.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return items;
  }

  List<DisciplinaDto> get _filteredCatalog {
    final query = _nomeController.text.trim().toLowerCase();
    final items = widget.catalog
        .where((disciplina) {
          if (_selectedAreaId != null && disciplina.idArea != _selectedAreaId) {
            return false;
          }

          if (query.isEmpty) return true;
          return disciplina.nome.toLowerCase().contains(query);
        })
        .toList(growable: false);

    final sorted = [...items];
    sorted.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return sorted.take(6).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDisciplina;
    _selectedAreaId = initial?.idArea;
    _selectedCicloId = initial?.idCicloEstudo;
    _selectedCatalogDisciplinaId = initial?.idDisciplina;
    _nomeController.text = initial?.nome ?? '';
    _descricaoController.text = initial?.descricao ?? '';
    _nomeController.addListener(_handleNomeChanged);
  }

  @override
  void dispose() {
    _nomeController
      ..removeListener(_handleNomeChanged)
      ..dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _handleNomeChanged() {
    final selected = widget.catalog.cast<DisciplinaDto?>().firstWhere(
      (item) => item?.idDisciplina == _selectedCatalogDisciplinaId,
      orElse: () => null,
    );

    if (selected == null) {
      setState(() {});
      return;
    }

    if (selected.nome.trim().toLowerCase() !=
        _nomeController.text.trim().toLowerCase()) {
      setState(() {
        _selectedCatalogDisciplinaId = null;
      });
      return;
    }

    setState(() {});
  }

  void _selectCatalogDisciplina(DisciplinaDto disciplina) {
    setState(() {
      _selectedCatalogDisciplinaId = disciplina.idDisciplina;
      _selectedAreaId = disciplina.idArea ?? _selectedAreaId;
      _nomeController.text = disciplina.nome;
      if (_descricaoController.text.trim().isEmpty &&
          (disciplina.descricao?.trim().isNotEmpty ?? false)) {
        _descricaoController.text = disciplina.descricao!.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _filteredCatalog;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing
                                  ? 'Editar disciplina'
                                  : 'Criar disciplina',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Defina a área, a disciplina e o ciclo de estudos para guardar corretamente no seu perfil.',
                              style: TextStyle(
                                fontSize: 15.5,
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 394,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedAreaId,
                          decoration: _inputDecoration(
                            label: 'Área',
                            hint: 'Selecione a área',
                          ),
                          items: _sortedAreas
                              .map(
                                (area) => DropdownMenuItem<String>(
                                  value: area.idArea,
                                  child: Text(area.nome),
                                ),
                              )
                              .toList(growable: false),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Selecione a área.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _selectedAreaId = value;
                              final selected = widget.catalog
                                  .cast<DisciplinaDto?>()
                                  .firstWhere(
                                    (item) =>
                                        item?.idDisciplina ==
                                        _selectedCatalogDisciplinaId,
                                    orElse: () => null,
                                  );
                              if (selected != null &&
                                  selected.idArea != value) {
                                _selectedCatalogDisciplinaId = null;
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 394,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCicloId,
                          decoration: _inputDecoration(
                            label: 'Ciclo de estudos',
                            hint: 'Selecione o ciclo',
                          ),
                          items: _sortedCiclos
                              .map(
                                (ciclo) => DropdownMenuItem<String>(
                                  value: ciclo.idCicloEstudo,
                                  child: Text(ciclo.nome),
                                ),
                              )
                              .toList(growable: false),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Selecione o ciclo de estudos.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _selectedCicloId = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nomeController,
                    decoration: _inputDecoration(
                      label: 'Disciplina',
                      hint: 'Escreva ou escolha uma disciplina existente',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Introduza o nome da disciplina.';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedCatalogDisciplinaId == null
                                  ? Icons.edit_note_rounded
                                  : Icons.library_books_outlined,
                              size: 18,
                              color: const Color(0xFF4A5565),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCatalogDisciplinaId == null
                                  ? 'Nova disciplina personalizada'
                                  : 'Disciplina existente selecionada',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (suggestions.isEmpty)
                          const Text(
                            'Sem sugestões para a área selecionada. Pode guardar como nova disciplina.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF667085),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: suggestions
                                .map(
                                  (disciplina) => ActionChip(
                                    label: Text(disciplina.nome),
                                    onPressed: () =>
                                        _selectCatalogDisciplina(disciplina),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descricaoController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: _inputDecoration(
                      label: 'Descrição',
                      hint: 'Descrição opcional para contexto adicional',
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          Navigator.of(context).pop(
                            _ProfessorDisciplinaDialogResult(
                              idDisciplina: _selectedCatalogDisciplinaId,
                              idArea: _selectedAreaId!,
                              idCicloEstudo: _selectedCicloId!,
                              nome: _nomeController.text.trim(),
                              descricao:
                                  _descricaoController.text.trim().isEmpty
                                  ? null
                                  : _descricaoController.text.trim(),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          _isEditing
                              ? 'Guardar alterações'
                              : 'Criar disciplina',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFC9039), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
