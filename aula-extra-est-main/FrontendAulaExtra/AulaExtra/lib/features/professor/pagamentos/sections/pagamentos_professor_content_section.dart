import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/full_bleed_scaled_section.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

  String _formatAmount(double value, {String currency = 'EUR'}) {
    final symbol = currency.toUpperCase() == 'EUR' ? '€' : currency;
    final fixed = value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)
        .replaceAll('.', ',');
    return symbol == '€' ? '$fixed$symbol' : '$fixed $symbol';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '—';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year · $hour:$minute';
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
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Detalhes do pagamento',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.lessonTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _DetailItem(label: 'Aluno', value: details.studentName),
                      _DetailItem(
                        label: 'Email',
                        value: details.studentEmail ?? '—',
                      ),
                      _DetailItem(label: 'Disciplina', value: details.subject),
                      _DetailItem(
                        label: 'Aula',
                        value:
                            '${_formatDateTime(details.lessonStart)} → ${_formatDateTime(details.lessonEnd)}',
                      ),
                      _DetailItem(
                        label: 'Data do pagamento',
                        value: _formatDateTime(details.paymentDate),
                      ),
                      _DetailItem(label: 'Estado', value: details.status),
                      _DetailItem(
                        label: 'Valor bruto',
                        value: _formatAmount(
                          details.grossAmount,
                          currency: details.currency,
                        ),
                      ),
                      _DetailItem(
                        label: 'Taxa da plataforma',
                        value: _formatAmount(
                          details.platformFeeAmount,
                          currency: details.currency,
                        ),
                      ),
                      _DetailItem(
                        label: 'Valor líquido',
                        value: _formatAmount(
                          details.netAmount,
                          currency: details.currency,
                        ),
                      ),
                      _DetailItem(
                        label: 'Referência',
                        value: details.reference ?? '—',
                      ),
                      _DetailItem(
                        label: 'Reserva',
                        value: details.reservationId,
                      ),
                      _DetailItem(
                        label: 'Transação',
                        value: details.transactionId ?? '—',
                      ),
                      _DetailItem(
                        label: 'Comissão',
                        value: details.commissionPercent == null
                            ? '—'
                            : '${details.commissionPercent!.toStringAsFixed(details.commissionPercent!.truncateToDouble() == details.commissionPercent ? 0 : 2)}%',
                      ),
                      _DetailItem(
                        label: 'Taxa fixa',
                        value: details.fixedFee == null
                            ? '—'
                            : _formatAmount(
                                details.fixedFee!,
                                currency: details.currency,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _showWithdrawalDialog() async {
    final ibanController = TextEditingController();
    final accountHolderController = TextEditingController();
    final bankNameController = TextEditingController();
    final amountController = TextEditingController();
    final observationsController = TextEditingController();
    PlatformFile? ibanProofFile;
    PlatformFile? paymentReceiptFile;

    try {
      final submitted = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          String? localError;

          Future<void> pickFile(
            bool isIbanProof,
            StateSetter setDialogState,
          ) async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: const <String>['pdf', 'png', 'jpg', 'jpeg'],
              withData: true,
              allowMultiple: false,
            );

            final selectedFile = result?.files.single;
            if (selectedFile == null) return;

            setDialogState(() {
              if (isIbanProof) {
                ibanProofFile = selectedFile;
              } else {
                paymentReceiptFile = selectedFile;
              }
              localError = null;
            });
          }

          return StatefulBuilder(
            builder: (context, setDialogState) {
              void submit() {
                final iban = ibanController.text.trim();
                final accountHolder = accountHolderController.text.trim();
                final amount = amountController.text.trim();

                if (iban.isEmpty ||
                    accountHolder.isEmpty ||
                    amount.isEmpty ||
                    ibanProofFile == null ||
                    paymentReceiptFile == null) {
                  setDialogState(() {
                    localError =
                        'Preencha os campos obrigatórios e anexe os dois ficheiros.';
                  });
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              }

              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Solicitar Saque',
                                  style: TextStyle(
                                    color: Color(0xFF101828),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.of(dialogContext).pop(),
                                borderRadius: BorderRadius.circular(999),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF667085),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _WithdrawalField(
                            label: 'IBAN *',
                            child: TextField(
                              controller: ibanController,
                              decoration: _withdrawalInputDecoration(
                                hintText: 'PT50 0000 0000 0000 0000 0000 0',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _WithdrawalField(
                            label: 'Titular da Conta *',
                            child: TextField(
                              controller: accountHolderController,
                              decoration: _withdrawalInputDecoration(
                                hintText: 'Nome completo',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _WithdrawalField(
                            label: 'Nome do Banco',
                            child: TextField(
                              controller: bankNameController,
                              decoration: _withdrawalInputDecoration(
                                hintText: 'Ex: Banco CTT, Millennium BCP',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _WithdrawalField(
                            label: 'Valor do Saque *',
                            child: TextField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _withdrawalInputDecoration(
                                hintText: '0.00',
                                suffixText: '€',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _UploadPickerCard(
                            label: 'Comprovante IBAN *',
                            selectedFileName: ibanProofFile?.name,
                            onPickFile: () => pickFile(true, setDialogState),
                          ),
                          const SizedBox(height: 20),
                          _UploadPickerCard(
                            label: 'Comprovante de Pagamento *',
                            selectedFileName: paymentReceiptFile?.name,
                            onPickFile: () => pickFile(false, setDialogState),
                          ),
                          const SizedBox(height: 20),
                          _WithdrawalField(
                            label: 'Observações',
                            child: TextField(
                              controller: observationsController,
                              minLines: 4,
                              maxLines: 6,
                              decoration: _withdrawalInputDecoration(
                                hintText: 'Informações adicionais (opcional)',
                              ),
                            ),
                          ),
                          if (localError != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              localError!,
                              style: const TextStyle(
                                color: Color(0xFFB42318),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    side: const BorderSide(
                                      color: Color(0xFFD0D5DD),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: Color(0xFF344054),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        PagamentosProfessorColors
                                            .withdrawGradientTop,
                                        PagamentosProfessorColors
                                            .withdrawGradientBottom,
                                      ],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: submit,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Solicitar Saque',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      if (submitted == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido de saque preenchido com sucesso.'),
          ),
        );
      }
    } finally {
      ibanController.dispose();
      accountHolderController.dispose();
      bankNameController.dispose();
      amountController.dispose();
      observationsController.dispose();
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
                                _SummaryCard(
                                  title: 'Total Recebido',
                                  value: _formatAmount(
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
                                _SummaryCard(
                                  title: 'Ganhos Pendentes',
                                  value: _formatAmount(
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
                                _SummaryCard(
                                  title: 'Total Este Mês',
                                  value: _formatAmount(
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: _WithdrawButton(
                              onTap: _showWithdrawalDialog,
                            ),
                          ),
                          const SizedBox(height: 19.171),
                          _TableCard(
                            rows: summary.history,
                            formatAmount: _formatAmount,
                            formatDateTime: _formatDateTime,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PagamentosProfessorLayout.summaryCardWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.summaryCardRadius,
          ),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 17.973,
              offset: const Offset(0, 11.982),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 7.189,
              offset: const Offset(0, 4.793),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PagamentosProfessorLayout.summaryCardPadding,
            PagamentosProfessorLayout.summaryCardPadding,
            PagamentosProfessorLayout.summaryCardPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: PagamentosProfessorLayout.summaryIconSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize:
                              PagamentosProfessorLayout.summaryLabelFontSize,
                          fontWeight: FontWeight.w500,
                          height:
                              PagamentosProfessorLayout.summaryLabelLineHeight /
                              PagamentosProfessorLayout.summaryLabelFontSize,
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      color: Colors.white,
                      size: PagamentosProfessorLayout.summaryIconSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9.586),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: PagamentosProfessorLayout.summaryValueFontSize,
                  fontWeight: FontWeight.w700,
                  height:
                      PagamentosProfessorLayout.summaryValueLineHeight /
                      PagamentosProfessorLayout.summaryValueFontSize,
                ),
              ),
              const SizedBox(height: 9.586),
              Opacity(
                opacity: 0.8,
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: PagamentosProfessorLayout.summarySubLabelFontSize,
                    fontWeight: FontWeight.w400,
                    height:
                        PagamentosProfessorLayout.summarySubLabelLineHeight /
                        PagamentosProfessorLayout.summarySubLabelFontSize,
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

InputDecoration _withdrawalInputDecoration({
  required String hintText,
  String? suffixText,
}) {
  const borderColor = Color(0xFFD0D5DD);

  OutlineInputBorder buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF98A2B3),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    suffixText: suffixText,
    suffixStyle: const TextStyle(
      color: Color(0xFF344054),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: buildBorder(borderColor),
    enabledBorder: buildBorder(borderColor),
    focusedBorder: buildBorder(PagamentosProfessorColors.withdrawGradientTop),
  );
}

class _WithdrawalField extends StatelessWidget {
  const _WithdrawalField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _UploadPickerCard extends StatelessWidget {
  const _UploadPickerCard({
    required this.label,
    required this.onPickFile,
    this.selectedFileName,
  });

  final String label;
  final String? selectedFileName;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD0D5DD)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF667085),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Arraste e solte o arquivo aqui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Formatos aceites: PDF, JPG, PNG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ou',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onPickFile,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(180, 44),
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Escolher Arquivo',
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selectedFileName != null) ...[
                const SizedBox(height: 14),
                Text(
                  selectedFileName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF027A48),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PagamentosProfessorLayout.withdrawButtonWidth,
      height: PagamentosProfessorLayout.withdrawButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.withdrawButtonRadius,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PagamentosProfessorColors.withdrawGradientTop,
              PagamentosProfessorColors.withdrawGradientBottom,
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.withdrawButtonRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 14.38, right: 14.38),
            child: Row(
              children: const [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: PagamentosProfessorLayout.withdrawIconSize,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Solicitar Saque',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: PagamentosProfessorLayout.tableTextFontSize,
                      fontWeight: FontWeight.w500,
                      height:
                          PagamentosProfessorLayout.tableTextLineHeight /
                          PagamentosProfessorLayout.tableTextFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.rows,
    required this.formatAmount,
    required this.formatDateTime,
    required this.onDetailsTap,
  });

  final List<ProfessorPaymentHistoryItemDto> rows;
  final String Function(double value, {String currency}) formatAmount;
  final String Function(DateTime? value) formatDateTime;
  final Future<void> Function(ProfessorPaymentHistoryItemDto row) onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 401.993,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          PagamentosProfessorLayout.tableRadius,
        ),
        border: Border.all(
          color: PagamentosProfessorColors.cardBorder,
          width: PagamentosProfessorLayout.tableBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: PagamentosProfessorLayout.tableShadowBlur1,
            offset: const Offset(0, 4.793),
            spreadRadius: -1.198,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: PagamentosProfessorLayout.tableShadowBlur2,
            offset: const Offset(0, 2.396),
            spreadRadius: -2.396,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          PagamentosProfessorLayout.tableRadius,
        ),
        child: Column(
          children: [
            const _TableHeader(),
            Expanded(
              child: rows.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Ainda não existem pagamentos para mostrar.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 1.198,
                          thickness: 1.198,
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                        );
                      },
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return _TableRow(
                          row: row,
                          formatAmount: formatAmount,
                          formatDateTime: formatDateTime,
                          onDetailsTap: () => onDetailsTap(row),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      color: PagamentosProfessorColors.text,
      fontSize: PagamentosProfessorLayout.tableTextFontSize,
      fontWeight: FontWeight.w500,
      height:
          PagamentosProfessorLayout.tableTextLineHeight /
          PagamentosProfessorLayout.tableTextFontSize,
    );

    return Container(
      height: PagamentosProfessorLayout.tableHeaderHeight,
      decoration: const BoxDecoration(
        color: PagamentosProfessorColors.tableHeaderBackground,
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1), width: 1.198),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.59),
        child: Row(
          children: const [
            SizedBox(
              width: 235.379 - 9.59,
              child: Text('Aluno', style: headerStyle),
            ),
            SizedBox(
              width: 208.251,
              child: Text('Data da Aula', style: headerStyle),
            ),
            SizedBox(width: 106.929, child: Text('Valor', style: headerStyle)),
            SizedBox(width: 180.889, child: Text('Status', style: headerStyle)),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ações',
                  style: headerStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.row,
    required this.formatAmount,
    required this.formatDateTime,
    required this.onDetailsTap,
  });

  final ProfessorPaymentHistoryItemDto row;
  final String Function(double value, {String currency}) formatAmount;
  final String Function(DateTime? value) formatDateTime;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final amountStyle = TextStyle(
      color: PagamentosProfessorColors.valueGreenText,
      fontSize: PagamentosProfessorLayout.tableTextFontSize,
      fontWeight: FontWeight.w500,
      height:
          PagamentosProfessorLayout.tableTextLineHeight /
          PagamentosProfessorLayout.tableTextFontSize,
    );

    const cellTextStyle = TextStyle(
      color: PagamentosProfessorColors.text,
      fontSize: PagamentosProfessorLayout.tableTextFontSize,
      fontWeight: FontWeight.w400,
      height:
          PagamentosProfessorLayout.tableTextLineHeight /
          PagamentosProfessorLayout.tableTextFontSize,
    );

    return SizedBox(
      height: PagamentosProfessorLayout.tableRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.59),
        child: Row(
          children: [
            SizedBox(
              width: 235.379 - 9.59,
              child: Text(
                row.studentName,
                style: cellTextStyle.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 208.251,
              child: Text(
                formatDateTime(row.lessonStart),
                style: cellTextStyle,
              ),
            ),
            SizedBox(
              width: 106.929,
              child: Text(
                formatAmount(row.netAmount, currency: row.currency),
                style: amountStyle,
              ),
            ),
            SizedBox(width: 180.889, child: _StatusBadge(status: row.status)),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _DetailsButton(onTap: onDetailsTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  bool get _isPaid {
    final normalized = status.trim().toLowerCase();
    return normalized.contains('paid') ||
        normalized.contains('pago') ||
        normalized.contains('success') ||
        normalized.contains('completed') ||
        normalized.contains('conclu');
  }

  @override
  Widget build(BuildContext context) {
    final background = _isPaid
        ? PagamentosProfessorColors.badgePaidBackground
        : PagamentosProfessorColors.badgePendingBackground;

    final textColor = _isPaid
        ? Colors.white
        : PagamentosProfessorColors.badgePendingText;

    final label = _isPaid ? 'Pago' : 'Pendente';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: PagamentosProfessorLayout.badgeHeight,
        padding: const EdgeInsets.symmetric(horizontal: 9.59),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.badgeRadius,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: PagamentosProfessorLayout.badgeFontSize,
              fontWeight: FontWeight.w500,
              height:
                  PagamentosProfessorLayout.badgeLineHeight /
                  PagamentosProfessorLayout.badgeFontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PagamentosProfessorLayout.actionButtonHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          PagamentosProfessorLayout.actionButtonRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              'Mostrar detalhes',
              style: const TextStyle(
                color: PagamentosProfessorColors.text,
                fontSize: PagamentosProfessorLayout.tableTextFontSize,
                fontWeight: FontWeight.w500,
                height:
                    PagamentosProfessorLayout.tableTextLineHeight /
                    PagamentosProfessorLayout.tableTextFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF101828),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
