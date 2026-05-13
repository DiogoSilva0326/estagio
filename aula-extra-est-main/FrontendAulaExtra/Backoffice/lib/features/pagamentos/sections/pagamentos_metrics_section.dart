import 'package:flutter/material.dart';

import '../widgets/pagamento_metric_card.dart';
import '../widgets/process_payouts_button.dart';

class PagamentosMetricsSection extends StatelessWidget {
  const PagamentosMetricsSection({
    required this.volumeTotalMes,
    required this.comissoesPlataforma,
    required this.payoutsPendentes,
    super.key,
  });

  static const double _cardHeight = 193.36;
  final String volumeTotalMes;
  final String comissoesPlataforma;
  final String payoutsPendentes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 900;
        final cards = [
          Expanded(
            child: PagamentoMetricCard(
              title: 'Volume Total (Mês)',
              value: volumeTotalMes,
              caption: 'Total transacionado na plataforma',
              icon: Icons.payments_outlined,
              iconBackgroundColor: Color(0x1A41A7D7),
              iconColor: Color(0xFF41A7D7),
              height: _cardHeight,
            ),
          ),
          SizedBox(width: 27.955),
          Expanded(
            child: PagamentoMetricCard(
              title: 'Comissões Plataforma',
              value: comissoesPlataforma,
              caption: 'Receita líquida retida',
              icon: Icons.account_balance_wallet_outlined,
              iconBackgroundColor: Color(0x1A12B76A),
              iconColor: Color(0xFF12B76A),
              height: _cardHeight,
            ),
          ),
          SizedBox(width: 27.955),
          Expanded(
            child: PagamentoMetricCard(
              title: 'Payouts Pendentes',
              value: payoutsPendentes,
              caption: '',
              icon: Icons.pending_actions_outlined,
              iconBackgroundColor: Color(0x1AFC9039),
              iconColor: Color(0xFFFC9039),
              height: _cardHeight,
              trailing: ProcessPayoutsButton(),
            ),
          ),
        ];

        if (isStacked) {
          return Column(
            children: [
              PagamentoMetricCard(
                title: 'Volume Total (Mês)',
                value: volumeTotalMes,
                caption: 'Total transacionado na plataforma',
                icon: Icons.payments_outlined,
                iconBackgroundColor: Color(0x1A41A7D7),
                iconColor: Color(0xFF41A7D7),
                height: _cardHeight,
              ),
              SizedBox(height: 18.637),
              PagamentoMetricCard(
                title: 'Comissões Plataforma',
                value: comissoesPlataforma,
                caption: 'Receita líquida retida',
                icon: Icons.account_balance_wallet_outlined,
                iconBackgroundColor: Color(0x1A12B76A),
                iconColor: Color(0xFF12B76A),
                height: _cardHeight,
              ),
              SizedBox(height: 18.637),
              PagamentoMetricCard(
                title: 'Payouts Pendentes',
                value: payoutsPendentes,
                caption: '',
                icon: Icons.pending_actions_outlined,
                iconBackgroundColor: Color(0x1AFC9039),
                iconColor: Color(0xFFFC9039),
                height: _cardHeight,
                trailing: ProcessPayoutsButton(),
              ),
            ],
          );
        }

        return Row(children: cards);
      },
    );
  }
}
