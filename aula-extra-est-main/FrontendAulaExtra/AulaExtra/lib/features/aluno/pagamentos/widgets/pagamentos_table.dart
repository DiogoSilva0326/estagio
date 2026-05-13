import 'package:aula_extra/core/data/payments/payment_status.dart';
import 'package:aula_extra/core/data/payments/dtos/payment_summary_dto.dart';
import 'package:flutter/material.dart';

class PagamentosTableCard extends StatelessWidget {
  const PagamentosTableCard({
    super.key,
    required this.rows,
    required this.currency,
    required this.onReceiptTap,
  });

  final List<PaymentHistoryItemDto> rows;
  final String currency;
  final Future<void> Function(PaymentHistoryItemDto row) onReceiptTap;

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _formatAmount(double value) {
    final symbol = currency.toUpperCase() == 'EUR' ? '€' : currency;
    final fixed = value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)
        .replaceAll('.', ',');
    return symbol == '€' ? '$fixed$symbol' : '$fixed $symbol';
  }

  String _getGroupKey(String subject) {
    final s = subject.trim().toLowerCase();
    if (s.contains('psicolog') || s.contains('terapia') || s.contains('ansiedade') || s.contains('orientação')) {
      return 'psicologia';
    }
    if (s.contains('tutor') || s.contains('mentoria')) {
      return 'tutoria';
    }
    return 'ensino';
  }

  Map<String, String> _getGroupMetadata(String key) {
    switch (key) {
      case 'psicologia':
        return {
          'title': 'Sessões de Psicologia & Bem-estar',
          'col1': 'PSICÓLOGO',
          'col2': 'ÁREA / SESSÃO',
        };
      case 'tutoria':
        return {
          'title': 'Sessões de Tutoria & Mentoria',
          'col1': 'TUTOR',
          'col2': 'ÁREA',
        };
      case 'ensino':
      default:
        return {
          'title': 'Aulas de Explicação',
          'col1': 'EXPLICADOR',
          'col2': 'DISCIPLINA',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = <String, List<PaymentHistoryItemDto>>{};
    for (final row in rows) {
      final key = _getGroupKey(row.subject);
      grouped.putIfAbsent(key, () => []).add(row);
    }

    final groupWidgets = <Widget>[];
    final keysOrder = ['ensino', 'tutoria', 'psicologia']; 

    for (final key in keysOrder) {
      if (grouped.containsKey(key)) {
        groupWidgets.add(_buildTableGroup(context, key, grouped[key]!));
        groupWidgets.add(const SizedBox(height: 32));
      }
    }

    for (final key in grouped.keys) {
      if (!keysOrder.contains(key)) {
        groupWidgets.add(_buildTableGroup(context, key, grouped[key]!));
        groupWidgets.add(const SizedBox(height: 32));
      }
    }

    if (groupWidgets.isNotEmpty) {
      groupWidgets.removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupWidgets,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.369),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.91),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.369),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 1.369),
            blurRadius: 4.108,
          ),
        ],
      ),
      child: const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Ainda não existem pagamentos para mostrar.',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A5565),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableGroup(BuildContext context, String key, List<PaymentHistoryItemDto> groupRows) {
    final meta = _getGroupMetadata(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            meta['title']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(1.369),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21.91),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1.369),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                offset: Offset(0, 1.369),
                blurRadius: 4.108,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                offset: Offset(0, 1.369),
                blurRadius: 2.739,
                spreadRadius: -1.369,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.541),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 972.261,
                child: Column(
                  children: [
                    _TableHeaderRow(
                      col1Label: meta['col1']!,
                      col2Label: meta['col2']!,
                    ),
                    for (int i = 0; i < groupRows.length; i++)
                      _PagamentoRow(
                        tutor: groupRows[i].tutorName,
                        disciplina: groupRows[i].subject,
                        data: _formatDate(groupRows[i].date),
                        valor: _formatAmount(groupRows[i].amount),
                        status: paymentStatusLabel(groupRows[i].status),
                        statusKind: normalizePaymentStatus(groupRows[i].status),
                        hasReceipt: (groupRows[i].receiptUrl?.trim().isNotEmpty ?? false),
                        hasBottomBorder: i != groupRows.length - 1,
                        onReceiptTap: () => onReceiptTap(groupRows[i]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({
    required this.col1Label,
    required this.col2Label,
  });

  final String col1Label;
  final String col2Label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.46,
      color: const Color(0xFFF9FAFB),
      child: Row(
        children: [
          _HeaderCell(width: 186.172, text: col1Label),
          _HeaderCell(width: 167.974, text: col2Label),
          const _HeaderCell(width: 138.832, text: 'DATA'),
          const _HeaderCell(width: 121.008, text: 'VALOR'),
          const _HeaderCell(width: 168.423, text: 'STATUS'),
          const _HeaderCell(width: 189.852, text: 'AÇÕES'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.width, required this.text});

  final double width;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.87),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.433,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5565),
              letterSpacing: 0.8216,
            ),
          ),
        ),
      ),
    );
  }
}

class _PagamentoRow extends StatelessWidget {
  const _PagamentoRow({
    required this.tutor,
    required this.disciplina,
    required this.data,
    required this.valor,
    required this.status,
    required this.statusKind,
    required this.hasReceipt,
    required this.hasBottomBorder,
    required this.onReceiptTap,
  });

  final String tutor;
  final String disciplina;
  final String data;
  final String valor;
  final String status;
  final String statusKind;
  final bool hasReceipt;
  final bool hasBottomBorder;
  final VoidCallback onReceiptTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        border: Border(
          bottom: hasBottomBorder
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 1.369)
              : BorderSide.none,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TutorCell(text: tutor),
          _BodyCell(width: 167.974, text: disciplina, topPadding: 39),
          _BodyCell(width: 138.832, text: data, topPadding: 26),
          _ValueCell(text: valor),
          _StatusCell(text: status, statusKind: statusKind),
          _ActionsCell(hasReceipt: hasReceipt, onTap: onReceiptTap),
        ],
      ),
    );
  }
}

class _TutorCell extends StatelessWidget {
  const _TutorCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 186.172,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.87),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21.91,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101828),
              height: 32.865 / 21.91,
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({
    required this.width,
    required this.text,
    required this.topPadding,
  });

  final double width;
  final String text;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.only(left: 32.87, top: topPadding),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 19.171,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4A5565),
            height: 27.388 / 19.171,
          ),
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 121.008,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.87),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 21.91,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101828),
              height: 32.865 / 21.91,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({required this.text, required this.statusKind});

  final String text;
  final String statusKind;

  @override
  Widget build(BuildContext context) {
    final bg = statusKind == 'refunded'
        ? const Color(0xFFFEE2E2)
        : statusKind == 'paid'
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFFEDD4);
    final fg = statusKind == 'refunded'
        ? const Color(0xFFB42318)
        : statusKind == 'paid'
        ? const Color(0xFF008236)
        : const Color(0xFFCA3500);

    return SizedBox(
      width: 168.423,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.87),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.433,
              vertical: 5.478,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(9999999),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.433,
                fontWeight: FontWeight.w500,
                color: fg,
                height: 21.91 / 16.433,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  const _ActionsCell({required this.hasReceipt, required this.onTap});

  final bool hasReceipt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 189.852,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.87),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _ReceiptButton(
            icon: Icons.receipt_long_rounded,
            enabled: hasReceipt,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _ReceiptButton extends StatelessWidget {
  const _ReceiptButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 38.343,
        width: 124.111,
        child: Row(
          children: [
            const SizedBox(width: 16.433),
            Icon(
              icon,
              size: 21.91,
              color: enabled
                  ? const Color(0xFF364153)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 10),
            Text(
              'Recibo',
              style: TextStyle(
                fontSize: 19.171,
                fontWeight: FontWeight.w400,
                color: enabled
                    ? const Color(0xFF364153)
                    : const Color(0xFF9CA3AF),
                height: 27.388 / 19.171,
              ),
            ),
          ],
        ),
      ),
    );
  }
}