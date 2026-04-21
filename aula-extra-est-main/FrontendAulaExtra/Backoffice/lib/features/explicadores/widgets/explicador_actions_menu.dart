import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/explicador_item.dart';
import 'review_candidatura_dialog.dart';

enum _ExplicadorAction { review, ban }

class ExplicadorActionsMenu extends StatelessWidget {
  const ExplicadorActionsMenu({required this.item, super.key});

  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ExplicadorAction>(
      tooltip: 'Ações do explicador',
      color: Colors.white,
      elevation: 10,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _ExplicadorAction.review:
            showDialog<void>(
              context: context,
              barrierColor: const Color(0x73000000),
              builder: (_) => ReviewCandidaturaDialog(item: item),
            );
          case _ExplicadorAction.ban:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'A ação de banir `${item.name}` pode ser ligada a seguir.',
                ),
              ),
            );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<_ExplicadorAction>(
          value: _ExplicadorAction.review,
          child: _MenuActionRow(
            icon: Icons.visibility_outlined,
            label: 'Rever candidatura',
          ),
        ),
        PopupMenuItem<_ExplicadorAction>(
          value: _ExplicadorAction.ban,
          child: _MenuActionRow(
            icon: Icons.block_outlined,
            label: 'Banir explicador',
            destructive: true,
          ),
        ),
      ],
      child: const SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          Icons.more_horiz_rounded,
          size: 23.296,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _MenuActionRow extends StatelessWidget {
  const _MenuActionRow({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.textPrimary;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
