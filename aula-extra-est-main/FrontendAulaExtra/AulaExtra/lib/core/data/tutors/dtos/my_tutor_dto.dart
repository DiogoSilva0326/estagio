class MyTutorDto {
  const MyTutorDto({
    required this.professorId,
    required this.tutorUserId,
    required this.tutorUsername,
    required this.tutorName,
    required this.avatarUrl,
    required this.subjects,
    required this.lastLessonSubject,
    required this.lastLessonStart,
    required this.rating,
    required this.reviewCount,
    required this.progress,
  });

  final String professorId;
  final String tutorUserId;
  final String? tutorUsername;
  final String tutorName;
  final String? avatarUrl;
  final List<String> subjects;
  final String? lastLessonSubject;
  final DateTime? lastLessonStart;
  final double? rating;
  final int reviewCount;
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

    List<String> asStringList(dynamic v) {
      if (v is! List) return const <String>[];
      return v
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    int asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return MyTutorDto(
      professorId:
          asString(json['professorId']) ?? asString(json['idProfessor']) ?? '',
      tutorUserId:
          asString(json['tutorUserId']) ?? asString(json['idUser']) ?? '',
      tutorUsername:
          asString(json['tutorUsername']) ?? asString(json['username']),
      tutorName: asString(json['tutorName']) ?? asString(json['name']) ?? '—',
      avatarUrl:
          asString(json['avatarUrl']) ??
          asString(json['AvatarUrl']) ??
          asString(json['photo']) ??
          asString(json['Photo']),
      subjects: asStringList(json['subjects'] ?? json['Subjects']),
      lastLessonSubject:
          asString(json['lastLessonSubject']) ?? asString(json['LastLessonSubject']),
      lastLessonStart: asDateTime(json['lastLessonStart'] ?? json['LastLessonStart']),
      rating: asDouble(json['rating'] ?? json['Rating']),
      reviewCount: asInt(json['reviewCount'] ?? json['ReviewCount']),
      progress: (asDouble(json['progress']) ?? 0).clamp(0, 1),
    );
  }
}
