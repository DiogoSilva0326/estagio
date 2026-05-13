import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/mensagem_thread.dart';

class MensagemBubble extends StatelessWidget {
  const MensagemBubble({required this.entry, super.key});

  final MensagemEntry entry;

  @override
  Widget build(BuildContext context) {
    final alignEnd = !entry.isIncoming;

    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 375),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: alignEnd ? const Color(0xFFFFF4E5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: alignEnd ? const Color(0xFFFFE1BF) : const Color(0xFFF3F4F6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15.143,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              entry.timeLabel,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.813,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
