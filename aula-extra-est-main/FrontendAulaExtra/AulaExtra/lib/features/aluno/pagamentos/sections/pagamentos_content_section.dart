import 'dart:math' as math;

import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/core/data/payments/dtos/payment_summary_dto.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_constants.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_mobile_intro.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_mobile_details_dialog.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_mobile_pagination.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_mobile_payment_card.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_mobile_stat_card.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_stat_card.dart';
import 'package:aula_extra/features/aluno/pagamentos/widgets/pagamentos_table.dart';
import 'package:aula_extra/features/shared/payments/widgets/payment_dispute_dialog.dart';
import 'package:aula_extra/core/data/payments/payment_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PagamentosContentSection extends StatefulWidget {
  const PagamentosContentSection({super.key});

  @override
  State<PagamentosContentSection> createState() =>
      _PagamentosContentSectionState();
}

enum _StudentPaymentRoleFilter { todos, explicador, tutor, psicologo }

class _PagamentosContentSectionState extends State<PagamentosContentSection> {
  final PaymentsService _paymentsService = PaymentsService();
  late Future<PaymentSummaryDto> _summaryFuture;
  static const int _mobileItemsPerPage = 3;
  int _mobileCurrentPage = 1;
  _StudentPaymentRoleFilter _selectedRoleFilter =
      _StudentPaymentRoleFilter.todos;

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
    final fixed = value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)
        .replaceAll('.', ',');
    return symbol == '€' ? '$fixed$symbol' : '$fixed $symbol';
  }

  Future<void> _openReceipt(PaymentHistoryItemDto item) async {
    final receiptUrl = item.receiptUrl?.trim();
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

  Color _statusBackgroundColor(String? status) {
    final statusKind = normalizePaymentStatus(status);
    if (statusKind == 'paid') {
      return const Color(0xFFDCFCE7);
    }
    if (statusKind == 'refunded') {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFFFEDD4);
  }

  Color _statusTextColor(String? status) {
    final statusKind = normalizePaymentStatus(status);
    if (statusKind == 'paid') {
      return const Color(0xFF008236);
    }
    if (statusKind == 'refunded') {
      return const Color(0xFFB42318);
    }
    return const Color(0xFFCA3500);
  }

  String _orDash(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return '—';
    }
    return normalized;
  }

  String _studentDisplayName(UserAccount? account) {
    final fullName = account?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    final username = account?.username?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    return 'Aluno';
  }

  Future<void> _showPaymentDetails(
    PaymentHistoryItemDto item,
    String currency,
  ) async {
    final account = context.read<UserProvider>().account;
    final amountLabel = _formatAmount(item.amount, currency: currency);
    final reference = _orDash(item.reference);
    final paymentSource = _orDash(item.paymentSource);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => PagamentosMobileDetailsDialog(
        title: 'Detalhes do pagamento',
        subtitle: _paymentTitle(item),
        studentName: _studentDisplayName(account),
        studentEmail: _orDash(account?.email),
        subject: _orDash(item.subject),
        lessonLabel: _paymentTypeLabel(item),
        paymentDateLabel: _formatMobileDate(item.date),
        statusLabel: paymentStatusLabel(item.status),
        statusBackgroundColor: _statusBackgroundColor(item.status),
        statusTextColor: _statusTextColor(item.status),
        grossAmountLabel: amountLabel,
        platformFeeLabel: '—',
        netAmountLabel: amountLabel,
        commissionLabel: '—',
        fixedFeeLabel: '—',
        referenceLabel: reference,
        reservationLabel: paymentSource,
        transactionLabel: _orDash(item.id),
        onClose: () => Navigator.of(dialogContext).pop(),
        onReceiptTap: () {
          Navigator.of(dialogContext).pop();
          _openReceipt(item);
        },
      ),
    );
  }

  List<PaymentDisputeOption> _buildDisputeOptions(
    List<PaymentHistoryItemDto> history,
    String currency,
  ) {
    return history
        .map(
          (item) => PaymentDisputeOption(
            id: item.id,
            paymentSource: item.paymentSource,
            title: item.subject.isNotEmpty ? item.subject : 'Pagamento',
            subtitle:
                '${item.tutorName} • ${_formatAmount(item.amount, currency: currency)} • ${item.reference ?? item.id}',
          ),
        )
        .toList(growable: false);
  }

  Future<void> _showDisputeDialog(PaymentSummaryDto summary) async {
    if (summary.history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ainda não tens pagamentos para reclamar.'),
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

  String _paymentTitle(PaymentHistoryItemDto item) {
    final subject = item.subject.trim();
    if (subject.isNotEmpty) {
      return subject;
    }
    final reference = item.reference?.trim();
    if (reference != null && reference.isNotEmpty) {
      return reference;
    }
    return 'Pagamento';
  }

  String _paymentTypeLabel(PaymentHistoryItemDto item) {
    final source = item.paymentSource.trim().toLowerCase();
    final subject = item.subject.trim().toLowerCase();
    if (source.contains('reservation')) {
      if (subject.contains('tutoria') || subject.contains('psicologia')) {
        return 'Sessão';
      }
      return 'Aula';
    }
    if (source.contains('topup')) {
      return 'Top-up';
    }
    return 'Pagamento';
  }

  String _getProfessionalLabel(PaymentHistoryItemDto item) {
    final type = _roleTypeForItem(item);
    if (type == 'psicologo') {
      return 'Psicólogo:';
    }
    if (type == 'tutor') {
      return 'Tutor:';
    }
    return 'Explicador:';
  }

  Widget _buildMobileContent(PaymentSummaryDto summary) {
    final filteredHistory = _filteredHistory(summary.history);
    final totalPages = math.max(
      1,
      (filteredHistory.length / _mobileItemsPerPage).ceil(),
    );
    final currentPage = _mobileCurrentPage.clamp(1, totalPages);
    final start = (currentPage - 1) * _mobileItemsPerPage;
    final end = math.min(start + _mobileItemsPerPage, filteredHistory.length);
    final pageItems = start < end
        ? filteredHistory.sublist(start, end)
        : const <PaymentHistoryItemDto>[];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PagamentosConstants.mobileHorizontalPadding,
        vertical: PagamentosConstants.mobileVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PagamentosMobileIntro(
            title: 'Pagamentos',
            subtitle: 'Gerencie seus pagamentos e pacotes de apoios',
          ),
          const SizedBox(height: 18),
          _buildRoleFilterCards(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PagamentosMobileStatCard(
                  value: _formatAmount(
                    summary.totalSpent,
                    currency: summary.currency,
                  ),
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
              const SizedBox(width: 8),
              Expanded(
                child: PagamentosMobileStatCard(
                  value: _formatAmount(
                    summary.pendingAmount,
                    currency: summary.currency,
                  ),
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
              const SizedBox(width: 8),
              Expanded(
                child: PagamentosMobileStatCard(
                  value: filteredHistory.length.toString(),
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
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDisputeDialog(summary),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15C64),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.report_problem_rounded),
              label: const Text('Submeter reclamação sobre pagamentos'),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Arquivos Recentes',
            style: PagamentosConstants.mobileSectionTitleStyle,
          ),
          const SizedBox(height: 12),
          if (pageItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PagamentosConstants.mobileSurfaceColor,
                borderRadius: BorderRadius.circular(
                  PagamentosConstants.mobileCardRadius,
                ),
                border: Border.all(
                  color: PagamentosConstants.mobileBorderColor,
                ),
              ),
              child: const Text(
                'Ainda não existem pagamentos para mostrar.',
                style: PagamentosConstants.mobileBodyStyle,
              ),
            )
          else
            ...pageItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PagamentosMobilePaymentCard(
                  item: item,
                  title: _paymentTitle(item),
                  typeLabel: _paymentTypeLabel(item),
                  professionalLabel: _getProfessionalLabel(item),
                  formattedDate: _formatMobileDate(item.date),
                  formattedAmount: _formatAmount(
                    item.amount,
                    currency: summary.currency,
                  ),
                  onDetailsTap: () =>
                      _showPaymentDetails(item, summary.currency),
                  onReceiptTap: () => _openReceipt(item),
                ),
              ),
            ),
          const SizedBox(height: 8),
          PagamentosMobilePagination(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: (page) {
              setState(() {
                _mobileCurrentPage = page;
              });
            },
          ),
        ],
      ),
    );
  }

  String _formatMobileDate(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _normalizeRoleType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('psico') || normalized.contains('psycho')) {
      return 'psicologo';
    }
    if (normalized.contains('tutor')) return 'tutor';
    if (normalized.contains('explic') ||
        normalized.contains('teacher') ||
        normalized.contains('professor')) {
      return 'explicador';
    }
    return normalized;
  }

  String _roleTypeForItem(PaymentHistoryItemDto item) {
    final payloadRole = _normalizeRoleType(item.roleType);
    if (payloadRole.isNotEmpty) return payloadRole;

    final subject = item.subject.trim().toLowerCase();
    final paymentSource = item.paymentSource.trim().toLowerCase();

    if (subject.contains('psicolog') ||
        subject.contains('terapia') ||
        subject.contains('ansiedade') ||
        subject.contains('depress') ||
        subject.contains('orientação') ||
        paymentSource.contains('psycholog') ||
        paymentSource.contains('psicolog')) {
      return 'psicologo';
    }
    if (subject.contains('tutor') ||
        subject.contains('tutoria') ||
        subject.contains('mentoria') ||
        paymentSource.contains('tutor')) {
      return 'tutor';
    }
    return 'explicador';
  }

  bool _matchesRoleFilter(PaymentHistoryItemDto item) {
    final type = _roleTypeForItem(item);
    return switch (_selectedRoleFilter) {
      _StudentPaymentRoleFilter.todos => true,
      _StudentPaymentRoleFilter.explicador => type == 'explicador',
      _StudentPaymentRoleFilter.tutor => type == 'tutor',
      _StudentPaymentRoleFilter.psicologo => type == 'psicologo',
    };
  }

  List<PaymentHistoryItemDto> _filteredHistory(
    List<PaymentHistoryItemDto> all,
  ) {
    return all.where(_matchesRoleFilter).toList(growable: false);
  }

  void _onRoleFilterSelected(_StudentPaymentRoleFilter filter) {
    setState(() {
      _selectedRoleFilter = filter;
      _mobileCurrentPage = 1;
    });
  }

  Widget _buildRoleFilterCards() {
    final filters = <(_StudentPaymentRoleFilter, String)>[
      (_StudentPaymentRoleFilter.todos, 'Todos os Pagamentos'),
      (_StudentPaymentRoleFilter.explicador, 'Explicador'),
      (_StudentPaymentRoleFilter.tutor, 'Tutor'),
      (_StudentPaymentRoleFilter.psicologo, 'Psicólogo'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        if (!isCompact) {
          return Row(
            children: [
              for (int i = 0; i < filters.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _StudentPaymentRoleFilterCard(
                    label: filters[i].$2,
                    selected: _selectedRoleFilter == filters[i].$1,
                    onTap: () => _onRoleFilterSelected(filters[i].$1),
                  ),
                ),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final filter in filters)
              SizedBox(
                width: (constraints.maxWidth - 10) / 2,
                child: _StudentPaymentRoleFilterCard(
                  label: filter.$2,
                  selected: _selectedRoleFilter == filter.$1,
                  onTap: () => _onRoleFilterSelected(filter.$1),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? PagamentosConstants.mobileHorizontalPadding
            : PagamentosConstants.horizontalPadding,
        vertical: isMobile
            ? PagamentosConstants.mobileVerticalPadding
            : PagamentosConstants.verticalPadding,
      ),
      child: FutureBuilder<PaymentSummaryDto>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagamentos',
                  style: isMobile
                      ? PagamentosConstants.mobileTitleStyle
                      : PagamentosConstants.titleStyle,
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
          final filteredHistory = _filteredHistory(summary.history);

          if (isMobile) {
            return _buildMobileContent(summary);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AlunoMenuNav(),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pagamentos',
                      style: PagamentosConstants.titleStyle,
                    ),
                    const SizedBox(height: 10.955),
                    const Text(
                      'Gerencie seus pagamentos e pacotes de apoios',
                      style: PagamentosConstants.subtitleStyle,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleFilterCards(),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
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
                    ),
                    const SizedBox(height: 43.82),
                    Row(
                      children: [
                        Expanded(
                          child: PagamentosStatCard(
                            value: _formatAmount(
                              summary.availableCredits,
                              currency: summary.currency,
                            ),
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
                            value: _formatAmount(
                              summary.totalSpent,
                              currency: summary.currency,
                            ),
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
                            value: _formatAmount(
                              summary.pendingAmount,
                              currency: summary.currency,
                            ),
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
                            value: filteredHistory.length.toString(),
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
                    const Text(
                      'Histórico de Pagamentos',
                      style: PagamentosConstants.sectionTitleStyle,
                    ),
                    const SizedBox(height: 21.91),
                    PagamentosTableCard(
                      rows: filteredHistory,
                      currency: summary.currency,
                      onReceiptTap: _openReceipt,
                      onDetailsTap: (item) => _showPaymentDetails(item, summary.currency), // ADICIONA ESTA LINHA
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentPaymentRoleFilterCard extends StatelessWidget {
  const _StudentPaymentRoleFilterCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1E8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFFF6900) : const Color(0xFFE4E7EC),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFFB93815) : const Color(0xFF344054),
          ),
        ),
      ),
    );
  }
}
