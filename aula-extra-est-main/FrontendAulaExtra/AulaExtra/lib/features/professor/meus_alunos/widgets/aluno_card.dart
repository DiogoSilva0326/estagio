import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/disciplina_badge.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/progresso_bar.dart';
import 'package:flutter/material.dart';

class AlunoCard extends StatelessWidget {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> subjects;
  final String lastLessonDate;
  final double progress;

  const AlunoCard({
    super.key,
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.subjects,
    required this.lastLessonDate,
    required this.progress,
  });

  Color subjectColor(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('mat') || lower.contains('fís')) return Colors.blue;
    if (lower.contains('ing') || lower.contains('port')) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.titleMedium;
    final body = Theme.of(context).textTheme.bodySmall;
    final orange = MeusAlunosProfessorColors.orange;
    final blue = MeusAlunosProfessorColors.blue;
    final green = MeusAlunosProfessorColors.green;

    // Calculamos o percentual para exibição (ex: 0.5 -> 50)
    final int progressPercent = (progress * 100).toInt();

    return SizedBox(
      width: MeusAlunosProfessorLayout.cardWidth,
      height: MeusAlunosProfessorLayout.cardHeight,
      child: Container(
        padding: const EdgeInsets.only(
          top: MeusAlunosProfessorLayout.cardPaddingTop,
          left: MeusAlunosProfessorLayout.cardPaddingSides,
          right: MeusAlunosProfessorLayout.cardPaddingSides,
          bottom: MeusAlunosProfessorLayout.cardPaddingBottom,
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: MeusAlunosProfessorLayout.cardBorderWidth,
              color: MeusAlunosProfessorColors.cardBorder,
            ),
            borderRadius: BorderRadius.circular(MeusAlunosProfessorLayout.cardRadius),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4.92,
              offset: Offset(0, 2.46),
              spreadRadius: -2.46,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 7.39,
              offset: Offset(0, 4.92),
              spreadRadius: -1.23,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MeusAlunosProfessorLayout.avatarSize,
                  height: MeusAlunosProfessorLayout.avatarSize,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20653750),
                    ),
                  ),
                  child: avatarUrl.trim().isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF9CA3AF),
                          ),
                        )
                      : Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, color: Color(0xFF9CA3AF));
                          },
                        ),
                ),
                const SizedBox(width: 19.70),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;

                      const badgeTextStyle = TextStyle(
                        fontSize: 14.77,
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                      );

                      double measureTextWidth(String text, TextStyle style) {
                        final tp = TextPainter(
                          text: TextSpan(text: text, style: style),
                          textDirection: TextDirection.ltr,
                        )..layout();
                        return tp.width;
                      }

                      final badgeWidths = subjects.map((s) {
                        final textW = measureTextWidth(s, badgeTextStyle);
                        return textW + 9.85 * 2;
                      }).toList(growable: false);

                      const double spacing = 9.85;

                      final List<List<int>> rows = [[]];
                      double currentRowW = 0.0;
                      for (var i = 0; i < badgeWidths.length; i++) {
                        final w = badgeWidths[i];
                        final projected = currentRowW == 0 ? w : currentRowW + spacing + w;
                        if (projected <= availableWidth || currentRowW == 0) {
                          rows.last.add(i);
                          currentRowW = projected;
                        } else if (rows.length == 1) {
                          rows.add([i]);
                          currentRowW = w;
                        } else {
                          final secondProjected = currentRowW + spacing + w;
                          if (secondProjected <= availableWidth) {
                            rows.last.add(i);
                            currentRowW = secondProjected;
                          } else {
                            break;
                          }
                        }
                      }

                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: MeusAlunosProfessorLayout.headerTextBlockHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              strutStyle: const StrutStyle(
                                fontSize: MeusAlunosProfessorLayout.headerNameFontSize,
                                height: MeusAlunosProfessorLayout.headerNameLineHeight,
                                forceStrutHeight: true,
                              ),
                              style: headline?.copyWith(
                                color: const Color(0xFF1D2838),
                                fontSize: MeusAlunosProfessorLayout.headerNameFontSize,
                                fontWeight: FontWeight.w500,
                                height: MeusAlunosProfessorLayout.headerNameLineHeight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: MeusAlunosProfessorLayout.headerBadgesTopGap),
                            for (var r = 0; r < rows.length; r++)
                              Padding(
                                padding: EdgeInsets.only(bottom: r == rows.length - 1 ? 0 : 6.0),
                                child: Row(
                                  children: [
                                    for (var j = 0; j < rows[r].length; j++) ...[
                                      if (j != 0) const SizedBox(width: spacing),
                                      DisciplinaBadge(
                                        label: subjects[rows[r][j]],
                                        color: subjectColor(subjects[rows[r][j]]),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 19.70),
            SizedBox(
              height: MeusAlunosProfessorLayout.lastLessonBlockHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última aula:',
                    style: body?.copyWith(
                      color: const Color(0xFF697282),
                      fontSize: MeusAlunosProfessorLayout.lastLessonFontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    lastLessonDate,
                    style: body?.copyWith(
                      color: const Color(0xFF354152),
                      fontSize: MeusAlunosProfessorLayout.lastLessonFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19.70),
            SizedBox(
              height: 44.32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Progresso',
                        style: body?.copyWith(
                          color: const Color(0xFF495565),
                          fontSize: 17.23,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$progressPercent%',
                        style: body?.copyWith(
                          color: const Color(0xFF1D2838),
                          fontSize: 17.23,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9.85),
                  ProgressoBar(value: progress, color: orange),
                ],
              ),
            ),
            const SizedBox(height: 19.70),
            SizedBox(
              height: MeusAlunosProfessorLayout.actionsRowHeight,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 39.39,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                          context,
                          Routes.professorStudentProfile,
                          arguments: id,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: orange,
                          side: BorderSide(color: orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MeusAlunosProfessorLayout.actionButtonRadius),
                          ),
                        ),
                        icon: const Icon(Icons.person_outline, size: 20),
                        label: const Text('Ver Perfil'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9.85),
                  _SquareActionButton(
                    icon: Icons.chat_bubble_outline,
                    borderColor: blue,
                    iconColor: blue,
                    onTap: () {},
                  ),
                  const SizedBox(width: 9.85),
                  _SquareActionButton(
                    icon: Icons.description_outlined,
                    borderColor: green,
                    iconColor: green,
                    onTap: () {},
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

class _SquareActionButton extends StatelessWidget {
  const _SquareActionButton({
    required this.icon,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: MeusAlunosProfessorLayout.actionButtonSize,
        height: MeusAlunosProfessorLayout.actionButtonSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MeusAlunosProfessorLayout.actionButtonRadius),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}