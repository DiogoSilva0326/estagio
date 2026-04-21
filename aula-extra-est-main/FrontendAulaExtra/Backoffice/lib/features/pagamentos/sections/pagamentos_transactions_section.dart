import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../constants/pagamentos_mock_data.dart';
import '../models/pagamento_item.dart';

class PagamentosTransactionsSection extends StatelessWidget {
  const PagamentosTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(37.273, 23.296, 37.273, 20),
            child: Text(
              'Últimas Transações',
              style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
                height: 1.05,
              ),
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  27.955,
                  18.637,
                  27.955,
                  18.637,
                ),
                child: Column(
                  children: [
                    const _TransactionsHeader(),
                    for (
                      var index = 0;
                      index < PagamentosMockData.transactions.length;
                      index++
                    )
                      _TransactionsRow(
                        item: PagamentosMockData.transactions[index],
                        showDivider:
                            index != PagamentosMockData.transactions.length - 1,
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
  const _TransactionsHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _HeaderCell('PAGAMENTOS', 150),
          _HeaderCell('DATA', 108),
          _HeaderCell('ALUNO', 168),
          _HeaderCell('EXPLICADOR', 175),
          _HeaderCell('VALOR TOTAL', 116),
          _HeaderCell('COMISSÃO', 160),
          _HeaderCell('VALOR EXPLICADOR', 154),
          _HeaderCell('ESTADO', 132),
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
  const _TransactionsRow({required this.item, required this.showDivider});

  final PagamentoItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 68.723,
      child: Row(
        children: [
          _BodyCell(item.code, width: 150, fontWeight: FontWeight.w700),
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
