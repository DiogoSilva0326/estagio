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
    required this.id,
    required this.title,
    required this.subject,
    required this.segment,
    required this.status,
    this.preheader,
    this.htmlBody,
    this.plainBody,
    this.scheduledAt,
    this.sentAt,
    this.createdAt,
    this.lastUpdate,
    this.totalRecipients = 0,
    this.sentCount = 0,
    this.failedCount = 0,
    this.timesSent = 0,
    this.openRate,
    this.clickRate,
  });

  factory NewsletterCampaign.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '0') ?? 0;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return NewsletterCampaign(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      preheader: _normalizeOptional(json['preheader']),
      htmlBody: _normalizeOptional(json['htmlBody'] ?? json['html_body']),
      plainBody: _normalizeOptional(json['plainBody'] ?? json['plain_body']),
      segment: json['segment']?.toString() ?? 'all_subscribed',
      status: _statusFromRaw(json['status']?.toString()),
      scheduledAt: parseDate(json['scheduledAt'] ?? json['scheduled_at']),
      sentAt: parseDate(json['sentAt'] ?? json['sent_at']),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      lastUpdate: parseDate(json['lastUpdate'] ?? json['last_update']),
      totalRecipients: parseInt(json['totalRecipients'] ?? json['total_recipients']),
      sentCount: parseInt(json['totalSent'] ?? json['total_sent']),
      failedCount: parseInt(json['totalFailed'] ?? json['total_failed']),
      timesSent: parseInt(json['timesSent'] ?? json['times_sent']),
      openRate: parseDouble(json['openRate'] ?? json['open_rate']),
      clickRate: parseDouble(json['clickRate'] ?? json['click_rate']),
    );
  }

  final String id;
  final String title;
  final String subject;
  final String? preheader;
  final String? htmlBody;
  final String? plainBody;
  final String segment;
  final NewsletterCampaignStatus status;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? lastUpdate;
  final int totalRecipients;
  final int sentCount;
  final int failedCount;
  final int timesSent;
  final double? openRate;
  final double? clickRate;

  String get audience => _segmentLabel(segment);

  String get scheduledFor {
    if (sentAt != null) {
      return 'Enviada em ${_formatDate(sentAt!, includeTime: true)}';
    }

    if (scheduledAt != null) {
      return 'Agendada para ${_formatDate(scheduledAt!, includeTime: true)}';
    }

    if (status == NewsletterCampaignStatus.draft) {
      return 'Rascunho';
    }

    if (createdAt != null) {
      return 'Criada em ${_formatDate(createdAt!)}';
    }

    return '-';
  }

  String get performanceLabel {
    if (sentCount > 0 || failedCount > 0) {
      if (failedCount > 0) {
        return '$sentCount enviados · $failedCount falhas';
      }
      return '$sentCount enviados';
    }

    if (totalRecipients > 0) {
      return '$totalRecipients contactos';
    }

    return 'Sem dados de envio';
  }

  static NewsletterCampaignStatus _statusFromRaw(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'scheduled':
      case 'sending':
        return NewsletterCampaignStatus.scheduled;
      case 'sent':
        return NewsletterCampaignStatus.sent;
      default:
        return NewsletterCampaignStatus.draft;
    }
  }

  static String? _normalizeOptional(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static String _segmentLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'new_registrations':
        return 'Novos registos';
      case 'inactive_students_30d':
        return 'Alunos inativos há 30 dias';
      case 'active_professors':
        return 'Explicadores ativos';
      case 'main_form_leads':
        return 'Leads do formulário principal';
      case 'all_subscribed':
      default:
        return 'Todos os subscritores';
    }
  }

  static String _formatDate(DateTime value, {bool includeTime = false}) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    if (!includeTime) {
      return '$day/$month/$year';
    }

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}