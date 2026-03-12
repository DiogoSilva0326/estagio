class PendingProfessorEvaluationDto {
  PendingProfessorEvaluationDto({
    required this.professorId,
    required this.professorName,
    required this.lastLessonStart,
    required this.lastLessonEnd,
  });

  final String professorId;
  final String professorName;
  final DateTime? lastLessonStart;
  final DateTime? lastLessonEnd;

  factory PendingProfessorEvaluationDto.fromJson(Map<String, dynamic> json) {
    return PendingProfessorEvaluationDto(
      professorId: json['professorId']?.toString() ?? '',
      professorName: json['professorName']?.toString() ?? '',
      lastLessonStart: json['lastLessonStart'] == null ? null : DateTime.tryParse(json['lastLessonStart'].toString()),
      lastLessonEnd: json['lastLessonEnd'] == null ? null : DateTime.tryParse(json['lastLessonEnd'].toString()),
    );
  }
}
