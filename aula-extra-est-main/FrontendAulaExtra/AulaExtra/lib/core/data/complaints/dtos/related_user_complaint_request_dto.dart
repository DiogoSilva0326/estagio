class RelatedUserComplaintRequestDto {
  const RelatedUserComplaintRequestDto({
    required this.targetUserId,
    required this.relationshipType,
    required this.complaintType,
    required this.subject,
    required this.message,
  });

  final String targetUserId;
  final String relationshipType;
  final String complaintType;
  final String subject;
  final String message;

  Map<String, dynamic> toJson() => {
    'targetUserId': targetUserId,
    'relationshipType': relationshipType,
    'complaintType': complaintType,
    'subject': subject,
    'message': message,
  };
}