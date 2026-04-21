import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../constants/avaliacoes_mock_data.dart';
import '../models/avaliacao_item.dart';
import '../widgets/avaliacao_action_button.dart';
import '../widgets/avaliacao_stars_display.dart';

class AvaliacoesTableSection extends StatelessWidget {
  const AvaliacoesTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1310),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(27.955, 18.637, 27.955, 18.637),
            child: Column(
              children: [
                const _AvaliacoesTableHeader(),
                for (
                  var index = 0;
                  index < AvaliacoesMockData.items.length;
                  index++
                )
                  _AvaliacoesTableRow(
                    item: AvaliacoesMockData.items[index],
                    showDivider: index != AvaliacoesMockData.items.length - 1,
                  ),
              ],
            ),
          ),
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
          _HeaderCell('AVALIAÇÕES', 140),
          _HeaderCell('ALUNO', 168),
          _HeaderCell('EXPLICADOR', 176),
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
  const _AvaliacoesTableRow({required this.item, required this.showDivider});

  final AvaliacaoItem item;
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
                for (var index = 0; index < item.actions.length; index++) ...[
                  AvaliacaoActionButton(
                    action: item.actions[index],
                    onTap: () =>
                        _handleAction(context, item, item.actions[index]),
                  ),
                  if (index != item.actions.length - 1)
                    const SizedBox(width: 9.318),
                ],
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

  void _handleAction(
    BuildContext context,
    AvaliacaoItem item,
    AvaliacaoAction action,
  ) {
    late final String message;

    switch (action.type) {
      case AvaliacaoActionType.aprovar:
        message = 'Avaliação ${item.code} aprovada.';
        break;
      case AvaliacaoActionType.rejeitar:
        message = 'Avaliação ${item.code} rejeitada.';
        break;
      case AvaliacaoActionType.detalhes:
        message = 'A abrir detalhes da avaliação ${item.code}.';
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
