import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../constants/sessoes_aulas_mock_data.dart';
import '../models/sessao_aula_item.dart';
import '../widgets/sessao_link_button.dart';
import '../widgets/sessoes_aulas_filter_chip.dart';

class SessoesAulasTableSection extends StatelessWidget {
  const SessoesAulasTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 90.272,
            padding: const EdgeInsets.symmetric(
              horizontal: 37.273,
              vertical: 23.296,
            ),
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: [
                  SessoesAulasFilterChip(label: 'DATA: TODAS', width: 164.818),
                  SizedBox(width: 18.637),
                  SessoesAulasFilterChip(
                    label: 'ESTADO: TODOS',
                    width: 174.137,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1417.909),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9.318, 9.318, 27.955, 18),
                child: Column(
                  children: [
                    const _SessoesAulasTableHeader(),
                    for (
                      var index = 0;
                      index < SessoesAulasMockData.sessoes.length;
                      index++
                    )
                      _SessoesAulasTableRow(
                        item: SessoesAulasMockData.sessoes[index],
                        showDivider:
                            index != SessoesAulasMockData.sessoes.length - 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessoesAulasTableHeader extends StatelessWidget {
  const _SessoesAulasTableHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 75.712,
      child: Row(
        children: [
          _HeaderCell('SESSÕES', 149.749),
          _HeaderCell('ALUNO', 166.593),
          _HeaderCell('EXPLICADOR', 175.092),
          _HeaderCell('DISCIPLINA', 150.468),
          _HeaderCell('DATA / HORA', 148.593),
          _HeaderCell('DURAÇÃO', 198.461),
          _HeaderCell('LINK SALA', 203.402),
          _HeaderCell('ESTADO', 169.641),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, this.width);

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(27.955, 24, 0, 17),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.813,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3563,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _SessoesAulasTableRow extends StatelessWidget {
  const _SessoesAulasTableRow({required this.item, required this.showDivider});

  final SessaoAulaItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 71.052,
      child: Row(
        children: [
          _BodyCell(item.codigo, width: 149.749),
          _BodyCell(item.aluno, width: 166.593),
          _BodyCell(item.explicador, width: 175.092),
          _BodyCell(item.disciplina, width: 150.468),
          _BodyCell(item.dataHora, width: 148.593),
          _BodyCell(item.duracao, width: 198.461),
          SizedBox(
            width: 203.402,
            child: Padding(
              padding: const EdgeInsets.only(left: 27.955),
              child: Align(
                alignment: Alignment.centerLeft,
                child: item.canEnterRoom
                    ? SessaoLinkButton(
                        label: item.linkSalaLabel,
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ligação à sala `${item.codigo}` pode ser ligada a seguir.',
                                ),
                              ),
                            );
                        },
                      )
                    : const Text(
                        '-',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.307,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.18,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(
            width: 169.641,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel,
                color: item.statusColor,
                backgroundColor: item.statusBackgroundColor,
                showDot: item.showStatusDot,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        const Divider(height: 1.165, color: Color(0x80F9FAFB)),
      ],
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.label, {required this.width});

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(left: 27.955),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A5565),
            fontSize: 16.307,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1752,
          ),
        ),
      ),
    );
  }
}
