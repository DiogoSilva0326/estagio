import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:flutter/material.dart';

Future<List<String>?> showAreaDisciplineSelectionDialog(
  BuildContext context, {
  required String areaName,
  required String imageAsset,
  required Color gradientStart,
  required Color gradientEnd,
  required List<DisciplinaDto> disciplinas,
  List<String> initialSelectedIds = const [],
}) {
  return showDialog<List<String>>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AreaDisciplineSelectionDialog(
      areaName: areaName,
      imageAsset: imageAsset,
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
      disciplinas: disciplinas,
      initialSelectedIds: initialSelectedIds,
    ),
  );
}

class AreaDisciplineSelectionDialog extends StatefulWidget {
  const AreaDisciplineSelectionDialog({
    super.key,
    required this.areaName,
    required this.imageAsset,
    required this.gradientStart,
    required this.gradientEnd,
    required this.disciplinas,
    this.initialSelectedIds = const [],
  });

  final String areaName;
  final String imageAsset;
  final Color gradientStart;
  final Color gradientEnd;
  final List<DisciplinaDto> disciplinas;
  final List<String> initialSelectedIds;

  @override
  State<AreaDisciplineSelectionDialog> createState() =>
      _AreaDisciplineSelectionDialogState();
}

class _AreaDisciplineSelectionDialogState
    extends State<AreaDisciplineSelectionDialog> {
  static const _dialogRadius = 31.789;

  static const _mutedSurface = Color(0xFFF9FAFB);
  static const _divider = Color(0xFFE5E7EB);
  static const _textSecondary = Color(0xFF4A5565);

  final Set<String> _selected = <String>{};

  @override
  void initState() {
    super.initState();
    _selected.addAll(
      widget.initialSelectedIds
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty),
    );
  }

  bool get _allSelected =>
      _selected.length == widget.disciplinas.length && widget.disciplinas.isNotEmpty;

  void _toggleDiscipline(String disciplinaId) {
    final id = disciplinaId.trim();
    if (id.isEmpty) return;
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(
            widget.disciplinas
                .map((d) => d.idDisciplina.trim())
                .where((id) => id.isNotEmpty),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final total = widget.disciplinas.length;
    final selectedCount = _selected.length;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_dialogRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1017.238, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _Header(
              areaName: widget.areaName,
              imageAsset: widget.imageAsset,
              gradientStart: widget.gradientStart,
              gradientEnd: widget.gradientEnd,
              onBack: () => Navigator.of(context).pop(),
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(31.789, 31.789, 31.789, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SearchRow(totalDisciplines: total),
                      const SizedBox(height: 21.192),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.894,
                          mainAxisSpacing: 15.894,
                          mainAxisExtent: 84,
                        ),
                        itemCount: total + 1,
                        itemBuilder: (context, index) {
                          if (index == total) {
                            return _DisciplineTile(
                              label: 'Selecionar Todas',
                              selected: _allSelected,
                              isSelectAll: true,
                              onTap: _toggleAll,
                            );
                          }

                          final disciplina = widget.disciplinas[index];
                          final id = disciplina.idDisciplina.trim();
                          return _DisciplineTile(
                            label: disciplina.nome,
                            selected: _selected.contains(id),
                            onTap: () => _toggleDiscipline(id),
                          );
                        },
                      ),
                      const SizedBox(height: 31.789),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 128.479,
              decoration: const BoxDecoration(
                color: _mutedSurface,
                border: Border(top: BorderSide(color: _divider, width: 1.325)),
              ),
              padding: const EdgeInsets.fromLTRB(31.789, 33.113, 31.789, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$selectedCount de $total disciplinas selecionadas',
                    style: const TextStyle(
                      fontSize: 18.543,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                      height: 26.491 / 18.543,
                    ),
                  ),
                  _ConfirmButton(
                    enabled: true,
                    onPressed: () =>
                        Navigator.of(context).pop(_selected.toList(growable: false)),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.areaName,
    required this.imageAsset,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onBack,
    required this.onClose,
  });

  final String areaName;
  final String imageAsset;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback onBack;
  final VoidCallback onClose;

  static const _divider = Color(0xFFE5E7EB);
  static const _textPrimary = Color(0xFF101828);
  static const _textSecondary = Color(0xFF4A5565);
  static const _iconColor = Color(0xFF364153);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 133.777,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider, width: 1.325)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 31.789),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52.981,
                height: 52.981,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onBack,
                    child: const Center(
                      child: Icon(Icons.arrow_back, color: _iconColor, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 21.192),
              Row(
                children: [
                  Container(
                    width: 63.577,
                    height: 63.577,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gradientStart, gradientEnd],
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
                    alignment: Alignment.center,
                    child: Image.asset(
                      imageAsset,
                      width: 81.702,
                      height: 81.702,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 15.894),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        areaName,
                        style: const TextStyle(
                          fontSize: 31.789,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          height: 42.385 / 31.789,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Selecione as disciplinas desejadas',
                        style: TextStyle(
                          fontSize: 18.543,
                          fontWeight: FontWeight.w400,
                          color: _textSecondary,
                          height: 26.491 / 18.543,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 52.981,
            height: 52.981,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onClose,
                child: const Center(
                  child: Icon(Icons.close, color: _iconColor, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.totalDisciplines});

  final int totalDisciplines;

  static const _border = Color(0xFFD1D5DC);
  static const _text = Color(0xFF364153);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border, width: 2.649),
        borderRadius: BorderRadius.circular(18.543),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 21.192),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pesquisar',
            style: TextStyle(
              fontSize: 23.842,
              fontWeight: FontWeight.w500,
              color: _text,
              height: 37.087 / 23.842,
            ),
          ),
          Opacity(
            opacity: 0.9,
            child: Text(
              '$totalDisciplines disciplinas',
              style: const TextStyle(
                fontSize: 18.543,
                fontWeight: FontWeight.w400,
                color: _text,
                height: 26.491 / 18.543,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplineTile extends StatelessWidget {
  const _DisciplineTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isSelectAll = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isSelectAll;

  static const _tileBorder = Color(0xFFE5E7EB);
  static const _tileBorderSelected = Color(0xFFFC9039);
  static const _checkboxBorder = Color(0xFFD1D5DC);
  static const _checkboxFillSelected = Color(0xFFFC9039);
  static const _text = Color(0xFF364153);

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? _tileBorderSelected : _tileBorder;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.543),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.543),
            border: Border.all(color: borderColor, width: 2.649),
          ),
          padding: const EdgeInsets.fromLTRB(23.842, 23.842, 23.842, 2.649),
          child: Row(
            children: [
              Container(
                width: 26.491,
                height: 26.491,
                decoration: BoxDecoration(
                  color: selected ? _checkboxFillSelected : Colors.white,
                  borderRadius: BorderRadius.circular(10.596),
                  border: Border.all(color: _checkboxBorder, width: 2.649),
                ),
              ),
              const SizedBox(width: 15.894),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSelectAll ? 23.842 : 21.192,
                    fontWeight: isSelectAll ? FontWeight.w500 : FontWeight.w400,
                    color: _text,
                    height: 31.789 / (isSelectAll ? 23.842 : 21.192),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  static const _disabledBg = Color(0xFFE5E7EB);
  static const _disabledText = Color(0xFF99A1AF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 239.398,
      height: 63.577,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled ? null : _disabledBg,
          gradient: enabled ? AreasAlunoConstants.orangeGradient : null,
          borderRadius: BorderRadius.circular(18.543),
        ),
        child: TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: enabled ? Colors.white : _disabledText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.543),
            ),
          ),
          child: const Text(
            'Confirmar Seleção',
            style: TextStyle(
              fontSize: 21.192,
              fontWeight: FontWeight.w500,
              height: 31.789 / 21.192,
            ),
          ),
        ),
      ),
    );
  }
}
