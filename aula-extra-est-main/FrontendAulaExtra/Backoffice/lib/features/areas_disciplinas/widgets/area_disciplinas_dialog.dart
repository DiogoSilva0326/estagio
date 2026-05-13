import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

enum AreaDisciplinasDialogMode { area, disciplina }

class AreaDisciplinasDialogResult {
  const AreaDisciplinasDialogResult({
    required this.areaName,
    required this.disciplinas,
    required this.targetRole, 
  });

  final String areaName;
  final List<String> disciplinas;
  final String targetRole; 
}

class AreaDisciplinasDialog extends StatefulWidget {
  const AreaDisciplinasDialog({
    super.key,
    required this.mode,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.initialAreaName,
    this.initialDisciplinas = const <String>[],
    this.initialTargetRole = 'ensino', 
  });

  final AreaDisciplinasDialogMode mode;
  final String? initialAreaName;
  final List<String> initialDisciplinas;
  final String initialTargetRole;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  @override
  State<AreaDisciplinasDialog> createState() => _AreaDisciplinasDialogState();
}

class _AreaDisciplinasDialogState extends State<AreaDisciplinasDialog> {
  late final TextEditingController _areaController;
  late final TextEditingController _disciplinaController;
  late List<String> _disciplinas;
  late String _targetRole; 

  bool get _isAreaMode => widget.mode == AreaDisciplinasDialogMode.area;

  String get _submitLabel =>
      _isAreaMode ? '+ Adicionar Área' : '+ Adicionar Disciplina';

  @override
  void initState() {
    super.initState();
    _areaController = TextEditingController(text: widget.initialAreaName ?? '');
    _disciplinaController = TextEditingController();
    _disciplinas = List<String>.from(widget.initialDisciplinas);
    _targetRole = widget.initialTargetRole; 
  }

  @override
  void dispose() {
    _areaController.dispose();
    _disciplinaController.dispose();
    super.dispose();
  }

  void _addDisciplina() {
    final value = _disciplinaController.text.trim();
    if (value.isEmpty) {
      return;
    }

    if (_disciplinas.any((item) => item.toLowerCase() == value.toLowerCase())) {
      _disciplinaController.clear();
      return;
    }

    setState(() {
      _disciplinas = [..._disciplinas, value];
      _disciplinaController.clear();
    });
  }

  void _removeDisciplina(String disciplina) {
    setState(() {
      _disciplinas = _disciplinas.where((item) => item != disciplina).toList();
    });
  }

  void _submit() {
    final areaName = _isAreaMode
        ? _areaController.text.trim()
        : (widget.initialAreaName ?? '').trim();

    if (areaName.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      AreaDisciplinasDialogResult(
        areaName: areaName,
        disciplinas: List<String>.from(_disciplinas),
        targetRole: _targetRole, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 435.633),
          child: Container(
            padding: const EdgeInsets.all(38.438),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(27.955),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 34.944,
                  offset: Offset(0, 9.318),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogHeader(
                  mode: widget.mode,
                  areaController: _areaController,
                  areaName: widget.initialAreaName,
                  icon: widget.icon,
                  iconBackgroundColor: widget.iconBackgroundColor,
                  iconColor: widget.iconColor,
                ),

                if (_isAreaMode) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'CONTEXTO / PERFIL',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.813,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3563,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16.307),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _targetRole,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                        items: const [
                          DropdownMenuItem(value: 'ensino', child: Text('Ensino / Escola (Explicador)')),
                          DropdownMenuItem(value: 'psicologia', child: Text('Saúde (Psicólogo)')),
                          DropdownMenuItem(value: 'tutoria', child: Text('Mentoria (Tutor)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _targetRole = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 27.955),
                const Text(
                  'DISCIPLINAS / ESPECIALIDADES',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.813,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3563,
                  ),
                ),
                const SizedBox(height: 13.978),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var index = 0; index < _disciplinas.length; index++) ...[
                          _DisciplinaEditableTile(
                            label: _disciplinas[index],
                            onRemove: () => _removeDisciplina(_disciplinas[index]),
                          ),
                          if (index != _disciplinas.length - 1)
                            const SizedBox(height: 9.318),
                        ],
                        if (_disciplinas.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.637,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(16.307),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'Ainda não existem disciplinas nesta área.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _DisciplinaInputRow(
                  controller: _disciplinaController,
                  onSubmitted: (_) => _addDisciplina(),
                  onAdd: _addDisciplina,
                ),
                const SizedBox(height: 27.955),
                InkWell(
                  onTap: _submit,
                  borderRadius: BorderRadius.circular(16.307),
                  child: CustomPaint(
                    painter: _DashedRoundedRectPainter(
                      color: const Color(0xFFE5E7EB),
                      strokeWidth: 2.33,
                      radius: 16.307,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55.91,
                      child: Center(
                        child: Text(
                          _submitLabel,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16.307,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1752,
                          ),
                        ),
                      ),
                    ),
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

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.mode,
    required this.areaController,
    required this.areaName,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final AreaDisciplinasDialogMode mode;
  final TextEditingController areaController;
  final String? areaName;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  bool get _isAreaMode => mode == AreaDisciplinasDialogMode.area;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 55.91,
                height: 55.91,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(18.637),
                ),
                child: Icon(icon, size: 27.955, color: iconColor),
              ),
              const SizedBox(width: 18.637),
              Expanded(
                child: SizedBox(
                  height: 55.91,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _isAreaMode
                            ? TextField(
                                controller: areaController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: 'Nome da área',
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 20.966,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5119,
                                    height: 1.15,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 20.966,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5119,
                                  height: 1.15,
                                ),
                              )
                            : Text(
                                areaName ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 20.966,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5119,
                                  height: 1.15,
                                ),
                              ),
                      ),
                      Text(
                        _isAreaMode
                            ? 'Defina a área e organize as disciplinas iniciais.'
                            : 'Adicione disciplinas à área selecionada.',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(11.648),
          child: Container(
            width: 37.273,
            height: 37.273,
            alignment: Alignment.center,
            child: const Icon(
              Icons.close_rounded,
              size: 18.637,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _DisciplinaEditableTile extends StatelessWidget {
  const _DisciplinaEditableTile({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44.262,
      padding: const EdgeInsets.symmetric(horizontal: 18.637),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4A5565),
                fontSize: 16.307,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1752,
              ),
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplinaInputRow extends StatelessWidget {
  const _DisciplinaInputRow({
    required this.controller,
    required this.onAdd,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46.592,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16.307),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Escrever disciplina',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: const Color(0xFFFC9039),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(14),
            child: const SizedBox(
              width: 46.592,
              height: 46.592,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  const _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const dashWidth = 6.0;
    const dashSpace = 5.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        radius != oldDelegate.radius;
  }
}
