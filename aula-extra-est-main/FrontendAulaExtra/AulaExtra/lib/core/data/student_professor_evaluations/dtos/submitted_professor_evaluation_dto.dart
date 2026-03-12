class SubmittedProfessorEvaluationDto {
  SubmittedProfessorEvaluationDto({
    required this.professorFeedbackId,
    required this.professorId,
    required this.professorName,
    required this.rating,
    required this.comments,
    required this.createdAt,
  });

  final String professorFeedbackId;
  final String professorId;
  final String professorName;
  final int? rating;
  final String? comments;
  final DateTime? createdAt;

  factory SubmittedProfessorEvaluationDto.fromJson(Map<String, dynamic> json) {
    return SubmittedProfessorEvaluationDto(
      professorFeedbackId: json['professorFeedbackId']?.toString() ?? '',
      professorId: json['professorId']?.toString() ?? '',
      professorName: json['professorName']?.toString() ?? '',
      rating: json['rating'] is int ? json['rating'] as int : int.tryParse(json['rating']?.toString() ?? ''),
      comments: json['comments']?.toString(),
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'].toString()),
    );
  }
}
