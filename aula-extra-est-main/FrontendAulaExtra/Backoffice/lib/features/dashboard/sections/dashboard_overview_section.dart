import 'package:flutter/material.dart';

import 'dashboard_header_section.dart';
import 'dashboard_kpi_grid_section.dart';
import 'dashboard_recent_sessions_section.dart';
import 'dashboard_system_status_section.dart';

class DashboardOverviewSection extends StatelessWidget {
  const DashboardOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeaderSection(),
        SizedBox(height: 55.91),
        DashboardKpiGridSection(),
        SizedBox(height: 37.273),
        DashboardRecentSessionsSection(),
        SizedBox(height: 37.273),
        DashboardSystemStatusSection(),
      ],
    );
  }
}
