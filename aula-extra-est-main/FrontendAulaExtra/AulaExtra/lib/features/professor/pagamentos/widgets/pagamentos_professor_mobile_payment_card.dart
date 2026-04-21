import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/payment_status.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:flutter/material.dart';

class PagamentosProfessorMobilePaymentCard extends StatelessWidget {
  const PagamentosProfessorMobilePaymentCard({
    super.key,
    required this.payment,
    required this.title,
    required this.formattedDate,
    required this.formattedAmount,
    required this.onDetailsTap,
  });

  final ProfessorPaymentHistoryItemDto payment;
  final String title;
  final String formattedDate;
  final String formattedAmount;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = normalizePaymentStatus(payment.status);
    final statusLabel = paymentStatusLabel(payment.status);
    final statusBackground = normalizedStatus == 'paid'
        ? const Color(0xFFDCFCE7)
        : normalizedStatus == 'refunded'
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFFEDD4);
    final statusColor = normalizedStatus == 'paid'
        ? const Color(0xFF008236)
        : normalizedStatus == 'refunded'
        ? const Color(0xFFB42318)
        : const Color(0xFFCA3500);

    return Container(
      padding: const EdgeInsets.all(
        PagamentosProfessorLayout.mobileListCardPadding,
      ),
      decoration: BoxDecoration(
        color: PagamentosProfessorColors.mobileSurface,
        borderRadius: BorderRadius.circular(
          PagamentosProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(color: PagamentosProfessorColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 24, 40, 0.08),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: PagamentosProfessorColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PagamentosProfessorColors.title,
                        height: 24 / 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: PagamentosProfessorColors.muted,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: PagamentosProfessorColors.valueGreenText,
                  height: 22 / 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetaItem(label: 'Aluno', value: payment.studentName),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaItem(label: 'Data', value: formattedDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetaItem(
                  label: 'Referência',
                  value: payment.reference ?? payment.id,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: PagamentosProfessorColors.muted,
                        height: 18 / 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 18 / 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: onDetailsTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                side: const BorderSide(
                  color: PagamentosProfessorColors.cardBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ver detalhes',
                style: TextStyle(
                  color: PagamentosProfessorColors.title,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});

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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: PagamentosProfessorColors.muted,
            height: 18 / 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PagamentosProfessorColors.title,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
