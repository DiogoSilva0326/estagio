import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/area_disciplinas_item.dart';
import 'disciplina_chip_tile.dart';

class AreaDisciplinasCard extends StatelessWidget {
  const AreaDisciplinasCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onAddDisciplina,
  });

  final AreaDisciplinasItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onAddDisciplina;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 429.227),
      padding: const EdgeInsets.all(38.438),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27.955),
        border: Border.all(color: AppColors.borderSoft, width: 1.165),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 34.944,
            offset: Offset(0, 9.318),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 55.91,
                      height: 55.91,
                      decoration: BoxDecoration(
                        color: item.iconBackgroundColor,
                        borderRadius: BorderRadius.circular(18.637),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 27.955,
                      ),
                    ),
                    const SizedBox(width: 18.637),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nome,
                              style: const TextStyle(
                                color: Color(0xFF101828),
                                fontSize: 20.966,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5119,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.explicadores} Explicadores',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 16.307,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1752,
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
                onTap: onEdit,
                borderRadius: BorderRadius.circular(11.648),
                child: Container(
                  width: 37.273,
                  height: 37.273,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18.637,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 27.955),
          const Text(
            'DISCIPLINAS',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.813,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3563,
            ),
          ),
          const SizedBox(height: 13.978),
          ..._buildDisciplinaWidgets(),
          SizedBox(height: item.disciplinas.length >= 3 ? 27.955 : 81.535),
          _AddDisciplinaButton(onTap: onAddDisciplina),
        ],
      ),
    );
  }

  List<Widget> _buildDisciplinaWidgets() {
    return [
      for (var index = 0; index < item.disciplinas.length; index++) ...[
        DisciplinaChipTile(label: item.disciplinas[index]),
        if (index != item.disciplinas.length - 1) const SizedBox(height: 9.318),
      ],
    ];
  }
}

class _AddDisciplinaButton extends StatelessWidget {
  const _AddDisciplinaButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.307),
      child: CustomPaint(
        painter: _DashedRoundedRectPainter(
          color: const Color(0xFFE5E7EB),
          strokeWidth: 2.33,
          radius: 16.307,
        ),
        child: Container(
          width: double.infinity,
          height: 55.91,
          alignment: Alignment.center,
          child: const Text(
            '+ Adicionar Disciplina',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16.307,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1752,
            ),
          ),
        ),
      ),
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
