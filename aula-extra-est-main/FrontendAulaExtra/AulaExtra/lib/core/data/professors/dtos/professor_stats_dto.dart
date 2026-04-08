class ProfessorStatsDto {
  const ProfessorStatsDto({
    required this.lessonsCount,
    required this.avgRating,
    required this.reviewCount,
  });

  final int lessonsCount;
  final double avgRating;
  final int reviewCount;

  static num _num(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int _int(Map<String, dynamic> json, String key) =>
      _num(json, key).toInt();

  static double _double(Map<String, dynamic> json, String key) =>
      _num(json, key).toDouble();

  factory ProfessorStatsDto.fromJson(Map<String, dynamic> json) {
    // Accept both camelCase and PascalCase payloads.
    final lessons = _int(json, 'lessonsCount');
    final lessons2 = lessons != 0 ? lessons : _int(json, 'LessonsCount');

    final rating = _double(json, 'avgRating');
    final rating2 = rating != 0 ? rating : _double(json, 'AvgRating');

    final reviews = _int(json, 'reviewCount');
    final reviews2 = reviews != 0 ? reviews : _int(json, 'ReviewCount');

    return ProfessorStatsDto(
      lessonsCount: lessons2,
      avgRating: rating2,
      reviewCount: reviews2,
    );
  }
}
