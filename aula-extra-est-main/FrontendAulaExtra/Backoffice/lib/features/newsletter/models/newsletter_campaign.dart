import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

enum NewsletterCampaignStatus { draft, scheduled, sent }

extension NewsletterCampaignStatusPresentation on NewsletterCampaignStatus {
  String get label {
    switch (this) {
      case NewsletterCampaignStatus.draft:
        return 'Rascunho';
      case NewsletterCampaignStatus.scheduled:
        return 'Agendada';
      case NewsletterCampaignStatus.sent:
        return 'Enviada';
    }
  }

  Color get textColor {
    switch (this) {
      case NewsletterCampaignStatus.draft:
        return AppColors.textSecondary;
      case NewsletterCampaignStatus.scheduled:
        return AppColors.warning;
      case NewsletterCampaignStatus.sent:
        return AppColors.success;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case NewsletterCampaignStatus.draft:
        return const Color(0xFFF3F4F6);
      case NewsletterCampaignStatus.scheduled:
        return const Color(0xFFFFF4E5);
      case NewsletterCampaignStatus.sent:
        return const Color(0xFFEAFBF3);
    }
  }
}

class NewsletterCampaign {
  const NewsletterCampaign({
    required this.title,
    required this.subject,
    required this.audience,
    required this.scheduledFor,
    required this.status,
    required this.sentCount,
    required this.openRate,
    required this.clickRate,
  });

  final String title;
  final String subject;
  final String audience;
  final String scheduledFor;
  final NewsletterCampaignStatus status;
  final int sentCount;
  final double openRate;
  final double clickRate;
}
