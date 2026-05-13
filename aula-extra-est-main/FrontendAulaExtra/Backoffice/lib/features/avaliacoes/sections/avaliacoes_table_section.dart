import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/avaliacao_item.dart';
import '../widgets/avaliacao_action_button.dart';
import '../widgets/avaliacao_stars_display.dart';

class AvaliacoesTableSection extends StatelessWidget {
  const AvaliacoesTableSection({
    required this.title,
    required this.items,
    required this.submittingIds,
    required this.onModerate,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final List<AvaliacaoItem> items;
  final Set<String> submittingIds;
  final Future<void> Function(AvaliacaoItem item, bool approved) onModerate;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(27.955, 24, 27.955, 18.637),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 18.637),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1310),
                child: Column(
                  children: [
                    const _AvaliacoesTableHeader(),
                    if (items.isEmpty)
                      _EmptyStateRow(message: emptyMessage)
                    else
                      for (var index = 0; index < items.length; index++)
                        _AvaliacoesTableRow(
                          item: items[index],
                          isSubmitting: submittingIds.contains(items[index].id),
                          onModerate: onModerate,
                          showDivider: index != items.length - 1,
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvaliacoesTableHeader extends StatelessWidget {
  const _AvaliacoesTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _HeaderCell('AVALIAÇÃO', 140),
          _HeaderCell('ALUNO', 168),
          _HeaderCell('PROFISSIONAL', 176),
          _HeaderCell('DISCIPLINA', 150),
          _HeaderCell('ESTRELAS', 166),
          _HeaderCell('COMENTÁRIO', 190),
          _HeaderCell('DATA', 108),
          _HeaderCell('ESTADO', 164),
          _HeaderCell('AÇÕES', 86),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, this.width);

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.813,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3563,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _AvaliacoesTableRow extends StatelessWidget {
  const _AvaliacoesTableRow({
    required this.item,
    required this.isSubmitting,
    required this.onModerate,
    required this.showDivider,
  });

  final AvaliacaoItem item;
  final bool isSubmitting;
  final Future<void> Function(AvaliacaoItem item, bool approved) onModerate;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: item.comment.length > 42 ? 118 : 94,
      child: Row(
        children: [
          _BodyCell(item.code, width: 140, fontWeight: FontWeight.w700),
          _BodyCell(item.aluno, width: 168),
          _BodyCell(item.explicador, width: 176),
          _BodyCell(item.disciplina, width: 150),
          SizedBox(
            width: 166,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AvaliacaoStarsDisplay(value: item.estrelas),
            ),
          ),
          _CommentCell(item.comment, width: 190),
          _BodyCell(item.dateLabel, width: 108),
          SizedBox(
            width: 164,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel,
                color: item.statusColor,
                backgroundColor: item.statusBackgroundColor,
              ),
            ),
          ),
          SizedBox(
            width: 86,
            child: Row(
              children: [
                AvaliacaoActionButton(
                  action: const AvaliacaoAction(
                    type: AvaliacaoActionType.aprovar,
                    icon: Icons.check_rounded,
                    backgroundColor: Color(0x1A12B76A),
                    iconColor: Color(0xFF12B76A),
                    tooltip: 'Aprovar avaliação',
                  ),
                  enabled: !isSubmitting,
                  isLoading: isSubmitting,
                  onTap: () => onModerate(item, true),
                ),
                const SizedBox(width: 9.318),
                AvaliacaoActionButton(
                  action: const AvaliacaoAction(
                    type: AvaliacaoActionType.rejeitar,
                    icon: Icons.close_rounded,
                    backgroundColor: Color(0x1AEF4444),
                    iconColor: Color(0xFFEF4444),
                    tooltip: 'Rejeitar avaliação',
                  ),
                  enabled: !isSubmitting,
                  onTap: () => onModerate(item, false),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        const Divider(height: 1.165, color: Color(0x80F3F4F6)),
      ],
    );
  }
}

class _EmptyStateRow extends StatelessWidget {
  const _EmptyStateRow({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16.307,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(
    this.label, {
    required this.width,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final double width;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF4A5565),
          fontSize: 16.307,
          fontWeight: fontWeight,
          letterSpacing: -0.1752,
        ),
      ),
    );
  }
}

class _CommentCell extends StatelessWidget {
  const _CommentCell(this.comment, {required this.width});

  final String comment;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        '“$comment”',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF4A5565),
          fontSize: 15.143,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.15,
          height: 1.55,
        ),
      ),
    );
  }
}
