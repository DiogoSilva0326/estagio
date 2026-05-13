import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_layout.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:flutter/material.dart';

class NotificacoesProfessorMarkAllButton extends StatelessWidget {
  const NotificacoesProfessorMarkAllButton({
    super.key,
    required this.enabled,
    required this.onTap,
    required this.config,
    this.isMobile = false,
  });

  final bool enabled;
  final VoidCallback onTap;
  final TeachingRoleConfig config;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Text(
            'Marcar todas como lidas',
            style: TextStyle(
              color: enabled
                  ? config.primaryColor
                  : const Color(0xFF9CA3AF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: NotificacoesProfessorLayout.markAllButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            NotificacoesProfessorLayout.markAllButtonRadius,
          ),
          border: Border.all(
            color: NotificacoesProfessorColors.buttonBorder,
            width: NotificacoesProfessorLayout.markAllButtonBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(
            NotificacoesProfessorLayout.markAllButtonRadius,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.355),
            child: Center(
              child: Text(
                'Marcar todas como lidas',
                style: TextStyle(
                  color: NotificacoesProfessorColors.buttonText,
                  fontSize: NotificacoesProfessorLayout.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  height:
                      NotificacoesProfessorLayout.bodyLineHeight /
                      NotificacoesProfessorLayout.bodyFontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}