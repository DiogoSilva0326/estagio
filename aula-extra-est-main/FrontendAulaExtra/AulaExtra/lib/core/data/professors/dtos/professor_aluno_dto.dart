class ProfessorAlunoDto {
  final String id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String avatarUrl;
  final List<String> subjects;
  final String lastLessonDate;
  final double progress;

  ProfessorAlunoDto({
    required this.id,
    this.firstName,
    this.lastName,
    required this.name,
    required this.avatarUrl,
    required this.subjects,
    required this.lastLessonDate,
    required this.progress,
  });

  factory ProfessorAlunoDto.fromJson(Map<String, dynamic> json) {
    return ProfessorAlunoDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Sem Nome',
      firstName: json['firstName']?.toString() ?? json['FirstName']?.toString(),
      lastName: json['lastName']?.toString() ?? json['LastName']?.toString(),
      avatarUrl: json['avatarUrl'] ?? '',
      subjects: List<String>.from(json['subjects'] ?? []),
      lastLessonDate: json['lastLessonDate'] ?? '-',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}