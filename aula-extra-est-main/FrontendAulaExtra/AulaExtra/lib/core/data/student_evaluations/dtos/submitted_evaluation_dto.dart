class SubmittedEvaluationDto {
  SubmittedEvaluationDto({
    required this.lessonFeedbackId,
    required this.lessonId,
    required this.professorId,
    required this.professorName,
    required this.subject,
    required this.lessonStart,
    required this.lessonEnd,
    required this.rating,
    required this.comments,
    required this.createdAt,
  });

  final String lessonFeedbackId;
  final String lessonId;
  final String? professorId;
  final String? professorName;
  final String? subject;
  final DateTime? lessonStart;
  final DateTime? lessonEnd;
  final int? rating;
  final String? comments;
  final DateTime? createdAt;

  factory SubmittedEvaluationDto.fromJson(Map<String, dynamic> json) {
    return SubmittedEvaluationDto(
      lessonFeedbackId: (json['lessonFeedbackId'] ?? '').toString(),
      lessonId: (json['lessonId'] ?? '').toString(),
      professorId: json['professorId']?.toString(),
      professorName: json['professorName']?.toString(),
      subject: json['subject']?.toString(),
      lessonStart: _tryParseDateTime(json['lessonStart']),
      lessonEnd: _tryParseDateTime(json['lessonEnd']),
      rating: _tryParseInt(json['rating']),
      comments: json['comments']?.toString(),
      createdAt: _tryParseDateTime(json['createdAt']),
    );
  }

  static int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    if (s.trim().isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
