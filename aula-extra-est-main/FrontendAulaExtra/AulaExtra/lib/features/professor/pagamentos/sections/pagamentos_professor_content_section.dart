import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:aula_extra/features/professor/pagamentos/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class PagamentosProfessorContentSection extends StatelessWidget {
  const PagamentosProfessorContentSection({
    super.key,
  });

  static const List<_PaymentRowData> _rows = [
    _PaymentRowData(
      studentName: 'João Silva',
      classDate: '20 Jan 2026',
      amountLabel: '25€',
      status: _PaymentStatus.paid,
    ),
    _PaymentRowData(
      studentName: 'Maria Santos',
      classDate: '22 Jan 2026',
      amountLabel: '30€',
      status: _PaymentStatus.paid,
    ),
    _PaymentRowData(
      studentName: 'Pedro Costa',
      classDate: '23 Jan 2026',
      amountLabel: '25€',
      status: _PaymentStatus.pending,
    ),
    _PaymentRowData(
      studentName: 'Ana Rodrigues',
      classDate: '24 Jan 2026',
      amountLabel: '25€',
      status: _PaymentStatus.pending,
    ),
    _PaymentRowData(
      studentName: 'Carlos Ferreira',
      classDate: '25 Jan 2026',
      amountLabel: '30€',
      status: _PaymentStatus.paid,
    ),
    _PaymentRowData(
      studentName: 'Sofia Oliveira',
      classDate: '26 Jan 2026',
      amountLabel: '45€',
      status: _PaymentStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: PagamentosProfessorColors.title,
      fontSize: PagamentosProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height: PagamentosProfessorLayout.titleLineHeight / PagamentosProfessorLayout.titleFontSize,
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
              const ProfessorMenuNav(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PagamentosProfessorLayout.contentPadding,
                    PagamentosProfessorLayout.contentPadding,
                    PagamentosProfessorLayout.contentPadding,
                    0,
                  ),
                  child: Column(
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
                              value: '85€',
                              subtitle: 'Este mês',
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  PagamentosProfessorColors.summaryGreenTop,
                                  PagamentosProfessorColors.summaryGreenBottom,
                                ],
                              ),
                              icon: Icons.payments_rounded,
                            ),
                            const SizedBox(width: PagamentosProfessorLayout.summaryCardsGap),
                            _SummaryCard(
                              title: 'Ganhos Pendentes',
                              value: '95€',
                              subtitle: 'A receber',
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  PagamentosProfessorColors.summaryOrangeTop,
                                  PagamentosProfessorColors.summaryOrangeBottom,
                                ],
                              ),
                              icon: Icons.hourglass_bottom_rounded,
                            ),
                            const SizedBox(width: PagamentosProfessorLayout.summaryCardsGap),
                            _SummaryCard(
                              title: 'Total Este Mês',
                              value: '180€',
                              subtitle: 'Janeiro 2026',
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  PagamentosProfessorColors.summaryBlueTop,
                                  PagamentosProfessorColors.summaryBlueBottom,
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
                        child: _WithdrawButton(onTap: () {}),
                      ),
                      const SizedBox(height: 19.171),
                      _TableCard(rows: _rows),
                    ],
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

enum _PaymentStatus {
  paid,
  pending,
}

class _PaymentRowData {
  const _PaymentRowData({
    required this.studentName,
    required this.classDate,
    required this.amountLabel,
    required this.status,
  });

  final String studentName;
  final String classDate;
  final String amountLabel;
  final _PaymentStatus status;
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
          borderRadius: BorderRadius.circular(PagamentosProfessorLayout.summaryCardRadius),
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
                          fontSize: PagamentosProfessorLayout.summaryLabelFontSize,
                          fontWeight: FontWeight.w500,
                          height: PagamentosProfessorLayout.summaryLabelLineHeight /
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
                  height: PagamentosProfessorLayout.summaryValueLineHeight /
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
                    height: PagamentosProfessorLayout.summarySubLabelLineHeight /
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

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PagamentosProfessorLayout.withdrawButtonWidth,
      height: PagamentosProfessorLayout.withdrawButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PagamentosProfessorLayout.withdrawButtonRadius),
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
          borderRadius: BorderRadius.circular(PagamentosProfessorLayout.withdrawButtonRadius),
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
                      height: PagamentosProfessorLayout.tableTextLineHeight /
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
  });

  final List<_PaymentRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 401.993,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PagamentosProfessorLayout.tableRadius),
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
        borderRadius: BorderRadius.circular(PagamentosProfessorLayout.tableRadius),
        child: Column(
          children: [
            const _TableHeader(),
            Expanded(
              child: ListView.separated(
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
                  return _TableRow(row: row);
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
      height: PagamentosProfessorLayout.tableTextLineHeight /
          PagamentosProfessorLayout.tableTextFontSize,
    );

    return Container(
      height: PagamentosProfessorLayout.tableHeaderHeight,
      decoration: const BoxDecoration(
        color: PagamentosProfessorColors.tableHeaderBackground,
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            width: 1.198,
          ),
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
            SizedBox(
              width: 106.929,
              child: Text('Valor', style: headerStyle),
            ),
            SizedBox(
              width: 180.889,
              child: Text('Status', style: headerStyle),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Ações', style: headerStyle, textAlign: TextAlign.right),
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
  });

  final _PaymentRowData row;

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
              child: Text(row.classDate, style: cellTextStyle),
            ),
            SizedBox(
              width: 106.929,
              child: Text(row.amountLabel, style: amountStyle),
            ),
            SizedBox(
              width: 180.889,
              child: _StatusBadge(status: row.status),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _DetailsButton(onTap: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final _PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final background = switch (status) {
      _PaymentStatus.paid => PagamentosProfessorColors.badgePaidBackground,
      _PaymentStatus.pending => PagamentosProfessorColors.badgePendingBackground,
    };

    final textColor = switch (status) {
      _PaymentStatus.paid => Colors.white,
      _PaymentStatus.pending => PagamentosProfessorColors.badgePendingText,
    };

    final label = switch (status) {
      _PaymentStatus.paid => 'Pago',
      _PaymentStatus.pending => 'Pendente',
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: PagamentosProfessorLayout.badgeHeight,
        padding: const EdgeInsets.symmetric(horizontal: 9.59),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(PagamentosProfessorLayout.badgeRadius),
        ),
        child: Center(
          child: Text(
            label,
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
  const _DetailsButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PagamentosProfessorLayout.actionButtonHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PagamentosProfessorLayout.actionButtonRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              'Ver Detalhes',
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
