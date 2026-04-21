import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../widgets/newsletter_metric_card.dart';

class NewsletterMetricsSection extends StatelessWidget {
  const NewsletterMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return const Column(
            children: [
              NewsletterMetricCard(
                title: 'Campanhas enviadas',
                value: '24',
                caption: 'Últimos 30 dias',
                icon: Icons.send_rounded,
                iconBackgroundColor: Color(0xFFFFF1E8),
                iconColor: Color(0xFFFC9039),
              ),
              SizedBox(height: 18),
              NewsletterMetricCard(
                title: 'Taxa média de abertura',
                value: '46,8%',
                caption: 'Acima do mês anterior',
                icon: Icons.mark_email_read_rounded,
                iconBackgroundColor: Color(0xFFEAF2FF),
                iconColor: Color(0xFF3B82F6),
              ),
              SizedBox(height: 18),
              NewsletterMetricCard(
                title: 'Cliques médios',
                value: '11,9%',
                caption: 'CTR global das campanhas',
                icon: Icons.ads_click_rounded,
                iconBackgroundColor: Color(0xFFEAFBF3),
                iconColor: Color(0xFF12B76A),
              ),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NewsletterMetricCard(
                title: 'Campanhas enviadas',
                value: '24',
                caption: 'Últimos 30 dias',
                icon: Icons.send_rounded,
                iconBackgroundColor: Color(0xFFFFF1E8),
                iconColor: Color(0xFFFC9039),
              ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: NewsletterMetricCard(
                title: 'Taxa média de abertura',
                value: '46,8%',
                caption: 'Acima do mês anterior',
                icon: Icons.mark_email_read_rounded,
                iconBackgroundColor: Color(0xFFEAF2FF),
                iconColor: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: NewsletterMetricCard(
                title: 'Cliques médios',
                value: '11,9%',
                caption: 'CTR global das campanhas',
                icon: Icons.ads_click_rounded,
                iconBackgroundColor: Color(0xFFEAFBF3),
                iconColor: Color(0xFF12B76A),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NewsletterAudienceSection extends StatelessWidget {
  const NewsletterAudienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 860;

        final cards = const [
          Expanded(
            child: _InsightCard(
              icon: Icons.groups_rounded,
              iconBackgroundColor: Color(0xFFEAF2FF),
              iconColor: Color(0xFF3B82F6),
              title: 'Segmentos ativos',
              body:
                  'Novos registos, alunos inativos, explicadores ativos e leads vindas do formulário principal.',
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: _InsightCard(
              icon: Icons.schedule_send_rounded,
              iconBackgroundColor: Color(0xFFFFF4E5),
              iconColor: AppColors.warning,
              title: 'Próximo envio',
              body:
                  'Reativação de alunos inativos · amanhã às 09:00 · audiência prevista de 860 contactos.',
            ),
          ),
        ];

        if (isCompact) {
          return const Column(
            children: [
              _InsightCard(
                icon: Icons.groups_rounded,
                iconBackgroundColor: Color(0xFFEAF2FF),
                iconColor: Color(0xFF3B82F6),
                title: 'Segmentos ativos',
                body:
                    'Novos registos, alunos inativos, explicadores ativos e leads vindas do formulário principal.',
              ),
              SizedBox(height: 18),
              _InsightCard(
                icon: Icons.schedule_send_rounded,
                iconBackgroundColor: Color(0xFFFFF4E5),
                iconColor: AppColors.warning,
                title: 'Próximo envio',
                body:
                    'Reativação de alunos inativos · amanhã às 09:00 · audiência prevista de 860 contactos.',
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards,
        );
      },
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 25),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
