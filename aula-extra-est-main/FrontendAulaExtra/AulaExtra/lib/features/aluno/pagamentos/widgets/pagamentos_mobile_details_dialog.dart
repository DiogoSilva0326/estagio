import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_constants.dart';
import 'package:flutter/material.dart';

class PagamentosMobileDetailsDialog extends StatelessWidget {
  const PagamentosMobileDetailsDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.studentName,
    required this.studentEmail,
    required this.subject,
    required this.lessonLabel,
    required this.paymentDateLabel,
    required this.statusLabel,
    required this.statusBackgroundColor,
    required this.statusTextColor,
    required this.grossAmountLabel,
    required this.platformFeeLabel,
    required this.netAmountLabel,
    required this.commissionLabel,
    required this.fixedFeeLabel,
    required this.referenceLabel,
    required this.reservationLabel,
    required this.transactionLabel,
    required this.onClose,
    this.onReceiptTap,
  });

  final String title;
  final String subtitle;
  final String studentName;
  final String studentEmail;
  final String subject;
  final String lessonLabel;
  final String paymentDateLabel;
  final String statusLabel;
  final Color statusBackgroundColor;
  final Color statusTextColor;
  final String grossAmountLabel;
  final String platformFeeLabel;
  final String netAmountLabel;
  final String commissionLabel;
  final String fixedFeeLabel;
  final String referenceLabel;
  final String reservationLabel;
  final String transactionLabel;
  final VoidCallback onClose;
  final VoidCallback? onReceiptTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 341),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.22),
              offset: Offset(0, 24),
              blurRadius: 48,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                            height: 24 / 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: PagamentosConstants.mobileBodyStyle,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _FieldBlock(label: 'Aluno', value: studentName),
                    const SizedBox(height: 16),
                    _FieldBlock(label: 'Email', value: studentEmail),
                    const SizedBox(height: 20),
                    _FieldBlock(label: 'Disciplina', value: subject),
                    const SizedBox(height: 16),
                    _FieldBlock(label: 'Tipo', value: lessonLabel),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _FieldBlock(
                      label: 'Data do pagamento',
                      value: paymentDateLabel,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado',
                          style: PagamentosConstants.mobileMetaLabelStyle,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackgroundColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel,
                            style: PagamentosConstants.mobileStatusStyle
                                .copyWith(color: statusTextColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                    _SoftSectionCard(
                      title: 'Detalhes Financeiros',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldBlock(
                            label: 'Valor bruto',
                            value: grossAmountLabel,
                          ),
                          const SizedBox(height: 14),
                          _FieldBlock(
                            label: 'Taxa da plataforma',
                            value: platformFeeLabel,
                            valueColor: const Color(0xFFFF6900),
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          _FieldBlock(
                            label: 'Valor líquido',
                            value: netAmountLabel,
                            valueStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF6900),
                              height: 24 / 18,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FieldBlock(
                            label: 'Comissão',
                            value: commissionLabel,
                          ),
                          const SizedBox(height: 14),
                          _FieldBlock(label: 'Taxa fixa', value: fixedFeeLabel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Informações Técnicas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101828),
                        height: 24 / 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TechnicalField(label: 'Referência', value: referenceLabel),
                    const SizedBox(height: 14),
                    _TechnicalField(label: 'Reserva', value: reservationLabel),
                    const SizedBox(height: 14),
                    _TechnicalField(
                      label: 'Transação',
                      value: transactionLabel,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: PagamentosConstants.mobileBorderColor,
                        ),
                      ),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(
                          color: PagamentosConstants.mobileTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: PagamentosConstants.orangeGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onReceiptTap,
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            height: 48,
                            child: Center(
                              child: Text(
                                'Imprimir Recibo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PagamentosConstants.mobileMetaLabelStyle),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              valueStyle ??
              PagamentosConstants.mobileMetaValueStyle.copyWith(
                color: valueColor,
              ),
        ),
      ],
    );
  }
}

class _SoftSectionCard extends StatelessWidget {
  const _SoftSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
              height: 24 / 18,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TechnicalField extends StatelessWidget {
  const _TechnicalField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PagamentosConstants.mobileMetaLabelStyle),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF344054),
              height: 18 / 13,
            ),
          ),
        ),
      ],
    );
  }
}
