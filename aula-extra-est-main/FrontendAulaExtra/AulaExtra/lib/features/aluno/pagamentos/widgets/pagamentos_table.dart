import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_mock_data.dart';
import 'package:flutter/material.dart';

class PagamentosTableCard extends StatelessWidget {
  const PagamentosTableCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                const _TableHeaderRow(),
                for (int i = 0; i < PagamentosMockData.rows.length; i++)
                  _PagamentoRow(
                    data: PagamentosMockData.rows[i],
                    hasBottomBorder: i != PagamentosMockData.rows.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.46,
      color: const Color(0xFFF9FAFB),
      child: const Row(
        children: [
          _HeaderCell(width: 186.172, text: 'TUTOR'),
          _HeaderCell(width: 167.974, text: 'DISCIPLINA'),
          _HeaderCell(width: 138.832, text: 'DATA'),
          _HeaderCell(width: 121.008, text: 'VALOR'),
          _HeaderCell(width: 168.423, text: 'STATUS'),
          _HeaderCell(width: 189.852, text: 'AÇÕES'),
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
  const _PagamentoRow({required this.data, required this.hasBottomBorder});

  final PagamentoRowData data;
  final bool hasBottomBorder;

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
          _TutorCell(text: data.tutor),
          _BodyCell(width: 167.974, text: data.disciplina, topPadding: 39),
          _BodyCell(width: 138.832, text: data.data, topPadding: 26),
          _ValueCell(text: data.valor),
          _StatusCell(text: data.status, isPago: data.isPago),
          _ActionsCell(icon: data.receiptIcon),
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
  const _BodyCell({required this.width, required this.text, required this.topPadding});

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
  const _StatusCell({required this.text, required this.isPago});

  final String text;
  final bool isPago;

  @override
  Widget build(BuildContext context) {
    final bg = isPago ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD4);
    final fg = isPago ? const Color(0xFF008236) : const Color(0xFFCA3500);

    return SizedBox(
      width: 168.423,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.87),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.433, vertical: 5.478),
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
  const _ActionsCell({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 189.852,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.87),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _ReceiptButton(icon: icon, onTap: () {}),
        ),
      ),
    );
  }
}

class _ReceiptButton extends StatelessWidget {
  const _ReceiptButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 38.343,
        width: 124.111,
        child: Row(
          children: [
            const SizedBox(width: 16.433),
            Icon(icon, size: 21.91, color: const Color(0xFF364153)),
            const SizedBox(width: 10),
            const Text(
              'Recibo',
              style: TextStyle(
                fontSize: 19.171,
                fontWeight: FontWeight.w400,
                color: Color(0xFF364153),
                height: 27.388 / 19.171,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
