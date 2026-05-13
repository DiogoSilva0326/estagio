import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/payment_status.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/pagamentos_professor_formatters.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:flutter/material.dart';

class PagamentosTableCard extends StatelessWidget {
  const PagamentosTableCard({
    super.key,
    required this.rows,
    required this.onDetailsTap,
    required this.config, 
  });

  final List<ProfessorPaymentHistoryItemDto> rows;
  final Future<void> Function(ProfessorPaymentHistoryItemDto row) onDetailsTap;
  final TeachingRoleConfig config;

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
            _TableHeader(config: config), 
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
  const _TableHeader({required this.config});

  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      color: PagamentosProfessorColors.text,
      fontSize: PagamentosProfessorLayout.tableTextFontSize,
      fontWeight: FontWeight.w500,
      height: PagamentosProfessorLayout.tableTextLineHeight /
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
          children: [
            SizedBox(
              width: 235.379 - 9.59,
              child: Text(config.pagamentos.userHeader, style: headerStyle),
            ),
            SizedBox(
              width: 208.251,
              child: Text(config.pagamentos.dateHeader, style: headerStyle),
            ),
            const SizedBox(width: 106.929, child: Text('Valor', style: headerStyle)),
            const SizedBox(width: 180.889, child: Text('Status', style: headerStyle)),
            const Expanded(
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
  const _TableRow({required this.row, required this.onDetailsTap});

  final ProfessorPaymentHistoryItemDto row;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final amountStyle = TextStyle(
      color: PagamentosProfessorColors.valueGreenText,
      fontSize: PagamentosProfessorLayout.tableTextFontSize,
      fontWeight: FontWeight.w500,
      height: PagamentosProfessorLayout.tableTextLineHeight /
          PagamentosProfessorLayout.tableTextFontSize,
    );

    const cellTextStyle = TextStyle(
      color: PagamentosProfessorColors.text,
      fontSize: PagamentosProfessorLayout.tableTextFontSize,
      fontWeight: FontWeight.w400,
      height: PagamentosProfessorLayout.tableTextLineHeight /
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
                formatProfessorPaymentDateTime(row.lessonStart),
                style: cellTextStyle,
              ),
            ),
            SizedBox(
              width: 106.929,
              child: Text(
                formatProfessorPaymentAmount(
                  row.netAmount,
                  currency: row.currency,
                ),
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

  @override
  Widget build(BuildContext context) {
    final normalized = normalizePaymentStatus(status);
    final background = normalized == 'refunded'
        ? PagamentosProfessorColors.badgeRefundedBackground
        : normalized == 'paid'
        ? PagamentosProfessorColors.badgePaidBackground
        : PagamentosProfessorColors.badgePendingBackground;

    final textColor = normalized == 'refunded'
        ? PagamentosProfessorColors.badgeRefundedText
        : normalized == 'paid'
        ? Colors.white
        : PagamentosProfessorColors.badgePendingText;

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
            paymentStatusLabel(status),
            style: TextStyle(
              color: textColor,
              fontSize: PagamentosProfessorLayout.badgeFontSize,
              fontWeight: FontWeight.w500,
              height: PagamentosProfessorLayout.badgeLineHeight /
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
                height: PagamentosProfessorLayout.tableTextLineHeight /
                    PagamentosProfessorLayout.tableTextFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}