class ProfessorAlunoDto {
  ProfessorAlunoDto({
    required this.id,
    required this.username,
    required this.name,
    this.firstName,
    this.lastName,
    required this.avatarUrl,
    required this.subjects,
    required this.interestSubjects,
    required this.lastLessonDate,
    required this.progress,
    this.submittedReviewsToProfessores,
    this.submittedReviewsToTutores,
    this.submittedReviewsToPsicologos,
  });

  final String id;
  final String username;
  final String name;
  final String? firstName;
  final String? lastName;
  final String avatarUrl;
  final List<String> subjects;
  final List<String> interestSubjects;
  final String lastLessonDate;
  final double progress;
  final int? submittedReviewsToProfessores;
  final int? submittedReviewsToTutores;
  final int? submittedReviewsToPsicologos;

  int get submittedReviewsProfessores => submittedReviewsToProfessores ?? 0;
  int get submittedReviewsTutores => submittedReviewsToTutores ?? 0;
  int get submittedReviewsPsicologos => submittedReviewsToPsicologos ?? 0;

  int get submittedReviewsTotal =>
      submittedReviewsProfessores +
      submittedReviewsTutores +
      submittedReviewsPsicologos;

  static int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _normalizeSubjects(dynamic rawSubjects) {
    final values = switch (rawSubjects) {
      List<dynamic>() => rawSubjects,
      _ => const <dynamic>[],
    };

    final unique = <String>[];
    final seen = <String>{};

    for (final value in values) {
      final subject = value.toString().trim();
      if (subject.isEmpty) continue;
      final key = subject.toLowerCase();
      if (seen.add(key)) {
        unique.add(subject);
      }
    }

    return unique;
  }

  String get fullName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final combined = '$first $last'.trim();
    if (combined.isNotEmpty) return combined;

    final fallbackName = name.trim();
    if (fallbackName.isNotEmpty &&
        fallbackName.toLowerCase() != username.trim().toLowerCase()) {
      return fallbackName;
    }

    return username.trim().isEmpty ? 'Sem Nome' : username.trim();
  }

  factory ProfessorAlunoDto.fromJson(Map<String, dynamic> json) {
    final reviewStats = json['reviewStats'];
    final reviewStatsMap = reviewStats is Map<String, dynamic>
        ? reviewStats
        : const <String, dynamic>{};

    final interests = _normalizeSubjects(
      json['interestSubjects'] ??
          json['interests'] ??
          json['disciplinasInteresse'] ??
          json['subjects'],
    );

    return ProfessorAlunoDto(
      id: json['id']?.toString() ?? '',
      username:
          json['username']?.toString() ??
          json['Username']?.toString() ??
          json['name']?.toString() ??
          '',
      name: json['name']?.toString() ?? 'Sem Nome',
      firstName: json['firstName']?.toString() ?? json['FirstName']?.toString(),
      lastName: json['lastName']?.toString() ?? json['LastName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      subjects: _normalizeSubjects(json['subjects']),
      interestSubjects: interests,
      lastLessonDate: json['lastLessonDate']?.toString() ?? '-',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      submittedReviewsToProfessores: _readInt(
        json['submittedReviewsToProfessores'] ??
            json['submittedEvaluationsToProfessores'] ??
            reviewStatsMap['professores'] ??
            reviewStatsMap['professor'],
      ),
      submittedReviewsToTutores: _readInt(
        json['submittedReviewsToTutores'] ??
            json['submittedEvaluationsToTutores'] ??
            reviewStatsMap['tutores'] ??
            reviewStatsMap['tutor'],
      ),
      submittedReviewsToPsicologos: _readInt(
        json['submittedReviewsToPsicologos'] ??
            json['submittedEvaluationsToPsicologos'] ??
            reviewStatsMap['psicologos'] ??
            reviewStatsMap['psicologo'],
      ),
    );
  }
}
