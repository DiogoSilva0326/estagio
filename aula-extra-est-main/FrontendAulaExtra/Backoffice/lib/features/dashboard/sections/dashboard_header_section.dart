import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/dashboard_refresh_button.dart';

class DashboardHeaderSection extends StatelessWidget {
  const DashboardHeaderSection({
    this.title = 'Dashboard',
    this.subtitle = 'Acompanha a atividade e os resultados da tua plataforma.',
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 41.933,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.67,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.307,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const DashboardRefreshButton(),
      ],
    );
  }
}
