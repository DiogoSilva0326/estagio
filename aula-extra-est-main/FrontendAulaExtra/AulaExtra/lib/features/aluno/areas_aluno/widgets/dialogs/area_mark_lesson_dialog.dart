import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

Future<void> showAreaMarkLessonDialog(
  BuildContext context, {
  required AreaOverview area,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AreaMarkLessonDialog(area: area),
  );
}

class AreaMarkLessonDialog extends StatelessWidget {
  const AreaMarkLessonDialog({
    super.key,
    required this.area,
  });

  final AreaOverview area;

  static const _dialogRadius = 16.0;

  static const _mutedSurface = Color(0xFFF9FAFB);
  static const _divider = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      backgroundColor: Colors.white,
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
            _Header(area: area, onClose: () => Navigator.of(context).pop()),
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
                      const Text(
                        'Seus Explicadores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                          height: 28 / 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _TutorCard(
                        initials: 'JS',
                        name: 'João Silva',
                        rating: '4.8',
                        lessonsText: '8 aulas realizadas',
                        nextLessonPillText: 'Amanhã 14:00',
                        disciplines: ['Álgebra', 'Geometria', 'Cálculo'],
                        progressLabel: 'Progresso do Curso',
                        progressPercent: 0.65,
                        progressPercentText: '65%',
                      ),
                      const SizedBox(height: 16),
                      const _TutorCard(
                        initials: 'AR',
                        name: 'Ana Rodrigues',
                        rating: '4.6',
                        lessonsText: '4 aulas realizadas',
                        nextLessonPillText: null,
                        disciplines: ['Estatística', 'Probabilidade'],
                        progressLabel: 'Progresso do Curso',
                        progressPercent: 0.35,
                        progressPercentText: '35%',
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
                border: Border(top: BorderSide(color: _divider)),
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
                          Navigator.of(context).pushNamed(Routes.explicadores);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Adicionar Explicador',
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
                  '2 Explicadores nesta área',
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

class _TutorCard extends StatelessWidget {
  const _TutorCard({
    required this.initials,
    required this.name,
    required this.rating,
    required this.lessonsText,
    required this.nextLessonPillText,
    required this.disciplines,
    required this.progressLabel,
    required this.progressPercent,
    required this.progressPercentText,
  });

  final String initials;
  final String name;
  final String rating;
  final String lessonsText;
  final String? nextLessonPillText;
  final List<String> disciplines;
  final String progressLabel;
  final double progressPercent;
  final String progressPercentText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(21, 21, 21, 1),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.10),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.10),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF364153),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                              height: 28 / 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: Color(0xFFFACC15)),
                              const SizedBox(width: 8),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4A5565),
                                  height: 20 / 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF99A1AF),
                                  height: 20 / 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lessonsText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4A5565),
                                    height: 20 / 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (nextLessonPillText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          nextLessonPillText!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF008236),
                            height: 16 / 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final d in disciplines)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF364153),
                            height: 16 / 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A5565),
                        height: 16 / 12,
                      ),
                    ),
                    Text(
                      progressPercentText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A5565),
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF2B7FFF)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AreasAlunoConstants.orangeGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Marcar Aula',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.message_outlined,
                            size: 16, color: Color(0xFF364153)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 98.375,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Ver Perfil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF364153),
                            height: 24 / 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
