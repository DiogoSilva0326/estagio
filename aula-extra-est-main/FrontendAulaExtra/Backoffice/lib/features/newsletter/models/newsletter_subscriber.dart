class NewsletterSubscriber {
  const NewsletterSubscriber({
    required this.id,
    required this.email,
    required this.status,
    required this.locale,
    required this.createdAt,
    required this.lastUpdate,
    this.source,
    this.confirmedAt,
  });

  factory NewsletterSubscriber.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) {
        return null;
      }

      return DateTime.tryParse(value.toString());
    }

    return NewsletterSubscriber(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'subscribed',
      locale: json['locale']?.toString() ?? 'pt-PT',
      source: json['source']?.toString(),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      confirmedAt: parseDate(json['confirmedAt'] ?? json['confirmed_at']),
      lastUpdate: parseDate(json['lastUpdate'] ?? json['last_update']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String email;
  final String status;
  final String locale;
  final String? source;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime lastUpdate;

  String get sourceLabel {
    final normalized = (source ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Sem origem';
    }

    switch (normalized) {
      case 'footer':
        return 'Footer';
      case 'backoffice':
        return 'Backoffice';
      default:
        return source!.trim();
    }
  }

  String get confirmedLabel {
    final value = confirmedAt ?? createdAt;
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}