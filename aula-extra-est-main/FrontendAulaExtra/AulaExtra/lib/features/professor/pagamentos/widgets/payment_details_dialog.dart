import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/payment_status.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_professor_formatters.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:flutter/material.dart';

class PaymentDetailsDialog extends StatelessWidget {
  const PaymentDetailsDialog({
    super.key,
    required this.details,
    required this.onClose,
    required this.onPrintReceipt,
    required this.config,
  });

  final ProfessorPaymentDetailsDto details;
  final VoidCallback onClose;
  final VoidCallback onPrintReceipt;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 768,
          maxHeight: media.height - 24,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                blurRadius: 50,
                offset: Offset(0, 25),
                spreadRadius: -12,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 23),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalhes do pagamento',
                            style: TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 32 / 24,
                              letterSpacing: 0.0703,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details.lessonTitle,
                            style: const TextStyle(
                              color: Color(0xFF6A7282),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 20 / 14,
                              letterSpacing: -0.1504,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.close_rounded,
                          color: Color(0xFF667085),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PaymentInfoRow(
                        left: _InfoTextBlock(
                          label: config.pagamentos.userHeader, 
                          value: details.studentName,
                        ),
                        right: _InfoTextBlock(
                          label: 'Email',
                          value: details.studentEmail ?? '—',
                        ),
                      ),
                      const SizedBox(height: 24),
                      _PaymentInfoRow(
                        left: _InfoTextBlock(
                          label: config.pagamentos.subjectHeader, 
                          value: details.subject,
                        ),
                        right: _InfoTextBlock(
                          label: 'Período', 
                          value:
                              '${formatProfessorPaymentDateTime(details.lessonStart)} → ${formatProfessorPaymentDateTime(details.lessonEnd)}',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(
                        height: 25,
                        thickness: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      _PaymentInfoRow(
                        left: _InfoTextBlock(
                          label: 'Data do pagamento',
                          value: formatProfessorPaymentDateTime(
                            details.paymentDate,
                          ),
                        ),
                        right: _InfoStatusBlock(status: details.status),
                      ),
                      const SizedBox(height: 24),
                      const Divider(
                        height: 25,
                        thickness: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      _FinancialCard(
                        grossAmount: formatProfessorPaymentAmount(
                          details.grossAmount,
                          currency: details.currency,
                        ),
                        platformFee: formatProfessorPaymentAmount(
                          details.platformFeeAmount,
                          currency: details.currency,
                        ),
                        netAmount: formatProfessorPaymentAmount(
                          details.netAmount,
                          currency: details.currency,
                        ),
                        commission: details.commissionPercent == null
                            ? '—'
                            : '${details.commissionPercent!.toStringAsFixed(details.commissionPercent!.truncateToDouble() == details.commissionPercent ? 0 : 2)}%',
                        fixedFee: details.fixedFee == null
                            ? '—'
                            : formatProfessorPaymentAmount(
                                details.fixedFee!,
                                currency: details.currency,
                              ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(
                        height: 25,
                        thickness: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      const Text(
                        'Informações Técnicas',
                        style: TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 27 / 18,
                          letterSpacing: -0.4395,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TechnicalField(
                        label: 'Referência',
                        value: details.reference ?? '—',
                        fullWidth: true,
                      ),
                      const SizedBox(height: 16),
                      _PaymentInfoRow(
                        gap: 16,
                        left: _TechnicalField(
                          label: 'Reserva',
                          value: details.reservationId,
                        ),
                        right: _TechnicalField(
                          label: 'Transação',
                          value: details.transactionId ?? '—',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 17, 24, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _DialogActionButton(
                      label: 'Fechar',
                      onTap: onClose,
                      outlined: true,
                      width: 103,
                    ),
                    const SizedBox(width: 12),
                    _DialogActionButton(
                      label: 'Imprimir Recibo',
                      onTap: onPrintReceipt,
                      width: 164.422,
                      enabled: details.receiptUrl?.trim().isNotEmpty ?? false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  const _PaymentInfoRow({
    required this.left,
    required this.right,
    this.gap = 24,
  });

  final Widget left;
  final Widget right;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: gap),
        Expanded(child: right),
      ],
    );
  }
}

class _InfoTextBlock extends StatelessWidget {
  const _InfoTextBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A7282),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            letterSpacing: -0.1504,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF101828),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            letterSpacing: -0.3125,
          ),
        ),
      ],
    );
  }
}

class _InfoStatusBlock extends StatelessWidget {
  const _InfoStatusBlock({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = normalizePaymentStatus(status);
    final background = normalized == 'refunded'
        ? const Color(0xFFFEE2E2)
        : normalized == 'paid'
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);
    final foreground = normalized == 'refunded'
        ? const Color(0xFFB42318)
        : normalized == 'paid'
        ? const Color(0xFF016630)
        : const Color(0xFF894B00);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado',
          style: TextStyle(
            color: Color(0xFF6A7282),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            letterSpacing: -0.1504,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999999),
          ),
          alignment: Alignment.center,
          child: Text(
            paymentStatusLabel(status),
            style: TextStyle(
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
              letterSpacing: -0.1504,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.commission,
    required this.fixedFee,
  });

  final String grossAmount;
  final String platformFee;
  final String netAmount;
  final String commission;
  final String fixedFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-0.92, -1),
          end: Alignment(1, 1),
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalhes Financeiros',
            style: TextStyle(
              color: Color(0xFF101828),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 27 / 18,
              letterSpacing: -0.4395,
            ),
          ),
          const SizedBox(height: 20),
          _PaymentInfoRow(
            gap: 16,
            left: _FinancialValueBlock(
              label: 'Valor bruto',
              value: grossAmount,
            ),
            right: _FinancialValueBlock(
              label: 'Taxa da plataforma',
              value: platformFee,
              accentColor: const Color(0xFFF54900),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFFFD6A8)),
          const SizedBox(height: 16),
          _FinancialValueBlock(
            label: 'Valor líquido',
            value: netAmount,
            large: true,
          ),
          const SizedBox(height: 24),
          _PaymentInfoRow(
            gap: 16,
            left: _InfoTextBlock(label: 'Comissão', value: commission),
            right: _InfoTextBlock(label: 'Taxa fixa', value: fixedFee),
          ),
        ],
      ),
    );
  }
}

class _FinancialValueBlock extends StatelessWidget {
  const _FinancialValueBlock({
    required this.label,
    required this.value,
    this.accentColor,
    this.large = false,
  });

  final String label;
  final String value;
  final Color? accentColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: accentColor ?? const Color(0xFF101828),
      fontSize: large ? 24 : 18,
      fontWeight: FontWeight.w700,
      height: large ? 32 / 24 : 28 / 18,
      letterSpacing: large ? 0.0703 : -0.4395,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A5565),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            letterSpacing: -0.1504,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: textStyle),
      ],
    );
  }
}

class _TechnicalField extends StatelessWidget {
  const _TechnicalField({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A7282),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            letterSpacing: -0.1504,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: fullWidth ? double.infinity : null,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF364153),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              fontFamily: 'Menlo',
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onTap,
    required this.width,
    this.outlined = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final double width;
  final bool outlined;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: width,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: const Color(0xFFD1D5DC), width: 2)
              : null,
          gradient: outlined || !enabled
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
                ),
          color: outlined
              ? Colors.white
              : enabled
              ? null
              : const Color(0xFFF2F4F7),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: outlined
                  ? const Color(0xFF364153)
                  : enabled
                  ? Colors.white
                  : const Color(0xFF98A2B3),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 24 / 16,
              letterSpacing: -0.3125,
            ),
          ),
        ),
      ),
    );

    return IgnorePointer(
      ignoring: !enabled,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }
}