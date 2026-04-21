import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../constants/explicadores_mock_data.dart';
import '../models/explicador_item.dart';
import '../widgets/explicador_actions_menu.dart';
import '../widgets/explicador_profile_cell.dart';
import '../widgets/explicadores_filter_chip.dart';

class ExplicadoresTableSection extends StatelessWidget {
  const ExplicadoresTableSection({super.key});

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
            height: 90.27,
            padding: const EdgeInsets.symmetric(
              horizontal: 37.273,
              vertical: 23.296,
            ),
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExplicadoresFilterChip(label: 'ESTADO: TODOS', width: 174.14),
                  SizedBox(width: 18.64),
                  ExplicadoresFilterChip(label: 'ÁREA: TODAS', width: 156.08),
                  SizedBox(width: 18.64),
                  ExplicadoresFilterChip(
                    label: 'VERIFICAÇÃO: TODOS',
                    width: 207.92,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 960),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(27.955, 20, 27.955, 18),
                child: Column(
                  children: [
                    const _ExplicadoresTableHeader(),
                    for (
                      var index = 0;
                      index < ExplicadoresMockData.explicadores.length;
                      index++
                    )
                      _ExplicadoresTableRow(
                        item: ExplicadoresMockData.explicadores[index],
                        showDivider:
                            index !=
                            ExplicadoresMockData.explicadores.length - 1,
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

class _ExplicadoresTableHeader extends StatelessWidget {
  const _ExplicadoresTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _HeaderCell('PERFIL', 292),
          _HeaderCell('DISCIPLINA\nPRINCIPAL', 168),
          _HeaderCell('PREÇO/HORA', 140),
          _HeaderCell('AVALIAÇÃO', 176),
          _HeaderCell('ESTADO', 140),
          SizedBox(width: 44),
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
        padding: const EdgeInsets.only(bottom: 16),
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

class _ExplicadoresTableRow extends StatelessWidget {
  const _ExplicadoresTableRow({required this.item, required this.showDivider});

  final ExplicadorItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 84.448,
      child: Row(
        children: [
          SizedBox(
            width: 292,
            child: ExplicadorProfileCell(
              initials: item.initials,
              name: item.name,
              email: item.email,
            ),
          ),
          _BodyCell(item.mainSubject, width: 168),
          _BodyCell(item.priceLabel, width: 140),
          _BodyCell(item.ratingLabel, width: 176),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel,
                color: item.statusColor,
                backgroundColor: item.statusBackgroundColor,
              ),
            ),
          ),
          SizedBox(width: 44, child: ExplicadorActionsMenu(item: item)),
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
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4A5565),
          fontSize: 16.307,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1752,
        ),
      ),
    );
  }
}
