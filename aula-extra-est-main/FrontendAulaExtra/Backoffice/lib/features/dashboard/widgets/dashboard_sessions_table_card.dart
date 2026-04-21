import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/dashboard_session_item.dart';
import 'dashboard_section_header.dart';
import 'dashboard_status_badge.dart';
import 'dashboard_subject_chip.dart';
import 'dashboard_surface_card.dart';

class DashboardSessionsTableCard extends StatelessWidget {
  const DashboardSessionsTableCard({
    required this.sessions,
    required this.title,
    required this.subtitle,
    this.action,
    this.minTableWidth = 980,
    super.key,
  });

  final List<DashboardSessionItem> sessions;
  final String title;
  final String subtitle;
  final Widget? action;
  final double minTableWidth;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.fromLTRB(37.273, 27.955, 37.273, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(
            title: title,
            subtitle: subtitle,
            action: action,
          ),
          const SizedBox(height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minTableWidth),
              child: Column(
                children: [
                  const _SessionTableHeader(),
                  for (var index = 0; index < sessions.length; index++)
                    _SessionTableRow(
                      item: sessions[index],
                      showDivider: index != sessions.length - 1,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTableHeader extends StatelessWidget {
  const _SessionTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _HeaderCell('ALUNO', 150),
          _HeaderCell('EXPLICADOR', 160),
          _HeaderCell('DISCIPLINA', 190),
          _HeaderCell('DATA / HORA', 180),
          _HeaderCell('DURAÇÃO', 120),
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
        padding: const EdgeInsets.only(bottom: 18),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.813,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.35,
          ),
        ),
      ),
    );
  }
}

class _SessionTableRow extends StatelessWidget {
  const _SessionTableRow({required this.item, required this.showDivider});

  final DashboardSessionItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Row(
        children: [
          _BodyText(
            item.student,
            width: 150,
            bold: true,
            color: AppColors.textPrimary,
          ),
          _BodyText(item.tutor, width: 160, color: const Color(0xFF4A5565)),
          SizedBox(
            width: 190,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardSubjectChip(
                label: item.subject,
                icon: item.subjectIcon,
                iconColor: item.subjectColor,
                backgroundColor: item.subjectBackgroundColor,
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18.637,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  item.dateLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16.307,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.18,
                  ),
                ),
              ],
            ),
          ),
          _BodyText(
            item.duration,
            width: 120,
            bold: true,
            color: AppColors.textSecondary,
          ),
          SizedBox(
            width: 160,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel.toUpperCase(),
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
        const Divider(height: 1, color: Color(0x80F9FAFB)),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(
    this.label, {
    required this.width,
    this.bold = false,
    required this.color,
  });

  final String label;
  final double width;
  final bool bold;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16.307,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -0.18,
        ),
      ),
    );
  }
}
