import 'package:flutter/material.dart';

import 'avaliacoes_header_section.dart';
import 'avaliacoes_metrics_section.dart';
import 'avaliacoes_table_section.dart';

class AvaliacoesOverviewSection extends StatelessWidget {
  const AvaliacoesOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvaliacoesHeaderSection(),
        SizedBox(height: 37.273),
        AvaliacoesMetricsSection(),
        SizedBox(height: 37.273),
        AvaliacoesTableSection(),
      ],
    );
  }
}
