import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

Future<void> showAreaDetailsDialog(
  BuildContext context, {
  required AreaOverview area,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AreaDetailsDialog(area: area),
  );
}

class AreaDetailsDialog extends StatelessWidget {
  const AreaDetailsDialog({
    super.key,
    required this.area,
  });

  final AreaOverview area;

  static const _dialogRadius = 16.0;

  static const _surface = Color(0xFFFFFFFF);
  static const _mutedSurface = Color(0xFFF9FAFB);
  static const _divider = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      backgroundColor: _surface,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_dialogRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 896, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _Header(
              area: area,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 39, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              borderColor: const Color(0xFFDBEAFE),
                              gradientStart: const Color(0xFFEFF6FF),
                              gradientEnd: const Color(0xFFFFFFFF),
                              icon: Icons.menu_book_outlined,
                              iconColor: const Color(0xFF155DFC),
                              title: 'TOTAL DE AULAS',
                              titleColor: const Color(0xFF155DFC),
                              value: '${area.scheduledLessons}',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              borderColor: const Color(0xFFFFEDD4),
                              gradientStart: const Color(0xFFFFF7ED),
                              gradientEnd: const Color(0xFFFFFFFF),
                              icon: Icons.assignment_outlined,
                              iconColor: const Color(0xFFF54900),
                              title: 'TAREFAS',
                              titleColor: const Color(0xFFF54900),
                              value: '${area.pendingTasks}',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              borderColor: const Color(0xFFDCFCE7),
                              gradientStart: const Color(0xFFF0FDF4),
                              gradientEnd: const Color(0xFFFFFFFF),
                              icon: Icons.schedule,
                              iconColor: const Color(0xFF00A63E),
                              title: 'PRÓXIMA AULA',
                              titleColor: const Color(0xFF00A63E),
                              value: area.nextLessonText,
                              valueIsSmall: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(21, 18, 21, 18),
                        decoration: BoxDecoration(
                          color: _mutedSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Disciplinas selecionadas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF101828),
                                height: 24 / 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (area.selectedDisciplinaNames.isEmpty)
                              const Text(
                                'Nenhuma disciplina selecionada nesta área.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4A5565),
                                  height: 20 / 14,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final name in area.selectedDisciplinaNames)
                                    Chip(
                                      label: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4A5565),
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFF3F4F6),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(21, 21, 21, 21),
                        decoration: BoxDecoration(
                          color: _mutedSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Ainda não tem um explicador nesta área. Vamos encontrar um?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF101828),
                                height: 28 / 18,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 48,
                              width: 194.117,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AreasAlunoConstants.orangeGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .pushNamed(Routes.explicadores);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Encontrar explicadores',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      height: 24 / 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 97,
              decoration: const BoxDecoration(
                color: _mutedSurface,
                border: Border(
                  top: BorderSide(color: _divider),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF364153),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 24 / 16,
                      ),
                    ),
                    child: const Text('Fechar'),
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
    required this.area,
    required this.onClose,
  });

  final AreaOverview area;
  final VoidCallback onClose;

  static const _headerColor = Color.fromRGBO(43, 127, 255, 0.69);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      color: _headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22.128),
            child: SizedBox(
              width: 88.511,
              height: 88.511,
              child: Center(
                child: Image.asset(
                  area.imageAsset,
                  width: 81.702,
                  height: 81.702,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 32 / 24,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nenhum explicador nesta área',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onClose,
                child: const Center(
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.borderColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.value,
    this.valueIsSmall = false,
  });

  final Color borderColor;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String value;
  final bool valueIsSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                  height: 16 / 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: valueIsSmall ? 14 : 24,
              fontWeight: valueIsSmall ? FontWeight.w600 : FontWeight.bold,
              color: const Color(0xFF101828),
              height: (valueIsSmall ? 20 : 32) / (valueIsSmall ? 14 : 24),
            ),
          ),
        ],
      ),
    );
  }
}
