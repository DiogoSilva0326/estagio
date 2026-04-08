class StudentAreaSummaryDto {
  const StudentAreaSummaryDto({
    required this.completedLessons,
    this.nextLessonStart,
    this.nextLessonEnd,
    this.nextLessonTitle,
    this.nextLessonProfessorName,
    this.nextLessonDisciplinaName,
  });

  final int completedLessons;
  final DateTime? nextLessonStart;
  final DateTime? nextLessonEnd;
  final String? nextLessonTitle;
  final String? nextLessonProfessorName;
  final String? nextLessonDisciplinaName;

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _string(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  factory StudentAreaSummaryDto.fromJson(Map<String, dynamic> json) {
    return StudentAreaSummaryDto(
      completedLessons: _int(json['completedLessons'] ?? json['CompletedLessons']),
      nextLessonStart: _date(json['nextLessonStart'] ?? json['NextLessonStart']),
      nextLessonEnd: _date(json['nextLessonEnd'] ?? json['NextLessonEnd']),
      nextLessonTitle: _string(json['nextLessonTitle'] ?? json['NextLessonTitle']),
      nextLessonProfessorName: _string(json['nextLessonProfessorName'] ?? json['NextLessonProfessorName']),
      nextLessonDisciplinaName: _string(json['nextLessonDisciplinaName'] ?? json['NextLessonDisciplinaName']),
    );
  }
}