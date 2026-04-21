import 'package:flutter/material.dart';

import '../models/newsletter_campaign.dart';
import 'newsletter_campaigns_section.dart';
import 'newsletter_header_section.dart';
import 'newsletter_metrics_section.dart';

class NewsletterOverviewSection extends StatelessWidget {
  const NewsletterOverviewSection({
    required this.items,
    required this.onCreate,
    super.key,
  });

  final List<NewsletterCampaign> items;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NewsletterHeaderSection(onCreate: onCreate),
        const SizedBox(height: 37.273),
        const NewsletterMetricsSection(),
        const SizedBox(height: 24),
        const NewsletterAudienceSection(),
        const SizedBox(height: 37.273),
        NewsletterCampaignsSection(items: items),
      ],
    );
  }
}
