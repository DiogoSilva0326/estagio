import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_professor_formatters.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_summary_card.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_table_card.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_withdraw_button.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/payment_details_dialog.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/withdrawal_dialog.dart';
import 'package:aula_extra/features/shared/payments/widgets/payment_dispute_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PagamentosProfessorContentSection extends StatefulWidget {
  const PagamentosProfessorContentSection({super.key});

  @override
  State<PagamentosProfessorContentSection> createState() =>
      _PagamentosProfessorContentSectionState();
}

class _PagamentosProfessorContentSectionState
    extends State<PagamentosProfessorContentSection> {
  final PaymentsService _paymentsService = PaymentsService();
  late Future<ProfessorPaymentSummaryDto> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _paymentsService.fetchMyTeacherSummary();
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = _paymentsService.fetchMyTeacherSummary();
    });
  }

  Future<void> _showDetails(ProfessorPaymentHistoryItemDto payment) async {
    try {
      final details = await _paymentsService.fetchMyTeacherPaymentDetails(
        payment.id,
      );
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => PaymentDetailsDialog(
          details: details,
          onClose: () => Navigator.of(dialogContext).pop(),
          onPrintReceipt: () => _openTeacherReceipt(details),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _openTeacherReceipt(ProfessorPaymentDetailsDto details) async {
    final receiptUrl = details.receiptUrl?.trim();
    if (receiptUrl == null || receiptUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este pagamento ainda não tem recibo disponível.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(receiptUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o recibo.')),
      );
    }
  }

  Future<void> _showWithdrawalDialog() async {
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => const WithdrawalDialog(),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido de saque preenchido com sucesso.'),
        ),
      );
    }
  }

  List<PaymentDisputeOption> _buildDisputeOptions(
    List<ProfessorPaymentHistoryItemDto> history,
    String currency,
  ) {
    return history
        .map(
          (item) => PaymentDisputeOption(
            id: item.id,
            paymentSource: 'reservation_payment',
            title: item.lessonTitle.isNotEmpty
                ? item.lessonTitle
                : item.subject,
            subtitle:
                '${item.studentName} • ${formatProfessorPaymentAmount(item.grossAmount, currency: currency)} • ${item.reference ?? item.id}',
          ),
        )
        .toList(growable: false);
  }

  Future<void> _showDisputeDialog(ProfessorPaymentSummaryDto summary) async {
    if (summary.history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ainda não existem pagamentos para reclamar.'),
        ),
      );
      return;
    }

    final account = context.read<UserProvider>().account;
    final didSubmit = await showDialog<bool>(
      context: context,
      builder: (_) => PaymentDisputeDialog(
        options: _buildDisputeOptions(summary.history, summary.currency),
        initialName: account?.fullName?.trim().isNotEmpty == true
            ? account!.fullName!.trim()
            : (account?.username?.trim() ?? ''),
        initialEmail: account?.email?.trim() ?? '',
        onSubmit: _paymentsService.createMyDispute,
      ),
    );

    if (didSubmit == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reclamação submetida com sucesso.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: PagamentosProfessorColors.title,
      fontSize: PagamentosProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height:
          PagamentosProfessorLayout.titleLineHeight /
          PagamentosProfessorLayout.titleFontSize,
    );

    return Container(
      color: PagamentosProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: PagamentosProfessorLayout.pageLeftPadding,
            right: PagamentosProfessorLayout.pageRightPadding,
            top: PagamentosProfessorLayout.pageTopPadding,
            bottom: PagamentosProfessorLayout.pageBottomPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(selectedIndex: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PagamentosProfessorLayout.contentPadding,
                    PagamentosProfessorLayout.contentPadding,
                    PagamentosProfessorLayout.contentPadding,
                    0,
                  ),
                  child: FutureBuilder<ProfessorPaymentSummaryDto>(
                    future: _summaryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: PagamentosProfessorLayout.titleLineHeight,
                              child: Text('Pagamentos', style: titleStyle),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              snapshot.error.toString(),
                              style: const TextStyle(
                                color: Color(0xFFB42318),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        );
                      }

                      final summary = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: PagamentosProfessorLayout.titleLineHeight,
                            child: Text('Pagamentos', style: titleStyle),
                          ),
                          const SizedBox(height: 28.889),
                          SizedBox(
                            height: PagamentosProfessorLayout.summaryCardHeight,
                            child: Row(
                              children: [
                                PagamentosSummaryCard(
                                  title: 'Total Recebido',
                                  value: formatProfessorPaymentAmount(
                                    summary.totalReceived,
                                    currency: summary.currency,
                                  ),
                                  subtitle: 'Pagamentos concluídos',
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      PagamentosProfessorColors.summaryGreenTop,
                                      PagamentosProfessorColors
                                          .summaryGreenBottom,
                                    ],
                                  ),
                                  icon: Icons.payments_rounded,
                                ),
                                const SizedBox(
                                  width:
                                      PagamentosProfessorLayout.summaryCardsGap,
                                ),
                                PagamentosSummaryCard(
                                  title: 'Ganhos Pendentes',
                                  value: formatProfessorPaymentAmount(
                                    summary.pendingAmount,
                                    currency: summary.currency,
                                  ),
                                  subtitle: 'A aguardar libertação',
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      PagamentosProfessorColors
                                          .summaryOrangeTop,
                                      PagamentosProfessorColors
                                          .summaryOrangeBottom,
                                    ],
                                  ),
                                  icon: Icons.hourglass_bottom_rounded,
                                ),
                                const SizedBox(
                                  width:
                                      PagamentosProfessorLayout.summaryCardsGap,
                                ),
                                PagamentosSummaryCard(
                                  title: 'Total Este Mês',
                                  value: formatProfessorPaymentAmount(
                                    summary.totalThisMonth,
                                    currency: summary.currency,
                                  ),
                                  subtitle:
                                      '${summary.transactionsCount} movimentos',
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      PagamentosProfessorColors.summaryBlueTop,
                                      PagamentosProfessorColors
                                          .summaryBlueBottom,
                                    ],
                                  ),
                                  icon: Icons.calendar_month_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28.889),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _showDisputeDialog(summary),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF15C64),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                icon: const Icon(Icons.report_problem_rounded),
                                label: const Text(
                                  'Submeter reclamação sobre pagamentos',
                                ),
                              ),
                              const SizedBox(width: 12),
                              PagamentosWithdrawButton(
                                onTap: _showWithdrawalDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 19.171),
                          PagamentosTableCard(
                            rows: summary.history,
                            onDetailsTap: _showDetails,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
