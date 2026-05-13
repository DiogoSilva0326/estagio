import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_layout.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:flutter/material.dart';

class NotificacoesProfessorUnreadSummaryCard extends StatelessWidget {
  const NotificacoesProfessorUnreadSummaryCard({
    super.key,
    required this.unreadCount,
    required this.config,
    this.isMobile = false,
  });

  final int unreadCount;
  final bool isMobile;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    final isOrange = config.roleName == 'Explicador';

    final padding = isMobile
        ? const EdgeInsets.all(20)
        : const EdgeInsets.all(28);
    final iconCircle = isMobile ? 44.82 : 56.0;
    final iconSize = isMobile ? 22.4 : 28.0;
    final countStyle = TextStyle(
      fontSize: isMobile ? 29.0 : 28,
      fontWeight: FontWeight.w700,
      color: NotificacoesProfessorColors.title,
      height: 1.05,
    );
    final labelStyle = TextStyle(
      fontSize: isMobile ? 14.0 : 16,
      fontWeight: FontWeight.w400,
      color: NotificacoesProfessorColors.subtitle,
      height: 1.35,
    );

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          NotificacoesProfessorLayout.cardRadius,
        ),
        border: Border.all(
          color: isOrange ? const Color(0xFFFFE2CC) : config.primaryColor.withOpacity(0.25),
          width: NotificacoesProfessorLayout.cardBorderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconCircle,
            height: iconCircle,
            decoration: BoxDecoration(
              color: config.primaryColor, 
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$unreadCount', style: countStyle),
              Text('Notificações não lidas', style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}