class ContactUserSummaryDto {
  const ContactUserSummaryDto({
    required this.contactId,
    required this.contactUserId,
    required this.status,
    this.username,
    this.displayName,
  });

  final String contactId;
  final String contactUserId;
  final String status;
  final String? username;
  final String? displayName;

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
    );
  }
}
