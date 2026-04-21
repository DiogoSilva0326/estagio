import 'dart:math' as math;

import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_professor_mobile_intro.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_professor_mobile_payment_card.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_professor_pagination.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_professor_mobile_stat_card.dart';
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
  const PagamentosProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<PagamentosProfessorContentSection> createState() =>
      _PagamentosProfessorContentSectionState();
}

class _PagamentosProfessorContentSectionState
    extends State<PagamentosProfessorContentSection> {
  final PaymentsService _paymentsService = PaymentsService();
  static const int _itemsPerPage = 5;
  late Future<ProfessorPaymentSummaryDto> _summaryFuture;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _paymentsService.fetchMyTeacherSummary();
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
      _summaryFuture = _paymentsService.fetchMyTeacherSummary();
    });
  }

  int _totalPages(List<ProfessorPaymentHistoryItemDto> history) {
    return math.max(1, (history.length / _itemsPerPage).ceil());
  }

  List<ProfessorPaymentHistoryItemDto> _currentPageItems(
    List<ProfessorPaymentHistoryItemDto> history,
  ) {
    final totalPages = _totalPages(history);
    final currentPage = _currentPage.clamp(1, totalPages);
    final start = (currentPage - 1) * _itemsPerPage;
    final end = math.min(start + _itemsPerPage, history.length);

    if (_currentPage != currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _currentPage = currentPage;
        });
      });
    }

    if (start >= end) {
      return const <ProfessorPaymentHistoryItemDto>[];
    }

    return history.sublist(start, end);
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

  Widget _buildMobileActionButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Color foregroundColor,
    Gradient? gradient,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: PagamentosProfessorLayout.mobileActionHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.mobileActionRadius,
          ),
          border: borderColor == null ? null : Border.all(color: borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              PagamentosProfessorLayout.mobileActionRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foregroundColor, size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(ProfessorPaymentSummaryDto summary) {
    final currentItems = _currentPageItems(summary.history);
    final totalPages = _totalPages(summary.history);

    return Container(
      width: double.infinity,
      color: PagamentosProfessorColors.background,
      padding: const EdgeInsets.fromLTRB(
        PagamentosProfessorLayout.mobileHorizontalPadding,
        PagamentosProfessorLayout.mobileTopPadding,
        PagamentosProfessorLayout.mobileHorizontalPadding,
        PagamentosProfessorLayout.mobileBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PagamentosProfessorMobileIntro(
            title: 'Pagamentos',
            subtitle:
                'Acompanhe ganhos, pagamentos pendentes e o histórico das suas aulas.',
          ),
          const SizedBox(height: PagamentosProfessorLayout.mobileSectionGap),
          Row(
            children: [
              Expanded(
                child: PagamentosProfessorMobileStatCard(
                  value: formatProfessorPaymentAmount(
                    summary.totalReceived,
                    currency: summary.currency,
                  ),
                  label: 'Recebido',
                  icon: Icons.payments_rounded,
                  borderColor: const Color(0xFFB9F8CF),
                  valueColor: PagamentosProfessorColors.valueGreenText,
                  labelColor: const Color(0xFF008236),
                  gradient: const LinearGradient(
                    begin: Alignment(-0.86, -0.5),
                    end: Alignment(0.86, 0.5),
                    colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PagamentosProfessorMobileStatCard(
                  value: formatProfessorPaymentAmount(
                    summary.pendingAmount,
                    currency: summary.currency,
                  ),
                  label: 'Pendente',
                  icon: Icons.hourglass_bottom_rounded,
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
              const SizedBox(width: 8),
              Expanded(
                child: PagamentosProfessorMobileStatCard(
                  value: summary.transactionsCount.toString(),
                  label: 'Movimentos',
                  icon: Icons.receipt_long_rounded,
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
            ],
          ),
          const SizedBox(height: 14),
          _buildMobileActionButton(
            onTap: () => _showWithdrawalDialog(),
            label: 'Solicitar saque',
            icon: Icons.account_balance_wallet_rounded,
            foregroundColor: Colors.white,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PagamentosProfessorColors.withdrawGradientTop,
                PagamentosProfessorColors.withdrawGradientBottom,
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildMobileActionButton(
            onTap: () => _showDisputeDialog(summary),
            label: 'Submeter reclamação',
            icon: Icons.report_problem_rounded,
            foregroundColor: PagamentosProfessorColors.disputeAccent,
            backgroundColor: PagamentosProfessorColors.disputeBackground,
            borderColor: const Color(0xFFFECED3),
          ),
          const SizedBox(height: PagamentosProfessorLayout.mobileSectionGap),
          const Text(
            'Histórico de pagamentos',
            style: TextStyle(
              color: PagamentosProfessorColors.title,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
            ),
          ),
          const SizedBox(height: 12),
          if (currentItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PagamentosProfessorColors.mobileSurface,
                borderRadius: BorderRadius.circular(
                  PagamentosProfessorLayout.mobileCardRadius,
                ),
                border: Border.all(color: PagamentosProfessorColors.cardBorder),
              ),
              child: const Text(
                'Ainda não existem pagamentos para mostrar.',
                style: TextStyle(
                  color: PagamentosProfessorColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
            )
          else
            Column(
              children: List.generate(currentItems.length, (index) {
                final payment = currentItems[index];
                final paymentTitle = payment.lessonTitle.isNotEmpty
                    ? payment.lessonTitle
                    : payment.subject;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == currentItems.length - 1 ? 0 : 12,
                  ),
                  child: PagamentosProfessorMobilePaymentCard(
                    payment: payment,
                    title: paymentTitle,
                    formattedDate: formatProfessorPaymentDateTime(
                      payment.lessonStart ?? payment.paymentDate,
                    ),
                    formattedAmount: formatProfessorPaymentAmount(
                      payment.netAmount,
                      currency: payment.currency,
                    ),
                    onDetailsTap: () => _showDetails(payment),
                  ),
                );
              }),
            ),
          const SizedBox(height: 16),
          PagamentosProfessorPagination(
            currentPage: _currentPage.clamp(1, totalPages),
            totalPages: totalPages,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
        ],
      ),
    );
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

    if (widget.isMobile) {
      return FutureBuilder<ProfessorPaymentSummaryDto>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: PagamentosProfessorColors.background,
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Container(
              color: PagamentosProfessorColors.background,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pagamentos',
                    style: TextStyle(
                      color: PagamentosProfessorColors.title,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 36 / 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Tentar novamente'),
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildMobileContent(snapshot.data!);
        },
      );
    }

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
                      final currentItems = _currentPageItems(summary.history);
                      final totalPages = _totalPages(summary.history);

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
                            rows: currentItems,
                            onDetailsTap: _showDetails,
                          ),
                          const SizedBox(height: 16),
                          PagamentosProfessorPagination(
                            currentPage: _currentPage.clamp(1, totalPages),
                            totalPages: totalPages,
                            onPageChanged: (page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
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
