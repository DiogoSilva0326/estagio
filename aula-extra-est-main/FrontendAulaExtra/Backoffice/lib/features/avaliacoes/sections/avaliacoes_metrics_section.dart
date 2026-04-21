import 'package:flutter/material.dart';

import '../widgets/avaliacao_metric_card.dart';

class AvaliacoesMetricsSection extends StatelessWidget {
  const AvaliacoesMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSingleColumn = constraints.maxWidth < 920;

        if (isSingleColumn) {
          return const Column(
            children: [
              AvaliacaoMetricCard(
                title: 'Avaliação Média Global',
                value: '4.8',
                caption: 'Baseado em 1.200 avaliações',
                icon: Icons.star_rounded,
                iconBackgroundColor: Color(0x1AF79009),
                iconColor: Color(0xFFF79009),
              ),
              SizedBox(height: 18.637),
              AvaliacaoMetricCard(
                title: 'Pendentes de Moderação',
                value: '14',
                caption: 'Aguardam revisão manual',
                icon: Icons.pending_actions_rounded,
                iconBackgroundColor: Color(0x1AFC9039),
                iconColor: Color(0xFFFC9039),
              ),
            ],
          );
        }

        return Row(
          children: const [
            Expanded(
              child: AvaliacaoMetricCard(
                title: 'Avaliação Média Global',
                value: '4.8',
                caption: 'Baseado em 1.200 avaliações',
                icon: Icons.star_rounded,
                iconBackgroundColor: Color(0x1AF79009),
                iconColor: Color(0xFFF79009),
              ),
            ),
            SizedBox(width: 27.955),
            Expanded(
              child: AvaliacaoMetricCard(
                title: 'Pendentes de Moderação',
                value: '14',
                caption: 'Aguardam revisão manual',
                icon: Icons.pending_actions_rounded,
                iconBackgroundColor: Color(0x1AFC9039),
                iconColor: Color(0xFFFC9039),
              ),
            ),
          ],
        );
      },
    );
  }
}
