import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/mensagem_thread.dart';

class MensagemThreadTile extends StatelessWidget {
  const MensagemThreadTile({
    required this.thread,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final MensagemThread thread;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF8FAFC) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18.637),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFF8FAFC),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _avatarBackgroundColor(thread.type),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  thread.avatarInitials,
                  style: TextStyle(
                    color: _avatarTextColor(thread.type),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15.143,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          thread.lastMessageTime,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.813,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.659),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (thread.unreadCount > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 23,
                              minHeight: 23,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFB7B02),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${thread.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.813,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
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

  Color _avatarBackgroundColor(MensagemThreadType type) {
    switch (type) {
      case MensagemThreadType.alunoExplicador:
        return const Color(0xFFFFF2E8);
      case MensagemThreadType.suporte:
        return const Color(0xFFEAF2FF);
    }
  }

  Color _avatarTextColor(MensagemThreadType type) {
    switch (type) {
      case MensagemThreadType.alunoExplicador:
        return const Color(0xFFFB7B02);
      case MensagemThreadType.suporte:
        return const Color(0xFF2563EB);
    }
  }
}
