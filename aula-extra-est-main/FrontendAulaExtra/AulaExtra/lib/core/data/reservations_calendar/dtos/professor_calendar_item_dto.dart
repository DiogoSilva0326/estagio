class ProfessorCalendarItemDto {
  const ProfessorCalendarItemDto({
    required this.idReservation,
    required this.idLesson,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.lessonTitle,
    required this.studentName,
    required this.disciplinaName,
    this.targetRole,
  });

  final String idReservation;
  final String idLesson;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String lessonTitle;
  final String studentName;
  final String disciplinaName;
  final String? targetRole;

  static String _readString(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final value = json[pascal] ?? json[camel];
    if (value == null) {
      throw const ProfessorCalendarException('Resposta inválida do servidor');
    }
    return value.toString();
  }

  static String? _readOptionalString(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final value = json[pascal] ?? json[camel];
    return value?.toString();
  }

  static DateTime _readDateTime(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final value = json[pascal] ?? json[camel];
    if (value == null) {
      throw const ProfessorCalendarException('Resposta inválida do servidor');
    }
    return DateTime.parse(value.toString()).toLocal();
  }

  factory ProfessorCalendarItemDto.fromJson(Map<String, dynamic> json) {
    return ProfessorCalendarItemDto(
      idReservation: _readString(json, 'IdReservation', 'idReservation'),
      idLesson: _readString(json, 'IdLesson', 'idLesson'),
      startTime: _readDateTime(json, 'StartTime', 'startTime'),
      endTime: _readDateTime(json, 'EndTime', 'endTime'),
      status: _readString(json, 'Status', 'status'),
      lessonTitle: _readString(json, 'LessonTitle', 'lessonTitle'),
      studentName: _readString(json, 'StudentName', 'studentName'),
      disciplinaName: _readString(json, 'DisciplinaName', 'disciplinaName'),
      targetRole: _readOptionalString(json, 'TargetRole', 'targetRole'),
    );
  }
}

class ProfessorCalendarException implements Exception {
  const ProfessorCalendarException(this.message);

  final String message;

  @override
  String toString() => message;
}
