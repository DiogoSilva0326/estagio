class ContactUserSummaryDto {
  const ContactUserSummaryDto({
    required this.contactId,
    required this.contactUserId,
    required this.status,
    this.username,
    this.displayName,
    this.profileImageUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.channelName,
    this.conversationType,
  });

  final String contactId;
  final String contactUserId;
  final String status;
  final String? username;
  final String? displayName;
  final String? profileImageUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? channelName;
  final String? conversationType;

  static String? _firstNonEmptyString(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static String _asString(dynamic value) {
    return value?.toString() ?? '';
  }

  static DateTime? _asDateTime(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final parsed = DateTime.parse(raw);
      final hasExplicitOffset = raw.endsWith('Z') ||
          RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(raw);
      if (hasExplicitOffset) {
        return parsed;
      }

      return DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      );
    } catch (_) {
      return null;
    }
  }

  factory ContactUserSummaryDto.fromJson(Map<String, dynamic> json) {
    return ContactUserSummaryDto(
      contactId: _asString(json['contactId']),
      contactUserId: _asString(json['contactUserId']),
      status: (json['status'] ?? 'pending').toString(),
      username: json['username']?.toString(),
      displayName: json['displayName']?.toString(),
      profileImageUrl: _firstNonEmptyString([
        json['profileImageUrl'],
        json['photoUrl'],
        json['photo'],
        json['avatarUrl'],
        json['imageUrl'],
      ]),
      lastMessage: _firstNonEmptyString([
        json['lastMessage'],
        json['last_message'],
      ]),
      lastMessageAt: _asDateTime(
        json['lastMessageAt'] ?? json['last_message_at'],
      ),
      channelName: _firstNonEmptyString([
        json['channelName'],
        json['channel_name'],
      ]),
      conversationType: _firstNonEmptyString([
        json['conversationType'],
        json['conversation_type'],
      ]),
    );
  }
}
