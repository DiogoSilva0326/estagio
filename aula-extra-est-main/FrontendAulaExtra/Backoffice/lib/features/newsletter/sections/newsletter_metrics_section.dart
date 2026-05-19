import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/newsletter_campaign.dart';
import '../models/newsletter_subscriber.dart';
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

class NewsletterSubscribersSection extends StatelessWidget {
  const NewsletterSubscribersSection({
    required this.subscribers,
    super.key,
  });

  final List<NewsletterSubscriber> subscribers;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.alternate_email_rounded,
                  color: Color(0xFF12B76A),
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscritores confirmados',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Lista real dos emails ativos guardados na base de dados da newsletter.',
                      style: TextStyle(
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
          const SizedBox(height: 24),
          if (subscribers.isEmpty)
            const Text(
              'Ainda não existem subscritores confirmados para mostrar.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 860) {
                  return Column(
                    children: [
                      for (var index = 0; index < subscribers.length; index++) ...[
                        _SubscriberMobileCard(item: subscribers[index]),
                        if (index != subscribers.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    const _SubscriberTableHeader(),
                    const SizedBox(height: 8),
                    for (var index = 0; index < subscribers.length; index++) ...[
                      _SubscriberTableRow(item: subscribers[index]),
                      if (index != subscribers.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SubscriberTableHeader extends StatelessWidget {
  const _SubscriberTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 4, child: _SubscriberHeaderLabel('Email')),
          Expanded(flex: 2, child: _SubscriberHeaderLabel('Origem')),
          Expanded(flex: 2, child: _SubscriberHeaderLabel('Idioma')),
          Expanded(flex: 3, child: _SubscriberHeaderLabel('Confirmado em')),
        ],
      ),
    );
  }
}

class _SubscriberHeaderLabel extends StatelessWidget {
  const _SubscriberHeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _SubscriberTableRow extends StatelessWidget {
  const _SubscriberTableRow({required this.item});

  final NewsletterSubscriber item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.email,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.sourceLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.locale,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.confirmedLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriberMobileCard extends StatelessWidget {
  const _SubscriberMobileCard({required this.item});

  final NewsletterSubscriber item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.email,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${item.sourceLabel} · ${item.locale} · ${item.confirmedLabel}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
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