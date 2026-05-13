import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import '../widgets/dashboard_surface_card.dart';
import 'dashboard_header_section.dart';
import 'dashboard_kpi_grid_section.dart';
import 'dashboard_recent_sessions_section.dart';
import 'dashboard_system_status_section.dart';

class DashboardOverviewSection extends StatefulWidget {
  const DashboardOverviewSection({super.key});

  @override
  State<DashboardOverviewSection> createState() => _DashboardOverviewSectionState();
}

class _DashboardOverviewSectionState extends State<DashboardOverviewSection> {
  late Future<DashboardViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DashboardViewData> _load() {
    return DashboardService().fetch();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardViewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? DashboardViewData.fallback();

        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: CircularProgressIndicator(),
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeaderSection(),
            if (data.warningMessage != null) ...[
              const SizedBox(height: 24),
              _DashboardWarningCard(
                message: data.warningMessage!,
                onRetry: _reload,
              ),
            ],
            const SizedBox(height: 55.91),
            DashboardKpiGridSection(items: data.kpis),
            const SizedBox(height: 37.273),
            DashboardRecentSessionsSection(sessions: data.recentSessions),
            const SizedBox(height: 37.273),
            DashboardSystemStatusSection(
              serviceStatuses: data.serviceStatuses,
              popularSubjects: data.popularSubjects,
            ),
          ],
        );
      },
    );
  }
}

class _DashboardWarningCard extends StatelessWidget {
  const _DashboardWarningCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFF79009),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
