import 'package:flutter/material.dart';

import '../constants/dashboard_mock_data.dart';
import '../../../routes/app_routes.dart';
import '../widgets/dashboard_sessions_table_card.dart';

class DashboardRecentSessionsSection extends StatelessWidget {
  const DashboardRecentSessionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardSessionsTableCard(
      sessions: DashboardMockData.recentSessions,
      title: 'Sessões Recentes',
      subtitle: 'Acompanha as videochamadas em tempo real',
      action: _SeeAllButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.sessoesRecentes);
        },
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFC9039),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: const Text(
        'Ver Todas',
        style: TextStyle(
          fontSize: 15.142,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.09,
        ),
      ),
    );
  }
}
