import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/disciplina_badge.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/progresso_bar.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';

class AlunoCard extends StatefulWidget {
  const AlunoCard({
    super.key,
    required this.data,
    this.onComplaintTap,
    this.onViewProfileTap,
  });

  final ProfessorAlunoDto data;
  final VoidCallback? onComplaintTap;
  final VoidCallback? onViewProfileTap;

  @override
  State<AlunoCard> createState() => _AlunoCardState();
}

class _AlunoCardState extends State<AlunoCard> {
  bool _showAllSubjects = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    final headline = Theme.of(context).textTheme.titleMedium;
    final body = Theme.of(context).textTheme.bodySmall;

    final primaryColor = config.primaryColor;
    final primaryLight = config.primaryLight; 
    final primaryDark = config.primaryDark;
    final borderColor = config.borderColor;
    
    final data = widget.data;
    final progressPercent = (data.progress * 100).round().clamp(0, 100);
    final studentDisplayName = data.fullName;
    final uniqueSubjects = data.subjects
        .map((subject) => subject.trim())
        .where((subject) => subject.isNotEmpty)
        .fold<List<String>>(<String>[], (list, subject) {
          final alreadyExists = list.any(
            (existing) => existing.toLowerCase() == subject.toLowerCase(),
          );
          if (!alreadyExists) {
            list.add(subject);
          }
          return list;
        });

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: MeusAlunosProfessorLayout.cardWidth,
        child: Container(
          padding: const EdgeInsets.only(
            top: MeusAlunosProfessorLayout.cardPaddingTop,
            left: MeusAlunosProfessorLayout.cardPaddingSides,
            right: MeusAlunosProfessorLayout.cardPaddingSides,
            bottom: 14,
          ),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: MeusAlunosProfessorLayout.cardBorderWidth,
                color: borderColor, 
              ),
              borderRadius: BorderRadius.circular(
                MeusAlunosProfessorLayout.cardRadius,
              ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableBadgeWidth =
                  constraints.maxWidth -
                  MeusAlunosProfessorLayout.avatarSize -
                  19.70;
              final subjectRows = _buildSubjectRows(
                subjects: uniqueSubjects,
                availableWidth: availableBadgeWidth,
              );
              final canToggleSubjects = subjectRows.length > 2;
              final visibleRows = _showAllSubjects
                  ? subjectRows
                  : subjectRows.take(2).toList(growable: false);
              final hiddenCount = subjectRows
                  .skip(2)
                  .expand((row) => row)
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                        child: data.avatarUrl.trim().isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF9CA3AF),
                                ),
                              )
                            : Image.network(
                                data.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox.shrink();
                                },
                              ),
                      ),
                      const SizedBox(width: 19.70),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight:
                                MeusAlunosProfessorLayout.headerTextBlockHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentDisplayName,
                                strutStyle: const StrutStyle(
                                  fontSize: MeusAlunosProfessorLayout
                                      .headerNameFontSize,
                                  height: MeusAlunosProfessorLayout
                                      .headerNameLineHeight,
                                  forceStrutHeight: true,
                                ),
                                style: headline?.copyWith(
                                  color: const Color(0xFF1D2838),
                                  fontSize: MeusAlunosProfessorLayout
                                      .headerNameFontSize,
                                  fontWeight: FontWeight.w500,
                                  height: MeusAlunosProfessorLayout
                                      .headerNameLineHeight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: MeusAlunosProfessorLayout
                                    .headerBadgesTopGap,
                              ),
                              if (visibleRows.isEmpty)
                                const SizedBox(
                                  height: MeusAlunosProfessorLayout
                                      .headerBadgeRowHeight,
                                )
                              else
                                for (
                                  var index = 0;
                                  index < visibleRows.length;
                                  index++
                                )
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == visibleRows.length - 1
                                          ? 0
                                          : 6,
                                    ),
                                    child: Wrap(
                                      spacing: 9.85,
                                      runSpacing: 6,
                                      children: [
                                        for (final subject
                                            in visibleRows[index])
                                          DisciplinaBadge(
                                            label: subject,
                                            color: primaryColor, 
                                            backgroundColor: primaryLight, 
                                            textColor: primaryDark,        
                                          ),
                                      ],
                                    ),
                                  ),
                              if (canToggleSubjects) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showAllSubjects = !_showAllSubjects;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _showAllSubjects
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                  .keyboard_arrow_down_rounded,
                                          color: primaryColor, 
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _showAllSubjects
                                              ? 'Mostrar menos'
                                              : '+$hiddenCount itens',
                                          style: const TextStyle(
                                            color: Color(0xFF667085),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (widget.onComplaintTap != null)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9CA3AF)),
                          onSelected: (value) {
                            if (value == 'report') {
                              widget.onComplaintTap!();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'report',
                              child: Text(
                                'Submeter reclamação',
                                style: TextStyle(color: MeusAlunosProfessorColors.danger),
                              ),
                            ),
                          ],
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
                          config.alunoCard.lastSessionLabel,
                          strutStyle: const StrutStyle(
                            fontSize:
                                MeusAlunosProfessorLayout.lastLessonFontSize,
                            height:
                                MeusAlunosProfessorLayout.lastLessonLineHeight,
                            forceStrutHeight: true,
                          ),
                          style: body?.copyWith(
                            color: const Color(0xFF697282),
                            fontSize:
                                MeusAlunosProfessorLayout.lastLessonFontSize,
                            fontWeight: FontWeight.w400,
                            height:
                                MeusAlunosProfessorLayout.lastLessonLineHeight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          data.lastLessonDate,
                          strutStyle: const StrutStyle(
                            fontSize:
                                MeusAlunosProfessorLayout.lastLessonFontSize,
                            height:
                                MeusAlunosProfessorLayout.lastLessonLineHeight,
                            forceStrutHeight: true,
                          ),
                          style: body?.copyWith(
                            color: const Color(0xFF354152),
                            fontSize:
                                MeusAlunosProfessorLayout.lastLessonFontSize,
                            fontWeight: FontWeight.w500,
                            height:
                                MeusAlunosProfessorLayout.lastLessonLineHeight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                        SizedBox(
                          height: 24.62,
                          child: Row(
                            children: [
                              Text(
                                'Progresso',
                                style: body?.copyWith(
                                  color: const Color(0xFF495565),
                                  fontSize: 17.23,
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$progressPercent%',
                                style: body?.copyWith(
                                  color: const Color(0xFF1D2838),
                                  fontSize: 17.23,
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 9.85),
                        ProgressoBar(value: data.progress, color: primaryColor), 
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SizedBox(
                      height: MeusAlunosProfessorLayout.actionsRowHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 39.39,
                              child: TextButton.icon(
                                onPressed: widget.onViewProfileTap,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: primaryLight, 
                                  foregroundColor: primaryDark, // Garante bom contraste no texto do botão
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      MeusAlunosProfessorLayout.actionButtonRadius,
                                    ),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 17.23,
                                    fontWeight: FontWeight.w600,
                                    height: 1.43,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.person_outline,
                                  size: MeusAlunosProfessorLayout.actionIconSize,
                                ),
                                label: const Text('Ver Perfil'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 9.85),
                          _SquareActionButton(
                            icon: Icons.chat_bubble_outline,
                            iconColor: primaryColor, // Ícones mantêm a cor vibrante
                            backgroundColor: primaryLight,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.professorChats,
                                arguments: <String, dynamic>{
                                  'studentUsername': data.username,
                                  'studentName': data.fullName,
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 9.85),
                          _SquareActionButton(
                            icon: Icons.description_outlined,
                            iconColor: primaryColor,
                            backgroundColor: primaryLight,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<List<String>> _buildSubjectRows({
    required List<String> subjects,
    required double availableWidth,
  }) {
    if (subjects.isEmpty || availableWidth <= 0) return const <List<String>>[];

    const badgeTextStyle = TextStyle(
      fontSize: 14.77,
      fontWeight: FontWeight.w500,
      height: 1.33,
    );
    const horizontalPadding = 9.85 * 2;
    const spacing = 9.85;

    double measureTextWidth(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: badgeTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter.width;
    }

    final rows = <List<String>>[];
    var currentRow = <String>[];
    var currentWidth = 0.0;

    for (final subject in subjects) {
      final badgeWidth = measureTextWidth(subject) + horizontalPadding;
      final nextWidth = currentRow.isEmpty
          ? badgeWidth
          : currentWidth + spacing + badgeWidth;

      if (currentRow.isEmpty || nextWidth <= availableWidth) {
        currentRow.add(subject);
        currentWidth = nextWidth;
        continue;
      }

      rows.add(List<String>.from(currentRow));
      currentRow = <String>[subject];
      currentWidth = badgeWidth;
    }

    if (currentRow.isNotEmpty) {
      rows.add(List<String>.from(currentRow));
    }

    return rows;
  }
}

class _SquareActionButton extends StatelessWidget {
  const _SquareActionButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: MeusAlunosProfessorLayout.actionButtonSize,
        height: MeusAlunosProfessorLayout.actionButtonSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            MeusAlunosProfessorLayout.actionButtonRadius,
          ),
          color: backgroundColor, 
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: MeusAlunosProfessorLayout.actionIconSize,
          color: iconColor,
        ),
      ),
    );
  }
}