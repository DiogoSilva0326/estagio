import 'package:flutter/material.dart';

import '../models/pagamento_item.dart';
import 'pagamentos_header_section.dart';
import 'pagamentos_metrics_section.dart';
import 'pagamentos_transactions_section.dart';

class PagamentosOverviewSection extends StatelessWidget {
  const PagamentosOverviewSection({
    required this.volumeTotalMes,
    required this.comissoesPlataforma,
    required this.payoutsPendentes,
    required this.items,
    required this.isLoading,
    required this.warningMessage,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onExportPressed,
    super.key,
  });

  final String volumeTotalMes;
  final String comissoesPlataforma;
  final String payoutsPendentes;
  final List<PagamentoItem> items;
  final bool isLoading;
  final String? warningMessage;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onExportPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PagamentosHeaderSection(
          onExportPressed: onExportPressed,
          exportEnabled: items.isNotEmpty,
        ),
        const SizedBox(height: 37.273),
        PagamentosMetricsSection(
          volumeTotalMes: volumeTotalMes,
          comissoesPlataforma: comissoesPlataforma,
          payoutsPendentes: payoutsPendentes,
        ),
        const SizedBox(height: 37.273),
        PagamentosTransactionsSection(
          items: items,
          isLoading: isLoading,
          warningMessage: warningMessage,
          selectedIds: selectedIds,
          onSelectionChanged: onSelectionChanged,
          onSelectAll: onSelectAll,
        ),
      ],
    );
  }
}
