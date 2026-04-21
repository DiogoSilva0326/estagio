import 'package:aula_extra/features/professor/notificacoes/widgets/notificacoes_professor_mark_all_button.dart';
import 'package:flutter/material.dart';

class NotificacoesProfessorMobileHeaderBlock extends StatelessWidget {
  const NotificacoesProfessorMobileHeaderBlock({
    super.key,
    required this.unreadCount,
    required this.canMarkAll,
    required this.onMarkAllTap,
  });

  final int unreadCount;
  final bool canMarkAll;
  final VoidCallback onMarkAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notificações',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101828),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          unreadCount > 0
              ? 'Acompanha aulas, tarefas e mensagens pendentes.'
              : 'Todas as tuas notificações estão em dia.',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4A5565),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: NotificacoesProfessorMarkAllButton(
            enabled: canMarkAll,
            onTap: onMarkAllTap,
            isMobile: true,
          ),
        ),
      ],
    );
  }
}
