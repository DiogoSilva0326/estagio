class ProfessorEvaluationsOverviewDto {
  ProfessorEvaluationsOverviewDto({
    required this.professorSummary,
    required this.lessonSummary,
    required this.professorReviews,
    required this.lessonReviews,
  });

  final ProfessorEvaluationSummaryDto professorSummary;
  final ProfessorEvaluationSummaryDto lessonSummary;
  final List<ProfessorEvaluationReviewDto> professorReviews;
  final List<ProfessorLessonEvaluationReviewDto> lessonReviews;

  factory ProfessorEvaluationsOverviewDto.fromJson(Map<String, dynamic> json) {
    return ProfessorEvaluationsOverviewDto(
      professorSummary: ProfessorEvaluationSummaryDto.fromJson(
        _asMap(json['professorSummary']),
      ),
      lessonSummary: ProfessorEvaluationSummaryDto.fromJson(
        _asMap(json['lessonSummary']),
      ),
      professorReviews: _asList(json['professorReviews'])
          .map(ProfessorEvaluationReviewDto.fromJson)
          .toList(growable: false),
      lessonReviews: _asList(json['lessonReviews'])
          .map(ProfessorLessonEvaluationReviewDto.fromJson)
          .toList(growable: false),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, innerValue) => MapEntry(key.toString(), innerValue),
          ),
        )
        .toList(growable: false);
  }
}

class ProfessorEvaluationSummaryDto {
  ProfessorEvaluationSummaryDto({
    required this.averageRating,
    required this.totalReviews,
  });

  final double averageRating;
  final int totalReviews;

  factory ProfessorEvaluationSummaryDto.fromJson(Map<String, dynamic> json) {
    return ProfessorEvaluationSummaryDto(
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
    );
  }
}

class ProfessorEvaluationReviewDto {
  ProfessorEvaluationReviewDto({
    required this.id,
    required this.studentName,
    required this.studentAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String studentName;
  final String? studentAvatarUrl;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  factory ProfessorEvaluationReviewDto.fromJson(Map<String, dynamic> json) {
    return ProfessorEvaluationReviewDto(
      id: (json['idProfessorFeedback'] ?? '').toString(),
      studentName: (json['studentName'] ?? '').toString(),
      studentAvatarUrl: _asNullableString(json['studentAvatarUrl']),
      rating: _asInt(json['rating']),
      comment: _asNullableString(json['comment']),
      createdAt: _asDateTime(json['createdAt']),
    );
  }
}

class ProfessorLessonEvaluationReviewDto {
  ProfessorLessonEvaluationReviewDto({
    required this.id,
    required this.lessonId,
    required this.studentName,
    required this.studentAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.lessonTitle,
    required this.scheduledStart,
    required this.scheduledEnd,
  });

  final String id;
  final String lessonId;
  final String studentName;
  final String? studentAvatarUrl;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final String lessonTitle;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;

  factory ProfessorLessonEvaluationReviewDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessorLessonEvaluationReviewDto(
      id: (json['idLessonFeedback'] ?? '').toString(),
      lessonId: (json['idLesson'] ?? '').toString(),
      studentName: (json['studentName'] ?? '').toString(),
      studentAvatarUrl: _asNullableString(json['studentAvatarUrl']),
      rating: _asInt(json['rating']),
      comment: _asNullableString(json['comment']),
      createdAt: _asDateTime(json['createdAt']),
      lessonTitle: (json['lessonTitle'] ?? 'Aula').toString(),
      scheduledStart: _asDateTime(json['scheduledStart']),
      scheduledEnd: _asDateTime(json['scheduledEnd']),
    );
  }
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
