import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/core/data/payments/dtos/payment_summary_dto.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_constants.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_stat_card.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PagamentosContentSection extends StatefulWidget {
  const PagamentosContentSection({super.key});

  @override
  State<PagamentosContentSection> createState() => _PagamentosContentSectionState();
}

class _PagamentosContentSectionState extends State<PagamentosContentSection> {
  final PaymentsService _paymentsService = PaymentsService();
  late Future<PaymentSummaryDto> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<PaymentSummaryDto> _loadSummary() async {
    final summary = await _paymentsService.fetchMySummary();
    if (mounted) {
      final provider = context.read<UserProvider>();
      provider.setAccount(
        (provider.account ?? const UserAccount()).copyWith(
          creditsBalance: summary.availableCredits,
          creditsCurrency: summary.currency,
        ),
      );
    }
    return summary;
  }

  String _formatAmount(double value, {String currency = 'EUR'}) {
    final symbol = currency.toUpperCase() == 'EUR' ? '€' : currency;
    final fixed = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2).replaceAll('.', ',');
    return symbol == '€' ? '$fixed$symbol' : '$fixed $symbol';
  }

  Future<void> _openReceipt(PaymentHistoryItemDto item) async {
    final receiptUrl = item.receiptUrl?.trim();
    if (receiptUrl == null || receiptUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este pagamento ainda não tem recibo disponível.')),
      );
      return;
    }

    final uri = Uri.tryParse(receiptUrl);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o recibo.')),
      );
    }
  }

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
            child: FutureBuilder<PaymentSummaryDto>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pagamentos', style: PagamentosConstants.titleStyle),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Color(0xFFB42318), fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _summaryFuture = _loadSummary();
                          });
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  );
                }

                final summary = snapshot.data!;

                return Column(
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
                      children: [
                        Expanded(
                          child: PagamentosStatCard(
                            value: _formatAmount(summary.availableCredits, currency: summary.currency),
                            label: 'Créditos Disponíveis',
                            borderColor: const Color(0xFFFED7AA),
                            valueColor: const Color(0xFFEA580C),
                            labelColor: const Color(0xFFC2410C),
                            gradient: const LinearGradient(
                              begin: Alignment(-0.86, -0.5),
                              end: Alignment(0.86, 0.5),
                              colors: [Color(0xFFFFFBEB), Color(0xFFFFEDD5)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: PagamentosStatCard(
                            value: _formatAmount(summary.totalSpent, currency: summary.currency),
                            label: 'Total Gasto',
                            borderColor: const Color(0xFFBEDBFF),
                            valueColor: const Color(0xFF155DFC),
                            labelColor: const Color(0xFF1447E6),
                            gradient: const LinearGradient(
                              begin: Alignment(-0.86, -0.5),
                              end: Alignment(0.86, 0.5),
                              colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: PagamentosStatCard(
                            value: _formatAmount(summary.pendingAmount, currency: summary.currency),
                            label: 'Pendente',
                            borderColor: const Color(0xFFFFD6A7),
                            valueColor: const Color(0xFFF54900),
                            labelColor: const Color(0xFFCA3500),
                            gradient: const LinearGradient(
                              begin: Alignment(-0.86, -0.5),
                              end: Alignment(0.86, 0.5),
                              colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD4)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: PagamentosStatCard(
                            value: summary.transactionsCount.toString(),
                            label: 'Transações',
                            borderColor: const Color(0xFFB9F8CF),
                            valueColor: const Color(0xFF00A63E),
                            labelColor: const Color(0xFF008236),
                            gradient: const LinearGradient(
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
                    PagamentosTableCard(
                      rows: summary.history,
                      currency: summary.currency,
                      onReceiptTap: _openReceipt,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
