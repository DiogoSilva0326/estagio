import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/newsletter_campaign.dart';
import '../widgets/newsletter_metric_card.dart';

class NewsletterMetricsSection extends StatelessWidget {
  const NewsletterMetricsSection({
    required this.items,
    required this.subscriberCount,
    super.key,
  });

  final List<NewsletterCampaign> items;
  final int subscriberCount;

  @override
  Widget build(BuildContext context) {
    final sentCampaigns = items.where((item) => item.status == NewsletterCampaignStatus.sent).length;
    final pendingCampaigns = items.where((item) => item.status != NewsletterCampaignStatus.sent).length;
    final sentContacts = items.fold<int>(0, (sum, item) => sum + item.sentCount);

    final cards = [
      NewsletterMetricCard(
        title: 'Subscritores ativos',
        value: '$subscriberCount',
        caption: 'Total confirmado na base de newsletter',
        icon: Icons.send_rounded,
        iconBackgroundColor: const Color(0xFFFFF1E8),
        iconColor: const Color(0xFFFC9039),
      ),
      NewsletterMetricCard(
        title: 'Campanhas enviadas',
        value: '$sentCampaigns',
        caption: 'Campanhas com envio concluído',
        icon: Icons.mark_email_read_rounded,
        iconBackgroundColor: const Color(0xFFEAF2FF),
        iconColor: const Color(0xFF3B82F6),
      ),
      NewsletterMetricCard(
        title: 'Fluxo ativo',
        value: pendingCampaigns > 0 ? '$pendingCampaigns' : '$sentContacts',
        caption: pendingCampaigns > 0
            ? 'Rascunhos ou campanhas ainda por concluir'
            : 'Contactos já processados pelos envios',
        icon: Icons.ads_click_rounded,
        iconBackgroundColor: const Color(0xFFEAFBF3),
        iconColor: const Color(0xFF12B76A),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 18),
              cards[1],
              const SizedBox(height: 18),
              cards[2],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 18),
            Expanded(child: cards[1]),
            const SizedBox(width: 18),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }
}

class NewsletterAudienceSection extends StatelessWidget {
  const NewsletterAudienceSection({required this.items, super.key});

  final List<NewsletterCampaign> items;

  @override
  Widget build(BuildContext context) {
    final activeSegments = items
        .map((item) => item.audience)
        .where((label) => label.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
    final nextScheduled = items.where((item) => item.scheduledAt != null).toList(growable: false)
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    final nextCampaign = nextScheduled.isNotEmpty ? nextScheduled.first : null;

    Widget buildSegmentsCard() {
      return _InsightCard(
        icon: Icons.groups_rounded,
        iconBackgroundColor: const Color(0xFFEAF2FF),
        iconColor: const Color(0xFF3B82F6),
        title: 'Segmentos ativos',
        body: activeSegments.isEmpty
            ? 'Sem segmentos utilizados ainda. As novas campanhas podem ser dirigidas a todos os subscritores ou a segmentos específicos.'
            : activeSegments.join(', '),
      );
    }

    Widget buildNextCard() {
      return _InsightCard(
        icon: Icons.schedule_send_rounded,
        iconBackgroundColor: const Color(0xFFFFF4E5),
        iconColor: AppColors.warning,
        title: 'Próximo envio',
        body: nextCampaign == null
            ? 'Sem campanhas agendadas de momento. Os rascunhos ficam disponíveis para envio manual.'
            : '${nextCampaign.title} · ${nextCampaign.scheduledFor} · ${nextCampaign.performanceLabel.toLowerCase()}.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 860;

        if (isCompact) {
          return Column(
            children: [
              buildSegmentsCard(),
              const SizedBox(height: 18),
              buildNextCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildSegmentsCard()),
            const SizedBox(width: 18),
            Expanded(child: buildNextCard()),
          ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
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