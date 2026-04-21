import 'package:aula_extra/core/data/payments/payment_status.dart';
import 'package:aula_extra/core/data/payments/dtos/payment_summary_dto.dart';
import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_constants.dart';
import 'package:flutter/material.dart';

class PagamentosMobilePaymentCard extends StatelessWidget {
  const PagamentosMobilePaymentCard({
    super.key,
    required this.item,
    required this.title,
    required this.typeLabel,
    required this.formattedDate,
    required this.formattedAmount,
    required this.onDetailsTap,
    required this.onReceiptTap,
  });

  final PaymentHistoryItemDto item;
  final String title;
  final String typeLabel;
  final String formattedDate;
  final String formattedAmount;
  final VoidCallback onDetailsTap;
  final VoidCallback onReceiptTap;

  @override
  Widget build(BuildContext context) {
    final statusKind = normalizePaymentStatus(item.status);
    final statusLabel = paymentStatusLabel(item.status);
    final statusBackground = statusKind == 'paid'
        ? const Color(0xFFDCFCE7)
        : statusKind == 'refunded'
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFFEDD4);
    final statusColor = statusKind == 'paid'
        ? const Color(0xFF008236)
        : statusKind == 'refunded'
        ? const Color(0xFFB42318)
        : const Color(0xFFCA3500);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          PagamentosConstants.mobileCardRadius,
        ),
        border: Border.all(color: PagamentosConstants.mobileBorderColor),
        boxShadow: PagamentosConstants.mobileShadow,
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
                  color: PagamentosConstants.mobileMutedColor,
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
                      style: PagamentosConstants.mobileCardTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(typeLabel, style: PagamentosConstants.mobileBodyStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetaItem(label: 'Tutor:', value: item.tutorName),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetaItem(label: 'Data:', value: formattedDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetaItem(label: 'Valor:', value: formattedAmount),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: PagamentosConstants.mobileMetaLabelStyle,
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
                        style: PagamentosConstants.mobileStatusStyle.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onDetailsTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: const BorderSide(
                        color: PagamentosConstants.mobileBorderColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ver detalhes',
                      style: TextStyle(
                        color: PagamentosConstants.mobileTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: PagamentosConstants.orangeGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onReceiptTap,
                        borderRadius: BorderRadius.circular(10),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Recibo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
        Text(label, style: PagamentosConstants.mobileMetaLabelStyle),
        const SizedBox(height: 4),
        Text(value, style: PagamentosConstants.mobileMetaValueStyle),
      ],
    );
  }
}
