class PendingEvaluationDto {
  PendingEvaluationDto({
    required this.lessonId,
    required this.professorId,
    required this.professorName,
    required this.subject,
    required this.lessonStart,
    required this.lessonEnd,
  });

  final String lessonId;
  final String professorId;
  final String professorName;
  final String? subject;
  final DateTime? lessonStart;
  final DateTime? lessonEnd;

  factory PendingEvaluationDto.fromJson(Map<String, dynamic> json) {
    return PendingEvaluationDto(
      lessonId: (json['lessonId'] ?? '').toString(),
      professorId: (json['professorId'] ?? '').toString(),
      professorName: (json['professorName'] ?? '').toString(),
      subject: json['subject']?.toString(),
      lessonStart: _tryParseDateTime(json['lessonStart']),
      lessonEnd: _tryParseDateTime(json['lessonEnd']),
    );
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    if (s.trim().isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
