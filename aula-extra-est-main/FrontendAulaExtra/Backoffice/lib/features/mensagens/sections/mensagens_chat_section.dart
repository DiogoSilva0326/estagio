import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/mensagem_thread.dart';
import '../widgets/mensagem_bubble.dart';

class MensagensChatSection extends StatelessWidget {
  const MensagensChatSection({required this.thread, super.key});

  final MensagemThread? thread;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: thread == null
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Selecione uma conversa para ver as mensagens.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.307,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Column(
              children: [
                _ChatHeader(thread: thread!),
                Container(height: 1.165, color: AppColors.borderSoft),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      37.273,
                      37.273,
                      37.273,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'Hoje',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13.978,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 27.955),
                        for (
                          var index = 0;
                          index < thread!.messages.length;
                          index++
                        ) ...[
                          MensagemBubble(entry: thread!.messages[index]),
                          if (index != thread!.messages.length - 1)
                            const SizedBox(height: 27.955),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(height: 1.165, color: AppColors.borderSoft),
                const _ReadOnlyFooter(),
              ],
            ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.thread});

  final MensagemThread thread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(27.955),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: thread.type == MensagemThreadType.suporte
                  ? const Color(0xFFEAF2FF)
                  : const Color(0xFFFFF2E8),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              thread.avatarInitials,
              style: TextStyle(
                color: thread.type == MensagemThreadType.suporte
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFFB7B02),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 18.637),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32.614,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.512,
                  ),
                ),
                const SizedBox(height: 4.659),
                Text(
                  thread.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15.143,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyFooter extends StatelessWidget {
  const _ReadOnlyFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(18.637),
      child: Row(
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 18.637,
            color: AppColors.textMuted,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo de leitura — Administradores podem monitorizar mas não enviar mensagens.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
