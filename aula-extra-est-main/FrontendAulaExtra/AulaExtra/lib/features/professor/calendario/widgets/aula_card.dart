import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_colors.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_layout.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_mock_data.dart';
import 'package:flutter/material.dart';

class AulaCard extends StatelessWidget {
  const AulaCard({
    super.key,
    required this.data,
    this.onEnterTap,
    this.onCancelTap,
  });

  final ProfessorAulaCardData data;
  final VoidCallback? onEnterTap;
  final VoidCallback? onCancelTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: CalendarioProfessorColors.title,
      fontSize: CalendarioProfessorLayout.nameFontSize,
      fontWeight: FontWeight.w500,
      height:
          CalendarioProfessorLayout.nameLineHeightPx /
          CalendarioProfessorLayout.nameFontSize,
    );

    final metaStyle = TextStyle(
      color: CalendarioProfessorColors.muted,
      fontSize: CalendarioProfessorLayout.metaFontSize,
      fontWeight: FontWeight.w400,
      height:
          CalendarioProfessorLayout.metaLineHeight /
          CalendarioProfessorLayout.metaFontSize,
    );

    final timeStyle = TextStyle(
      color: CalendarioProfessorColors.text,
      fontSize: CalendarioProfessorLayout.metaFontSize,
      fontWeight: FontWeight.w500,
      height:
          CalendarioProfessorLayout.metaLineHeight /
          CalendarioProfessorLayout.metaFontSize,
    );

    final badgeTextStyle = TextStyle(
      color: Colors.white,
      fontSize: CalendarioProfessorLayout.badgeFontSize,
      fontWeight: FontWeight.w500,
      height:
          CalendarioProfessorLayout.badgeLineHeightPx /
          CalendarioProfessorLayout.badgeFontSize,
    );

    return SizedBox(
      height: CalendarioProfessorLayout.aulaCardHeight,
      child: Container(
        padding: const EdgeInsets.only(
          top: CalendarioProfessorLayout.aulaCardPaddingTop,
          left: CalendarioProfessorLayout.aulaCardPaddingSides,
          right: CalendarioProfessorLayout.aulaCardPaddingSides,
          bottom: CalendarioProfessorLayout.aulaCardPaddingBottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            CalendarioProfessorLayout.aulaCardRadius,
          ),
          border: Border.all(
            color: CalendarioProfessorColors.cardBorder,
            width: CalendarioProfessorLayout.aulaCardBorderWidth,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.10),
              offset: Offset(0, 4.727),
              blurRadius: 7.09,
            ),
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.10),
              offset: Offset(0, 2.363),
              blurRadius: 4.727,
            ),
          ],
        ),
        child: SizedBox(
          height: CalendarioProfessorLayout.aulaRowHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _InitialsAvatar(initials: data.initials, color: data.color),
                    const SizedBox(width: CalendarioProfessorLayout.listGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.studentName,
                            style: titleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.727),
                          Row(
                            children: [
                              _SubjectBadge(
                                label: data.subject,
                                color: data.color,
                                textStyle: badgeTextStyle,
                              ),
                              const SizedBox(
                                width: CalendarioProfessorLayout.metaGap,
                              ),
                              Flexible(
                                child: Text(
                                  data.weekdayAndDate,
                                  style: metaStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                width: CalendarioProfessorLayout.metaGap,
                              ),
                              Text(
                                data.timeRange,
                                style: timeStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CalendarioProfessorLayout.listGap),
              SizedBox(
                height: CalendarioProfessorLayout.actionsHeight,
                child: Row(
                  children: [
                    if (data.showPrimaryAction) ...[
                      SizedBox(
                        height: CalendarioProfessorLayout.actionsHeight,
                        child: ElevatedButton.icon(
                          onPressed: data.primaryActionEnabled
                              ? onEnterTap
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: data.primaryActionEnabled
                                ? CalendarioProfessorColors.enterButton
                                : const Color(0xFFF1F5F9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                CalendarioProfessorLayout.actionRadius,
                              ),
                            ),
                            textStyle: TextStyle(
                              fontSize: CalendarioProfessorLayout.tabFontSize,
                              fontWeight: FontWeight.w500,
                              height:
                                  CalendarioProfessorLayout.tabLineHeight /
                                  CalendarioProfessorLayout.tabFontSize,
                            ),
                          ),
                          icon: Icon(
                            Icons.video_call_outlined,
                            size: CalendarioProfessorLayout.actionIconSize,
                          ),
                          label: Text(data.primaryActionLabel),
                        ),
                      ),
                      const SizedBox(
                        width: CalendarioProfessorLayout.actionGap,
                      ),
                    ],
                    SizedBox(
                      width: CalendarioProfessorLayout.cancelButtonWidth,
                      height: CalendarioProfessorLayout.actionsHeight,
                      child: OutlinedButton.icon(
                        onPressed: onCancelTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CalendarioProfessorColors.cancelRed,
                          side: const BorderSide(
                            color: CalendarioProfessorColors.cancelRed,
                            width: CalendarioProfessorLayout.cancelBorderWidth,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CalendarioProfessorLayout.actionRadius,
                            ),
                          ),
                          textStyle: TextStyle(
                            fontSize: CalendarioProfessorLayout.tabFontSize,
                            fontWeight: FontWeight.w500,
                            height:
                                CalendarioProfessorLayout.tabLineHeight /
                                CalendarioProfessorLayout.tabFontSize,
                          ),
                        ),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: CalendarioProfessorLayout.actionIconSize,
                        ),
                        label: const Text('Cancelar'),
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

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CalendarioProfessorLayout.avatarSize,
      height: CalendarioProfessorLayout.avatarSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: CalendarioProfessorLayout.avatarFontSize,
          fontWeight: FontWeight.w500,
          height:
              CalendarioProfessorLayout.avatarLineHeight /
              CalendarioProfessorLayout.avatarFontSize,
        ),
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({
    required this.label,
    required this.color,
    required this.textStyle,
  });

  final String label;
  final Color color;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CalendarioProfessorLayout.badgeHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: CalendarioProfessorLayout.badgePaddingH,
        vertical: CalendarioProfessorLayout.badgePaddingV,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          CalendarioProfessorLayout.badgeRadius,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
