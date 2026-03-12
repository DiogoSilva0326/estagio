class MyTutorDto {
  const MyTutorDto({
    required this.professorId,
    required this.tutorUserId,
    required this.tutorName,
    required this.lastLessonSubject,
    required this.lastLessonStart,
    required this.rating,
    required this.progress,
  });

  final String professorId;
  final String tutorUserId;
  final String tutorName;
  final String? lastLessonSubject;
  final DateTime? lastLessonStart;
  final double? rating;
  final double progress; // 0..1

  factory MyTutorDto.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic v) => v is String ? v : null;
    double? asDouble(dynamic v) => v is num ? v.toDouble() : null;

    DateTime? asDateTime(dynamic v) {
      if (v is String && v.trim().isNotEmpty) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return MyTutorDto(
      professorId: asString(json['professorId']) ?? asString(json['idProfessor']) ?? '',
      tutorUserId: asString(json['tutorUserId']) ?? asString(json['idUser']) ?? '',
      tutorName: asString(json['tutorName']) ?? asString(json['name']) ?? '—',
      lastLessonSubject: asString(json['lastLessonSubject']),
      lastLessonStart: asDateTime(json['lastLessonStart']),
      rating: asDouble(json['rating']),
      progress: (asDouble(json['progress']) ?? 0).clamp(0, 1),
    );
  }
}
