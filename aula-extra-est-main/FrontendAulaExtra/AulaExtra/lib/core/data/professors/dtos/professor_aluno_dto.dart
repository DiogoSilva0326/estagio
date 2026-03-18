class ProfessorAlunoDto {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> subjects;
  final String lastLessonDate;
  final double progress;

  ProfessorAlunoDto({
    required this.id,
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
      avatarUrl: json['avatarUrl'] ?? '',
      subjects: List<String>.from(json['subjects'] ?? []),
      lastLessonDate: json['lastLessonDate'] ?? '-',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}