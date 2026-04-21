class ContactUserSummaryDto {
  const ContactUserSummaryDto({
    required this.contactId,
    required this.contactUserId,
    required this.status,
    this.username,
    this.displayName,
    this.profileImageUrl,
  });

  final String contactId;
  final String contactUserId;
  final String status;
  final String? username;
  final String? displayName;
  final String? profileImageUrl;

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
    );
  }
}
