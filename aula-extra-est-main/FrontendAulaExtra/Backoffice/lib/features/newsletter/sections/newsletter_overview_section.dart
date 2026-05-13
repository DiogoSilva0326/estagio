import 'package:flutter/material.dart';

import '../models/newsletter_campaign.dart';
import 'newsletter_campaigns_section.dart';
import 'newsletter_header_section.dart';
import 'newsletter_metrics_section.dart';

class NewsletterOverviewSection extends StatelessWidget {
  const NewsletterOverviewSection({
    required this.items,
    required this.subscriberCount,
    required this.onCreate,
    required this.onOpenCampaign,
    this.warningMessage,
    this.creating = false,
    super.key,
  });

  final List<NewsletterCampaign> items;
  final int subscriberCount;
  final VoidCallback? onCreate;
  final ValueChanged<NewsletterCampaign> onOpenCampaign;
  final String? warningMessage;
  final bool creating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NewsletterHeaderSection(onCreate: onCreate, creating: creating),
        if (warningMessage != null) ...[
          const SizedBox(height: 24),
          _NewsletterWarningCard(message: warningMessage!),
        ],
        const SizedBox(height: 37.273),
        NewsletterMetricsSection(
          items: items,
          subscriberCount: subscriberCount,
        ),
        const SizedBox(height: 24),
        NewsletterAudienceSection(items: items),
        const SizedBox(height: 37.273),
        NewsletterCampaignsSection(
          items: items,
          onOpenCampaign: onOpenCampaign,
        ),
      ],
    );
  }
}

class _NewsletterWarningCard extends StatelessWidget {
  const _NewsletterWarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        border: Border.all(color: const Color(0xFFFFD38A)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF8A5A00),
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),
      ),
    );
  }
}
