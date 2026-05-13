import 'package:flutter/material.dart';

import '../services/backoffice_avaliacoes_service.dart';
import '../widgets/avaliacao_metric_card.dart';

class AvaliacoesMetricsSection extends StatelessWidget {
  const AvaliacoesMetricsSection({
    required this.summary,
    required this.scopeLabel,
    super.key,
  });

  final BackofficeAvaliacoesSummary summary;
  final String scopeLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSingleColumn = constraints.maxWidth < 920;

        if (isSingleColumn) {
          return Column(
            children: [
              AvaliacaoMetricCard(
                title: 'Avaliação Média $scopeLabel',
                value: summary.averageRating.toStringAsFixed(1),
                caption: 'Baseado em ${summary.totalEvaluations} avaliacoes',
                icon: Icons.star_rounded,
                iconBackgroundColor: Color(0x1AF79009),
                iconColor: Color(0xFFF79009),
              ),
              const SizedBox(height: 18.637),
              AvaliacaoMetricCard(
                title: 'Pendentes de Moderação',
                value: '${summary.pendingModeration}',
                caption: 'Aguardam revisao manual nesta listagem',
                icon: Icons.pending_actions_rounded,
                iconBackgroundColor: Color(0x1AFC9039),
                iconColor: Color(0xFFFC9039),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: AvaliacaoMetricCard(
                title: 'Avaliação Média $scopeLabel',
                value: summary.averageRating.toStringAsFixed(1),
                caption: 'Baseado em ${summary.totalEvaluations} avaliacoes',
                icon: Icons.star_rounded,
                iconBackgroundColor: const Color(0x1AF79009),
                iconColor: const Color(0xFFF79009),
              ),
            ),
            const SizedBox(width: 27.955),
            Expanded(
              child: AvaliacaoMetricCard(
                title: 'Pendentes de Moderação',
                value: '${summary.pendingModeration}',
                caption: 'Aguardam revisao manual nesta listagem',
                icon: Icons.pending_actions_rounded,
                iconBackgroundColor: const Color(0x1AFC9039),
                iconColor: const Color(0xFFFC9039),
              ),
            ),
          ],
        );
      },
    );
  }
}
