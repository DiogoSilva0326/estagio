import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/dashboard_popular_subject_item.dart';
import '../models/dashboard_service_status_item.dart';
import '../widgets/dashboard_popular_subject_row.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_service_status_row.dart';
import '../widgets/dashboard_surface_card.dart';

class DashboardSystemStatusSection extends StatelessWidget {
  const DashboardSystemStatusSection({
    required this.serviceStatuses,
    required this.popularSubjects,
    super.key,
  });

  final List<DashboardServiceStatusItem> serviceStatuses;
  final List<DashboardPopularSubjectItem> popularSubjects;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.fromLTRB(37.273, 27.955, 37.273, 37.273),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Estado do Sistema',
            subtitle: 'Métricas em tempo real',
          ),
          const SizedBox(height: 37.273),
          const _SectionEyebrow(label: 'SERVIÇOS CORE'),
          const SizedBox(height: 23.296),
          for (var index = 0; index < serviceStatuses.length; index++) ...[
            DashboardServiceStatusRow(item: serviceStatuses[index]),
            if (index != serviceStatuses.length - 1)
              const SizedBox(height: 18.637),
          ],
          const SizedBox(height: 37.273),
          const Divider(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 37.273),
          const _SectionEyebrow(label: 'ÁREAS POPULARES'),
          const SizedBox(height: 23.296),
          for (var index = 0; index < popularSubjects.length; index++) ...[
            DashboardPopularSubjectRow(item: popularSubjects[index]),
            if (index != popularSubjects.length - 1)
              const SizedBox(height: 13.978),
          ],
        ],
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6.989,
          height: 6.989,
          decoration: const BoxDecoration(
            color: Color(0xFFD1D5DC),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.813,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.35,
          ),
        ),
      ],
    );
  }
}
