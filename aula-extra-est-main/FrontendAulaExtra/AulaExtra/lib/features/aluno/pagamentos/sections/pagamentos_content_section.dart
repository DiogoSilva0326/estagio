import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_constants.dart';
import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_mock_data.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_stat_card.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_table.dart';
import 'package:flutter/material.dart';

class PagamentosContentSection extends StatelessWidget {
  const PagamentosContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PagamentosConstants.horizontalPadding,
        vertical: PagamentosConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 6),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pagamentos', style: PagamentosConstants.titleStyle),
                const SizedBox(height: 10.955),
                const Text(
                  'Gerencie seus pagamentos e pacotes de aulas',
                  style: PagamentosConstants.subtitleStyle,
                ),
                const SizedBox(height: 43.82),
                Row(
                  children: const [
                    Expanded(
                      child: PagamentosStatCard(
                        value: PagamentosMockData.totalGasto,
                        label: 'Total Gasto',
                        borderColor: Color(0xFFBEDBFF),
                        valueColor: Color(0xFF155DFC),
                        labelColor: Color(0xFF1447E6),
                        gradient: LinearGradient(
                          begin: Alignment(-0.86, -0.5),
                          end: Alignment(0.86, 0.5),
                          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                        ),
                      ),
                    ),
                    SizedBox(width: 32.87),
                    Expanded(
                      child: PagamentosStatCard(
                        value: PagamentosMockData.pendente,
                        label: 'Pendente',
                        borderColor: Color(0xFFFFD6A7),
                        valueColor: Color(0xFFF54900),
                        labelColor: Color(0xFFCA3500),
                        gradient: LinearGradient(
                          begin: Alignment(-0.86, -0.5),
                          end: Alignment(0.86, 0.5),
                          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD4)],
                        ),
                      ),
                    ),
                    SizedBox(width: 32.87),
                    Expanded(
                      child: PagamentosStatCard(
                        value: PagamentosMockData.transacoes,
                        label: 'Transações',
                        borderColor: Color(0xFFB9F8CF),
                        valueColor: Color(0xFF00A63E),
                        labelColor: Color(0xFF008236),
                        gradient: LinearGradient(
                          begin: Alignment(-0.86, -0.5),
                          end: Alignment(0.86, 0.5),
                          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 43.82),
                const Text('Histórico de Pagamentos', style: PagamentosConstants.sectionTitleStyle),
                const SizedBox(height: 21.91),
                const PagamentosTableCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
