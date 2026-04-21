import 'package:flutter/material.dart';

import 'pagamentos_header_section.dart';
import 'pagamentos_metrics_section.dart';
import 'pagamentos_transactions_section.dart';

class PagamentosOverviewSection extends StatelessWidget {
  const PagamentosOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PagamentosHeaderSection(),
        SizedBox(height: 37.273),
        PagamentosMetricsSection(),
        SizedBox(height: 37.273),
        PagamentosTransactionsSection(),
      ],
    );
  }
}
