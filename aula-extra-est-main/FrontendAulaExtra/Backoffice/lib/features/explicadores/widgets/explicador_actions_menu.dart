import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../profissionais/services/backoffice_professional_review_service.dart';
import '../models/explicador_item.dart';
import 'review_candidatura_dialog.dart';

enum _ExplicadorAction { review, ban }

class ExplicadorActionsMenu extends StatelessWidget {
  const ExplicadorActionsMenu({
    required this.item,
    super.key,
    this.entityLabel = 'explicador',
    this.reviewDialogEntityLabel = 'explicador',
    this.entityTitle = 'Explicador',
    this.onReviewUpdated,
  });

  final ExplicadorItem item;
  final String entityLabel;
  final String reviewDialogEntityLabel;
  final String entityTitle;
  final VoidCallback? onReviewUpdated;

  Future<bool> _confirmBan(BuildContext context) async {
    final shouldBan = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Banir $entityLabel'),
          content: Text(
            'Esta ação vai colocar ${item.name} como inativo e não verificado. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Banir'),
            ),
          ],
        );
      },
    );

    return shouldBan == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ExplicadorAction>(
      tooltip: 'Ações do $entityLabel',
      color: Colors.white,
      elevation: 10,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.zero,
      onSelected: (action) async {
        switch (action) {
          case _ExplicadorAction.review:
            final updated = await showDialog<bool>(
              context: context,
              barrierColor: const Color(0x73000000),
              builder: (_) => ReviewCandidaturaDialog(
                item: item,
                entityLabel: reviewDialogEntityLabel,
                entityTitle: entityTitle,
              ),
            );
            if (updated == true) {
              onReviewUpdated?.call();
            }
          case _ExplicadorAction.ban:
            final shouldBan = await _confirmBan(context);
            if (!shouldBan) {
              return;
            }

            try {
              await BackofficeProfessionalReviewService().banProfessor(
                item.idProfessor,
              );
              if (!context.mounted) {
                return;
              }

              onReviewUpdated?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$entityTitle ${item.name} foi colocado como inativo e não verificado.',
                  ),
                ),
              );
            } catch (error) {
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Não foi possível banir $entityLabel ${item.name}: $error',
                  ),
                ),
              );
            }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_ExplicadorAction>(
          value: _ExplicadorAction.review,
          child: const _MenuActionRow(
            icon: Icons.visibility_outlined,
            label: 'Rever candidatura',
          ),
        ),
        PopupMenuItem<_ExplicadorAction>(
          value: _ExplicadorAction.ban,
          child: _MenuActionRow(
            icon: Icons.block_outlined,
            label: 'Banir $entityLabel',
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
