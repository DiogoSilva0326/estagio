class StudentCalendarItemDto {
  const StudentCalendarItemDto({
    required this.idReservation,
    required this.idLesson,
    required this.professorUserId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.lessonTitle,
    required this.professorName,
    required this.disciplinaName,
  });

  final String idReservation;
  final String idLesson;
  final String? professorUserId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String lessonTitle;
  final String professorName;
  final String disciplinaName;

  static String _readString(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final v = json[pascal] ?? json[camel];
    if (v == null) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }
    return v.toString();
  }

  static DateTime _readDateTime(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final v = json[pascal] ?? json[camel];
    if (v == null) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }
    return DateTime.parse(v.toString()).toLocal();
  }

  factory StudentCalendarItemDto.fromJson(Map<String, dynamic> json) {
    return StudentCalendarItemDto(
      idReservation: _readString(json, 'IdReservation', 'idReservation'),
      idLesson: _readString(json, 'IdLesson', 'idLesson'),
      professorUserId: (json['ProfessorUserId'] ?? json['professorUserId'])
          ?.toString(),
      startTime: _readDateTime(json, 'StartTime', 'startTime'),
      endTime: _readDateTime(json, 'EndTime', 'endTime'),
      status: _readString(json, 'Status', 'status'),
      lessonTitle: _readString(json, 'LessonTitle', 'lessonTitle'),
      professorName: _readString(json, 'ProfessorName', 'professorName'),
      disciplinaName: _readString(json, 'DisciplinaName', 'disciplinaName'),
    );
  }
}

class StudentCalendarException implements Exception {
  const StudentCalendarException(this.message);
  final String message;

  @override
  String toString() => message;
}
