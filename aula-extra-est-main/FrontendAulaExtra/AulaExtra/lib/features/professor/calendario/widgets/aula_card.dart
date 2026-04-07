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
    final bool isCanceled = data.timeRange.contains('(Cancelada)') || data.studentName.contains('(Aula Recusada)');

    final titleStyle = TextStyle(
      color: CalendarioProfessorColors.title,
      fontSize: CalendarioProfessorLayout.nameFontSize,
      fontWeight: FontWeight.w500,
      decoration: isCanceled ? TextDecoration.lineThrough : null, // Riscado se cancelada
      height: CalendarioProfessorLayout.nameLineHeightPx / CalendarioProfessorLayout.nameFontSize,
    );

    final metaStyle = TextStyle(
      color: CalendarioProfessorColors.muted,
      fontSize: CalendarioProfessorLayout.metaFontSize,
      fontWeight: FontWeight.w400,
      height: CalendarioProfessorLayout.metaLineHeight / CalendarioProfessorLayout.metaFontSize,
    );

    final timeStyle = TextStyle(
      color: isCanceled ? Colors.red : CalendarioProfessorColors.text,
      fontSize: CalendarioProfessorLayout.metaFontSize,
      fontWeight: FontWeight.w500,
      height: CalendarioProfessorLayout.metaLineHeight / CalendarioProfessorLayout.metaFontSize,
    );

    final badgeTextStyle = TextStyle(
      color: Colors.white,
      fontSize: CalendarioProfessorLayout.badgeFontSize,
      fontWeight: FontWeight.w500,
      height: CalendarioProfessorLayout.badgeLineHeightPx / CalendarioProfessorLayout.badgeFontSize,
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
          color: isCanceled ? const Color(0xFFF9FAFB) : Colors.white, // Fundo cinzento se cancelada
          borderRadius: BorderRadius.circular(CalendarioProfessorLayout.aulaCardRadius),
          border: Border.all(
            color: isCanceled ? const Color(0xFFEAECF0) : CalendarioProfessorColors.cardBorder,
            width: CalendarioProfessorLayout.aulaCardBorderWidth,
          ),
          boxShadow: isCanceled ? [] : const [ // Removemos a sombra se estiver cancelada
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 4.727), blurRadius: 7.09),
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 2.363), blurRadius: 4.727),
          ],
        ),
        child: SizedBox(
          height: CalendarioProfessorLayout.aulaRowHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💡 OPACIDADE: O lado esquerdo fica desvanecido (50%) se a aula foi cancelada
              Expanded(
                child: Opacity(
                  opacity: isCanceled ? 0.45 : 1.0,
                  child: Row(
                    children: [
                      _InitialsAvatar(initials: data.initials, color: isCanceled ? Colors.grey : data.color),
                      const SizedBox(width: CalendarioProfessorLayout.listGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.studentName, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4.727),
                            Row(
                              children: [
                                _SubjectBadge(
                                  label: data.subject,
                                  color: isCanceled ? Colors.grey : data.color,
                                  textStyle: badgeTextStyle,
                                ),
                                const SizedBox(width: CalendarioProfessorLayout.metaGap),
                                Flexible(child: Text(data.weekdayAndDate, style: metaStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: CalendarioProfessorLayout.metaGap),
                                Text(data.timeRange, style: timeStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: CalendarioProfessorLayout.listGap),
              
              // BOTÕES
              SizedBox(
                height: CalendarioProfessorLayout.actionsHeight,
                child: Row(
                  children: [
                    SizedBox(
                      height: CalendarioProfessorLayout.actionsHeight,
                      child: ElevatedButton.icon(
                        onPressed: isCanceled ? null : onEnterTap, // Se for null, o Flutter desativa o botão
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CalendarioProfessorColors.enterButton,
                          foregroundColor: Colors.white,
                          // 💡 CORES DE BOTÃO DESATIVADO (Fica um Cinzento profissional)
                          disabledBackgroundColor: const Color(0xFFF2F4F7),
                          disabledForegroundColor: const Color(0xFF98A2B3),
                          padding: const EdgeInsets.symmetric(horizontal: 14.18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CalendarioProfessorLayout.actionRadius)),
                          textStyle: TextStyle(
                            fontSize: CalendarioProfessorLayout.tabFontSize,
                            fontWeight: FontWeight.w500,
                            height: CalendarioProfessorLayout.tabLineHeight / CalendarioProfessorLayout.tabFontSize,
                          ),
                        ),
                        icon: Icon(
                          isCanceled ? Icons.block : Icons.video_call_outlined, 
                          size: CalendarioProfessorLayout.actionIconSize
                        ),
                        label: Text(isCanceled ? 'Aula Recusada' : 'Entrar na Aula'),
                      ),
                    ),
                    const SizedBox(width: CalendarioProfessorLayout.actionGap),
                    SizedBox(
                      width: CalendarioProfessorLayout.cancelButtonWidth,
                      height: CalendarioProfessorLayout.actionsHeight,
                      child: OutlinedButton.icon(
                        onPressed: onCancelTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CalendarioProfessorColors.cancelRed,
                          side: const BorderSide(color: CalendarioProfessorColors.cancelRed, width: CalendarioProfessorLayout.cancelBorderWidth),
                          padding: const EdgeInsets.symmetric(horizontal: 14.18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CalendarioProfessorLayout.actionRadius)),
                          textStyle: TextStyle(
                            fontSize: CalendarioProfessorLayout.tabFontSize,
                            fontWeight: FontWeight.w500,
                            height: CalendarioProfessorLayout.tabLineHeight / CalendarioProfessorLayout.tabFontSize,
                          ),
                        ),
                        // 💡 Muda o Ícone para o Caxote do Lixo se estiver a limpar
                        icon: Icon(isCanceled ? Icons.delete_outline : Icons.cancel_outlined, size: CalendarioProfessorLayout.actionIconSize),
                        label: Text(isCanceled ? 'Limpar' : 'Cancelar'),
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
      width: CalendarioProfessorLayout.avatarSize, height: CalendarioProfessorLayout.avatarSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(color: Colors.white, fontSize: CalendarioProfessorLayout.avatarFontSize, fontWeight: FontWeight.w500)),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({required this.label, required this.color, required this.textStyle});
  final String label;
  final Color color;
  final TextStyle textStyle;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: CalendarioProfessorLayout.badgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: CalendarioProfessorLayout.badgePaddingH, vertical: CalendarioProfessorLayout.badgePaddingV),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(CalendarioProfessorLayout.badgeRadius)),
      child: Center(child: Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
    );
  }
}