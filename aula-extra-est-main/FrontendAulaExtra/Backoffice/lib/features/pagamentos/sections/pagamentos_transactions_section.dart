import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/pagamento_item.dart';
import '../../sessoes_aulas/widgets/sessoes_aulas_filter_chip.dart';

class PagamentosTransactionsSection extends StatelessWidget {
  const PagamentosTransactionsSection({
    required this.items,
    required this.isLoading,
    required this.warningMessage,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    super.key,
  });

  final List<PagamentoItem> items;
  final bool isLoading;
  final String? warningMessage;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final ValueChanged<bool> onSelectAll;

  @override
  Widget build(BuildContext context) {
    final selectedCount = items.where((item) => selectedIds.contains(item.id)).length;
    final allSelected = items.isNotEmpty && selectedCount == items.length;
    final hasPartialSelection = selectedCount > 0 && !allSelected;

    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(37.273, 23.296, 37.273, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transações e Faturação',
                  style: TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SessoesAulasFilterChip(
                        label: 'RESULTADOS: ${items.length}',
                        width: 174.137,
                      ),
                      const SizedBox(width: 18.637),
                      SessoesAulasFilterChip(
                        label: 'SELECIONADAS: $selectedCount',
                        width: 194.137,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1192),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9.318, 18.637, 27.955, 18.637),
                child: Column(
                  children: [
                    _TransactionsHeader(
                      allSelected: allSelected,
                      hasPartialSelection: hasPartialSelection,
                      onSelectAll: onSelectAll,
                    ),
                    if (warningMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD39A)),
                          ),
                          child: Text(
                            warningMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB54708),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          'Sem transações para apresentar.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15.143,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      for (var index = 0; index < items.length; index++)
                        _TransactionsRow(
                          item: items[index],
                          selected: selectedIds.contains(items[index].id),
                          onSelectionChanged: onSelectionChanged,
                          showDivider: index != items.length - 1,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  const _TransactionsHeader({
    required this.allSelected,
    required this.hasPartialSelection,
    required this.onSelectAll,
  });

  final bool allSelected;
  final bool hasPartialSelection;
  final ValueChanged<bool> onSelectAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Center(
              child: Checkbox(
                value: hasPartialSelection ? null : allSelected,
                tristate: true,
                onChanged: (value) => onSelectAll(value ?? false),
              ),
            ),
          ),
          const _HeaderCell('PAGAMENTOS', 150),
          const _HeaderCell('DISCIPLINA', 148),
          const _HeaderCell('DATA', 108),
          const _HeaderCell('ALUNO', 168),
          const _HeaderCell('EXPLICADOR', 175),
          const _HeaderCell('VALOR TOTAL', 116),
          const _HeaderCell('COMISSÃO', 160),
          const _HeaderCell('VALOR EXPLICADOR', 154),
          const _HeaderCell('ESTADO', 132),
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

class _TransactionsRow extends StatelessWidget {
  const _TransactionsRow({
    required this.item,
    required this.selected,
    required this.onSelectionChanged,
    required this.showDivider,
  });

  final PagamentoItem item;
  final bool selected;
  final void Function(String id, bool selected) onSelectionChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 68.723,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Center(
              child: Checkbox(
                value: selected,
                onChanged: (value) =>
                    onSelectionChanged(item.id, value ?? false),
              ),
            ),
          ),
          _BodyCell(item.code, width: 150, fontWeight: FontWeight.w700),
          _BodyCell(item.subject, width: 148),
          _BodyCell(item.dateLabel, width: 108),
          _BodyCell(item.aluno, width: 168),
          _BodyCell(item.explicador, width: 175),
          _BodyCell(item.totalAmount, width: 116),
          _BodyCell(item.commissionLabel, width: 160),
          _BodyCell(item.teacherAmount, width: 154),
          SizedBox(
            width: 132,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel,
                color: item.statusColor,
                backgroundColor: item.statusBackgroundColor,
              ),
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
