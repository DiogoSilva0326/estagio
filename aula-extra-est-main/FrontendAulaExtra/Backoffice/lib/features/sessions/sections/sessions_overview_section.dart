import 'package:flutter/material.dart';

import '../../dashboard/constants/dashboard_mock_data.dart';
import '../../dashboard/sections/dashboard_header_section.dart';
import '../../dashboard/widgets/dashboard_sessions_table_card.dart';

class SessionsOverviewSection extends StatelessWidget {
  const SessionsOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeaderSection(
          title: 'Sessões Recentes',
          subtitle: 'Consulta todas as sessões recentes da plataforma.',
        ),
        SizedBox(height: 55.91),
        DashboardSessionsTableCard(
          sessions: DashboardMockData.allSessions,
          title: 'Sessões Recentes',
          subtitle: 'Acompanha as videochamadas em tempo real',
        ),
      ],
    );
  }
}
