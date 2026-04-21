import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../constants/alunos_mock_data.dart';
import '../models/aluno_item.dart';
import '../widgets/aluno_profile_cell.dart';
import '../widgets/alunos_filter_chip.dart';

class AlunosTableSection extends StatelessWidget {
  const AlunosTableSection({super.key});

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
                  AlunosFilterChip(label: 'ESTADO: TODOS', width: 174.14),
                  SizedBox(width: 18.64),
                  AlunosFilterChip(label: 'ANO: TODOS', width: 156.08),
                  SizedBox(width: 18.64),
                  AlunosFilterChip(label: 'PLANO: TODOS', width: 176.92),
                ],
              ),
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(27.955, 20, 27.955, 18),
                child: Column(
                  children: [
                    const _AlunosTableHeader(),
                    for (
                      var index = 0;
                      index < AlunosMockData.alunos.length;
                      index++
                    )
                      _AlunosTableRow(
                        item: AlunosMockData.alunos[index],
                        showDivider: index != AlunosMockData.alunos.length - 1,
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

class _AlunosTableHeader extends StatelessWidget {
  const _AlunosTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _HeaderCell('PERFIL', 292),
          _HeaderCell('ANO / NÍVEL', 150),
          _HeaderCell('PLANO', 150),
          _HeaderCell('SESSÕES', 150),
          _HeaderCell('ESTADO', 160),
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

class _AlunosTableRow extends StatelessWidget {
  const _AlunosTableRow({required this.item, required this.showDivider});

  final AlunoItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 84.448,
      child: Row(
        children: [
          SizedBox(
            width: 292,
            child: AlunoProfileCell(
              initials: item.initials,
              name: item.name,
              email: item.email,
            ),
          ),
          _BodyCell(item.schoolYear, width: 150),
          _BodyCell(item.planLabel, width: 150),
          _BodyCell(item.sessionsLabel, width: 150),
          SizedBox(
            width: 160,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel,
                color: item.statusColor,
                backgroundColor: item.statusBackgroundColor,
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
